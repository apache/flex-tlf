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

	import flash.events.*;

	import flashx.textLayout.*;
	import flashx.textLayout.edit.*;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;

	import mx.utils.LoaderUtil;

 	public class TextFlowEditTest extends VellumTestCase
	{
		public function TextFlowEditTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super(methodName, testID, testConfig);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Editing";
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			ts.addTestDescriptor (new TestDescriptor (TextFlowEditTest, "simulateClipboardTest", testConfig ) ); //HBS
			ts.addTestDescriptor (new TestDescriptor (TextFlowEditTest, "addChildTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (TextFlowEditTest, "removeChildTest", testConfig ) );
   		}

  		// Returns the string from begIdx through and including endIdx
   		private function getText( begIdx:int, endIdx:int ): String
   		{
   			var outString:String = "";

   			for ( var x:int = begIdx; x < endIdx; x++ )
   			{
   				outString += SelManager.textFlow.getCharAtPosition(x);
   			}

   			return outString;
   		}

  		// Tests FlowGroupElement's addChild and addChildAt on TextFlow
  		public function addChildTest():void
  		{
  			var origLength:int = SelManager.textFlow.textLength;
  			var firstPara:FlowElement = SelManager.textFlow.getChildAt(0).deepCopy();

  			// Test addChild
  			SelManager.textFlow.removeChildAt(0);
  			var flowLength:int = SelManager.textFlow.textLength;
  			var tempPara:FlowElement = SelManager.textFlow.getChildAt(0).deepCopy();
  			SelManager.textFlow.addChild(tempPara);
  			flowLength *= 2;
  			assertTrue( "addChild failed on textFlow",
  						flowLength == SelManager.textFlow.textLength );

			// Try to add an already added element this should simply replace it
 			SelManager.textFlow.addChild(tempPara);
  			assertTrue( "readdChild failed on textFlow",
  						flowLength == SelManager.textFlow.textLength && tempPara.parent == SelManager.textFlow && tempPara == SelManager.textFlow.getChildAt(SelManager.textFlow.numChildren-1));

			// Test addChildAt
  			SelManager.textFlow.addChildAt(1,firstPara);
  			SelManager.textFlow.removeChildAt(2);
  			assertTrue( "addChildAt failed on textFlow",
  						origLength == SelManager.textFlow.textLength );
  			assertTrue ( "addChildAt failed to place child at correct position",
  						 getText(0,7) == "The man" );
  		}

  		// Tests FlowGroupElement's removeChild and removeChildAt on TextFlow
  		public function removeChildTest():void
  		{
  			SelManager.textFlow.removeChildAt(0);
  			assertTrue( "Removing first child paragraph failed",
  						SelManager.textFlow.getChildAt(1) == null );

  			SelManager.selectRange(25,25);
  			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 20, 20 );

  			var paraElem:FlowGroupElement = SelManager.textFlow.getChildAt(0) as ParagraphElement;
  			var imgElem:FlowElement = paraElem.getChildAt(paraElem.findChildIndexAtPosition(25));
  			assertTrue("Expected InlineImageElement not found", imgElem is InlineGraphicElement );
  			paraElem.removeChild(imgElem);

  			assertTrue("FlowGroupElement method removeChild failed to remove InlineGraphic",
  						!(paraElem.getChildAt(
							paraElem.findChildIndexAtPosition(25))
								is InlineGraphicElement) )

  			// Try to remove an element that isn't here
  			var gotError:Boolean = false;
  			try
  			{
  				SelManager.textFlow.removeChild(imgElem);
  			}
  			catch ( e:ArgumentError )
  			{
  				gotError = true;
  			}

  			assertTrue( "Removing invalid child element failed to throw error",
  						gotError );
  		}

		/**
		 * Selects the characters between the 10th and 50th characters and does a cut.  It then
		 * does an undo, redo, and another undo of the cut operation.
		 * Verifies that there is the correct amount of characters on the clipboard after the cut operation.
		 * Verifies that the correct amount of characters are left in the document after the cut operation.
		 * Verifies that the correct amount of characters are left in the doucment after undoing the cut operation.
		 * Verifies that the correct amount of characters are left in the document after redoing the cut operation.
		 * Verifies that the correct amount of characters are left in the document after re-undoing the cut operation.
		 */
		public function simulateClipboardTest():void  //HBS
		{
			var startIndx:int = 10;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx,endIndx);
			var initLength:uint = SelManager.textFlow.textLength;
			var peudoClipboard:TextScrap = SelManager.cutTextScrap();
			var endLength:uint = SelManager.textFlow.textLength;
			assertTrue("Text length is incorrect after a cut operation", endLength == initLength - (endIndx - startIndx) );

			SelManager.undo();
			var afterUndoLength:uint = SelManager.textFlow.textLength;
			assertTrue("Text length is incorrect after undoing a cut operation", afterUndoLength == initLength);

			//everything is ok so far if we get down here.  Now, redo the undo operation and
			//make suer the flow goes back to the endLength

			SelManager.redo();
			var afterRedoLength:uint = SelManager.textFlow.textLength;
			assertTrue("Text length is incorrect after redoing a cut operation", afterRedoLength == endLength);

			//everything is ok so far if we get down here.  Now, do an undo again to get
			//the doc back to it's original state so that we can go on with tests.

			SelManager.undo();
			afterUndoLength = SelManager.textFlow.textLength;
			assertTrue("Text length is incorrect after undoing a cut operation", afterUndoLength == initLength);
		}
	}
}
