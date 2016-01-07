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
		public function testBase64EncodeUnicode():void {
			var str:String = "Bobby\u1920s Story";
			
			var base64:String = Util.base64Encode(str);
			
			Assert.assertEquals("Qm9iYnnhpKBzIFN0b3J5", base64);
		}
		
		[Test]
		public function testJsonEncodeUnicodeNode():void {
			var map:Object = {};
			map["title"] = "Bobby\u1920s Story";
			
			var node:String = JSON.encode(map);
			
			Assert.assertEquals("{\"title\":\"Bobby\u0019s Story\"}", node);
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