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
  import com.snowplowanalytics.snowplow.tracker.Parameter;

  public final class EmitterProtocol
  {

    public var scheme:String;

    public function EmitterProtocol(scheme:String)
		{
			switch (scheme)
      {
        case Parameter.PROTOCOL_HTTPS:
          this.scheme = Parameter.PROTOCOL_HTTPS;
          break;
        case Parameter.PROTOCOL_HTTP:
          this.scheme = Parameter.PROTOCOL_HTTP;
          break;
        case Parameter.PROTOCOL_AUTO:
          this.scheme = Parameter.PROTOCOL_AUTO;
          break;
        default:
          throw new EmitterError("Invalid Protocol provided to emitter. Use http/https or Auto to detect from uri.");
      }
		}
  }
}