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
	import flash.events.Event;
	
	import bxf.ui.controls.BxPopupMenu;
	import bxf.ui.controls.HUDComboPopupControl;
	
	public class ComboBoxPropertyEditor extends PropertyEditorBase implements IPropertyEditor
	{
		private var mChangeNotify:ValueChangeNotifier;
		private var mComboBox:HUDComboPopupControl;
		private var mComboBoxStyleName:String;
		private var mAvailVals:Array;
		private var mValueRemap:Object;
		private var mSelectedIdx:int = 0;
		private var mDeferredInitValue:String = null;
						
		public function ComboBoxPropertyEditor(inLabel:String, inPropName:String, inAvailVals:Array, inValueRemap:Object = null) {
			super(inLabel);

			mChangeNotify = new ValueChangeNotifier(inPropName, this);
			mComboBoxStyleName = "comboPropEditorValue";

			mAvailVals = inAvailVals;
			mValueRemap = (inValueRemap != null) ? inValueRemap : new Object();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			if (mComboBox == null) {	
				mComboBox = new HUDComboPopupControl(mAvailVals, mComboBoxStyleName);
				mComboBox.setStyle("paddingTop", 2);

				addChild(mComboBox);

				if (mDeferredInitValue != null && mDeferredInitValue != "")
				{
					mComboBox.value = mDeferredInitValue;
					mDeferredInitValue = null;
				}
				
				// Make sure the app knows that there is a value selected...
				else if (mAvailVals.length > 0)
				{
					var value:Object = mValueRemap[mComboBox.value];
					if (value == null)
						value = mComboBox.value;
		
					mChangeNotify.ValueCommitted(value);
				}
				 
				mComboBox.addEventListener(BxPopupMenu.SELECTION_CHANGED, onComboChanged);
			}		
		}

		private function onComboChanged(inEvt:Event):void {
			var value:Object = mValueRemap[mComboBox.value];
			if (value == null)
				value = mComboBox.value;

			mChangeNotify.ValueCommitted(value);
		}

		public function setValueAsString(inValue:String, inProperty:String):void {
			for (var userString:String in mValueRemap) {
				if (mValueRemap[userString] == inValue) {
					inValue = userString;
					break;
				}
			}
			
			if (mComboBox)
				mComboBox.value = inValue;
			else
				mDeferredInitValue = inValue;
		}

		
		public function setMultiValue(inValues:Array, inProperty:String):void {
			var value:String = "Mixed";
			if (mComboBox)
				mComboBox.value = value;
			else
				mDeferredInitValue = value;
		}
	}
}
