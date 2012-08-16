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
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	
	import bxf.ui.controls.ConflictOverlay;
	
	public class ToggleButtonPropertyEditor extends PropertyEditorBase implements IPropertyEditor
	{
		private var mToggleButton:Button;
		private var mConflictOverlay:ConflictOverlay = null;
		private var mOverlayCanvas:Canvas;
		private var mCommitState:Boolean;
		private var mStyle:String;
		private var mLabel:String;
		private var mIcon:Class;
		private var mButtonWidth:Number;
		private var mFalseStr:String;
		private var mTrueStr:String;
		private var mChangeNotify:ValueChangeNotifier;
		private var mValue:Object = null;
		
		public function ToggleButtonPropertyEditor(inLabel:String, inIcon:Class, inPropName:String,
							inFalseStr:String, inTrueStr:String, inCommitState:Boolean, inStyle:String = "",
							inButtonWidth:Number = 0)
		{
			super("");
			mLabel = inLabel;
			mIcon = inIcon;
			mButtonWidth = inButtonWidth;
			mCommitState = inCommitState;
			mStyle = inStyle;
			mFalseStr = inFalseStr ? inFalseStr : "false";
			mTrueStr = inTrueStr ? inTrueStr : "true";
			
			mChangeNotify = new ValueChangeNotifier(inPropName, this);

		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			if (mToggleButton == null) {
				mToggleButton = new Button();

				mToggleButton.toggle = true;
				
				if (mStyle != "")
				{
					mToggleButton.styleName = mStyle;
				}
				
				mToggleButton.height = 16;
				mToggleButton.focusEnabled = false;
	
				mToggleButton.label = mLabel ? mLabel : "";
				if (mIcon)
					mToggleButton.setStyle("icon", mIcon);
				if (mButtonWidth)
					mToggleButton.width = mButtonWidth;

				mOverlayCanvas = new Canvas();
				mOverlayCanvas.setStyle("backgroundAlpha", 0);
				mOverlayCanvas.width = mToggleButton.width;
				mOverlayCanvas.height = mToggleButton.height;
				
				mOverlayCanvas.addChild(mToggleButton);
				addChild(mOverlayCanvas);
				
				mToggleButton.addEventListener(flash.events.MouseEvent.CLICK, onMouseClick);
				if (mValue)
					if (mValue is Array)
						setMultiValue(mValue as Array, "");
					else
						setValueAsString(mValue as String, "");
			}
		}
		
		public function onMouseClick(inEvt:MouseEvent):void {
			
			if (mCommitState)
				mChangeNotify.ValueCommitted(mToggleButton.selected ? mTrueStr : mFalseStr);
			else
				mChangeNotify.ValueEdited(mToggleButton.selected ? mTrueStr : mFalseStr);
			
			this.parentApplication.dispatchEvent(new Event(Event.ACTIVATE));
		}
		
		
		public function setValueAsString(inValue:String, inProperty:String):void {
			mValue = inValue;
			if (mToggleButton)
				mToggleButton.selected = (mValue == mTrueStr);
			if (mConflictOverlay)
				mConflictOverlay.visible = false;
		}
		
		public function setMultiValue(inValues:Array, inProperty:String):void {
			mValue = inValues;
			if (mToggleButton)
			{
				if (mConflictOverlay == null)
				{
					mConflictOverlay = new ConflictOverlay();
					mConflictOverlay.width = mToggleButton.width;
					mConflictOverlay.height = mToggleButton.height;
					mConflictOverlay.x = mToggleButton.x;
					mOverlayCanvas.addChild(mConflictOverlay);
				}
				setValueAsString(mFalseStr, inProperty);
				mConflictOverlay.visible = true;
			}
		}
		
	}
}
