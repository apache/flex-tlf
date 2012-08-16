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
	import flashx.textLayout.tlf_internal;
		
	use namespace tlf_internal;
	
	[ExcludeClass]
	/** A property description with a String as its value @private */
	public class StringProperty extends Property
	{
		public function StringProperty(nameValue:String, defaultValue:String, inherited:Boolean, category:String)
		{
			super(nameValue, defaultValue, inherited, category);
		}
		
		/** @private */
		public override function setHelper(currVal:*,newObject:*):*
		{ 
			if (newObject === null)
				newObject = undefined;
			
			if (newObject === undefined || newObject is String)
				return newObject;
			
			Property.errorHandler(this,newObject);
			return currVal;	
		}	
		
		/** @private */
		public override function hash(val:Object, seed:uint):uint
		{ 
			return doHash(val as String, seed);
		}
		
		/** @private */
		tlf_internal static function doHash(val:String, seed:uint):uint
		{
			if (val == null)
				return seed;
				
			var len:uint = val.length;
			var hash:uint = seed;

			// Incrementally hash integers composed of pairs of character codes in the string
			for (var ix:uint=0; ix<len/2; ix++)
			{
				hash = UintProperty.doHash((val.charCodeAt(2*ix) << 16) | val.charCodeAt(2*ix+1), hash);
			}
			
			// Handle last character code in an odd-length string
			if (len % 2 != 0)
				hash = UintProperty.doHash (val.charCodeAt(len-1), hash);
			
			return hash;
		}
	}
}
