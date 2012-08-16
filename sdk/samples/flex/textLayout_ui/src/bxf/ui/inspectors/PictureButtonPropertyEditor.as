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
	import flash.external.*;
	//import ControllerInterface.ExternalInterfaceConstants;
	
	import mx.controls.Button;
	
	public class PictureButtonPropertyEditor extends PropertyEditorBase implements IPropertyEditor
	{
		private var mButton:Button;
		private var mStyle:String;
		private var mTooltip:String;
		private var mCmd:int;
		
		public function PictureButtonPropertyEditor(inCmd:int, inStyle:String, inTooltip:String)
		{
			// style specifies all skins!
			// inCmd is cmd to send when clicked
			super("");
			mStyle = inStyle;
			mCmd = inCmd;
			mTooltip = inTooltip;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			if (mButton == null) {
				mButton = new Button();

				if (mStyle != "")
				{
					mButton.styleName = mStyle;
				}
				addChild(mButton);
				if (mTooltip != "") {
					mButton.toolTip = mTooltip;
				}
				mButton.addEventListener( flash.events.MouseEvent.CLICK, onMouseClick);
			}
		}
		
		private function onMouseClick (mouseEvent: flash.events.MouseEvent):void {
		// sent event to host app -- this should really send command for flex app too, but can't figure out how to get toolbar controller
		// to just send command for flex app
			trace("send command: ", mCmd);
			//ExternalInterface.call(ExternalInterfaceConstants.cExecuteCommand, mCmd);
 		}

		
		public function setValueAsString(inValue:String, inProperty:String):void {
			// do nothing for this
		}
		
		
		public function setMultiValue(inValues:Array, inProperty:String):void {
			trace(this.className + ": Multivalue not supported yet.");
			setValueAsString(inValues[0], inProperty);
		}
	}
}

