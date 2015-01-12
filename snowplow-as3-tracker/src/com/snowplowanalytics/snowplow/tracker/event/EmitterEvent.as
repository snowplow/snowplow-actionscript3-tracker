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

package com.snowplowanalytics.snowplow.tracker.event
{
	import flash.events.Event;
	
	public class EmitterEvent extends Event
	{
		public static const SUCCESS:String = "EMITTER_SUCCESS";
		public static const FAILURE:String = "EMITTER_FAILURE";
		
		public var successCount:Number;
		public var unsentPayloads:Array;
		public var errorInfo:String;
		
		public function EmitterEvent(type:String, successCount:Number = NaN, unsentPayloads:Array = null, errorInfo:String = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.successCount = successCount;
			this.unsentPayloads = unsentPayloads;
			this.errorInfo = errorInfo;
		}
	}
}