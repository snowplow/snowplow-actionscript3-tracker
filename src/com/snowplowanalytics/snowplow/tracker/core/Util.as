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

package com.snowplowanalytics.snowplow.tracker.core
{
	public class Util
	{
		public static function isNullOrEmpty(str:*):Boolean
		{
			return str == null || (str is String && (str as String).length == 0);
		}
		
		public static function padZeroes (value:*, places:int = 2):String
		{
			var str:String = value.toString();
			var zeroes:int = places - str.length;
			if (zeroes > 0)
			{
				for (var i:int=0;i<zeroes;i++)
				{
					str = "0" + str;
				}
			}
			return str;
		}
	}
}