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
	import flash.display.DisplayObject;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPathWinding;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;
	import flash.text.engine.TextRotation;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.elements.ContainerFormattedElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.FlowValueHolder;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.external.WeakRef;
	import flashx.textLayout.formats.BackgroundColor;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.JustificationRule;
	import flashx.textLayout.formats.LeadingModel;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.utils.CharacterUtil;
	
	use namespace tlf_internal;
	
	
	/** 
	 * The TextFlowLine class represents a single line of text in a text flow.
	 * 
	 * <p>Use this class to access information about how a line of text has been composed: its position, 
	 * height, width, and so on. When the text flow (TextFlow) is modified, the lines immediately before and at the  
	 * site of the modification are marked as invalid because they need to be recomposed. Lines after
	 * the site of the modification might not be damaged immediately, but they might be regenerated once the
	 * text is composed. You can access a TextFlowLine that has been damaged, but any values you access
	 * reflect the old state of the TextFlow. When the TextFlow is recomposed, it generates new lines and you can 
	 * get the new line for a given position by calling <code>TextFlow.flowComposer.findLineAtPosition()</code>.</p>
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	public final class TextFlowLine implements IVerticalJustificationLine 
	{
		
		
		
		/** @private */
		
		private var _absoluteStart:int;		// text-offset of start of line - from beginning of the TextFlow
		private var _textLength:int;	// number of chars to next line (incl trailing spaces, etc.)
		private var _height:Number = 0;		// y advance
		CONFIG::debug
		{
			private var _spaceBefore:Number = 0;	// amount of vertical space to leave at the top of the line
			private var _spaceAfter:Number = 0;	// amount of vertical space to leave at the bottom of the line
		}
		private var _x:Number = 0;			// left edge of line
		private var _y:Number = 0;			// top edge of line
		private var _outerTargetWidth:Number = 0; // width line is composed to, excluding indents
		
		private var _boundsLeftTW:int = 2;			// text line bounds: left
		private var _boundsRightTW:int = 1;			// text line bounds: right (if left > right, then it is not set)
		private var _boundsTopTW:int;				// text line bounds: top
		private var _boundsBottomTW:int;			// text line bounds: bottom
		
		private var _para:ParagraphElement;			// owning paragraph
		private var _controller:ContainerController;	// what frame the line was composed into
		private var _columnIndex:int;			// column number in the container
		
		private var _adornCount:int = 0;
		
		// added to support TextFlowLine when TextLine not available
		private var _ascent:Number;
		private var _descent:Number;
		private var _targetWidth:Number;
		private var _validity:String;
		private var _textHeight:Number;
		private var _lineOffset:Number;
		private var _lineExtent:Number;	// content bounds logical width for the line
		private var _released:Boolean;	// True if line has been released from the TextBlock
		private var _alignment:String;	// actual alignment applied to the line by composition (right or center), null if no alignment applied
		private var _hasGraphicElement:Boolean;	// True if line has as graphic element
		
		private var _textLineCache:WeakRef;
		
		/** @private */
		tlf_internal function get hasGraphicElement():Boolean
		{ return _hasGraphicElement; }
		
		/**
		 * The height of the text line, which is equal to <code>ascent</code> plus <code>descent</code>. The 
		 * value is calculated based on the difference between the baselines that bound the line, either 
		 * ideographic top and bottom or ascent and descent depending on whether the baseline at y=0 
		 * is ideographic (for example, TextBaseline.IDEOGRAPHIC_TOP) or not. 
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see flash.text.engine.TextBaseline TextBaseline
		 */
		
		public function get textHeight():Number 
		{ return _textHeight; }	
		
		/** @private */
		/**
		 * Check if the line is visible by comparing a set rectangle to the supplied
		 * rectangle (all values in Twips).
		 */
		tlf_internal function isLineVisible(wmode:String, x:int, y:int, w:int, h:int):Boolean
		{
			if (_boundsLeftTW > _boundsRightTW)
				return false;
			
			if (wmode == BlockProgression.RL)
				return _boundsRightTW >= x && _boundsLeftTW < x + w;
			else
				return _boundsBottomTW >= y && _boundsTopTW < y + h;
		}
		
		/** @private
		 * Set the text line bounds rectangle, all values in Twips.
		 * If left > right, the rectangle is considered not to be set.
		 */
		tlf_internal function setLineBounds(x:int, y:int, w:int, h:int):void
		{
			_boundsLeftTW = x;
			_boundsRightTW = x + w;
			_boundsTopTW = y;
			_boundsBottomTW = y + h;
		}
		
		/** @private
		 * Check if the text line bounds are set. If the stored left
		 * value is > the right value, then the rectangle is not set.
		 */
		tlf_internal function hasLineBounds():Boolean
		{
			return (_boundsLeftTW <= _boundsRightTW);
		}
		
		/** @private - the selection block cache */
		static private var _selectionBlockCache:Dictionary = new Dictionary(true);
		
		private static const EMPTY_LINE_WIDTH:Number = 2;		// default size of empty line selection
		
		/** Constructor - creates a new TextFlowLine instance. 
		 *  <p><strong>Note</strong>: No client should call this. It's exposed for writing your own composer.</p>
		 *
		 * @param textLine The TextLine display object to use for this line.
		 * @param paragraph The paragraph (ParagraphElement) in which to place the line.
		 * @param outerTargetWidth The width the line is composed to, excluding indents.
		 * @param lineOffset The line's offset in pixels from the appropriate container inset (as dictated by paragraph direction and container block progression), prior to alignment of lines in the paragraph. 
		 * @param absoluteStart	The character position in the text flow at which the line begins.
		 * @param numChars	The number of characters in the line.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see flash.text.engine.TextLine
		 * @see ParagraphElement
		 * @see #absoluteStart
		 * @see #numChars
		 */
		
		public function TextFlowLine(textLine:TextLine, paragraph:ParagraphElement, outerTargetWidth:Number = 0, lineOffset:Number = 0, absoluteStart:int = 0, numChars:int = 0)
		{
			initialize(paragraph, outerTargetWidth, lineOffset, absoluteStart,numChars,textLine);		
		}
		
		/** @private */
		tlf_internal function initialize(paragraph:ParagraphElement, outerTargetWidth:Number = 0, lineOffset:Number = 0, absoluteStart:int = 0, numChars:int = 0, textLine:TextLine = null):void
		{
			_para = paragraph;
			_outerTargetWidth = outerTargetWidth;
			_absoluteStart = absoluteStart;
			_textLength = numChars;
			_released = (textLine == null);
			if (textLine)
			{
				_textLineCache = new WeakRef(textLine);
				textLine.userData = this;
				_targetWidth = textLine.specifiedWidth;
				_ascent = textLine.ascent;
				_descent = textLine.descent;
				_textHeight = textLine.textHeight;
				_lineOffset = lineOffset;
				_validity = TextLineValidity.VALID;
				_hasGraphicElement = textLine.hasGraphicElement;
			}
			else 
				_validity = TextLineValidity.INVALID;
		}
		
		/** @private */
		tlf_internal function releaseTextLine():void
		{ _textLineCache = null; }
		
		/** @private */
		tlf_internal function peekTextLine():TextLine
		{ return _textLineCache ? _textLineCache.get() : null; }
		
		/** 
		 * The horizontal position of the line relative to its container, expressed as the offset in pixels from the 
		 * left of the container.
		 * <p><strong>Note: </strong>Although this property is technically <code>read-write</code>, 
		 * you should treat it as <code>read-only</code>. The setter exists only to satisfy the
		 * requirements of the IVerticalJustificationLine interface that defines both a getter and setter for this property.
		 * Use of the setter, though possible, will lead to unpredictable results.
		 * </p>
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see #y
		 */
		public function get x():Number
		{ return _x; }
		
		/** 
		 * This comment is ignored, but the setter should not be used and exists only to satisfy
		 * the IVerticalJustificationLine interface.
		 * @see flashx.textLayout.compose.IVerticalJustificationLine 
		 * @private 
		 */
		public function set x(lineX:Number):void
		{ 
			_x = lineX; 
			// invalidate bounds
			_boundsLeftTW = 2;
			_boundsRightTW = 1;
		}
		
		/** 
		 * The vertical position of the line relative to its container, expressed as the offset in pixels from the top 
		 * of the container.
		 * <p><strong>Note: </strong>Although this property is technically <code>read-write</code>, 
		 * you should treat it as <code>read-only</code>. The setter exists only to satisfy the
		 * requirements of the IVerticalJustificationLine interface that defines both a getter and setter for this property.
		 * Use of the setter, though possible, will lead to unpredictable results.
		 * </p>
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * 
		 * @see #x
		 */
		public function get y():Number
		{ return _y;  }
		
		/** This comment is ignored, but the setter should not be used and exists only to satisfy
		 * the IVerticalJustificationLine interface.
		 * @see flashx.textLayout.compose.IVerticalJustificationLine
		 * @private
		 */
		public function set y(lineY:Number):void
		{ 
			_y = lineY;
			// invalidate bounds
			_boundsLeftTW = 2;
			_boundsRightTW = 1;
		}
		
		/** @private */
		tlf_internal function setXYAndHeight(lineX:Number,lineY:Number,lineHeight:Number):void
		{
			_x = lineX;
			_y = lineY;
			_height = lineHeight;
			// invalidate bounds
			_boundsLeftTW = 2;
			_boundsRightTW = 1;
		}
		
		/** 
		 * One of the values from TextFlowLineLocation for specifying a line's location within a paragraph.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see ParagraphElement
		 * @see TextFlowLineLocation
		 */
		
		public function get location():int
		{
			if (_para)
			{
				var lineStart:int = _absoluteStart - _para.getAbsoluteStart();
				
				// Initialize settings for location
				if (lineStart == 0)		// we're at the start of the paragraph
					return _textLength == _para.textLength ? TextFlowLineLocation.ONLY : TextFlowLineLocation.FIRST;
				if (lineStart + _textLength == _para.textLength)	// we're at the end of the para
					return TextFlowLineLocation.LAST;
			}
			return TextFlowLineLocation.MIDDLE;
		}
		
		/** 
		 * The controller (ContainerController object) for the container in which the line has been placed.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * 
		 * @see flashx.textLayout.container.ContainerController 
		 */
		
		public function get controller():ContainerController
		{ return _controller; }
		
		/** The number of the column in which the line has been placed, with the first column being 0.
		 *		
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		
		public function get columnIndex():int
		{ return _columnIndex; }
		
		/** @private */
		tlf_internal function setController(cont:ContainerController,colNumber:int):void
		{ 
			_controller = cont as ContainerController;
			_columnIndex = colNumber;
		}
		
		/** The height of the line in pixels.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see #width
		 */
		
		public function get height():Number
		{ return _height; }
		
		/** 
		 * @copy flash.text.engine.TextLine#ascent
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		
		public function get ascent():Number
		{ return _ascent; }
		
		/** 
		 * @copy flash.text.engine.TextLine#descent
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		
		public function get descent():Number
		{ return _descent; }
		
		/** 
		 * The line's offset in pixels from the appropriate container inset (as dictated by paragraph direction and container block progression), 
		 * prior to alignment of lines in the paragraph.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get lineOffset():Number
		{
			return _lineOffset;
		}
		
		
		/** 
		 * The paragraph (ParagraphElement) in which the line resides.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * 
		 * @see ParagraphElement
		 */
		
		public function get paragraph():ParagraphElement
		{ return _para; }
		
		/** 
		 * The location of the line as an absolute character position in the TextFlow object.
		 * 
		 * @return 	the character position in the text flow at which the line begins.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see TextFlow
		 */
		
		public function get absoluteStart():int
		{ return _absoluteStart; }
		/** @private */
		tlf_internal function setAbsoluteStart(val:int):void
		{ _absoluteStart = val; }
		
		/** 
		 * The number of characters to the next line, including trailing spaces. 
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		
		public function get textLength():int
		{ return _textLength; }
		/** @private */
		tlf_internal function setTextLength(val:int):void
		{ 
			_textLength = val; 
			//	assert(_validity == TextLineValidity.INVALID, "not already damaged");
			damage(TextLineValidity.INVALID);
		}
		
		/** 
		 * The amount of space to leave before the line.
		 * <p>If the line is the first line of a paragraph that has a space-before applied, the line will have
		 * a <code>spaceBefore</code> value. If the line comes at the top of a column, <code>spaceBefore</code> is ignored. 
		 * Otherwise, the line follows another line in the column, and it is positioned vertically to insure that there is
		 * at least this much space left between this line and the last line of the preceding paragraph.</p> 
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see flashx.textLayout.formats.TextLayoutFormat#paragraphSpaceBefore TextLayoutFormat.paragraphSpaceBefore
		 */
		
		public function get spaceBefore():Number
		{ 
			CONFIG::debug 
			{
				var newResult:Number = (this.location & TextFlowLineLocation.FIRST)? _para.computedFormat.paragraphSpaceBefore : 0;
				assert(newResult == _spaceBefore, "spaceBefore getting wrong result");
			}
		 	return (this.location & TextFlowLineLocation.FIRST)? _para.computedFormat.paragraphSpaceBefore : 0;
		}
		
		/** @private */
		CONFIG::debug tlf_internal function setSpaceBefore(val:Number):void
		{  _spaceBefore = val; }
		
		/** 
		 * The amount of space to leave after the line.
		 * <p>If the line is the last line of a paragraph that has a space-after, the line will have
		 * a <code>spaceAfter</code> value. If the line comes at the bottom of a column, then the <code>spaceAfter</code>
		 * is ignored. Otherwise, the line comes before another line in the column, and the following line must be positioned vertically to
		 * insure that there is at least this much space left between this last line of the paragraph and the first
		 * line of the following paragraph.</p> 
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see flashx.textLayout.formats.TextLayoutFormat#paragraphSpaceAfter TextLayoutFormat.paragraphSpaceAfter
		 */
		
		public function get spaceAfter():Number
		{ 
			CONFIG::debug 
			{
				var newResult:Number = (this.location & TextFlowLineLocation.LAST) ? _para.computedFormat.paragraphSpaceAfter : 0; 
				assert(newResult == _spaceAfter, "spaceAfter getting wrong result");
			}
			return ((this.location & TextFlowLineLocation.LAST) ? _para.computedFormat.paragraphSpaceAfter : 0); 			
		}
		
		/** @private */
		CONFIG::debug tlf_internal function setSpaceAfter(val:Number):void
		{ _spaceAfter = val ; }
		
		/** @private 
		 * Target width not including paragraph indents */
		tlf_internal function get outerTargetWidth():Number
		{ return _outerTargetWidth; }
		
		/** @private */
		tlf_internal function set outerTargetWidth(val:Number):void
		{ _outerTargetWidth = val; }
		
		/** @private  
		 * Amount of space used to break the line
		 * <p>The target width is the amount of space allowed for the line, including the space required for indents.</p>
		 */
		tlf_internal function get targetWidth():Number
		{ return _targetWidth; }
		
		/** 
		 * Returns the bounds of the line as a rectangle.
		 *
		 * @return a rectangle that represents the boundaries of the line.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		
		public function getBounds():Rectangle
		{	
			var textLine:TextLine = getTextLine(true);
			if (!textLine)
				return new Rectangle();
			
			// TODO: just use the textLine.x and textLine.y - after all getTextLine now sets them.
			// not going to change this right now though
			var bp:String = paragraph.getAncestorWithContainer().computedFormat.blockProgression;
			var shapeX:Number = createShapeX();
			var shapeY:Number = createShapeY(bp);
			if (bp == BlockProgression.TB)
				shapeY += descent-textLine.height;
			return new Rectangle(shapeX, shapeY, textLine.width, textLine.height);			
		}
		
		/** The validity of the line. 
		 * <p>A line can be invalid if the text, the attributes applied to it, or the controller settings have
		 * changed since the line was created. An invalid line can still be displayed, and you can use it, but the values
		 * used will be the values at the time it was created. The line represented by <code>textLine</code> also will be in an
		 * invalid state. </p>
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see #textLine
		 * @see flash.text.engine.TextLine#validity TextLine.validity
		 * @see #GEOMETRY_DAMAGED
		 */
		
		public function get validity():String
		{ 
			// A TextLine may be invalidated separately from the TextFlowLine, when the invalidation is driven from the Player (e.g. changes have been made directly). 
			// If the TextFlowLine is marked valid, the line may still be invalid if the TextLine has been marked invalid.
			// If the line has been released (TextBlock.releaseLines called), then it may have an existing TextLine that got marked invalid by the Player 
			// when it was released. We want to ignore that invalid marking.
			if (!_released)
			{
				var textLine:TextLine = peekTextLine();
				if (textLine && (_validity == FlowDamageType.GEOMETRY || _validity == TextLineValidity.VALID) && textLine.validity != TextLineValidity.VALID)
					_validity = textLine.validity;
			}
			return _validity; 
		}
		
		/** 
		 * The width of the line if it was not justified. For unjustified text, this value is the same as <code>textLength</code>. 
		 * For justified text, this value is what the length would have been without justification, and <code>textLength</code> 
		 * represents the actual line width. For example, when the following String is justified and assigned a width of 500, it 
		 * has an actual width of 500 but an unjustified width of 268.9921875. 
		 *
		 * <p>TBD: add graphic of justified line </p>
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		
		public function get unjustifiedTextWidth():Number
		{ 
			// hack - outerTargetWidth holds value from the factory
			var textLine:TextLine = getTextLine(true);
			return textLine.unjustifiedTextWidth + (_outerTargetWidth - targetWidth); 
		}
		
		/** @private */
		tlf_internal function get lineExtent():Number
		{
			return _lineExtent;
		}
		
		/** @private */
		tlf_internal function set lineExtent(value:Number):void
		{
			_lineExtent = value;
		}
		
		/** @private */
		tlf_internal function get alignment():String
		{
			return _alignment;
		}
		
		/** @private */
		tlf_internal function set alignment(value:String):void
		{
			_alignment = value;
		} 
		
		/** @private 
		 * True if the line needs composing. */
		tlf_internal function isDamaged():Boolean
		{ 
			if (_validity != TextLineValidity.VALID)
				return true;
			if (!_released)
			{
				var textLine:TextLine = peekTextLine(); 
				if (textLine && textLine.validity != TextLineValidity.VALID)
					return true;
			}
			return false;
		}
		
		/** @private
		 * Mark the line as valid */
		tlf_internal function clearDamage():void
		{ 
			CONFIG::debug { assert(_validity == FlowDamageType.GEOMETRY, "can't clear damage other than geometry"); }
			if (_validity == TextLineValidity.VALID)		// already is valid
				return;	
			_validity = TextLineValidity.VALID; 
			
			//CONFIG::debug { assert(_textLineCache != null, "bad call to clearDamage"); }
			
			var textLine:TextLine =  peekTextLine();
			
			// The line in the cache, if there is one, is either invalid because its been released, or its geometry_damaged, or its already valid.
			CONFIG::debug { assert(!textLine || _released || textLine.validity == TextLineValidity.VALID || textLine.validity == FlowDamageType.GEOMETRY, "can't clear TextLine damage other than geometry"); }
			
			if (textLine && !_released)	// mark the TextLine as well
			{
				textLine.validity = TextLineValidity.VALID;
				CONFIG::debug { Debugging.traceFTEAssign(textLine,"validity",TextLineValidity.VALID);  }
			}
		}
		
		/** @private
		 * Mark the line as damaged */
		
		tlf_internal function damage(damageType:String):void
		{
			// trace("TextFlowLine.damage ", this.start.toString(), this.textLength.toString());
			if (_validity == damageType || _validity == TextLineValidity.INVALID)
				return;	// totally damaged
			_validity = damageType;
			
			var textLine:TextLine = peekTextLine();
			if (textLine && textLine.validity != TextLineValidity.INVALID)
			{
				textLine.validity = _validity;
				CONFIG::debug { Debugging.traceFTEAssign(textLine,"validity",damageType);  }
			}
		}
		
		/** @private */
		CONFIG::debug public function toString():String
		{
			return "x:" + x + " y: " + y + " absoluteStart:" + absoluteStart + " textLength:" + textLength +  " location: " + location + " validity: " + _validity;
		}
		
		/** 
		 * Indicates whether the <code>flash.text.engine.TextLine</code> object for this TextFlowLine exists.  
		 * The value is <code>true</code> if the TextLine object has <em>not</em> been garbage collected and 
		 * <code>false</code> if it has been.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see flash.text.engine.TextLine TextLine
		 */
		
		public function get textLineExists():Boolean
		{
			return peekTextLine() != null;			
		}
		
		/** 
		 * Returns the <code>flash.text.engine.TextLine</code> object for this line, which might be recreated 
		 * if it does not exist due to garbage collection. Set <code>forceValid</code> to <code>true</code>
		 * to cause the TextLine to be regenerated. Returns null if the TextLine cannot be recreated.
		 *.
		 * @param forceValid	if true, the TextLine is regenerated, if it exists but is invalid.
		 *
		 * @return object for this line or <code>null</code> if the TextLine object cannot be 
		 * recreated.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see flash.text.engine.TextLine TextLine
		 */
		
		public function getTextLine(forceValid:Boolean = false):TextLine
		{ 				
			var textLine:TextLine = peekTextLine();
			if (!textLine || (textLine.validity != TextLineValidity.VALID && forceValid))
			{
				if (isDamaged() && validity != FlowDamageType.GEOMETRY)
					return null;
				
				var textBlock:TextBlock = paragraph.getTextBlock();

				// regenerate the whole paragraph at once, up to current position. The TextBlock may already contain valid
				// lines that got generated on a prior call to getTextLine but couldn't be added to the cache (e.g., because
				// the cache contains an invalid line that is in the display list), so we check for that before making a new line.
				var previousLine:TextLine;
				var currentLine:TextLine = textBlock.firstLine;
				var flowComposer:IFlowComposer = paragraph.getTextFlow().flowComposer;
				var lineIndex:int = flowComposer.findLineIndexAtPosition(paragraph.getAbsoluteStart());
				do
				{
					var line:TextFlowLine = flowComposer.getLineAt(lineIndex);
					CONFIG::debug { assert (line.paragraph == paragraph, "Expecting line in same paragraph"); }
					if (currentLine != null && currentLine.validity == TextLineValidity.VALID)
					{
						textLine = currentLine;
						currentLine = currentLine.nextLine;
						
						line.updateTextLineCache(textLine);
					}
					else
					{
						textLine = line.recreateTextLine(textBlock, previousLine);
						currentLine = null;
					}
					previousLine = textLine;
					++lineIndex;
				} while (line != this);			
			}
			
			if(textLine != null && textLine.numChildren == 0 && _adornCount > 0)
			{
				var para:ParagraphElement = this.paragraph;
				var paraStart:int = para.getAbsoluteStart();
				var elem:FlowLeafElement = para.findLeaf(this.absoluteStart - paraStart);
				var elemStart:int = elem.getAbsoluteStart();
				
				createAdornments(para.getAncestorWithContainer().computedFormat.blockProgression,elem, elemStart);		
			}
			
			return textLine;
		}
		
		/** @private Regenerate the TextLine -- called when textLine has been gc'ed */
		tlf_internal function recreateTextLine(textBlock:TextBlock, previousLine:TextLine):TextLine
		{
			var textLine:TextLine;
			
			// If we already have a valid text line, just return it.
			if (!_released)
			{
				textLine = peekTextLine();
				if (textLine)
					return textLine;
			}
			
			var textFlow:TextFlow = paragraph.getTextFlow();
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var swfContext:ISWFContext = flowComposer.swfContext ? flowComposer.swfContext : BaseCompose.globalSWFContext;
			
			textLine = TextLineRecycler.getLineForReuse();
			if (textLine)
			{
				CONFIG::debug { assert(textFlow.backgroundManager == null || textFlow.backgroundManager.lineDict[textLine] === undefined,"Bad TextLine in recycler cache"); }
				textLine = swfContext.callInContext(textBlock["recreateTextLine"], textBlock, [ textLine, previousLine, _targetWidth, _lineOffset, true ]);
			}
			else
				textLine = swfContext.callInContext(textBlock.createTextLine, textBlock, [ previousLine, _targetWidth, _lineOffset, true ]);
			
			textLine.x = createShapeX();
			CONFIG::debug { Debugging.traceFTEAssign(textLine,"x", createShapeX());  }
			textLine.y = createShapeY(textFlow.computedFormat.blockProgression);
			CONFIG::debug { Debugging.traceFTEAssign(textLine,"y", createShapeY(textFlow.computedFormat.blockProgression));  }
			textLine.doubleClickEnabled = true;
			
			updateTextLineCache(textLine);
			
			return textLine;
		}
		
		/** the rule is that all "displayed" lines must be in the TextFlowLine textLineCache.  Put this new line in the cache iff there isn't already a displayed line */
		private function updateTextLineCache(textLine:TextLine):void
		{
			textLine.userData = this;	
			var existingTextLine:TextLine = peekTextLine();
			// If there is an existing, released line, and it is currently being displayed, we can't replace it in the cache.
			if (!existingTextLine || existingTextLine.parent == null)
			{
				if (existingTextLine != textLine)
					_textLineCache = new WeakRef(textLine);	
				_released = false;		
			}
		}
		
		/** @private */
		tlf_internal function markReleased():void
		{
			_released = true;
		}
		
		/** @private */
		tlf_internal function createShape(bp:String):TextLine
		{
			var textLine:TextLine = getTextLine();
			
			var newX:Number = createShapeX();
			//if (int(newX*20) != int(textLine.x*20))
			{
				textLine.x = newX;
				CONFIG::debug { Debugging.traceFTEAssign(textLine,"x", newX);  }
			}
			var newY:Number = createShapeY(bp);
			//if (int(newY*20) != int(textLine.y*20))
			{
				textLine.y = newY;
				CONFIG::debug { Debugging.traceFTEAssign(textLine,"y", newY);  }
			}
			return textLine;
		}
		
		private function createShapeX():Number
		{ return x; }
		
		private function createShapeY(bp:String):Number
		{ return bp == BlockProgression.RL ? y : y + _ascent; }
		
		/** @private 
		 * Scan through the format runs within the line, and draw any underline or strikethrough that might need it
		 */
		
		tlf_internal function createAdornments(blockProgression:String,elem:FlowLeafElement,elemStart:int):void
		{
			CONFIG::debug { assert(elemStart == elem.getAbsoluteStart(),"bad elemStart passed to createAdornments"); } 
			var endPos:int = _absoluteStart + _textLength;
			
			//init adornments back to 0
			_adornCount = 0;
			
			for (;;)
			{
				var format:ITextLayoutFormat = elem.computedFormat;
				
				_adornCount += elem.updateAdornments(this, blockProgression);
				
				var fvh:FlowValueHolder = elem.format as FlowValueHolder;
				if(fvh && fvh.userStyles && fvh.userStyles.imeStatus)
				{
					elem.updateIMEAdornments(this, blockProgression, fvh.userStyles.imeStatus as String);
				}
				elemStart += elem.textLength;
				if (elemStart >= endPos)
					break;
				elem = elem.getNextLeaf(_para);
				CONFIG::debug { assert(elem != null,"bad nextLeaf"); }
			}
		}
		
		/** @private 
		 * Scan through the format runs within the line, and figure out what the leading for the overall line is.
		 * The line's leading is equal to the maximum leading of any individual run within the line.
		 * The leading in an individual format run is calculated by looking at the leading attribute in the
		 * CharacterFormat. If it is set to a value, we just use that value. Otherwise, if it is set to AUTO,
		 * we calculate the leading based on the point size and the auto leading percentage from the ParagraphFormat.
		 */
		
		tlf_internal function getLineLeading(bp:String,elem:FlowLeafElement,elemStart:int):Number
		{
			CONFIG::debug { assert(elemStart == elem.getAbsoluteStart(),"bad elemStart passed to getLineLeading"); } 
			var endPos:int = _absoluteStart + _textLength;
			var totalLeading:Number = 0;
			CONFIG::debug { assert(elem.getAncestorWithContainer() != null,"element with no container"); }
			for (;;)
			{
				//this is kinda bunk and really shouldn't be here, but I'm loath to find a better way....
				//ignore the leading on a TCY Block.
				//if the elem is in a TCYBlock, AND it is not the only block in the line, "skip" it
				if (!(bp == BlockProgression.RL && (elem.parent is TCYElement) &&  (!isNaN(totalLeading) || (elem.textLength != this.textLength))))
				{
					var elemLeading:Number = TextLayoutFormat.lineHeightProperty.computeActualPropertyValue(elem.computedFormat.lineHeight,elem.getEffectiveFontSize());
					totalLeading = Math.max(totalLeading, elemLeading);
				}
				elemStart += elem.textLength;
				if (elemStart >= endPos)
					break;
				elem = elem.getNextLeaf(_para);
				CONFIG::debug { assert(elem != null,"bad nextLeaf"); }
			}
			return totalLeading;
		}
		
		/** @private 
		 * Scan through the format runs within the line, and figure out what the typographic ascent (i.e. ascent relative to the 
		 * Roman baseline) for the overall line is. Normally it is the distance between the Roman and Ascent baselines, 
		 * but it may be adjusted upwards by the width/height of the GraphicElement.
		 */
		tlf_internal function getLineTypographicAscent(elem:FlowLeafElement,elemStart:int):Number
		{
			CONFIG::debug { assert(elemStart == elem.getAbsoluteStart(),"bad elemStart passed to getLineTypographicAscent"); } 
			return getTextLineTypographicAscent(getTextLine(), elem, elemStart, absoluteStart+textLength, _para);
		}
		
		/** @private 
		 * Scan through the format runs within the line, and figure out what the typographic ascent (i.e. ascent relative to the 
		 * Roman baseline) for the overall line is. Normally it is the distance between the Roman and Ascent baselines, 
		 * but it may be adjusted upwards by the width/height of the GraphicElement.
		 */
		static tlf_internal function getTextLineTypographicAscent(textLine:TextLine, elem:FlowLeafElement,elemStart:int, textLineEnd:int, para:ParagraphElement):Number
		{
			CONFIG::debug { assert(elemStart == elem.getAbsoluteStart(),"bad elemStart passed to getTextLineTypographicAscent"); } 
			var rslt:Number = textLine.getBaselinePosition(flash.text.engine.TextBaseline.ROMAN) - textLine.getBaselinePosition(flash.text.engine.TextBaseline.ASCENT);
			
			for (;;) 
			{
				if (elem is InlineGraphicElement)
					rslt = Math.max(rslt,InlineGraphicElement(elem).getTypographicAscent(textLine));
				elemStart += elem.textLength;
				if (elemStart >= textLineEnd)
					break;
				elem = elem.getNextLeaf(para);
				CONFIG::debug { assert(elem != null,"bad nextLeaf"); }
			}
			return rslt;
		}
		
		//helper method to determine which subset of line is underlined
		//I believe this will be replaced by the eventSink mechanism
		private function isTextlineSubsetOfSpan(element:FlowLeafElement): Boolean
		{ 
			var spanStart:int = element.getAbsoluteStart();
			var spanEnd:int = spanStart + element.textLength;
			
			var lineStart:int = this.absoluteStart;
			var lineEnd:int = this.absoluteStart + this._textLength;
			
			return spanStart <= lineStart && spanEnd >= lineEnd;
		}
		
		
		
		/** Create a rectangle for selection */
		static private function createSelectionRect(selObj:Shape, color:uint, x:Number, y:Number, width:Number, height:Number):DisplayObject
		{
			selObj.graphics.beginFill(color);
			var cmds:Vector.<int> = new Vector.<int>();
			var pathPoints:Vector.<Number> = new Vector.<Number>();
			
			//set the start point - topLeft
			cmds.push(GraphicsPathCommand.MOVE_TO);
			pathPoints.push(x);
			pathPoints.push(y);
			
			//line to topRight
			cmds.push(GraphicsPathCommand.LINE_TO);
			pathPoints.push(x + width);
			pathPoints.push(y);
			
			//line to botRight
			cmds.push(GraphicsPathCommand.LINE_TO);
			pathPoints.push(x + width);
			pathPoints.push(y + height);
			
			//line to botLeft
			cmds.push(GraphicsPathCommand.LINE_TO);
			pathPoints.push(x);
			pathPoints.push(y + height);
			
			//line to close the path - topLeft
			cmds.push(GraphicsPathCommand.LINE_TO);
			pathPoints.push(x);
			pathPoints.push(y);
			
			selObj.graphics.drawPath(cmds, pathPoints, flash.display.GraphicsPathWinding.NON_ZERO);
			
			return selObj;			
		}
		
		/** @private getSelectionShapesCacheEntry
		 * 
		 * creates and adds block selection(s) to the text container.  In most circumstances,
		 * this method will produce and add a single DisplayObject, but in certain circumstances,
		 * such as TCY in TTB text, will need to make multiple selection rectangles.
		 * 
		 * Examples:
		 * 1) horizontal - ABCDE
		 * 2) vertical - ABCDE
		 * 3) horizontal - ABcdE
		 * 4) vertical:		A
		 * 					B
		 * 				   cde
		 * 					F
		 * 
		 */
		private function getSelectionShapesCacheEntry(begIdx:int, endIdx:int, prevLine:TextFlowLine, nextLine:TextFlowLine, blockProgression:String):SelectionCache
		{
			if (isDamaged())
				return null;
			
			// CONFIG::debug { assert(_textLineCache != null, "bad call to getSelectionShapesCacheEntry"); }
			
			//get the absolute start of the paragraph.  Calculation is expensive, so just do this once.
			var paraAbsStart:int = _para.getAbsoluteStart();
			
			//if the indexes are identical and are equal to the start of the line, then
			//don't draw anything.  This prevents a bar being drawn on a following line when
			//selecting accross line boundaries
			//with exception for a selection that includes just the first character of an empty last line in the TextFlow
			if (begIdx == endIdx && paraAbsStart + begIdx == absoluteStart)
			{
				if (absoluteStart != _para.getTextFlow().textLength-1)
					return null;
				endIdx++;
			}
			
			//the cached selection bounds and rects
			var selectionCache:SelectionCache = _selectionBlockCache[this];
			if (selectionCache && selectionCache.begIdx == begIdx && selectionCache.endIdx == endIdx)
				return selectionCache;			
			
			var drawRects:Array = new Array();
			//an array to store any tcy rectangles which need separate processing and may not exist
			var tcyDrawRects:Array = new Array();
			
			if(selectionCache == null)
			{
				selectionCache = new SelectionCache();
				_selectionBlockCache[this] = selectionCache;
			}	
			else
			{
				selectionCache.clear();
			}
			selectionCache.begIdx = begIdx;
			selectionCache.endIdx = endIdx;
			
			var textLine:TextLine = getTextLine();
			var heightAndAdj:Array = getRomanSelectionHeightAndVerticalAdjustment(prevLine, nextLine);
			calculateSelectionBounds(textLine, drawRects, begIdx, endIdx, blockProgression, heightAndAdj);
			
			//iterate the blocks and create DisplayObjects to draw...
			for each(var drawRect:Rectangle in drawRects)
			{
				CONFIG::debug{ assert(selectionCache != null, "If we're caching, selectionArray should never be null!"); }
				//we have to make new rectangles or the convertLineRectToGlobal will alter the cached ones!
				selectionCache.pushSelectionBlock(drawRect);
			}
			
			
			//allow the atoms to be garbage collected.
			if (textLine)
				textLine.flushAtomData();
			
			return selectionCache;
		}
		
		
		/** @private - helper method to calculate all selection blocks within a line.*/
		tlf_internal function calculateSelectionBounds(textLine:TextLine, rectArray:Array, begIdx:int, endIdx:int, blockProgression:String, heightAndAdj:Array):void
		{
			//the direction of the text
			var direction:String = _para.computedFormat.direction;
			//get the absolute start of the paragraph.  Calculation is expensive, so just do this once.
			var paraAbsStart:int = _para.getAbsoluteStart();
			//the current index.  used to iterate to the next element
			var curIdx:int = begIdx;
			//the current FlowLeafElement as determined by curIdx
			var curElem:FlowLeafElement = null;
			//the hightest glyph.  Needed to normalize the rectangles we'll be building
			var largestRise:Number = 0;
			
			//blockRectArray holds each leaf's blocks which could be 1 or more
			var blockRectArray:Array = new Array();
			//floatRectArray holds the selection rects for any floats in the range.
			var floatRectArray:Array = null;
			//tcyDrawRects:Array
			var tcyDrawRects:Array = null;
			
			//do this loop and only afterwards perform the normalization and addition to the rectArr
			while(curIdx < endIdx)
			{
				curElem = _para.findLeaf(curIdx);
				//if we somehow got a 0 length element, then increment the index and continue
				if(curElem.textLength == 0)
				{
					++curIdx;
					continue;
				}
				else if(curElem is InlineGraphicElement && (curElem as InlineGraphicElement).float != Float.NONE)
				{
					if(floatRectArray == null)
						floatRectArray = new Array();
					
					var tempFloatArray:Array = makeSelectionBlocks(curIdx, curIdx+1, paraAbsStart, blockProgression, direction, heightAndAdj);
					CONFIG::debug{ assert(tempFloatArray.length == 1, "How can a single floated InlineGraph have multiple shapes!"); }
					floatRectArray.push(tempFloatArray[0]);
					++curIdx;
					continue;
				}
				//the number of potential glyphs to hilite.  Could larger than needs be if we are only selecting part of it.
				var numCharsSelecting:int = curElem.textLength + curElem.getElementRelativeStart(_para) - curIdx;
				//the index of the last glyph to hilite.  If a partial selection, use endIdx
				var endPos:int = (numCharsSelecting + curIdx) > endIdx ? endIdx : (numCharsSelecting + curIdx);
				
				//if this is not a TCY in vertical, the blocks should all be running in the same direction
				if (blockProgression != BlockProgression.RL || 
					(textLine.getAtomTextRotation(textLine.getAtomIndexAtCharIndex(curIdx)) != TextRotation.ROTATE_0))
				{
					var leafBlockArray:Array = makeSelectionBlocks(curIdx, endPos, paraAbsStart, blockProgression, direction, heightAndAdj);
					//copy all the blocks into the blockRectArray - we'll normalize them later
					for(var leafBlockIter:int = 0; leafBlockIter < leafBlockArray.length; ++leafBlockIter)
					{
						blockRectArray.push(leafBlockArray[leafBlockIter]);
					}
				}
				else
				{
					var tcyBlock:FlowElement = curElem.getParentByType(TCYElement);
					CONFIG::debug{ assert(tcyBlock != null, "What kind of object is this that is ROTATE_0, but not TCY?");}
					
					//if this element is still encompassed by a SubParagraphGroupElement of some kind (either a link or a TCYBlock)
					//keep moving up to the parent.  Otherwise, the below code will go into an infinite loop.  bug 1905734
					var tcyParentRelativeEnd:int = tcyBlock.parentRelativeEnd;
					var subParBlock:SubParagraphGroupElement = tcyBlock.getParentByType(SubParagraphGroupElement) as SubParagraphGroupElement;
					while (subParBlock)
					{
						tcyParentRelativeEnd += subParBlock.parentRelativeStart;
						subParBlock = subParBlock.getParentByType(SubParagraphGroupElement) as SubParagraphGroupElement;
					}
					
					var largestTCYRise:Number = 0;
					var lastTCYIdx:int = endIdx < tcyParentRelativeEnd ? endIdx : tcyParentRelativeEnd;
					var tcyRects:Array = new Array();
					
					
					while(curIdx < lastTCYIdx)
					{
						curElem = _para.findLeaf(curIdx);
						numCharsSelecting = curElem.textLength + curElem.getElementRelativeStart(_para) - curIdx;
						endPos = numCharsSelecting + curIdx > endIdx ? endIdx : numCharsSelecting + curIdx;
						var tcyRectArray:Array =  makeSelectionBlocks(curIdx, endPos, paraAbsStart, blockProgression, direction, heightAndAdj);
						
						for(var tcyBlockIter:int = 0; tcyBlockIter < tcyRectArray.length; ++tcyBlockIter)
						{
							var tcyRect:Rectangle = tcyRectArray[tcyBlockIter];
							
							if(tcyRect.height > largestTCYRise)
							{
								largestTCYRise = tcyRect.height;
							}
							
							tcyRects.push(tcyRect);
						}
						curIdx = endPos;
					}
					
					if(!tcyDrawRects)
						tcyDrawRects = new Array();
					
					normalizeRects(tcyRects, tcyDrawRects, largestTCYRise, BlockProgression.TB, direction);
					continue;
					
				}
				
				//set the curIdx to the last char in the block
				curIdx = endPos;
			}
			
			
			
			//adding check for an empty set of draw rects.  If there are not recangles, skip this.
			//this can happen is there are ONLY TCY blocks and the whole line is selected.
			//Watson 2273832. - gak 02.09.09
			//if the whole line is selected
			if(blockRectArray.length > 0 && (paraAbsStart + begIdx) == absoluteStart && (paraAbsStart + endIdx) == (absoluteStart + textLength))
			{
				curElem = _para.findLeaf(begIdx);
				//if we have the entire line selected, but the first element is NOT the last, then
				//we will land up with a selection which is 1 character wider than it should be.
				if(((curElem.getAbsoluteStart() + curElem.textLength) < (absoluteStart + textLength)) && endPos >= 2)
				{
					//make sure that this is a white char and that we aren't deselecting the last
					//char in a line - esp important for scripts which don't use spaces ie Japanese
					var charCode:int = _para.getCharCodeAtPosition(endPos - 1);
					if(charCode != SpanElement.kParagraphTerminator.charCodeAt(0) && CharacterUtil.isWhitespace(charCode))
					{
						var lastElemBlockArray:Array = makeSelectionBlocks(endPos - 1, endPos - 1, paraAbsStart, blockProgression, direction, heightAndAdj);
						var lastRect:Rectangle = lastElemBlockArray[lastElemBlockArray.length - 1];
						var modifyRect:Rectangle = blockRectArray[blockRectArray.length - 1] as Rectangle;
						
						if (blockProgression != BlockProgression.RL)
						{
							//if they have the same width, simply remove the last block
							if(modifyRect.width == lastRect.width)
							{
								blockRectArray.pop();
							}
							else
							{
								modifyRect.width -= lastRect.width;
								
								//if this is RTL, we need to shift the selection block over by the amount
								//we reduced it.
								if(direction == Direction.RTL)
									modifyRect.left -= lastRect.width;
							}
						}
						else
						{
							//if they have the same height, simply remove the last block
							if(modifyRect.height == lastRect.height)
							{
								blockRectArray.pop();
							}
							else
							{
								modifyRect.height -= lastRect.height;
								
								//if this is RTL, we need to shift the selection block down by the amount
								//we reduced it.
								if(direction == Direction.RTL)
									modifyRect.top += lastRect.height;
							}
						}
					}
				}
			}
			
			normalizeRects(blockRectArray, rectArray, largestRise, blockProgression, direction);
			//add in the TCY Rects
			if(tcyDrawRects && tcyDrawRects.length > 0)
			{
				for(var tcyIter:int = 0; tcyIter < tcyDrawRects.length; ++tcyIter)
				{
					rectArray.push(tcyDrawRects[tcyIter]);
				}
			}
			
			//float selections do not normalize, put them into the rect array now
			if(floatRectArray)
			{
				for(var floatIter:int = 0; floatIter < floatRectArray.length; ++floatIter)
				{
					rectArray.push(floatRectArray[floatIter]);
				}
			}
			
		}
		
		private function createSelectionShapes(selObj:Shape, selFormat:SelectionFormat, container:DisplayObject, begIdx:int, endIdx:int, prevLine:TextFlowLine, nextLine:TextFlowLine):void
		{
			var contElement:ContainerFormattedElement = _para.getAncestorWithContainer();
			CONFIG::debug { assert(contElement != null,"para with no container"); }
			var blockProgression:String = contElement.computedFormat.blockProgression;
			
			var selCache:SelectionCache = getSelectionShapesCacheEntry(begIdx, endIdx, prevLine, nextLine, blockProgression);
			if (!selCache)
				return;
			
			//iterate the blocks and create DisplayObjects to draw...
			var drawRect:Rectangle;
			var color:uint = selFormat.rangeColor;
			
			if (_para && _para.getTextFlow()) {
				var selMgr:ISelectionManager = _para.getTextFlow().interactionManager;
				if (selMgr && (selMgr.anchorPosition == selMgr.activePosition))
					color = selFormat.pointColor;
			}
			
			for each (drawRect in selCache.selectionBlocks)
			{
				drawRect = drawRect.clone();
				convertLineRectToContainer(drawRect, true);
				createSelectionRect(selObj, color, drawRect.x, drawRect.y, drawRect.width, drawRect.height);
			}
		}
		
		/** @private 
		 * Get the height and vertical adjustment for the line's selection shape, assuming Western typographic rules
		 * where leading is included in selection.
		 * @return An array with two elements
		 * [0] height
		 * [1] vertical adjustment to counter 'align bottom' behavior. The remainder of the selection code assumes selection shape
		 * bottom is to be aligned with line descent. If this is not the case, vertical adjustment is set to an appropriate non-zero value. 
		 */
		tlf_internal function getRomanSelectionHeightAndVerticalAdjustment (prevLine:TextFlowLine, nextLine:TextFlowLine):Array
		{	
			var rectHeight:Number = 0;
			var verticalAdj:Number = 0; //  Default to 'align bottom'.
			
			//This code erroneously assumed that it would only be called with a SPACE justifier and that AUTO would be up.  That is incorrect
			//because some scripts, like Korean, use an up leading model and the EAST_ASIAN justifier.  New code just performs the check
			if(ParagraphElement.useUpLeadingDirection(_para.getEffectiveLeadingModel()))
			{			
				// "Space above, align bottom" 
				// 1) Space above as dictated by first baseline offset for the first line or line leading otherwise (both obtained from the 'height' data member)
				// 2) Selection rectangle must at least include all of the text area
				rectHeight = height > _textHeight ? height : _textHeight;
				
				// 3) Selection rectangle's bottom aligned with line descent; verticalAdj remains 0
			}
			else
			{
				// TODO-9/4/08-Is this the right way to check for first/last lines? 
				var isFirstLine:Boolean = !prevLine || prevLine.controller != controller || prevLine.columnIndex != columnIndex;
				var isLastLine:Boolean  = !nextLine || nextLine.controller != controller || nextLine.columnIndex != columnIndex
					|| nextLine.paragraph.getEffectiveLeadingModel() == LeadingModel.ROMAN_UP;
				//I'm removing this line as it makes the assumption that AUTO leading dir is UP only for Roman text, which is incorrect.
				//Korean also uses UP leading but uses the EastAsian justifier. - gak 01.22.09
				//||(nextLine.paragraph.computedFormat.leadingDirection == LeadingDirection.AUTO && nextLine.paragraph.computedFormat.justificationRule == JustificationRule.SPACE); 
				
				if (isLastLine)
				{
					// There is no line after this one, or there is one which uses leading UP, so leading DOWN does not apply
					
					if (!isFirstLine)
					{
						// "Space above None, align bottom" (eqivalently, "Space below None, align top"): 
						// 1) Only the text area should be selected
						rectHeight = _textHeight;
						
						// 2) Selection rectangle's bottom aligned with line descent; verticalAdj remains 0
					}
					else
					{
						// "Space above, align bottom" 
						// 1) Space above as dictated by first baseline offset 
						// 2) Selection rectangle must at least include all of the text area
						rectHeight = height > _textHeight ? height : _textHeight;
						// 3) Selection rectangle's bottom aligned with line descent; verticalAdj remains 0
					}
				}
				else
				{
					// There is a line after this one, so leading DOWN applies
					
					if (!isFirstLine)
					{
						// "Space below, align top" 
						// 1) Space below as dictated by line leading (obtained from 'height' member of next line) 
						// 2) Selection rectangle must at least include all of the text area
						rectHeight = nextLine.height > _textHeight ? nextLine.height : _textHeight;
						
						// 3) Selection rectangle's top to be aligned with line ascent, so its bottom to be at rectHeight - textLine.ascent,
						// not textLine.descent, set verticalAdj accordingly 
						verticalAdj = rectHeight - _textHeight; // same as rectHeight - textLine.ascent - textLine.descent
					}
					else
					{
						// Union of 
						// 1) first line, leading up: In this case, rectangle height is the larger of line height and text height,
						// and the rectangle is shifted down by descent amount to align bottoms. So, top of rectangle is at:
						var top:Number = _descent - (height > _textHeight ? height : _textHeight);
						
						// 2) interior line, leading down: In this case, rectangle height is the larger of line leading and text height,
						// and the rectangle is shifted up by ascent amount to align tops. So, bottom of rectangle is at:
						var bottom:Number = (nextLine.height > _textHeight ? nextLine.height : _textHeight) - _ascent;
						
						rectHeight = bottom - top;
						
						// 3) Selection rectangle's bottom to be at 'bottom', not the line's descent; set verticalAdj accordingly
						verticalAdj = bottom - _descent;
					}
				}
			}
			
			//If we don't have a line above us, then we need to pad the line a bit as well as make it shift up.
			//If we don't, then it overlaps the line below too much OR clips the top of the glyphs.
			if(!prevLine || prevLine.columnIndex != this.columnIndex || prevLine.controller != this.controller)
			{
				//make it taller - this is kinda a fudge, but we have no info to determine a good top.
				//if we don't do this, the selection rectangle will clip to the top of the glyphs and even
				//let parts stick out a bit.  So, re-add the descent and offset the rect by 50% so that
				//it appears to balance the top and bottom.
				rectHeight += this.descent;
				verticalAdj = Math.floor(this.descent/2);
			}
			return [rectHeight, verticalAdj];
		}
		
		/** @private 
		 * 
		 * 
		 */
		private function makeSelectionBlocks(begIdx:int, endIdx:int, paraAbsStart:int, blockProgression:String, direction:String, heightAndAdj:Array):Array
		{
			CONFIG::debug{ assert(begIdx <= endIdx, "Selection indexes are reversed!  How can this happen?!"); }
			
			var blockArray:Array = new Array();
			var blockRect:Rectangle = new Rectangle();
			var startElem:FlowLeafElement = _para.findLeaf(begIdx);
			var startMetrics:Rectangle = startElem.getComputedFontMetrics().emBox;
			
			var textLine:TextLine = getTextLine(true);
			
			//++makeBlockPassCounter;
			//trace(makeBlockPassCounter + ") direction = " + direction + " blockProgression = " + blockProgression);
			
			//if this is the whole line, then we should use line data to perform the selection
			if(paraAbsStart + begIdx == absoluteStart && paraAbsStart + endIdx == absoluteStart + textLength)
			{
				var globalStart:Point = new Point(0,0);
				var justRule:String = _para.getEffectiveJustificationRule();
				
				//use the textLine info if we're not using J justification
				if(justRule != JustificationRule.EAST_ASIAN)
				{
					if(blockProgression == BlockProgression.RL)
					{
						globalStart.x -= heightAndAdj[1];
						blockRect.width = heightAndAdj[0];
						blockRect.height = textLine.textWidth == 0 ? EMPTY_LINE_WIDTH : textLine.textWidth;
					}
					else 
					{
						globalStart.y += heightAndAdj[1];
						blockRect.height = heightAndAdj[0];
						blockRect.width = textLine.textWidth == 0 ? EMPTY_LINE_WIDTH : textLine.textWidth;
					}	
					
				}
				else
				{
					var eaStartElem:int  = textLine.getAtomIndexAtCharIndex(begIdx);
					var eaStartRect:Rectangle = textLine.getAtomBounds(eaStartElem);
					
					if(blockProgression == BlockProgression.RL)
					{
						blockRect.width = eaStartRect.width;
						blockRect.height = textLine.textWidth;
					}
					else
					{
						blockRect.height =  eaStartRect.height;
						blockRect.width = textLine.textWidth;
					}
				}
				
				blockRect.x = globalStart.x;
				blockRect.y = globalStart.y;
				
				if(blockProgression == BlockProgression.RL)
				{
					blockRect.x -= textLine.descent;
				}
				else
				{
					blockRect.y += (textLine.descent - blockRect.height)
				}
				
				//handle rotation
				if(startElem.computedFormat.textRotation == TextRotation.ROTATE_180 || 
					startElem.computedFormat.textRotation == TextRotation.ROTATE_90)
				{
					if(blockProgression != BlockProgression.RL)
						blockRect.y += blockRect.height / 2;
					else
						blockRect.x -= blockRect.width;
				}
				//push it onto array
				blockArray.push(blockRect);
			}
			else //we only have part of the line.  Get the start and end TC bounds
			{
				//trace(makeBlockPassCounter + ") begIdx = " + begIdx.toString() + " endIdx = " +  endIdx.toString());
				var begElementIndex:int = textLine.getAtomIndexAtCharIndex(begIdx); 
				var endElementIndex:int = adjustEndElementForBidi(begIdx, endIdx, begElementIndex, direction);
				
				//trace(makeBlockPassCounter + ") begElementIndex = " + begElementIndex.toString() + " endElementIndex = " +  endElementIndex.toString());
				CONFIG::debug{ assert(begElementIndex >= 0, "Invalid start index! begIdx = " + begIdx)};
				CONFIG::debug{ assert(endElementIndex >= 0, "Invalid end index! begIdx = " + endIdx)};
				
				if(direction == Direction.RTL && textLine.getAtomBidiLevel(endElementIndex)%2 != 0)
				{
					//if we are in RTL, anchoring the LTR text gets tricky.  Because the endElement is before the first
					//element - which is why we're in this code - the result can be a zero-width rectangle if the span of LTR
					//text breaks across line boundaries.  If that is the case, then the endElementIndex value will be 0.  As
					//this is the less common case, assume that it isn't and make all other cases come first
					if (endElementIndex == 0 && begIdx < endIdx-1)
					{
						//since the endElementIndex is 0, meaning that the LTR spans lines,
						//we want to grab the glyph before the endIdx which represents the last LTR glyph for the selection. 
						//Make a recursive call into makeSelectionBlocks using and endIdx decremented by 1.
						blockArray = makeSelectionBlocks(begIdx, endIdx - 1, paraAbsStart, blockProgression, direction, heightAndAdj);
						var bidiBlock:Array = makeSelectionBlocks(endIdx - 1, endIdx - 1, paraAbsStart, blockProgression, direction, heightAndAdj)
						var bidiBlockIter:int = 0;
						while(bidiBlockIter < bidiBlock.length)
						{
							blockArray.push(bidiBlock[bidiBlockIter]);
							++bidiBlockIter;
						}
						return blockArray;
					}
				}
				
				var begIsBidi:Boolean = begElementIndex != -1 ? isAtomBidi(begElementIndex, direction) : false;
				var endIsBidi:Boolean = endElementIndex != -1 ? isAtomBidi(endElementIndex, direction) : false;
				
				//trace("begElementIndex is bidi = " + begIsBidi.toString());
				//trace("endElementIndex is bidi = " + endIsBidi.toString());	
				
				if(begIsBidi || endIsBidi)
				{	
					//this code needs to iterate over the glyphs starting at the begElementIndex and going forward.
					//It doesn't matter is beg is bidi or not, we need to find a boundary, create a rect on it, then proceded.
					//use the value of begIsBidi for testing the consistency of the selection.
					
					//Example bidi text.  Note that the period comes at the left end of the line:
					//
					//	Bidi state:		f f t t t t t	(true/false)
					//	Element Index:0 1 2 3 4 5 6		(0 is the para terminator)
					//	Chars:			. t o _ b e
					//  Flow Index:	   6 0 1 2 3 4 (5) 	Note that these numbers represent the space between glyphs AND
					//					 5(f)			that index 5 is both the space after the e and before the period.
					//									but, the position 5 is not a valid cursor location.
					
					//the original code I implemented used the beg and endElement indexes however that fails because when the text
					//is mixed bidi/non-bidi, the indexes are only 1 char apart. This resulted in, for example, only the period in 
					//a line getting selected when the text was bidi.   Instead, we're going to use the begIdx and endIdx and 
					//recalculate the element indexes each time.  This is expensive, but I don't see an alternative. - gak 09.05.08
					var curIdx:int = begIdx;
					var incrementor:int = (begIdx != endIdx ? 1 : 0);
					
					//the indexes used to draw the seleciton.  activeStart/End represent the
					//beginning of the selection shape atoms, while cur is the one we are testing.
					var activeStartIndex:int = begElementIndex;
					var activeEndIndex:int = begElementIndex;
					var curElementIndex:int = begElementIndex;
					
					//when activeEndIsBidi no longer matches the bidi setting for the activeStartIndex, we will create the shape
					var activeEndIsBidi:Boolean = begIsBidi;
					
					do
					{
						//increment the index
						curIdx += incrementor;
						//get the next atom index
						curElementIndex = textLine.getAtomIndexAtCharIndex(curIdx);
						
						//calculate the bidi level for the - kinda cludgy, but if the bidi-text wraps, curElementIndex == -1
						//so just set it to false if this is the case.  It will get ignored in the subsequent check and curIdx
						//will == endIdx as this is the last glyph in the line - which is why the next is -1 - gak 09.12.08
						var curIsBidi:Boolean = (curElementIndex != -1) ? isAtomBidi(curElementIndex, direction) : false;
						
						if(curElementIndex != -1 && curIsBidi != activeEndIsBidi)
						{
							blockRect = makeBlock(activeStartIndex, activeEndIndex, startMetrics, blockProgression, direction, heightAndAdj);
							blockArray.push(blockRect);
							
							//shift the activeStart/End indexes to the current
							activeStartIndex = curElementIndex;
							activeEndIndex = curElementIndex;
							//update the bidi setting
							activeEndIsBidi = curIsBidi;
						}
						else
						{
							//we don't get another chance to make a block, so if this is the last char, make the block before we bail out.
							//we have to check both equality and equality plus the incrementor because if we don't, then we'll miss a
							//character in the selection.
							if(curIdx == endIdx)
							{
								blockRect = makeBlock(activeStartIndex, activeEndIndex, startMetrics, blockProgression, direction, heightAndAdj);
								blockArray.push(blockRect);
							}
							
							activeEndIndex = curElementIndex;
						}
					}while(curIdx < endIdx)
					
				}
				else
				{
					var testILG:InlineGraphicElement = startElem as InlineGraphicElement;
					if(!testILG || testILG.float == Float.NONE)
					{
						blockRect = makeBlock(begElementIndex, endElementIndex, startMetrics, blockProgression, direction, heightAndAdj);
					}
					else
					{
						blockRect = testILG.graphic.getBounds(textLine);
					}
					
					blockArray.push(blockRect);
				}
				
			}
			
			return blockArray;
		}	
		
		/** @private 
		 * 
		 * 
		 */
		private function makeBlock(begElementIndex:int, endElementIndex:int, startMetrics:Rectangle, blockProgression:String, direction:String, heightAndAdj:Array):Rectangle
		{
			var blockRect:Rectangle = new Rectangle();
			var globalStart:Point = new Point(0,0);
			var heightAndAdj:Array;
			
			if(begElementIndex > endElementIndex)
			{
				// swap the start and end
				var tempEndIdx:int = endElementIndex;
				endElementIndex = begElementIndex;
				begElementIndex = tempEndIdx;
			}
			var textLine:TextLine = getTextLine(true);
			
			//now that we have elements and they are in the right order for drawing, get their rectangles
			var begCharRect:Rectangle = textLine.getAtomBounds(begElementIndex);
			//trace(makeBlockPassCounter + ") begCharRect = " + begCharRect.toString());
			
			var endCharRect:Rectangle = textLine.getAtomBounds(endElementIndex);
			//trace(makeBlockPassCounter + ") endCharRect = " + endCharRect.toString());
			
			//Calculate the justificationRule value
			var justRule:String = _para.getEffectiveJustificationRule();
			//If this is TTB text and NOT TCY, as indicated by TextRotation.rotate0...
			if(blockProgression == BlockProgression.RL && textLine.getAtomTextRotation(begElementIndex) != TextRotation.ROTATE_0)
			{
				globalStart.y = begCharRect.y;
				blockRect.height = begElementIndex != endElementIndex ? endCharRect.bottom - begCharRect.top : begCharRect.height;
				
				//re-ordered this code.  EAST_ASIAN is more common in vertical and should be the first option.
				if(justRule == JustificationRule.EAST_ASIAN)
				{
					blockRect.width = begCharRect.width;
				}
				else
				{
					blockRect.width = heightAndAdj[0];
					globalStart.x -= heightAndAdj[1];
				}
			}
			else
			{
				//given bidi text alternations, the endCharRect could be left of the begCharRect,
				//use whichever is farther left.
				globalStart.x = (begCharRect.x < endCharRect.x ? begCharRect.x : endCharRect.x);
				//if we're here and the BlockProgression is TTB, then we're TCY.  Less frequent case, so make non-TCY
				//the first option...
				//NB - Never use baseline adjustments for TCY.  They don't make sense here.(I think) - gak 06.03.08
				if(blockProgression == BlockProgression.RL)
					globalStart.y = begCharRect.y + (startMetrics.width /2); // TODO-9/5/8:Behavior for leading down TBD
				
				
				if(justRule != JustificationRule.EAST_ASIAN)
				{
					blockRect.height = heightAndAdj[0];
					if(blockProgression == BlockProgression.RL)
						globalStart.x -= heightAndAdj[1];
					else 
						globalStart.y += heightAndAdj[1];
					//changed the width from a default of 2 to use the begCharRect.width so that point seletion
					//can choose to use the right or left side of the glyph when drawing a caret Watson 1876415/1876953- gak 08.19.09
					blockRect.width = begElementIndex != endElementIndex ? Math.abs(endCharRect.right - begCharRect.left) : begCharRect.width;
				}
				else
				{
					blockRect.height =  begCharRect.height;
					
					//changed the width from a default of 2 to use the begCharRect.width so that point seletion
					//can choose to use the right or left side of the glyph when drawing a caret Watson 1876415/1876953- gak 08.19.09
					blockRect.width = begElementIndex != endElementIndex ? Math.abs(endCharRect.right - begCharRect.left) : begCharRect.width;
				}
			}
			
			blockRect.x = globalStart.x;
			blockRect.y = globalStart.y;
			if(blockProgression == BlockProgression.RL)
			{
				if(textLine.getAtomTextRotation(begElementIndex) != TextRotation.ROTATE_0)
					blockRect.x -= textLine.descent;
				else //it's TCY
					blockRect.y -= (blockRect.height / 2)
			}
			else
			{
				blockRect.y += (textLine.descent - blockRect.height);
			}
			
			var tfl:TextFlowLine = textLine.userData as TextFlowLine;
			var curElem:FlowLeafElement = _para.findLeaf(textLine.textBlockBeginIndex + begElementIndex);
			var rotation:String = curElem.computedFormat.textRotation;
			
			//handle rotation.  For horizontal text, rotations of 90 or 180 cause the text
			//to draw under the baseline in a cosistent location.  Vertical text is a bit more complicated
			//in that a 90 rotation puts it immediately to the left of the Em Box, whereas 180 is one quarter
			//of the way in the Em Box. Fix for Watson 1915930 - gak 02.17.09
			if(rotation == TextRotation.ROTATE_180 || 
				rotation == TextRotation.ROTATE_90)
			{
				if(blockProgression != BlockProgression.RL)
					blockRect.y += (blockRect.height / 2);
				else
				{
					if(curElem.getParentByType(TCYElement) == null)
					{	
						if(rotation == TextRotation.ROTATE_90)
							blockRect.x -= blockRect.width;
						else
							blockRect.x -= (blockRect.width * .75);
					}
					else
					{
						if(rotation == TextRotation.ROTATE_90)
							blockRect.y += blockRect.height;
						else
							blockRect.y += (blockRect.height * .75);
					}
				}
			}
			
			
			return blockRect;
		}
		
		/** @private
		 * 
		 * 
		 */
		tlf_internal function convertLineRectToContainer(rect:Rectangle, constrainShape:Boolean):void
		{
			var textLine:TextLine = getTextLine();
			
			/* var globalStart:Point = new Point(rect.x, rect.y);
			
			//convert to controller coordinates...
			////trace(makeBlockPassCounter + ") globalStart = " + globalStart.toString());
			globalStart = textLine.localToGlobal(globalStart);
			////trace(makeBlockPassCounter + ") localToGlobal.globalStart = " + globalStart.toString());
			globalStart = container.globalToLocal(globalStart);
			////trace(makeBlockPassCounter + ") globalToLocal.globalStart = " + globalStart.toString());
			rect.x = globalStart.x;
			rect.y = globalStart.y; */
			
			// this is much simpler and actually more accurate - localToGlobal/globalToLocal does some rounding
			rect.x += textLine.x;
			rect.y += textLine.y;
			
			if (constrainShape)
			{
				var tf:TextFlow = _para.getTextFlow();
				var columnRect:Rectangle = controller.columnState.getColumnAt(this.columnIndex);
				constrainRectToColumn(tf,rect,columnRect,controller.horizontalScrollPosition,controller.verticalScrollPosition,controller.compositionWidth,controller.compositionHeight);
			}
		}
		
		/** @private */
		static tlf_internal function constrainRectToColumn(tf:TextFlow,rect:Rectangle,columnRect:Rectangle,hScrollPos:Number,vScrollPos:Number,compositionWidth:Number,compositionHeight:Number):void
		{		
			if(tf.computedFormat.lineBreak == LineBreak.EXPLICIT)
				return;
			
			var bp:String = tf.computedFormat.blockProgression;
			var direction:String = tf.computedFormat.direction;
			
			if(bp == BlockProgression.TB && !isNaN(compositionWidth))
			{	
				if(direction == Direction.LTR)
				{
					//make sure is doesn't go past the end of the container
					if(rect.left > (columnRect.x + columnRect.width + hScrollPos))
						rect.left = (columnRect.x + columnRect.width + hScrollPos);
					
					//make sure that if this is a selection and not a point selection, that 
					//we don't go beyond the end of the container...
					if(rect.right > (columnRect.x + columnRect.width + hScrollPos))
						rect.right = (columnRect.x + columnRect.width + hScrollPos);
				}
				else
				{
					if(rect.right < (columnRect.x + hScrollPos))
						rect.right = (columnRect.x + hScrollPos);
					
					if(rect.left < (columnRect.x + hScrollPos))
						rect.left = (columnRect.x + hScrollPos);
				}
			}
			else if (bp == BlockProgression.RL && !isNaN(compositionHeight))
			{
				if(direction == Direction.LTR)
				{
					//make sure is doesn't go past the end of the container
					if(rect.top > (columnRect.y + columnRect.height + vScrollPos))
						rect.top = (columnRect.y + columnRect.height + vScrollPos);
					
					//make sure that if this is a selection and not a point selection, that 
					//we don't go beyond the end of the container...
					if(rect.bottom > (columnRect.y + columnRect.height + vScrollPos))
						rect.bottom = (columnRect.y + columnRect.height + vScrollPos);
				}
				else
				{
					if(rect.bottom < (columnRect.y + vScrollPos))
						rect.bottom = (columnRect.y + vScrollPos);
					
					if(rect.top < (columnRect.y + vScrollPos))
						rect.top = (columnRect.y + vScrollPos);
				}
			}
		}
		
		/** @private
		 * Helper method to hilight the portion of a block selection on this TextLine.  A selection display is created and added to the line's TextFrame with ContainerController addSelectionShape.
		 * @param begIdx absolute index of start of selection on this line.
		 * @param endIdx absolute index of end of selection on this line.
		 */
		tlf_internal function hiliteBlockSelection(selObj:Shape, selFormat:SelectionFormat, container:DisplayObject, begIdx:int,endIdx:int, prevLine:TextFlowLine, nextLine:TextFlowLine):void
		{
			// no container for overflow lines, or lines scrolled out 
			if (isDamaged() || !_controller)
				return;
			
			// CONFIG::debug { assert(_textLineCache != null, "bad call to hiliteBlockSelection"); }
			
			var textLine:TextLine = peekTextLine();
			if (!textLine || !textLine.parent)
				return;
			
			var paraStart:int = _para.getAbsoluteStart();
			begIdx -= paraStart;
			endIdx -= paraStart;
			
			createSelectionShapes(selObj, selFormat, container, begIdx, endIdx, prevLine, nextLine);
		} 
		
		/** @private
		 * Helper method to hilight a point selection on this TextLine.  x,y,w,h of the selection are calculated and ContainerController.drawPointSelection is called 
		 * @param idx absolute index of the point selection.
		 */
		tlf_internal function hilitePointSelection(selFormat:SelectionFormat, idx:int, container:DisplayObject, prevLine:TextFlowLine, nextLine:TextFlowLine):void
		{
			var rect:Rectangle = computePointSelectionRectangle(idx,container,prevLine,nextLine, true);
			if (rect)
				_controller.drawPointSelection(selFormat, rect.x, rect.y, rect.width, rect.height)
		}
		
		static private function setRectangleValues(rect:Rectangle,x:Number,y:Number,width:Number,height:Number):void
		{
			rect.x = x;
			rect.y = y;
			rect.width = width;
			rect.height = height;
		}
		
		/** @private */
		tlf_internal function computePointSelectionRectangle(idx:int, container:DisplayObject, prevLine:TextFlowLine, nextLine:TextFlowLine, constrainSelRect:Boolean):Rectangle
		{
			if (isDamaged() || !_controller)
				return null;
			
			// CONFIG::debug { assert(_textLineCache != null, "bad call to hiliteBlockSelection"); }
			
			// no container for overflow lines, or lines scrolled out 
			var textLine:TextLine = peekTextLine();
			if (!textLine || !textLine.parent)
				return null;			
			// adjust to this paragraph's TextBlock
			idx -= _para.getAbsoluteStart();
			
			textLine = getTextLine(true);
			
			//endIdx will only differ if idx is altered when detecting TCY bounds
			var endIdx:int = idx;
			var elementIndex:int = textLine.getAtomIndexAtCharIndex(idx);
			CONFIG::debug{ assert(elementIndex != -1, "Invalid point selection index! idx = " + idx); }
			
			var isTCYBounds:Boolean = false;
			var paraLeadingTCY:Boolean = false;
			
			var contElement:ContainerFormattedElement = _para.getAncestorWithContainer();
			CONFIG::debug { assert(contElement != null,"para with no container"); }
			var blockProgression:String = contElement.computedFormat.blockProgression;
			var direction:String = _para.computedFormat.direction;
			
			//need to check for TCY.  TCY cannot take input into it's head, but can in it's tail.
			if(blockProgression == BlockProgression.RL)
			{
				if (idx == 0)
				{ 
					if(textLine.getAtomTextRotation(0) == TextRotation.ROTATE_0)
						paraLeadingTCY = true;
				}
				else
				{
					var prevElementIndex:int = textLine.getAtomIndexAtCharIndex(idx - 1);
					if(prevElementIndex != -1)
					{
						//if this elem is TCY, then we need to back up one space and use the right bounds
						if(textLine.getAtomTextRotation(elementIndex) == TextRotation.ROTATE_0 && 
							textLine.getAtomTextRotation(prevElementIndex) != TextRotation.ROTATE_0)
						{
							elementIndex = prevElementIndex;
							--idx;
							isTCYBounds = true;
						}
						else if(textLine.getAtomTextRotation(prevElementIndex) == TextRotation.ROTATE_0)
						{
							elementIndex = prevElementIndex;
							--idx;
							isTCYBounds = true;
						}
					}
				}
			}
			
			var heightAndAdj:Array = getRomanSelectionHeightAndVerticalAdjustment(prevLine, nextLine);
			var blockRectArray:Array = makeSelectionBlocks(idx, endIdx, _para.getAbsoluteStart(), blockProgression, direction, heightAndAdj);
			CONFIG::debug{ assert(blockRectArray.length == 1, "A point selection should return a single selection rectangle!"); }
			var rect:Rectangle = blockRectArray[0];
			
			convertLineRectToContainer(rect, constrainSelRect);
			
			var drawOnRight:Boolean = (direction == Direction.RTL);
			
			if((drawOnRight && textLine.getAtomBidiLevel(elementIndex) % 2 == 0) || 
				(!drawOnRight && textLine.getAtomBidiLevel(elementIndex) % 2 != 0))
			{
				drawOnRight = !drawOnRight;
			}
			
			if(blockProgression == BlockProgression.RL && textLine.getAtomTextRotation(elementIndex) != TextRotation.ROTATE_0)
			{
				if(!drawOnRight)
					setRectangleValues(rect, rect.x, !isTCYBounds ? rect.y : rect.y + rect.height,rect.width,1);
				else
					setRectangleValues(rect, rect.x, !isTCYBounds ? rect.y + rect.height : rect.y ,rect.width,1);
			}
			else
			{
				//choose to use the right or left side of the glyph based on Direction when drawing a caret Watson 1876415/1876953
				//if the direction is ltr, then the cursor should be on the left side
				if(!drawOnRight)
					setRectangleValues(rect, !isTCYBounds ? rect.x : rect.x + rect.width, rect.y, 1, rect.height);
				else //otherwise, it should be on the right, unless it is TCY
					setRectangleValues(rect, !isTCYBounds ? rect.x + rect.width : rect.x, rect.y, 1, rect.height);
			}
			
			//allow the atoms to be garbage collected.
			textLine.flushAtomData();
			
			return rect;
		}
		
		/** @private
		 * Three states.  Disjoint(0), Intersects(1), HeightContainedIn(2),  
		 */
		
		tlf_internal function selectionWillIntersectScrollRect(scrollRect:Rectangle, begIdx:int, endIdx:int, prevLine:TextFlowLine, nextLine:TextFlowLine):int
		{
			var contElement:ContainerFormattedElement = _para.getAncestorWithContainer();
			CONFIG::debug { assert(contElement != null,"para with no container"); }
			var blockProgression:String = contElement.computedFormat.blockProgression;
			var textLine:TextLine = getTextLine(true);
			
			if (begIdx == endIdx)
			{
				var pointSelRect:Rectangle = computePointSelectionRectangle(begIdx, DisplayObject(controller.container), prevLine, nextLine, false);
				if (pointSelRect)
				{
					if (scrollRect.containsRect(pointSelRect))
						return 2;
					if (scrollRect.intersects(pointSelRect))
						return 1;
				}
			}
			else
			{
				var paraStart:int = _para.getAbsoluteStart();
				var selCache:SelectionCache = this.getSelectionShapesCacheEntry(begIdx-paraStart,endIdx-paraStart,prevLine,nextLine,blockProgression);
				if (selCache)
				{
					//iterate the blocks and check for intersections
					var drawRect:Rectangle;
					for each (drawRect in selCache.selectionBlocks)
					{
						drawRect = drawRect.clone();
						// convertLineRectToContainer(container, drawRect);
						drawRect.x += textLine.x; 
						drawRect.y += textLine.y; 
						if (scrollRect.intersects(drawRect))
						{
							if(blockProgression == BlockProgression.RL)
							{
								// see if width is entirely contained in scrollRect
								if (drawRect.left >= scrollRect.left && drawRect.right <= scrollRect.right)
									return 2;
							}
							else
							{
								if (drawRect.top >= scrollRect.top && drawRect.bottom <= scrollRect.bottom)
									return 2;
							}
							return 1;
						}
					}
				}
			}
			return 0;
		}
		
		
		/** @private */
		CONFIG::debug private static function dumpAttribute(result:String, attributeName:String, attributeValue:Object):String
		{
			if (attributeValue)
			{
				result += " ";
				result += attributeName;
				result += "=\"";
				result += attributeValue.toString();
				result += "\""	
			}
			return result;		
		}
		
		/** @private
		 */
		private function normalizeRects(srcRects:Array, dstRects:Array, largestRise:Number, blockProgression:String, direction:String):void
		{
			//the last rectangle in the list with a potential to merge
			var lastRect:Rectangle = null;
			var rectIter:int = 0;
			while(rectIter < srcRects.length)
			{
				//get the current rect and advance the iterator
				var rect:Rectangle = srcRects[rectIter++];
				
				//apply a new height if needed.
				if(blockProgression == BlockProgression.RL)
				{
					if(rect.width < largestRise)
					{
						rect.width = largestRise;
					}
				}
				else
				{
					if(rect.height < largestRise)
					{
						rect.height = largestRise;
					}
				}
				//if the lastRect is null, no need to perform calculation
				if(lastRect == null)
				{
					lastRect = rect;
				}
				else
				{
					//TCY has already been excluded, so no need to worry about it here...
					if(blockProgression == BlockProgression.RL)
					{
						//trace(normalCounter + ") lastRect = " + lastRect.toString());
						//trace(normalCounter + ") rect = " + rect.toString());
						
						//merge it in to the last rect
						if(lastRect.y < rect.y && (lastRect.y + lastRect.height) >= rect.top && lastRect.x == rect.x)
						{
							lastRect.height += rect.height;
						}
						else if(rect.y < lastRect.y && lastRect.y <= rect.bottom && lastRect.x == rect.x)
						{
							lastRect.height += rect.height;
							lastRect.y = rect.y;
						}
						else
						{
							//we have a break in the rectangles and should push last rect onto the draw list before continuing
							dstRects.push(lastRect);
							lastRect = rect;
						}
					}
					else
					{
						if(lastRect.x < rect.x && (lastRect.x + lastRect.width) >= rect.left && lastRect.y == rect.y)
						{
							lastRect.width += rect.width;
						}
						else if(rect.x < lastRect.x && lastRect.x <= rect.right && lastRect.y == rect.y)
						{
							lastRect.width += rect.width;
							lastRect.x = rect.x;
						}
						else
						{
							//we have a break in the rectangles and should push last rect onto the draw list before continuing
							dstRects.push(lastRect);
							lastRect = rect;
						}
					}
				}
				//if this is the last rectangle, we haven't added it, do so now.
				if(rectIter == srcRects.length)
					dstRects.push(lastRect);
			}
		}
		
		/** @private */
		private function adjustEndElementForBidi(begIdx:int, endIdx:int, begElementIndex:int, direction:String):int
		{
			var endElementIndex:int = begElementIndex;
			
			var textLine:TextLine = getTextLine(true);
			
			if(endIdx != begIdx)
			{
				if(((direction == Direction.LTR && textLine.getAtomBidiLevel(begElementIndex)%2 != 0)
					|| (direction == Direction.RTL && textLine.getAtomBidiLevel(begElementIndex)%2 == 0))
					&& textLine.getAtomTextRotation(begElementIndex) != TextRotation.ROTATE_0)
					endElementIndex = textLine.getAtomIndexAtCharIndex(endIdx);
				else
				{
					endElementIndex = textLine.getAtomIndexAtCharIndex(endIdx - 1);
				}
			}
			
			if(endElementIndex == -1 && endIdx > 0)
			{
				return adjustEndElementForBidi(begIdx, endIdx - 1, begElementIndex, direction);
			}
			return endElementIndex;
		}
		
		/** @private */
		private function isAtomBidi(elementIdx:int, direction:String):Boolean
		{
			var textLine:TextLine = getTextLine(true);
			
			return (textLine.getAtomBidiLevel(elementIdx)%2 != 0 && direction == Direction.LTR) || (textLine.getAtomBidiLevel(elementIdx)%2 == 0 && direction == Direction.RTL);
		}
		
		/** @private */
		tlf_internal function get adornCount():int 
		{ return _adornCount; }
		
		/** @private */
		CONFIG::debug public function dumpToXML():String
		{
			var result:String = new String("<line");
			
			result = dumpAttribute(result, "absoluteStart", absoluteStart);
			result = dumpAttribute(result, "textLength", textLength);
			result = dumpAttribute(result, "height", height);
			result = dumpAttribute(result, "spaceBefore", spaceBefore);
			
			result = dumpAttribute(result, "spaceAfter", spaceAfter);
			result = dumpAttribute(result, "location", location);
			result = dumpAttribute(result, "x", x);
			result = dumpAttribute(result, "y", y);
			result = dumpAttribute(result, "targetWidth", targetWidth);
			result = dumpAttribute(result, "lineOffset", _lineOffset);
			result += ">\n";
			
			
			var textLine:TextLine = getTextLine(true);
			
			result += "<TextBlock>";
			result += textLine.textBlock.dump(); 
			result += "</TextBlock>";
			result += "<TextLine>"
			result += textLine.dump();
			result += "</TextLine>"
			
			result += "</line>";
			return result;
		}
		
	};
}

