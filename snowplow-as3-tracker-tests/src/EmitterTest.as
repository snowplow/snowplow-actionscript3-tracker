package
{
	import com.snowplowanalytics.snowplow.tracker.emitter.BufferOption;
	import com.snowplowanalytics.snowplow.tracker.emitter.Emitter;
	import com.snowplowanalytics.snowplow.tracker.payload.TrackerPayload;
	
	import flash.net.URLRequestMethod;

	public class EmitterTest
	{
		//    private static String testURL = "segfault.ngrok.com";
		private static var testURL:String = "d3rkrsqld9gmqf.cloudfront.net";
		
		[Test]
		public function testEmitterConstructor():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
		}
		
		[Test]
		public function testEmitterConstructor2():void {
			var emitter:Emitter = new Emitter(testURL);
		}
		
		[Test]
		public function testFlushGet():void {
			var emitter:Emitter = new Emitter(testURL);
			
			var payload:TrackerPayload;
			var foo:Object = {};
			foo["test"] = "testFlushBuffer";
			payload = new TrackerPayload();
			payload.addMap(foo);
			
			emitter.addToBuffer(payload);
			
			emitter.flushBuffer();
		}
		
		[Test]
		public function testFlushPost():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST, null);
			
			var payload:TrackerPayload;
			var foo:Object = {};
			var bar:Array = [];
			bar.push("somebar");
			bar.push("somebar");
			foo["test"] = "testMaxBuffer";
			foo["mehh"] = bar;
	
			payload = new TrackerPayload();
			payload.addMap(foo);
			
			emitter.addToBuffer(payload);
			
			emitter.flushBuffer();
		}
		
		[Test]
		public function testBufferOption():void {
			var emitter:Emitter = new Emitter(testURL);
			emitter.setBufferSize(BufferOption.INSTANT);
		}
		
		[Test]
		public function testFlushBuffer():void {
			
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.GET,
				function onSuccess(successCount:int):void {
					trace("Buffer length for POST/GET:" + successCount);
				},
				function onFailure(successCount:int, failedEvent:Array):void {
					trace("Failure, successCount: " + successCount +
						"\nfailedEvent:\n" + failedEvent.toString());
				}
			);
			
			for (var i:int=0; i < 5; i++) {
				var payload:TrackerPayload;
				var foo:Object = {};
				foo["test"] = "testFlushBuffer";
				payload = new TrackerPayload();
				payload.addMap(foo);
				
				emitter.addToBuffer(payload);
			}
			emitter.flushBuffer();
		}
		
		[Test]
		public function testMaxBuffer():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.GET, null);

			for (var i:int=0; i < 10; i++) {
				var payload:TrackerPayload;
				var foo:Object = {};
				foo["test"] = "testFlushBuffer";
				payload = new TrackerPayload();
				payload.addMap(foo);
				
				emitter.addToBuffer(payload);
			}
		}

	}
}