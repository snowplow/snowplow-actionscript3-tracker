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

package
{
	import com.snowplowanalytics.snowplow.tracker.emitter.BufferOption;
	import com.snowplowanalytics.snowplow.tracker.emitter.Emitter;
	import com.snowplowanalytics.snowplow.tracker.emitter.EmitterError;
	import com.snowplowanalytics.snowplow.tracker.event.EmitterEvent;
	import com.snowplowanalytics.snowplow.tracker.payload.TrackerPayload;
	
	import flash.net.URLRequestMethod;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	
	public class EmitterTest
	{
		private static var testURL:String = "https://astracker.snplow.com";
		private var callCompleted:Boolean = false;
		private var testPayloadData:Object = {
			"schema":"iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-0",
			"data":[
				{
					"aid":"cloudfront",
					"co":"{\"schema\":\"iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0\",\"data\":[{\"schema\":\"iglu:com.snowplowanalytics.snowplow/flash_context/jsonschema/1-0-0\",\"data\":{\"hasLocalStorage\":true,\"stageSize\":{\"height\":893,\"width\":1131},\"version\":\"WIN 11,1,102,63\",\"isDebugger\":true,\"playerType\":\"ActiveX\",\"hasScriptAccess\":true}}]}",
					"dtm":"1421582265712",
					"e":"pv",
					"eid":"ec7585f8-50a0-4f74-b9eb-b10e9fc1f3b0",
					"p":"pc",
					"page":"My Page",
					"refr":"www.me.com",
					"tna":"AF003",
					"tv":"as3-0.3.0",
					"tz":"Etc/UTC-2:00",
					"ue_pr":"{\"schema\":\"iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1\",\"data\":{\"targetUrl\":\"http://www.google.com\"}}",
					"url":"www.mypage.com",
					"vp":"320x480"
				}
			]
		};
		
		
		[Test]
		public function testEmitterConstructor():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
		}
		
		[Test]
		public function testEmitterConstructor2():void {
			var emitter:Emitter = new Emitter(testURL);
		}

		[Test]
		public function testEmitterConstructor3():void {
			//Uri with protocol
		var emitter:Emitter = new Emitter("analytics.snowplow.com", URLRequestMethod.POST, "http");
		}

		[Test]
		public function testEmitterConstructorFail1():void {
			//Uri without scheme for Protocol.AUTO
			try
			{
				var emitter:Emitter = new Emitter("analytics.snowplow.com");
			} catch (e: EmitterError)
			{
					Assert.assertEquals(e.message, "Invalid protocol scheme provided in uri. Use http or https");
			}
		}

		[Test]
		public function testEmitterConstructorFail2():void {
			//Uri with incorrect protocol
			try
			{
				var emitter:Emitter = new Emitter("analytics.snowplow.com", URLRequestMethod.POST, "ftp");
			} catch (e: EmitterError)
			{
					Assert.assertEquals(e.message, "Invalid Protocol provided to emitter. Use http/https or Auto to detect from uri.");
			}
		}
		
		[Test]
		public function testFlushGet():void {
			var emitter:Emitter = new Emitter(testURL);
			
			var payload:TrackerPayload = new TrackerPayload();
			payload.addMap(testPayloadData);
			
			emitter.addToBuffer(payload);
			
			emitter.flushBuffer();
		}
		
		[Test]
		public function testFlushPost():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			
			var payload:TrackerPayload;
			payload = new TrackerPayload();
			payload.addMap(testPayloadData);
			
			emitter.addToBuffer(payload);
			
			emitter.flushBuffer();
		}
		
		[Test]
		public function testBufferOption():void {
			var emitter:Emitter = new Emitter(testURL);
			emitter.setBufferSize(BufferOption.DEFAULT);
		}
		
		private function onSuccess(successCount:int):void {
			trace("Buffer length for POST/GET:" + successCount);
			Assert.assertTrue(successCount > 0);
		}

		/*
		private function handleTimeout(passThroughData:Object):void {
			if (!callCompleted) {
				Assert.fail( "Timeout reached before event");          
			}
		}
		*/
		
		[Test()]
		public function testFlushBuffer():void {
			/*
			var timeout:int = 500;
			callCompleted = false;
			
			var onSuccess:Function = Async.asyncHandler(this, 
				function (event:EmitterEvent, passThroughData:Object):void {
					callCompleted = true;
					trace("Buffer length for POST/GET:" + event.successCount);
					Assert.assertTrue(event.successCount > 0);
				}, 
				timeout, 
				null, 
				handleTimeout 
			);
			
			var onFailure:Function = Async.asyncHandler(this, 
				function (event:EmitterEvent, passThroughData:Object):void {
					callCompleted = true;
					trace("Failure, successCount: " + event.successCount +
						"\nerrorInfo:\n" + event.errorInfo +
						"\nfailedEvent:\n" + event.toString());
					Assert.fail( "An error occured flushing the buffer.");   
				}, 
				timeout, 
				null, 
				handleTimeout 
			);
			*/
			var emitter:Emitter = new Emitter(testURL, 
				URLRequestMethod.GET
			);
			
			//emitter.addEventListener(EmitterEvent.SUCCESS, onSuccess);
			//emitter.addEventListener(EmitterEvent.FAILURE, onFailure);
			
			
			for (var i:int=0; i < 5; i++) {
				var payload:TrackerPayload;
				payload = new TrackerPayload();
				payload.addMap(testPayloadData);
				
				emitter.addToBuffer(payload);
			}
			emitter.flushBuffer();
		}
		
		[Test]
		public function testMaxBuffer():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.GET);

			for (var i:int=0; i < 10; i++) {
				var payload:TrackerPayload;
				payload = new TrackerPayload();
				payload.addMap(testPayloadData);
				
				emitter.addToBuffer(payload);
			}
		}

		[Test]
		public function testLocalBufferStorage():void {
			try
			{
				var emitter:Emitter = new Emitter(testURL, URLRequestMethod.GET, "https", true);
			} catch (e: EmitterError)
			{
					Assert.assertEquals(e.message, "Local storage is unavailable for Buffering");
			}
		}

	}
}