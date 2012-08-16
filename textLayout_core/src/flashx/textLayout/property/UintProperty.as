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
	/** A property description with an unsigned integer as its value.  Typically used for color. @private */
	public class UintProperty extends Property
	{
		public function UintProperty(nameValue:String, defaultValue:uint, inherited:Boolean, category:String)
		{
			super(nameValue, defaultValue, inherited, category);
		}
		
		/** @private */
		public override function setHelper(currVal:*,newObject:*):*
		{ 
			if (newObject === null)
				newObject = undefined;
			
			if (newObject === undefined || newObject == FormatValue.INHERIT)
				return newObject;
			
			var newVal:*;
			if (newObject is String)
			{
				var str:String = String(newObject);
				// Normally, we could just cast a string to a uint. However, the casting technique only works for
				// normal numbers and numbers preceded by "0x". We can encounter numbers of the form "#ffffffff"					
				if (str.substr(0, 1) == "#")
					str = "0x" + str.substr(1, str.length-1);
				newVal = (str.toLowerCase().substr(0, 2) == "0x") ? parseInt(str) : NaN;
			}
			else if (newObject is Number || newObject is int || newObject is uint)
				newVal = Number(newObject);
			else
				newVal = NaN;
			
			if (isNaN(newVal))
			{
				Property.errorHandler(this,str);
				return currVal;
			}
			
			if (newVal is Number)
			{
				if (newVal < 0 || newVal > 0xffffffff)
				{
					Property.errorHandler(this,newObject);
					return currVal;					
				}
			}
			
			return newVal;
		}
		
		/** @private */
		public override function toXMLString(val:Object):String
		{
			// Always export in # format, to be compatible with color spec.
			if (val == FormatValue.INHERIT)
				return String(val);
				
			var result:String = val.toString(16);
			if (result.length < 6)
				result = "000000".substr(0, 6 - result.length) + result;
			result = "#" + result;
			return result;
		}
		
		/** @private */
		public override function hash(val:Object, seed:uint):uint
		{ 
			if (val == FormatValue.INHERIT)
				return UintProperty.doHash(inheritHashValue, seed);
			return doHash(val as uint, seed);
		}
		
		/** @private */
		tlf_internal static function doHash(val:uint, seed:uint):uint
		{ 
			return ((seed << 5) ^ (seed >> 27)) ^ val;
		}
	}
}
