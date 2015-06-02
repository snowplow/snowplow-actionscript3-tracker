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
	import com.snowplowanalytics.snowplow.tracker.payload.IPayload;
	import com.snowplowanalytics.snowplow.tracker.payload.SchemaPayload;
	import com.snowplowanalytics.snowplow.tracker.payload.TrackerPayload;
	
	import org.flexunit.Assert;

	public class TrackerPayloadTest
	{
		[Test]
		public function testAddString():void {
			var payload:IPayload = new TrackerPayload();
			payload.add("foo", "bar");
			
			var res:String = "{\"foo\":\"bar\"}";
			Assert.assertEquals(res, payload.toString());
		}
		
		[Test]
		public function testAddObject():void {
			var payload:IPayload = new TrackerPayload();
			var map:Object = {};
			map["foo"] = "bar";
			map["more foo"] = "more bar";
			payload.add("map", map);
			
			var res1:String = "{\"map\":{\"foo\":\"bar\",\"more foo\":\"more bar\"}}";
			var res2:String = "{\"map\":{\"more foo\":\"more bar\",\"foo\":\"bar\"}}";
			var payloadString:String = payload.toString();
			Assert.assertTrue(payloadString == res1 || payloadString == res2);
		}
		
		[Test]
		public function testAddMap():void {
			var foo:Object = {};
			var bar:Array = [];
			bar.push("somebar");
			bar.push("somebar2");
			foo["myKey"] = "my Value";
			foo["mehh"] = bar;
			var payload:IPayload = new TrackerPayload();
			payload.addMap(foo);
			
			var res1:String = "{\"myKey\":\"my Value\",\"mehh\":[\"somebar\",\"somebar2\"]}";
			var res2:String = "{\"mehh\":[\"somebar\",\"somebar2\"],\"myKey\":\"my Value\"}";
			var payloadString:String = payload.toString();
			Assert.assertTrue(payloadString == res1 || payloadString == res2);
		}
		
		[Test]
		public function testAddMapNotEncoding():void {
			var foo:Object = {};
			var bar:Array = [];
			bar.push("somebar");
			bar.push("somebar2");
			foo["myKey"] = "my Value";
			foo["mehh"] = bar;
			var payload:IPayload = new TrackerPayload();
			payload.addMap(foo, false, "cx", "co");
			
			var res1:String = "{\"co\":\"{\\\"myKey\\\":\\\"my Value\\\",\\\"mehh\\\":[\\\"somebar\\\",\\\"somebar2\\\"]}\"}";
			var res2:String = "{\"co\":\"{\\\"mehh\\\":[\\\"somebar\\\",\\\"somebar2\\\"],\\\"myKey\\\":\\\"my Value\\\"}\"}";
			var payloadString:String = payload.toString();
			
			Assert.assertTrue(payloadString == res1 || payloadString == res2);
		}
		
		[Test]
		public function testAddMapEncoding():void {
			var foo:Object = {};
			var bar:Array = [];
			bar.push("somebar");
			bar.push("somebar2");
			foo["myKey"] = "my Value";
			foo["mehh"] = bar;
			var payload:IPayload = new TrackerPayload();
			payload.addMap(foo, true, "cx", "co");
			
			var res1:String = "{\"cx\":\"eyJteUtleSI6Im15IFZhbHVlIiwibWVoaCI6WyJzb21lYmFyIiwic29tZWJhcjIiXX0=\"}";
			var res2:String = "{\"cx\":\"eyJteUtleSI6Im15IFZhbHVlIiwibWVoaCI6WyJzb21lYmFyIiwic29tZWJhcjIiXX0\"}";
			var res3:String = "{\"cx\":\"eyJtZWhoIjpbInNvbWViYXIiLCJzb21lYmFyMiJdLCJteUtleSI6Im15IFZhbHVlIn0=\"}";
			var res4:String = "{\"cx\":\"eyJtZWhoIjpbInNvbWViYXIiLCJzb21lYmFyMiJdLCJteUtleSI6Im15IFZhbHVlIn0\"}";
			
			var payloadString:String = payload.toString();
			
			Assert.assertTrue(payloadString == res1 || payloadString == res2 || payloadString == res3 || payloadString == res4);
		}
		
		[Test]
		public function testSetData():void {
			var payload:IPayload;
			var res:String;
			var foo:Object = {};
			var bar:Array = [];
			bar.push("somebar");
			bar.push("somebar2");
			foo["myKey"] = "my Value";
			foo["mehh"] = bar;
			var myarray:Array = ["arrayItem","arrayItem2"];
			payload = new TrackerPayload();
			payload.add("myarray", myarray);
			
			res = "{\"myarray\":[\"arrayItem\",\"arrayItem2\"]}";
			Assert.assertEquals(res, payload.toString());
			
			payload = new TrackerPayload();
			payload.add("foo", foo);
			
            res = "{\"foo\":{\"myKey\":\"my Value\",\"mehh\":[\"somebar\",\"somebar2\"]}}";
			var res2:String = "{\"foo\":{\"mehh\":[\"somebar\",\"somebar2\"],\"myKey\":\"my Value\"}}";
			var payloadString:String = payload.toString();
			Assert.assertTrue(res == payloadString || res2 == payloadString);
			
			payload = new TrackerPayload();
			payload.add("bar", bar);
			
			res = "{\"bar\":[\"somebar\",\"somebar2\"]}";
			Assert.assertEquals(res, payload.toString());
		}
		
		[Test]
		public function testSetSchema():void {
			var payload:SchemaPayload = new SchemaPayload();
			payload.setSchema("iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-0");
			var res:String = "{\"schema\":\"iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-0\"}";
			Assert.assertEquals(res, payload.toString());
		}
		
		[Test]
		public function testGetMap():void {
			var payload:SchemaPayload;
			var res:String;
			var foo:Object = {};
			var bar:Array = [];
			bar.push("somebar");
			bar.push("somebar2");
			foo["myKey"] = "my Value";
			foo["mehh"] = bar;
			var data:Object = {};
			data["data"] = foo;
			payload = new SchemaPayload();
			payload.setData(foo);
			
			Assert.assertTrue(Helpers.compareObjects(data, payload.getMap()));
		}
	}
}