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
			payload["map"] = map;
			
			var res:String = "{\"map\":{\"more foo\":\"more bar\",\"foo\":\"bar\"}}";
			Assert.assertEquals(res, payload.toString());
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
			
			var res:String = "{\"myKey\":\"my Value\",\"mehh\":[\"somebar\",\"somebar2\"]}";
			Assert.assertEquals(res, payload.toString());
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
			
			var res:String = "{\"co\":\"{\\\"myKey\\\":\\\"my Value\\\",\\\"mehh\\\":[\\\"somebar\\\",\\\"somebar2\\\"]}\"}";
			Assert.assertEquals(res, payload.toString());
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
			
			var res:String = "{\"cx\":\"eyJteUtleSI6Im15IFZhbHVlIiwibWVoaCI6WyJzb21lYmFyIiwic29tZWJhcjIiXX0=\"}";
			Assert.assertEquals(res, payload.toString());
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
			payload["myarray"] = myarray;
			
			res = "{\"myarray\":[\"arrayItem\",\"arrayItem2\"]}";
			Assert.assertEquals(res, payload.toString());
			
			payload = new TrackerPayload();
			payload.add("foo", foo);
			
			res = "{\"foo\":{\"myKey\":\"my Value\",\"mehh\":[\"somebar\",\"somebar2\"]}}";
			Assert.assertEquals(res, payload.toString());
			
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
			
			Assert.assertEquals(data, payload.getMap());
		}
	}
}