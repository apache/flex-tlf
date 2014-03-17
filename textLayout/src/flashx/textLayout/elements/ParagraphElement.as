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
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.tlf_internal;
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
		private var _textBlock:TextBlock;
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
			_textBlock = new TextBlock();
			CONFIG::debug { Debugging.traceFTECall(_textBlock,null,"new TextBlock()"); }
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:FlowElement = getChildAt(i);
				child.createContentElement();
			}
			updateTextBlock();
		}
		
		/** @private */
		
		tlf_internal function releaseTextBlock():void
		{
			if (!_textBlock)
				return;
				
			if (_textBlock.firstLine)	// A TextBlock may have no firstLine if it has previously been released.
			{
				for (var textLineTest:TextLine = _textBlock.firstLine; textLineTest != null; textLineTest = textLineTest.nextLine)
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
				
				CONFIG::debug { Debugging.traceFTECall(null,_textBlock,"releaseLines",_textBlock.firstLine, _textBlock.lastLine); }				
				_textBlock.releaseLines(_textBlock.firstLine, _textBlock.lastLine);	
			}	

			_textBlock.content = null;
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:FlowElement = getChildAt(i);
				child.releaseContentElement();
			}
			_textBlock = null;
			if (_computedFormat)
				_computedFormat = null;
		}
		
		/** TextBlock where the text of the paragraph is kept. @private */
		tlf_internal function getTextBlock():TextBlock
		{ 
			if (!_textBlock)
				createTextBlock();
			return _textBlock; 
		}
		
		/** TextBlock where the text of the paragraph is kept, or null if we currently don't have one. @private */
		tlf_internal function peekTextBlock():TextBlock
		{ 
			return _textBlock; 
		}
		
		/** @private */
		tlf_internal function releaseLineCreationData():void
		{
			CONFIG::debug { assert(Configuration.playerEnablesArgoFeatures,"bad call to releaseLineCreationData"); }
			if (_textBlock)
				_textBlock["releaseLineCreationData"]();
		}
		
		/** @private */
		tlf_internal override function createContentAsGroup():GroupElement
		{ 			
			var group:GroupElement = _textBlock.content as GroupElement;
			if (!group)
			{
				var originalContent:ContentElement = _textBlock.content;
				
				group = new GroupElement();
				CONFIG::debug { Debugging.traceFTECall(group,null,"new GroupElement()"); }
				_textBlock.content = group;
				CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"content",group); }

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
				if (_textBlock.firstLine && textLength)
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
			if (numChildren == 1)
			{
				if (block is GroupElement)
				{
					// see insertBlockElement
					CONFIG::debug { assert(_textBlock.content != block,"removeBlockElement: bad call to removeBlockElement"); }
					CONFIG::debug { assert(_textBlock.content is GroupElement,"removeBlockElement: bad content"); }
					CONFIG::debug { assert(GroupElement(_textBlock.content).elementCount == 1,"removeBlockElement: bad element count"); }
					CONFIG::debug { assert(GroupElement(_textBlock.content).getElementAt(0) == block,"removeBlockElement: bad group content"); }
					GroupElement(_textBlock.content).replaceElements(0,1,null);
					CONFIG::debug { Debugging.traceFTECall(null,_textBlock.content,"replaceElements",0,1,null); }
				}
				_textBlock.content = null;
				CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"content",null); }
			}
			else
			{
				var idx:int = this.getChildIndex(child);
				var group:GroupElement = GroupElement(_textBlock.content);
				CONFIG::debug { assert(group.elementCount == numChildren,"Mismatched group and elementCount"); }
				group.replaceElements(idx,idx+1,null);
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
						_textBlock.content = elem;
						CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"content",elem); }
					}
				}
			}
		}
		
		
		/** @private */
		tlf_internal override function hasBlockElement():Boolean
		{
			return _textBlock != null;
		}
		
		/** @private */
		override tlf_internal function createContentElement():void
		{
			createTextBlock();
		}
		
		/** @private */
		tlf_internal override function insertBlockElement(child:FlowElement, block:ContentElement):void
		{
			if (_textBlock == null)
			{
				child.releaseContentElement();
				createTextBlock();	// does the whole tree
				return;
			}
			var gc:Vector.<ContentElement>;	// scratch var
			var group:GroupElement;			// scratch
			if (numChildren == 1)
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
					_textBlock.content = group;
					CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"content",group); }
				}
				else
				{
					_textBlock.content = block;
					CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"content",block);  }
				}
			}
			else
			{
				group = createContentAsGroup();
				var idx:int = this.getChildIndex(child);
				gc = new Vector.<ContentElement>();
				CONFIG::debug { Debugging.traceFTECall(gc,null,"new Vector.<ContentElement>") }
				gc.push(block);
				CONFIG::debug { Debugging.traceFTECall(null,gc,"push",block); }
				group.replaceElements(idx,idx,gc);
				CONFIG::debug { Debugging.traceFTECall(null,group,"replaceElements",idx,idx,gc); }
			}
		}
		
		/** @private */
		override protected function get abstract():Boolean
		{ return false;	}	
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "p"; }

		/** @private */
		public override function replaceChildren(beginChildIndex:int,endChildIndex:int,...rest):void
		{
			var applyParams:Array;
			
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
			
			ensureTerminatorAfterReplace();
		}
		/** @private */
		tlf_internal function ensureTerminatorAfterReplace():void
		{
			var newLastLeaf:FlowLeafElement = getLastLeaf();
			if (_terminatorSpan != newLastLeaf)
			{
				if (_terminatorSpan)
				{
					_terminatorSpan.removeParaTerminator();
					this._terminatorSpan = null;
				}
				
				if (newLastLeaf)
				{
					if (newLastLeaf is SpanElement)
					{
						(newLastLeaf as SpanElement).addParaTerminator();
						this._terminatorSpan = newLastLeaf as SpanElement;
					}
					else
					{
						var s:SpanElement = new SpanElement();
						super.replaceChildren(numChildren,numChildren,s);
						s.format = newLastLeaf.format;
						s.addParaTerminator();
						this._terminatorSpan = s;
					}
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
		}
		
		/** @private
 		 */
		public override function getText(relativeStart:int=0, relativeEnd:int=-1, paragraphSeparator:String="\n"):String
		{
			// Optimization for getting text of the entire paragraph
			if (relativeStart == 0 && (relativeEnd == -1 || relativeEnd >= textLength-1) && _textBlock)
			{
				if (_textBlock.content && _textBlock.content.rawText)
				{
					var text:String = _textBlock.content.rawText;
					return text.substring(0, text.length - 1);
				}
				return "";		// content is null
			}
			return super.getText(relativeStart, relativeEnd, paragraphSeparator);
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
			if (ContainerController.tlf_internal::usesDiscretionaryHyphens)
			{
				var textBlock:TextBlock = getTextBlock();
				var tl:TextLine = textBlock.getTextLineAtCharIndex(relativePosition);
				var currentAtomIndex:int = tl.getAtomIndexAtCharIndex(relativePosition);
                //trace("relpos", relativePosition, "atomIndex", currentAtomIndex);
                var isRTL:Boolean = tl.getAtomBidiLevel(currentAtomIndex) == 1;
                if (isRTL)
                {
                   var foo:int = getTextBlock().findPreviousAtomBoundary(relativePosition);
                   if (currentAtomIndex == 0)
                   {
                       // when cursor is left of all characters (end of line)
                       // atomIndex is 0, so compensate
                       if (tl.atomCount > 0)
                       {
                           while (--relativePosition)
                           {
                               if (tl.getAtomIndexAtCharIndex(relativePosition) != currentAtomIndex)
                                   break;
                           }
                       }
                   }
                   else
                   {
                       while (--relativePosition)
                       {
                           if (tl.getAtomIndexAtCharIndex(relativePosition) != currentAtomIndex)
                               break;
                       }
                   }
                   if (CharacterUtil.isLowSurrogate(getText(relativePosition, relativePosition + 1).charCodeAt(0)))
                       relativePosition--;
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
    					if (tl.textBlockBeginIndex + tl.rawTextLength == relativePosition)
    						return tl.textBlockBeginIndex + tl.rawTextLength - 1;
    					return tl.textBlockBeginIndex + tl.rawTextLength;
    				}
    				while (--relativePosition)
    				{
    					if (tl.getAtomIndexAtCharIndex(relativePosition) < currentAtomIndex)
    						break;
    				}
                    if (CharacterUtil.isLowSurrogate(getText(relativePosition, relativePosition + 1).charCodeAt(0)))
                        relativePosition--;
                }
				return relativePosition;
			}
            var pos:int = getTextBlock().findPreviousAtomBoundary(relativePosition);
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
			if (ContainerController.tlf_internal::usesDiscretionaryHyphens)
			{
				var textBlock:TextBlock = getTextBlock();
				var tl:TextLine = textBlock.getTextLineAtCharIndex(relativePosition);
				var currentAtomIndex:int = tl.getAtomIndexAtCharIndex(relativePosition);
                //trace("relpos", relativePosition, "atomIndex", currentAtomIndex);
                var isRTL:Boolean = tl.getAtomBidiLevel(currentAtomIndex) == 1;
                if (isRTL)
                {
                    var foo:int = getTextBlock().findNextAtomBoundary(relativePosition);
                    if (currentAtomIndex == 0)
                    {
                        while (++relativePosition)
                        {
                            if (tl.getAtomIndexAtCharIndex(relativePosition) != currentAtomIndex)
                                break;
                        }
                    }
                    else
                    {
                        while (++relativePosition)
                        {
                            if (tl.getAtomIndexAtCharIndex(relativePosition) != currentAtomIndex)
                                break;
                        }
                    }
                    if (CharacterUtil.isHighSurrogate(getText(relativePosition, relativePosition + 1).charCodeAt(0)))
                        relativePosition++;
                    //trace("next", relativePosition, foo);
                }
                else
                {
    				if (currentAtomIndex == tl.atomCount - 1)
    				{
    					tl = tl.nextLine;
    					if (!tl)
    						return -1;
    					return tl.textBlockBeginIndex;
    				}
    				while (++relativePosition)
    				{
    					if (tl.getAtomIndexAtCharIndex(relativePosition) > currentAtomIndex)
    						break;
    				}
                    if (CharacterUtil.isHighSurrogate(getText(relativePosition, relativePosition + 1).charCodeAt(0)))
                        relativePosition++;
                }
				return relativePosition;
			}
			var pos:int = getTextBlock().findNextAtomBoundary(relativePosition);
            //trace("next", relativePosition, pos);
            return pos;
		}
		
		/** @private */
		public override function getCharAtPosition(relativePosition:int):String
		{
			return getTextBlock().content.rawText.charAt(relativePosition);
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
			return getTextBlock().findPreviousWordBoundary(relativePosition);
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
			return getTextBlock().findNextWordBoundary(relativePosition);
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
		
		private function updateTextBlock():void
		{
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
				_textBlock.textJustifier = spaceJustifier;
				CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"textJustifier",spaceJustifier); }
				_textBlock.baselineZero = getLeadingBasis(this.getEffectiveLeadingModel());
				CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"baselineZero",_textBlock.baselineZero);  }
			}
			else
			{
				var eastAsianJustifier:Object = new EastAsianJustifier(_computedFormat.locale,lineJust, makeJustRuleStyle);
				if( Configuration.versionIsAtLeast(10,3) && eastAsianJustifier.hasOwnProperty("composeTrailingIdeographicSpaces")){
					eastAsianJustifier.composeTrailingIdeographicSpaces = true;
				}
				CONFIG::debug { Debugging.traceFTECall(eastAsianJustifier,null,"new EastAsianJustifier",_computedFormat.locale,lineJust,makeJustRuleStyle); }
				_textBlock.textJustifier = eastAsianJustifier as EastAsianJustifier;
				CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"textJustifier",eastAsianJustifier);  }
				_textBlock.baselineZero = getLeadingBasis(this.getEffectiveLeadingModel());
				CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"baselineZero",_textBlock.baselineZero);  }
			}
			
			_textBlock.bidiLevel = _computedFormat.direction == Direction.LTR ? 0 : 1;
			CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"bidiLevel",_textBlock.bidiLevel);  }

			_textBlock.lineRotation = containerElementFormat.blockProgression == BlockProgression.RL ? TextRotation.ROTATE_90 : TextRotation.ROTATE_0;
			CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"lineRotation",_textBlock.lineRotation);  }
			
			if (_computedFormat.tabStops && _computedFormat.tabStops.length != 0)
			{
				//create a vector of TabStops and assign it to tabStops in _textBlock
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
				_textBlock.tabStops = tabStops;
				CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"tabStops",tabStops);  }
			} 
			else if (GlobalSettings.enableDefaultTabStops && !Configuration.playerEnablesArgoFeatures)
			{
				// 	Player versions prior to 10.1 do not set up any default tabStops. As a workaround, if enableDefaultTabs
				//	is true, TLF will set up default tabStops in the case where there are no tabs defined. 
				if (_defaultTabStops == null)
					initializeDefaultTabStops();
				_textBlock.tabStops = _defaultTabStops;
				CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"tabStops",_defaultTabStops);  }
			}
			else
			{
				_textBlock.tabStops = null;
				CONFIG::debug { Debugging.traceFTEAssign(_textBlock,"tabStops",null);  }
			}		 
		}
		
		/** @private */
		public override function get computedFormat():ITextLayoutFormat
		{
			if (!_computedFormat)
			{
				super.computedFormat;
				if (_textBlock)
					updateTextBlock();
			}
			return _computedFormat;
		}

		/** @private */
		tlf_internal override function canOwnFlowElement(elem:FlowElement):Boolean
		{
			return elem is FlowLeafElement || elem is SubParagraphGroupElementBase;
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
		
		// mjzhang : new API for table feature, to discuss
		public function isInTable():Boolean
		{
			var parent:FlowElement = this.parent;
			while ( parent )
			{
				if ( (parent is TableDataCellElement) )
					return true;
				parent = parent.parent;
			}
				
			return false;
		}
		
		public function getTableDataCellElement():TableDataCellElement
		{
			var parent:FlowElement = this.parent;
			while ( parent )
			{
				if ( (parent is TableDataCellElement) )
					return parent as TableDataCellElement;
				parent = parent.parent;
			}
			
			return null;
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
			var rslt:int = super.debugCheckFlowElement(depth," fte:"+getDebugIdentity(_textBlock)+" "+extraData);
			
			// now check the character count and then the last character 
			
			if (_textBlock)
			{
				var contentLength:int = _textBlock.content && _textBlock.content.rawText ? _textBlock.content.rawText.length : 0;
				rslt += assert(contentLength == textLength,"Bad paragraph length mode:"+textLength.toString()+" _textBlock:" + contentLength.toString());

				var groupElement:GroupElement = _textBlock.content as GroupElement;
				if (groupElement)
					assert(groupElement.elementCount == numChildren,"Mismatched group and elementCount"); 
				else if (_textBlock.content)
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
	}
}
