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