/*
* Copyright (c) 2016 Snowplow Analytics Ltd. All rights reserved.
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
  
  public class InMemoryBuffer implements IBuffer
  {

    private var buffer:Array;

    public function InMemoryBuffer()
    {
      this.buffer = [];
    }

    public function get():Array
    {
      return this.buffer;
    }

    public function push(payload: Array):void
    {
      this.buffer.concat(payload);
      return;
    }

    public function length():int
    {
      return this.buffer.length;
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