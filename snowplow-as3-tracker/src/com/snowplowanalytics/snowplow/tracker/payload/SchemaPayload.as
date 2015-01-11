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

package com.snowplowanalytics.snowplow.tracker.payload
{
	import com.snowplowanalytics.snowplow.tracker.Parameter;
	import com.snowplowanalytics.snowplow.tracker.Util;
	import com.snowplowanalytics.snowplow.tracker.util.Preconditions;

	public class SchemaPayload implements IPayload
	{
		//private var objectMapper:ObjectMapper = Util.defaultMapper();
		//private var logger:Logger = LoggerFactory.getLogger(SchemaPayload.class);
		private var objectNode:Object = {};
		
		public function SchemaPayload(payload:IPayload = null)
		{
/*			if (payload != null) {
				var data:ObjectNode;
				
				if (payload.getClass() == TrackerPayload.class) {
					logger.debug("Payload class is a TrackerPayload instance.");
					logger.debug("Trying getNode()");
					data = (ObjectNode) payload.getNode();
				} else {
					logger.debug("Converting Payload map to ObjectNode.");
					data = objectMapper.valueToTree(payload.getMap());
				}
					objectNode.set(Parameter.DATA, data);
			}
*/		}
		
		public function setSchema(schema:String):SchemaPayload {
			Preconditions.checkNotNull(schema, "schema cannot be null");
			Preconditions.checkArgument(!Util.isNullOrEmpty(schema), "schema cannot be empty.");
			
			trace("Setting schema: {}", schema);
			objectNode[Parameter.SCHEMA] = schema;
			return this;
		}
		
		public function setData(data:*):SchemaPayload {
			if (data is IPayload) {
				data = data.getMap();
			}
			objectNode[Parameter.DATA] = data;
			return this;
		}
		
		public function add(key:String, value:*):void
		{
		}
		
		public function addMap(map:Object):void
		{
		}
		
		public function getMap():Object
		{
			return null;
		}
		
		public function getNode():*
		{
			return null;
		}
		
		public function toString():String
		{
			return null;
		}
	}
}