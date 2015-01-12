package 
{
	import com.snowplowanalytics.snowplow.tracker.*;
	import com.snowplowanalytics.snowplow.tracker.emitter.*;
	import com.snowplowanalytics.snowplow.tracker.payload.*;
	import com.snowplowanalytics.snowplow.tracker.util.*;
	
	import flash.net.URLRequestMethod;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	import org.flexunit.Assert;
	
	public class TrackerTest
	{
		private static const testURL:String = "d3rkrsqld9gmqf.cloudfront.net";
		
		[Test]
		public function testDefaultPlatform():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var subject:Subject = new Subject();
			var tracker:Tracker = new Tracker(emitter, subject, "AF003", "cloudfront", FlexGlobals.topLevelApplication.stage, false);
			Assert.assertEquals(DevicePlatform.DESKTOP, tracker.getPlatform());
		}
		
		[Test]
		public function testSetPlatform():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var subject:Subject = new Subject();
			var tracker:Tracker = new Tracker(emitter, subject, "AF003", "cloudfront", FlexGlobals.topLevelApplication.stage, false);
			tracker.setPlatform(DevicePlatform.CONNECTED_TV);
			Assert.assertEquals(DevicePlatform.CONNECTED_TV, tracker.getPlatform());
		}
		
		[Test]
		public function testSetSubject():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var s1:Subject = new Subject();
			var tracker:Tracker = new Tracker(emitter, s1, "AF003", "cloudfront", FlexGlobals.topLevelApplication.stage, false);
			var s2:Subject = new Subject();
			s2.setColorDepth(24);
			tracker.setSubject(s2);
			var subjectPairs:Object = {};

			var tzOffset:Number = (new Date()).getTimezoneOffset();
		
			subjectPairs["tz"] = "Etc/UTC"  + 
				(tzOffset < 0 ? "" : "+") +
				Util.padZeroes(Math.floor(tzOffset / 60)) + 
				":" +
				Util.padZeroes(tzOffset % 60);
			subjectPairs["cd"] = 24;
			Assert.assertTrue(Helpers.compareObjects(subjectPairs, tracker.getSubject().getSubject()));
		}
		
		[Test]
		public function testSetSchema():void {
			
		}
		
		[Test]
		public function testTrackPageView():void {
			
		}
		
		[Test]
		public function testTrackPageView1():void {
			
		}
		
		[Test]
		public function testTrackPageView2():void {
			
		}
		
		[Test]
		public function testTrackPageView3():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var subject:Subject = new Subject();
			subject.setViewPort(320, 480);
			var tracker:Tracker = new Tracker(emitter, subject, "AF003", "cloudfront", FlexGlobals.topLevelApplication.stage, false);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			
			var context:SchemaPayload = new SchemaPayload();
			var someContext:Object = {};
			someContext["someContextKey"] = "testTrackPageView3";
			context.setSchema("iglu:com.snowplowanalytics.snowplow/example/jsonschema/1-0-0");
			context.setData(someContext);
			var contextList:Array = [];
			contextList.push(context);
			
			tracker.trackPageView("www.mypage.com", "My Page", "www.me.com", contextList);
			
			emitter.flushBuffer();
		}
		
		[Test]
		public function testTrackStructuredEvent():void {
			
		}
		
		[Test]
		public function testTrackStructuredEvent1():void {
			
		}
		
		[Test]
		public function testTrackStructuredEvent2():void {
			
		}
		
		[Test]
		public function testTrackStructuredEvent3():void {
			
		}
		
		[Test]
		public function testTrackUnstructuredEvent():void {
			
		}
		
		[Test]
		public function testTrackUnstructuredEvent1():void {
			
		}
		
		[Test]
		public function testTrackUnstructuredEvent2():void {
			
		}
		
		[Test]
		public function testTrackUnstructuredEvent3():void {
			
		}
		
		[Test]
		public function testTrackEcommerceTransactionItem():void {
			
		}
		
		[Test]
		public function testTrackEcommerceTransaction():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var tracker:Tracker = new Tracker(emitter, null, "AF003", "cloudfront", FlexGlobals.topLevelApplication.stage, false);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			
			var context:SchemaPayload = new SchemaPayload();
			var someContext:Object = {};
			someContext["someContextKey"] = "testTrackPageView2";
			context.setSchema("iglu:com.snowplowanalytics.snowplow/example/jsonschema/1-0-0");
			context.setData(someContext);
			var contextList:Array = [];
			contextList.push(context);
			
			var transactionItem:TransactionItem = new TransactionItem("order-8", "no_sku",
				34.0, 1, "Big Order", "Food", "USD", contextList);
			var transactionItemLinkedList:Array = [];
			transactionItemLinkedList.push(transactionItem);
			tracker.trackEcommerceTransaction("order-7", 25.0, "no_affiliate", 0.0, 0.0, "Dover",
				"Delaware", "US", "USD", transactionItemLinkedList);
			
			emitter.flushBuffer();
		}
		
		[Test]
		public function testTrackEcommerceTransaction1():void {
			
		}
		
		[Test]
		public function testTrackEcommerceTransaction2():void {
			
		}
		
		[Test]
		public function testTrackEcommerceTransaction3():void {
			
		}
		
		[Test]
		public function testTrackScreenView():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var subject:Subject = new Subject();
			subject.setViewPort(320, 480);
			var tracker:Tracker = new Tracker(emitter, subject, "AF003", "cloudfront", FlexGlobals.topLevelApplication.stage, false);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			//emitter.setBufferOption(BufferOption.Instant);
			
			var context:SchemaPayload = new SchemaPayload();
			var someContext:Object = {};
			someContext["someContextKey"] = "testTrackPageView2";
			context.setSchema("iglu:com.snowplowanalytics.snowplow/example/jsonschema/1-0-0");
			context.setData(someContext);
			var contextList:Array = [];
			contextList.push(context);
			
			tracker.trackScreenView(null, "screen_1", contextList, 0);
		}
		
		[Test]
		public function testTrackScreenView1():void {
			
		}
		
		[Test]
		public function testTrackScreenView2():void {
			
		}
		
		[Test]
		public function testTrackScreenView3():void {
			
		}
		
	}
}