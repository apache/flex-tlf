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
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.edit.TextFlowEdit;
	import flashx.textLayout.edit.TextScrap;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormatValueHolder;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	/**
	 * The DeleteTextOperation class encapsulates the deletion of a range of text.
	 *
	 * @see flashx.textLayout.edit.EditManager
	 * @see flashx.textLayout.events.FlowOperationEvent
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
	 */
	public class DeleteTextOperation extends FlowTextOperation
	{
		private var _textScrap:TextScrap;
		private var _allowMerge:Boolean;
		private var _undoParaFormat:TextLayoutFormatValueHolder;
		private var _undoCharacterFormat:TextLayoutFormatValueHolder;
		private var _needsOldFormat:Boolean = false;
		private var _pendingFormat:TextLayoutFormatValueHolder;
		
		private var _deleteSelectionState:SelectionState = null;
		/** 
		 * Creates a DeleteTextOperation operation.
		 * 
		 * @param operationState The original range of text.
		 * @param deleteSelectionState The range of text to delete, if different from the range 
		 * described by <code>operationState</code>. (Set to <code>null</code> to delete the range
		 * described by <code>operationState</code>.)
		 * @param allowMerge Set to <code>true</code> if this operation can be merged with the next or previous operation.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 */
		public function DeleteTextOperation(operationState:SelectionState, deleteSelectionState:SelectionState = null, allowMerge:Boolean = false)
		{
			_deleteSelectionState = deleteSelectionState ? deleteSelectionState : operationState;				
			
			super(_deleteSelectionState);
			originalSelectionState = operationState;
			_allowMerge = allowMerge;
		}
		
		/** 
		 * Indicates whether this operation can be merged with operations executed before or after it.
		 * 
		 * <p>Some delete operations, for example, a sequence of backspace keystrokes, can be fruitfully 
		 * merged into one operation so that undoing the operation reverses the entire sequence.</p>
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		*/
		public function get allowMerge():Boolean
		{
			return _allowMerge;
		}
		public function set allowMerge(value:Boolean):void
		{
			_allowMerge = value;
		}
		
		/** 
		 * deleteSelectionState The range of text to delete
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
		
		/** @private */
		public override function doOperation():Boolean
		{
			// Nothing to delete
			if (absoluteStart == absoluteEnd)
				return false;
				
			_textScrap = TextFlowEdit.createTextScrap(textFlow, absoluteStart, absoluteEnd);
			var leafEl:FlowLeafElement = textFlow.findLeaf(absoluteStart);
			var paraEl:ParagraphElement = leafEl.getParagraph(); 
			var paraElAbsStart:int = paraEl.getAbsoluteStart();
			
			_pendingFormat = new TextLayoutFormatValueHolder(leafEl.format);
						
			if (_textScrap)
			{
				if ((_textScrap.textFlow.textLength == 1) && 
						((absoluteEnd == (textFlow.textLength - 1)) || (absoluteEnd == (paraElAbsStart + paraEl.textLength))))
			 	{
					//special case. Always insert the paragraph
					_textScrap.beginMissingArray = new Array();
					_textScrap.endMissingArray = new Array();
			 	}
			 	
			 	if (_textScrap.textFlow.textLength >= 1)
			 	{
					//save off the paragraph format of the next paragraph since we will need to set it back
					//on an undo operation					
					leafEl = textFlow.findLeaf(absoluteEnd);
					paraEl = leafEl.getParagraph();
					if (absoluteEnd == paraEl.getAbsoluteStart())
					{
						_undoParaFormat = new TextLayoutFormatValueHolder(paraEl.format);
						_undoCharacterFormat = new TextLayoutFormatValueHolder(leafEl.format);
						_needsOldFormat = true;
					}
				}
			} 
			
			var beforeOpLen:int = textFlow.textLength;
			TextFlowEdit.replaceRange(textFlow, absoluteStart, absoluteEnd, null);
			if (textFlow.interactionManager)
				textFlow.interactionManager.notifyInsertOrDelete(absoluteStart, -(absoluteEnd - absoluteStart));
			
			if (originalSelectionState.selectionManagerOperationState && textFlow.interactionManager)
			{
				// set pointFormat from leafFormat
				var state:SelectionState = textFlow.interactionManager.getSelectionState();
				if (state.anchorPosition == state.activePosition)
				{
					state.pointFormat = new TextLayoutFormatValueHolder(_pendingFormat);
					textFlow.interactionManager.setSelectionState(state);
				}
			}

			// nothing deleted???
			if (beforeOpLen == textFlow.textLength)
				_textScrap = null;
			return true;	
		}
		
		/** @private */
		public override function undo():SelectionState
		{
			if (_textScrap != null) {
				TextFlowEdit.replaceRange(textFlow, absoluteStart, absoluteStart, _textScrap);
				if (_needsOldFormat)
				{
					textFlow.normalize();
					var leafEl:FlowLeafElement = textFlow.findLeaf(absoluteEnd);
					if (leafEl)
					{
						var paraEl:ParagraphElement = leafEl.getParagraph();
						paraEl.format = _undoParaFormat;
						leafEl.format = _undoCharacterFormat; 
					}
					
				}
				if (textFlow.interactionManager)
					textFlow.interactionManager.notifyInsertOrDelete(absoluteStart, absoluteEnd - absoluteStart);
			}
			return originalSelectionState;				
		}
	
		/** @private */
		public override function redo():SelectionState
		{
			TextFlowEdit.replaceRange(textFlow, absoluteStart, absoluteEnd, null);			
			if (textFlow.interactionManager)
				textFlow.interactionManager.notifyInsertOrDelete(absoluteStart, -(absoluteEnd - absoluteStart));
			return new SelectionState(textFlow,absoluteStart,absoluteStart,_pendingFormat);	
		}

		/** @private */
		tlf_internal override function merge(op2:FlowOperation):FlowOperation
		{
			if (this.endGeneration != op2.beginGeneration)
					return null;
			var delOp:DeleteTextOperation = op2 as DeleteTextOperation;
			if ((delOp == null) || !delOp.allowMerge || !_allowMerge)
				return null;
				
			return new CompositeOperation([this, op2]);
		}	
	}
}