import flash.geom.Rectangle;

import flashx.textLayout.edit.ISelectionManager;

/** @private - I would have defined this as tlf_internal, but that is not an option, so
 * making it private.
 * 
 * The SelectionCache is a structure designed to hold a few key data points needed to quickly
 * reconstruct a selection on a line:
 * 
 * a) the beginning and end indicies of the selection on the line
 * b) the regular selection rectangles
 * c) the irregular selection rectangles, such as TCY selection rects in vertical text
 * 
 **/
final class SelectionCache
{
	private var _begIdx:int = -1;
	private var _endIdx:int = -1;
	
	private var _selectionBlocks:Array = null;
	
	public function SelectionCache()
	{
	}
	
	public function get begIdx():int 
	{ return _begIdx; }
	public function set begIdx(val:int):void	
	{ _begIdx = val; }
	
	public function get endIdx():int 
	{ return _endIdx; }
	public function set endIdx(val:int):void	
	{ _endIdx = val; }
	
	public function pushSelectionBlock(drawRect:Rectangle):void 
	{
		if(!_selectionBlocks)
			_selectionBlocks = new Array();
		
		_selectionBlocks.push(drawRect.clone());
	}
	
	public function get selectionBlocks():Array 
	{ return _selectionBlocks; }
	
	
	public function clear():void
	{
		_selectionBlocks = null;
		_begIdx = -1;
		_endIdx = -1;
	}
	
}
