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

  public interface IBuffer
  {
    /**
     * Returns the buffer content as an Array
     * @returns A Buffer
     */
    function get():Array;

    /**
     * Add payload to buffer.
     * @param Array of IPayloads
     */
    function push(payload: Array):void;

    /**
     * Returns the number of items in buffer
     */
     function length():int;

     /**
     * Return the byte size of the buffer
     */
     function size():int;

    /**
     * Clears the buffer.
     */
     function clear():void;
  }
}