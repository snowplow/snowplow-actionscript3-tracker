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
	public class Constants
	{
		public static const PROTOCOL_VENDOR:String = "com.snowplowanalytics.snowplow";
		public static const PROTOCOL_VERSION:String = "tp2"; // Tracker Protocol v2
		
		public static const SCHEMA_PAYLOAD_DATA:String = "iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-0";
		public static const SCHEMA_CONTEXTS:String = "iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0";
		public static const SCHEMA_UNSTRUCT_EVENT:String = "iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0";
		public static const SCHEMA_SCREEN_VIEW:String = "iglu:com.snowplowanalytics.snowplow/screen_view/jsonschema/1-0-0";
		
		public static const EVENT_PAGE_VIEW:String = "pv";
		public static const EVENT_STRUCTURED:String = "se";
		public static const EVENT_UNSTRUCTURED:String = "ue";
		public static const EVENT_ECOMM:String = "tr";
		public static const EVENT_ECOMM_ITEM:String = "ti";
	}
}