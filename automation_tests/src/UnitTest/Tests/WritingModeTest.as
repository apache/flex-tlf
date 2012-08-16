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
	import flash.text.engine.TextLine;

	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;

	public class WritingModeTest extends VellumTestCase
	{
		public function WritingModeTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Container";
			metaData.productSubArea = "Text Direction";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = WritingModeTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

   		// test each writingMode with two columns setting them on the TextFlow
   		// have to clear any container overrides - not sure how they got there.

   		public function japaneseAttrib():void
   		{
   			SelManager.selectRange(0,0);
   			SelManager.flushPendingOperations();

   			SelManager.textFlow.blockProgression = BlockProgression.RL;
   			SelManager.textFlow.columnCount = 2;
   			SelManager.textFlow.direction = Direction.LTR;

   			assertTrue(true, SelManager.textFlow.format.blockProgression == BlockProgression.RL);
   			assertTrue(true, SelManager.textFlow.computedFormat.blockProgression == BlockProgression.RL);
   		}

   		public function arabicAttrib():void
   		{
   			SelManager.selectRange(0,0);
   			SelManager.flushPendingOperations();

   			SelManager.textFlow.blockProgression = BlockProgression.TB;
   			SelManager.textFlow.columnCount = 2;
   			SelManager.textFlow.direction = Direction.RTL;

   			assertTrue(true, SelManager.textFlow.format.blockProgression == BlockProgression.TB );
   			assertTrue(true, SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB );
   		}

   		public function romanAttrib():void
   		{
   			SelManager.selectRange(0,0);
   			SelManager.flushPendingOperations();

   			SelManager.textFlow.blockProgression = BlockProgression.TB;
   			SelManager.textFlow.columnCount = 2;
   			SelManager.textFlow.direction = Direction.LTR;

			assertTrue(true, SelManager.textFlow.format.blockProgression == BlockProgression.TB );
			assertTrue(true, SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB );
   		}

   		// No writing system uses this, but it's still a possible combination
   		public function rtlAttrib():void
   		{
   			SelManager.selectRange(0,0);
   			SelManager.flushPendingOperations();

   			SelManager.textFlow.blockProgression = BlockProgression.RL;
   			SelManager.textFlow.columnCount = 2;
   			SelManager.textFlow.direction = Direction.RTL;

   			assertTrue(true, SelManager.textFlow.format.blockProgression == BlockProgression.RL);
   			assertTrue(true, SelManager.textFlow.computedFormat.blockProgression == BlockProgression.RL);
   		}

   		// Test BlockProgression.RL + Direction.LTR
   		public function japanesePositioning():void
   		{
   			// Force the intended text positioning
   			SelManager.textFlow.blockProgression = BlockProgression.RL;
   			SelManager.textFlow.direction = Direction.LTR;
		 	SelManager.textFlow.paddingBottom = 0;
		 	SelManager.textFlow.paddingLeft = 0;
		 	SelManager.textFlow.paddingRight = 0;
		 	SelManager.textFlow.paddingTop = 0;
		 	SelManager.textFlow.columnCount = 2;
		 	SelManager.textFlow.columnGap = 0;

		 	// Create a new paragraph in the second column
		 	SelManager.selectRange(1842,1842);
		 	SelManager.splitParagraph();

		 	SelManager.flushPendingOperations();

		 	// Get the posititioning of the first and second columns
		 	var x1:int = SelManager.textFlow.flowComposer.findLineAtPosition(0).x;
		 	var y1:int = SelManager.textFlow.flowComposer.findLineAtPosition(0).y;
		 	var x2:int = SelManager.textFlow.flowComposer.findLineAtPosition(1843).x;
		 	var y2:int = SelManager.textFlow.flowComposer.findLineAtPosition(1843).y;

		 	assertTrue(
		 		"BlockProgression: BP: R to L, Direction: L to R placed text in an incorrect direction.",
		 		x1 == x2
		 	);
		 	assertTrue(
		 		"BlockProgression: BP: R to L, Direction: L to R placed text in an incorrect direction.",
		 		y1 < y2
		 	);
   		}

   		// Test BlockProgression.TB + Direction.LTR
   		public function romanPositioning():void
   		{
   			// Force the intended text positioning
   			SelManager.textFlow.blockProgression = BlockProgression.TB;
   			SelManager.textFlow.direction = Direction.LTR;
		 	SelManager.textFlow.paddingBottom = 0;
		 	SelManager.textFlow.paddingLeft = 0;
		 	SelManager.textFlow.paddingRight = 0;
		 	SelManager.textFlow.paddingTop = 0;
		 	SelManager.textFlow.columnCount = 2;
		 	SelManager.textFlow.columnGap = 0;

		 	// Create a new paragraph in the second column
		 	SelManager.selectRange(1862,1862);
		 	SelManager.splitParagraph();

		 	SelManager.flushPendingOperations();

		 	// Get the posititioning of the first and second columns
		 	var x1:int = SelManager.textFlow.flowComposer.findLineAtPosition(0).x;
		 	var y1:int = SelManager.textFlow.flowComposer.findLineAtPosition(0).y;
		 	var x2:int = SelManager.textFlow.flowComposer.findLineAtPosition(1873).x;
		 	var y2:int = SelManager.textFlow.flowComposer.findLineAtPosition(1873).y;

		 	assertTrue(
		 		"BlockProgression: BP: T to B, Direction: L to R placed text in an incorrect direction.",
		 		x1 < x2
		 	);
		 	assertTrue(
		 		"BlockProgression: BP: T to B, Direction: L to R placed text in an incorrect direction.",
		 		y1 == y2
		 	);
   		}

   		// Test BlockProgression.RL + Direction.RTL
   		public function rtlPositioning():void
   		{
   			// Force the intended text positioning
   			SelManager.textFlow.blockProgression = BlockProgression.RL;
   			SelManager.textFlow.direction = Direction.RTL;
		 	SelManager.textFlow.paddingBottom = 0;
		 	SelManager.textFlow.paddingLeft = 0;
		 	SelManager.textFlow.paddingRight = 0;
		 	SelManager.textFlow.paddingTop = 0;
		 	SelManager.textFlow.columnCount = 2;
		 	SelManager.textFlow.columnGap = 0;

		 	// Create a new paragraph in the second column
		 	SelManager.selectRange(1842,1842);
		 	SelManager.splitParagraph();

		 	SelManager.flushPendingOperations();

		 	// Get the posititioning of the first and second columns
		 	var x1:int = SelManager.textFlow.flowComposer.findLineAtPosition(0).x;
		 	var y1:int = SelManager.textFlow.flowComposer.findLineAtPosition(0).y;
		 	var x2:int = SelManager.textFlow.flowComposer.findLineAtPosition(1843).x;
		 	var y2:int = SelManager.textFlow.flowComposer.findLineAtPosition(1843).y;

		 	assertTrue(
		 		"BlockProgression: BP: R to L, Direction: R to L placed text in an incorrect direction.",
		 		x1 == x2
		 	);
		 	assertTrue(
		 		"BlockProgression: BP: R to L, Direction: R to L placed text in an incorrect direction.",
		 		y1 < y2
		 	);
   		}

   		// Test BlockProgression.TB + Direction.RTL
  		public function arabicPositioning():void
   		{
   			// Force the intended text positioning
   			SelManager.textFlow.blockProgression = BlockProgression.TB;
   			SelManager.textFlow.direction = Direction.RTL;
		 	SelManager.textFlow.paddingBottom = 0;
		 	SelManager.textFlow.paddingLeft = 0;
		 	SelManager.textFlow.paddingRight = 0;
		 	SelManager.textFlow.paddingTop = 0;
		 	SelManager.textFlow.columnCount = 2;
		 	SelManager.textFlow.columnGap = 0;

		 	// Create a new paragraph in the second column
		 	SelManager.selectRange(1862,1862);
		 	SelManager.splitParagraph();

		 	SelManager.flushPendingOperations();

		 	// Get the posititioning of the first and second columns
		 	var x1:int = SelManager.textFlow.flowComposer.findLineAtPosition(0).x;
		 	var y1:int = SelManager.textFlow.flowComposer.findLineAtPosition(0).y;
		 	var x2:int = SelManager.textFlow.flowComposer.findLineAtPosition(1873).x;
		 	var y2:int = SelManager.textFlow.flowComposer.findLineAtPosition(1873).y;

		 	assertTrue(
		 		"BlockProgression: BlockProgression: T to B, Direction: R to L placed text in an incorrect direction.",
		 		x1 > x2
		 	);
		 	assertTrue(
		 		"BlockProgression: BlockProgression: T to B, Direction: R to L placed text in an incorrect direction.",
		 		y1 == y2
		 	);
   		}

   		// Test BlockProgression.RL + Direction.LTR
   		public function japaneseJustification():void
   		{
			// Force the intended text positioning
   			SelManager.textFlow.blockProgression = BlockProgression.RL;
   			SelManager.textFlow.direction = Direction.LTR;

		 	// Create new paragraphs to with severe justification differences
		 	SelManager.insertText("M");
		 	SelManager.insertText("MMMMMM");
		 	SelManager.insertText("MMMMMMMMMMMM");
		 	SelManager.selectRange(1,1);
		 	SelManager.splitParagraph();
		 	SelManager.selectRange(8,8);
		 	SelManager.splitParagraph();

			var xPos:Array = new Array();
			var yPos:Array = new Array();

			for ( var l:int = 0; l < TestFrame.textFlow.flowComposer.numLines; l++ )
			{
				var testLine:TextLine = SelManager.textFlow.flowComposer.getLineAt(l).getTextLine();

				xPos.push(testLine.getBounds( TestFrame.container as DisplayObject ).x);
				yPos.push(testLine.getBounds( TestFrame.container as DisplayObject ).y);
			}

			// Check that we're on different lines
			assertTrue( "Justification incorrect with BlockProgression: R to L, Direction: L to R",
						xPos[0] > xPos[1] && xPos[1] > xPos[2] );
			// Justification is correct
			assertTrue( "Justification incorrect with BlockProgression: R to L, Direction: L to R",
						yPos[0] == yPos[1] && yPos[1] == yPos[2] );
   		}

   		// Test BlockProgression.TB + Direction.LTR
   		public function romanJustification():void
   		{
			// Force the intended text positioning
   			SelManager.textFlow.blockProgression = BlockProgression.TB;
   			SelManager.textFlow.direction = Direction.LTR;

		 	// Create new paragraphs to with severe justification differences
		 	SelManager.insertText("M");
		 	SelManager.insertText("MMMMMM");
		 	SelManager.insertText("MMMMMMMMMMMM");
		 	SelManager.selectRange(1,1);
		 	SelManager.splitParagraph();
		 	SelManager.selectRange(8,8);
		 	SelManager.splitParagraph();

			var xPos:Array = new Array();
			var yPos:Array = new Array();

			for ( var l:int = 0; l < TestFrame.textFlow.flowComposer.numLines; l++ )
			{
				var testLine:TextLine = SelManager.textFlow.flowComposer.getLineAt(l).getTextLine();

				xPos.push(testLine.getBounds( TestFrame.container as DisplayObject ).x);
				yPos.push(testLine.getBounds( TestFrame.container as DisplayObject ).y);
			}

			// Check that we're on different lines
			assertTrue( "Justification incorrect with BlockProgression: T to B, Direction: L to R",
						yPos[0] != yPos[1] && yPos[1] != yPos[2] );
			// Justification is correct
			assertTrue( "Justification incorrect with BlockProgression: T to B, Direction: L to R",
						xPos[0] == xPos[1] && xPos[1] == xPos[2] );
   		}

   		// Test BlockProgression.RL + Direction.RTL
   		public function rtlJustification():void
   		{
			// Force the intended text positioning
   			SelManager.textFlow.blockProgression = BlockProgression.RL;
   			SelManager.textFlow.direction = Direction.RTL;

		 	// Create new paragraphs to with severe justification differences
		 	SelManager.insertText("M");
		 	SelManager.insertText("MMMMMM");
		 	SelManager.insertText("MMMMMMMMMMMM");
		 	SelManager.selectRange(1,1);
		 	SelManager.splitParagraph();
		 	SelManager.selectRange(8,8);
		 	SelManager.splitParagraph();

			var xPos:Array = new Array();
			var yPos:Array = new Array();

			for ( var l:int = 0; l < TestFrame.textFlow.flowComposer.numLines; l++ )
			{
				var testLine:TextLine = SelManager.textFlow.flowComposer.getLineAt(l).getTextLine();

				xPos.push(testLine.getBounds( TestFrame.container as DisplayObject ).x);
				yPos.push(testLine.getBounds( TestFrame.container as DisplayObject ).y);
			}

			// Check that we're on different lines
			assertTrue( "Justification incorrect with BlockProgression: R to L, Direction: R to L",
						xPos[0] != xPos[1] && xPos[1] != xPos[2] );
			// Justification is correct
			assertTrue( "Justification incorrect with BlockProgression: R to L, Direction: R to L",
						yPos[0] > yPos[1] && yPos[1] > yPos[2] );
   		}

   		// Test BlockProgression.TB + Direction.RTL
  		public function arabicJustification():void
   		{
			// Force the intended text positioning
   			SelManager.textFlow.blockProgression = BlockProgression.TB;
   			SelManager.textFlow.direction = Direction.RTL;

		 	// Create new paragraphs to with severe justification differences
		 	SelManager.insertText("M");
		 	SelManager.insertText("MMMMMM");
		 	SelManager.insertText("MMMMMMMMMMMM");
		 	SelManager.selectRange(1,1);
		 	SelManager.splitParagraph();
		 	SelManager.selectRange(8,8);
		 	SelManager.splitParagraph();

			var xPos:Array = new Array();
			var yPos:Array = new Array();

			for ( var l:int = 0; l < TestFrame.textFlow.flowComposer.numLines; l++ )
			{
				var testLine:TextLine = SelManager.textFlow.flowComposer.getLineAt(l).getTextLine();

				xPos.push(testLine.getBounds( TestFrame.container as DisplayObject ).x);
				yPos.push(testLine.getBounds( TestFrame.container as DisplayObject ).y);
			}

			// Check that we're on different lines
			assertTrue( "Justification incorrect with BlockProgression: T to B & Direction: R to L",
						yPos[0] != yPos[1] && yPos[1] != yPos[2] );
			// Justification is correct
			assertTrue( "Justification incorrect with BlockProgression: T to B & Direction: R to L",
						xPos[0] > xPos[1] && xPos[1] > xPos[2] );
   		}

   		// Make sure the right to left fonts are displayed right to left
   		public function arabicDirection():void
   		{
			for ( var l:int = 0; l < TestFrame.textFlow.flowComposer.numLines; l++ )
			{
				var testLine:TextLine = SelManager.textFlow.flowComposer.getLineAt(l).getTextLine();

				for ( var i:int = 1; i < testLine.atomCount; i++)
				{
					assertTrue( "Display direction incorrect on right to left fonts",
								testLine.getAtomBounds(i).x > testLine.getAtomBounds(i-1).x );

					assertTrue( "Display direction incorrect on right to left fonts",
								testLine.getAtomBounds(i).y == testLine.getAtomBounds(i-1).y );
				}
			}
   		}
	}
}
