package
{
	import com.adobe.serialization.json.JSON;
	import com.snowplowanalytics.snowplow.tracker.Util;
	
	import org.flexunit.Assert;

	public class UtilTest
	{
		[Test]
		public function testGetTimestamp():void {
			Assert.assertNotNull(Util.getTimestamp());
		}
		
		[Test]
		public function testGetTransactionId():void {
			Assert.assertNotNull(Util.getTransactionId());
		}
		
		[Test]
		public function testMapToJsonNode():void {
			var map:Object = {};
			map["foo"] = "bar";
			
			var node:String = JSON.encode(map);
			
			Assert.assertEquals("{\"foo\":\"bar\"}", node);
		}
		
		[Test]
		public function testMapToJsonNode2():void {
			var map:Object = {};
			map["foo"] = "bar";
			
			var list:Array = [];
			list.push("some");
			list.push("stuff");
			
			map["list"] = list;
			
			var res1:String = "{\"list\":[\"some\",\"stuff\"],\"foo\":\"bar\"}";
			var res2:String = "{\"foo\":\"bar\",\"list\":[\"some\",\"stuff\"]}";
			var node:String = JSON.encode(map);
			
			Assert.assertTrue(node == res1 || node == res2);
		}

	}
}