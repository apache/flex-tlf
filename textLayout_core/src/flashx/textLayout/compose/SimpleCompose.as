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
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.compose.TextFlowLineLocation;
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
	public class SimpleCompose extends BaseCompose
	{
		// reusable scratch TextFlowLine
		protected var workingLine:TextFlowLine = new TextFlowLine(null, null);
		
		// resulting TextLines
		public var _lines:Array;
		
		// scratch aligns for VJ
		private var _vjLines:Array;
		
		// for figuring out when to do VJ
		private var vjBeginLineIndex:int = 0;
		private var vjDisableThisParcel:Boolean = false;
		private var vjParcel:Parcel;
		private var vjType:String;
		
		// accumulator for absolute start computation to support truncation 
		private var _totalLength:Number;
		
		/** Constructor. */
		public function  SimpleCompose()
		{	
			super();
			_lines = new Array();
			_vjLines = new Array();
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

		protected override function  initializeForComposer(composer:IFlowComposer, composeToPosition:int, controllerEndIndex:int):void
		{
			super.initializeForComposer(composer, composeToPosition, controllerEndIndex);
			
			// vj support
			_vjLines.splice(0);
			vjBeginLineIndex = 0;
			vjParcel = parcelList.currentParcel;	
			vjDisableThisParcel = false;
			vjType = vjParcel ? vjParcel.controller.computedFormat.verticalAlign : VerticalAlign.TOP;
			
			_startController = composer.getControllerAt(0);
            _startComposePosition = 0;
		}

		/** @private */
		public override function composeTextFlow(textFlow:TextFlow, composeToPosition:int, controllerEndIndex:int):int
		{
			_flowComposer = textFlow.flowComposer as StandardFlowComposer;
			
			// empty out lines array
			_lines.splice(0);
			
			// accumulator initialization
			_totalLength = 0;
			
			return super.composeTextFlow(textFlow, composeToPosition, controllerEndIndex);
		}
		
 		override protected function doVerticalAlignment(canVerticalAlign:Boolean,nextParcel:Parcel):Boolean
 		{
			var result:Boolean = false;

			if (canVerticalAlign && vjType != VerticalAlign.TOP && vjBeginLineIndex != _lines.length &&  !vjDisableThisParcel && vjParcel.columnCoverage == Parcel.FULL_COLUMN)
			{						
				applyVerticalAlignmentToColumn(vjParcel.controller,vjType,_vjLines,0,_vjLines.length);
				result = true;	// lines were moved
			}

			_vjLines.splice(0);
			vjBeginLineIndex = _lines.length;
			vjParcel = nextParcel;	// next parcel
			vjDisableThisParcel = false;
			if (nextParcel)
				vjType = vjParcel.controller.computedFormat.verticalAlign;
			return result;
 		}
 		
		private function finalizeLine(curLine:TextFlowLine):void
		{
			var line:TextLine = curLine.createShape(_blockProgression);
			
			if (textFlow.backgroundManager)
				textFlow.backgroundManager.finalizeLine(curLine);
				
			line.userData = _totalLength; 		// store absolute start position in the userData field
			_totalLength += line.rawTextLength; // update length accumulator
			_lines.push(line);
			if (vjType != VerticalAlign.TOP)
				_vjLines.push(new VJHelper(line,curLine.height));
				
			commitLastLineState (curLine);	
		}

		public function get textFlow():TextFlow
		{
			return _textFlow;
		}
		
		/** @private */
		protected override function composeParagraphElement(elem:ParagraphElement, absStart:int):Boolean
		{
			_curParaElement  = elem;
			_curParaStart    = absStart;
			_curParaFormat = elem.computedFormat;
			CONFIG::debug { assert(_curParaStart == elem.getAbsoluteStart(),"composeParagraphElement: bad start"); }
			_curElement 	 = elem.getFirstLeaf();
			_curElementStart = _curParaStart;
			return composeParagraphElementIntoLines();
		}		
		/** @private */
		protected override function composeNextLine():TextFlowLine
		{
			// Check to see if there's an existing line that is composed up-to-date

			var startCompose:int = _curElementStart + _curElementOffset - _curParaStart;
			var prevLine:TextLine = startCompose != 0 ? workingLine.getTextLine() : null;
			CONFIG::debug { assert(!prevLine || prevLine.validity == "valid","Bad prevline: "+Debugging.getIdentity(prevLine)); }
			var finishLineSlug:Rectangle = _parcelList.currentParcel;
			var curLine:TextFlowLine;
			
			for (;;) 
			{
				for (;;)
				{	
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
				curLine = fitLineToParcel(curLine, true);
				if (curLine)
					break;
				if (_parcelList.atEnd())
					return null;
				finishLineSlug = _lineSlug;
			}
			
			finalizeLine(curLine);

			CONFIG::debug { assert(curLine != null, "curLine != null"); }			
			return curLine;
		}

		/** @private */
		protected function createTextLine(prevLine:TextLine,	// previous line
			lineStart:int, 		// text index of position to start from, relative to start of paragraph
			x:Number,			// left edge of the line
			y:Number, 			// top of the line
			targetWidth:Number	// target width we're composing into
			):TextFlowLine
        {     		    		
			// adjust target width for text indent, start and end indent 			
 			var lineOffset:Number = Number(_curParaFormat.paragraphStartIndent);  	// indent to "beginning" of the line.  Direction dependent (as is paragraphStartIndent)    		
     		if (prevLine == null) 	// first line indent
     			lineOffset += Number(_curParaFormat.textIndent);
     		
     		var outerTargetWidth:Number = targetWidth;
     		targetWidth -= (Number(_curParaFormat.paragraphEndIndent) + lineOffset);		// make room for offset and end indent
     		targetWidth = (targetWidth < 0) ? 0 : targetWidth;		// no negative targetwidth allowed
     		if (targetWidth > TextLine.MAX_LINE_WIDTH)
     			targetWidth = TextLine.MAX_LINE_WIDTH;
	   		
        	//var textLine:TextLine = _flowComposer.textLineCreator.createTextLine(_curParaElement.getTextBlock(), prevLine, targetWidth, lineOffset, true);
        	var textLine:TextLine = TextLineRecycler.getLineForReuse();
        	var textBlock:TextBlock = _curParaElement.getTextBlock();
	   		if (textLine)
	   		{
	   			CONFIG::debug { assert(_textFlow.backgroundManager == null || _textFlow.backgroundManager.lineDict[textLine] === undefined,"Bad TextLine in recycler cache"); }
	        	textLine = swfContext.callInContext(textBlock["recreateTextLine"], textBlock, [ textLine, prevLine, targetWidth, lineOffset, true ]);
      		}
	   		else
	   		{
	        	textLine = swfContext.callInContext(textBlock.createTextLine, textBlock, [prevLine, targetWidth, lineOffset, true ]);
      		}
        	// Unable to fit a new line
        	if (textLine == null)
        		return null;

 			CONFIG::debug { assert(_curParaStart == _curParaElement.getAbsoluteStart(),"bad _curParaStart"); }
 			workingLine.initialize(_curParaElement, outerTargetWidth, lineOffset, lineStart + _curParaStart, textLine.rawTextLength, textLine);
 			CONFIG::debug { assert(workingLine.targetWidth == targetWidth,"Bad targetWidth"); }
 			
			// update spaceBefore & spaceAfter		
			var linePos:uint = workingLine.location;
			workingLine.setSpaceBefore((linePos & TextFlowLineLocation.FIRST) ? Number(_curParaFormat.paragraphSpaceBefore) : 0);
			workingLine.setSpaceAfter((linePos & TextFlowLineLocation.LAST) ? Number(_curParaFormat.paragraphSpaceAfter) : 0); 

 			return workingLine;
        }
        
        /** @private */
        tlf_internal function swapLines(lines:Array):Array
        {
        	var current:Array = _lines;
        	_lines = lines;
        	return current;
        }

		/** Final adjustment on the content bounds. */
 		override protected function finalParcelAdjustment(controller:ContainerController):void
 		{
 			var minX:Number = TextLine.MAX_LINE_WIDTH;
 			var minY:Number = TextLine.MAX_LINE_WIDTH;
 			var maxX:Number = -TextLine.MAX_LINE_WIDTH;
 			var maxY:Number = -TextLine.MAX_LINE_WIDTH;
 			
 			var textLine:TextLine;
 			var verticalText:Boolean = _blockProgression == BlockProgression.RL;
 			var startPos:int = controller.absoluteStart;

			for each (textLine in _lines)
			{
				var leaf:FlowLeafElement = controller.textFlow.findLeaf(startPos);
				var para:ParagraphElement = leaf.getParagraph();

            	// Check the logical vertical dimension first
            	// If the lines have children, they may be inlines. The origin of the TextLine is the baseline, 
            	// which does not include the ascent of the inlines or the text. So we have to factor that in.
				// var verticalAdjust:Number = verticalText ? textLine.descent : textLine.ascent;
				var inlineAscent:Number = 0;
				if (textLine.numChildren > 0)		// adjustjust logical vertical coord to take into account inlines
				{
					var leafStart:int = leaf.getAbsoluteStart();
					inlineAscent = TextFlowLine.getTextLineTypographicAscent(textLine, leaf, leafStart, startPos + textLine.rawTextLength, para);
				}

				// Figure out the logical horizontal adjustment
				var edgeAdjust:Number = 0;
				var curParaFormat:ITextLayoutFormat = para.computedFormat;
				if (curParaFormat.direction == Direction.LTR)
					edgeAdjust = curParaFormat.paragraphStartIndent + Math.max(curParaFormat.textIndent, 0);
				else
					edgeAdjust = curParaFormat.paragraphEndIndent;
				
				if (verticalText)
				{
		            minX = Math.min(textLine.x - textLine.descent, minX);
		            maxX = Math.max(textLine.x + Math.max(inlineAscent,textLine.ascent), maxX);
		           	minY = Math.min(textLine.y - edgeAdjust, minY);
				}
				else
				{
					if (inlineAscent < textLine.ascent)
						inlineAscent = textLine.ascent;
		            minX = Math.min(textLine.x - edgeAdjust, minX);
		           	minY = Math.min(textLine.y - inlineAscent, minY);
		  		}
		  		startPos += textLine.rawTextLength;
   			}
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
		
		tlf_internal override function releaseAnyReferences():void
		{
			super.releaseAnyReferences();
			workingLine.initialize(null,0,0,0,0,null);
			// parcelList.releaseAnyReferences();
		}
	}
}
import flash.text.engine.TextLine;
import flashx.textLayout.compose.IVerticalJustificationLine;
import flash.text.engine.TextLineCreationResult;

class VJHelper implements IVerticalJustificationLine
{
	private var _line:TextLine;
	private var _height:Number;

	public function VJHelper(line:TextLine,h:Number)
	{
		_line = line;
		_height = h;
	}
	public function get x():Number
	{ return _line.x; }
	public function set x(val:Number):void
	{ _line.x = val; }
		
	public function get y():Number
	{ return _line.y; }
	public function set y(val:Number):void
	{ _line.y = val; }
		
	public function get ascent():Number
	{ return _line.ascent; }
	public function get descent():Number
	{ return _line.descent; }
	public function get height():Number
	{ return _height; }
}
