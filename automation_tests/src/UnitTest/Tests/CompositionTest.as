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
	
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;
	
	import flashx.textLayout.*;
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.TextScrap;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.factory.TruncationOptions;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.VerticalAlign;
	use namespace tlf_internal;

	import mx.utils.UIDUtil;
	import flashx.textLayout.edit.EditManager;

	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.compose.TextFlowLine;
	import mx.core.Container;
	import flash.display.Sprite;
	import flashx.textLayout.formats.ITextLayoutFormat;

 	public class CompositionTest extends VellumTestCase
	{

		public function CompositionTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super (methodName, testID, testConfig);
			if (methodName != "resizeController2644361")
				TestData.fileName = "asknot.xml";
			else
				addDefaultTestSettings = false;

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Composition";
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "checkParagraphShufflingTest", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "partialCompositionTest", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "releasedLineTest", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "composeOneScreen", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "truncationTest", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "CompositionCompleteEventTest", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "scrolledRedrawPartialCompose", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "multipleContainersWithPadding", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "deleteAtContainerStart", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "resizeController2644361", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "resizeEmptyController", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "emptyController", testConfig ) );
			ts.addTestDescriptor( new TestDescriptor ( CompositionTest, "contentBoundsOnComposeFromMiddle", testConfig ) );
		}

		/**
		 * First, find two back to back paragraphs. Second, record the first line of the
		 * second paragraph; if the first paragraph is changed and the second gets recomposed
		 * (i.e. what we don't want) this line will be re-created (also, the first line of
		 * the second paragraph is the easiest to find). Third, make an insertion
		 * point at the end of the first paragraph. Fourth, place a bunch of text at the end
		 * of the paragraph to force it to recompose. Finally, find the first line in the
		 * second paragraph again and see if it is the same as the line you recorded in step
		 * (using "===").
		 */
		public function checkParagraphShufflingTest():void
		{
			var startLength:int = TestFrame.rootElement.textLength;

			var flow1:FlowElement;
			var flow2:FlowElement;

			//Look for two back to back paragraphs.
			for(var i:int = 0; i < TestFrame.rootElement.numChildren-1; i++){
				flow1 = TestFrame.rootElement.getChildAt(i);
				flow2 = TestFrame.rootElement.getChildAt(i+1);

				if(flow1 is ParagraphElement && flow2 is ParagraphElement){
					break;
				}
			}

			assertTrue("either flow1 or flow2 are null", flow1 != null && flow2 != null);

			var para1:ParagraphElement = flow1 as ParagraphElement;
			var para2:ParagraphElement = flow2 as ParagraphElement;

			var lines:Array = StandardFlowComposer(SelManager.textFlow.flowComposer).lines;

			var refLine:Object;
			for each (var line:TextFlowLine in lines){
				if(line.paragraph == para2){
					refLine = line;
					break;
				}
			}

			var para1end:int = para1.textLength - 1;
			SelManager.selectRange(para1end,para1end);

			var longString:String = "Far be it from me to interrupt such an important " +
					"discussion, but it's come to my attention that the behavior of " +
					"line shuffling has yet to be fully investigated within this context. " +
					"So please allow me but a few lines with which to test whether or not " +
					"the aforementioned is indeed working. Thank you.";
			SelManager.insertText(longString);

			SelManager.flushPendingOperations();

			lines = StandardFlowComposer(SelManager.textFlow.flowComposer).lines;

			for each (var line2:TextFlowLine in lines){
				if(line2.paragraph == para2){
					assertTrue("the next paragraph got recomposed instead of shuffling", line2 === refLine);
					break;
				}
			}
		}

		/**
		 * This very complicated test inserts some text in the middle of the flow after
		 * determining which lines will be affected by the change (in terms of which
		 * will need to recompose). It then checks to see if only those that should
		 * be effected by the change have been changed.
		 */
		public function partialCompositionTest():void
		{
			var lines:Array = StandardFlowComposer(SelManager.textFlow.flowComposer).lines;

			var linenum:int = lines.length / 2;
			var initLength:int = lines.length;

			var good:Boolean = false;
			for(var i:int = 0; i < lines.length - 1; i++){
				if(
					(lines[linenum + i] as TextFlowLine).paragraph ==
					(lines[linenum + i + 1] as TextFlowLine).paragraph
				){
					good = true;
					linenum = linenum + i;
					break;
				}
			}

			if(!good){
				for(var j:int = 0; j > 1; j--){
					if(
						(lines[linenum - j] as TextFlowLine).paragraph ==
						(lines[linenum - j - 1] as TextFlowLine).paragraph
					){
						good = true;
						linenum = linenum - j;
						break;
					}
				}
			}

			if(!good){
				fail("No starting place could be found");
			}

			//Register all the lines that shouldn't be damaged.
			var undamagedUIDs:Array = new Array();
			for(var k:int = 0; k < linenum; k++){
				undamagedUIDs[k] = UIDUtil.getUID(lines[k]);
			}

			for(var l:int = lines.length - 1;
				l > linenum &&
				(lines[l] as TextFlowLine).paragraph != (lines[linenum] as TextFlowLine).paragraph;
				l--)
			{
				undamagedUIDs[l] = UIDUtil.getUID(lines[l]);
			}

			//Register all the lines that should be damaged.
			var damagedUIDs:Array = new Array();
			for(var n:int = linenum;
				 n < lines.length &&
				(lines[n] as TextFlowLine).paragraph != null &&
				(lines[n] as TextFlowLine).paragraph == (lines[linenum] as TextFlowLine).paragraph;
				n++)
			{
				damagedUIDs[n] = UIDUtil.getUID(lines[n]);
			}

			var lineToDamage:TextFlowLine = lines[linenum] as TextFlowLine;
			var ip:int = lineToDamage.absoluteStart + lineToDamage.textLength;

			SelManager.selectRange(ip,ip+9);

			var longString:String = "Line Break";
			SelManager.insertText(longString);

			SelManager.flushPendingOperations();

			for(var m:int = 0; m < initLength; m++){
				var UID:String = undamagedUIDs[m];

				if(UID != null){
					assertTrue("Expected line " + m + " not to recompose." +
								" Break was at " + linenum + ".",
								UID == UIDUtil.getUID(lines[m])
					);
				}else{
					UID = damagedUIDs[m];
					assertTrue("Expected line " + m + " to recompose." +
								" Break was at " + linenum + ".",
								UID != UIDUtil.getUID(lines[m])
					);
				}
			}
		}

		private function createLineSummary(flowComposer:IFlowComposer):Object
		{
			// Lines that are referenced should go first
			var releasedLineCount:int = 0;
			var invalidLineCount:int = 0;
			var validLineCount:int = 0;
			var parentedLineCount:int = 0;
			var nonexistentLineCount:int = 0;
			var lineIndex:int = 0;
			while (lineIndex < flowComposer.numLines)
			{
				var line:TextFlowLine = flowComposer.getLineAt(lineIndex);
				if (line.validity == TextLineValidity.VALID)
				{
					assertTrue("Expecting valid referenced lines before invalid lines", invalidLineCount == 0);
					var textLine:TextLine = line.peekTextLine();
					assertTrue(!textLine || textLine.userData == line, "TextLine userData doesn't point back to TextFlowLine");
					if (!textLine || !textLine.textBlock || textLine.textBlock.firstLine == null)
						releasedLineCount++;
					else if (textLine.parent)
						parentedLineCount++;
					else if (textLine.validity == TextLineValidity.VALID)
						validLineCount++;
					else assertTrue(false, "Found damaged unreleased TextLine for valid TextFlowLine");
				}
				else
					invalidLineCount++;
				lineIndex++;
			}

			var result:Object = new Object();
			result["releasedLineCount"] = releasedLineCount;
			result["invalidLineCount"] = invalidLineCount;
			result["validLineCount"] = validLineCount;
			result["parentedLineCount"] = parentedLineCount;
			result["nonexistentLineCount"] = nonexistentLineCount;
			return result;
		}

		// For benchmark: read in Alice and display one screenfull
		public function composeOneScreen():void
		{
			loadTestFile("aliceExcerpt.xml");
		}

		// Tests that lines that aren't in view are released, and that composition didn't run to the end
		public function releasedLineTest():void
		{
			loadTestFile("aliceExcerpt.xml");

			var flowComposer:IFlowComposer = SelManager.textFlow.flowComposer;
			assertTrue("Composed to the end, should leave text that is not in view uncomposed", flowComposer.damageAbsoluteStart < SelManager.textFlow.textLength);

			var controller:ContainerController = flowComposer.getControllerAt(0);
			var originalEstimatedHeight:Number = controller.contentHeight;
			controller.verticalScrollPosition += 500;		// scroll ahead so we have some lines generated that can be released

			var lineSummary:Object = createLineSummary(flowComposer);

			assertTrue("Expected some invalid lines -- composition not complete", lineSummary["invalidLineCount"] > 0);
			// NOTE: Released lines not in view can be garbage collected. This assertion is not necessarily valid.
			assertTrue("Expected some released lines -- not all lines in view", lineSummary["releasedLineCount"] > 0);
			assertTrue("Expected some valid and parented lines", lineSummary["parentedLineCount"] > 0);

			// This will force composition
			flowComposer.composeToPosition();
			var actualContentHeight:Number = controller.contentHeight;
			assertTrue("Expected full compose", flowComposer.damageAbsoluteStart == SelManager.textFlow.textLength);

			var afterFullCompose:Object = createLineSummary(flowComposer);
			assertTrue("Expected no invalid lines -- composition complete", afterFullCompose["invalidLineCount"] == 0);

			assertTrue("Expected estimated is correct after full composition!", flowComposer.getControllerAt(0).contentHeight == actualContentHeight);

	/*		Can't seem to get gc to release the textlines, although they get released when run through the profiler.
			var eventCount:int = 0;
			System.gc();System.gc();
			var sprite:Sprite = Sprite(flowComposer.getControllerAt(0).container);
			sprite.stage.addEventListener(Event.ENTER_FRAME, checkSummary);
			// Wait for next enterFrame event, because gc is delayed

			function checkSummary():void
			{
				if (eventCount > 50)
				{
					var afterGC:Object = createLineSummary(flowComposer);

					// Test that lines are really getting gc'd
					assertTrue("Expected lines to be gc'd!", afterGC["nonexistentLineCount"] > lineSummary["nonexistentLineCount"]);
					assertTrue("Released lines expected 0", afterGC["releasedLineCount"] == 0);
					sprite.stage.removeEventListener(Event.ENTER_FRAME, checkSummary);
				}
				System.gc();System.gc();
				++eventCount;
			} */
		}

		private var _lines:Array;
		private var _textLen:int;
		private function truncationTestCallback(textLine:TextLine):void
		{
			_textLen += textLine.rawTextLength;
			_lines.push(textLine);
		}

		public function truncationTest():void
		{
			var bounds:Rectangle = new Rectangle();
			var text:String = 'There are many such lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. ' +
							  'Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers ' +
							  'rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come.';

			var rtlText:String ='مدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسة'+
								'مدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسة'+
								'مدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسة'+
								'مدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسة';

			var accentedText:String = '\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A' +
											'\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A' +
											'\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A' +
											'\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A' +
											'\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A';

			var formatForRtlTest:TextLayoutFormat = new TextLayoutFormat();
			formatForRtlTest.fontFamily = 'Adobe Arabic';

			// Get stats used later
			_lines = new Array(); _textLen = 0;
			bounds.width = 200;	bounds.height = NaN;
			var factory:StringTextLineFactory = new StringTextLineFactory();
			factory.text = text;
			factory.compositionBounds = bounds;
			factory.createTextLines(truncationTestCallback);
			bounds = factory.getContentBounds();
			assertTrue("[Not a code bug] Fix test case so that text occupies at least three lines when composed in specified bounds.", _lines.length >= 3);
			var line0:TextLine = _lines[0] as TextLine;
			var line0Extent:Number = StringTextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line0.y - line0.ascent : line0.y + line0.descent;
			var line0TextLen:int = line0.rawTextLength;
			var line1:TextLine = _lines[1] as TextLine;
			var line1Extent:Number = StringTextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line1.y - line1.ascent : line1.y + line1.descent;
			var line2:TextLine = _lines[2] as TextLine;
			var line2Extent:Number = StringTextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line2.y - line2.ascent : line2.y + line2.descent;
			var contentHeight:Number = bounds.height;
			var contentTextLength:int = _textLen;

			_lines.splice(0); _textLen = 0; // reset
			bounds.width = 200;	bounds.height = NaN;
			factory.compositionBounds = bounds;
			factory.text = rtlText;
			factory.spanFormat = formatForRtlTest;
			factory.createTextLines(truncationTestCallback);
			assertTrue("[Not a code bug] Fix test case so that RTL text occupies at least two lines when composed in specified bounds.", _lines.length >= 2);
			var rtlLine0TextLen:int = _lines[0].rawTextLength;

			_lines.splice(0); _textLen = 0; // Reset
			bounds.width = 200;	bounds.height = NaN;
			factory.compositionBounds = bounds;
			factory.text = accentedText;
			factory.spanFormat = null;
			factory.createTextLines(truncationTestCallback);
			assertTrue("[Not a code bug] Fix test case so that accented text occupies at least two lines when composed in specified bounds.", _lines.length >= 2);

			var line:TextLine;
			var lineExtent:Number;
			var truncationIndicatorIndex:int;
			var originalContentPrefix:String;
			var customTruncationIndicator:String;
			var customFactory:StringTextLineFactory = new StringTextLineFactory();

			// Verify that text is truncated even if width is not specified
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = NaN;	bounds.height = NaN;
			factory.text = "A\nB"; // has an explicit new line character to ensure two lines
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 1);
			factory.createTextLines(truncationTestCallback);
			assertTrue("Did not truncate when width is unspecified", factory.isTruncated);

			// Verify that text is truncated even if explicit line breaking is used
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN;
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.lineBreak = LineBreak.EXPLICIT;
			factory.textFlowFormat = format;
			factory.text = "A\nB"; // has an explicit new line character to ensure two lines
			factory.compositionBounds = bounds;
			factory.createTextLines(truncationTestCallback);
			assertTrue("Did not truncate when explicit line breaking is used", factory.isTruncated);

			// No lines case 1: compose height allows no line
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line0Extent/2; // less than what one line requires
			factory.textFlowFormat = null;
			factory.text = text;
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions();
			factory.createTextLines(truncationTestCallback);
			assertTrue("Composed one or more lines when compose height allows none", _lines.length == 0 && factory.isTruncated);

			// No lines case 2: 0 line count limit
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = contentHeight; // enough to fit all content
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 0);
			factory.createTextLines(truncationTestCallback);
			assertTrue("Composed one or more lines when line count limit is 0", _lines.length == 0 && factory.isTruncated);

			// No lines case 3: truncation indicator is too large
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = contentHeight -1; // just shy of what the truncation indicator (same as original text) requires
			factory.compositionBounds = bounds;
			factory.text = text;
			factory.truncationOptions = new TruncationOptions(text);
			factory.textFlowFormat = null;
			factory.createTextLines(truncationTestCallback);
			assertTrue("Composed one or more lines when compose height does not allow truncation indicator itself to fit", _lines.length == 0 && factory.isTruncated);

			// Verify truncation if composing to fit in bounds
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line1Extent; // should fit two lines
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions();
			factory.createTextLines(truncationTestCallback);
			assertTrue("Invalid truncation results when composing to fit in bounds (lineCount)", _lines.length == 2 && factory.isTruncated);
			line = _lines[1] as TextLine;
			lineExtent = StringTextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line.y - line.ascent : line.y + line.descent;
			assertTrue("Invalid truncation results when composing to fit in bounds", lineExtent <= line1Extent);

			// Verify truncation if composing to fit in a line count limit
			_lines.splice(0); _textLen = 0; // reset
			bounds.width = 200; bounds.height = NaN;
			bounds.left = 0; bounds.top = 0;
			factory.text = text;
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 2);
			factory.createTextLines(truncationTestCallback);
			assertTrue("Invalid truncation results when composing to fit in a line count limit", _lines.length == 2 && factory.isTruncated);

			// Verify truncation if composing to fit in bounds and a line count limit; the former dominates
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line0Extent; // should fit one line
			factory.text = text;
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 2);
			factory.createTextLines(truncationTestCallback); // line count limit of 2
			assertTrue("Invalid truncation results when multiple truncation criteria provided", _lines.length == 1 && factory.isTruncated);
			line = _lines[0] as TextLine;
			lineExtent = StringTextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line.y - line.ascent : line.y + line.descent;
			assertTrue("Invalid truncation results when multiple truncation criteria provided", lineExtent <= line0Extent);

			// Verify truncation if composing to fit in bounds and a line count limit; the latter dominates
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line1Extent; // should fit two lines
			factory.text = text;
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 1);
			factory.createTextLines(truncationTestCallback); // line count limit of 1
			assertTrue("Invalid truncation results when multiple truncation criteria provided", _lines.length == 1 && factory.isTruncated);
			line = _lines[0] as TextLine;
			lineExtent = StringTextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line.y - line.ascent : line.y + line.descent;
			assertTrue("Invalid truncation results when multiple truncation criteria provided", lineExtent <= line1Extent);

			// Verify truncated text content with default truncation indicator (line count limit)
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN; customFactory.text = text;
			customFactory.compositionBounds = bounds;
			customFactory.truncationOptions = new TruncationOptions(null, 2);
			customFactory.createTextLines(truncationTestCallback);
			truncationIndicatorIndex = customFactory.truncatedText.lastIndexOf(TruncationOptions.HORIZONTAL_ELLIPSIS);
			assertTrue("Default truncation indicator not present at the end of the truncated string", truncationIndicatorIndex+TruncationOptions.HORIZONTAL_ELLIPSIS.length == customFactory.truncatedText.length && factory.isTruncated);
			originalContentPrefix = customFactory.truncatedText.slice(0, truncationIndicatorIndex);
			assertTrue("Original content before truncation indicator mangled", text.indexOf(originalContentPrefix) == 0);

			// Verify truncated text content with default truncation indicator (fit in bounds)
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line1Extent; // should fit two lines;
			customFactory.text = text;
			customFactory.compositionBounds = bounds;
			customFactory.truncationOptions = new TruncationOptions();
			customFactory.createTextLines(truncationTestCallback);
			truncationIndicatorIndex = customFactory.truncatedText.lastIndexOf(TruncationOptions.HORIZONTAL_ELLIPSIS);
			assertTrue("Default truncation indicator not present at the end of the truncated string", truncationIndicatorIndex+TruncationOptions.HORIZONTAL_ELLIPSIS.length == customFactory.truncatedText.length && factory.isTruncated);
			originalContentPrefix = customFactory.truncatedText.slice(0, truncationIndicatorIndex);
			assertTrue("Original content before truncation indicator mangled", text.indexOf(originalContentPrefix) == 0);

			// Verify truncated text content with custom truncation indicator
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN; customFactory.text = text;
			customTruncationIndicator = "<SNIP>";
			customFactory.compositionBounds = bounds;
			customFactory.truncationOptions = new TruncationOptions(customTruncationIndicator, 2);
			customFactory.createTextLines(truncationTestCallback);
			truncationIndicatorIndex = customFactory.truncatedText.lastIndexOf(customTruncationIndicator);
			assertTrue("Truncation indicator not present at the end of the truncated string", truncationIndicatorIndex+customTruncationIndicator.length == customFactory.truncatedText.length && factory.isTruncated);
			originalContentPrefix = customFactory.truncatedText.slice(0, truncationIndicatorIndex);
			assertTrue("Original content before truncation indicator mangled", text.indexOf(originalContentPrefix) == 0);

			// Verify original text replacement is optimal
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN; customFactory.text = text;
			customFactory.text = text;
			customFactory.compositionBounds = bounds;
			customTruncationIndicator = '\u200B'; // Zero-width space : should not require *any* original content that fits to be replaced
			customFactory.truncationOptions = new TruncationOptions(customTruncationIndicator, 1);
			customFactory.createTextLines(truncationTestCallback);
			assertTrue("Replacing more original content than is neccessary", customFactory.truncatedText.length == line0TextLen+customTruncationIndicator.length && factory.isTruncated);

			// Verify original text replacement is optimal (RTL text)
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN; customFactory.text = rtlText;
			customFactory.compositionBounds = bounds;
			customTruncationIndicator = '\u200B'; // Zero-width space : should not require *any* original content that fits to be replaced
			customFactory.spanFormat = formatForRtlTest;
			customFactory.truncationOptions = new TruncationOptions(customTruncationIndicator, 1);
			customFactory.createTextLines(truncationTestCallback);
			assertTrue("Replacing more original content than is neccessary (RTL text)", customFactory.truncatedText.length == rtlLine0TextLen+customTruncationIndicator.length && factory.isTruncated);
			customFactory.spanFormat = null;

			// Verify truncation happens at atom boundaries
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN; customFactory.text = accentedText;
			customTruncationIndicator = '<' + '\u200A' /* Hair space */ + '>'; // what precedes and succeeds the hair space is irrelevant
			customFactory.compositionBounds = bounds;
			customFactory.truncationOptions = new TruncationOptions(customTruncationIndicator, 1);
			customFactory.createTextLines(truncationTestCallback);
			assertTrue("[Not a code bug] Fix test case so that truncation indicator itself fits", _lines.length == 1 && factory.isTruncated); // baseline

			var initialTruncationPoint:int =  customFactory.truncatedText.length - customTruncationIndicator.length;
			assertTrue("[Not a code bug] Fix test case so that some of the original content is left behind on first truncation attempt", initialTruncationPoint > 0); // baseline
			assertTrue("Truncation in the middle of an atom!", initialTruncationPoint % 2 == 0);
			var nextTruncationPoint:int;
			do
			{
				bounds.height = NaN;
				customTruncationIndicator = customTruncationIndicator.replace('\u200A', '\u200A\u200A'); // add another hair space in each iteration, making truncation indicator wider (ever so slightly)
				customFactory.compositionBounds = bounds;
				customFactory.truncationOptions = new TruncationOptions(customTruncationIndicator, 1);
				customFactory.createTextLines(truncationTestCallback);

				nextTruncationPoint =  customFactory.truncatedText.length - customTruncationIndicator.length;
				if (nextTruncationPoint != initialTruncationPoint)
				{
					assertTrue("Truncation in the middle of an atom!", nextTruncationPoint % 2 == 0);
					assertTrue("Sub-optimal replacement of original content?", nextTruncationPoint == initialTruncationPoint-2);
					initialTruncationPoint = nextTruncationPoint;
				}

			} while (nextTruncationPoint);

			// Verify scrolling behavior when truncation options are set
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line1Extent; // should fit two lines
			factory.compositionBounds = bounds;
			factory.verticalScrollPolicy = "on";
			var vaFormat:TextLayoutFormat = new TextLayoutFormat();
			vaFormat.verticalAlign = VerticalAlign.BOTTOM;
			factory.textFlowFormat = vaFormat;
			factory.truncationOptions = new TruncationOptions(); // should override scroll policy
			factory.createTextLines(truncationTestCallback);
			assertTrue("When verticalAlign is Bottom, and scrolling is on, but truncation options are set, only text that fits should be generated",
				_textLen < contentTextLength && factory.isTruncated);
		}

		public function CompositionCompleteEventTest():void
		{
			var gotEvent:Boolean = false;
			var textFlow:TextFlow = SelManager.textFlow;
			textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, completionHandler);
			var charFormat:TextLayoutFormat = new TextLayoutFormat();
			charFormat.fontSize=48;
			SelManager.selectAll();
			(SelManager as EditManager).applyLeafFormat(charFormat);
			assertTrue("Didn't get the CompositionCompleteEvent", gotEvent == true);

			function completionHandler(event:CompositionCompleteEvent): void
			{
				gotEvent = true;
				textFlow.removeEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, completionHandler);
			}
		}
		
		private function setUpMultipleLinkedContainers(numberOfContainers:int):Sprite
		{
			var flexContainer:Container;
			var textFlow:TextFlow = SelManager.textFlow;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var firstController:ContainerController = textFlow.flowComposer.getControllerAt(0);
			var totalWidth:Number = firstController.compositionWidth;
			var containerWidth:Number = totalWidth / numberOfContainers;
			var containerHeight:Number = firstController.compositionHeight;
			firstController.setCompositionSize(containerWidth, firstController.compositionHeight);
			var containerParent:Sprite = firstController.container.parent as Sprite;
			if (containerParent is Container)
			{
				flexContainer = Container(containerParent);
				var newContainerParent:Sprite = new Sprite();
				flexContainer.rawChildren.addChild(newContainerParent);
				flexContainer.rawChildren.removeChild(firstController.container);
				newContainerParent.addChild(firstController.container);
				containerParent = newContainerParent;
			}
			var pos:int = containerWidth;
			while (flowComposer.numControllers < numberOfContainers)
			{
				var s:Sprite = new Sprite();
				s.x = pos;
				pos += containerWidth;
				containerParent.addChild(s);
				flowComposer.addController(new ContainerController(s, containerWidth, containerHeight));
			}
			return containerParent;
		}
		
		private function restoreToSingleContainer(containerParent:Sprite):void
		{
			var flexContainer:Container = containerParent.parent as Container;
			
			if (flexContainer)
			{
				flexContainer.rawChildren.removeChild(containerParent);
				flexContainer.rawChildren.addChild(containerParent.getChildAt(0));
			}
			var flowComposer:IFlowComposer = SelManager.textFlow.flowComposer;
			while (flowComposer.numControllers > 1)
				flowComposer.removeControllerAt(flowComposer.numControllers - 1);			
		}
		
		// Test case with multiple containers, where the last container is scrolled down, and update will cause a scroll
		// Watson 2583969
		public function scrolledRedrawPartialCompose():void
		{
			var multiContainerParent:Sprite;
			
			try 
			{
				var textFlow:TextFlow = SelManager.textFlow;
				var flowComposer:IFlowComposer = textFlow.flowComposer;
				multiContainerParent = setUpMultipleLinkedContainers(5);
				
				// Paste all the text again, so all containers are full, and there is text scrolled out
				var textScrap:TextScrap = TextScrap.createTextScrap(new TextRange(textFlow, 0, textFlow.textLength));
				EditManager(SelManager).pasteTextScrap(textScrap);
				flowComposer.updateAllControllers();
				
	
				// Set selection to the last two lines of the flow, and scroll to the new selection, and then delete the text
				var lastController:ContainerController = flowComposer.getControllerAt(flowComposer.numControllers - 1);
				flowComposer.composeToPosition();	// force all text to compose
				var nextToLastLine:TextFlowLine = flowComposer.getLineAt(flowComposer.numLines - 2);
				SelManager.selectRange(nextToLastLine.absoluteStart, textFlow.textLength);
				lastController.scrollToRange(SelManager.absoluteStart, SelManager.absoluteEnd);
				var firstVisibleChar:int = lastController.getFirstVisibleLine().absoluteStart; // save off the current scrolled-to text pos
				flowComposer.updateAllControllers();
				EditManager(SelManager).deleteText();
				
				// The delete (and subsequent redraw) should have caused a scroll during the ContainerController updateCompositionShapes.
				// Check that this happened correctly.
				var firstVisibleCharAfterPaste:int = lastController.getFirstVisibleLine().absoluteStart;
				assertTrue("Expected scroll during update", firstVisibleChar != firstVisibleCharAfterPaste);
			}
			finally
			{
				// restore how containers were set up before
				restoreToSingleContainer(multiContainerParent);
			}
		}

		// Test case with multiple containers, where the last container is scrolled down, and update will cause a scroll
		// Watson 2583969
		public function multipleContainersWithPadding():void
		{
			var multiContainerParent:Sprite;
			
			try 
			{
				var textFlow:TextFlow = SelManager.textFlow;
				var flowComposer:IFlowComposer = textFlow.flowComposer;
				multiContainerParent = setUpMultipleLinkedContainers(2);
				
				var firstController:ContainerController = flowComposer.getControllerAt(0);
				var format:TextLayoutFormat = new TextLayoutFormat(firstController.format);
				format.paddingTop = firstController.compositionHeight;
				firstController.format = format;
				flowComposer.updateAllControllers();
				
				assertTrue("Expected no lines in first container", firstController.getFirstVisibleLine() == null && firstController.getLastVisibleLine() == null);
			}
			finally
			{
				// restore how containers were set up before
				restoreToSingleContainer(multiContainerParent);
			}
		}
		
		private const numberOfLinesBack:int = 5;
		public function deleteAtContainerStart():void
		{
			var multiContainerParent:Sprite;
			
			try 
			{
				var textFlow:TextFlow = SelManager.textFlow;
				var flowComposer:IFlowComposer = textFlow.flowComposer;
				multiContainerParent = setUpMultipleLinkedContainers(2);

				flowComposer.composeToPosition();
				var controller:ContainerController = flowComposer.getControllerAt(0);
				
				var lastLineIndex:int = flowComposer.findLineIndexAtPosition(controller.absoluteStart + controller.textLength);
				var startIndex:int = flowComposer.getLineAt(lastLineIndex - numberOfLinesBack).absoluteStart;
				SelManager.selectRange(startIndex, startIndex);
				for (var i:int = 0; i < numberOfLinesBack + 1; ++i)
					SelManager.splitParagraph();
				flowComposer.updateAllControllers();
				var textLengthBefore:int = controller.textLength;
				
				assertTrue("Selection should be at the start of the next container", SelManager.absoluteStart == controller.absoluteStart + controller.textLength);
				SelManager.deletePreviousCharacter();
				flowComposer.composeToPosition();
				assertTrue("Expected first line of following container to be sucked in", controller.textLength > textLengthBefore);
			}
			finally
			{
				// restore how containers were set up before
				restoreToSingleContainer(multiContainerParent);
			}
		}
		
		public function resizeController2644361():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			var originalWidth:Number = controller.compositionWidth;
			var originalHeight:Number = controller.compositionHeight;
			var scrap:TextScrap = TextScrap.createTextScrap(new TextRange(textFlow, 0, textFlow.textLength));
			SelManager.selectRange(textFlow.textLength - 1, textFlow.textLength - 1);
			SelManager.splitParagraph();
			SelManager.pasteTextScrap(scrap);
			SelManager.pasteTextScrap(scrap);
			textFlow.flowComposer.updateAllControllers();
			controller.setCompositionSize( 825 ,  471 )
			SelManager.updateAllControllers();
			controller.setCompositionSize( 808 ,  464 )
			SelManager.updateAllControllers();
			controller.setCompositionSize( 791 ,  462 )
			SelManager.updateAllControllers();
			controller.setCompositionSize( 768 ,  461 )
			SelManager.updateAllControllers();
		}
		
		public function resizeEmptyController():void
		{
			var textFlow:TextFlow = new TextFlow();
			var p:ParagraphElement = new ParagraphElement();
			textFlow.addChild(p);
			
			var span:SpanElement = new SpanElement();
			span.text = "Hello world";
			span.fontSize = 40;
			p.addChild(span);
			
			var sprite1:Sprite = new Sprite();
			var cc1:ContainerController = new ContainerController(sprite1,100,50);
			sprite1.x = 100;
			var sprite2:Sprite = new Sprite();
			var cc2:ContainerController = new ContainerController(sprite2,100,50);
			sprite2.x = 300;
		//	addChild(sprite1);
		//	addChild(sprite2);
			textFlow.flowComposer.addController(cc1);
			textFlow.flowComposer.addController(cc2);
			textFlow.flowComposer.updateAllControllers();
			var originalLength:int = cc1.textLength;
			cc1.setCompositionSize(100,10);
			textFlow.flowComposer.updateAllControllers();
			cc1.setCompositionSize(100,50);
			textFlow.flowComposer.updateAllControllers();
			assertTrue("Expected text to recompose into controller", cc1.textLength == originalLength);
		}

		public function emptyController():void
		{
			var s:Sprite = new Sprite();
			var textFlow:TextFlow = new TextFlow();
			textFlow.flowComposer.addController(new ContainerController(s, 0, 0));
			textFlow.flowComposer.updateAllControllers();
		}
		
		// Check that the content bounds includes all parcels when composition starts from a column that is not the first
		// See Watson 2769670
		public function contentBoundsOnComposeFromMiddle():void
		{
			TestFrame.rootElement.blockProgression = writingDirection[0];
			TestFrame.rootElement.direction        = writingDirection[1];
			
			var textFlow:TextFlow = SelManager.textFlow;
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			var composeSpace:Rectangle = new Rectangle(0, 0, controller.compositionWidth, controller.compositionHeight);

			var lastLine:TextFlowLine = controller.getLastVisibleLine();
			var lastVisiblePosition:int = lastLine.absoluteStart + lastLine.textLength - 1;
			var charPos:int = lastVisiblePosition - 100;
			
			// Trim off the unseen portion of the flow to a little before the end, so we aren't 
			// affected by content height estimation, and so we can check that height from previous
			// columns is included.
			SelManager.selectRange(charPos, textFlow.textLength - 1);
			SelManager.deleteText();
			
			// Change format to 3 columns justified text, and get the bounds. This time we composed from the start.
			var format:TextLayoutFormat = new TextLayoutFormat(textFlow.format);
			format.columnCount = 3;
			format.textAlign = TextAlign.JUSTIFY;
			textFlow.format = format;
			textFlow.flowComposer.updateAllControllers();
			var bounds:Rectangle = controller.getContentBounds();
			
			// Force partial composition in the last column. The bounds may be slightly different in height because we aren't
			// iterating all the lines to get height. If it doesn't match, it should be equal to the (logical) compositionHeight.
			charPos = textFlow.textLength - 3;
			var leafFormat:TextLayoutFormat = new TextLayoutFormat();
			leafFormat.color = 0xFF0000;
			SelManager.selectRange(charPos, charPos + 1);
			SelManager.applyLeafFormat(leafFormat);
			var boundsAfterPartialCompose:Rectangle = controller.getContentBounds();

			var boundsMatch:Boolean = boundsAfterPartialCompose.equals(bounds);
			if (!boundsMatch && 
				bounds.y == boundsAfterPartialCompose.y)
			{
				if (controller.effectiveBlockProgression == BlockProgression.TB)
					boundsMatch = Math.abs(boundsAfterPartialCompose.x - bounds.x) < 1 && Math.abs(boundsAfterPartialCompose.width - bounds.width) < 1 && boundsAfterPartialCompose.height == controller.compositionHeight;
				else
					boundsMatch = Math.abs(boundsAfterPartialCompose.x - -controller.compositionWidth) < 1 && Math.abs(boundsAfterPartialCompose.height - bounds.height) < 1 && boundsAfterPartialCompose.width == controller.compositionWidth;
			}
			
			assertTrue("Expected bounds after partial compose to match bounds from previous full compose", boundsMatch);
		}
	}
}
