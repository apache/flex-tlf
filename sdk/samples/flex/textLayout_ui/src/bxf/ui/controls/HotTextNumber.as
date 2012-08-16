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
package bxf.ui.controls
{
	import mx.formatters.NumberFormatter;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class HotTextNumber extends HotText
	{
		private var numberFormatter:NumberFormatter;
		private var _value:Number;
		private var _minVal:Number;
		private var _maxVal:Number;
		private var _increment:Number = 1;
		private var _decimalPlaces:int = 0;
		private var _enforcePrecision:Boolean = false;

		public function HotTextNumber()
		{
			super();
			this.tabChildren = true;
			this.tabEnabled = true;

			numberFormatter = new NumberFormatter;
			numberFormatter.precision = _decimalPlaces;
		}
			
		public function get value():Number {
			return _value;
		}	
		
		override protected function createChildren():void {
			super.createChildren();
			inPlaceEdit.restrict = "0-9.\\-";
			textField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			textField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		public function set value(inVal:Number):void {
			if (inVal > maxValue)
				inVal = maxValue;
			else if (inVal < minValue)
				inVal = minValue;

			if (inVal == _value && !valueConflict)
				return;
								
			_value = inVal;
			UpdateStringFromValue();
			if (_enforcePrecision) {
				var wasUsingThousandsSeparator:Boolean = numberFormatter.useThousandsSeparator;
				numberFormatter.useThousandsSeparator = false;	// bug 216009
				_value = Number(numberFormatter.format(_value));
				numberFormatter.useThousandsSeparator = wasUsingThousandsSeparator;
				UpdateStringFromValue();
			}
			invalidateSize();
		}
		
		public function get minValue():Number {
			return _minVal;
		}
		
		public function set minValue(inVal:Number):void {
			_minVal = inVal;
		}
		
		public function get maxValue():Number {
			return _maxVal;
		}
		
		public function set maxValue(inVal:Number):void {
			_maxVal = inVal;
		}

		public function set decimalPlaces(decimal_places:int):void {
			_decimalPlaces = decimal_places;
			numberFormatter.precision = _decimalPlaces;
			UpdateStringFromValue();
			if (_enforcePrecision) {
				var wasUsingThousandsSeparator:Boolean = numberFormatter.useThousandsSeparator;
				numberFormatter.useThousandsSeparator = false;	// bug 216009
				_value = Number(numberFormatter.format(_value));
				numberFormatter.useThousandsSeparator = wasUsingThousandsSeparator;
				UpdateStringFromValue();
			}
		}
		
		public function get decimalPlaces():int {
			return _decimalPlaces;
		}
		
		public function get increment():Number {
			return _increment;
		}
		
		public function set increment(inVal:Number):void {
			_increment = inVal;
		}
		
		public function get enforcePrecision():Boolean {
			return _enforcePrecision;
		}
		
		public function set enforcePrecision(enforce:Boolean):void {
			_enforcePrecision = enforce;
			
		}
		public function SetValueUnknown():void {
			
		}

		public function IncrementValue(inAmount:Number):void {
			var diff_value:Number = inAmount*_increment;
			
			value += diff_value;
		}
		
		override protected function UpdateStringFromValue():void {
			valueString = numberFormatter.format(_value);
		}
		
		override public function beginInPlaceEdit():void {
			super.beginInPlaceEdit();
			inPlaceEdit.text = valueConflict ? "" : _value.toString();
		}
		
		private function onKeyDown(evt:KeyboardEvent):void {
			if (!inPlaceEdit.visible) { // Make sure we aren't in edit mode first
				var inc:Number = _increment;
				if (evt.shiftKey) inc *= 10; // If you hold shift, change by 10
				switch (evt.keyCode) {
					case Keyboard.ENTER: beginInPlaceEdit(); break;
					case Keyboard.LEFT:
						value -= inc;
						dispatchEvent(new HotTextEvent(HotTextEvent.CHANGE, value));
						break;
					case Keyboard.UP:
						value += inc;
						dispatchEvent(new HotTextEvent(HotTextEvent.CHANGE, value));
						break;
					case Keyboard.RIGHT:
						value += inc;
						dispatchEvent(new HotTextEvent(HotTextEvent.CHANGE, value));
						break;
					case Keyboard.DOWN:
						value -= inc;
						dispatchEvent(new HotTextEvent(HotTextEvent.CHANGE, value));
						break;
				}
			}
		}

		private function onKeyUp(evt:KeyboardEvent):void {
			if (!inPlaceEdit.visible) { // Make sure we aren't in edit mode first
				dispatchEvent(new HotTextEvent(HotTextEvent.FINISH_CHANGE, value));
			}
		}
		
		override protected function SetValueFromText(inString:String):void {
			var n:Number = new Number(inString);
			if (isNaN(n))
				return;
				
			value = n;
			dispatchEvent(new HotTextEvent(HotTextEvent.FINISH_CHANGE, value)); 
		}
		
		override protected function ServeMouseCapture():IMouseCapture {
			return new HotTextMouseCapture(this, beginInPlaceEdit);
		}		
	}
}

import bxf.ui.controls.HotTextNumber;
import bxf.ui.controls.IMouseCapture;
import bxf.ui.controls.HotTextEvent;

import flash.events.MouseEvent;
import flash.geom.Point;

class HotTextMouseCapture implements IMouseCapture {
	private var hotTextNumber:HotTextNumber;
	private var initialValue:Number;
	private var initialDecimalPlaces:int;
	private var lastPoint:Point;
	private var diff_pt:Point;
	private var changed:Boolean;
	private var defAction:Function;
	
	public function HotTextMouseCapture(inHotTextNumber:HotTextNumber, inDefAction:Function = null) {
		hotTextNumber = inHotTextNumber;
		initialValue = hotTextNumber.value;
		defAction = inDefAction;
		initialDecimalPlaces = hotTextNumber.decimalPlaces;
		diff_pt = new Point;
		changed = false;
	}
	public function BeginTracking(inMouseEvent:MouseEvent, inCursorAdjust:Boolean):void {
		lastPoint = new Point;
		lastPoint.x = inMouseEvent.stageX;
		lastPoint.y = inMouseEvent.stageY;
		
	}
	
	public function ContinueTracking(inMouseEvent:MouseEvent):void {
		diff_pt.x = inMouseEvent.stageX - lastPoint.x;
		diff_pt.y = inMouseEvent.stageY - lastPoint.y;
		lastPoint.x = inMouseEvent.stageX;
		lastPoint.y = inMouseEvent.stageY;
		var increment:Number = diff_pt.x - diff_pt.y;
		if (0 != increment) {
			hotTextNumber.IncrementValue(increment);
			hotTextNumber.dispatchEvent(new HotTextEvent(HotTextEvent.CHANGE, hotTextNumber.value));
			changed = true;
		}
		
	}
	
	public function EndTracking(inMouseEvent:MouseEvent):void {
		if (!changed) {
			if (defAction != null)
				defAction();
		} else {
			hotTextNumber.dispatchEvent(new HotTextEvent(HotTextEvent.FINISH_CHANGE, hotTextNumber.value)); 	
		}
	}
}
