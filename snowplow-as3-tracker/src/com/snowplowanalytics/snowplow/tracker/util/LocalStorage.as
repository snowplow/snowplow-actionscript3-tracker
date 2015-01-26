package com.snowplowanalytics.snowplow.tracker.util
{
	import com.snowplowanalytics.snowplow.tracker.Util;
	
	import de.aggro.utils.CookieUtil;
	
	import flash.net.SharedObject;

	public class LocalStorage
	{
		public static const COOKIES:String = "cookies";
		public static const SHARED_OBJECT:String = "sharedObject";
		public static const BOTH:String = "both";

		private static const LOCAL_OBJECT_NAME:String = "com.snowplowanalytics.snowplow-as3-tracker";
		
		private var cookies:Boolean = false;
		private var sharedObject:Boolean = false;
		private var sharedObjectClient:SharedObject;
		
		public function LocalStorage(mode:String)
		{
			switch(mode)
			{
				case COOKIES:
					cookies = true;
					break;
				case SHARED_OBJECT:
					sharedObject = true;
					break;
				case BOTH:
					cookies = true;
					sharedObject = true;
					break;
			}
			
			if (sharedObject) {
				sharedObjectClient = SharedObject.getLocal(LOCAL_OBJECT_NAME);
			}
			
			try {
				CookieUtil.init();
			} catch (e:Error) {
				cookies = false;
			}
		}
		
		public function getLocal(name:String):String
		{
			var value:String = null;
			
			if (cookies) {
				value = CookieUtil.getCookie(name) as String;
			}
			
			if (sharedObject && Util.isNullOrEmpty(value)) {
				value =  sharedObjectClient.data[name];
			}
			
			return value;
		}

		public function setLocal(name:String, value:String, cookieTimeout:int = 999999, cookiePath:String = "/", cookieDomain:String = null):void
		{
			if (cookies) {
				CookieUtil.setCookie(name, value, cookieTimeout, cookiePath, cookieDomain);
			}
			
			if (sharedObject) {
				sharedObjectClient.data[name] = value;
				sharedObjectClient.flush();
			}
		}

		public function deleteLocal(name:String):void
		{
			if (cookies) {
				CookieUtil.deleteCookie(name);
			}
			
			if (sharedObject) {
				delete sharedObjectClient.data[name];
				sharedObjectClient.flush();
			}
		}
	}
}