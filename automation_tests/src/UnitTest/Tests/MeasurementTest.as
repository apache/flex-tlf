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
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.TextScrap;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.VerticalAlign;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;



	public class MeasurementTest extends VellumTestCase
	{
		public function MeasurementTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Container";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = MeasurementTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}


		public override function loadTestFile(fileName:String):void
		{
			super.loadTestFile(fileName);

			SelManager.textFlow.blockProgression = writingDirection[0];;
			SelManager.textFlow.direction = writingDirection[1];;
			SelManager.flushPendingOperations();
		}
		
		public function listNegativeMarkersMeasure():void
		{ listNegativeMarkers(); }

		public function listNegativeMarkers():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);

			textFlow.blockProgression = writingDirection[0];
			textFlow.direction = writingDirection[1];
			if (this.TestData.measure == "true")
				controller.setCompositionSize(NaN,NaN);
			textFlow.flowComposer.updateAllControllers();
			// listmarkers have no padding and stick out to the side set by direction/blockProgression
			var initialBounds:Rectangle = controller.getContentBounds();
			
			// now turn off the list padding and get the bounds again
			var listElem:FlowElement = textFlow.getElementByID("theList");
			listElem.paddingLeft = undefined;
			listElem.paddingRight = undefined;
			listElem.paddingTop = undefined;
			listElem.paddingBottom = undefined;
			textFlow.flowComposer.updateAllControllers();
			var normalBounds:Rectangle = controller.getContentBounds();
			
			// some simple tests that the bounds gets mutated
			if (textFlow.blockProgression == BlockProgression.TB)
			{
				if (textFlow.direction == Direction.LTR)
					assertTrue("Bad list bounds",initialBounds.x < normalBounds.x);
				else
					assertTrue("Bad list bounds",initialBounds.right > normalBounds.right);
			}
			else
				assertTrue("Bad list bounds",initialBounds.y < normalBounds.y);	
		}
		
		
		public function listInsideAlignmentMeasure():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			
			textFlow.blockProgression = writingDirection[0];
			textFlow.direction = writingDirection[1];
			textFlow.flowComposer.updateAllControllers();
			// listmarkers have no padding and stick out to the side set by direction/blockProgression
			var bounds:Rectangle = controller.getContentBounds();
			
			// some simple tests that the bounds gets mutated
			if (textFlow.blockProgression == BlockProgression.TB)
				assertTrue("Bad list bounds",bounds.x  == 0 && bounds.width == controller.compositionWidth);
			else
				assertTrue("Bad list bounds",bounds.y  == 0 && bounds.height == controller.compositionHeight);
		}
		/** Set the vertical and horizontal alignment in the current TextFlow */
		private function setAlignment(horizontalAlign:String, verticalAlign:String):void
		{
			SelManager.selectAll();
			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat(SelManager.textFlow.getFirstLeaf().getParagraph().computedFormat);
			paragraphFormat.textAlign = horizontalAlign;
			var containerFormat:TextLayoutFormat = new TextLayoutFormat(SelManager.textFlow.computedFormat);
			containerFormat.verticalAlign = verticalAlign;
			(SelManager as EditManager).applyFormat(null,paragraphFormat,containerFormat);
		}

		/* Given a container that is composed up to date, walk its display list
		 * to find all the children and get the largest extent of container.
		 * Is this equivalent to calling getBounds on the container???
		 */
		private function getContentBounds(cont:DisplayObjectContainer):Rectangle
		{
			var left:Number;
			var right:Number
			var top:Number
			var bottom:Number;

			for (var i:int = 0; i < cont.numChildren; i++)
			{
				var child:DisplayObject = cont.getChildAt(i);
				var bounds:Rectangle = child.getBounds(cont);
				left = isNaN(left) ? bounds.left : Math.min(left, bounds.left);
				top = isNaN(top) ? bounds.top : Math.min(top, bounds.top);
				right = isNaN(right) ? bounds.right : Math.max(right, bounds.right);
				bottom = isNaN(bottom) ? bounds.bottom : Math.max(bottom, bounds.bottom);
			}

			return new Rectangle(left, top, right - left, bottom - top);
		}

		/** Given a container that is composed up to date, walk its display list to find
		 * all the TextLines. Follow them back to the TextFlowLines, and create an array
		 * that has the ending position of each line in the container.
		 */
		private function getLineEnds(cont:DisplayObjectContainer):Array
		{
			var lineEnds:Array = [];
			for (var i:int = 0; i < cont.numChildren; i++)
			{
				var textLine:TextLine = cont.getChildAt(i) as TextLine;
				if (textLine)
				{
					var textFlowLine:TextFlowLine = TextFlowLine(textLine.userData);
					lineEnds.push(textFlowLine.absoluteStart + textFlowLine.textLength);
				}
			}

			return lineEnds;
		}

		/** Given a container that is composed up to date, walk its display list to find
		 * all the TextLines. Follow them back to the TextFlowLines, and create an array
		 * that has the ending position of each line in the container.
		 */
		private function getLongestLine(cont:DisplayObjectContainer):Number
		{
			var width:Number = 0;
			for (var i:int = 0; i < cont.numChildren; i++)
			{
				var textLine:TextLine = cont.getChildAt(i) as TextLine;
				if (textLine)
					width = Math.max(textLine.textWidth, width);
			}

			return width;
		}


		/** Run measurement tests on a container.
		 * First compares the contentBounds, as generated by looking at the display list, to the contentWidth and contentHeight
		 * properties -- these should be close, but won't be identical (the contentBounds is inked bounds, and contentWidth and
		 * contentHeight are logical bounds.
		 *
		 * Then resets the composition width & height to the unjustified content width & height and checks to make sure that
		 * the line breaks were not changed as a result.
		 */
		public function testMeasurementValues(cont:ContainerController):void
		{
			cont.flowComposer.updateAllControllers();

			var blockProgression:String = cont.textFlow.computedFormat.blockProgression;
			var lineEndsBefore:Array = getLineEnds(cont.container as DisplayObjectContainer);

			// Keep logical width the same and resize to fit height
			if (blockProgression == BlockProgression.TB)
				cont.setCompositionSize(cont.compositionWidth, cont.contentHeight);
			else
				cont.setCompositionSize(cont.contentWidth, cont.compositionHeight);
			cont.flowComposer.updateAllControllers();
			assertTrue("Expected whole flow to fit in container", cont.textLength == cont.textFlow.textLength);
			if (blockProgression == BlockProgression.TB)
				assertTrue("Expected new height (tb) to fit to size (not be extra large)", cont.contentHeight+2 > cont.compositionHeight);
			else
				assertTrue("Expected new logical height (rl) to fit to size (not be extra large)", cont.contentWidth+2 > cont.compositionWidth);

			var longestLineWidth:Number = getLongestLine(cont.container as DisplayObjectContainer);
			assertTrue("Expected longest line to fit in logical content width", longestLineWidth <= cont.contentWidth);

			// lineEndsBefore and lineEndsAfter should be equal
			var lineEndsAfter:Array = getLineEnds(cont.container as DisplayObjectContainer);
			assertTrue("more or less lines after resizing. Expected same line ends", lineEndsBefore.length == lineEndsAfter.length);
			for (var i:int = 0; i < lineEndsBefore.length; ++i)
				assertTrue ("mismatch in line ends after resizing. Expected same line ends", lineEndsBefore[i] == lineEndsAfter[i]);
		}

	//	private var horizontalAlignmentValues:Array = [TextAlign.LEFT, TextAlign.CENTER, TextAlign.RIGHT, TextAlign.JUSTIFY];
		private var horizontalAlignmentValues:Array = [TextAlign.LEFT, TextAlign.CENTER, TextAlign.RIGHT];
		private var verticalAlignmentValues:Array = [VerticalAlign.TOP, VerticalAlign.MIDDLE, VerticalAlign.BOTTOM, VerticalAlign.JUSTIFY];

		/** Test all combinations of horizontal and vertical alignment.
		 * Justify is not working, so I've left it off for now. Question is off to Jerry.
		 */
		public function measureAlignment():void
		{
			for each (var textAlign:String in horizontalAlignmentValues)
			{
				for each (var verticalAlign:String in verticalAlignmentValues)
				{
					setAlignment(textAlign, verticalAlign);
					testMeasurementValues(SelManager.textFlow.flowComposer.getControllerAt(0));
				}
			}
		}

		// Floats with a fair amount of text that goes beside them
		private var floatsLongText:XML =
  			<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" textIndent="15" paragraphSpaceAfter="15" paddingTop="4" paddingLeft="4">
    			<flow:p>Images in a flow are a good thing. For example, here is a float. It should show on the left: <flow:img float="left" height="50" width="19" source="surprised.png"/>. Do you agree? Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. </flow:p>
     			<flow:p>Here is another float, it should show up on the right: <flow:img float="right" height="50" elementHeight="200" width="19" source="surprised.png"/>. Do you agree? Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. Another sentence here. </flow:p>
  			</flow:TextFlow>;

		// Floats with very little text that goes beside them
		private var floatsShortText:XML =
  			<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" textIndent="15" paragraphSpaceAfter="15" paddingTop="4" paddingLeft="4">
    			<flow:p>Here is a left float<flow:img float="left" height="50" width="19" source="surprised.png"/>.</flow:p>
     			<flow:p>Here is a right float<flow:img float="right" height="50" elementHeight="200" width="19" source="surprised.png"/>.</flow:p>
  			</flow:TextFlow>;

		// Floats with very little text that goes beside them
		private var floatsAtStartText:XML =
  			<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" textIndent="15" paragraphSpaceAfter="15" paddingTop="4" paddingLeft="4">
    			<flow:p><flow:img float="left" height="50" width="19" source="surprised.png"/>Left float at start.</flow:p>
     			<flow:p><flow:img float="right" height="50" elementHeight="200" width="19" source="surprised.png"/>Right float at start.</flow:p>
  			</flow:TextFlow>;

  		private var floatMarkup:Array = [floatsLongText, floatsShortText, floatsAtStartText];

  		/** Run measurement tests on a TextFlow generated from XML markup. */
		public function measureMarkup(markup:XML):void
		{
   			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
   			setUpFlowForTest(textFlow);

   			testMeasurementValues(textFlow.flowComposer.getControllerAt(0));
		}

		/** Run measurement tests on floats examples. Doesn't work for now, because it requires a connection between the parcels,
		 * so the unjustified width is the sum of the unjustified width in each of the parcels from left to right.
		 **/
		public function measureFloats():void
		{
		//	for (var i:int = 0; i < floatMarkup.length; i++)
		//		measureMarkup(floatMarkup[i]);
		}

		/* TO DO's
		 * Add test that runs with overflowPolicy fitAny.
		 * Add test for trailing whitespace in line break explicit
		 * Add test for last line justification
		 */

		/** Test explicit line breaks, both shorter than compositionWidth and longer than compositionWidth,
		 * with every different alignment type.
		 */
		public function testExplicitAlignment():void
		{
			var textFlow:TextFlow = TextConverter.importToFlow("Hello", TextConverter.PLAIN_TEXT_FORMAT);
			testExplicitAllHorizontalAlignment(textFlow);
			textFlow = TextConverter.importToFlow("We dare not forget today that we are the heirs of that first revolution. Let the word go forth from this time and place, to friend and foe alike, that the torch has been passed to a new generation", TextConverter.PLAIN_TEXT_FORMAT);
			testExplicitAllHorizontalAlignment(textFlow);
		}

		private function testExplicitAllHorizontalAlignment(textFlow:TextFlow):void
		{
			setUpFlowForTest(textFlow);
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			controller.setCompositionSize(300, 20);
			// vellum unit always comes up a fixed size and stageWidth is not accessible in a security sandbox
			controller.container.x = 400; // (controller.container.stage.stageWidth - controller.compositionWidth) / 2;
			textFlow.lineBreak = LineBreak.EXPLICIT;
			for each (var textAlign:String in horizontalAlignmentValues)
			{
				testExplicitAlignmentInBounds(textFlow, textAlign);
	   			testMeasurementValues(textFlow.flowComposer.getControllerAt(0));
			}
		}

		private function drawBounds(container:Sprite, width:Number, height:Number):void
		{
			var g:Graphics = container.graphics;
			g.beginFill(0xEEEEEE);
			g.drawRect(0, 0, width, height);
			g.endFill();
		}

		private function testExplicitAlignmentInBounds(textFlow:TextFlow, textAlign:String):void
		{
			const marginOfError:int = 3;

			textFlow.textAlign = textAlign;
			textFlow.flowComposer.updateAllControllers();
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			drawBounds(controller.container as Sprite, controller.compositionWidth, controller.compositionHeight);
			var bounds:Rectangle = getContentBounds(controller.container as DisplayObjectContainer);
			var paragraph:ParagraphElement = textFlow.getFirstLeaf().getParagraph();	// assume all paragraphs uniform
			var paragraphFormat:ITextLayoutFormat = paragraph.computedFormat;
			assertTrue("TextAlign not set! Expected " + textAlign, "got " + paragraphFormat.textAlign, textAlign == paragraphFormat.textAlign);
			switch (paragraphFormat.textAlign)
			{
				case TextAlign.START:
				case TextAlign.JUSTIFY:
					textAlign = (paragraphFormat.direction == Direction.LTR) ? TextAlign.LEFT : TextAlign.RIGHT;
					break;
				case TextAlign.END:
					textAlign = (paragraphFormat.direction == Direction.LTR) ? TextAlign.RIGHT : TextAlign.LEFT;
			}

			if (textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				switch(paragraphFormat.textAlign)
				{
					case TextAlign.LEFT:
						assertTrue("not left aligned, got " + bounds.left + "expected zero", bounds.left <= marginOfError);
						break;
					case TextAlign.RIGHT:
						assertTrue("not right aligned, got " + bounds.right + "expected " + controller.compositionWidth,
							Math.abs(bounds.right - controller.compositionWidth) <= marginOfError);
						break;
					case TextAlign.CENTER:
						assertTrue("not center aligned, got " + bounds.left + bounds.width/2 + "expected " + controller.compositionWidth/2,
							Math.abs((bounds.left + bounds.width/2) - (controller.compositionWidth/2)) <= marginOfError);
						break;
				}
			}
			else
			{
				switch(paragraphFormat.textAlign)
				{
					case TextAlign.LEFT:
						assertTrue("not left aligned, got " + bounds.top + "expected zero", bounds.top <= marginOfError);
						break;
					case TextAlign.RIGHT:
						assertTrue("not right aligned, got " + bounds.bottom + "expected " + controller.compositionHeight,
							Math.abs(bounds.bottom - controller.compositionHeight) <= marginOfError);
						break;
					case TextAlign.CENTER:
						assertTrue("not center aligned, got " + bounds.top + bounds.height/2 + "expected " + controller.compositionHeight/2,
							Math.abs((bounds.top + bounds.height/2) - (controller.compositionHeight/2)) <= marginOfError);
						break;
				}
			}
		}
	}
}
