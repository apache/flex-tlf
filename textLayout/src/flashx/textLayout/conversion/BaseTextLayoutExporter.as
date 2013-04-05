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
	import flash.system.System;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.TextLayoutVersion;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.ContainerFormattedElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.GlobalSettings;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphFormattedElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.elements.TextRange;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.WhiteSpaceCollapse;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;
	
	[ExcludeClass]
	/** 
	 * @private 
	 * Export converter for TextLayout format. 
	 */
	internal class BaseTextLayoutExporter extends ConverterBase implements ITextExporter
	{	
		private var _config:ImportExportConfiguration;
		private var _rootTag:XML;
		private var _ns:Namespace;
				
		public function BaseTextLayoutExporter(ns:Namespace, rootTag:XML, config:ImportExportConfiguration)
		{
			_config = config;
			_ns = ns;
			_rootTag = rootTag;
		}
		
		/** @copy ITextExporter#export()
		 */
		public function export(source:TextFlow, conversionType:String):Object
		{
			clear();
			
			var result:XML = exportToXML(source);
			return conversionType == ConversionType.STRING_TYPE ? convertXMLToString(result) : result;
		}
		
		/** Export text content of a TextFlow into XFL format.
		 * @param source	the text to export
		 * @return XML	the exported content
		 */
		protected function exportToXML(textFlow:TextFlow) : XML
		{
			var result:XML;
			if (_rootTag)
			{
				result = new XML(_rootTag);
				result.addNamespace(_ns);
				result.appendChild(exportChild(textFlow));
			}
			else
			{
				result = XML(exportTextFlow(this, textFlow));
				result.addNamespace(_ns);
			}
			return result;
		}
		
		/** Export text content as a string
		 * @param xml	the XML to convert
		 * @return String	the exported content
		 * @private
		 */
		static tlf_internal function convertXMLToString(xml:XML):String
		{
			var result:String;
			// Adjust settings so that leading and trailing spaces in the XML don't get dropped when it is converted to a string
			var originalSettings:Object = XML.settings();
			try
			{
				XML.ignoreProcessingInstructions = false;		
				XML.ignoreWhitespace = false;
				XML.prettyPrinting = false;
				result = xml.toXMLString();
				if (Configuration.playerEnablesArgoFeatures)
					System["disposeXML"](xml);
				XML.setSettings(originalSettings);
			}
			catch(e:Error)
			{
				XML.setSettings(originalSettings);
				throw(e);
			}		
			return result;
		}

	
		/** Base functionality for exporting a FlowElement. 
		 * @param exporter	Root object for the export
		 * @param flowElement	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportFlowElement(exporter:BaseTextLayoutExporter, flowElement:FlowElement):XMLList
		{
			return exporter.exportFlowElement(flowElement);
		}
		
		/** Overridable worker method for exporting a FlowElement. Creates the XMLList.
		 * @param flowElement	Element to export
		 * @return XMLList	XML for the element
		 */
		protected function exportFlowElement (flowElement:FlowElement):XMLList
		{
			var className:String = flash.utils.getQualifiedClassName(flowElement);
			var elementName:String = _config.lookupName(className);	// NO PMD
			var output:XML = <{elementName}/>;
			output.setNamespace(_ns);
			return XMLList(output);
		}
		
		static public function exportSpanText(destination:XML, span:SpanElement, replacementRegex:RegExp, replacementXMLCallback:Function):void
		{
			//get the text for this span
			var spanText:String = span.text;

			// Check to see if it has text that needs to be converted			
			var matchLocation:Array = spanText.match(replacementRegex);
			
			if(matchLocation)	
			{
				var dummy:XML;
				
				// We have text that has characters to be converted. Break it up into runs of text interspersed with elements corresponding to match these characters
				while(matchLocation != null)
				{
					var ix:int = matchLocation.index;
					var tempStr:String = spanText.substr(0, ix);
					
					//if we have some text which does not need to be replaced, then write it now
					if(tempStr.length > 0)
					{
						// output[0].appendChild(tempStr); // extraneous tags can appear around a string child added after an XML element: see bug 1852072  
						
						// workaround for above-mentioned bug
						dummy = <dummy/>;
						dummy.appendChild(tempStr); // no extraneous tags here since there is no preceding XML element sibling
						destination.appendChild(dummy.text()[0]);
					}
					
					var replacementXML:XML = replacementXMLCallback(spanText.charAt(ix));
					CONFIG::debug{ assert(replacementXML != null, "Specified match regex, but provided null replacement XML"); }
					destination.appendChild(replacementXML);
					
					//remove the text up to this point
					spanText = spanText.slice(ix + 1, spanText.length);
					
					//look for another character to be replaced
					matchLocation = spanText.match(replacementRegex);
					
					//if we don't have any more matches, but there is still text, write that out as the last span
					if(!matchLocation && spanText.length > 0)
					{
						// output[0].appendChild(spanText); // extraneous tags can appear around a string child added after an XML element: see bug 1852072  
						
						// workaround for above-mentioned bug
						dummy = <dummy/>;
						dummy.appendChild(spanText); // no extraneous tags here since there is no preceding XML element sibling
						destination.appendChild(dummy.text()[0]);
					}
				}
			}
			else
			{
				//this is the simple case where we don't have a character to replace
				destination.appendChild(spanText);
			}		
		}  
		
		/** Base functionality for exporting a Span. Exports as a FlowElement,
		 * and exports the text of the span.
		 * @param exporter	Root object for the export
		 * @param span	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportSpan(exporter:BaseTextLayoutExporter, span:SpanElement):XMLList
		{
			var output:XMLList = exportFlowElement(exporter, span);	
			exportSpanText(output[0], span, exporter.spanTextReplacementRegex, exporter.getSpanTextReplacementXML);
			return output;
		}
		
		static private const brRegEx:RegExp = /\u2028/;
		
		/** Gets the regex that specifies characters in span text to be replaced with XML elements
		 *  Note: Each match is a single character 
		 */
		protected function get spanTextReplacementRegex():RegExp
		{
			return brRegEx;
		}

		/** Gets the xml element used to represent a character in the export format
		 */
		protected function getSpanTextReplacementXML(ch:String):XML
		{
			CONFIG::debug {assert(ch == '\u2028', "Did not recognize character to be replaced with XML"); }
			var breakXML:XML = <br/>;
			breakXML.setNamespace(flowNS);
			return breakXML;
		}
		
		/** Base functionality for exporting a FlowGroupElement. Exports as a FlowElement,
		 * and exports the children of a element.
		 * @param exporter	Root object for the export
		 * @param flowBlockElement	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportFlowGroupElement(exporter:BaseTextLayoutExporter, flowBlockElement:FlowGroupElement):XMLList
		{
			var output:XMLList = exportFlowElement(exporter, flowBlockElement);
			
			// output each child
			for(var childIter:int = 0; childIter < flowBlockElement.numChildren; ++childIter)
			{
				var flowChild:FlowElement = flowBlockElement.getChildAt(childIter);
				var childXML:XMLList = exporter.exportChild(flowChild);
				if (childXML)
					output.appendChild(childXML);
			}
			return output;
		}

		/** Base functionality for exporting a ParagraphFormattedElement. Exports as a FlowGroupElement,
		 * and exports paragraph attributes.
		 * @param exporter	Root object for the export
		 * @param flowParagraph	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportParagraphFormattedElement(exporter:BaseTextLayoutExporter, flowParagraph:ParagraphFormattedElement):XMLList
		{
			return exporter.exportParagraphFormattedElement(flowParagraph);
		}
		
		/** Overridable worker method for exporting a ParagraphFormattedElement. Creates the XMLList.
		 * @param flowElement	Element to export
		 * @return XMLList	XML for the element
		 */
		protected function exportParagraphFormattedElement(flowElement:FlowElement):XMLList
		{
			var rslt:XMLList = exportFlowElement(flowElement);
			// output each child
			for(var childIter:int = 0; childIter < ParagraphFormattedElement(flowElement).numChildren; ++childIter)
			{
				var flowChild:FlowElement = ParagraphFormattedElement(flowElement).getChildAt(childIter);
				rslt.appendChild(exportChild(flowChild));
			}
			return rslt;
		}
		
		static public function exportList(exporter:BaseTextLayoutExporter, flowParagraph:ParagraphFormattedElement):XMLList
		{
			return exporter.exportList(flowParagraph);
		}
		
		protected function exportList(flowElement:FlowElement):XMLList
		{
			var rslt:XMLList = exportFlowElement(flowElement);
			// output each child
			for(var childIter:int = 0; childIter < FlowGroupElement(flowElement).numChildren; ++childIter)
			{
				var flowChild:FlowElement = FlowGroupElement(flowElement).getChildAt(childIter);
				rslt.appendChild(exportChild(flowChild));
			}
			return rslt;
		}
		
		static public function exportListItem(exporter:BaseTextLayoutExporter, flowParagraph:ParagraphFormattedElement):XMLList
		{
			return exporter.exportListItem(flowParagraph);
		}
		
		protected function exportListItem(flowElement:FlowElement):XMLList
		{
			var rslt:XMLList = exportFlowElement(flowElement);
			// output each child
			for(var childIter:int = 0; childIter < FlowGroupElement(flowElement).numChildren; ++childIter)
			{
				var flowChild:FlowElement = FlowGroupElement(flowElement).getChildAt(childIter);
				rslt.appendChild(exportChild(flowChild));
			}
			return rslt;
		}
		
		/** Base functionality for exporting a ContainerFormattedElement. Exports as a ParagraphFormattedElement,
		 * and exports container attributes.
		 * @param exporter	Root object for the export
		 * @param container	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportContainerFormattedElement(exporter:BaseTextLayoutExporter, container:ContainerFormattedElement):XMLList
		{
			return exporter.exportContainerFormattedElement(container);
		}
		
		/** Overridable worker method for exporting a ParagraphFormattedElement. Creates the XMLList.
		 * @param flowElement	Element to export
		 * @return XMLList	XML for the element
		 */
		protected function exportContainerFormattedElement(flowElement:FlowElement):XMLList
		{
			return exportParagraphFormattedElement(flowElement);
		}

		/** Base functionality for exporting a TextFlow. Exports as a ContainerElement,
		 * and exports container attributes.
		 * @param exporter	Root object for the export
		 * @param textFlow	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportTextFlow(exporter:BaseTextLayoutExporter, textFlow:TextFlow):XMLList
		{
			var output:XMLList = exportContainerFormattedElement(exporter, textFlow);
			
			// TextLayout will use PRESERVE on output
			output.@[TextLayoutFormat.whiteSpaceCollapseProperty.name] = WhiteSpaceCollapse.PRESERVE;
			
			// TextLayout adds version information
			output.@["version"] = TextLayoutVersion.getVersionString(TextLayoutVersion.CURRENT_VERSION);
						
			return output;
		}


		/** Exports the object. It will find the appropriate exporter and use it to 
		 * export the object.
		 * @param exporter	Root object for the export
		 * @param flowElement	Element to export
		 * @return XMLList	XML for the flowElement
		 */
		public function exportChild(flowElement:FlowElement):XMLList
		{
			var className:String = flash.utils.getQualifiedClassName(flowElement);
			var info:FlowElementInfo = _config.lookupByClass(className);
			if (info != null)
				return info.exporter(this, flowElement);
			return null;
		}
					
		/** Helper function to export styles (core or user) in the form of xml attributes or xml children
		 * @param xml object to which attributes/children are added 
		 * @param sortableStyles an array of objects (xmlName,xmlVal) members that is sorted and exported.
		 */
		protected function exportStyles(xml:XMLList, sortableStyles:Array):void
		{
			// Sort the styles based on name for predictable export order
			sortableStyles.sortOn("xmlName");
			
			for each(var exportInfo:Object in sortableStyles)
            {
            	var xmlVal:Object = exportInfo.xmlVal;
				CONFIG::debug{ assert(useClipboardAnnotations || exportInfo.xmlName != ConverterBase.MERGE_TO_NEXT_ON_PASTE, "Found paste merge attribute in exported TextFlow"); }
				/* Filter out paste attributes */
				if (!useClipboardAnnotations && exportInfo.xmlName == ConverterBase.MERGE_TO_NEXT_ON_PASTE)
					continue;
            	if (xmlVal is String)
					xml.@[exportInfo.xmlName] = xmlVal; // as an attribute
				else if (xmlVal is XMLList)
					xml.appendChild(xmlVal);			// as a child 
            }  
		}

		internal function get flowNS():Namespace
		{
			return _ns;
		}

		protected function get formatDescription():Object
		{
			return null;
		}		

	}
}
