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
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.ListItemElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	[ExcludeClass]
	/** 
	 * The ModelEdit class contains static functions for performing speficic suboperations.  Each suboperation returns a "memento" for undo/redo.
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	public class ModelEdit
	{
		public static function splitElement(textFlow:TextFlow, elemToSplit:FlowGroupElement, relativePosition:int):IMemento
		{
			return SplitMemento.perform(textFlow,elemToSplit,relativePosition,true);
		}
		
		public static function joinElement(textFlow:TextFlow, element1:FlowGroupElement, element2:FlowGroupElement):IMemento
		{
			return JoinMemento.perform(textFlow, element1, element2, true);
		}
		
		public static function addElement(textFlow:TextFlow, elemToAdd:FlowElement, parent:FlowGroupElement, index:int):IMemento
		{
			CONFIG::debug { assert(elemToAdd.parent == null,"Use moveElement"); }
			return AddElementMemento.perform(textFlow,elemToAdd,parent,index,true);
		}
		
		public static function moveElement(textFlow:TextFlow, elemToMove:FlowElement, parent:FlowGroupElement, index:int):IMemento
		{
			CONFIG::debug { assert(elemToMove.parent != null,"Use addElement"); }
			return MoveElementMemento.perform(textFlow,elemToMove,parent,index,true);
		}
		
		public static function removeElements(textFlow:TextFlow, elemtToRemoveParent:FlowGroupElement,startIndex:int, numElements:int):IMemento
		{
			return RemoveElementsMemento.perform(textFlow,elemtToRemoveParent,startIndex,numElements,true);
		}
		
		public static function deleteText(textFlow:TextFlow, absoluteStart:int, absoluteEnd:int, createMemento:Boolean):IMemento
		{
			var memento:MementoList;
			var mergePara:ParagraphElement;

			// Special case to see if the whole of the last element of the flow is selected. If so, force the terminator at the end to be deleted
			// so that if there is a list or a div at the end, it will be entirely removed.
			if (absoluteEnd == textFlow.textLength - 1)
			{
				var lastElement:FlowElement = textFlow.getChildAt(textFlow.numChildren - 1);
				if (absoluteStart <= lastElement.getAbsoluteStart())
					absoluteEnd = textFlow.textLength;
			}
			
			// Special case for when the last paragraph in the flow is deleted. We clone the last paragraph
			// before letting the delete get processed. This lets whatever hierarchy is associated with the 
			// old last paragraph die a natural death, but doesn't leave the flow with no terminator.
			var newLastParagraph:ParagraphElement;
			if (absoluteEnd >= textFlow.textLength)
			{
				var lastSpan:FlowLeafElement = textFlow.getLastLeaf();
				var lastParagraph:ParagraphElement = lastSpan.getParagraph();
				newLastParagraph = new ParagraphElement();
				var newLastSpan:SpanElement = new SpanElement();
				newLastParagraph.replaceChildren(0, 0, newLastSpan);
				newLastParagraph.format = lastParagraph.format;
				newLastSpan.format = lastSpan.format;
				absoluteEnd = textFlow.textLength;
			}

			if (createMemento)
			{
				memento = new MementoList(textFlow);
				if (newLastParagraph)
					memento.push(addElement(textFlow, newLastParagraph, textFlow, textFlow.numChildren));
				var deleteTextMemento:DeleteTextMemento = new DeleteTextMemento(textFlow, absoluteStart, absoluteEnd);
				memento.push(deleteTextMemento);
				
				mergePara = TextFlowEdit.deleteRange(textFlow, absoluteStart, absoluteEnd);
				memento.push(TextFlowEdit.joinNextParagraph(mergePara, false));
				checkNormalize(textFlow, deleteTextMemento.commonRoot, memento);
			}
			else
			{
				if (newLastParagraph)
					textFlow.replaceChildren(textFlow.numChildren, textFlow.numChildren, newLastParagraph);
				mergePara = TextFlowEdit.deleteRange(textFlow, absoluteStart, absoluteEnd);
				TextFlowEdit.joinNextParagraph(mergePara, false);
			}

			if (textFlow.interactionManager)
				textFlow.interactionManager.notifyInsertOrDelete(absoluteStart, -(absoluteEnd - absoluteStart));
			
			return memento;			
		}
		
		private static function checkNormalize(textFlow:TextFlow, commonRoot:FlowGroupElement, mementoList:MementoList):void
		{
			if ((commonRoot is ListItemElement) && (commonRoot as ListItemElement).normalizeNeedsInitialParagraph())
			{
				var paragraph:ParagraphElement = new ParagraphElement();
				paragraph.replaceChildren(0, 0, new SpanElement());
				mementoList.push(ModelEdit.addElement(textFlow, paragraph, commonRoot, 0));
			}
			for (var index:int = 0; index < commonRoot.numChildren; ++index)
			{
				var child:FlowGroupElement = commonRoot.getChildAt(index) as FlowGroupElement;
				if (child)
					checkNormalize(textFlow, child, mementoList);
			}
		}
		
		public static function saveCurrentState(textFlow:TextFlow, absoluteStart:int, absoluteEnd:int):IMemento
		{
			return new TextRangeMemento(textFlow,absoluteStart,absoluteEnd);
		}
	}
}

import flash.utils.getQualifiedClassName;

import flashx.textLayout.debug.Debugging;
import flashx.textLayout.debug.assert;
import flashx.textLayout.edit.ElementMark;
import flashx.textLayout.edit.IMemento;
import flashx.textLayout.edit.ModelEdit;
import flashx.textLayout.elements.*;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.FlowGroupElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.tlf_internal;

use namespace tlf_internal;



class BaseMemento
{
	protected var _textFlow:TextFlow;
	
	public function BaseMemento(textFlow:TextFlow)
	{ _textFlow = textFlow; }
	
	CONFIG::debug public function debugCheckTextFlow(s:String):void
	{
		trace(s);
		var saveDebugCheckTextFlow:Boolean = Debugging.debugCheckTextFlow;
		var saveVerbose:Boolean = Debugging.verbose;
		Debugging.debugCheckTextFlow = true;
		Debugging.verbose = true;
		try
		{
			_textFlow.debugCheckTextFlow(false);
		}
		finally
		{
			Debugging.debugCheckTextFlow = saveDebugCheckTextFlow;
			Debugging.verbose = saveVerbose;
		}
	}
	
}

import flashx.textLayout.conversion.ConversionType;
import flashx.textLayout.conversion.TextConverter;

// Use this for operations that undo using copy & paste
class DeleteTextMemento extends BaseMemento implements IMemento
{
	private var _commonRootMark:ElementMark;
	private var _startChildIndex:int;
	private var _endChildIndex:int;
	private var _originalChildren:Array;
	private var _absoluteStart:int;
		
	protected var scrapChildren:Array;
	protected var replaceCount:int;

	public function DeleteTextMemento(textFlow:TextFlow, absoluteStart:int, absoluteEnd:int)
	{
		super(textFlow);
		
		// Find the lowest possible common root that contains both start and end, and is at least one paragraph
		// We move the common root to the paragraph level so that we don't have to worry on undo about spans that have merged.
		var startLeaf:FlowLeafElement = textFlow.findLeaf(absoluteStart);
		//var commonRoot:FlowGroupElement = startLeaf.parent;
		var commonRoot:FlowGroupElement = startLeaf.getParagraph().parent;
		while (commonRoot && commonRoot.parent && (commonRoot.getAbsoluteStart() + commonRoot.textLength < absoluteEnd || (commonRoot.getAbsoluteStart() == absoluteStart && commonRoot.getAbsoluteStart() + commonRoot.textLength == absoluteEnd)))
			commonRoot = commonRoot.parent;
		
		// Find even element boundaries smallest amount that contains the entire range
		if (commonRoot)
		{
			var rootStart:int = commonRoot.getAbsoluteStart();
			_startChildIndex = commonRoot.findChildIndexAtPosition(absoluteStart - rootStart);
			_endChildIndex = commonRoot.findChildIndexAtPosition(absoluteEnd - rootStart - 1);
			if (_endChildIndex < 0)
				_endChildIndex = commonRoot.numChildren - 1;
			
			var startChild:FlowElement = commonRoot.getChildAt(_startChildIndex);
			var absoluteStartAdjusted:int = startChild.getAbsoluteStart();
			var endChild:FlowElement = commonRoot.getChildAt(_endChildIndex);
			var absoluteEndAdjusted:int = endChild.getAbsoluteStart() + endChild.textLength;

			// Set how many elements we expect to replace on undo. Although the delete does a merge at the end if a CR was deleted, the merge
			// (if there was one) will have been undone before DeleteTextMemento.undo() is called. 
			// Basic rule is that if there was content before the delete range in the common root, then there will be an element after the delete
			// with that content that should get replaced. Likewise for if there's content after the delete range in the common root. The exception
			// to the rule is if the common root is a grandparent of the range to be deleted, then there will be just one element getting replaced.
			replaceCount = 0;		// how many original (post-do) elements we're replacing
			if (_startChildIndex == _endChildIndex)
			{
				if (absoluteStartAdjusted < absoluteStart || absoluteEndAdjusted > absoluteEnd)	// if we're deleting the entire element, nothing to replace
					replaceCount = 1;
			}
			else
			{
				if (absoluteStartAdjusted < absoluteStart)
					replaceCount++;
				if (absoluteEndAdjusted > absoluteEnd)
					replaceCount++;
			}

			var scrapRoot:FlowGroupElement = commonRoot.deepCopy(absoluteStartAdjusted - rootStart, absoluteEndAdjusted - rootStart) as FlowGroupElement;
			scrapChildren = scrapRoot.mxmlChildren;
		}
		
		_commonRootMark = new ElementMark(commonRoot, 0);
		_absoluteStart = absoluteStart;
	}
		
	public function undo():*
	{ 
		var root:FlowGroupElement = commonRoot;
		
		// Save off the original children for later redo
		_originalChildren = [];
		for (var childIndex:int = _startChildIndex; childIndex < _startChildIndex + replaceCount; ++childIndex)
			_originalChildren.push(root.getChildAt(childIndex));
		
		// Make copies of the scrapChildren, and add the copies to the main flow
		var addToFlow:Array = [];
		for each (var element:FlowElement in scrapChildren)
			addToFlow.push(element.deepCopy());
		root.replaceChildren(_startChildIndex, _startChildIndex + replaceCount, addToFlow);
	}
	
	public function redo():*
	{ 
		commonRoot.replaceChildren(_startChildIndex, _startChildIndex + scrapChildren.length, _originalChildren);
	}
	
	public function get commonRoot():FlowGroupElement
	{
		return _commonRootMark.findElement(_textFlow) as FlowGroupElement;
	}
	
}

// Use this for operations that undo using copy & paste
class TextRangeMemento extends DeleteTextMemento implements IMemento
{
	public function TextRangeMemento(textFlow:TextFlow, absoluteStart:int, absoluteEnd:int)
	{
		super(textFlow, absoluteStart, absoluteEnd);
		replaceCount = scrapChildren.length;
	}
} 


	

class InternalSplitFGEMemento extends BaseMemento implements IMemento
{
	private var _target:ElementMark;
	private var _undoTarget:ElementMark;
	private var _newSibling:FlowGroupElement;
	private var _skipUndo:Boolean;
	
	public function InternalSplitFGEMemento(textFlow:TextFlow, target:ElementMark, undoTarget:ElementMark, newSibling:FlowGroupElement)
	{ 
		super(textFlow); 
		_target = target;
		_undoTarget = undoTarget;
		_newSibling = newSibling;
		_skipUndo = (newSibling is SubParagraphGroupElementBase);
	}
	
	public function get newSibling():FlowGroupElement
	{
		return _newSibling;
	}
	
	static public function perform(textFlow:TextFlow, elemToSplit:FlowElement, relativePosition:int, createMemento:Boolean):*
	{
		var target:ElementMark = new ElementMark(elemToSplit,relativePosition);
		var newSibling:FlowGroupElement = performInternal(textFlow, target);

		if (createMemento)
		{
			var undoTarget:ElementMark = new ElementMark(newSibling,0);
			return new InternalSplitFGEMemento(textFlow, target, undoTarget, newSibling);
		}
		else
			return newSibling;
	}
	
	static public function performInternal(textFlow:TextFlow, target:ElementMark):*
	{
		var targetElement:FlowGroupElement = target.findElement(textFlow) as FlowGroupElement;
		var childIdx:int = target.elemStart == targetElement.textLength ? targetElement.numChildren-1 : targetElement.findChildIndexAtPosition(target.elemStart);
		var child:FlowElement = targetElement.getChildAt(childIdx);
		var newSibling:FlowGroupElement;
		if (child.parentRelativeStart == target.elemStart)
			newSibling = targetElement.splitAtIndex(childIdx);
		else
			newSibling = targetElement.splitAtPosition(target.elemStart) as FlowGroupElement;
		
		if (targetElement is ParagraphElement)
		{
			if (targetElement.textLength <= 1)
			{
				targetElement.normalizeRange(0,targetElement.textLength);
				targetElement.getLastLeaf().quickCloneTextLayoutFormat(newSibling.getFirstLeaf());
			}
			else if (newSibling.textLength <= 1)
			{
				newSibling.normalizeRange(0,newSibling.textLength);
				newSibling.getFirstLeaf().quickCloneTextLayoutFormat(targetElement.getLastLeaf());
			}
		}
		// debugCheckTextFlow("After InternalSplitFGEMemento.perform");
		
		return newSibling;
		
	}
	
	public function undo():*
	{ 
		// debugCheckTextFlow("Before InternalSplitFGEMemento.undo");
		if (_skipUndo)
			return;
		
		var target:FlowGroupElement = _undoTarget.findElement(_textFlow) as FlowGroupElement;
		// move all children of target into previoussibling and delete target
		CONFIG::debug { assert(target != null,"Missing FlowGroupElement from undoTarget"); }
		var prevSibling:FlowGroupElement = target.getPreviousSibling() as FlowGroupElement;
		CONFIG::debug { assert(getQualifiedClassName(target) == getQualifiedClassName(prevSibling),"Mismatched class in InternalSplitFGEMemento"); }
		
		target.parent.removeChild(target);
		var lastLeaf:FlowLeafElement = prevSibling.getLastLeaf();
		prevSibling.replaceChildren(prevSibling.numChildren,prevSibling.numChildren,target.mxmlChildren);
		
		// paragraphs only - watch out for trailing empty spans that need to be removed
		if (prevSibling is ParagraphElement && lastLeaf.textLength == 0)
			prevSibling.removeChild(lastLeaf);
		
		// debugCheckTextFlow("After InternalSplitFGEMemento.undo");
	}
	
	public function redo():*
	{ return performInternal(_textFlow, _target ); }
}

class SplitMemento extends BaseMemento implements IMemento
{
	private var _mementoList:Array;
	private var _target:ElementMark;
	
	public function SplitMemento(textFlow:TextFlow, target:ElementMark, mementoList:Array)
	{ 
		super(textFlow); 
		_target = target;
		_mementoList = mementoList;
	}
	
	static public function perform(textFlow:TextFlow, elemToSplit:FlowGroupElement, relativePosition:int, createMemento:Boolean):*
	{
		var target:ElementMark = new ElementMark(elemToSplit,relativePosition);
		var mementoList:Array = [];

		var newChild:FlowGroupElement = performInternal(textFlow, target, createMemento ? mementoList : null);
		
		if (createMemento)
			return new SplitMemento(textFlow, target, mementoList);
		
		return newChild;
	}
	
	static private function testValidLeadingParagraph(elem:FlowGroupElement):Boolean
	{
		// listitems have to have the very first item as a paragraph
		if (elem is ListItemElement)
			return !(elem as ListItemElement).normalizeNeedsInitialParagraph();
		
		while (elem && !(elem is ParagraphElement))
			elem = elem.getChildAt(0) as FlowGroupElement;
		return elem is ParagraphElement;
	}
	
	static public function performInternal(textFlow:TextFlow, target:ElementMark, mementoList:Array):FlowGroupElement
	{
		// split all the way up the chain and then do a move
		var targetElement:FlowGroupElement = target.findElement(textFlow) as FlowGroupElement;
		var child:FlowGroupElement = (target.elemStart == targetElement.textLength ? targetElement.getLastLeaf() : targetElement.findLeaf(target.elemStart)).parent;
		var newChild:FlowGroupElement;
		
		var splitStart:int = target.elemStart;
		var memento:IMemento;
		
		for (;;)
		{
			var splitPos:int = splitStart - (child.getAbsoluteStart()-targetElement.getAbsoluteStart());
			//if (splitPos != 0)
			{
				var splitMemento:InternalSplitFGEMemento = InternalSplitFGEMemento.perform(textFlow,child,splitPos, true);
				if (mementoList)
					mementoList.push(splitMemento);
				newChild = splitMemento.newSibling;
				
				if (child is ParagraphElement && !(target.elemStart == targetElement.textLength))
				{
					// count the terminator
					splitStart++;
				}
				else if (child is ContainerFormattedElement)
				{
					// if its a ContainerFormattedElement there needs to be a paragraph at position zero on each side
					if (!testValidLeadingParagraph(child))
					{
						memento = ModelEdit.addElement(textFlow,new ParagraphElement,child,0);
						if (mementoList)
							mementoList.push(memento);
						splitStart++;
					}
					if (!testValidLeadingParagraph(newChild))
					{
						memento = ModelEdit.addElement(textFlow,new ParagraphElement,newChild,0);
						if (mementoList)
							mementoList.push(memento);
					}
				}
			}
			if (child == targetElement)
				break;
			child = child.parent;
		}
		
		return newChild;
	}
	
	public function undo():*
	{ 
		_mementoList.reverse();
		for each (var memento:IMemento in  _mementoList)
			memento.undo();
		_mementoList.reverse();
	}
	
	public function redo():*
	{ return performInternal(_textFlow, _target, null); }
}

import flashx.textLayout.edit.TextFlowEdit;

class JoinMemento extends BaseMemento implements IMemento
{
	private var _element1:ElementMark;
	private var _element2:ElementMark;
	private var _joinPosition:int;
	private var _removeParentChain:IMemento;
	
	public function JoinMemento(textFlow:TextFlow, element1:ElementMark, element2:ElementMark, joinPosition:int, removeParentChain:IMemento)
	{ 
		super(textFlow); 
		_element1 = element1;
		_element2 = element2;
		_joinPosition = joinPosition;
		_removeParentChain = removeParentChain;
	}
	
	static public function perform(textFlow:TextFlow, element1:FlowGroupElement, element2:FlowGroupElement, createMemento:Boolean):*
	{
		var joinPosition:int = element1.textLength - 1;
		
		var element1Mark:ElementMark = new ElementMark(element1,0);
		var element2Mark:ElementMark = new ElementMark(element2,0);
		performInternal(textFlow, element1Mark, element2Mark);
		var removeParentChain:IMemento = TextFlowEdit.removeEmptyParentChain(element2);

		if (createMemento)
		{
			return new JoinMemento(textFlow, element1Mark, element2Mark, joinPosition,  removeParentChain);
		}
		
		return null;
	}
	
	static public function performInternal(textFlow:TextFlow, element1Mark:ElementMark, element2Mark:ElementMark):void
	{
		var element1:FlowGroupElement = element1Mark.findElement(textFlow) as FlowGroupElement;
		var element2:FlowGroupElement = element2Mark.findElement(textFlow) as FlowGroupElement;
		
		moveChildren(element2, element1);
	}
	
	static private function moveChildren(elementSource:FlowGroupElement, elementDestination:FlowGroupElement): void
	{
		// move children of elementSource to end of elementDestination
		var childrenToMove:Array = elementSource.mxmlChildren;
		elementSource.replaceChildren(0, elementSource.numChildren);
		elementDestination.replaceChildren(elementDestination.numChildren, elementDestination.numChildren, childrenToMove);
	}
	
	public function undo():*
	{ 
		_removeParentChain.undo();
		
		var element1:FlowGroupElement = _element1.findElement(_textFlow) as FlowGroupElement;
		var element2:FlowGroupElement = _element2.findElement(_textFlow) as FlowGroupElement;
		var tmpElement:FlowGroupElement = element1.splitAtPosition(_joinPosition) as FlowGroupElement;
		// everything after the split moves to element2
		moveChildren(tmpElement, element2);
		tmpElement.parent.removeChild(tmpElement);
	}
	
	public function redo():*
	{ 
		performInternal(_textFlow, _element1, _element2);
		_removeParentChain.redo();
	}
}

class AddElementMemento extends BaseMemento implements IMemento
{
	private var _target:ElementMark;
	private var _targetIndex:int;
	private var _elemToAdd:FlowElement;
	
	public function AddElementMemento(textFlow:TextFlow, elemToAdd:FlowElement, target:ElementMark, index:int)
	{ 
		super(textFlow); 
		_target = target;
		_targetIndex = index;
		_elemToAdd = elemToAdd;
	}
	
	static public function perform(textFlow:TextFlow, elemToAdd:FlowElement, parent:FlowGroupElement, index:int, createMemento:Boolean):*
	{
		var elem:FlowElement = elemToAdd;
		if (createMemento)
			elemToAdd = elem.deepCopy();	// for redo

		var target:ElementMark = new ElementMark(parent,0);

		var targetElement:FlowGroupElement = target.findElement(textFlow) as FlowGroupElement;
		targetElement.addChildAt(index,elem);
		if (createMemento)
			return new AddElementMemento(textFlow, elemToAdd, target, index);
		return null;
	}

	public function undo():*
	{ 
		var target:FlowGroupElement = _target.findElement(_textFlow) as FlowGroupElement;
		target.removeChildAt(_targetIndex);
	}
	
	public function redo():*
	{ 
		var parent:FlowGroupElement = _target.findElement(_textFlow) as FlowGroupElement;
		return perform(_textFlow, _elemToAdd, parent, _targetIndex, false); 
	}
}

class MoveElementMemento extends BaseMemento implements IMemento
{
	private var _target:ElementMark;
	private var _targetIndex:int;
	
	private var _elemBeforeMove:ElementMark;
	private var _elemAfterMove:ElementMark;
	private var _source:ElementMark;		// original parent
	private var _sourceIndex:int; 			// original index	
	
	public function MoveElementMemento(textFlow:TextFlow, elemBeforeMove:ElementMark, elemAfterMove:ElementMark, target:ElementMark, targetIndex:int, source:ElementMark, sourceIndex:int)
	{ 
		super(textFlow); 
		_elemBeforeMove = elemBeforeMove;
		_elemAfterMove = elemAfterMove;
		_target = target;
		_targetIndex = targetIndex;
		_source = source;
		_sourceIndex = sourceIndex;
	}
	
	static public function perform(textFlow:TextFlow, elem:FlowElement, newParent:FlowGroupElement, newIndex:int, createMemento:Boolean):*
	{
		var target:ElementMark = new ElementMark(newParent,0);
		var elemBeforeMove:ElementMark = new ElementMark(elem, 0);
		
		var source:FlowGroupElement = elem.parent;
		var sourceIndex:int = source.getChildIndex(elem);
		var sourceMark:ElementMark = new ElementMark(source, 0);
		
		newParent.addChildAt(newIndex,elem);
		if (createMemento)
			return new MoveElementMemento(textFlow, elemBeforeMove, new ElementMark(elem, 0), target, newIndex, sourceMark, sourceIndex);
		return elem;
	}
	
	public function undo():*
	{ 
		var elem:FlowElement = _elemAfterMove.findElement(_textFlow);
		elem.parent.removeChildAt(elem.parent.getChildIndex(elem));
		var source:FlowGroupElement = _source.findElement(_textFlow) as FlowGroupElement;
		source.addChildAt(_sourceIndex,elem);
	}
	
	public function redo():*
	{ 
		var target:FlowGroupElement = _target.findElement(_textFlow) as FlowGroupElement;
		var elem:FlowElement = _elemBeforeMove.findElement(_textFlow) as FlowElement;
		return perform(_textFlow, elem, target, _targetIndex, false); 
	}
}

class RemoveElementsMemento extends BaseMemento implements IMemento
{
	private var _elements:Array;
	
	private var _elemParent:ElementMark;
	private var _startIndex:int;
	private var _numElements:int;
	
	/**
	* RemoveElements from the TextFlow,
	* @param parent parent of elements to rmeove
	* @param startIndex index of first child to remove
	* @param numElements number of elements to remove
	*/
	public function RemoveElementsMemento(textFlow:TextFlow, elementParent:ElementMark, startIndex:int, numElements:int, elements:Array)
	{ 
		super(textFlow); 
		_elemParent   = elementParent;
		_startIndex  = startIndex;
		_numElements = numElements;
		_elements = elements;
	}
	
	static public function perform(textFlow:TextFlow, parent:FlowGroupElement, startIndex:int, numElements:int, createMemento:Boolean):*
	{
		var elemParent:ElementMark = new ElementMark(parent,0);
		
		// hold on to elements for undo
		var elements:Array = parent.mxmlChildren.slice(startIndex, startIndex + numElements);
		// now remove them
		parent.replaceChildren(startIndex, startIndex + numElements);
		if (createMemento)
			return new RemoveElementsMemento(textFlow, elemParent, startIndex, numElements, elements);
		return elements;
	}
	
	public function undo():*
	{ 
		var parent:FlowGroupElement = _elemParent.findElement(_textFlow) as FlowGroupElement;
		parent.replaceChildren(_startIndex,_startIndex,_elements);
		_elements = null;	// release the saved elements array
		return parent.mxmlChildren.slice(_startIndex,_startIndex+_numElements);
	}
	
	public function redo():*
	{ 
		var parent:FlowGroupElement = _elemParent.findElement(_textFlow) as FlowGroupElement;
		_elements = perform(_textFlow, parent, _startIndex, _numElements, false); 
	}
}
