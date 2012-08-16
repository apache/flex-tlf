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
	/** A property description with a Number or a Percent or enumerated string as its value. @private */
	public class NumberOrPercentOrEnumProperty extends NumberOrPercentProperty
	{
		private var _range:Object;
		private var _defaultValue:Object;		// could be Number or Percent or EnumString value

		/** Value will be a % terminated string or a number or an enumeration */
		public function NumberOrPercentOrEnumProperty(nameValue:String, defaultValue:Object, inherited:Boolean, category:String, minValue:Number, maxValue:Number, minPercentValue:String, maxPercentValue:String, ... rest)
		{
			// rest is the list of possible values
			_range = EnumStringProperty.createRange(rest); 

			if (defaultValue is String && _range.hasOwnProperty(defaultValue))
				_defaultValue = defaultValue;
			// leave _defaultValue null if its not an enum

			super(nameValue, defaultValue, inherited, category, minValue, maxValue, minPercentValue, maxPercentValue);
		}
		
		/** @private */
		public override function get defaultValue():Object
		{ return (_defaultValue != null) ? _defaultValue : super.defaultValue; }
		
		/** Returns object whose properties are the legal enum values */
		public function get range():Object
		{
			return Property.shallowCopy(_range); 
		}
		
		/** @private */
		public override function setHelper(currVal:*,newObject:*):*
		{ 
			if (newObject === null)
				newObject = undefined;
			
			if (newObject === undefined)	// range has INHERIT
				return newObject;
				
			return _range.hasOwnProperty(newObject) ? newObject : super.setHelper(currVal,newObject);
		}
		
		/** @private */
		public override function hash(val:Object, seed:uint):uint
		{ 
			var hash:uint = _range[val];
			if (hash != 0)
				return UintProperty.doHash(hash, seed);
			return super.hash(val, seed);
		}		
	}
}
