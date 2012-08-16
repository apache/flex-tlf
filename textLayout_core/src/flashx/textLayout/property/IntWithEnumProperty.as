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
	/** A property description with an integer or enumerated string as its value. @private */
	public class IntWithEnumProperty extends IntProperty
	{
		private var _range:Object;
		private var _defaultValue:Object;		// could be Int or EnumString value
		
		public function IntWithEnumProperty(nameValue:String, defaultValue:Object, inherited:Boolean, category:String, minValue:int, maxValue:int, ... rest)
		{
			// rest is the list of possible values
			_range = EnumStringProperty.createRange(rest); 
				
			var defaultIsEnum:Boolean = defaultValue is String && _range.hasOwnProperty(defaultValue);
			var numberDefault:int = defaultIsEnum ? 0 : int(defaultValue);
			super(nameValue, numberDefault, inherited, category, minValue, maxValue);
			_defaultValue = defaultValue;
		}
		
		/** @private */
		public override function get defaultValue():Object
		{ return _defaultValue; }
		
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
			CONFIG::debug { assert(!(val is String) || _range.hasOwnProperty(val), "String " + val + " not among possible values for this IntWithEnumProperty"); }
			var hash:uint = _range[val];
			if (hash != 0)
				return UintProperty.doHash(hash, seed);
			return super.hash(val, seed);
		}
	}
}
