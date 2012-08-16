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
package flashx.textLayout.operations
{
	import flashx.textLayout.edit.ElementRange;
	import flashx.textLayout.edit.ParaEdit;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;


	/**
	 * The InsertTextOperation class encapsulates a text insertion operation.
	 *
	 * @see flashx.textLayout.edit.EditManager
	 * @see flashx.textLayout.events.FlowOperationEvent
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
	 */
	public class InsertTextOperation extends FlowTextOperation
	{
		private var _deleteSelectionState:SelectionState;
		private var delSelOp:DeleteTextOperation = null; 
		/** @private - this should be private but too late for code changes on Labs */
		public var _text:String;
		private var adjustedForInsert:Boolean = false;
		
		private var _characterFormat:ITextLayoutFormat;
			
		/** 
		 * Creates an InsertTextOperation object.
		 * 
		 * @param operationState Describes the insertion point or range of text.
		 * @param text The string to insert.
		 * @param deleteSelectionState Describes the range of text to delete before doing insertion, 
		 * if different than the range described by <code>operationState</code>.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 */	
		public function InsertTextOperation(operationState:SelectionState, text:String, deleteSelectionState:SelectionState = null)
		{
			super(operationState);
			
			_characterFormat = operationState.pointFormat;
			_text = text;
			
			initialize(deleteSelectionState);
		}
		
		private function initialize(deleteSelectionState:SelectionState):void
		{	
			if (deleteSelectionState == null)
				deleteSelectionState = originalSelectionState;
			if (deleteSelectionState.anchorPosition != deleteSelectionState.activePosition)
			{
				_deleteSelectionState = deleteSelectionState;
				delSelOp = new DeleteTextOperation(_deleteSelectionState);
			}
		}
		
		/** 
		 * The text inserted by this operation. 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		*/
		public function get text():String
		{
			return _text;
		}
		public function set text(value:String):void
		{
			_text = value;
		}
		
		/** 
		 * The text deleted by this operation, if any.
		 * 
		 * <p><code>null</code> if no text is deleted.</p>
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		*/
		public function get deleteSelectionState():SelectionState
		{
			return _deleteSelectionState;
		}
		public function set deleteSelectionState(value:SelectionState):void
		{
			_deleteSelectionState = value;
		}
		
		/** 
		 * The character format applied to the inserted text.
		 *  
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		*/
		public function get characterFormat():ITextLayoutFormat
		{
			return _characterFormat;
		}
		public function set characterFormat(value:ITextLayoutFormat):void
		{
			_characterFormat = new TextLayoutFormat(value);
		}
		
		private function doInternal():void
		{
			var leafEl:FlowLeafElement = textFlow.findLeaf(absoluteStart);
			var tcyEl:TCYElement = null;
			
			if(leafEl is InlineGraphicElement && leafEl.parent is TCYElement)
			{
				tcyEl = leafEl.parent as TCYElement;
			}
			
			if (delSelOp != null) {	
				var deleteFormat:ITextLayoutFormat = new TextLayoutFormat(textFlow.findLeaf(absoluteStart).format);
				if (delSelOp.doOperation())		// figure out what to do here
				{
					//do not change characterFormat if user specified one already
					if ((characterFormat == null) && (absoluteStart < absoluteEnd))
					{
						_characterFormat = deleteFormat;
					} 
					else 
					{
						if (leafEl.textLength == 0) 
						{
							var pos:int = leafEl.parent.getChildIndex(leafEl);
							leafEl.parent.replaceChildren(pos, pos + 1, null);
						}
					}
					
					if(tcyEl && tcyEl.numChildren == 0)
					{
						leafEl = new SpanElement();
						tcyEl.replaceChildren(0,0,leafEl);
					}
				} 
			} 
			
			// Wasteful, but it gives us the leanLeft logic for insert - which we only want to do if this is a point selection.
			
			var range:ElementRange;
			var useExistingLeaf:Boolean = false;
			// favor using leaf we have if it's valid (i.e., it has a paragraph in its parent chain and it is still inside a TextFlow)
			if (absoluteStart >= absoluteEnd || leafEl.getParagraph() == null || leafEl.getTextFlow() == null)
			{
				range = ElementRange.createElementRange(textFlow,absoluteStart, absoluteStart);
			}
			else
			{
				range = new ElementRange();
				range.firstParagraph = leafEl.getParagraph();
				range.firstLeaf = leafEl;
				useExistingLeaf = true;
			}
			var paraSelBegIdx:int = absoluteStart-range.firstParagraph.getAbsoluteStart();
			
			// force insert to use the leaf given if we have a good one
			ParaEdit.insertText(range.firstParagraph, range.firstLeaf, paraSelBegIdx, _text, useExistingLeaf);
			if (textFlow.interactionManager)
				textFlow.interactionManager.notifyInsertOrDelete(absoluteStart, _text.length);
			
			if (_characterFormat && !TextLayoutFormat.isEqual(_characterFormat, range.firstLeaf.format))
				ParaEdit.applyTextStyleChange(textFlow,absoluteStart,absoluteStart+_text.length,_characterFormat,null);
		}
		
		/** @private */
		public override function doOperation():Boolean
		{
			doInternal();
			if (originalSelectionState.selectionManagerOperationState && textFlow.interactionManager)
			{
				var state:SelectionState = textFlow.interactionManager.getSelectionState();
				if (state.pointFormat)
				{
					state.pointFormat = null;
					textFlow.interactionManager.setSelectionState(state);
				}
			}
			return true;
		}
	
		/** @private */
		public override function undo():SelectionState
		{ 
			var para:ParagraphElement = textFlow.findAbsoluteParagraph(absoluteStart);
			// paragraph relative offset - into the store
			var paraSelBegIdx:int = absoluteStart-para.getAbsoluteStart();

			ParaEdit.deleteText(para, paraSelBegIdx, _text.length);
			if (textFlow.interactionManager)
				textFlow.interactionManager.notifyInsertOrDelete(absoluteStart, -_text.length);
			
			var newSelectionState:SelectionState = originalSelectionState;
			if (delSelOp != null)
			{
				newSelectionState = delSelOp.undo();
			}
			
			if (adjustedForInsert)
			{
				var newBegIdx:int = newSelectionState.anchorPosition;
				var newEndIdx:int = newSelectionState.activePosition;
				if (newEndIdx > newBegIdx) newEndIdx--;
				else newBegIdx--;
				
				if (absoluteStart < absoluteEnd)
				{
					return new SelectionState(textFlow, newBegIdx, newEndIdx, newSelectionState.pointFormat);
				}
				else
				{
					return new SelectionState(textFlow, newBegIdx, newEndIdx, originalSelectionState.pointFormat);
				}
			}
			return originalSelectionState;
		}
		
		/**
		 * Re-executes the operation after it has been undone.
		 * 
		 * <p>This function is called by the edit manager, when necessary.</p>
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 */
		public override function redo():SelectionState
		{ 
			doInternal();
			return new SelectionState(textFlow,absoluteStart+_text.length,absoluteStart+_text.length,null);
		}

		/** @private */
		tlf_internal override function merge(op2:FlowOperation):FlowOperation
		{
			if (absoluteStart < absoluteEnd)
				return null;
			if (this.endGeneration != op2.beginGeneration)
				return null;
			// We are assuming here that these operations are contiguous, because
			// SelectionManager doesn't try to merge operations if the selection
			// has changed
			var insertOp:InsertTextOperation = null;
			if (op2 is InsertTextOperation)
				insertOp = op2 as InsertTextOperation;
			if (insertOp)
			{
				if (insertOp.deleteSelectionState != null || deleteSelectionState != null)
					return null;
				if ((insertOp.originalSelectionState.pointFormat == null) && (originalSelectionState.pointFormat != null))
					return null;
				if ((originalSelectionState.pointFormat == null) && (insertOp.originalSelectionState.pointFormat != null))
					return null;
				if (originalSelectionState.absoluteStart + _text.length != insertOp.originalSelectionState.absoluteStart)
					return null;
				if (((originalSelectionState.pointFormat == null) && (insertOp.originalSelectionState.pointFormat == null)) ||
					(TextLayoutFormat.isEqual(originalSelectionState.pointFormat, insertOp.originalSelectionState.pointFormat)))
					_text += insertOp.text;
				else
					return null;
				setGenerations(beginGeneration,insertOp.endGeneration);
				return this;
			}
			
			if (op2 is SplitParagraphOperation)
				return new CompositeOperation([this,op2]);

			return null;
		}
	}
}