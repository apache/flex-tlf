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
package flashx.textLayout.formats
{
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;

	[ExcludeClass]
	/** @private */
	public class TextLayoutFormatValueHolder implements ITextLayoutFormat
	{
		private var _coreStyles:Object;

		public function TextLayoutFormatValueHolder(initialValues:ITextLayoutFormat = null)
		{
			initialize(initialValues);
		}

		private function initialize(initialValues:ITextLayoutFormat):void
		{
			if (initialValues)
			{
				var holder:TextLayoutFormatValueHolder = initialValues as TextLayoutFormatValueHolder;
				if (holder)
				{
					for (var s:String in holder.coreStyles)
						writableCoreStyles()[s] = holder.coreStyles[s];
				}
				else
				{
					for each (var prop:Property in TextLayoutFormat.description)
					{
						var val:* = initialValues[prop.name];
						if (val !== undefined)
							writableCoreStyles()[prop.name] = val;
					}
				}
			}
		}

		private function writableCoreStyles():Object
		{
			if (_coreStyles == null)
				_coreStyles = new Object();
			return _coreStyles;
		}

		public function get coreStyles():Object
		{ return _coreStyles; }
		public function set coreStyles(val:Object):void
		{ _coreStyles = val; }

		private function getCoreStyle(styleProp:String):*
		{ return _coreStyles ? _coreStyles[styleProp] : undefined; }
		private function setCoreStyle(styleProp:Property,currValue:*,newValue:*):void
		{
			newValue = styleProp.setHelper(currValue,newValue);
			if (newValue !== undefined)
				writableCoreStyles()[styleProp.name] = newValue;
			else if (_coreStyles)
				delete _coreStyles[styleProp.name];
		}

		public function hash(hash:uint):uint
		{
			for (var s:String in coreStyles)
				hash = TextLayoutFormat.description[s].hash(coreStyles[s],hash);
			return hash;
		}

		public function set format(incoming:ITextLayoutFormat):void
		{
			if (incoming == null)
			{
				coreStyles = null;
				return;
			}
			var holder:TextLayoutFormatValueHolder = incoming as TextLayoutFormatValueHolder;
			if (holder)
			{
				coreStyles = holder.coreStyles ? Property.shallowCopy(holder.coreStyles) : null;
				return;
			}

			coreStyles = null;
			var val:*;
			if ((val = incoming.color) !== undefined)
				this.color = val;
			if ((val = incoming.backgroundColor) !== undefined)
				this.backgroundColor = val;
			if ((val = incoming.lineThrough) !== undefined)
				this.lineThrough = val;
			if ((val = incoming.textAlpha) !== undefined)
				this.textAlpha = val;
			if ((val = incoming.backgroundAlpha) !== undefined)
				this.backgroundAlpha = val;
			if ((val = incoming.fontSize) !== undefined)
				this.fontSize = val;
			if ((val = incoming.baselineShift) !== undefined)
				this.baselineShift = val;
			if ((val = incoming.trackingLeft) !== undefined)
				this.trackingLeft = val;
			if ((val = incoming.trackingRight) !== undefined)
				this.trackingRight = val;
			if ((val = incoming.lineHeight) !== undefined)
				this.lineHeight = val;
			if ((val = incoming.breakOpportunity) !== undefined)
				this.breakOpportunity = val;
			if ((val = incoming.digitCase) !== undefined)
				this.digitCase = val;
			if ((val = incoming.digitWidth) !== undefined)
				this.digitWidth = val;
			if ((val = incoming.dominantBaseline) !== undefined)
				this.dominantBaseline = val;
			if ((val = incoming.kerning) !== undefined)
				this.kerning = val;
			if ((val = incoming.ligatureLevel) !== undefined)
				this.ligatureLevel = val;
			if ((val = incoming.alignmentBaseline) !== undefined)
				this.alignmentBaseline = val;
			if ((val = incoming.locale) !== undefined)
				this.locale = val;
			if ((val = incoming.typographicCase) !== undefined)
				this.typographicCase = val;
			if ((val = incoming.fontFamily) !== undefined)
				this.fontFamily = val;
			if ((val = incoming.textDecoration) !== undefined)
				this.textDecoration = val;
			if ((val = incoming.fontWeight) !== undefined)
				this.fontWeight = val;
			if ((val = incoming.fontStyle) !== undefined)
				this.fontStyle = val;
			if ((val = incoming.whiteSpaceCollapse) !== undefined)
				this.whiteSpaceCollapse = val;
			if ((val = incoming.renderingMode) !== undefined)
				this.renderingMode = val;
			if ((val = incoming.cffHinting) !== undefined)
				this.cffHinting = val;
			if ((val = incoming.fontLookup) !== undefined)
				this.fontLookup = val;
			if ((val = incoming.textRotation) !== undefined)
				this.textRotation = val;
			if ((val = incoming.textIndent) !== undefined)
				this.textIndent = val;
			if ((val = incoming.paragraphStartIndent) !== undefined)
				this.paragraphStartIndent = val;
			if ((val = incoming.paragraphEndIndent) !== undefined)
				this.paragraphEndIndent = val;
			if ((val = incoming.paragraphSpaceBefore) !== undefined)
				this.paragraphSpaceBefore = val;
			if ((val = incoming.paragraphSpaceAfter) !== undefined)
				this.paragraphSpaceAfter = val;
			if ((val = incoming.textAlign) !== undefined)
				this.textAlign = val;
			if ((val = incoming.textAlignLast) !== undefined)
				this.textAlignLast = val;
			if ((val = incoming.textJustify) !== undefined)
				this.textJustify = val;
			if ((val = incoming.justificationRule) !== undefined)
				this.justificationRule = val;
			if ((val = incoming.justificationStyle) !== undefined)
				this.justificationStyle = val;
			if ((val = incoming.direction) !== undefined)
				this.direction = val;
			if ((val = incoming.tabStops) !== undefined)
				this.tabStops = val;
			if ((val = incoming.leadingModel) !== undefined)
				this.leadingModel = val;
			if ((val = incoming.columnGap) !== undefined)
				this.columnGap = val;
			if ((val = incoming.paddingLeft) !== undefined)
				this.paddingLeft = val;
			if ((val = incoming.paddingTop) !== undefined)
				this.paddingTop = val;
			if ((val = incoming.paddingRight) !== undefined)
				this.paddingRight = val;
			if ((val = incoming.paddingBottom) !== undefined)
				this.paddingBottom = val;
			if ((val = incoming.columnCount) !== undefined)
				this.columnCount = val;
			if ((val = incoming.columnWidth) !== undefined)
				this.columnWidth = val;
			if ((val = incoming.firstBaselineOffset) !== undefined)
				this.firstBaselineOffset = val;
			if ((val = incoming.verticalAlign) !== undefined)
				this.verticalAlign = val;
			if ((val = incoming.blockProgression) !== undefined)
				this.blockProgression = val;
			if ((val = incoming.lineBreak) !== undefined)
				this.lineBreak = val;
		}

		public function concat(incoming:ITextLayoutFormat):void
		{
			var holder:TextLayoutFormatValueHolder = incoming as TextLayoutFormatValueHolder;
			if (holder)
			{
				for (var key:String in holder.coreStyles)
				{
					this[key] = TextLayoutFormat.description[key].concatHelper(this[key],holder.coreStyles[key]);
				}
				return;
			}

			this.color = TextLayoutFormat.colorProperty.concatHelper(this.color, incoming.color);
			this.backgroundColor = TextLayoutFormat.backgroundColorProperty.concatHelper(this.backgroundColor, incoming.backgroundColor);
			this.lineThrough = TextLayoutFormat.lineThroughProperty.concatHelper(this.lineThrough, incoming.lineThrough);
			this.textAlpha = TextLayoutFormat.textAlphaProperty.concatHelper(this.textAlpha, incoming.textAlpha);
			this.backgroundAlpha = TextLayoutFormat.backgroundAlphaProperty.concatHelper(this.backgroundAlpha, incoming.backgroundAlpha);
			this.fontSize = TextLayoutFormat.fontSizeProperty.concatHelper(this.fontSize, incoming.fontSize);
			this.baselineShift = TextLayoutFormat.baselineShiftProperty.concatHelper(this.baselineShift, incoming.baselineShift);
			this.trackingLeft = TextLayoutFormat.trackingLeftProperty.concatHelper(this.trackingLeft, incoming.trackingLeft);
			this.trackingRight = TextLayoutFormat.trackingRightProperty.concatHelper(this.trackingRight, incoming.trackingRight);
			this.lineHeight = TextLayoutFormat.lineHeightProperty.concatHelper(this.lineHeight, incoming.lineHeight);
			this.breakOpportunity = TextLayoutFormat.breakOpportunityProperty.concatHelper(this.breakOpportunity, incoming.breakOpportunity);
			this.digitCase = TextLayoutFormat.digitCaseProperty.concatHelper(this.digitCase, incoming.digitCase);
			this.digitWidth = TextLayoutFormat.digitWidthProperty.concatHelper(this.digitWidth, incoming.digitWidth);
			this.dominantBaseline = TextLayoutFormat.dominantBaselineProperty.concatHelper(this.dominantBaseline, incoming.dominantBaseline);
			this.kerning = TextLayoutFormat.kerningProperty.concatHelper(this.kerning, incoming.kerning);
			this.ligatureLevel = TextLayoutFormat.ligatureLevelProperty.concatHelper(this.ligatureLevel, incoming.ligatureLevel);
			this.alignmentBaseline = TextLayoutFormat.alignmentBaselineProperty.concatHelper(this.alignmentBaseline, incoming.alignmentBaseline);
			this.locale = TextLayoutFormat.localeProperty.concatHelper(this.locale, incoming.locale);
			this.typographicCase = TextLayoutFormat.typographicCaseProperty.concatHelper(this.typographicCase, incoming.typographicCase);
			this.fontFamily = TextLayoutFormat.fontFamilyProperty.concatHelper(this.fontFamily, incoming.fontFamily);
			this.textDecoration = TextLayoutFormat.textDecorationProperty.concatHelper(this.textDecoration, incoming.textDecoration);
			this.fontWeight = TextLayoutFormat.fontWeightProperty.concatHelper(this.fontWeight, incoming.fontWeight);
			this.fontStyle = TextLayoutFormat.fontStyleProperty.concatHelper(this.fontStyle, incoming.fontStyle);
			this.whiteSpaceCollapse = TextLayoutFormat.whiteSpaceCollapseProperty.concatHelper(this.whiteSpaceCollapse, incoming.whiteSpaceCollapse);
			this.renderingMode = TextLayoutFormat.renderingModeProperty.concatHelper(this.renderingMode, incoming.renderingMode);
			this.cffHinting = TextLayoutFormat.cffHintingProperty.concatHelper(this.cffHinting, incoming.cffHinting);
			this.fontLookup = TextLayoutFormat.fontLookupProperty.concatHelper(this.fontLookup, incoming.fontLookup);
			this.textRotation = TextLayoutFormat.textRotationProperty.concatHelper(this.textRotation, incoming.textRotation);
			this.textIndent = TextLayoutFormat.textIndentProperty.concatHelper(this.textIndent, incoming.textIndent);
			this.paragraphStartIndent = TextLayoutFormat.paragraphStartIndentProperty.concatHelper(this.paragraphStartIndent, incoming.paragraphStartIndent);
			this.paragraphEndIndent = TextLayoutFormat.paragraphEndIndentProperty.concatHelper(this.paragraphEndIndent, incoming.paragraphEndIndent);
			this.paragraphSpaceBefore = TextLayoutFormat.paragraphSpaceBeforeProperty.concatHelper(this.paragraphSpaceBefore, incoming.paragraphSpaceBefore);
			this.paragraphSpaceAfter = TextLayoutFormat.paragraphSpaceAfterProperty.concatHelper(this.paragraphSpaceAfter, incoming.paragraphSpaceAfter);
			this.textAlign = TextLayoutFormat.textAlignProperty.concatHelper(this.textAlign, incoming.textAlign);
			this.textAlignLast = TextLayoutFormat.textAlignLastProperty.concatHelper(this.textAlignLast, incoming.textAlignLast);
			this.textJustify = TextLayoutFormat.textJustifyProperty.concatHelper(this.textJustify, incoming.textJustify);
			this.justificationRule = TextLayoutFormat.justificationRuleProperty.concatHelper(this.justificationRule, incoming.justificationRule);
			this.justificationStyle = TextLayoutFormat.justificationStyleProperty.concatHelper(this.justificationStyle, incoming.justificationStyle);
			this.direction = TextLayoutFormat.directionProperty.concatHelper(this.direction, incoming.direction);
			this.tabStops = TextLayoutFormat.tabStopsProperty.concatHelper(this.tabStops, incoming.tabStops);
			this.leadingModel = TextLayoutFormat.leadingModelProperty.concatHelper(this.leadingModel, incoming.leadingModel);
			this.columnGap = TextLayoutFormat.columnGapProperty.concatHelper(this.columnGap, incoming.columnGap);
			this.paddingLeft = TextLayoutFormat.paddingLeftProperty.concatHelper(this.paddingLeft, incoming.paddingLeft);
			this.paddingTop = TextLayoutFormat.paddingTopProperty.concatHelper(this.paddingTop, incoming.paddingTop);
			this.paddingRight = TextLayoutFormat.paddingRightProperty.concatHelper(this.paddingRight, incoming.paddingRight);
			this.paddingBottom = TextLayoutFormat.paddingBottomProperty.concatHelper(this.paddingBottom, incoming.paddingBottom);
			this.columnCount = TextLayoutFormat.columnCountProperty.concatHelper(this.columnCount, incoming.columnCount);
			this.columnWidth = TextLayoutFormat.columnWidthProperty.concatHelper(this.columnWidth, incoming.columnWidth);
			this.firstBaselineOffset = TextLayoutFormat.firstBaselineOffsetProperty.concatHelper(this.firstBaselineOffset, incoming.firstBaselineOffset);
			this.verticalAlign = TextLayoutFormat.verticalAlignProperty.concatHelper(this.verticalAlign, incoming.verticalAlign);
			this.blockProgression = TextLayoutFormat.blockProgressionProperty.concatHelper(this.blockProgression, incoming.blockProgression);
			this.lineBreak = TextLayoutFormat.lineBreakProperty.concatHelper(this.lineBreak, incoming.lineBreak);
		}

		public function concatInheritOnly(incoming:ITextLayoutFormat):void
		{
			var holder:TextLayoutFormatValueHolder = incoming as TextLayoutFormatValueHolder;
			if (holder)
			{
				for (var key:String in holder.coreStyles)
				{
					this[key] = TextLayoutFormat.description[key].concatInheritOnlyHelper(this[key],holder.coreStyles[key]);
				}
				return;
			}

			this.color = TextLayoutFormat.colorProperty.concatInheritOnlyHelper(this.color, incoming.color);
			this.backgroundColor = TextLayoutFormat.backgroundColorProperty.concatInheritOnlyHelper(this.backgroundColor, incoming.backgroundColor);
			this.lineThrough = TextLayoutFormat.lineThroughProperty.concatInheritOnlyHelper(this.lineThrough, incoming.lineThrough);
			this.textAlpha = TextLayoutFormat.textAlphaProperty.concatInheritOnlyHelper(this.textAlpha, incoming.textAlpha);
			this.backgroundAlpha = TextLayoutFormat.backgroundAlphaProperty.concatInheritOnlyHelper(this.backgroundAlpha, incoming.backgroundAlpha);
			this.fontSize = TextLayoutFormat.fontSizeProperty.concatInheritOnlyHelper(this.fontSize, incoming.fontSize);
			this.baselineShift = TextLayoutFormat.baselineShiftProperty.concatInheritOnlyHelper(this.baselineShift, incoming.baselineShift);
			this.trackingLeft = TextLayoutFormat.trackingLeftProperty.concatInheritOnlyHelper(this.trackingLeft, incoming.trackingLeft);
			this.trackingRight = TextLayoutFormat.trackingRightProperty.concatInheritOnlyHelper(this.trackingRight, incoming.trackingRight);
			this.lineHeight = TextLayoutFormat.lineHeightProperty.concatInheritOnlyHelper(this.lineHeight, incoming.lineHeight);
			this.breakOpportunity = TextLayoutFormat.breakOpportunityProperty.concatInheritOnlyHelper(this.breakOpportunity, incoming.breakOpportunity);
			this.digitCase = TextLayoutFormat.digitCaseProperty.concatInheritOnlyHelper(this.digitCase, incoming.digitCase);
			this.digitWidth = TextLayoutFormat.digitWidthProperty.concatInheritOnlyHelper(this.digitWidth, incoming.digitWidth);
			this.dominantBaseline = TextLayoutFormat.dominantBaselineProperty.concatInheritOnlyHelper(this.dominantBaseline, incoming.dominantBaseline);
			this.kerning = TextLayoutFormat.kerningProperty.concatInheritOnlyHelper(this.kerning, incoming.kerning);
			this.ligatureLevel = TextLayoutFormat.ligatureLevelProperty.concatInheritOnlyHelper(this.ligatureLevel, incoming.ligatureLevel);
			this.alignmentBaseline = TextLayoutFormat.alignmentBaselineProperty.concatInheritOnlyHelper(this.alignmentBaseline, incoming.alignmentBaseline);
			this.locale = TextLayoutFormat.localeProperty.concatInheritOnlyHelper(this.locale, incoming.locale);
			this.typographicCase = TextLayoutFormat.typographicCaseProperty.concatInheritOnlyHelper(this.typographicCase, incoming.typographicCase);
			this.fontFamily = TextLayoutFormat.fontFamilyProperty.concatInheritOnlyHelper(this.fontFamily, incoming.fontFamily);
			this.textDecoration = TextLayoutFormat.textDecorationProperty.concatInheritOnlyHelper(this.textDecoration, incoming.textDecoration);
			this.fontWeight = TextLayoutFormat.fontWeightProperty.concatInheritOnlyHelper(this.fontWeight, incoming.fontWeight);
			this.fontStyle = TextLayoutFormat.fontStyleProperty.concatInheritOnlyHelper(this.fontStyle, incoming.fontStyle);
			this.whiteSpaceCollapse = TextLayoutFormat.whiteSpaceCollapseProperty.concatInheritOnlyHelper(this.whiteSpaceCollapse, incoming.whiteSpaceCollapse);
			this.renderingMode = TextLayoutFormat.renderingModeProperty.concatInheritOnlyHelper(this.renderingMode, incoming.renderingMode);
			this.cffHinting = TextLayoutFormat.cffHintingProperty.concatInheritOnlyHelper(this.cffHinting, incoming.cffHinting);
			this.fontLookup = TextLayoutFormat.fontLookupProperty.concatInheritOnlyHelper(this.fontLookup, incoming.fontLookup);
			this.textRotation = TextLayoutFormat.textRotationProperty.concatInheritOnlyHelper(this.textRotation, incoming.textRotation);
			this.textIndent = TextLayoutFormat.textIndentProperty.concatInheritOnlyHelper(this.textIndent, incoming.textIndent);
			this.paragraphStartIndent = TextLayoutFormat.paragraphStartIndentProperty.concatInheritOnlyHelper(this.paragraphStartIndent, incoming.paragraphStartIndent);
			this.paragraphEndIndent = TextLayoutFormat.paragraphEndIndentProperty.concatInheritOnlyHelper(this.paragraphEndIndent, incoming.paragraphEndIndent);
			this.paragraphSpaceBefore = TextLayoutFormat.paragraphSpaceBeforeProperty.concatInheritOnlyHelper(this.paragraphSpaceBefore, incoming.paragraphSpaceBefore);
			this.paragraphSpaceAfter = TextLayoutFormat.paragraphSpaceAfterProperty.concatInheritOnlyHelper(this.paragraphSpaceAfter, incoming.paragraphSpaceAfter);
			this.textAlign = TextLayoutFormat.textAlignProperty.concatInheritOnlyHelper(this.textAlign, incoming.textAlign);
			this.textAlignLast = TextLayoutFormat.textAlignLastProperty.concatInheritOnlyHelper(this.textAlignLast, incoming.textAlignLast);
			this.textJustify = TextLayoutFormat.textJustifyProperty.concatInheritOnlyHelper(this.textJustify, incoming.textJustify);
			this.justificationRule = TextLayoutFormat.justificationRuleProperty.concatInheritOnlyHelper(this.justificationRule, incoming.justificationRule);
			this.justificationStyle = TextLayoutFormat.justificationStyleProperty.concatInheritOnlyHelper(this.justificationStyle, incoming.justificationStyle);
			this.direction = TextLayoutFormat.directionProperty.concatInheritOnlyHelper(this.direction, incoming.direction);
			this.tabStops = TextLayoutFormat.tabStopsProperty.concatInheritOnlyHelper(this.tabStops, incoming.tabStops);
			this.leadingModel = TextLayoutFormat.leadingModelProperty.concatInheritOnlyHelper(this.leadingModel, incoming.leadingModel);
			this.columnGap = TextLayoutFormat.columnGapProperty.concatInheritOnlyHelper(this.columnGap, incoming.columnGap);
			this.paddingLeft = TextLayoutFormat.paddingLeftProperty.concatInheritOnlyHelper(this.paddingLeft, incoming.paddingLeft);
			this.paddingTop = TextLayoutFormat.paddingTopProperty.concatInheritOnlyHelper(this.paddingTop, incoming.paddingTop);
			this.paddingRight = TextLayoutFormat.paddingRightProperty.concatInheritOnlyHelper(this.paddingRight, incoming.paddingRight);
			this.paddingBottom = TextLayoutFormat.paddingBottomProperty.concatInheritOnlyHelper(this.paddingBottom, incoming.paddingBottom);
			this.columnCount = TextLayoutFormat.columnCountProperty.concatInheritOnlyHelper(this.columnCount, incoming.columnCount);
			this.columnWidth = TextLayoutFormat.columnWidthProperty.concatInheritOnlyHelper(this.columnWidth, incoming.columnWidth);
			this.firstBaselineOffset = TextLayoutFormat.firstBaselineOffsetProperty.concatInheritOnlyHelper(this.firstBaselineOffset, incoming.firstBaselineOffset);
			this.verticalAlign = TextLayoutFormat.verticalAlignProperty.concatInheritOnlyHelper(this.verticalAlign, incoming.verticalAlign);
			this.blockProgression = TextLayoutFormat.blockProgressionProperty.concatInheritOnlyHelper(this.blockProgression, incoming.blockProgression);
			this.lineBreak = TextLayoutFormat.lineBreakProperty.concatInheritOnlyHelper(this.lineBreak, incoming.lineBreak);
		}

		public function apply(incoming:ITextLayoutFormat):void
		{
			var holder:TextLayoutFormatValueHolder = incoming as TextLayoutFormatValueHolder;
			if (holder)
			{
				for (var key:String in holder.coreStyles)
				{
					CONFIG::debug { assert(holder.coreStyles[key] !== undefined,"bad value in apply"); }
					this[key] = holder.coreStyles[key];
				}
				return;
			}

			var val:*;
			if ((val = incoming.color) !== undefined)
				this.color = val;
			if ((val = incoming.backgroundColor) !== undefined)
				this.backgroundColor = val;
			if ((val = incoming.lineThrough) !== undefined)
				this.lineThrough = val;
			if ((val = incoming.textAlpha) !== undefined)
				this.textAlpha = val;
			if ((val = incoming.backgroundAlpha) !== undefined)
				this.backgroundAlpha = val;
			if ((val = incoming.fontSize) !== undefined)
				this.fontSize = val;
			if ((val = incoming.baselineShift) !== undefined)
				this.baselineShift = val;
			if ((val = incoming.trackingLeft) !== undefined)
				this.trackingLeft = val;
			if ((val = incoming.trackingRight) !== undefined)
				this.trackingRight = val;
			if ((val = incoming.lineHeight) !== undefined)
				this.lineHeight = val;
			if ((val = incoming.breakOpportunity) !== undefined)
				this.breakOpportunity = val;
			if ((val = incoming.digitCase) !== undefined)
				this.digitCase = val;
			if ((val = incoming.digitWidth) !== undefined)
				this.digitWidth = val;
			if ((val = incoming.dominantBaseline) !== undefined)
				this.dominantBaseline = val;
			if ((val = incoming.kerning) !== undefined)
				this.kerning = val;
			if ((val = incoming.ligatureLevel) !== undefined)
				this.ligatureLevel = val;
			if ((val = incoming.alignmentBaseline) !== undefined)
				this.alignmentBaseline = val;
			if ((val = incoming.locale) !== undefined)
				this.locale = val;
			if ((val = incoming.typographicCase) !== undefined)
				this.typographicCase = val;
			if ((val = incoming.fontFamily) !== undefined)
				this.fontFamily = val;
			if ((val = incoming.textDecoration) !== undefined)
				this.textDecoration = val;
			if ((val = incoming.fontWeight) !== undefined)
				this.fontWeight = val;
			if ((val = incoming.fontStyle) !== undefined)
				this.fontStyle = val;
			if ((val = incoming.whiteSpaceCollapse) !== undefined)
				this.whiteSpaceCollapse = val;
			if ((val = incoming.renderingMode) !== undefined)
				this.renderingMode = val;
			if ((val = incoming.cffHinting) !== undefined)
				this.cffHinting = val;
			if ((val = incoming.fontLookup) !== undefined)
				this.fontLookup = val;
			if ((val = incoming.textRotation) !== undefined)
				this.textRotation = val;
			if ((val = incoming.textIndent) !== undefined)
				this.textIndent = val;
			if ((val = incoming.paragraphStartIndent) !== undefined)
				this.paragraphStartIndent = val;
			if ((val = incoming.paragraphEndIndent) !== undefined)
				this.paragraphEndIndent = val;
			if ((val = incoming.paragraphSpaceBefore) !== undefined)
				this.paragraphSpaceBefore = val;
			if ((val = incoming.paragraphSpaceAfter) !== undefined)
				this.paragraphSpaceAfter = val;
			if ((val = incoming.textAlign) !== undefined)
				this.textAlign = val;
			if ((val = incoming.textAlignLast) !== undefined)
				this.textAlignLast = val;
			if ((val = incoming.textJustify) !== undefined)
				this.textJustify = val;
			if ((val = incoming.justificationRule) !== undefined)
				this.justificationRule = val;
			if ((val = incoming.justificationStyle) !== undefined)
				this.justificationStyle = val;
			if ((val = incoming.direction) !== undefined)
				this.direction = val;
			if ((val = incoming.tabStops) !== undefined)
				this.tabStops = val;
			if ((val = incoming.leadingModel) !== undefined)
				this.leadingModel = val;
			if ((val = incoming.columnGap) !== undefined)
				this.columnGap = val;
			if ((val = incoming.paddingLeft) !== undefined)
				this.paddingLeft = val;
			if ((val = incoming.paddingTop) !== undefined)
				this.paddingTop = val;
			if ((val = incoming.paddingRight) !== undefined)
				this.paddingRight = val;
			if ((val = incoming.paddingBottom) !== undefined)
				this.paddingBottom = val;
			if ((val = incoming.columnCount) !== undefined)
				this.columnCount = val;
			if ((val = incoming.columnWidth) !== undefined)
				this.columnWidth = val;
			if ((val = incoming.firstBaselineOffset) !== undefined)
				this.firstBaselineOffset = val;
			if ((val = incoming.verticalAlign) !== undefined)
				this.verticalAlign = val;
			if ((val = incoming.blockProgression) !== undefined)
				this.blockProgression = val;
			if ((val = incoming.lineBreak) !== undefined)
				this.lineBreak = val;
		}

		/**
		 * TextLayoutFormat:
		 * Color of the text. A hexadecimal number that specifies three 8-bit RGB (red, green, blue) values; for example, 0xFF0000 is red and 0x00FF00 is green. 
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get color():*
		{ return getCoreStyle("color"); }
		public function set color(value:*):void
		{ setCoreStyle(TextLayoutFormat.colorProperty,color,value); }

		/**
		 * TextLayoutFormat:
		 * Background color of the text (adopts default value if undefined during cascade). Can be either the constant value  <code>BackgroundColor.TRANSPARENT</code>, or a hexadecimal value that specifies the three 8-bit RGB (red, green, blue) values; for example, 0xFF0000 is red and 0x00FF00 is green.
		 * <p>Legal values as a string are flashx.textLayout.formats.BackgroundColor.TRANSPARENT, flashx.textLayout.formats.FormatValue.INHERIT and uints from 0x0 to 0xffffffff.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of TRANSPARENT.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.BackgroundColor
		 */
		public function get backgroundColor():*
		{ return getCoreStyle("backgroundColor"); }
		public function set backgroundColor(value:*):void
		{ setCoreStyle(TextLayoutFormat.backgroundColorProperty,backgroundColor,value); }

		/**
		 * TextLayoutFormat:
		 * If <code>true</code>, applies strikethrough, a line drawn through the middle of the text.
		 * <p>Legal values are true, false and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of false.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get lineThrough():*
		{ return getCoreStyle("lineThrough"); }
		public function set lineThrough(value:*):void
		{ setCoreStyle(TextLayoutFormat.lineThroughProperty,lineThrough,value); }

		/**
		 * TextLayoutFormat:
		 * Alpha (transparency) value for the text. A value of 0 is fully transparent, and a value of 1 is fully opaque. Display objects with <code>textAlpha</code> set to 0 are active, even though they are invisible.
		 * <p>Legal values are numbers from 0 to 1 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 1.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get textAlpha():*
		{ return getCoreStyle("textAlpha"); }
		public function set textAlpha(value:*):void
		{ setCoreStyle(TextLayoutFormat.textAlphaProperty,textAlpha,value); }

		/**
		 * TextLayoutFormat:
		 * Alpha (transparency) value for the background (adopts default value if undefined during cascade). A value of 0 is fully transparent, and a value of 1 is fully opaque. Display objects with alpha set to 0 are active, even though they are invisible.
		 * <p>Legal values are numbers from 0 to 1 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of 1.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get backgroundAlpha():*
		{ return getCoreStyle("backgroundAlpha"); }
		public function set backgroundAlpha(value:*):void
		{ setCoreStyle(TextLayoutFormat.backgroundAlphaProperty,backgroundAlpha,value); }

		/**
		 * TextLayoutFormat:
		 * The size of the text in pixels.
		 * <p>Legal values are numbers from 1 to 720 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 12.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get fontSize():*
		{ return getCoreStyle("fontSize"); }
		public function set fontSize(value:*):void
		{ setCoreStyle(TextLayoutFormat.fontSizeProperty,fontSize,value); }

		/**
		 * TextLayoutFormat:
		 * Amount to shift the baseline from the <code>dominantBaseline</code> value. Units are in pixels, or a percentage of <code>fontSize</code> (in which case, enter a string value, like 140%).  Positive values shift the line up for horizontal text (right for vertical) and negative values shift it down for horizontal (left for vertical). 
		 * <p>Legal values are flashx.textLayout.formats.BaselineShift.SUPERSCRIPT, flashx.textLayout.formats.BaselineShift.SUBSCRIPT, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Legal values as a number are from -1000 to 1000.</p>
		 * <p>Legal values as a percent are numbers from -1000 to 1000.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 0.0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.BaselineShift
		 */
		public function get baselineShift():*
		{ return getCoreStyle("baselineShift"); }
		public function set baselineShift(value:*):void
		{ setCoreStyle(TextLayoutFormat.baselineShiftProperty,baselineShift,value); }

		/**
		 * TextLayoutFormat:
		 * Number in pixels (or percent of <code>fontSize</code>, like 120%) indicating the amount of tracking (manual kerning) to be applied to the left of each character. If kerning is enabled, the <code>trackingLeft</code> value is added to the values in the kerning table for the font. If kerning is disabled, the <code>trackingLeft</code> value is used as a manual kerning value. Supports both positive and negative values. 
		 * <p>Legal values as a number are from -1000 to 1000.</p>
		 * <p>Legal values as a percent are numbers from -1000% to 1000%.</p>
		 * <p>Legal values include flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get trackingLeft():*
		{ return getCoreStyle("trackingLeft"); }
		public function set trackingLeft(value:*):void
		{ setCoreStyle(TextLayoutFormat.trackingLeftProperty,trackingLeft,value); }

		/**
		 * TextLayoutFormat:
		 * Number in pixels (or percent of <code>fontSize</code>, like 120%) indicating the amount of tracking (manual kerning) to be applied to the right of each character.  If kerning is enabled, the <code>trackingRight</code> value is added to the values in the kerning table for the font. If kerning is disabled, the <code>trackingRight</code> value is used as a manual kerning value. Supports both positive and negative values. 
		 * <p>Legal values as a number are from -1000 to 1000.</p>
		 * <p>Legal values as a percent are numbers from -1000% to 1000%.</p>
		 * <p>Legal values include flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get trackingRight():*
		{ return getCoreStyle("trackingRight"); }
		public function set trackingRight(value:*):void
		{ setCoreStyle(TextLayoutFormat.trackingRightProperty,trackingRight,value); }

		/**
		 * TextLayoutFormat:
		 * Leading controls for the text. The distance from the baseline of the previous or the next line (based on <code>LeadingModel</code>) to the baseline of the current line is equal to the maximum amount of the leading applied to any character in the line. This is either a number or a percent.  If specifying a percent, enter a string value, like 140%.<p><img src='../../../images/textLayout_lineHeight1.jpg' alt='lineHeight1' /><img src='../../../images/textLayout_lineHeight2.jpg' alt='lineHeight2' /></p>
		 * <p>Legal values as a number are from -720 to 720.</p>
		 * <p>Legal values as a percent are numbers from -1000% to 1000%.</p>
		 * <p>Legal values include flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 120%.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get lineHeight():*
		{ return getCoreStyle("lineHeight"); }
		public function set lineHeight(value:*):void
		{ setCoreStyle(TextLayoutFormat.lineHeightProperty,lineHeight,value); }

		/**
		 * TextLayoutFormat:
		 * Controls where lines are allowed to break when breaking wrapping text into multiple lines. Set to <code>BreakOpportunity.AUTO</code> to break text normally. Set to <code>BreakOpportunity.NONE</code> to <em>not</em> break the text unless the text would overrun the measure and there are no other places to break the line. Set to <code>BreakOpportunity.ANY</code> to allow the line to break anywhere, rather than just between words. Set to <code>BreakOpportunity.ALL</code> to have each typographic cluster put on a separate line (useful for text on a path).
		 * <p>Legal values are flash.text.engine.BreakOpportunity.ALL, flash.text.engine.BreakOpportunity.ANY, flash.text.engine.BreakOpportunity.AUTO, flash.text.engine.BreakOpportunity.NONE, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of AUTO.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.BreakOpportunity
		 */
		public function get breakOpportunity():*
		{ return getCoreStyle("breakOpportunity"); }
		public function set breakOpportunity(value:*):void
		{ setCoreStyle(TextLayoutFormat.breakOpportunityProperty,breakOpportunity,value); }

		/**
		 * TextLayoutFormat:
		 * The type of digit case used for this text. Setting the value to <code>DigitCase.OLD_STYLE</code> approximates lowercase letterforms with varying ascenders and descenders. The figures are proportionally spaced. This style is only available in selected typefaces, most commonly in a supplemental or expert font. The <code>DigitCase.LINING</code> setting has all-cap height and is typically monospaced to line up in charts.<p><img src='../../../images/textLayout_digitcase.gif' alt='digitCase' /></p>
		 * <p>Legal values are flash.text.engine.DigitCase.DEFAULT, flash.text.engine.DigitCase.LINING, flash.text.engine.DigitCase.OLD_STYLE, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of DEFAULT.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.DigitCase
		 */
		public function get digitCase():*
		{ return getCoreStyle("digitCase"); }
		public function set digitCase(value:*):void
		{ setCoreStyle(TextLayoutFormat.digitCaseProperty,digitCase,value); }

		/**
		 * TextLayoutFormat:
		 * Type of digit width used for this text. This can be <code>DigitWidth.PROPORTIONAL</code>, which looks best for individual numbers, or <code>DigitWidth.TABULAR</code>, which works best for numbers in tables, charts, and vertical rows.<p><img src='../../../images/textLayout_digitwidth.gif' alt='digitWidth' /></p>
		 * <p>Legal values are flash.text.engine.DigitWidth.DEFAULT, flash.text.engine.DigitWidth.PROPORTIONAL, flash.text.engine.DigitWidth.TABULAR, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of DEFAULT.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.DigitWidth
		 */
		public function get digitWidth():*
		{ return getCoreStyle("digitWidth"); }
		public function set digitWidth(value:*):void
		{ setCoreStyle(TextLayoutFormat.digitWidthProperty,digitWidth,value); }

		/**
		 * TextLayoutFormat:
		 * Specifies which element baseline snaps to the <code>alignmentBaseline</code> to determine the vertical position of the element on the line. A value of <code>TextBaseline.AUTO</code> selects the dominant baseline based on the <code>locale</code> property of the parent paragraph.  For Japanese and Chinese, the selected baseline value is <code>TextBaseline.IDEOGRAPHIC_CENTER</code>; for all others it is <code>TextBaseline.ROMAN</code>. These baseline choices are determined by the choice of font and the font size.<p><img src='../../../images/textLayout_baselines.jpg' alt='baselines' /></p>
		 * <p>Legal values are flashx.textLayout.formats.FormatValue.AUTO, flash.text.engine.TextBaseline.ROMAN, flash.text.engine.TextBaseline.ASCENT, flash.text.engine.TextBaseline.DESCENT, flash.text.engine.TextBaseline.IDEOGRAPHIC_TOP, flash.text.engine.TextBaseline.IDEOGRAPHIC_CENTER, flash.text.engine.TextBaseline.IDEOGRAPHIC_BOTTOM, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of flashx.textLayout.formats.FormatValue.AUTO.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.TextBaseline
		 */
		public function get dominantBaseline():*
		{ return getCoreStyle("dominantBaseline"); }
		public function set dominantBaseline(value:*):void
		{ setCoreStyle(TextLayoutFormat.dominantBaselineProperty,dominantBaseline,value); }

		/**
		 * TextLayoutFormat:
		 * Kerning adjusts the pixels between certain character pairs to improve readability. Kerning is supported for all fonts with kerning tables.
		 * <p>Legal values are flash.text.engine.Kerning.ON, flash.text.engine.Kerning.OFF, flash.text.engine.Kerning.AUTO, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of AUTO.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.Kerning
		 */
		public function get kerning():*
		{ return getCoreStyle("kerning"); }
		public function set kerning(value:*):void
		{ setCoreStyle(TextLayoutFormat.kerningProperty,kerning,value); }

		/**
		 * TextLayoutFormat:
		 * Controls which of the ligatures that are defined in the font may be used in the text. The ligatures that appear for each of these settings is dependent on the font. A ligature occurs where two or more letter-forms are joined as a single glyph. Ligatures usually replace consecutive characters sharing common components, such as the letter pairs 'fi', 'fl', or 'ae'. They are used with both Latin and Non-Latin character sets. The ligatures enabled by the values of the LigatureLevel class - <code>MINIMUM</code>, <code>COMMON</code>, <code>UNCOMMON</code>, and <code>EXOTIC</code> - are additive. Each value enables a new set of ligatures, but also includes those of the previous types.<p><b>Note: </b>When working with Arabic or Syriac fonts, <code>ligatureLevel</code> must be set to MINIMUM or above.</p><p><img src='../../../images/textLayout_ligatures.png' alt='ligatureLevel' /></p>
		 * <p>Legal values are flash.text.engine.LigatureLevel.MINIMUM, flash.text.engine.LigatureLevel.COMMON, flash.text.engine.LigatureLevel.UNCOMMON, flash.text.engine.LigatureLevel.EXOTIC, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of COMMON.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.LigatureLevel
		 */
		public function get ligatureLevel():*
		{ return getCoreStyle("ligatureLevel"); }
		public function set ligatureLevel(value:*):void
		{ setCoreStyle(TextLayoutFormat.ligatureLevelProperty,ligatureLevel,value); }

		/**
		 * TextLayoutFormat:
		 * Specifies the baseline to which the dominant baseline aligns. For example, if you set <code>dominantBaseline</code> to ASCENT, setting <code>alignmentBaseline</code> to DESCENT aligns the top of the text with the DESCENT baseline, or below the line.  The largest element in the line generally determines the baselines.<p><img src='../../../images/textLayout_baselines.jpg' alt='baselines' /></p>
		 * <p>Legal values are flash.text.engine.TextBaseline.ROMAN, flash.text.engine.TextBaseline.ASCENT, flash.text.engine.TextBaseline.DESCENT, flash.text.engine.TextBaseline.IDEOGRAPHIC_TOP, flash.text.engine.TextBaseline.IDEOGRAPHIC_CENTER, flash.text.engine.TextBaseline.IDEOGRAPHIC_BOTTOM, flash.text.engine.TextBaseline.USE_DOMINANT_BASELINE, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of USE_DOMINANT_BASELINE.</p>
		 * @includeExample examples\TextLayoutFormat_alignmentBaselineExample.as -noswf
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.TextBaseline
		 */
		public function get alignmentBaseline():*
		{ return getCoreStyle("alignmentBaseline"); }
		public function set alignmentBaseline(value:*):void
		{ setCoreStyle(TextLayoutFormat.alignmentBaselineProperty,alignmentBaseline,value); }

		/**
		 * TextLayoutFormat:
		 * The locale of the text. Controls case transformations and shaping. Standard locale identifiers as described in Unicode Technical Standard #35 are used. For example en, en_US and en-US are all English, ja is Japanese. 
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of en.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get locale():*
		{ return getCoreStyle("locale"); }
		public function set locale(value:*):void
		{ setCoreStyle(TextLayoutFormat.localeProperty,locale,value); }

		/**
		 * TextLayoutFormat:
		 * The type of typographic case used for this text. Here are some examples:<p><img src='../../../images/textLayout_typographiccase.png' alt='typographicCase' /></p>
		 * <p>Legal values are flashx.textLayout.formats.TLFTypographicCase.DEFAULT, flashx.textLayout.formats.TLFTypographicCase.CAPS_TO_SMALL_CAPS, flashx.textLayout.formats.TLFTypographicCase.UPPERCASE, flashx.textLayout.formats.TLFTypographicCase.LOWERCASE, flashx.textLayout.formats.TLFTypographicCase.LOWERCASE_TO_SMALL_CAPS, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of DEFAULT.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.TLFTypographicCase
		 */
		public function get typographicCase():*
		{ return getCoreStyle("typographicCase"); }
		public function set typographicCase(value:*):void
		{ setCoreStyle(TextLayoutFormat.typographicCaseProperty,typographicCase,value); }

		/**
		 * TextLayoutFormat:
		 *  The name of the font to use, or a comma-separated list of font names. The Flash runtime renders the element with the first available font in the list. For example Arial, Helvetica, _sans causes the player to search for Arial, then Helvetica if Arial is not found, then _sans if neither is found.
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of Arial.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get fontFamily():*
		{ return getCoreStyle("fontFamily"); }
		public function set fontFamily(value:*):void
		{ setCoreStyle(TextLayoutFormat.fontFamilyProperty,fontFamily,value); }

		/**
		 * TextLayoutFormat:
		 * Decoration on text. Use to apply underlining; default is none.
		 * <p>Legal values are flashx.textLayout.formats.TextDecoration.NONE, flashx.textLayout.formats.TextDecoration.UNDERLINE, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of NONE.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.TextDecoration
		 */
		public function get textDecoration():*
		{ return getCoreStyle("textDecoration"); }
		public function set textDecoration(value:*):void
		{ setCoreStyle(TextLayoutFormat.textDecorationProperty,textDecoration,value); }

		/**
		 * TextLayoutFormat:
		 * Weight of text. May be <code>FontWeight.NORMAL</code> for use in plain text, or <code>FontWeight.BOLD</code>. Applies only to device fonts (<code>fontLookup</code> property is set to flash.text.engine.FontLookup.DEVICE).
		 * <p>Legal values are flash.text.engine.FontWeight.NORMAL, flash.text.engine.FontWeight.BOLD, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of NORMAL.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.FontWeight
		 */
		public function get fontWeight():*
		{ return getCoreStyle("fontWeight"); }
		public function set fontWeight(value:*):void
		{ setCoreStyle(TextLayoutFormat.fontWeightProperty,fontWeight,value); }

		/**
		 * TextLayoutFormat:
		 * Style of text. May be <code>FontPosture.NORMAL</code>, for use in plain text, or <code>FontPosture.ITALIC</code> for italic. This property applies only to device fonts (<code>fontLookup</code> property is set to flash.text.engine.FontLookup.DEVICE).
		 * <p>Legal values are flash.text.engine.FontPosture.NORMAL, flash.text.engine.FontPosture.ITALIC, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of NORMAL.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.FontPosture
		 */
		public function get fontStyle():*
		{ return getCoreStyle("fontStyle"); }
		public function set fontStyle(value:*):void
		{ setCoreStyle(TextLayoutFormat.fontStyleProperty,fontStyle,value); }

		/**
		 * TextLayoutFormat:
		 * Collapses or preserves whitespace when importing text into a TextFlow. <code>WhiteSpaceCollapse.PRESERVE</code> retains all whitespace characters. <code>WhiteSpaceCollapse.COLLAPSE</code> removes newlines, tabs, and leading or trailing spaces within a block of imported text. Line break tags (<br/>) and Unicode line separator characters are retained.
		 * <p>Legal values are flashx.textLayout.formats.WhiteSpaceCollapse.PRESERVE, flashx.textLayout.formats.WhiteSpaceCollapse.COLLAPSE, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of COLLAPSE.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.WhiteSpaceCollapse
		 */
		public function get whiteSpaceCollapse():*
		{ return getCoreStyle("whiteSpaceCollapse"); }
		public function set whiteSpaceCollapse(value:*):void
		{ setCoreStyle(TextLayoutFormat.whiteSpaceCollapseProperty,whiteSpaceCollapse,value); }

		/**
		 * TextLayoutFormat:
		 * The rendering mode used for this text.  Applies only to embedded fonts (<code>fontLookup</code> property is set to <code>FontLookup.EMBEDDED_CFF</code>).
		 * <p>Legal values are flash.text.engine.RenderingMode.NORMAL, flash.text.engine.RenderingMode.CFF, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of CFF.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.RenderingMode
		 */
		public function get renderingMode():*
		{ return getCoreStyle("renderingMode"); }
		public function set renderingMode(value:*):void
		{ setCoreStyle(TextLayoutFormat.renderingModeProperty,renderingMode,value); }

		/**
		 * TextLayoutFormat:
		 * The type of CFF hinting used for this text. CFF hinting determines whether the Flash runtime forces strong horizontal stems to fit to a sub pixel grid or not. This property applies only if the <code>renderingMode</code> property is set to <code>RenderingMode.CFF</code>, and the font is embedded (<code>fontLookup</code> property is set to <code>FontLookup.EMBEDDED_CFF</code>). At small screen sizes, hinting produces a clear, legible text for human readers.
		 * <p>Legal values are flash.text.engine.CFFHinting.NONE, flash.text.engine.CFFHinting.HORIZONTAL_STEM, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of HORIZONTAL_STEM.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.CFFHinting
		 */
		public function get cffHinting():*
		{ return getCoreStyle("cffHinting"); }
		public function set cffHinting(value:*):void
		{ setCoreStyle(TextLayoutFormat.cffHintingProperty,cffHinting,value); }

		/**
		 * TextLayoutFormat:
		 * Font lookup to use. Specifying <code>FontLookup.DEVICE</code> uses the fonts installed on the system that is running the SWF file. Device fonts result in a smaller movie size, but text is not always rendered the same across different systems and platforms. Specifying <code>FontLookup.EMBEDDED_CFF</code> uses font outlines embedded in the published SWF file. Embedded fonts increase the size of the SWF file (sometimes dramatically), but text is consistently displayed in the chosen font.
		 * <p>Legal values are flash.text.engine.FontLookup.DEVICE, flash.text.engine.FontLookup.EMBEDDED_CFF, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of DEVICE.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.FontLookup
		 */
		public function get fontLookup():*
		{ return getCoreStyle("fontLookup"); }
		public function set fontLookup(value:*):void
		{ setCoreStyle(TextLayoutFormat.fontLookupProperty,fontLookup,value); }

		/**
		 * TextLayoutFormat:
		 * Determines the number of degrees to rotate this text.
		 * <p>Legal values are flash.text.engine.TextRotation.ROTATE_0, flash.text.engine.TextRotation.ROTATE_180, flash.text.engine.TextRotation.ROTATE_270, flash.text.engine.TextRotation.ROTATE_90, flash.text.engine.TextRotation.AUTO, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of AUTO.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.TextRotation
		 */
		public function get textRotation():*
		{ return getCoreStyle("textRotation"); }
		public function set textRotation(value:*):void
		{ setCoreStyle(TextLayoutFormat.textRotationProperty,textRotation,value); }

		/**
		 * TextLayoutFormat:
		 * A Number that specifies, in pixels, the amount to indent the first line of the paragraph.
		 * A negative indent will push the line into the margin, and possibly out of the container.
		 * <p>Legal values are numbers from -1000 to 1000 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get textIndent():*
		{ return getCoreStyle("textIndent"); }
		public function set textIndent(value:*):void
		{ setCoreStyle(TextLayoutFormat.textIndentProperty,textIndent,value); }

		/**
		 * TextLayoutFormat:
		 * A Number that specifies, in pixels, the amount to indent the paragraph's start edge. Refers to the left edge in left-to-right text and the right edge in right-to-left text. 
		 * <p>Legal values are numbers from 0 to 1000 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get paragraphStartIndent():*
		{ return getCoreStyle("paragraphStartIndent"); }
		public function set paragraphStartIndent(value:*):void
		{ setCoreStyle(TextLayoutFormat.paragraphStartIndentProperty,paragraphStartIndent,value); }

		/**
		 * TextLayoutFormat:
		 * A Number that specifies, in pixels, the amount to indent the paragraph's end edge. Refers to the right edge in left-to-right text and the left edge in right-to-left text. 
		 * <p>Legal values are numbers from 0 to 1000 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get paragraphEndIndent():*
		{ return getCoreStyle("paragraphEndIndent"); }
		public function set paragraphEndIndent(value:*):void
		{ setCoreStyle(TextLayoutFormat.paragraphEndIndentProperty,paragraphEndIndent,value); }

		/**
		 * TextLayoutFormat:
		 * A Number that specifies the amount of space, in pixels, to leave before the paragraph. 
		 * Collapses in tandem with <code>paragraphSpaceAfter</code>.
		 * <p>Legal values are numbers from 0 to 1000 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get paragraphSpaceBefore():*
		{ return getCoreStyle("paragraphSpaceBefore"); }
		public function set paragraphSpaceBefore(value:*):void
		{ setCoreStyle(TextLayoutFormat.paragraphSpaceBeforeProperty,paragraphSpaceBefore,value); }

		/**
		 * TextLayoutFormat:
		 * A Number that specifies the amount of space, in pixels, to leave after the paragraph.
		 * Collapses in tandem with  <code>paragraphSpaceBefore</code>.
		 * <p>Legal values are numbers from 0 to 1000 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get paragraphSpaceAfter():*
		{ return getCoreStyle("paragraphSpaceAfter"); }
		public function set paragraphSpaceAfter(value:*):void
		{ setCoreStyle(TextLayoutFormat.paragraphSpaceAfterProperty,paragraphSpaceAfter,value); }

		/**
		 * TextLayoutFormat:
		 * Alignment of lines in the paragraph relative to the container.
		 * <code>TextAlign.LEFT</code> aligns lines along the left edge of the container. <code>TextAlign.RIGHT</code> aligns on the right edge. <code>TextAlign.CENTER</code> positions the line equidistant from the left and right edges. <code>TextAlign.JUSTIFY</code> spreads the lines out so they fill the space. <code>TextAlign.START</code> is equivalent to setting left in left-to-right text, or right in right-to-left text. <code>TextAlign.END</code> is equivalent to setting right in left-to-right text, or left in right-to-left text.
		 * <p>Legal values are flashx.textLayout.formats.TextAlign.LEFT, flashx.textLayout.formats.TextAlign.RIGHT, flashx.textLayout.formats.TextAlign.CENTER, flashx.textLayout.formats.TextAlign.JUSTIFY, flashx.textLayout.formats.TextAlign.START, flashx.textLayout.formats.TextAlign.END, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of START.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.TextAlign
		 */
		public function get textAlign():*
		{ return getCoreStyle("textAlign"); }
		public function set textAlign(value:*):void
		{ setCoreStyle(TextLayoutFormat.textAlignProperty,textAlign,value); }

		/**
		 * TextLayoutFormat:
		 * Alignment of the last (or only) line in the paragraph relative to the container in justified text.
		 * If <code>textAlign</code> is set to <code>TextAlign.JUSTIFY</code>, <code>textAlignLast</code> specifies how the last line (or only line, if this is a one line block) is aligned. Values are similar to <code>textAlign</code>.
		 * <p>Legal values are flashx.textLayout.formats.TextAlign.LEFT, flashx.textLayout.formats.TextAlign.RIGHT, flashx.textLayout.formats.TextAlign.CENTER, flashx.textLayout.formats.TextAlign.JUSTIFY, flashx.textLayout.formats.TextAlign.START, flashx.textLayout.formats.TextAlign.END, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of START.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.TextAlign
		 */
		public function get textAlignLast():*
		{ return getCoreStyle("textAlignLast"); }
		public function set textAlignLast(value:*):void
		{ setCoreStyle(TextLayoutFormat.textAlignLastProperty,textAlignLast,value); }

		/**
		 * TextLayoutFormat:
		 * Specifies options for justifying text.
		 * Default value is <code>TextJustify.INTER_WORD</code>, meaning that extra space is added to the space characters. <code>TextJustify.DISTRIBUTE</code> adds extra space to space characters and between individual letters. Used only in conjunction with a <code>justificationRule</code> value of <code>JustificationRule.SPACE</code>.
		 * <p>Legal values are flashx.textLayout.formats.TextJustify.INTER_WORD, flashx.textLayout.formats.TextJustify.DISTRIBUTE, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of INTER_WORD.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.TextJustify
		 */
		public function get textJustify():*
		{ return getCoreStyle("textJustify"); }
		public function set textJustify(value:*):void
		{ setCoreStyle(TextLayoutFormat.textJustifyProperty,textJustify,value); }

		/**
		 * TextLayoutFormat:
		 * Rule used to justify text in a paragraph.
		 * Default value is <code>FormatValue.AUTO</code>, which justifies text based on the paragraph's <code>locale</code> property. For all languages except Japanese and Chinese, <code>FormatValue.AUTO</code> becomes <code>JustificationRule.SPACE</code>, which adds extra space to the space characters.  For Japanese and Chinese, <code>FormatValue.AUTO</code> becomes <code>JustficationRule.EAST_ASIAN</code>. In part, justification changes the spacing of punctuation. In Roman text the comma and Japanese periods take a full character's width but in East Asian text only half of a character's width. Also, in the East Asian text the spacing between sequential punctuation marks becomes tighter, obeying traditional East Asian typographic conventions. Note, too, in the example below the leading that is applied to the second line of the paragraphs. In the East Asian version, the last two lines push left. In the Roman version, the second and following lines push left.<p><img src='../../../images/textLayout_justificationrule.png' alt='justificationRule' /></p>
		 * <p>Legal values are flashx.textLayout.formats.JustificationRule.EAST_ASIAN, flashx.textLayout.formats.JustificationRule.SPACE, flashx.textLayout.formats.FormatValue.AUTO, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of flashx.textLayout.formats.FormatValue.AUTO.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.JustificationRule
		 */
		public function get justificationRule():*
		{ return getCoreStyle("justificationRule"); }
		public function set justificationRule(value:*):void
		{ setCoreStyle(TextLayoutFormat.justificationRuleProperty,justificationRule,value); }

		/**
		 * TextLayoutFormat:
		 * The style used for justification of the paragraph. Used only in conjunction with a <code>justificationRule</code> setting of <code>JustificationRule.EAST_ASIAN</code>.
		 * Default value of <code>FormatValue.AUTO</code> is resolved to <code>JustificationStyle.PUSH_IN_KINSOKU</code> for all locales.  The constants defined by the JustificationStyle class specify options for handling kinsoku characters, which are Japanese characters that cannot appear at either the beginning or end of a line. If you want looser text, specify <code>JustificationStyle.PUSH-OUT-ONLY</code>. If you want behavior that is like what you get with the  <code>justificationRule</code> of <code>JustificationRule.SPACE</code>, use <code>JustificationStyle.PRIORITIZE-LEAST-ADJUSTMENT</code>.
		 * <p>Legal values are flash.text.engine.JustificationStyle.PRIORITIZE_LEAST_ADJUSTMENT, flash.text.engine.JustificationStyle.PUSH_IN_KINSOKU, flash.text.engine.JustificationStyle.PUSH_OUT_ONLY, flashx.textLayout.formats.FormatValue.AUTO, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of flashx.textLayout.formats.FormatValue.AUTO.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.JustificationStyle
		 */
		public function get justificationStyle():*
		{ return getCoreStyle("justificationStyle"); }
		public function set justificationStyle(value:*):void
		{ setCoreStyle(TextLayoutFormat.justificationStyleProperty,justificationStyle,value); }

		/**
		 * TextLayoutFormat:
		 * Specifies the default bidirectional embedding level of the text in the text block. 
		 * Left-to-right reading order, as in Latin-style scripts, or right-to-left reading order, as in Arabic or Hebrew. This property also affects column direction when it is applied at the container level. Columns can be either left-to-right or right-to-left, just like text. Below are some examples:<p><img src='../../../images/textLayout_direction.gif' alt='direction' /></p>
		 * <p>Legal values are flashx.textLayout.formats.Direction.LTR, flashx.textLayout.formats.Direction.RTL, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of LTR.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.Direction
		 */
		public function get direction():*
		{ return getCoreStyle("direction"); }
		public function set direction(value:*):void
		{ setCoreStyle(TextLayoutFormat.directionProperty,direction,value); }

		/**
		 * TextLayoutFormat:
		 * Specifies the tab stops associated with the paragraph.
		 * Setters can take an array of flashx.textLayout.formats.TabStopFormat, a condensed string representation, undefined, or <code>FormatValue.INHERIT</code>. The condensed string representation is always converted into an array of flashx.textLayout.formats.TabStopFormat. <p>The string-based format is a list of tab stops, where each tab stop is delimited by one or more spaces.</p><p>A tab stop takes the following form: &lt;alignment type&gt;&lt;alignment position&gt;|&lt;alignment token&gt;.</p><p>The alignment type is a single character, and can be S, E, C, or D (or lower-case equivalents). S or s for start, E or e for end, C or c for center, D or d for decimal. The alignment type is optional, and if its not specified will default to S.</p><p>The alignment position is a Number, and is specified according to FXG spec for Numbers (decimal or scientific notation). The alignment position is required.</p><p>The vertical bar is used to separate the alignment position from the alignment token, and should only be present if the alignment token is present.</p><p> The alignment token is optional if the alignment type is D, and should not be present if the alignment type is anything other than D. The alignment token may be any sequence of characters terminated by the space that ends the tab stop (for the last tab stop, the terminating space is optional; end of alignment token is implied). A space may be part of the alignment token if it is escaped with a backslash (\ ). A backslash may be part of the alignment token if it is escaped with another backslash (\\). If the alignment type is D, and the alignment token is not specified, it will take on the default value of null.</p><p>If no tab stops are specified, a tab action defaults to the end of the line.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of null.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get tabStops():*
		{ return getCoreStyle("tabStops"); }
		public function set tabStops(value:*):void
		{ setCoreStyle(TextLayoutFormat.tabStopsProperty,tabStops,value); }

		/**
		 * TextLayoutFormat:
		 * Specifies the leading model, which is a combination of leading basis and leading direction.
		 * Leading basis is the baseline to which the <code>lineHeight</code> property refers. Leading direction determines whether the <code>lineHeight</code> property refers to the distance of a line's baseline from that of the line before it or the line after it. The default value of <code>FormatValue.AUTO</code> is resolved based on the paragraph's <code>locale</code> property.  For Japanese and Chinese, it is <code>LeadingModel.IDEOGRAPHIC_TOP_DOWN</code> and for all others it is <code>LeadingModel.ROMAN_UP</code>.<p><strong>Leading Basis:</strong></p><p><img src='../../../images/textLayout_LB1.png' alt='leadingBasis1' />    <img src='../../../images/textLayout_LB2.png' alt='leadingBasis2' />    <img src='../../../images/textLayout_LB3.png' alt='leadingBasis3' /></p><p><strong>Leading Direction:</strong></p><p><img src='../../../images/textLayout_LD1.png' alt='leadingDirection1' />    <img src='../../../images/textLayout_LD2.png' alt='leadingDirection2' />    <img src='../../../images/textLayout_LD3.png' alt='leadingDirection3' /></p>
		 * <p>Legal values are flashx.textLayout.formats.LeadingModel.ROMAN_UP, flashx.textLayout.formats.LeadingModel.IDEOGRAPHIC_TOP_UP, flashx.textLayout.formats.LeadingModel.IDEOGRAPHIC_CENTER_UP, flashx.textLayout.formats.LeadingModel.IDEOGRAPHIC_TOP_DOWN, flashx.textLayout.formats.LeadingModel.IDEOGRAPHIC_CENTER_DOWN, flashx.textLayout.formats.LeadingModel.APPROXIMATE_TEXT_FIELD, flashx.textLayout.formats.LeadingModel.ASCENT_DESCENT_UP, flashx.textLayout.formats.LeadingModel.AUTO, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of AUTO.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.LeadingModel
		 */
		public function get leadingModel():*
		{ return getCoreStyle("leadingModel"); }
		public function set leadingModel(value:*):void
		{ setCoreStyle(TextLayoutFormat.leadingModelProperty,leadingModel,value); }

		/**
		 * TextLayoutFormat:
		 * Specifies the amount of gutter space, in pixels, to leave between the columns (adopts default value if undefined during cascade).
		 * Value is a Number
		 * <p>Legal values are numbers from 0 to 1000 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of 20.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get columnGap():*
		{ return getCoreStyle("columnGap"); }
		public function set columnGap(value:*):void
		{ setCoreStyle(TextLayoutFormat.columnGapProperty,columnGap,value); }

		/**
		 * TextLayoutFormat:
		 * Left inset in pixels (adopts default value if undefined during cascade).
		 * Space between the left edge of the container and the text.  Value is a Number.<p> With vertical text, in scrollable containers with multiple columns, the first and following columns will show the padding as blank space at the end of the container, but for the last column, if the text doesn't all fit, you may have to scroll in order to see the padding.</p>
		 * <p>Legal values are numbers from 0 to 1000 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get paddingLeft():*
		{ return getCoreStyle("paddingLeft"); }
		public function set paddingLeft(value:*):void
		{ setCoreStyle(TextLayoutFormat.paddingLeftProperty,paddingLeft,value); }

		/**
		 * TextLayoutFormat:
		 * Top inset in pixels (adopts default value if undefined during cascade).
		 * Space between the top edge of the container and the text.  Value is a Number.
		 * <p>Legal values are numbers from 0 to 1000 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get paddingTop():*
		{ return getCoreStyle("paddingTop"); }
		public function set paddingTop(value:*):void
		{ setCoreStyle(TextLayoutFormat.paddingTopProperty,paddingTop,value); }

		/**
		 * TextLayoutFormat:
		 * Right inset in pixels (adopts default value if undefined during cascade).
		 * Space between the right edge of the container and the text.  Value is a Number.
		 * <p>Legal values are numbers from 0 to 1000 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get paddingRight():*
		{ return getCoreStyle("paddingRight"); }
		public function set paddingRight(value:*):void
		{ setCoreStyle(TextLayoutFormat.paddingRightProperty,paddingRight,value); }

		/**
		 * TextLayoutFormat:
		 * Botttom inset in pixels (adopts default value if undefined during cascade).
		 * Space between the bottom edge of the container and the text.  Value is a Number. <p> With horizontal text, in scrollable containers with multiple columns, the first and following columns will show the padding as blank space at the bottom of the container, but for the last column, if the text doesn't all fit, you may have to scroll in order to see the padding.</p>
		 * <p>Legal values are numbers from 0 to 1000 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of 0.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get paddingBottom():*
		{ return getCoreStyle("paddingBottom"); }
		public function set paddingBottom(value:*):void
		{ setCoreStyle(TextLayoutFormat.paddingBottomProperty,paddingBottom,value); }

		/**
		 * TextLayoutFormat:
		 * Number of text columns (adopts default value if undefined during cascade).
		 * The column number overrides the  other column settings. Value is an integer, or <code>FormatValue.AUTO</code> if unspecified. If <code>columnCount</code> is not specified,<code>columnWidth</code> is used to create as many columns as can fit in the container.
		 * <p>Legal values as a string are flashx.textLayout.formats.FormatValue.AUTO, flashx.textLayout.formats.FormatValue.INHERIT and from ints from 1 to 50.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of AUTO.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.FormatValue
		 */
		public function get columnCount():*
		{ return getCoreStyle("columnCount"); }
		public function set columnCount(value:*):void
		{ setCoreStyle(TextLayoutFormat.columnCountProperty,columnCount,value); }

		/**
		 * TextLayoutFormat:
		 * Column width in pixels (adopts default value if undefined during cascade).
		 * If you specify the width of the columns, but not the count, TextLayout will create as many columns of that width as possible, given the  container width and <code>columnGap</code> settings. Any remainder space is left after the last column. Value is a Number.
		 * <p>Legal values as a string are flashx.textLayout.formats.FormatValue.AUTO, flashx.textLayout.formats.FormatValue.INHERIT and numbers from 0 to 8000.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of AUTO.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.FormatValue
		 */
		public function get columnWidth():*
		{ return getCoreStyle("columnWidth"); }
		public function set columnWidth(value:*):void
		{ setCoreStyle(TextLayoutFormat.columnWidthProperty,columnWidth,value); }

		/**
		 * TextLayoutFormat:
		 * Specifies the baseline position of the first line in the container. Which baseline this property refers to depends on the container-level locale.  For Japanese and Chinese, it is <code>TextBaseline.IDEOGRAPHIC_BOTTOM</code>; for all others it is <code>TextBaseline.ROMAN</code>.
		 * The offset from the top inset (or right inset if <code>blockProgression</code> is RL) of the container to the baseline of the first line can be either <code>BaselineOffset.ASCENT</code>, meaning equal to the ascent of the line, <code>BaselineOffset.LINE_HEIGHT</code>, meaning equal to the height of that first line, or any fixed-value number to specify an absolute distance. <code>BaselineOffset.AUTO</code> aligns the ascent of the line with the container top inset.<p><img src='../../../images/textLayout_FBO1.png' alt='firstBaselineOffset1' /><img src='../../../images/textLayout_FBO2.png' alt='firstBaselineOffset2' /><img src='../../../images/textLayout_FBO3.png' alt='firstBaselineOffset3' /><img src='../../../images/textLayout_FBO4.png' alt='firstBaselineOffset4' /></p>
		 * <p>Legal values as a string are flashx.textLayout.formats.BaselineOffset.AUTO, flashx.textLayout.formats.BaselineOffset.ASCENT, flashx.textLayout.formats.BaselineOffset.LINE_HEIGHT, flashx.textLayout.formats.FormatValue.INHERIT and numbers from 0 to 1000.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of AUTO.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.BaselineOffset
		 */
		public function get firstBaselineOffset():*
		{ return getCoreStyle("firstBaselineOffset"); }
		public function set firstBaselineOffset(value:*):void
		{ setCoreStyle(TextLayoutFormat.firstBaselineOffsetProperty,firstBaselineOffset,value); }

		/**
		 * TextLayoutFormat:
		 * Vertical alignment or justification (adopts default value if undefined during cascade).
		 * Determines how TextFlow elements align within the container.
		 * <p>Legal values are flashx.textLayout.formats.VerticalAlign.TOP, flashx.textLayout.formats.VerticalAlign.MIDDLE, flashx.textLayout.formats.VerticalAlign.BOTTOM, flashx.textLayout.formats.VerticalAlign.JUSTIFY, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of TOP.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.VerticalAlign
		 */
		public function get verticalAlign():*
		{ return getCoreStyle("verticalAlign"); }
		public function set verticalAlign(value:*):void
		{ setCoreStyle(TextLayoutFormat.verticalAlignProperty,verticalAlign,value); }

		/**
		 * TextLayoutFormat:
		 * Specifies a vertical or horizontal progression of line placement.
		 * Lines are either placed top-to-bottom (<code>BlockProgression.TB</code>, used for horizontal text) or right-to-left (<code>BlockProgression.RL</code>, used for vertical text).
		 * <p>Legal values are flashx.textLayout.formats.BlockProgression.RL, flashx.textLayout.formats.BlockProgression.TB, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will inherit its value from an ancestor. If no ancestor has set this property, it will have a value of TB.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.BlockProgression
		 */
		public function get blockProgression():*
		{ return getCoreStyle("blockProgression"); }
		public function set blockProgression(value:*):void
		{ setCoreStyle(TextLayoutFormat.blockProgressionProperty,blockProgression,value); }

		/**
		 * TextLayoutFormat:
		 * Controls word wrapping within the container (adopts default value if undefined during cascade).
		 * Text in the container may be set to fit the width of the container (<code>LineBreak.TO_FIT</code>), or can be set to break only at explicit return or line feed characters (<code>LineBreak.EXPLICIT</code>).
		 * <p>Legal values are flashx.textLayout.formats.LineBreak.EXPLICIT, flashx.textLayout.formats.LineBreak.TO_FIT, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of TO_FIT.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flashx.textLayout.formats.LineBreak
		 */
		public function get lineBreak():*
		{ return getCoreStyle("lineBreak"); }
		public function set lineBreak(value:*):void
		{ setCoreStyle(TextLayoutFormat.lineBreakProperty,lineBreak,value); }
	}
}
