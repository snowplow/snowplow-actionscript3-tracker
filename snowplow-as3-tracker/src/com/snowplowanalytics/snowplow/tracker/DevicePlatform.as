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
	/*
		https://github.com/snowplow/snowplow/wiki/snowplow-tracker-protocol
	*/
	public class DevicePlatform
	{
		public static const WEB:String = "web";
		public static const MOBILE:String = "mob";
		public static const DESKTOP:String = "pc";
		public static const SERVER_SIDE_APP:String = "srv";
		public static const GENERAL:String = "app";
		public static const CONNECTED_TV:String = "tv";
		public static const GAMES_CONSOLE:String = "cnsl";
		public static const INTERNET_OF_THINGS:String = "iot";
	}
}