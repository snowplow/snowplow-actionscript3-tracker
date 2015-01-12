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
	import com.snowplowanalytics.snowplow.tracker.util.UUID;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;

	import mx.utils.Base64Encoder;

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
		
		private static function callCallback (dataFormat:String, loader:URLLoader, callback:Function):void
		{
			var result:*;
			
			switch (dataFormat)
			{
				case URLLoaderDataFormat.TEXT:
				case URLLoaderDataFormat.VARIABLES:
					result = loader.data;
					break;
				case URLLoaderDataFormat.BINARY:
				default:
					result = ByteArray(loader.data);
					break;
			}
			
			callback(result);
		}
		
		public static function getResponse	(
				url:String, 
				callback:Function, 
				errorCallback:Function, 
				method:String = "get", 
				postData:String = null, 
				dataFormat:String = "text"
			):void
		{
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(url);
			request.method = method;
			
			if (postData != null && method == URLRequestMethod.POST)
			{
				request.data = postData;
				request.contentType = "application/json; charset=utf-8";
			}
			
			loader.dataFormat = dataFormat;
			
			loader.addEventListener
				(
					Event.COMPLETE, 
					function (event:Event):void
					{
						if (callback != null)
						{
							callCallback(dataFormat, loader, callback);
						}
					}
				);
			
			loader.addEventListener
				(
					IOErrorEvent.IO_ERROR, 
					function (event:IOErrorEvent):void
					{
						if (event.type == "201")
						{
							if (callback != null)
							{
								callCallback(dataFormat, loader, callback);
							}
						}
						else
						{
							if (errorCallback != null)
							{
								errorCallback(event);
							}
						}
					}
				);
			
			loader.addEventListener
				(
					SecurityErrorEvent.SECURITY_ERROR, 
					function (event:SecurityErrorEvent):void
					{
						if (errorCallback != null)
						{
							errorCallback(event);
						}
					}
				);
			
			loader.load(request); 
		}
		
		public static function getEventId():String 
		{
			return UUID.generateGuid();
		}
		
		public static function getTimestamp():String {
			var date:Date = new Date();
			return date.time.toString();
		}
		
		public static function copyObject (object:Object, returnEmptyObjectIfNull:Boolean = false):Object  
		{ 
			if (object == null)
			{
				if (returnEmptyObjectIfNull)
					return {}
				else
					return null;
			}
			
			var newObject:Object = {};
			
			for (var key:String in object) {
				newObject[key] = object[key];
			}

			return newObject;
		}
		
		/* Addition functions
		*  Used to add different sources of key=>value pairs to a map.
		*  Map is then used to build "Associative array for getter function.
		*  Some use Base64 encoding
		*/
		public static function base64Encode(str:String):String {
			try {
				var encoder:Base64Encoder = new Base64Encoder();
				encoder.encode(str);
				return encoder.flush();
			} catch (e:Error) {
				trace(e.getStackTrace());
			}
			return null;
		}
		
		public static function getTransactionId():int 
		{ 
			return Math.round(Math.random() * 1000000);
	    }
		
		public static function clearArray (a:Array):void
		{
			a.splice(0, a.length);
		}
	}
}