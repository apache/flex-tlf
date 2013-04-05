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
package UnitTest.Tests
{
	import UnitTest.ExtendedClasses.TestSuiteExtended;
	import UnitTest.ExtendedClasses.VellumTestCase;
	import UnitTest.Fixtures.TestConfig;

	import flash.text.engine.JustificationStyle;
	import flash.text.engine.TextBaseline;

	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.JustificationRule;
	import flashx.textLayout.formats.LeadingModel;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

	public class LocaleTests extends VellumTestCase
	{
		public function LocaleTests(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);
			metaData.productArea = "Text Attributes";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = LocaleTests;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

		public function textFlowLocale():void  //KJT  test selection range and change event
		{
			SelManager.selectRange(0,0);

			var tf:TextFlow = SelManager.textFlow;
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca["locale"] = "fr_FR";
			SelManager.applyFormatToElement(tf, ca);

			var leaf:FlowLeafElement = tf.getFirstLeaf();
			assertTrue("TextFlow locale set failed on the leaf",leaf.computedFormat.locale == tf.computedFormat.locale);

			var para:ParagraphElement = leaf.getParagraph();
			assertTrue("TextFlow locale set failed on the paragraph",para.computedFormat.locale == tf.computedFormat.locale);
		}

		public function validateEnLocaleSettings():void
		{
			setupLocaleAndAutoValues("en_US");
			var tf:TextFlow = SelManager.textFlow;
			var leaf:FlowLeafElement = tf.getFirstLeaf();
			var para:ParagraphElement = leaf.getParagraph();

			assertTrue("LocaleTest en_US: The flow dominantBaseline should be roman but is " + para.getEffectiveDominantBaseline(),
				para.getEffectiveDominantBaseline() == TextBaseline.ROMAN);
			assertTrue("LocaleTest en_US: The flow justificationRule should be SPACE but is " + para..getEffectiveJustificationRule(),
				para.getEffectiveJustificationRule() == JustificationRule.SPACE);
			assertTrue("LocaleTest en_US: The flow justificationStyle should be PUSH_IN_KINSOKU but is " + para.getEffectiveJustificationStyle(),
				para.getEffectiveJustificationStyle() == JustificationStyle.PUSH_IN_KINSOKU);
			assertTrue("LocaleTest en_US: The flow leadingModel should be ROMAN_UP but is " + para.getEffectiveLeadingModel(),
				para.getEffectiveLeadingModel() == LeadingModel.ROMAN_UP);
		}

		public function validateZhLocaleSettings():void
		{
			setupLocaleAndAutoValues("zh_TW");
			var tf:TextFlow = SelManager.textFlow;
			var leaf:FlowLeafElement = tf.getFirstLeaf();
			var para:ParagraphElement = leaf.getParagraph();

			assertTrue("LocaleTest zh_TW: The flow dominantBaseline should be ideo center but is " + para.getEffectiveDominantBaseline(),
				para.getEffectiveDominantBaseline() == TextBaseline.IDEOGRAPHIC_CENTER);
			assertTrue("LocaleTest zh_TW: The flow justificationRule should be EAST_ASIAN but is " + para..getEffectiveJustificationRule(),
				para.getEffectiveJustificationRule() == JustificationRule.EAST_ASIAN);
			assertTrue("LocaleTest zh_TW: The flow justificationStyle should be PUSH_IN_KINSOKU but is " + para.getEffectiveJustificationStyle(),
				para.getEffectiveJustificationStyle() == JustificationStyle.PUSH_IN_KINSOKU);
			assertTrue("TLocaleTest zh_TW: he flow leadingModel should be IDEOGRAPHIC_TOP_DOWN but is " + para.getEffectiveLeadingModel(),
				para.getEffectiveLeadingModel() == LeadingModel.IDEOGRAPHIC_TOP_DOWN);
		}

		public function validateJaLocaleSettings():void
		{
			setupLocaleAndAutoValues("ja_JP");
			var tf:TextFlow = SelManager.textFlow;
			var leaf:FlowLeafElement = tf.getFirstLeaf();
			var para:ParagraphElement = leaf.getParagraph();

			assertTrue("LocaleTest ja_JP: The flow dominantBaseline should be ideo center but is " + para.getEffectiveDominantBaseline(),
				para.getEffectiveDominantBaseline() == TextBaseline.IDEOGRAPHIC_CENTER);
			assertTrue("LocaleTest ja_JP: The flow justificationRule should be EAST_ASIAN but is " + para..getEffectiveJustificationRule(),
				para.getEffectiveJustificationRule() == JustificationRule.EAST_ASIAN);
			assertTrue("LocaleTest ja_JP: The flow justificationStyle should be PUSH_IN_KINSOKU but is " + para.getEffectiveJustificationStyle(),
				para.getEffectiveJustificationStyle() == JustificationStyle.PUSH_IN_KINSOKU);
			assertTrue("TLocaleTest ja_JP: he flow leadingModel should be IDEOGRAPHIC_TOP_DOWN but is " + para.getEffectiveLeadingModel(),
				para.getEffectiveLeadingModel() == LeadingModel.IDEOGRAPHIC_TOP_DOWN);
		}

		public function validateDefaultLocaleSettings():void
		{
			setupLocaleAndAutoValues("es_MX");
			var tf:TextFlow = SelManager.textFlow;
			var leaf:FlowLeafElement = tf.getFirstLeaf();
			var para:ParagraphElement = leaf.getParagraph();

			assertTrue("LocaleTest es_MX (undefined locale): The flow dominantBaseline should be roman but is " + para.getEffectiveDominantBaseline(),
				para.getEffectiveDominantBaseline() == TextBaseline.ROMAN);
			assertTrue("LocaleTest es_MX (undefined locale): The flow justificationRule should be SPACE but is " + para..getEffectiveJustificationRule(),
				para.getEffectiveJustificationRule() == JustificationRule.SPACE);
			assertTrue("LocaleTest es_MX (undefined locale): The flow justificationStyle should be PUSH_IN_KINSOKU but is " + para.getEffectiveJustificationStyle(),
				para.getEffectiveJustificationStyle() == JustificationStyle.PUSH_IN_KINSOKU);
			assertTrue("LocaleTest es_MX (undefined locale): The flow leadingModel should be ROMAN_UP but is " + para.getEffectiveLeadingModel(),
				para.getEffectiveLeadingModel() == LeadingModel.ROMAN_UP);
		}

		public function overrideLocaleWithEastAsian():void
		{
			//first set the locale to a non-East Asian value
			setupLocaleAndAutoValues("en_US");

			var tf:TextFlow = SelManager.textFlow;

			//Now override the values and make sure that the locale is being ignored.
			var leaf:FlowLeafElement = tf.getFirstLeaf();
			var para:ParagraphElement = leaf.getParagraph();

			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca["dominantBaseline"] = TextBaseline.IDEOGRAPHIC_CENTER;
			ca["leadingModel"] = LeadingModel.IDEOGRAPHIC_TOP_DOWN;
			ca["justificationRule"] = JustificationRule.EAST_ASIAN;
			ca["justificationStyle"] = JustificationStyle.PUSH_IN_KINSOKU;
			SelManager.applyFormatToElement(para, ca);

			assertTrue("overrideLocaleWithEastAsian ja_JP: The flow dominantBaseline should be ideo center but is " + para.getEffectiveDominantBaseline(),
				para.getEffectiveDominantBaseline() == TextBaseline.IDEOGRAPHIC_CENTER);
			assertTrue("overrideLocaleWithEastAsian ja_JP: The flow justificationRule should be EAST_ASIAN but is " + para..getEffectiveJustificationRule(),
				para.getEffectiveJustificationRule() == JustificationRule.EAST_ASIAN);
			assertTrue("overrideLocaleWithEastAsian ja_JP: The flow justificationStyle should be PUSH_IN_KINSOKU but is " + para.getEffectiveJustificationStyle(),
				para.getEffectiveJustificationStyle() == JustificationStyle.PUSH_IN_KINSOKU);
			assertTrue("overrideLocaleWithEastAsian ja_JP: he flow leadingModel should be IDEOGRAPHIC_TOP_DOWN but is " + para.getEffectiveLeadingModel(),
				para.getEffectiveLeadingModel() == LeadingModel.IDEOGRAPHIC_TOP_DOWN);
		}

		public function overrideLocaleWithEnOrDefault():void
		{
			//first set the locale to an East Asian value
			setupLocaleAndAutoValues("ja_JP");

			var tf:TextFlow = SelManager.textFlow;

			//Now override the values and make sure that the locale is being ignored.
			var leaf:FlowLeafElement = tf.getFirstLeaf();
			var para:ParagraphElement = leaf.getParagraph();

			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca["dominantBaseline"] = TextBaseline.ROMAN;
			ca["leadingModel"] = LeadingModel.ROMAN_UP;
			ca["justificationRule"] = JustificationRule.SPACE;
			ca["justificationStyle"] = JustificationStyle.PRIORITIZE_LEAST_ADJUSTMENT;
			SelManager.applyFormatToElement(para, ca);

			assertTrue("overrideLocaleWithEnOrDefault en/default: The flow dominantBaseline should be roman but is " + para.getEffectiveDominantBaseline(),
				para.getEffectiveDominantBaseline() == TextBaseline.ROMAN);
			assertTrue("overrideLocaleWithEnOrDefault en/default: The flow justificationRule should be SPACE but is " + para..getEffectiveJustificationRule(),
				para.getEffectiveJustificationRule() == JustificationRule.SPACE);
			assertTrue("overrideLocaleWithEnOrDefault en/default: The flow justificationStyle should be PRIORITIZE_LEAST_ADJUSTMENT but is " + para.getEffectiveJustificationStyle(),
				para.getEffectiveJustificationStyle() == JustificationStyle.PRIORITIZE_LEAST_ADJUSTMENT);
			assertTrue("overrideLocaleWithEnOrDefault en/default: The flow leadingModel should be ROMAN_UP but is " + para.getEffectiveLeadingModel(),
				para.getEffectiveLeadingModel() == LeadingModel.ROMAN_UP);
		}

		protected function setupLocaleAndAutoValues(locale:String):void
		{
			var tf:TextFlow = SelManager.textFlow;
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca["locale"] = locale;
			if(tf.computedFormat.dominantBaseline != flashx.textLayout.formats.FormatValue.AUTO)
			{
				ca["dominantBaseline"] = flashx.textLayout.formats.FormatValue.AUTO;
			}

			if(tf.computedFormat.justificationRule != flashx.textLayout.formats.FormatValue.AUTO)
			{
				ca["justificationRule"] = flashx.textLayout.formats.FormatValue.AUTO;
			}

			if(tf.computedFormat.justificationStyle != flashx.textLayout.formats.FormatValue.AUTO)
			{
				ca["justificationStyle"] = flashx.textLayout.formats.FormatValue.AUTO
			}

			if(tf.computedFormat.leadingModel != flashx.textLayout.formats.LeadingModel.AUTO)
			{
				ca["leadingModel"] = flashx.textLayout.formats.LeadingModel.AUTO;
			}
			SelManager.applyFormatToElement(tf, ca);
		}
	}
}
