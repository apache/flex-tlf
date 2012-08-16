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
package flashx.textLayout.conversion 
{
	import __AS3__.vec.Vector;
	
	import flash.display.Shape;
	import flash.text.engine.TextRotation;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.BreakElement;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.GlobalSettings;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TabElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormatValueHolder;
	import flashx.textLayout.property.EnumStringProperty;
	import flashx.textLayout.property.NumberProperty;
	import flashx.textLayout.property.StringProperty;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	[ExcludeClass]
	/** 
	 * @private
	 * TextLayoutImporter converts from XML to TextLayout data structures and back.
	 */ 	
	public class TextLayoutImporter extends BaseTextLayoutImporter 
	{
		private static var _defaultConfiguration:ImportExportConfiguration;
		
		/** Default ImportExportConfiguration to use when none specified 
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0 
		*/
		public static function get defaultConfiguration():ImportExportConfiguration
		{
			// The first call will force the import/export to include the standard components
			if (!_defaultConfiguration)
			{
				_defaultConfiguration = new ImportExportConfiguration();
				// shared by TextLayout and FXG markup
	 			_defaultConfiguration.addIEInfo("TextFlow", TextFlow,        BaseTextLayoutImporter.parseTextFlow, BaseTextLayoutExporter.exportTextFlow, true);
				_defaultConfiguration.addIEInfo("br", BreakElement,          BaseTextLayoutImporter.parseBreak, BaseTextLayoutExporter.exportFlowElement, false);
				_defaultConfiguration.addIEInfo("p", ParagraphElement,       BaseTextLayoutImporter.parsePara, BaseTextLayoutExporter.exportParagraphFormattedElement, true);
				_defaultConfiguration.addIEInfo("span", SpanElement,         BaseTextLayoutImporter.parseSpan, BaseTextLayoutExporter.exportSpan, false);
				_defaultConfiguration.addIEInfo("tab", TabElement,           BaseTextLayoutImporter.parseTab, BaseTextLayoutExporter.exportFlowElement, false);
				// shared by TextLayoutMarkup only
				_defaultConfiguration.addIEInfo("tcy", TCYElement,           TextLayoutImporter.parseTCY, TextLayoutExporter.exportTCY, false);
				_defaultConfiguration.addIEInfo("a", LinkElement,            TextLayoutImporter.parseLink, TextLayoutExporter.exportLink, false);
	 			_defaultConfiguration.addIEInfo("div", DivElement,           TextLayoutImporter.parseDivElement, TextLayoutExporter.exportDiv, true);
				_defaultConfiguration.addIEInfo("img", InlineGraphicElement, TextLayoutImporter.parseInlineGraphic, TextLayoutExporter.exportImage, false);							 
				// customized link formats
				_defaultConfiguration.addIEInfo(LinkElement.LINK_NORMAL_FORMAT_NAME,null,TextLayoutImporter.parseLinkNormalFormat,null, false);
				_defaultConfiguration.addIEInfo(LinkElement.LINK_ACTIVE_FORMAT_NAME,null,TextLayoutImporter.parseLinkActiveFormat,null, false);
				_defaultConfiguration.addIEInfo(LinkElement.LINK_HOVER_FORMAT_NAME, null,TextLayoutImporter.parseLinkHoverFormat, null, false);
			}
			
			return _defaultConfiguration;
		}
		
		/** Set the default configuration back to its original value 
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*/
		public static function restoreDefaults():void
		{
			_defaultConfiguration = null;
		}
		
				
		protected var bindingsArray:Array;
		
		static private const _formatImporter:TLFormatImporter = new TLFormatImporter(TextLayoutFormatValueHolder,TextLayoutFormat.description);
		static private const _idImporter:SingletonAttributeImporter = new SingletonAttributeImporter("id");
		static private const _styleNameImporter:SingletonAttributeImporter = new SingletonAttributeImporter("styleName");
		static private const _customFormatImporter:CustomFormatImporter = new CustomFormatImporter();
		
		static private const _flowElementFormatImporters:Array = [ _formatImporter,_idImporter,_styleNameImporter,_customFormatImporter ];

		/** Constructor */
		public function TextLayoutImporter(textFlowConfiguration:IConfiguration)
		{
			super(textFlowConfiguration, flowNS, defaultConfiguration);
		}

		override protected function clear():void
		{
			bindingsArray = null;
			super.clear();
		}
		
		private static function get flowNS():Namespace
		{
			return new Namespace("flow", "http://ns.adobe.com/textLayout/2008");
		}
		
		/**  @private */
		override protected function parseContent(rootStory:XML):TextFlow
		{
			// Capture all the top-level tags of interest that can be "bound"
			// We have to do this because the attributes are applied at the point
			// of calling something like:
			// span.charAttrs = characterAttrs;
			// At one time, we just set the variable to the parameter (in the setter),
			// but now we're copying the data into a new object. This change does
			// not allow for us to parse the bindings in any order. Hence, we
			// will process the potential bindings objects first, then the
			// TextFlow objects.
			//
			// Also note the use of "..*" below. We are using this to traverse the
			// XML structure looking for particular tags and at the same time allow for
			// any namespace. So, you might see something like <flow:TextContainer> or
			// <TextContainer> and this code will capture both cases.
			
			var rootName:String = rootStory.name().localName;
			var textFlowElement:XML = rootName == "TextFlow" ? rootStory : rootStory..*::TextFlow[0];
			if (!textFlowElement)
			{
				reportError(GlobalSettings.resourceStringFunction("missingTextFlow")); 
				return null;
			}
			if (!checkNamespace(textFlowElement))
				return null;
	
			return parseTextFlow(this, textFlowElement);
		}
		
		private function parseStandardFlowElementAttributes(flowElem:FlowElement,xmlToParse:XML,importers:Array = null):void
		{
			if (importers == null)
				importers = _flowElementFormatImporters;
			// all the standard ones have to be in importers - some check needed
			parseAttributes(xmlToParse,importers);
			flowElem.format = extractTextFormatAttributesHelper(flowElem.format,_formatImporter) as ITextLayoutFormat;

			flowElem.id = _idImporter.result as String;
			flowElem.styleName = _styleNameImporter.result as String;
			flowElem.userStyles = _customFormatImporter.result as Dictionary;
		}
		

		override public function createTextFlowFromXML(xmlToParse:XML, textFlow:TextFlow = null):TextFlow
		{
			// allocate the TextFlow and set the TextContainer's rootElement to it.
			var newFlow:TextFlow = null;
			if (xmlToParse.@["id"] != undefined)
			{
				var flowName:String = null;
				flowName = xmlToParse.@["id"];
				newFlow = getBoundObjNamed(flowName, TextFlow) as TextFlow;
			}

			if (!checkNamespace(xmlToParse))
				return newFlow;

			// allocate the TextFlow and initialize the container attributes
			if (!newFlow)
				newFlow = new TextFlow(_textFlowConfiguration);
	
			parseStandardFlowElementAttributes(newFlow,xmlToParse);
			
			// TextFlow can have CharacterFormat, ParagraphFormat and ContainerFormat children.  Filter them out here
			parseFlowGroupElementChildren(xmlToParse, newFlow);
			
			CONFIG::debug { newFlow.debugCheckNormalizeAll() ; }
			newFlow.tlf_internal::normalize();
			
			newFlow.tlf_internal::applyWhiteSpaceCollapse();
			
			return newFlow;
		}
		
		public function createDivFromXML(xmlToParse:XML):DivElement
		{
			// add the div element to the parent
			var divElem:DivElement = new DivElement();
			
			parseStandardFlowElementAttributes(divElem,xmlToParse);

			return divElem;
		}
		
		public override function createParagraphFromXML(xmlToParse:XML):ParagraphElement
		{
			var paraElem:ParagraphElement = new ParagraphElement();
			parseStandardFlowElementAttributes(paraElem,xmlToParse);
			return paraElem;
		}
		
		public function createTCYFromXML(xmlToParse:XML):TCYElement
		{
			var tcyElem:TCYElement = new TCYElement();
			parseStandardFlowElementAttributes(tcyElem,xmlToParse);
			return tcyElem;
		}
		
			
		static internal const _linkDescription:Object = {
			href : new StringProperty("href",null, false, null),
			target : new StringProperty("target",null, false, null)
		}
		static private const _linkFormatImporter:TLFormatImporter = new TLFormatImporter(Dictionary,_linkDescription);
		static private const _linkElementFormatImporters:Array = [ _linkFormatImporter, _formatImporter,_idImporter,_styleNameImporter,_customFormatImporter ];

		/** Parse a LinkElement Block.
		 * 
		 * @param - importFilter:BaseTextLayoutImporter - parser object
		 * @param - xmlToParse:XML - the xml describing the Link
		 * @param - parent:FlowBlockElement - the parent of the new Link
		 * @return LinkElement - a new LinkElement and its children
		 */
		public function createLinkFromXML(xmlToParse:XML):LinkElement
		{
			var linkElem:LinkElement = new LinkElement();
			parseStandardFlowElementAttributes(linkElem,xmlToParse,_linkElementFormatImporters);
			if (_linkFormatImporter.result)
			{
				linkElem.href = _linkFormatImporter.result["href"] as String;
				linkElem.target = _linkFormatImporter.result["target"] as String;
			}

			return linkElem;
		}
		
		public override function createSpanFromXML(xmlToParse:XML):SpanElement
		{
			var spanElem:SpanElement = new SpanElement();
			
			parseStandardFlowElementAttributes(spanElem,xmlToParse);

			return spanElem;
		}
		
		static private const _imageDescription:Object = {
			height:InlineGraphicElement.heightPropertyDefinition,
			width:InlineGraphicElement.widthPropertyDefinition,
			source: new StringProperty("source", null, false, null),
			float: new StringProperty("float", null, false, null),
			rotation: InlineGraphicElement.rotationPropertyDefinition }
		
		static private const _ilgFormatImporter:TLFormatImporter = new TLFormatImporter(Dictionary,_imageDescription);
		static private const _ilgElementFormatImporters:Array = [ _ilgFormatImporter, _formatImporter/*,_boundTextLayoutFormatImporter*/,_idImporter,_styleNameImporter,_customFormatImporter ];

		public function createInlineGraphicFromXML(xmlToParse:XML):InlineGraphicElement
		{				
			var imgElem:InlineGraphicElement = new InlineGraphicElement();
			
			parseStandardFlowElementAttributes(imgElem,xmlToParse,_ilgElementFormatImporters);
			
			if (_ilgFormatImporter.result)
			{
				var source:String = _ilgFormatImporter.result["source"];
				imgElem.source = source;
				
				// if not defined then let InlineGraphic set its own default
				imgElem.height = InlineGraphicElement.heightPropertyDefinition.setHelper(imgElem.height,_ilgFormatImporter.result["height"]);
				imgElem.width  = InlineGraphicElement.widthPropertyDefinition.setHelper(imgElem.width,_ilgFormatImporter.result["width"]);
				/*	We don't support rotation yet because of bugs in the player. */		
				// imgElem.rotation  = InlineGraphicElement.heightPropertyDefinition.setHelper(imgElem.rotation,_ilgFormatImporter.result["rotation"]);
				imgElem.float = InlineGraphicElement.floatPropertyDefinition.setHelper(imgElem.float,_ilgFormatImporter.result["float"]);
			}
			
			return imgElem;
		}
	
		public function extractTextFormatAttributesHelper(curAttrs:Object, importer:TLFormatImporter):Object
		{
			return extractAttributesHelper(curAttrs,importer);
		}

		protected function parseNamedFormatDefinition(xmlToParse:XML, importer:TLFormatImporter) : void
		{
			if (!checkNamespace(xmlToParse))
				return;
			
			var idName:String = xmlToParse.@id.toString();
			if (idName == null || idName.length == 0)
				return;
				
			importer.reset();
			for each (var item:XML in xmlToParse.attributes())
				importer.importOneFormat(item.name().localName,item.toString());
			
			if (!bindingsArray)
				bindingsArray = new Array();
			bindingsArray[idName] = importer.result ? importer.result : new importer.classType();
		}
		
		// Find string in array
		static private function arrayHasString(arr:Array, str:String):Boolean
		{
			for each (var item:String in arr)
				if (str == item)
					return true;
			return false;
		}
		
		// Return a "bindings" object. This method allows us to encounter a object via a binding
		// (it appears within "{}" or we can encounter the actual tag (e.g, <CharacterFormat ... >). Either way
		// this method will allocate an object with the given name, and assign the attributes as they become
		// available in the BaseTextLayoutImportFilter.
		internal function getBoundObjNamed(name:String, typeClass:Class):Object
		{
			CONFIG::debug {assert(name != null && name.length > 0, "null string for a bound object")}
			if (!bindingsArray)
				bindingsArray = new Array();
			if (bindingsArray[name] == null) 
			{
				if (typeClass == TextFlow)
					bindingsArray[name] = new typeClass(this._textFlowConfiguration);
				else
					bindingsArray[name] = new typeClass();
 			}

			return bindingsArray[name];
		}

		/** Parse a TCY Block.
		 * 
		 * @param - importFilter:BaseTextLayoutImporter - parser object
		 * @param - xmlToParse:XML - the xml describing the TCY Block
		 * @param - parent:FlowBlockElement - the parent of the new TCY Block
		 * @return TCYBlockElement - a new TCYBlockElement and its children
		 */
		static public function parseTCY(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{
			var tcyElem:TCYElement = TextLayoutImporter(importFilter).createTCYFromXML(xmlToParse);
			if (importFilter.addChild(parent, tcyElem))
			{
				importFilter.parseFlowGroupElementChildren(xmlToParse, tcyElem);
				//if parsing an empty tcy, create a Span for it.
				if (tcyElem.numChildren == 0)
					tcyElem.addChild(new SpanElement());
			}
		}
		
				
		/** Parse a LinkElement Block.
		 * 
		 * @param - importFilter:BaseTextLayoutImporter - parser object
		 * @param - xmlToParse:XML - the xml describing the Link
		 * @param - parent:FlowBlockElement - the parent of the new Link
		 * @return LinkElement - a new LinkElement and its children
		 */
		static public function parseLink(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{
			var linkElem:LinkElement = TextLayoutImporter(importFilter).createLinkFromXML(xmlToParse);
			if (importFilter.addChild(parent, linkElem))
			{
				importFilter.parseFlowGroupElementChildren(xmlToParse, linkElem);
				//if parsing an empty link, create a Span for it.
				if (linkElem.numChildren == 0)
					linkElem.addChild(new SpanElement());
			}
		}
		
		public function createDictionaryFromXML(xmlToParse:XML):Dictionary
		{
			var formatImporters:Array = [ _customFormatImporter ];

			// parse the TextLayoutFormat child object		
			var formatList:XMLList = xmlToParse..*::TextLayoutFormat;
			if (formatList.length() != 1)
				reportError(GlobalSettings.resourceStringFunction("expectedExactlyOneTextLayoutFormat",[ xmlToParse.name() ]));
			
			var parseThis:XML = formatList.length() > 0 ? formatList[0] : xmlToParse;
			parseAttributes(parseThis,formatImporters);
			var styleDictionary:Dictionary = _customFormatImporter.result as Dictionary;

			// Link style property values may have been brought through as literal String values. We need to convert
			// them into typed values, so they get output as canonical translation of the value type into String. 
			// The color property is an example, where it can get input in 3 different formats, but can only be output in one.
			var description:Object = TextLayoutFormat.description;
			for (var prop:String in description)
			{
				var val:* = styleDictionary[prop];
				if (val !== undefined)
				{
					val = description[prop].setHelper(undefined,val)
					if (val !== undefined)
						styleDictionary[prop] = val;
				}
			}
			
			return styleDictionary;
		}

		static public function parseLinkNormalFormat(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{ parent.linkNormalFormat = TextLayoutImporter(importFilter).createDictionaryFromXML(xmlToParse); }
		static public function parseLinkActiveFormat(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{ parent.linkActiveFormat = TextLayoutImporter(importFilter).createDictionaryFromXML(xmlToParse); }
		static public function parseLinkHoverFormat(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{ parent.linkHoverFormat = TextLayoutImporter(importFilter).createDictionaryFromXML(xmlToParse); }

		/** Parse the <div ...> tag and all its children
		 * 
		 * @param - importFilter:BaseTextLayoutImportFilter - parser object
		 * @param - xmlToParse:XML - the xml describing the Div
		 * @param - parent:FlowBlockElement - the parent of the new Div
		 */
		static public function parseDivElement(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{
			var divElem:DivElement = TextLayoutImporter(importFilter).createDivFromXML(xmlToParse);
			if (importFilter.addChild(parent, divElem))
			{
				importFilter.parseFlowGroupElementChildren(xmlToParse, divElem);
				// we can't have a <div> tag w/no children... so, add an empty paragraph
				if (divElem.numChildren == 0)
					divElem.addChild(new ParagraphElement());
			}
		}

		/** Parse a leaf element, the <img ...>  tag.
		 * 
		 * @param - importFilter:BaseTextLayoutImporter - parser object
		 * @param - xmlToParse:XML - the xml describing the InlineGraphic FlowElement
		 * @param - parent:FlowBlockElement - the parent of the new image FlowElement
		 */
		static public function parseInlineGraphic(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{
			var ilg:InlineGraphicElement = TextLayoutImporter(importFilter).createInlineGraphicFromXML(xmlToParse);
			importFilter.addChild(parent, ilg);
		}
	}
}

