////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package UnitTest.Validation
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.events.StatusChangeEvent;

	public class StatusChangeEventValidator extends EventValidator
	{
		public function StatusChangeEventValidator(target:IEventDispatcher, expectedEvent:Event)
		{
			super(target, expectedEvent);
		}

		override protected function eventsAreEqual(event:Event, expectedEvent:Event):Boolean
		{
			StatusChangeEvent(event).errorEvent = StatusChangeEvent(event).errorEvent;
			StatusChangeEvent(event).element = StatusChangeEvent(event).element;
			StatusChangeEvent(event).status = StatusChangeEvent(event).status;
			return (StatusChangeEvent(event).errorEvent == StatusChangeEvent(expectedEvent).errorEvent &&
					StatusChangeEvent(event).status == StatusChangeEvent(expectedEvent).status);

		}
	}
}
