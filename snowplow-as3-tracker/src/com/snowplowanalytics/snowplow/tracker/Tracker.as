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
	import com.snowplowanalytics.snowplow.tracker.emitter.Emitter;
	import com.snowplowanalytics.snowplow.tracker.payload.IPayload;
	import com.snowplowanalytics.snowplow.tracker.payload.SchemaPayload;
	import com.snowplowanalytics.snowplow.tracker.payload.TrackerPayload;
	import com.snowplowanalytics.snowplow.tracker.util.Preconditions;
	
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.system.Capabilities;

	public class Tracker
	{
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
		
		/**
		 * @param emitter Emitter to which events will be sent
		 * @param subject Subject to be tracked
		 * @param namespace Identifier for the Tracker instance
		 * @param appId Application ID
		 * @param stage The flash stage object.  used for adding stage info to payload.
		 * @param base64Encoded Whether JSONs in the payload should be base-64 encoded
		 */
		function Tracker(emitter:Emitter, subject:Subject, namespace:String, appId:String, stage:Stage = null, base64Encoded:Boolean = true) {
				this.emitter = emitter;
				this.appId = appId;
				this.base64Encoded = base64Encoded;
				this.namespace = namespace;
				this.subject = subject;
				this.trackerVersion = Version.TRACKER;
				this.platform = DevicePlatform.DESKTOP;
				this.stage = stage;
				
				this.playerType = Capabilities.playerType;
				this.playerVersion = Capabilities.version;
				this.isDebugger = Capabilities.isDebugger;
				try 
				{
					SharedObject.getLocal("test");
					this.hasLocalStorage = true;
				} 
				catch (e:Error)
				{
					this.hasLocalStorage = false;
				}
				this.hasScriptAccess = ExternalInterface.available;
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
				
				// If timestamp is set to 0, generate one
				payload.add(Parameter.TIMESTAMP,
					(timestamp == 0 ? Util.getTimestamp() : String(timestamp)));
				
				// Add flash information
				payload.add(Parameter.FLASH_PLAYER_TYPE, playerType);
				payload.add(Parameter.FLASH_VERSION, playerVersion);
				payload.add(Parameter.FLASH_IS_DEBUGGER, isDebugger);
				payload.add(Parameter.FLASH_HAS_LOCAL_STORAGE, hasLocalStorage);
				payload.add(Parameter.FLASH_HAS_SCRIPT_ACCESS, hasScriptAccess);
				if (stage != null) {
					payload.add(Parameter.FLASH_STAGE_SIZE, stage.stageWidth + "x" + stage.stageHeight);	
				}				

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
					payload.addMap(envelope.getMap());
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
					
		/**
		 * @param pageUrl URL of the viewed page
		 * @param pageTitle Title of the viewed page
		 * @param referrer Referrer of the page
		 * @param context Custom context for the event
		 * @param timestamp Optional user-provided timestamp for the event
		 */
		public function trackPageView(pageUrl:String, pageTitle:String, referrer:String, context:Array = null, timestamp:Number = 0):void 
		{
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
			var payload:IPayload = new TrackerPayload();
			var envelope:SchemaPayload = new SchemaPayload();
			
			envelope.setSchema(Constants.SCHEMA_UNSTRUCT_EVENT);
			envelope.setData(eventData.getMap());
			
			payload.add(Parameter.EVENT, Constants.EVENT_UNSTRUCTURED);
			payload.addMap(envelope.getMap());
			
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