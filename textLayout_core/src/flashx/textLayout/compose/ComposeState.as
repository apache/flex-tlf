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
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.ContainerFormattedElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.OverflowPolicy;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BaselineOffset;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.VerticalAlign;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	[ExcludeClass]
	/** Keeps track of internal state during composition. 
	 * 
	 * This is the simpler version, used when there are no floats, no wraps, no columns.
	 * @private
	 */
	public class ComposeState extends BaseCompose 
	{
		/** Index of current line */
		protected var _curLineIndex:int;	
		
		// for figuring out when to do VJ
		protected var vjBeginLineIndex:int;
		protected var vjDisableThisParcel:Boolean;
		
		// a single ComposeState that is checked out and checked in
		static private var _sharedComposeState:ComposeState;

		/** @private */
		static tlf_internal function getComposeState():ComposeState
		{
			var rslt:ComposeState = _sharedComposeState ? _sharedComposeState : new ComposeState();
			_sharedComposeState = null;
			return rslt;
		}
		
		/** @private */
		static tlf_internal function releaseComposeState(state:ComposeState):void
		{
			if (_sharedComposeState == null)
			{
				_sharedComposeState = state;
				if (_sharedComposeState)
					_sharedComposeState.releaseAnyReferences();
			}
		}

		/** Constructor. */
		public function  ComposeState()
		{	
			super();	
		}				

		/** @private */
		protected override function createParcelList():IParcelList
		{
			return ParcelList.getParcelList();
		}
		/** @private */
		protected override function releaseParcelList(list:IParcelList):void
		{
			ParcelList.releaseParcelList(list);
		}
		
		/** @private */
		public override function composeTextFlow(textFlow:TextFlow, composeToPosition:int, controllerEndIndex:int):int
		{
			_curLineIndex    = 0;
					
			vjBeginLineIndex = 0;
			vjDisableThisParcel = false;
			
			return super.composeTextFlow(textFlow, composeToPosition, controllerEndIndex);
		}
		
		protected override function initializeForComposer(composer:IFlowComposer,composeToPosition:int,controllerEndIndex:int):void
		{
			super.initializeForComposer(composer,composeToPosition,controllerEndIndex);
			           
			// start composing from the first damaged position. Update internal composition state as if we'd composed to here already.
			_startComposePosition = composer.damageAbsoluteStart; // _startController.absoluteStart;
			var controllerIndex:int = composer.findControllerIndexAtPosition(_startComposePosition);
			if (controllerIndex == -1)
			{
				controllerIndex = composer.numControllers-1;
				// if off the end in the overflow - find the last non-zero controller
				while (controllerIndex != 0 && composer.getControllerAt(controllerIndex).textLength == 0)
					controllerIndex--;
			}
			// if damage is in overflow after last controller we could get smart about that
			_startController = composer.getControllerAt(controllerIndex);
			CONFIG::debug { assert(_startController != null,"Bad start start controller"); }

			// Disable partial container composition if we have to vertically align the lines.
			if (_startController.computedFormat.verticalAlign != VerticalAlign.TOP)
				_startComposePosition = _startController.absoluteStart; 

			// Comment this line in to disable composing from the middle of a container.
		//	_startComposePosition = _startController.absoluteStart; 
		}
		
		/** @private */
		protected override function composeInternal(composeRoot:FlowGroupElement,absStart:int):void
		{
			super.composeInternal(composeRoot,absStart);
			
			// mark all overflow lines as not being in any container or column
			if (_curElement)
			{
				CONFIG::debug { assert(_curLineIndex == _flowComposer.findLineIndexAtPosition(_curElementStart + _curElementOffset),"bad _curLineIndex"); }
				while (_curLineIndex < _flowComposer.numLines)
					_flowComposer.getLineAt(_curLineIndex++).setController(null,-1);
			}
		}

 		override protected function doVerticalAlignment(canVerticalAlign:Boolean,nextParcel:Parcel):Boolean
		{
			var result:Boolean = false;
			if (canVerticalAlign && _curParcel && vjBeginLineIndex != _curLineIndex &&  !vjDisableThisParcel && _curParcel.columnCoverage == Parcel.FULL_COLUMN)
			{
				var controller:ContainerController = _curParcel.controller;
				var vjtype:String = controller.computedFormat.verticalAlign;
				if (vjtype != VerticalAlign.TOP)
				{	
					// Exclude overset lines
					var end:int = _flowComposer.findLineIndexAtPosition(_curElementStart + _curElementOffset)

					if (vjBeginLineIndex < end)
					{
						applyVerticalAlignmentToColumn(controller,vjtype,_flowComposer.lines,vjBeginLineIndex,end-vjBeginLineIndex);
						result = true;	// lines were moved
					}
				}
			}
			
			// always reset these variables
			vjDisableThisParcel = false;
			vjBeginLineIndex = _curLineIndex;	
			
			return result;
		}
		
		/** Final adjustment on the content bounds. */
 		override protected function finalParcelAdjustment(controller:ContainerController):void
 		{
 			var minX:Number = TextLine.MAX_LINE_WIDTH;
 			var minY:Number = TextLine.MAX_LINE_WIDTH;
 			var maxX:Number = -TextLine.MAX_LINE_WIDTH;
 			var maxY:Number = -TextLine.MAX_LINE_WIDTH;
 			
 			var verticalText:Boolean = _blockProgression == BlockProgression.RL;

            var lineIndex:int = _flowComposer.findLineIndexAtPosition(controller.absoluteStart); 
            while (lineIndex < _curLineIndex)
            {
            	var line:TextFlowLine = _flowComposer.getLineAt(lineIndex);

            	// Check the logical vertical dimension first
            	// If the lines have children, they may be inlines. The origin of the TextFlowLine is the baseline - ascent, 
            	// which does not include the ascent of the inlines. So we have to factor that in.
				if (verticalText)
				{
	      	 		maxX = Math.max(line.x + line.ascent, maxX);
	      	 		minX = Math.min(line.x, minX);
	   			}	
	      	 	else
	      	 		minY = Math.min(line.y + line.ascent - line.height, minY);
	       		
				// CONFIG::debug { assert(line.hasGraphicElement == line.getTextLine().hasGraphicElement,"Bad hasGraphicElement"); }
				// this is a test for an inline graphic
	       		if (line.hasGraphicElement)
	       		{
	       			var leafElement:FlowLeafElement = _textFlow.findLeaf(line.absoluteStart);
	       			var adjustedAscent:Number = line.getLineTypographicAscent(leafElement, leafElement.getAbsoluteStart());
					if (!verticalText)
	       				minY = Math.min(line.y + line.ascent - adjustedAscent, minY);
	       			else
	       				maxX = Math.max(line.x + adjustedAscent, maxX);
	       		}


				// Now check the logical horizontal dimension
				var edgeAdjust:Number;
				var curParaFormat:ITextLayoutFormat = line.paragraph.computedFormat;
				if (curParaFormat.direction == Direction.LTR)
					edgeAdjust = Math.max(line.lineOffset, 0);
				else
					edgeAdjust = curParaFormat.paragraphEndIndent;
             	if (verticalText)
           			minY = Math.min(line.y - edgeAdjust, minY);
             	else 
           			minX = Math.min(line.x - edgeAdjust, minX);
            	++lineIndex;
            }
            
            if (_blockProgression == BlockProgression.RL)
            	minX -= _lastLineDescent;
            
            // Don't make adjustments for tiny fractional values.
            if (minX != TextLine.MAX_LINE_WIDTH && Math.abs(minX-_parcelLeft) >= 1)
         		_parcelLeft = minX;
            if (maxX != -TextLine.MAX_LINE_WIDTH && Math.abs(maxX-_parcelRight) >= 1)
         		_parcelRight = maxX;
         	if (minY != TextLine.MAX_LINE_WIDTH && Math.abs(minY-_parcelTop) >= 1)
           		_parcelTop = minY;
         	if (maxY != -TextLine.MAX_LINE_WIDTH && Math.abs(maxY-_parcelBottom) >= 1)
           		_parcelBottom = maxY;
 		}
 				
		private function finalizeLine(useExistingLine:Boolean,curLine:TextFlowLine):void
		{
			if ( !useExistingLine ) 		
			{	
				_flowComposer.addLine(curLine,_curLineIndex);
			}
			_curLineIndex++;
			
			commitLastLineState (curLine);
		}
		
		protected override function composeParagraphElement(elem:ParagraphElement, absStart:int):Boolean
		{
			_curParaElement  = elem;
			_curParaStart    = absStart;
			_curParaFormat = elem.computedFormat;
			CONFIG::debug { assert(_curParaStart == elem.getAbsoluteStart(),"composeParagraphElement: bad start"); }
			if (_startComposePosition == 0)
			{
				_curElement 	 = elem.getFirstLeaf();
				_curElementStart = _curParaStart;
			}
			else 
			{
				CONFIG::debug { assert(absStart <= _startComposePosition && absStart+elem.textLength > _startComposePosition,"bad call to composeParagraphElement"); }
				_curElement = elem.findLeaf(_startComposePosition-absStart);
				_curElementStart = _curElement.getAbsoluteStart();
				_curElementOffset = _startComposePosition-_curElementStart;
				_curLineIndex = _flowComposer.findLineIndexAtPosition(_curElementStart + _curElementOffset);
				// next time we are all postioned
				_startComposePosition = 0;
			}

			return composeParagraphElementIntoLines();
		}
		
		/** @private */
		protected override function composeNextLine():TextFlowLine
		{
			CONFIG::debug { assert(_curLineIndex == _flowComposer.findLineIndexAtPosition(_curElementStart + _curElementOffset),"bad _curLineIndex"); }

			// Check to see if there's an existing line that is composed up-to-date
			var line:TextFlowLine = _curLineIndex < _flowComposer.numLines ? _flowComposer.lines[_curLineIndex] : null;
			var useExistingLine:Boolean = line && (!line.isDamaged() || line.validity == FlowDamageType.GEOMETRY);
			var curLine:TextFlowLine = useExistingLine ? line : null;
			var startCompose:int = _curElementStart + _curElementOffset - _curParaStart;
			var prevLine:TextFlowLine;
			if (startCompose != 0)
			{
				prevLine = _flowComposer.lines[_curLineIndex - 1];
				if (prevLine.absoluteStart < _curParaStart)		// is the previous line in the previous paragraph?
					prevLine = null;
			}
			var finishLineSlug:Rectangle = _parcelList.currentParcel;
			
			for (;;) 
			{
				while (!curLine)
				{	
					useExistingLine = false;
					// generate new line
					CONFIG::debug { assert(!_parcelList.atEnd(), "failing to stop"); }
					CONFIG::debug { assert(_curElement is FlowLeafElement, "element must be leaf before calling composeLine"); }
					
					curLine = createTextLine(prevLine,	startCompose, _parcelList.getComposeXCoord(finishLineSlug), _parcelList.getComposeYCoord(finishLineSlug),	_parcelList.getComposeWidth(finishLineSlug));
					if (curLine != null)
						break;
					// force advance to the next parcel
					if (!_parcelList.next())
						return null;
				}
				
				// updates _lineSlug
				curLine = fitLineToParcel(curLine, !useExistingLine);
				if (curLine)
					break;
				if (_parcelList.atEnd())
					return null;
				finishLineSlug = _lineSlug;
			}
			
			// Clear up user_invalid
			if (curLine.validity == FlowDamageType.GEOMETRY)
				curLine.clearDamage(); 
								
			finalizeLine(useExistingLine,curLine);

			CONFIG::debug { assert(curLine != null, "curLine != null"); }			
			return curLine;
		}
		
		/** @private */
		protected function createTextLine(prevLine:TextFlowLine,	// previous line
			lineStart:int, 		// text index of position to start from, relative to start of paragraph
			x:Number,			// left edge of the line
			y:Number, 			// top of the line
			targetWidth:Number	// target width we're composing into
			):TextFlowLine
        {
        //	trace("lineBreak: start", prevLine ? (prevLine.start+prevLine.textLength) : 0, "paraEnd", paraEnd, "(", x, y, ")", "targetWidth", targetWidth);
         	
        	CONFIG::debug { validateLineStart(prevLine, lineStart, _curParaElement); }
        	
 			var lineOffset:Number = Number(_curParaFormat.paragraphStartIndent);  	// indent to "beginning" of the line.  Direction dependent (as is paragraphStartIndent)    		
     		if (prevLine == null) 	// first line indent
     			lineOffset += Number(_curParaFormat.textIndent);
     		
     		var outerTargetWidth:Number = targetWidth;
     		targetWidth -= (Number(_curParaFormat.paragraphEndIndent) + lineOffset);		// make room for offset and end indent
     		
     		// TargetWidth must be between 0 and TextLine.MAX_LINE_WIDTH
     		if (targetWidth < 0)
     			targetWidth = 0;
     		else if (targetWidth > TextLine.MAX_LINE_WIDTH)
     			targetWidth = TextLine.MAX_LINE_WIDTH;
	   		
	   		var textLine:TextLine = TextLineRecycler.getLineForReuse();
	   		var textBlock:TextBlock = _curParaElement.getTextBlock();
	   		if (textLine)
	   		{
				CONFIG::debug { assert(_textFlow.backgroundManager == null || _textFlow.backgroundManager.lineDict[textLine] === undefined,"Bad TextLine in recycler cache"); }
	        	textLine = swfContext.callInContext(textBlock["recreateTextLine"],textBlock,[textLine, prevLine?prevLine.getTextLine(true):null, targetWidth, lineOffset, true]);
      		}
	   		else
	   		{
	        	textLine = swfContext.callInContext(textBlock.createTextLine,textBlock,[prevLine?prevLine.getTextLine(true):null, targetWidth, lineOffset, true]);
      		}
        	// Unable to fit a new line
        	if (textLine == null)
        		return null;
        	//trace("LineBreak prevLineLength:",prevLine?prevLine.textLine.rawTextLength:0,"nextLineLength:",line?line.textLine.rawTextLength:0);
 			// outerTargetWidth, targetWidth, textIndent, start, textLength, textLine
 			CONFIG::debug { assert(_curParaStart == _curParaElement.getAbsoluteStart(),"bad _curParaStart"); }
 			var line:TextFlowLine = new TextFlowLine(textLine, _curParaElement, outerTargetWidth, lineOffset, lineStart + _curParaStart, textLine.rawTextLength);
 			CONFIG::debug { assert(line.targetWidth == targetWidth,"Bad targetWidth"); }
 			textLine.doubleClickEnabled = true;		// allow line to be the target oif a double click event
 			
			// update spaceBefore & spaceAfter		
			CONFIG::debug
			{
				var linePos:uint = line.location;
				if (linePos & TextFlowLineLocation.FIRST)
					line.setSpaceBefore(Number(_curParaFormat.paragraphSpaceBefore));
				if (linePos & TextFlowLineLocation.LAST)
		     		line.setSpaceAfter(Number(_curParaFormat.paragraphSpaceAfter)); 		
			}
 			
 			return line;
        }
        
        /** @private */
		CONFIG::debug private static function validateLineStart(prevLine:TextFlowLine, lineStart:int, paraNode:ParagraphElement):void
		{
			// If the lines have been released, don't validate
			if (lineStart != 0 && paraNode.getTextBlock().firstLine == null)
				return;
				
	       	var testStart:int = 0;
	    	var testLine:TextLine = prevLine ? prevLine.getTextLine(true) : null;
	    	while (testLine)
	    	{
	    		testStart += testLine.rawTextLength;
	    		testLine = testLine.previousLine;
	    	}
	    	assert(testStart == lineStart, "Bad lines");
			
      		assert(paraNode is ParagraphElement,"composeLine: paraNode must be a para"); 
      		assert(!prevLine || !(prevLine.location & TextFlowLineLocation.LAST),"prevLine may not be from a different para"); 
		} 
	}
}
