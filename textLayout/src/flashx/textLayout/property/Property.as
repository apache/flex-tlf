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
	import flashx.textLayout.formats.ListMarkerFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
		
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
		
		// shared propertyHandler instances
		/** @private */
		tlf_internal static const sharedStringHandler:StringPropertyHandler = new StringPropertyHandler();
		/** @private */
		tlf_internal static const sharedInheritEnumHandler:EnumPropertyHandler = new EnumPropertyHandler([ FormatValue.INHERIT ]);
		/** @private */
		tlf_internal static const sharedUndefinedHandler:UndefinedPropertyHandler = new UndefinedPropertyHandler();
		/** @private */
		tlf_internal static const sharedUintHandler:UintPropertyHandler = new UintPropertyHandler();
		/** @private */
		tlf_internal static const sharedBooleanHandler:BooleanPropertyHandler = new BooleanPropertyHandler();
		
		/** @private */
		tlf_internal static const sharedTextLayoutFormatHandler:FormatPropertyHandler = new FormatPropertyHandler();
		/** @private */
		tlf_internal static const sharedListMarkerFormatHandler:FormatPropertyHandler = new FormatPropertyHandler();
		
		public static function NewBooleanProperty(nameValue:String, defaultValue:Boolean, inherited:Boolean, categories:Vector.<String>):Property
		{			
			var rslt:Property = new Property(nameValue, defaultValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,sharedBooleanHandler,sharedInheritEnumHandler);
			return rslt;
		}
		
		public static function NewStringProperty(nameValue:String, defaultValue:String, inherited:Boolean, categories:Vector.<String>):Property
		{
			var rslt:Property = new Property(nameValue, defaultValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,sharedStringHandler);
			return rslt;			
		}
		public static function NewUintProperty(nameValue:String, defaultValue:uint, inherited:Boolean, categories:Vector.<String>):Property
		{
			var rslt:Property = new Property(nameValue, defaultValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,sharedUintHandler,sharedInheritEnumHandler);
			return rslt;
		}

		public static function NewEnumStringProperty(nameValue:String, defaultValue:String, inherited:Boolean, categories:Vector.<String>, ... rest):Property
		{
			var rslt:Property = new Property(nameValue, defaultValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,new EnumPropertyHandler(rest),sharedInheritEnumHandler);
			return rslt;
		}
		
		public static function NewIntOrEnumProperty(nameValue:String, defaultValue:Object, inherited:Boolean, categories:Vector.<String>, minValue:int, maxValue:int, ... rest):Property
		{		
			var rslt:Property = new Property(nameValue, defaultValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,new EnumPropertyHandler(rest),new IntPropertyHandler(minValue,maxValue),sharedInheritEnumHandler);
			return rslt;
		}
		
		public static function NewUintOrEnumProperty(nameValue:String, defaultValue:Object, inherited:Boolean, categories:Vector.<String>,  ... rest):Property
		{			
			var rslt:Property = new Property(nameValue, defaultValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,new EnumPropertyHandler(rest),sharedUintHandler,sharedInheritEnumHandler);
			return rslt;
		}

		public static function NewNumberProperty(nameValue:String, defaultValue:Number, inherited:Boolean, categories:Vector.<String>, minValue:Number, maxValue:Number):Property
		{
			var rslt:Property = new Property(nameValue, defaultValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,new NumberPropertyHandler(minValue,maxValue),sharedInheritEnumHandler);
			return rslt;
		}
		public static function 	NewNumberOrPercentOrEnumProperty(nameValue:String, defaultValue:Object, inherited:Boolean, categories:Vector.<String>, minValue:Number, maxValue:Number, minPercentValue:String, maxPercentValue:String, ... rest):Property
		{
			var rslt:Property = new Property(nameValue, defaultValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,new EnumPropertyHandler(rest),new PercentPropertyHandler(minPercentValue,maxPercentValue),new NumberPropertyHandler(minValue,maxValue),sharedInheritEnumHandler);
			return rslt;
		}
		public static function NewNumberOrPercentProperty(nameValue:String, defaultValue:Object, inherited:Boolean, categories:Vector.<String>, minValue:Number, maxValue:Number, minPercentValue:String, maxPercentValue:String):Property
		{			
			var rslt:Property = new Property(nameValue, defaultValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,new PercentPropertyHandler(minPercentValue,maxPercentValue),new NumberPropertyHandler(minValue,maxValue),sharedInheritEnumHandler);
			return rslt;
		}
		public static function NewNumberOrEnumProperty(nameValue:String, defaultValue:Object, inherited:Boolean, categories:Vector.<String>, minValue:Number, maxValue:Number, ... rest):Property
		{			
			var rslt:Property = new Property(nameValue, defaultValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,new EnumPropertyHandler(rest),new NumberPropertyHandler(minValue,maxValue),sharedInheritEnumHandler);
			return rslt;
		}
		public static function NewTabStopsProperty(nameValue:String, defaultValue:Array, inherited:Boolean, categories:Vector.<String>):Property
		{
			return new TabStopsProperty(nameValue,defaultValue,inherited,categories);
		}
		public static function NewSpacingLimitProperty(nameValue:String, defaultValue:Object, inherited:Boolean, categories:Vector.<String>, minPercentValue:String, maxPercentValue:String):Property
		{
			var rslt:Property = new Property(nameValue,defaultValue,inherited,categories);
			rslt.addHandlers(sharedUndefinedHandler, new SpacingLimitPropertyHandler(minPercentValue, maxPercentValue), sharedInheritEnumHandler);
			return rslt;
		}
		
		private static const undefinedValue:* = undefined;
		
		public static function NewTextLayoutFormatProperty(nameValue:String, defaultValue:Object, inherited:Boolean, categories:Vector.<String>):Property
		{
			// passing undefined as a value seems to confuse the compiler
			var rslt:Property = new Property(nameValue, undefinedValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,sharedTextLayoutFormatHandler,sharedInheritEnumHandler);
			return rslt;
		}
		public static function NewListMarkerFormatProperty(nameValue:String, defaultValue:Object, inherited:Boolean, categories:Vector.<String>):Property
		{
			// passing undefined as a value seems to confuse the compiler
			var rslt:Property = new Property(nameValue, undefinedValue, inherited, categories);
			rslt.addHandlers(sharedUndefinedHandler,sharedListMarkerFormatHandler,sharedInheritEnumHandler);
			return rslt;
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
		private var _default:*;
		private var _inherited:Boolean;
		private var _categories:Vector.<String>;
		private var _hasCustomExporterHandler:Boolean;
		private var _numberPropertyHandler:NumberPropertyHandler;
		
		protected var _handlers:Vector.<PropertyHandler>;
		
		/** Initializer.  Each property has a name and a default. */
		public function Property(nameValue:String,defaultValue:*,inherited:Boolean,categories:Vector.<String>)
		{ 
			_name = nameValue;
			_default = defaultValue;
			_inherited = inherited;
			_categories = categories;
			_hasCustomExporterHandler = false;
		}
		
		/** The name of the property */
		public function get name():String
		{ return _name; }
		
		/** The default value of this property */
		public function get defaultValue():*
		{ return _default; }
		
		/** Is this property inherited */
		public function get inherited():Object
		{ return _inherited; }
		
		/** First listed Category of this property. This is the legacy category from when Properties could only be in one category.  */
		public function get category():String
		{ return _categories[0]; }
		
		/** Return the list of categories */
		public function get categories():Vector.<String>
		{ return _categories; }
				
		public function addHandlers(... rest):void
		{
			_handlers = new Vector.<PropertyHandler>(rest.length,true);
			for (var idx:int = 0; idx < rest.length; idx++)
			{
				var handler:PropertyHandler = rest[idx]
				_handlers[idx] = handler;
				if (handler.customXMLStringHandler)
					_hasCustomExporterHandler = true;
				if (handler is NumberPropertyHandler)
					_numberPropertyHandler = handler as NumberPropertyHandler;
			}
		}
		
		public function findHandler(handlerClass:Class):PropertyHandler
		{
			for each (var prop:PropertyHandler in _handlers)
			{
				if (prop is handlerClass)
					return prop;
			}
			return null;
		}

		/** Helper function when setting the property */
		public function setHelper(currVal:*,newVal:*):*
		{
			for each (var handler:PropertyHandler in _handlers)
			{
				var checkRslt:* = handler.owningHandlerCheck(newVal);
				if (checkRslt !== undefined)
					return handler.setHelper(checkRslt);
			}
			
			Property.errorHandler(this,newVal);
			return currVal;	
		}
				
		/** Helper function when merging the property to compute actual attributes */
		public function concatInheritOnlyHelper(currVal:*,concatVal:*):*
		{ return (_inherited && currVal === undefined) || currVal == FormatValue.INHERIT ? concatVal : currVal; }

		public static function defaultConcatHelper(currVal:*,concatVal:*):*
		{ return currVal === undefined || currVal == FormatValue.INHERIT ? concatVal : currVal; }

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
			if (_hasCustomExporterHandler)
			{
				for each (var prop:PropertyHandler in _handlers)
				{
					if (prop.customXMLStringHandler && prop.owningHandlerCheck(val) !== undefined)
						return prop.toXMLString(val);
				}				
			}
			return val.toString();
		}
		
		public function get maxPercentValue():Number
		{
			var handler:PercentPropertyHandler = findHandler(PercentPropertyHandler) as PercentPropertyHandler;
			return handler ? handler.maxValue : NaN;
		}
		public function get minPercentValue():Number
		{
			var handler:PercentPropertyHandler = findHandler(PercentPropertyHandler) as PercentPropertyHandler;
			return handler ? handler.minValue : NaN;
		}
		public function get minValue():Number
		{
			var numberHandler:NumberPropertyHandler = findHandler(NumberPropertyHandler) as NumberPropertyHandler;
			if (numberHandler)
				return numberHandler.minValue;
			var intHandler:IntPropertyHandler = findHandler(IntPropertyHandler) as IntPropertyHandler;
			return intHandler ? intHandler.minValue : NaN;
		}
		public function get maxValue():Number
		{
			var numberHandler:NumberPropertyHandler = findHandler(NumberPropertyHandler) as NumberPropertyHandler;
			if (numberHandler)
				return numberHandler.maxValue;
			var intHandler:IntPropertyHandler = findHandler(IntPropertyHandler) as IntPropertyHandler;
			return intHandler ? intHandler.maxValue : NaN;
		}
		
		public function computeActualPropertyValue(propertyValue:Object,percentInput:Number):Number
		{				
			var percent:Number = toNumberIfPercent(propertyValue);
			if (isNaN(percent))
				return Number(propertyValue);
			
			// its a percent - calculate and clamp
			var rslt:Number =  percentInput * (percent / 100);
			return _numberPropertyHandler ? _numberPropertyHandler.clampToRange(rslt) : rslt;
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

		static public function extractInCategory(formatClass:Class,description:Object,props:Object,category:String,legacy:Boolean = true):Object
		{
			var rslt:Object = null;
			for each (var prop:Property in description)
			{
				if (props[prop.name] == null)
					continue;
				
				if (legacy)
				{
					if (prop.category != category)
						continue;
				}
				else if (prop.categories.indexOf(category) == -1)
					continue;
				
				if (rslt == null)
					rslt = new formatClass();
				rslt[prop.name] = props[prop.name];
			}
			return rslt;
		}
		
		/** @private Copy an object */
		static public function shallowCopy(src:Object):Object
		{
			// make a shallow copy
			var rslt:Object = new Object()
			for (var val:Object in src)
				rslt[val] = src[val]; 
			return rslt;
		}
		
		/** @private Copy properties from src to result if a property of the same name exists in filter */
		static public function shallowCopyInFilter(src:Object,filter:Object):Object
		{
			// make a shallow copy
			var rslt:Object = new Object()
			for (var val:Object in src)
			{
				if (filter.hasOwnProperty(val))
					rslt[val] = src[val];
			}
			return rslt;
		}
		
		/** @private Copy properties from src to result if a property of the same name exists in filter */
		static public function shallowCopyNotInFilter(src:Object,filter:Object):Object
		{
			// make a shallow copy
			var rslt:Object = new Object()
			for (var val:Object in src)
			{
				if (!filter.hasOwnProperty(val))
					rslt[val] = src[val];
			}
			return rslt;
		}
		
		static private function compareStylesLoop(o1:Object,o2:Object,description:Object):Boolean
		{
			for (var val:String in o1)
			{
				var o1val:Object = o1[val];
				var o2val:Object = o2[val];
				if (o1val != o2val)
				{
					if (!(o1val is Array) || !(o2val is Array) || o1val.length != o2val.length || !description)
						return false;	// different
					var prop:ArrayProperty = description[val];
					if (!prop || !equalAllHelper(prop.memberType.tlf_internal::description,o1val,o2val))
						return false;
				}
			}
			return true;
		}
		/** @private */
		static tlf_internal const nullStyleObject:Object = new Object();
		/** @private */
		static public function equalStyles(o1:Object,o2:Object,description:Object):Boolean
		{
			if (o1 == null)
				o1 = nullStyleObject;
			if (o2 == null)
				o2 = nullStyleObject;
			// Use of prototype chains and bug https://bugzilla.mozilla.org/show_bug.cgi?id=447673 requires this two way compare
			return compareStylesLoop(o1,o2,description) && compareStylesLoop(o2,o1,description);
		}
		
		/** @private */
		static public function toNumberIfPercent(o:Object):Number
		{
			if (!(o is String))
				return NaN;
			var s:String = String(o);
			var len:int = s.length;
			
			return len != 0 && s.charAt(len-1) == "%" ? parseFloat(s) : NaN;
		}
		
		static private var prototypeFactory:Function = function():void
		{ }
		
		/** @private Create an object with specified prototype parent */
		static public function createObjectWithPrototype(parent:Object):Object
		{
			prototypeFactory.prototype = parent;
			return new prototypeFactory();
		}
	}
}
