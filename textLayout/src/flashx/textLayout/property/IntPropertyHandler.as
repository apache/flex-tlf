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
	/** A property description with a Number as its value. @private */
	public class IntPropertyHandler extends PropertyHandler
	{
		private var _minValue:int;
		private var _maxValue:int;
		private var _limits:String;
		
		public function IntPropertyHandler(minValue:int,maxValue:int,limits:String = Property.ALL_LIMITS)
		{
			_minValue = minValue;
			_maxValue = maxValue;
			_limits = limits;
		}
		
		public function get minValue():int
		{ return _minValue; }
		public function get maxValue():int
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
			var newNumber:Number = newVal is String ? parseInt(newVal) : int(newVal);
			if (isNaN(newNumber))
				return undefined;

			var newInt:int = int(newNumber)
			if (checkLowerLimit() && newInt < _minValue)
				return undefined;
			if (checkUpperLimit() && newInt > _maxValue)
				return undefined;
			return newInt;	
		}
				
	}
}
