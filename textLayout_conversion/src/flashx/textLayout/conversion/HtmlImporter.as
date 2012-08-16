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
	import flash.text.engine.Kerning;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.BreakElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.GlobalSettings;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TabElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.LeadingModel;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormatValueHolder;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.property.StringProperty;
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;
	
	[ExcludeClass]
	/** 
	 * @private
	 * HtmlImporter converts from HTML to TextLayout data structures
	 */ 	
	internal class HtmlImporter extends BaseTextLayoutImporter
	{
		// TLF formats to which <font/> attributes map directly
		static internal var _fontDescription:Object = {
			color:TextLayoutFormat.colorProperty,
			trackingRight:TextLayoutFormat.trackingRightProperty,
			fontFamily:TextLayoutFormat.fontFamilyProperty
		};
		
		// <font/> attributes that require custom logic for mapping to TLF formats
		static internal const _fontMiscDescription:Object = {
			size	: new StringProperty("size", null, false, null),
			kerning	: new StringProperty("kerning", null, false, null)
		};
				
		// TLF formats to which <textformat/> attributes map directly		
		static internal var _textFormatDescription:Object = {
			paragraphStartIndent:TextLayoutFormat.paragraphStartIndentProperty,
			paragraphEndIndent:TextLayoutFormat.paragraphEndIndentProperty,
			textIndent:TextLayoutFormat.textIndentProperty,
			lineHeight:TextLayoutFormat.lineHeightProperty,
			tabStops:TextLayoutFormat.tabStopsProperty
		};	
		
		// <textformat/> attributes that require custom logic for mapping to TLF formats
		static internal const _textFormatMiscDescription:Object = {
			blockIndent	: new StringProperty("blockIndent", null, false, null)
		};
		
		static internal var _paragraphFormatDescription:Object = {
			textAlign:TextLayoutFormat.textAlignProperty
		};
		
		static internal const _linkHrefDescription:Object = {
			href	: new StringProperty("href",   null, false, null)
		};
		
		static internal const _linkTargetDescription:Object = {
			target	: new StringProperty("target", null, false, null)
		};
		
		static internal const _imageDescription:Object = {
			height	: InlineGraphicElement.heightPropertyDefinition,
			width	: InlineGraphicElement.widthPropertyDefinition};
		
		// Separate description because id value is case-sensitive unlike others
		static internal const _imageMiscDescription:Object = {
			src		: new StringProperty("src", null, false, null),
			id		: new StringProperty("id", null, false, null)};
			
		static internal const _classDescription:Object =
		{
			// A property named 'class' confuses the compiler. 
			// class	: new StringProperty("class",   null, false, null)
			// So, we initialize _classDescription in the constructor 
		};
		
		// For some reason, the following can't be initialized here
		static private var _fontImporter:FontImporter;
		static private var _fontMiscImporter:CaseInsensitiveTLFFormatImporter;
		static private var _textFormatImporter:TextFormatImporter;
		static private var _textFormatMiscImporter:CaseInsensitiveTLFFormatImporter;		
		static private var _paragraphFormatImporter:HtmlCustomParaFormatImporter;
		static private var _linkHrefImporter:CaseInsensitiveTLFFormatImporter;
		static private var _linkTargetImporter:CaseInsensitiveTLFFormatImporter;
		static private var _ilgFormatImporter:CaseInsensitiveTLFFormatImporter;
		static private var _ilgMiscFormatImporter:CaseInsensitiveTLFFormatImporter;
		static private var _classImporter:CaseInsensitiveTLFFormatImporter;
		
		// Formats specified by formatting elements in the ancestry of the element being parsed currently 
		static private var _activeFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder(); // to be applied to all flow elements
		static private var _activeParaFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder(); // to be applied to paras only
		static private var _activeImpliedParaFormat:TextLayoutFormatValueHolder = null;
		
		// The basis for relative font size calculation
		static private var _baseFontSize:Number; 
		
		/** Constructor */
		public function HtmlImporter(textFlowConfiguration:IConfiguration)
		{
			super(textFlowConfiguration, null, createConfig());
		}
		
		private static function createConfig():ImportExportConfiguration
		{
			var config:ImportExportConfiguration = new ImportExportConfiguration();
			
			// inherited	
			config.addIEInfo("br", BreakElement, BaseTextLayoutImporter.parseBreak, null, false); 
 			
 			config.addIEInfo("p", ParagraphElement, HtmlImporter.parsePara, null, true);
 			config.addIEInfo("span", SpanElement, HtmlImporter.parseSpan, null, false);
 			config.addIEInfo("a", LinkElement, HtmlImporter.parseLink, null, false);
			config.addIEInfo("img", InlineGraphicElement, HtmlImporter.parseInlineGraphic, null, false);
		
			// formatting elements
			config.addIEInfo("font", null, HtmlImporter.parseFont, null, false);
			config.addIEInfo("textformat", null, HtmlImporter.parseTextFormat, null, false);
			config.addIEInfo("u", null, HtmlImporter.parseUnderline, null, false);
			config.addIEInfo("i", null, HtmlImporter.parseItalic, null, false);
			config.addIEInfo("b", null, HtmlImporter.parseBold, null, false);
			
			// create these here - can't be done above
			if (_classDescription["class"] === undefined)
			{
				_classDescription["class"] = new StringProperty("class", null, false, null);
				_paragraphFormatImporter = new HtmlCustomParaFormatImporter(TextLayoutFormat, _paragraphFormatDescription);
				_textFormatImporter = new TextFormatImporter(TextLayoutFormat, _textFormatDescription);
				_fontImporter = new FontImporter(TextLayoutFormat, _fontDescription);
				_fontMiscImporter = new CaseInsensitiveTLFFormatImporter(Dictionary, _fontMiscDescription);		
				_textFormatMiscImporter = new CaseInsensitiveTLFFormatImporter(Dictionary, _textFormatMiscDescription);
				_linkHrefImporter = new CaseInsensitiveTLFFormatImporter(Dictionary,_linkHrefDescription,false);
				_linkTargetImporter = new CaseInsensitiveTLFFormatImporter(Dictionary,_linkTargetDescription);
				_ilgFormatImporter = new CaseInsensitiveTLFFormatImporter(Dictionary,_imageDescription);
				_ilgMiscFormatImporter = new CaseInsensitiveTLFFormatImporter(Dictionary,_imageMiscDescription, false);
				_classImporter = new CaseInsensitiveTLFFormatImporter(Dictionary,_classDescription);
			}
			return config;
		}
		
		
		/** Parse and convert input data
		 * 
		 * @param source - the HTML string
		 */
		protected override function importFromString(source:String):TextFlow
		{	
			// Use toXML rather than the XML constructor because the latter expects
			// well-formed XML, which source may not be 
			var xml:XML = toXML(source);
			return xml ? importFromXML(xml) : null;
		}

		/** Parse and convert input XML data
		 */
		protected override function importFromXML(xmlSource:XML):TextFlow
		{
			var textFlow:TextFlow = new TextFlow(_textFlowConfiguration);
			
			// Use font size specified in _textFlowConfiguration.textFlowInitialFormat as the base font size
			// If not specified, use 12
			_baseFontSize = textFlow.fontSize === undefined ? 12 : textFlow.fontSize;
			
			// Unlike other markup formats, the HTML format for TLF does not have a fixed root XML element.
			// <html> and <body> are optional, and flow elements may or may not be encapsulated in formatting 
			// elements like <i> or <textformat>. Use parseObject to handle any (expected) root element.
			parseObject(xmlSource.name().localName, xmlSource, textFlow);
			
			// If the last para is implied, there is nothing following it that'll trigger a reset. 
			// For most importers, this is fine (clear will eventually reset it), but the HTML importer has 
			// some special behavior associated with the reset (replacing BreakElements with para splits).
			// Explicitly do so now (must happen before normalization)
			resetImpliedPara();
			
			CONFIG::debug { textFlow.debugCheckNormalizeAll() ; }
			textFlow.normalize();
			textFlow.applyWhiteSpaceCollapse(null);
			
			return textFlow;
		}		

		protected override function clear():void
		{
			// Reset active formats and base font size
			_activeParaFormat.coreStyles = null;
			_activeFormat.coreStyles = null;
			super.clear();
		}
		
		tlf_internal override function createImpliedParagraph():ParagraphElement
		{
			var rslt:ParagraphElement;
			var savedActiveFormat:TextLayoutFormatValueHolder = _activeFormat;
			if (_activeImpliedParaFormat)
				_activeFormat = _activeImpliedParaFormat;
			try
			{
				rslt = super.createImpliedParagraph();
			}
			finally
			{
				_activeFormat = savedActiveFormat;
			}
			return rslt;
		}

		public override function createParagraphFromXML(xmlToParse:XML):ParagraphElement
		{
			var paraElem:ParagraphElement = new ParagraphElement();
				
			// Parse xml attributes for paragraph format
			var formatImporters:Array = [_paragraphFormatImporter, _classImporter];
			parseAttributes(xmlToParse, formatImporters);
			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat(_paragraphFormatImporter.result as ITextLayoutFormat);
			
			// Apply paragraph format inherited from formatting elements
			if (_activeParaFormat)
				paragraphFormat.apply(_activeParaFormat);
			if (_activeFormat)
				paragraphFormat.apply(_activeFormat);
			
			// A <FONT/> that is the only child of a <P/> specifies formats that apply to the paragraph itself
			// Otherwise (i.e., if it has siblings), the formats apply to the elements nested within the <FONT/>
			// Check for the former case here
			var fontFormattingElement:XML = getSingleFontChild (xmlToParse);
			if (fontFormattingElement)
				paragraphFormat.apply(parseFontAttributes(fontFormattingElement));
				
			if (paragraphFormat.lineHeight !== undefined)
				paragraphFormat.leadingModel = LeadingModel.APPROXIMATE_TEXT_FIELD;
			
			paraElem.format = paragraphFormat;
			
			// Use the value of the 'class' attribute (if present) as styleName
			paraElem.styleName =  _classImporter.getFormatValue("class"); 
					
			return paraElem;
		}
				
		/** Parse the supplied XML into a paragraph. Parse the <p/> element and its children.
		 * 
		 * @param importFilter	parser object
		 * @param xmlToParse	content to parse
		 * @param parent 		the parent for the new content
		 */
		static public function parsePara(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{
			var paraElem:ParagraphElement = (importFilter as HtmlImporter).createParagraphFromXML(xmlToParse);
			
			if (importFilter.addChild(parent, paraElem))
			{
				// Parse children, but if there is only one child, a <FONT/>, skip to *its* children.
				// That's because the single <FONT/> chuld has already been parsed in createParagraphFromXML.
				var fontFormattingElement:XML = getSingleFontChild (xmlToParse);
				parseChildrenUnderNewActiveFormat (importFilter, fontFormattingElement ? fontFormattingElement : xmlToParse, paraElem, _activeFormat, null);
				
				//if parsing an empty paragraph, create a Span for it.
				if (paraElem.numChildren == 0)
					paraElem.addChild(new SpanElement());
			}
			
			// Replace break elements with paragraph splits
			// This must happen before normalization else BreakElements may merge or become spans
			replaceBreakElementsWithParaSplits(paraElem);
		}
		
		protected override function onResetImpliedPara(para:ParagraphElement):void
		{
			// Replacing break elements with paragraph splits, even for implied paras
			replaceBreakElementsWithParaSplits (para);
		}
		
		/** If the provided xml has a single child <FONT.../>, get it
		 */
		static private function getSingleFontChild (xmlToParse:XML):XML
		{
			var children:XMLList = xmlToParse.children();
			if (children.length() == 1)
			{
				var child:XML = children[0];
				if (child.name().localName.toLowerCase() == "font")
					return child;
			}
			
			return null;
		}
			
		private function createLinkFromXML(xmlToParse:XML):LinkElement
		{
			var linkElem:LinkElement = new LinkElement();

			var formatImporters:Array = [ _linkHrefImporter, _linkTargetImporter ];
			parseAttributes(xmlToParse, formatImporters);
			
			linkElem.href = _linkHrefImporter.getFormatValue("href");
			linkElem.target = _linkTargetImporter.getFormatValue("target");
			
			// Handle difference in defaults between TextField and TLF 
			// target "_self" vs. null (equivalent to "_blank")
			if (!linkElem.target)
				linkElem.target = "_self";
				
			//  Apply active format
			linkElem.format = _activeFormat;

			return linkElem;
		}
		
		/** Parse the supplied XML into a LinkElement. Parse the <a/> element and its children.
		 * 
		 * @param importFilter	parser object
		 * @param xmlToParse	content to parse
		 * @param parent 		the parent for the new content
		 */
		static public function parseLink(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{
			var linkElem:LinkElement = HtmlImporter(importFilter).createLinkFromXML(xmlToParse);
			
			if (importFilter.addChild(parent, linkElem))
			{
				parseChildrenUnderNewActiveFormat (importFilter, xmlToParse, linkElem, _activeFormat, null);
				
				// If parsing an empty link, create a Span for it.
				if (linkElem.numChildren == 0)
					linkElem.addChild(new SpanElement());
			}
		}	
		
		/** Static method for constructing a span from XML. Parse the <span> ... </span> tag. 
		 * Insert the new content into its parent
		 * Note: Differs from BaseTextLayoutImporter.parseSpan in that it allows nested <span/> elements. 
		 * 
		 * @param importFilter	parser object
		 * @param xmlToParse	content to parse
		 * @param parent 		the parent for the new content
		 */
		static public function parseSpan(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{
			var firstSpan:SpanElement = new SpanElement();
			
			// Use the value of the 'class' attribute (if present) as styleName
			var formatImporters:Array = [_classImporter];
			importFilter.parseAttributes(xmlToParse,formatImporters);
			firstSpan.styleName = _classImporter.getFormatValue("class");
			
			// Apply active format
			firstSpan.format = _activeFormat;
			
			var elemList:XMLList = xmlToParse[0].children();
			if(elemList.length() == 0)
			{
				// Empty span, but may have formatting, so don't strip it out. 
				// Note: the normalizer may yet strip it out if it is not the last child, but that's the normalizer's business.
				importFilter.addChild(parent, firstSpan); 
				return;
			}
	
			for each (var child:XML in elemList) 
			{
				var elemName:String = child.name() ? child.name().localName : null;
					
				if (elemName == null) // span text
				{
					if (firstSpan.parent == null)	// hasn't been used yet
					{
						firstSpan.text = child.toString();
						importFilter.addChild(parent, firstSpan);
					}
					else
					{
						var s:SpanElement = new SpanElement();
						copyAllStyleProps(s,firstSpan);
						s.text = child.toString();
						importFilter.addChild(parent, s);
					}
				}
				else 
				{
					// Anything else: will become siblings of the spans that are (or will be) created for text nodes
					// (assuming that's valid). For example <span class="A">A quick <span class="B">fox</span></span>
					// is treated like <span class="A">A quick </span><span class="B">fox</span>. Consequently, any formatting
					// associated with class "A" will not apply to "fox". This is a shortcoming in the TLF object model: 
					// SpanElements can't nest.
					importFilter.parseObject(elemName, child, parent);
				}
			}
		} 
	
		private function createInlineGraphicFromXML(xmlToParse:XML):InlineGraphicElement
		{				
			var imgElem:InlineGraphicElement = new InlineGraphicElement();

			var formatImporters:Array = [_ilgFormatImporter, _ilgMiscFormatImporter];	
			parseAttributes(xmlToParse,formatImporters);
			
			var source:String = _ilgMiscFormatImporter.getFormatValue("src");
			imgElem.source = source;
				
			// if not defined then let InlineGraphic set its own default
			imgElem.height = InlineGraphicElement.heightPropertyDefinition.setHelper(imgElem.height,_ilgFormatImporter.getFormatValue("height"));
			imgElem.width  = InlineGraphicElement.heightPropertyDefinition.setHelper(imgElem.width,_ilgFormatImporter.getFormatValue("width"));
				
			/* Not currently supported
			var floatVal:String = _ilgFormatImporter.getFormatValue("align");
			// Handle difference in defaults between TextField and TLF 
			// float "left" vs. "none"
			imgElem.float = floatVal ? floatVal : Float.LEFT;
			*/
			
			var id:String = _ilgMiscFormatImporter.getFormatValue("id");
			imgElem.id = id;
			
			//  Apply active format
			imgElem.format = _activeFormat;
			
			return imgElem;
		}

		/** Parse the supplied XML into an InlineGraphicElement. Parse the <img/> element.
		 * 
		 * @param importFilter	parser object
		 * @param xmlToParse	content to parse
		 * @param parent 		the parent for the new content
		 */
		static public function parseInlineGraphic(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{
			var ilg:InlineGraphicElement = HtmlImporter(importFilter).createInlineGraphicFromXML(xmlToParse);
			importFilter.addChild(parent, ilg);
		}
		
		public override function createTabFromXML(xmlToParse:XML):TabElement
		{
			return null; // no tabs in HTML
		}
			
		/** Parse the attributes of the <Font/> formatting element and returns the corresponding TLF format
		 */
		private function parseFontAttributes(xmlToParse:XML):ITextLayoutFormat
		{
			var formatImporters:Array = [_fontImporter, _fontMiscImporter];
			parseAttributes(xmlToParse, formatImporters);
			
			var newFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder(_fontImporter.result as ITextLayoutFormat);
			
			var kerning:String = _fontMiscImporter.getFormatValue("kerning");
			if (kerning)
			{
				var kerningVal:Number = Number(kerning);
				newFormat.kerning = kerningVal == 0 ? Kerning.OFF : Kerning.AUTO;
			}
			
			var size:String = _fontMiscImporter.getFormatValue("size");
			if (size)
			{
				var sizeVal:Number = TextLayoutFormat.fontSizeProperty.setHelper(NaN, size);
				if (!isNaN(sizeVal))
				{
					if (size.search(/\s*(-|\+)/) != -1) // leading whitespace followed by + or -
						sizeVal += _baseFontSize;		// implies relative font sizes
					newFormat.fontSize = sizeVal;
				}
			}
			
			return newFormat;
		}
		
		/** Parse the <Font/> formatting element
		 * Calculates the new format to apply to _activeFormat and continues parsing down the hierarchy
		 */
		static public function parseFont(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{
			var newFormat:ITextLayoutFormat = (importFilter as HtmlImporter).parseFontAttributes (xmlToParse);
			parseChildrenUnderNewActiveFormatWithImpliedParaFormat(importFilter, xmlToParse, parent, newFormat);
		}
		
		/** Parse the <TextFormat> formatting element
		 * Calculates the new format to apply to _activeParaFormat and continues parsing down the hierarchy
		 */
		static public function parseTextFormat(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{	
			var formatImporters:Array = [_textFormatImporter, _textFormatMiscImporter];
			importFilter.parseAttributes(xmlToParse, formatImporters);
			
			var newFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder(_textFormatImporter.result as ITextLayoutFormat);
			
			var blockIndent:String = _textFormatMiscImporter.getFormatValue("blockIndent");
			if (blockIndent)
			{
				// TODO: Nested <TextFormat/>?
				var blockIndentVal:Number = TextLayoutFormat.paragraphStartIndentProperty.setHelper(NaN, blockIndent);
				if (!isNaN(blockIndentVal))
					newFormat.paragraphStartIndent = newFormat.paragraphStartIndent === undefined ? blockIndentVal : newFormat.paragraphStartIndent + blockIndentVal;
			}

			parseChildrenUnderNewActiveFormat (importFilter, xmlToParse, parent, _activeParaFormat, newFormat, true);
		}
		
		/** Parse the <b> formatting element
		 * Calculates the new format to apply to _activeFormat and continues parsing down the hierarchy
		 */
		static public function parseBold(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{	
			var newFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder();
			newFormat.fontWeight = flash.text.engine.FontWeight.BOLD;
			
			parseChildrenUnderNewActiveFormatWithImpliedParaFormat (importFilter, xmlToParse, parent, newFormat);
		}
		
		/** Parse the <i> formatting element
		 * Calculates the new format to apply to _activeFormat and continues parsing down the hierarchy
		 */
		static public function parseItalic(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{	
			var newFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder();
			newFormat.fontStyle = flash.text.engine.FontPosture.ITALIC;
			parseChildrenUnderNewActiveFormatWithImpliedParaFormat (importFilter, xmlToParse, parent, newFormat);
		}
		
		/** Parse the <u> formatting element
		 * Calculates the new format to apply to _activeFormat and continues parsing down the hierarchy
		 */
		static public function parseUnderline(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement):void
		{	
			var newFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder();
			newFormat.textDecoration = flashx.textLayout.formats.TextDecoration.UNDERLINE;
			parseChildrenUnderNewActiveFormatWithImpliedParaFormat(importFilter, xmlToParse, parent, newFormat);

		}
		
		static private function parseChildrenUnderNewActiveFormatWithImpliedParaFormat(importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement, newFormat:ITextLayoutFormat):void
		{
			var oldActiveImpliedParaFormat:TextLayoutFormatValueHolder = _activeImpliedParaFormat;
			if (_activeImpliedParaFormat == null)
				_activeImpliedParaFormat = new TextLayoutFormatValueHolder(_activeFormat);
			try
			{
				parseChildrenUnderNewActiveFormat(importFilter, xmlToParse, parent, _activeFormat, newFormat, true);
			}
			finally
			{
				_activeImpliedParaFormat = oldActiveImpliedParaFormat;
			}
		}
		
		/** Updates the current active format and base font size as specified, parses children, and restores the active format and base font size
		 * There are two different use cases for this method:
		 * - Parsing children of a formatting XML element like <Font/> or <TextFormat/>. In this case, the TLF format corresponding to the formatting element
		 * (newFormat) is applied to the currently active format (_activeFormat in the case of <Font/> and _activeParaFormat in the case of <TextFormat/>). 
		 * Children of the formatting element are parsed under this new active format.
		 * - Parsing children of a flow XML element like <P/> or <A/>. In this case, newFormat is null and the currently active format (_activeFormat) is reset.
		 * Children of the flow element are parsed under this newly reset format. This is to avoid redundancy (the format is already applied to the flow element). 
		 * 
		 * @param importFilter	parser object
		 * @param xmlToParse	content to parse
		 * @param parent 		the parent for the parsed children
		 * @param currFormat	the active format (_activeFormat or _activeParaFormat)
		 * @param newFormat		the format to apply to currFormat while the children are being parsed. If null, currFormat is to be reset.
		 * @param chainedParent whether parent actually corresponds to xmlToParse or has been chained (such as when xmlToParse is a formatting element). See BaseTextLayoutImporter.parseFlowGroupElementChildren
		 */
		static private function parseChildrenUnderNewActiveFormat (importFilter:BaseTextLayoutImporter, xmlToParse:XML, parent:FlowGroupElement, currFormat:TextLayoutFormatValueHolder, newFormat:ITextLayoutFormat, chainedParent:Boolean=false):void
		{
			// Remember the current state
			var restoreBaseFontSize:Number = _baseFontSize;
			var restoreCoreStyles:Object = Property.shallowCopy(currFormat.coreStyles);
			
			if (newFormat)
			{
				// Update base font size based on the new format
				if (newFormat.fontSize !== undefined)
					_baseFontSize = newFormat.fontSize; 
					
				// Apply the new format
				currFormat.apply(newFormat);
			}
			else
			{
				// Base font size remains unchanged
				
				// Reset the new format
				currFormat.coreStyles = null;
			}
			
			try
			{
				importFilter.parseFlowGroupElementChildren(xmlToParse, parent, null, chainedParent);
			}
			finally
			{
				// Restore 
				currFormat.coreStyles = restoreCoreStyles;
				_baseFontSize = restoreBaseFontSize;
			}
		}
		
		protected override function handleUnknownAttribute(elementName:String, propertyName:String):void
		{
			// A toss-up: report error or ignore? Ignore for now
			// If we do end up reporting error, we should add exceptions for documented attributes that we don't handle
			// like align on <img/>
		}
		
		protected override function handleUnknownElement(name:String, xmlToParse:XML, parent:FlowGroupElement):void
		{
			// Not an error (it may be a styling element like <h1/>); continue parsing children
			parseFlowGroupElementChildren (xmlToParse, parent, null, true);
		}										
		
		tlf_internal override function  parseObject(name:String, xmlToParse:XML, parent:FlowGroupElement, exceptionElements:Object=null):void
		{
			// override to allow upper case tag names
			super.parseObject(name.toLowerCase(), xmlToParse, parent, exceptionElements);
		}
		
		protected override function checkNamespace(xmlToParse:XML):Boolean
		{	
			/* Ignore namespace */
			return true;
		}
		
		/** Splits the paragraph wherever a break element occurs and removes the latter
		 * This is to replicate TextField handling of <br/>: splits the containing paragraph (implied or otherwise)
		 * The <br/> itself doesn't survive.
		 */
		static private function replaceBreakElementsWithParaSplits(para:ParagraphElement):void
		{
			// performance: when splitting the paragraph into multiple paragraphs take it out of the TextFlow
			var paraArray:Array;
			var paraIndex:int;
			var paraParent:FlowGroupElement;
	
			// Find each BreakElement and split into a new paragraph
			var elem:FlowLeafElement = para.getFirstLeaf();
			while (elem)
			{
				if (!(elem is BreakElement))
				{
					elem = elem.getNextLeaf(para);
					continue;					
				}
				if (!paraArray)
				{
					paraArray = [ para ];
					paraParent = para.parent;
					paraIndex = paraParent.getChildIndex(para);
					paraParent.removeChildAt(paraIndex);
				}
					
				// Split the para right after the BreakElement
				//CONFIG::debug { assert(elem.textLength == 1,"Bad TextLength in BreakElement"); }
				CONFIG::debug {assert( para.getAbsoluteStart() == 0,"Bad paragraph in replaceBreakElementsWithParaSplits"); }
				para = para.splitAtPosition(elem.getAbsoluteStart()+elem.textLength) as ParagraphElement;
				paraArray.push(para);
					
				// Remove the BreakElement
				elem.parent.removeChild(elem);	
				
				// point elem to the first leaf of the new paragraph
				elem = para.getFirstLeaf();
			}
			
			if (paraArray)
				paraParent.replaceChildren(paraIndex,paraIndex,paraArray);
		}
		
		/** HTML parsing code
		 *  Uses regular expressions for recognizing constructs like comments, tags etc.
		 *  and a hand-coded parser to recognize the document structure and covert to well-formed xml
		 *  TODO-1/16/2009:List caveats
		 */ 
		
		/** Regex for stuff to be stripped: a comment, processing instruction, or a declaration
		 *
		 * <!--.*?--> - comment
		 *   <!-- - start comment
		 *   .*? - anything (including newline character, thanks to the s flag); the ? prevents a greedy match (which could match a --> later in the string) 
		 *  --> - end comment
		 *  
		 * <\?(".*?"|'.*?'|[^>]+)*> - processing instruction
		 *   <\? - start processing instruction
		 *   (".*?"|'.*?'|[^>]+)* - 0 or more of the following (interleaved in any order)
		 *     ".*?" - anything (including >) so long as it is within double quotes; the ? prevents a greedy match (which could match everything until a later " in the string) 
		 *     '.*?' - anything (including >) so long as it is within single quotes; the ? prevents a greedy match (which could match everything until a later ' in the string)
		 *     [^>"']+ - one or more characters other than > (because > ends the processing instruction), " (handled above), ' (handled above) 
		 *   > - end processing instruction
		 *
		 * <!(".*?"|'.*?'|[^>"']+)*> - declaration; 
		 * TODO-1/15/2009:not sure if a declaration can contain > within quotes. Assuming it can, the regex is  
		 *  is exactly like processing instruction above except it uses a ! instead of a ?
		 */
		private static var stripRegex:RegExp = /<!--.*?-->|<\?(".*?"|'.*?'|[^>"']+)*>|<!(".*?"|'.*?'|[^>"']+)*>/sg;
						
		/** Regular expression for an HTML tag
		 * < - open
		 *
		 * (\/?) - start modifier; 0 or 1 occurance of one of /
		 *
		 * (\w+) - tag name; 1 or more name characters
		 *
		 * ((?:\s+\w+(?:\s*=\s*(?:".*?"|'.*?'|[\w\.]+))?)*) - attributes; 0 or more of the following
		 *   (?:\s+\w+(?:\s*=\s*(?:".*?"|'.*?'|[\w\.]+))?) - attribute; 1 or more space, followed by 1 or more name characters optionally followed by
		 *      \s*=\s*(?:".*?"|'.*?'|[\w\.]+) - attribute value assignment; optional space followed by = followed by more optional space followed by one of
		 *         ".*?" - quoted attribute value (using double quotes); the ? prevents a greedy match (which could match everything until a later " in the string)
		 *         '.*?' - quoted attribute value (using single quotes); the ? prevents a greedy match ((which could match everything until a later ' in the string)
		 *         [\w\.]+ - unquoted attribute value; can only contain name characters or a period
		 *  Note: ?: specifies a non-capturing group (i.e., match won't be recorded or used as a numbered back-reference)
		 *
		 * \s* - optional space
		 *
		 * (\/?) - end modifer (0 or 1 occurance of /)
		 *
		 * > - close*/
		private static var tagRegex:RegExp = /<(\/?)(\w+)((?:\s+\w+(?:\s*=\s*(?:".*?"|'.*?'|[\w\.]+))?)*)\s*(\/?)>/sg;
		
		/** Regular expression for an attribute. Except for grouping differences, this regex is the same as the one that appears in tagRegex
		 */
		private static var attrRegex:RegExp = /\s+(\w+)(?:\s*=\s*(".*?"|'.*?'|[\w\.]+))?/sg;
		
		/** Wrapper for core HTML parsing code that manages XML settings during the process
		 */
		private function toXML(source:String):XML
		{
			var xml:XML;
			
			var originalSettings:Object = XML.settings();
			try
			{
				XML.ignoreProcessingInstructions = false;		
				XML.ignoreWhitespace = false;	

				xml = toXMLInternal(source);				
			}			
			finally
			{
				XML.setSettings(originalSettings);
			}	
			
			return xml;
		}	
		
		/** Convert HTML string to well-formed xml, accounting for the following HTML oddities
		 * 
		 * 1) Start tags are optional for some elements.
		 * Optional start tag not specified</html>
		 * TextField dialect: This is true for all elements. 
		 * 
		 * 2) End tags are optional for some elements. Elements with missing end tags may be implicitly closed by
		 *    a) start-tag for a peer element
		 *    <p>p element without end tag; closed by next p start tag
		 *    <p>closes previous p element with missing end tag</p>
		 * 
		 *    b) end-tag for an ancestor element 
		 * 	  <html><p>p element without end tag; closed by next end tag of an ancestor</html>
		 *     TextField dialect: This is true for all elements. 
		 * 
		 * 3) End tags are forbidden for some elements
		 * <br> and <br/> are valid, but <br></br> is not
		 * TextField dialect: Does not apply. 
		 * 
		 * 4) Element and attribute names may use any case
		 * <P ALign="left"></p>
		 * 
		 * 5) Attribute values may be unquoted
		 * <p align=left/>
		 * 
		 * 6) Boolean attributed may assume a minimized form
		 * <p selected/> is equivalent to <p selected="selected"/>
		 * 
		 */	
		private function toXMLInternal(source:String):XML
		{
			// Strip out comments, processing instructions and declaratins	
			source = source.replace(stripRegex, "");
			
			// Parse the source, looking for tags and interleaved text content, creating an XML hierarchy in the process.
			// At any given time, there is a chain of 'open' elements corresponding to unclosed tags, the innermost of which is 
			// tracked by the currElem. Content (element or text) parsed next is added as a child of currElem.
			
			// Root of the XML hierarchy (set to <html/> because the html start tag is optional)
			// Note that source may contain an html start tag, in which case we'll end up with two such elements
			// This is not quite correct, but handled by the importer  
			var root:XML = <html/>; 
			var currElem:XML = root;  
			
			var lastIndex:int = tagRegex.lastIndex = 0;
			var openElemName:String;
						
			do
			{						
				var result:Object = tagRegex.exec(source);
				if (!result)
				{
					// No more tags: add text (starting at search index) as a child of the innermost open element and break out
					appendTextChild (currElem, source.substring(lastIndex));
					break;
				}
				
				if (result.index != lastIndex)
				{
					// Add text between tags as a child of the innermost open element
					appendTextChild (currElem, source.substring(lastIndex, result.index));
				}
				
				var tag:String = result[0]; // entire tag
				var hasStartModifier:Boolean = (result[1] == "\/"); // modifier after < (/ for end tag)
				var name:String = result[2].toLowerCase();  // name; use lower case
				var attrs:String = result[3];  // attributes; including whitespace
				var hasEndModifier:Boolean = (result[4] == "\/"); // modifier before > (/ for composite start and end tag)

				if (!hasStartModifier) // start tag 
				{	
					// Special case for implicit closing of <p>
					// TODO-12/23/2008: this will need to be handled more generically				
					if (name == "p" && currElem.name().localName == "p")
						currElem = currElem.parent();
						
					// Create an XML element by constructing a tag that can be fed to the XML constructor. Specifically, ensure
					// - it is a composite tag (start and end tag together) using the terminating slash shorthand
					// - element and attribute names are lower case (this is not required, but doesn't hurt)
					// - attribute values are quoted  	
					// - boolean attributes are fully specified (e.g., selected="selected" rather than selected)
					tag = "<" + name;
					do
					{
						var innerResult:Object = attrRegex.exec(attrs);
						if (!innerResult)
							break;
							
						var attrName:String = innerResult[1].toLowerCase();
						tag += " " + attrName + "="; 
						var val:String = innerResult[2] ? innerResult[2] : attrName /* boolean attribute with implied value equal to attribute name */; 
						var startChar:String = val.charAt(0); 
						tag += ((startChar == "'" || startChar == "\"") ? val : ("\"" + val + "\""));
						
					} while (true);	 
					tag += "\/>";
					
					// Add the corresponding element as a child of the innermost open element 
					currElem.appendChild(new XML(tag));
					
					// The new element becomes the innermost open element unless it is already closed because
					// - this is a composite start and end tag (i.e., has an end modifier) 
					// - the start tag itself implies closure
					if (!hasEndModifier && !doesStartTagCloseElement(name))
						currElem = currElem.children()[currElem.children().length()-1];	
				}	
				else // end tag
				{	
					if (hasEndModifier || attrs.length)
					{
						reportError(GlobalSettings.resourceStringFunction("malformedTag",[tag]));
					}
					else
					{
						/*
						// Does not apply to TextField dialect
						if (isEndTagForbidden(name))
						{
							xxxreportError("End tag is not allowed for element " + name); NOTE : MAKE A LOCALIZABLE ERROR IF THIS COMES BACK
							return null;
						}*/
					
						// Move up the chain of open elements looking for a matching name
						// The matching element is closed and its parent becomes the innermost open element
						// Report error if matching element is not found and it requires a start tag
						// All intermediate open elements are also closed provided they don't require end tags
						// Report error if an intermediate element requires end tags
						var openElem:XML = currElem;
						do
						{
							openElemName = openElem.name().localName; 
							openElem = openElem.parent();
							
							if (openElemName == name)
							{
								currElem = openElem;
								break;
							}
							/*
							// Does not apply to TextField dialect
							else if (isEndTagRequired(openElemName))
							{
								xxxreportError("Missing end tag for element " + openElemName);
								return null;
							}*/
	
							
							if (!openElem)
							{
								// Does not apply to TextField dialect
								/*if (isStartTagRequired(name))
								{
									xxxreportError("Unexpected end tag " + name);
									return null;
								}*/
								break;
							}					
						}
						while (true);
					}
				}
				
				lastIndex = tagRegex.lastIndex;
				if (lastIndex == source.length)
					break; // string completely parsed
					
			} while (currElem); // null currElem means <html/> has been closed, so ignore everything else		
			
			// No more string to parse, specifically, no more end tags. 
			// Validate that remaining open elements do not require end tags.
			// Does not apply to TextField dialect
			/* while (currElem)
			{
				openElemName = currElem.name().localName; 
				if (isEndTagRequired(openElemName))
				{
					xxxreportError("Missing end tag for element " + openElemName);
					return null;
				}
				currElem = currElem.parent();
			}*/	
			
			return root;
		}
		
		/** TODO-1/16/2009-Evaluate if following code may be better implemented using dictionaries queried at runtime
		 */
		/* 
		// TextField dialect: Not used  
		private function isStartTagRequired (tagName:String):Boolean
		{
			switch (tagName)
			{
				case "a":
				case "b":
				case "br":
				case "font":
				case "i":
				case "img":
				case "p":
				case "span":
				case "textformat":
				case "u":
					return true;
				default:
					// html, head, body, and unrecognized elements (which are handled leniently)
					return false;
			}
		}
		
		private function isEndTagRequired (tagName:String):Boolean
		{
			switch (tagName)
			{
				case "a":
				case "b":
				case "font":
				case "i":
				case "span":
				case "textformat":
				case "u":
					return true;
				default:
					// html, head, body, p, br, image and unrecognized elements (which are handled leniently)
					return false; 	
			}
		}
		
		private function isEndTagForbidden (tagName:String):Boolean
		{
			switch (tagName)
			{
				case "br":
				case "img":
					return true;
				default:
					return false;
			}
		}*/
		
		private function doesStartTagCloseElement (tagName:String):Boolean
		{
			switch (tagName)
			{
				case "br":
				case "img":
					return true;
				default:
					return false;
			}
		}
		
		private static const anyPrintChar:RegExp = /[^\u0009\u000a\u000d\u0020]/g;	

		/** Adds text as a descendant of the specified XML element. Adds an intermediate <span> element is created if parent is not a <span>
		 *  No action is taken for whitespace-only text
		 */
		private function appendTextChild(parent:XML, text:String):void
		{
			// No whitespace collapse
			// if (text.match(anyPrintChar).length != 0) 
			{
				var parentIsSpan:Boolean = (parent.localName() == "span");
				var elemName:String = parentIsSpan ? "dummy" : "span";
				
				//var xml:XML = <{elemName}/>;
				//xml.appendChild(text);
				// The commented-out code above doesn't handle character entities like &lt; 
				// The following lets the XML constructor handle them 
				var xmlText:String = "<" + elemName + ">" + text + "<\/" + elemName + ">";
				try
				{
					var xml:XML = new XML(xmlText);
					parent.appendChild(parentIsSpan ? xml.children()[0] : xml);
				}
				catch (e:*)
				{
					// Report malformed content like "<" instead of "&lt;"
					reportError(GlobalSettings.resourceStringFunction("malformedMarkup",[text]));
				}
					
			}
		}	
	}
}

import flashx.textLayout.conversion.TLFormatImporter;

/** Specialized to provide case insensitivity (as required by TEXT_FIELD_HTML_FORMAT)
 *  Keys need to be lower-cased. Values may or may not based on a flag passed to the constructor. 
 */
class CaseInsensitiveTLFFormatImporter extends TLFormatImporter
{
	public function CaseInsensitiveTLFFormatImporter(classType:Class,description:Object, convertValuesToLowerCase:Boolean=true)
	{
		_convertValuesToLowerCase = convertValuesToLowerCase;
		
		var lowerCaseDescription:Object = new Object();
		for (var prop:Object in description)
		{
			lowerCaseDescription[prop.toLowerCase()] = description[prop];
		}
		
		super(classType, lowerCaseDescription);
	}
	
	public override function importOneFormat(key:String,val:String):Boolean
	{
		return super.importOneFormat(key.toLowerCase(), _convertValuesToLowerCase ? val.toLowerCase() : val);  
	} 
	
	public function getFormatValue (key:String):*
	{
		return result ? result[key.toLowerCase()] : undefined;
	}
	
	private var _convertValuesToLowerCase:Boolean;
}

class HtmlCustomParaFormatImporter extends TLFormatImporter
{
	public function HtmlCustomParaFormatImporter(classType:Class,description:Object)
	{
		super(classType,description);
	}
	
	public override function importOneFormat(key:String,val:String):Boolean
	{
		key = key.toLowerCase();
		
		if (key == "align")
			key = "textAlign";
		return super.importOneFormat(key,val.toLowerCase()); // covert val to lowercase because TLF won't accept, say, "RIGHT"
	} 
}

class TextFormatImporter extends TLFormatImporter
{
	public function TextFormatImporter(classType:Class,description:Object)
	{
		super(classType,description);
	}
	
	public override function importOneFormat(key:String,val:String):Boolean
	{
		key = key.toLowerCase();
		
		if (key == "leftmargin")
			key = "paragraphStartIndent"; // assumed to be left-to-right text since we don't handle DIR attribute
		else if (key == "rightmargin")
			key = "paragraphEndIndent";   // assumed to be left-to-right text since we don't handle DIR attribute
		else if (key == "indent")
			key = "textIndent";
		else if (key == "leading")
			key = "lineHeight";
		else if (key == "tabstops")
		{
			key = "tabStops";
			// Comma-delimited in TextField HTML format, space delimited in TLF
			val = val.replace(/,/g, ' '); 
		}
		return super.importOneFormat(key,val); // no case-coversion required, values for these formats in TLF are case-insensitive
	} 
}

class FontImporter extends TLFormatImporter
{
	public function FontImporter(classType:Class,description:Object)
	{
		super(classType,description);
	}
	
	public override function importOneFormat(key:String,val:String):Boolean
	{
		key = key.toLowerCase();
		if (key == "letterspacing")
			key = "trackingRight";
		else if (key == "face")
			key = "fontFamily";
		return super.importOneFormat(key,val);  // no case-coversion required, values for these formats in TLF are case-insensitive
	} 
}

