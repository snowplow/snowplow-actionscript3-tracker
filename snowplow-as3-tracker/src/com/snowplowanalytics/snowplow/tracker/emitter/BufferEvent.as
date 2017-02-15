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
    import flash.events.Event;

    public class BufferEvent extends Event
    {
        public static const FULL:String = "BUFFER_FULL";

        public var payloads:Array;
        public var bufferId:String;

        public function BufferEvent(type:String, bufferId:String, payloads:Array, errorInfo:String = null, bubbles:Boolean=false, cancelable:Boolean=false):void
        {
            super(type, bubbles, cancelable);
            this.bufferId = bufferId;
            this.payloads = payloads;
        }
    }
}