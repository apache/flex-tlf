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
package flashx.textLayout.property
{
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.tlf_internal;
		
	use namespace tlf_internal;
	
	[ExcludeClass]
	/** A property description with a Number or a Percent as its value. @private */
	public class PercentPropertyHandler extends PropertyHandler
	{
		private var _minValue:Number;
		private var _maxValue:Number;
		private var _limits:String;
		
		public function PercentPropertyHandler(minValue:String,maxValue:String,limits:String = Property.ALL_LIMITS)
		{
			_minValue = Property.toNumberIfPercent(minValue);
			_maxValue = Property.toNumberIfPercent(maxValue);
			_limits = limits;
		}

		public function get minValue():Number
		{ return _minValue; }
		public function get maxValue():Number
		{ return _maxValue; } 

		/** not yet enabled.  @private */
		public function checkLowerLimit():Boolean
		{ return _limits == Property.ALL_LIMITS || _limits == Property.LOWER_LIMIT; }
		
		/** not yet enabled.  @private */
		public function checkUpperLimit():Boolean
		{ return _limits == Property.ALL_LIMITS || _limits == Property.UPPER_LIMIT; }	
		
		// return true if this handler can "own" this property
		public override function owningHandlerCheck(newVal:*):*
		{			
			var newNumber:Number = Property.toNumberIfPercent(newVal);
			if (isNaN(newNumber))
				return undefined;
			if (checkLowerLimit() && newNumber < _minValue)
				return undefined;
			if (checkUpperLimit() && newNumber > _maxValue)
				return undefined;
			return newVal;
		}
	}
}
