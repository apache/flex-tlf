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
	import flashx.textLayout.debug.Debugging
	import flashx.textLayout.debug.assert
	import flashx.textLayout.property.*
	import flashx.textLayout.tlf_internal
	use namespace tlf_internal
	import flashx.textLayout.formats.BackgroundColor
	import flash.text.engine.BreakOpportunity
	import flash.text.engine.DigitCase
	import flash.text.engine.DigitWidth
	import flash.text.engine.TextBaseline
	import flash.text.engine.Kerning
	import flash.text.engine.LigatureLevel
	import flash.text.engine.TextBaseline
	import flashx.textLayout.formats.TLFTypographicCase
	import flashx.textLayout.formats.TextDecoration
	import flash.text.engine.FontWeight
	import flash.text.engine.FontPosture
	import flashx.textLayout.formats.WhiteSpaceCollapse
	import flash.text.engine.RenderingMode
	import flash.text.engine.CFFHinting
	import flash.text.engine.FontLookup
	import flash.text.engine.TextRotation
	import flashx.textLayout.formats.TextAlign
	import flashx.textLayout.formats.TextAlign
	import flashx.textLayout.formats.TextJustify
	import flashx.textLayout.formats.JustificationRule
	import flash.text.engine.JustificationStyle
	import flashx.textLayout.formats.Direction
	import flashx.textLayout.formats.LeadingModel
	import flashx.textLayout.formats.FormatValue
	import flashx.textLayout.formats.FormatValue
	import flashx.textLayout.formats.BaselineOffset
	import flashx.textLayout.formats.VerticalAlign
	import flashx.textLayout.formats.BlockProgression
	import flashx.textLayout.formats.LineBreak
	/**
	 * The TextLayoutFormat class holds all of the text layout properties. These properties affect the format and style of a text flow at the container level, paragraph level, and text level.  Both the ContainerController class and the FlowElement base class have <code>format</code> properties that enable you to assign a TextLayoutFormat instance to them. Assign a TextLayoutFormat object to a container to affect the format of all of the container's content. Assign a TextLayoutFormat object to a FlowElement descendant to specify formatting for that particular element: TextFlow, ParagraphElement, DivElement, SpanElement, InlineGraphicElement, LinkElement, and TCYElement.
	 * In addition to the <code>format</code> property, these classes also define each of the individual TextLayoutFormat properties so that you can override the setting of a particular style property for that element, if you wish. <p>Because you can set a given style at multiple levels, it is possible to have conflicts. For example, the color of the text at the TextFlow level could be set to black while a SpanElement object sets it to blue. The general rule is that the setting at the lowest level on the text flow tree takes precedence. So if the ligature level is set for a TextFlow instance and also set for a DivElement, the DivElement setting takes precedence. </p><p>Cascading styles refers to the process of adopting styles from a higher level in the text flow if a style value is undefined at a lower level. When a style is undefined on an element at the point it is about to be rendered, it either takes its default value or the value cascades or descends from the value on a parent element. For example, if the transparency (<code>textAlpha</code> property) of the text is undefined on a SpanElement object, but is set on the TextFlow, the value of the <code>TextFlow.textAlpha</code> property cascades to the SpanElement object and is applied to the text for that span. The result of the cascade, or the sum of the styles that is applied to the element, is stored in the element's <code>computedFormat</code> property.</p><p>In the same way, you can apply user styles using the <code>userStyles</code> property of the ContainerController and FlowElement classes. This  property allows you to read or write a dictionary of user styles and apply its settings to a container or a text flow element. The user styles dictionary is an object that consists of <em>stylename-value</em> pairs. Styles specified by the <code>userStyles</code> property take precedence over all others.</p><p>Most styles that are undefined inherit the value of their immediate parent during a cascade. A small number of styles, however, do not inherit their parent's value and take on their default values instead.</p><p><strong>Style properties that adopt their default values, if undefined, include:</strong> <code>backgroundAlpha</code>, <code>backgroundColor</code>, <code>columnCount</code>, <code>columnGap</code>, <code>columnWidth</code>, <code>lineBreak</code>, <code>paddingBottom</code>, <code>paddingLeft</code>, <code>paddingRight</code>, <code>paddingTop</code>, <code>verticalAlign</code>.</p>
	 * @includeExample examples\TextLayoutFormatExample.as -noswf
	 * @includeExample examples\TextLayoutFormatExample2.as -noswf
	 * @see flashx.textLayout.elements.FlowElement#format
	 * @see flashx.textLayout.factory.TextFlowTextLineFactory
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5 
	 * @langversion 3.0 
	 */
	public class TextLayoutFormat implements ITextLayoutFormat
	{
		/** @private */
		static private var _colorProperty:UintProperty = new UintProperty("color",0,true,Category.CHARACTER);
		/** @private */
		static private var _backgroundColorProperty:UintWithEnumProperty = new UintWithEnumProperty(
			"backgroundColor",flashx.textLayout.formats.BackgroundColor.TRANSPARENT,false,Category.CHARACTER
			,flashx.textLayout.formats.BackgroundColor.TRANSPARENT
		);
		/** @private */
		static private var _lineThroughProperty:BooleanProperty = new BooleanProperty("lineThrough",false,true,Category.CHARACTER);
		/** @private */
		static private var _textAlphaProperty:NumberProperty = new NumberProperty("textAlpha",1,true,Category.CHARACTER,0,1); 		/** @private */
		static private var _backgroundAlphaProperty:NumberProperty = new NumberProperty("backgroundAlpha",1,false,Category.CHARACTER,0,1); 		/** @private */
		static private var _fontSizeProperty:NumberProperty = new NumberProperty("fontSize",12,true,Category.CHARACTER,1,720); 		/** @private */
		static private var _baselineShiftProperty:NumberOrPercentOrEnumProperty = new NumberOrPercentOrEnumProperty("baselineShift",0.0,true,Category.CHARACTER,-1000,1000,"-1000%","1000%"
			,flashx.textLayout.formats.BaselineShift.SUPERSCRIPT
			,flashx.textLayout.formats.BaselineShift.SUBSCRIPT
		);
		/** @private */
		static private var _trackingLeftProperty:NumberOrPercentProperty = new NumberOrPercentProperty("trackingLeft",0,true,Category.CHARACTER,-1000,1000,"-1000%","1000%")
		/** @private */
		static private var _trackingRightProperty:NumberOrPercentProperty = new NumberOrPercentProperty("trackingRight",0,true,Category.CHARACTER,-1000,1000,"-1000%","1000%")
		/** @private */
		static private var _lineHeightProperty:NumberOrPercentProperty = new NumberOrPercentProperty("lineHeight","120%",true,Category.CHARACTER,-720,720,"-1000%","1000%")
		/** @private */
		static private var _breakOpportunityProperty:EnumStringProperty = new EnumStringProperty(
			"breakOpportunity",flash.text.engine.BreakOpportunity.AUTO,true,Category.CHARACTER
			,flash.text.engine.BreakOpportunity.ALL
			,flash.text.engine.BreakOpportunity.ANY
			,flash.text.engine.BreakOpportunity.AUTO
			,flash.text.engine.BreakOpportunity.NONE
		);
		/** @private */
		static private var _digitCaseProperty:EnumStringProperty = new EnumStringProperty(
			"digitCase",flash.text.engine.DigitCase.DEFAULT,true,Category.CHARACTER
			,flash.text.engine.DigitCase.DEFAULT
			,flash.text.engine.DigitCase.LINING
			,flash.text.engine.DigitCase.OLD_STYLE
		);
		/** @private */
		static private var _digitWidthProperty:EnumStringProperty = new EnumStringProperty(
			"digitWidth",flash.text.engine.DigitWidth.DEFAULT,true,Category.CHARACTER
			,flash.text.engine.DigitWidth.DEFAULT
			,flash.text.engine.DigitWidth.PROPORTIONAL
			,flash.text.engine.DigitWidth.TABULAR
		);
		/** @private */
		static private var _dominantBaselineProperty:EnumStringProperty = new EnumStringProperty(
			"dominantBaseline",flashx.textLayout.formats.FormatValue.AUTO,true,Category.CHARACTER
			,flashx.textLayout.formats.FormatValue.AUTO
			,flash.text.engine.TextBaseline.ROMAN
			,flash.text.engine.TextBaseline.ASCENT
			,flash.text.engine.TextBaseline.DESCENT
			,flash.text.engine.TextBaseline.IDEOGRAPHIC_TOP
			,flash.text.engine.TextBaseline.IDEOGRAPHIC_CENTER
			,flash.text.engine.TextBaseline.IDEOGRAPHIC_BOTTOM
		);
		/** @private */
		static private var _kerningProperty:EnumStringProperty = new EnumStringProperty(
			"kerning",flash.text.engine.Kerning.AUTO,true,Category.CHARACTER
			,flash.text.engine.Kerning.ON
			,flash.text.engine.Kerning.OFF
			,flash.text.engine.Kerning.AUTO
		);
		/** @private */
		static private var _ligatureLevelProperty:EnumStringProperty = new EnumStringProperty(
			"ligatureLevel",flash.text.engine.LigatureLevel.COMMON,true,Category.CHARACTER
			,flash.text.engine.LigatureLevel.MINIMUM
			,flash.text.engine.LigatureLevel.COMMON
			,flash.text.engine.LigatureLevel.UNCOMMON
			,flash.text.engine.LigatureLevel.EXOTIC
		);
		/** @private */
		static private var _alignmentBaselineProperty:EnumStringProperty = new EnumStringProperty(
			"alignmentBaseline",flash.text.engine.TextBaseline.USE_DOMINANT_BASELINE,true,Category.CHARACTER
			,flash.text.engine.TextBaseline.ROMAN
			,flash.text.engine.TextBaseline.ASCENT
			,flash.text.engine.TextBaseline.DESCENT
			,flash.text.engine.TextBaseline.IDEOGRAPHIC_TOP
			,flash.text.engine.TextBaseline.IDEOGRAPHIC_CENTER
			,flash.text.engine.TextBaseline.IDEOGRAPHIC_BOTTOM
			,flash.text.engine.TextBaseline.USE_DOMINANT_BASELINE
		);
		/** @private */
		static private var _localeProperty:StringProperty = new StringProperty("locale","en",true,Category.CHARACTER);
		/** @private */
		static private var _typographicCaseProperty:EnumStringProperty = new EnumStringProperty(
			"typographicCase",flashx.textLayout.formats.TLFTypographicCase.DEFAULT,true,Category.CHARACTER
			,flashx.textLayout.formats.TLFTypographicCase.DEFAULT
			,flashx.textLayout.formats.TLFTypographicCase.CAPS_TO_SMALL_CAPS
			,flashx.textLayout.formats.TLFTypographicCase.UPPERCASE
			,flashx.textLayout.formats.TLFTypographicCase.LOWERCASE
			,flashx.textLayout.formats.TLFTypographicCase.LOWERCASE_TO_SMALL_CAPS
		);
		/** @private */
		static private var _fontFamilyProperty:StringProperty = new StringProperty("fontFamily","Arial",true,Category.CHARACTER);
		/** @private */
		static private var _textDecorationProperty:EnumStringProperty = new EnumStringProperty(
			"textDecoration",flashx.textLayout.formats.TextDecoration.NONE,true,Category.CHARACTER
			,flashx.textLayout.formats.TextDecoration.NONE
			,flashx.textLayout.formats.TextDecoration.UNDERLINE
		);
		/** @private */
		static private var _fontWeightProperty:EnumStringProperty = new EnumStringProperty(
			"fontWeight",flash.text.engine.FontWeight.NORMAL,true,Category.CHARACTER
			,flash.text.engine.FontWeight.NORMAL
			,flash.text.engine.FontWeight.BOLD
		);
		/** @private */
		static private var _fontStyleProperty:EnumStringProperty = new EnumStringProperty(
			"fontStyle",flash.text.engine.FontPosture.NORMAL,true,Category.CHARACTER
			,flash.text.engine.FontPosture.NORMAL
			,flash.text.engine.FontPosture.ITALIC
		);
		/** @private */
		static private var _whiteSpaceCollapseProperty:EnumStringProperty = new EnumStringProperty(
			"whiteSpaceCollapse",flashx.textLayout.formats.WhiteSpaceCollapse.COLLAPSE,true,Category.CHARACTER
			,flashx.textLayout.formats.WhiteSpaceCollapse.PRESERVE
			,flashx.textLayout.formats.WhiteSpaceCollapse.COLLAPSE
		);
		/** @private */
		static private var _renderingModeProperty:EnumStringProperty = new EnumStringProperty(
			"renderingMode",flash.text.engine.RenderingMode.CFF,true,Category.CHARACTER
			,flash.text.engine.RenderingMode.NORMAL
			,flash.text.engine.RenderingMode.CFF
		);
		/** @private */
		static private var _cffHintingProperty:EnumStringProperty = new EnumStringProperty(
			"cffHinting",flash.text.engine.CFFHinting.HORIZONTAL_STEM,true,Category.CHARACTER
			,flash.text.engine.CFFHinting.NONE
			,flash.text.engine.CFFHinting.HORIZONTAL_STEM
		);
		/** @private */
		static private var _fontLookupProperty:EnumStringProperty = new EnumStringProperty(
			"fontLookup",flash.text.engine.FontLookup.DEVICE,true,Category.CHARACTER
			,flash.text.engine.FontLookup.DEVICE
			,flash.text.engine.FontLookup.EMBEDDED_CFF
		);
		/** @private */
		static private var _textRotationProperty:EnumStringProperty = new EnumStringProperty(
			"textRotation",flash.text.engine.TextRotation.AUTO,true,Category.CHARACTER
			,flash.text.engine.TextRotation.ROTATE_0
			,flash.text.engine.TextRotation.ROTATE_180
			,flash.text.engine.TextRotation.ROTATE_270
			,flash.text.engine.TextRotation.ROTATE_90
			,flash.text.engine.TextRotation.AUTO
		);
		/** @private */
		static private var _textIndentProperty:NumberProperty = new NumberProperty("textIndent",0,true,Category.PARAGRAPH,-1000,1000); 		/** @private */
		static private var _paragraphStartIndentProperty:NumberProperty = new NumberProperty("paragraphStartIndent",0,true,Category.PARAGRAPH,0,1000); 		/** @private */
		static private var _paragraphEndIndentProperty:NumberProperty = new NumberProperty("paragraphEndIndent",0,true,Category.PARAGRAPH,0,1000); 		/** @private */
		static private var _paragraphSpaceBeforeProperty:NumberProperty = new NumberProperty("paragraphSpaceBefore",0,true,Category.PARAGRAPH,0,1000); 		/** @private */
		static private var _paragraphSpaceAfterProperty:NumberProperty = new NumberProperty("paragraphSpaceAfter",0,true,Category.PARAGRAPH,0,1000); 		/** @private */
		static private var _textAlignProperty:EnumStringProperty = new EnumStringProperty(
			"textAlign",flashx.textLayout.formats.TextAlign.START,true,Category.PARAGRAPH
			,flashx.textLayout.formats.TextAlign.LEFT
			,flashx.textLayout.formats.TextAlign.RIGHT
			,flashx.textLayout.formats.TextAlign.CENTER
			,flashx.textLayout.formats.TextAlign.JUSTIFY
			,flashx.textLayout.formats.TextAlign.START
			,flashx.textLayout.formats.TextAlign.END
		);
		/** @private */
		static private var _textAlignLastProperty:EnumStringProperty = new EnumStringProperty(
			"textAlignLast",flashx.textLayout.formats.TextAlign.START,true,Category.PARAGRAPH
			,flashx.textLayout.formats.TextAlign.LEFT
			,flashx.textLayout.formats.TextAlign.RIGHT
			,flashx.textLayout.formats.TextAlign.CENTER
			,flashx.textLayout.formats.TextAlign.JUSTIFY
			,flashx.textLayout.formats.TextAlign.START
			,flashx.textLayout.formats.TextAlign.END
		);
		/** @private */
		static private var _textJustifyProperty:EnumStringProperty = new EnumStringProperty(
			"textJustify",flashx.textLayout.formats.TextJustify.INTER_WORD,true,Category.PARAGRAPH
			,flashx.textLayout.formats.TextJustify.INTER_WORD
			,flashx.textLayout.formats.TextJustify.DISTRIBUTE
		);
		/** @private */
		static private var _justificationRuleProperty:EnumStringProperty = new EnumStringProperty(
			"justificationRule",flashx.textLayout.formats.FormatValue.AUTO,true,Category.PARAGRAPH
			,flashx.textLayout.formats.JustificationRule.EAST_ASIAN
			,flashx.textLayout.formats.JustificationRule.SPACE
			,flashx.textLayout.formats.FormatValue.AUTO
		);
		/** @private */
		static private var _justificationStyleProperty:EnumStringProperty = new EnumStringProperty(
			"justificationStyle",flashx.textLayout.formats.FormatValue.AUTO,true,Category.PARAGRAPH
			,flash.text.engine.JustificationStyle.PRIORITIZE_LEAST_ADJUSTMENT
			,flash.text.engine.JustificationStyle.PUSH_IN_KINSOKU
			,flash.text.engine.JustificationStyle.PUSH_OUT_ONLY
			,flashx.textLayout.formats.FormatValue.AUTO
		);
		/** @private */
		static private var _directionProperty:EnumStringProperty = new EnumStringProperty(
			"direction",flashx.textLayout.formats.Direction.LTR,true,Category.PARAGRAPH
			,flashx.textLayout.formats.Direction.LTR
			,flashx.textLayout.formats.Direction.RTL
		);
		/** @private */
		static private var _tabStopsProperty:TabStopsProperty = new TabStopsProperty("tabStops",null,true,Category.PARAGRAPH);
		/** @private */
		static private var _leadingModelProperty:EnumStringProperty = new EnumStringProperty(
			"leadingModel",flashx.textLayout.formats.LeadingModel.AUTO,true,Category.PARAGRAPH
			,flashx.textLayout.formats.LeadingModel.ROMAN_UP
			,flashx.textLayout.formats.LeadingModel.IDEOGRAPHIC_TOP_UP
			,flashx.textLayout.formats.LeadingModel.IDEOGRAPHIC_CENTER_UP
			,flashx.textLayout.formats.LeadingModel.IDEOGRAPHIC_TOP_DOWN
			,flashx.textLayout.formats.LeadingModel.IDEOGRAPHIC_CENTER_DOWN
			,flashx.textLayout.formats.LeadingModel.APPROXIMATE_TEXT_FIELD
			,flashx.textLayout.formats.LeadingModel.ASCENT_DESCENT_UP
			,flashx.textLayout.formats.LeadingModel.AUTO
		);
		/** @private */
		static private var _columnGapProperty:NumberProperty = new NumberProperty("columnGap",20,false,Category.CONTAINER,0,1000); 		/** @private */
		static private var _paddingLeftProperty:NumberProperty = new NumberProperty("paddingLeft",0,false,Category.CONTAINER,0,1000); 		/** @private */
		static private var _paddingTopProperty:NumberProperty = new NumberProperty("paddingTop",0,false,Category.CONTAINER,0,1000); 		/** @private */
		static private var _paddingRightProperty:NumberProperty = new NumberProperty("paddingRight",0,false,Category.CONTAINER,0,1000); 		/** @private */
		static private var _paddingBottomProperty:NumberProperty = new NumberProperty("paddingBottom",0,false,Category.CONTAINER,0,1000); 		/** @private */
		static private var _columnCountProperty:IntWithEnumProperty = new IntWithEnumProperty(
			"columnCount",flashx.textLayout.formats.FormatValue.AUTO,false,Category.CONTAINER,1,50
			,flashx.textLayout.formats.FormatValue.AUTO
		);
		/** @private */
		static private var _columnWidthProperty:NumberWithEnumProperty = new NumberWithEnumProperty(
			"columnWidth",flashx.textLayout.formats.FormatValue.AUTO,false,Category.CONTAINER,0,8000
			,flashx.textLayout.formats.FormatValue.AUTO
		);
		/** @private */
		static private var _firstBaselineOffsetProperty:NumberWithEnumProperty = new NumberWithEnumProperty(
			"firstBaselineOffset",flashx.textLayout.formats.BaselineOffset.AUTO,true,Category.CONTAINER,0,1000
			,flashx.textLayout.formats.BaselineOffset.AUTO
			,flashx.textLayout.formats.BaselineOffset.ASCENT
			,flashx.textLayout.formats.BaselineOffset.LINE_HEIGHT
		);
		/** @private */
		static private var _verticalAlignProperty:EnumStringProperty = new EnumStringProperty(
			"verticalAlign",flashx.textLayout.formats.VerticalAlign.TOP,false,Category.CONTAINER
			,flashx.textLayout.formats.VerticalAlign.TOP
			,flashx.textLayout.formats.VerticalAlign.MIDDLE
			,flashx.textLayout.formats.VerticalAlign.BOTTOM
			,flashx.textLayout.formats.VerticalAlign.JUSTIFY
		);
		/** @private */
		static private var _blockProgressionProperty:EnumStringProperty = new EnumStringProperty(
			"blockProgression",flashx.textLayout.formats.BlockProgression.TB,true,Category.CONTAINER
			,flashx.textLayout.formats.BlockProgression.RL
			,flashx.textLayout.formats.BlockProgression.TB
		);
		/** @private */
		static private var _lineBreakProperty:EnumStringProperty = new EnumStringProperty(
			"lineBreak",flashx.textLayout.formats.LineBreak.TO_FIT,false,Category.CONTAINER
			,flashx.textLayout.formats.LineBreak.EXPLICIT
			,flashx.textLayout.formats.LineBreak.TO_FIT
		);

		/** @private */
		static tlf_internal function get colorProperty():UintProperty
		{ return _colorProperty; }
		/** @private */
		static tlf_internal function get backgroundColorProperty():UintWithEnumProperty
		{ return _backgroundColorProperty; }
		/** @private */
		static tlf_internal function get lineThroughProperty():BooleanProperty
		{ return _lineThroughProperty; }
		/** @private */
		static tlf_internal function get textAlphaProperty():NumberProperty
		{ return _textAlphaProperty; }
		/** @private */
		static tlf_internal function get backgroundAlphaProperty():NumberProperty
		{ return _backgroundAlphaProperty; }
		/** @private */
		static tlf_internal function get fontSizeProperty():NumberProperty
		{ return _fontSizeProperty; }
		/** @private */
		static tlf_internal function get baselineShiftProperty():NumberOrPercentOrEnumProperty
		{ return _baselineShiftProperty; }
		/** @private */
		static tlf_internal function get trackingLeftProperty():NumberOrPercentProperty
		{ return _trackingLeftProperty; }
		/** @private */
		static tlf_internal function get trackingRightProperty():NumberOrPercentProperty
		{ return _trackingRightProperty; }
		/** @private */
		static tlf_internal function get lineHeightProperty():NumberOrPercentProperty
		{ return _lineHeightProperty; }
		/** @private */
		static tlf_internal function get breakOpportunityProperty():EnumStringProperty
		{ return _breakOpportunityProperty; }
		/** @private */
		static tlf_internal function get digitCaseProperty():EnumStringProperty
		{ return _digitCaseProperty; }
		/** @private */
		static tlf_internal function get digitWidthProperty():EnumStringProperty
		{ return _digitWidthProperty; }
		/** @private */
		static tlf_internal function get dominantBaselineProperty():EnumStringProperty
		{ return _dominantBaselineProperty; }
		/** @private */
		static tlf_internal function get kerningProperty():EnumStringProperty
		{ return _kerningProperty; }
		/** @private */
		static tlf_internal function get ligatureLevelProperty():EnumStringProperty
		{ return _ligatureLevelProperty; }
		/** @private */
		static tlf_internal function get alignmentBaselineProperty():EnumStringProperty
		{ return _alignmentBaselineProperty; }
		/** @private */
		static tlf_internal function get localeProperty():StringProperty
		{ return _localeProperty; }
		/** @private */
		static tlf_internal function get typographicCaseProperty():EnumStringProperty
		{ return _typographicCaseProperty; }
		/** @private */
		static tlf_internal function get fontFamilyProperty():StringProperty
		{ return _fontFamilyProperty; }
		/** @private */
		static tlf_internal function get textDecorationProperty():EnumStringProperty
		{ return _textDecorationProperty; }
		/** @private */
		static tlf_internal function get fontWeightProperty():EnumStringProperty
		{ return _fontWeightProperty; }
		/** @private */
		static tlf_internal function get fontStyleProperty():EnumStringProperty
		{ return _fontStyleProperty; }
		/** @private */
		static tlf_internal function get whiteSpaceCollapseProperty():EnumStringProperty
		{ return _whiteSpaceCollapseProperty; }
		/** @private */
		static tlf_internal function get renderingModeProperty():EnumStringProperty
		{ return _renderingModeProperty; }
		/** @private */
		static tlf_internal function get cffHintingProperty():EnumStringProperty
		{ return _cffHintingProperty; }
		/** @private */
		static tlf_internal function get fontLookupProperty():EnumStringProperty
		{ return _fontLookupProperty; }
		/** @private */
		static tlf_internal function get textRotationProperty():EnumStringProperty
		{ return _textRotationProperty; }
		/** @private */
		static tlf_internal function get textIndentProperty():NumberProperty
		{ return _textIndentProperty; }
		/** @private */
		static tlf_internal function get paragraphStartIndentProperty():NumberProperty
		{ return _paragraphStartIndentProperty; }
		/** @private */
		static tlf_internal function get paragraphEndIndentProperty():NumberProperty
		{ return _paragraphEndIndentProperty; }
		/** @private */
		static tlf_internal function get paragraphSpaceBeforeProperty():NumberProperty
		{ return _paragraphSpaceBeforeProperty; }
		/** @private */
		static tlf_internal function get paragraphSpaceAfterProperty():NumberProperty
		{ return _paragraphSpaceAfterProperty; }
		/** @private */
		static tlf_internal function get textAlignProperty():EnumStringProperty
		{ return _textAlignProperty; }
		/** @private */
		static tlf_internal function get textAlignLastProperty():EnumStringProperty
		{ return _textAlignLastProperty; }
		/** @private */
		static tlf_internal function get textJustifyProperty():EnumStringProperty
		{ return _textJustifyProperty; }
		/** @private */
		static tlf_internal function get justificationRuleProperty():EnumStringProperty
		{ return _justificationRuleProperty; }
		/** @private */
		static tlf_internal function get justificationStyleProperty():EnumStringProperty
		{ return _justificationStyleProperty; }
		/** @private */
		static tlf_internal function get directionProperty():EnumStringProperty
		{ return _directionProperty; }
		/** @private */
		static tlf_internal function get tabStopsProperty():TabStopsProperty
		{ return _tabStopsProperty; }
		/** @private */
		static tlf_internal function get leadingModelProperty():EnumStringProperty
		{ return _leadingModelProperty; }
		/** @private */
		static tlf_internal function get columnGapProperty():NumberProperty
		{ return _columnGapProperty; }
		/** @private */
		static tlf_internal function get paddingLeftProperty():NumberProperty
		{ return _paddingLeftProperty; }
		/** @private */
		static tlf_internal function get paddingTopProperty():NumberProperty
		{ return _paddingTopProperty; }
		/** @private */
		static tlf_internal function get paddingRightProperty():NumberProperty
		{ return _paddingRightProperty; }
		/** @private */
		static tlf_internal function get paddingBottomProperty():NumberProperty
		{ return _paddingBottomProperty; }
		/** @private */
		static tlf_internal function get columnCountProperty():IntWithEnumProperty
		{ return _columnCountProperty; }
		/** @private */
		static tlf_internal function get columnWidthProperty():NumberWithEnumProperty
		{ return _columnWidthProperty; }
		/** @private */
		static tlf_internal function get firstBaselineOffsetProperty():NumberWithEnumProperty
		{ return _firstBaselineOffsetProperty; }
		/** @private */
		static tlf_internal function get verticalAlignProperty():EnumStringProperty
		{ return _verticalAlignProperty; }
		/** @private */
		static tlf_internal function get blockProgressionProperty():EnumStringProperty
		{ return _blockProgressionProperty; }
		/** @private */
		static tlf_internal function get lineBreakProperty():EnumStringProperty
		{ return _lineBreakProperty; }

		static private var _description:Object = {
			  color:_colorProperty
			, backgroundColor:_backgroundColorProperty
			, lineThrough:_lineThroughProperty
			, textAlpha:_textAlphaProperty
			, backgroundAlpha:_backgroundAlphaProperty
			, fontSize:_fontSizeProperty
			, baselineShift:_baselineShiftProperty
			, trackingLeft:_trackingLeftProperty
			, trackingRight:_trackingRightProperty
			, lineHeight:_lineHeightProperty
			, breakOpportunity:_breakOpportunityProperty
			, digitCase:_digitCaseProperty
			, digitWidth:_digitWidthProperty
			, dominantBaseline:_dominantBaselineProperty
			, kerning:_kerningProperty
			, ligatureLevel:_ligatureLevelProperty
			, alignmentBaseline:_alignmentBaselineProperty
			, locale:_localeProperty
			, typographicCase:_typographicCaseProperty
			, fontFamily:_fontFamilyProperty
			, textDecoration:_textDecorationProperty
			, fontWeight:_fontWeightProperty
			, fontStyle:_fontStyleProperty
			, whiteSpaceCollapse:_whiteSpaceCollapseProperty
			, renderingMode:_renderingModeProperty
			, cffHinting:_cffHintingProperty
			, fontLookup:_fontLookupProperty
			, textRotation:_textRotationProperty
			, textIndent:_textIndentProperty
			, paragraphStartIndent:_paragraphStartIndentProperty
			, paragraphEndIndent:_paragraphEndIndentProperty
			, paragraphSpaceBefore:_paragraphSpaceBeforeProperty
			, paragraphSpaceAfter:_paragraphSpaceAfterProperty
			, textAlign:_textAlignProperty
			, textAlignLast:_textAlignLastProperty
			, textJustify:_textJustifyProperty
			, justificationRule:_justificationRuleProperty
			, justificationStyle:_justificationStyleProperty
			, direction:_directionProperty
			, tabStops:_tabStopsProperty
			, leadingModel:_leadingModelProperty
			, columnGap:_columnGapProperty
			, paddingLeft:_paddingLeftProperty
			, paddingTop:_paddingTopProperty
			, paddingRight:_paddingRightProperty
			, paddingBottom:_paddingBottomProperty
			, columnCount:_columnCountProperty
			, columnWidth:_columnWidthProperty
			, firstBaselineOffset:_firstBaselineOffsetProperty
			, verticalAlign:_verticalAlignProperty
			, blockProgression:_blockProgressionProperty
			, lineBreak:_lineBreakProperty
		}

		/** Property descriptions accessible by name. @private */
		static tlf_internal function get description():Object
		{ return _description; }

		/** @private */
		static private var _emptyTextLayoutFormat:ITextLayoutFormat;
		/**
		 * Returns an ITextLayoutFormat instance with all properties set to <code>undefined</code>.
		 * @private
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		static tlf_internal function get emptyTextLayoutFormat():ITextLayoutFormat
		{
			if (_emptyTextLayoutFormat == null)
				_emptyTextLayoutFormat = new TextLayoutFormatValueHolder();
			return _emptyTextLayoutFormat;
		}


		private var _color:*;
		private var _backgroundColor:*;
		private var _lineThrough:*;
		private var _textAlpha:*;
		private var _backgroundAlpha:*;
		private var _fontSize:*;
		private var _baselineShift:*;
		private var _trackingLeft:*;
		private var _trackingRight:*;
		private var _lineHeight:*;
		private var _breakOpportunity:*;
		private var _digitCase:*;
		private var _digitWidth:*;
		private var _dominantBaseline:*;
		private var _kerning:*;
		private var _ligatureLevel:*;
		private var _alignmentBaseline:*;
		private var _locale:*;
		private var _typographicCase:*;
		private var _fontFamily:*;
		private var _textDecoration:*;
		private var _fontWeight:*;
		private var _fontStyle:*;
		private var _whiteSpaceCollapse:*;
		private var _renderingMode:*;
		private var _cffHinting:*;
		private var _fontLookup:*;
		private var _textRotation:*;
		private var _textIndent:*;
		private var _paragraphStartIndent:*;
		private var _paragraphEndIndent:*;
		private var _paragraphSpaceBefore:*;
		private var _paragraphSpaceAfter:*;
		private var _textAlign:*;
		private var _textAlignLast:*;
		private var _textJustify:*;
		private var _justificationRule:*;
		private var _justificationStyle:*;
		private var _direction:*;
		private var _tabStops:*;
		private var _leadingModel:*;
		private var _columnGap:*;
		private var _paddingLeft:*;
		private var _paddingTop:*;
		private var _paddingRight:*;
		private var _paddingBottom:*;
		private var _columnCount:*;
		private var _columnWidth:*;
		private var _firstBaselineOffset:*;
		private var _verticalAlign:*;
		private var _blockProgression:*;
		private var _lineBreak:*;

		/**
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
		{ return _color; }
		public function set color(newValue:*):void
		{ _color = _colorProperty.setHelper(_color,newValue); }

		/**
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
		{ return _backgroundColor; }
		public function set backgroundColor(newValue:*):void
		{ _backgroundColor = _backgroundColorProperty.setHelper(_backgroundColor,newValue); }

		/**
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
		{ return _lineThrough; }
		public function set lineThrough(newValue:*):void
		{ _lineThrough = _lineThroughProperty.setHelper(_lineThrough,newValue); }

		/**
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
		{ return _textAlpha; }
		public function set textAlpha(newValue:*):void
		{ _textAlpha = _textAlphaProperty.setHelper(_textAlpha,newValue); }

		/**
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
		{ return _backgroundAlpha; }
		public function set backgroundAlpha(newValue:*):void
		{ _backgroundAlpha = _backgroundAlphaProperty.setHelper(_backgroundAlpha,newValue); }

		/**
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
		{ return _fontSize; }
		public function set fontSize(newValue:*):void
		{ _fontSize = _fontSizeProperty.setHelper(_fontSize,newValue); }

		/**
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
		{ return _baselineShift; }
		public function set baselineShift(newValue:*):void
		{ _baselineShift = _baselineShiftProperty.setHelper(_baselineShift,newValue); }

		/**
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
		{ return _trackingLeft; }
		public function set trackingLeft(newValue:*):void
		{ _trackingLeft = _trackingLeftProperty.setHelper(_trackingLeft,newValue); }

		/**
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
		{ return _trackingRight; }
		public function set trackingRight(newValue:*):void
		{ _trackingRight = _trackingRightProperty.setHelper(_trackingRight,newValue); }

		/**
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
		{ return _lineHeight; }
		public function set lineHeight(newValue:*):void
		{ _lineHeight = _lineHeightProperty.setHelper(_lineHeight,newValue); }

		/**
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
		{ return _breakOpportunity; }
		public function set breakOpportunity(newValue:*):void
		{ _breakOpportunity = _breakOpportunityProperty.setHelper(_breakOpportunity,newValue); }

		/**
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
		{ return _digitCase; }
		public function set digitCase(newValue:*):void
		{ _digitCase = _digitCaseProperty.setHelper(_digitCase,newValue); }

		/**
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
		{ return _digitWidth; }
		public function set digitWidth(newValue:*):void
		{ _digitWidth = _digitWidthProperty.setHelper(_digitWidth,newValue); }

		/**
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
		{ return _dominantBaseline; }
		public function set dominantBaseline(newValue:*):void
		{ _dominantBaseline = _dominantBaselineProperty.setHelper(_dominantBaseline,newValue); }

		/**
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
		{ return _kerning; }
		public function set kerning(newValue:*):void
		{ _kerning = _kerningProperty.setHelper(_kerning,newValue); }

		/**
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
		{ return _ligatureLevel; }
		public function set ligatureLevel(newValue:*):void
		{ _ligatureLevel = _ligatureLevelProperty.setHelper(_ligatureLevel,newValue); }

		/**
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
		{ return _alignmentBaseline; }
		public function set alignmentBaseline(newValue:*):void
		{ _alignmentBaseline = _alignmentBaselineProperty.setHelper(_alignmentBaseline,newValue); }

		/**
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
		{ return _locale; }
		public function set locale(newValue:*):void
		{ _locale = _localeProperty.setHelper(_locale,newValue); }

		/**
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
		{ return _typographicCase; }
		public function set typographicCase(newValue:*):void
		{ _typographicCase = _typographicCaseProperty.setHelper(_typographicCase,newValue); }

		/**
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
		{ return _fontFamily; }
		public function set fontFamily(newValue:*):void
		{ _fontFamily = _fontFamilyProperty.setHelper(_fontFamily,newValue); }

		/**
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
		{ return _textDecoration; }
		public function set textDecoration(newValue:*):void
		{ _textDecoration = _textDecorationProperty.setHelper(_textDecoration,newValue); }

		/**
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
		{ return _fontWeight; }
		public function set fontWeight(newValue:*):void
		{ _fontWeight = _fontWeightProperty.setHelper(_fontWeight,newValue); }

		/**
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
		{ return _fontStyle; }
		public function set fontStyle(newValue:*):void
		{ _fontStyle = _fontStyleProperty.setHelper(_fontStyle,newValue); }

		/**
		 * Collapses or preserves whitespace when importing text into a TextFlow. <code>WhiteSpaceCollapse.PRESERVE</code> retains all whitespace characters. <code>WhiteSpaceCollapse.COLLAPSE</code> removes newlines, tabs, and leading or trailing spaces within a block of imported text. Line break tags (&lt;br/&gt;) and Unicode line separator characters are retained.
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
		{ return _whiteSpaceCollapse; }
		public function set whiteSpaceCollapse(newValue:*):void
		{ _whiteSpaceCollapse = _whiteSpaceCollapseProperty.setHelper(_whiteSpaceCollapse,newValue); }

		/**
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
		{ return _renderingMode; }
		public function set renderingMode(newValue:*):void
		{ _renderingMode = _renderingModeProperty.setHelper(_renderingMode,newValue); }

		/**
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
		{ return _cffHinting; }
		public function set cffHinting(newValue:*):void
		{ _cffHinting = _cffHintingProperty.setHelper(_cffHinting,newValue); }

		/**
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
		{ return _fontLookup; }
		public function set fontLookup(newValue:*):void
		{ _fontLookup = _fontLookupProperty.setHelper(_fontLookup,newValue); }

		/**
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
		{ return _textRotation; }
		public function set textRotation(newValue:*):void
		{ _textRotation = _textRotationProperty.setHelper(_textRotation,newValue); }

		/**
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
		{ return _textIndent; }
		public function set textIndent(newValue:*):void
		{ _textIndent = _textIndentProperty.setHelper(_textIndent,newValue); }

		/**
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
		{ return _paragraphStartIndent; }
		public function set paragraphStartIndent(newValue:*):void
		{ _paragraphStartIndent = _paragraphStartIndentProperty.setHelper(_paragraphStartIndent,newValue); }

		/**
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
		{ return _paragraphEndIndent; }
		public function set paragraphEndIndent(newValue:*):void
		{ _paragraphEndIndent = _paragraphEndIndentProperty.setHelper(_paragraphEndIndent,newValue); }

		/**
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
		{ return _paragraphSpaceBefore; }
		public function set paragraphSpaceBefore(newValue:*):void
		{ _paragraphSpaceBefore = _paragraphSpaceBeforeProperty.setHelper(_paragraphSpaceBefore,newValue); }

		/**
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
		{ return _paragraphSpaceAfter; }
		public function set paragraphSpaceAfter(newValue:*):void
		{ _paragraphSpaceAfter = _paragraphSpaceAfterProperty.setHelper(_paragraphSpaceAfter,newValue); }

		/**
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
		{ return _textAlign; }
		public function set textAlign(newValue:*):void
		{ _textAlign = _textAlignProperty.setHelper(_textAlign,newValue); }

		/**
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
		{ return _textAlignLast; }
		public function set textAlignLast(newValue:*):void
		{ _textAlignLast = _textAlignLastProperty.setHelper(_textAlignLast,newValue); }

		/**
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
		{ return _textJustify; }
		public function set textJustify(newValue:*):void
		{ _textJustify = _textJustifyProperty.setHelper(_textJustify,newValue); }

		/**
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
		{ return _justificationRule; }
		public function set justificationRule(newValue:*):void
		{ _justificationRule = _justificationRuleProperty.setHelper(_justificationRule,newValue); }

		/**
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
		{ return _justificationStyle; }
		public function set justificationStyle(newValue:*):void
		{ _justificationStyle = _justificationStyleProperty.setHelper(_justificationStyle,newValue); }

		/**
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
		{ return _direction; }
		public function set direction(newValue:*):void
		{ _direction = _directionProperty.setHelper(_direction,newValue); }

		/**
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
		{ return _tabStops; }
		public function set tabStops(newValue:*):void
		{ _tabStops = _tabStopsProperty.setHelper(_tabStops,newValue); }

		/**
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
		{ return _leadingModel; }
		public function set leadingModel(newValue:*):void
		{ _leadingModel = _leadingModelProperty.setHelper(_leadingModel,newValue); }

		/**
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
		{ return _columnGap; }
		public function set columnGap(newValue:*):void
		{ _columnGap = _columnGapProperty.setHelper(_columnGap,newValue); }

		/**
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
		{ return _paddingLeft; }
		public function set paddingLeft(newValue:*):void
		{ _paddingLeft = _paddingLeftProperty.setHelper(_paddingLeft,newValue); }

		/**
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
		{ return _paddingTop; }
		public function set paddingTop(newValue:*):void
		{ _paddingTop = _paddingTopProperty.setHelper(_paddingTop,newValue); }

		/**
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
		{ return _paddingRight; }
		public function set paddingRight(newValue:*):void
		{ _paddingRight = _paddingRightProperty.setHelper(_paddingRight,newValue); }

		/**
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
		{ return _paddingBottom; }
		public function set paddingBottom(newValue:*):void
		{ _paddingBottom = _paddingBottomProperty.setHelper(_paddingBottom,newValue); }

		/**
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
		{ return _columnCount; }
		public function set columnCount(newValue:*):void
		{ _columnCount = _columnCountProperty.setHelper(_columnCount,newValue); }

		/**
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
		{ return _columnWidth; }
		public function set columnWidth(newValue:*):void
		{ _columnWidth = _columnWidthProperty.setHelper(_columnWidth,newValue); }

		/**
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
		{ return _firstBaselineOffset; }
		public function set firstBaselineOffset(newValue:*):void
		{ _firstBaselineOffset = _firstBaselineOffsetProperty.setHelper(_firstBaselineOffset,newValue); }

		/**
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
		{ return _verticalAlign; }
		public function set verticalAlign(newValue:*):void
		{ _verticalAlign = _verticalAlignProperty.setHelper(_verticalAlign,newValue); }

		/**
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
		{ return _blockProgression; }
		public function set blockProgression(newValue:*):void
		{ _blockProgression = _blockProgressionProperty.setHelper(_blockProgression,newValue); }

		/**
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
		{ return _lineBreak; }
		public function set lineBreak(newValue:*):void
		{ _lineBreak = _lineBreakProperty.setHelper(_lineBreak,newValue); }

		/**
		 * Creates a new TextLayoutFormat object. All settings are empty or, optionally, are initialized from the
		 * supplied <code>initialValues</code> object.
		 * 
		 * @param initialValues optional instance from which to copy initial values.
		 * 
		 * @see #defaultFormat
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function TextLayoutFormat(initialValues:ITextLayoutFormat = null)
		{
			if (initialValues)
				apply(initialValues)
		}

		/**
		 * Copies TextLayoutFormat settings from the <code>values</code> ITextLayoutFormat instance into this TextLayoutFormat object.
		 * If <code>values</code> is <code>null</code>, this TextLayoutFormat object is initialized with undefined values for all properties.
		 * @param values optional instance from which to copy values.
		 * 
		 * @includeExample examples\TextLayoutFormat_copyExample.as -noswf
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function copy(values:ITextLayoutFormat):void
		{
			 if (values == null)
				values = emptyTextLayoutFormat;
			this.color = values.color;
			this.backgroundColor = values.backgroundColor;
			this.lineThrough = values.lineThrough;
			this.textAlpha = values.textAlpha;
			this.backgroundAlpha = values.backgroundAlpha;
			this.fontSize = values.fontSize;
			this.baselineShift = values.baselineShift;
			this.trackingLeft = values.trackingLeft;
			this.trackingRight = values.trackingRight;
			this.lineHeight = values.lineHeight;
			this.breakOpportunity = values.breakOpportunity;
			this.digitCase = values.digitCase;
			this.digitWidth = values.digitWidth;
			this.dominantBaseline = values.dominantBaseline;
			this.kerning = values.kerning;
			this.ligatureLevel = values.ligatureLevel;
			this.alignmentBaseline = values.alignmentBaseline;
			this.locale = values.locale;
			this.typographicCase = values.typographicCase;
			this.fontFamily = values.fontFamily;
			this.textDecoration = values.textDecoration;
			this.fontWeight = values.fontWeight;
			this.fontStyle = values.fontStyle;
			this.whiteSpaceCollapse = values.whiteSpaceCollapse;
			this.renderingMode = values.renderingMode;
			this.cffHinting = values.cffHinting;
			this.fontLookup = values.fontLookup;
			this.textRotation = values.textRotation;
			this.textIndent = values.textIndent;
			this.paragraphStartIndent = values.paragraphStartIndent;
			this.paragraphEndIndent = values.paragraphEndIndent;
			this.paragraphSpaceBefore = values.paragraphSpaceBefore;
			this.paragraphSpaceAfter = values.paragraphSpaceAfter;
			this.textAlign = values.textAlign;
			this.textAlignLast = values.textAlignLast;
			this.textJustify = values.textJustify;
			this.justificationRule = values.justificationRule;
			this.justificationStyle = values.justificationStyle;
			this.direction = values.direction;
			this.tabStops = values.tabStops;
			this.leadingModel = values.leadingModel;
			this.columnGap = values.columnGap;
			this.paddingLeft = values.paddingLeft;
			this.paddingTop = values.paddingTop;
			this.paddingRight = values.paddingRight;
			this.paddingBottom = values.paddingBottom;
			this.columnCount = values.columnCount;
			this.columnWidth = values.columnWidth;
			this.firstBaselineOffset = values.firstBaselineOffset;
			this.verticalAlign = values.verticalAlign;
			this.blockProgression = values.blockProgression;
			this.lineBreak = values.lineBreak;
		}

		/**
		 * Concatenates the values of properties in the <code>incoming</code> ITextLayoutFormat instance
		 * with the values of this TextLayoutFormat object. In this (the receiving) TextLayoutFormat object, properties whose values are <code>FormatValue.INHERIT</code>,
		 * and inheriting properties whose values are <code>undefined</code> will get new values from the <code>incoming</code> object.
		 * Non-inheriting properties whose values are <code>undefined</code> will get their default values.
		 * All other property values will remain unmodified.
		 * 
		 * @param incoming instance from which values are concatenated.
		 * @see flashx.textLayout.formats.FormatValue#INHERIT
		 * 
		 * @includeExample examples\TextLayoutFormat_concatExample.as -noswf
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function concat(incoming:ITextLayoutFormat):void
		{
			var holder:TextLayoutFormatValueHolder = incoming as TextLayoutFormatValueHolder;
			if (holder)
			{
					for (var key:String in holder.coreStyles)
					{
						this[key] = description[key].concatHelper(this[key],holder.coreStyles[key]);
				}
				return;
			}
			this.color = _colorProperty.concatHelper(this.color, incoming.color);
			this.backgroundColor = _backgroundColorProperty.concatHelper(this.backgroundColor, incoming.backgroundColor);
			this.lineThrough = _lineThroughProperty.concatHelper(this.lineThrough, incoming.lineThrough);
			this.textAlpha = _textAlphaProperty.concatHelper(this.textAlpha, incoming.textAlpha);
			this.backgroundAlpha = _backgroundAlphaProperty.concatHelper(this.backgroundAlpha, incoming.backgroundAlpha);
			this.fontSize = _fontSizeProperty.concatHelper(this.fontSize, incoming.fontSize);
			this.baselineShift = _baselineShiftProperty.concatHelper(this.baselineShift, incoming.baselineShift);
			this.trackingLeft = _trackingLeftProperty.concatHelper(this.trackingLeft, incoming.trackingLeft);
			this.trackingRight = _trackingRightProperty.concatHelper(this.trackingRight, incoming.trackingRight);
			this.lineHeight = _lineHeightProperty.concatHelper(this.lineHeight, incoming.lineHeight);
			this.breakOpportunity = _breakOpportunityProperty.concatHelper(this.breakOpportunity, incoming.breakOpportunity);
			this.digitCase = _digitCaseProperty.concatHelper(this.digitCase, incoming.digitCase);
			this.digitWidth = _digitWidthProperty.concatHelper(this.digitWidth, incoming.digitWidth);
			this.dominantBaseline = _dominantBaselineProperty.concatHelper(this.dominantBaseline, incoming.dominantBaseline);
			this.kerning = _kerningProperty.concatHelper(this.kerning, incoming.kerning);
			this.ligatureLevel = _ligatureLevelProperty.concatHelper(this.ligatureLevel, incoming.ligatureLevel);
			this.alignmentBaseline = _alignmentBaselineProperty.concatHelper(this.alignmentBaseline, incoming.alignmentBaseline);
			this.locale = _localeProperty.concatHelper(this.locale, incoming.locale);
			this.typographicCase = _typographicCaseProperty.concatHelper(this.typographicCase, incoming.typographicCase);
			this.fontFamily = _fontFamilyProperty.concatHelper(this.fontFamily, incoming.fontFamily);
			this.textDecoration = _textDecorationProperty.concatHelper(this.textDecoration, incoming.textDecoration);
			this.fontWeight = _fontWeightProperty.concatHelper(this.fontWeight, incoming.fontWeight);
			this.fontStyle = _fontStyleProperty.concatHelper(this.fontStyle, incoming.fontStyle);
			this.whiteSpaceCollapse = _whiteSpaceCollapseProperty.concatHelper(this.whiteSpaceCollapse, incoming.whiteSpaceCollapse);
			this.renderingMode = _renderingModeProperty.concatHelper(this.renderingMode, incoming.renderingMode);
			this.cffHinting = _cffHintingProperty.concatHelper(this.cffHinting, incoming.cffHinting);
			this.fontLookup = _fontLookupProperty.concatHelper(this.fontLookup, incoming.fontLookup);
			this.textRotation = _textRotationProperty.concatHelper(this.textRotation, incoming.textRotation);
			this.textIndent = _textIndentProperty.concatHelper(this.textIndent, incoming.textIndent);
			this.paragraphStartIndent = _paragraphStartIndentProperty.concatHelper(this.paragraphStartIndent, incoming.paragraphStartIndent);
			this.paragraphEndIndent = _paragraphEndIndentProperty.concatHelper(this.paragraphEndIndent, incoming.paragraphEndIndent);
			this.paragraphSpaceBefore = _paragraphSpaceBeforeProperty.concatHelper(this.paragraphSpaceBefore, incoming.paragraphSpaceBefore);
			this.paragraphSpaceAfter = _paragraphSpaceAfterProperty.concatHelper(this.paragraphSpaceAfter, incoming.paragraphSpaceAfter);
			this.textAlign = _textAlignProperty.concatHelper(this.textAlign, incoming.textAlign);
			this.textAlignLast = _textAlignLastProperty.concatHelper(this.textAlignLast, incoming.textAlignLast);
			this.textJustify = _textJustifyProperty.concatHelper(this.textJustify, incoming.textJustify);
			this.justificationRule = _justificationRuleProperty.concatHelper(this.justificationRule, incoming.justificationRule);
			this.justificationStyle = _justificationStyleProperty.concatHelper(this.justificationStyle, incoming.justificationStyle);
			this.direction = _directionProperty.concatHelper(this.direction, incoming.direction);
			this.tabStops = _tabStopsProperty.concatHelper(this.tabStops, incoming.tabStops);
			this.leadingModel = _leadingModelProperty.concatHelper(this.leadingModel, incoming.leadingModel);
			this.columnGap = _columnGapProperty.concatHelper(this.columnGap, incoming.columnGap);
			this.paddingLeft = _paddingLeftProperty.concatHelper(this.paddingLeft, incoming.paddingLeft);
			this.paddingTop = _paddingTopProperty.concatHelper(this.paddingTop, incoming.paddingTop);
			this.paddingRight = _paddingRightProperty.concatHelper(this.paddingRight, incoming.paddingRight);
			this.paddingBottom = _paddingBottomProperty.concatHelper(this.paddingBottom, incoming.paddingBottom);
			this.columnCount = _columnCountProperty.concatHelper(this.columnCount, incoming.columnCount);
			this.columnWidth = _columnWidthProperty.concatHelper(this.columnWidth, incoming.columnWidth);
			this.firstBaselineOffset = _firstBaselineOffsetProperty.concatHelper(this.firstBaselineOffset, incoming.firstBaselineOffset);
			this.verticalAlign = _verticalAlignProperty.concatHelper(this.verticalAlign, incoming.verticalAlign);
			this.blockProgression = _blockProgressionProperty.concatHelper(this.blockProgression, incoming.blockProgression);
			this.lineBreak = _lineBreakProperty.concatHelper(this.lineBreak, incoming.lineBreak);
		}

		/**
		 * Concatenates the values of properties in the <code>incoming</code> ITextLayoutFormat instance
		 * with the values of this TextLayoutFormat object. In this (the receiving) TextLayoutFormat object, properties whose values are <code>FormatValue.INHERIT</code>,
		 * and inheriting properties whose values are <code>undefined</code> will get new values from the <code>incoming</code> object.
		 * All other property values will remain unmodified.
		 * 
		 * @param incoming instance from which values are concatenated.
		 * @see flashx.textLayout.formats.FormatValue#INHERIT
		 * 
		 * @includeExample examples\TextLayoutFormat_concatInheritOnlyExample.as -noswf
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function concatInheritOnly(incoming:ITextLayoutFormat):void
		{
			var holder:TextLayoutFormatValueHolder = incoming as TextLayoutFormatValueHolder;
			if (holder)
			{
					for (var key:String in holder.coreStyles)
					{
						this[key] = description[key].concatInheritOnlyHelper(this[key],holder.coreStyles[key]);
				}
				return;
			}
			this.color = _colorProperty.concatInheritOnlyHelper(this.color, incoming.color);
			this.backgroundColor = _backgroundColorProperty.concatInheritOnlyHelper(this.backgroundColor, incoming.backgroundColor);
			this.lineThrough = _lineThroughProperty.concatInheritOnlyHelper(this.lineThrough, incoming.lineThrough);
			this.textAlpha = _textAlphaProperty.concatInheritOnlyHelper(this.textAlpha, incoming.textAlpha);
			this.backgroundAlpha = _backgroundAlphaProperty.concatInheritOnlyHelper(this.backgroundAlpha, incoming.backgroundAlpha);
			this.fontSize = _fontSizeProperty.concatInheritOnlyHelper(this.fontSize, incoming.fontSize);
			this.baselineShift = _baselineShiftProperty.concatInheritOnlyHelper(this.baselineShift, incoming.baselineShift);
			this.trackingLeft = _trackingLeftProperty.concatInheritOnlyHelper(this.trackingLeft, incoming.trackingLeft);
			this.trackingRight = _trackingRightProperty.concatInheritOnlyHelper(this.trackingRight, incoming.trackingRight);
			this.lineHeight = _lineHeightProperty.concatInheritOnlyHelper(this.lineHeight, incoming.lineHeight);
			this.breakOpportunity = _breakOpportunityProperty.concatInheritOnlyHelper(this.breakOpportunity, incoming.breakOpportunity);
			this.digitCase = _digitCaseProperty.concatInheritOnlyHelper(this.digitCase, incoming.digitCase);
			this.digitWidth = _digitWidthProperty.concatInheritOnlyHelper(this.digitWidth, incoming.digitWidth);
			this.dominantBaseline = _dominantBaselineProperty.concatInheritOnlyHelper(this.dominantBaseline, incoming.dominantBaseline);
			this.kerning = _kerningProperty.concatInheritOnlyHelper(this.kerning, incoming.kerning);
			this.ligatureLevel = _ligatureLevelProperty.concatInheritOnlyHelper(this.ligatureLevel, incoming.ligatureLevel);
			this.alignmentBaseline = _alignmentBaselineProperty.concatInheritOnlyHelper(this.alignmentBaseline, incoming.alignmentBaseline);
			this.locale = _localeProperty.concatInheritOnlyHelper(this.locale, incoming.locale);
			this.typographicCase = _typographicCaseProperty.concatInheritOnlyHelper(this.typographicCase, incoming.typographicCase);
			this.fontFamily = _fontFamilyProperty.concatInheritOnlyHelper(this.fontFamily, incoming.fontFamily);
			this.textDecoration = _textDecorationProperty.concatInheritOnlyHelper(this.textDecoration, incoming.textDecoration);
			this.fontWeight = _fontWeightProperty.concatInheritOnlyHelper(this.fontWeight, incoming.fontWeight);
			this.fontStyle = _fontStyleProperty.concatInheritOnlyHelper(this.fontStyle, incoming.fontStyle);
			this.whiteSpaceCollapse = _whiteSpaceCollapseProperty.concatInheritOnlyHelper(this.whiteSpaceCollapse, incoming.whiteSpaceCollapse);
			this.renderingMode = _renderingModeProperty.concatInheritOnlyHelper(this.renderingMode, incoming.renderingMode);
			this.cffHinting = _cffHintingProperty.concatInheritOnlyHelper(this.cffHinting, incoming.cffHinting);
			this.fontLookup = _fontLookupProperty.concatInheritOnlyHelper(this.fontLookup, incoming.fontLookup);
			this.textRotation = _textRotationProperty.concatInheritOnlyHelper(this.textRotation, incoming.textRotation);
			this.textIndent = _textIndentProperty.concatInheritOnlyHelper(this.textIndent, incoming.textIndent);
			this.paragraphStartIndent = _paragraphStartIndentProperty.concatInheritOnlyHelper(this.paragraphStartIndent, incoming.paragraphStartIndent);
			this.paragraphEndIndent = _paragraphEndIndentProperty.concatInheritOnlyHelper(this.paragraphEndIndent, incoming.paragraphEndIndent);
			this.paragraphSpaceBefore = _paragraphSpaceBeforeProperty.concatInheritOnlyHelper(this.paragraphSpaceBefore, incoming.paragraphSpaceBefore);
			this.paragraphSpaceAfter = _paragraphSpaceAfterProperty.concatInheritOnlyHelper(this.paragraphSpaceAfter, incoming.paragraphSpaceAfter);
			this.textAlign = _textAlignProperty.concatInheritOnlyHelper(this.textAlign, incoming.textAlign);
			this.textAlignLast = _textAlignLastProperty.concatInheritOnlyHelper(this.textAlignLast, incoming.textAlignLast);
			this.textJustify = _textJustifyProperty.concatInheritOnlyHelper(this.textJustify, incoming.textJustify);
			this.justificationRule = _justificationRuleProperty.concatInheritOnlyHelper(this.justificationRule, incoming.justificationRule);
			this.justificationStyle = _justificationStyleProperty.concatInheritOnlyHelper(this.justificationStyle, incoming.justificationStyle);
			this.direction = _directionProperty.concatInheritOnlyHelper(this.direction, incoming.direction);
			this.tabStops = _tabStopsProperty.concatInheritOnlyHelper(this.tabStops, incoming.tabStops);
			this.leadingModel = _leadingModelProperty.concatInheritOnlyHelper(this.leadingModel, incoming.leadingModel);
			this.columnGap = _columnGapProperty.concatInheritOnlyHelper(this.columnGap, incoming.columnGap);
			this.paddingLeft = _paddingLeftProperty.concatInheritOnlyHelper(this.paddingLeft, incoming.paddingLeft);
			this.paddingTop = _paddingTopProperty.concatInheritOnlyHelper(this.paddingTop, incoming.paddingTop);
			this.paddingRight = _paddingRightProperty.concatInheritOnlyHelper(this.paddingRight, incoming.paddingRight);
			this.paddingBottom = _paddingBottomProperty.concatInheritOnlyHelper(this.paddingBottom, incoming.paddingBottom);
			this.columnCount = _columnCountProperty.concatInheritOnlyHelper(this.columnCount, incoming.columnCount);
			this.columnWidth = _columnWidthProperty.concatInheritOnlyHelper(this.columnWidth, incoming.columnWidth);
			this.firstBaselineOffset = _firstBaselineOffsetProperty.concatInheritOnlyHelper(this.firstBaselineOffset, incoming.firstBaselineOffset);
			this.verticalAlign = _verticalAlignProperty.concatInheritOnlyHelper(this.verticalAlign, incoming.verticalAlign);
			this.blockProgression = _blockProgressionProperty.concatInheritOnlyHelper(this.blockProgression, incoming.blockProgression);
			this.lineBreak = _lineBreakProperty.concatInheritOnlyHelper(this.lineBreak, incoming.lineBreak);
		}

		/**
		 * Replaces property values in this TextLayoutFormat object with the values of properties that are set in
		 * the <code>incoming</code> ITextLayoutFormat instance. Properties that are <code>undefined</code> in the <code>incoming</code>
		 * ITextLayoutFormat instance are not changed in this object.
		 * 
		 * @param incoming instance whose property values are applied to this TextLayoutFormat object.
		 * 
		 * @includeExample examples\TextLayoutFormat_applyExample.as -noswf
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function apply(incoming:ITextLayoutFormat):void
		{
			var val:*;

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
		 * Compares properties in ITextLayoutFormat instance <code>p1</code> with properties in ITextLayoutFormat instance <code>p2</code>
		 * and returns <code>true</code> if all properties match.
		 * 
		 * @param p1 instance to compare to <code>p2</code>.
		 * @param p2 instance to compare to <code>p1</code>.
		 * 
		 * @return true if all properties match, false otherwise.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		static public function isEqual(p1:ITextLayoutFormat,p2:ITextLayoutFormat):Boolean
		{
			if (p1 == null)
				p1 = emptyTextLayoutFormat;
			if (p2 == null)
				p2 = emptyTextLayoutFormat;
			if (p1 == p2)
				return true;
			var p1Holder:TextLayoutFormatValueHolder = p1 as TextLayoutFormatValueHolder;
			var p2Holder:TextLayoutFormatValueHolder = p2 as TextLayoutFormatValueHolder;
			if (p1Holder && p2Holder)
				return Property.equalCoreStyles(p1Holder.coreStyles,p2Holder.coreStyles,TextLayoutFormat.description);

			if (!_colorProperty.equalHelper(p1.color, p2.color))
				return false;
			if (!_backgroundColorProperty.equalHelper(p1.backgroundColor, p2.backgroundColor))
				return false;
			if (!_lineThroughProperty.equalHelper(p1.lineThrough, p2.lineThrough))
				return false;
			if (!_textAlphaProperty.equalHelper(p1.textAlpha, p2.textAlpha))
				return false;
			if (!_backgroundAlphaProperty.equalHelper(p1.backgroundAlpha, p2.backgroundAlpha))
				return false;
			if (!_fontSizeProperty.equalHelper(p1.fontSize, p2.fontSize))
				return false;
			if (!_baselineShiftProperty.equalHelper(p1.baselineShift, p2.baselineShift))
				return false;
			if (!_trackingLeftProperty.equalHelper(p1.trackingLeft, p2.trackingLeft))
				return false;
			if (!_trackingRightProperty.equalHelper(p1.trackingRight, p2.trackingRight))
				return false;
			if (!_lineHeightProperty.equalHelper(p1.lineHeight, p2.lineHeight))
				return false;
			if (!_breakOpportunityProperty.equalHelper(p1.breakOpportunity, p2.breakOpportunity))
				return false;
			if (!_digitCaseProperty.equalHelper(p1.digitCase, p2.digitCase))
				return false;
			if (!_digitWidthProperty.equalHelper(p1.digitWidth, p2.digitWidth))
				return false;
			if (!_dominantBaselineProperty.equalHelper(p1.dominantBaseline, p2.dominantBaseline))
				return false;
			if (!_kerningProperty.equalHelper(p1.kerning, p2.kerning))
				return false;
			if (!_ligatureLevelProperty.equalHelper(p1.ligatureLevel, p2.ligatureLevel))
				return false;
			if (!_alignmentBaselineProperty.equalHelper(p1.alignmentBaseline, p2.alignmentBaseline))
				return false;
			if (!_localeProperty.equalHelper(p1.locale, p2.locale))
				return false;
			if (!_typographicCaseProperty.equalHelper(p1.typographicCase, p2.typographicCase))
				return false;
			if (!_fontFamilyProperty.equalHelper(p1.fontFamily, p2.fontFamily))
				return false;
			if (!_textDecorationProperty.equalHelper(p1.textDecoration, p2.textDecoration))
				return false;
			if (!_fontWeightProperty.equalHelper(p1.fontWeight, p2.fontWeight))
				return false;
			if (!_fontStyleProperty.equalHelper(p1.fontStyle, p2.fontStyle))
				return false;
			if (!_whiteSpaceCollapseProperty.equalHelper(p1.whiteSpaceCollapse, p2.whiteSpaceCollapse))
				return false;
			if (!_renderingModeProperty.equalHelper(p1.renderingMode, p2.renderingMode))
				return false;
			if (!_cffHintingProperty.equalHelper(p1.cffHinting, p2.cffHinting))
				return false;
			if (!_fontLookupProperty.equalHelper(p1.fontLookup, p2.fontLookup))
				return false;
			if (!_textRotationProperty.equalHelper(p1.textRotation, p2.textRotation))
				return false;
			if (!_textIndentProperty.equalHelper(p1.textIndent, p2.textIndent))
				return false;
			if (!_paragraphStartIndentProperty.equalHelper(p1.paragraphStartIndent, p2.paragraphStartIndent))
				return false;
			if (!_paragraphEndIndentProperty.equalHelper(p1.paragraphEndIndent, p2.paragraphEndIndent))
				return false;
			if (!_paragraphSpaceBeforeProperty.equalHelper(p1.paragraphSpaceBefore, p2.paragraphSpaceBefore))
				return false;
			if (!_paragraphSpaceAfterProperty.equalHelper(p1.paragraphSpaceAfter, p2.paragraphSpaceAfter))
				return false;
			if (!_textAlignProperty.equalHelper(p1.textAlign, p2.textAlign))
				return false;
			if (!_textAlignLastProperty.equalHelper(p1.textAlignLast, p2.textAlignLast))
				return false;
			if (!_textJustifyProperty.equalHelper(p1.textJustify, p2.textJustify))
				return false;
			if (!_justificationRuleProperty.equalHelper(p1.justificationRule, p2.justificationRule))
				return false;
			if (!_justificationStyleProperty.equalHelper(p1.justificationStyle, p2.justificationStyle))
				return false;
			if (!_directionProperty.equalHelper(p1.direction, p2.direction))
				return false;
			if (!_tabStopsProperty.equalHelper(p1.tabStops, p2.tabStops))
				return false;
			if (!_leadingModelProperty.equalHelper(p1.leadingModel, p2.leadingModel))
				return false;
			if (!_columnGapProperty.equalHelper(p1.columnGap, p2.columnGap))
				return false;
			if (!_paddingLeftProperty.equalHelper(p1.paddingLeft, p2.paddingLeft))
				return false;
			if (!_paddingTopProperty.equalHelper(p1.paddingTop, p2.paddingTop))
				return false;
			if (!_paddingRightProperty.equalHelper(p1.paddingRight, p2.paddingRight))
				return false;
			if (!_paddingBottomProperty.equalHelper(p1.paddingBottom, p2.paddingBottom))
				return false;
			if (!_columnCountProperty.equalHelper(p1.columnCount, p2.columnCount))
				return false;
			if (!_columnWidthProperty.equalHelper(p1.columnWidth, p2.columnWidth))
				return false;
			if (!_firstBaselineOffsetProperty.equalHelper(p1.firstBaselineOffset, p2.firstBaselineOffset))
				return false;
			if (!_verticalAlignProperty.equalHelper(p1.verticalAlign, p2.verticalAlign))
				return false;
			if (!_blockProgressionProperty.equalHelper(p1.blockProgression, p2.blockProgression))
				return false;
			if (!_lineBreakProperty.equalHelper(p1.lineBreak, p2.lineBreak))
				return false;

			return true;
		}

		/**
		 * Sets properties in this TextLayoutFormat object to <code>undefined</code> if they match those in the <code>incoming</code>
		 * ITextLayoutFormat instance.
		 * 
		 * @param incoming instance against which to compare this TextLayoutFormat object's property values.
		 * 
		 * @includeExample examples\TextLayoutFormat_removeMatchingExample.as -noswf
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function removeMatching(incoming:ITextLayoutFormat):void
		{
			if (incoming == null)
				return;

			var holder:TextLayoutFormatValueHolder = incoming as TextLayoutFormatValueHolder;
			if (holder)
			{
					for (var key:String in holder.coreStyles)
					{
						CONFIG::debug { assert(holder.coreStyles[key] !== undefined,"bad value in removeMatching"); }
						if (description[key].equalHelper(this[key],holder.coreStyles[key]))
							this[key] = undefined;
				}
				return;
			}

			if (_colorProperty.equalHelper(this.color, incoming.color))
				this.color = undefined;
			if (_backgroundColorProperty.equalHelper(this.backgroundColor, incoming.backgroundColor))
				this.backgroundColor = undefined;
			if (_lineThroughProperty.equalHelper(this.lineThrough, incoming.lineThrough))
				this.lineThrough = undefined;
			if (_textAlphaProperty.equalHelper(this.textAlpha, incoming.textAlpha))
				this.textAlpha = undefined;
			if (_backgroundAlphaProperty.equalHelper(this.backgroundAlpha, incoming.backgroundAlpha))
				this.backgroundAlpha = undefined;
			if (_fontSizeProperty.equalHelper(this.fontSize, incoming.fontSize))
				this.fontSize = undefined;
			if (_baselineShiftProperty.equalHelper(this.baselineShift, incoming.baselineShift))
				this.baselineShift = undefined;
			if (_trackingLeftProperty.equalHelper(this.trackingLeft, incoming.trackingLeft))
				this.trackingLeft = undefined;
			if (_trackingRightProperty.equalHelper(this.trackingRight, incoming.trackingRight))
				this.trackingRight = undefined;
			if (_lineHeightProperty.equalHelper(this.lineHeight, incoming.lineHeight))
				this.lineHeight = undefined;
			if (_breakOpportunityProperty.equalHelper(this.breakOpportunity, incoming.breakOpportunity))
				this.breakOpportunity = undefined;
			if (_digitCaseProperty.equalHelper(this.digitCase, incoming.digitCase))
				this.digitCase = undefined;
			if (_digitWidthProperty.equalHelper(this.digitWidth, incoming.digitWidth))
				this.digitWidth = undefined;
			if (_dominantBaselineProperty.equalHelper(this.dominantBaseline, incoming.dominantBaseline))
				this.dominantBaseline = undefined;
			if (_kerningProperty.equalHelper(this.kerning, incoming.kerning))
				this.kerning = undefined;
			if (_ligatureLevelProperty.equalHelper(this.ligatureLevel, incoming.ligatureLevel))
				this.ligatureLevel = undefined;
			if (_alignmentBaselineProperty.equalHelper(this.alignmentBaseline, incoming.alignmentBaseline))
				this.alignmentBaseline = undefined;
			if (_localeProperty.equalHelper(this.locale, incoming.locale))
				this.locale = undefined;
			if (_typographicCaseProperty.equalHelper(this.typographicCase, incoming.typographicCase))
				this.typographicCase = undefined;
			if (_fontFamilyProperty.equalHelper(this.fontFamily, incoming.fontFamily))
				this.fontFamily = undefined;
			if (_textDecorationProperty.equalHelper(this.textDecoration, incoming.textDecoration))
				this.textDecoration = undefined;
			if (_fontWeightProperty.equalHelper(this.fontWeight, incoming.fontWeight))
				this.fontWeight = undefined;
			if (_fontStyleProperty.equalHelper(this.fontStyle, incoming.fontStyle))
				this.fontStyle = undefined;
			if (_whiteSpaceCollapseProperty.equalHelper(this.whiteSpaceCollapse, incoming.whiteSpaceCollapse))
				this.whiteSpaceCollapse = undefined;
			if (_renderingModeProperty.equalHelper(this.renderingMode, incoming.renderingMode))
				this.renderingMode = undefined;
			if (_cffHintingProperty.equalHelper(this.cffHinting, incoming.cffHinting))
				this.cffHinting = undefined;
			if (_fontLookupProperty.equalHelper(this.fontLookup, incoming.fontLookup))
				this.fontLookup = undefined;
			if (_textRotationProperty.equalHelper(this.textRotation, incoming.textRotation))
				this.textRotation = undefined;
			if (_textIndentProperty.equalHelper(this.textIndent, incoming.textIndent))
				this.textIndent = undefined;
			if (_paragraphStartIndentProperty.equalHelper(this.paragraphStartIndent, incoming.paragraphStartIndent))
				this.paragraphStartIndent = undefined;
			if (_paragraphEndIndentProperty.equalHelper(this.paragraphEndIndent, incoming.paragraphEndIndent))
				this.paragraphEndIndent = undefined;
			if (_paragraphSpaceBeforeProperty.equalHelper(this.paragraphSpaceBefore, incoming.paragraphSpaceBefore))
				this.paragraphSpaceBefore = undefined;
			if (_paragraphSpaceAfterProperty.equalHelper(this.paragraphSpaceAfter, incoming.paragraphSpaceAfter))
				this.paragraphSpaceAfter = undefined;
			if (_textAlignProperty.equalHelper(this.textAlign, incoming.textAlign))
				this.textAlign = undefined;
			if (_textAlignLastProperty.equalHelper(this.textAlignLast, incoming.textAlignLast))
				this.textAlignLast = undefined;
			if (_textJustifyProperty.equalHelper(this.textJustify, incoming.textJustify))
				this.textJustify = undefined;
			if (_justificationRuleProperty.equalHelper(this.justificationRule, incoming.justificationRule))
				this.justificationRule = undefined;
			if (_justificationStyleProperty.equalHelper(this.justificationStyle, incoming.justificationStyle))
				this.justificationStyle = undefined;
			if (_directionProperty.equalHelper(this.direction, incoming.direction))
				this.direction = undefined;
			if (_tabStopsProperty.equalHelper(this.tabStops, incoming.tabStops))
				this.tabStops = undefined;
			if (_leadingModelProperty.equalHelper(this.leadingModel, incoming.leadingModel))
				this.leadingModel = undefined;
			if (_columnGapProperty.equalHelper(this.columnGap, incoming.columnGap))
				this.columnGap = undefined;
			if (_paddingLeftProperty.equalHelper(this.paddingLeft, incoming.paddingLeft))
				this.paddingLeft = undefined;
			if (_paddingTopProperty.equalHelper(this.paddingTop, incoming.paddingTop))
				this.paddingTop = undefined;
			if (_paddingRightProperty.equalHelper(this.paddingRight, incoming.paddingRight))
				this.paddingRight = undefined;
			if (_paddingBottomProperty.equalHelper(this.paddingBottom, incoming.paddingBottom))
				this.paddingBottom = undefined;
			if (_columnCountProperty.equalHelper(this.columnCount, incoming.columnCount))
				this.columnCount = undefined;
			if (_columnWidthProperty.equalHelper(this.columnWidth, incoming.columnWidth))
				this.columnWidth = undefined;
			if (_firstBaselineOffsetProperty.equalHelper(this.firstBaselineOffset, incoming.firstBaselineOffset))
				this.firstBaselineOffset = undefined;
			if (_verticalAlignProperty.equalHelper(this.verticalAlign, incoming.verticalAlign))
				this.verticalAlign = undefined;
			if (_blockProgressionProperty.equalHelper(this.blockProgression, incoming.blockProgression))
				this.blockProgression = undefined;
			if (_lineBreakProperty.equalHelper(this.lineBreak, incoming.lineBreak))
				this.lineBreak = undefined;
		}

		/**
		 * Sets properties in this TextLayoutFormat object to <code>undefined</code> if they do not match those in the
		 * <code>incoming</code> ITextLayoutFormat instance.
		 * 
		 * @param incoming instance against which to compare this TextLayoutFormat object's property values.
		 * 
		 * @includeExample examples\TextLayoutFormat_removeClashingExample.as -noswf
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function removeClashing(incoming:ITextLayoutFormat):void
		{
			if (incoming == null)
				return;

			var holder:TextLayoutFormatValueHolder = incoming as TextLayoutFormatValueHolder;
			if (holder)
			{
					for (var key:String in holder.coreStyles)
					{
						CONFIG::debug { assert(holder.coreStyles[key] !== undefined,"bad value in removeClashing"); }
						if (!description[key].equalHelper(this[key],holder.coreStyles[key]))
							this[key] = undefined;
				}
				return;
			}

			if (!_colorProperty.equalHelper(this.color, incoming.color))
				this.color = undefined;
			if (!_backgroundColorProperty.equalHelper(this.backgroundColor, incoming.backgroundColor))
				this.backgroundColor = undefined;
			if (!_lineThroughProperty.equalHelper(this.lineThrough, incoming.lineThrough))
				this.lineThrough = undefined;
			if (!_textAlphaProperty.equalHelper(this.textAlpha, incoming.textAlpha))
				this.textAlpha = undefined;
			if (!_backgroundAlphaProperty.equalHelper(this.backgroundAlpha, incoming.backgroundAlpha))
				this.backgroundAlpha = undefined;
			if (!_fontSizeProperty.equalHelper(this.fontSize, incoming.fontSize))
				this.fontSize = undefined;
			if (!_baselineShiftProperty.equalHelper(this.baselineShift, incoming.baselineShift))
				this.baselineShift = undefined;
			if (!_trackingLeftProperty.equalHelper(this.trackingLeft, incoming.trackingLeft))
				this.trackingLeft = undefined;
			if (!_trackingRightProperty.equalHelper(this.trackingRight, incoming.trackingRight))
				this.trackingRight = undefined;
			if (!_lineHeightProperty.equalHelper(this.lineHeight, incoming.lineHeight))
				this.lineHeight = undefined;
			if (!_breakOpportunityProperty.equalHelper(this.breakOpportunity, incoming.breakOpportunity))
				this.breakOpportunity = undefined;
			if (!_digitCaseProperty.equalHelper(this.digitCase, incoming.digitCase))
				this.digitCase = undefined;
			if (!_digitWidthProperty.equalHelper(this.digitWidth, incoming.digitWidth))
				this.digitWidth = undefined;
			if (!_dominantBaselineProperty.equalHelper(this.dominantBaseline, incoming.dominantBaseline))
				this.dominantBaseline = undefined;
			if (!_kerningProperty.equalHelper(this.kerning, incoming.kerning))
				this.kerning = undefined;
			if (!_ligatureLevelProperty.equalHelper(this.ligatureLevel, incoming.ligatureLevel))
				this.ligatureLevel = undefined;
			if (!_alignmentBaselineProperty.equalHelper(this.alignmentBaseline, incoming.alignmentBaseline))
				this.alignmentBaseline = undefined;
			if (!_localeProperty.equalHelper(this.locale, incoming.locale))
				this.locale = undefined;
			if (!_typographicCaseProperty.equalHelper(this.typographicCase, incoming.typographicCase))
				this.typographicCase = undefined;
			if (!_fontFamilyProperty.equalHelper(this.fontFamily, incoming.fontFamily))
				this.fontFamily = undefined;
			if (!_textDecorationProperty.equalHelper(this.textDecoration, incoming.textDecoration))
				this.textDecoration = undefined;
			if (!_fontWeightProperty.equalHelper(this.fontWeight, incoming.fontWeight))
				this.fontWeight = undefined;
			if (!_fontStyleProperty.equalHelper(this.fontStyle, incoming.fontStyle))
				this.fontStyle = undefined;
			if (!_whiteSpaceCollapseProperty.equalHelper(this.whiteSpaceCollapse, incoming.whiteSpaceCollapse))
				this.whiteSpaceCollapse = undefined;
			if (!_renderingModeProperty.equalHelper(this.renderingMode, incoming.renderingMode))
				this.renderingMode = undefined;
			if (!_cffHintingProperty.equalHelper(this.cffHinting, incoming.cffHinting))
				this.cffHinting = undefined;
			if (!_fontLookupProperty.equalHelper(this.fontLookup, incoming.fontLookup))
				this.fontLookup = undefined;
			if (!_textRotationProperty.equalHelper(this.textRotation, incoming.textRotation))
				this.textRotation = undefined;
			if (!_textIndentProperty.equalHelper(this.textIndent, incoming.textIndent))
				this.textIndent = undefined;
			if (!_paragraphStartIndentProperty.equalHelper(this.paragraphStartIndent, incoming.paragraphStartIndent))
				this.paragraphStartIndent = undefined;
			if (!_paragraphEndIndentProperty.equalHelper(this.paragraphEndIndent, incoming.paragraphEndIndent))
				this.paragraphEndIndent = undefined;
			if (!_paragraphSpaceBeforeProperty.equalHelper(this.paragraphSpaceBefore, incoming.paragraphSpaceBefore))
				this.paragraphSpaceBefore = undefined;
			if (!_paragraphSpaceAfterProperty.equalHelper(this.paragraphSpaceAfter, incoming.paragraphSpaceAfter))
				this.paragraphSpaceAfter = undefined;
			if (!_textAlignProperty.equalHelper(this.textAlign, incoming.textAlign))
				this.textAlign = undefined;
			if (!_textAlignLastProperty.equalHelper(this.textAlignLast, incoming.textAlignLast))
				this.textAlignLast = undefined;
			if (!_textJustifyProperty.equalHelper(this.textJustify, incoming.textJustify))
				this.textJustify = undefined;
			if (!_justificationRuleProperty.equalHelper(this.justificationRule, incoming.justificationRule))
				this.justificationRule = undefined;
			if (!_justificationStyleProperty.equalHelper(this.justificationStyle, incoming.justificationStyle))
				this.justificationStyle = undefined;
			if (!_directionProperty.equalHelper(this.direction, incoming.direction))
				this.direction = undefined;
			if (!_tabStopsProperty.equalHelper(this.tabStops, incoming.tabStops))
				this.tabStops = undefined;
			if (!_leadingModelProperty.equalHelper(this.leadingModel, incoming.leadingModel))
				this.leadingModel = undefined;
			if (!_columnGapProperty.equalHelper(this.columnGap, incoming.columnGap))
				this.columnGap = undefined;
			if (!_paddingLeftProperty.equalHelper(this.paddingLeft, incoming.paddingLeft))
				this.paddingLeft = undefined;
			if (!_paddingTopProperty.equalHelper(this.paddingTop, incoming.paddingTop))
				this.paddingTop = undefined;
			if (!_paddingRightProperty.equalHelper(this.paddingRight, incoming.paddingRight))
				this.paddingRight = undefined;
			if (!_paddingBottomProperty.equalHelper(this.paddingBottom, incoming.paddingBottom))
				this.paddingBottom = undefined;
			if (!_columnCountProperty.equalHelper(this.columnCount, incoming.columnCount))
				this.columnCount = undefined;
			if (!_columnWidthProperty.equalHelper(this.columnWidth, incoming.columnWidth))
				this.columnWidth = undefined;
			if (!_firstBaselineOffsetProperty.equalHelper(this.firstBaselineOffset, incoming.firstBaselineOffset))
				this.firstBaselineOffset = undefined;
			if (!_verticalAlignProperty.equalHelper(this.verticalAlign, incoming.verticalAlign))
				this.verticalAlign = undefined;
			if (!_blockProgressionProperty.equalHelper(this.blockProgression, incoming.blockProgression))
				this.blockProgression = undefined;
			if (!_lineBreakProperty.equalHelper(this.lineBreak, incoming.lineBreak))
				this.lineBreak = undefined;
		}

		static private var _defaults:TextLayoutFormat;
		/**
		 * Returns a TextLayoutFormat object with default settings.
		 * This function always returns the same object.
		 * 
		 * @return a singleton instance of ITextLayoutFormat that is populated with default values.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		static public function get defaultFormat():ITextLayoutFormat
		{
			if (_defaults == null)
			{
				_defaults = new TextLayoutFormat();
				Property.defaultsAllHelper(_description,_defaults);
			}
			return _defaults;
		}
	}
}
