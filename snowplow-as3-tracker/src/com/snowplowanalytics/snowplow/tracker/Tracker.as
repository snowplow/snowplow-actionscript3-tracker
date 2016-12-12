/*
* Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
*
* This program is licensed to you under the Apache License Version 2.0,
* and you may not use this file except in compliance with the Apache License Version 2.0.
* You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
*
* Unless required by applicable law or agreed to in writing,
* software distributed under the Apache License Version 2.0 is distributed on an
* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.
*/

package com.snowplowanalytics.snowplow.tracker
{
	import adobe.utils.CustomActions;
	
	import com.adobe.crypto.SHA1;
	import com.adobe.net.URI;
	import com.adobe.serialization.json.JSON;
	import com.snowplowanalytics.snowplow.tracker.emitter.Emitter;
	import com.snowplowanalytics.snowplow.tracker.payload.IPayload;
	import com.snowplowanalytics.snowplow.tracker.payload.SchemaPayload;
	import com.snowplowanalytics.snowplow.tracker.payload.TrackerPayload;
	import com.snowplowanalytics.snowplow.tracker.util.LocalStorage;
	import com.snowplowanalytics.snowplow.tracker.util.Preconditions;
	
	import de.aggro.utils.CookieUtil;
	
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.setTimeout;

	public class Tracker
	{
		private var domainUserId:String;
		
		private var base64Encoded:Boolean = true;
		private var emitter:Emitter;
		private var platform:String;
		private var appId:String;
		private var namespace:String;
		private var trackerVersion:String;
		private var subject:Subject;
		private var stage:Stage;
		
		private var playerType:String;
		private var playerVersion:String;
		private var isDebugger:Boolean;
		private var hasLocalStorage:Boolean;
		private var hasScriptAccess:Boolean;
		private var allowCookies:Boolean;
		
		private var configStorageNamePrefix:String = '_sp_';
		private var configStorageDomain:String = null;
		private var sharedObjectDomainHash:String = null;
		private var cookieDomainHash:String = null;
		private var configCookiePath:String = '/';
		private var configVisitorCookieTimeout:int = 63072000; // 2 years
		private var configSessionCookieTimeout:int = 1800; // 30 minutes
			
		private var businessUserId:String = null;	
		private var configUserFingerprintHashSeed:Number = 123412414;
		private var cookieUserFingerprint:Number;
		private var sharedObjectUserFingerprint:Number;

		private var customUrl:String = null;
		
		private var javascriptInfo:Object = null;
		private var browserFeatures:Object = null;
		
		private var localSharedObject:LocalStorage = null;
		private var localCookies:LocalStorage = null;
		private var localBoth:LocalStorage = null;

		/**
		 * @param emitter Emitter to which events will be sent
		 * @param subject Subject to be tracked
		 * @param namespace Identifier for the Tracker instance
		 * @param appId Application ID
		 * @param stage The flash stage object.  used for adding stage info to payload.
		 * @param base64Encoded Whether JSONs in the payload should be base-64 encoded
		 */
		function Tracker(emitter:Emitter, namespace:String, appId:String, subject:Subject = null, stage:Stage = null, base64Encoded:Boolean = true, allowCookies:Boolean = true) {
			this.emitter = emitter;
			this.appId = appId;
			this.base64Encoded = base64Encoded;
			this.namespace = namespace;
			this.subject = subject;
			this.trackerVersion = Version.TRACKER;
			this.platform = DevicePlatform.WEB;
			this.stage = stage;
			
			this.playerType = Capabilities.playerType;
			this.playerVersion = Capabilities.version;
			this.isDebugger = Capabilities.isDebugger;
			
			this.allowCookies = allowCookies;
			
			if (allowCookies) 
			{
				localSharedObject = new LocalStorage(LocalStorage.SHARED_OBJECT);
				localCookies = new LocalStorage(LocalStorage.COOKIES);
				localBoth = new LocalStorage(LocalStorage.BOTH);

				try 
				{
					SharedObject.getLocal("test");
					this.hasLocalStorage = true;
				} 
				catch (e:Error)
				{
					this.hasLocalStorage = false;
				}
			} 
			else 
			{
				this.hasLocalStorage = false;
			}
			
			this.hasScriptAccess = Util.isScriptAccessAllowed();
			
			var defaultJavascriptInfo:Object = {
				cd: Capabilities.screenColor
				, cookie: '0'
				, domain: ""
				, gears: null
				, hasLocalStorage: false
				, hasSessionStorage: false
				, javaEnabled: null
				, mimeTypes: null
				, pageUrl: null
				, platform: Capabilities.os
				, plugins: null
				, res: Capabilities.screenResolutionX + 'x' + Capabilities.screenResolutionY
				, title: null
				, userAgent: null
				, referrer: null
			};
			
			if (this.hasScriptAccess) {
	
				var javascriptInfoScript:String = "function getJavascriptInfo() {\n " +
					"function cookie(name, value, ttl, path, domain, secure) {\n ";
					if (allowCookies) { 
						javascriptInfoScript +=	"	\n " +
						"	if (arguments.length > 1) {\n " +
						"		return document.cookie = name + '=' + encodeURIComponent(value) +\n " +
						"		(ttl ? '; expires=' + new Date(+new Date()+(ttl*1000)).toUTCString() : '') +\n " +
						"		(path   ? '; path=' + path : '') +\n " +
						"		(domain ? '; domain=' + domain : '') +\n " +
						"		(secure ? '; secure' : '')\n " +
						"	}\n " +
						"	\n " +
						"	return decodeURIComponent((('; '+document.cookie).split('; '+name+'=')[1]||'').split(';')[0])\n ";
					} else {
						javascriptInfoScript +=	"	return null;\n ";
					}						
					javascriptInfoScript +=	"}\n " +
					"function hasCookies () {\n";
				    if (allowCookies) { 
						javascriptInfoScript +=	"	var cookieName = 'testcookie';\n" +
							"	\n" +
							"	if (typeof navigator.cookieEnabled == 'undefined') {\n" +
							"		cookie(cookieName, '1');\n" +
							"		return cookie(cookieName) === '1' ? '1' : '0';\n" +
							"	}\n" +
							"	\n" +
							"	return navigator.cookieEnabled ? '1' : '0';\n";
					} else {
						javascriptInfoScript +=	"	return false;\n";
					}
					javascriptInfoScript +=	"}\n" +
					"function getMimeTypes () {\n" +
					"	var mimeTypes = [];\n" +
					"	for (var i=0; i < navigator.mimeTypes.length; i++) {\n" +
					"		var mimeType = navigator.mimeTypes[i];\n" +
					"		mimeTypes.push({description: mimeType.description \n" +
					"						, enabledPlugin: typeof mimeType.enabledPlugin != 'undefined' \n" +
					"						, suffixes: mimeType.suffixes \n" +
					"						, type: mimeType.type \n" +
					"   				   });\n" +
					"	}\n" +
					"	return mimeTypes;\n" +
					"}\n" +
					"function getPlugins () {\n" +
					"	var plugins = [];\n" +
					"	for(var i = 0; i < navigator.plugins.length; i++)\n" +
					"	{\n" +
					"		plugins[i] = {};\n" +
					"		for(var j = 0; j < navigator.plugins[i].length; j++)\n" +
					"		{\n" +
					"			plugins[i][j] = {}\n" +
					"			plugins[i][j].suffixes = navigator.plugins[i][j].suffixes;\n" +
					"			plugins[i][j].type = navigator.plugins[i][j].type;\n" +
					"		}\n" +
					"		plugins[i].name = navigator.plugins[i].name;\n" +
					"		plugins[i].description = navigator.plugins[i].description;\n" +
					"	}\n" +
					"	return plugins;\n" +
					"}\n" +
					"function hasLocalStorage () {\n";
					if (allowCookies) { 
						javascriptInfoScript +=	"  try {\n" +
							"    return !!window.localStorage;\n" +
							"  } catch (e) {\n" +
							"    return true; // SecurityError when referencing it means it exists\n" +
							"  }\n";
					} else {
						javascriptInfoScript +=	"	return false;\n";
					}
					javascriptInfoScript += "}\n" +
					"function hasSessionStorage () {\n";
					if (allowCookies) { 
						javascriptInfoScript +=	"  try {\n" +
							"    return !!window.sessionStorage;\n" +
							"  } catch (e) {\n" +
							"    return true; // SecurityError when referencing it means it exists\n" +
							"  }\n";
					} else {
						javascriptInfoScript +=	"	return false;\n";
					}
					javascriptInfoScript +=	"}\n" +
					"return { " +
					"  cd: screen.colorDepth\n" +
					", cookie: hasCookies()\n" +
					", domain: document.domain\n" + 
					", gears: typeof window.GearsFactory == 'function' ? '1' : '0' \n" +
					", hasLocalStorage: hasLocalStorage()\n" +
					", hasSessionStorage: hasSessionStorage()\n" +
					", javaEnabled: typeof navigator.javaEnabled !== 'unknown' && !navigator.hasOwnProperty('javaEnabled') && navigator.javaEnabled() ? '1' : '0'\n" +
					", mimeTypes: getMimeTypes()\n" +
					", pageUrl: document.location.href\n" + 
					", platform: navigator.platform\n" + 
					", plugins: getPlugins()\n" + 
					", res: screen.width + 'x' + screen.height\n" +
					", title: document.title\n" + 
					", userAgent: navigator.userAgent \n" +
					"}; }";
				
				try { javascriptInfo = ExternalInterface.call(javascriptInfoScript); }
				catch(e:Error) { 
					javascriptInfo = defaultJavascriptInfo; 
				}								
				
				var fromQuerystringMethod:String = "function fromQuerystring (field, url) {\n" +
					"	var match = new RegExp('^[^#]*[?&]' + field + '=([^&#]*)').exec(url);\n" +
					"	if (!match) {\n" +
					"		return null;\n" +
					"	}\n" +
					"	return decodeURIComponent(match[1].replace(/\\+/g, ' '));\n" +
					"}";
				try {  ExternalInterface.call(fromQuerystringMethod); }	catch(e:Error) { }				
				
				var getReferrerMethod:String = "function getReferrer() { \n" +
					"var referrer = '';\n" +
					"var fromQs = fromQuerystring('referrer', window.location.href) || " +
					"fromQuerystring('referer', window.location.href);\n" +
					"\n" +
					"// Short-circuit\n" +
					"if (fromQs) {\n" +
					"	return fromQs;\n" +
					"}\n" +
					"\n" +
					"try {\n" +
					"	referrer = window.top.document.referrer;\n" +
					"} catch (e) {\n" +
					"	if (window.parent) {\n" +
					"		try {\n" +
					"			referrer = window.parent.document.referrer;\n" +
					"		} catch (e2) {\n" +
					"			referrer = '';\n" +
					"		}\n" +
					"	}\n" +
					"}\n" +
					"if (referrer === '') {\n" +
					"	referrer = document.referrer;\n" +
					"}\n" +
					"return referrer; }";
				
				if (javascriptInfo == null){
					javascriptInfo = defaultJavascriptInfo;
				}
				
				try { 
					javascriptInfo.referrer = ExternalInterface.call(getReferrerMethod);
				} 
				catch(e:Error){
					javascriptInfo.referrer = null; 
				}
				
				var locationArray:Array = Util.fixupUrl(javascriptInfo.domain, javascriptInfo.pageUrl, javascriptInfo.referrer);
				javascriptInfo.domain = Util.fixupDomain(locationArray[0]);
				javascriptInfo.pageUrl = locationArray[1];
				javascriptInfo.referrer = locationArray[2];
				
				browserFeatures = detectBrowserFeatures();
				
				cookieUserFingerprint = detectJavascriptSignature(configUserFingerprintHashSeed);
			} else { //we can not get javascript info since we have no script access
				javascriptInfo = defaultJavascriptInfo;
				cookieUserFingerprint = NaN;
			}
			
			sharedObjectUserFingerprint = detectFlashSignature(configUserFingerprintHashSeed);
			
			updateCookieDomainHash();
		}
		
		/**
		 * @param payload Payload builder
		 * @param context Custom context for the event
		 * @param timestamp Optional user-provided timestamp for the event
		 * @return A completed Payload
		 */
		protected function completePayload(payload:IPayload, 
										   context:Array,
										   timestamp:Number):IPayload {
			
				payload.add(Parameter.PLATFORM, this.platform);
				payload.add(Parameter.APPID, this.appId);
				payload.add(Parameter.NAMESPACE, this.namespace);
				payload.add(Parameter.TRACKER_VERSION, this.trackerVersion);
				payload.add(Parameter.EID, Util.getEventId());
				
				//Add page data
				payload.add(Parameter.PAGE_URL, customUrl == null ? javascriptInfo.pageUrl : customUrl);
				payload.add(Parameter.PAGE_TITLE, javascriptInfo.title);
				payload.add(Parameter.PAGE_REFR, javascriptInfo.referrer);
				
				// If timestamp is set to 0, generate one
				payload.add(Parameter.TIMESTAMP,
					(timestamp == 0 ? Util.getTimestamp() : String(timestamp)));
				
				// Add flash information
				if (context == null) {
					context = [];
				}
				
				var flashData:TrackerPayload = new TrackerPayload();
				flashData.add(Parameter.FLASH_PLAYER_TYPE, playerType);
				flashData.add(Parameter.FLASH_VERSION, playerVersion);
				flashData.add(Parameter.FLASH_IS_DEBUGGER, isDebugger);
				flashData.add(Parameter.FLASH_HAS_LOCAL_STORAGE, hasLocalStorage);
				flashData.add(Parameter.FLASH_HAS_SCRIPT_ACCESS, hasScriptAccess);
				if (stage != null) {
					try
					{
						flashData.add(Parameter.FLASH_STAGE_SIZE, { "width": stage.stageWidth, "height": stage.stageHeight});	
					}
					catch (e:Error)
					{
						flashData.add(Parameter.FLASH_STAGE_SIZE, { "width": -1, "height": -1});
						trace("Snowplow Tracker: We do not control the stage, so tracking stage size -1, -1");
					}
				}				

				var flashPayload:SchemaPayload = new SchemaPayload();
				flashPayload.setSchema(Constants.SCHEMA_FLASH);
				flashPayload.setData(flashData.getMap());

				addBrowserData(payload, flashPayload);
				
				context.push(flashPayload);
				
				// Encodes context data
				if (context != null && context.length > 0) {
					var envelope:SchemaPayload = new SchemaPayload();
					envelope.setSchema(Constants.SCHEMA_CONTEXTS);
					
					// We can do better here, rather than re-iterate through the list
					var contextDataList:Array = [];
					for each(var schemaPayload:SchemaPayload in context) {
						contextDataList.push(schemaPayload.getMap());
					}
					
					envelope.setData(contextDataList);
					payload.addMap(envelope.getMap(), this.base64Encoded, Parameter.CONTEXT_ENCODED, Parameter.CONTEXT);
				}
				
				if (this.subject != null) {
					payload.addMap(Util.copyObject(subject.getSubject(), true));
				}
				
				return payload;
			}
		
		public function setPlatform(platform:String):void {
			this.platform = platform;
		}
		
		public function getPlatform():String {
			return this.platform;
		}
		
		public function setReferrerUrl(url:String):void {
			javascriptInfo.referrer = url;
		}

		public function getReferrerUrl():String {
			return javascriptInfo.referrer;
		}
		
		public function setCustomUrl(url:String):void {
			customUrl = url;
		}
		
		public function getCustomUrl():String {
			return customUrl;
		}
		
		protected function setTrackerVersion(version:String):void {
			this.trackerVersion = version;
		}
		
		private function addTrackerPayload(payload:IPayload):void {
			this.emitter.addToBuffer(payload);
		}
		
		public function setSubject(subject:Subject):void {
			this.subject = subject;
		}
		
		public function getSubject():Subject {
			return this.subject;
		}
		
		public function getCookieUserFingerprint():Number {
			return cookieUserFingerprint;
		}
		
		public function getSharedObjectUserFingerprint():Number {
			return sharedObjectUserFingerprint;
		}
		
		/**
		* Update domain hash
		*/
		public function updateCookieDomainHash():void {
			var stringToHash:String = (configStorageDomain || javascriptInfo.domain) + (configCookiePath || '/');
			var hash:String = SHA1.hash(stringToHash);
			cookieDomainHash = hash.slice(0, 4); // 4 hexits = 16 bits
		}
		
		/**
		 * Update domain hash
		 */
		public function updateSharedObjectDomainHash():void {
			var stringToHash:String = (configStorageDomain || javascriptInfo.domain) + (configCookiePath || '/');
			var hash:String = SHA1.hash(stringToHash);
			sharedObjectDomainHash = hash.slice(0, 4); // 4 hexits = 16 bits
		}
		
		/**
		 * Set first-party cookie domain
		 *
		 * @param string domain
		 */
		public function setCookieDomain (domain:String):void {
			configStorageDomain = Util.fixupDomain(domain);
			updateCookieDomainHash();
		}
		
		/**
		 * Set visitor cookie timeout (in seconds)
		 *
		 * @param int timeout
		 */
		public function setVisitorCookieTimeout (timeout:int):void {
			configVisitorCookieTimeout = timeout;
		}
		
		/**
		 * Set session cookie timeout (in seconds)
		 *
		 * @param int timeout
		 */
		public function setSessionCookieTimeout (timeout:int):void {
			configSessionCookieTimeout = timeout;
		}		
		
		/**
		 * Set first-party cookie path
		 *
		 * @param string domain
		 */
		public function setCookiePath (path:String):void {
			configCookiePath = path;
			updateCookieDomainHash();
		}
		
		/**
		 * Set first-party cookie name prefix
		 *
		 * @param string cookieNamePrefix
		 */
		public function setStorageNamePrefix (storageNamePrefix:String):void {
			configStorageNamePrefix = storageNamePrefix;
		}
		
		/**
		 * Get page url
		 */
		public function getPageUrl ():String {
			return javascriptInfo.pageUrl;
		}
		
		/**
		* Get storage name with prefix and domain hash
		*/
		public function getSnowplowCookieName (baseName:String):String {
			return configStorageNamePrefix + baseName + '.' + cookieDomainHash;
		}

		/**
		 * Get storage name with prefix and domain hash
		 */
		public function getSnowplowSharedObjectName (baseName:String):String {
			return configStorageNamePrefix + baseName + '.' + sharedObjectDomainHash;
		}
		
		/**
		* storage getter.
		*/
		public function getSnowplowSharedObjectValue(storageName:String):String {
			if (localSharedObject == null) {
				return null;
			} else {
				return localSharedObject.getLocal(getSnowplowSharedObjectName(storageName));
			}
		}
		
		/**
		 * storage getter.
		 */
		public function getSnowplowCookieValue(cookie:String):String {
			if (localCookies == null) {
				return null;
			} else {
				return localCookies.getLocal(getSnowplowCookieName(cookie));
			}
		}
		
		/**
		 * Returns browser features (plugins, resolution, cookies)
		 *
		 * @return Object containing browser features
		 */
		public function detectBrowserFeatures():Object {
			var i:String;
			var mimeType:Object;
			var features:Object = {};
			var pluginMap:Object = {
				// document types
				pdf: 'application/pdf',
				
				// media players
				qt: 'video/quicktime',
				realp: 'audio/x-pn-realaudio-plugin',
				wma: 'application/x-mplayer2',
				
				// interactive multimedia
				dir: 'application/x-director',
				fla: 'application/x-shockwave-flash',
				
				// RIA
				java: 'application/x-java-vm',
				gears: 'application/x-googlegears',
				ag: 'application/x-silverlight'
			};
			
			// General plugin detection
			if (javascriptInfo.mimeTypes && javascriptInfo.mimeTypes.length > 0) {
				for (i in pluginMap) {
					mimeType = Util.findFirstItemInArray(javascriptInfo.mimeTypes, "type", pluginMap[i]);
					features[i] = (mimeType && mimeType.enabledPlugin) ? '1' : '0';
				}
			}
			
			// Safari and Opera
			// IE6/IE7 navigator.javaEnabled can't be aliased, so test directly
			features.java = javascriptInfo.java;
			
			// Firefox
			features.gears = javascriptInfo.gears;
			
			// Other browser features
			features.res = javascriptInfo.res;
			features.cd = javascriptInfo.cd;
			features.cookie = javascriptInfo.cookie;
			
			return features;
		};
		
		/**
		* Sets the Visitor ID storage: either the first time loadDomainUserIdStorage is called
		* or when there is a new visit or a new page view
		*/
		public function setDomainUserIdCookie(_domainUserId:String, createTs:String, visitCount:String, nowTs:String, lastVisitTs:String):void {
			if (localCookies != null) {
				localCookies.setLocal(getSnowplowCookieName('id'), 
					_domainUserId + '.' + createTs + '.' + visitCount + '.' + nowTs + '.' + lastVisitTs, 
					configVisitorCookieTimeout, 
					configCookiePath, 
					configStorageDomain);
			}
		}
		
		/**
		 * Sets the Visitor ID storage: either the first time loadDomainUserIdStorage is called
		 * or when there is a new visit or a new page view
		 */
		public function setDomainUserIdSharedObject(_domainUserId:String, createTs:String, visitCount:String, nowTs:String, lastVisitTs:String):void {
			if (localSharedObject != null) {
				localSharedObject.setLocal(getSnowplowSharedObjectName('id'), 
					_domainUserId + '.' + createTs + '.' + visitCount + '.' + nowTs + '.' + lastVisitTs);
			}
		}
		
		/**
		* Load visitor ID cookie
		*/
		public function loadDomainUserIdCookie():Array {
			var now:Date = new Date();
			var	nowTs:Number = Math.round(now.getTime() / 1000);
			var	id:String = localCookies == null ? null : localCookies.getLocal('id');
			var	tmpContainer:Array;
			
			if (id) {
				tmpContainer = id.split('.');
				// New visitor set to 0 now
				tmpContainer.unshift('0');
			} else {
				// Domain - generate a pseudo-unique ID to fingerprint this user;
				// Note: this isn't a RFC4122-compliant UUID

				if (!domainUserId) {
					domainUserId = SHA1.hash(
						(javascriptInfo.userAgent || '') +
						(javascriptInfo.platform || '') +
						JSON.encode(browserFeatures) + nowTs
					).slice(0, 16); // 16 hexits = 64 bits
				}
				
				tmpContainer = [
					// New visitor
					'1',
					// Domain user ID
					domainUserId,
					// Creation timestamp - seconds since Unix epoch
					nowTs,
					// visitCount - 0 = no previous visit
					0,
					// Current visit timestamp
					nowTs,
					// Last visit timestamp - blank meaning no previous visit
					''
				];
			}
			return tmpContainer;
		}
		
		/**
		 * Load visitor ID shared object
		 */
		public function loadDomainUserIdSharedObject():Array {
			var now:Date = new Date();
			var	nowTs:Number = Math.round(now.getTime() / 1000);
			var	id:String = localSharedObject == null ? null : localSharedObject.getLocal('id');
			var	tmpContainer:Array;
			
			if (id) {
				tmpContainer = id.split('.');
				// New visitor set to 0 now
				tmpContainer.unshift('0');
			} else {
				// Domain - generate a pseudo-unique ID to fingerprint this user;
				// Note: this isn't a RFC4122-compliant UUID
				
				if (!domainUserId) {
					domainUserId = SHA1.hash(
						(javascriptInfo.userAgent || '') +
						(javascriptInfo.platform || '') +
						JSON.encode(browserFeatures) + nowTs
					).slice(0, 16); // 16 hexits = 64 bits
				}
				
				tmpContainer = [
					// New visitor
					'1',
					// Domain user ID
					domainUserId,
					// Creation timestamp - seconds since Unix epoch
					nowTs,
					// visitCount - 0 = no previous visit
					0,
					// Current visit timestamp
					nowTs,
					// Last visit timestamp - blank meaning no previous visit
					''
				];
			}
			return tmpContainer;
		}
		
		/**
		 * Get the current user ID (as set previously
		 * with setUserId()).
		 *
		 * @return string Business-defined user ID
		 */
		public function getUserId ():String {
			return businessUserId;
		}
		
		/**
		 * Set the business-defined user ID for this user.
		 *
		 * @param string userId The business-defined user ID
		 */
		public function setUserId (userId:String):void {
			businessUserId = userId;
		}
		
		/**
		 * Set the business-defined user ID for this user using the location querystring.
		 * 
		 * @param string queryName Name of a querystring name-value pair
		 */
		public function setUserIdFromLocation (querystringField:String):void {
			try { 
				businessUserId = ExternalInterface.call("fromQuerystring", querystringField, javascriptInfo.pageUrl); }
			catch(e:Error) { }				
		}
		
		/**
		 * Set the business-defined user ID for this user using the referrer querystring.
		 * 
		 * @param string queryName Name of a querystring name-value pair
		 */
		public function setUserIdFromReferrer (querystringField:String):void {
			try { 
				businessUserId = ExternalInterface.call("fromQuerystring", querystringField, javascriptInfo.referrer); }
			catch(e:Error) { }				
		}
		
		/**
		 * Set the business-defined user ID for this user to the value of a storage.
		 * 
		 * @param string storageName Name of the storage whose value will be assigned to businessUserId
		 */
		public function setUserIdFromStorage (storageName:String):void {
			businessUserId = localBoth == null ? null : localBoth.getLocal(storageName);
		}
		
		/**
		 * @param number seed The seed used for MurmurHash3
		 */
		public function setUserFingerprintSeed (seed:Number):void {
			configUserFingerprintHashSeed = seed;
			cookieUserFingerprint = detectJavascriptSignature(configUserFingerprintHashSeed);
			sharedObjectUserFingerprint = detectFlashSignature(configUserFingerprintHashSeed);
		}
		
		/**
		 * AS Implementation for browser fingerprint.
		 * Does not require any external resources.
		 * Based on https://github.com/carlo/jquery-browser-fingerprint
		 * @return {number} 32-bit positive integer hash 
		 */
		public function detectJavascriptSignature (hashSeed:Number):Number {
			
			var fingerprint:Array = [
				javascriptInfo.userAgent,
				javascriptInfo.res + 'x' + javascriptInfo.cd,
				( new Date() ).getTimezoneOffset(),
				javascriptInfo.hasSessionStorage,
				javascriptInfo.hasLocalStorage
			];
			
			var plugins:Array = [];
			if (javascriptInfo.plugins)
			{
				for(var i:int = 0; i < javascriptInfo.plugins.length; i++)
				{
					var mt:Array = [];
					for(var j:int = 0; j < javascriptInfo.plugins[i].length; j++)
					{
						mt.push([javascriptInfo.plugins[i][j].type, javascriptInfo.plugins[i][j].suffixes]);
					}
					plugins.push([javascriptInfo.plugins[i].name + "::" + javascriptInfo.plugins[i].description, mt.join("~")]);
				}
			}
			return Util.murmurhash3_32_gc(fingerprint.join("###") + "###" + plugins.sort().join(";"), hashSeed);
		};
	
		/**
		 * AS Implementation for browser fingerprint.
		 * Does not require any external resources.
		 * Based on https://github.com/carlo/jquery-browser-fingerprint
		 * @return {number} 32-bit positive integer hash 
		 */
		public function detectFlashSignature (hashSeed:Number):Number {
			
			var jsonSignature:String = JSON.encode([Capabilities, System]);
						
			return Util.murmurhash3_32_gc(jsonSignature, hashSeed);
		};
		
		/**
		 * Gets the current viewport.
		 *
		 * Code based on:
		 * - http://andylangton.co.uk/articles/javascript/get-viewport-size-javascript/
		 * - http://responsejs.com/labs/dimensions/
		 */
		public function detectViewport ():String {
			var detectViewportString:String =  "function detectViewport () {\n" +
				"	var e = window, a = 'inner';\n" +
				"	if (!('innerWidth' in window)) {\n" +
				"		a = 'client';\n" +
				"		e = document.documentElement || document.body;\n" +
				"	}\n" +
				"	return e[a+'Width'] + 'x' + e[a+'Height'];\n" +
				"}";
			
			var vp:String;
			try { 
				vp = ExternalInterface.call(detectViewportString); 
			} catch(e:Error) { 
				vp = null;
			}	
			return vp;
		}
		
		/**
		 * Gets the dimensions of the current
		 * document.
		 *
		 * Code based on:
		 * - http://andylangton.co.uk/articles/javascript/get-viewport-size-javascript/
		 */
		public function detectDocumentSize ():String {
			var detectDocumentSizeString:String =  "function detectDocumentSize  () {\n" +
				"	var de = document.documentElement; // Alias\n" +
				"	var w = Math.max(de.clientWidth, de.offsetWidth, de.scrollWidth);\n" +
				"	var h = Math.max(de.clientHeight, de.offsetHeight, de.scrollHeight);\n" +
				"	return isNaN(w) || isNaN(h) ? '' : w + 'x' + h;\n" +
				"}";
			
			var ds:String;
			try { 
				ds = ExternalInterface.call(detectDocumentSizeString); 
			} catch(e:Error) { 
				ds = null;
			}	
			return ds;
		}
		
		/**
		* Attaches common web fields to every request
		* (resolution, url, referrer, etc.)
		* Also sets the required storage.
		*/
		public function addBrowserData(payload:IPayload, flashPayload:IPayload):void {
			var nowTs:String = Math.round(new Date().getTime() / 1000).toString();
			var	idname:String = getSnowplowCookieName('id');
			var	sesname:String = getSnowplowCookieName('ses');
			var	ses:String = getSnowplowCookieValue('ses'); // aka cookie.cookie(sesname)
			
			var	cookieId:Array = loadDomainUserIdCookie();
			var	cookieDomainUserId:String = cookieId[1]; // We could use the global (domainUserId) but this is better etiquette
			var cookieCreateTs:String = cookieId[2];
			var cookieVisitCount:Number = parseInt(cookieId[3]);
			var cookieCurrentVisitTs:String = cookieId[4];
			var cookieLastVisitTs:String = cookieId[5];
			
			var	sharedObjectId:Array = loadDomainUserIdSharedObject();
			var	sharedObjectDomainUserId:String = sharedObjectId[1]; // We could use the global (domainUserId) but this is better etiquette
			var sharedObjectCreateTs:String = sharedObjectId[2];
			var sharedObjectVisitCount:Number = parseInt(sharedObjectId[3]);
			var sharedObjectCurrentVisitTs:String = sharedObjectId[4];
			var sharedObjectLastVisitTs:String = sharedObjectId[5];
			
			// New session?
			if (!ses) {
				// New session (aka new visit)
				cookieVisitCount++;
				// Update the last visit timestamp
				cookieLastVisitTs = cookieCurrentVisitTs;
			}
			
			sharedObjectVisitCount++;
			
			// Build out the rest of the request
			payload.add(Parameter.VIEWPORT, detectViewport());
			payload.add(Parameter.DOCUMENT_SIZE, detectDocumentSize());
			payload.add(Parameter.VISIT_COUNT, isNaN(cookieVisitCount) ? "0" :  cookieVisitCount.toString());
			payload.add(Parameter.DOMAIN_USER_ID, cookieDomainUserId); // Set to our local variable
			payload.add(Parameter.USER_FINGERPRINT, cookieUserFingerprint.toString());
			payload.add(Parameter.UID, businessUserId);
			
			flashPayload.add(Parameter.SHARED_OBJECT_VISIT_COUNT, sharedObjectVisitCount);
			flashPayload.add(Parameter.SHARED_OBJECT_DOMAIN_USER_ID, sharedObjectDomainUserId); // Set to our local variable
			flashPayload.add(Parameter.SHARED_OBJECT_USER_FINGERPRINT, sharedObjectUserFingerprint);
			
			// Update storage
			setDomainUserIdSharedObject(sharedObjectDomainUserId, sharedObjectCreateTs, sharedObjectVisitCount.toString(), nowTs, sharedObjectLastVisitTs);

			if (hasScriptAccess && allowCookies) {
				setDomainUserIdCookie(cookieDomainUserId, cookieCreateTs, cookieVisitCount.toString(), nowTs, cookieLastVisitTs);
				// only use cookies for session.  flash local storage does not support a TTL.
				CookieUtil.setCookie(sesname, '*', configSessionCookieTimeout, configCookiePath, configStorageDomain);
			}
		}

		
		/**
		 * @param pageUrl URL of the viewed page
		 * @param pageTitle Title of the viewed page
		 * @param referrer Referrer of the page
		 * @param context Custom context for the event
		 * @param timestamp Optional user-provided timestamp for the event
		 */
		public function trackPageView(pageUrl:String, pageTitle:String, referrer:String, context:Array = null, timestamp:Number = 0):void 
		{
			if (context == null) context = [];

			// Precondition checks
			Preconditions.checkNotNull(pageUrl);
			Preconditions.checkArgument(!Util.isNullOrEmpty(pageUrl), "pageUrl cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(pageTitle), "pageTitle cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(referrer), "referrer cannot be empty");
			
			var payload:IPayload = new TrackerPayload();
			payload.add(Parameter.EVENT, Constants.EVENT_PAGE_VIEW);
			payload.add(Parameter.PAGE_URL, pageUrl);
			payload.add(Parameter.PAGE_TITLE, pageTitle);
			payload.add(Parameter.PAGE_REFR, referrer);
			
			completePayload(payload, context, timestamp);
			
			addTrackerPayload(payload);
		}
				
		/**
		 * @param category Category of the event
		 * @param action The event itself
		 * @param label Refer to the object the action is performed on
		 * @param property Property associated with either the action or the object
		 * @param value A value associated with the user action
		 * @param context Custom context for the event
		 * @param timestamp Optional user-provided timestamp for the event
		 */
		public function trackStructuredEvent(category:String, 
			action:String, 
			label:String, 
			property:String,
			value:int, 
			context:Array = null, 
			timestamp:Number = 0):void
		{
			if (context == null) context = [];

			// Precondition checks
			Preconditions.checkNotNull(label);
			Preconditions.checkNotNull(property);
			Preconditions.checkArgument(!Util.isNullOrEmpty(label), "label cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(property), "property cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(category), "category cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(action), "action cannot be empty");
			
			var payload:IPayload = new TrackerPayload();
			payload.add(Parameter.EVENT, Constants.EVENT_STRUCTURED);
			payload.add(Parameter.SE_CATEGORY, category);
			payload.add(Parameter.SE_ACTION, action);
			payload.add(Parameter.SE_LABEL, label);
			payload.add(Parameter.SE_PROPERTY, property);
			payload.add(Parameter.SE_VALUE, String(value));
			
			completePayload(payload, context, timestamp);
			
			addTrackerPayload(payload);
		}
		
		/**
		 *
		 * @param eventData The properties of the event. Has two field:
		 *                   A "data" field containing the event properties and
		 *                   A "schema" field identifying the schema against which the data is validated
		 * @param context Custom context for the event
		 * @param timestamp Optional user-provided timestamp for the event
		 */
		public function trackUnstructuredEvent(eventData:SchemaPayload, context:Array = null,
			timestamp:Number = 0):void 
		{
			if (context == null) context = [];

			var envelope:SchemaPayload = new SchemaPayload();
			envelope.setSchema(Constants.SCHEMA_UNSTRUCT_EVENT);
			envelope.setData(eventData.getMap());
			
			var payload:IPayload = new TrackerPayload();
			payload.add(Parameter.EVENT, Constants.EVENT_UNSTRUCTURED);
			payload.addMap(envelope.getMap(), base64Encoded,
				Parameter.UNSTRUCTURED_ENCODED, Parameter.UNSTRUCTURED);
			
			completePayload(payload, context, timestamp);
			
			addTrackerPayload(payload);
		}
		
		/**
		 * This is an internal method called by track_ecommerce_transaction. It is not for public use.
		 * @param order_id Order ID
		 * @param sku Item SKU
		 * @param price Item price
		 * @param quantity Item quantity
		 * @param name Item name
		 * @param category Item category
		 * @param currency The currency the price is expressed in
		 * @param context Custom context for the event
		 * @param timestamp Optional user-provided timestamp for the event
		 */
		protected function trackEcommerceTransactionItem(order_id:String, sku:String, price:Number,
			quantity:int, name:String, category:String,
			currency:String, context:Array,
			timestamp:Number):void 
		{
			// Precondition checks
			Preconditions.checkNotNull(name);
			Preconditions.checkNotNull(category);
			Preconditions.checkNotNull(currency);
			Preconditions.checkArgument(!Util.isNullOrEmpty(order_id), "order_id cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(sku), "sku cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(name), "name cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(category), "category cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(currency), "currency cannot be empty");
			
			var payload:IPayload = new TrackerPayload();
			payload.add(Parameter.EVENT, Constants.EVENT_ECOMM_ITEM);
			payload.add(Parameter.TI_ITEM_ID, order_id);
			payload.add(Parameter.TI_ITEM_SKU, sku);
			payload.add(Parameter.TI_ITEM_NAME, name);
			payload.add(Parameter.TI_ITEM_CATEGORY, category);
			payload.add(Parameter.TI_ITEM_PRICE, String(price));
			payload.add(Parameter.TI_ITEM_QUANTITY, String(quantity));
			payload.add(Parameter.TI_ITEM_CURRENCY, currency);
			
			completePayload(payload, context, timestamp);
			
			addTrackerPayload(payload);
		}
				
		/**
		 * @param order_id ID of the eCommerce transaction
		 * @param total_value Total transaction value
		 * @param affiliation Transaction affiliation
		 * @param tax_value Transaction tax value
		 * @param shipping Delivery cost charged
		 * @param city Delivery address city
		 * @param state Delivery address state
		 * @param country Delivery address country
		 * @param currency The currency the price is expressed in
		 * @param items The items in the transaction
		 * @param context Custom context for the event
		 * @param timestamp Optional user-provided timestamp for the event
		 */
		public function trackEcommerceTransaction(order_id:String, total_value:Number, affiliation:String,
			tax_value:Number, shipping:Number, city:String,
			state:String, country:String, currency:String,
			items:Array, context:Array = null,
			timestamp:Number = 0):void 
		{
			if (context == null) context = [];

			// Precondition checks
			Preconditions.checkNotNull(affiliation);
			Preconditions.checkNotNull(city);
			Preconditions.checkNotNull(state);
			Preconditions.checkNotNull(country);
			Preconditions.checkNotNull(currency);
			Preconditions.checkArgument(!Util.isNullOrEmpty(order_id), "order_id cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(affiliation), "affiliation cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(city), "city cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(state), "state cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(country), "country cannot be empty");
			Preconditions.checkArgument(!Util.isNullOrEmpty(currency), "currency cannot be empty");
			
			var payload:IPayload = new TrackerPayload();
			payload.add(Parameter.EVENT, Constants.EVENT_ECOMM);
			payload.add(Parameter.TR_ID, order_id);
			payload.add(Parameter.TR_TOTAL, String(total_value));
			payload.add(Parameter.TR_AFFILIATION, affiliation);
			payload.add(Parameter.TR_TAX, String(tax_value));
			payload.add(Parameter.TR_SHIPPING, String(shipping));
			payload.add(Parameter.TR_CITY, city);
			payload.add(Parameter.TR_STATE, state);
			payload.add(Parameter.TR_COUNTRY, country);
			payload.add(Parameter.TR_CURRENCY, currency);
			
			completePayload(payload, context, timestamp);
			
			for each(var item:TransactionItem in items) {
				trackEcommerceTransactionItem(
					String(item.get(Parameter.TI_ITEM_ID)),
					String(item.get(Parameter.TI_ITEM_SKU)),
					Number(item.get(Parameter.TI_ITEM_PRICE)),
					parseInt(item.get(Parameter.TI_ITEM_QUANTITY)),
					String(item.get(Parameter.TI_ITEM_NAME)),
					String(item.get(Parameter.TI_ITEM_CATEGORY)),
					String(item.get(Parameter.TI_ITEM_CURRENCY)),
					item.get(Parameter.CONTEXT),
					timestamp);
			}
			
			addTrackerPayload(payload);
		}
		
		
		/**
		 * @param name The name of the screen view event
		 * @param id Screen view ID
		 * @param context Custom context for the event
		 * @param timestamp Optional user-provided timestamp for the event
		 */
		public function trackScreenView(name:String, id:String, context:Array,
			timestamp:Number):void {
				Preconditions.checkArgument(name != null || id != null);
				var trackerPayload:TrackerPayload = new TrackerPayload();
				
				trackerPayload.add(Parameter.SV_NAME, name);
				trackerPayload.add(Parameter.SV_ID, id);
				
				var payload:SchemaPayload = new SchemaPayload();
				payload.setSchema(Constants.SCHEMA_SCREEN_VIEW);
				payload.setData(trackerPayload);
				
				trackUnstructuredEvent(payload, context, timestamp);
			}
	}
}