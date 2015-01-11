package
{
	import com.snowplowanalytics.snowplow.tracker.Subject;
	
	import org.flexunit.Assert;

	public class SubjectTest
	{
		[Test]
		public function testSetUserId():void {
			subject:Subject = new Subject();
			subject.setUserId("user1");
			Assert.assertEquals("user1", subject.getSubject().get("uid"));
		}
		
		[Test]
		public function testSetScreenResolution():void {
			var subject:Subject = new Subject();
			subject.setScreenResolution(100, 150);
			Assert.assertEquals("100x150", subject.getSubject().get("res"));
		}
		
		[Test]
		public function testSetViewPort():void {
			var subject:Subject = new Subject();
			subject.setViewPort(150, 100);
			Assert.assertEquals("150x100", subject.getSubject().get("vp"));
		}
		
		[Test]
		public function testSetColorDepth():void {
			var subject:Subject = new Subject();
			subject.setColorDepth(10);
			Assert.assertEquals("10", subject.getSubject().get("cd"));
		}
		
		// Enable only if running locally, change assert to your local timezone
		//    [Test]
		//    public function testSetTimezone():void {
		//        var subject:Subject = new Subject();
		//        Assert.assertEquals("America/Toronto", subject.getSubject().get("tz"));
		//    }
		
		[Test]
		public function testSetTimezone2():void {
			var subject:Subject = new Subject();
			subject.setTimezone("America/Toronto");
			Assert.assertEquals("America/Toronto", subject.getSubject().get("tz"));
		}
		
		[Test]
		public function testSetLanguage():void {
			var subject:Subject = new Subject();
			subject.setLanguage("EN");
			Assert.assertEquals("EN", subject.getSubject().get("lang"));
		}
		
		[Test]
		public function testGetSubject():void {
			var subject:Subject = new Subject();
			var expected:Object = {};
			subject.setTimezone("America/Toronto");
			subject.setUserId("user1");
			
			expected["tz"] = "America/Toronto";
			expected["uid"] = "user1";
			
			Assert.assertEquals(expected, subject.getSubject());
		}
	}
}