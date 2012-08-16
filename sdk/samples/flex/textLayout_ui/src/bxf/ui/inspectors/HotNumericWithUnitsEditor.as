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
	
	import mx.utils.StringUtil;
	
	import bxf.ui.controls.BxPopupMenu;
	import bxf.ui.controls.HUDComboPopupControl;
	import bxf.ui.controls.HotTextEvent;
	import bxf.ui.controls.HotTextNumber;
	import bxf.ui.inspectors.PropertyEditorBase;
	import bxf.ui.inspectors.IPropertyEditor;
	
	/*
		spec XML elements and attributes
		numericunit
			displayname
			min
			max
			default
			decimals
			enforceprecision
			increment
			converttopercent
			maxchars
		defaultunit - value is displayname of a numericunit
		enumval
			displayname
			value
	*/
	
	public class HotNumericWithUnitsEditor extends PropertyEditorBase implements IPropertyEditor
	{
		private var mChangeNotify:ValueChangeNotifier;
		private var mPropName:String;
		private var mValue:Object = null;
		private var mVal:HotTextNumber;
		private var mComboBox:HUDComboPopupControl;
		private var mSpec:XML;
		private var mComboValues:Array;
		private var mUnits:Array;
		private var mEnums:Array;
		private var mDefaultUnit:String;
		private var mCurrentUnit:String;
		private var mComboSpecs:Object;
		private var mConvertToPercent:Boolean;
		private var mUnitComboStyleName:String;
		
		public function HotNumericWithUnitsEditor(inLabel:String, inPropName:String, inSpec:XML)
		{
			super(inLabel);
			mPropName = inPropName;
			mSpec = inSpec.copy();

			mUnitComboStyleName = "unitComboValue";
			
			mComboValues = [];
			mUnits = [];
			mEnums = [];
			mComboSpecs = new Object;
			var displayName:String;
			for each (var unit:XML in mSpec.numericunit)
			{
				displayName = unit.@displayname;
				mComboValues.push(displayName);
				mUnits.push(displayName);
				mComboSpecs[displayName] = unit.copy();
			}
			if (mComboValues.length == 0)
				throw new Error("HotNumericWithUnitsEditor: at least one numericunit required in spec.");
			if (mSpec.enumval[0] != null)
				mComboValues.push({type: "separator"});
			for each (var enum:XML in mSpec.enumval)
			{
				displayName = enum.@displayname;
				mComboValues.push(displayName);
				mEnums.push(displayName);
				mComboSpecs[displayName] = enum.copy();
			}

			mDefaultUnit = mSpec.defaultunit[0].toString();

			mChangeNotify = new ValueChangeNotifier(inPropName, this);
			this.tabChildren = true;
		}
			

		override protected function createChildren():void
		{
	        super.createChildren();
	
			if (null == mVal) {
				mVal = new HotTextNumber();
				mVal.width = Math.max(this.GetNumberAttribute(mSpec, "width", 40), 40);
				addChild(mVal);
				mVal.displayUnderline = true;
					
				
				// add event listener for each function
				mVal.addEventListener(HotTextEvent.CHANGE, onNumberChanged);
				mVal.addEventListener(HotTextEvent.FINISH_CHANGE, onNumberChangeFinished);			
				
				mComboBox = new HUDComboPopupControl(mComboValues, mUnitComboStyleName);
				mComboBox.setStyle("paddingTop", 2);
				addChild(mComboBox);
				mComboBox.addEventListener(BxPopupMenu.SELECTION_CHANGED, onComboChanged);

				DisplayValue();
			}
		}
		
		
		private function SetUnit(inUnit:String):void
		{
			if (mVal && mComboBox)
			{
				if (mUnits.indexOf(inUnit) == -1)
					throw new Error("HotNumericWithUnitsEditor: unknown unit.");
				mComboBox.value = inUnit;
				mCurrentUnit = inUnit;
				var unitSpec:XML = mComboSpecs[inUnit];
				mVal.minValue = GetNumberAttribute(unitSpec, "min");
				mVal.maxValue = GetNumberAttribute(unitSpec, "max");
				mVal.decimalPlaces = GetUintAttribute(unitSpec, "decimals", 0);
				mVal.increment = GetNumberAttribute(unitSpec, "increment", 1);
				mVal.enforcePrecision = GetBooleanAttribute(unitSpec, "enforceprecision", false);
				mVal.maxChars = GetUintAttribute(unitSpec, "maxchars");
				mConvertToPercent = GetBooleanAttribute(unitSpec, "converttopercent", false);
				mVal.visible = true;
				mVal.width = Math.max(this.GetNumberAttribute(mSpec, "width", 40), 40);
			}
		}
		
		
		private function GetNumberAttribute(inXML:XML, inAttr:String, inDefault:Number = Number.NaN):Number
		{
			var attrStr:String = inXML.attribute(inAttr);
			return (attrStr != null && attrStr.length > 0) ? Number(attrStr) : inDefault;
		}
		
		private function GetUintAttribute(inXML:XML, inAttr:String, inDefault:uint = 0):uint
		{
			var attrStr:String = inXML.attribute(inAttr);
			return (attrStr != null && attrStr.length > 0) ? uint(attrStr) : inDefault;
		}
		
		private function GetBooleanAttribute(inXML:XML, inAttr:String, inDefault:Boolean):Boolean
		{
			var attrStr:String = inXML.attribute(inAttr);
			if (attrStr != null && attrStr.length > 0)
			{
				attrStr = attrStr.toLowerCase();
				if (attrStr == "true" || attrStr == "t" || attrStr == "yes" || attrStr == "1")
					return true;
				else if (attrStr == "false" || attrStr == "f" || attrStr == "no" || attrStr == "0")
					return false;
				else
					return inDefault;
			}
			else
				return inDefault;
		}
		
		
		public function setValueAsString(value:String, inPropType:String):void
		{
			mValue = value;
			DisplayValue();
		}
		
		public function setMultiValue(values:Array, inPropType:String):void
		{
			mValue = values;
			DisplayValue();
		}

		private function DisplayValue():void
		{
			if (mValue && mVal)
			{
				var val:Object;
				if (mValue is String)
				{
					if (mEnums.length)
					{
						for each(var spec:XML in mComboSpecs)
						{
							if (spec.name() == "enumval")
							{
								if (spec.@value == mValue)
								{
									mComboBox.value = String(spec.@displayname);
									mVal.value = 0;
									mVal.visible = false;
									mVal.width = 0;
									return;
								}
							}
						}
					}
					val = ParseValueString(mValue as String, mDefaultUnit);
					if (val)
					{
						mVal.value = val.value;
						SetUnit(val.unit);
					}
				}
				else
				{
					var unit:String = "";
					for each (var valStr:String in mValue)
					{
						val = ParseValueString(valStr, mDefaultUnit);
						if (val)
						{
							if (unit == "")
								unit = val.unit;
							else if (unit != val.unit)
							{
								unit = null;
								break;
							}
						}
					}
					if (unit != null)
						SetUnit(unit);
					else
						SetUnit(mDefaultUnit);
					mVal.setValueConflict();
				}
			}
		}
		
		private function ParseValueString(inValStr:String, inDefaultUnit:String):Object
		{
			// returns Object with two keys, value and unit, or null if invalid
			var valStr:String = StringUtil.trim(inValStr) + " ";
			var numericChars:String = "0123456789-.";
			var result:Object = null;
			for (var i:int = 0; i < valStr.length; ++i)
			{
				if (numericChars.search(valStr.substr(i, 1)) == -1)
				{
					if (i > 0)
					{
						var val:Number = Number(valStr.substr(0, i));
						if (!isNaN(val))
						{
							valStr = StringUtil.trim(valStr.substr(i));
							if (valStr.length == 0)
							{
								result = new Object;
								result.value = val;
								result.unit = inDefaultUnit;
							}
							else if (mUnits.indexOf(valStr) != -1)
							{
								result = new Object;
								result.value = val;
								result.unit = valStr;
							}
						}
					}
					break;
				}
			}
			return result;
		}

		// allows live update, before committing with onNumberChangeFinished
		public function onNumberChanged(inEvt:HotTextEvent):void
		{
			mChangeNotify.ValueEdited(GetValueString());
		}

		private function onComboChanged(inEvt:Event):void
		{
			var value:String = mComboBox.value;
			var spec:XML = mComboSpecs[value];
			if (spec.name() == "numericunit")
			{
				SetUnit(value);
				var def:Number = GetNumberAttribute(mComboSpecs[value], "default");
				if (!isNaN(def))
				{
					mVal.value = def;
					mChangeNotify.ValueCommitted(GetValueString());
				} 
				mVal.beginInPlaceEdit();
			}
			else if (spec.name() == "enumval")
			{
				mChangeNotify.ValueCommitted(String(spec.@value));
			}
		}

		public function onNumberChangeFinished(inEvt:HotTextEvent):void
		{
			mChangeNotify.ValueCommitted(GetValueString());
		}
		
		private function GetValueString():String
		{
			var value:String;
			if (mConvertToPercent == true)
				value = (mVal.value/100).toString();
			else 
				value = mVal.value.toString();
			if (mCurrentUnit != mDefaultUnit)
				value = value + mCurrentUnit;
			return value;
		}
	}
}
