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
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElementBase;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
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
		 * @param textFlow		TextFlow to insert into
		 * @param absoluteStart	index relative to beginning of the TextFlow to insert text
		 * @param text	actual text to insert 
		 * @param createNewSpan	flag to force creation of a new span
		 */
		public static function insertText(textFlow:TextFlow, absoluteStart:int,insertText:String, createNewSpan:Boolean):SpanElement
		{
			if (insertText.length == 0)
				return null;	// error? other sanity checks needed here?
				
			var sibling:FlowElement = textFlow.findLeaf(absoluteStart);
			var siblingIndex:int;
			var paragraph:ParagraphElement = sibling.getParagraph();
			var paraStart:int = paragraph.getAbsoluteStart();
			var paraSelBegIdx:int = absoluteStart - paraStart;
			
			if (paraStart == absoluteStart)		// insert to start of paragraph
				siblingIndex = 0;
			else 
			{
				// If we're at the start a span, go to the previous span in the same paragraph, and insert at the end of it
				if (paraSelBegIdx == sibling.getElementRelativeStart(paragraph))
					sibling = FlowLeafElement(sibling).getPreviousLeaf(paragraph);	
				siblingIndex = sibling.parent.getChildIndex(sibling) + 1;
			}
			var insertParent:FlowGroupElement = sibling.parent;
			
			// If we are adding text to the start or end of a link, it doesn't allow the insertion to group with the link.
			// So in that case, we will insert to the element beside the position that is *not* part of the link.
			var curSPGElement:SubParagraphGroupElementBase = sibling.getParentByType(SubParagraphGroupElementBase) as SubParagraphGroupElementBase;
			while (curSPGElement != null)
			{
				var subParInsertionPoint:int = paraSelBegIdx - curSPGElement.getElementRelativeStart(paragraph);
				if (((subParInsertionPoint == 0) && (!curSPGElement.acceptTextBefore())) ||
					((!curSPGElement.acceptTextAfter() && (subParInsertionPoint == curSPGElement.textLength || 
					(subParInsertionPoint == curSPGElement.textLength - 1 && (sibling == paragraph.getLastLeaf()))))))
				{
					createNewSpan = true;
					sibling = insertParent;
					insertParent = insertParent.parent;
					curSPGElement = curSPGElement.getParentByType(SubParagraphGroupElementBase) as SubParagraphGroupElementBase;
					siblingIndex = insertParent.getChildIndex(sibling) + 1;
				} else {
					break;
				}
			}
			// adjust the flow so that we are in a span for the insertion
			var insertSpan:SpanElement = sibling as SpanElement;
			
			// use the terminator span if it's empty
			if(paragraph.terminatorSpan.textLength == 1 && paragraph.terminatorSpan == insertSpan)
				createNewSpan = false;
			
			if (!insertSpan || createNewSpan)
			{
				var newSpan:SpanElement = new SpanElement();
				var insertIdx:int;
				if (siblingIndex > 0)
				{
					var relativeStart:int = paraSelBegIdx - sibling.getElementRelativeStart(paragraph);
					if (createNewSpan)
					{
						if (relativeStart == 0)
							siblingIndex--;
						else if (relativeStart != sibling.textLength)
							sibling.splitAtPosition(relativeStart);		// we'll insert between the two elements
					}
				}
				var nextLeaf:FlowLeafElement = paragraph.findLeaf(paraSelBegIdx);
				if(nextLeaf && nextLeaf.textLength == 1 && nextLeaf == paragraph.terminatorSpan)
				{
					// use the terminator span instead of inserting a new one.
					newSpan = SpanElement(nextLeaf);
				}
				else {
					insertParent.replaceChildren(siblingIndex, siblingIndex, newSpan);
				}
				var formatElem:FlowLeafElement = newSpan.getPreviousLeaf(paragraph);
				if (formatElem == null)
					newSpan.format = newSpan.getNextLeaf(paragraph).format;
				else
					newSpan.format = formatElem.format;
					
				insertSpan = newSpan;
			}
			
			var runInsertionPoint:int = paraSelBegIdx - insertSpan.getElementRelativeStart(paragraph);
			
				
			insertSpan.replaceText(runInsertionPoint, runInsertionPoint, insertText);
			return insertSpan;
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
			imgElem.float = options ? options.toString() : undefined;
			
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
		
		private static function undefineDefinedFormats(target:TextLayoutFormat,undefineFormat:ITextLayoutFormat):void
		{
			if (undefineFormat)
			{
				// this is fairly rare so this operation is not optimizied
				var tlfUndefineFormat:TextLayoutFormat;
				if (undefineFormat is TextLayoutFormat)
					tlfUndefineFormat = undefineFormat as TextLayoutFormat;
				else 
					tlfUndefineFormat = new TextLayoutFormat(undefineFormat);
				for (var prop:String in tlfUndefineFormat.styles)
					target.setStyle(prop, undefined);
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
			var newFormat:TextLayoutFormat = new TextLayoutFormat(leaf.format);
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
		static private function setCharacterFormat(leaf:FlowLeafElement, format:ITextLayoutFormat, begIdx:int, rangeLength:int):int
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
					elemToUpdate.setStylesInternal(format);
				
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
		public static function setTextStyleChange(flowRoot:TextFlow,begChange:int, endChange:int, coreStyle:ITextLayoutFormat):void
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
		
		public static function splitElement(elem:FlowGroupElement, splitPos:int):FlowGroupElement
		{
			CONFIG::debug { assert(splitPos >= 0 && splitPos <= elem.textLength, "Invalid call to ParaEdit.splitElement"); }
			
			var rslt:FlowGroupElement = elem.splitAtPosition(splitPos) as FlowGroupElement;
			
			// rslt always follows elem
			

			if (!(rslt is SubParagraphGroupElementBase))
			{
				
				// need to insure there is a paragraph and a span on each side
				var rsltParagraph:FlowGroupElement = rslt;
				while (!(rsltParagraph is ParagraphElement) && rsltParagraph.numChildren)
					rsltParagraph = rsltParagraph.getChildAt(0) as FlowGroupElement;
				
				var elemParagraph:FlowGroupElement = elem;
				while (!(elemParagraph is ParagraphElement) && elemParagraph.numChildren)
					elemParagraph = elemParagraph.getChildAt(elemParagraph.numChildren-1) as FlowGroupElement;
				
				CONFIG::debug { assert (elemParagraph is ParagraphElement || rsltParagraph is ParagraphElement,"ParaEdit.splitElement didn't find at least one paragraph"); }
				
				var p:ParagraphElement;
				
				if (!(elemParagraph is ParagraphElement))
				{
					// clone rlstParagraph
					p = rsltParagraph.shallowCopy() as ParagraphElement;
					elemParagraph.addChild(p);
					elemParagraph = p;
				}
				else if (!(rsltParagraph is ParagraphElement))
				{
					p = elemParagraph.shallowCopy() as ParagraphElement;
					rsltParagraph.addChild(p);
					rsltParagraph = p;						
				}
				
				// if we have an empty before or after para need to make sure the formats got copied
				if (elemParagraph.textLength <= 1)
				{
					elemParagraph.normalizeRange(0,elemParagraph.textLength);
					elemParagraph.getLastLeaf().quickCloneTextLayoutFormat(rsltParagraph.getFirstLeaf());
				}
				else if (rsltParagraph.textLength <= 1)
				{
					rsltParagraph.normalizeRange(0,rsltParagraph.textLength);
					rsltParagraph.getFirstLeaf().quickCloneTextLayoutFormat(elemParagraph.getLastLeaf());
				}
			}

			return rslt;
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
				obj.attributes = new TextLayoutFormat(para.format);
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
		public static function setParagraphStyleChange(flowRoot:TextFlow,begChange:int, endChange:int, format:ITextLayoutFormat):void
		{
			var beginPara:int = begChange;
			while (beginPara <= endChange)
			{
				var para:ParagraphElement = flowRoot.findLeaf(beginPara).getParagraph();
				
				para.format = format ? new TextLayoutFormat(format) : null;
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
				var leaf:FlowLeafElement = flowRoot.findLeaf(curIndex);
				if (!leaf)
					break;
				var para:ParagraphElement = leaf.getParagraph();
				
				// now, need to get the change from "format" and apply to para. We make
				// a new ParagraphFormat object instead of changing the ParagraphFormat
				// already in the paragraph so that if the object is shared, other uses
				// in other paragraphs will not be affected.
				var newFormat:TextLayoutFormat = new TextLayoutFormat(para.format);
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
				
				// just the styles
				obj.style = new TextLayoutFormat(elem.format);
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
				var ctrlrBegIdx:int = flowRoot.flowComposer.findControllerIndexAtPosition(begIdx,false);
				if (ctrlrBegIdx == -1)
					return;
				var ctrlrEndIdx:int = flowRoot.flowComposer.findControllerIndexAtPosition(endIdx,true);
				if (ctrlrEndIdx == -1)
					ctrlrEndIdx = flowRoot.flowComposer.numControllers-1;
				while (ctrlrBegIdx <= ctrlrEndIdx)
				{
					var controller:ContainerController = flowRoot.flowComposer.getControllerAt(ctrlrBegIdx);
					var obj:Object = new Object();
					obj.container = controller;
					// save just the styles
					obj.attributes = new TextLayoutFormat(controller.format);
					undoArray.push(obj);
					ctrlrBegIdx++;
				}
			}
		}

		public static function applyContainerStyleChange(flowRoot:TextFlow,begIdx:int,endIdx:int,applyFormat:ITextLayoutFormat,undefineFormat:ITextLayoutFormat):void
		{
			CONFIG::debug { assert(begIdx <= endIdx,"bad indexes passed to ParaEdit.cacheContainerStyleInformation");  }
			if (flowRoot.flowComposer)
			{
				var ctrlrBegIdx:int = flowRoot.flowComposer.findControllerIndexAtPosition(begIdx,false);
				if (ctrlrBegIdx == -1)
					return;
				var ctrlrEndIdx:int = flowRoot.flowComposer.findControllerIndexAtPosition(endIdx,true);
				if (ctrlrEndIdx == -1)
					ctrlrEndIdx = flowRoot.flowComposer.numControllers-1;
				var controllerIndex:int = flowRoot.flowComposer.findControllerIndexAtPosition(begIdx,false);
				while (ctrlrBegIdx <= ctrlrEndIdx)
				{
					var controller:ContainerController = flowRoot.flowComposer.getControllerAt(ctrlrBegIdx);
					var newFormat:TextLayoutFormat = new TextLayoutFormat(controller.format);
					if (applyFormat)
						newFormat.apply(applyFormat);
					undefineDefinedFormats(newFormat,undefineFormat);
					controller.format = newFormat;
					ctrlrBegIdx++;
				}
			}
		}

		/** obj is created by cacheContainerStyleInformation */
		public static function setContainerStyleChange(obj:Object):void
		{
			obj.container.format = obj.attributes as ITextLayoutFormat;
		}
	}
}
