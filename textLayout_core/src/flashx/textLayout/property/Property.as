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
	import flashx.textLayout.elements.GlobalSettings;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.tlf_internal;
		
	[ExcludeClass]
	/** Base class of property metadata.  Each property in the various TextLayout attributes structures has a metadata singletion Property class instance.  The instance
	 * can be used to process the property to and from xml, find out range information and help with the attribute cascade.  The Property class also contains static functions
	 * for processing all the properties collected in a TextLayout Format object. @private  */
	public class Property
	{
		public static var errorHandler:Function = defaultErrorHandler;
		public static function defaultErrorHandler(p:Property,value:Object):void
		{
			throw(new RangeError(createErrorString(p,value)));
		}
		public static function createErrorString(p:Property,value:Object):String
		{
			return GlobalSettings.resourceStringFunction("badPropertyValue",[ p.name, value.toString() ])
		}
		
		/** not yet enabled.  @private */
		public static const NO_LIMITS:String ="noLimits";
		/** not yet enabled.  @private */
		public static const LOWER_LIMIT:String ="lowerLimit";
		/** not yet enabled.  @private */
		public static const UPPER_LIMIT:String = "upperLimit";
		/** not yet enabled.  @private */
		public static const ALL_LIMITS:String = "allLimits";
		
		// storing name here is redundant but is more efficient 
		private var _name:String;
		private var _default:Object;
		private var _inherited:Boolean;
		private var _limits:String;
		private var _category:String;
		
		/** @private */
		tlf_internal static const inheritHashValue:uint  = 314159;
		
		/** Initializer.  Each property has a name and a default. */
		public function Property(nameValue:String,defaultValue:Object,inherited:Boolean,category:String)
		{
			_name = nameValue;
			_default = defaultValue;
			_limits = ALL_LIMITS;
			_inherited = inherited;
			_category = category;
		}
		
		/** not yet enabled.  @private */
		protected function checkLowerLimit():Boolean
		{ return _limits == ALL_LIMITS || _limits == LOWER_LIMIT; }
		
		/** not yet enabled.  @private */
		protected function checkUpperLimit():Boolean
		{ return _limits == ALL_LIMITS || _limits == LOWER_LIMIT; }
		
		/** The name of the property */
		public function get name():String
		{ return _name; }
		
		/** The default value of this property */
		public function get defaultValue():Object
		{ return _default; }
		
		/** Is this property inherited */
		public function get inherited():Object
		{ return _inherited; }
		
		/** Category of this property. */
		public function get category():String
		{ return _category; }
			
		/** Helper function when setting the property */
		public function setHelper(currVal:*,newVal:*):*
		{
			if (newVal === null)
				newVal = undefined;

			return newVal; 
		}
		
		/** Helper function when merging the property to compute actual attributes */
		public function concatInheritOnlyHelper(currVal:*,concatVal:*):*
		{
			return (_inherited && currVal === undefined) || currVal == FormatValue.INHERIT ? concatVal : currVal;
		}
		/** Helper function when merging the property to compute actual attributes */
		public function concatHelper(currVal:*,concatVal:*):*
		{
			if (_inherited)
				return currVal === undefined || currVal == FormatValue.INHERIT ? concatVal : currVal;
			if (currVal === undefined)
				return defaultValue;
			return currVal == FormatValue.INHERIT ? concatVal : currVal;
		}
		
		/** Helper function when comparing the property */
		public function equalHelper(v1:*,v2:*):Boolean
		{ return v1 == v2; }
		
		/** Convert the value of this property to a string appropriate for XML export */
		public function toXMLString(val:Object):String
		{
			return val.toString();
		}
		
		/** Get the hash of the property value
		 * @param val the property value
		 * @param seed seed value for the hash algorithm 
		 * @return the hash of the property value
		 */
		public function hash(val:Object, seed:uint):uint
		{ 
			return 0;
		}
		
		// /////////////////////////////////////////////
		// Following static functions are used by Format classes to 
		// perform functions that iterate over all the attributes.
		// They are driven by the attributes metadata object that contains
		// definitions for all the properties.
		// /////////////////////////////////////////////
			
		/** Helper function to initialize all property values from defaults. */
		static public function defaultsAllHelper(description:Object,current:Object):void
		{
			for each (var prop:Property in description)
				current[prop.name] = prop.defaultValue;
		}
		
		/** Helper function to compare two sets of properties. */
		static public function equalAllHelper(description:Object,p1:Object,p2:Object):Boolean
		{
			if (p1 == p2)
				return true;
			// these could be "equal" if all attributes of p1 or p2 are null
			if (p1 == null || p2 == null)
				return false;
			for each (var prop:Property in description)
			{
				var name:String = prop.name;
				if (!(prop.equalHelper(p1[name],p2[name])))
					return false;
			}
			return true;
		}

		static public function extractInCategory(formatClass:Class,description:Object,props:Object,category:String):Object
		{
			var rslt:Object = null;
			for each (var prop:Property in description)
			{
				if (prop.category == category && props[prop.name] != null)
				{
					if (rslt == null)
						rslt = new formatClass();
					rslt[prop.name] = props[prop.name];
				}
			}
			return rslt;
		}
		/** @private */
		static public function shallowCopy(src:Object):Object
		{
			// make a shallow copy
			var rslt:Object = new Object()
			for (var val:Object in src)
				rslt[val] = src[val]; 
			return rslt;
		}
		
		static private const nullStyleObject:Object = new Object();
		/** @private */
		static public function equalStyleObjects(o1:Object,o2:Object):Boolean
		{
			if (o1 == null)
				o1 = nullStyleObject;
			if (o2 == null)
				o2 = nullStyleObject;
			var o1len:int = 0;
			// compare property values and count o1len
			for (var val:Object in o1)
			{
				CONFIG::debug { assert(!(o1[val] is Array) && !(o2[val] is Array),"Arrays as user styles not supported"); }
				if (o1[val] != o2[val])
					return false;	// different
				o1len++;
			}
			var o2len:int = 0;
			for (val in o2)
				o2len++;
			// matching keys from o1 to o2.  return equal if they both have the same length
			return o1len == o2len;
		}
		
		/** @private */
		static public function equalCoreStyles(o1:Object,o2:Object,description:Object):Boolean
		{
			if (o1 == null)
				o1 = nullStyleObject;
			if (o2 == null)
				o2 = nullStyleObject;
			var o1len:int = 0;
			// compare property values and count o1len
			for (var val:String in o1)
			{
				var o1val:Object = o1[val];
				var o2val:Object = o2[val];
				if (o1val != o2val)
				{
					if (!(o1val is Array) || !(o2val is Array) || o1val.length != o2val.length)
						return false;	// different
					var valClass:Class = description[val].memberType;
					if (!Property.equalAllHelper(valClass.tlf_internal::description,o1val,o2val))
						return false;
				}
				o1len++;
			}
			var o2len:int = 0;
			for (val in o2)
				o2len++;
			// matching keys from o1 to o2.  return equal if they both have the same length
			return o1len == o2len;
		}
	}
}
