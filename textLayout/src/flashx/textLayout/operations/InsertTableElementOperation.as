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
	import flashx.textLayout.edit.ElementMark;
	import flashx.textLayout.edit.ElementRange;
	import flashx.textLayout.edit.MementoList;
	import flashx.textLayout.edit.ModelEdit;
	import flashx.textLayout.edit.PointFormat;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.TableElement;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	public class InsertTableElementOperation extends FlowTextOperation
	{
		private var delSelOp:DeleteTextOperation; 
		private var _table:TableElement;
		private var selPos:int = 0;
		private var _mementoList:MementoList;
		private var _postOpSelectionState:SelectionState;
		private var _listParentMarker:ElementMark;
		
		public function InsertTableElementOperation(operationState:SelectionState, table:TableElement)
		{
			super(operationState);
			
			_mementoList = new MementoList(operationState.textFlow);
			_table = table;
		}
		
		/** @private */
		public override function doOperation():Boolean
		{
			var pointFormat:ITextLayoutFormat;
			
			selPos = absoluteStart;
			if (absoluteStart != absoluteEnd) 
			{
				var leafEl:FlowLeafElement = textFlow.findLeaf(absoluteStart);
				var deleteFormat:PointFormat = new PointFormat(textFlow.findLeaf(absoluteStart).format);
				
				_mementoList.push(ModelEdit.deleteText(textFlow,absoluteStart,absoluteEnd,true));
				pointFormat = deleteFormat;
			}
			else
				pointFormat = originalSelectionState.pointFormat;
			
			
			var target:FlowGroupElement = textFlow;
			
			var begStart:int = absoluteStart;
			var begChildIndex:int = 0;
			var endChildIndex:int;
			
			// scratch vars
			var child:FlowGroupElement;
			
			if(begStart >= 0)
			{
				// figure out the starting child
				begChildIndex = target.findChildIndexAtPosition(begStart);
				child = target.getChildAt(begChildIndex) as FlowGroupElement;
				_mementoList.push(ModelEdit.splitElement(textFlow,child,begStart-child.parentRelativeStart));
			}
			
			if (begStart >= target.textLength - 1)
				endChildIndex = target.numChildren;
			else
				endChildIndex = begChildIndex+1;
			
			
			if (begChildIndex == target.numChildren)
			{
				// new list at the end of target
				child = target.getChildAt(target.numChildren-1) as FlowGroupElement;
				
				_mementoList.push(ModelEdit.addElement(textFlow,_table,target,target.numChildren));
			}
			else
			{
				_mementoList.push(ModelEdit.addElement(textFlow,_table,target,endChildIndex));
			}
			
			if (originalSelectionState.selectionManagerOperationState && textFlow.interactionManager)
			{
				textFlow.normalize();
				_postOpSelectionState = new SelectionState(textFlow,_table.getAbsoluteStart(),_table.getAbsoluteStart()+_table.textLength-1);
				textFlow.interactionManager.setSelectionState(_postOpSelectionState);
			}
			
			return true;
		}
		
		/** @private */
		public override function undo():SelectionState
		{
			_mementoList.undo();
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
			_mementoList.redo();
			return _postOpSelectionState;
		}
	}
}