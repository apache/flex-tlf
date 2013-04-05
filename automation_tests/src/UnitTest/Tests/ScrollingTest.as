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
	import UnitTest.Tests.SingleContainerTest;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.elements.TextRange;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.utils.NavigationUtil;
	
	/** Test the state of selection after each operation is done, undone, and redone.
	 */
 	public class ScrollingTest extends VellumTestCase
	{
		public function ScrollingTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);
			addDefaultTestSettings = false;
			if (!TestData.hasOwnProperty("testFile"))
				TestData.fileName = "aliceExcerpt.xml";		// longer file so it exceeds container - default for this suite, tests may override in XML
			else
				TestData.fileName = TestData.testFile;

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "UI";
			metaData.productSubArea = "Scrolling";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = ScrollingTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}


		private function findFirstAndLastVisibleLine(flowComposer:IFlowComposer, controller:ContainerController):Array
		{
			var firstLine:int = flowComposer.findLineIndexAtPosition(controller.absoluteStart);
			var lastLine:int = flowComposer.findLineIndexAtPosition(controller.absoluteStart + controller.textLength - 1);
			var lastColumn:int = 0;
			var firstVisibleLine:int = -1;
			var lastVisibleLine:int = -1;
			for (var lineIndex:int = firstLine; lineIndex <= lastLine; lineIndex++)
			{
				var curLine:TextFlowLine = flowComposer.getLineAt(lineIndex);
				if (curLine.controller != controller)
					continue;

				// skip until we find the lines in the last column
				if (curLine.columnIndex != lastColumn)
					continue;

				if (curLine.textLineExists && curLine.getTextLine().parent)
				{
					if (firstVisibleLine < 0)
						firstVisibleLine = lineIndex;

					lastVisibleLine = lineIndex;
				}
			}

			return [firstVisibleLine, lastVisibleLine];
		}

		/* Test Cases:  (explicit & wrap, vertical & horizontal, ltr, rtl)
			- Page forward, backward
			- Forward, backward by n lines
				- Partial line visible
				- On line boundary
			- Forward, backward by n pixels
			- Scroll to position horizontal scroll forward/backward (mimic typing off form field)
			- Scroll to position when position is visible
			- Scroll to position when position is partly visible (up/down/left/right)
			- Scroll to end
			- Scroll to start
		*/

		private function pageForwardOrBackward(forward:Boolean):Array
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var controller:ContainerController = flowComposer.getControllerAt(0);
			var blockProgression:String = textFlow.computedFormat.blockProgression;

			var linePositionBefore:Array = findFirstAndLastVisibleLine(flowComposer, controller);

			var panelSize:Number = (blockProgression == BlockProgression.TB) ? controller.compositionHeight : controller.compositionWidth;
			var pageSize:Number = panelSize * .75;

			if (!forward)
				pageSize = -pageSize;

			if (blockProgression == BlockProgression.TB)
				controller.verticalScrollPosition += pageSize;
			else
				controller.horizontalScrollPosition -= pageSize;

			flowComposer.updateAllControllers();

			return linePositionBefore;
		}

		public function pageForward():void
		{
			var beforePosition:Array = pageForwardOrBackward(true);
			var beforeFirstVisibleLine:int = beforePosition[0];
			var beforeLastVisibleLine:int = beforePosition[1];

			var textFlow:TextFlow = SelManager.textFlow;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var controller:ContainerController = flowComposer.getControllerAt(0);
			var afterPosition:Array = findFirstAndLastVisibleLine(flowComposer, controller);
			var afterFirstVisibleLine:int = afterPosition[0];
			var afterLastVisibleLine:int = afterPosition[1];

			// Check that we did scroll forward, and check that some text that was visible before is still visible.
			assertTrue("PageForward didn't advance scroll", afterFirstVisibleLine > beforeFirstVisibleLine);
			assertTrue("PageForward didn't overlap previous text", afterFirstVisibleLine < beforeLastVisibleLine);
		}

		public function pageBackward():void
		{
			var beforePosition:Array = pageForwardOrBackward(false);
			var beforeFirstVisibleLine:int = beforePosition[0];
			var beforeLastVisibleLine:int = beforePosition[1];

			var textFlow:TextFlow = SelManager.textFlow;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var controller:ContainerController = flowComposer.getControllerAt(0);
			var afterPosition:Array = findFirstAndLastVisibleLine(flowComposer, controller);
			var afterFirstVisibleLine:int = afterPosition[0];
			var afterLastVisibleLine:int = afterPosition[1];

			// Check that we did scroll backward, and check that some text that was visible before is still visible.
			assertTrue("PageBackward didn't reverse scroll", afterFirstVisibleLine < beforeFirstVisibleLine);
			assertTrue("PageBackward didn't overlap previous text", afterLastVisibleLine > beforeFirstVisibleLine);
		}

		public function scrollByPageTest():void
		{
			pageForward();
			pageBackward();
		}

		private function pageForwardOrBackwardByLines(numberOfLines:int):void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var controller:ContainerController = flowComposer.getControllerAt(0);
			var blockProgression:String = textFlow.computedFormat.blockProgression;

			var beforePosition:Array = findFirstAndLastVisibleLine(flowComposer, controller);

			var amount:Number = controller.getScrollDelta(numberOfLines);

			if (blockProgression == BlockProgression.TB)
				controller.verticalScrollPosition += amount;
			else
				controller.horizontalScrollPosition -= amount;

			flowComposer.updateAllControllers();

			var beforeFirstVisibleLine:int = beforePosition[0];
			var beforeLastVisibleLine:int = beforePosition[1];

			var afterPosition:Array = findFirstAndLastVisibleLine(flowComposer, controller);
			var afterFirstVisibleLine:int = afterPosition[0];
			var afterLastVisibleLine:int = afterPosition[1];

			// Check that we did scroll forward, and check that some text that was visible before is still visible.
			assertTrue("scrollMultipleLines didn't advance scroll correctly", afterFirstVisibleLine == beforeFirstVisibleLine + numberOfLines);
		}

		public function scrollMultipleLinesTest():void
		{
			pageForwardOrBackwardByLines(26);
			pageForwardOrBackwardByLines(-13);
			for (var i:int = 0; i < 6; ++i)
				pageForwardOrBackwardByLines(1);
		}

		public function scrollAndResizeTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var position:int = textFlow.textLength-1;

			// shrink it down
			var w:Number = TestFrame.compositionWidth;
			var h:Number = TestFrame.compositionHeight;
			TestFrame.setCompositionSize(w/2,h/2);
			textFlow.flowComposer.updateAllControllers();

			// select at the end
			SelManager.selectRange(position,position);
			TestFrame.scrollToRange(position,position);

			// restore size
			TestFrame.setCompositionSize(w,h);
			textFlow.flowComposer.updateAllControllers();

			// verify that the last line is in view
			var afterPosition:Array = findFirstAndLastVisibleLine(textFlow.flowComposer, TestFrame);
			var afterFirstVisibleLine:int = afterPosition[0];
			var afterLastVisibleLine:int = afterPosition[1];
			assertTrue("scrollAndResizeTest last line no longer in view", afterLastVisibleLine == textFlow.flowComposer.numLines-1);
		}
		/* ************************************************************** */
		/* nextPage() test */
		/* ************************************************************** */

		public function nextPageTest():void
		{
			//Create a new TextFlow, IFlowComposer, ContainerController
			var textFlow:TextFlow = SelManager.textFlow;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var controller:ContainerController = flowComposer.getControllerAt(0);

			//set a textRange.
			var textRange:TextRange = new TextRange(textFlow, 0, 10);

			NavigationUtil.nextPage(textRange, false);

			//composes all the text up-to date.
			flowComposer.updateAllControllers();

			//find what the first line displayed in a scrolling container is
			var firstLineIndex:int = findFirstAndLastVisibleLine(flowComposer, controller)[0];

			//verify the position of textRange after nextPage applied
			assertTrue("first line index at first line is " + firstLineIndex + " and it should be large than 0" ,
				firstLineIndex > 0);
		}

		/* ************************************************************** */
		/* previousPage() test */
		/* ************************************************************** */

		public function previousPageTest():void
		{
			//Create a new TextFlow, IFlowComposer, ContainerController?
			var textFlow:TextFlow = SelManager.textFlow;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var controller:ContainerController = flowComposer.getControllerAt(0);
			controller.verticalScrollPosition = 100;

			//set a textRange.
			var textRange:TextRange = new TextRange(textFlow, 1000, 1010);

			//find text index at the first line in the visible area befor change
			var firstLineIndexBefore:int = findFirstAndLastVisibleLine(flowComposer, controller)[0];

			NavigationUtil.previousPage(textRange, false);

			//composes all the text up-to date.
			flowComposer.updateAllControllers();

			//find text index at the first line in the visible area after change
			var firstLineIndexAfter:int = findFirstAndLastVisibleLine(flowComposer, controller)[0];

			//verify the position of textRange after previousPage applied
			assertTrue("last line index at last line is " + firstLineIndexAfter + " and it should be less than " + firstLineIndexBefore,
			firstLineIndexAfter < firstLineIndexBefore);
		}
		

		private function testScrollLimitWithString(content:String):void
			// Scrolling from a long line to a short line should not scroll horizontally if end of short line already in view
		{
			var textFlow:TextFlow = TextConverter.importToFlow(content, TextConverter.PLAIN_TEXT_FORMAT);
			textFlow.lineBreak = LineBreak.EXPLICIT;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var s:Sprite = new Sprite();
			var controller:ContainerController = new ContainerController(s, 100, 30);
			flowComposer.addController(controller);
			var selectionManager:SelectionManager = new SelectionManager();
			textFlow.interactionManager = selectionManager;
			selectionManager.selectRange(0, 0);
			selectionManager.setFocus();
			flowComposer.updateAllControllers();

			// Set cursor at the end of the 1st line
			var firstLine:TextFlowLine = flowComposer.getLineAt(0);
			selectionManager.selectRange(firstLine.absoluteStart + firstLine.textLength - 1, firstLine.absoluteStart + firstLine.textLength - 1);
			controller.scrollToRange(selectionManager.absoluteStart, selectionManager.absoluteEnd);
			var secondLine:TextFlowLine = flowComposer.getLineAt(1);
			var expectScrolling:Boolean = firstLine.textLength > secondLine.textLength;
			
			
			// Scroll down and back up
			scrollByKey(textFlow, Keyboard.DOWN, expectScrolling);
			scrollByKey(textFlow, Keyboard.UP, false);
			scrollByKey(textFlow, Keyboard.DOWN, false);
			scrollByKey(textFlow, Keyboard.UP, false);
			
			textFlow.interactionManager.selectRange(secondLine.absoluteStart + secondLine.textLength - 1, secondLine.absoluteStart + secondLine.textLength - 1);
			controller.scrollToRange(selectionManager.absoluteStart, selectionManager.absoluteEnd);
			flowComposer.updateAllControllers();

			// Scroll up and back down
			scrollByKey(textFlow, Keyboard.UP, !expectScrolling);
			scrollByKey(textFlow, Keyboard.DOWN, false);
			scrollByKey(textFlow, Keyboard.UP, false);
			scrollByKey(textFlow, Keyboard.DOWN, false);
			}
		
		public function scrollByKey(textFlow:TextFlow, keyCode:int, expectScrolling:Boolean):void
			// Scroll one line, and check that we only scrolled in vertical direction
		{
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);

			// Save off old logical horizontal scroll pos
			var blockProgression:String = textFlow.computedFormat.blockProgression;
			var logicalHorizontalScrollPosition:Number = (blockProgression == BlockProgression.TB) ? controller.horizontalScrollPosition : controller.verticalScrollPosition;

			var kEvent:KeyboardEvent = new KeyboardEvent( KeyboardEvent.KEY_DOWN, true, false, 0, keyCode);
			SelectionManager(textFlow.interactionManager).keyDownHandler(kEvent);
			
			if (expectScrolling)
				assertTrue("Logical horizontal scroll position should have changed", 
					logicalHorizontalScrollPosition != ((blockProgression == BlockProgression.TB) ? controller.horizontalScrollPosition : controller.verticalScrollPosition));
			else
				assertTrue("Logical horizontal scroll position should not have changed", 
					logicalHorizontalScrollPosition == ((blockProgression == BlockProgression.TB) ? controller.horizontalScrollPosition : controller.verticalScrollPosition));
		}
		
		// Test for Watson 2476646
		public function scrollUpDownLimitTest():void
			// Scrolling from a long line to a short line or vice versa should not scroll horizontally if end of short line already in view
		{
			testScrollLimitWithString("A B C D E F G\n" + "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z");
			testScrollLimitWithString("A B C D E F G H I J K L M N O P Q R S T U V W X Y Z\n" + "A B C D E F G");
		}
		
		public function scrollToSelectionAfterParagraphInsertion():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			textFlow.flowComposer.updateAllControllers();
			SelManager.selectRange(textFlow.textLength, textFlow.textLength);
			var paragraphCount:int = textFlow.computedFormat.blockProgression == BlockProgression.RL ? 12 : 7;
			for (var i:int = 0; i < paragraphCount; ++i)
				SelManager.splitParagraph();
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			var firstLineIndex:int = findFirstAndLastVisibleLine(textFlow.flowComposer, controller)[0];
			assertTrue("Expected view to scroll to keep selection in view", firstLineIndex > 0);
		}
		
		public function scrollWithAdormentsAndInlines():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			textFlow.flowComposer.updateAllControllers();
			// underline everything
			SelManager.selectAll();
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.textDecoration = TextDecoration.UNDERLINE;
			(SelManager as IEditManager).applyLeafFormat(format);
			// insert a graphic
			var shape:Shape = new Shape;
			shape.graphics.beginFill(0xff0000);
			shape.graphics.drawRect(0,0,25,25);
			shape.graphics.endFill();
			SelManager.selectRange(0,0);
			(SelManager as IEditManager).insertInlineGraphic(shape,25,25);
			// now page forward and then back
			pageForward();
			pageBackward();
			// check rendering - there should be decorations
		}
		
		public function scrollWithInsideList():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			textFlow.flowComposer.updateAllControllers();
			// now page forward and then back
			pageForward();
			pageBackward();
			// check rendering - the inside list should have proper markers
		}
		
		private function createFilledSprite(width:Number, height:Number, color:int):Sprite
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(color);	// red
			sprite.graphics.drawRect(0,0,width,height);
			sprite.graphics.endFill();
			return sprite;
		}
		
		public function largeLastLine():void		// 2739996
		{
			var textFlow:TextFlow = SelManager.textFlow;
			SelManager.selectRange(textFlow.textLength - 1, textFlow.textLength - 1);
			SelManager.insertInlineGraphic(createFilledSprite(200, 200, 0xff0000), 200, 200, Float.NONE);
			textFlow.flowComposer.updateAllControllers();
			SelManager.selectRange(0, 0);
			textFlow.flowComposer.getControllerAt(0).scrollToRange(0, 0);
			var insertLineCount:int = textFlow.computedFormat.blockProgression == BlockProgression.RL ? 11 : 6;
			for (var i:int = 0; i < insertLineCount; ++i)		// gradually force the inline out of view
				SelManager.splitParagraph();
			var firstVisibleLine:int = findFirstAndLastVisibleLine(textFlow.flowComposer, textFlow.flowComposer.getControllerAt(0))[0];
			assertTrue("Shouldn't scroll down yet", firstVisibleLine == 0);
		}
		
		// mjzhang : Watson#2819924 Error #1009 in flashx.textLayout.container::ContainerController::updateGraphics()   
		public function Bug2819924_case1():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			
			for ( var i:int = 0; i < 15; i ++ )
			{
				textFlow.addChild( TextConverter.importToFlow(
						'<TextFlow xmlns="http://ns.adobe.com/textLayout/2008">xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx <img source="http://static.v41.skyrock.net/chat/chat20080110/images/smileys/3-blink.png"/> xxxx</TextFlow>',
						TextConverter.TEXT_LAYOUT_FORMAT
					).getChildAt(0) );
				
				textFlow.addChild(
					TextConverter.importToFlow(
						'<TextFlow xmlns="http://ns.adobe.com/textLayout/2008">xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxx</TextFlow>',
						TextConverter.TEXT_LAYOUT_FORMAT
					).getChildAt(0) );
				
				controller.verticalScrollPosition += 50;
				textFlow.flowComposer.updateAllControllers();
			}
		}
		private var singleCT:SingleContainerTest = new SingleContainerTest();
		// mjzhang : Watson#2819924 Error #1009 in flashx.textLayout.container::ContainerController::updateGraphics()   
		public function Bug2819924_case2():void
		{
			SelManager.insertInlineGraphic(singleCT, 600, 400, Float.NONE);
		}
		
		// mjzhang : Watson#2819924 Error #1009 in flashx.textLayout.container::ContainerController::updateGraphics()   
		public function Bug2819924_case3():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			
			var str:String = "";
			var i:int = 30;
			while(i>0){
				str += i+"\n"
				i--;
			}
			
			var tf:TextFlow = TextConverter.importToFlow(str, TextConverter.PLAIN_TEXT_FORMAT);
			var flowElem:FlowElement = tf.getChildAt(0);
			textFlow.addChild( flowElem );
			
			textFlow.addChild( TextConverter.importToFlow(
				'<TextFlow xmlns="http://ns.adobe.com/textLayout/2008"><img source="http://static.v41.skyrock.net/chat/chat20080110/images/smileys/3-blink.png"/> </TextFlow>',
				TextConverter.TEXT_LAYOUT_FORMAT
			).getChildAt(0) );
			
			
			for ( var j:int = 0; j < 100; j ++ )
			{
				textFlow.addChild( TextConverter.importToFlow("aaa", TextConverter.PLAIN_TEXT_FORMAT).getChildAt(0) );
				textFlow.addChild( TextConverter.importToFlow(
					'<TextFlow xmlns="http://ns.adobe.com/textLayout/2008"><img source="http://static.v41.skyrock.net/chat/chat20080110/images/smileys/3-blink.png"/> </TextFlow>',
					TextConverter.TEXT_LAYOUT_FORMAT
				).getChildAt(0) );
				
				controller.verticalScrollPosition += 10;
				textFlow.flowComposer.updateAllControllers();
			}
			
			textFlow.flowComposer.updateAllControllers();
		}
		
		public function bug2988852():void
		{
			var tf:TextFlow = SelManager.textFlow;
			for( var i:int = 0; i < 15; i ++ )
			{
				tf.addChild( TextConverter.importToFlow(
					'<TextFlow xmlns="http://ns.adobe.com/textLayout/2008">Alice was beginning to get very tired of sitting by her sister	on the bank, and of having nothing to do: once or twice she had	peeped into the book her sister was reading, but it had no pictures or conversations in it, “and what is the use of a book,” thought Alice “without pictures or conversation?<img source="http://static.v41.skyrock.net/chat/chat20080110/images/smileys/3-blink.png"/> conversation?</TextFlow>',
					TextConverter.TEXT_LAYOUT_FORMAT
				).getChildAt(0) );
			}
			tf.flowComposer.updateAllControllers();
			
			SelManager.insertInlineGraphic(singleCT, "auto", "auto", Float.NONE, new SelectionState(tf, 500,500));
			var controller:ContainerController = tf.flowComposer.getControllerAt(0);
			controller.verticalScrollPosition += 20;
			tf.flowComposer.updateAllControllers();
			
			controller.verticalScrollPosition += 2000;
			tf.flowComposer.updateAllControllers();
			
			controller.verticalScrollPosition -= 2100;
			tf.flowComposer.updateAllControllers();
			
			for(var scrollTimes:int = 0; scrollTimes < 10; scrollTimes ++)
			{
				controller.verticalScrollPosition += (800 + 50*scrollTimes);
				tf.flowComposer.updateAllControllers();
				
				controller.verticalScrollPosition -= (800 + 20*scrollTimes);
				tf.flowComposer.updateAllControllers();
			}
		}
		
		public function twoColumnsTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			for( var i:int = 0; i < 60; i ++ )
			{
				tf.addChildAt(0, TextConverter.importToFlow(
					'<TextFlow xmlns="http://ns.adobe.com/textLayout/2008"><list paddingRight="24" paddingLeft="24" listStyleType="upperAlpha"><li>upperAlpha item</li></list></TextFlow>',
					TextConverter.TEXT_LAYOUT_FORMAT
				).getChildAt(0));
			}
			var controller:ContainerController = tf.flowComposer.getControllerAt(0);
			controller.columnCount = 2;
			tf.flowComposer.updateAllControllers();
			
			controller.verticalScrollPosition += 100;
			tf.flowComposer.updateAllControllers();
			var tfl60:TextFlowLine = tf.flowComposer.getLineAt(59);
			assertTrue("The 60th line should be on the stage after scrolling down 100 pixels", controller.container.contains(tfl60.getTextLine()));
		}
	}
}
