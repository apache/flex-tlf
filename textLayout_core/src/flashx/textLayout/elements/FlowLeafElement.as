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
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontMetrics;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextRotation;
	import flash.text.engine.TypographicCase;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.compose.FlowComposerBase;
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.ISWFContext;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.formats.BackgroundColor;
	import flashx.textLayout.formats.BaselineShift;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.IMEStatus;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TLFTypographicCase;
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.utils.CharacterUtil;
	import flashx.textLayout.utils.LocaleUtil;
	
	use namespace tlf_internal;
		
	
	/** Base class for FlowElements that appear at the lowest level of the flow hierarchy. FlowLeafElement objects have
	* no children and include InlineGraphicElement objects and SpanElement objects.
	*
	* @playerversion Flash 10
	* @playerversion AIR 1.5
	* @langversion 3.0
	*
	* @see InlineGraphicElement
	* @see SpanElement
	*/
	public class FlowLeafElement extends FlowElement
	{				
		/** Holds the content of the leaf @private */
		protected var _blockElement:ContentElement;
		
		/** @private
		 * Holds the text for the leaf element - unless there's a valid blockElement, 
		 * in which case the text is in the rawText field of the blockElement.
		 */
		protected var _text:String;	// holds the text property if the blockElement is null
		private var _hasAttachedListeners:Boolean;	// true if FTE eventMirror may be in use
		
		/** 
		 * Base class - invoking new FlowLeafElement() throws an error exception. 
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * 
		 */
		public function FlowLeafElement()
		{
			_hasAttachedListeners = false;
			super();
		}
		
		/** @private */
		override tlf_internal function createContentElement():void
		{
			CONFIG::debug { assert(_blockElement != null, "_blockElement not allocated in derived class"); }
			if (_computedFormat)
			{
				_blockElement.elementFormat = computeElementFormat();
				CONFIG::debug { Debugging.traceFTEAssign(_blockElement,"elementFormat",_blockElement.elementFormat); }
			}
			if (parent)
				parent.insertBlockElement(this,_blockElement);
		}
		/** @private */
		override tlf_internal function releaseContentElement():void
		{
			if (!canReleaseContentElement() || _blockElement == null)
				return;
				
			_blockElement = null;
			if (_computedFormat)
				_computedFormat = null;
		}
		/** @private */
		override tlf_internal function canReleaseContentElement():Boolean
		{
			return !_hasAttachedListeners;
		}
		
		private function blockElementExists():Boolean
		{
			return _blockElement != null;
		}

		/** @private */
		tlf_internal function getBlockElement():ContentElement
		{ 
			if (!_blockElement)
				createContentElement();
			return _blockElement; 
		}
		
		
		/**
		 * The text associated with the FlowLeafElement:
		 * <p><ul>
		 * <li>The value for SpanElement subclass will be one character less than <code>textLength</code> if this is the last span in a ParagraphELement.</li>
		 * <li>The value for BreakElement subclass is a U+2028</li>
		 * <li>The value for TabElement subclass is a tab</li>
		 * <li>The value for InlineGraphicElement subclass is U+FDEF</li>
		 * </ul></p>
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see flashx.textLayout.elements.SpanElement#replaceText()
		 */
		public function get text():String
		{
			return _blockElement ?  _blockElement.rawText : _text;
		}
		
		/** @private */
		tlf_internal function getElementFormat():ElementFormat
		{ 			
			if (!_blockElement)
				createContentElement();
			return _blockElement.elementFormat; 
 		}
		
		/** @private */
		tlf_internal override function setParentAndRelativeStart(newParent:FlowGroupElement,newStart:int):void
		{
			if (newParent == parent)
				return;
		
			var hasBlock:Boolean = _blockElement != null;
			
			if (_blockElement && parent && parent.hasBlockElement())	// remove textElement from the parent content
				parent.removeBlockElement(this,_blockElement);
			if (newParent && !newParent.hasBlockElement() && _blockElement)
				newParent.createContentElement();
					
			super.setParentAndRelativeStart(newParent,newStart);
			
			// Update the FTE ContentElement structure. If the parent has FTE elements, then create FTE elements for the leaf node 
			// if it doesn't already have them, and add them in. If the parent does not have FTE elements, release the leaf's FTE
			// elements also so they match.
			if (parent)
			{
				if (parent.hasBlockElement())
				{
					if (!_blockElement)
						createContentElement();
					else if (hasBlock)	// don't do this if the _blockElement was constructed as side-effect of setParentAndRelativeStart; in that case, it's already attached
						parent.insertBlockElement(this,_blockElement);
				}
				else if (_blockElement)
					releaseContentElement();
			}
		}
	
		/** @private */
		protected function quickInitializeForSplit(sibling:FlowLeafElement,newSpanLength:int,newSpanTextElement:TextElement):void
		{
			setTextLength(newSpanLength);
			_blockElement = newSpanTextElement;
			quickCloneTextLayoutFormat(sibling);
			var tf:TextFlow = sibling.getTextFlow();
			if (tf == null || tf.formatResolver == null)
			{
				_computedFormat = sibling._computedFormat;
				if (_blockElement)
					_blockElement.elementFormat = sibling.getElementFormat();
			}
		}
		
		/** @private */
		tlf_internal function addParaTerminator():void
		{
			// some FlowLeafElement types have RO text and can't have a paragraph terminator
			CONFIG::debug { assert(false,"TODO: para terminator in non-span leaves"); }
		}
		/** @private */
		tlf_internal function removeParaTerminator():void
		{
			// some FlowLeafElement types have RO text and can't have a paragraph terminator
			CONFIG::debug { assert(false,"TODO: para terminator in non-span leaves"); }
		}
		
		/**
		 * Returns the next FlowLeafElement object.  
		 * 
		 * @param limitElement	Specifies FlowGroupElement on whose last leaf to stop looking. A value of null (default) 
		 * 	means search till no more elements.
		 * @return 	next FlowLeafElement or null if at the end
		 *
		 * @includeExample examples\FlowLeafElement_getNextLeafExample.as -noswf
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
		 */
		 
		 public function getNextLeaf(limitElement:FlowGroupElement=null):FlowLeafElement
		{
			if (!parent)
				return null;
			return parent.getNextLeafHelper(limitElement,this);
		}
		
		/**
		 * Returns the previous FlowLeafElement object.  
		 * 
		 * @param limitElement	Specifies the FlowGroupElement on whose first leaf to stop looking.   null (default) means search till no more elements.
		 * @return 	previous leafElement or null if at the end
		 *
		 * @includeExample examples\FlowLeafElement_getPreviousLeafExample.as -noswf
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
		 */
		 
		public function getPreviousLeaf(limitElement:FlowGroupElement=null):FlowLeafElement
		{
			if (!parent)
				return null;
			return parent.getPreviousLeafHelper(limitElement,this);
		}
		
		/** @private */
		public override function getCharAtPosition(relativePosition:int):String
		{
			var textValue:String = _blockElement ? _blockElement.rawText : _text;
			if (textValue)
				return textValue.charAt(relativePosition);
			return String("");
		} 
		
		/** @private */
		tlf_internal override function normalizeRange(normalizeStart:uint,normalizeEnd:uint):void
		{
			// this does the cascade - potential optimization to skip it if the _blockElement isn't attached
			if (_blockElement)
				computedFormat;
		}
		
		/** Returns the FontMetrics object for the span. The properties of the FontMetrics object describe the 
		 * emBox, strikethrough position, strikethrough thickness, underline position, 
		 * and underline thickness for the specified font. 
		 *
 		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
		 * @see flash.text.engine.FontMetrics
		 * @see flash.text.engine.ElementFormat#getFontMetrics
		 *
		 * @return font metrics associated with the span
		 */
		public function getComputedFontMetrics():FontMetrics
		{
			if (!_blockElement)
				createContentElement();
			var ef:ElementFormat = _blockElement.elementFormat;
			if (!ef)
				return null;
				
			var tf:TextFlow = getTextFlow()
			if (tf && tf.flowComposer && tf.flowComposer.swfContext)
				return tf.flowComposer.swfContext.callInContext(ef.getFontMetrics,ef,null,true);

			return ef.getFontMetrics();
		}
		
		/** @private */
		private function resolveDomBaseline():String
		{
			CONFIG::debug { assert(_computedFormat != null,"bad call to resolveDomBaseline"); }
			
			var domBase:String = _computedFormat.dominantBaseline;
			if(domBase == FormatValue.AUTO)
			{
				if(this.computedFormat.textRotation == TextRotation.ROTATE_270 /*|| 
					this.computedFormat.blockProgression == BlockProgression.RL*/)
					domBase = TextBaseline.IDEOGRAPHIC_CENTER;
				else
				{
					var para:ParagraphElement = getParagraph();
					//otherwise, avoid using the locale of the element and use the paragraph's locale
					if(para != null)
						domBase = para.getEffectiveDominantBaseline();
					else
						domBase = LocaleUtil.dominantBaseline(_computedFormat.locale);
				}
			}
			
			return domBase;
		}
		
		/** @private */
		private function computeElementFormat():ElementFormat
		{
			CONFIG::debug { assert(_computedFormat != null,"bad call to computeElementFormat"); }

			// compute the cascaded elementFormat
			var format:ElementFormat = new ElementFormat();
			CONFIG::debug { Debugging.traceFTECall(format,null,"new ElementFormat()"); }
			
			format.alignmentBaseline	= _computedFormat.alignmentBaseline;
			format.alpha				= Number(_computedFormat.textAlpha);
			format.breakOpportunity		= _computedFormat.breakOpportunity;
			format.color				= uint(_computedFormat.color);
			format.dominantBaseline		= resolveDomBaseline();
			
			format.digitCase			= _computedFormat.digitCase;
			format.digitWidth			= _computedFormat.digitWidth;
			format.ligatureLevel		= _computedFormat.ligatureLevel;
			format.fontSize				= Number(_computedFormat.fontSize);
			format.kerning				= _computedFormat.kerning;
			format.locale				= _computedFormat.locale;
			format.trackingLeft			= TextLayoutFormat.trackingLeftProperty.computeActualPropertyValue(_computedFormat.trackingLeft,format.fontSize);
			format.trackingRight		= TextLayoutFormat.trackingRightProperty.computeActualPropertyValue(_computedFormat.trackingRight,format.fontSize);
			format.textRotation			= _computedFormat.textRotation;
			format.baselineShift 		= -(TextLayoutFormat.baselineShiftProperty.computeActualPropertyValue(_computedFormat.baselineShift, format.fontSize));
			switch (_computedFormat.typographicCase)
			{
				case TLFTypographicCase.LOWERCASE_TO_SMALL_CAPS:
					format.typographicCase = TypographicCase.CAPS_AND_SMALL_CAPS;
					break;
				case TLFTypographicCase.CAPS_TO_SMALL_CAPS:
					format.typographicCase = TypographicCase.SMALL_CAPS;
					break;
				/* Others map directly so handle it in the default case */
				default:
					format.typographicCase = _computedFormat.typographicCase;
					break;
			}
			
			CONFIG::debug { Debugging.traceFTEAssign(format,"alignmentBaseline",format.alignmentBaseline); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"alpha",format.alpha); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"breakOpportunity",format.breakOpportunity); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"color",format.color); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"dominantBaseline",format.dominantBaseline); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"digitCase",format.digitCase); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"digitWidth",format.digitWidth); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"ligatureLevel",format.ligatureLevel); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"fontSize",format.fontSize); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"kerning",format.kerning); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"locale",format.locale); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"trackingLeft",format.trackingLeft); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"trackingRight",format.trackingRight); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"typographicCase",format.typographicCase); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"textRotation",format.textRotation); }
			CONFIG::debug { Debugging.traceFTEAssign(format,"baselineShift",format.baselineShift);	 }	
							
			// set the fontDesription in the cascadedFormat
			var fd:FontDescription = new FontDescription();
			fd.fontWeight = _computedFormat.fontWeight;
			fd.fontPosture = _computedFormat.fontStyle;
			fd.fontName = _computedFormat.fontFamily;
			fd.renderingMode = _computedFormat.renderingMode;
			fd.cffHinting = _computedFormat.cffHinting;
			
			// the fontLookup may be override by the resolveFontLookupFunction
			if (GlobalSettings.resolveFontLookupFunction != null)
			{
				var textFlow:TextFlow = getTextFlow();
				if (textFlow)
				{
					var flowComposer:IFlowComposer = textFlow.flowComposer;
					fd.fontLookup = GlobalSettings.resolveFontLookupFunction(flowComposer ? FlowComposerBase.computeBaseSWFContext(flowComposer.swfContext) : null,_computedFormat);
				}
				else
					fd.fontLookup = _computedFormat.fontLookup;
			}
			else
				fd.fontLookup = _computedFormat.fontLookup;
			// and now give the fontMapper a shot at rewriting the FontDescription
			var fontMapper:Function = GlobalSettings.fontMapperFunction;
			if (fontMapper != null)
				fontMapper(fd);
			CONFIG::debug { Debugging.traceFTECall(fd,null,"new FontDescription()"); }
			CONFIG::debug { Debugging.traceFTEAssign(fd,"fontWeight",fd.fontWeight);	 }
			CONFIG::debug { Debugging.traceFTEAssign(fd,"fontPosture",fd.fontPosture);	 }
			CONFIG::debug { Debugging.traceFTEAssign(fd,"fontName",fd.fontName);	 }
			CONFIG::debug { Debugging.traceFTEAssign(fd,"renderingMode",fd.renderingMode);	 }
			CONFIG::debug { Debugging.traceFTEAssign(fd,"cffHinting",fd.cffHinting);	 }
			CONFIG::debug { Debugging.traceFTEAssign(fd,"fontLookup",fd.fontLookup);	 }
			
			format.fontDescription = fd;
			CONFIG::debug { Debugging.traceFTEAssign(format,"fontDescription",fd); }
				
			//Moved code here because original code tried to access fontMetrics prior to setting the elementFormat.
			//Since getFontMetrics returns the value of blockElement.elementFormat.getFontMetrics(), we cannot call this
			//until after the element has been set. Watson 1820571 - gak 06.11.08
			// Adjust format for superscript/subscript
			if (_computedFormat.baselineShift == BaselineShift.SUPERSCRIPT || 
				_computedFormat.baselineShift == BaselineShift.SUBSCRIPT)
			{
				var fontMetrics:FontMetrics;
				var tf:TextFlow = getTextFlow();
				var swfContext:ISWFContext = tf && tf.flowComposer ? tf.flowComposer.swfContext : null;
				if (swfContext)
					fontMetrics = swfContext.callInContext(format.getFontMetrics,format,null,true);
				else	
					fontMetrics = format.getFontMetrics();	
				if (_computedFormat.baselineShift == BaselineShift.SUPERSCRIPT)
				{
					format.baselineShift = (fontMetrics.superscriptOffset * format.fontSize);
					format.fontSize = fontMetrics.superscriptScale * format.fontSize;
				}
				else // it's subscript
				{
					format.baselineShift = (fontMetrics.subscriptOffset * format.fontSize);
					format.fontSize = fontMetrics.subscriptScale * format.fontSize;
				}
				CONFIG::debug { Debugging.traceFTEAssign(format,"baselineShift",format.baselineShift); }
				CONFIG::debug { Debugging.traceFTEAssign(format,"fontSize",format.fontSize); }
			}			
			return format;
		}

		/** 
		 * The computed text format attributes that are in effect for this element.
		 * Takes into account the inheritance of attributes.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
		 * @see flashx.textLayout.formats.ITextLayoutFormat
		 */
		public override function get computedFormat():ITextLayoutFormat
		{		
			if (!_computedFormat)
			{
				_computedFormat = doComputeTextLayoutFormat();

				if (_blockElement)
				{
					_blockElement.elementFormat = computeElementFormat();
					CONFIG::debug { Debugging.traceFTEAssign(_blockElement,"elementFormat",_blockElement.elementFormat); }
				}

			}
			return _computedFormat;
		}
		
		/** Returns the fontSize from this element's properties.  @private */
		tlf_internal function getEffectiveFontSize():Number
		{
			return Number(computedFormat.fontSize);
		}
		/** @private */
		tlf_internal function getSpanBoundsOnLine(textLine:TextLine, blockProgression:String):Array
		{
			var line:TextFlowLine = TextFlowLine(textLine.userData);
			var paraStart:int = line.paragraph.getAbsoluteStart();
			var lineEnd:int = (line.absoluteStart + line.textLength) - paraStart;
			var spanStart:int = getAbsoluteStart() - paraStart;		// get start pos relative to the paragraph (which might not be the parent)
			var endPos:int = spanStart + text.length;		// so we don't include the paragraph terminator character, if present
		
			// Clip to start of line	
			var startPos:int = Math.max(spanStart, line.absoluteStart - paraStart);
			
			// Clip to end of line	
			// Heuristic for detecting spaces at the end of the line and eliminating them from the range so they won't be underlined.
			if (endPos >= lineEnd)
			{
				endPos = lineEnd;
				var spanText:String = text;
				while (endPos > startPos && CharacterUtil.isWhitespace(spanText.charCodeAt(endPos - spanStart - 1)))
					--endPos;
			}

			var mainRects:Array = [];
			line.calculateSelectionBounds(textLine, mainRects, startPos, endPos, blockProgression, [ line.textHeight,0]);
			return mainRects;
		}
		
		/** @private */
		tlf_internal function updateIMEAdornments(line:TextFlowLine, blockProgression:String, imeStatus:String):void
		{
			var tLine:TextLine = line.getTextLine();
			var metrics:FontMetrics = getComputedFontMetrics();
			var spanBoundsArray:Array = getSpanBoundsOnLine(tLine, blockProgression);
			//this is pretty much always going to have a length of 1, but just to be sure...
			for (var i:int = 0; i < spanBoundsArray.length; i++)
			{
				//setup ime variables
				var imeLineThickness:int = 1;
				var imeLineColor:uint = 0x000000;
				var imeLineStartX:Number = 0;
				var imeLineStartY:Number = 0;
				var imeLineEndX:Number = 0;
				var imeLineEndY:Number = 0;
				
				//selected text draws with 2 px
				if(imeStatus == IMEStatus.SELECTED_CONVERTED || imeStatus == IMEStatus.SELECTED_RAW)
				{
					imeLineThickness = 2;
				}
				//Raw or deadkey text draws with grey
				if(imeStatus == IMEStatus.SELECTED_RAW || imeStatus == IMEStatus.NOT_SELECTED_RAW
					|| imeStatus == IMEStatus.DEAD_KEY_INPUT_STATE)
				{
					imeLineColor = 0xA6A6A6;
				}
				
				var spanBounds:Rectangle = spanBoundsArray[i] as Rectangle;
				var stOffset:Number = calculateStrikeThrough(tLine, blockProgression, metrics);
				var ulOffset:Number = calculateUnderlineOffset(stOffset, blockProgression, metrics, tLine);
				
				if (blockProgression != BlockProgression.RL)
				{
					imeLineStartX = spanBounds.topLeft.x + 1;
					imeLineEndX = spanBounds.topLeft.x + spanBounds.width - 1;
					imeLineStartY = ulOffset;
					imeLineEndY = ulOffset;
				}
				else
				{
					//is this TCY?
					var elemIdx:int = this.getAbsoluteStart() - line.absoluteStart;
					imeLineStartY = spanBounds.topLeft.y + 1;
					imeLineEndY = spanBounds.topLeft.y + spanBounds.height - 1;
					
					//elemIdx can sometimes be negative if the text is being wrapped due to a
					//resize gesture - in which case the tLine has not necessarily been updated.
					//If the elemIdx is invalid, just treat it like it's normal ttb text - gak 07.08.08
					if(elemIdx < 0 || tLine.atomCount <= elemIdx || tLine.getAtomTextRotation(elemIdx) != TextRotation.ROTATE_0)
					{
						imeLineStartX = ulOffset;
						imeLineEndX = ulOffset;
					}
					else
					{
						//it is TCY!
						var tcyParent:TCYElement =  this.getParentByType(TCYElement) as TCYElement;
						CONFIG::debug{ assert(tcyParent != null, "What kind of object is this that is ROTATE_0, but not TCY?");}
						
						//only perform calculations for TCY adornments when we are on the last leaf.  ONLY the last leaf matters
						if((this.getAbsoluteStart() + this.textLength) == (tcyParent.getAbsoluteStart() + tcyParent.textLength))
						{
							var tcyAdornBounds:Rectangle = new Rectangle();
							tcyParent.calculateAdornmentBounds(tcyParent, tLine, blockProgression, tcyAdornBounds);
							var baseULAdjustment:Number = metrics.underlineOffset + (metrics.underlineThickness/2);
							
							imeLineStartY = tcyAdornBounds.top + 1;
							imeLineEndY = tcyAdornBounds.bottom - 1;
							imeLineStartX = spanBounds.bottomRight.x + baseULAdjustment;
							imeLineEndX = spanBounds.bottomRight.x + baseULAdjustment;
						}
					}
				}
				
				//Build the shape
				var selObj:Shape = new Shape();
				//TODO - this is probably going to need to be overridable in the full implementation
				selObj.alpha = 1;       				
				selObj.graphics.beginFill(imeLineColor);
				
				selObj.graphics.lineStyle(imeLineThickness, imeLineColor, selObj.alpha);
				selObj.graphics.moveTo(imeLineStartX, imeLineStartY);
				selObj.graphics.lineTo(imeLineEndX, imeLineEndY);
				
				selObj.graphics.endFill();
				tLine.addChild(selObj);
			}
		}
		
		
		/** @private return number of shapes added */
		tlf_internal function updateAdornments(line:TextFlowLine, blockProgression:String):int
		{
			CONFIG::debug { assert(_computedFormat != null,"invalid call to updateAdornments"); }

			// Only work on lines with strikethrough or underline
			if (_computedFormat.textDecoration == TextDecoration.UNDERLINE || _computedFormat.lineThrough || _computedFormat.backgroundAlpha > 0 && _computedFormat.backgroundColor != BackgroundColor.TRANSPARENT)
			{
				var tLine:TextLine = line.getTextLine(true);
				var spanBoundsArray:Array = getSpanBoundsOnLine(tLine, blockProgression);
				for (var i:int = 0; i < spanBoundsArray.length; i++)
					updateAdornmentsOnBounds(line, tLine, blockProgression, spanBoundsArray[i]);
				return spanBoundsArray.length ;
			}
			return 0;
		}
		 
		private function updateAdornmentsOnBounds(line:TextFlowLine, tLine:TextLine, blockProgression:String, spanBounds:Rectangle):void
		{
			CONFIG::debug { assert(_computedFormat != null,"invalid call to updateAdornmentsOnBounds"); }

   			var selObj:Shape = new Shape();
			var metrics:FontMetrics = getComputedFontMetrics();
		
			selObj.alpha = Number(_computedFormat.textAlpha);       				
						
			selObj.graphics.beginFill(uint(_computedFormat.color));
			var stOffset:Number = calculateStrikeThrough(tLine, blockProgression, metrics);
			var ulOffset:Number = calculateUnderlineOffset(stOffset, blockProgression, metrics, tLine);
						
			if (blockProgression != BlockProgression.RL)
			{
				if (_computedFormat.textDecoration == TextDecoration.UNDERLINE)
				{
					selObj.graphics.lineStyle(metrics.underlineThickness, _computedFormat.color as uint, selObj.alpha);
					selObj.graphics.moveTo(spanBounds.topLeft.x, ulOffset);
					selObj.graphics.lineTo(spanBounds.topLeft.x + spanBounds.width, ulOffset);
				}
				
				if((_computedFormat.lineThrough))
				{
					selObj.graphics.lineStyle(metrics.strikethroughThickness, _computedFormat.color as uint, selObj.alpha);
					selObj.graphics.moveTo(spanBounds.topLeft.x, stOffset);
					selObj.graphics.lineTo(spanBounds.topLeft.x + spanBounds.width, stOffset);
				}
				
				addBackgroundRect (line, tLine, metrics, spanBounds, true); 
			}
			else
			{
				//is this TCY?
				var elemIdx:int = this.getAbsoluteStart() - line.absoluteStart;
				
				//elemIdx can sometimes be negative if the text is being wrapped due to a
				//resize gesture - in which case the tLine has not necessarily been updated.
				//If the elemIdx is invalid, just treat it like it's normal ttb text - gak 07.08.08
				if(elemIdx < 0 || tLine.atomCount <= elemIdx || tLine.getAtomTextRotation(elemIdx) != TextRotation.ROTATE_0)
				{
					if (_computedFormat.textDecoration == TextDecoration.UNDERLINE)
					{
						selObj.graphics.lineStyle(metrics.underlineThickness, _computedFormat.color as uint, selObj.alpha);
						selObj.graphics.moveTo(ulOffset, spanBounds.topLeft.y);
						selObj.graphics.lineTo(ulOffset, spanBounds.topLeft.y + spanBounds.height);
					}
					
					if (_computedFormat.lineThrough == true)
					{
						selObj.graphics.lineStyle(metrics.strikethroughThickness, _computedFormat.color as uint, selObj.alpha);
						selObj.graphics.moveTo(-stOffset, spanBounds.topLeft.y);
						selObj.graphics.lineTo(-stOffset, spanBounds.topLeft.y + spanBounds.height);															
					}
					
					addBackgroundRect (line, tLine, metrics, spanBounds, false);
				}
				else
				{
					//it is TCY!
					var tcyParent:TCYElement =  this.getParentByType(TCYElement) as TCYElement;
					CONFIG::debug{ assert(tcyParent != null, "What kind of object is this that is ROTATE_0, but not TCY?");}
					
					//if the locale of the paragraph is Chinese, we need to adorn along the left and not right side.
					var tcyPara:ParagraphElement = this.getParentByType(ParagraphElement) as ParagraphElement;
					var lowerLocale:String = tcyPara.computedFormat.locale.toLowerCase();
					var adornRight:Boolean = (lowerLocale.indexOf("zh") != 0);
					
					addBackgroundRect (line, tLine, metrics, spanBounds, true, true); 
					
					//only perform calculations for TCY adornments when we are on the last leaf.  ONLY the last leaf matters
					if((this.getAbsoluteStart() + this.textLength) == (tcyParent.getAbsoluteStart() + tcyParent.textLength))
					{
						var tcyAdornBounds:Rectangle = new Rectangle();
						tcyParent.calculateAdornmentBounds(tcyParent, tLine, blockProgression, tcyAdornBounds);
						
						if (_computedFormat.textDecoration == TextDecoration.UNDERLINE)
						{
							selObj.graphics.lineStyle(metrics.underlineThickness, _computedFormat.color as uint, selObj.alpha);
							var baseULAdjustment:Number = metrics.underlineOffset + (metrics.underlineThickness/2);
							var xCoor:Number = adornRight ? spanBounds.right : spanBounds.left;
							if(!adornRight)
								baseULAdjustment = -baseULAdjustment;
							
							selObj.graphics.moveTo(xCoor + baseULAdjustment, tcyAdornBounds.top);
							selObj.graphics.lineTo(xCoor + baseULAdjustment, tcyAdornBounds.bottom);
						}

						if (_computedFormat.lineThrough == true)
						{
							var tcyMid:Number = spanBounds.bottomRight.x - tcyAdornBounds.x;
							tcyMid /= 2;
							tcyMid += tcyAdornBounds.x;
							
							selObj.graphics.lineStyle(metrics.strikethroughThickness, _computedFormat.color as uint, selObj.alpha);
							selObj.graphics.moveTo(tcyMid, tcyAdornBounds.top);
							selObj.graphics.lineTo(tcyMid, tcyAdornBounds.bottom);
						}
						
					}
				}
			}
			
			selObj.graphics.endFill();
			tLine.addChild(selObj);
		}
		
		/** @private
		 * Adds the background rectangle (if needed), making adjustments for glyph shifting as appropriate
		 */
		 private function addBackgroundRect(line:TextFlowLine, tLine:TextLine, metrics:FontMetrics, spanBounds:Rectangle, horizontalText:Boolean, isTCY:Boolean=false):void
		 {
			if(_computedFormat.backgroundAlpha == 0 || _computedFormat.backgroundColor == BackgroundColor.TRANSPARENT)
				return;
				
			var tf:TextFlow = this.getTextFlow();
			// ensure the TextFlow has a background manager - but its only supported with the StandardFlowComposer at this time
			if(!tf.backgroundManager && (tf.flowComposer is StandardFlowComposer))
				tf.backgroundManager = StandardFlowComposer(tf.flowComposer).createBackgroundManager();
			
			if (!tf.backgroundManager)
				return;
					
			// The background rectangle usually needs to coincide with the passsed-in span bounds.
			var r:Rectangle = spanBounds.clone();
			
			// With constrained glyph shifting (such as when superscript/subscript are in use), we'd like the
			// background rectangle to follow the glyphs. Not so for arbitrary glyph shifting (such as when 
			// baseline shift or baseline alignment are in use)	 	
			// TODO-06/12/2009: Need to figure out adjustment for TCY background rect. No adjustment for now.
			if (!isTCY && (_computedFormat.baselineShift == BaselineShift.SUPERSCRIPT || _computedFormat.baselineShift == BaselineShift.SUBSCRIPT))
			{	
				// The atom bounds returned by FTE do not reflect the effect of glyph shifting.
				// We approximate this effect by making the following assumptions (strikethrough/underline code does the same)
				// - The strike-through adornment runs through the center of the glyph
				// - The Roman baseline is halfway between the center and bottom (descent)
				// Effectively, the glyph's descent equals the strike-through offset, and its ascent is three times that
				
				var desiredExtent:Number; // The desired extent of the rectangle in the block progression direction
				var baselineShift:Number; 
				var fontSize:Number = getEffectiveFontSize();
				var baseStrikethroughOffset:Number = metrics.strikethroughOffset + metrics.strikethroughThickness/2;
				
				if (_computedFormat.baselineShift == BaselineShift.SUPERSCRIPT)
				{
					// The rectangle needs to sit on the line's descent and must extend far enough to accommodate the
					// ascender of the glyph (that has moved up because of superscript)
					
					var glyphAscent:Number = -3 * baseStrikethroughOffset; // see assumptions above
					baselineShift = -metrics.superscriptOffset * fontSize;
					var lineDescent:Number = tLine.getBaselinePosition(TextBaseline.DESCENT) - tLine.getBaselinePosition(TextBaseline.ROMAN);
					
					desiredExtent = glyphAscent  + baselineShift + lineDescent;
					if (horizontalText)
					{
						if (desiredExtent > r.height)
						{
							r.y -= desiredExtent - r.height;
							r.height = desiredExtent;
						}
					}
					else
					{
						if (desiredExtent > r.width)
							r.width = desiredExtent;
					}
				}
				else
				{
					// The rectangle needs to hang from the line's ascent and must extend far enough to accommodate the
					// descender of the glyph (that has moved down because of superscript)
					
					var glyphDescent:Number = -baseStrikethroughOffset; // see assumptions above
					baselineShift = metrics.subscriptOffset * fontSize; 
					var lineAscent:Number = tLine.getBaselinePosition(TextBaseline.ROMAN) - tLine.getBaselinePosition(TextBaseline.ASCENT);
					
					desiredExtent = lineAscent + baselineShift + glyphDescent;
					if (horizontalText)
					{
						if (desiredExtent > r.height)
							r.height = desiredExtent;
					}
					else
					{
						if (desiredExtent > r.width)
						{
							r.x -= desiredExtent - r.width
							r.width = desiredExtent;
						}
					}
				}
			}
			
			tf.backgroundManager.addRect(line, this, r, _computedFormat.backgroundColor, _computedFormat.backgroundAlpha);	 
		 }
		 
		
		/** @private
		 * Gets the EventDispatcher associated with this FlowLeafElement.  Use the functions
		 * of EventDispatcher such as <code>setEventHandler()</code> and <code>removeEventHandler()</code> 
		 * to capture events that happen over this FlowLeafElement object.  The
		 * event handler that you specify will be called after this FlowLeafElement object does
		 * the processing it needs to do.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
		 * @see flash.events.EventDispatcher
		 */
		tlf_internal function getEventMirror():EventDispatcher
		{
			if (!_blockElement)
			{
				var para:ParagraphElement = getParagraph();
				if (para)
					para.getTextBlock();
				else
					createContentElement();
			}
			if (_blockElement.eventMirror == null)
			{				
				_blockElement.eventMirror = new EventDispatcher();
			}
			_hasAttachedListeners = true;
			return (_blockElement.eventMirror);
		}
		
		
		/** @private */
		tlf_internal function calculateStrikeThrough(textLine:TextLine, blockProgression:String, metrics:FontMetrics):Number
		{
			var underlineAndStrikeThroughShift:int = 0;	
			var effectiveFontSize:Number = this.getEffectiveFontSize()
			if (_computedFormat.baselineShift == BaselineShift.SUPERSCRIPT)
			{
				underlineAndStrikeThroughShift = -(metrics.superscriptOffset * effectiveFontSize);
			} else if (_computedFormat.baselineShift == BaselineShift.SUBSCRIPT)
			{
				underlineAndStrikeThroughShift = -(metrics.subscriptOffset * (effectiveFontSize / metrics.subscriptScale));
			} else {
				underlineAndStrikeThroughShift = TextLayoutFormat.baselineShiftProperty.computeActualPropertyValue(_computedFormat.baselineShift, effectiveFontSize);
			}
			
			//grab the dominantBaseline and alignmentBaseline strings
			var domBaselineString:String = resolveDomBaseline();
			var alignmentBaselineString:String = this.computedFormat.alignmentBaseline;
			
			//this value represents the position of the baseline used to align this text
			var alignDomBaselineAdjustment:Number = textLine.getBaselinePosition(domBaselineString);
			
			//if the alignment baseline differs from the dominant, then we need to apply the delta between the
			//dominant and the alignment to determine the line along which the glyphs are lining up...
			if(alignmentBaselineString != flash.text.engine.TextBaseline.USE_DOMINANT_BASELINE && 
				alignmentBaselineString != domBaselineString)
			{
				alignDomBaselineAdjustment = textLine.getBaselinePosition(alignmentBaselineString);
				//take the alignmentBaseline offset and make it relative to the dominantBaseline
			}
			
			
			//first, establish the offset relative to the glyph based in fontMetrics data
			var stOffset:Number = metrics.strikethroughOffset;
			
			
			//why are we using the stOffset?  Well, the stOffset effectively tells us where the mid-point
			//of the glyph is.  By using this value, we can determine how we need to offset the underline.
			//now adjust the value.  If it is center, then the glyphs are aligned along the ST position already
			if(domBaselineString == flash.text.engine.TextBaseline.IDEOGRAPHIC_CENTER)
			{
				stOffset = 0;
			}
			else if(domBaselineString == flash.text.engine.TextBaseline.IDEOGRAPHIC_TOP || 
				domBaselineString == flash.text.engine.TextBaseline.ASCENT)
			{
				stOffset *= -2;  //if the glyphs are top or ascent, then we need to invert and double the offset
				stOffset -= (2 * metrics.strikethroughThickness);
			}
			else if(domBaselineString == flash.text.engine.TextBaseline.IDEOGRAPHIC_BOTTOM || 
				domBaselineString == flash.text.engine.TextBaseline.DESCENT)
			{
				stOffset *= 2; //if they're bottom, then we need to simply double it
				stOffset += (2 * metrics.strikethroughThickness);
			}
			else //Roman
			{
				stOffset -= metrics.strikethroughThickness;
			}
			
			
			//Now apply the actual dominant baseline position to the offset
			stOffset += (alignDomBaselineAdjustment - underlineAndStrikeThroughShift);
			return stOffset;
		}
		
		/** @private */
		tlf_internal function calculateUnderlineOffset(stOffset:Number, blockProgression:String, metrics:FontMetrics, textLine:TextLine):Number
		{
			var ulOffset:Number = metrics.underlineOffset + metrics.underlineThickness;
			var baseSTAdjustment:Number = metrics.strikethroughOffset;
			
			//based on the stOffset - which really represents the middle of the glyph, set the ulOffset
			//which will always be relative.  Note that simply using the alignDomBaselineAdjustment is not enough
			if(blockProgression != BlockProgression.RL)
				ulOffset += (stOffset - baseSTAdjustment) + metrics.underlineThickness/2;
			else
			{	
				var para:FlowElement = this.parent;
				while(!(para is ParagraphElement))
				{
					para = para.parent;
				}
				var lowerLocale:String = para.computedFormat.locale.toLowerCase();
				if(lowerLocale.indexOf("zh") == 0)
				{
					ulOffset = -ulOffset;
					ulOffset -= (stOffset - baseSTAdjustment + (metrics.underlineThickness*2));
				}
				else
					ulOffset -= (-ulOffset + stOffset + baseSTAdjustment + (metrics.underlineThickness/2));
			}
			
			return ulOffset;
		}
		
		/** @private */
		CONFIG::debug public override function debugCheckFlowElement(depth:int = 0, extraData:String = ""):int
		{
			// debugging function that asserts if the flow element tree is in an invalid state
			
			var rslt:int = super.debugCheckFlowElement(depth," fte:"+getDebugIdentity(_blockElement)+" "+extraData);
			
			// TODO: eventually these tests will be valid for InlineGraphicElement elements as well
			if (!(this is InlineGraphicElement))
			{
				rslt += assert(textLength != 0 || bindableElement || (parent is SubParagraphGroupElement && parent.numChildren == 1), "FlowLeafElement with zero textLength must be deleted"); 
				rslt += assert(parent is ParagraphElement || parent is SubParagraphGroupElement, "FlowLeafElement must have a ParagraphElement or SubParagraphGroupElement parent");
			}
			return rslt;
		}
	}
}
