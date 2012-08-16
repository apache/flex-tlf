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
	import flashx.textLayout.elements.BreakElement;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TabElement;
	import flashx.textLayout.elements.TextFlow;

	/** Configure for import/export of standard components.
	 * Configures the import/export package so it can export all the standard FlowElements. 
	 * @see flashx.textLayout.elements.Configuration
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	internal class ImportExportConfiguration 
	{
		/** array of FlowElementInfo objects (key = name, value = FlowElementInfo) */	
		private var flowElementInfoList:Object;	

		/** Constructor.
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
		 */
		public function ImportExportConfiguration()
		{
		}
		
		/** Add a parser for a new FlowElement type. This allows FlowElements to be added from outside the main system,
		 * and still have the main system be able to import them from XML.
		 * @param name		the name of the FlowElement class, as it appear in the XML
		 * @param flowClass	the class of the FlowElement
		 * @param parser	a function capable of parsing the XML into the flow element
		 * @param	isParagraphFormattedElement Boolean indicating if this class is a subclass of ParagraphFormattedElement
		 * @private - this should really be tf_internal
		 */
		public function addIEInfo(name:String, flowClass:Class, parser:Function, exporter:Function, isParagraphFormattedElement:Boolean):void
		{
			if (flowElementInfoList == null)
				flowElementInfoList = new Object();
			CONFIG::debug { assert (lookup(name) == null, "FlowElementInfo already exists");}
			flowElementInfoList[name] = new FlowElementInfo(flowClass, parser, exporter, isParagraphFormattedElement);
		}
		
		/** @private */
		public function overrideIEInfo(name:String, flowClass:Class, parser:Function, exporter:Function):void
		{
			if (flowElementInfoList == null)
				flowElementInfoList = new Object();
			
			CONFIG::debug { assert (lookup(name) != null, "FlowElementInfo doesn't already exist");}
			flowElementInfoList[name].flowClass = flowClass;
			flowElementInfoList[name].parser = parser;
			flowElementInfoList[name].exporter = exporter;
		}
		
		/** Return the information being held about the FlowElement, as a FlowElementInfo.
		 * @param name				the name of the FlowElement class, as it appears in the XML
		 * @return FlowElementInfo	the information being held, as it was supplied to addParseInfo
		 * @private
		 */
		public function lookup(name:String):FlowElementInfo
		{
			return flowElementInfoList ? flowElementInfoList[name] : null;
		}

		/** Return the element name for the class
		 * @param classToMatch		fully qualified class name of the FlowElement
		 * @return name				export name to use for class
		 * @private
		 */
		public function lookupName(classToMatch:String):String
		{
			for (var name:String in flowElementInfoList)
			{
				if (flowElementInfoList[name].flowClassName == classToMatch)
					return name;
			}
			return null;
		}

		/** Return the information being held about the FlowElement, as a FlowElementInfo.
		 * @param classToMatch		fully qualified class name of the FlowElement
		 * @return FlowElementInfo	the information being held, as it was supplied to addParseInfo
		 * @private
		 */
		public function lookupByClass(classToMatch:String):FlowElementInfo
		{
			for (var name:String in flowElementInfoList)
			{
				if (flowElementInfoList[name].flowClassName == classToMatch)
					return flowElementInfoList[name];
			}
			return null;
		}
	}
}
