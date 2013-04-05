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
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.VerticalAlign;
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.utils.GeometryUtil;
	import flashx.textLayout.utils.NavigationUtil;

	use namespace tlf_internal;


	public class BoxTest extends VellumTestCase
	{
		private var  _textFlow:TextFlow;
		private var _editManager:IEditManager;
		
		public function BoxTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null):void
		{
			super (methodName, testID, testConfig);
			TestData.fileName = null;
			
			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Composition";	
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			ts.addTestDescriptor (new TestDescriptor (BoxTest,"paddingAndMarginOnDiv", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (BoxTest,"negativePaddingAndMarginOnDiv", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (BoxTest,"verticalSpaceCollapse", testConfig, null) );

			ts.addTestDescriptor (new TestDescriptor (BoxTest,"ilgMarginsAndPaddingStart", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (BoxTest,"ilgMarginsAndPaddingEnd", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (BoxTest,"ilgMarginsAndPaddingBeforeAndAfter", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (BoxTest,"ilgMarginsAndPaddingStartStrikeAndUnderline", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (BoxTest,"ilgMarginsAndPaddingEndStrikeAndUnderline", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (BoxTest,"ilgMarginsAndPaddingBeforeAndAfterStrikeAndUnderline", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (BoxTest,"floatMarginsAndPaddingLeftAndRight", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (BoxTest,"floatMarginsAndPaddingUpAndDown", testConfig, null) );

			
			// We only need one version of these tests, they supply their own markup
			if (testConfig.writingDirection[0] == BlockProgression.TB && testConfig.writingDirection[1] == Direction.LTR)
			{
				ts.addTestDescriptor(new TestDescriptor (BoxTest,"textFlowPadding", testConfig, null) );
				ts.addTestDescriptor (new TestDescriptor (BoxTest,"rlPaddingOnDiv", testConfig, null) );	
				ts.addTestDescriptor (new TestDescriptor (BoxTest,"boundsWithPadding", testConfig, null) );
			}			
		}
		
		private static var _englishContent:String = "There are many such lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.\n" + 
			"The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Within the furnace were seen the curling and riotous flames, and the burning marble, almost molten with the intensity of heat; while without, the reflection of the fire quivered on the dark intricacy of the surrounding forest, and showed in the foreground a bright and ruddy little picture of the hut, the spring beside its door, the athletic and coal-begrimed figure of the lime-burner, and the half-frightened child, shrinking into the protection of his father's shadow. And when again the iron door was closed, then reappeared the tender light of the half-full moon, which vainly strove to trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, though thus far down into the valley the sunshine had vanished long and long ago.\n" + 
			'“Father, what is that?” asked the little boy, leaving his play, and pressing betwixt his father’s knees.' + 
			'“O, some drunken man, I suppose,” answered the lime-burner; “some merry fellow from the barroom in the village, who dared not laugh loud enough within doors lest he should blow the roof of the house off. So here he is, shaking his jolly sides at the foot of Graylock.”\n' + 
			'“But, father,” said the child, more sensitive than the obtuse, middle-aged clown, “he does not laugh like a man that is glad. So the noise frightens me!”';

		private function initializeFlow(content:String):void
		{
			_textFlow = TextConverter.importToFlow(content, TextConverter.PLAIN_TEXT_FORMAT);
			VellumTestCase.testApp.contentChange (_textFlow);
			TestDisplayObject = VellumTestCase.testApp.getDisplayObject();
			TestFrame = _textFlow.flowComposer.getControllerAt(0);
			if (TestFrame.rootElement)
			{
				// Set the writing direction specified by the test
				_textFlow.blockProgression = writingDirection[0];
				_textFlow.direction        = writingDirection[1];
				SelManager = EditManager(_textFlow.interactionManager);
				if(SelManager) 
				{
					SelManager.selectRange(0, 0);
					//make sure there is never any blinking when running these tests
					setCaretBlinkRate (0);
				}
				_editManager = SelManager;
			}
			_textFlow.flowComposer.updateAllControllers();
		}
		
		private function applyLogicalMarginAndPadding(element:Object, totalLeft:Number, totalTop:Number, totalRight:Number, totalBottom:Number):void
		{
			var verticalText:Boolean = TestFrame.textFlow.computedFormat.blockProgression == BlockProgression.RL;
			var format:TextLayoutFormat = new TextLayoutFormat(element.format);
			if (verticalText)
			{
				format.paddingLeft = totalBottom;
				format.paddingTop = totalLeft;
				format.paddingRight = totalTop;
				format.paddingBottom = totalRight;
			}
			else
			{
				format.paddingLeft = totalLeft;
				format.paddingTop = totalTop;
				format.paddingRight = totalRight;
				format.paddingBottom = totalBottom;
			}
		/*	if (verticalText)		FOR WHEN MARGINS ARE TURNED BACK ON
			{
				format.marginLeft = totalBottom / 2;
				format.paddingLeft = totalBottom / 2;
				format.marginTop = totalLeft / 2;
				format.paddingTop = totalLeft / 2;
				format.marginRight = totalTop / 2;
				format.paddingRight = totalTop / 2;
				format.marginBottom = totalRight / 2;
				format.paddingBottom = totalRight / 2;
			}
			else
			{
				format.marginLeft = totalLeft / 2;
				format.paddingLeft = totalLeft / 2;
				format.marginTop = totalTop / 2;
				format.paddingTop = totalTop / 2;
				format.marginRight = totalRight / 2;
				format.paddingRight = totalRight / 2;
				format.marginBottom = totalBottom / 2;
				format.paddingBottom = totalBottom / 2;
			} */
			element.format = format;
		}
		
		private function createDiv(rootElement:ContainerFormattedElement, startIndex:int, elementCount:int):DivElement
			// Create a div element out of some of a root element's children
		{
			var div:DivElement = new DivElement();
			for (var i:int = startIndex + elementCount - 1; i >= startIndex; --i)
			{
				var child:FlowElement = _textFlow.getChildAt(i);
				div.replaceChildren(0, 0, child);
			}
			rootElement.replaceChildren(startIndex, startIndex, div);
			return div;
		}
		
		private function paddingAndMarginOnDivInternal(left:Number, right:Number):void
		{
			initializeFlow(_englishContent);
			
			// take the conversation  (last 3 paragraphs) and make it an indented div
			var div:DivElement = createDiv(_textFlow, _textFlow.numChildren - 3, 3);
			applyLogicalMarginAndPadding(div, left, 0, right, 0);
			var format:TextLayoutFormat = new TextLayoutFormat(div.format);
			format.textAlign = TextAlign.JUSTIFY;
			div.format = format;
			SelManager.selectRange(div.getAbsoluteStart(), div.getAbsoluteStart() + div.textLength);	// select everything so we can see highlight area
			_textFlow.flowComposer.updateAllControllers();
			
			var firstLineIndexInDiv:int = _textFlow.flowComposer.findLineIndexAtPosition(div.getAbsoluteStart());
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(firstLineIndexInDiv);
			var bbox:Rectangle = textFlowLine.getBounds();
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var verticalText:Boolean = (_textFlow.computedFormat.blockProgression == BlockProgression.RL);
			var logicalWidth:Number = verticalText ? controller.compositionHeight : controller.compositionWidth;
			
			if (verticalText)
			{
				assertTrue("Expected line to be indented on left using div's paddingLeft and marginLeft", bbox.top == left);
				assertTrue("Expected line to be indented on right using div's paddingRight and marginRight", Math.abs((bbox.height + left + right) - logicalWidth) < 1);
			}
			else
			{
				assertTrue("Expected line to be indented on left using div's paddingLeft and marginLeft", bbox.left == left);
				assertTrue("Expected line to be indented on right using div's paddingRight and marginRight", Math.abs((bbox.width + left + right) - logicalWidth) < 1);
			}
		}
		public function paddingAndMarginOnDiv():void
		{
			paddingAndMarginOnDivInternal(20, 30);
		}

		public function negativePaddingAndMarginOnDiv():void
		{
			paddingAndMarginOnDivInternal(-20, -30);
		}
		
		private function saveCompositionResults(textFlow:TextFlow):Array
		{
			// Save off line positions
			var lineArray:Array = [];
			var tfl:TextFlowLine;
			var verticalText:Boolean = textFlow.computedFormat.blockProgression == BlockProgression.RL;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			for (var i:int = 0; i < flowComposer.numLines; ++i)
			{
				tfl = flowComposer.getLineAt(i)
				lineArray.push(verticalText ? tfl.x : tfl.y);
			}
			return lineArray;
		}

		private function assertCompositionResultsMatch(textFlow:TextFlow, lineArray:Array):void
		{
			var tfl:TextFlowLine;
			var verticalText:Boolean = textFlow.computedFormat.blockProgression == BlockProgression.RL;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			assertTrue("Number of lines don't match", flowComposer.numLines == lineArray.length);
			for (var i:int = 0; i < flowComposer.numLines; ++i)
			{
				tfl = flowComposer.getLineAt(i);
				assertTrue("Line has moved, should match previous location", Math.abs(lineArray[i] - (verticalText ? tfl.x : tfl.y)) < 1);
			}
		}
		
		public function verticalSpaceCollapse():void
		{
			var originalPadding:Number = 30;
			var compositionResults:Array;
			
			initializeFlow(_englishContent);
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			applyLogicalMarginAndPadding(controller, 0, 0, 0, 0);
			
			// Take the first two paragraphs, wrap them in a div element and apply a margin bottom on the first, and
			// the same margin top on the second
			var divElement:DivElement = createDiv(_textFlow, 0, 2);
			var firstPara:FlowElement = divElement.getChildAt(0);
			applyLogicalMarginAndPadding(firstPara, 0, 0, 0, originalPadding);
			var secondPara:FlowElement = divElement.getChildAt(1);
			applyLogicalMarginAndPadding(secondPara, 0, originalPadding, 0, 0);	
			_textFlow.flowComposer.updateAllControllers();
			
			// save off the composition results
			compositionResults = saveCompositionResults(_textFlow);
			
			// decrease the padding bottom of the first paragraph, composition results should match (it takes the max)
			applyLogicalMarginAndPadding(firstPara, 0, 0, 0, originalPadding - 10);
			_textFlow.flowComposer.updateAllControllers();
			assertCompositionResultsMatch(_textFlow, compositionResults);
			
			// restore the padding bottom of the first paragraph, decrease the padding top of the second paragraph
			// composition results should match (it takes the max)
			applyLogicalMarginAndPadding(firstPara, 0, 0, 0, originalPadding);
			applyLogicalMarginAndPadding(secondPara, 0, originalPadding - 10, 0, 0);	
			_textFlow.flowComposer.updateAllControllers();
			assertCompositionResultsMatch(_textFlow, compositionResults);

			// Add a top padding to the first paragraph, and a bottom padding to the last
			applyLogicalMarginAndPadding(firstPara, 0, originalPadding, 0, 0);	
			applyLogicalMarginAndPadding(secondPara, 0, 0, 0, originalPadding);	
			_textFlow.flowComposer.updateAllControllers();
			compositionResults = saveCompositionResults(_textFlow);

			// Add a top and bottom padding to the div, results should be unchanged from previous (div padding and child padding collapse)
			applyLogicalMarginAndPadding(divElement, 0, originalPadding, 0, originalPadding);	
			_textFlow.flowComposer.updateAllControllers();
			assertCompositionResultsMatch(_textFlow, compositionResults);
			
			// Add a controller padding and check that the block collapses with it
			var verticalText:Boolean = _textFlow.computedFormat.blockProgression == BlockProgression.RL;
			var totalTop:Number = originalPadding;
			var totalBottom:Number = originalPadding;
			applyLogicalMarginAndPadding(controller, 0, totalTop, 0, totalBottom);
			_textFlow.flowComposer.updateAllControllers();
			assertCompositionResultsMatch(_textFlow, compositionResults);
		}
		
		private function ilgMarginAndPaddingSetup(startIndex:int, width:int = 30, height:int = 20, float:String = null):InlineGraphicElement
		{
			// Create a simple rectangular display object for the float
			var displayObject:Sprite = new Sprite();
			var g:Graphics = displayObject.graphics;
			g.beginFill(0xFF0000);
			g.drawRect(0, 0, width, height);
			g.endFill();
			
			SelManager.insertInlineGraphic(displayObject,width,height, float, new SelectionState(_textFlow, startIndex, startIndex));
			return _textFlow.findLeaf(startIndex) as InlineGraphicElement;
		}
		
		private function ilgMarginsAndPaddingStartInternal(paddingStart:Number):int
			// Test margins that are inline before the ilg (to the left in tb/ltr)
		{
			var flowComposer:IFlowComposer = _textFlow.flowComposer;
			
			// Insert graphic in the middle of the second line
			var textFlowLine:TextFlowLine = flowComposer.getLineAt(2);
			var startIndex:int = textFlowLine.absoluteStart + textFlowLine.textLength/2;
			
			var ilg:InlineGraphicElement = ilgMarginAndPaddingSetup(startIndex);
			
			var verticalText:Boolean = _textFlow.computedFormat.blockProgression == BlockProgression.RL;
			applyLogicalMarginAndPadding(ilg, paddingStart, 0, 0, 0);
			flowComposer.updateAllControllers();
			
			// Check that text before the graphic leaves a margin on the left side
			var returnArray:Array = GeometryUtil.getHighlightBounds(new TextRange(_textFlow, startIndex - 1, startIndex));
			var textBBox:Rectangle = returnArray[0].rect.clone(); 
			var textLine:TextLine = returnArray[0].textLine; 
			var globalInlinePt:Point = ilg.graphic.localToGlobal(new Point(0, 0));
			var lineInlinePt:Point = textLine.globalToLocal(globalInlinePt);
			var inlineBBox:Rectangle = new Rectangle(lineInlinePt.x, lineInlinePt.y, ilg.elementWidth, ilg.elementHeight);
			
			if (verticalText)
				assertTrue("Expected margin before the inline", Math.abs(inlineBBox.y - (textBBox.bottom + paddingStart)) < 1);
			else
				assertTrue("Expected margin before the inline", Math.abs(inlineBBox.x - (textBBox.right + paddingStart)) < 1);
			return startIndex;
		}
		
		private function ilgMarginsAndPaddingEndInternal(paddingEnd:Number):int
			// Test margins that are inline after the ilg (to the right in tb/ltr)
		{
			var flowComposer:IFlowComposer = _textFlow.flowComposer;

			// Insert graphic in the middle of the second line
			var textFlowLine:TextFlowLine = flowComposer.getLineAt(2);
			var startIndex:int = textFlowLine.absoluteStart + textFlowLine.textLength/2;
			
			var ilg:InlineGraphicElement = ilgMarginAndPaddingSetup(startIndex);
			
			var verticalText:Boolean = _textFlow.computedFormat.blockProgression == BlockProgression.RL;
			
			// Check that text after the graphic leaves a margin on the right side
			applyLogicalMarginAndPadding(ilg, 0, 0, paddingEnd, 0);
			flowComposer.updateAllControllers();
			
			// Get the bounds of the text
			var posAfterGraphic:int = startIndex + 1;
			var returnArray:Array = GeometryUtil.getHighlightBounds(new TextRange(_textFlow, posAfterGraphic, posAfterGraphic + 1));
			var textBBox:Rectangle = returnArray[0].rect.clone(); 
			var textLine:TextLine = returnArray[0].textLine; 
			
			// Get the physical location of the ILG
			var globalInlinePt:Point = ilg.graphic.localToGlobal(new Point(0, 0));
			var lineInlinePt:Point = textLine.globalToLocal(globalInlinePt);
			var inlineBBox:Rectangle = new Rectangle(lineInlinePt.x, lineInlinePt.y, ilg.elementWidth, ilg.elementHeight);
			
			if (verticalText)
				assertTrue("Expected margin after the inline", Math.abs((inlineBBox.y + inlineBBox.width) - (textBBox.top - paddingEnd)) < 1);
			else
				assertTrue("Expected margin after the inline", Math.abs(inlineBBox.right - (textBBox.x - paddingEnd)) < 1);
			return startIndex;
		}
		
		
		public function ilgMarginsAndPaddingStart():void
			// Test margins that are inline before the ilg (to the left in tb/ltr)
		{
			_textFlow = SelManager.textFlow;
			var marginAndPaddingLeft:Array = [ -20, 20 ];
			var startIndex:int = -1;
			for each (var leftValue:Number in marginAndPaddingLeft)
			{
				if (startIndex >= 0)
					SelManager.deleteText(new SelectionState(_textFlow, startIndex, startIndex + 1));		// delete the inline inserted on the previous time through
				startIndex = ilgMarginsAndPaddingStartInternal(leftValue);
			}
		}
		
		
		public function ilgMarginsAndPaddingEnd():void
			// Test margins that are inline after the ilg (to the right in tb/ltr)
		{
			_textFlow = SelManager.textFlow;
			var marginAndPaddingRight:Array = [ -10, 30 ];

			var startIndex:int = -1;
			for each (var rightValue:Number in marginAndPaddingRight)
			{
				if (startIndex >= 0)
					SelManager.deleteText(new SelectionState(_textFlow, startIndex, startIndex + 1));		// delete the inline inserted on the previous time through
				startIndex = ilgMarginsAndPaddingEndInternal(rightValue);
			}
		}
		
		private function ilgMarginsAndPaddingBeforeAndAfterInternal(paddingUp:Number, paddingDown:Number, float:String = null):int
			// Test margins that are block-direction before the ilg (top in tb/ltr)
		{
			var flowComposer:IFlowComposer = _textFlow.flowComposer;
			var verticalText:Boolean = _textFlow.computedFormat.blockProgression == BlockProgression.RL;
			
			// Insert an inline that takes as much space as a small inline with padding
			// Compare the results to adding an inline that is smaller, but has room for padding
			// smallerSize + padding = largerSize. Lines should be in the same positions.
			var initialWidth:Number = 35;
			var initialHeight:Number = 25;
			var width:Number = initialWidth;
			var height:Number = initialHeight;
			height += paddingUp + paddingDown;
			var textFlowLine:TextFlowLine = flowComposer.getLineAt(2);
			var startIndex:int = textFlowLine.absoluteStart + textFlowLine.textLength/2;
			var ilg:InlineGraphicElement = ilgMarginAndPaddingSetup(startIndex, width, height, float);

			flowComposer.updateAllControllers();
			
			// Save off line positions
			var lineArray:Array = [];
			var tfl:TextFlowLine;
			for (var i:int = 0; i < flowComposer.numLines; ++i)
			{
				tfl = flowComposer.getLineAt(i)
				lineArray.push(verticalText ? tfl.x : tfl.y);
			}
			
			SelManager.undo();
			textFlowLine = flowComposer.getLineAt(2);
			startIndex = textFlowLine.absoluteStart + textFlowLine.textLength/2;
			ilg = ilgMarginAndPaddingSetup(startIndex, initialWidth, initialHeight, float);
			applyLogicalMarginAndPadding(ilg, 0, paddingUp, 0, paddingDown);
			flowComposer.updateAllControllers();
			for (i = 0; i < flowComposer.numLines; ++i)
			{
				tfl = flowComposer.getLineAt(i)
				assertTrue("Line has moved, should match previous location", lineArray[i] == (verticalText ? tfl.x : tfl.y));
			}
			
			return startIndex;
		}
		
		
		public function ilgMarginsAndPaddingBeforeAndAfter():void
			// Test margins that are block-direction after the ilg (bottom in tb/ltr)
		{
			_textFlow = SelManager.textFlow;
			var valuesBeforeAndAfter:Array = [ [-5, 0], [0, -5], [0, 20], [20, 0] ];
			var startIndex:int = -1;
			for each (var values:Array in valuesBeforeAndAfter)
			{
				if (startIndex >= 0)
					SelManager.deleteText(new SelectionState(SelManager.textFlow, startIndex, startIndex + 1));		// delete the inline inserted on the previous time through
				startIndex = ilgMarginsAndPaddingBeforeAndAfterInternal(values[0], values[1]); // before, after
			}
		}
		
		public function ilgMarginsAndPaddingStartStrikeAndUnderline():void
			// Test margins that are inline before the ilg (to the left in tb/ltr)
		{
			var format:TextLayoutFormat = new TextLayoutFormat(TestFrame.textFlow.format);
			format.lineThrough = true;
			format.textDecoration = TextDecoration.UNDERLINE;
			SelManager.textFlow.format = format;
			SelManager.textFlow.flowComposer.updateAllControllers();
			ilgMarginsAndPaddingStart();
		}
		
		public function ilgMarginsAndPaddingEndStrikeAndUnderline():void
			// Test margins that are inline after the ilg (to the right in tb/ltr)
		{
			_textFlow = SelManager.textFlow;
			var format:TextLayoutFormat = new TextLayoutFormat(TestFrame.textFlow.format);
			format.lineThrough = true;
			format.textDecoration = TextDecoration.UNDERLINE;
			SelManager.textFlow.format = format;
			SelManager.textFlow.flowComposer.updateAllControllers();
			ilgMarginsAndPaddingEnd();
		}
		
		public function ilgMarginsAndPaddingBeforeAndAfterStrikeAndUnderline():void
			// Test margins that are block-direction before the ilg (top in tb/ltr)
		{
			_textFlow = SelManager.textFlow;
			var format:TextLayoutFormat = new TextLayoutFormat(TestFrame.textFlow.format);
			format.lineThrough = true;
			format.textDecoration = TextDecoration.UNDERLINE;
			SelManager.textFlow.format = format;
			SelManager.textFlow.flowComposer.updateAllControllers();
			ilgMarginsAndPaddingBeforeAndAfter();
		}

		private function floatMarginsAndPaddingLeftRightInternal(paddingStart:Number, paddingEnd:Number, float:String):int
			// Test margins that are inline before the ilg (to the left in tb/ltr)
		{
			var flowComposer:IFlowComposer = _textFlow.flowComposer;
			
			// Insert graphic in the start of the flow
			var startIndex:int = 0;
			var ilg:InlineGraphicElement = ilgMarginAndPaddingSetup(startIndex, 30, 20, float);
			
			var verticalText:Boolean = _textFlow.computedFormat.blockProgression == BlockProgression.RL;
			applyLogicalMarginAndPadding(ilg, paddingStart, 0, paddingEnd, 0);
			flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = ilg.graphic.parent;
			
			var controller:ContainerController = flowComposer.getControllerAt(0);
			var lineIndex:int = flowComposer.findLineIndexAtPosition(startIndex);
			var tfl:TextFlowLine = flowComposer.getLineAt(lineIndex);
			var columnRect:Rectangle = controller.columnState.getColumnAt(tfl.columnIndex);
			
			// Check that graphic leaves a margin on the left side, so its not right up against the container edge
		//	var globalInlinePt:Point = ilg.graphic.localToGlobal(new Point(0, 0));
		//	var inlinePt:Point = controller.container.globalToLocal(globalInlinePt);
		//	var inlineBBox:Rectangle = new Rectangle(inlinePt.x, inlinePt.y, ilg.elementWidth, ilg.elementHeight);
			var inlineBBox:Rectangle = new Rectangle(floatHolder.x, floatHolder.y, ilg.elementWidth, ilg.elementHeight);
			
			if (float == Float.LEFT)
			{
				if (verticalText)
					assertTrue("Expected float to be indented from container edge", Math.abs(inlineBBox.y - (paddingStart + columnRect.y)) < 1);
				else
					assertTrue("Expected float to be indented from container edge", Math.abs((inlineBBox.x - paddingStart) - columnRect.x) < 1);
			}
			else
			{
				if (verticalText)
					assertTrue("Expected float to be indented from container edge", Math.abs((inlineBBox.bottom + paddingEnd) - columnRect.bottom) < 1);
				else
					assertTrue("Expected float to be indented from container edge", Math.abs((inlineBBox.right + paddingEnd) - columnRect.right) < 1);
			}
			return startIndex;
		}
		
		private var floatValues:Array = [Float.LEFT, Float.RIGHT];
		
		public function floatMarginsAndPaddingLeftAndRight():void
			// Test margins that are inline before the ilg (to the left in tb/ltr)
		{
			_textFlow = SelManager.textFlow;
			var marginAndPaddingLeft:Array = [ [-20, -20] , [20, 20] ];		// start & end padding value pairs
			var startIndex:int = -1;
			for each (var float:String in floatValues)
			{
				for each (var paddingStartAndEnd:Array in marginAndPaddingLeft)
				{
					if (startIndex >= 0)
						SelManager.deleteText(new SelectionState(_textFlow, startIndex, startIndex + 1));		// delete the inline inserted on the previous time through
					startIndex = floatMarginsAndPaddingLeftRightInternal(paddingStartAndEnd[0], paddingStartAndEnd[1], float);
				}
			}
		}
		
		public function floatMarginsAndPaddingUpAndDown():void
			// Test margins that are inline before the ilg (to the left in tb/ltr)
		{
			_textFlow = SelManager.textFlow;
			var marginAndPadding:Array = [ [-5, -5] , [20, 20] ];		// start & end padding value pairs
			var startIndex:int = -1;
			for each (var float:String in floatValues)
			{
				for each (var valuePair:Array in marginAndPadding)
				{
					if (startIndex >= 0)
						SelManager.deleteText(new SelectionState(_textFlow, startIndex, startIndex + 1));		// delete the inline inserted on the previous time through
					startIndex = ilgMarginsAndPaddingBeforeAndAfterInternal(valuePair[0], valuePair[1], float);
				}
			}
		}
		
		public function rlPaddingOnDiv():void
		{
			var markup:String = '<?xml version="1.0" encoding="utf-8"?>' +
				'<TextFlow xmlns="http://ns.adobe.com/textLayout/2008" version="2.0" paddingLeft="4" paddingTop="4" columnCount="4" fontSize="18" blockProgression="rl">' +
				'<p>BEFORE</p>' + 
				'<div paddingBottom="60" paddingTop="60">' +
				'<p>Hello</p>' +
				'</div>' +
				'<p>AFTER</p>' +
  				'</TextFlow>';
			
			var tf:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			testApp.contentChange(tf);
			assertTrue("nextLine should fail because text is overset", !NavigationUtil.nextLine(new TextRange(tf, 0, 0),false));
		} 
		
		public function textFlowPadding():void		// 2610219
		{
			var markup:String = '<?xml version="1.0" encoding="utf-8"?>' +
				'<TextFlow xmlns="http://ns.adobe.com/textLayout/2008" paddingLeft="4" paddingTop="2" columnCount="4" fontSize="18" direction="rtl" textAlign="left">' +
				'<p><span>Ask Not What Your Country Can Do For You speech</span></p>' + 
				'<p><span>Vice President Johnson, Mr. Speaker, Mr. Chief Justice, President Eisenhower, Vice President Nixon, President Truman, reverend clergy, fellow citizens, we observe today not a victory of party, but a celebration of freedom - symbolizing an end, as well as a beginning - signifying renewal, as well as change. For I have sworn before you and Almighty God the same solemn oath our forebears prescribed nearly a century and three quarters ago. </span></p>' + 
				'<p><span>The world is very different now. For man holds in his mortal hands the power to abolish all forms of human poverty and all forms of human life. And yet the same revolutionary beliefs for which our forebears fought are still at issue around the globe - the belief that the rights of man come not from the generosity of the state, but from the hand of God. </span></p>' +
				'<p><span>We dare not forget today that we are the heirs of that first revolution. Let the word go forth from this time and place, to friend and foe alike, that the torch has been passed to a new generation of Americans - born in this century, tempered by war, disciplined by a hard and bitter peace, proud of our ancient heritage - and unwilling to witness or permit the slow undoing of those human rights to which this Nation has always been committed, and to which we are committed today at home and around the world. </span></p>' +
				'<p><span>Let every nation know, whether it wishes us well or ill, that we shall pay any price, bear any burden, meet any hardship, support any friend, oppose any foe, in order to assure the survival and the success of liberty. </span></p>' +
				'<p><span>This much we pledge - and more. </span></p>' + 
				'<p><span>To those old allies whose cultural and spiritual origins we share, we pledge the loyalty of faithful friends. United, there is little we cannot do in a host of cooperative ventures. Divided, there is little we can do - for we dare not meet a powerful challenge at odds and split asunder. </span></p>' + 
				'<p><span>To those new States whom we welcome to the ranks of the free, we pledge our word that one form of colonial control shall not have passed away merely to be replaced by a far more iron tyranny. We shall not always expect to find them supporting our view. But we shall always hope to find them strongly supporting their own freedom - and to remember that, in the past, those who foolishly sought power by riding the back of the tiger ended up inside. </span></p>' + 
				'<p><span>To those peoples in the huts and villages across the globe struggling to break the bonds of mass misery, we pledge our best efforts to help them help themselves, for whatever period is required - not because the Communists may be doing it, not because we seek their votes, but because it is right. If a free society cannot help the many who are poor, it cannot save the few who are rich. </span></p>' + 
				'<p><span>To our sister republics south of our border, we offer a special pledge - to convert our good words into good deeds - in a new alliance for progress - to assist free men and free governments in casting off the chains of poverty. But this peaceful revolution of hope cannot become the prey of hostile powers. Let all our neighbours know that we shall join with them to oppose aggression or subversion anywhere in the Americas. And let every other power know that this Hemisphere intends to remain the master of its own house. </span></p>' + 
				'<p><span>To that world assembly of sovereign states, the United Nations, our last best hope in an age where the instruments of war have far outpaced the instruments of peace, we renew our pledge of support - to prevent it from becoming merely a forum for invective - to strengthen its shield of the new and the weak - and to enlarge the area in which its writ may run. </span></p>' + 
				'<p><span>Finally, to those nations who would make themselves our adversary, we offer not a pledge but a request: that both sides begin anew the quest for peace, before the dark powers of destruction unleashed by science engulf all humanity in planned or accidental self-destruction. </span></p>' + 
				'</TextFlow>';
			
			// When we're measuring, column setting is ignored
			var tf:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			testApp.contentChange(tf);
			var controller:ContainerController = tf.flowComposer.getControllerAt(0);
			controller.setCompositionSize(NaN, controller.compositionHeight);
			tf.flowComposer.updateAllControllers();
			var line:TextFlowLine = tf.flowComposer.getLineAt(0);
			assertTrue("Expected line to extend to padding", line.x == 4);
		}
		
		private function boundsCheck(markup:String, width:Number, height:Number):Rectangle
		{
			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			
			// Get factory bounds 
			var factory:TextFlowTextLineFactory = new TextFlowTextLineFactory();
			factory.compositionBounds = new Rectangle(0, 0, width, height);
			factory.createTextLines(handleLines, textFlow);
			var factoryBounds:Rectangle = factory.getContentBounds();
			
			// Get ContainerController bounds
			textFlow.flowComposer = new StandardFlowComposer();
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var controller:ContainerController = new ContainerController(new Sprite(), NaN, 200);
			flowComposer.updateAllControllers();
			var controllerBounds:Rectangle = controller.getContentBounds();
			
			assertTrue(controllerBounds.equals(factoryBounds), "Expected composition bounds for ContainerController to match factory");
			
			return factoryBounds;
			
			function handleLines(textLine:TextLine):void
			{
				// do nothing -- we just want the bounds
			}
		}
		
		public function boundsWithPadding():void	// 2733620
		{
			var width:Number; 	// NaN
			var height:Number = 200;
			
			var markup:String = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008" fontSize="14" textIndent="0" paddingTop="0" paddingLeft="0" fontFamily="Times New Roman"  version="2.0.0"><div paddingTop="8" paddingLeft="8" paddingRight="10" paddingBottom="10"><p paddingTop="0" paddingLeft="0">ABCD</p></div></TextFlow>';
			var contentBounds:Rectangle = boundsCheck(markup, width, height);
			assertTrue("Expected to see space left for padding top and left", contentBounds.x == 0 && contentBounds.y == 0);
			
			var rtlMarkup:String = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008" fontSize="14" textIndent="0" paddingTop="0" paddingLeft="0" fontFamily="Times New Roman"  version="2.0.0"><div paddingTop="8" paddingLeft="8" paddingRight="10" paddingBottom="10"><p direction="rtl" paddingTop="0" paddingLeft="0">ABCD</p></div></TextFlow>';
			var rtlContentBounds:Rectangle = boundsCheck(rtlMarkup, width, height);
			assertTrue("Content bounds for rtl should match content Bounds for ltr", contentBounds.equals(rtlContentBounds));

			var rlMarkup:String = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008" blockProgression="rl" fontSize="14" textIndent="0" paddingTop="0" paddingLeft="0" fontFamily="Times New Roman"  version="2.0.0"><div paddingTop="8" paddingLeft="8" paddingRight="10" paddingBottom="10"><p paddingTop="0" paddingLeft="0">ABCD</p></div></TextFlow>';
			var rlContentBounds:Rectangle = boundsCheck(rlMarkup, height, width );
			assertTrue("Content bounds for vertical text should match horizontal", rlContentBounds.top == 0 && rlContentBounds.width == contentBounds.height && rlContentBounds.height == contentBounds.width);
			
		}
	}
}