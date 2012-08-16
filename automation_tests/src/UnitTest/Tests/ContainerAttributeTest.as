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
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.engine.TextLine;
	import flash.ui.Mouse;
	import flash.utils.*;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.*;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.GlobalSettings;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.ListElement;
	import flashx.textLayout.elements.ListItemElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.tlf_internal;
	
	import mx.containers.Canvas;

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
	
		public function columnBreakTest():void
		{
			var TestCanvas:Canvas = myEmptyChilds();
			
			var FORMAT1_BB:int = 1;
			var FORMAT1_BA:int = 2;
			var FORMAT2_BB:int = 4;
			var FORMAT2_BA:int = 8;
			var FORMAT3_BB:int = 16;
			var FORMAT3_BA:int = 32;
			
			var tlFmt1:TextLayoutFormat = new TextLayoutFormat();
			var tlFmt2:TextLayoutFormat = new TextLayoutFormat();
			var tlFmt3:TextLayoutFormat = new TextLayoutFormat();
			
			var columnWidth:int = 600;
			for ( var i:int = 0; i < 64; i ++ )
			{
				tlFmt1.columnBreakBefore = (FORMAT1_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;	
				tlFmt1.columnBreakAfter  = (FORMAT1_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				
				tlFmt2.columnBreakBefore = (FORMAT2_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;	
				tlFmt2.columnBreakAfter  = (FORMAT2_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				
				tlFmt3.columnBreakBefore = (FORMAT3_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;	
				tlFmt3.columnBreakAfter  = (FORMAT3_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				
				var cb:ColumnBreak = new ColumnBreak(columnWidth, tlFmt1, tlFmt2, tlFmt3);
				TestCanvas.rawChildren.addChild(cb);
			
				// Verify test results
				var textFlow:TextFlow = cb.textFlow;
				var columnWidthModify:int = columnWidth / 3;
				trace( textFlow.flowComposer.numLines);
				for(var j:int = 0; j < textFlow.flowComposer.numLines ;j ++)
				{
					var textFlowLine:TextFlowLine = textFlow.flowComposer.getLineAt(j);
					var textLine:TextLine = textFlowLine.getTextLine();
					var text:String = textLine.textBlock.content.text;
					var textLineBounds:Rectangle = textFlowLine.getTextLine().getBounds(cb);
					trace(textLineBounds.x, textLineBounds.y, text);
					
					// Assert for STR1's position
					if ( j == 0 )
						assertTrue( isBetween( textLineBounds.x, 0, columnWidthModify ) );
					
					// Assert for STR2's position
					var isStr2InColumn1:Boolean = true;
					if ( tlFmt1.columnBreakAfter == BreakStyle.ALWAYS || tlFmt2.columnBreakBefore == BreakStyle.ALWAYS )
						isStr2InColumn1 = false;
					
					if ( text.search( "STR2" ) >= 0 )
					{
						if ( isStr2InColumn1 )
							assertTrue( isBetween( textLineBounds.x, 0, columnWidthModify ) );
						else
							assertTrue( isBetween( textLineBounds.x, columnWidthModify, columnWidthModify * 2 ) );
					}
					
					// Assert for STR3's position
					if ( text.search( "STR3" ) >= 0 )
					{
						if ( isStr2InColumn1 )
						{
							if ( tlFmt2.columnBreakAfter == BreakStyle.ALWAYS || tlFmt3.columnBreakBefore == BreakStyle.ALWAYS )
								assertTrue( isBetween( textLineBounds.x, columnWidthModify, columnWidthModify * 2 ) );
							else
								assertTrue( isBetween( textLineBounds.x, 0, columnWidthModify ) );
						}
						else
						{
							if ( tlFmt2.columnBreakAfter == BreakStyle.ALWAYS || tlFmt3.columnBreakBefore == BreakStyle.ALWAYS )
								assertTrue( isBetween( textLineBounds.x, columnWidthModify * 2, columnWidthModify * 3 ) );
							else
								assertTrue( isBetween( textLineBounds.x, columnWidthModify, columnWidthModify * 2 ) );
						}
					}
					
				}
			}
		}
		
		private function isBetween(item:int, x1:int, x2:int):Boolean
		{
			if ( item >= x1 && item <= x2 )
				return true;
			return false;
		}
		
		public function containerBreakTest():void
		{
			var TestCanvas:Canvas = myEmptyChilds();
			
			var FORMAT1_BB:int = 1;
			var FORMAT1_BA:int = 2;
			var FORMAT2_BB:int = 4;
			var FORMAT2_BA:int = 8;
			var FORMAT3_BB:int = 16;
			var FORMAT3_BA:int = 32;
			
			var tlFmt1:TextLayoutFormat = new TextLayoutFormat();
			var tlFmt2:TextLayoutFormat = new TextLayoutFormat();
			var tlFmt3:TextLayoutFormat = new TextLayoutFormat();
			
			var containerWidth:int = 200;
			for ( var i:int = 0; i < 64; i ++ )
			{
				tlFmt1.containerBreakBefore = (FORMAT1_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;	
				tlFmt1.containerBreakAfter  = (FORMAT1_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				
				tlFmt2.containerBreakBefore = (FORMAT2_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;	
				tlFmt2.containerBreakAfter  = (FORMAT2_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				
				tlFmt3.containerBreakBefore = (FORMAT3_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;	
				tlFmt3.containerBreakAfter  = (FORMAT3_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				
				var cb:ContainerBreak = new ContainerBreak(containerWidth, tlFmt1, tlFmt2, tlFmt3);
				TestCanvas.rawChildren.addChild(cb);
				
				// Verify test results
				var textFlow:TextFlow = cb.textFlow;
				trace( textFlow.flowComposer.numLines);
				for(var j:int = 0; j < textFlow.flowComposer.numLines ;j ++)
				{
					var textFlowLine:TextFlowLine = textFlow.flowComposer.getLineAt(j);
					var textLine:TextLine = textFlowLine.getTextLine();
					var text:String = textLine.textBlock.content.text;
					var textLineBounds:Rectangle = textFlowLine.getTextLine().getBounds(cb);
					trace(textLineBounds.x, textLineBounds.y, text);
					
					// Assert for STR1's position
					if ( j == 0 )
						assertTrue( isBetween( textLineBounds.x, 0, containerWidth ) );
					
					// Assert for STR2's position
					var isStr2InColumn1:Boolean = true;
					if ( tlFmt1.containerBreakAfter == BreakStyle.ALWAYS || tlFmt2.containerBreakBefore == BreakStyle.ALWAYS )
						isStr2InColumn1 = false;
					
					if ( text.search( "STR2" ) >= 0 )
					{
						if ( isStr2InColumn1 )
							assertTrue( isBetween( textLineBounds.x, 0, containerWidth ) );
						else
							assertTrue( isBetween( textLineBounds.x, containerWidth, containerWidth * 2 ) );
					}
					
					// Assert for STR3's position
					if ( text.search( "STR3" ) >= 0 )
					{
						if ( isStr2InColumn1 )
						{
							if ( tlFmt2.containerBreakAfter == BreakStyle.ALWAYS || tlFmt3.containerBreakBefore == BreakStyle.ALWAYS )
								assertTrue( isBetween( textLineBounds.x, containerWidth, containerWidth * 2 ) );
							else
								assertTrue( isBetween( textLineBounds.x, 0, containerWidth ) );
						}
						else
						{
							if ( tlFmt2.containerBreakAfter == BreakStyle.ALWAYS || tlFmt3.containerBreakBefore == BreakStyle.ALWAYS )
								assertTrue( isBetween( textLineBounds.x, containerWidth * 2, containerWidth * 3 ) );
							else
								assertTrue( isBetween( textLineBounds.x, containerWidth, containerWidth * 2 ) );
						}
					}
					
				}
			}
		}
		
		public function columnContainerBreakTest0():void
		{
			columnContainerBreakTestX(0);
		}
		
		public function columnContainerBreakTest1000():void
		{
			columnContainerBreakTestX(1000);
		}
		
		public function columnContainerBreakTest2000():void
		{
			columnContainerBreakTestX(2000);
		}
		
		public function columnContainerBreakTest3000():void
		{
			columnContainerBreakTestX(3000);
		}
		
		public function columnContainerBreakTest4000():void
		{
			columnContainerBreakTestX(4000);
		}
		
		public function columnContainerBreakTestX(startIdx:int):void
		{
			var TestCanvas:Canvas = myEmptyChilds();
			
			var tlFmt1:TextLayoutFormat = new TextLayoutFormat();
			var tlFmt2:TextLayoutFormat = new TextLayoutFormat();
			var tlFmt3:TextLayoutFormat = new TextLayoutFormat();
			
			var FORMAT1_COL_BB:int = 1;
			var FORMAT1_COL_BA:int = 2;
			var FORMAT1_CON_BB:int = 4;
			var FORMAT1_CON_BA:int = 8;
			var FORMAT2_COL_BB:int = 16;
			var FORMAT2_COL_BA:int = 32;
			var FORMAT2_CON_BB:int = 64;
			var FORMAT2_CON_BA:int = 128;
			var FORMAT3_COL_BB:int = 256;
			var FORMAT3_COL_BA:int = 512;
			var FORMAT3_CON_BB:int = 1024;
			var FORMAT3_CON_BA:int = 2048;
			
			var containerWidth:int = 300;
			for ( var i:int = startIdx; i < startIdx + 1000; i ++ )
			{
				if ( i >= 4096 )
					break;
				TestCanvas = myEmptyChilds();
				tlFmt1.columnBreakBefore    = (FORMAT1_COL_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				tlFmt1.columnBreakAfter     = (FORMAT1_COL_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				tlFmt1.containerBreakBefore = (FORMAT1_CON_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;	
				tlFmt1.containerBreakAfter  = (FORMAT1_CON_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				
				tlFmt2.columnBreakBefore    = (FORMAT2_COL_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				tlFmt2.columnBreakAfter     = (FORMAT2_COL_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				tlFmt2.containerBreakBefore = (FORMAT2_CON_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;	
				tlFmt2.containerBreakAfter  = (FORMAT2_CON_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				
				tlFmt3.columnBreakBefore    = (FORMAT3_COL_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				tlFmt3.columnBreakAfter     = (FORMAT3_COL_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
				tlFmt3.containerBreakBefore = (FORMAT3_CON_BB & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;	
				tlFmt3.containerBreakAfter  = (FORMAT3_CON_BA & i) ? BreakStyle.ALWAYS : BreakStyle.AUTO;
						
				var cb:ColumnContainerBreak = new ColumnContainerBreak(containerWidth, tlFmt1, tlFmt2, tlFmt3);
				TestCanvas.rawChildren.addChild(cb);
				
				// Verify test results
				var textFlow:TextFlow = cb.textFlow;
				trace( textFlow.flowComposer.numLines);
				var bStr2Checked:Boolean = false;
				var bStr3Checked:Boolean = false;
				for(var j:int = 0; j < textFlow.flowComposer.numLines ;j ++)
				{
					var textFlowLine:TextFlowLine = textFlow.flowComposer.getLineAt(j);
					var textLine:TextLine = textFlowLine.getTextLine();
					var text:String = textLine.textBlock.content.text;
					var textLineBounds:Rectangle = textFlowLine.getTextLine().getBounds(cb);
					trace(textLineBounds.x, textLineBounds.y, text);
					
					// Assert for STR1's position
					if ( j == 0 )
						assertTrue( isBetween( textLineBounds.x, 0, containerWidth ) );
					
					// Assert for STR2's position, 
					// str2Pos = 1 means str2 in container1, column1
					// str2Pos = 2 means str2 in container1, column2
					// str2Pos = 3 means str2 in container2, column1
					var str2Pos:int = 1;
					if ( tlFmt1.containerBreakAfter == BreakStyle.ALWAYS || tlFmt2.containerBreakBefore == BreakStyle.ALWAYS )
						str2Pos = 3;
					else if ( tlFmt1.columnBreakAfter == BreakStyle.ALWAYS || tlFmt2.columnBreakBefore == BreakStyle.ALWAYS )
						str2Pos = 2;
					
					var columnWidth:int = containerWidth / 3;
					if ( ! bStr2Checked && text.search( "STR2" ) >= 0 )
					{
						bStr2Checked = true;
						switch ( str2Pos )
						{
						case 1:
							assertTrue( isBetween( textLineBounds.x, 0, columnWidth ) );
							break;
						case 2:
							assertTrue( isBetween( textLineBounds.x, columnWidth, columnWidth * 2 ) );
							break;
						case 3:
							assertTrue( isBetween( textLineBounds.x, containerWidth, containerWidth + columnWidth ) );
							break;
						default: break;
						}
					}
					
					// Assert for STR3's position
					if ( ! bStr3Checked && text.search( "STR3" ) >= 0 )
					{
						bStr3Checked = true;
						var isStr3ColumnBreak    :Boolean = false;
						var isStr3ContainerBreak :Boolean = false;
						if ( tlFmt2.columnBreakAfter == BreakStyle.ALWAYS || tlFmt3.columnBreakBefore == BreakStyle.ALWAYS )
							isStr3ColumnBreak = true;
						
						if ( tlFmt2.containerBreakAfter == BreakStyle.ALWAYS || tlFmt3.containerBreakBefore == BreakStyle.ALWAYS )
							isStr3ContainerBreak = true;
						
						// str3Pos = 1 means str3 in container1, column1
						// str3Pos = 2 means str3 in container1, column2
						// str3Pos = 3 means str3 in container1, column3
						// str3Pos = 4 means str3 in container2, column1
						// str3Pos = 5 means str3 in container2, column2
						// str3Pos = 6 means str3 in container3, column1
						var str3Pos:int = 0;
						switch ( str2Pos )
						{
						case 1:
							if ( ! isStr3ContainerBreak && ! isStr3ColumnBreak )
								str3Pos = 1;
							if ( ! isStr3ContainerBreak && isStr3ColumnBreak )
								str3Pos = 2;
							if ( isStr3ContainerBreak )
								str3Pos = 4;
							break;
						case 2:
							if ( ! isStr3ContainerBreak && ! isStr3ColumnBreak )
								str3Pos = 2;
							if ( ! isStr3ContainerBreak && isStr3ColumnBreak )
								str3Pos = 3;
							if ( isStr3ContainerBreak )
								str3Pos = 4;
							break;
						case 3:
							if ( ! isStr3ContainerBreak && ! isStr3ColumnBreak )
								str3Pos = 4;
							if ( ! isStr3ContainerBreak && isStr3ColumnBreak )
								str3Pos = 5;
							if ( isStr3ContainerBreak )
								str3Pos = 6;
							break;
						default : break;
						}
								
						switch ( str3Pos )
						{
						case 1:
							assertTrue( isBetween( textLineBounds.x, 0, columnWidth ) );
							break;
						case 2:
							assertTrue( isBetween( textLineBounds.x, columnWidth, columnWidth * 2 ) );
							break;
						case 3:
							assertTrue( isBetween( textLineBounds.x, columnWidth * 2, columnWidth * 3 ) );
							break;
						case 4:
							assertTrue( isBetween( textLineBounds.x, containerWidth, containerWidth + columnWidth ) );
							break;
						case 5:
							assertTrue( isBetween( textLineBounds.x, containerWidth + columnWidth, containerWidth + columnWidth * 2 ) );
							break;
						case 6:
							assertTrue( isBetween( textLineBounds.x, containerWidth * 2, containerWidth * 2 + columnWidth ) );
							break;
						default : break;
						}
						
					}
				}
			}
		}
	
		public function myEmptyChilds():Canvas
		{
			var TestCanvas:Canvas = null;
			TestDisplayObject = testApp.getDisplayObject();
			if (TestDisplayObject)
			{
				TestCanvas = Canvas(TestDisplayObject);
				TestCanvas.removeAllChildren();
				var iCnt:int = TestCanvas.numChildren;
				for ( var a:int = 0; a < iCnt; a ++ )
				{
					TestCanvas.rawChildren.removeChildAt(0);
				}
			}
			
			return TestCanvas;
		}
		
		// mjzhang : Watson Bug#2841799 When lineBreak="toFit" the contentBounds width does 
		// not include the trailing whitespace
		public function ContentBoundsWithWhitespaces():void
		{
			// This is the switch for calculate whitespace or not regardless lineBreak="toFix".
			GlobalSettings.alwaysCalculateWhitespaceBounds = true;
			
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("AAAAAAAAAAAAAA");
			SelManager.updateAllControllers();
			
			var textFlowLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var textLength:Number = textFlowLine.lineExtent;
			var contentBounds:Number = SelManager.textFlow.flowComposer.getControllerAt(0).getContentBounds().width;
			
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("AAAAAAAAAAAAAA  ");
			SelManager.updateAllControllers();
			
			var textFlowLine1:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0);
			var textWithSpace:Number = textFlowLine1.lineExtent;
			var contentBoundsWithSpace:Number = SelManager.textFlow.flowComposer.getControllerAt(0).getContentBounds().width;
			// mjzhang : if the blockProgression is RL, we needs to check the height, not the width.
			if ( SelManager.textFlow.blockProgression == BlockProgression.RL )
			{
				textWithSpace = textFlowLine1.lineExtent;
				contentBoundsWithSpace = SelManager.textFlow.flowComposer.getControllerAt(0).getContentBounds().height;
			}
			
			GlobalSettings.alwaysCalculateWhitespaceBounds = false;
			
			assertTrue("With spaces text length should larger than no spaces text length.", 
				textWithSpace > textLength );
			assertTrue("With spaces text length should larger than no spaces text length.", 
				contentBoundsWithSpace > contentBounds );
		}
		
		// mjzhang : Bug#2835316 The TextLine is INVALID and cannot be used to access the current state of the TextBlock
		public function TextSelectAllTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var markup:String = '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh</span></p></TextFlow>';
			var textFlowNew:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			
			var textLayoutFormat:TextLayoutFormat = new TextLayoutFormat();
			textLayoutFormat.fontSize = 12;
			textLayoutFormat.textIndent = 0;
			textLayoutFormat.paragraphSpaceAfter = 5;
			textLayoutFormat.fontFamily="Arial" ;
			
			var paraElement:ParagraphElement = textFlowNew.getChildAt(0) as ParagraphElement;
			var paraElementCopy:ParagraphElement = paraElement.deepCopy(0, paraElement.textLength) as ParagraphElement;
			paraElementCopy.format = textLayoutFormat;
			textFlow.replaceChildren(0, textFlow.numChildren, paraElementCopy);
			textFlow.whiteSpaceCollapse = "preserve";
			textFlow.flowComposer.updateAllControllers();
			
			var cc:ContainerController = SelManager.textFlow.flowComposer.getControllerAt(0);
			cc.setCompositionSize(229, 81);
			cc.verticalScrollPolicy = ScrollPolicy.ON;
			cc.horizontalScrollPolicy = ScrollPolicy.ON;
			SelManager.selectRange(40, 40);
			
			var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.DOUBLE_CLICK, true, false, 80, 80);
			TestFrame.container["dispatchEvent"](mouseEvent);
			SelManager.flushPendingOperations();
		}
		
		// mjzhang : Bug#2898924 TLF reports incorrect content height after composition when floats are used with padding
		public function ContentBoundsWithPaddingTest():void
		{
			// Get image content height which has padding top set
			var textFlow:TextFlow = SelManager.textFlow;
			var markup:String = '<TextFlow fontFamily="Arial" fontSize="16" paddingBottom="2" paddingLeft="2" paddingRight="2" paddingTop="2" whiteSpaceCollapse="preserve" version="2.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><img paddingTop="-100" paddingLeft="50" height="auto" width="auto" source="http://www.lacitelibreria.info/ambientazione-cite/cite-libreria-logo.png" float="left"/><span fontFamily="Georgia" fontSize="24">La Cité Libreria Cafè</span></p></TextFlow>';
			var textFlowNew:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			
			textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, statusChangeHandler );
			
			var paraElement:ParagraphElement = textFlowNew.getChildAt(0) as ParagraphElement;
			var paraElementCopy:ParagraphElement = paraElement.deepCopy(0, paraElement.textLength) as ParagraphElement;
			textFlow.replaceChildren(0, textFlow.numChildren, paraElementCopy);
			textFlow.flowComposer.updateAllControllers();
			SelManager.updateAllControllers();
		}
		
		// mjzhang : Track the completion of loading inlines
		private function statusChangeHandler(obj:Event):void
		{
			var event:StatusChangeEvent = StatusChangeEvent(obj);
			var textFlow:TextFlow = event.element.getTextFlow();
			switch (event.status)
			{
				case InlineGraphicElementStatus.LOADING:
					break;
				case InlineGraphicElementStatus.SIZE_PENDING:
					textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,statusChangeHandler);
					var contentHeight:int = textFlow.flowComposer.getControllerAt(0).getContentBounds().height;
					var contentWidth:int  = textFlow.flowComposer.getControllerAt(0).getContentBounds().width;
					assertTrue("Content height should calculate padding info of inlinegraphic, should be 44", contentHeight == 44);
					assertTrue("Content width should calculate padding info of inlinegraphic, should be 670", contentWidth == 669);
					break;
				case InlineGraphicElementStatus.READY:
					break;
				default:
					break;
			}
		}
		
		// mjzhang : Bug#2758977 <s:p color="red"/> throws out of range error - can you do color lookup like Flex SDK?
		// Tests all the color options, also test Upper case and bad case(XXX)
		public function colorPropetyTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var markup:String = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008">'
				+ '<p color="black"><span>black</span></p>'
				+ '<p color="blue"><span>blue</span></p>'
				+ '<p color="green"><span>green</span></p>'
				+ '<p color="gray"><span>gray</span></p>'
				+ '<p color="silver"><span>silver</span></p>'
				+ '<p color="lime"><span>lime</span></p>'
				+ '<p color="olive"><span>olive</span></p>'
				+ '<p color="white"><span>white</span></p>'
				+ '<p color="yellow"><span>yellow</span></p>'
				+ '<p color="maroon"><span>maroon</span></p>'
				+ '<p color="navy"><span>navy</span></p>'
				+ '<p color="red"><span>Red</span></p>'
				+ '<p color="purple"><span>purple</span></p>'
				+ '<p color="teal"><span>teal</span></p>'
				+ '<p color="fuchsia"><span>fuchsia</span></p>'
				+ '<p color="aqua"><span>aqua</span></p>'
				+ '<p color="magenta"><span>magenta</span></p>'
				+ '<p color="cyan"><span>cyan</span></p>'
				+ '<p color="CYAN"><span>CYAN</span></p>'
				+ '<p color="XXX"><span>XXX</span></p>'
				+ '</TextFlow>';
			var textFlowNew:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			
			SelManager.selectAll();
			SelManager.deleteText();
			for ( var i:int = 0; i < 20; i ++ )
			{
				var paraElement:ParagraphElement = textFlowNew.getChildAt(i) as ParagraphElement;
				var paraElementCopy:ParagraphElement = paraElement.deepCopy(0, paraElement.textLength) as ParagraphElement;
				textFlow.replaceChildren(i, i, paraElementCopy);
			}
			SelManager.updateAllControllers();
			
			var paraBlack  :ParagraphElement = textFlow.getChildAt(0) as ParagraphElement;
			var paraBlue   :ParagraphElement = textFlow.getChildAt(1) as ParagraphElement;
			var paraGreen  :ParagraphElement = textFlow.getChildAt(2) as ParagraphElement;
			var paraGray   :ParagraphElement = textFlow.getChildAt(3) as ParagraphElement;
			var paraSilver :ParagraphElement = textFlow.getChildAt(4) as ParagraphElement;
			var paraLime   :ParagraphElement = textFlow.getChildAt(5) as ParagraphElement;
			var paraOlive  :ParagraphElement = textFlow.getChildAt(6) as ParagraphElement;
			var paraWhite  :ParagraphElement = textFlow.getChildAt(7) as ParagraphElement;
			var paraYellow :ParagraphElement = textFlow.getChildAt(8) as ParagraphElement;
			var paraMaroon :ParagraphElement = textFlow.getChildAt(9) as ParagraphElement;
			var paraNavy   :ParagraphElement = textFlow.getChildAt(10) as ParagraphElement;
			var paraRed    :ParagraphElement = textFlow.getChildAt(11) as ParagraphElement;
			var paraPurple :ParagraphElement = textFlow.getChildAt(12) as ParagraphElement;
			var paraTeal   :ParagraphElement = textFlow.getChildAt(13) as ParagraphElement;
			var paraFuchsia:ParagraphElement = textFlow.getChildAt(14) as ParagraphElement;
			var paraAqua   :ParagraphElement = textFlow.getChildAt(15) as ParagraphElement;
			var paraMagenta:ParagraphElement = textFlow.getChildAt(16) as ParagraphElement;
			var paraCyan   :ParagraphElement = textFlow.getChildAt(17) as ParagraphElement;
			var paraCYAN   :ParagraphElement = textFlow.getChildAt(18) as ParagraphElement;
			var paraXXX    :ParagraphElement = textFlow.getChildAt(19) as ParagraphElement;
			assertTrue("Paragraph color value should be equal", paraBlack.format.color   == ColorName.BLACK);
			assertTrue("Paragraph color value should be equal", paraBlue.format.color    == ColorName.BLUE);
			assertTrue("Paragraph color value should be equal", paraGreen.format.color   == ColorName.GREEN);
			assertTrue("Paragraph color value should be equal", paraGray.format.color    == ColorName.GRAY);
			assertTrue("Paragraph color value should be equal", paraSilver.format.color  == ColorName.SILVER);
			assertTrue("Paragraph color value should be equal", paraLime.format.color    == ColorName.LIME);
			assertTrue("Paragraph color value should be equal", paraOlive.format.color   == ColorName.OLIVE);
			assertTrue("Paragraph color value should be equal", paraWhite.format.color   == ColorName.WHITE);
			assertTrue("Paragraph color value should be equal", paraYellow.format.color  == ColorName.YELLOW);
			assertTrue("Paragraph color value should be equal", paraMaroon.format.color  == ColorName.MAROON);
			assertTrue("Paragraph color value should be equal", paraNavy.format.color    == ColorName.NAVY);
			assertTrue("Paragraph color value should be equal", paraRed.format.color     == ColorName.RED);
			assertTrue("Paragraph color value should be equal", paraPurple.format.color  == ColorName.PURPLE);
			assertTrue("Paragraph color value should be equal", paraTeal.format.color    == ColorName.TEAL);
			assertTrue("Paragraph color value should be equal", paraFuchsia.format.color == ColorName.FUCHSIA);
			assertTrue("Paragraph color value should be equal", paraAqua.format.color    == ColorName.AQUA);
			assertTrue("Paragraph color value should be equal", paraMagenta.format.color == ColorName.MAGENTA);
			assertTrue("Paragraph color value should be equal", paraCyan.format.color    == ColorName.CYAN);
			assertTrue("Paragraph color value should be equal", paraCYAN.format.color    == undefined);
			assertTrue("Paragraph color value should be equal", paraXXX.format.color     == undefined);
		}
		
		private function myHBeamCursorFunction(value:String):String
		{
			var cursorPoints:Vector.<Number>;
			var cursorCommands:Vector.<int>;
			
			// mjzhang : IBEAM cursor have different appearence on Mac and Win, so we draw HBEAM differently
			if ( Capabilities.os.search("Mac OS") > -1 )
			{
				cursorPoints = new <Number>[0,0, 0,1, 3,4,  3,4, 0,7, 0,8,  3,4, 16,4,  19,0, 19,1, 17,4,  17,4, 19,7, 19,8,  10,3, 10,6];
				cursorCommands = new <int>[1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2];
			}
			else
			{
				cursorPoints = new <Number>[0,0, 0,4, 0,5, 0,9, 1,4, 17,4, 17,0, 17,4, 17,5, 17,9];
				cursorCommands = new <int>[1, 2, 1, 2, 1, 2, 1, 2, 1, 2];
			}
			var cursorShape:Shape = new Shape();
			cursorShape.graphics.beginFill(0x000000, 1.0);
			cursorShape.graphics.lineStyle(1);
			cursorShape.graphics.drawPath(cursorCommands, cursorPoints);
			cursorShape.graphics.endFill();
			var cursorBmp:BitmapData = new BitmapData(20, 10, true, 0);
			cursorBmp.draw(cursorShape);
			
			var cursorData:Vector.<BitmapData> = new Vector.<BitmapData>();
			cursorData.push(cursorBmp);
			
			var MouseCursorDataClass:Class;
			try 
			{
				MouseCursorDataClass = getDefinitionByName("flash.ui.MouseCursorData") as Class;
			}
			catch(e:Error) {}
			
			if (MouseCursorDataClass)
			{
				var mouseCursorData:Object = new MouseCursorDataClass();
				mouseCursorData.data = cursorData;
				mouseCursorData.hotSpot = new Point(10, 5);
				
				var registerCursor:Function = Mouse["registerCursor"];
				if ( Mouse["registerCursor"] != undefined )
				{ 
					registerCursor("hbeam", mouseCursorData);
				}
				
			}
			
			return "hbeam";
			
		}
		
		public function HBeamCursorTest():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			
			var markup:String = '<TextFlow whiteSpaceCollapse="preserve" version="2.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p paddingBottom="25"><span>Move your mouse over this text to see custom cursor</span></p></TextFlow>';
			
			var config:Configuration = new Configuration();
			config.cursorFunction = myHBeamCursorFunction;
			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT, config);
			textFlow.blockProgression = BlockProgression.RL;
			textFlow.interactionManager = new EditManager();
			
			var sprite:Sprite = new Sprite();
			textFlow.flowComposer.addController(new ContainerController(sprite, 400, 200));
			textFlow.flowComposer.updateAllControllers();
			
			var testCanvas:Canvas = myEmptyChilds();
			testCanvas.rawChildren.addChild(sprite);
		}
		
		// mjzhang : Bug#2907691 When composition starts in middle of the container, paddingBottom for the previous paragraph is ignored
		public function paddingBottomTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var markup:String = '<TextFlow whiteSpaceCollapse="preserve" version="2.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p paddingBottom="25"><span>para1</span></p><p paddingBottom="25"><span>para2</span></p><p paddingBottom="25"><span>para3</span></p></TextFlow>';
			var textFlowNew:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.replaceChildren(0, textFlow.numChildren, textFlowNew.mxmlChildren);			
			SelManager.updateAllControllers();
			
			SelManager.selectRange(100, 100);
			SelManager.insertText("aaa");
			SelManager.textFlow.flowComposer.compose();
			
			var textFlowLine:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(2);
			var canvas:Canvas = Canvas(testApp.getDisplayObject());
			var textLineBounds:Rectangle = textFlowLine.getTextLine().getBounds(canvas);
			assertTrue("Paragraph3's top value should be 87.55.", textLineBounds.top == 87.55);
		}
		
		//Fix bug 2869747  using TextFlow.flowComposer and ContainerController, displayed text is incorrectly masked
		public function scrollRectTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
		    var container:Sprite = new Sprite();
			container = textFlow.flowComposer.getControllerAt(0).container as Sprite;
			textFlow.flowComposer.addController(new ContainerController(container, 200, 100));		
			textFlow.flowComposer.updateAllControllers();	
			textFlow.flowComposer.removeAllControllers();		
			textFlow.flowComposer.addController(new ContainerController(container, 500, 500));
			textFlow.flowComposer.updateAllControllers();
		}
		
	}
}
