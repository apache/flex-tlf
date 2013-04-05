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
	import UnitTest.ExtendedClasses.TestDescriptor;
	import UnitTest.ExtendedClasses.TestSuiteExtended;
	import UnitTest.ExtendedClasses.VellumTestCase;
	import UnitTest.Fixtures.TestConfig;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.geom.Point;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineCreationResult;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BaselineOffset;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.JustificationRule;
	import flashx.textLayout.formats.LeadingModel;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	import mx.core.UIComponent;
	import mx.utils.LoaderUtil;

	use namespace tlf_internal;

	public class LeadingTest extends VellumTestCase
	{
		public static var diffTolerance:Number = 0.001;

		public function LeadingTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super(methodName, testID, testConfig);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Composition";
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "verifyRomanDefaultsTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "verifyAsianDefaultsTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "textFieldStyleLeadingTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "ascentFromRomanTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "descentFromRomanTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "ideoTopFromIdeoCenterTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "ideoBottomFromIdeoCenterTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "eastAFirstBaselineOffsetTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "spaceFirstBaselineOffsetTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "topFBOColumnTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "bottomFBOColumnTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "ascentFBOColumnTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "romanFBOColumnTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "descentFBOColumnTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "checkUpDownParagraphBoundryTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "checkDownUpParagraphBoundryTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor (LeadingTest, "inlineGraphicWithFBOTest", testConfig) );
		}

		public function verifyRomanDefaultsTest():void
		{
			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonCharacterFormat());
			cf.fontFamily = "Times New Roman";

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.locale = "en";
			pf.leadingModel = LeadingModel.AUTO;

			SelManager.selectAll();
			SelManager.applyLeafFormat(cf);
			SelManager.applyParagraphFormat(pf);
			SelManager.flushPendingOperations();

			var data1:BitmapData = getData();

			pf = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.locale = "en";
			pf.leadingModel = LeadingModel.ROMAN_UP;

			SelManager.applyParagraphFormat(pf);
			SelManager.flushPendingOperations();

			var data2:BitmapData = getData();

			assertTrue("Changing to explicit default values changed image.",
				compareData(data1,data2)
			);
		}

		public function verifyAsianDefaultsTest():void
		{
			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonCharacterFormat());
			cf.fontFamily = "Times New Roman";

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.locale = "ja";
			pf.leadingModel = LeadingModel.AUTO;

			SelManager.selectAll();
			SelManager.applyLeafFormat(cf);
			SelManager.applyParagraphFormat(pf);
			SelManager.flushPendingOperations();

			var data1:BitmapData = getData();

			pf = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.locale = "ja";
			pf.leadingModel = LeadingModel.IDEOGRAPHIC_TOP_DOWN;

			SelManager.applyParagraphFormat(pf);
			SelManager.flushPendingOperations();

			var data2:BitmapData = getData();

			assertTrue("Changing to explicit default values changed image.",
				compareData(data1,data2)
			);
		}

		public function textFieldStyleLeadingTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;

			textFlow.paddingTop = 0;
			textFlow.paddingBottom = 0;
			textFlow.paddingLeft = 0;
			textFlow.paddingRight = 0;

			var cf:TextLayoutFormat = new TextLayoutFormat();
			cf.paddingTop = cf.paddingBottom = cf.paddingLeft = cf.paddingRight = 0;
			cf.columnCount = 1;

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.leadingModel = LeadingModel.ASCENT_DESCENT_UP;
			pf.paragraphSpaceBefore = pf.paragraphSpaceAfter = 0; pf.paragraphStartIndent = 0; pf.paragraphEndIndent = 0;

			var lf:TextLayoutFormat = new TextLayoutFormat();
			lf.lineHeight = 0;

			SelManager.selectAll();
			SelManager.applyFormat(lf, pf, cf);
			SelManager.flushPendingOperations();

			var composer:IFlowComposer =  SelManager.textFlow.flowComposer;
			composer.composeToPosition(); // ensure everything is composed regardless of what's visible

			var cumulativeTextHeight:Number = 0;
			for (var i:int=0; i<composer.numLines; i++)
			{
				var line:TextFlowLine = composer.getLineAt(i);
				cumulativeTextHeight += line.textHeight;
			}

			var cumulativeContentHeight:Number = 0;
			for (i=0; i<composer.numControllers; i++)
			{
				var controller:ContainerController = composer.getControllerAt(i);
				cumulativeContentHeight += textFlow.computedFormat.blockProgression == BlockProgression.TB ? controller.contentHeight : controller.contentWidth;
			}

			assertTrue("Lines set solid by using lineHeight=0 and leadingModel=ascentDescentUp. Yet, cumulative content height does not equal cumulative text height.",
				cumulativeTextHeight == cumulativeContentHeight);
		}

		public function ascentFromRomanTest():void
		{
			SelManager.selectRange(SelManager.absoluteStart,SelManager.absoluteEnd);

			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			/*cf.firstBaselineOffset = 0;
			cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.ASCENT;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.firstBaselineOffset = "auto";

			SelManager.applyContainerFormat(cf);
			SelManager.applyFormatToElement(SelManager.textFlow,cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.SPACE;
			pf.leadingModel = LeadingModel.ROMAN_UP;

			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);

			SelManager.selectRange(firstLine.textLength,firstLine.textLength);
			SelManager.splitParagraph();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var nextLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(1);

			assertTrue("There is only one line in the paragraph!", nextLine != null);

			var flStats:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			var slStats:Array = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);
			assertTrue("FBO and/or padding not correctly set!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					flStats[4] == 0 :
					flStats[3] == -flStats[0]
			);
			assertTrue("First and second lines do not share leading values!",
				flStats[0] == slStats[0] && flStats[2] == slStats[2]
			);
		}

		public function descentFromRomanTest():void
		{
			SelManager.selectRange(SelManager.absoluteStart,SelManager.absoluteEnd);

			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			cf.firstBaselineOffset = 0;
			/*cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.DESCENT;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.locale = "ja";

			SelManager.applyContainerFormat(cf);
			SelManager.applyFormatToElement(SelManager.textFlow,cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.SPACE;
			pf.leadingModel = LeadingModel.ROMAN_UP;

			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);

			SelManager.selectRange(firstLine.textLength,firstLine.textLength);
			SelManager.splitParagraph();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var nextLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(1);

			assertTrue("There is only one line in the paragraph!", nextLine != null);

			var flStats:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			var slStats:Array = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);
			assertTrue("FBO and/or padding not correctly set!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					flStats[4] == -(flStats[0] + flStats[2]) :
					flStats[3] == flStats[2]
			);
			assertTrue("First and second lines do not share leading values!",
				flStats[0] == slStats[0] && flStats[2] == slStats[2]
			);
		}

		public function ideoTopFromIdeoCenterTest():void
		{
			SelManager.selectRange(SelManager.absoluteStart,SelManager.absoluteEnd);

			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			/*cf.firstBaselineOffset = 0;
			cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.IDEOGRAPHIC_TOP;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.firstBaselineOffset = "auto";

			SelManager.applyContainerFormat(cf);
			SelManager.applyFormatToElement(SelManager.textFlow,cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.EAST_ASIAN;
			pf.leadingModel = LeadingModel.IDEOGRAPHIC_CENTER_DOWN;

			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);

			SelManager.selectRange(firstLine.textLength,firstLine.textLength);
			SelManager.splitParagraph();
			
			var startIndex:int = SelManager.absoluteStart;
			var endIndex:int = SelManager.absoluteEnd;
			
			SelManager.undo();
			SelManager.redo();
			
			SelManager.selectRange(startIndex, endIndex);

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var nextLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(1);

			assertTrue("There is only one line in the paragraph!", nextLine != null);

			var flStats:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			var slStats:Array = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);
			assertTrue("FBO and/or padding not correctly set!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					flStats[4] == 0 :
					flStats[3] == -flStats[2]
			);
			assertTrue("First and second lines do not share leading values!",
				flStats[0] == slStats[0] && flStats[2] == slStats[2]
			);

			pf = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.EAST_ASIAN;
			pf.leadingModel = LeadingModel.IDEOGRAPHIC_TOP_DOWN;

			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);
			nextLine = SelManager.textFlow.flowComposer.getLineAt(1);

			assertTrue("There is only one line in the paragraph!", nextLine != null);

			flStats = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			slStats = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);

			assertTrue("FBO and/or padding not correctly set!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					flStats[4] == 0 :
					flStats[3] == -flStats[2]
			);
			assertTrue("Second line does not have the correct leading!",
				slStats[0] == flStats[0] - flStats[2] &&
				slStats[2] == flStats[0] + flStats[2]
			);
		}

		public function ideoBottomFromIdeoCenterTest():void
		{
			SelManager.selectRange(SelManager.absoluteStart,SelManager.absoluteEnd);

			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			/*cf.firstBaselineOffset = 0;
			cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.IDEOGRAPHIC_TOP;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.firstBaselineOffset = "auto";

			SelManager.applyContainerFormat(cf);
			SelManager.applyFormatToElement(SelManager.textFlow,cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.EAST_ASIAN;
			pf.leadingModel = LeadingModel.IDEOGRAPHIC_CENTER_DOWN;

			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);

			SelManager.selectRange(firstLine.textLength,firstLine.textLength);
			SelManager.splitParagraph();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var nextLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(1);

			assertTrue("There is only one line in the paragraph!", nextLine != null);

			var flStats:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			var slStats:Array = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);
			assertTrue("FBO and/or padding not correctly set!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					flStats[4] == 0 :
					flStats[3] == -(flStats[2])
			);
			assertTrue("First and second lines do not share leading values!",
				flStats[0] == slStats[0] && flStats[2] == slStats[2]
			);
		}

		public function eastAFirstBaselineOffsetTest():void
		{
			SelManager.selectRange(SelManager.absoluteStart,SelManager.absoluteEnd);

			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			/*cf.firstBaselineOffset = 0;
			cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.IDEOGRAPHIC_TOP;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.firstBaselineOffset = "auto";

			SelManager.applyContainerFormat(cf);
			SelManager.applyFormatToElement(SelManager.textFlow,cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.EAST_ASIAN;
			pf.leadingModel = LeadingModel.IDEOGRAPHIC_CENTER_DOWN;

			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);

			SelManager.selectRange(firstLine.textLength,SelManager.absoluteEnd);
			SelManager.deleteText();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);

			var flStats:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);

			assertTrue("Height not equal to ascent!",flStats[0] == flStats[1]);
			assertTrue("Position not equal to height minus ascent!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					flStats[4] == flStats[1] - flStats[0] :
					flStats[3] == -(flStats[1])
			);

			cf = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			/*cf.firstBaselineOffset = 0;
			cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.IDEOGRAPHIC_CENTER;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.firstBaselineOffset = firstLine.textHeight/2;
			cf.locale = "ja";

			SelManager.applyContainerFormat(cf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);

			flStats = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);

			assertTrue("Height not equal to zero!",flStats[1] == 0);
			assertTrue("Position not equal to height minus ascent!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					flStats[4] == flStats[1] - flStats[0] :
					flStats[3] == -(flStats[1])
			);

			cf = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			cf.firstBaselineOffset = 0;
			/*cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.IDEOGRAPHIC_BOTTOM;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.locale = "ja";

			SelManager.applyContainerFormat(cf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);

			flStats = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);

			assertTrue("Height not equal to negative descent!",flStats[1] == -(flStats[2]));
			assertTrue("Position not equal to height minus ascent!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					flStats[4] == flStats[1] - flStats[0] :
					flStats[3] == -(flStats[1])
			);
		}

		public function spaceFirstBaselineOffsetTest():void
		{
			SelManager.selectRange(SelManager.absoluteStart,SelManager.absoluteEnd);

			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			/*cf.firstBaselineOffset = 0;
			cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.ASCENT;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.firstBaselineOffset = "auto";

			SelManager.applyContainerFormat(cf);
			SelManager.applyFormatToElement(SelManager.textFlow,cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.SPACE;
			pf.leadingModel = LeadingModel.ROMAN_UP;

			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);

			SelManager.selectRange(firstLine.textLength,SelManager.absoluteEnd);
			SelManager.deleteText();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);

			var flStats:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);

			assertTrue("Height not equal to ascent!",flStats[0] == flStats[1]);
			assertTrue("Position not equal to height minus ascent!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					flStats[4] == flStats[1] - flStats[0] :
					flStats[3] == -(flStats[1])
			);

			cf = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			cf.firstBaselineOffset = 0;
			/*cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.ROMAN;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.locale = "en"; // not really needed since this is the default

			SelManager.applyContainerFormat(cf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);

			flStats = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);

			assertTrue("Height not equal to zero!",flStats[1] == 0);
			assertTrue("Position not equal to height minus ascent!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					flStats[4] == flStats[1] - flStats[0] :
					flStats[3] == -(flStats[1])
			);

			cf = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			cf.firstBaselineOffset = 0;
			/*cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.DESCENT;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.locale = "ja";

			SelManager.applyContainerFormat(cf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);

			flStats = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);

			assertTrue("Height not equal to negative descent!",flStats[1] == -(flStats[2]));
			assertTrue("Position not equal to height minus ascent!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					flStats[4] == flStats[1] - flStats[0] :
					flStats[3] == -(flStats[1])
			);
		}

		public function topFBOColumnTest():void
		{
			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			cf.columnCount = 2;
			/*cf.firstBaselineOffset = 0;
			cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.IDEOGRAPHIC_TOP;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.firstBaselineOffset = "auto";

			SelManager.applyContainerFormat(cf);
			SelManager.applyFormatToElement(SelManager.textFlow,cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.EAST_ASIAN;
			pf.leadingModel = LeadingModel.AUTO;

			SelManager.selectAll();
			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var nextLine:TextFlowLine;

			for(var i:int = 0; i < SelManager.textFlow.flowComposer.numLines; i++){
				nextLine = SelManager.textFlow.flowComposer.getLineAt(i);

				if(nextLine.columnIndex == 1){
					break;
				}else{
					nextLine = null;
				}
			}

			assertTrue("Could not find a line in the second column!", nextLine != null);

			var f:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			var n:Array = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);

			assertTrue("Ascent of second column line not equal to first!", f[0]==n[0]);
			assertTrue("Height of second column line not equal to first!", f[1]==n[1]);
			assertTrue("Descent of second column line not equal to first!", f[2]==n[2]);
			assertTrue("Position of second column line not equal to first!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					f[4]==n[4] :
					f[3]==n[3]
			);
		}

		public function bottomFBOColumnTest():void
		{
			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			cf.columnCount = 2;
			cf.firstBaselineOffset = 0;
			/*cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.IDEOGRAPHIC_BOTTOM;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.locale = "ja";

			SelManager.applyContainerFormat(cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.EAST_ASIAN;
			pf.leadingModel = LeadingModel.AUTO;

			SelManager.selectAll();
			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var nextLine:TextFlowLine;

			for(var i:int = 0; i < SelManager.textFlow.flowComposer.numLines; i++){
				nextLine = SelManager.textFlow.flowComposer.getLineAt(i);

				if(nextLine.columnIndex == 1){
					break;
				}else{
					nextLine = null;
				}
			}

			assertTrue("Could not find a line in the second column!", nextLine != null);

			var f:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			var n:Array = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);

			assertTrue("Ascent of second column line not equal to first!", f[0]==n[0]);
			assertTrue("Height of second column line not equal to first!", f[1]==n[1]);
			assertTrue("Descent of second column line not equal to first!", f[2]==n[2]);
			assertTrue("Position of second column line not equal to first!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					f[4]==n[4] :
					f[3]==n[3]
			);
		}

		public function ascentFBOColumnTest():void
		{
			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			cf.columnCount = 2;
			/*cf.firstBaselineOffset = 0;
			cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.ASCENT;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.firstBaselineOffset = "auto";

			SelManager.applyContainerFormat(cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.SPACE;
			pf.leadingModel = LeadingModel.AUTO;

			SelManager.selectAll();
			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var nextLine:TextFlowLine;

			for(var i:int = 0; i < SelManager.textFlow.flowComposer.numLines; i++){
				nextLine = SelManager.textFlow.flowComposer.getLineAt(i);

				if(nextLine.columnIndex == 1){
					break;
				}else{
					nextLine = null;
				}
			}

			assertTrue("Could not find a line in the second column!", nextLine != null);

			var f:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			var n:Array = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);

			assertTrue("Ascent of second column line not equal to first!", f[0]==n[0]);
			assertTrue("Height of second column line not equal to first!", f[1]==n[1]);
			assertTrue("Descent of second column line not equal to first!", f[2]==n[2]);
			assertTrue("Position of second column line not equal to first!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					f[4]==n[4] :
					f[3]==n[3]
			);
		}

		public function romanFBOColumnTest():void
		{
			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			cf.columnCount = 2;
			cf.firstBaselineOffset = 0;
			/*cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.ROMAN;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.locale = "en"; // not really needed since this is the default

			SelManager.applyContainerFormat(cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.SPACE;
			pf.leadingModel = LeadingModel.AUTO;

			SelManager.selectAll();
			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var nextLine:TextFlowLine;

			for(var i:int = 0; i < SelManager.textFlow.flowComposer.numLines; i++){
				nextLine = SelManager.textFlow.flowComposer.getLineAt(i);

				if(nextLine.columnIndex == 1){
					break;
				}else{
					nextLine = null;
				}
			}

			assertTrue("Could not find a line in the second column!", nextLine != null);

			var f:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			var n:Array = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);

			assertTrue("Ascent of second column line not equal to first!", f[0]==n[0]);
			assertTrue("Height of second column line not equal to first!", f[1]==n[1]);
			assertTrue("Descent of second column line not equal to first!", f[2]==n[2]);
			assertTrue("Position of second column line not equal to first!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					f[4]==n[4] :
					f[3]==n[3]
			);
		}

		public function descentFBOColumnTest():void
		{
			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			cf.columnCount = 2;
			cf.firstBaselineOffset = 0;
			/*cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.DESCENT;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.locale = "ja";

			SelManager.applyContainerFormat(cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.SPACE;
			pf.leadingModel = LeadingModel.AUTO;

			SelManager.selectAll();
			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var nextLine:TextFlowLine;

			for(var i:int = 0; i < SelManager.textFlow.flowComposer.numLines; i++){
				nextLine = SelManager.textFlow.flowComposer.getLineAt(i);

				if(nextLine.columnIndex == 1){
					break;
				}else{
					nextLine = null;
				}
			}

			assertTrue("Could not find a line in the second column!", nextLine != null);

			var f:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			var n:Array = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);

			assertTrue("Ascent of second column line not equal to first!", f[0]==n[0]);
			assertTrue("Height of second column line not equal to first!", f[1]==n[1]);
			assertTrue("Descent of second column line not equal to first!", f[2]==n[2]);
			assertTrue("Position of second column line not equal to first!",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
					f[4]==n[4] :
					f[3]==n[3]
			);
		}

		public function checkUpDownParagraphBoundryTest():void
		{
			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			/*cf.firstBaselineOffset = 0;
			cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.ASCENT;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.firstBaselineOffset = "auto";

			SelManager.applyFormatToElement(SelManager.textFlow,cf);
			SelManager.applyContainerFormat(cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.SPACE;
			pf.leadingModel = LeadingModel.IDEOGRAPHIC_TOP_UP;

			SelManager.selectAll();
			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);

			SelManager.selectRange(firstLine.textLength,firstLine.textLength);
			SelManager.splitParagraph();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var nextLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(1);

			assertTrue("Seperated lines are still in the same paragraph!",
				firstLine.paragraph != nextLine.paragraph
			);

			pf = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.SPACE;
			pf.leadingModel = LeadingModel.IDEOGRAPHIC_TOP_DOWN;

			SelManager.selectRange(
				nextLine.absoluteStart,
				(nextLine.absoluteStart + nextLine.textLength)
			);
			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);
			nextLine = SelManager.textFlow.flowComposer.getLineAt(1);

			var f:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			var n:Array = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);
			var size:int = SelManager.getCommonCharacterFormat().fontSize as int;
			assertTrue("Leading is incorrectly applied",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
				nextLine.y == nextLine.height + size + 1 :
				nextLine.x == -(nextLine.height + size + 1)
			);
		}

		public function checkDownUpParagraphBoundryTest():void
		{
			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			/*cf.firstBaselineOffset = 0;
			cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.ASCENT;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.firstBaselineOffset = "auto";

			SelManager.applyFormatToElement(SelManager.textFlow,cf);
			SelManager.applyContainerFormat(cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.SPACE;
			pf.leadingModel = LeadingModel.IDEOGRAPHIC_TOP_DOWN;

			SelManager.selectAll();
			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);

			SelManager.selectRange(firstLine.textLength,firstLine.textLength);
			SelManager.splitParagraph();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var nextLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(1);

			assertTrue("Seperated lines are still in the same paragraph!",
				firstLine.paragraph != nextLine.paragraph
			);

			pf = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.SPACE;
			pf.leadingModel = LeadingModel.IDEOGRAPHIC_TOP_UP;

			SelManager.selectRange(
				nextLine.absoluteStart,
				(nextLine.absoluteStart + nextLine.textLength)
			);
			SelManager.applyParagraphFormat(pf);
			SelManager.textFlow.flowComposer.updateAllControllers();

			firstLine = SelManager.textFlow.flowComposer.getLineAt(0);
			nextLine = SelManager.textFlow.flowComposer.getLineAt(1);

			var f:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);
			var n:Array = new Array(
				nextLine.ascent,
				nextLine.height,
				nextLine.descent,
				nextLine.x,
				nextLine.y
			);
			var size:int = SelManager.getCommonCharacterFormat().fontSize as int;
			assertTrue("Leading is incorrectly applied",
				SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB ?
				nextLine.y == nextLine.height + size + 1 :
				nextLine.x == -(nextLine.height + size + 1)
			);
		}

		public function inlineGraphicWithFBOTest():void
		{
			var cf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			cf.paddingTop = 0;
			cf.paddingRight = 0;
			/*cf.firstBaselineOffset = 0;
			cf.firstBaselineOffsetBasis = flash.text.engine.TextBaseline.ASCENT;
			(firstBaselineOffsetBasis no longer supported; using following equivlent)*/
			cf.firstBaselineOffset = "auto";

			SelManager.applyContainerFormat(cf);

			var pf:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			pf.justificationRule = JustificationRule.SPACE;
			pf.leadingModel = LeadingModel.ROMAN_UP;

			SelManager.selectAll();
			SelManager.applyParagraphFormat(pf);

			SelManager.selectRange(3,4);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/smiling.png"),30,30);
			SelManager.textFlow.flowComposer.updateAllControllers();

			var firstLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);

			var flStats:Array = new Array(
				firstLine.ascent,
				firstLine.height,
				firstLine.descent,
				firstLine.x,
				firstLine.y
			);

			assertTrue("Line height is not the height of the inline graphic!",flStats[1] == 30);
		}

		private function getData():BitmapData
		{
			var doc:DisplayObjectContainer =
				testApp.getTextFlow().flowComposer.getControllerAt(0).container;

			var data:BitmapData = new BitmapData(doc.width,doc.height);
			data.draw(doc);

			return data;
		}

		private function compareData(data1:BitmapData, data2:BitmapData):Boolean
		{
			var vect1:Vector.<uint> = data1.getVector(data1.rect);
			var vect2:Vector.<uint> = data2.getVector(data2.rect);

			var one:uint = 0;
			var two:uint = 0;
			var count:int = 0;

			var marked:Boolean = false;
			for(var i:int = 0; i < vect1.length; i++){
				one = vect1.pop();
				two = vect2.pop();

				/* TODO: Change this back to not include block progression.*/
				if( one != two &&
					SelManager.textFlow.computedFormat.blockProgression !=
						BlockProgression.RL)
				{
					count++;
				}
			}

			return (((count/(vect1.length/4))*100) < diffTolerance);
		}
	}
}
