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
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.elements.TextRange;
	import flashx.textLayout.edit.TextFlowEdit;
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
		private var _beginMissingArray:Array;
		private var _endMissingArray:Array;

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
			_beginMissingArray = new Array();
			_endMissingArray = new Array();
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
			return TextFlowEdit.createTextScrap(range.textFlow, range.absoluteStart, range.absoluteEnd);
		}
		
		/** @private
		 * Gets the TextFlow that is currently in the TextScrap.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */												
		tlf_internal function get textFlow():TextFlow
		{
			return _textFlow;
		}
		
		/**
		 * @private
		 * 
		 * Indicates whether the specified FlowElement has it's beginning part missing.
		 */												
		tlf_internal function isBeginMissing(fl:FlowElement):Boolean
		{
			var arrLen:int = _beginMissingArray.length;
			var currPos:int = 0;
			while (currPos < arrLen)
			{
				if (_beginMissingArray[currPos] == fl)
				{
					return true;
				}
				currPos++;
			}
			return false;
		}
		
		/**
		 * @private
		 * 
		 * Indicates whether the specified FlowElement has it's end part missing.
		 */												
		tlf_internal function isEndMissing(fl:FlowElement):Boolean
		{
			var arrLen:int = _endMissingArray.length;
			var currPos:int = 0;
			while (currPos < arrLen)
			{
				if (_endMissingArray[currPos] == fl)
				{
					return true;
				}
				currPos++;
			}
			return false;			
		}

		/**
		 * @private
		 * 
		 * Indicates that the specified FlowElement has it's beginning part missing.
		 */														
		tlf_internal function addToBeginMissing(fl:FlowElement):void
		{
			_beginMissingArray.push(fl);
		}

		/**
		 * @private
		 * 
		 * Indicates that the specified FlowElement has it's end part missing.
		 */																
		tlf_internal function addToEndMissing(fl:FlowElement):void
		{
			_endMissingArray.push(fl);			
		}

		/**
		 * @private
		 * 
		 * Returns all the FlowElements in the TextFlow that have their beginning
		 * parts missing.
		 */																		
		tlf_internal function get beginMissingArray():Array
		{
			return _beginMissingArray;
		}

		/**
		 * @private
		 * 
		 * Returns all the FlowElements in the TextFlow that have their ending
		 * parts missing.
		 */																				
		tlf_internal function get endMissingArray():Array
		{
			return _endMissingArray;
		}

		/**
		 * @private
		 * 
		 * Sets an array of FlowElements that are missing their
		 * beginning parts in this TextFlow.
		 */																						
		tlf_internal function set beginMissingArray(arr:Array):void
		{
			_beginMissingArray = arr;
		}	

		/**
		 * Sets an array of FlowElements that are missing their
		 * ending parts in this TextFlow.
		 * @private
		 */																						
		tlf_internal function set endMissingArray(arr:Array):void
		{	
			_endMissingArray = arr;
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
			var t:TextFlow = textFlow.deepCopy() as TextFlow;
			var newTextScrap:TextScrap = new TextScrap(t);
			
			var beginMissingArray:Array = _beginMissingArray;
			var endMissingArray:Array = _endMissingArray;
			
			var curPos:int = beginMissingArray.length - 2;
			var curFlElement:FlowElement;
			var curFlElementIndex:int;
			var newFlowElement:FlowElement = newTextScrap.textFlow;
			
			if (beginMissingArray.length > 0)
			{
				var newBeginArray:Array = new Array();
				newBeginArray.push(newFlowElement);
				while (curPos >= 0)
				{
					curFlElement = beginMissingArray[curPos];
					curFlElementIndex = curFlElement.parent.getChildIndex(curFlElement);
					if (newFlowElement is FlowGroupElement)
					{
						newFlowElement = (newFlowElement as FlowGroupElement).getChildAt(curFlElementIndex);
						newBeginArray.push(newFlowElement);
					}
					curPos--;
				}
				newTextScrap.beginMissingArray = newBeginArray;
			}
			
			curPos = endMissingArray.length - 2;
			newFlowElement = newTextScrap.textFlow;
			if (endMissingArray.length > 0)
			{
				var newEndArray:Array = new Array();
				newEndArray.push(newFlowElement);
				while (curPos >= 0)
				{
					curFlElement = endMissingArray[curPos];
					curFlElementIndex = curFlElement.parent.getChildIndex(curFlElement);
					if (newFlowElement is FlowGroupElement)
					{
						newFlowElement = (newFlowElement as FlowGroupElement).getChildAt(curFlElementIndex);
						newEndArray.push(newFlowElement);
					}
					curPos--;					
				}
				newTextScrap.endMissingArray = newEndArray;
			}
			return newTextScrap;
		}

	} // end TextScap class
} // end package
