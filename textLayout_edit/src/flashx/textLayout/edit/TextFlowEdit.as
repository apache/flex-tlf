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
	import flashx.textLayout.elements.ContainerFormattedElement;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;
	
	[ExcludeClass]
	/**
	 * Encapsulates all methods necessary for dynamic editing of a text.  The methods are all static member functions of this class.
     * @private - because we can't make it tlf_internal. Used by the operations package 
	 */	
	public class TextFlowEdit
	{
		private static function deleteRange(theFlow:FlowGroupElement, startPos:int, endPos:int):int
		{
			var curFlowElementIdx:int = 0;
			var curFlowElement:FlowElement;
			var needToMergeWhenDone:Boolean = false;
			var relStart:int = 0;
			var relEnd:int = 0;
			var s:SpanElement;
			var processedAnElement:Boolean = false;
			var totalItemsDeleted:int = 0;
			var curNumDeleted:int = 0;
			var tempFlowElement:FlowElement;
			var numItems:int;
			
			while (curFlowElementIdx < theFlow.numChildren)
			{
				curFlowElement = theFlow.getChildAt(curFlowElementIdx);
				relStart = startPos - curFlowElement.parentRelativeStart;
				if (relStart < 0) relStart = 0;
				relEnd = endPos - curFlowElement.parentRelativeStart;
							
				if ((relStart < curFlowElement.textLength) && (relEnd > 0))
				{
					//at least partially selected
					if ((relStart <= 0) && ((relEnd > curFlowElement.textLength) || ((relEnd >= curFlowElement.textLength) && (curFlowElement is ParagraphElement))))
					{
						//completely selected
						// If the last character of a paragraph is part of the span, it won't get deleted. We will skip over it for now, and may delete it later as 
						// part of a paragraph merge.
						curNumDeleted = curFlowElement.textLength;
						var skippingTerminator:Boolean = curFlowElementIdx == theFlow.numChildren - 1 && (curFlowElement is SpanElement) && (theFlow is ParagraphElement);
						theFlow.replaceChildren(curFlowElementIdx, curFlowElementIdx + 1, null);
						if (skippingTerminator)
							++curFlowElementIdx;
						totalItemsDeleted += curNumDeleted;
						endPos -= curNumDeleted;
					} else { //not completely selected
						if (curFlowElement is SpanElement) {
							s = curFlowElement as SpanElement;
							
							if(relEnd > s.textLength) 
								relEnd = s.textLength;	
								
							s.replaceText(relStart, relEnd, "");
							curNumDeleted = (relEnd - relStart);
							totalItemsDeleted += curNumDeleted;
							endPos -= curNumDeleted;
						} else if (!(curFlowElement is FlowGroupElement))
						{
							curNumDeleted = curFlowElement.textLength;
							totalItemsDeleted += curFlowElement.textLength;
							endPos -= curNumDeleted;
							theFlow.replaceChildren(curFlowElementIdx, curFlowElementIdx + 1, null);			
						} else { //it must be a FlowGroupElement of some kind
							if ((!processedAnElement) && (relEnd >= curFlowElement.textLength))
							{
								if (curFlowElement is ParagraphElement)
									needToMergeWhenDone = true;
								else if (curFlowElement is FlowGroupElement)
								{
									numItems = (curFlowElement as FlowGroupElement).numChildren;
									if (numItems > 0)
									{
										tempFlowElement = (curFlowElement as FlowGroupElement).getChildAt(numItems - 1);
										if (tempFlowElement is ParagraphElement)
										{
											needToMergeWhenDone = true;
										}
									}
								}
							}							
							curNumDeleted = TextFlowEdit.deleteRange(curFlowElement as FlowGroupElement, relStart, relEnd);
							totalItemsDeleted += curNumDeleted;
							endPos -= curNumDeleted;
							if (needToMergeWhenDone == true) 
								endPos++;
							if (!(curFlowElement is ParagraphElement)) 
								needToMergeWhenDone = false;
						}
						if (processedAnElement)
						{
							break;
						}						
						curFlowElementIdx++;
					}
					processedAnElement = true;
				} else if (processedAnElement)
				{
					break;
				} else {
					curFlowElementIdx++;
				}
			}
			if (needToMergeWhenDone)
			{
				joinNextParagraph(ParagraphElement(curFlowElement.getPreviousSibling()));
			}
			
			return totalItemsDeleted;
		}
		
		private static function isFlowElementInArray(arr:Array, fl:FlowElement):Boolean
		{
			if (arr != null)
			{
				var arrLen:int = arr.length;
				var currPos:int = 0;
				while (currPos < arrLen)
				{
					if (arr[currPos] == fl)
					{
						return true;
					}
					currPos++;
				}
			}
			return false;
		}
				
		private static function getContainer(flEl:FlowElement):ContainerFormattedElement
		{
			while (!(flEl.parent is ContainerFormattedElement))
			{
				flEl = flEl.parent;
			}
			return flEl.parent as ContainerFormattedElement;
		}
		
		private static function isInsertableItem(flItem:FlowElement, missingBeginElements:Array, missingEndElements:Array):Boolean
		{
			return ((flItem is ParagraphElement) ||
					(!TextFlowEdit.isFlowElementInArray(missingBeginElements, flItem) &&
					 !TextFlowEdit.isFlowElementInArray(missingEndElements, flItem)));
		}
		
		private static function putDivAtEndOfContainer(container:ContainerFormattedElement):DivElement
		{
			var tempDiv:DivElement = new DivElement();
			var tempPar:ParagraphElement = new ParagraphElement();
			tempPar.replaceChildren(0, 0, new SpanElement());
			tempDiv.replaceChildren(0, 0, tempPar);
			container.replaceChildren(container.numChildren, container.numChildren, tempDiv);
			return tempDiv;			
		}
		
		private static function putDivAtEndOfContainerAndInsertTextFlow(theFlow:TextFlow, pos:int, insertedTextFlow:FlowGroupElement, missingBeginElements:Array, missingEndElements:Array, separatorArray:Array):int
		{
			var tempFlChild:FlowElement;
			var nextInsertionPosition:int = pos;
			var insertContainer:ContainerFormattedElement = TextFlowEdit.getContainer(theFlow.findAbsoluteParagraph(nextInsertionPosition));						
			var tempDiv:DivElement = TextFlowEdit.putDivAtEndOfContainer(insertContainer);
			separatorArray.push(tempDiv);
			while (insertedTextFlow.numChildren > 0)
			{
				tempFlChild = insertedTextFlow.getChildAt(0);
				insertedTextFlow.replaceChildren(0, 1, null);
				nextInsertionPosition = TextFlowEdit.insertTextFlow(theFlow, nextInsertionPosition, tempFlChild as FlowGroupElement, missingBeginElements, missingEndElements, separatorArray);
			}
			var elementIdx:int = tempDiv.parent.getChildIndex(tempDiv);
			tempDiv.parent.replaceChildren(elementIdx, elementIdx + 1, null);
			separatorArray.pop();
			return nextInsertionPosition;
		}
		
		private static function isContainerSeparator(fl:FlowElement, separatorArray:Array):Boolean
		{
			var i:int = 0;
			var numItemsInArray:int = separatorArray.length;
			while (i < numItemsInArray)
			{
				if (separatorArray[i] == fl)
				{
					return true;
				}
				i++;
			}
			return false;
		}
		
		private static var processedFirstFlowElement:Boolean = false;
		private static function insertTextFlow(theFlow:TextFlow, pos:int, insertedTextFlow:FlowGroupElement, missingBeginElementsInFlow:Array = null, missingEndElementsInFlow:Array = null, separatorArray:Array = null):int
		{
			var nextInsertionPosition:int = pos;
						
			if (!TextFlowEdit.isInsertableItem(insertedTextFlow, missingBeginElementsInFlow, missingEndElementsInFlow) ||
				(insertedTextFlow is TextFlow))
			{
				if (insertedTextFlow is TextFlow)
				{
					processedFirstFlowElement = false;
					var tempDiv:DivElement = TextFlowEdit.putDivAtEndOfContainer(theFlow as ContainerFormattedElement);
					separatorArray = new Array();
					separatorArray.push(tempDiv);
				}
				var tempFlChild:FlowElement = insertedTextFlow.getChildAt(0);
				if (TextFlowEdit.isInsertableItem(tempFlChild, missingBeginElementsInFlow, missingEndElementsInFlow))
				{
					nextInsertionPosition = TextFlowEdit.putDivAtEndOfContainerAndInsertTextFlow(theFlow, nextInsertionPosition, insertedTextFlow, missingBeginElementsInFlow, missingEndElementsInFlow, separatorArray);  
				} else {				
					while (insertedTextFlow.numChildren > 0)
					{
						tempFlChild = insertedTextFlow.getChildAt(0);
						insertedTextFlow.replaceChildren(0, 1, null);
						nextInsertionPosition = TextFlowEdit.insertTextFlow(theFlow, nextInsertionPosition, tempFlChild as FlowGroupElement, missingBeginElementsInFlow, missingEndElementsInFlow, separatorArray);
					}
				}
				
				if (insertedTextFlow is TextFlow)
				{
					theFlow.replaceChildren(theFlow.numChildren - 1, theFlow.numChildren, null);
					if (nextInsertionPosition >= theFlow.textLength)
					{
						nextInsertionPosition = theFlow.textLength - 1;
					}
					separatorArray.pop();					
				}				
			} else {
				//if you are inserting at the very end of a paragraph, bump up the position
				//by one.  Otherwise, if you are not at the end of the paragraph, split at
				//the position, and then move up by 1.
										
				var leafEl:FlowLeafElement = null;
				if (pos > 0) leafEl = theFlow.findLeaf(pos - 1);
				var para:ParagraphElement = theFlow.findAbsoluteParagraph(pos);
				var paraSplitIndex:int = pos - para.getAbsoluteStart();
				var flowElIndex:int = para.parent.getChildIndex(para);
				var okToMergeWithAfter:Boolean = true;
				
				if (paraSplitIndex > 0)
				{
					if (paraSplitIndex < (para.textLength - 1))
					{
						
						para.splitAtPosition(paraSplitIndex);
						
					} else if ((insertedTextFlow.textLength == 1) && !processedFirstFlowElement) {
						if (TextFlowEdit.isFlowElementInArray(missingEndElementsInFlow, insertedTextFlow) ||
							TextFlowEdit.isFlowElementInArray(missingBeginElementsInFlow, insertedTextFlow))
						{ 
							processedFirstFlowElement = true;
							return nextInsertionPosition;
						} else {
							
							para.splitAtPosition(paraSplitIndex);
									
						}
					} else {
						okToMergeWithAfter = false;
					}
					pos++;
				} else { //no split done. So we want to insert after the previous paragraph.
					flowElIndex = flowElIndex - 1;
				}
			
				//insert the insertedTextFlow after the paragraph at paragraphIndex
				var paragraphContainer:FlowGroupElement = para.parent;
				
				if (TextFlowEdit.isContainerSeparator(paragraphContainer, separatorArray))
				{
					flowElIndex = paragraphContainer.parent.getChildIndex(paragraphContainer);
					paragraphContainer = paragraphContainer.parent;
					flowElIndex--;	
				}
				
				paragraphContainer.replaceChildren(flowElIndex + 1, flowElIndex + 1, insertedTextFlow);
				nextInsertionPosition = pos + insertedTextFlow.textLength;

				if (insertedTextFlow is ParagraphElement)
				{	
					var missingEnd:Boolean = TextFlowEdit.isFlowElementInArray(missingEndElementsInFlow, insertedTextFlow);
					if (okToMergeWithAfter && missingEnd)
					{
						// Merge the paragraph with what comes next. If the inserted paragraph is inserted to the middle or end of the paragraph,
						// then merge the next paragraph into the inserted paragraph. If we're inserting to the start of the paragraph, merge
						// the inserted paragraph into the next paragraph, so that the original host paragraph maintains its format settings.
						if (paraSplitIndex == 0)
						{
							if (joinToNextParagraph(ParagraphElement(insertedTextFlow)))
								nextInsertionPosition--;
						}
						else if (joinNextParagraph(ParagraphElement(insertedTextFlow)))
							nextInsertionPosition--;
					}

					if (!processedFirstFlowElement)
					{
						if (paraSplitIndex > 0)
						{
							var prevSibling:ParagraphElement = insertedTextFlow.getPreviousSibling() as ParagraphElement;
							if (prevSibling && joinNextParagraph(prevSibling))
								nextInsertionPosition--;
						}
					}
					
					if (missingEnd)
					{
						var absolutePar:ParagraphElement = paragraphContainer.getTextFlow().findAbsoluteParagraph(nextInsertionPosition);
						var absoluteParIndex:int = absolutePar.getAbsoluteStart();
						if ((nextInsertionPosition - absolutePar.getAbsoluteStart()) == 0)
						{
							nextInsertionPosition--;
						}
					}
				}
				
				
				processedFirstFlowElement = true;			
			}
			return nextInsertionPosition;
		}
		
		/**
		 * Replaces the range of text positions that the <code>startPos</code> and
		 * <code>endPos</code> parameters specify with the <code>newTextFlow</code> parameter in
		 * <code>theFlow</code>.
		 * <p>To delete elements, pass <code>null</code> for <code>newTextFlow</code>.</p>
		 * <p>To insert an element, pass the same value for <code>startPos</code> and <code>endPos</code>.
		 * <p>To insert a newline after the <code>newTextFlow</code> is inserted, pass in
		 * <code>true</code> for <code>insertParAfter</code></p>   
		 * <p>The new element will be inserted before the specified index.</p>
		 * <p>To append the TextFlow, pass <code>theFlow.length</code> for <code>startPos</code> and <code>endPos</code>.</p>
		 * 
		 * @param theFlow The TextFlow that is being inserted into.
		 * @param startPos The index value of the first position of the replacement range in the TextFlow.
		 * @param endPos The index value following the end position of the replacement range in the TextFlow.
		 * @param newTextFlow The TextFlow to be merged into theFlow.
		 * @param missingBeginElementsInFlow Array indicating all the elements within the TextFlow that have their beginning parts chopped off.
		 * @param missingEndElementsInFlow Array indicating all the elements within the TextFlow that have their ending parts chopped off.
		 */				
		public static function replaceRange(theFlow:TextFlow, startPos:int, endPos:int, textScrap:TextScrap = null):int
		{
			var nextInsertPosition:int = startPos;
			if (endPos > startPos)
			{
				deleteRange(theFlow, startPos, endPos);
			}
			
			if (textScrap != null)
			{
				textScrap = textScrap.clone();	// make a copy so the original isn't mutated
				nextInsertPosition = insertTextFlow(theFlow, startPos, textScrap.textFlow, textScrap.beginMissingArray, textScrap.endMissingArray);	
			}
			return nextInsertPosition;
		}

		/**
		 * Creates a copy of the TextFlow in between two positions and returns the TextFlow
		 * within a TextScrap object.  See TextScrap for more information.
		 * @param theFlow The TextFlow that is being copied from.
		 * @param startPos The index value of the first position of the TextFlow being copied from.
		 * @param endPos The index value following the end position of the TextFlow being copied from.
		 */			 
		public static function createTextScrap(theFlow:TextFlow, startPos:int, endPos:int):TextScrap
		{
			if (!theFlow || startPos >= endPos) 
				return null;
			var newTextFlow:TextFlow = theFlow.deepCopy(startPos, endPos) as TextFlow;
			newTextFlow.normalize();
			var retTextScrap:TextScrap = new TextScrap(newTextFlow);
			if (newTextFlow.textLength > 0)
			{
				var fl:FlowElement = newTextFlow.getLastLeaf();
			
				var srcElem:FlowElement = theFlow.findLeaf(startPos);
				var copyElem:FlowElement = newTextFlow.getFirstLeaf();
				while (copyElem && srcElem)
				{
					if ((startPos - srcElem.getAbsoluteStart()) > 0)
					{
						retTextScrap.addToBeginMissing(copyElem);
					}
					copyElem = copyElem.parent;
					srcElem = srcElem.parent;
				}
			
				srcElem = theFlow.findLeaf(endPos - 1);
				copyElem = newTextFlow.getLastLeaf();
				if ((copyElem is SpanElement) && (!(srcElem is SpanElement)))
				{
					copyElem = newTextFlow.findLeaf(newTextFlow.textLength - 2);
				}
				
				while (copyElem && srcElem)
				{
					if (endPos < (srcElem.getAbsoluteStart() + srcElem.textLength))
					{
						retTextScrap.addToEndMissing(copyElem);
					}
					copyElem = copyElem.parent;
					srcElem = srcElem.parent;
				}
				return retTextScrap;
			}
			return null;
		}		
		
		/**
		 * Creates a TCY run out of the selected positions.
		 * @param theFlow The TextFlow of interest.
		 * @param startPos The index value of the first position of the TextFlow to be turned into a TCY run.
		 * @param endPos The index value following the end position of the TextFlow to be turned into a TCY run.
		 */	
		public static function makeTCY(theFlow:TextFlow, startPos:int, endPos:int):Boolean
		{
			var madeTCY:Boolean = true;
			var curPara:ParagraphElement = theFlow.findAbsoluteParagraph(startPos);
			if(!curPara)
				return false;
			while(curPara)
			{
				var paraEnd:int = curPara.getAbsoluteStart() + curPara.textLength;
				var curEndPos:int = Math.min(paraEnd, endPos);
				
				//we have an entire para selected and the para only contains a kParaTerminator char, which cannot be
				//made into TCY. 
				if(canInsertSPBlock(theFlow, startPos, curEndPos, TCYElement) && curPara.textLength > 1)
				{
					var new_tcyElem:TCYElement = new TCYElement();
					
					//don't hide an error!
					if(madeTCY)
						madeTCY = insertNewSPBlock(theFlow, startPos, curEndPos, new_tcyElem, TCYElement);
					else
						insertNewSPBlock(theFlow, startPos, curEndPos, new_tcyElem, TCYElement);
				}
				else
					madeTCY = false;
				
				if(paraEnd < endPos)
				{
					curPara = theFlow.findAbsoluteParagraph(curEndPos);	
					startPos = curEndPos;
				}
				else
					curPara = null;
			}
			
			return madeTCY;
		}
		
		/**
		 * Creates one or more LinkElements out of the selected positions. It will go through
		 * every paragraph within the selected position and make links.
		 * @param theFlow The TextFlow of interest.
		 * @param startPos The index value of the first position of the TextFlow to be turned into a link.
		 * @param endPos The index value following the end position of the TextFlow to be turned into a link.
		 * @param urlString The url string to be associated with the link.
		 */			
		public static function makeLink(theFlow:TextFlow, startPos:int, endPos:int, urlString:String, target:String):Boolean
		{
			var madeLink:Boolean = true;
			var curPara:ParagraphElement = theFlow.findAbsoluteParagraph(startPos);
			if(!curPara)
				return false;
				
			while(curPara)
			{
				var paraEnd:int = curPara.getAbsoluteStart() + curPara.textLength;
				var curEndPos:int = Math.min(paraEnd, endPos);
				var linkEndPos:int = (curEndPos == paraEnd) ? (curEndPos - 1) : curEndPos;
				if (linkEndPos > startPos)
				{
					//if the end of the paragraph is < endPos, we are going across bounds
					if(!canInsertSPBlock(theFlow, startPos, linkEndPos, LinkElement))
					{
						return false;
					}
				
					var newLinkElement:LinkElement = new LinkElement();
					newLinkElement.href = urlString;
					newLinkElement.target = target;
				
					//don't hide an error!
					if(madeLink)
						madeLink = insertNewSPBlock(theFlow, startPos, linkEndPos, newLinkElement, LinkElement);
					else
						insertNewSPBlock(theFlow, startPos, linkEndPos, newLinkElement, LinkElement);
				}	
				if(paraEnd < endPos)
				{
					curPara = theFlow.findAbsoluteParagraph(curEndPos);	
					startPos = curEndPos;
				}
				else
					curPara = null;
			}
			
			return madeLink;
		}
		
		
		/**
		 * Removes the TCY block at the selected positions. 
		 * @param theFlow The TextFlow of interest.
		 * @param startPos The index value of the first position of the TextFlow.
		 * @param endPos The index value following the end position of the TextFlow.
		 */			
		public static function removeTCY(theFlow:TextFlow, startPos:int, endPos:int):Boolean
		{
			if (endPos <= startPos)
			{
				return false;
			}
			
			return findAndRemoveFlowGroupElement(theFlow, startPos, endPos, TCYElement);;
		}
		
		/**
		 * Removes all LinkElements under the selected positions. It will go through
		 * every paragraph within the selected position and remove any link.
		 * @param theFlow The TextFlow of interest.
		 * @param startPos The index value of the first position of the TextFlow.
		 * @param endPos The index value following the end position of the TextFlow.
		 */			
		public static function removeLink(theFlow:TextFlow, startPos:int, endPos:int):Boolean
		{
			if (endPos <= startPos)
			{
				return false;
			}
			
			return findAndRemoveFlowGroupElement(theFlow, startPos, endPos, LinkElement);
		}
		
		/**
		 * @private
		 * insertNewSPBlock - add a SubParagraphGroupElement (spg) to <code>theFlow</code> at the indicies specified by <code>startPos</code> and
		 * <code>endPos</code>.  The <code>newSPB</code> will take ownership of any FlowElements within the range and will split them
		 * as needed.  If the parent of the FlowGroupElement indicated by <code>startPos</code> is the same as <code>spgClass</code> then
		 * the method fails and returns false because a spg cannot own children of the same class as itself.  Any spg of type <code>spgClass</code>
		 * found within the indicies, however, is subsumed into <code>newSPB</code>, effectively replacing it.
		 *
		 * @param theFlow:TextFlow - The TextFlow that is the destination for the newSPB
		 * @param startPos:int - The absolute index value of the first position of the range in the TextFlow to perform the insertion.
		 * @param endPos:int - The index value following the end position of the range in the TextFlow to perform the insertion.
		 * @param newSPB:SubParagraphGroupElement - The new SubParagraphElement which is to be added into theFlow.
		 * @param spgClass:Class - the class of the fbe we intend to add.
		 * 
		 * Examples: Simple and complex where insertion is of <code>spgClass</code> b.  Selection is l~o
		 *		1) <a><span>ghijklmnop</span></a>
		 * 		2) <a><span>ghij</span><b><span>klm</span></b><span>nop</span></a>
		 * 		3) <a><span>ghijk</span><c><span>lmn</span></c><span>op</span></a>
		 * 
		 */
		tlf_internal static function insertNewSPBlock(theFlow:TextFlow, startPos:int, endPos:int, newSPB:SubParagraphGroupElement, spgClass:Class):Boolean
		{
			var curPos:int = startPos;
			var curFBE:FlowGroupElement = theFlow.findAbsoluteFlowGroupElement(curPos);
			var elementIdx:int = 0;
			
			CONFIG::debug{ assert(curFBE != null, "No FBE at location curPos(" + curPos + ")!");}
			
			//if we are at the last "real" glyph of the paragraph, include the terminator.
			var paraEl:ParagraphElement = curFBE.getParagraph();
			if(endPos == (paraEl.getAbsoluteStart() + paraEl.textLength - 1))
				++endPos;
			
			//before processing this any further, we need to make sure that we are not
			//splitting a spg which is contained within the same type of spg as the curFBE's parent.
			//for example, if we had a tcyElement inside a linkElement, then we cannot allow a link element
			//to be made within the tcyElement as the link would not function.  As a rule, a SubParagraphElement
			//cannot own a child of the same class.
			//
			//However, if the curFBE is parented by a spg and the objects have the same start and end, then we are doing
			//a replace and we're not splitting the parent. Check if the bounds are the same and if so, don't skip it...
			var parentStart:int = curFBE.parent.getAbsoluteStart();
			var curFBEStart:int = curFBE.getAbsoluteStart();
			if(curFBE.parent && curFBE.parent is spgClass && 
				!(parentStart == curFBEStart && parentStart + curFBE.parent.textLength == curFBEStart + curFBE.textLength))
			{
				return false;
			}
			
			//entire FBE is selected and is not a paragraph, get its parent.
			if(!(curFBE is ParagraphElement) && curPos == curFBEStart && curPos + curFBE.textLength <= endPos)
			{
				elementIdx = curFBE.parent.getChildIndex(curFBE);
				curFBE = curFBE.parent;
			}
			//first, if the curFBE is of the same class as the newSPB, then we need to split it to allow for insertion
			//of the new one IF the start position is > the start of the curFBE
			//
			//running example after this block:
			//	1) <a><span>ghijk</span><span>lmnop</span></a>
			//	2) <a><span>ghij</span><b><span>k</span></b><b><span>lm</span></b><span>nop</span></a>
			//	3) <a><span>ghijk</span><c><span>lmn</span></c><span>op</span></a> - no change
			if(curPos >= curFBEStart)
			{
				if(!(curFBE is spgClass))
					elementIdx = findAndSplitElement(curFBE, elementIdx, curPos, true);
				else
				{
					elementIdx = findAndSplitElement(curFBE.parent, curFBE.parent.getChildIndex(curFBE), curPos, false);
					curFBE = curFBE.parent;
				}
			}
			
			//now that the curFBE has been split, we want to insert the newSPB into the flow and then start absorbing the
			//contents...
			//running example after this block:
			//	1) <a><span>ghijk</span><b></b><span>lmnop</span></a>
			//	2) <a><span>ghij</span><b><span>k</span></b><b></b><b><span>lm</span></b><span>nop</span></a>
			//	3) <a><span>ghijk</span><b></b><c><span>lmn</span></c><span>op</span></a> - no change
			//
		//	we need another use case here where selection is entire sbp and selection runs from the head of a spg to
		//	part way through it - so that a) does into parent and b) goes into spg
			
			// if this is case 2, then the new element must go into the parent...
			if(curFBE is spgClass)
			{
				curFBEStart = curFBE.getAbsoluteStart();
				elementIdx = curFBE.parent.getChildIndex(curFBE);
				if(curPos > curFBEStart)//we're splitting the element, not replacing it...
					elementIdx += 1;
				
				//if the spg, curFBE is entirely selected then we want to use the parent, not the item itself.
				while(endPos >= curFBEStart + curFBE.textLength)
				{
					//we need access to the parent, which contains both the start and end not the FBE we just split
					curFBE = curFBE.parent;
				}
				curFBE.replaceChildren(elementIdx, elementIdx, newSPB);
			}
			else
			{
				//we're inserting into the curFBE
				curFBE.replaceChildren(elementIdx, elementIdx, newSPB);
			}
			
			//see subsumeElementsToSPBlock to see effects on running example
			subsumeElementsToSPBlock(curFBE, elementIdx + 1, curPos, endPos, newSPB, spgClass);
			
			return true;
		}
		
		
		/**
		 * @private
		 * splitElement - split <code>elem</code> at the relative index of <code>splitPos</code>.  If <code>splitSubBlockContents</code>
		 * is true, split the contents of <code>elem</code> if it is a SubParagraphGroupElement, otherwise just split <code>elem</code>
		 * 
		 * @param elem:FlowElement - the FlowElement to split
		 * @param splitPos:int - The elem relative index indicating where to split
		 * @param splitSubBlockContents:Boolean - boolean indicating whether a SubParagraphGroupElement is to be split OR that it's contents
		 * should be split.  For example, are we splitting a link or are we splitting the child of the link
		 * 
		 * <spg><span>ABCDEF</span></spg>
		 * 
		 * if <code>splitPos</code> indicated index between C and D, then if <code>splitSubBlockContents</code> equals true,
		 * result is:
		 * 
		 * <spg><span>ABC</span><span>DEF</span></spg>
		 * 
		 * if <code>splitSubBlockContents</code> equals false, result is:
		 * 
		 * <spg><span>ABC</span></spg><spg><span>DEF</span></spg>
		 */
		tlf_internal static function splitElement(elem:FlowElement, splitPos:int, splitSubBlockContents:Boolean):void
		{
			CONFIG::debug{ assert(splitPos < elem.textLength, "trying to splic FlowElement at illegal index!"); }
			if (elem is SpanElement)
			{
				SpanElement(elem).splitAtPosition(splitPos);
			}
			else if(elem is SubParagraphGroupElement && splitSubBlockContents)
			{
				var subBlock:SubParagraphGroupElement = SubParagraphGroupElement(elem);
				// Split the SpanElement of the block at splitPos.  If the item at the splitPos is not a SpanElement, no action occurs.
				var tempElem:SpanElement = subBlock.findLeaf(splitPos) as SpanElement;
				if (tempElem)
					tempElem.splitAtPosition(splitPos - tempElem.getElementRelativeStart(subBlock));
			}
			else if (elem is FlowGroupElement)
			{
				FlowGroupElement(elem).splitAtPosition(splitPos);
			}
			else
			{
				CONFIG::debug { assert(false, "Trying to split on an illegal FlowElement"); }				
			}
		}
		
		/**
		 * @private
		 * findAndSplitElement - starting at the child <code>elementIdx</code> of <code>fbe</code>, iterate
		 * through the elements untill we find the one located at the aboslute index of <code>startIdx</code>. Upon
		 * locating the child, split either the element itself OR its children based on the value of <code>splitSubBlockContents</code>
		 * 
		 * @param fbe:FlowGroupElement - the FBE into which the newSPB is being inserted.
		 * @param elementIdx:int - The index into the <code>fbe's</code> child list to start
		 * @param startIdx:int - The absolute index value into the TextFlow.
		 * @param splitSubBlockContents:Boolean - boolean indicating whether a subElement is to be split OR that it's contents
		 * should be split.  For example, are we splitting a link or are we splitting the child of the link
		 * 
		 * <p>ZYX<link>ABCDEF</link>123</p>
		 * 
		 * if we are inserting a TCY into the link, splitSubBlockContents should be false. We want to split the span ABCDEF such that result is:
		 * <p>ZYX<link>AB<tcy>CD</tcy>EF</link>123</p>
		 * 
		 * if we are creating a new link from X to B, then we want the link to split and splitSubBlockContents should be false:
		 * 
		 * <p>ZY<link>XAB</link><link>CDEF</link>123</p>
		 * 
		 * @return int - the index of the last child of <code>fbe</code> processed.
		 */
		tlf_internal static function findAndSplitElement(fbe:FlowGroupElement, elementIdx:int, startIdx:int, splitSubBlockContents:Boolean):int
		{
			var curFlowEl:FlowElement = null;
			var curIndexInPar:int = startIdx - fbe.getAbsoluteStart();
			
			while(elementIdx < fbe.numChildren)
			{
				curFlowEl = fbe.getChildAt(elementIdx);
				if (curIndexInPar == curFlowEl.parentRelativeStart)
					return elementIdx;
				if ((curIndexInPar > curFlowEl.parentRelativeStart) && (curIndexInPar < curFlowEl.parentRelativeEnd))
				{
					splitElement(curFlowEl, curIndexInPar - curFlowEl.parentRelativeStart, splitSubBlockContents); 
				}
				++elementIdx;
			}
			return elementIdx;
		}
		
		/**
		 * @private
		 * subsumeElementsToSPBlock - incorporates all elements of <code>parentFBE</code> into
		 * the <code>newSPB</code> between the <code>curPos</code> and <code>endPos</code>.  If a child of
		 * <code>parentFBE</code> is of type <code>spgClass</code> then the child's contents are removed from the child,
		 * added to the <code>newSPB</code>, the child is then removed from the <code>parentFBE</code>
		 * 
		 * @param parentFBE:FlowGroupElement - the FBE into which the newSPB is being inserted.
		 * @param startPos:int - The index value of the first position of the replacement range in the TextFlow.
		 * @param endPos:int - The index value following the end position of the replacement range in the TextFlow.
		 * @param newSPB:SubParagraphGroupElement - the new SubParagraphGroupElement we intend to insert.
		 * @param spgClass:Class - the class of the fbe we intend to insert.
		 * 
		 * @return int - the aboslute index in the text flow after insertion.
		 * 
		 *  Examples: Simple and complex where insertion is of <code>spgClass</class> b.  Selection is l~o
		 *		1) <a><span>ghijk</span><b></b><span>lmnop</span></a>
		 *		2) <a><span>ghij</span><b><span>k</span></b><b></b><b><span>lm</span></b><span>nop</span></a>
		 * 
		 * 	parentFBE = <a>
		 *  elementIdx = 1) 2, 2) 3
		 *  curPos = 5
		 *  endPos = 9
		 *  newSPB is of type <b>
		 */
		tlf_internal static function subsumeElementsToSPBlock(parentFBE:FlowGroupElement, elementIdx:int, curPos:int, endPos:int, newSPB:SubParagraphGroupElement, spgClass:Class):int
		{
			var curFlowEl:FlowElement = null;
			
			//if we have an invalid index, then skip out.  elementIdx will always point one
			//element beyond the one we are inserting....
			if(elementIdx >= parentFBE.numChildren)
				return curPos;
			
			while (curPos < endPos)
			{
				//running example: curFlowEl is the element immediately after the inserted newSPB:
				//	1) <a><span>ghijk</span><b></b><span>lmnop</span></a>
				//		points to span-lmnop
				//	2) <a><span>ghij</span><b><span>k</span></b><b></b><b><span>lm</span></b><span>nop</span></a>
				//		points to b-lm
				curFlowEl = parentFBE.getChildAt(elementIdx);
				
				//if the curFlowEl is of the Class we are adding (spgClass), and the entire thing is selected,
				//then we are adding the entire block, but not spliting it - perform the split on the next block
				
				//I think this can be safely removed from here as ownership of contents is handled below.
				//leaving in commented out code in case we need to revert - gak 05.01.08
			/*	if(curFlowEl is spgClass && curPos == curFlowEl.getAbsoluteStart() && curFlowEl.getAbsoluteStart() + curFlowEl.textLength <= endPos)
				{
					curPos = parentFBE.getAbsoluteStart() + parentFBE.textLength;
					continue;
				}*/
				
				//if the endPos is less than the length of the curFlowEl, then we need to split it.
				//if the curFlowEl is NOT of class type spgClass, then we need to break it
				//
				//Use case: splitting a link in two (or three as will be the result with head and tail sharing
				//attributes...
				//running example 1 hits this, but 2 does not. Using variation of 2:
				//
				// example: 1) <a><span>ghijk</span><b></b><span>lmnop</span></a>
				// 			2a) <a><span>fo</span><b></b><b><span>obar</span></b></a> - selection: from o~a
				//
				// after this code:
				//			1) <a><span>ghijk</span><b></b><span>lmno</span><span>p</span></a>
				//			2a) <a><span>fo</span><b></b><b><span>oba</span></b><b><span>or</span></b></a>
				if ((curPos + curFlowEl.textLength) > endPos)
				{
					splitElement(curFlowEl, endPos - curFlowEl.getAbsoluteStart(), !(curFlowEl is spgClass));  //changed to curFlowEl from newSPB as newSPB should be of type spgClass
				}
				
				//add the length before replacing the elements
				curPos += curFlowEl.textLength;
				
				//running example: after parentFBE.replaceChildren
				//
				//	1) curFlowEl = <span>lmno</span>
				//		<a><span>ghijk</span><b></b>{curFlowEl}<span>p</span></a>
				//
				//	2) curFlowEl = <b><span>lm</span></b>
				//		<a><span>ghij</span><b><span>k</span></b><b></b>{curFlowEl}<span>nop</span></a>
				parentFBE.replaceChildren(elementIdx, elementIdx + 1, null);
				
				//if the curFlowEl is of type spgClass, then we need to take its children and
				//add them to the newSPB because a spg cannot contain a child of the same class
				//as itself
				//
				// exmaple: 2) curFlowEl = <b><span>lm</span></b>
				if (curFlowEl is spgClass)
				{
					var subBlock:SubParagraphGroupElement = curFlowEl as SubParagraphGroupElement;
					//elementCount == 1 - <span>lm</span>
					while (subBlock.numChildren > 0)
					{
						//fe[0] = <span>lm</span>
						var fe:FlowElement = subBlock.getChildAt(0);
						//<span></span>
						subBlock.replaceChildren(0, 1, null);
						//<b><span>lm</span></b>
						newSPB.replaceChildren(newSPB.numChildren, newSPB.numChildren, fe);
					}
					//when compelete, example 2 is:
					//2) <a><span>ghij</span><b><span>k</span></b><b><span>lm</span></b><span>nop</span></a>
				}
				else 
				{
					//example 1, curFlowEl is <span>lmno</span>, so this is not hit
					//
					// extending element <a> from foo~other
					// <a>foo</a><b>bar<a>other</a><b>
					// curFlowEl = <b>bar<a>other</a><b>
					//
					// since <b> is a spg, we need to walk it's contents and remove any <a> elements
					if(curFlowEl is SubParagraphGroupElement)
					{
						//we need to dive into this spgClass and remove any fbes of type spgClass
						//pass in the curFlowEl as the newSPB, remove any spgs of type spgClass, then 
						//perform the replace on the newSPB passed in here
						//
						//ignore the return value of the recursive call as the length has already been
						//accounted for above
						flushSPBlock(curFlowEl as SubParagraphGroupElement, spgClass);
					}
					newSPB.replaceChildren(newSPB.numChildren, newSPB.numChildren, curFlowEl);
					
					if(newSPB.numChildren == 1 && curFlowEl is SubParagraphGroupElement)
					{
						var childSPGE:SubParagraphGroupElement = curFlowEl as SubParagraphGroupElement;
						//running example:
						//a.precedence = 800, tcy.precedence = kMinSPGEPrecedence
						//this = <tcy><a><span>fooBar</span></a><tcy>
						//childSPGE = <a><span>fooBar</span></a>
						if(childSPGE.textLength == newSPB.textLength && (curPos >= endPos))
						{
							CONFIG::debug { assert(childSPGE.precedence != newSPB.precedence, "normalizeRange found two equal SPGEs"); }
	
							//if the child's precedence is higher than mine, I need to swap
							if(childSPGE.precedence > newSPB.precedence)
							{
								//first, remove the child
								//this = <tcy></tcy>
								newSPB.replaceChildren(0,1,null);
								
								//we need to flop this object for the child
								while(childSPGE.numChildren > 0)
								{
									//tempFE = <span>fooBar</span>
									var tempFE:FlowElement = childSPGE.getChildAt(0);
									//child = <a></a>
									childSPGE.replaceChildren(0,1,null);
									//this = <tcy><span>fooBar</span></tcy>
									newSPB.replaceChildren(newSPB.numChildren, newSPB.numChildren, tempFE);
								}
								
								var myIdx:int = newSPB.parent.getChildIndex(newSPB);
								CONFIG::debug{ assert(myIdx >= 0, "Invalid index!  How can a SubParagraphGroupElement normalizing not have a parent!"); }
								
								//add childSPGE in my place
								newSPB.parent.replaceChildren(myIdx, myIdx + 1, childSPGE)
								
								//childSPGE = <tcy><a><span>fooBar</span></a></tcy>
								childSPGE.replaceChildren(0,0,newSPB);
							}
						}
					}
				}
				
			}
	
			return curPos;
		}
		
		/**
		 * @private
		 * findAndRemoveFlowGroupElement 
		 *
		 * @param theFlow The TextFlow that is containing the elements to remove.
		 * @param startPos The index value of the first position of the range in the TextFlow where we want to perform removal.
		 * @param endPos The index value following the end position of the range in the TextFlow where we want to perform removal.
		 * @param fbeClass Class the class of the fbe we intend to remove.
		 * 
		 * Walks through the elements of <code>theFlow</code> looking for any FlowGroupElement of type <code>fbeClass</class>
		 * On finding one, it removes the FBE's contents and adds them back into the FBE's parent.  If the class of object is
		 * embedded within another spg and this removal would break the parent spg, then the method does nothing.
		 * 
		 * Example:
		 * 	<link>ABC<tcy>DEF</tcy>GHI</link>
		 * 	Selection is on E and removal of link is attempted.
		 * 	Because E is a child of a spg (tcy), and removing the link from E would split the parent spg (link),
		 *  the action is disallowed.
		 * 
		 * Running example:
		 * 	1) <link><tcy><span>foo</span></tcy><span>bar</span></link>
		 * @return Boolean - true if items are removed or none are found.  false if operation is illegal.
		 */ 
		tlf_internal static function findAndRemoveFlowGroupElement(theFlow:TextFlow, startPos:int, endPos:int, fbeClass:Class):Boolean
		{
			var curPos:int = startPos;
			var curEl:FlowElement;
			
			//walk through the elements
			while (curPos < endPos)
			{
				var containerFBE:FlowGroupElement = theFlow.findAbsoluteFlowGroupElement(curPos);
				
				//if the start of the parent is the same as the start of the current containerFBE, then
				//we potentially have the wrong object.  We need to walk up the parents until we get to
				//the one which starts at our start AND is the topmost object at that index.
				//example: <a><b>foo</b> bar</a> - getting the object at "f" will yield the <b> element, not <a>
				while(containerFBE.parent && containerFBE.parent.getAbsoluteStart() == containerFBE.getAbsoluteStart() && 
					!(containerFBE.parent is ParagraphElement)) //don't go beyond paragraph
				{
					containerFBE = containerFBE.parent;
				}
				
				//if the absoluteFBE is the item we are trying to remove, we need to work with its parent, so
				//reassign containerFBE.  For example, if an entire link were selected, we'd need to get it's parent to
				//perform the removal
				if(containerFBE is fbeClass)
					containerFBE = containerFBE.parent;
					
				//before processing this any further, we need to make sure that we are not
				//splitting a spg which is contained within the same type of spg as the curFBE's parent.
				//for example, if we had a tcyElement inside a linkElement, then we cannot allow a link element
				//to be broken within the tcyElement as the link would have to split the TCY.
				var ancestorOfFBE:FlowGroupElement = containerFBE.parent;
				while(ancestorOfFBE != null && !(ancestorOfFBE is fbeClass))
				{
					if(ancestorOfFBE.parent is fbeClass)
					{
						return false;
					}
					ancestorOfFBE = ancestorOfFBE.parent;
				}
				
				//if this is a sbe block contained in another sbe, and it is entire within the 
				//selection bounds, we need to use the parent sbe's container.  If it is splitting
				//the child sbe, we don't allow this and it is handled later...
				var containerFBEStart:int = containerFBE.getAbsoluteStart();
				if(ancestorOfFBE is fbeClass && (containerFBEStart >= curPos && containerFBEStart + containerFBE.textLength <= endPos))
					containerFBE = ancestorOfFBE.parent;
					
				var childIdx:int = containerFBE.findChildIndexAtPosition(curPos - containerFBEStart);
				curEl = containerFBE.getChildAt(childIdx);
				if(curEl is fbeClass)
				{
					CONFIG::debug{ assert(curEl is SubParagraphGroupElement, "Wrong FBE type!  Trying to remove illeage FBE!") };
					var curFBE:FlowGroupElement = curEl as FlowGroupElement;
					
					//get it's parent and the index of the curFBE
					var parentBlock:FlowGroupElement = curFBE.parent;
					var idxInParent:int = parentBlock.getChildIndex(curFBE);
					
					//if the curPos is not at the head of the SPB, then we need to split it here
					//curFBE will point to the FBE starting at curPos
					if(curPos > curFBE.getAbsoluteStart())
					{
						splitElement(curFBE, curPos - curFBE.getAbsoluteStart(), false);
						curPos = curFBE.getAbsoluteStart() + curFBE.textLength;
						continue;
					}
					
					//if curFBE goes beyond the endPos, then we need to split off the tail.
					if (curFBE.getAbsoluteStart() + curFBE.textLength > endPos)
					{
						splitElement(curFBE, endPos - curFBE.getAbsoluteStart(), false);
					}
				
					//apply the length of the curFBE to the curPos tracker.  Do this before 
					//removing the contents or it will be 0!
					curPos = curFBE.getAbsoluteStart() + curFBE.textLength;
					
					//walk all the contents of the FBE into it's parent container
					while (curFBE.numChildren > 0)
					{
						var childFE:FlowElement = curFBE.getChildAt(0);
						curFBE.replaceChildren(0, 1, null);
						parentBlock.replaceChildren(idxInParent, idxInParent, childFE);
						idxInParent++; 
					}
					
					//remove the curFBE
					parentBlock.replaceChildren(idxInParent, idxInParent + 1, null);
				}
				else if(curEl is SubParagraphGroupElement) //check all the parents...
				{
					var curSPB:SubParagraphGroupElement = SubParagraphGroupElement(curEl);
					if(curSPB.numChildren == 1)
						curPos = curSPB.getAbsoluteStart() + curSPB.textLength;
					else
					{
						curEl = curSPB.getChildAt(curSPB.findChildIndexAtPosition(curPos - curSPB.getAbsoluteStart()));
						curPos = curEl.getAbsoluteStart() + curEl.textLength;
					}
				}
				else
				{
					//the current block isn't the type we're looking for, so just go to the end of the
					//FlowElement and continue
					curPos = curEl.getAbsoluteStart() + curEl.textLength;
				}
				
			}
			
			return true;
		}
		
		/**
		 * @private
		 * canInsertSPBlock 
		 * 
		 * validate that we a valid selection to allow for insertion of a subBlock.  The rules are as
		 * follows:
		 * 	endPos > start
		 * 	the new block will not span multiple paragraphs
		 *  if the block is going into a SubParagraphGroupElement, it must not split the block:
		 * 		example:  Text 		- ABCDEFG with a link on CDE
		 * 		legal new Block		- D, CD, CDE, [n-chars]CDE[n1-chars]
		 * 		illegal new Block 	- [1 + n-chars]C[D], [D]E[1 + n-chars]
		 * 			exception - if the newBlock is the same class as the one we are trying to split
		 * 			then we can truncate the original and add its contents to the new one, or extend it
		 * 			as appropriate
		 * 
		 * @param theFlow The TextFlow that is containing the elements to validate.
		 * @param startPos The index value of the first position of the range in the TextFlow to test.
		 * @param endPos The index value following the end position of the range in the TextFlow to test.
		 * @param blockClass Class the class of the fbe we intend to insert.
		 */
		tlf_internal static function canInsertSPBlock(theFlow:TextFlow, startPos:int, endPos:int, blockClass:Class):Boolean
		{
			if(endPos <= startPos)
				return false;
				
			var anchorFBE:FlowGroupElement = theFlow.findAbsoluteFlowGroupElement(startPos);
			if(anchorFBE.getParentByType(blockClass))
				anchorFBE = anchorFBE.getParentByType(blockClass) as FlowGroupElement;
				
			var tailFBE:FlowGroupElement = theFlow.findAbsoluteFlowGroupElement(endPos - 1);
			if(tailFBE.getParentByType(blockClass))
				tailFBE = tailFBE.getParentByType(blockClass) as FlowGroupElement;
			
			//if these are the same FBEs then we are safe to insert a SubParagraphGroupElement
			if(anchorFBE == tailFBE)
				return true;
			//make sure that the two FBEs belong to the same paragraph!
			else if(anchorFBE.getParagraph() != tailFBE.getParagraph())
				return false;
			else if(anchorFBE is blockClass && tailFBE is blockClass)//they're the same class, OK to merge, split, etc...
				return true;
			else if(anchorFBE is SubParagraphGroupElement && !(anchorFBE is blockClass))
			{
				var anchorStart:int = anchorFBE.getAbsoluteStart();
				if(startPos > anchorStart && endPos > anchorStart + anchorFBE.textLength)
					return false;
			}
			else if((anchorFBE.parent is SubParagraphGroupElement || tailFBE.parent is SubParagraphGroupElement)
				&& anchorFBE.parent != tailFBE.parent)
			{
				//if either FBE parent is a SPGE and they are not the same, prevent the split.  
				return false;
			}	
			
			//if we got here, then the anchorFBE is OK, check the tail.  If endPos is pointing to the
			//0th character of a FlowGroupElement, we don't need to worry about the tail.
			if(tailFBE is SubParagraphGroupElement && !(tailFBE is blockClass) && endPos > tailFBE.getAbsoluteStart())
			{
				var tailStart:int = tailFBE.getAbsoluteStart();
				if(startPos < tailStart && endPos < tailStart + tailFBE.textLength)
					return false;
			}	
			return true;
		}
		
		/**
		 * @private flushSPBlock recursively walk a spg looking for elements of type spgClass.  On finding one,
		 * remove it's children and then remove the object itself.  Since spg's cannot hold children of the same type
		 * as themselves, recursion is only needed for spg's of a class other than that of spgClass.
		 * 
		 * example: subPB = <b>bar<a>other</a><b> extending an <a> element to include all of "other"
		 */ 
		tlf_internal static function flushSPBlock(subPB:SubParagraphGroupElement, spgClass:Class):void
		{
			var subParaIter:int = 0;
	
			//example, subPB has 2 elements, <span>bar</span> and <a><span>other</span></a>
			while(subParaIter < subPB.numChildren)
			{
				//subParaIter == 0, subFE = <span>bar</span> skip the FE and move to next
				//subParaIter == 1, subFE = <a><span>other</span></a> - is a spgClass
				var subFE:FlowElement = subPB.getChildAt(subParaIter);
				if(subFE is spgClass)
				{
					//subParaIter == 1, subFE = <a><span>other</span></a>
					var subChildFBE:FlowGroupElement = subFE as FlowGroupElement;
					while(subChildFBE.numChildren > 0)
					{
						//subFEChild = <span>other</span>
						var subFEChild:FlowElement = subChildFBE.getChildAt(0);
						//subFEChild = <a></a>
						subChildFBE.replaceChildren(0, 1, null);
						//subPB = <b>barother<a></a><b>
						subPB.replaceChildren(subParaIter, subParaIter, subFEChild);
					}
					
					//increment so that subParaIter points to the element we just emptied
					++subParaIter;
					//remove the empty child
					//subPB = <b>barother<b>
					subPB.replaceChildren(subParaIter, subParaIter + 1, null);
				}
				else if(subFE is SubParagraphGroupElement)
				{
					flushSPBlock(subFE as SubParagraphGroupElement, spgClass);
					++subParaIter;
				}
				else
					++subParaIter;//go to next child
			}
		}
		/** Joins this paragraph's next sibling to this if it is a paragraph */
		static public function joinNextParagraph(para:ParagraphElement):Boolean
		{		
			if (para && para.parent)
			{
				var myidx:int = para.parent.getChildIndex(para);
				if (myidx != para.parent.numChildren-1)
				{
					// right now, you can only merge with other paragraphs
					var sibParagraph:ParagraphElement = para.parent.getChildAt(myidx+1) as ParagraphElement;
					if (sibParagraph)
					{						
						while (sibParagraph.numChildren > 0)
						{
							var curFlowElement:FlowElement = sibParagraph.getChildAt(0);
							sibParagraph.replaceChildren(0, 1, null);
							para.replaceChildren(para.numChildren, para.numChildren, curFlowElement);
						}
						para.parent.replaceChildren(myidx+1, myidx+2, null);
						return true;
					}
				}
			} 
			return false;
		}

		/** Joins this paragraph's next sibling to this if it is a paragraph */
		static public function joinToNextParagraph(para:ParagraphElement):Boolean
		{		
			if (para && para.parent)
			{
				var myidx:int = para.parent.getChildIndex(para);
				if (myidx != para.parent.numChildren-1)
				{
					// right now, you can only merge with other paragraphs
					var sibParagraph:ParagraphElement = para.parent.getChildAt(myidx+1) as ParagraphElement;
					if (sibParagraph)
					{			
						// Add the first paragraph's children to the front of the next paragraph's child list
						var addAtIndex:int = 0;
						while (para.numChildren > 0)
						{
							var curFlowElement:FlowElement = para.getChildAt(0);
							para.replaceChildren(0, 1, null);
							sibParagraph.replaceChildren(addAtIndex, addAtIndex, curFlowElement);
							++addAtIndex;
						}
						para.parent.replaceChildren(myidx, myidx+1, null);
						return true;
					}
				}
			} 
			return false;
		}

								
	}
}
