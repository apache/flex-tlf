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
	/** An property description with an enumerated string as its value. @private */
	public class EnumStringProperty extends Property
	{
		private var _range:Object;
		
		public function EnumStringProperty(nameValue:String, defaultValue:String, inherited:Boolean, category:String, ... rest)
		{ 
			super(nameValue, defaultValue, inherited, category);
			_range = createRange(rest); 
		}
		
		/** @private */
		tlf_internal static var nextEnumHashValue:uint = 217287;
		
		/** @private */
		tlf_internal static function createRange(rest:Array):Object
		{
			var range:Object = new Object();
			// rest is the list of possible values
			for (var i:int = 0; i < rest.length; i++)
				range[rest[i]] = nextEnumHashValue++;
			range[FormatValue.INHERIT] = nextEnumHashValue++;	
			return range;
		}
		
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
			
			if (newObject === undefined)
				return newObject;
				
			if (_range.hasOwnProperty(newObject))
				return newObject;
			Property.errorHandler(this,newObject);
			return currVal;
		}
		
		/** @private */
		public override function hash(val:Object, seed:uint):uint
		{ 
			CONFIG::debug { assert(_range.hasOwnProperty(val), "String " + val + " not among possible values for this EnumStringProperty"); }
			return UintProperty.doHash(_range[val], seed);
		}
		
	}
}
