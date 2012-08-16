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
	public class NumberProperty extends Property
	{
		private var _minValue:Number;
		private var _maxValue:Number;
		
		public function NumberProperty(nameValue:String, defaultValue:Number, inherited:Boolean, category:String, minValue:Number, maxValue:Number)
		{
			super(nameValue, defaultValue, inherited, category);
			_minValue = minValue;
			_maxValue = maxValue;
		}
		
		public function get minValue():Number
		{ return _minValue; }
		public function get maxValue():Number
		{ return _maxValue; } 
		
		/** @private */
		public override function setHelper(currVal:*,newObject:*):*
		{ 
			if (newObject === null)
				newObject = undefined;
			
			if (newObject === undefined || newObject == FormatValue.INHERIT)
				return newObject;

			var newVal:Number = newObject is String ? parseFloat(newObject) : Number(newObject);
			if (isNaN(newVal))
			{
				Property.errorHandler(this,newObject);
				return currVal;
			}
			if (checkLowerLimit() && newVal < _minValue)
			{
				Property.errorHandler(this,newObject);
				return currVal;
			}
			if (checkUpperLimit() && newVal > _maxValue)
			{
				Property.errorHandler(this,newObject);
				return currVal;
			}
			return newVal;
		}
		
		/** @private */
		public override function hash(val:Object, seed:uint):uint
		{ 
			if (val == FormatValue.INHERIT)
				return UintProperty.doHash(inheritHashValue, seed);
			return NumberProperty.doHash(val as Number, seed);
		}
		
		/** @private */
		tlf_internal static function doHash(num:Number, seed:uint):uint
		{ 
			//return stringHash(num.toString(), seed);
			
			var trunc:uint = uint(num);
			var hash:uint = UintProperty.doHash(trunc, seed);
			if (trunc != num)
			{
				var fraction:uint = (uint)((num - trunc) * 10000000000);
				hash =  UintProperty.doHash(fraction, hash);
			}
			
			return hash; 
		}
	}
}
