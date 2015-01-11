package
{
	import com.snowplowanalytics.snowplow.tracker.Subject;
	
	import org.flexunit.Assert;

	public class SubjectTest
	{
		[Test]
		public function testSetUserId():void {
			var subject:Subject = new Subject();
			subject.setUserId("user1");
			Assert.assertEquals("user1", subject.getSubject()["uid"]);
		}
		
		[Test]
		public function testSetScreenResolution():void {
			var subject:Subject = new Subject();
			subject.setScreenResolution(100, 150);
			Assert.assertEquals("100x150", subject.getSubject()["res"]);
		}
		
		[Test]
		public function testSetViewPort():void {
			var subject:Subject = new Subject();
			subject.setViewPort(150, 100);
			Assert.assertEquals("150x100", subject.getSubject()["vp"]);
		}
		
		[Test]
		public function testSetColorDepth():void {
			var subject:Subject = new Subject();
			subject.setColorDepth(10);
			Assert.assertEquals("10", subject.getSubject()["cd"]);
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
			Assert.assertEquals("America/Toronto", subject.getSubject()["tz"]);
		}
		
		[Test]
		public function testSetLanguage():void {
			var subject:Subject = new Subject();
			subject.setLanguage("EN");
			Assert.assertEquals("EN", subject.getSubject()["lang"]);
		}
		
		[Test]
		public function testGetSubject():void {
			var subject:Subject = new Subject();
			var expected:Object = {};
			subject.setTimezone("America/Toronto");
			subject.setUserId("user1");
			
			expected["tz"] = "America/Toronto";
			expected["uid"] = "user1";
			
			Assert.assertTrue(Helpers.compareObjects(expected, subject.getSubject()));
		}
	}
}