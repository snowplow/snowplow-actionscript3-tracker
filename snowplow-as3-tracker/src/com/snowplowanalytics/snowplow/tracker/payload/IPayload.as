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
		 * Add a map to the Payload with a key dependent on the base 64 encoding option you choose using the
		 * two keys provided.
		 * @param map Mapping to be stored
		 * @param base64_encoded The option you choose to encode the data
		 * @param type_encoded The key that would be set if the encoding option was set to true
		 * @param type_no_encoded They key that would be set if the encoding option was set to false
		 */
		function addMap(map:Object, base64_encoded:Boolean = false, type_encoded:String = null, type_no_encoded:String = null):void;

		/**
		 * Returns the Payload as a HashMap.
		 * @return A HashMap
		 */
		function getMap():Object;
		
		/**
		 * Returns the Payload as a string. This is essentially the toString from the ObjectNode used
		 * to store the Payload.
		 * @return A string value of the Payload.
		 */
		function toString():String;
	}
}