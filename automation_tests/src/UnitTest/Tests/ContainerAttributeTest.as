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
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

 	public class ContainerAttributeTest extends VellumTestCase
	{
		private var testContainer:Boolean;
		private var inputContainerAttrs:TextLayoutFormat;
		private var outputContainerAttrs:ITextLayoutFormat;
		private var initSize:Point;

		public function ContainerAttributeTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);
			this.testContainer = (TestData.testContainer=="true");
			TestID = TestID + ":" + testContainer;
			inputContainerAttrs = new TextLayoutFormat();

			metaData.productArea = "Text Container";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = ContainerAttributeTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

    	public override function setUp():void
    	{
    		super.setUp();
    		paddingRight = 0;
			paddingLeft = 0;
			SelManager.textFlow.paddingLeft = 0;
			SelManager.textFlow.paddingRight = 0;
			SelManager.selectAll();
			columnGap = 0;
			columnWidth = FormatValue.AUTO;
			columnCount = FormatValue.AUTO;
    	}

		public override function tearDown():void
		{
			if(initSize){
				size = initSize;
			}

			super.tearDown();
		}

		private function set columnCount(count:Object):void
		{
			if(testContainer)
			{
				var ca:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
				ca.columnCount = count;
				TestFrame.format = ca;
			}
			else
			{
				inputContainerAttrs.columnCount = count;
				SelManager.applyContainerFormat(inputContainerAttrs);
			}
		}

		private function get columnCount():Object
		{
			outputContainerAttrs = TestFrame.computedFormat;
			return outputContainerAttrs.columnCount;
		}

		private function set columnGap(gap:Object):void
		{
			if(testContainer)
			{
				var ca:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
				ca.columnGap = gap;
				TestFrame.format = ca;
			}
			else
			{
				inputContainerAttrs.columnGap = gap;
				SelManager.applyContainerFormat(inputContainerAttrs);
			}
		}

		private function get columnGap():Object
		{
			outputContainerAttrs = TestFrame.computedFormat;
			return outputContainerAttrs.columnGap;
		}

		private function set columnWidth(width:Object):void
		{
			if(testContainer)
			{
				var ca:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
				ca.columnWidth = width;
				TestFrame.format = ca;
			}
			else
			{
				inputContainerAttrs.columnWidth = width;
				SelManager.applyContainerFormat(inputContainerAttrs);
			}
		}

		private function get verticalAlign():Object
		{
			outputContainerAttrs = TestFrame.computedFormat;
			return outputContainerAttrs.verticalAlign;
		}

		private function set verticalAlign(align:Object):void
		{
			if(testContainer)
			{
				var ca:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
				ca.verticalAlign = align as String;
				TestFrame.format = ca;

				// Added as result of bug #1875477
				TestFrame.textFlow.flowComposer.updateAllControllers();
			}
			else
			{
				inputContainerAttrs.verticalAlign = align as String;
				SelManager.applyContainerFormat(inputContainerAttrs);
			}
		}

		private function get columnWidth():Object
		{
			outputContainerAttrs = TestFrame.computedFormat;
			return outputContainerAttrs.columnWidth;
		}

		private function set paddingTop(padding:Object):void
		{
			if(testContainer)
			{
				var ca:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
				ca.paddingTop = padding;
				TestFrame.format = ca;
			}
			else
			{
				inputContainerAttrs.paddingTop = padding;
				SelManager.applyContainerFormat(inputContainerAttrs);
			}
		}

		private function set paddingBottom(padding:Object):void
		{
			if(testContainer)
			{
				var ca:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
				ca.paddingBottom = padding;
				TestFrame.format = ca;
			}
			else
			{
				inputContainerAttrs.paddingBottom = padding;
				SelManager.applyContainerFormat(inputContainerAttrs);
			}
		}

		private function set paddingRight(padding:Object):void
		{
			if(testContainer)
			{
				var ca:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
				ca.paddingRight = padding;
				TestFrame.format = ca;
			}
			else
			{
				inputContainerAttrs.paddingRight = padding;
				SelManager.applyContainerFormat(inputContainerAttrs);
			}
		}

		private function set paddingLeft(padding:Object):void
		{
			if(testContainer)
			{
				var ca:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
				ca.paddingLeft = padding;
				TestFrame.format = ca;
			}
			else
			{
				inputContainerAttrs.paddingLeft = padding;
				SelManager.applyContainerFormat(inputContainerAttrs);
			}
		}

		private function get testFrameWidth():Number
		{
			return TestFrame.compositionWidth;
		}
		private function get testFrameHeight():Number
		{
			return TestFrame.compositionHeight;
		}

		private function get blockProgression():String
		{
			return TestFrame.rootElement.computedFormat.blockProgression;
		}

		private function set blockProgression(mode:String):void
		{
			TestFrame.rootElement.blockProgression = mode;
			TestFrame.textFlow.flowComposer.compose();
		}

		private function get size():Point
		{
			var width:Number = 0;
			var height:Number = 0;

			if(TestFrame.container is DisplayObject)
			{
				var frame:DisplayObject = TestFrame.container as DisplayObject;
				width = frame.width;
				height = frame.height;
			}

			return new Point(width,height);
		}

		private function set size(dimension:Point):void
		{
	 		var containerAttr:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
	 		containerAttr.columnCount = 1;
 			containerAttr.paddingLeft = 0;
 			containerAttr.paddingRight = 0;
 			containerAttr.paddingTop = 0;
 			containerAttr.paddingBottom = 0;
 			TestFrame.format = containerAttr;

			if (TestFrame.container is Sprite)
			{
				TextFlow(testApp.getTextFlow()).flowComposer.getControllerAt(0).setCompositionSize(dimension.x,dimension.y);
				TextFlow(testApp.getTextFlow()).flowComposer.updateAllControllers();
			}
			else
				throw new Error("test does not know how to resize this container type");	// Above should be generalized?
		}

		/**
		 * Set and get the firstBaselineOffset string values and test bound of numeric values.
		 */
		public function checkfirstBaselineOffset():void // KJT
		{

			inputContainerAttrs.firstBaselineOffset = flashx.textLayout.formats.BaselineOffset.ASCENT;
			assertTrue("expected: ascent.  cascaded: " + String(inputContainerAttrs.firstBaselineOffset),
						String(inputContainerAttrs.firstBaselineOffset) == flashx.textLayout.formats.BaselineOffset.ASCENT);
			inputContainerAttrs.firstBaselineOffset = flashx.textLayout.formats.BaselineOffset.LINE_HEIGHT;
			assertTrue("expected: leading.  cascaded: " + String(inputContainerAttrs.firstBaselineOffset),
						String(inputContainerAttrs.firstBaselineOffset) == flashx.textLayout.formats.BaselineOffset.LINE_HEIGHT);
			for (var cter:uint = TextLayoutFormat.firstBaselineOffsetProperty.minValue; cter <= TextLayoutFormat.firstBaselineOffsetProperty.maxValue; cter+=33.33)
			{
				inputContainerAttrs.firstBaselineOffset = cter;
				assertTrue("expected: " + cter + ". cascaded: " + inputContainerAttrs.firstBaselineOffset,inputContainerAttrs.firstBaselineOffset == cter);
			}

			inputContainerAttrs.firstBaselineOffset = undefined;
		}

		/**
		 * Set the gap, then change the width to see how the column count changes.
		 */
		public function checkColumnCountOnWidthChangeTest():void
		{
			var width:Number = testFrameWidth;
			var cWidth:Number = width/10;

			columnGap = 0;
			columnWidth = cWidth;

			var initCount:int = TestFrame.columnState.columnCount;

			columnWidth = cWidth*2;


			var endCount:int = TestFrame.columnState.columnCount;

			assertTrue("expected " + Math.floor(initCount/2) + " but got " + endCount,
						Math.floor(initCount/2) == endCount);
		}

		/**
		 * Set the width, then change the column gap to see how the column count changes.
		 */
		public function checkColumnCountOnGapChangeTest():void
		{
			var width:Number = testFrameWidth;
			var cWidth:Number = width/10;

			/*paddingRight = 0;
			paddingLeft = 0;
			SelManager.textFlow.paddingLeft = 0;
			SelManager.textFlow.paddingRight = 0;*/
			columnGap = 0;
			columnWidth = cWidth;

			var initCount:Number = TestFrame.columnState.columnCount;

			columnGap = cWidth/10;

			var endCount:Number = TestFrame.columnState.columnCount;

			assertTrue("expected " + (initCount - 1) + " but got " + endCount,
						initCount - 1 == endCount);
		}

		/**
		 * Set the column count, then change the column gap and see how the column width changes.
		 */
		public function checkColumnWidthOnGapChangeTest():void
		{
			var width:Number = testFrameWidth;
			var cWidth:Number = width/10;

			/*paddingRight = 0;
			paddingLeft = 0;
			SelManager.textFlow.paddingLeft = 0;
			SelManager.textFlow.paddingRight = 0;*/
			columnGap = 0;
			columnCount = 10;

			var initColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			var initWidth:Number = initColumn.width;

			columnGap = cWidth/9;

			var endColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			var endWidth:Number = endColumn.width;
			assertTrue("expected " + (initWidth - (initWidth/10)) + " but got " + endWidth,
						((initWidth - (initWidth/10)) - endWidth) < 0.01);
		}

		/**
		 * Set the column gap, then change the column count to see how the column width changes.
		 */
		public function checkColumnWidthOnCountChangeTest():void
		{
			var bp:String = TestFrame.textFlow.computedFormat.blockProgression;
			var width:Number = bp == BlockProgression.TB ? testFrameWidth : testFrameHeight;
			var cWidth:Number = width/10;

			/*paddingRight = 0;
			paddingLeft = 0;
			SelManager.textFlow.paddingLeft = 0;
			SelManager.textFlow.paddingRight = 0;*/
			columnGap = 0;
			columnCount = 10;

			var initColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			var initWidth:Number = bp == BlockProgression.TB ? initColumn.width : initColumn.height;

			columnCount = 5;

			var endColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			var endWidth:Number = bp == BlockProgression.TB ? endColumn.width : endColumn.height;

			assertTrue("expected " + Math.floor(endWidth/2) + " but got " + initWidth,
						Math.floor(endWidth/2) == Math.floor(initWidth));
			assertTrue("expected " + Math.floor(initWidth) + " but got " + Math.floor(cWidth),
						Math.floor(initWidth) == Math.floor(cWidth));
		}

		/**
		 * Set the column count, then change the column width to see how the column gap changes.
		 */
		public function checkColumnGapOnWidthChangeTest():void
		{
			var width:Number = testFrameWidth;
			
			columnCount = 2;
			columnWidth = width/3;
			
			var initColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			var initGap:Number = width - initColumn.width * 2;
			
			assertTrue("expected init width to equal " + width/3 + ", but got " + columnWidth,
				columnWidth == width/3);
			assertTrue("expected init count to equal " + 2 + ", but got " + columnCount,
				columnCount == 2);
			assertTrue("expected init gap to equal " + width/3 + ", but got " + initGap,
				Math.floor(initGap) == Math.floor(width/3));
			
			columnWidth = width/2;
			
			var endColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			var endGap:Number = width - endColumn.width * 2;
			
			assertTrue("expected " + Math.floor(width/2) + " but got " + Math.floor(endGap),
				Math.floor(endGap) == 0);
		}

		/**
		 * Set the column width, then change the column count to see how the column gap changes.
		 * NOTE: Currently commented out due to bug 1657149.
		 */
		public function checkColumnGapOnCountChangeTest():void
		{
			var width:Number = testFrameWidth;
			
			columnCount = 10;
			var cWidth:Number = width/10;
			//to get gap by reducing column width
			columnWidth = cWidth - cWidth/9;
			
			var initColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			var initGap:Number = cWidth - initColumn.width;
			
			//increase column count but no change to column count, gap should reduce
			columnCount = 11;
			cWidth = width/11;
			
			var endColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			var endGap:Number = cWidth - endColumn.width;
			assertTrue("Gap should reduce when column count increased and column width no change. ",
				initGap > endGap);
		}

		 /**
		 * Slowly increase the padding at the top until it pushes a line off the screen
		 * then verify that the last line was the line pushed off the screen.
		 */
		 public function topPaddingSqueezeTest():void
		 {
		 	var length:int = SelManager.textFlow.flowComposer.numLines;
		 	var last:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(length-1);
		 	var size:int = last.textLength;
		 	var count:int = TestFrame.textLength;

		 	for(var i:int = 0; i < 1000; i++){
		 		paddingTop = i;
		 		TestFrame.textFlow.flowComposer.compose();

		 		if(TestFrame.textLength == count - size){
		 			return;
		 		}
		 	}
		 	assertTrue ("Expected " + size + "characters to be pushed off (the last line)" +
		 				" but actually had " + (TestFrame.textLength - count) + "pushed off",
		 				TestFrame.textLength != count - size);
		 }

		 /**
		 * Slowly increase the padding at the bottom until it eats the last line
		 * then verify that the last line was the line eaten.
		 */
		 public function bottomPaddingSqueezeTest():void
		 {
		 	//FLEX: Why no lines?
		 	var length:int = SelManager.textFlow.flowComposer.numLines;
		 	var last:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(length-1);
		 	var size:int = last.textLength;
		 	var count:int = TestFrame.textLength;

		 	for(var i:int = 0; i < 1000; i++){
		 		paddingBottom = i;
		 		TestFrame.textFlow.flowComposer.compose();

		 		if(TestFrame.textLength == count - size){
		 			return;
		 		}
		 	}
		 	assertTrue ("Expected " + size + "characters to be pushed off (the last line)" +
		 				" but actually had " + (TestFrame.textLength - count) + "pushed off",
		 				TestFrame.textLength != count - size);
		 }

		 /**
		 * Increase the left padding until you force the flow to create a new line.
		 */
		 public function leftPaddingSqueezeTest():void
		 {
		 	var length:int = SelManager.textFlow.flowComposer.numLines;

		 	for(var i:int = 0; i < 1000; i++){
		 		paddingLeft = i;
		 		TestFrame.textFlow.flowComposer.compose();

		 		if(SelManager.textFlow.flowComposer.numLines > length){
		 			return;
		 		}
		 	}
		 	assertTrue ("Increasing the left padding to 1000 did not add lines",
		 				SelManager.textFlow.flowComposer.numLines <= length);
		 }

		/**
		 * Increase the right padding until you force the flow to create a new line.
		 */
		 public function rightPaddingSqueezeTest():void
		 {
		 	var length:int = SelManager.textFlow.flowComposer.numLines;

		 	for(var i:int = 0; i < 1000; i++){
		 		paddingRight = i;
		 		TestFrame.textFlow.flowComposer.compose();

		 		if(SelManager.textFlow.flowComposer.numLines > length){
		 			return;
		 		}
		 	}
		 	assertTrue ("Increasing the right padding to 1000 did not add lines",
		 				SelManager.textFlow.flowComposer.numLines <= length);
		 }

		 public function writingModeBreakTest():void
		 {
			// clear all padding on the textFlow for this test
			SelManager.textFlow.paddingTop = 0;
			SelManager.textFlow.paddingLeft = 0;
			SelManager.textFlow.paddingRight = 0;
			SelManager.textFlow.paddingBottom = 0;

		 	initSize = size;
			size = new Point(200,200);

		 	var initCounts:Array = new  Array(SelManager.textFlow.flowComposer.numLines);

	 		var initMode:String = blockProgression;
		 	var nextMode:String = null;

		 	if(initMode == flashx.textLayout.formats.BlockProgression.TB){
		 		nextMode = flashx.textLayout.formats.BlockProgression.RL;
		 	}else{
		 		nextMode = flashx.textLayout.formats.BlockProgression.TB;
		 	}


		 	var i:int = 0;
		 	for(; i < SelManager.textFlow.flowComposer.numLines; i++){
		 		var line:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(i);
		 		if (line.isDamaged())
		 			break;
		 		initCounts[i] = line.textLength;
		 	}
		 	initCounts.length = i;

		 	blockProgression = nextMode;
		 	SelManager.flushPendingOperations();

	 		var endCounts:Array = new  Array(SelManager.textFlow.flowComposer.numLines);

	 		i = 0;
		 	for(; i < SelManager.textFlow.flowComposer.numLines; i++){
		 		line = SelManager.textFlow.flowComposer.getLineAt(i);
		 		if (line.isDamaged())
		 			break;
		 		endCounts[i] = line.textLength;
		 	}
		 	endCounts.length = i;

		 	var one:int = initCounts.length;
		 	var two:int = endCounts.length;

		 	assertTrue("number of lines are not the same after changing writing direction in a square frame",
		 				initCounts.length == endCounts.length);
		 	for(i = 0; i < initCounts.length; i++){
		 		assertTrue("line length of line " + i + " changed after changing writing direction in a square frame",
		 			initCounts[i] == endCounts[i]);
		 	}
		 }

		/**
		 * This test exists solely for snapshotting.
		 */
		 public function checkVerticalAlignTopTest():void
		 {
		 	var division:int =
		 		TestFrame.textFlow.computedFormat.blockProgression ==
		 		BlockProgression.RL ?
		 			TestFrame.compositionWidth / 3 :
		 			TestFrame.compositionHeight /3;

		 	SelManager.selectAll();
		 	SelManager.deleteNextCharacter();
		 	SelManager.flushPendingOperations();

		 	SelManager.insertText("ABC");
		 	SelManager.selectRange(2,2);
		 	SelManager.splitParagraph();
			SelManager.selectRange(1,1);
		 	SelManager.splitParagraph();
		 	SelManager.flushPendingOperations();

		 	verticalAlign = VerticalAlign.TOP;
		 	SelManager.flushPendingOperations();

		 	if(	TestFrame.textFlow.computedFormat.blockProgression ==
		 		BlockProgression.RL
		 	){
		 		assertTrue(
			 		"Vertical Alignment = TOP did not correctly place the first line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(1).x > -1*division &&
			 		SelManager.textFlow.flowComposer.findLineAtPosition(1).x < 0
			 	);
			 	assertTrue(
			 		"Vertical Alignment = TOP did not correctly place the second line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).x > -1*division &&
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).x < 0
			 	);
			 	assertTrue(
			 		"Vertical Alignment = TOP did not correctly place the third line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(5).x > -1*division &&
			 		SelManager.textFlow.flowComposer.findLineAtPosition(5).x < 0
			 	);
		 	}else{
		 		assertTrue(
			 		"Vertical Alignment = TOP did not correctly place the first line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(1).y < division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = TOP did not correctly place the second line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).y < division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = TOP did not correctly place the third line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(5).y < division
			 	);
		 	}
		 }

		/**
		 * This test exists solely for snapshotting.
		 */
		 public function checkVerticalAlignBottomTest():void
		 {
		 	var division:int =
		 		TestFrame.textFlow.computedFormat.blockProgression ==
		 		BlockProgression.RL ?
		 			TestFrame.compositionWidth / 3 :
		 			TestFrame.compositionHeight /3;

		 	SelManager.selectAll();
		 	SelManager.deleteNextCharacter();
		 	SelManager.flushPendingOperations();

		 	SelManager.insertText("ABC");
		 	SelManager.selectRange(2,2);
		 	SelManager.splitParagraph();
			SelManager.selectRange(1,1);
		 	SelManager.splitParagraph();
		 	SelManager.flushPendingOperations();

		 	verticalAlign = VerticalAlign.BOTTOM;
		 	SelManager.flushPendingOperations();

		 	var t1:int = SelManager.textFlow.flowComposer.findLineAtPosition(1).x;
		 	var t2:int = SelManager.textFlow.flowComposer.findLineAtPosition(1).y;

		 	if(	TestFrame.textFlow.computedFormat.blockProgression ==
		 		BlockProgression.RL
		 	){
		 		assertTrue(
		 			"Vertical Alignment = BOTTOM did not correctly place the first line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(1).x < -2*division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = BOTTOM did not correctly place the second line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).x < -2*division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = BOTTOM did not correctly place the third line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(5).x < -2*division
			 	);
		 	}else{
		 		assertTrue(
		 			"Vertical Alignment = BOTTOM did not correctly place the first line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(1).y > 2*division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = BOTTOM did not correctly place the second line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).y > 2*division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = BOTTOM did not correctly place the third line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(5).y > 2*division
			 	);
		 	}
		 }

		/**
		 * This test exists solely for snapshotting.
		 */
		 public function checkVerticalAlignMiddleTest():void
		 {
		 	var division:int =
		 		TestFrame.textFlow.computedFormat.blockProgression ==
		 		BlockProgression.RL ?
		 			TestFrame.compositionWidth / 3 :
		 			TestFrame.compositionHeight /3;


		 	SelManager.selectAll();
		 	SelManager.deleteNextCharacter();
		 	SelManager.flushPendingOperations();

		 	SelManager.insertText("ABC");
		 	SelManager.selectRange(2,2);
		 	SelManager.splitParagraph();
			SelManager.selectRange(1,1);
		 	SelManager.splitParagraph();
		 	SelManager.flushPendingOperations();

		 	verticalAlign = VerticalAlign.MIDDLE;
		 	SelManager.flushPendingOperations();

		 	if(	TestFrame.textFlow.computedFormat.blockProgression ==
		 		BlockProgression.RL
		 	){
		 		assertTrue(
		 			"Vertical Alignment = MIDDLE did not correctly place the first line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(1).x < -1*division &&
			 		SelManager.textFlow.flowComposer.findLineAtPosition(1).x > -2*division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = MIDDLE did not correctly place the second line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).x < -1*division &&
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).x > -2*division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = MIDDLE did not correctly place the third line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(5).x < -1*division &&
			 		SelManager.textFlow.flowComposer.findLineAtPosition(5).x > -2*division
			 	);
		 	}else{
		 		assertTrue(
		 			"Vertical Alignment = MIDDLE did not correctly place the first line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(1).y > division &&
			 		SelManager.textFlow.flowComposer.findLineAtPosition(1).y < 2*division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = MIDDLE did not correctly place the second line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).y > division &&
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).y < 2*division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = MIDDLE did not correctly place the third line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(5).y > division &&
			 		SelManager.textFlow.flowComposer.findLineAtPosition(5).y < 2*division
			 	);
			 }
		 }

		/**
		 * This test exists solely for snapshotting.
		 */
		 public function checkVerticalAlignJustifyTest():void
		 {
		 	var division:int =
		 		TestFrame.textFlow.computedFormat.blockProgression ==
		 		BlockProgression.RL ?
		 			TestFrame.compositionWidth / 3 :
		 			TestFrame.compositionHeight /3;

		 	SelManager.selectAll();
		 	SelManager.deleteNextCharacter();
		 	SelManager.flushPendingOperations();

		 	SelManager.insertText("ABC");
		 	SelManager.selectRange(2,2);
		 	SelManager.splitParagraph();
			SelManager.selectRange(1,1);
		 	SelManager.splitParagraph();
		 	SelManager.flushPendingOperations();

		 	verticalAlign = VerticalAlign.JUSTIFY;
		 	SelManager.flushPendingOperations();

		 	if(	TestFrame.textFlow.computedFormat.blockProgression ==
		 		BlockProgression.RL
		 	){
		 		assertTrue(
		 			"Vertical Alignment = JUSTIFY did not correctly place the first line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(1).x > -1*division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = JUSTIFY did not correctly place the second line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).x < -1*division &&
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).x > -2*division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = JUSTIFY did not correctly place the third line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(5).x < -2*division
			 	);
		 	}else{
		 		assertTrue(
		 			"Vertical Alignment = JUSTIFY did not correctly place the first line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(1).y < division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = JUSTIFY did not correctly place the second line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).y > division &&
			 		SelManager.textFlow.flowComposer.findLineAtPosition(3).y < 2*division
			 	);
			 	assertTrue(
			 		"Vertical Alignment = JUSTIFY did not correctly place the third line.",
			 		SelManager.textFlow.flowComposer.findLineAtPosition(5).y > 2*division
			 	);
			 }
		 }
	
		 // non-empty flow, check if attribute changed after insertion point at position 0
		 public function insertPos0CheckColumnWidthTest():void
		 {
			 var bp:String = TestFrame.textFlow.computedFormat.blockProgression;
			 var width:Number = bp == BlockProgression.TB ? testFrameWidth : testFrameHeight;
			 var cWidth:Number = width/10;
			 
			 columnGap = 0;
			 columnCount = 10;
			 
			 var initColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			 var initWidth:Number = bp == BlockProgression.TB ? initColumn.width : initColumn.height;
			 
			 SelManager.selectRange(0,0);
			 SelManager.insertText("BBB");
			 SelManager.updateAllControllers();
			 
			 var endColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			 var endWidth:Number = bp == BlockProgression.TB ? endColumn.width : endColumn.height;
			 
			 assertTrue("Container attribute got changed, expected column width " + initWidth + " but got " + cWidth,
				 initWidth == endWidth);
		 }
		 
		 //check if container attribute change after insertion in an empty flow
		 public function checkColumnCountEmptyFlowInsertTest():void
		 {
			 var width:Number = testFrameWidth;
			 var cWidth:Number = width/10;
			 
			 columnGap = 0;
			 columnWidth = cWidth;
			 
			 var initCount:Number = TestFrame.columnState.columnCount;
			 
			 //insert text in a empty flow
			 SelManager.selectAll();
			 SelManager.deleteText();
			 SelManager.insertText("AAAAAAAAAAAAAA");
			 SelManager.updateAllControllers();
			 
			 var endCount:Number = TestFrame.columnState.columnCount;
			 
			 assertTrue("container attribute has been changed, expected colume count is" + initCount + " but got " + endCount,
				 initCount == endCount );
		 }
		 
		 // non-empty flow, check if attribute changed after insertion point at end position 
		 public function insertAtEndOfFlowCheckColumnGapTest():void
		 {
			 var bp:String = TestFrame.textFlow.computedFormat.blockProgression;
			 var width:Number = testFrameWidth;
			 
			 columnCount = 2;
			 columnWidth = width/3;
			 
			 var initColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			 var initGap:Number = bp == BlockProgression.TB ? (width - initColumn.width * 2) : (width - initColumn.height * 2);
			 
			 var len:int = SelManager.textFlow.textLength;
			 SelManager.selectRange(len,len);
			 SelManager.insertText("BBB");
			 SelManager.updateAllControllers();
			 
			 var endColumn:Rectangle = TestFrame.columnState.getColumnAt(0);
			 var endGap:Number = bp == BlockProgression.TB ? (width - endColumn.width * 2) : (width - endColumn.height * 2);
			 
			 assertTrue("Container attribute got changed, expected column gap " + initGap + " but got " + endGap,
				 initGap == endGap);
		 }
	
	}
}
