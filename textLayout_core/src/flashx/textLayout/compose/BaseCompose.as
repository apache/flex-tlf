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
package flashx.textLayout.compose
{
	import flash.geom.Rectangle;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.*;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.utils.LocaleUtil;
	
	use namespace tlf_internal;
	
	
	[ExcludeClass]
	/** @private Common composer base class */
	public class BaseCompose
	{
		
		public static function get globalSWFContext():ISWFContext
		{ 
			return GlobalSWFContext.globalSWFContext; 
		}
		
		protected var _parcelList:IParcelList;
		
		/** List of areas we're composing into, matches the container's bounding box */
		public function get parcelList():IParcelList
		{ return _parcelList; }
		
		/** Element of current location */
		protected var _curElement:FlowLeafElement;		
		/** Absolute start position of _curElement */
		protected var _curElementStart:int;		
		/** Offset from element start to current location */
		protected var _curElementOffset:int;		
		/** ParagraphElement that contains the current location */
		protected var _curParaElement:ParagraphElement;	
		protected var _curParaFormat:ITextLayoutFormat;
		/** Absolute start position of _curParaElement */
		protected var _curParaStart:int;
		/** leading direction for the current line's para (set when line is being composed and committed to _lastLineLeadingModel when line is finalized) */
		private var _curLineLeadingModel:String = "";
		/** leading amount for the current line (set when line is being composed and committed to _lastLineLeading when line is finalized) */
		private var _curLineLeading:Number;
		/** leading direction for the last line's para */
		protected var _lastLineLeadingModel:String = "";
		/** leading amount for the last line */
		protected var _lastLineLeading:Number;
		/** descent of the last line */
		protected var _lastLineDescent:Number;
		/** Amount of spaceAfter added to the previous line */
		protected var _spaceCarried:Number;
		/** BlockProgression - vertical horizontal etc. @see text.formats.BlockProgression */
		protected var _blockProgression:String;
		
		/** Minimum left edge coordinate across all the parcels in a controller */
		private var _controllerLeft:Number;
		/** Minimum top edge across all the parcels in a controller */
		private var _controllerTop:Number;
		/** Maximum right edge coordinate across all the parcels in a controller */
		private var _controllerRight:Number;
		/** Maximum bottom edge coordinate across all the parcels in a controller */
		private var _controllerBottom:Number;
		
		/** Maximum horizontal extension from left/right edge of the parcel.  Alignment width for the parcel. */
		protected var _contentLogicalExtent:Number;
		/* Commited extent any lines needing additional alignment must update this number */
		protected var _contentCommittedExtent:Number;
		
		/** Minimum left edge coordinate across all the parcels in a controller */
		protected var _parcelLeft:Number;
		/** Minimum top edge across all the parcels in a controller */
		protected var _parcelTop:Number;
		/** Maximum right edge coordinate across all the parcels in a controller */
		protected var _parcelRight:Number;
		/** Maximum bottom edge coordinate across all the parcels in a controller */
		protected var _parcelBottom:Number;
		
		/** owning textFlow of current compose */
		protected var _textFlow:TextFlow;
		private var _releaseLineCreationData:Boolean;
		/** flowComposer of current compose */
		protected var _flowComposer:StandardFlowComposer;
		/** rootElement of current compose */
		protected var _rootElement:ContainerFormattedElement;
		/** position to stop composing at */
		protected var _stopComposePos:int;
		
		/** First damaged controller to begin composing */
		protected var _startController:ContainerController;
		/** Beginning composition position.  Note this gets cleared once its been passed */
		protected var _startComposePosition:int;
		
		
		// scratch line slugs
		static protected var _candidateLineSlug:Rectangle = new Rectangle();
		static protected var _lineSlug:Rectangle = new Rectangle();
		
		// scratch array for holding lines awaiting alignment
		static private var _alignLines:Array;
		
		/** Parcel we are composing - used for keeping track of when it changes b/c parcelList.parcel may have advanced */
		protected var _curParcel:Parcel;
		
		/** Start position of _curParcel */
		protected var _curParcelStart:int;
		
		/** Constructor. */
		public function  BaseCompose()
		{	
			
		}
		
		protected function createParcelList():IParcelList
		{ return null; }
		protected function releaseParcelList(list:IParcelList):void
		{ }
		
		/** Starting controller for skipping ahead */
		public function get startController():ContainerController
		{ return _startController; }
		
		/** prevent any leaks. @private */
		tlf_internal function releaseAnyReferences():void
		{
			_curElement = null;
			_curParaElement = null;
			_curParaFormat = null;
			_flowComposer = null;
			_parcelList = null;
			_rootElement = null;
			_startController = null;
			_textFlow = null;
		}
		
		/** Initialize for a composition that will compose up through the controllerEndIndex, or all the way to the end of the flow
		 * @param composer
		 * @param composeToPosition 	-1 means not specified.  0 means request to compose nothing, >0 specifies a position to force compose to
		 * @param controllerEndIndex	index of the last controller to compose for, or -1 to compose through all controllers
		 */
		protected function  initializeForComposer(composer:IFlowComposer, composeToPosition:int, controllerEndIndex:int):void
		{
			_parcelList = createParcelList();
			_parcelList.notifyOnParcelChange = parcelHasChanged;
			
			_spaceCarried = 0;
			// TODO: just use the rootElement for table cells
			_blockProgression = composer.rootElement.computedFormat.blockProgression;
			// for a non-specified compose position the ParcelList handles the bail out - just set to textLength
			_stopComposePos = composeToPosition >= 0 ? Math.min(_textFlow.textLength,composeToPosition) : _textFlow.textLength;
			
			// this chains through the list - tell it if a "care about" comopseToPosition was specified
			_parcelList.beginCompose(composer, controllerEndIndex, composeToPosition > 0);	
			
			_contentLogicalExtent = 0;
			_contentCommittedExtent = 0;
		}
		
		/*
		* Compose an inline-block element, used for tables or other inline-blocks. The
		* element has a container associated with it, and the container is going to be placed
		* after the current paragraph if it fits in the text container.
		* 
		* @param composeFrame	the text container we're composing into
		*/
		protected function composeFloat(elem:ContainerFormattedElement,composeFrame:ContainerController):void
		{
			// Should get handled in derived class
			CONFIG::debug { assert(false, "Floats are not supported in ComposeState"); }
		}
		
		/** Called when we are about to compose a line. Handler for derived classes to override default behavior. */
		protected function startLine():void
		{
			// does nothing
		}
		
		/** Called when we are finished composing a line. Handler for derived classes to override default behavior.  */
		protected function endLine():void
		{
			// does nothing
		}		
		
		private function composeBlockElement(elem:FlowGroupElement,absStart:int):Boolean
		{	
			// Compose all the children, until all the containers are filled, or if we're on the last container, we've hit the stop compose text index
			var idx:int;
			if (_startComposePosition != 0)
			{
				idx = elem.findChildIndexAtPosition(_startComposePosition-absStart);
				CONFIG::debug { assert(idx != -1,"Bad _startComposePosition to index in composeBlockElement"); }
				absStart += elem.getChildAt(idx).parentRelativeStart;
			}
			else
				idx = 0;
			
			for (; idx < elem.numChildren && (absStart <= _stopComposePos || ! parcelList.atLast()); idx++)
			{
				var child:FlowElement = elem.getChildAt(idx);
				
				var para:ParagraphElement = child as ParagraphElement;
				if (para)
				{
					var rslt:Boolean = composeParagraphElement(para,absStart);
					// we need to flush each TextBlock - this saves a lot of memory at the cost of performance during editing	
					// note that this is a nop on older players.  only newer players implement flush	
					if (releaseLineCreationData)
						para.releaseLineCreationData();
					if (!rslt)
						return false;	// done
				}
				else if (child.display == FlowElementDisplayType.FLOAT)
				{
					composeFloat(ContainerFormattedElement(child),_parcelList.controller);
					if (_parcelList.atEnd())
						return false;
					CONFIG::debug { assert(child.getAbsoluteStart() + child.textLength - _parcelList.controller.absoluteStart >= 0, "frame has negative composition"); }
				}
				else 
				{
					if (!composeBlockElement(FlowGroupElement(child),absStart))
						return false;
				}
				
				absStart += child.textLength;
			}
			return true;
		}
		
		// TODO: move somewhere reasonable
		
		private static function doNothingOnParcelChange(newParcel:Parcel):void
		{ }
		
		
		/**
		 * Compose the flow into the text container. Starts at the root element,
		 * and composes elements until either there are no more elements, or the
		 * text container is full. It will compose only the lines which are
		 * marked invalid, so that existing lines that are unchanged are not
		 * recomposed.
		 */
		public function composeTextFlow(textFlow:TextFlow, composeToPosition:int, controllerEndIndex:int):int
		{
			_textFlow = textFlow;
			_releaseLineCreationData = textFlow.configuration.releaseLineCreationData && Configuration.playerEnablesArgoFeatures;
			
			// must setup _startController and _startComposePosition
			initializeForComposer(textFlow.flowComposer, composeToPosition, controllerEndIndex);
			
			_flowComposer = _textFlow.flowComposer as StandardFlowComposer;
			_rootElement = textFlow;
			_curElementOffset = 0;
			_curElement = _rootElement.getFirstLeaf();	
			
			_curElementStart = 0;		// current position in the text (start of current line)
			
			_curParcel = null;
			resetControllerBounds();
			
			if (_startController != _flowComposer.getControllerAt(0))
			{
				var cacheNotify:Function = _parcelList.notifyOnParcelChange;
				_parcelList.notifyOnParcelChange =  doNothingOnParcelChange;
				// skip parcels until the first one in startController
				while(_parcelList.currentParcel.controller != _startController)
					_parcelList.next();
				_parcelList.notifyOnParcelChange =  cacheNotify;
			}
			
			parcelHasChanged(_parcelList.currentParcel);		// force start of composition acccounting initialization
			
			composeInternal(_rootElement,0);
			
			for (;;)
			{
				if (parcelList.atEnd())
				{
					parcelHasChanged(null);		// force end of composition accounting for the parcel
					break;
				}				
				parcelList.next();
			}
			
			
			releaseParcelList(_parcelList);
			_parcelList = null;
			
			return _curElementStart + _curElementOffset;		// Return last composed position
		}
		
		private function resetControllerBounds():void
		{
			_controllerLeft = TextLine.MAX_LINE_WIDTH;
			_controllerTop = TextLine.MAX_LINE_WIDTH;
			_controllerRight = -TextLine.MAX_LINE_WIDTH;
			_controllerBottom = -TextLine.MAX_LINE_WIDTH;
		}
		
		/** Release line creation data during this compose */
		protected function get releaseLineCreationData():Boolean
		{ return _releaseLineCreationData; }
		
		// Create new lines through composition. lines, wrap, etc.
		protected function composeInternal(composeRoot:FlowGroupElement,absStart:int):void
		{
			composeBlockElement(composeRoot,absStart);
		}
		
		protected function composeParagraphElement(elem:ParagraphElement,absStart:int):Boolean
		{
			CONFIG::debug { assert(false,"MISSING OVERRIDE"); }
			return false;
		}
		
		protected function composeParagraphElementIntoLines():Boolean
		{
			var curLine:TextFlowLine;
			
			// loop creating lines
			for (;;)
			{
				if (_parcelList.atEnd())
					return false;
				
				// Allow derived classes to do processing here
				startLine();
				
				// Get the next line
				curLine = composeNextLine();
				if (curLine ==  null)
					return false;
				
				var alignData:AlignData = calculateTextAlign(curLine, curLine.getTextLine());
				
				/* {
				for (var idx:int = 0; idx < curLine.textLine.atomCount; idx++)
				{
				trace(idx.toString()+": beginIndex: " + curLine.textLine.getAtomTextBlockBeginIndex(idx)+ " bidiLevel: "+ curLine.textLine.getAtomBidiLevel(idx) + " bounds: " + curLine.textLine.getAtomBounds(idx));
				}
				} */
				
				if ((curLine.spaceBefore != 0 || _spaceCarried != 0) && !_parcelList.isColumnStart())
					_parcelList.addTotalDepth(Math.max(curLine.spaceBefore, _spaceCarried));
				_spaceCarried = 0;
				_parcelList.addTotalDepth(curLine.height);
				_curElementOffset += curLine.textLength;
				// textLength is the first character in the next line
				
				var textLine:TextLine = curLine.getTextLine();
				
				var lineWidth:Number; 
				if (_parcelList.explicitLineBreaks)
				{
					var isRTL:Boolean = _curParaElement.computedFormat.direction == Direction.RTL;
					textLine = curLine.getTextLine(true);
					var lastAtom:int = textLine.atomCount - 1;
					// If we're at the end of the paragraph, don't count the terminator
					var endOfParagraph:Boolean = _curElementStart+_curElementOffset == _curParaStart + _curParaElement.textLength;
					if (endOfParagraph && !isRTL)
						--lastAtom;	// can go negative if just the terminator.  in that case use left/top of atom zero
					var bounds:Rectangle = textLine.getAtomBounds(lastAtom >= 0 ? lastAtom : 0);	// get rightmost atom bounds
					lineWidth = (_blockProgression == BlockProgression.TB) 
						? (lastAtom >= 0 ? bounds.right : bounds.left)
						: (lastAtom >= 0 ? bounds.bottom : bounds.top);
					if (isRTL)	// in right to left, get leftmost atom bounds, that has trailing space
					{
						// in RTL strip the width of the paragraph terminator from the front
						bounds = textLine.getAtomBounds(lastAtom != 0 && endOfParagraph ? 1 : 0);						
						lineWidth -= (_blockProgression == BlockProgression.TB) ? bounds.left : bounds.top;
					}
					textLine.flushAtomData();
				}
				else
					lineWidth = textLine.textWidth;
				
				var rightSidePadding:Number =  _curParaFormat.direction == Direction.LTR ? _curParaFormat.paragraphEndIndent : _curParaFormat.paragraphStartIndent;
				var textIndent:Number = 0;
				var rightSideIndent:Number = 0;
				var leftSideIndent:Number = 0;
				if (_curParaFormat.direction == Direction.RTL && (curLine.location & TextFlowLineLocation.FIRST))
				{
					// the textIndent isn't applied on left aligned paragraphs in measured RTL mode
					// need to be careful because leftaligned paragraphs need to be exactly right coming out of this routine
					if (alignData && (_blockProgression == BlockProgression.TB && !curLine.controller.measureWidth || _blockProgression == BlockProgression.RL && !curLine.controller.measureHeight))
						rightSideIndent = _curParaFormat.textIndent;
				}
				var leftSidePadding:Number =  _curParaFormat.direction == Direction.LTR ? _curParaFormat.paragraphStartIndent : _curParaFormat.paragraphEndIndent;
				if (_curParaFormat.direction == Direction.LTR && (curLine.location & TextFlowLineLocation.FIRST))
				{
					// recording leftSideIndent is here because there is an extra alignment step for non-left aligned paragraphs
					leftSideIndent = _curParaFormat.textIndent;
				}					
				
				if (alignData)
				{
					alignData.rightSidePadding = rightSidePadding;
					alignData.leftSidePadding  = leftSidePadding;
					alignData.lineWidth = lineWidth;
					alignData.rightSideIndent = rightSideIndent;
					alignData.leftSideIndent = leftSideIndent;
					
					// trace("AlignData",alignData.leftSidePadding,alignData.rightSidePadding,alignData.lineWidth,alignData.leftSideIndent,alignData.rightSideIndent);
				}
				
				// extent from the left margin
				var lineExtent:Number = lineWidth + leftSidePadding+leftSideIndent + rightSidePadding+rightSideIndent;
				_contentLogicalExtent = Math.max(_contentLogicalExtent, lineExtent);
				if (!alignData)
					_contentCommittedExtent = Math.max(_contentCommittedExtent, lineExtent);
				
				CONFIG::debug { assert(_parcelList.controller.textLength >= 0, "frame has negative composition"); }
				
				if (_parcelList.atEnd())
					return false;
				
				endLine();
				
				// advance to the next element, using the rootElement of the container as a limitNode
				// to prevent going past the content bound to this container
				if (_curElementOffset >= _curElement.textLength)
				{
					// We may have composed ahead over several spans; skip until we match up
					// Loop until we use catch up to where the line we just composed ended (pos).
					// Stop if we run out of elements. Skip empty inline elements, and skip floats
					// that came at the start of the line before any text -- they've already been 
					// processed.
					do{
						_curElementOffset -= _curElement.textLength;
						_curElementStart  += _curElement.textLength;
						if (_curElementStart == _curParaStart+_curParaElement.textLength)
						{
							_curElement = null;
							break;
						}
						_curElement = _curElement.getNextLeaf();
						CONFIG::debug { assert(_curElement && _curElement.getParagraph() == _curParaElement,"composeParagraphElement: bad textLength in TextLine"); }
					} while (_curElementOffset >= _curElement.textLength || _curElement.textLength == 0 );
				}
				
				_spaceCarried = curLine.spaceAfter;
				
				
				if (_curElement == null)
					break;
			}
			return true;
		}
		
		protected function composeNextLine():TextFlowLine
		{
			CONFIG::debug { throw new Error("composeNextLine requires override"); }		
			return null;
		}
		
		// fills in _lineSlug
		protected function fitLineToParcel(curLine:TextFlowLine, isNewLine:Boolean):TextFlowLine
		{
			// Try to place the line in the current parcel.
			// get a zero height parcel. place the line there and then test if it still fits.
			// if it doesn't place it in the new result parcel
			// still need to investigate because the height used on the 2nd getLineSlug call may be too big.
			for (;;)
			{
				if (_parcelList.getLineSlug(_candidateLineSlug,0))
					break;
				_parcelList.next();
				if (_parcelList.atEnd())
					return null;
				_spaceCarried = 0;
			}
			
			curLine.setController(_parcelList.controller,_parcelList.columnIndex);
			
			// If we are at the last parcel, we let text be clipped if that's specified in the configuration. At the point where no part of text can be accommodated, we go overset.
			// If we are not at the last parcel, we let text flow to the next parcel instead of getting clipped.
			var spaceBefore:Number = Math.max(curLine.spaceBefore, _spaceCarried);
			for (;;)
			{
				finishComposeLine(curLine, _candidateLineSlug, isNewLine);	
				if (_parcelList.getLineSlug(_lineSlug, spaceBefore + (_parcelList.atLast() && _textFlow.configuration.overflowPolicy != OverflowPolicy.FIT_DESCENDERS ? curLine.height-curLine.ascent : curLine.height+curLine.descent)))
				{
					CONFIG::debug { assert(_parcelList.getComposeXCoord(_candidateLineSlug) == _parcelList.getComposeXCoord(_lineSlug) && _parcelList.getComposeYCoord(_candidateLineSlug) == _parcelList.getComposeYCoord(_lineSlug),"fitLineToParcel: slug mismatch"); }
					break;
				}
				spaceBefore = curLine.spaceBefore;
				for (;;)
				{
					_parcelList.next();
					if (_parcelList.atEnd())
						return null;
					if (_parcelList.getLineSlug(_candidateLineSlug,0))
						break;
				}
				curLine.setController(_parcelList.controller,_parcelList.columnIndex);
			}						
			
			// check to see if we got a good line
			return (_parcelList.getComposeWidth(_lineSlug) == curLine.outerTargetWidth) ? curLine : null;
		}
		
		
		protected function finishComposeLine(curLine:TextFlowLine, lineSlug:Rectangle, isNewLine:Boolean):void
		{      	
			var curTextLine:TextLine = curLine.getTextLine();
			var lineHeight:Number = 0;
			//replace X and Y with rise and run.  
			//	rise - the offset within a line relative to block progressiong.  For RL this is X, for TB Y
			//	run - the indentation of the line.  For RL this is Y, TB X
			var rise:Number = _blockProgression != BlockProgression.RL ? parcelList.getComposeYCoord(lineSlug) : _parcelList.getComposeXCoord(lineSlug);
			var run:Number = _blockProgression != BlockProgression.RL ? parcelList.getComposeXCoord(lineSlug) : _parcelList.getComposeYCoord(lineSlug);
			
			if (_curParaFormat.direction == Direction.LTR)
			{
				run += curLine.lineOffset;
			} 
			else 
			{
				run += curLine.outerTargetWidth-curLine.lineOffset-curLine.targetWidth;
				
				if (curLine.outerTargetWidth == TextLine.MAX_LINE_WIDTH && curLine.location&TextFlowLineLocation.FIRST)	// doing measurement ignore 
				{
					run += curLine.paragraph.computedFormat.textIndent;
				}
			}
			
			_curLineLeading = curLine.getLineLeading(_blockProgression,_curElement,_curElementStart);
			_curLineLeadingModel = _curParaElement.getEffectiveLeadingModel();
			
			var containerAttrs:ITextLayoutFormat = _parcelList.controller.computedFormat;		
			var baselineType:Object = BaselineOffset.LINE_HEIGHT;
			if (_parcelList.isColumnStart())
			{
				// If we're at the top of the column, we need to check the container properties to see
				// what the firstBaselineOffset should be. This tells us how to treat the line.
				// However, when vertical alignment is center or bottom, ignore the firstBaselineOffset setting
				// and treat them as the BaselineOffset.AUTO case
				if (containerAttrs.firstBaselineOffset != BaselineOffset.AUTO && containerAttrs.verticalAlign != VerticalAlign.BOTTOM && containerAttrs.verticalAlign != VerticalAlign.MIDDLE) 
				{
					baselineType = containerAttrs.firstBaselineOffset;
					// The first line's offset is specified relative firstBaselineOffsetBasis, which used to be, but no longer is, a container-level property
					// Now it is implicitly deduced based on the container-level locale in the following manner: 
					// IDEOGRAPHIC_BOTTOM for ja and zh locales (this is the same locale set for which the default LeadingModel is IDEOGRAPHIC_TOP_DOWN)
					// ROMAN for all other locales
					var firstBaselineOffsetBasis:String = LocaleUtil.leadingModel(containerAttrs.locale) == LeadingModel.IDEOGRAPHIC_TOP_DOWN ?  flash.text.engine.TextBaseline.IDEOGRAPHIC_BOTTOM : flash.text.engine.TextBaseline.ROMAN;
					lineHeight -= curTextLine.getBaselinePosition(firstBaselineOffsetBasis);		
				}
				else
				{
					if (_curLineLeadingModel == LeadingModel.APPROXIMATE_TEXT_FIELD)
					{
						// Reinterpret AUTO when APPROXIMATE_TEXT_FIELD leading model is used. 
						// Align the "enhanced ascent" (an approximation of TextField's notion of ascent baseline, 
						// which differs from FTEs notion of the same by an amount equal to the line's descent) with the container top inset
						lineHeight += Math.round(curTextLine.descent) + Math.round(curTextLine.ascent)
						
						// Ensure Roman baseline will fall at an integer position. This is desirable for all leading models, 
						// but only APPROXIMATE_TEXT_FIELD requires it now. In a future release, this code can be moved below and lineX/lineY rounded off directly. 
						if (_blockProgression == BlockProgression.TB)
							lineHeight = Math.round(rise + lineHeight) - rise;
						else
							lineHeight = rise - Math.round(rise - lineHeight);
						
						baselineType = 0; // No further adjustments    
					}
					else
					{
						// The AUTO case requires aligning line top to container top inset. This efect can be achieved by using firstBaselineOffset=ASCENT
						// and firstBaselineOffsetBasis=ROMAN 
						baselineType = BaselineOffset.ASCENT;
						
						if(curTextLine.hasGraphicElement)
						{
							var firstLineAdjustment:LeadingAdjustment = getLineAdjustmentForInline(curLine, _curLineLeadingModel, true);
							if(firstLineAdjustment != null)
							{
								if(_blockProgression == BlockProgression.RL)
								{
									firstLineAdjustment.rise = -(firstLineAdjustment.rise);
								}
								_curLineLeading += firstLineAdjustment.leading;
								rise += firstLineAdjustment.rise;
							}
						}
						
						lineHeight -= curTextLine.getBaselinePosition(flash.text.engine.TextBaseline.ROMAN);
					}
				}
			}
			else
			{
				// handle space before by adjusting y position of line
				if (curLine.spaceBefore != 0 || _spaceCarried != 0)
				{
					var spaceAdjust:Number = Math.max(curLine.spaceBefore, _spaceCarried);
					
					rise += _blockProgression == BlockProgression.RL ? -spaceAdjust :spaceAdjust;
				}
			}
			//getTextLineTypographicAscent
			if (baselineType == BaselineOffset.ASCENT)
			{
				//	CONFIG::debug { assert(_curElement == _textFlow.findLeaf(curLine.absoluteStart),"Bad _curElement"); }
				CONFIG::debug { assert(_curElementStart == _textFlow.findLeaf(curLine.absoluteStart).getAbsoluteStart(), "Bad _curElementStart"); }
				lineHeight += curLine.getLineTypographicAscent(_curElement,_curElementStart);
			}
			else 
			{
				if (baselineType == BaselineOffset.LINE_HEIGHT)
				{
					if (_curLineLeadingModel == LeadingModel.APPROXIMATE_TEXT_FIELD)
					{
						// Position the "enhanced ascent" (see above) at a distance of leading from the previous line's descent
						lineHeight += Math.round(_lastLineDescent) + Math.round(curTextLine.ascent) + Math.round(curTextLine.descent) + Math.round(_curLineLeading);
					}
					else if (_curLineLeadingModel == LeadingModel.ASCENT_DESCENT_UP)
					{
						lineHeight += _lastLineDescent + curTextLine.ascent + _curLineLeading;
					} 
					else
					{
						// Leading direction is irrelevant for the first line. Treat it as (UP, UP)
						// TODO-9/3/2008-It may be better to handle Middle/Last lines separately because we know that the previous line also belongs in the same para 
						var curLeadingDirectionUp:Boolean = _parcelList.isColumnStart() ? true : ParagraphElement.useUpLeadingDirection(_curLineLeadingModel);
						
						var prevLeadingDirectionUp:Boolean = _parcelList.isColumnStart() || _lastLineLeadingModel == "" ? true : 
							ParagraphElement.useUpLeadingDirection(_lastLineLeadingModel);
						
						var prevLineFirstElement:FlowLeafElement;
						
						if (curLeadingDirectionUp)
						{	
							//TODO-9/12/2008-The above behavior is the InDesign behavior but raises some questions about selection shapes.
							//Should selection code associate leading with the influencing line? That would be weird. InDesign only
							//supports alternate leading directions in the J feature set, where leading is never included in selection,
							//so this question does not arise. We take the unambiguous route: ignore leading DOWN at the end of a para
							lineHeight += _curLineLeading;
						}
						else
						{
							if (!prevLeadingDirectionUp)
							{
								// Same leading directions; use previous line's leading setting.
								lineHeight += _lastLineLeading;
							}
							else
							{
								// Make NO leading adjustments. Set lines solid.
								lineHeight += _lastLineDescent + curTextLine.ascent;
							}
						}	
					}
				}
				else
					lineHeight += Number(baselineType);		// fixed offset
			}
			
			//don't know why, but ascent only needs to be removed from horizontal text.  Hmm, that seems
			//odd to me - gak 12.15.09
			rise += _blockProgression == BlockProgression.RL ? -(lineHeight) : lineHeight - curTextLine.ascent;
			
			//baselineType will be BaselineOffset.ASCENT for fixed leading
			if(curTextLine.hasGraphicElement && baselineType != BaselineOffset.ASCENT)
			{
				var adjustment:LeadingAdjustment = getLineAdjustmentForInline(curLine, _curLineLeadingModel, false);
				if(adjustment != null)
				{	
					if(_blockProgression == BlockProgression.RL)
					{
						adjustment.rise = -(adjustment.rise);
					}
					_curLineLeading += adjustment.leading;
					rise += adjustment.rise;
				}
			}
			
			
			if(_blockProgression == BlockProgression.TB)
				curLine.setXYAndHeight(run,rise,lineHeight);
			else
				curLine.setXYAndHeight(rise,run,lineHeight);
			
			if(isNewLine)
				curLine.createAdornments(_blockProgression,_curElement,_curElementStart);
		}	
		
		// Calculate the text alignment of the current line we're composing. If alignment is required, the adjustment will be made in
		// applyTextAlign, after we've calculated the width of the parcel (it may be based on measurement).
		// TODO: optimization possibility - do the alignment here when not doing measurement
		private function calculateTextAlign(curLine:TextFlowLine, curTextLine:TextLine):AlignData
		{
			// Adjust the coordinates of the line for center/right.  The line is always left aligned.  TextBlock handles justified cases
			// If we're on the last line of a justified paragraph, use the textAlignLast value 
			var textAlignment:String = _curParaFormat.textAlign;
			if (textAlignment == TextAlign.JUSTIFY && _curParaFormat.textAlignLast != null)
			{
				var location:int = curLine.location;
				if (location == TextFlowLineLocation.LAST || location == TextFlowLineLocation.ONLY)
					textAlignment = _curParaFormat.textAlignLast;
			}
			switch(textAlignment)
			{
				case TextAlign.START:
					textAlignment = (_curParaFormat.direction == Direction.LTR) ? TextAlign.LEFT : TextAlign.RIGHT;
					break;
				case TextAlign.END:
					textAlignment = (_curParaFormat.direction == Direction.LTR) ? TextAlign.RIGHT : TextAlign.LEFT;
					break; 
			}
			
			var createAlignData:Boolean = textAlignment == TextAlign.CENTER || textAlignment == TextAlign.RIGHT;
			
			// in argo lines that have tabs must be either START or JUSTIFY
			if (Configuration.playerEnablesArgoFeatures)
			{
				if (curTextLine["hasTabs"])
				{
					if (_curParaFormat.direction == Direction.LTR)
					{
						createAlignData = false;	// don't align it - let it be left align
					}
					else
					{
						createAlignData = true;
						textAlignment = TextAlign.RIGHT;
					}
				}
			}
			
			
			if (createAlignData)
			{
				var alignData:AlignData = new AlignData();
				alignData.textLine = curTextLine;
				alignData.center = (textAlignment == TextAlign.CENTER);
				if (!_alignLines)
					_alignLines = [];
				_alignLines.push(alignData);
				return alignData;
			}
			return null;
		}
		
		private function applyTextAlign(effectiveParcelWidth:Number):void
		{
			var textLine:TextLine;
			var line:TextFlowLine;
			var alignData:AlignData;
			
			var coord:Number;
			var delta:Number;
			var adjustedLogicalRight:Number;
			var extraSpace:Number;
			var leftSideGap:Number;
			var rightSideGap:Number;
			
			if (_blockProgression == BlockProgression.TB)
			{
				for each (alignData in _alignLines) 
				{
					textLine = alignData.textLine;
					
					rightSideGap = alignData.rightSidePadding;
					leftSideGap = alignData.leftSidePadding;
					leftSideGap += alignData.leftSideIndent;
					rightSideGap += alignData.rightSideIndent;
					
					line = textLine.userData as TextFlowLine;
					extraSpace = effectiveParcelWidth - leftSideGap - rightSideGap -  textLine.textWidth;
					delta = leftSideGap + (alignData.center ? extraSpace / 2 : extraSpace);
					coord = _curParcel.left + delta;
					if (line)
						line.x = coord;
					textLine.x = coord;
					
					adjustedLogicalRight = alignData.lineWidth + coord + Math.max(rightSideGap, 0);
					_parcelRight = Math.max(adjustedLogicalRight , _parcelRight);
				}
			}
			else
			{
				for each (alignData in _alignLines) 
				{
					textLine = alignData.textLine;
					
					rightSideGap = alignData.rightSidePadding;
					leftSideGap = alignData.leftSidePadding;
					leftSideGap += alignData.leftSideIndent;
					rightSideGap += alignData.rightSideIndent;
					
					line = textLine.userData as TextFlowLine;
					extraSpace = effectiveParcelWidth - leftSideGap - rightSideGap -  textLine.textWidth;
					delta = leftSideGap + (alignData.center ? extraSpace / 2 : extraSpace);
					coord = _curParcel.top + delta;
					if (line)
						line.y = coord;
					textLine.y = coord;
					
					adjustedLogicalRight = alignData.lineWidth + coord + Math.max(rightSideGap, 0);
					_parcelBottom = Math.max(adjustedLogicalRight,_parcelBottom);
				}
			}
			_alignLines.length = 0;
		}
		
		protected function commitLastLineState(curLine:TextFlowLine):void
		{
			// Remember leading-related state that may be used for laying out the next line
			_lastLineDescent = curLine.descent;
			_lastLineLeading = _curLineLeading;
			_lastLineLeadingModel = _curLineLeadingModel;
		}
		
		protected function doVerticalAlignment(canVerticalAlign:Boolean,nextParcel:Parcel):Boolean
		{
			// stub for required override
			CONFIG::debug { assert(false, "override in derived class"); }
			return false;
		}
		
		protected function finalParcelAdjustment(controller:ContainerController):void
		{
			// stub for required override
			CONFIG::debug { assert(false, "finalParcelAdjustment missing override in derived class"); }
		}
		
		protected function finishParcel(controller:ContainerController,nextParcel:Parcel):Boolean
		{
			if (_curParcelStart == _curElementStart+_curElementOffset)		// empty parcel -- nothing composed into it
			{
				CONFIG::debug { assert(_contentLogicalExtent == 0,"bad contentlogicalextent on empty container"); }
				return false;
			}
			
			// We're only going to align the lines in measurement mode if there's only one parcel
			var doTextAlign:Boolean = (_alignLines && _alignLines.length > 0); 
			
			// Figure out the contents bounds information for the parcel we just finished composing
			
			// Content logical height is parcel depth, plus descenders of last line
			var totalDepth:Number = _parcelList.totalDepth;
			if (_textFlow.configuration.overflowPolicy == OverflowPolicy.FIT_DESCENDERS && !isNaN(_lastLineDescent))
				totalDepth += _lastLineDescent;
			
			// Initialize the parcel bounds
			// note we can later optimize away the adjustements
			if (_blockProgression == BlockProgression.TB)
			{
				_parcelLeft = _curParcel.left;
				_parcelTop = _curParcel.top;
				_parcelRight = _contentCommittedExtent+_curParcel.left;
				_parcelBottom = totalDepth+_curParcel.top;
			}
			else
			{
				// Push the values up to the controller running min/max, if they are bigger
				_parcelLeft = _curParcel.right-totalDepth;
				_parcelTop = _curParcel.top;
				_parcelRight = _curParcel.right;
				_parcelBottom = _contentCommittedExtent+_curParcel.top;
			}			
			if (doTextAlign)
			{
				var effectiveParcelWidth:Number;
				if (_blockProgression == BlockProgression.TB)
					effectiveParcelWidth = controller.measureWidth ? _contentLogicalExtent : _curParcel.width;
				else
					effectiveParcelWidth = controller.measureHeight ? _contentLogicalExtent : _curParcel.height;
				applyTextAlign(effectiveParcelWidth);
			}
			
			// If we're measuring, then don't do vertical alignment
			var canVerticalAlign:Boolean = false;
			if (_blockProgression == BlockProgression.TB)
			{
				if (!controller.measureHeight && (!_curParcel.fitAny || _curElementStart + _curElementOffset >= _textFlow.textLength))
					canVerticalAlign = true;
			}
			else
			{
				if (!controller.measureWidth && (!_curParcel.fitAny || _curElementStart + _curElementOffset >= _textFlow.textLength))
					canVerticalAlign = true;
			}
			
			// need to always call this function because internal variables may need resetting
			if (doVerticalAlignment(canVerticalAlign,nextParcel))
				doTextAlign = true;
			// This last adjustment is for two issues
			// 1) inline graphics that extend above the top (any ILGS I expect)
			// 2) negative first line indents (stil a worry here?)
			// If neither of these are present it can be skipped - TODO optimization
			// trace("BEF finalParcelAdjustment",_parcelLeft,_parcelRight,_parcelTop,_parcelBottom);
			finalParcelAdjustment(controller);
			// trace("AFT finalParcelAdjustment",_parcelLeft,_parcelRight,_parcelTop,_parcelBottom);
			_contentLogicalExtent = 0;
			_contentCommittedExtent = 0;
			
			return true;
		}
		
		/** apply vj and adjust the parcel bounds */
		protected function applyVerticalAlignmentToColumn(controller:ContainerController,vjType:String,lines:Array,beginIndex:int,numLines:int):void
		{
			var firstLine:IVerticalJustificationLine = lines[beginIndex];
			var lastLine:IVerticalJustificationLine = lines[beginIndex+numLines-1]
			var firstLineCoord:Number;
			var lastLineCoord:Number
			if (_blockProgression == BlockProgression.TB)
			{
				firstLineCoord = firstLine.y;
				lastLineCoord  = lastLine.y;
			}
			else
			{
				firstLineCoord = firstLine.x;
				lastLineCoord = lastLine.x;
			}
			
			VerticalJustifier.applyVerticalAlignmentToColumn(controller,vjType,lines,beginIndex,numLines);
			
			if (_blockProgression == BlockProgression.TB)
			{
				_parcelTop += firstLine.y-firstLineCoord;
				_parcelBottom += lastLine.y-lastLineCoord;
			}
			else
			{
				_parcelRight += firstLine.x-firstLineCoord;
				_parcelLeft += lastLine.x-lastLineCoord;
			}
		}
		
		private function finishController(controller:ContainerController):void
		{
			var controllerTextLength:int = _curElementStart + _curElementOffset - controller.absoluteStart;
			
			if (controllerTextLength != 0)
			{
				// Leave room for the padding. If the content overlaps the padding, don't count the padding twice.
				var paddingLeft:Number = controller.effectivePaddingLeft;
				var paddingTop:Number = controller.effectivePaddingTop;
				var paddingRight:Number = controller.effectivePaddingRight;
				var paddingBottom:Number = controller.effectivePaddingBottom;
				if (_blockProgression == BlockProgression.TB)
				{
					if (_controllerLeft > 0)
					{
						if (_controllerLeft < paddingLeft)
							_controllerLeft = 0;
						else 
							_controllerLeft -= paddingLeft;
					}
					
					if (_controllerTop > 0)
					{
						if (_controllerTop < paddingTop)
							_controllerTop = 0;
						else 
							_controllerTop -= paddingTop;
					}
					
					if (isNaN(controller.compositionWidth))
						_controllerRight += paddingRight;		 				
					else if (_controllerRight < controller.compositionWidth)
					{
						if (_controllerRight > controller.compositionWidth - paddingRight)
							_controllerRight = controller.compositionWidth;
						else 
							_controllerRight += paddingRight;
					}
					_controllerBottom += paddingBottom;	
				}
				else
				{
					_controllerLeft -= paddingLeft;
					if (_controllerTop > 0)
					{
						if (_controllerTop < paddingTop)
							_controllerTop = 0;
						else 
							_controllerTop -= paddingTop;
					}
					if (_controllerRight < 0)
					{
						if (_controllerRight > -paddingRight)
						{
							_controllerRight = 0;
						}
						else
							_controllerRight += paddingRight;
					}
					if (isNaN(controller.compositionHeight))
						_controllerBottom += paddingBottom;
					else if (_controllerBottom < controller.compositionHeight)
					{
						if (_controllerBottom > controller.compositionHeight - paddingBottom)
							_controllerBottom = controller.compositionHeight;
						else 
							_controllerBottom += paddingBottom;
					}
				}
				controller.setContentBounds(_controllerLeft, _controllerTop, _controllerRight-_controllerLeft, _controllerBottom-_controllerTop);
			}
			else
				controller.setContentBounds(0,0,0,0);
			
			controller.setTextLength(controllerTextLength);
		}
		
		private function clearControllers(oldController:ContainerController, newController:ContainerController):void
		{
			// any controller between oldController and up to and including newController gets cleared
			var firstToClear:int = oldController ? _flowComposer.getControllerIndex(oldController)+1 : 0;
			var lastToClear:int  = newController ? _flowComposer.getControllerIndex(newController) : _flowComposer.numControllers-1;
			while (firstToClear <= lastToClear)
			{
				var controllerToClear:ContainerController = ContainerController(_flowComposer.getControllerAt(firstToClear));
				controllerToClear.setContentBounds(0, 0, 0, 0);
				controllerToClear.setTextLength(0);
				firstToClear++;
			}
		}
		
		/** This is called when the parcel has changed 
		 * @param oldParcel - the parcel we had before (you can get the new parcel from the parcel list)
		 */
		protected function parcelHasChanged(newParcel:Parcel):void
		{
			var oldController:ContainerController = _curParcel ? ContainerController(_curParcel.controller) : null;
			var newController:ContainerController = newParcel  ? ContainerController(newParcel.controller)  : null;
			
			/* if (newParcel)
			trace("parcelHasChanged newParcel: ",newParcel.clone().toString()); */
			
			if (_curParcel != null)
			{
				if (finishParcel(oldController,newParcel))
				{
					if (_parcelLeft < _controllerLeft)
						_controllerLeft = _parcelLeft;
					if (_parcelRight > _controllerRight)
						_controllerRight = _parcelRight;
					if (_parcelTop < _controllerTop)
						_controllerTop = _parcelTop;
					if (_parcelBottom > _controllerBottom)
						_controllerBottom = _parcelBottom;
				}
			}
			
			// update parcel data			
			if (oldController != newController)		// we're going on to the next controller in the chain
			{
				if (oldController)
					finishController(oldController);
				
				resetControllerBounds();
				
				if (_flowComposer.numControllers > 1)
				{
					if (oldController == null && _startController)
						clearControllers(_startController, newController);
					else
						clearControllers(oldController, newController);
				}
				// Parcel list will set totalDepth to newController's paddingTop
			}
			_curParcel = newParcel;
			_curParcelStart = _curElementStart;
		}
		/** @private */
		private function getLineAdjustmentForInline(curLine:TextFlowLine, curLeadingDir:String, isFirstLine:Boolean):LeadingAdjustment
		{
			var adjustment:LeadingAdjustment = null;
			var curTextLine:TextLine = curLine.getTextLine();
			var para:ParagraphElement = curLine.paragraph;
			var flowElem:FlowLeafElement = _curElement; //the first element included in this line
			var curPos:int = flowElem.getAbsoluteStart();
			var largestPointSize:Number = flowElem.getEffectiveFontSize();
			var largestImg:Number = 0;
			
			//walk
			while(flowElem && curPos < curLine.absoluteStart + curLine.textLength)
			{
				if(curPos >= curLine.absoluteStart || curPos + flowElem.textLength >= curLine.absoluteStart)
				{	
					if(flowElem is InlineGraphicElement)
					{
						var inlineImg:InlineGraphicElement = flowElem as InlineGraphicElement;
						//we can ignore TCY for leading adjustments
						if(!(_blockProgression == BlockProgression.RL && (flowElem.parent is TCYElement)))
						{
							//if the largest found img is smaller than the current image, we need new data
							if(largestImg < inlineImg.getEffectiveFontSize())
							{
								largestImg = inlineImg.getEffectiveFontSize();
								//only get this if the img is as large or larger than the largest found text
								if(largestImg >= largestPointSize)
								{
									largestImg = largestImg;
									var domBaseline:String = flowElem.computedFormat.dominantBaseline;
									if(domBaseline == FormatValue.AUTO)
										domBaseline = LocaleUtil.dominantBaseline(para.computedFormat.locale);
									
									//we are only making the adjustment for ideo-center, all others are to be ignored...
									if(domBaseline == TextBaseline.IDEOGRAPHIC_CENTER)
									{
										var elemLeading:Number = TextLayoutFormat.lineHeightProperty.computeActualPropertyValue(inlineImg.computedFormat.lineHeight, inlineImg.getEffectiveFontSize());	
										var curAdjustment:LeadingAdjustment = calculateLinePlacementAdjustment(curTextLine, domBaseline, curLeadingDir, inlineImg, isFirstLine);
										if(!adjustment || Math.abs(curAdjustment.rise) > Math.abs(adjustment.rise) || Math.abs(curAdjustment.leading) > Math.abs(adjustment.leading))
										{
											if(adjustment)
											{
												adjustment.rise = curAdjustment.rise;
												adjustment.leading = curAdjustment.leading;
											}
											else
												adjustment = curAdjustment;
										}
									}
								}
							}
						}
					}
					else
					{
						var tempSize:Number = flowElem.getEffectiveFontSize();
						if(largestPointSize <= tempSize)
						{
							largestPointSize = tempSize;
						}
						
						//if the largest image is smaller than this element, zero out the adjustment
						if(adjustment && largestImg < largestPointSize)
						{
							adjustment.leading = 0;
							adjustment.rise = 0;
						}
					}
				}
				
				//advance the position and get the next element
				curPos += flowElem.textLength;
				flowElem = flowElem.getNextLeaf(para);
			}
			return adjustment;
		}


		public function get swfContext():ISWFContext
		{ 
			var composerContext:ISWFContext = _flowComposer.swfContext;
			return composerContext ? composerContext : GlobalSWFContext.globalSWFContext; 
		}

		/** @private */
		private function calculateLinePlacementAdjustment(curTextLine:TextLine, domBaseline:String, curLeadingDir:String, inlineImg:InlineGraphicElement, isFirstLine:Boolean):LeadingAdjustment
		{
			var curAdjustment:LeadingAdjustment = new LeadingAdjustment();
			//get the leading height for the img
			var imgHeight:Number = TextLayoutFormat.lineHeightProperty.computeActualPropertyValue(inlineImg.computedFormat.lineHeight, inlineImg.getEffectiveFontSize());
			//get the leading as if the line contains no imgs.  We'll need this to adjust the total adjustments
			var lineLeading:Number = TextLayoutFormat.lineHeightProperty.computeActualPropertyValue(inlineImg.computedFormat.lineHeight, curTextLine.textHeight)
			
			//this is a redundant check, but will be needed in the future, so we're leaving it in. - gak 12.16.09
			if(domBaseline == TextBaseline.IDEOGRAPHIC_CENTER)
			{
				if(!isFirstLine)
				{
					//for non-first lines, we want to offset the rise of the line
					curAdjustment.rise += (imgHeight - lineLeading)/2;
				}
				else
				{
					//for the first line, the offset will be right, but hte leading wrong.
					curAdjustment.leading -= (imgHeight - lineLeading)/2;
				}
			}
			
			return curAdjustment;
		}
	}
}

