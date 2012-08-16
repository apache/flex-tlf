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
	import flashx.textLayout.elements.ParagraphFormattedElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
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
		private static var nameCounter:int = 0;
		static private var _formatDescription:Object= TextLayoutFormat.description;

		private var queuedExport:Object = null;
		
		public function TextLayoutExporter()
		{
			super(new Namespace("http://ns.adobe.com/textLayout/2008"), null, TextLayoutImporter.defaultConfiguration);
		}
		
		override protected function clear():void
		{
			nameCounter = 0;
			queuedExport = null;
		}
		
		/** Export text content of a TextFlow into TextLayout format.
		 * @param source	the text to export
		 * @return XML	the exported content
		 */
		protected override function exportToXML(textFlow:TextFlow) : XML
		{
			var result:XML = super.exportToXML(textFlow);
			var queuedXML:XMLList = exportQueuedObjects();
			if (queuedXML)
				result.appendChild(queuedXML);
			return result;
		}
		
		private function exportQueuedObjects():XMLList
		{
			if (!queuedExport)
				return null;
			
			// pump out the queued objects
			var result:XMLList = new XMLList();
			for  (var idName:String in queuedExport) {
				var objectToExport:Object = queuedExport[idName];
				var output:XMLList = new XMLList();
				if (objectToExport is FlowValueHolder) {
					var characterFormatXML:XML = new XML("<format/>");
					characterFormatXML.setNamespace(flowNS);
					output += characterFormatXML;
					output.@id = idName;
					exportStyles(output, objectToExport.coreStyles, formatDescription);
					exportStyles(output, objectToExport.userStyles);
				}
				result += output;
			}
			return result;
		}
		
		/** Get additional objects that are required for export
		 * The subject may have dependent objects that will need to be exported, in addition
		 * to the subject itself.
		 * @return XML	array of Objects to export
		 */
		private function queueForExport(object:Object, name:String):void
		{
			if (!queuedExport)
				queuedExport = new Object();
				
			queuedExport[name] = object;
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
		
		protected override function exportFlowElement(flowElement:FlowElement):XMLList
		{
			var rslt:XMLList = super.exportFlowElement(flowElement);
			
			var coreStyles:Object = flowElement.coreStyles;
			if (coreStyles)
			{
				// WhiteSpaceCollapse attribute should never be exported (except on TextFlow -- handled separately)
				delete coreStyles[TextLayoutFormat.whiteSpaceCollapseProperty.name];
				exportStyles(rslt, coreStyles, formatDescription);
			}
			
			// export id and styleName
			if (flowElement.id != null)
				rslt.@["id"] = flowElement.id;
			if (flowElement.styleName != null)
				rslt.@["styleName"] = flowElement.styleName;
			// export any user defined styles
			var styles:Object = flowElement.userStyles;
			if (styles)
				exportStyles(rslt, styles);
				
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
			// FUTURE!!! output.@float = image.float;
						
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
		
		/** Base functionality for exporting a TCYElement. Exports as a FlowGroupElement
		 * @param exporter	Root object for the export
		 * @param tcy	Element to export
		 * @return XMLList	XML for the element
		 */
		static public function exportTCY(exporter:BaseTextLayoutExporter, tcy:TCYElement):XMLList
		{
			return exportFlowGroupElement(exporter, tcy);
		}
		
		/** Queues the object for export later, generates an ID for it, and returns
		 * the ID.
		 * @param exporter	Root object for the export
		 * @param obj	Element to export
		 * @return String	ID of the object
		 */
		static private function exportToName(exporter:BaseTextLayoutExporter, obj:Object):String
		{
			var newName:String = "ObjectID" + nameCounter.toString();
			TextLayoutExporter(exporter).queueForExport(obj, newName);
			nameCounter++;
			return newName;
		}
		
		override protected function get formatDescription():Object
		{
			return _formatDescription;
		}		

	}
}
