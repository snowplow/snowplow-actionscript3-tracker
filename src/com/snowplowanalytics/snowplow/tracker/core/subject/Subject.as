package com.snowplowanalytics.snowplow.tracker.core.subject
{
	import com.snowplowanalytics.snowplow.tracker.core.Util;

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
		
		public function setViewPort(int width, int height):void {
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