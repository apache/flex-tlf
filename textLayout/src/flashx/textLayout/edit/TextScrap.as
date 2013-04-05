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
	import flashx.textLayout.conversion.ConverterBase;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.elements.TextRange;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	/**
	 * The TextScrap class represents a fragment of a text flow.
	 * 
	 * <p>A TextScrap is a holding place for all or part of a TextFlow. A range of text can be copied 
	 * from a TextFlow into a TextScrap, and pasted from the TextScrap into another TextFlow.</p>
	 *
	 * @see flashx.textLayout.elements.TextFlow
	 * @see flashx.textLayout.edit.SelectionManager
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	*/	
	public class TextScrap
	{	
		private var _textFlow:TextFlow;
		private var _plainText:int;		/* flag to tell if text in scrap is plain or formatted: -1 = unknown, 0 = false, 1 = true

		// These are duplicates of same entries in TextConverter, here to avoid dragging in more code caused by compiler bug.
		// Remove this when http://bugs.adobe.com/jira/browse/ASC-4092 is fixed. 
		/** @private */
		static tlf_internal const MERGE_TO_NEXT_ON_PASTE:String = "mergeToNextOnPaste";
		
		/**
		 * Creates a TextScrap object.
		 * 
		 * <p>Use the <code>createTextScrap()</code> method to create a TextScrap object from
		 * a range of text represented by a TextRange object.</p>
		 *  
		 * @param textFlow if set, the new TextScrap object contains the entire text flow.
		 * Otherwise, the TextScrap object is empty.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */												
		public function TextScrap(textFlow:TextFlow = null)
		{
			_textFlow = textFlow;
			_textFlow.flowComposer = null;	// no flowcomposer in a TextScrap
			_plainText = -1;
		}

		/**
		 * Creates a TextScrap object from a range of text represented by a TextRange object.
		 * 
		 * @param range the TextRange object representing the range of text to copy.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		public static function createTextScrap(range:TextRange):TextScrap
		{
			var startPos:int = range.absoluteStart;
			var endPos:int = range.absoluteEnd;
			var theFlow:TextFlow = range.textFlow;
			
			if (!theFlow || startPos >= endPos) 
				return null;
			var newTextFlow:TextFlow = theFlow.deepCopy(startPos, endPos) as TextFlow;
			newTextFlow.normalize();
			var retTextScrap:TextScrap = new TextScrap(newTextFlow);
			if (newTextFlow.textLength > 0)
			{
				var fl:FlowElement = newTextFlow.getLastLeaf();
				
				var srcElem:FlowElement = theFlow.findLeaf(endPos - 1);
				var copyElem:FlowElement = newTextFlow.getLastLeaf();
				if ((copyElem is SpanElement) && (!(srcElem is SpanElement)))
					copyElem = newTextFlow.findLeaf(newTextFlow.textLength - 2);
				
				while (copyElem && srcElem)
				{
					if (endPos < srcElem.getAbsoluteStart() + srcElem.textLength)
						copyElem.setStyle(MERGE_TO_NEXT_ON_PASTE, "true");
					copyElem = copyElem.parent;
					srcElem = srcElem.parent;
				}
				return retTextScrap;
			}
			return null;
		}
		
		/** 
		 * Gets the TextFlow that is currently in the TextScrap.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */												
		public function get textFlow():TextFlow
		{
			return _textFlow;
		}
		
		/**
		 * Creates a duplicate copy of this TextScrap object.
		 * 
		 * @return TextScrap A copy of this TextScrap.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		public function clone():TextScrap
		{
			return new TextScrap(textFlow.deepCopy() as TextFlow);
		}

		/** Marks the TextScrap's content as being either plain or formatted */
		tlf_internal function setPlainText(plainText:Boolean):void
		{
			_plainText = plainText ? 0 : 1;
		}
		
		/** 
		 * Returns true if the text is plain text (not formatted)
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */												
		tlf_internal function isPlainText():Boolean
		{
			var foundAttributes:Boolean = false;
			
			if (_plainText == -1)
			{
				for (var i:int = _textFlow.numChildren - 1; i >= 0; --i)
					_textFlow.getChildAt(i).applyFunctionToElements(isPlainElement);
				_plainText = foundAttributes ? 1 : 0;
			}
			return _plainText == 0;
			
			function isPlainElement(element:FlowElement):Boolean
			{
				if (!(element is ParagraphElement) && !(element is SpanElement))
				{
					foundAttributes = true;
					return true;
				}
				var styles:Object = element.styles;
				if (styles)
				{
					for (var prop:String in styles)
					{
						if (prop != ConverterBase.MERGE_TO_NEXT_ON_PASTE)
						{
							foundAttributes = true;
							return true;		// stops iteration
						}
					}
				}
				return false;
			}
		}
	} // end TextScrap class
} // end package
