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