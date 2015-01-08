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
	public class Subject {
		
		private var standardPairs:Object;
		
		function Subject() {
			standardPairs = {};
			
			// Default Timezone
			var tzOffset:Number = (new Date()).getTimezoneOffset();
			var tz:String = "GMT" + 
							(tzOffset < 0 ? "-" : "+") +
							Util.padZeroes(Math.floor(tzOffset / 60)) + 
							":" +
							Util.padZeroes(tzOffset % 60);
		
			this.setTimezone(tz);
		}
		
		public function setUserId(userId:String):void {
			this.standardPairs[Parameter.UID] = userId;
		}
		
		public function setScreenResolution(width:int, height:int):void {
			var res:String = width + "x" + height;
			this.standardPairs[Parameter.RESOLUTION] = res;
		}
		
		public function setViewPort(width:int, height:int):void {
			var res:String = width + "x" + height;
			this.standardPairs[Parameter.VIEWPORT] = res;
		}
		
		public function setColorDepth(depth:int):void {
			this.standardPairs[Parameter.COLOR_DEPTH] = depth;
		}
		
		public function setTimezone(timezone:String):void {
			this.standardPairs[Parameter.TIMEZONE] = timezone;
		}
		
		public function setLanguage(language:String):void {
			this.standardPairs[Parameter.LANGUAGE] = language;
		}
		
		public function getSubject():Object {
			return this.standardPairs;
		}
	}
}