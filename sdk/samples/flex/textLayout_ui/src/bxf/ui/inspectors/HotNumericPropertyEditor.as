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
	import bxf.ui.controls.HotTextEvent;
	import bxf.ui.controls.HotTextNumber;
	
	public class HotNumericPropertyEditor extends PropertyEditorBase implements IPropertyEditor
	{
		private var mChangeNotify:ValueChangeNotifier;
		private var mPropName:String;
		private var mVal:HotTextNumber;
		private var mMin:Number, mMax:Number;
		private var mDecimals:uint;
		private var mIncrement:Number;
		private var mValue:Number;
		private var mHotTextSuffix:String;
		private var mEnforcePrecision:Boolean;
		private var mMaxChars:int;	// for in place editing; bug 212147
		private var mConvertToPercent:Boolean;
		
		public function HotNumericPropertyEditor(inLabel:String, inPropName:String,
												inHotTextSuffix:String = null,
												inMin:Number = Number.NaN, inMax:Number = Number.NaN,
												inConvertToPercent:Boolean = false,
												inDecimals:uint = 0, inIncrement:Number = 1.0,
												inEnforcePrecision:Boolean = false, inMaxChars:int = 0)
		{
			super(inLabel);
			mMin = inMin;
			mMax = inMax;
			mDecimals = inDecimals;
			mIncrement = inIncrement;
			mEnforcePrecision = inEnforcePrecision;
			mMaxChars = inMaxChars;
			mHotTextSuffix = inHotTextSuffix;
			mConvertToPercent = inConvertToPercent;
			mPropName = inPropName;
			mChangeNotify = new ValueChangeNotifier(inPropName, this);
			this.tabChildren = true;
		}
			

		override protected function createChildren():void
		{
	        super.createChildren();
	
			if (null == mVal) {
				mVal = new HotTextNumber();
				mVal.width = 58;
				addChild(mVal);
				mVal.minValue = mMin;
				mVal.maxValue = mMax;
				mVal.decimalPlaces = mDecimals;
				mVal.increment = mIncrement;
				mVal.enforcePrecision = mEnforcePrecision;
				mVal.maxChars = mMaxChars;
				//mVal.hotTextColor = 0x909090;
				mVal.displayUnderline = true;
					
				if (mHotTextSuffix)
					mVal.suffix=mHotTextSuffix;
				//mVal.restrict = "0-9\\-";
				
				// add event listener for each function
				mVal.addEventListener(HotTextEvent.CHANGE, onNumberChanged);
				mVal.addEventListener(HotTextEvent.FINISH_CHANGE, onNumberChangeFinished);			
			
				mVal.value = mValue;
			}
		}
		
		
		public function setValueAsString(inValue:String, inProperty:String):void {
			if (mConvertToPercent == true) {
				mValue = Math.ceil(Number(inValue)*100);
			}
			else mValue = Number(inValue);
			if (mVal)
				mVal.value = mValue;
			
		}
		
		public function setMultiValue(inValues:Array, inProperty:String):void {
			setValueAsString(inValues[0], inProperty);
			mVal.setValueConflict();
		}

		// allows live update, before committing with onNumberChangeFinished
		public function onNumberChanged(inEvt:HotTextEvent):void {
			if (mConvertToPercent == true) {
				mChangeNotify.ValueEdited(mVal.value/100);
			}
			else mChangeNotify.ValueEdited(mVal.value);
		}

		public function onNumberChangeFinished(inEvt:HotTextEvent):void {
			if (mConvertToPercent == true) {
				mChangeNotify.ValueCommitted(mVal.value/100);
			}
			else mChangeNotify.ValueCommitted(mVal.value);
		}
	}
}

		
