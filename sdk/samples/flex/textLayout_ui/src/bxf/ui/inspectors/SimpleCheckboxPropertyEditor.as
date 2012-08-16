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
	
	import mx.containers.Canvas;
	import mx.controls.CheckBox;
	
	/* The simple checkbox property editor keeps the label to the right of the
		control and doesn't partipate in any dynamic label sizing */
	public class SimpleCheckboxPropertyEditor extends Canvas implements IPropertyEditor
	{
		private var mChangeNotify:ValueChangeNotifier;

		//private var mLabel:mx.controls.Text;
		private var mCheckbox:CheckBox;
					
		public function SimpleCheckboxPropertyEditor(inLabel:String, inPropName:String)
		{
			super();

			mChangeNotify = new ValueChangeNotifier(inPropName, this);

			mCheckbox = new CheckBox();
			mCheckbox.label = inLabel;
			addChild(mCheckbox);
   
			mCheckbox.addEventListener(MouseEvent.CLICK, onMouseClick);			
		}
		

		public function onMouseClick(inEvt:MouseEvent):void {
			mChangeNotify.ValueCommitted(mCheckbox.selected ? "true" : "false");
		}
		
		public function setValueAsString(inValue:String, inProperty:String):void {
			mCheckbox.selected = Boolean(inValue == "true");
		}
				
		public function setMultiValue(inValues:Array, inProperty:String):void {
			trace(this.className + ": Multivalue not supported yet.");
			setValueAsString(inValues[0], inProperty);
		}
	}
}

		
