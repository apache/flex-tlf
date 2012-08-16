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
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.VerticalAlign;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	/** @private
	 * Adjust line positions according to verticalAlign settings.  Vertical alignment is perpendicular
	 * to the linebreak direction.
	 */
	public final class VerticalJustifier
	{
		[ ArrayElementType("text.IVerticalJustificationLine") ] 
		/** Vertical justify the subset of lines from startIndext to startIndex to numLines according to the rule specified by verticalAlignAttr.  
		 * The assumption is that they are all the lines in a single column of cont. 
		 * @see text.formats.VerticalAlign
		 * */
		static public function applyVerticalAlignmentToColumn(cont:ContainerController, verticalAlignAttr:String, lines:Array, startIndex:int, numLines:int):void
		{
			// TODO: This function doesn't work if there are any tables.
			
			var helper:IVerticalAdjustmentHelper;
			if (cont.rootElement.computedFormat.blockProgression == BlockProgression.RL)
				helper = new RL_VJHelper(ContainerController(cont));
			else
				helper = new TB_VJHelper(ContainerController(cont));
				
			CONFIG::debug { assert(startIndex + numLines <= lines.length && numLines > 0,"applyVerticalAlignmentToColumn: bad indices"); }
									
			var i:int;
			
			switch(verticalAlignAttr) 
			{
				case VerticalAlign.MIDDLE:
					helper.computeMiddleAdjustment(lines[(startIndex + numLines) - 1]);
					for (i = startIndex; i < startIndex + numLines; i++)
						helper.applyMiddleAdjustment(lines[i]);
					break;
				case VerticalAlign.BOTTOM:
					helper.computeBottomAdjustment(lines[(startIndex + numLines) - 1]);
					for (i = startIndex; i < startIndex + numLines; i++)
						helper.applyBottomAdjustment(lines[i]);
					break;
				case VerticalAlign.JUSTIFY:
					helper.computeJustifyAdjustment(lines, startIndex, numLines);
					helper.applyJustifyAdjustment(lines, startIndex, numLines);
					break;
			}

			//for (i = startIndex; i < startIndex + numLines; i++)
			//	trace("x=", sc[i].x, "y=", sc[i].y, "yAdj=", yAdj);
		}
	}
}
import flash.text.engine.TextLine;
import flashx.textLayout.compose.IVerticalJustificationLine;
import flashx.textLayout.container.ContainerController;
import flashx.textLayout.compose.TextFlowLine;
import flashx.textLayout.compose.TextFlowLine;


interface IVerticalAdjustmentHelper
{
	function computeMiddleAdjustment(lastLine:IVerticalJustificationLine):void;
	function applyMiddleAdjustment(line:IVerticalJustificationLine):void;
	
	function computeBottomAdjustment(lastLine:IVerticalJustificationLine):void;
	function applyBottomAdjustment(line:IVerticalJustificationLine):void;
	
	function computeJustifyAdjustment(lineArray:Array, firstLine:int, numLines:int):void;
	function applyJustifyAdjustment(lineArray:Array, firstLine:int, numLines:int):void;
}

class TB_VJHelper implements IVerticalAdjustmentHelper
{
	import flashx.textLayout.tlf_internal;	
	use namespace tlf_internal;
	
	private var _textFrame:ContainerController;
	private var adj:Number;
	
	public function TB_VJHelper(tf:ContainerController):void
	{
		_textFrame = tf;
	}
	
	private function getBottomOfLine(line:IVerticalJustificationLine):Number
	{
		return getBaseline(line) + line.descent;
	}
	
	private function getBaseline(line:IVerticalJustificationLine):Number
	{
		if (line is TextFlowLine)
			return line.y + line.ascent;
		else
			return line.y;
	}
	
	private function setBaseline(line:IVerticalJustificationLine, pos:Number):void
	{
		if (line is TextFlowLine)
			line.y = pos - line.ascent;
		else
			line.y = pos;
	}
	
	// half of the available adjustment added to each y to shift the lines half way down the frame
	public function computeMiddleAdjustment(lastLine:IVerticalJustificationLine):void
	{
		var frameBottom:Number = _textFrame.compositionHeight - Number(_textFrame.effectivePaddingBottom);
		adj = (frameBottom - getBottomOfLine(lastLine)) / 2;
		if (adj < 0)
			adj = 0; // no space available to redistribute
	}
	public function applyMiddleAdjustment(line:IVerticalJustificationLine):void
	{
		line.y = line.y + adj;
	}
	
	// the baseline of the last line should be at the bottom of the frame - paddingBottom.
	public function computeBottomAdjustment(lastLine:IVerticalJustificationLine):void
	{
		var frameBottom:Number = _textFrame.compositionHeight - Number(_textFrame.effectivePaddingBottom);
		adj = frameBottom - getBottomOfLine(lastLine);
		if (adj < 0)
			adj = 0; // no space available to redistribute
	}
	public function applyBottomAdjustment(line:IVerticalJustificationLine):void
	{
		line.y = line.y + adj;
	}
	
	// one line: untouched, two lines: first line untouched and descent of last line at the bottom of the frame, 
	// and more than two lines: line spacing increased proportionally, with first line untouched and descent of last line at the bottom of the frame
	[ ArrayElementType("text.compose.IVerticalJustificationLine") ]
	public function computeJustifyAdjustment(lineArray:Array, firstLineIndex:int, numLines:int):void
	{
		adj = 0;
		
		if (numLines == 1)
			return;	// do nothing
			
		// first line unchanged	
		var firstLine:IVerticalJustificationLine = lineArray[firstLineIndex];
		var firstBaseLine:Number =  getBaseline(firstLine);

		// descent of the last line on the bottom of the frame	
		var lastLine:IVerticalJustificationLine = lineArray[firstLineIndex + numLines - 1];
		var frameBottom:Number = _textFrame.compositionHeight - Number(_textFrame.effectivePaddingBottom);
		var allowance:Number = frameBottom - getBottomOfLine(lastLine);
		if (allowance < 0)
			return; // Some text scrolled out; don't justify
		var lastBaseLine:Number = getBaseline(lastLine); 
	
		adj = allowance/(lastBaseLine - firstBaseLine); // multiplicative factor by which the space between consecutive lines is increased 
	}
	
