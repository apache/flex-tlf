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
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.formats.TabStopFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.formats.LeadingModel;
	import flashx.textLayout.formats.FormatValue;
	import flash.text.engine.FontWeight;
	import flash.text.engine.FontPosture;
	import flash.text.engine.Kerning;
	import flash.text.engine.TabAlignment;
	import flash.utils.getQualifiedClassName;
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.formats.FormatValue;
	use namespace tlf_internal;

	[ExcludeClass]
	/** 
	* @private
	* Export filter for HTML format. 
	*/
	internal class HtmlExporter implements ITextExporter	
	{
		private static var _config:ImportExportConfiguration;
		
		public function HtmlExporter()
		{
			if (!_config)
			{
				_config = new ImportExportConfiguration();
				_config.addIEInfo("P", ParagraphElement, null, exportParagraph, true);
				_config.addIEInfo("A", LinkElement, null, exportLink, false);
				_config.addIEInfo("TCY" /* only children exported, so name is irrelevant */, TCYElement, null, exportTCY, false);
				_config.addIEInfo("SPAN"/* only children exported, so name is irrelevant */, SpanElement, null, exportSpan, false);
				_config.addIEInfo("IMG", InlineGraphicElement, null, exportImage, false);
				_config.addIEInfo("TAB" /* exported as a span, so name is irrelevant */, TabElement, null, exportTab, false);
				_config.addIEInfo("BR", BreakElement, null, exportBreak, false);

			}
		}
		 
		/** Export text content
		 * @param source	the text to export
		 * @param conversionType 	what type to return
		 * @return Object	the exported content
		 */
		public function export(source:TextFlow, conversionType:String):Object
		{
			if (conversionType == ConversionType.STRING_TYPE)
				return exportToString(source);
			else if (conversionType == ConversionType.XML_TYPE)
				return exportToXML(source);
			return null;
		}
		
		/** Export text content as a string
		 * @param source	the text to export
		 * @return String	the exported content
		 */
		private function exportToString(textFlow:TextFlow):String
		{
			var result:String;
			// We do some careful type casting here so that leading and trailing spaces in the XML don't
			// get dropped when it is converted to a string
			var originalSettings:Object = XML.settings();
			try
			{
				XML.ignoreProcessingInstructions = false;		
				XML.ignoreWhitespace = false;
				XML.prettyPrinting = false;
				result = exportToXML(textFlow).toXMLString();
				XML.setSettings(originalSettings);
			}
			catch(e:Error)
			{
				XML.setSettings(originalSettings);
				throw(e);
			}		
			return result;
		}
		
		/** Export text content of a TextFlow into HTML format.
		 * @param source	the text to export
		 * @return XML	the exported content
		 */
		private function exportToXML(textFlow:TextFlow) : XML
		{
			var xml:XML = <BODY/>;
			
			var firstLeaf:FlowLeafElement = textFlow.getFirstLeaf();
			if (firstLeaf)
			{
				var para:ParagraphElement = firstLeaf.getParagraph();	
				var lastPara:ParagraphElement = textFlow.getLastLeaf().getParagraph();
	
				for (;;)
				{
					xml.appendChild(exportElement(para));
					if (para == lastPara)
						break;
						
					para = textFlow.findLeaf(para.getAbsoluteStart() + para.textLength).getParagraph();
				}
			}
			
			var html:XML = <HTML/>;
			html.appendChild(xml);
			
			return html;
		}
		
		/** Export a paragraph
		 * @param name name for the XML element
		 * @return XML	the populated XML element
		 */
		private function exportParagraph(name:String, para:ParagraphElement):XML
		{
			// Exported as a <P/>
			// Some paragraph-level formats (such as textAlign) are exported as attributes of <P/>, 
			// Others (such as textIndent) are exported as attributes of the <TEXTFORMAT/> parent of <P/>
			// Some character-level formats (such as fontSize) are exported as attributes of the <FONT/> child of <P/>
			// Children of the ParagraphElement are nested inside the <FONT/>
			
			var xml:XML = <{name}/>;
			
			var fontXML:XML = exportFont(para.computedFormat);
			CONFIG::debug { assert(fontXML != null, "Expect exportFont to return non-null xml if second parameter (ifDifferentFromFormat) is null"); }
			exportChildren (fontXML, para);
			nest(xml, fontXML);
			
			return exportParagraphFormat(xml, para);
		}
		
		/** Export a link
		 * @param name name for the XML element
		 * @return XML	the populated XML element
		 */
		private function exportLink(name:String, link:LinkElement):Object
		{
			// Exported as an <A/> with HREF and TARGET attributes
			// Children of the LinkElement are nested inside the <A/>
			// If the computed values of certain character-level formats differ from the corresponding computed values for the
			// containing paragraph, these are exported as attributes of a <FONT/> which (in this case) parents the <A/>.
			
			var xml:XML = <{name}/>;
			
			if (link.href)
				xml.@HREF= link.href;
			if (link.target)
				xml.@TARGET = link.target;
			else
			{
				// TextField uses _self as the default target  
				// while TLF uses null (funcionally identical to _blank). Account for this difference.
				xml.@TARGET = "_blank";
			}
						
			exportChildren(xml, link);
			
			var format:ITextLayoutFormat = link.computedFormat;
			var ifDifferentFromFormat:ITextLayoutFormat = link.getParagraph().computedFormat;
			
			var font:XML = exportFont(format, ifDifferentFromFormat);	
			return font ? nest(font, xml) : xml;
		}
		
		/** Export a tcy element
		 * @param name ignored
		 * @return XMLList the exported children
		 */
		private function exportTCY(name:String, tcy:TCYElement):XMLList
		{
			// Only children are exported
			
			var xml:XML = <{name}/>;
			exportChildren(xml, tcy);
			return xml.children();
		}
		
		static private const brRegEx:RegExp = /\u2028/;
		
		/** Gets the xml element used to represent a character in the export format
		 */
		static private function getSpanTextReplacementXML(ch:String):XML
		{
			CONFIG::debug {assert(ch == '\u2028', "Did not recognize character to be replaced with XML"); }
			return <BR/>;
		}
		
		/** Export a span
		 * @param name name for the XML element
		 * @return XML	the populated XML element
		 */
		private function exportSpan(name:String, span:SpanElement):Object
		{
			// Span text is exported as a text node (or text nodes delimited by <BR/> elements for any occurences of U+2028)
			// These text nodes and <BR/> elements are optionally nested in formatting elements
			var xml:XML  = <{name}/>; 
			BaseTextLayoutExporter.exportSpanText(xml, span, brRegEx, getSpanTextReplacementXML);
			
			// for brevity, do not export attribute-less <span> tags; export just their children
			var children:Object = xml.children();
				
			// Workaround for bug 1852072 : extraneous tags can appear around a string child added after an XML element 
			if (children.length() == 1 && children[0].nodeKind() == "text")
				children = xml.text()[0];
					
			return exportSpanFormat (children, span);
		}
		
		/** Export an inline graphic
		 * @param name name for the XML element
		 * @return XML	the populated XML element
		 */
		private function exportImage(name:String, image:InlineGraphicElement):XML
		{
			// Exported as an <IMG/> with SRC, WIDTH, HEIGHT and ALIGN attributes
			
			var xml:XML = <{name}/>;
			if (image.id)
				xml.@ID = image.id;
			if (image.source)
				xml.@SRC = image.source;
			if (image.width !== undefined && image.width != FormatValue.AUTO) 
				xml.@WIDTH = image.width;
			// xml.@WIDTH = image.actualWidth;
			if (image.height !== undefined && image.height != FormatValue.AUTO) 
				xml.@HEIGHT = image.height;
			// xml.@HEIGHT = image.actualHeight;	
			if (image.float != Float.NONE)
				xml.@ALIGN = image.float;
			return xml;
		}
	
		/** Export a break
		 * Is this ever called: BreakElements are either merged with adjacent spans or become spans? 
		 * @param name name for the XML element
		 * @return XML	the populated XML element
		 */		
		private function exportBreak(name:String, breakElement:BreakElement):XML
		{
			return <{name}/>;
		}
		
		/** Export a tab
		 * Is this ever called: TabElements are either merged with adjacent spans or become spans? 
		 * @param name ignored
		 * @return XML	the populated XML element
		 */	
		private function exportTab(name:String, tabElement:TabElement):Object
		{
			// Export as a span
			return exportSpan(name, tabElement);
		}
		
		private function exportTextFormatAttribute (textFormatXML:XML, attrName:String, attrVal:*):XML
		{
			if (!textFormatXML)
				textFormatXML = <TEXTFORMAT/>;
				
			textFormatXML.@[attrName] = attrVal;
			
			return textFormatXML;	
		}
		
		/** Exports the paragraph-level format for a paragraph  
		 * @param xml xml to decorate with attributes or add nest in formatting elements
		 * @para the paragraph
		 * @return XML	the outermost XML element after exporting 
		 */	
		private function exportParagraphFormat(xml:XML, para:ParagraphElement):XML
		{	
			var paraFormat:ITextLayoutFormat = para.computedFormat;
			
			var textAlignment:String;
			switch(paraFormat.textAlign)
			{
				case TextAlign.START:
					textAlignment = (paraFormat.direction == Direction.LTR) ? TextAlign.LEFT : TextAlign.RIGHT;
					break;
				case TextAlign.END:
					textAlignment = (paraFormat.direction == Direction.LTR) ? TextAlign.RIGHT : TextAlign.LEFT;
					break;
				default:
					textAlignment = paraFormat.textAlign;
			}
			xml.@ALIGN = textAlignment;
					
			var textFormat:XML;
			
			if (paraFormat.paragraphStartIndent != 0)
				textFormat = exportTextFormatAttribute (textFormat, paraFormat.direction == Direction.LTR ? "LEFTMARGIN" : "RIGHTMARGIN", paraFormat.paragraphStartIndent);
			
			if (paraFormat.paragraphEndIndent != 0)
				 textFormat = exportTextFormatAttribute (textFormat, paraFormat.direction == Direction.LTR ? "RIGHTMARGIN" : "LEFTMARGIN", paraFormat.paragraphEndIndent);
			
			if (paraFormat.textIndent != 0)
				textFormat = exportTextFormatAttribute(textFormat, "INDENT", paraFormat.textIndent);
				
			if (paraFormat.leadingModel == LeadingModel.APPROXIMATE_TEXT_FIELD)
			{
				var firstLeaf:FlowLeafElement = para.getFirstLeaf();
				if (firstLeaf)
				{
					var lineHeight:Number = TextLayoutFormat.lineHeightProperty.computeActualPropertyValue(firstLeaf.computedFormat.lineHeight,firstLeaf.getEffectiveFontSize());
					if (lineHeight != 0)
						textFormat = exportTextFormatAttribute(textFormat, "LEADING", lineHeight);
				}
			}
			
			var tabStops:Array = paraFormat.tabStops;
			if (tabStops)
			{
				var tabStopsString:String = "";
				for each (var tabStop:TabStopFormat in tabStops)
				{
					if (tabStop.alignment != TabAlignment.START)
						break;
					
					if (tabStopsString.length)
						tabStopsString += ", ";
					
					tabStopsString += tabStop.position;
				}
				
				if (tabStopsString.length)
					textFormat = exportTextFormatAttribute(textFormat, "TABSTOPS", tabStopsString);
			}
			
			return textFormat ? nest(textFormat, xml) : xml;
		}
		
		/** Exports the character-level format for a span  
		 * @param xml xml/xmlList to nest in formatting elements
		 * @span the span
		 * @return XML	the outermost XML element after exporting 
		 */	
		private function exportSpanFormat(xml:Object, span:SpanElement):Object
		{
			// These are optionally nested in a <FONT/> with appopriate attributes ,			 
			
			var format:ITextLayoutFormat = span.computedFormat;
			var outerElement:Object = xml;
			
			// Nest in <B/>, <I/>, or <U/> if applicable
			if (format.textDecoration.toString() == flashx.textLayout.formats.TextDecoration.UNDERLINE)
				outerElement = nest (<U/>, outerElement);
			if (format.fontStyle.toString() == flash.text.engine.FontPosture.ITALIC)
				outerElement = nest (<I/>, outerElement);
			if (format.fontWeight.toString() == flash.text.engine.FontWeight.BOLD)
				outerElement = nest (<B/>, outerElement);
				
			// Nest in <FONT/> if the computed values of certain character-level formats 
			// differ from the corresponding computed values for the containing parent that's exported
			// A span can be contained in a TCY, link, or paragraph. Of these, TCY is not exported, so only
			// check link and paragraph.
			var exportedParent:FlowElement = span.getParentByType(LinkElement);
			if (!exportedParent)
				exportedParent = span.getParagraph();
	
			var font:XML = exportFont(format, exportedParent.computedFormat);	
			if (font)
				outerElement = nest(font, outerElement);	

			return outerElement;			   	
		}	
		
		private function exportFontAttribute (fontXML:XML, attrName:String, attrVal:*):XML
		{
			if (!fontXML)
				fontXML = <FONT/>;
				
			fontXML.@[attrName] = attrVal;
			
			return fontXML;	
		}
		
		/**  
		 * Exports certain character level formats as a <FONT/> with appropriate attributes
		 * @param format format to export
		 * @param ifDifferentFromFormat if non-null, a value in format is exported only if it differs from the corresponding value in ifDifferentFromFormat
		 * @return XML	the populated XML element
		 */	
		private function exportFont(format:ITextLayoutFormat, ifDifferentFromFormat:ITextLayoutFormat=null):XML
		{
			var font:XML;
			if (!ifDifferentFromFormat || ifDifferentFromFormat.fontFamily != format.fontFamily)
				font = exportFontAttribute(font, "FACE", format.fontFamily);
			if (!ifDifferentFromFormat || ifDifferentFromFormat.fontSize != format.fontSize)
				font = exportFontAttribute(font, "SIZE", format.fontSize);
			if (!ifDifferentFromFormat || ifDifferentFromFormat.color != format.color)
			{
				var rgb:String = format.color.toString(16);
				while (rgb.length < 6) 
					rgb = "0" + rgb; // pad with leading zeros
				rgb = "#" + rgb
				font = exportFontAttribute(font, "COLOR", rgb);
			}
			if (!ifDifferentFromFormat || ifDifferentFromFormat.trackingRight != format.trackingRight)
				font = exportFontAttribute(font, "LETTERSPACING", format.trackingRight); 
			if (!ifDifferentFromFormat || ifDifferentFromFormat.kerning != format.kerning)
				font = exportFontAttribute(font, "KERNING", format.kerning == Kerning.OFF ? "0" : "1");
						
			return font;				
		}
			
		/** Exports the flow element by finding the appropriate exporter
		 * @param flowElement	Element to export
		 * @return Object	XML/XMLList for the flowElement
		 */
		private function exportElement(flowElement:FlowElement):Object
		{
			var className:String = flash.utils.getQualifiedClassName(flowElement);
			var info:FlowElementInfo = _config.lookupByClass(className);
			if (info != null)
				return info.exporter(_config.lookupName(className), flowElement);
			return null;
		}
		
		/** Exports the children of a flow group element
		 * @param xml XML to append children to
		 * @param flowGroupElement	the flow group element
		 */
		private function exportChildren(xml:XML, flowGroupElement:FlowGroupElement):void
		{
			for(var i:int=0; i < flowGroupElement.numChildren; ++i)
			{
				xml.appendChild(exportElement(flowGroupElement.getChildAt(i)));	
			}
		}
		
		/** Helper to establish a parent-child relationship between two xml elements
		 * and return the parent
		 * @param parent the intended parent
		 * @param children the intended children (XML or XMLList)
		 * @return the parent
		 */
		private function nest (parent:XML, children:Object):XML
		{
			parent.setChildren(children);
			return parent;
		}
		
 	}
}