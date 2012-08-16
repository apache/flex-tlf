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
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.edit.ParaEdit;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.tlf_internal;


	use namespace tlf_internal;


	/**
	 * The SplitParagraphOperation class encapsulates a change that splits a paragraph into two elements.
	 *
	 * <p>The operation creates a new paragraph containing the text from 
	 * the specified position to the end of the paragraph. If a range of text is specified, the text 
	 * in the range is deleted first.</p>
	 * 
	 * @see flashx.textLayout.elements.ParagraphElement
	 * @see flashx.textLayout.edit.EditManager
	 * @see flashx.textLayout.events.FlowOperationEvent
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
	 */			
	public class SplitParagraphOperation extends FlowTextOperation
	{
		private var delSelOp:DeleteTextOperation;
		private var _characterFormat:ITextLayoutFormat;
		
		/** 
		 * Creates a SplitParagraphOperation object.
		 * 
		 * @param operationState Describes the point at which to split the paragraph.
		 * If a range of text is specified, the contents of the range are deleted.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 */
		function SplitParagraphOperation(operationState:SelectionState)
		{
			super(operationState);
			characterFormat = operationState.pointFormat;
		}
		
		/** 
		 * The format applied to the new empty paragraph when a paragraph is split at the end.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 */
		private function get characterFormat():ITextLayoutFormat
		{
			return _characterFormat;
		}
		private function set characterFormat(value:ITextLayoutFormat):void
		{
			_characterFormat = value ? new TextLayoutFormat(value) : null;
		}
		
		/** @private */
		public override function doOperation():Boolean
		{ 
			if (absoluteStart < absoluteEnd)
			{
				delSelOp = new DeleteTextOperation(originalSelectionState);
				delSelOp.doOperation();
			}
			
			var para:ParagraphElement = textFlow.findAbsoluteParagraph(absoluteStart);
			
			// paragraph relative offset - into the store
			var paraSelBegIdx:int = absoluteStart-para.getAbsoluteStart();
			
			var nextPara:ParagraphElement = ParaEdit.splitParagraph(para, paraSelBegIdx, _characterFormat);
			if (textFlow.interactionManager)
				textFlow.interactionManager.notifyInsertOrDelete(absoluteStart, 1);

			// splitParagraph guarantees these exist
			var lastParaLeaf:FlowLeafElement = para.getLastLeaf(); 
			if (lastParaLeaf != null && lastParaLeaf.textLength == 1)
			{
				//if the lastParaLeaf is only a newline, you really want the span right before
				var elementIdx:int = lastParaLeaf.parent.getChildIndex(lastParaLeaf);
				if (elementIdx > 0)
				{
					var prevSpan:SpanElement = lastParaLeaf.parent.getChildAt(elementIdx - 1) as SpanElement;
					if (prevSpan != null) lastParaLeaf = prevSpan;
				}
			}
			
			var firstNextParaLeaf:FlowLeafElement = nextPara.getFirstLeaf();
			
			var newCharAttrs:TextLayoutFormat; // Point format for new selection position
			if (getQualifiedClassName(lastParaLeaf.parent) != getQualifiedClassName(firstNextParaLeaf.parent))
			{
				// Reset it; no easy way to migrate point format when parent types differ
				newCharAttrs = new TextLayoutFormat();
			} 
			else
			{
				// 1. Convert to absolute (position-independent) value by concatenating with the actual attribute of para's last leaf
				newCharAttrs = new TextLayoutFormat(_characterFormat);
				
				if (nextPara.textLength == 1)
				{
					//we have a completely new paragraph.  Just append on the character
					//attributes of the last leaf and stop.
					if (lastParaLeaf.format != null)
					{
						newCharAttrs.concat(lastParaLeaf.format);
					}
				}
				else
				{
					newCharAttrs.concat(lastParaLeaf.computedFormat);
					
					// 2. Convert to a relative value (dependent on the new position) by removing attributes 
					// that match the actual  attributes of nextPar's first leaf 
					newCharAttrs.removeMatching(firstNextParaLeaf.computedFormat);
				}
			}		

			return true;
		}
	
		/** @private */
		public override function undo():SelectionState
		{ 
			var para:ParagraphElement = textFlow.findAbsoluteParagraph(absoluteStart);
			ParaEdit.mergeParagraphWithNext(para);
			if (textFlow.interactionManager)
				textFlow.interactionManager.notifyInsertOrDelete(absoluteStart, -1);
			
			return absoluteStart < absoluteEnd ? delSelOp.undo() : originalSelectionState;
		}
		
		/** @private */
		tlf_internal override function merge(operation:FlowOperation):FlowOperation
		{
			if (this.endGeneration != operation.beginGeneration)
				return null;
			// TODO we could probably do something a bit more efficient for a backspace
			if ((operation is SplitParagraphOperation) || (operation is InsertTextOperation))
				return new CompositeOperation([this,operation]);
			return null;
		}
	}
}