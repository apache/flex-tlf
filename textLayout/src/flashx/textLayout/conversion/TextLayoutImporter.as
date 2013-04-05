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
	import flash.display.Shape;
	import flash.text.engine.TextRotation;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.TextLayoutVersion;
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
	import flashx.textLayout.elements.ListElement;
	import flashx.textLayout.elements.ListItemElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TabElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.ListMarkerFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	[ExcludeClass]
	/** 
	 * @private
	 * TextLayoutImporter converts from XML to TextLayout data structures and back.
	 */ 	
	public class TextLayoutImporter extends BaseTextLayoutImporter implements ITextLayoutImporter
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
				// elements
	 			_defaultConfiguration.addIEInfo("TextFlow", TextFlow,        BaseTextLayoutImporter.parseTextFlow,	BaseTextLayoutExporter.exportTextFlow);
				_defaultConfiguration.addIEInfo("br", BreakElement,          BaseTextLayoutImporter.parseBreak,		BaseTextLayoutExporter.exportFlowElement);
				_defaultConfiguration.addIEInfo("p", ParagraphElement,       BaseTextLayoutImporter.parsePara,		BaseTextLayoutExporter.exportParagraphFormattedElement);
				_defaultConfiguration.addIEInfo("span", SpanElement,         BaseTextLayoutImporter.parseSpan,		BaseTextLayoutExporter.exportSpan);
				_defaultConfiguration.addIEInfo("tab", TabElement,           BaseTextLayoutImporter.parseTab,		BaseTextLayoutExporter.exportFlowElement);
				_defaultConfiguration.addIEInfo("list", ListElement,  		 BaseTextLayoutImporter.parseList,		BaseTextLayoutExporter.exportList);
				_defaultConfiguration.addIEInfo("li", ListItemElement,       BaseTextLayoutImporter.parseListItem,	BaseTextLayoutExporter.exportListItem);
				_defaultConfiguration.addIEInfo("g", SubParagraphGroupElement, TextLayoutImporter.parseSPGE, 		TextLayoutExporter.exportSPGE);
				_defaultConfiguration.addIEInfo("tcy", TCYElement,           TextLayoutImporter.parseTCY, 			TextLayoutExporter.exportTCY);
				_defaultConfiguration.addIEInfo("a", LinkElement,            TextLayoutImporter.parseLink, 			TextLayoutExporter.exportLink);
	 			_defaultConfiguration.addIEInfo("div", DivElement,           TextLayoutImporter.parseDivElement, 	TextLayoutExporter.exportDiv);
				_defaultConfiguration.addIEInfo("img", InlineGraphicElement, TextLayoutImporter.parseInlineGraphic, TextLayoutExporter.exportImage);	
				
				// validate the defaultTypeName values.  They are to match the TLF format export xml names
				CONFIG::debug 
				{
					for (var name:String in _defaultConfiguration.flowElementInfoList)
					{
						var info:FlowElementInfo = _defaultConfiguration.flowElementInfoList[name];
						assert(name == (new info.flowClass).defaultTypeName,"Bad defaultTypeName in "+info.flowClass);
					}
				}
				// customized link formats
				_defaultConfiguration.addIEInfo(LinkElement.LINK_NORMAL_FORMAT_NAME,null,TextLayoutImporter.parseLinkNormalFormat,null);
				_defaultConfiguration.addIEInfo(LinkElement.LINK_ACTIVE_FORMAT_NAME,null,TextLayoutImporter.parseLinkActiveFormat,null);
				_defaultConfiguration.addIEInfo(LinkElement.LINK_HOVER_FORMAT_NAME, null,TextLayoutImporter.parseLinkHoverFormat, null);
				// list marker format
				_defaultConfiguration.addIEInfo(ListElement.LIST_MARKER_FORMAT_NAME,null,TextLayoutImporter.parseListMarkerFormat,null);
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
				
		static private const _formatImporter:TLFormatImporter = new TLFormatImporter(TextLayoutFormat,TextLayoutFormat.description);
		static private const _idImporter:SingletonAttributeImporter = new SingletonAttributeImporter("id");
		static private const _typeNameImporter:SingletonAttributeImporter = new SingletonAttributeImporter("typeName");
		static private const _customFormatImporter:CustomFormatImporter = new CustomFormatImporter();
		
		static private const _flowElementFormatImporters:Array = [ _formatImporter,_idImporter,_typeNameImporter,_customFormatImporter ];
		
		private var _imageSourceResolveFunction:Function;

		/** Constructor */
		public function TextLayoutImporter()
		{
			super(new Namespace("flow", "http://ns.adobe.com/textLayout/2008"), defaultConfiguration);
		}
		
		/** @copy ITextLayoutImporter#imageSourceResolveFunction
		 * 
		 * @playerversion Flash 10.0
		 * @playerversion AIR 2.0
		 * @langversion 3.0
		 */
		public function get imageSourceResolveFunction():Function
		{ return _imageSourceResolveFunction; }
		public function set imageSourceResolveFunction(resolver:Function):void
		{ _imageSourceResolveFunction = resolver; }
		
		
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
			
			var textFormat:TextLayoutFormat = extractTextFormatAttributesHelper(flowElem.format,_formatImporter) as TextLayoutFormat;
			if (textFormat)
			{
				CONFIG::debug { assert(textFormat.getStyles() != null,"Bad TextFormat in parseStandardFlowElementAttributes"); }
				flowElem.format = textFormat;
			}

			if (_idImporter.result)
				flowElem.id = _idImporter.result as String;
			if (_typeNameImporter.result)
				flowElem.typeName = _typeNameImporter.result as String;
			if (_customFormatImporter.result)
			{
				for (var styleName:String in _customFormatImporter.result)
					flowElem.setStyle(styleName,_customFormatImporter.result[styleName]);
			}
		}
		

		override public function createTextFlowFromXML(xmlToParse:XML, textFlow:TextFlow = null):TextFlow
		{
			// allocate the TextFlow and set the TextContainer's rootElement to it.
			var newFlow:TextFlow = null;

			if (!checkNamespace(xmlToParse))
				return newFlow;

			if (xmlToParse.hasOwnProperty("@version"))
			{
				var version:String = xmlToParse.@["version"];
				if (version == "3.0.0")
					_importVersion = TextLayoutVersion.VERSION_3_0;
				else if (version == "2.0.0")
					_importVersion = TextLayoutVersion.VERSION_2_0;
				else if (version == "1.1.0" || version == "1.0.0")
					_importVersion = TextLayoutVersion.VERSION_1_0;
				else
				{
					reportError(GlobalSettings.resourceStringFunction("unsupportedVersion",[ xmlToParse.@["version"] ]));
					_importVersion = TextLayoutVersion.CURRENT_VERSION;
				}
			}
			else		// we must be the first version
				_importVersion = TextLayoutVersion.VERSION_1_0;
				
			// allocate the TextFlow and initialize the container attributes
			if (!newFlow)
				newFlow = new TextFlow(_textFlowConfiguration);
	
			// parse formatting
			parseStandardFlowElementAttributes(newFlow,xmlToParse);
			
			// descend into children
			parseFlowGroupElementChildren(xmlToParse, newFlow);
			
			CONFIG::debug { newFlow.debugCheckNormalizeAll() ; }
			newFlow.normalize();
			
			newFlow.applyWhiteSpaceCollapse(null);
			
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
		
		public function createSubParagraphGroupFromXML(xmlToParse:XML):SubParagraphGroupElement
		{
			var elem:SubParagraphGroupElement = new SubParagraphGroupElement();
			parseStandardFlowElementAttributes(elem,xmlToParse);
			return elem;
		}
		
		public function createTCYFromXML(xmlToParse:XML):TCYElement
		{
			var tcyElem:TCYElement = new TCYElement();
			parseStandardFlowElementAttributes(tcyElem,xmlToParse);
			return tcyElem;
		}
		
			
		static internal const _linkDescription:Object = {
			href : Property.NewStringProperty("href",null, false, null),
			target : Property.NewStringProperty("target",null, false, null)
		}
		static private const _linkFormatImporter:TLFormatImporter = new TLFormatImporter(Dictionary,_linkDescription);
		static private const _linkElementFormatImporters:Array = [ _linkFormatImporter, _formatImporter,_idImporter,_typeNameImporter,_customFormatImporter ];

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
			source: Property.NewStringProperty("source", null, false, null),
			float: Property.NewStringProperty("float", null, false, null),
			rotation: InlineGraphicElement.rotationPropertyDefinition }
		
		static private const _ilgFormatImporter:TLFormatImporter = new TLFormatImporter(Dictionary,_imageDescription);
		static private const _ilgElementFormatImporters:Array = [ _ilgFormatImporter, _formatImporter, _idImporter, _typeNameImporter, _customFormatImporter ];

		public function createInlineGraphicFromXML(xmlToParse:XML):InlineGraphicElement
		{				
			var imgElem:InlineGraphicElement = new InlineGraphicElement();
			
			parseStandardFlowElementAttributes(imgElem,xmlToParse,_ilgElementFormatImporters);
			
			if (_ilgFormatImporter.result)
			{
				var source:String = _ilgFormatImporter.result["source"];
				imgElem.source = _imageSourceResolveFunction != null ? _imageSourceResolveFunction(source) : source;
				
				// if not defined then let InlineGraphic set its own default
				imgElem.height = _ilgFormatImporter.result["height"];
				imgElem.width  = _ilgFormatImporter.result["width"];
				/*	We don't support rotation yet because of bugs in the player. */		
				// imgElem.rotation  = InlineGraphicElement.heightPropertyDefinition.setHelper(imgElem.rotation,_ilgFormatImporter.result["rotation"]);
				imgElem.float = _ilgFormatImporter.result["float"];
			}
			
			return imgElem;
		}
	
		public override function createListFromXML(xmlToParse:XML):ListElement
		{
			var rslt:ListElement = new ListElement;
			parseStandardFlowElementAttributes(rslt,xmlToParse);
			return rslt;
		}

		public override function createListItemFromXML(xmlToParse:XML):ListItemElement
		{
			var rslt:ListItemElement = new ListItemElement;
			parseStandardFlowElementAttributes(rslt,xmlToParse);
			return rslt;
		}
		
		public function extractTextFormatAttributesHelper(curAttrs:Object, importer:TLFormatImporter):Object
		{
			return extractAttributesHelper(curAttrs,importer);
		}
		
		/** Parse an SPGE element
		 * 
		 * @param - importFilter:BaseTextLayoutImporter - parser object
		 * @param - xmlToParse:XML - the xml describing the TCY Block
		 * @param - parent:FlowBlockElement - the parent of the new TCY Block
		 * @return SubParagraphGroupElement - a new TCYBlockElement and its children
		 */
		static public function parseSPGE(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{
			var elem:SubParagraphGroupElement = TextLayoutImporter(importFilter).createSubParagraphGroupFromXML(xmlToParse);
			if (importFilter.addChild(parent, elem))
			{
				importFilter.parseFlowGroupElementChildren(xmlToParse, elem);
				//if parsing an empty tcy, create a Span for it.
				if (elem.numChildren == 0)
					elem.addChild(new SpanElement());
			}
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
			return _customFormatImporter.result as Dictionary;
		}

		static public function parseLinkNormalFormat(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{ parent.linkNormalFormat = TextLayoutImporter(importFilter).createDictionaryFromXML(xmlToParse); }
		static public function parseLinkActiveFormat(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{ parent.linkActiveFormat = TextLayoutImporter(importFilter).createDictionaryFromXML(xmlToParse); }
		static public function parseLinkHoverFormat(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{ parent.linkHoverFormat = TextLayoutImporter(importFilter).createDictionaryFromXML(xmlToParse); }
		
		public function createListMarkerFormatDictionaryFromXML(xmlToParse:XML):Dictionary
		{
			var formatImporters:Array = [ _customFormatImporter ];
			
			// parse the TextLayoutFormat child object		
			var formatList:XMLList = xmlToParse..*::ListMarkerFormat;
			if (formatList.length() != 1)
				reportError(GlobalSettings.resourceStringFunction("expectedExactlyOneListMarkerFormat",[ xmlToParse.name() ]));
			
			var parseThis:XML = formatList.length() > 0 ? formatList[0] : xmlToParse;
			parseAttributes(parseThis,formatImporters);
			return _customFormatImporter.result as Dictionary;
		}
		
		static public function parseListMarkerFormat(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{ parent.listMarkerFormat = TextLayoutImporter(importFilter).createListMarkerFormatDictionaryFromXML(xmlToParse); }

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

