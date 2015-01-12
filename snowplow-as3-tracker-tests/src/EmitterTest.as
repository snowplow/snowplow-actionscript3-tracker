package
{
	import com.snowplowanalytics.snowplow.tracker.emitter.BufferOption;
	import com.snowplowanalytics.snowplow.tracker.emitter.Emitter;
	import com.snowplowanalytics.snowplow.tracker.event.EmitterEvent;
	import com.snowplowanalytics.snowplow.tracker.payload.TrackerPayload;
	
	import flash.net.URLRequestMethod;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	
	public class EmitterTest
	{
		private static var testURL:String = "astracker.snplow.com";
		private var callCompleted:Boolean = false;
		
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
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			
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
			emitter.setBufferSize(BufferOption.DEFAULT);
		}
		
		private function onSuccess(successCount:int):void {
			trace("Buffer length for POST/GET:" + successCount);
			Assert.assertTrue(successCount > 0);
		}
		
		private function handleTimeout(passThroughData:Object):void {
			if (!callCompleted) {
				Assert.fail( "Timeout reached before event");          
			}
		}
		
		[Test(async, description="Test flush buffer")]
		public function testFlushBuffer():void {
			
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
			
			var emitter:Emitter = new Emitter(testURL, 
				URLRequestMethod.GET
			);
			
			emitter.addEventListener(EmitterEvent.SUCCESS, onSuccess);
			emitter.addEventListener(EmitterEvent.FAILURE, onFailure);
			
			
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
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.GET);

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