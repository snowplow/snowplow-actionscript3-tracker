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
		private static const testURL:String = "astracker.snplow.com";
		
		[Test]
		public function testDefaultPlatform():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var subject:Subject = new Subject();
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", subject, FlexGlobals.topLevelApplication.stage, false);
			Assert.assertEquals(DevicePlatform.WEB, tracker.getPlatform());
		}
		
		[Test]
		public function testSetPlatform():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var subject:Subject = new Subject();
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", subject, FlexGlobals.topLevelApplication.stage, false);
			tracker.setPlatform(DevicePlatform.CONNECTED_TV);
			Assert.assertEquals(DevicePlatform.CONNECTED_TV, tracker.getPlatform());
		}
		
		[Test]
		public function testSetSubject():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var s1:Subject = new Subject();
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", s1, FlexGlobals.topLevelApplication.stage, false);
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
		public function testTrackPageViewPost():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var subject:Subject = new Subject();
			subject.setViewPort(320, 480);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", subject, FlexGlobals.topLevelApplication.stage, false);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;

			var context:SchemaPayload = new SchemaPayload();
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
			context.setData(someContext);
			
			var contextList:Array = [];
			contextList.push(context);
			
			tracker.trackPageView("www.mypage.com", "My Page", "www.me.com", contextList);
			
			emitter.flushBuffer();
		}
		
		[Test]
		public function testTrackPageViewPostBase64():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var subject:Subject = new Subject();
			subject.setViewPort(320, 480);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", subject, FlexGlobals.topLevelApplication.stage, true);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			var context:SchemaPayload = new SchemaPayload();
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
			context.setData(someContext);
			
			var contextList:Array = [];
			contextList.push(context);
			
			tracker.trackPageView("www.mypage.com", "My Page", "www.me.com", contextList);
			
			emitter.flushBuffer();
		}		
		
		[Test]
		public function testTrackPageViewGet():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.GET);
			var subject:Subject = new Subject();
			subject.setViewPort(320, 480);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", subject, FlexGlobals.topLevelApplication.stage, false);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			var context:SchemaPayload = new SchemaPayload();
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
			context.setData(someContext);
			
			var contextList:Array = [];
			contextList.push(context);
			
			tracker.trackPageView("www.mypage.com", "My Page", "www.me.com", contextList);
			
			emitter.flushBuffer();
		}
		
		[Test]
		public function testTrackPageViewGetBase64():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.GET);
			var subject:Subject = new Subject();
			subject.setViewPort(320, 480);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", subject, FlexGlobals.topLevelApplication.stage, true);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			var context:SchemaPayload = new SchemaPayload();
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
			context.setData(someContext);
			
			var contextList:Array = [];
			contextList.push(context);
			
			tracker.trackPageView("www.mypage.com", "My Page", "www.me.com", contextList);
			
			emitter.flushBuffer();
		}		
	
		[Test]
		public function testTrackStructuredEventGet():void {
			/*var expected:Object = {
				tv: Version.TRACKER,
					tna: 'cf',
					aid: 'cfe35',
					e: 'se',
					se_ca: 'clothes',
					se_ac: 'add_to_basket',
					se_la: undefined,
					se_pr: 'red',			
					se_va: '15'
			};*/
			
			var e:Emitter = new Emitter(testURL, URLRequestMethod.GET);
			
			var t:Tracker = new Tracker(e, 'cf', 'cfe35', null, FlexGlobals.topLevelApplication.stage, false);

			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			var context:SchemaPayload = new SchemaPayload();
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
			context.setData(someContext);

			var contextList:Array = [];
			contextList.push(context);
			
			t.trackStructuredEvent('clothes', 'add_to_basket', 'struct_label', 'red', 15, contextList);
		}
		
		[Test]
		public function testTrackStructuredEventPost():void {
/*			var expected:Object = {
				tv: Version.TRACKER,
					tna: 'cf',
					aid: 'cfe35',
					e: 'se',
					se_ca: 'clothes',
					se_ac: 'add_to_basket',
					se_la: undefined,
					se_pr: 'red',			
					se_va: '15'
			};
*/			
			var e:Emitter = new Emitter(testURL, URLRequestMethod.POST);

			var t:Tracker = new Tracker(e, 'cf', 'cfe35', null, FlexGlobals.topLevelApplication.stage, false);
			
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			var context:SchemaPayload = new SchemaPayload();
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
			context.setData(someContext);
			
			var contextList:Array = [];
			contextList.push(context);
			
			t.trackStructuredEvent('clothes', 'add_to_basket', 'struct_label', 'red', 15, contextList);
		}

		[Test]
		public function testTrackStructuredEventGetBase64():void {
			/*var expected:Object = {
			tv: Version.TRACKER,
			tna: 'cf',
			aid: 'cfe35',
			e: 'se',
			se_ca: 'clothes',
			se_ac: 'add_to_basket',
			se_la: undefined,
			se_pr: 'red',			
			se_va: '15'
			};*/
			
			var e:Emitter = new Emitter(testURL, URLRequestMethod.GET);
			
			var t:Tracker = new Tracker(e, 'cf', 'cfe35', null, FlexGlobals.topLevelApplication.stage, true);
			
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			var context:SchemaPayload = new SchemaPayload();
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
			context.setData(someContext);
			
			var contextList:Array = [];
			contextList.push(context);
			
			t.trackStructuredEvent('clothes', 'add_to_basket', 'struct_label', 'red', 15, contextList);
		}
		
		[Test]
		public function testTrackStructuredEventPostBase64():void {
			/*			var expected:Object = {
			tv: Version.TRACKER,
			tna: 'cf',
			aid: 'cfe35',
			e: 'se',
			se_ca: 'clothes',
			se_ac: 'add_to_basket',
			se_la: undefined,
			se_pr: 'red',			
			se_va: '15'
			};
			*/			
			var e:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			
			var t:Tracker = new Tracker(e, 'cf', 'cfe35', null, FlexGlobals.topLevelApplication.stage, true);
			
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			var context:SchemaPayload = new SchemaPayload();
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
			context.setData(someContext);
			
			var contextList:Array = [];
			contextList.push(context);
			
			t.trackStructuredEvent('clothes', 'add_to_basket', 'struct_label', 'red', 15, contextList);
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
		public function testTrackSelfDescribingEvent():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", null, FlexGlobals.topLevelApplication.stage, false);
			var eventData:SchemaPayload = new SchemaPayload()
			eventData.add("temp", "100");
			tracker.trackSelfDescribingEvent(eventData, null, 1479808724);
		}
		
		[Test]
		public function testTrackEcommerceTransactionPost():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", null, FlexGlobals.topLevelApplication.stage, false);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			
			var context:SchemaPayload = new SchemaPayload();
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
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
		public function testTrackEcommerceTransactionPostBase64():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", null, FlexGlobals.topLevelApplication.stage, true);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			
			var context:SchemaPayload = new SchemaPayload();
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
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
		public function testTrackEcommerceTransactionGet():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.GET);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", null, FlexGlobals.topLevelApplication.stage, false);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			
			var context:SchemaPayload = new SchemaPayload();
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
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
		public function testTrackEcommerceTransactionGetBase64():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.GET);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", null, FlexGlobals.topLevelApplication.stage, true);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			
			var context:SchemaPayload = new SchemaPayload();
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
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
		public function testTrackScreenViewPost():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var subject:Subject = new Subject();
			subject.setViewPort(320, 480);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", subject, FlexGlobals.topLevelApplication.stage, false);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			//emitter.setBufferOption(BufferOption.Instant);
			
			var context:SchemaPayload = new SchemaPayload();
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
			context.setData(someContext);
			var contextList:Array = [];
			contextList.push(context);
			
			tracker.trackScreenView(null, "screen_1", contextList, 0);
		}
		
		[Test]
		public function testTrackScreenViewPostBase64():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.POST);
			var subject:Subject = new Subject();
			subject.setViewPort(320, 480);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", subject, FlexGlobals.topLevelApplication.stage, true);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			//emitter.setBufferOption(BufferOption.Instant);
			
			var context:SchemaPayload = new SchemaPayload();
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
			context.setData(someContext);
			var contextList:Array = [];
			contextList.push(context);
			
			tracker.trackScreenView(null, "screen_1", contextList, 0);
		}
		
		[Test]
		public function testTrackScreenViewGet():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.GET);
			var subject:Subject = new Subject();
			subject.setViewPort(320, 480);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", subject, FlexGlobals.topLevelApplication.stage, false);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			//emitter.setBufferOption(BufferOption.Instant);
			
			var context:SchemaPayload = new SchemaPayload();
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
			context.setData(someContext);
			var contextList:Array = [];
			contextList.push(context);
			
			tracker.trackScreenView(null, "screen_1", contextList, 0);
		}
		
		[Test]
		public function testTrackScreenViewGetBase64():void {
			var emitter:Emitter = new Emitter(testURL, URLRequestMethod.GET);
			var subject:Subject = new Subject();
			subject.setViewPort(320, 480);
			var tracker:Tracker = new Tracker(emitter, "AF003", "cloudfront", subject, FlexGlobals.topLevelApplication.stage, true);
			//emitter.setRequestMethod(RequestMethod.Asynchronous);
			//emitter.setBufferOption(BufferOption.Instant);
			
			var context:SchemaPayload = new SchemaPayload();
			var someContext:Object = {};
			someContext["latitude"] = 31.778013
			someContext["longitude"] = 35.235379;
			
			context.setSchema("iglu:com.snowplowanalytics.snowplow/geolocation_context/jsonschema/1-0-0");
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