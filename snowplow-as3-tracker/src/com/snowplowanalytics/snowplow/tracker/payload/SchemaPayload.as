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
	import flash.utils.ByteArray;
	import com.adobe.serialization.json.JSON;
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
			if (payload != null) 
			{
				objectNode[Parameter.DATA] = payload.getMap();
			}
		}
		
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
			/*
			* We intentionally do nothing because we do not want our SchemaPayload
			* to do anything except accept a 'data' and 'schema'
			*/
			trace("add(String, String) method called: Doing nothing.");
		}
		
		public function addMap(map:Object, base64_encoded:Boolean = false, type_encoded:String = null, type_no_encoded:String = null):void
		{
			/*
			* We intentionally do nothing because we do not want our SchemaPayload
			* to do anything except accept a 'data' and 'schema'
			*/
			trace("addMap(Map, Boolean, String, String) method called: Doing nothing.");
		}
		
		public function getMap():Object
		{
			return objectNode;
		}
	
		public function toString():String
		{
			return JSON.encode(objectNode);
		}

		public function size():int
		{
			var payload:ByteArray = new ByteArray();
			payload.writeUTFBytes(JSON.encode(objectNode));
			return payload.length;
		}
	}
}