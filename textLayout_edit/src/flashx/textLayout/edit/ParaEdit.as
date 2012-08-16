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
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormatValueHolder;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	[ExcludeClass]
	/**
	 * Encapsulates all methods necessary for dynamic editing of a text.  The methods are all static member functions of this class.
	 * @private - because we can't make it tlf_internal. Used by the operations package 
	 */
 	public class ParaEdit
	{
		/**
		 * Inserts text into specified paragraph
		 * @param p		ParagraphElement to insert into
		 * @param paraSelBegIdx	index relative to beginning of the paragraph to insert text
		 * @param leanBack  at an attribute change boundary are we on the left or the right
		 * @param text	actual text to insert 
		 * @param forceIntoLeafGiven	flag to suppress creation of new leaf element during insert (useful for type-to-replace)
		 */
		public static function insertText(para:ParagraphElement, elem:FlowLeafElement, paraSelBegIdx:int,insertText:String, forceIntoLeafGiven:Boolean = false):void
		{
			if (insertText.length == 0)
				return;	// error? other sanity checks needed here?
				
			var createNewSpan:Boolean = false;
			var insertParent:FlowGroupElement = elem.parent;
			
			var curSPGElement:SubParagraphGroupElement = elem.getParentByType(SubParagraphGroupElement) as SubParagraphGroupElement;
			while (curSPGElement != null)
			{
				var subParInsertionPoint:int = paraSelBegIdx - curSPGElement.getElementRelativeStart(para);
				if (((subParInsertionPoint == 0) && (!curSPGElement.acceptTextBefore())) ||
					((!curSPGElement.acceptTextAfter() && (subParInsertionPoint == curSPGElement.textLength || 
					(subParInsertionPoint == curSPGElement.textLength - 1 && (elem == para.getLastLeaf()))))))
				{
					createNewSpan = !forceIntoLeafGiven;
					insertParent = insertParent.parent;
					curSPGElement = curSPGElement.getParentByType(SubParagraphGroupElement) as SubParagraphGroupElement;
				} else {
					break;
				}
			}
				
			// adjust the flow so that we are in a span for the insertion
			if ((!(elem is SpanElement)) || (createNewSpan == true))
			{
				var newSpan:SpanElement;	// scratch
				var insertIdx:int;	// scratch
				
				// if were not in a span then we must be at the beginning or end of some other FlowLeafElement.  
				// go to prev or next and use if it is a span.  add a span if needed.
				var paraRelativeStart:int = elem.getElementRelativeStart(para);
				CONFIG::debug{ assert(paraRelativeStart == paraSelBegIdx || paraRelativeStart+elem.textLength == paraSelBegIdx || paraRelativeStart+elem.textLength - 1 == paraSelBegIdx,"selection inside non-SpanElement Leaf"); }
				if (paraRelativeStart == paraSelBegIdx)
				{
					elem = elem.getPreviousLeaf(para);
					if (!(elem is SpanElement))
					{
						newSpan = new SpanElement();
						if (elem)
						{
							newSpan.format = elem.format;
							insertIdx = insertParent.getChildIndex(elem)+1;
						}
						else
						{
							newSpan.format = para.getFirstLeaf().format;
							insertIdx = 0;
						}
						insertParent.replaceChildren(insertIdx,insertIdx,newSpan);
						elem = newSpan;
					}
				}
				else
				{
					newSpan = new SpanElement();
					newSpan.format = elem.format;
					if(elem.parent == insertParent)
						insertIdx = insertParent.getChildIndex(elem)+1;
					else
						insertIdx = insertParent.getChildIndex(elem.parent)+1;
						
					insertParent.replaceChildren(insertIdx,insertIdx,newSpan);
					elem = newSpan;
				}
			}
			
			var curSpan:SpanElement = elem as SpanElement;
			var runInsertionPoint:int;
			//if we added a new span, then 
			runInsertionPoint = paraSelBegIdx - curSpan.getElementRelativeStart(para);
			
				
			curSpan.replaceText(runInsertionPoint, runInsertionPoint, insertText);
		}
		
		private static function deleteTextInternal(para:ParagraphElement, paraSelBegIdx:int, totalToDelete:int):void
		{
			var composeNode:FlowElement;
			var curSpan:SpanElement;
			
			var curNumToDelete:int;
			var curSpanDeletePos:int = 0;
			
			while (totalToDelete > 0)
			{
				composeNode = para.findLeaf(paraSelBegIdx);
				CONFIG::debug { assert(composeNode is SpanElement,"deleteTextInternal: leaf element is not a span"); }
								
				curSpan = composeNode as SpanElement;
				var curSpanRelativeStart:int = curSpan.getElementRelativeStart(para);
				curSpanDeletePos = paraSelBegIdx - curSpanRelativeStart;
				if (paraSelBegIdx > (curSpanRelativeStart + curSpan.textLength))
				{
					curNumToDelete = curSpan.textLength;
				}
				else
				{
					curNumToDelete = (curSpanRelativeStart + curSpan.textLength) - paraSelBegIdx;
				}
				
				if (totalToDelete < curNumToDelete)
				{
					curNumToDelete = totalToDelete;
				}
				
				curSpan.replaceText(curSpanDeletePos, curSpanDeletePos + curNumToDelete, "");
				if (curSpan.textLength == 0)
				{
					var delIdx:int = curSpan.parent.getChildIndex(curSpan);
					curSpan.parent.replaceChildren(delIdx,delIdx+1,null);						
				}
				totalToDelete -= curNumToDelete;
			}			
		}
		
		public static function deleteText(para:ParagraphElement, paraSelBegIdx:int, totalToDelete:int):void
		{
			var lastParPos:int = para.textLength - 1;
			if ((paraSelBegIdx < 0) || (paraSelBegIdx > lastParPos))
			{
				//not much we can do. There's nothing to delete in this paragraph
				return;
			}
			
			if (totalToDelete <= 0)
			{
				//can't delete a negative number of characters... just return
				return;
			}
			
			var endPos:int = paraSelBegIdx + totalToDelete - 1;
			if (endPos > lastParPos)
			{
				endPos = lastParPos;
				totalToDelete = endPos - paraSelBegIdx + 1
			}
			
			deleteTextInternal(para,paraSelBegIdx,totalToDelete);
		}
		
		/**
		 * Creates image and inserts it into specified FlowGroupElement
		 * @param flowBlock	FlowGroupElement to insert image into
		 * @param flowSelBegIdx	index relative to beginning of the FlowGroupElement to insert image
		 * @param urlString	the url of image to insert
		 * @param width	the width of the image
		 * @param height the height of the image
		 * @param options none supported
		 */
		public static function createImage(flowBlock:FlowGroupElement, flowSelBegIdx:int,source:Object, width:Object, height:Object, options:Object, pointFormat:ITextLayoutFormat):InlineGraphicElement
		{
			//first, split the element that we are on
			var curComposeNode:FlowElement = flowBlock.findLeaf(flowSelBegIdx);
			var posInCurComposeNode:int = 0;
			if (curComposeNode != null)
			{
				posInCurComposeNode = flowSelBegIdx - curComposeNode.getElementRelativeStart(flowBlock); // curComposeNode.parentRelativeStart;
			}			
			
			if ((curComposeNode != null) && (posInCurComposeNode > 0) && (posInCurComposeNode < curComposeNode.textLength))
			{
				//it is a LeafElement, and not position 0. It has to be a Span 
				(curComposeNode as SpanElement).splitAtPosition(posInCurComposeNode);
			}
			
			//the FlowElement or FlowGroupElement is now split.  Insert the image now.
			var imgElem:InlineGraphicElement = new InlineGraphicElement();
			imgElem.height = height;
			imgElem.width = width;
			imgElem.float = options ? options.toString() : Float.NONE;
			
			var src:Object = source;
			var embedStr:String = "@Embed";
			if (src is String && src.length > embedStr.length && src.substr(0, embedStr.length) == embedStr) {
				// we should be dealing with an embedded asset. They are of the form "url=@Embed(source='path-to-asset')"
				var searchStr:String = "source=";
				var index:int = src.indexOf(searchStr, embedStr.length);
				if (index > 0) {
					index += searchStr.length;
					index = src.indexOf("'", index);
					src = src.substring(index+1, src.indexOf("'", index+1));
				}
			}
			imgElem.source = src;
			
			while (curComposeNode && curComposeNode.parent != flowBlock)
			{
				curComposeNode = curComposeNode.parent;
			}

			var elementIdx:int = curComposeNode != null ? flowBlock.getChildIndex(curComposeNode) : flowBlock.numChildren;
			if (curComposeNode && posInCurComposeNode > 0)
				elementIdx++;
			flowBlock.replaceChildren(elementIdx,elementIdx,imgElem);
			
			//clone characterFormat from the left OR iff the the first element the right
			var p:ParagraphElement = imgElem.getParagraph();
			var attrElem:FlowLeafElement = imgElem.getPreviousLeaf(p);
			if (!attrElem)
				attrElem = imgElem.getNextLeaf(p);
			CONFIG::debug { assert(attrElem != null, "no element to get attributes from"); }
			
			if (attrElem.format || pointFormat)
			{
				var imageElemFormat:TextLayoutFormat = new TextLayoutFormat(attrElem.format);
				if (pointFormat)
					imageElemFormat.apply(pointFormat);
				imgElem.format = imageElemFormat;
			}
			return imgElem;			
		}		
		
		/** Merge changed attributes into this
		 */
		static private function splitForChange(span:SpanElement,begIdx:int,rangeLength:int):SpanElement
		{
			var startOffset:int = span.getAbsoluteStart();
			if (begIdx == startOffset && rangeLength == span.textLength)
				return span;
				
			// element must be split into spans
			var elemToUpdate:SpanElement;
			var origLength:int = span.textLength;
			
			var begRelativeIdx:int = begIdx - startOffset;
			if (begRelativeIdx > 0)
			{
				// We create an initial span to hold the text before the new span, then
				// a following span for the specified range.
				elemToUpdate = span.splitAtPosition(begRelativeIdx) as SpanElement;
				if (begRelativeIdx + rangeLength < origLength)
					elemToUpdate.splitAtPosition(rangeLength);
			}
			else
			{
				// The specified range falls at the start of the element, so this span is the 
				// one that's getting the new format.
				span.splitAtPosition(rangeLength);
				elemToUpdate = span;
			}

			return elemToUpdate;
		}
		
		private static function undefineDefinedFormats(target:TextLayoutFormatValueHolder,undefineFormat:ITextLayoutFormat):void
		{
			if (undefineFormat)
			{
				// this is fairly rare so this operation is not optimizied
				for (var prop:String in TextLayoutFormat.description)
				{
					if (undefineFormat[prop] !== undefined)
						target[prop] = undefined;
				} 
			}
		}

		/**
		 * Apply formatting changes to a range of text in the FlowElement
		 *
		 * @param begIdx	text index of first text in span
		 * @param rangeLength	number of characters to modify
		 * @param applyFormat		Character Format to apply to content
		 * @param undefineFormat	Character Format to undefine to content
		 * @return begIdx + number of actual actual characters modified.
		 */
		static private function applyCharacterFormat(leaf:FlowLeafElement, begIdx:int, rangeLength:int, applyFormat:ITextLayoutFormat, undefineFormat:ITextLayoutFormat):int
		{
			var newFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder(leaf.format);
			if (applyFormat)
				newFormat.apply(applyFormat);
			undefineDefinedFormats(newFormat,undefineFormat);
			return setCharacterFormat(leaf, newFormat, begIdx, rangeLength);
		}
		
		/**
		 * Set formatting to a range of text in the FlowElement
		 *
		 * @param format	Character Format to apply to content
		 * @param begIdx	text index of first text in span
		 * @param rangeLength	number of characters to modify
		 * @return starting position of following span
		 */
		static private function setCharacterFormat(leaf:FlowLeafElement, format:Object, begIdx:int, rangeLength:int):int
		{
			var startOffset:int = leaf.getAbsoluteStart();
			if (!(format is ITextLayoutFormat) || !TextLayoutFormat.isEqual(ITextLayoutFormat(format),leaf.format))
			{				
				var para:ParagraphElement = leaf.getParagraph();
				var paraStartOffset:int = para.getAbsoluteStart();
				
				// clip rangeLength to the length of this span. Extend the rangeLength by one to include the terminator if
				// it is in the span, and the end of the range abuts the terminator. That way the terminator will stay in the 
				// last span.
				var begRelativeIdx:int = begIdx - startOffset;
				if (begRelativeIdx + rangeLength > leaf.textLength)
					rangeLength = leaf.textLength - begRelativeIdx;
				if (begRelativeIdx + rangeLength == leaf.textLength - 1 && (leaf is SpanElement) && SpanElement(leaf).hasParagraphTerminator)
					++rangeLength;
				
				var elemToUpdate:FlowLeafElement
				if (leaf is SpanElement)
					elemToUpdate = splitForChange(SpanElement(leaf),begIdx,rangeLength);
				else
				{
					CONFIG::debug { assert(rangeLength >= leaf.textLength,"unable to split non-span leaf"); }
					elemToUpdate = leaf;
				}
				
				if (format is ITextLayoutFormat)
					elemToUpdate.format = ITextLayoutFormat(format);
				else
					elemToUpdate.setCoreStylesInternal(format);
				
				return begIdx+rangeLength;
			}
			
			rangeLength = leaf.textLength;
			return startOffset+rangeLength;
		}
		
		public static function applyTextStyleChange(flowRoot:TextFlow,begChange:int,endChange:int,applyFormat:ITextLayoutFormat,undefineFormat:ITextLayoutFormat):void
		{	
			// TODO: this code only works for span's.  Revisit when new FlowLeafElement types enabled
			var workIdx:int = begChange;
			while (workIdx < endChange)
			{
				var elem:FlowLeafElement = flowRoot.findLeaf(workIdx);
				CONFIG::debug  { assert(elem != null,"null FlowLeafElement found"); }
				workIdx = applyCharacterFormat(elem,workIdx,endChange-workIdx,applyFormat,undefineFormat); 
			}
		}
		
		// used for undo of operation
		public static function setTextStyleChange(flowRoot:TextFlow,begChange:int, endChange:int, coreStyle:Object):void
		{
			// TODO: this code only works for span's.  Revisit when new FlowLeafElement types enabled
			var workIdx:int = begChange;
			while (workIdx < endChange)
			{
				var elem:FlowElement = flowRoot.findLeaf(workIdx);
				CONFIG::debug  { assert(elem != null,"null FlowLeafElement found"); }
				workIdx = setCharacterFormat(FlowLeafElement(elem),coreStyle,workIdx,endChange-workIdx);
			}
		}

		public static function splitParagraph(para:ParagraphElement, paraSplitPos:int, pointFormat:ITextLayoutFormat=null):ParagraphElement
		{
			CONFIG::debug { assert(((paraSplitPos >= 0) && (paraSplitPos <= para.textLength - 1)), "Invalid call to ParaEdit.splitParagraph"); }

			var newPar:ParagraphElement;
			var paraStartAbsolute:int = para.getAbsoluteStart();
			var absSplitPos:int = paraStartAbsolute + paraSplitPos;
			
			if ((paraSplitPos == para.textLength - 1))
			{
				newPar = para.shallowCopy() as ParagraphElement;
				newPar.replaceChildren(0, 0, new SpanElement());
				var startIdx:int = para.parent.getChildIndex(para);
				para.parent.replaceChildren(startIdx + 1, startIdx + 1, newPar);
				if (newPar.textLength == 1)
				{
					//we have an empty paragraph.  Make sure that the first
					//span of this paragraph has the same character attributes
					//of the last span of this

					var lastSpan:FlowLeafElement = para.getLastLeaf();
					var prevSpan:FlowLeafElement;
					if (lastSpan != null && lastSpan.textLength == 1)
					{
						//if the lastSpan is only a newline, you really want the span right before
						var elementIdx:int = lastSpan.parent.getChildIndex(lastSpan);
						if (elementIdx > 0)
						{
							prevSpan = lastSpan.parent.getChildAt(elementIdx - 1) as SpanElement;
							if (prevSpan != null) lastSpan = prevSpan;
						}
					}
					if (lastSpan != null)
					{
						ParaEdit.setTextStyleChange(para.getTextFlow(), absSplitPos + 1, absSplitPos + 2, lastSpan.format);
					}
					if (pointFormat != null)
						ParaEdit.applyTextStyleChange(para.getTextFlow(),absSplitPos + 1, absSplitPos + 2, pointFormat, null);
				}							
			}
			else
			{
				newPar = para.splitAtPosition(paraSplitPos) as ParagraphElement;
			}
			
			//you can't have empty paragraphs.  Put the span back
			// This now handled in normalize()
			if (para.numChildren == 0)
			{
				//If we are injecting a new Span, we need to clone the attributes from 
				//the newPar's first child.  If we don't, then contents of para will have
				//no formatting. (2464521)
				var newFormattedSpan:SpanElement = new SpanElement();
				newFormattedSpan.quickCloneTextLayoutFormat(newPar.getChildAt(0));
				para.replaceChildren(0, 0, newFormattedSpan);
			}
			
			return newPar;
		}
		
		// TODO: rewrite this method by moving the elements.  This is buggy.
		public static function mergeParagraphWithNext(para:ParagraphElement):Boolean
		{
			var indexOfPara:int = para.parent.getChildIndex(para);
			
			// last can't merge
			if (indexOfPara == para.parent.numChildren-1)
				return false;
				
			var nextPar:ParagraphElement  = para.parent.getChildAt(indexOfPara + 1) as ParagraphElement;
			// next is not a paragraph
			if (nextPar == null)
				return false;
				
			// remove nextPar from its parent - do this first because it will require less updating of starts and lengths
			para.parent.replaceChildren(indexOfPara+1,indexOfPara+2,null);
			if (nextPar.textLength <= 1) 
				return true;
			
			// move all the elements
			while (nextPar.numChildren)
			{
				var elem:FlowElement = nextPar.getChildAt(0);
				nextPar.replaceChildren(0,1,null);
				para.replaceChildren(para.numChildren,para.numChildren,elem);
				if ((para.numChildren >  1) && (para.getChildAt(para.numChildren - 2).textLength == 0))
				{
					//bug 1658164
					//imagine that the last element of para is only a kParaTerminator (like a single
					//span of length 1 that only contains a kParaTerminator, and you merge with the
					//next paragraph. That kParaTerminator will move, leaving an empty leaf element
					para.replaceChildren(para.numChildren - 2, para.numChildren - 1, null);
				}
			}

			return true;
		}
		
		public static function cacheParagraphStyleInformation(flowRoot:TextFlow,begSel:int,endSel:int,undoArray:Array):void
		{
			while (begSel <= endSel && begSel >= 0)
			{
				var para:ParagraphElement = flowRoot.findLeaf(begSel).getParagraph();
				
				// build an object holding the old style and format
				var obj:Object = new Object();
				obj.begIdx = para.getAbsoluteStart();
				obj.endIdx = obj.begIdx + para.textLength - 1;
				obj.attributes = para.coreStyles;
				undoArray.push(obj);

				begSel = obj.begIdx + para.textLength;
			}
		}

		/**
		 * Replace the existing paragraph attributes with the incoming attributes.
		 * 
		 * @param flowRoot	text flow where paragraphs are
		 * @param format	attributes to apply
		 * @param beginIndex	text index within the first paragraph in the range
		 * @param endIndex		text index within the last paragraph in the range
		 */
		// used for undo of operation
		public static function setParagraphStyleChange(flowRoot:TextFlow,begChange:int, endChange:int, coreStyles:Object):void
		{
			var beginPara:int = begChange;
			while (beginPara < endChange)
			{
				var para:ParagraphElement = flowRoot.findLeaf(beginPara).getParagraph();
				
				para.setCoreStylesInternal(coreStyles);
				beginPara = para.getAbsoluteStart() + para.textLength;
			}
		}
		
		/**
		 * Additively apply the paragraph formating attributes to the paragraphs in the specified range.
		 * Each non-null field in the incoming format is copied into the existing paragraph attributes.
		 * 
		 * @param flowRoot	text flow where paragraphs are
		 * @param format	attributes to apply
		 * @param beginIndex	text index within the first paragraph in the range
		 * @param endIndex		text index within the last paragraph in the range
		 */
		public static function applyParagraphStyleChange(flowRoot:TextFlow,begChange:int,endChange:int,applyFormat:ITextLayoutFormat,undefineFormat:ITextLayoutFormat):void
		{	
			var curIndex:int = begChange;
			while (curIndex <= endChange)
			{
				var para:ParagraphElement = flowRoot.findLeaf(curIndex).getParagraph();
				
				// now, need to get the change from "format" and apply to para. We make
				// a new ParagraphFormat object instead of changing the ParagraphFormat
				// already in the paragraph so that if the object is shared, other uses
				// in other paragraphs will not be affected.
				var newFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder(para.format);
				if (applyFormat)
					newFormat.apply(applyFormat);
				undefineDefinedFormats(newFormat,undefineFormat);
				para.format = newFormat;
				
				curIndex = para.getAbsoluteStart() + para.textLength;
			}		
		}

		public static function cacheStyleInformation(flowRoot:TextFlow,begSel:int,endSel:int,undoArray:Array):void
		{
			var elem:FlowElement = flowRoot.findLeaf(begSel);
			var elemLength:int = elem.getAbsoluteStart()+elem.textLength-begSel;
			var countRemaining:int = endSel - begSel;
			CONFIG::debug { assert(countRemaining != 0,"cacheStyleInformation called on point selection"); }
			for (;;)
			{
				// build an object holding the old style and format
				var obj:Object = new Object();

				obj.begIdx = begSel;
				var objLength:int = Math.min(countRemaining, elemLength);
				obj.endIdx = begSel + objLength;
				
				// save just the styles
				obj.style = elem.coreStyles;
				undoArray.push(obj);
				
				countRemaining -= Math.min(countRemaining, elemLength);
				if (countRemaining == 0)
					break;
				
				// advance
				begSel = obj.endIdx;
				
				elem = flowRoot.findLeaf(begSel);
				elemLength = elem.textLength;
			}
		}
		
		public static function cacheContainerStyleInformation(flowRoot:TextFlow,begIdx:int,endIdx:int,undoArray:Array):void
		{
			CONFIG::debug { assert(begIdx <= endIdx,"bad indexeds passed to ParaEdit.cacheContainerStyleInformation");  }
			if (flowRoot.flowComposer)
			{
				var controllerIndex:int = flowRoot.flowComposer.findControllerIndexAtPosition(begIdx,false);
				if (controllerIndex >= 0)
				{
					while (controllerIndex < flowRoot.flowComposer.numControllers)
					{
						var controller:ContainerController = flowRoot.flowComposer.getControllerAt(controllerIndex);
						if (controller.absoluteStart >= endIdx)
							break;
						var obj:Object = new Object();
						obj.container = controller;
						// save just the styles
						obj.attributes = controller.coreStyles;
						undoArray.push(obj);
						controllerIndex++;
					}
				}
			}
		}

		public static function applyContainerStyleChange(flowRoot:TextFlow,begIdx:int,endIdx:int,applyFormat:ITextLayoutFormat,undefineFormat:ITextLayoutFormat):void
		{
			CONFIG::debug { assert(begIdx <= endIdx,"bad indexes passed to ParaEdit.cacheContainerStyleInformation");  }
			if (flowRoot.flowComposer)
			{
				var controllerIndex:int = flowRoot.flowComposer.findControllerIndexAtPosition(begIdx,false);
				if (controllerIndex >= 0)
				{
					while (controllerIndex < flowRoot.flowComposer.numControllers)
					{
						var controller:ContainerController = flowRoot.flowComposer.getControllerAt(controllerIndex);
						if (controller.absoluteStart >= endIdx)
							break;
						var newFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder(controller.format);
						if (applyFormat)
							newFormat.apply(applyFormat);
						undefineDefinedFormats(newFormat,undefineFormat);
						controller.format = newFormat;
						controllerIndex++;
					}
				}
			}
		}

		/** obj is created by cacheContainerStyleInformation */
		public static function setContainerStyleChange(flowRoot:TextFlow,obj:Object):void
		{
			obj.container.format = obj.attributes as ITextLayoutFormat;
		}
	}
}
