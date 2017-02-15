/*
 * Copyright (c) 2017 Snowplow Analytics Ltd. All rights reserved.
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
    import com.snowplowanalytics.snowplow.tracker.emitter.IBuffer;
    import com.snowplowanalytics.snowplow.tracker.payload.IPayload;
    import com.snowplowanalytics.snowplow.tracker.payload.TrackerPayload;
    import com.snowplowanalytics.snowplow.tracker.emitter.LocalStorageBuffer;
    import com.snowplowanalytics.snowplow.tracker.emitter.BufferEvent;

    import flash.events.Event;
    import org.flexunit.Assert;
    import org.flexunit.async.Async;

    public class LocalStorageBufferTest {

        private var buffer:LocalStorageBuffer;
        private var payload:IPayload;
        private var bufferSize:int = 105;

        [Before]
        public function setUp():void {
            this.buffer = new LocalStorageBuffer("PRIMARY_BUFFER", this.bufferSize);
            this.payload = new TrackerPayload();
            var _map:Object = {"foo":"bar"};
            this.payload.add("map", _map);
        }

        [Test]
        public function testInMemoryBufferSize():void {
            this.buffer.push(this.payload);
            this.buffer.push(this.payload);
            Assert.assertEquals(this.buffer.size(), this.payload.size() * 2);
        }

        [Test]
        public function testInMemoryBufferClear():void {
            this.buffer.push(this.payload);
            this.buffer.push(this.payload);
            Assert.assertEquals(this.buffer.size(), this.payload.size() * 2);
            this.buffer.clear();
            Assert.assertEquals(this.buffer.size(), 0);
        }

        [Test(async, description="Buffer full event")]
        public function testInMemoryBufferPush():void {
            var timeout:int = 500;
            var callCompleted:Boolean = false;

            function handleTimeout(passThroughData:Object):void {
                if (!callCompleted) {
                    Assert.fail("Timeout reached before event");
                }
            }
            var onBufferFull:Function = Async.asyncHandler(this,
                    function (event:Event, passThroughData:Object):void {
                        Assert.assertEquals(1, 1);
                    },
                    timeout,
                    null,
                    handleTimeout
            );
            this.buffer.addEventListener(BufferEvent.FULL, onBufferFull);
            for (var i:int=0; i<6; i++) {
                this.buffer.push(this.payload);
            }
        }
    }

}