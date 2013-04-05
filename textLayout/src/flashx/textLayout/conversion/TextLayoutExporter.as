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
	import flash.utils.Dictionary;
	
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.ContainerFormattedElement;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowValueHolder;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ListElement;
	import flashx.textLayout.elements.ParagraphFormattedElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.ListMarkerFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.WhiteSpaceCollapse;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	[ExcludeClass]
	/** 
	 * @private
	 * Export filter for TextLayout format. 
	 */
	internal class TextLayoutExporter extends BaseTextLayoutExporter
	{	
		static private var _formatDescription:Object= TextLayoutFormat.description;

		public function TextLayoutExporter()
		{
			super(new Namespace("http://ns.adobe.com/textLayout/2008"), null, TextLayoutImporter.defaultConfiguration);
		}
		
		static private const brTabRegEx:RegExp = new RegExp("[" + "\u2028" + "\t" + "]"); // Doesn't /\u2028\t/ work?
		
		/** Gets the regex that specifies characters to be replaced with XML elements
		 *  Note: Each match is a single character 
		 */
		protected override function get spanTextReplacementRegex():RegExp
		{
			return brTabRegEx;
		}
		
		/** Gets the xml element used to represent a character in the export format
		 */
		protected override function getSpanTextReplacementXML(ch:String):XML
		{
			var replacementXML:XML;
			if (ch == '\u2028')
				replacementXML = <br/>;
			else if (ch == '\t')
				replacementXML = <tab/>;
			else
			{
				CONFIG::debug {assert(false, "Did not recognize character to be replaced with XML"); }
				return null;			
			}
		
			replacementXML.setNamespace(flowNS);
			return replacementXML;	
		}
		
		/** Helper function to export styles (core or user) in the form of xml attributes or xml children
		 * @private
		 */
		tlf_internal function createStylesFromDescription(styles:Object, description:Object, includeUserStyles:Boolean, exclusions:Array):Array
		{
			var sortableStyles:Array = [];
			for (var key:String in styles)
			{
				var val:Object = styles[key];
				if (exclusions && exclusions.indexOf(val) != -1)
					continue;
				
				var prop:Property = description[key];
				if (!prop)
				{
					if (includeUserStyles)
					{
						// User style
						if ((val is String) || val.hasOwnProperty("toString"))
						{
							// Is or can be converted to a String which will be used as an XML attribute value
							sortableStyles.push({xmlName:key, xmlVal:val});
						}						
					}
				}
				else if (val is TextLayoutFormat)
				{
					// A style dictionary; Will be converted to an XMLList containing elements to be added as children 
					var customDictProp:XMLList = exportObjectAsTextLayoutFormat(key,(val as TextLayoutFormat).getStyles());
					if (customDictProp)
						sortableStyles.push({xmlName:key, xmlVal:customDictProp});
				}
				else
					sortableStyles.push({xmlName:key, xmlVal:prop.toXMLString(val)});		
			}
			return sortableStyles;  
		}
		
		tlf_internal function exportObjectAsTextLayoutFormat(key:String,styleDict:Object):XMLList
		{
			// link attributes and ListMarkerFormat
			var elementName:String;
			var description:Object;
			if (key == LinkElement.LINK_NORMAL_FORMAT_NAME || key == LinkElement.LINK_ACTIVE_FORMAT_NAME || key == LinkElement.LINK_HOVER_FORMAT_NAME)
			{
				elementName = "TextLayoutFormat";
				description = TextLayoutFormat.description;
			}
			else if (key == ListElement.LIST_MARKER_FORMAT_NAME)
			{
				elementName = "ListMarkerFormat";
				description = ListMarkerFormat.description;
			}
			
			if (elementName == null)
				return null;
				
			// create the  element
			var formatXML:XML = <{elementName}/>;
			formatXML.setNamespace(flowNS);
			var sortableStyles:Array = createStylesFromDescription(styleDict, description, true, null);
			exportStyles(XMLList(formatXML), sortableStyles);
			
			// create the link format element
			var propertyXML:XMLList = XMLList(<{key}/>);
			propertyXML.appendChild(formatXML);
			return propertyXML;
		}
			
		protected override function exportFlowElement(flowElement:FlowElement):XMLList
		{
			var rslt:XMLList = super.exportFlowElement(flowElement);
			
			var allStyles:Object = flowElement.styles;
			if (allStyles)
			{
				// WhiteSpaceCollapse attribute should never be exported (except on TextFlow -- handled separately)
				delete allStyles[TextLayoutFormat.whiteSpaceCollapseProperty.name];
				// To prevent "inherit" from getting exported for the root node, comment in the following line, and remove the one after that (only need one call to exportStyles
				var sortableStyles:Array = createStylesFromDescription(allStyles,formatDescription,true,flowElement.parent ? null : [FormatValue.INHERIT]);
				exportStyles(rslt, sortableStyles );
			}
			
			// export id and styleName
			if (flowElement.id != null)
				rslt.@["id"] = flowElement.id;
			if (flowElement.typeName != flowElement.defaultTypeName)
				rslt.@["typeName"] = flowElement.typeName;
				
			return rslt;
		}

		/** Base functionality for exporting an Image. Exports as a FlowElement,
		 * and exports image properties.
		 * @param exporter	Root object for the export
		 * @param image	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportImage(exporter:BaseTextLayoutExporter, image:InlineGraphicElement):XMLList
		{
			var output:XMLList = exportFlowElement(exporter, image);
			
			// output the img specific values
			if (image.height !== undefined)
				output.@height = image.height;
			if (image.width !== undefined)
				output.@width = image.width;
		//	output.@rotation = image.rotation;  don't support rotation yet
			if (image.source != null)
				output.@source = image.source;
			if (image.float != undefined)
				output.@float = image.float;
						
			return output;
		}

		/** Base functionality for exporting a LinkElement. Exports as a FlowGroupElement,
		 * and exports link properties.
		 * @param exporter	Root object for the export
		 * @param link	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportLink(exporter:BaseTextLayoutExporter, link:LinkElement):XMLList
		{
			var output:XMLList = exportFlowGroupElement(exporter, link);

			if (link.href)
				output.@href= link.href;
				
			if (link.target)
				output.@target = link.target;
				
			return output;
		}
		
		/** Base functionality for exporting a DivElement. Exports as a FlowContainerFormattedElement
		 * @param exporter	Root object for the export
		 * @param div	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportDiv(exporter:BaseTextLayoutExporter, div:DivElement):XMLList
		{
			return exportContainerFormattedElement(exporter, div);
		}
		
		/** Base functionality for exporting a SubParagraphGroupElement. Exports as a FlowGroupElement
		 * @param exporter	Root object for the export
		 * @param elem	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportSPGE(exporter:BaseTextLayoutExporter, elem:SubParagraphGroupElement):XMLList
		{
			return exportFlowGroupElement(exporter, elem);
		}
		/** Base functionality for exporting a TCYElement. Exports as a FlowGroupElement
		 * @param exporter	Root object for the export
		 * @param tcy	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportTCY(exporter:BaseTextLayoutExporter, tcy:TCYElement):XMLList
		{
			return exportFlowGroupElement(exporter, tcy);
		}
		
		override protected function get formatDescription():Object
		{
			return _formatDescription;
		}		

	}
}
