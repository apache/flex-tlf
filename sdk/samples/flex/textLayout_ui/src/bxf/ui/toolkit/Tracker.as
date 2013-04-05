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
	import bxf.ui.utils.EffectiveStage;
	import mx.core.UIComponent;
	import mx.managers.ISystemManager;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class Tracker extends UIComponent implements ITrackerInterface
	{
		public function Tracker(inPeerToTrackTo:UIComponent, inStageX:int, inStageY:int)
		{
			super();
			mouseEnabled = false;
			sm = inPeerToTrackTo.systemManager.topLevelSystemManager;
			x = inStageX;
			y = inStageY;
			mPeerToTrackTo = inPeerToTrackTo;
			mPeerToTrackTo.parent.addChild(this);
			EffectiveStage(this).addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
			sm.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
			EffectiveStage(this).addEventListener(Event.MOUSE_LEAVE, onMouseLeave, false);
		}
		
		public function Remove():void
		{
			EffectiveStage(this).removeEventListener(Event.MOUSE_LEAVE, onMouseLeave, false);
			EffectiveStage(this).removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
			sm.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
			mPeerToTrackTo.parent.removeChild(this);
			mPeerToTrackTo = null;
		}
		
		/**	Override to get cursor adjust hook and mouse down. 
		 * @param inMouseEvent mouse info.
		 * @param inCursorAdjust true if this is a mouse up track.*/
		public function BeginTracking(inMouseEvent:MouseEvent, inCursorAdjust:Boolean):void
		{
			mLastMouseEvent = inMouseEvent;
			TrackPoint(inMouseEvent, true);
		}
		
		/**	Override to get mouse move. 
		 * @param inMouseEvent mouse info.*/
		public function ContinueTracking(inMouseEvent:MouseEvent):void
		{
			TrackPoint(inMouseEvent, false);
		}
		
		/**	Override to get mouse up. 
		 * @param inMouseEvent mouse info.*/
		public function EndTracking(inMouseEvent:MouseEvent):void
		{
			TrackPoint(inMouseEvent, false);
		}
		
		protected function TrackPoint(inMouseEvent:MouseEvent, inAlsoSetAnchor:Boolean): void
		{
			mTrackPt.x = inMouseEvent.stageX;
			mTrackPt.y = inMouseEvent.stageY;
			mTrackPt = globalToLocal(mTrackPt);
			if (inAlsoSetAnchor)
				mAnchorPt = mTrackPt.clone();
		}

		private function onMouseMove(evt:MouseEvent):void
		{
			mLastMouseEvent = evt;
			ContinueTracking(evt);
		}

		private function onMouseUp(evt:MouseEvent):void
		{
			EndTracking(evt);
			Remove();
		}

		private function onMouseLeave(evt:Event):void
		{
			EndTracking(mLastMouseEvent);
			Remove();
		}


		private var mPeerToTrackTo:UIComponent = null;
		private var sm:ISystemManager = null;
		private var mLastMouseEvent:MouseEvent = null;
		protected var mTrackPt:Point = new Point;
		protected var mAnchorPt:Point = new Point;
	}
}
