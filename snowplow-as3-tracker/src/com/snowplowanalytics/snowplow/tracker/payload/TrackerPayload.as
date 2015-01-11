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
	import com.snowplowanalytics.snowplow.tracker.Util;

	public class TrackerPayload implements IPayload
	{
		//private var objectMapper:ObjectMapper = Util.defaultMapper();
		//private var logger:Logger = LoggerFactory.getLogger(SchemaPayload.class);
		private var objectNode:Object = {};

		public function TrackerPayload()
		{
		}
		
		public function add(key:String, value:*):void
		{
/*			if (Util.isNullOrEmpty(value)) {
				trace("kv-value is empty. Returning out without adding key..");
				return;
			}
			
			trace("Adding new key: {} with value: {}", key, value);
			objectNode[key] = value;
*/			
		}
		
		public function addMap(map:Object, base64_encoded:Boolean = false, type_encoded:String = null, type_no_encoded:String = null):void
		{
/*			if (map == null) {
				logger.debug("Map passed in is null. Returning without adding map..");
				return;
			}
			
			for(var key:String in map) {
				add(key, map[key]);
			}
*/		}
		
		public function getMap():Object
		{
			return objectNode;
		}
		
		public function getNode():*
		{
			return objectNode;
		}
		
		public function toString():String
		{
			return objectNode.toString();
		}
	}
}