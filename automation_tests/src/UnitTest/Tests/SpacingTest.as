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

	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

	public class SpacingTest extends VellumTestCase
	{
		private var firstLine:TextFlowLine;
		private var secondLine:TextFlowLine;

		public function SpacingTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Composition";
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			ts.addTestDescriptor(new TestDescriptor(SpacingTest, "spaceLeadingMarginTest", testConfig));
		}

		public override function setUp():void
		{
			super.setUp();

			var ca:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
			ca.columnCount = 1;
			TestFrame.format = ca;

			TestFrame.textFlow.flowComposer.updateAllControllers();
		}

		//Paragraph.
		public function spaceLeadingMarginTest():void
		{
			var lines:Array = StandardFlowComposer(SelManager.textFlow.flowComposer).lines;
			firstLine = lines[0] as TextFlowLine;

			for each (var sl:TextFlowLine in lines){
				if(sl.paragraph != firstLine.paragraph &&
						sl.location == firstLine.location
				){
					secondLine = sl;
					break;
				}
			}

			SelManager.selectRange(firstLine.absoluteStart,firstLine.textLength - 2);
			var pa:TextLayoutFormat = new TextLayoutFormat();

			if (this.writingDirection[0] == BlockProgression.TB)
			{
				if (this.writingDirection[1] == Direction.LTR)
				{
					assertTrue(firstLine.x == secondLine.x);
					pa.paragraphStartIndent = 100;
				}
				else if (this.writingDirection[1] == Direction.RTL)
				{
					// these should be close
					var l1End:Number = firstLine.x+firstLine.getTextLine().width;
					var l2End:Number = secondLine.x+secondLine.getTextLine().width;
					var isNearlyEqual:Boolean = Math.abs(l1End-l2End)< 0.1;
					assertTrue(isNearlyEqual);
					pa.paragraphEndIndent = 100;
				}
				else
					fail("Unknown direction " + this.writingDirection[1]);
			}
			else if (this.writingDirection[0] == BlockProgression.RL)
			{
				assertTrue(firstLine.y == secondLine.y);
				pa.paragraphStartIndent = 100;
			}
			else
				fail("Unknown blockProgression " + this.writingDirection[0]);

			SelManager.applyParagraphFormat(pa);
			SelManager.flushPendingOperations();

			firstLine = lines[0];
			testLines();
		}

		private function testLines():void
		{
			if (this.writingDirection[0] == BlockProgression.TB)
			{
				if (this.writingDirection[1] == Direction.LTR)
				{
					assertTrue("First = " + firstLine.x + ", Second = " + secondLine.x,
						firstLine.x == secondLine.x + 100
					);
				}
				else if (this.writingDirection[1] == Direction.RTL)
				{
					assertTrue("First = " + firstLine.targetWidth +
							", Second = " + secondLine.targetWidth,
						firstLine.targetWidth == secondLine.targetWidth - 100
					);
				}
				else
					fail("Unknown direction " + this.writingDirection[1]);
			}
			else if (this.writingDirection[0] == BlockProgression.RL)
			{
				assertTrue("First = " + firstLine.y + ", Second = " + secondLine.y,
					firstLine.y == secondLine.y + 100
				);
			}
			else
				fail("Unknown blockProgression " + this.writingDirection[0]);
		}
	}
}
