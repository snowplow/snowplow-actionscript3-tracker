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

package com.snowplowanalytics.snowplow.tracker.emitter
{
    import com.snowplowanalytics.snowplow.tracker.payload.IPayload;

    import flash.events.EventDispatcher;

    public class InMemoryBuffer extends EventDispatcher implements IBuffer
    {
        private var id:String;
        private var buffer:Array;
        private var bufferSize:int;

        public function InMemoryBuffer(id:String, size:int)
        {
            this.id = id;
            this.bufferSize = size;
            this.buffer = [];
        }

        public function push(payload: IPayload):void
        {
            this.buffer.push(payload);
            if (this.size() >= this.bufferSize) {
                var payloads:Array = this.buffer;
                this.clear();
                dispatchEvent(new BufferEvent(BufferEvent.FULL, this.id, payloads));
            }
            return;
        }

        public function size():int
        {
            var _size: int = 0;
            for each (var payload:IPayload in this.buffer) {
                _size += payload.size();
            }
            return _size;
        }

        public function clear():void
        {
            this.buffer =  [];
        }
    }
}