import flash.text.engine.TextLine;
import flashx.textLayout.compose.ISWFContext;
import flashx.textLayout.debug.Debugging;
import flashx.textLayout.tlf_internal;

use namespace tlf_internal;

class AlignData 
{
	public var textLine:TextLine;
	public var lineWidth:Number;
	public var leftSidePadding:Number;
	public var rightSidePadding:Number;
	public var center:Boolean;
	public var leftSideIndent:Number;
	public var rightSideIndent:Number;
}


class GlobalSWFContext implements ISWFContext
{
	static public const globalSWFContext:GlobalSWFContext = new GlobalSWFContext();

	public function GlobalSWFContext()
	{ }
	
	public function callInContext(fn:Function, thisArg:Object, argsArray:Array, returns:Boolean=true):*
	{
		CONFIG::debug
		{
			var rslt:*
			try
			{
				if (returns)
					rslt = fn.apply(thisArg, argsArray);

				else
					fn.apply(thisArg, argsArray);
					
				if (thisArg)
				{
					var traceArgs:Array;
					// later make this table driven
					if (thisArg.hasOwnProperty("createTextLine") && fn == thisArg["createTextLine"])
					{
						traceArgs = [rslt,thisArg,"createTextLine"]
						traceArgs.push.apply(traceArgs, argsArray);
						Debugging.traceFTECall.apply(null,traceArgs);
					}
					else if (thisArg.hasOwnProperty("recreateTextLine") && fn == thisArg["recreateTextLine"])
					{
						traceArgs = [rslt,thisArg,"recreateTextLine"]
						traceArgs.push.apply(traceArgs, argsArray);
						Debugging.traceFTECall.apply(null,traceArgs);
					}
				}
			}
			catch(e:Error)
			{
				// trace(e);
				throw(e);
			}
			return rslt;
		}
		CONFIG::release
		{
			if (returns)
				return fn.apply(thisArg, argsArray);
			fn.apply(thisArg, argsArray);
		}
	}
}

class LeadingAdjustment
{
	public var rise:Number = 0;
	public var leading:Number = 0;
	public var lineHeight:Number = 0;
}


