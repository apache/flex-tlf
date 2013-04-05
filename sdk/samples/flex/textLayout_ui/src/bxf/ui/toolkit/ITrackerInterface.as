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
package bxf.ui.toolkit
{
	import flash.events.MouseEvent;
	
	public interface ITrackerInterface {

		/**	Override to get cursor adjust hook and mouse down. 
		 * @param inMouseEvent mouse info.
		 * @param inCursorAdjust true if this is a mouse up track.*/
		function BeginTracking(inMouseEvent:MouseEvent, inCursorAdjust:Boolean):void;
		
		/**	Override to get mouse move. 
		 * @param inMouseEvent mouse info.*/
		function ContinueTracking(inMouseEvent:MouseEvent):void;
				
		/**	Override to get mouse up. 
		 * @param inMouseEvent mouse info.*/
		function EndTracking(inMouseEvent:MouseEvent):void;
	}
}