	[ ArrayElementType("text.compose.IVerticalJustificationLine") ]
	public function applyJustifyAdjustment(lineArray:Array, firstLineIndex:int, numLines:int):void
	{ 
		if (numLines == 1 || adj == 0)
			return;	// do nothing
			
		var firstLine:IVerticalJustificationLine = lineArray[firstLineIndex];
		var prevBaseLine:Number = getBaseline(firstLine);
		var prevBaseLineUnjustified:Number = prevBaseLine;
		
		var line:IVerticalJustificationLine;
		var currBaseLine:Number;
		var currBaseLineUnjustified:Number;
		
		for (var i:int = 1; i < numLines; i++)
		{
			line = lineArray[i + firstLineIndex];
			currBaseLineUnjustified = getBaseline(line);
			
			// Space between consecutive baselines scaled up by the calculated factor
			currBaseLine = prevBaseLine  + (currBaseLineUnjustified - prevBaseLineUnjustified)*(1 + adj);
			setBaseline(line, currBaseLine);
			
			prevBaseLineUnjustified = currBaseLineUnjustified;
			prevBaseLine = currBaseLine;
		}
	}
}

class RL_VJHelper implements IVerticalAdjustmentHelper
{
	import flashx.textLayout.tlf_internal;	
	use namespace tlf_internal;

	private var _textFrame:ContainerController;
	private var adj:Number = 0;
	
	public function RL_VJHelper(tf:ContainerController):void
	{
		_textFrame = tf;
	}
	
	// half of the available adjustment added to each x to shift the lines half way left across the frame
	public function computeMiddleAdjustment(lastTextLine:IVerticalJustificationLine):void
	{
		// ignore paddingRight its already offset
		var frameWidth:Number = _textFrame.compositionWidth-Number(_textFrame.effectivePaddingLeft);
		adj = (frameWidth + lastTextLine.x - lastTextLine.descent) / 2;
		if (adj < 0)
			adj = 0; // no space available to redistribute
	}
	public function applyMiddleAdjustment(line:IVerticalJustificationLine):void
	{
		line.x = (line.x - adj);
	}
	
	// the baseline of the last line should be at the bottom of the frame - paddingLeft.
	public function computeBottomAdjustment(lastTextLine:IVerticalJustificationLine):void
	{
		var frameWidth:Number = _textFrame.compositionWidth-Number(_textFrame.effectivePaddingLeft);
		adj = frameWidth + lastTextLine.x - lastTextLine.descent;
		if (adj < 0)
			adj = 0; // no space available to redistribute
	}
	public function applyBottomAdjustment(line:IVerticalJustificationLine):void
	{
		line.x = (line.x - adj);
	}
	
	// one line: untouched, two lines: first line untouched and descent of last line at the bottom of the frame, 
	// and more than two lines: line spacing increased proportionally, with first line untouched and descent of last line at the bottom of the frame
	[ ArrayElementType("text.compose.IVerticalJustificationLine") ]
	public function computeJustifyAdjustment(lineArray:Array, firstLineIndex:int, numLines:int):void
	{ 
		adj = 0;
		
		if (numLines == 1)
			return;	// do nothing
			
		// first line unchanged
		var firstLine:IVerticalJustificationLine = lineArray[firstLineIndex];
		var firstBaseLine:Number =  firstLine.x;
		
		// descent of the last line on the left of the frame	
		var lastLine:IVerticalJustificationLine = lineArray[firstLineIndex + numLines - 1];
		var frameLeft:Number =  Number(_textFrame.effectivePaddingLeft) - _textFrame.compositionWidth;
		var allowance:Number = (lastLine.x - lastLine.descent) - frameLeft;
		if (allowance < 0)
			return; // Some text scrolled out; don't justify
		var lastBaseLine:Number = lastLine.x;  
		
		adj = allowance/(firstBaseLine - lastBaseLine);  // multiplicative factor by which the space between consecutive lines is increased 
	}
	
	[ ArrayElementType("text.IVerticalJustificationLine") ]
	public function applyJustifyAdjustment(lineArray:Array, firstLineIndex:int, numLines:int):void
	{
		if (numLines == 1 || adj == 0)
			return;	// do nothing
			
		var firstLine:IVerticalJustificationLine = lineArray[firstLineIndex];
		var prevBaseLine:Number = firstLine.x;
		var prevBaseLineUnjustified:Number = prevBaseLine;
		
		var line:IVerticalJustificationLine;
		var currBaseLine:Number;
		var currBaseLineUnjustified:Number;
		
		for (var i:int = 1; i < numLines; i++)
		{
			line = lineArray[i + firstLineIndex];
			currBaseLineUnjustified = line.x;
			
			// Space between consecutive baselines scaled up by the calculated factor
			currBaseLine = prevBaseLine - (prevBaseLineUnjustified - currBaseLineUnjustified)*(1 + adj);
			line.x = currBaseLine;
			
			prevBaseLineUnjustified = currBaseLineUnjustified;
			prevBaseLine = currBaseLine;
		}		
	}
	
}