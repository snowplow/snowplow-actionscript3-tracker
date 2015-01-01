/*
* Copyright (c) 2014 Snowplow Analytics Ltd. All rights reserved.
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

package com.snowplowanalytics.snowplow.tracker.core.emitter
{
	import com.adobe.net.URI;
	import com.snowplowanalytics.snowplow.tracker.core.Constants;
	import com.snowplowanalytics.snowplow.tracker.core.payload.IPayload;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	public class Emitter
	{
		private var _uri:URI;
		private var _loader:URLLoader;
		private var _buffer:Array = [];
		
		protected var bufferSize:int = BufferOption.DEFAULT;
		protected var requestCallback:Function;
		protected var httpMethod:String = URLRequestMethod.GET;
		
		/**
		 * Create an Emitter instance with a collector URL and HttpMethod to send requests.
		 * @param URI The collector URL. Don't include "http://" - this is done automatically.
		 * @param httpMethod The HTTP request method. If GET, <code>BufferOption</code> is set to <code>Instant</code>.
		 * @param callback The callback function to handle success/failure cases when sending events.
		 */
		public function Emitter(uri:String, httpMethod:String = URLRequestMethod.GET, callback:Function = null) {
			if (httpMethod == URLRequestMethod.GET) {
				_uri = new URI("http://" + uri + "/i");
			} else { // POST
				_uri = new URI("http://" + uri + "/" + Constants.PROTOCOL_VENDOR + "/" + Constants.PROTOCOL_VERSION);
			}
			
			this.requestCallback = callback;
			this.httpMethod = httpMethod;
			this._loader = new URLLoader();
			
			if (httpMethod == URLRequestMethod.GET) {
				this.setBufferSize(BufferOption.INSTANT);
			}
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
		public function flushBuffer():void {
			if (_buffer.length == 0) {
				trace("Buffer is empty, exiting flush operation.");
				return;
			}
			
			if (httpMethod == URLRequestMethod.GET) {
				var success_count:int = 0;
				var unsentPayloads:Array = [];
				
				for (var payload:IPayload in _buffer) {
					var status_code:int = sendGetData(payload).getStatusLine().getStatusCode();
					if (status_code == 200)
						success_count++;
					else
						unsentPayloads.add(payload);
				}
				
				if (unsentPayloads.size() == 0) {
					if (requestCallback != null)
						requestCallback.onSuccess(success_count);
				}
				else if (requestCallback != null)
					requestCallback.onFailure(success_count, unsentPayloads);
				
			} else if (httpMethod == HttpMethod.POST) {
				LinkedList<Payload> unsentPayload = new LinkedList<Payload>();
				
				SchemaPayload postPayload = new SchemaPayload();
				postPayload.setSchema(Constants.SCHEMA_PAYLOAD_DATA);
				
				ArrayList<Map> eventMaps = new ArrayList<Map>();
				for (Payload payload : buffer) {
					eventMaps.add(payload.getMap());
				}

				postPayload.setData(eventMaps);
				
				int status_code = sendPostData(postPayload).getStatusLine().getStatusCode();
				if (status_code == 200 && requestCallback != null)
					requestCallback.onSuccess(buffer.size());
				else if (requestCallback != null){
					unsentPayload.add(postPayload);
					requestCallback.onFailure(0, unsentPayload);
				}
			}
			
			// Empties current buffer
			buffer.clear();
		}
		
		protected function sendPostData(payload:IPayload):* {
		
		}
		
		protected function sendGetData(payload:IPayload):* {
			
		}	
	}
}