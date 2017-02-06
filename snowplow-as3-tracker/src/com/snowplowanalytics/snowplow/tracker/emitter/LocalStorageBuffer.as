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

  import flash.net.SharedObject;

  public class LocalStorageBuffer implements IBuffer
  {

    private var buffer:SharedObject;
    private var SHARED_OBJECT_BUFFER_NAME:String = "com.snowplowanalytics.snowplow-as3-tracker.buffer";

    public function LocalStorageBuffer()
    {
      this.buffer = SharedObject.getLocal(SHARED_OBJECT_BUFFER_NAME);
      this.buffer[SHARED_OBJECT_BUFFER_NAME] = [];
    }

    public function get():Array
    {
      return this.buffer.data[SHARED_OBJECT_BUFFER_NAME];
    }

    public function push(payload: Array):void
    {
      var _q:Array = this.buffer.data[SHARED_OBJECT_BUFFER_NAME];
      if (_q == null)
      {
        _q = [];
      }
      _q.concat(payload)
      this.buffer.data[SHARED_OBJECT_BUFFER_NAME] = _q;
      this.buffer.flush();
    }

    public function length():int
    {
      return this.buffer.data[SHARED_OBJECT_BUFFER_NAME].length;
    }

    public function size():int
    {
      var _data:Array = this.buffer.data[SHARED_OBJECT_BUFFER_NAME];
      var _size: int = 0;
      for each (var payload:IPayload in _data) {
        _size += payload.size();
      }
      return _size;
    }

    public function clear():void
    {
      this.buffer.data[SHARED_OBJECT_BUFFER_NAME] = [];
      this.buffer.flush();
    }
  }
}