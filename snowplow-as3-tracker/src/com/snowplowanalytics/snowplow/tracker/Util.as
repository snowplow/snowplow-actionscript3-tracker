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
	import com.snowplowanalytics.snowplow.tracker.util.UUID;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Encoder;

	public class Util
	{
		public static function isNullOrEmpty(str:*):Boolean
		{
			return str == null || (str is String && (str as String).length == 0);
		}
		
		public static function padZeroes (value:*, places:int = 2):String
		{
			var str:String = value.toString();
			var zeroes:int = places - str.length;
			if (zeroes > 0)
			{
				for (var i:int=0;i<zeroes;i++)
				{
					str = "0" + str;
				}
			}
			return str;
		}
		
		private static function callCallback (dataFormat:String, loader:URLLoader, callback:Function):void
		{
			var result:*;
			
			switch (dataFormat)
			{
				case URLLoaderDataFormat.TEXT:
				case URLLoaderDataFormat.VARIABLES:
					result = loader.data;
					break;
				case URLLoaderDataFormat.BINARY:
				default:
					result = ByteArray(loader.data);
					break;
			}
			
			callback(result);
		}
		
		public static function getResponse	(
				url:String, 
				callback:Function, 
				errorCallback:Function, 
				method:String = "get", 
				postData:String = null, 
				dataFormat:String = "text"
			):void
		{
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(url);
			request.method = method;
			
			if (postData != null && method == URLRequestMethod.POST)
			{
				request.data = postData;
				request.contentType = "application/json; charset=utf-8";
			}
			
			loader.dataFormat = dataFormat;
			
			loader.addEventListener
				(
					Event.COMPLETE, 
					function (event:Event):void
					{
						if (callback != null)
						{
							callCallback(dataFormat, loader, callback);
						}
					}
				);
			
			loader.addEventListener
				(
					IOErrorEvent.IO_ERROR, 
					function (event:IOErrorEvent):void
					{
						if (event.type == "201")
						{
							if (callback != null)
							{
								callCallback(dataFormat, loader, callback);
							}
						}
						else
						{
							if (errorCallback != null)
							{
								errorCallback(event);
							}
						}
					}
				);
			
			loader.addEventListener
				(
					SecurityErrorEvent.SECURITY_ERROR, 
					function (event:SecurityErrorEvent):void
					{
						if (errorCallback != null)
						{
							errorCallback(event);
						}
					}
				);
			
			loader.load(request); 
		}
		
		public static function getEventId():String 
		{
			return UUID.generateGuid();
		}
		
		public static function getTimestamp():String {
			var date:Date = new Date();
			return date.time.toString();
		}
		
		public static function copyObject (object:Object, returnEmptyObjectIfNull:Boolean = false):Object  
		{ 
			if (object == null)
			{
				if (returnEmptyObjectIfNull)
					return {}
				else
					return null;
			}
			
			var newObject:Object = {};
			
			for (var key:String in object) {
				newObject[key] = object[key];
			}

			return newObject;
		}
		
		/* Addition functions
		*  Used to add different sources of key=>value pairs to a map.
		*  Map is then used to build "Associative array for getter function.
		*  Some use Base64 encoding
		*/
		public static function base64Encode(str:String):String {
			try {
				var encoder:Base64Encoder = new Base64Encoder();
				encoder.encode(str);
				var base64:String = encoder.flush();
				
				//make base64 url safe.
				base64 = base64.replace(/\+/g, "-");
				base64 = base64.replace(/\//g, "_");
				base64 = base64.replace(/=/g, "");
				base64 = base64.replace(/\n/g, "");
				base64 = base64.replace(/\r/g, "");
				base64 = base64.replace(/\t/g, "");
				
				return base64;
			} catch (e:Error) {
				trace(e.getStackTrace());
			}
			return null;
		}
		
		public static function getTransactionId():int 
		{ 
			return Math.round(Math.random() * 1000000);
	    }
		
		public static function clearArray (a:Array):void
		{
			a.splice(0, a.length);
		}
		
		public static function findFirstItemInArray (array:Array, prop:String, val:*):*
		{
			for each(var item:* in array)
			{
				if (item[prop] == val)
				{
					return item;
				}
			}
			
			return null;
		}
		
		/**
		* Return value from name-value pair in querystring 
		*/
		private static function fromQuerystring(field:String, url:String):String {
			var match:RegExp = new RegExp('^[^#]*[?&]' + field + '=([^&#]*)').exec(url);
			if (!match) {
				return null;
			}
			return decodeURIComponent(match[1].replace(/\+/g, ' '));
		};
		
		/**
		* Extract parameter from URL
		*/
		private static function getParameter(url:String, name:String):String {
			// scheme : // [username [: password] @] hostname [: port] [/ [path] [? query] [# fragment]]
			var e:RegExp = new RegExp('^(?:https?|ftp)(?::/*(?:[^?]+))([?][^#]+)');
			var	matches:* = e.exec(url);
			var	result:String = fromQuerystring(name, matches[1]);
			
			return result;
		}
		
		/**
		* Extract hostname from URL
		*/
		private static function getHostName(url:String):String {
			// scheme : // [username [: password] @] hostname [: port] [/ [path] [? query] [# fragment]]
			var e:RegExp = new RegExp('^(?:(?:https?|ftp):)/*(?:[^@]+@)?([^:/#]+)');
			var	matches:* = e.exec(url);
			
			return matches ? matches[1] : url;
		};
		
		/**
		* Test whether a string is an IP address
		*/
		private static function isIpAddress(str:String):Boolean {
			var IPRegExp:RegExp = new RegExp('^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
			return IPRegExp.test(str);
		}
		
		/**
		* If the hostname is an IP address, look for text indicating
		* that the page is cached by Yahoo
		*/
		private static function isYahooCachedPage(hostName:String):Boolean 
		{
			return false;
			var	initialDivText:String;
			var cachedIndicator:String;
			
			if (isIpAddress(hostName)) {
				try {
					initialDivText = ExternalInterface.call("function getInitialDivText() { return document.body.children[0].children[0].children[0].children[0].children[0].children[0].innerHTML; }");
					cachedIndicator = 'You have reached the cached page for';
					return initialDivText.slice(0, cachedIndicator.length) === cachedIndicator;
				} catch (e:Error) {
					return false;
				}
			} else {
				return false;
			}
		}
		
		/**
		* Fix-up domain
		*/
		public static function fixupDomain(domain:String):String {
			if (domain != null){
				var dl:int = domain.length;
				
				// remove trailing '.'
				if (domain.charAt(--dl) === '.') {
					domain = domain.slice(0, dl);
				}
				// remove leading '*'
				if (domain.slice(0, 2) === '*.') {
					domain = domain.slice(1);
				}
			}
			return domain;
		};
		
		/**
		 * Fix-up URL when page rendered from search engine cache or translated page.
		 * TODO: it would be nice to generalise this and/or move into the ETL phase.
		 */
		public static function fixupUrl(hostName:String, href:String, referrer:String):Array {
			
			if (hostName === 'translate.googleusercontent.com') {       // Google
				if (referrer === '') {
					referrer = href;
				}
				href = getParameter(href, 'u');
				hostName = getHostName(href);
			} else if (hostName === 'cc.bingj.com' ||                   // Bing
		  			   hostName === 'webcache.googleusercontent.com' ||            // Google
				       isYahooCachedPage(hostName)) {                         // Yahoo (via Inktomi 74.6.0.0/16)
				try {
					href = ExternalInterface.call("function getLinkHref() { return document.links[0].href; }");
				} catch (e:Error) {
					href = '';
				}
				hostName = getHostName(href);
			}
			return [hostName, href, referrer];
		};
		
		public static var scriptAccessAllowed:int = -1; //-1 = not set. 0 = false. 1 = true.
		
		public static function isScriptAccessAllowed ():Boolean
		{
			if (scriptAccessAllowed != -1)
			{
				return scriptAccessAllowed == 1;
			}
			
			if (!ExternalInterface.available)
			{
				scriptAccessAllowed = 0;
				return false;
			}
			
			try
			{
				ExternalInterface.call("function isScriptAccessAllowed(){return true;}");
				scriptAccessAllowed = 1;
			}
			catch (error:Error)
			{
				if (error is SecurityError)
				{
					scriptAccessAllowed = 0;
				}
			}
			
			return scriptAccessAllowed == 1;
		}
		
		
		/**
		 * AS Implementation of MurmurHash3 
		 * 
		 * @param {string} key ASCII only
		 * @param {number} seed Positive integer only
		 * @return {number} 32-bit positive integer hash 
		 */
		public static function murmurhash3_32_gc(key:String, seed:Number):Number {
			var remainder:Number;
			var bytes:Number;
			var h1:Number;
			var h1b:Number;
			var c1:Number;
			var c1b:Number;
			var c2:Number;
			var c2b:Number;
			var k1:Number;
			var i:Number;
			
			remainder = key.length & 3; // key.length % 4
			bytes = key.length - remainder;
			h1 = seed;
			c1 = 0xcc9e2d51;
			c2 = 0x1b873593;
			i = 0;
			
			while (i < bytes) {
				k1 = 
					((key.charCodeAt(i) & 0xff)) |
					((key.charCodeAt(++i) & 0xff) << 8) |
					((key.charCodeAt(++i) & 0xff) << 16) |
					((key.charCodeAt(++i) & 0xff) << 24);
				++i;
				
				k1 = ((((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16))) & 0xffffffff;
				k1 = (k1 << 15) | (k1 >>> 17);
				k1 = ((((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16))) & 0xffffffff;
				
				h1 ^= k1;
				h1 = (h1 << 13) | (h1 >>> 19);
				h1b = ((((h1 & 0xffff) * 5) + ((((h1 >>> 16) * 5) & 0xffff) << 16))) & 0xffffffff;
				h1 = (((h1b & 0xffff) + 0x6b64) + ((((h1b >>> 16) + 0xe654) & 0xffff) << 16));
			}
			
			k1 = 0;
			
			switch (remainder) {
				case 3: k1 ^= (key.charCodeAt(i + 2) & 0xff) << 16;
				case 2: k1 ^= (key.charCodeAt(i + 1) & 0xff) << 8;
				case 1: k1 ^= (key.charCodeAt(i) & 0xff);
					
					k1 = (((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16)) & 0xffffffff;
					k1 = (k1 << 15) | (k1 >>> 17);
					k1 = (((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16)) & 0xffffffff;
					h1 ^= k1;
			}
			
			h1 ^= key.length;
			
			h1 ^= h1 >>> 16;
			h1 = (((h1 & 0xffff) * 0x85ebca6b) + ((((h1 >>> 16) * 0x85ebca6b) & 0xffff) << 16)) & 0xffffffff;
			h1 ^= h1 >>> 13;
			h1 = ((((h1 & 0xffff) * 0xc2b2ae35) + ((((h1 >>> 16) * 0xc2b2ae35) & 0xffff) << 16))) & 0xffffffff;
			h1 ^= h1 >>> 16;
			
			return h1 >>> 0;
		}
	}
}