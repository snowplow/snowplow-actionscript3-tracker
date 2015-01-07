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

package com.snowplowanalytics.snowplow.tracker.core
{
	import com.snowplowanalytics.snowplow.tracker.core.emitter.Emitter;
	import com.snowplowanalytics.snowplow.tracker.core.subject.Subject;

	public class Tracker
	{
		private var base64Encoded:Boolean = true;
		private var emitter:Emitter;
		private var platform:String;
		private var appId:String;
		private var namespace:String;
		private var trackerVersion:String;
		private var subject:Subject;
		
		/**
		 * @param emitter Emitter to which events will be sent
		 * @param subject Subject to be tracked
		 * @param namespace Identifier for the Tracker instance
		 * @param appId Application ID
		 * @param base64Encoded Whether JSONs in the payload should be base-64 encoded
		 */
		function Tracker(emitter:Emitter, subject:Subject, namespace:String, appId:String, base64Encoded:Boolean = true) {
				this.emitter = emitter;
				this.appId = appId;
				this.base64Encoded = base64Encoded;
				this.namespace = namespace;
				this.subject = subject;
				this.trackerVersion = Version.TRACKER;
				this.platform = DevicePlatform.DESKTOP;
			}
	}
}