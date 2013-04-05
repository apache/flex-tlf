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
	import flashx.textLayout.events.DamageEvent;

	public class DamageEventValidator extends EventValidator
	{
		public function DamageEventValidator(target:IEventDispatcher, expectedEvent:Event)
		{
			super(target, expectedEvent);
		}

		override protected function eventsAreEqual(event:Event, expectedEvent:Event):Boolean
		{
			return (DamageEvent(event).damageAbsoluteStart == DamageEvent(expectedEvent).damageAbsoluteStart &&
				DamageEvent(event).damageLength == DamageEvent(expectedEvent).damageLength);
		}

	}
}
