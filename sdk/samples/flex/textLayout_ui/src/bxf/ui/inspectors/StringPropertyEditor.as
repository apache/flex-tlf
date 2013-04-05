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
	import flash.events.FocusEvent;
	
	import mx.controls.Text;
	import mx.events.FlexEvent;

	public class StringPropertyEditor extends PropertyEditorBase implements IPropertyEditor
	{
		private var mChangeNotify:ValueChangeNotifier;
		
		private var mLabel:mx.controls.Text;
		private var mVal:mx.controls.TextInput;
		private var mFieldWid:int;
		private var mValStr:String;
		
		
		public function StringPropertyEditor(inLabel:String, inPropName:String, inFieldWid:int = 36):void
		{
			super(inLabel);
			mChangeNotify = new ValueChangeNotifier(inPropName, this);
			mFieldWid = inFieldWid;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			if (mVal == null) {
				mVal = new mx.controls.TextInput();
				mVal.styleName = "stringPropertyEditor";
				mVal.setStyle("fontFamily", "_sans"); 				
				
				addChild(mVal);

				mVal.width = mFieldWid;
				mVal.addEventListener(mx.events.FlexEvent.ENTER, onValueChanged);
				mVal.addEventListener( flash.events.FocusEvent.FOCUS_OUT, onLoseFocus);
				mVal.data = mValStr;
			}
		}
		
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			if (mVal != null) {
				mVal.enabled = value;
			}	
		}
		
		public function setValueAsString(inValue:String, inProperty:String):void {
			mValStr = inValue;
			if (mVal)
				mVal.data = inValue;
		}
		
		public function setMultiValue(inValues:Array, inProperty:String):void {
			trace(this.className + ": Multivalue not supported yet.");
			setValueAsString(inValues[0], inProperty);
		}
		
		private function onValueChanged(evt:mx.events.FlexEvent):void {
			mChangeNotify.ValueCommitted(mVal.text);
 		}

		private function onLoseFocus(change: flash.events.FocusEvent):void {
			mChangeNotify.ValueCommitted(mVal.text);
 		}
	}
}

		
