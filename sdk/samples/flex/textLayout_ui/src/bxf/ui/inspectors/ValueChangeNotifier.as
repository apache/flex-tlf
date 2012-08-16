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
package bxf.ui.inspectors
{
	import flash.events.IEventDispatcher;
	
	/**
	 * Used by the property (and soon action argument) editors to communicate changes back
	 * to the client.  As of inital writing, it calls callback functions, but that will be
	 * migrating to events. Consolidating it here makes that easier.  
	 **/
	public class ValueChangeNotifier
	{
		public function ValueChangeNotifier(inPropName:String, dispatcher:IEventDispatcher)
		{
			mPropName = inPropName;
			mDispatcher = dispatcher;
			commitOngoing = false;
		}

		public function ValueEdited(newValue:Object):void
		{
			mDispatcher.dispatchEvent(new PropertyEditEvent(PropertyEditEvent.VALUE_EDITED, mPropName, newValue));
		}
		
		public function ValueCommitted(newValue:Object):void
		{
			// Protect against reentrancy. When doing a commit in response to a keyDown (enter key), we can get a loseFocus that 
			// comes through and commits again, causing the change to made twice. 
			if (!commitOngoing)
			{
				commitOngoing = true;
				mDispatcher.dispatchEvent(new PropertyEditEvent(PropertyEditEvent.VALUE_CHANGED, mPropName, newValue));
				commitOngoing = false;
			}
		}
		
		private var mPropName:String;
		private var mDispatcher:IEventDispatcher;
		private var commitOngoing:Boolean;

	}
}
