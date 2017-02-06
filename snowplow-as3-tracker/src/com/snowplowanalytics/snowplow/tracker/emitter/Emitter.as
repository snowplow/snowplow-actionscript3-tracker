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
	import com.snowplowanalytics.snowplow.tracker.Parameter;
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
		private var _buffer:IBuffer;
		
		protected var bufferSize:int = BufferOption.DEFAULT;
		protected var httpMethod:String = URLRequestMethod.GET;
		
		/**
		 * Create an Emitter instance with a collector URL and HttpMethod to send requests.
		 * @param URI The collector URI.
		 * @param httpMethod The HTTP request method.
		 * @param protocol The protocol for the call. Either http or https. Defaults to protocol provided in the uri.
		 * @param buffer Flag that enables buffering using LocalStorage.
		 */
		public function Emitter(uri:String, httpMethod:String = URLRequestMethod.GET, protocol:String = Parameter.PROTOCOL_AUTO,  buffering: Boolean = false) {
			//protocol is string. Enums and Comparision 
			//See http://stackoverflow.com/questions/39506217/create-enum-in-actionscript-3-and-compare

			var emitterProtocol:EmitterProtocol = new EmitterProtocol(protocol);
			
			if (buffering) {
				try {
					_buffer = new LocalStorageBuffer();
					bufferSize = BufferOption.BATCH;
				} catch (e:Error) {
					throw new EmitterError("Local storage is unavailable for Buffering");

				}
			} else {
				_buffer = new InMemoryBuffer();
			}

			if (emitterProtocol.scheme == Parameter.PROTOCOL_AUTO) {
				var protocolScheme:Array = uri.match("^(http|https)://");
				if (protocolScheme) {
					trace("Collector protocol is " + protocolScheme[0]);
				} else {
					throw new EmitterError("Invalid protocol scheme provided in uri. Use http or https");
				}
			} else {
				// Set http/https protocol in uri
				uri = emitterProtocol.scheme + "://";
			}
			
			if (httpMethod == URLRequestMethod.GET) {
				_uri = new URI(uri + "/i");
			} else { // POST
				_uri = new URI(uri + "/" + Constants.PROTOCOL_VENDOR + "/" + Constants.PROTOCOL_VERSION);
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
			// If payload is > 50000 bytes do not add to buffer, instead fire and forget.
			if (payload.size() > 50000)
			{
			  sendData(payload,
					function onSendSuccess (data:*):void 
					{
						trace("Large payload send success");
					},
					function onSendError (data:*):void 
					{
						trace("Large payload send failure." + payload.toString());
				});
			}
			// Add payload to buffer
			_buffer.push([payload]);

			// Flush buffer if bufferSize is reached.
			if (_buffer.size() >= bufferSize)
			{
				flushBuffer();
			}
		}

		/**
		 * Sends all events in the buffer to the collector.
		 */
		public function checkBufferComplete(successCount:int, totalCount:int, totalPayload:int, unsentPayload:Array):void {
			if (totalCount == totalPayload) 
			{
				// Clear buffer since all payloads have been successfully sent
				_buffer.clear();
				if (unsentPayload.length == 0) 
				{
					dispatchEvent(new EmitterEvent(EmitterEvent.SUCCESS, successCount));
				} 
				else 
				{
					dispatchEvent(new EmitterEvent(EmitterEvent.FAILURE, successCount, unsentPayload, "Not all items in buffer were sent"));
				}
			}
		}
		
		/**
		 * Sends all events in the buffer to the collector.
		 */
		public function flushBuffer():void {
			if (_buffer.size() == 0) {
				trace("Buffer is empty, exiting flush operation");
				return;
			}
			
			var payloads:Array = _buffer.get();
			var unsentPayload:Array = [];

			if (httpMethod == URLRequestMethod.GET) {
				var successCount:int = 0;
				var totalCount:int = 0;
				var totalPayload:int = _buffer.length();

				for each (var getPayload:IPayload in payloads) {
					// Attach sent timestamp
					getPayload.add(Parameter.DEVICE_SENT_TIMESTAMP, Util.getTimestamp()); 
					sendGetData(getPayload,
						function onGetSuccess (data:*):void {
							successCount++;
							totalCount++;
							checkBufferComplete(successCount, totalCount, totalPayload, unsentPayload);
						},
						function onGetError ():void {
							totalCount++;
							unsentPayload.push(getPayload)
							checkBufferComplete(successCount, totalCount, totalPayload, unsentPayload);
						}
					);
				}
			} else if (httpMethod == URLRequestMethod.POST) {
				
				var postPayload:SchemaPayload = new SchemaPayload();
				postPayload.setSchema(Constants.SCHEMA_PAYLOAD_DATA);
				
				var eventMaps:Array = [];

				for each (var payload:IPayload in payloads) {
					// Attach sent timestamp
					payload.add(Parameter.DEVICE_SENT_TIMESTAMP, Util.getTimestamp());
					eventMaps.push(payload.getMap());
				}

				postPayload.setData(eventMaps);
				
				sendPostData(postPayload,
					function onPostSuccess (data:*):void 
					{
						_buffer.clear();
						dispatchEvent(new EmitterEvent(EmitterEvent.SUCCESS, _buffer.length()));
					},
					function onPostError (event:Event):void 
					{
						_buffer.clear();
						unsentPayload.push(postPayload);
						dispatchEvent(new EmitterEvent(EmitterEvent.FAILURE, 0, unsentPayload, event.toString()));
					}
				);
			}
		}

		protected function sendData(payload:IPayload, successCallback:Function, errorCallback:Function):void
		{
			if (httpMethod == URLRequestMethod.GET) {
				sendGetData(payload, successCallback, errorCallback)
			}
			else if (httpMethod == URLRequestMethod.POST) {
				sendPostData(payload, successCallback, errorCallback)
			}
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