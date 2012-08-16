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
package textEditBar
{
	import flash.events.Event;


	public class MultiContainerChangeEvent extends Event
	{
		public static const CONTAINER_PROPS_CHANGE:String = "containerPropsChange";
		public static const CONTAINER_DRAW_BOUNDS_CHANGE:String = "drawContainerBoundsChange";

		/** arrangement values */
		public static const ARRANGE_AS_VIEWSTACK:String = "arrangeAsViewStack";
		public static const ARRANGE_SIDE_BY_SIDE:String = "arrangeSideBySide";

		private var _numContainers:int;
		private var _arrangement:String;
		private var _visibleContainer:int;

		public function MultiContainerChangeEvent(type:String, numContainers:int, arrangement:String, visibleContainer:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_numContainers = numContainers;
			_arrangement = arrangement;
			_visibleContainer = visibleContainer;
			super(type, bubbles, cancelable);
		}

		override public function clone():Event
		{
			return new MultiContainerChangeEvent(type, _numContainers, _arrangement, _visibleContainer, bubbles, cancelable);
		}
		/** Number of containers */
		public function get numContainers():int
		{ return _numContainers; }
		/** Arrangement */
		public function get arrangement():String
		{ return _arrangement; }
		/** Container to show in view */
		public function get visibleContainer():int
		{ return _visibleContainer; }
	}
}
