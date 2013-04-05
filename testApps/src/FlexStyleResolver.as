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
package
{
	import flash.utils.Dictionary;

	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.IFormatResolver;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;

	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.styles.IStyleManager2;

	/** This version hands back a style on demand from the dictinoary.
	 * Another way to do it would be to "redo" the cascade top down.
	 */
	public class FlexStyleResolver implements IFormatResolver
	{
		private var _formatCache:Dictionary;
		private var _styleManager:IStyleManager2;

		static public var classToNameDictionary:Object = { "SpanElement":"flashx.textLayout.elements.span", "ParagraphElement":"flashx.textLayout.elements.p", "TextFlow":"flashx.textLayout.elements.TextFlow", "DivElement":"flashx.textLayout.elements.div" }

		/** Create a flex style resolver.
		 * @param ignoreGlobal - don't use global settings.
		 */
		public function FlexStyleResolver(styleManager:IStyleManager2):void
		{
			// cache results
			_formatCache = new Dictionary(true);
			_styleManager = styleManager;
		}

		private function addStyleAttributes(attr:TextLayoutFormat, styleSelector:String):TextLayoutFormat
	 	{
	 		var foundStyle:CSSStyleDeclaration = _styleManager.getStyleDeclaration(styleSelector);
	 		if (foundStyle)
	 		{
	 			for each (var prop:Property in TextLayoutFormat.description)
	 			{
	 				var propStyle:Object = foundStyle.getStyle(prop.name);
	 				if (propStyle)
	 				{
	 					if (attr == null)
	 						attr = new TextLayoutFormat();
	 					attr[prop.name] = propStyle;
	 				}
	 			}
	 		}
	 		return attr;
	 	}

	 	public function resolveFormat(elem:Object):ITextLayoutFormat
	 	{
	 		// trace("flowStyleResolver");
	 		// lookup in the cache
	 		var attr:TextLayoutFormat = _formatCache[elem];
	 		if (attr !== null)
	 			return attr;

	 		// global on TextFlow only
	 		if (elem is FlowElement)
	 		{
		 		// maps ParagraphElement to p, SpanElement to span etc.
		 		var elemClassName:String = flash.utils.getQualifiedClassName(elem);
		 		elemClassName = elemClassName.substr(elemClassName.lastIndexOf(":")+1)
				var dictionaryName:String = FlexStyleResolver.classToNameDictionary[elemClassName] ;
				attr = addStyleAttributes(attr, dictionaryName ? dictionaryName : elemClassName);

				if (elem.styleName != null)
					attr = addStyleAttributes(attr, "." + elem.styleName);

				if (elem.id != null)
					attr = addStyleAttributes(attr, "#" + elem.id);

				_formatCache[elem] = attr;
			}
			// else if elem is ContainerController inherit via the container?
	 		return attr;
	 	}

 		public function resolveUserFormat(elem:Object,userStyle:String):*
 		{
 			var flowElem:FlowElement = elem as FlowElement;
 			var cssStyle:CSSStyleDeclaration;
 			var propStyle:*;

 			// support non-tlf styles
 			if (flowElem)
 			{
 				if (flowElem.id)
 				{
 					cssStyle = _styleManager.getStyleDeclaration("#"+flowElem.id);
 					if (cssStyle)
 					{
 						propStyle = cssStyle.getStyle(userStyle);
 						if (propStyle !== undefined)
 							return propStyle;
 					}
 				}
 				if (flowElem.styleName)
 				{
 					cssStyle = _styleManager.getStyleDeclaration("."+flowElem.styleName);
 					if (cssStyle)
 					{
 						propStyle = cssStyle.getStyle(userStyle);
 						if (propStyle !== undefined)
 							return propStyle;
 					}
 				}

 				var elemClassName:String = flash.utils.getQualifiedClassName(flowElem);
	 			elemClassName = elemClassName.substr(elemClassName.lastIndexOf(":")+1)
				var dictionaryName:String = classToNameDictionary[elemClassName];
 				cssStyle = _styleManager.getStyleDeclaration(dictionaryName == null ? elemClassName : dictionaryName);
 				if (cssStyle)
 				{
 					propStyle = cssStyle.getStyle(userStyle);
 					if (propStyle !== undefined)
 						return propStyle;
 				}
 			}
 			return undefined;
 		}

 		public function invalidateAll(tf:TextFlow):void
 		{
 			_formatCache = new Dictionary(true);	// clears the cache
 		}

 		// id and styleName don't need to descend now do they - this could conditionally descend on the change type.
 		public function invalidate(target:Object):void
 		{
 			delete _formatCache[target];
 			var blockElem:FlowGroupElement = target as FlowGroupElement;
 			if (blockElem)
 			{
	 			for (var idx:int = 0; idx < blockElem.numChildren; idx++)
	 				invalidate(blockElem.getChildAt(idx));
	 		}
 		}

	 	// these are sharable between TextFlows
		public function getResolverForNewFlow(oldFlow:TextFlow,newFlow:TextFlow):IFormatResolver
	 	{ return this; }
	}
}
