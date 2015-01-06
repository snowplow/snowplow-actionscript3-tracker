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

package com.snowplowanalytics.snowplow.tracker.core.payload
{
	import com.adobe.serialization.json.JSONToken;

	public interface IPayload
	{
		/**
		 * Add a basic parameter.
		 * @param key The parameter key
		 * @param value The parameter value as a String or Object
		 */
		function add(key:String, value:*):void;
		
		/**
		 * Add all the mappings from the specified map. The effect is the equivalent to that of calling
		 * add(String key, Object value) for each mapping for each key.
		 * @param map Mappings to be stored in this map
		 */
		function addMap(map:Object):void;

		/**
		 * Returns the Payload as a HashMap.
		 * @return A HashMap
		 */
		function getMap():Object;
		
		/**
		 * Returns the Payload using Jackson JSON to return a JsonNode.
		 * @return A JsonNode
		 */
		function getNode():*;
		
		/**
		 * Returns the Payload as a string. This is essentially the toString from the ObjectNode used
		 * to store the Payload.
		 * @return A string value of the Payload.
		 */
		function toString():String;
	}
}