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

package com.snowplowanalytics.snowplow.tracker.emitter
{
	import com.adobe.net.URI;
	import com.snowplowanalytics.snowplow.tracker.Constants;
	import com.snowplowanalytics.snowplow.tracker.Util;
	import com.snowplowanalytics.snowplow.tracker.event.EmitterEvent;
	import com.snowplowanalytics.snowplow.tracker.payload.IPayload;
	import com.snowplowanalytics.snowplow.tracker.payload.SchemaPayload;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	public class Emitter extends EventDispatcher
	{
		private var _uri:URI;
		private var _buffer:Array = [];
		
		protected var bufferSize:int = BufferOption.DEFAULT;
		protected var httpMethod:String = URLRequestMethod.GET;
		
		/**
		 * Create an Emitter instance with a collector URL and HttpMethod to send requests.
		 * @param URI The collector URL. Don't include "http://" - this is done automatically.
		 * @param httpMethod The HTTP request method. If GET, <code>BufferOption</code> is set to <code>Instant</code>.
		 * @param successCallback The callback function to handle success cases when sending events.
		 * @param errorCallback The callback function to handle error cases when sending events.
		 */
		public function Emitter(uri:String, httpMethod:String = "get") {
			if (httpMethod == URLRequestMethod.GET) {
				_uri = new URI("http://" + uri + "/i");
			} else { // POST
				_uri = new URI("http://" + uri + "/" + Constants.PROTOCOL_VENDOR + "/" + Constants.PROTOCOL_VERSION);
			}
			
			this.httpMethod = httpMethod;
		}
		
		/**
		 * Sets whether the buffer should send events instantly or after the buffer has reached
		 * it's limit. By default, this is set to BufferOption Default.
		 * @param option Set the BufferOption enum to Instant send events upon creation.
		 */
		public function setBufferSize(option:int):void {
			this.bufferSize = option;
		}

		/**
		 * Add event payloads to the emitter's buffer
		 * @param payload Payload to be added
		 */
		public function addToBuffer(payload:IPayload):void {
			_buffer.push(payload);
			if (_buffer.length == bufferSize)
				flushBuffer();
		}

		/**
		 * Sends all events in the buffer to the collector.
		 */
		public function checkBufferComplete(successCount:int, totalCount:int, totalPayloads:int, unsentPayloads:Array):void {
			if (totalCount == totalPayloads) 
			{
				if (unsentPayloads.length == 0) 
				{
					dispatchEvent(new EmitterEvent(EmitterEvent.SUCCESS, successCount));
				} 
				else 
				{
					dispatchEvent(new EmitterEvent(EmitterEvent.FAILURE, successCount, unsentPayloads, "Not all items in buffer were sent"));
				}
			}
		}
		
		/**
		 * Sends all events in the buffer to the collector.
		 */
		public function flushBuffer():void {
			if (_buffer.length == 0) {
				trace("Buffer is empty, exiting flush operation.");
				return;
			}
			
			if (httpMethod == URLRequestMethod.GET) {
				var successCount:int = 0;
				var totalCount:int = 0;
				var totalPayloads:int = _buffer.length;
				var unsentPayloads:Array = [];
				
				for each (var getPayload:IPayload in _buffer) {
					sendGetData(getPayload,
						function onGetSuccess (data:*):void {
							successCount++;
							totalCount++;
							checkBufferComplete(successCount, totalCount, totalPayloads, unsentPayloads);
						},
						function onGetError ():void {
							totalCount++;
							unsentPayloads.add(payload);
							checkBufferComplete(successCount, totalCount, totalPayloads, unsentPayloads);
						}
					);
				}
			} else if (httpMethod == URLRequestMethod.POST) {
				var unsentPayload:Array = [];
				
				var postPayload:SchemaPayload = new SchemaPayload();
				postPayload.setSchema(Constants.SCHEMA_PAYLOAD_DATA);
				
				var eventMaps:Array = [];
				for each (var payload:IPayload in _buffer) {
					eventMaps.push(payload.getMap());
				}

				postPayload.setData(eventMaps);
				
				sendPostData(postPayload,
					function onPostSuccess (data:*):void 
					{
						dispatchEvent(new EmitterEvent(EmitterEvent.SUCCESS, _buffer.length));
					},
					function onPostError (event:Event):void 
					{
						unsentPayload.push(postPayload);
						dispatchEvent(new EmitterEvent(EmitterEvent.FAILURE, 0, unsentPayloads, event.toString()));
					}
				);
			}
			
			// Empties current buffer
			Util.clearArray(_buffer);
		}
		
		protected function sendPostData(payload:IPayload, successCallback:Function, errorCallback:Function):void
		{
			Util.getResponse(_uri.toString(), 
				successCallback,
				errorCallback, 
				URLRequestMethod.POST,
				payload.toString());
		}
		
		protected function sendGetData(payload:IPayload, successCallback:Function, errorCallback:Function):void 
		{
			var hashMap:Object = payload.getMap();
			_uri.setQueryByMap(hashMap);
			
			Util.getResponse(_uri.toString(), 
				successCallback,
				errorCallback);
		}
	}
}