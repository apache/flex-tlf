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

	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;

	import flashx.textLayout.*;
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.factory.TruncationOptions;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.VerticalAlign;
	use namespace tlf_internal;

	import mx.utils.UIDUtil;
	import flashx.textLayout.edit.EditManager;

	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.factory.TextFlowTextLineFactory;

 	public class TextFlowTextLineFactoryTest extends VellumTestCase
	{

		public function TextFlowTextLineFactoryTest(methodName:String, testID:String, testConfig:TestConfig,  testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);
			TestData.fileName = "asknot.xml";

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Composition";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = TextFlowTextLineFactoryTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
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
		private var para:ParagraphElement;
		private var tf:TextFlow;
		private var _truncatedTextLen:int;

		private function createLineCallback(textLine:TextLine):void
		{
			_lines.push(textLine);
			_textLen += textLine.rawTextLength;
		}

		private function truncatedCallback(tf:TextFlow):void
		{

			_truncatedTextLen = tf.textLength;

		}

		private function initTextFlow(text:String, format:TextLayoutFormat):void
		{
			tf = TextConverter.importToFlow(text, TextConverter.PLAIN_TEXT_FORMAT);
			tf.format = format;
			/*var span:SpanElement = new SpanElement();
			para = new ParagraphElement();
			span.text = text;
			para.addChild(span);*/

		}


		public function truncationTest():void
		{
			var bounds:Rectangle = new Rectangle();
			var format:TextLayoutFormat = new TextLayoutFormat();
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
			//var factory:StringTextLineFactory = new StringTextLineFactory();
			var factory:TextFlowTextLineFactory = new TextFlowTextLineFactory();
			factory.compositionBounds = bounds;
			initTextFlow(text,format);
			tf.addChild(para);
			factory.createTextLines(createLineCallback, tf);
			bounds = factory.getContentBounds();
			assertTrue("[Not a code bug] Fix test case so that text occupies at least three lines when composed in specified bounds.", _lines.length >= 3);
			var line0:TextLine = _lines[0] as TextLine;
			var line0Extent:Number = tf.configuration.overflowPolicy == OverflowPolicy.FIT_ANY ? line0.y - line0.ascent : line0.y + line0.descent;
			var line0TextLen:int = line0.rawTextLength;
			var line1:TextLine = _lines[1] as TextLine;
			var line1Extent:Number = tf.configuration.overflowPolicy == OverflowPolicy.FIT_ANY ? line1.y - line1.ascent : line1.y + line1.descent;
			var line2:TextLine = _lines[2] as TextLine;
			var line2Extent:Number = tf.configuration.overflowPolicy == OverflowPolicy.FIT_ANY ? line2.y - line2.ascent : line2.y + line2.descent;
			var contentHeight:Number = bounds.height;
			var contentTextLength:int = _textLen;

			_lines.splice(0); _textLen = 0; // reset
			bounds.width = 200;	bounds.height = NaN;
			factory.compositionBounds = bounds;
			initTextFlow(rtlText,formatForRtlTest);
			factory.createTextLines(createLineCallback, tf);
			assertTrue("[Not a code bug] Fix test case so that RTL text occupies at least two lines when composed in specified bounds.", _lines.length >= 2);
			var rtlLine0TextLen:int = _lines[0].rawTextLength;

			_lines.splice(0); _textLen = 0; // Reset
			bounds.width = 200;	bounds.height = NaN;
			factory.compositionBounds = bounds;
			initTextFlow(accentedText,null);
			factory.createTextLines(createLineCallback,tf);
			assertTrue("[Not a code bug] Fix test case so that accented text occupies at least two lines when composed in specified bounds.", _lines.length >= 2);


            var line:TextLine;
			var lineExtent:Number;
			var truncationIndicatorIndex:int;
			var originalContentPrefix:String;
			var customTruncationIndicator:String;
			var customFactory:TextFlowTextLineFactory = new TextFlowTextLineFactory();

			// Verify that text is truncated even if width is not specified
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = NaN;	bounds.height = NaN;
			initTextFlow("A\nB", format); // has an explicit new line character to ensure two lines
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 1);
			factory.createTextLines(createLineCallback, tf);
			assertTrue("Did not truncate when width is unspecified", _lines.length == 1 && factory.isTruncated);

			// Verify that text is not truncated if explicit line breaking is used
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN;
			format.lineBreak = LineBreak.EXPLICIT;
			initTextFlow("A\nB", format); // has an explicit new line character to ensure two lines
			factory.compositionBounds = bounds;
			factory.createTextLines(createLineCallback, tf);
			assertTrue("Did not truncate when explicit line breaking is used", factory.isTruncated);

			// No lines case 1: compose height allows no line
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line0Extent/2; // less than what one line requires
			initTextFlow(text, null);
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions();
			factory.createTextLines(createLineCallback,tf);
			assertTrue("Composed one or more lines when compose height allows none", _lines.length == 0 && factory.isTruncated);

			// No lines case 2: 0 line count limit
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = contentHeight; // enough to fit all content
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 0);
			factory.createTextLines(createLineCallback,tf);
			assertTrue("Composed one or more lines when line count limit is 0", _lines.length == 0 && factory.isTruncated);

			// No lines case 3: truncation indicator is too large
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200;
			bounds.height = 10;
			//bounds.height = contentHeight - 1; // just shy of what the truncation indicator (same as original text) requires
			factory.compositionBounds = bounds;
			initTextFlow(text, null);
			factory.truncationOptions = new TruncationOptions(text);
			factory.createTextLines(createLineCallback, tf);
			assertTrue("Composed one or more lines when compose height does not allow truncation indicator itself to fit", _lines.length == 0 && factory.isTruncated);

			// Verify truncation if composing to fit in bounds
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line1Extent; // should fit two lines
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions();
			factory.createTextLines(createLineCallback,tf);
			assertTrue("Invalid truncation results when composing to fit in bounds (lineCount)", _lines.length == 2 && factory.isTruncated);
			line = _lines[1] as TextLine;
			lineExtent = tf.configuration.overflowPolicy == OverflowPolicy.FIT_ANY ? line.y - line.ascent : line.y + line.descent;
			assertTrue("Invalid truncation results when composing to fit in bounds", lineExtent <= line1Extent);

			// Verify truncation if composing to fit in a line count limit
			_lines.splice(0); _textLen = 0; // reset
			bounds.width = 200; bounds.height = NaN;
			bounds.left = 0; bounds.top = 0;
			initTextFlow(text,null);
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 2);
			factory.createTextLines(createLineCallback, tf);
			assertTrue("Invalid truncation results when composing to fit in a line count limit", _lines.length == 2 && factory.isTruncated);

			// Verify truncation if composing to fit in bounds and a line count limit; the former dominates
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line0Extent; // should fit one line
			initTextFlow(text,null);
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 2);
			factory.createTextLines(createLineCallback, tf); // line count limit of 2
			assertTrue("Invalid truncation results when multiple truncation criteria provided", _lines.length == 1 && factory.isTruncated);
			line = _lines[0] as TextLine;
			lineExtent = tf.configuration.overflowPolicy == OverflowPolicy.FIT_ANY ? line.y - line.ascent : line.y + line.descent;
			assertTrue("Invalid truncation results when multiple truncation criteria provided", lineExtent <= line0Extent);


			// Verify truncation if composing to fit in bounds and a line count limit; the latter dominates
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line1Extent; // should fit two lines
			initTextFlow(text,null);
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 1);
			factory.createTextLines(createLineCallback, tf); // line count limit of 1
			assertTrue("Invalid truncation results when multiple truncation criteria provided", _lines.length == 1 && factory.isTruncated);
			line = _lines[0] as TextLine;
			lineExtent = tf.configuration.overflowPolicy == OverflowPolicy.FIT_ANY ? line.y - line.ascent : line.y + line.descent;
			assertTrue("Invalid truncation results when multiple truncation criteria provided", lineExtent <= line1Extent);


			// Verify truncated text content with default truncation indicator (line count limit)
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN;
			customFactory.compositionBounds = bounds;
			initTextFlow(text,null)
			customFactory.truncationOptions = new TruncationOptions(null, 2);
			customFactory.createTextLines(createLineCallback, tf);
			truncationIndicatorIndex = customFactory.truncationOptions.truncationIndicator.lastIndexOf(TruncationOptions.HORIZONTAL_ELLIPSIS);
			assertTrue("Default truncation indicator not present at the end of the truncated string", truncationIndicatorIndex+TruncationOptions.HORIZONTAL_ELLIPSIS.length == customFactory.truncationOptions.truncationIndicator.length && customFactory.isTruncated);
			originalContentPrefix = customFactory.truncationOptions.truncationIndicator.slice(0, truncationIndicatorIndex);
			assertTrue("Original content before truncation indicator mangled", text.indexOf(originalContentPrefix) == 0);

			// Verify truncation if composing to fit in bounds and a line count limit; the former dominates
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line0Extent; // should fit one line
			initTextFlow(text,null);
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 2);
			factory.createTextLines(createLineCallback, tf); // line count limit of 2
			assertTrue("Invalid truncation results when multiple truncation criteria provided", _lines.length == 1 && factory.isTruncated);
			line = _lines[0] as TextLine;
			lineExtent = StringTextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line.y - line.ascent : line.y + line.descent;
			assertTrue("Invalid truncation results when multiple truncation criteria provided", lineExtent <= line0Extent);

			// Verify truncation if composing to fit in bounds and a line count limit; the latter dominates
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line1Extent; // should fit two lines
			initTextFlow(text,null);
			factory.compositionBounds = bounds;
			factory.truncationOptions = new TruncationOptions(null, 1);
			factory.createTextLines(createLineCallback, tf); // line count limit of 1
			assertTrue("Invalid truncation results when multiple truncation criteria provided", _lines.length == 1 && factory.isTruncated);
			line = _lines[0] as TextLine;
			lineExtent = StringTextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line.y - line.ascent : line.y + line.descent;
			assertTrue("Invalid truncation results when multiple truncation criteria provided", lineExtent <= line1Extent);

			// Verify truncated text content with default truncation indicator (line count limit)
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN;
			customFactory.compositionBounds = bounds;
			customFactory.truncationOptions = new TruncationOptions(null, 2);
			customFactory.createTextLines(createLineCallback, tf);
			truncationIndicatorIndex = customFactory.truncationOptions.truncationIndicator.lastIndexOf(TruncationOptions.HORIZONTAL_ELLIPSIS);
			assertTrue("Default truncation indicator not present at the end of the truncated string", truncationIndicatorIndex+TruncationOptions.HORIZONTAL_ELLIPSIS.length == customFactory.truncationOptions.truncationIndicator.length && customFactory.isTruncated);
			originalContentPrefix = customFactory.truncationOptions.truncationIndicator.slice(0, truncationIndicatorIndex);
			assertTrue("Original content before truncation indicator mangled", text.indexOf(originalContentPrefix) == 0);


			// Verify truncated text content with default truncation indicator (fit in bounds)
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line1Extent; // should fit two lines;
			customFactory.compositionBounds = bounds;
			customFactory.truncationOptions = new TruncationOptions();
			customFactory.createTextLines(createLineCallback, tf);
			truncationIndicatorIndex = customFactory.truncationOptions.truncationIndicator.lastIndexOf(TruncationOptions.HORIZONTAL_ELLIPSIS);
			assertTrue("Default truncation indicator not present at the end of the truncated string", truncationIndicatorIndex+TruncationOptions.HORIZONTAL_ELLIPSIS.length == customFactory.truncationOptions.truncationIndicator.length && customFactory.isTruncated);
			originalContentPrefix = customFactory.truncationOptions.truncationIndicator.slice(0, truncationIndicatorIndex);
			assertTrue("Original content before truncation indicator mangled", text.indexOf(originalContentPrefix) == 0);


			// Verify truncated text content with default truncation indicator (fit in bounds)
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = line1Extent; // should fit two lines;
			customFactory.compositionBounds = bounds;
			customFactory.truncationOptions = new TruncationOptions();
			customFactory.createTextLines(createLineCallback, tf);
			truncationIndicatorIndex = customFactory.truncationOptions.truncationIndicator.lastIndexOf(TruncationOptions.HORIZONTAL_ELLIPSIS);
			assertTrue("Default truncation indicator not present at the end of the truncated string", truncationIndicatorIndex+TruncationOptions.HORIZONTAL_ELLIPSIS.length == customFactory.truncationOptions.truncationIndicator.length && customFactory.isTruncated);
			originalContentPrefix = customFactory.truncationOptions.truncationIndicator.slice(0, truncationIndicatorIndex);
			assertTrue("Original content before truncation indicator mangled", text.indexOf(originalContentPrefix) == 0);

			// Verify truncated text content with custom truncation indicator
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN;
			customTruncationIndicator = "<SNIP>";
			customFactory.compositionBounds = bounds;
			customFactory.truncationOptions = new TruncationOptions(customTruncationIndicator, 2);
			customFactory.createTextLines(createLineCallback,tf);
			truncationIndicatorIndex = customFactory.truncationOptions.truncationIndicator.lastIndexOf(customTruncationIndicator);
			assertTrue("Truncation indicator not present at the end of the truncated string", truncationIndicatorIndex+customTruncationIndicator.length == customFactory.truncationOptions.truncationIndicator.length && customFactory.isTruncated);
			originalContentPrefix = customFactory.truncationOptions.truncationIndicator.slice(0, truncationIndicatorIndex);
			assertTrue("Original content before truncation indicator mangled", text.indexOf(originalContentPrefix) == 0);

			// Verify original text replacement is optimal
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN;
			initTextFlow(text,null);
			customFactory.compositionBounds = bounds;
			customTruncationIndicator = '\u200B'; // Zero-width space : should not require *any* original content that fits to be replaced
			customFactory.truncatedTextFlowCallback = truncatedCallback;
			customFactory.truncationOptions = new TruncationOptions(customTruncationIndicator, 1);
			customFactory.createTextLines(createLineCallback,tf);
			var indicatorLen:int = customTruncationIndicator.length;
			// TextFlow.textLength includes the length of the paragraph terminator string, so _truncatedTextLen
			// in the textflow factory case is not a direct substitute for truncatedText.length in the string factory case.
			assertTrue("Replacing more original content than is neccessary", this._truncatedTextLen == line0TextLen+customTruncationIndicator.length+1 && customFactory.isTruncated);

			// Verify original text replacement is optimal (RTL text)
			_lines.splice(0); _textLen = 0; // reset
			bounds.left = 0; bounds.top = 0;
			bounds.width = 200; bounds.height = NaN;
			initTextFlow(rtlText, formatForRtlTest);
			customFactory.compositionBounds = bounds;
			customTruncationIndicator = '\u200B'; // Zero-width space : should not require *any* original content that fits to be replaced
			customFactory.truncationOptions = new TruncationOptions(customTruncationIndicator, 1);
			customFactory.createTextLines(createLineCallback, tf);
			assertTrue("Replacing more original content than is neccessary (RTL text)", this._truncatedTextLen == rtlLine0TextLen+customTruncationIndicator.length+1 && customFactory.isTruncated);

		}

		public function compositionCompletionEventTest():void
		{
			var gotEvent:Boolean = false;
			var textFlow:TextFlow = SelManager.textFlow;
			textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, completionHandler);
			var charFormat:TextLayoutFormat = new TextLayoutFormat();
			charFormat.fontSize=48;
			SelManager.selectRange(0,textFlow.textLength);
			(SelManager as EditManager).applyLeafFormat(charFormat);
			assertTrue("Didn't get the compositionCompletionEvent", gotEvent == true);

			function completionHandler(event:CompositionCompleteEvent): void
			{
				gotEvent = true;
				textFlow.removeEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, completionHandler);
			}
		}
	}
}
