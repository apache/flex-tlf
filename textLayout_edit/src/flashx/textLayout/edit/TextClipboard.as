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
package flashx.textLayout.edit
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	
	import flashx.textLayout.conversion.*;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;
		
	use namespace tlf_internal;

	/**
	 * The TextClipboard class copies and pastes TextScrap objects to and from the system clipboard.
	 * 
	 * <p>When you copy a TextScrap to the TextClipboard, the information is copied to the
	 * system clipboard in two clipboard formats. One format is an XML string expressing the copied 
	 * TextScrap object in Text Layout Markup syntax. This clipboard object uses the format name: 
	 * "TEXT_LAYOUT_MARKUP". The second format is a plain-text string, which uses the standard 
	 * Clipboard.TEXT_FORMAT name.</p>
	 * 
	 * <p>The methods of the TextClipboard class are static functions, you do not need to
	 * create an instance of TextClipboard.</p>  
	 * 
	 * @see flash.desktop.Clipboard
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	*/
	public class TextClipboard
	{	
		/** @private */
		static tlf_internal const TEXT_LAYOUT_MARKUP:String = "TEXT_LAYOUT_MARKUP";
		
		/** @private */
		static tlf_internal function getTextOnClipboardForFormat(format:String):String
		{
			var systemClipboard:Clipboard = Clipboard.generalClipboard;
			return (systemClipboard.hasFormat(format)) ? String(systemClipboard.getData(format)) : null;
		}
		
		/**
		 * Gets any text on the system clipboard as a TextScrap object.
		 *  
		 * <p>If the "TEXT_LAYOUT_MARKUP" format is available, this method converts the formatted
		 * string into a TextScrap and returns it. Otherwise, if the Clipboard.TEXT_Format is available,
		 * this method converts the plain-text string into a TextScrap. If neither clipboard format
		 * is available, this method returns <code>null</code>.</p>
		 * 
		 * <p>Flash Player requires that the <code>getContents()</code> method be called in a paste event handler. In AIR, 
		 * this restriction only applies to content outside of the application security sandbox.</p>
		 * 
		 * @see flash.events.Event#PASTE
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 */										
		public static function getContents():TextScrap
		{
			var retTextScrap:TextScrap = null;
			var textFlow:TextFlow;
			var textOnClipboard:String;
			
			// first look for text_layout_markup
			textOnClipboard = getTextOnClipboardForFormat(TEXT_LAYOUT_MARKUP);
			
			if ((textOnClipboard != null) && (textOnClipboard != ""))
			{
				var originalSettings:Object = XML.settings();
				try {
					XML.ignoreProcessingInstructions = false;
					XML.ignoreWhitespace = false;
					var xmlTree:XML = new XML(textOnClipboard);
					var beginArrayChild:XML = xmlTree..*::BeginMissingElements[0];
					var endArrayChild:XML = xmlTree..*::EndMissingElements[0];
					var textLayoutMarkup:XML = xmlTree..*::TextFlow[0];
					
					textFlow = TextConverter.importToFlow(textLayoutMarkup, TextConverter.TEXT_LAYOUT_FORMAT);
					
					if (textFlow != null)
					{
						retTextScrap = new TextScrap(textFlow);
						retTextScrap.beginMissingArray = getBeginArray(beginArrayChild, textFlow);
						retTextScrap.endMissingArray = getEndArray(endArrayChild, textFlow);
					}
				}
				finally
				{
					XML.setSettings(originalSettings);
				}			
			}
			
			// if there is no retTextScrap let's get the text_format and try that
			if (retTextScrap == null)
			{
				textOnClipboard = getTextOnClipboardForFormat(ClipboardFormats.TEXT_FORMAT);

				if (textOnClipboard != null && textOnClipboard != "")
				{
					textFlow = TextConverter.importToFlow(textOnClipboard, TextConverter.PLAIN_TEXT_FORMAT);
					if (textFlow)
					{
						retTextScrap = new TextScrap(textFlow);
						var firstLeaf:FlowLeafElement = textFlow.getFirstLeaf();
						if (firstLeaf)
						{
							retTextScrap.beginMissingArray.push(firstLeaf);
							retTextScrap.beginMissingArray.push(firstLeaf.parent);
							retTextScrap.beginMissingArray.push(textFlow);
							
							var lastLeaf:FlowLeafElement = textFlow.getLastLeaf();
							retTextScrap.endMissingArray.push(lastLeaf);
							retTextScrap.endMissingArray.push(lastLeaf.parent);
							retTextScrap.endMissingArray.push(textFlow);
						}
					}
				}
			}
			return retTextScrap;
		}
		
		/** @private */
		tlf_internal static function createTextFlowExportString(scrap:TextScrap):String
		{
			var textFlowExportString:String = "";
			var originalSettings:Object = XML.settings();
			try
			{
				XML.ignoreProcessingInstructions = false;		
				XML.ignoreWhitespace = false;
				XML.prettyPrinting = false;
					
				var exporter:ITextExporter = TextConverter.getExporter(TextConverter.TEXT_LAYOUT_FORMAT);
				var result:String = '<?xml version="1.0" encoding="utf-8"?>\n';
				result += "<TextScrap>\n";
				result += getPartialElementString(scrap);
				
				var xmlExport:XML = exporter.export(scrap.textFlow, ConversionType.XML_TYPE) as XML;
				result += xmlExport;
				result += "</TextScrap>\n";				
				textFlowExportString = result.toString();
				XML.setSettings(originalSettings);
			}				
			catch(e:Error)
			{
				XML.setSettings(originalSettings);
			}
			return textFlowExportString;
		}
		
		/** @private */
		tlf_internal static function createPlainTextExportString(scrap:TextScrap):String
		{
			// At some point, import/export filters will be installable. We want our clipboard fomat to be
			// predictable, so we explicitly use the PlainTextExporter 
			// var plainTextExporter:ITextExporter = TextConverter.getExporter(TextConverter.PLAIN_TEXT_FORMAT);
			var plainTextExporter:PlainTextExporter = new PlainTextExporter();
			var plainTextExportString:String = plainTextExporter.export(scrap.textFlow, ConversionType.STRING_TYPE) as String;
			
			// The plain text exporter does not append the paragraph separator after the last paragraph
			// When putting text on the clipboard, the last paragraph should get a separator if it was 
			// copied through its end, i.e., if its end is not missing 
			var lastPara:ParagraphElement = scrap.textFlow.getLastLeaf().getParagraph();
			if (!scrap.isEndMissing(lastPara))
				plainTextExportString += plainTextExporter.paragraphSeparator;
			return plainTextExportString;
		}
		
		/** @private */
		tlf_internal static function setClipboardContents(textFlowExportString:String,plainTextExportString:String):void
		{	
			var systemClipboard:Clipboard = Clipboard.generalClipboard;
			systemClipboard.clear();
			systemClipboard.setData(TEXT_LAYOUT_MARKUP, textFlowExportString);
			systemClipboard.setData(ClipboardFormats.TEXT_FORMAT, plainTextExportString);
		}
		/**
		 * Puts a TextScrap onto the system clipboard.  
		 * 
		 * <p>The TextScrap is placed onto the system clipboard as both a Text Layout Markup
		 * representation and a plain text representation.</p>
		 * 
		 * <p>Flash Player requires a user event (such as a key press or mouse click) before 
		 * calling <code>setContents()</code>. In AIR, this restriction only applies to content outside of 
		 * the application security sandbox. </p>
		 * 
		 * @param scrap The TextScrap to paste into the clipboard.
		 * 
		 * @see flash.events.Event#COPY
		 * @see flash.events.Event#CUT
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
 		 */										
		public static function setContents(scrap:TextScrap):void
		{
			if (scrap == null) 
				return;
			var textFlowExportString:String = createTextFlowExportString(scrap);
			var plainTextExportString:String = createPlainTextExportString(scrap);
			setClipboardContents(textFlowExportString,plainTextExportString);
		}
		
		private static function getPartialElementString(scrap:TextScrap):String
		{
			var beginMissingArray:Array = scrap.beginMissingArray;
			var endMissingArray:Array = scrap.endMissingArray;
			var beginMissingString:String = "";
			var endMissingString:String = "";
			var resultString:String = "";
			
			var curPos:int = beginMissingArray.length - 2;
			var curFlElement:FlowElement;
			var curFlElementIndex:int;
			
			if (beginMissingArray.length > 0)
			{
				beginMissingString = "0";
				while (curPos >= 0)
				{
					curFlElement = beginMissingArray[curPos];
					curFlElementIndex = curFlElement.parent.getChildIndex(curFlElement);
					beginMissingString = beginMissingString + "," + curFlElementIndex;
					curPos--;
				}
			}
			
			curPos = endMissingArray.length - 2;
			if (endMissingArray.length > 0)
			{
				endMissingString = "0";
				
				while (curPos >= 0)
				{
					curFlElement = endMissingArray[curPos];
					curFlElementIndex = curFlElement.parent.getChildIndex(curFlElement);
					endMissingString = endMissingString + "," + curFlElementIndex;
					curPos--;					
				}
			}
			
			if (beginMissingString != "")
			{
				resultString = '<BeginMissingElements value="';
				resultString += beginMissingString;
				resultString += '"';
				resultString += '/>\n';
			}
			
			if (endMissingString != "")
			{
				resultString += '<EndMissingElements value="';
				resultString += endMissingString;
				resultString += '"';
				resultString += '/>\n';				
			}
			return resultString;
		}
		
		private static function getBeginArray(beginArrayChild:XML, textFlow:TextFlow):Array
		{
			var beginArray:Array = new Array();
			var curFlElement:FlowElement = textFlow;
			if (beginArrayChild != null)
			{
				var value:String = (beginArrayChild.@value != undefined) ? String(beginArrayChild.@value) : "";
				beginArray.push(textFlow);
				var posOfComma:int = value.indexOf(",");
				var startPos:int;
				var endPos:int;
				var curStr:String;
				var indexIntoFlowElement:int;
				while (posOfComma >= 0)
				{
					startPos = posOfComma + 1;
					posOfComma = value.indexOf(",", startPos);
					if (posOfComma >= 0)
					{
						endPos = posOfComma;
					} else {
						endPos = value.length;
					}
					curStr = value.substring(startPos, endPos);
					if (curStr.length > 0)
					{
						indexIntoFlowElement = parseInt(curStr);
						if (curFlElement is FlowGroupElement)
						{
							curFlElement = (curFlElement as FlowGroupElement).getChildAt(indexIntoFlowElement);
							beginArray.push(curFlElement);
						}
					}
				}				
			}
			return beginArray.reverse();
		}
		
		private static function getEndArray(endArrayChild:XML, textFlow:TextFlow):Array
		{
			var endArray:Array = new Array();
			var curFlElement:FlowElement = textFlow;
			if (endArrayChild != null)
			{
				var value:String = (endArrayChild.@value != undefined) ? String(endArrayChild.@value) : "";
				endArray.push(textFlow);
				var posOfComma:int = value.indexOf(",");
				var startPos:int;
				var endPos:int;
				var curStr:String;
				var indexIntoFlowElement:int;
				while (posOfComma >= 0)
				{
					startPos = posOfComma + 1;
					posOfComma = value.indexOf(",", startPos);
					if (posOfComma >= 0)
					{
						endPos = posOfComma;
					} else {
						endPos = value.length;
					}
					curStr = value.substring(startPos, endPos);
					if (curStr.length > 0)
					{
						indexIntoFlowElement = parseInt(curStr);
						if (curFlElement is FlowGroupElement)
						{
							curFlElement = (curFlElement as FlowGroupElement).getChildAt(indexIntoFlowElement);
							endArray.push(curFlElement);
						}
					}
				}				
			}
			return endArray.reverse();
		}

		
	} // end TextClipboard class
}

class TextClipboardSingletonEnforcer {}
