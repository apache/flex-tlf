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
	import flexunit.framework.Assert;

	public class EventValidator
	{
		private var _eventCount:int;
		private var _expectedEvent:Event;
		private var _target:IEventDispatcher;
		private var _attachCount:int;

		public var lastEvent:Event;
		
		public function EventValidator(target:IEventDispatcher, expectedEvent:Event)
		{
			_target = target;
			_attachCount = 0;
			reset(expectedEvent);
		}

		protected function validateHandler(event:Event):void
		{
	   		if (event.type == _expectedEvent.type && eventsAreEqual(event, _expectedEvent))
			{
				lastEvent = event;
	   			++_eventCount;
			}
		}

		protected function eventsAreEqual(event:Event, expectedEvent:Event):Boolean
		{
			return true; // override in derived class
		}

		public function validate(count:int):Boolean
		{
			var result:Boolean = _eventCount == count;
			_eventCount = 0;
	   		_target.removeEventListener(_expectedEvent.type, validateHandler);
	   		--_attachCount;
			Assert.assertTrue("Expected to get an event, but didn't", result);
			return result;
		}
		
		public function reset(expectedEvent:Event = null):void
		{
			CONFIG::debug { assert (_attachCount == 0, "Expected previous call to validate"); }
			if (expectedEvent != null)
				_expectedEvent = expectedEvent;
			_eventCount = 0;
			lastEvent = null;
	   		_target.addEventListener(_expectedEvent.type, validateHandler);
	   		++_attachCount;
		}
	}
}
