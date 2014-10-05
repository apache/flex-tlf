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
package flashx.textLayout.elements 
{
	import flash.display.Shape;
	import flash.text.engine.ContentElement;
	import flash.text.engine.EastAsianJustifier;
	import flash.text.engine.GroupElement;
	import flash.text.engine.LineJustification;
	import flash.text.engine.SpaceJustifier;
	import flash.text.engine.TabAlignment;
	import flash.text.engine.TabStop;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;
	import flash.text.engine.TextRotation;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.JustificationRule;
	import flashx.textLayout.formats.LeadingModel;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TabStopFormat;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextJustify;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.utils.CharacterUtil;
	import flashx.textLayout.utils.LocaleUtil;
	
	use namespace tlf_internal;

	/** 
	 * The ParagraphElement class represents a paragraph in the text flow hierarchy. Its parent
	 * is a ParagraphFormattedElement, and its children can include spans (SpanElement), images 
	 * (inLineGraphicElement), links (LinkElement) and TCY (Tatechuuyoko - ta-tae-chu-yo-ko) elements (TCYElement). The 
	 * paragraph text is stored in one or more SpanElement objects, which define ranges of text that share the same attributes. 
	 * A TCYElement object defines a small run of Japanese text that runs perpendicular to the line, as in a horizontal run of text in a 
	 * vertical line. A TCYElement can also contain multiple spans.
	 *
	 * @includeExample examples\ParagraphElementExample.as -noswf
	 * @includeExample examples\ParagraphElementExample2.as -noswf
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 * 
	 * @see InlineGraphicElement
	 * @see LinkElement
	 * @see SpanElement
	 * @see TCYElement
	 * @see TextFlow
	 */
	 
	public final class ParagraphElement extends ParagraphFormattedElement
	{
		//private var _textBlock:TextBlock;
		private var _textBlockChildren:Dictionary;
		private var _terminatorSpan:SpanElement;
		
		private var _interactiveChildrenCount:int;
		/** Constructor - represents a paragraph in a text flow. 
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*/
	 	
		public function ParagraphElement()
		{
			super();
			_terminatorSpan = null;
			_interactiveChildrenCount = 0 ;
			_textBlockChildren = new Dictionary();
		}
		tlf_internal function get interactiveChildrenCount():int
		{
			return _interactiveChildrenCount;
		}
		
		/** @private */
		tlf_internal function createTextBlock():void
		{
			CONFIG::debug { assert(_textBlock == null,"createTextBlock called when there is already a textblock"); }
			computedFormat;	// recreate the format BEFORE the _textBlock is created
			var tbs:Vector.<TextBlock> = getTextBlocks();
			//tbs.length = 0;
			var tableCount:int = 0;
			if(tbs.length == 0 && !(getChildAt(0) is TableElement) )
				tbs.push(new TextBlock());
			//getTextBlocks()[0] = new TextBlock();
			CONFIG::debug { Debugging.traceFTECall(_textBlock,null,"new TextBlock()"); }
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:FlowElement = getChildAt(i);
				if(child is TableElement)
					tableCount++;
//					tbs.push(new TextBlock());
				else
				{
					//child.releaseContentElement();
					//child.createContentElement();
				}
			}
			while(tableCount >= tbs.length)
				tbs.push(new TextBlock());
			
			for (i = 0; i < numChildren; i++)
			{
				child = getChildAt(i);
				child.createContentElement();
			}
			tbs.length = tableCount + 1;
			var tb:TextBlock;
			for each(tb in tbs){
				updateTextBlock(tb);
			}
		}
		private function updateTextBlockDict():void
		{
			var tbs:Vector.<TextBlock> = getTextBlocks();
			if(tbs.length == 0)
				return;//nothing to do
			var tbIdx:int = 0;
			var tb:TextBlock = tbs[tbIdx];
			var items:Array = [];
			var child:FlowElement;
			for (var i:int = 0; i < numChildren; i++)
			{
				child = getChildAt(i);
				if(child is TableElement)
				{
					_textBlockChildren[tb] = items;
					tb = tbs[++tbIdx];
					items = [];
					continue;
				}
				items.push(child);
			}
			_textBlockChildren[tb] = items;
		}
		private function removeTextBlock(tb:TextBlock):void
		{
			var tbs:Vector.<TextBlock> = getTextBlocks();
			if(tbs)
			{
				var idx:int = getTextBlocks().indexOf(tb);
				if(idx > -1)
				{
					tbs.splice(idx,1);
					delete _textBlockChildren[tb];
				}
			}
		}
		private function releaseTextBlockInternal(tb:TextBlock):void
		{
			if (!tb)
				return;
			
			if (tb.firstLine)	// A TextBlock may have no firstLine if it has previously been released.
			{
				for (var textLineTest:TextLine = tb.firstLine; textLineTest != null; textLineTest = textLineTest.nextLine)
				{	
					if(textLineTest.numChildren != 0)
					{	
						//if the number of adornments added does not match the number of children on the textLine
						//then a third party has added adornments.  Don't recycle the line or the adornment will be
						//lost.
						var tfl:TextFlowLine = textLineTest.userData as TextFlowLine;
						if(tfl.adornCount != textLineTest.numChildren)
							return;
					}
				}
				
				CONFIG::debug { Debugging.traceFTECall(null,tb,"releaseLines",tb.firstLine, tb.lastLine); }				
				tb.releaseLines(tb.firstLine, tb.lastLine);	
			}	
			var items:Array = _textBlockChildren[tb];
			var len:int = items.length;
			for (var i:int = 0; i < len; i++)
			{
				var child:FlowElement = items[i];
				child.releaseContentElement();
			}
			items.length = 0;
			tb.content = null;
			removeTextBlock(tb);
		}
		/** @private */
		tlf_internal function releaseTextBlock(tb:TextBlock=null):void
		{
			updateTextBlockDict();
			if(tb)
			{
				releaseTextBlockInternal(tb);
				return;
			}
			var tbs:Vector.<TextBlock> = getTextBlocks();
			for each(var tb:TextBlock in tbs)
			{
				releaseTextBlockInternal(tb);
			}
			//_textBlock = null;
			if (_computedFormat)
				_computedFormat = null;
		}
		private var _textBlocks:Vector.<TextBlock>;
		tlf_internal function getTextBlocks():Vector.<TextBlock>
		{
			if(_textBlocks == null)
				_textBlocks = new Vector.<TextBlock>();
			return _textBlocks;
		}
		/** TextBlock where the text of the paragraph is kept. @private */
		tlf_internal function getTextBlock():TextBlock
		{
			if (!getTextBlocks().length)
				createTextBlock();
			
			return getTextBlocks()[0]; 
		}
		/** Last TextBlock where the text of the paragraph is kept. @private */
		tlf_internal function getLastTextBlock():TextBlock
		{
			var tbs:Vector.<TextBlock> = getTextBlocks();
			if(!tbs.length)
				createTextBlock();
			
			return tbs[tbs.length-1];
		}

		/** Get TextBlock at specified position. @private */
		tlf_internal function getTextBlockAtPosition(pos:int):TextBlock
		{
			var curPos:int = 0;
			var posShift:int = 0;
			var tables:Vector.<TableElement> = getTables();
			if(!tables.length)
				return getTextBlock();
			
			for each(var table:TableElement in tables)
			{
				if(table.getElementRelativeStart(this) < pos)
					posShift++;
			}
			var tbs:Vector.<TextBlock> = getTextBlocks();
			for each(var tb:TextBlock in tbs)
			{
				if(tb.content == null)
					return tb;
				curPos += tb.content.rawText.length;
				if(curPos + posShift > pos)
				{
					if(getTextBlockStart(tb) > pos)
						return null;
					return tb;
				}
			}
			return null;
		}
		
		tlf_internal function getTextBlockAbsoluteStart(tb:TextBlock):int
		{
			var start:int = getTextBlockStart(tb);
			if(start < 0)
				start = 0;
			return getAbsoluteStart() + start;
		}
		tlf_internal function getTextBlockStart(tb:TextBlock):int
		{
			var i:int;
			var curPos:int = 0;
			var tbs:Vector.<TextBlock> = getTextBlocks();
			if(tbs.length == 0)
				return -1;
			var tables:Vector.<TableElement> = getTables();
			for each(var curTB:TextBlock in tbs)
			{
				for each(var table:TableElement in tables)
				{
					if(table.getElementRelativeStart(this) <= curPos)
					{
						curPos++;
						tables.splice(tables.indexOf(table),1);
					}
				}
				if(tb == curTB)
					return curPos;
				if(tb.content)
					curPos += curTB.content.rawText.length;
			}
			
			return -1;
		}
		
		private function getTables():Vector.<TableElement>
		{
			var tables:Vector.<TableElement> = new Vector.<TableElement>();
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:FlowElement = getChildAt(i);
				if(child is TableElement)
					tables.push(child as TableElement);
			}
			return tables;
		}

		/** TextBlock where the text of the paragraph is kept, or null if we currently don't have one. @private */
		tlf_internal function peekTextBlock():TextBlock
		{ 
			return getTextBlocks().length == 0 ? null : getTextBlocks()[0];
		}
		
		/** @private */
		tlf_internal function releaseLineCreationData():void
		{
			CONFIG::debug { assert(Configuration.playerEnablesArgoFeatures,"bad call to releaseLineCreationData"); }
			var tbs:Vector.<TextBlock> = getTextBlocks();
			for each(var tb:TextBlock in tbs)
			{
				tb["releaseLineCreationData"]();
			}
		}
		
		/** @private */
		tlf_internal override function createContentAsGroup(pos:int=0):GroupElement
		{
			var tb:TextBlock = getTextBlockAtPosition(pos);
			var group:GroupElement = tb.content as GroupElement;
			if (!group)
			{
				var originalContent:ContentElement = tb.content;
				
				group = new GroupElement();
				CONFIG::debug { Debugging.traceFTECall(group,null,"new GroupElement()"); }
				tb.content = group;
				CONFIG::debug { Debugging.traceFTEAssign(tb,"content",group); }

				if (originalContent)
				{
					var gc:Vector.<ContentElement> = new Vector.<ContentElement>();
					CONFIG::debug { Debugging.traceFTECall(gc,null,"new Vector.<ContentElement>()") }
					gc.push(originalContent);
					CONFIG::debug { Debugging.traceFTECall(null,gc,"push",originalContent); }
					group.replaceElements(0,0,gc);
					CONFIG::debug { Debugging.traceFTECall(null,group,"replaceElements",0,0,gc); }
				}
				
				// Now we've got to force damage the entire paragraph, because we restructured it in FTE.
				if (tb.firstLine && textLength)
				{
					var textFlow:TextFlow = getTextFlow();
					if (textFlow)
						textFlow.damage(getAbsoluteStart(), textLength, TextLineValidity.INVALID, false);
				}
			}
			return group;
 		}
 		
 		/** @private */
		tlf_internal override function removeBlockElement(child:FlowElement, block:ContentElement):void
		{
			var tb:TextBlock = getTextBlockAtPosition(child.getElementRelativeStart(this));
			if(!tb)
				tb = getTextBlock();
			
			if(tb.content == null)
				return;
			var relativeStart:int = child.getElementRelativeStart(this);

			if (getChildrenInTextBlock(relativeStart).length < 2)
			{
				if (block is GroupElement)
				{
					// see insertBlockElement
					CONFIG::debug { assert(_textBlock.content != block,"removeBlockElement: bad call to removeBlockElement"); }
					CONFIG::debug { assert(_textBlock.content is GroupElement,"removeBlockElement: bad content"); }
					CONFIG::debug { assert(GroupElement(_textBlock.content).elementCount == 1,"removeBlockElement: bad element count"); }
					CONFIG::debug { assert(GroupElement(_textBlock.content).getElementAt(0) == block,"removeBlockElement: bad group content"); }
					GroupElement(tb.content).replaceElements(0,1,null);
					CONFIG::debug { Debugging.traceFTECall(null,_textBlock.content,"replaceElements",0,1,null); }
				}
				tb.content = null;
				CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"content",null); }
			}
			else if(block.groupElement)
			{
				var idx:int = getChildIndexInBlock(child);
				var group:GroupElement = GroupElement(tb.content);
				CONFIG::debug { assert(group.elementCount == numChildren,"Mismatched group and elementCount"); }
				group.replaceElements(idx,idx+1,null);
				if(group.elementCount == 0)
					return;
				CONFIG::debug { Debugging.traceFTECall(null,group,"replaceElements",idx,idx+1,null); }
				if (numChildren == 2)	// its going to be one so ungroup
				{
					// ungroup - need to take it out first as inlinelements can only have one parent
					var elem:ContentElement = group.getElementAt(0);
					CONFIG::debug { Debugging.traceFTECall(elem,group,"getElementAt",0); }
					if (!(elem is GroupElement))
					{
						group.replaceElements(0,1,null);
						CONFIG::debug { Debugging.traceFTECall(null,group,"replaceElements",0,1,null); }
						tb.content = elem;
						CONFIG::debug { Debugging.traceFTEAssign(tb,"content",elem); }
					}
				}
			}
			else {
				//trace("1");
				//tb.content = null;
			}
		}
		
		
		/** @private */
		tlf_internal override function hasBlockElement():Boolean
		{
			return getTextBlocks().length > 0;
		}
		
		/** @private */
		override tlf_internal function createContentElement():void
		{
			createTextBlock();
		}
		
		/** @private */
		private function getChildrenInTextBlock(pos:int):Array
		{
			var retVal:Array = [];
			if(numChildren == 0)
				return retVal;
			if(numChildren == 1)
			{
				retVal.push(getChildAt(0));
				return retVal
			}
			var chldrn:Array = mxmlChildren.slice();
			for(var i:int = 0; i<chldrn.length;i++)
			{
				if(chldrn[i] is TableElement)
				{
					if(chldrn[i].parentRelativeStart == pos)
						return [chldrn[i]];
					if(chldrn[i].parentRelativeStart < pos)
					{
						retVal.length = 0;
						continue;
					}
					if(chldrn[i].parentRelativeStart > pos)
						break;
				}
				retVal.push(chldrn[i]);		
			}
			return retVal;
		}
		
		/** @private */
		tlf_internal override function insertBlockElement(child:FlowElement, block:ContentElement):void
		{
			var relativeStart:int = child.getElementRelativeStart(this);
			var tb:TextBlock = getTextBlockAtPosition(relativeStart);
			if (getTextBlocks().length == 0 || !tb)
			{
				child.releaseContentElement();
				createTextBlock();	// does the whole tree
				return;
			}
			var gc:Vector.<ContentElement>;	// scratch var
			var group:GroupElement;			// scratch
			if (getChildrenInTextBlock(relativeStart).length < 2)
			{
				if (block is GroupElement)
				{
					// this case forces the Group to be in a Group so that following FlowLeafElements aren't in a SubParagraphGroupElementBase's group
					gc = new Vector.<ContentElement>();
					CONFIG::debug { Debugging.traceFTECall(gc,null,"new Vector.<ContentElement>()") }
					gc.push(block);
					CONFIG::debug { Debugging.traceFTECall(null,gc,"push",block); }
					group = new GroupElement(gc);
					CONFIG::debug { Debugging.traceFTECall(group,null,"new GroupElement",gc); }
					tb.content = group;
					CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"content",group); }
				}
				else
				{
					if(block.groupElement)
					{
						block.groupElement.elementCount;
					}
					tb.content = block;
					CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"content",block);  }
				}
			}
			else
			{
				group = createContentAsGroup(relativeStart);
				var idx:int = getChildIndexInBlock(child);
				gc = new Vector.<ContentElement>();
				CONFIG::debug { Debugging.traceFTECall(gc,null,"new Vector.<ContentElement>") }
				gc.push(block);
				CONFIG::debug { Debugging.traceFTECall(null,gc,"push",block); }
				group.replaceElements(idx,idx,gc);
				CONFIG::debug { Debugging.traceFTECall(null,group,"replaceElements",idx,idx,gc); }
			}
		}
		
		private function getChildIndexInBlock(elem:FlowElement):int
		{
			var relIdx:int = 0;
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:FlowElement = getChildAt(i);
				if(child == elem)
					return relIdx;
				relIdx++;
				if(child is TableElement)
					relIdx = 0;
			}
			return -1;
		}
		
		/** @private */
		override protected function get abstract():Boolean
		{ return false;	}	
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "p"; }

		tlf_internal function removeEmptyTerminator():void
		{
			if(numChildren == 1 && _terminatorSpan && _terminatorSpan.textLength == 1)
			{
				_terminatorSpan.removeParaTerminator();
				super.replaceChildren(0, 1);
				this._terminatorSpan = null;
			}
		}
		/** @private */
		public override function replaceChildren(beginChildIndex:int,endChildIndex:int,...rest):void
		{
			var applyParams:Array;

			do{
				if(_terminatorSpan)
				{
					var termIdx:int = getChildIndex(_terminatorSpan);
					if(termIdx !=0 && _terminatorSpan.textLength == 1)
					{
						super.replaceChildren(termIdx, termIdx+1);
						_terminatorSpan = null;
						if(beginChildIndex >= termIdx)
						{
							beginChildIndex--;
							if(rest.length == 0) // delete of terminator was already done.
								break;
						}
						if(endChildIndex >= termIdx && beginChildIndex != endChildIndex)
							endChildIndex--;
					}
				}
				
				// makes a measurable difference - rest.length zero and one are the common cases
				if (rest.length == 1)
					applyParams = [beginChildIndex, endChildIndex, rest[0]];
				else
				{
					applyParams = [beginChildIndex, endChildIndex];
					if (rest.length != 0)
						applyParams = applyParams.concat.apply(applyParams, rest);
				}
				
				super.replaceChildren.apply(this, applyParams);
				
			}while(false);
			
			ensureTerminatorAfterReplace();
			// ensure correct text blocks
			createTextBlock();
		}
		
		public override function splitAtPosition(relativePosition:int):FlowElement
		{
			// need to handle multiple TextBlocks
			// maybe not. It might be handled in replaceChildren().
			return super.splitAtPosition(relativePosition);
		}
		/** @private */
		tlf_internal function ensureTerminatorAfterReplace():void
		{
			var newLastLeaf:FlowLeafElement = getLastLeaf();
			if (_terminatorSpan != newLastLeaf)
			{
				if (newLastLeaf && _terminatorSpan)
				{
					_terminatorSpan.removeParaTerminator();
					if(_terminatorSpan.textLength == 0)
					{
						var termIdx:int = getChildIndex(_terminatorSpan);
						super.replaceChildren(termIdx, termIdx+1);
					}
					this._terminatorSpan = null;
				}
				
				if (newLastLeaf is SpanElement)
				{
					(newLastLeaf as SpanElement).addParaTerminator();
					this._terminatorSpan = newLastLeaf as SpanElement;
				}
				else
				{
					var s:SpanElement = new SpanElement();
					super.replaceChildren(numChildren,numChildren,s);
					s.format = newLastLeaf ? newLastLeaf.format : _terminatorSpan.format;
					s.addParaTerminator();
					this._terminatorSpan = s;
				}
			}
			//merge terminator span to previous if possible
			if(_terminatorSpan.textLength == 1)
			{
				var prev:FlowLeafElement = _terminatorSpan.getPreviousLeaf(this);
				if(prev && prev is SpanElement)
				{
					_terminatorSpan.removeParaTerminator();
					termIdx = getChildIndex(_terminatorSpan);
					super.replaceChildren(termIdx, termIdx+1);
					s = prev as SpanElement;
					s.addParaTerminator();
					this._terminatorSpan = s;
				}
			}
		}
		
		/** @private */
		tlf_internal function updateTerminatorSpan(splitSpan:SpanElement,followingSpan:SpanElement):void
		{
			if (_terminatorSpan == splitSpan)
				_terminatorSpan = followingSpan;
		}

		[RichTextContent]
		/** @private NOTE: all FlowElement implementers and overrides of mxmlChildren must specify [RichTextContent] metadata */
		public override function set mxmlChildren(array:Array):void
		{
			// remove all existing children
			replaceChildren(0,numChildren);
			
			for each (var child:Object in array)
			{
				if (child is FlowElement)
				{
					if ((child is SpanElement) || (child is SubParagraphGroupElementBase))
						child.bindableElement = true;
					
					// Note: calling super.replaceChildren because we don't want to transfer para terminator each time
					super.replaceChildren(numChildren, numChildren, child as FlowElement);
				}
				else if (child is String)
				{
					var s:SpanElement = new SpanElement();
					s.text = String(child);
					s.bindableElement = true;
					
					// Note: calling super.replaceChildren because we don't want to transfer para terminator each time
					super.replaceChildren(numChildren, numChildren, s);
				}
				else if (child != null)
					throw new TypeError(GlobalSettings.resourceStringFunction("badMXMLChildrenArgument",[ getQualifiedClassName(child) ]));
			}
			
			// Now ensure para terminator
			ensureTerminatorAfterReplace();
			
			// recreate text blocks to handle possible TableElement changes
			createTextBlock();
		}
		
		/** @private
 		 */
		public override function getText(relativeStart:int=0, relativeEnd:int=-1, paragraphSeparator:String="\n"):String
		{
			// Optimization for getting text of the entire paragraph
			if (relativeStart == 0 && (relativeEnd == -1 || relativeEnd >= textLength-1) && getTextBlocks().length)
			{
				var tb:TextBlock;
				var tbs:Vector.<TextBlock> = getTextBlocks();
				var text:String = "";
				for each(tb in tbs)
				{
					text = text + getTextInBlock(tb);
				}
				if(tb.content && tb.content.rawText)
					return text.substring(0, text.length - 1);
				return text;
			}
			return super.getText(relativeStart, relativeEnd, paragraphSeparator);
		}
		private function getTextInBlock(tb:TextBlock):String{
			if(!tb.content || !tb.content.rawText)
				return "";
			return tb.content.rawText;
		}
		
		/** Returns the paragraph that follows this one, or null if there are no more paragraphs. 
		 *
		 * @return the next paragraph or null if there are no more paragraphs.
		 *
		 * @includeExample examples\ParagraphElement_getNextParagraph.as -noswf
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 * 
	 	 * @see #getPreviousParagraph()
	 	 */
		public function getNextParagraph():ParagraphElement
		{
			var nextLeaf:FlowLeafElement = getLastLeaf().getNextLeaf();
			return nextLeaf ? nextLeaf.getParagraph() : null;
		}
	
		/** Returns the paragraph that precedes this one, or null, if this paragraph is the first one 
		 * in the TextFlow. 
		 *
		 * @includeExample examples\ParagraphElement_getPreviousParagraph.as -noswf
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see #getNextParagraph()
	 	 */
		public function getPreviousParagraph():ParagraphElement
		{
			var previousLeaf:FlowLeafElement = getFirstLeaf().getPreviousLeaf();
			return previousLeaf ? previousLeaf.getParagraph() : null;
		}
	
		/** 
		 * Scans backward from the supplied position to find the location
		 * in the text of the previous atom and returns the index. The term atom refers to 
		 * both graphic elements and characters (including groups of combining characters), the 
		 * indivisible entities that make up a text line.
		 * 
		 * @param relativePosition  position in the text to start from, counting from 0
		 * @return index in the text of the previous cluster
		 *
		 * @includeExample examples\ParagraphElement_findPreviousAtomBoundary.as -noswf
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see flash.text.engine.TextLine
		 */
		 
		public function findPreviousAtomBoundary(relativePosition:int):int
		{
			var tb:TextBlock = getTextBlockAtPosition(relativePosition);
			var tbStart:int = getTextBlockStart(tb);
			var textBlockPos:int = relativePosition - tbStart;
			if (ContainerController.tlf_internal::usesDiscretionaryHyphens)
			{
				var tl:TextLine = tb.getTextLineAtCharIndex(textBlockPos);
				var currentAtomIndex:int = tl.getAtomIndexAtCharIndex(textBlockPos);
                //trace("relpos", relativePosition, "atomIndex", currentAtomIndex);
                var isRTL:Boolean = tl.getAtomBidiLevel(currentAtomIndex) == 1;
                if (isRTL)
                {
                   var foo:int = tb.findPreviousAtomBoundary(textBlockPos);
                   if (currentAtomIndex == 0)
                   {
                       // when cursor is left of all characters (end of line)
                       // atomIndex is 0, so compensate
                       if (tl.atomCount > 0)
                       {
                           while (--textBlockPos)
                           {
							   --relativePosition;
                               if (tl.getAtomIndexAtCharIndex(textBlockPos) != currentAtomIndex)
                                   break;
                           }
                       }
                   }
                   else
                   {
                       while (--relativePosition && --textBlockPos)
                       {
                           if (tl.getAtomIndexAtCharIndex(textBlockPos) != currentAtomIndex)
                               break;
                       }
                   }
                   if (CharacterUtil.isLowSurrogate(getText(relativePosition, relativePosition + 1).charCodeAt(0)))
				   {
					   relativePosition--;
					   textBlockPos--;
				   }
				   
                   //trace("previous", relativePosition, foo);
                }
                else
                {
    				if (currentAtomIndex == 0)
    				{
    					tl = tl.previousLine;
    					if (!tl)
    						return -1;
    					// need this when 0x2028 line separator in use
    					if (tl.textBlockBeginIndex + tl.rawTextLength == textBlockPos)
    						return tl.textBlockBeginIndex + tl.rawTextLength - 1 + tbStart;
    					return tl.textBlockBeginIndex + tl.rawTextLength + tbStart;
    				}
    				while (--relativePosition && --textBlockPos)
    				{
    					if (tl.getAtomIndexAtCharIndex(textBlockPos) < currentAtomIndex)
    						break;
    				}
                    if (CharacterUtil.isLowSurrogate(getText(relativePosition, relativePosition + 1).charCodeAt(0)))
					{
						relativePosition--;
						textBlockPos--;
					}
                }
				return relativePosition;
			}
            var pos:int = tb.findPreviousAtomBoundary(textBlockPos);
			if(pos >= 0)
				pos += tbStart;
            //trace("previous", relativePosition, pos);
			return pos;
		}

		/** 
		 * Scans ahead from the supplied position to find the location
		 * in the text of the next atom and returns the index. The term atom refers to 
		 * both graphic elements and characters (including groups of combining characters), the 
		 * indivisible entities that make up a text line.
		 * 
		 * @param relativePosition  position in the text to start from, counting from 0
		 * @return index in the text of the following atom
		 *
		 * @includeExample examples\ParagraphElement_findNextAtomBoundary.as -noswf
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see flash.text.engine.TextLine
		 */
		 
		public function findNextAtomBoundary(relativePosition:int):int
		{
			var tb:TextBlock = getTextBlockAtPosition(relativePosition);
			var tbStart:int = getTextBlockStart(tb);
			var textBlockPos:int = relativePosition - tbStart;
			if (ContainerController.tlf_internal::usesDiscretionaryHyphens)
			{
				var tl:TextLine = tb.getTextLineAtCharIndex(textBlockPos);
				var currentAtomIndex:int = tl.getAtomIndexAtCharIndex(textBlockPos);
                //trace("relpos", relativePosition, "atomIndex", currentAtomIndex);
                var isRTL:Boolean = tl.getAtomBidiLevel(currentAtomIndex) == 1;
                if (isRTL)
                {
                    var foo:int = tb.findNextAtomBoundary(textBlockPos);
                    if (currentAtomIndex == 0)
                    {
                        while (++textBlockPos)
                        {
							++relativePosition;
                            if (tl.getAtomIndexAtCharIndex(textBlockPos) != currentAtomIndex)
                                break;
                        }
                    }
                    else
                    {
                        while (++textBlockPos)
                        {
							++relativePosition;
                            if (tl.getAtomIndexAtCharIndex(textBlockPos) != currentAtomIndex)
                                break;
                        }
                    }
                    if (CharacterUtil.isHighSurrogate(getText(relativePosition, relativePosition + 1).charCodeAt(0)))
					{
						relativePosition++;
						textBlockPos++;
					}
                    //trace("next", relativePosition, foo);
                }
                else
                {
    				if (currentAtomIndex == tl.atomCount - 1)
    				{
    					tl = tl.nextLine;
    					if (!tl)
    						return -1;
    					return tl.textBlockBeginIndex + tbStart;
    				}
    				while (++textBlockPos)
    				{
						++relativePosition;
    					if (tl.getAtomIndexAtCharIndex(textBlockPos) > currentAtomIndex)
    						break;
    				}
                    if (CharacterUtil.isHighSurrogate(getText(relativePosition, relativePosition + 1).charCodeAt(0)))
					{
						relativePosition++;
						textBlockPos++;
					}
                }
				return relativePosition;
			}
			var pos:int = tb.findNextAtomBoundary(textBlockPos);
			if(pos >= 0)
				pos += tbStart;
            //trace("next", relativePosition, pos);
            return pos;
		}
		
		/** @private */
		public override function getCharAtPosition(relativePosition:int):String
		{
			var foundTB:TextBlock = getTextBlockAtPosition(relativePosition);
			if(!foundTB)
				return "\u0016";
			var tables:Vector.<TableElement> = getTables();
			var pos:int = relativePosition;
			for each(var table:TableElement in tables)
			{
				if(table.getElementRelativeStart(this) < pos)
					relativePosition--;
			}
			var tbs:Vector.<TextBlock> = getTextBlocks();
			for each(var tb:TextBlock in tbs)
			{
				if(foundTB == tb)
					break;
				if(tb)
					relativePosition -= tb.content.rawText.length;
				else
					relativePosition -= 1;this.getText()
			}
			return foundTB.content.rawText.charAt(relativePosition);
		} 

		/** 
		 * Returns the index of the previous word boundary in the text.
		 * 
		 * <p>Scans backward from the supplied position to find the previous position
		 * in the text that starts or ends a word. </p>
		 * 
		 * @param relativePosition  position in the text to start from, counting from 0
		 * @return index in the text of the previous word boundary
		 *
		 * @includeExample examples\ParagraphElement_findPreviousWordBoundary.as -noswf
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 */
		 
		public function findPreviousWordBoundary(relativePosition:int):int
		{	
			if (relativePosition == 0)
				return 0;
			var prevCharCode:int = getCharCodeAtPosition(relativePosition - 1);
			if (CharacterUtil.isWhitespace(prevCharCode))
			{				
				while (CharacterUtil.isWhitespace(prevCharCode) && ((relativePosition - 1) > 0))
				{
					relativePosition--;
					prevCharCode = getCharCodeAtPosition(relativePosition - 1);
				}
				return relativePosition;
			}
			var block:TextBlock = getTextBlockAtPosition(relativePosition);
			if(block == null)
				block = getTextBlockAtPosition(--relativePosition);
			var pos:int = getTextBlockStart(block);
			if(pos < 0)
				pos = 0;
			return relativePosition == pos ? pos : pos + block.findPreviousWordBoundary(relativePosition - pos);
		}

		/** 
		 * Returns the index of the next word boundary in the text.
		 * 
		 * <p>Scans ahead from the supplied position to find the next position
		 * in the text that starts or ends a word. </p>
		 * 
		 * @param relativePosition  position in the text to start from, counting from 0
		 * @return  index in the text of the next word boundary
		 * 
		 * @includeExample examples\ParagraphElement_findNextWordBoundary.as -noswf
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 */
		 
		public function findNextWordBoundary(relativePosition:int):int
		{	
			if (relativePosition == textLength) 
				return textLength;
			var curCharCode:int = getCharCodeAtPosition(relativePosition);
			if (CharacterUtil.isWhitespace(curCharCode))
			{
				while (CharacterUtil.isWhitespace(curCharCode) && relativePosition < (textLength - 1))
				{
					relativePosition++;
					curCharCode = getCharCodeAtPosition(relativePosition);
				}
				return relativePosition;
			}
			var block:TextBlock = getTextBlockAtPosition(relativePosition);
			if(block == null)
				block = getTextBlockAtPosition(--relativePosition);
			var pos:int = getTextBlockStart(block);
			if(pos < 0)
				pos = 0;
			return pos + block.findNextWordBoundary(relativePosition - pos);
		}
		
		static private var _defaultTabStops:Vector.<TabStop>;
		static private const defaultTabWidth:int = 48;		// matches default tabs setting in Argo
		static private const defaultTabCount:int = 20;
		
		static private function initializeDefaultTabStops():void
		{
			_defaultTabStops = new Vector.<TabStop>(defaultTabCount, true);
			for (var i:int = 0; i < defaultTabCount; ++i)
				_defaultTabStops[i] = new TabStop(TextAlign.START, defaultTabWidth * i);
		}
		
		private function updateTextBlock(textBlock:TextBlock=null):void
		{
			if(!textBlock)
				textBlock = getTextBlock();
			// find the ancestor with a container and use its format for various settings
			var containerElement:ContainerFormattedElement = getAncestorWithContainer();
			if (!containerElement)
				return;
				
			var containerElementFormat:ITextLayoutFormat = containerElement ? containerElement.computedFormat : TextLayoutFormat.defaultFormat;
			
			var lineJust:String;
			if (computedFormat.textAlign == TextAlign.JUSTIFY)
			{
				lineJust = (_computedFormat.textAlignLast == TextAlign.JUSTIFY) ?
					LineJustification.ALL_INCLUDING_LAST :
					LineJustification.ALL_BUT_LAST;
					
				// We don't allow explicit line breaks and justification together because it results in very strange (invisible) lines
				if (containerElementFormat.lineBreak == LineBreak.EXPLICIT)
					lineJust = LineJustification.UNJUSTIFIED;
			}
			else
				lineJust = LineJustification.UNJUSTIFIED;
		
			
			var makeJustRuleStyle:String = this.getEffectiveJustificationStyle();
			
			var justRule:String = this.getEffectiveJustificationRule();
				
			// set the justifier in the TextBlock
			if (justRule == JustificationRule.SPACE)
			{
				var spaceJustifier:SpaceJustifier = new SpaceJustifier(_computedFormat.locale,lineJust,false);
				spaceJustifier.letterSpacing = _computedFormat.textJustify == TextJustify.DISTRIBUTE ? true : false;

				if (Configuration.playerEnablesArgoFeatures)
				{
					// These three properties have to be set in the correct order so that consistency checks done
					// in the Player on set are never violated
					var newMinimumSpacing:Number = Property.toNumberIfPercent(_computedFormat.wordSpacing.minimumSpacing)/100;
					var newMaximumSpacing:Number = Property.toNumberIfPercent(_computedFormat.wordSpacing.maximumSpacing)/100;
					var newOptimumSpacing:Number = Property.toNumberIfPercent(_computedFormat.wordSpacing.optimumSpacing)/100; 
					spaceJustifier["minimumSpacing"] = Math.min(newMinimumSpacing, spaceJustifier["minimumSpacing"]);
					spaceJustifier["maximumSpacing"] = Math.max(newMaximumSpacing, spaceJustifier["maximumSpacing"]);
					spaceJustifier["optimumSpacing"] = newOptimumSpacing;
					spaceJustifier["minimumSpacing"] = newMinimumSpacing;
					spaceJustifier["maximumSpacing"] = newMaximumSpacing;
				}

				CONFIG::debug { Debugging.traceFTECall(spaceJustifier,null,"new SpaceJustifier",_computedFormat.locale,lineJust,spaceJustifier.letterSpacing); }
				textBlock.textJustifier = spaceJustifier;
				CONFIG::debug { Debugging.traceFTEAssign(textBlock,"textJustifier",spaceJustifier); }
				textBlock.baselineZero = getLeadingBasis(this.getEffectiveLeadingModel());
				CONFIG::debug { Debugging.traceFTEAssign(textBlock,"baselineZero",textBlock.baselineZero);  }
			}
			else
			{
				var eastAsianJustifier:Object = new EastAsianJustifier(_computedFormat.locale,lineJust, makeJustRuleStyle);
				if( Configuration.versionIsAtLeast(10,3) && eastAsianJustifier.hasOwnProperty("composeTrailingIdeographicSpaces")){
					eastAsianJustifier.composeTrailingIdeographicSpaces = true;
				}
				CONFIG::debug { Debugging.traceFTECall(eastAsianJustifier,null,"new EastAsianJustifier",_computedFormat.locale,lineJust,makeJustRuleStyle); }
				textBlock.textJustifier = eastAsianJustifier as EastAsianJustifier;
				CONFIG::debug { Debugging.traceFTEAssign(textBlock,"textJustifier",eastAsianJustifier);  }
				textBlock.baselineZero = getLeadingBasis(this.getEffectiveLeadingModel());
				CONFIG::debug { Debugging.traceFTEAssign(textBlock,"baselineZero",textBlock.baselineZero);  }
			}
			
			textBlock.bidiLevel = _computedFormat.direction == Direction.LTR ? 0 : 1;
			CONFIG::debug { Debugging.traceFTEAssign(textBlock,"bidiLevel",textBlock.bidiLevel);  }

			textBlock.lineRotation = containerElementFormat.blockProgression == BlockProgression.RL ? TextRotation.ROTATE_90 : TextRotation.ROTATE_0;
			CONFIG::debug { Debugging.traceFTEAssign(textBlock,"lineRotation",textBlock.lineRotation);  }
			
			if (_computedFormat.tabStops && _computedFormat.tabStops.length != 0)
			{
				//create a vector of TabStops and assign it to tabStops in textBlock
				var tabStops:Vector.<TabStop> = new Vector.<TabStop>();
				CONFIG::debug { Debugging.traceFTECall(tabStops,null,"new Vector.<TabStop>()"); }
				for each(var tsa:TabStopFormat in _computedFormat.tabStops)
				{
					var token:String = tsa.decimalAlignmentToken==null ? "" : tsa.decimalAlignmentToken;
					var alignment:String = tsa.alignment==null ? TabAlignment.START : tsa.alignment;
					var tabStop:TabStop = new TabStop(alignment,Number(tsa.position),token);
					// this next line when uncommented works around bug 1912782
					if (tsa.decimalAlignmentToken != null) var garbage:String = "x" + tabStop.decimalAlignmentToken;
					CONFIG::debug { Debugging.traceFTECall(tabStop,null,"new TabStop",tabStop.alignment,tabStop.position,tabStop.decimalAlignmentToken); }
					tabStops.push(tabStop);
					CONFIG::debug { Debugging.traceFTECall(null,tabStops,"push",tabStop); }
				}
				textBlock.tabStops = tabStops;
				CONFIG::debug { Debugging.traceFTEAssign(textBlock,"tabStops",tabStops);  }
			} 
			else if (GlobalSettings.enableDefaultTabStops && !Configuration.playerEnablesArgoFeatures)
			{
				// 	Player versions prior to 10.1 do not set up any default tabStops. As a workaround, if enableDefaultTabs
				//	is true, TLF will set up default tabStops in the case where there are no tabs defined. 
				if (_defaultTabStops == null)
					initializeDefaultTabStops();
				textBlock.tabStops = _defaultTabStops;
				CONFIG::debug { Debugging.traceFTEAssign(textBlock,"tabStops",_defaultTabStops);  }
			}
			else
			{
				textBlock.tabStops = null;
				CONFIG::debug { Debugging.traceFTEAssign(textBlock,"tabStops",null);  }
			}		 
		}
		
		/** @private */
		public override function get computedFormat():ITextLayoutFormat
		{
			if (!_computedFormat)
			{
				super.computedFormat;
				var tbs:Vector.<TextBlock> = getTextBlocks();
				for each(var tb:TextBlock in tbs)
					updateTextBlock(tb);
					
			}
			return _computedFormat;
		}

		/** @private */
		tlf_internal override function canOwnFlowElement(elem:FlowElement):Boolean
		{
			return elem is FlowLeafElement || elem is SubParagraphGroupElementBase || elem is TableElement;
		}
		
		/** @private */
		tlf_internal override function normalizeRange(normalizeStart:uint,normalizeEnd:uint):void
		{
			var idx:int = findChildIndexAtPosition(normalizeStart);
			if (idx != -1 && idx < numChildren)
			{
				var child:FlowElement = getChildAt(idx);
				normalizeStart = normalizeStart-child.parentRelativeStart;
				
				CONFIG::debug { assert(normalizeStart >= 0, "bad normalizeStart in normalizeRange"); }
				for (;;)
				{
					// watch out for changes in the length of the child
					var origChildEnd:int = child.parentRelativeStart+child.textLength;
					child.normalizeRange(normalizeStart,normalizeEnd-child.parentRelativeStart);
					var newChildEnd:int = child.parentRelativeStart+child.textLength;
					normalizeEnd += newChildEnd-origChildEnd;	// adjust
					
					// no zero length children
					if (child.textLength == 0 && !child.bindableElement)
						replaceChildren(idx,idx+1);
					else if (child.mergeToPreviousIfPossible())
					{
						var prevElement:FlowElement = this.getChildAt(idx-1);
						// possibly optimize the start to the length of prevelement before the merge
						prevElement.normalizeRange(0,prevElement.textLength);
					}
					else
						idx++;

					if (idx == numChildren)
					{
						// check if last child is an empty SubPargraphBlock and remove it
						if (idx != 0)
						{
							var lastChild:FlowElement = this.getChildAt(idx-1);
							if (lastChild is SubParagraphGroupElementBase && lastChild.textLength == 1 && !lastChild.bindableElement)
								replaceChildren(idx-1,idx);
						}
						break;
					}
					
					// next child
					child = getChildAt(idx);
					
					if (child.parentRelativeStart > normalizeEnd)
						break;
						
					normalizeStart = 0;		// for the next child	
				}
			}
			
			// empty paragraphs not allowed after normalize
			if (numChildren == 0 || textLength == 0)
			{
				var s:SpanElement = new SpanElement();
				replaceChildren(0,0,s);
				s.normalizeRange(0,s.textLength);
			}
		}
		
		/** @private */
		tlf_internal function getEffectiveLeadingModel():String
		{
			return computedFormat.leadingModel == LeadingModel.AUTO ? LocaleUtil.leadingModel(computedFormat.locale) : computedFormat.leadingModel;
		}
		
		/** @private */
		tlf_internal function getEffectiveDominantBaseline():String
		{
			return computedFormat.dominantBaseline == FormatValue.AUTO ? LocaleUtil.dominantBaseline(computedFormat.locale) : computedFormat.dominantBaseline;
		}
		
		/** @private */
		tlf_internal function getEffectiveJustificationRule():String
		{
			return computedFormat.justificationRule == FormatValue.AUTO ? LocaleUtil.justificationRule(computedFormat.locale) : computedFormat.justificationRule;
		}
		
		/** @private */
		tlf_internal function getEffectiveJustificationStyle():String
		{
			return computedFormat.justificationStyle == FormatValue.AUTO ? LocaleUtil.justificationStyle(computedFormat.locale) : computedFormat.justificationStyle;
		}
		
		
		/** @private */
		CONFIG::debug public override function debugCheckFlowElement(depth:int = 0, extraData:String = ""):int
		{
			var tb:TextBlock = getTextBlock();
			var rslt:int = super.debugCheckFlowElement(depth," fte:"+getDebugIdentity(tb)+" "+extraData);
			
			// now check the character count and then the last character 
			
			if (tb)
			{
				var contentLength:int = tb.content && tb.content.rawText ? tb.content.rawText.length : 0;
				rslt += assert(contentLength == textLength,"Bad paragraph length mode:"+textLength.toString()+" _textBlock:" + contentLength.toString());

				var groupElement:GroupElement = tb.content as GroupElement;
				if (groupElement)
					assert(groupElement.elementCount == numChildren,"Mismatched group and elementCount"); 
				else if (tb.content)
					assert(1 == numChildren,"Mismatched group and elementCount"); 
				else 
					assert(0 == numChildren,"Mismatched group and elementCount"); 
			}
			rslt += assert(numChildren == 0 || textLength > 0,"Para must have at least one text char");
			return rslt;
		}
		
		/** @private */
		tlf_internal static function getLeadingBasis (leadingModel:String):String
		{
			switch (leadingModel)
			{
				default:
					CONFIG::debug { assert(false,"Unsupported parameter to ParagraphElement.getLeadingBasis"); } // In particular, AUTO is not supported by this method. Must be mapped to one of the above 
				case LeadingModel.ASCENT_DESCENT_UP:
				case LeadingModel.APPROXIMATE_TEXT_FIELD:
				case LeadingModel.BOX:
				case LeadingModel.ROMAN_UP:
					return flash.text.engine.TextBaseline.ROMAN;
				case LeadingModel.IDEOGRAPHIC_TOP_UP:
				case LeadingModel.IDEOGRAPHIC_TOP_DOWN:
					return flash.text.engine.TextBaseline.IDEOGRAPHIC_TOP;
				case LeadingModel.IDEOGRAPHIC_CENTER_UP:
				case LeadingModel.IDEOGRAPHIC_CENTER_DOWN:
					return flash.text.engine.TextBaseline.IDEOGRAPHIC_CENTER;
			}
		}
		
		/** @private */
		tlf_internal static function useUpLeadingDirection (leadingModel:String):Boolean
		{
			switch (leadingModel)
			{
				default:
					CONFIG::debug { assert(false,"Unsupported parameter to ParagraphElement.useUpLeadingDirection"); } // In particular, AUTO is not supported by this method. Must be mapped to one of the above 
				case LeadingModel.ASCENT_DESCENT_UP:
				case LeadingModel.APPROXIMATE_TEXT_FIELD:
				case LeadingModel.BOX:
				case LeadingModel.ROMAN_UP:
				case LeadingModel.IDEOGRAPHIC_TOP_UP:
				case LeadingModel.IDEOGRAPHIC_CENTER_UP:
					return true;
				case LeadingModel.IDEOGRAPHIC_TOP_DOWN:
				case LeadingModel.IDEOGRAPHIC_CENTER_DOWN:
					return false;
			}
		}
		
		tlf_internal function incInteractiveChildrenCount() : void
		{
			++ _interactiveChildrenCount ;
		}
		tlf_internal function decInteractiveChildrenCount() : void
		{
			-- _interactiveChildrenCount ;
		}
		
		tlf_internal function hasInteractiveChildren() : Boolean
		{
			return _interactiveChildrenCount != 0 ;
		}

		tlf_internal function get terminatorSpan():SpanElement
		{
			return _terminatorSpan;
		}

	}
}
