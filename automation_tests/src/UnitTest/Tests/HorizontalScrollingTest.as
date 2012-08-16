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
	import UnitTest.Fixtures.FileRepository;
	import UnitTest.Fixtures.TestConfig;

	import flash.events.KeyboardEvent;
	import flash.ui.KeyLocation;

	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.container.ContainerController;



	public class HorizontalScrollingTest extends VellumTestCase
	{
		// List of available keyboard gestures
		// Note that on Mac: CTRL == COMMAND
		//              and: ALT == OPTION
		// These are directly mapped in flash player
		private static const CTRL_BACKSPACE:int   = 100;
   		private static const CTRL_DELETE:int      = 101;
   		private static const OPT_BACKSPACE:int    = 102;
   		private static const OPT_DELETE:int       = 103;
   		private static const CTRL_LEFT:int        = 104;
   		private static const CTRL_RIGHT:int       = 105;
   		private static const CTRL_UP:int          = 106;
   		private static const CTRL_DOWN:int        = 107;
   		private static const OPT_LEFT:int         = 108;
   		private static const OPT_RIGHT:int        = 109;
   		private static const OPT_UP:int           = 110;
   		private static const OPT_DOWN:int         = 111;
   		private static const SHIFT_CTRL_LEFT:int  = 112;
   		private static const SHIFT_CTRL_RIGHT:int = 113;
   		private static const SHIFT_CTRL_UP:int    = 114;
   		private static const SHIFT_CTRL_DOWN:int  = 115;
   		private static const SHIFT_OPT_LEFT:int   = 116;
   		private static const SHIFT_OPT_RIGHT:int  = 117;
   		private static const SHIFT_OPT_UP:int     = 118;
   		private static const SHIFT_OPT_DOWN:int   = 119;
   		private static const HOME:int             = 120;
   		private static const END:int              = 121;
   		private static const SHIFT_HOME:int       = 122;
   		private static const SHIFT_END:int        = 123;
   		private static const CTRL_HOME:int        = 124;
   		private static const CTRL_END:int         = 125;
   		private static const SHIFT_CTRL_HOME:int  = 126;
   		private static const SHIFT_CTRL_END:int   = 127;
   		private static const PG_UP:int            = 128;
   		private static const PG_DOWN:int          = 129;
   		private static const SHIFT_PG_UP:int      = 130;
   		private static const SHIFT_PG_DOWN:int    = 131;
   		private static const UP:int          	  = 132;
   		private static const DOWN:int     	      = 133;
   		private static const LEFT:int     		  = 134;
   		private static const RIGHT:int    		  = 135;

   		private static const SHIFT_RIGHT:int	  = 136;
   		private static const SHIFT_LEFT:int    	  = 137;

		public function HorizontalScrollingTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "UI";
			metaData.productSubArea = "Scrolling";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
			FileRepository.readFile(testConfig.baseURL,"../../test/testFiles/markup/tlf/HORLTRHARD.xml");
			FileRepository.readFile(testConfig.baseURL,"../../test/testFiles/markup/tlf/VORLTRHARD.xml");
			FileRepository.readFile(testConfig.baseURL,"../../test/testFiles/markup/tlf/HORRTLHARD.xml");
			FileRepository.readFile(testConfig.baseURL,"../../test/testFiles/markup/tlf/VORRTLHARD.xml");
 			var testCaseClass:Class = HorizontalScrollingTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

   		public override function setUp():void
   		{
			// Booga - Need to load up the test file here.

			super.setUp();
   		}

   		public override function tearDown():void
   		{
   			// Restore default configurations
   			super.tearDown();
   		}


   		// Send a keyboard gesture using values listed above
   		// Code folding extremely recommended here
   		private function sendKeyboardGesture( type:int ): void
   		{
   			var charCode:int;
   			var keyCode:int;
   			var ctrlDown:Boolean = false;
   			var shiftDown:Boolean = false;
   			var altDown:Boolean = false;

   			var leftCode:int = 37;
   			var rightCode:int = 39;
   			var upCode:int = 38;
   			var downCode:int = 40;

   			// Arrow keys behave differently on Right to Left Blockprogression
   			// For the sake of test simplicity, I am translating the directions here
   			if( SelManager.textFlow.computedFormat.blockProgression == BlockProgression.RL )
   			{
   				leftCode = 38;
   				rightCode = 40;
   				upCode = 39;
   				downCode = 37;
   			}
   			switch( type )
   			{
   				case CTRL_BACKSPACE:
   					charCode = 8;
   					keyCode  = 8;
   					ctrlDown = true;
   					break;
   				case CTRL_DELETE:
   					charCode = 127;
   					keyCode  = 46;
   					ctrlDown = true;
   					break;
   				case OPT_BACKSPACE:
   					charCode = 8;
   					keyCode  = 8;
   					altDown = true;
   					break;
   				case OPT_DELETE:
   					charCode = 127;
   					keyCode  = 46;
   					altDown = true;
   					break;
   				case CTRL_LEFT:
   					charCode = 0;
   					keyCode  = leftCode;
   					ctrlDown = true;
   					break;
   				case CTRL_RIGHT:
   					charCode = 0;
   					keyCode  = rightCode;
   					ctrlDown = true;
   					break;
   				case CTRL_UP:
   					charCode = 0;
   					keyCode  = upCode;
   					ctrlDown = true;
   					break;
   				case CTRL_DOWN:
   					charCode = 0;
   					keyCode  = downCode;
   					ctrlDown = true;
   					break;
   				case OPT_LEFT:
   					charCode = 0;
   					keyCode  = leftCode;
   					altDown = true;
   					break;
   				case OPT_RIGHT:
   					charCode = 0;
   					keyCode  = rightCode;
   					altDown = true;
   					break;
   				case OPT_UP:
   					charCode = 0;
   					keyCode  = upCode;
   					altDown = true;
   					break;
   				case OPT_DOWN:
   					charCode = 0;
   					keyCode  = downCode;
   					altDown = true;
   					break;
   				case SHIFT_LEFT:
   					charCode = 0;
   					keyCode  = leftCode;
   					ctrlDown = false;
   					shiftDown = true;
   					break;
   				case SHIFT_RIGHT:
   					charCode = 0;
   					keyCode  = rightCode;
   					ctrlDown = false;
   					shiftDown = true;
   					break;
   				case SHIFT_CTRL_LEFT:
   					charCode = 0;
   					keyCode  = leftCode;
   					ctrlDown = true;
   					shiftDown = true;
   					break;
   				case SHIFT_CTRL_RIGHT:
   					charCode = 0;
   					keyCode  = rightCode;
   					ctrlDown = true;
   					shiftDown = true;
   					break;
   				case SHIFT_CTRL_UP:
   					charCode = 0;
   					keyCode  = upCode;
   					ctrlDown = true;
   					shiftDown = true;
   					break;
   				case SHIFT_CTRL_DOWN:
   					charCode = 0;
   					keyCode  = downCode;
   					ctrlDown = true;
   					shiftDown = true;
   					break;
   				case SHIFT_OPT_LEFT:
   					charCode = 0;
   					keyCode  = leftCode;
   					ctrlDown = true;
   					shiftDown = true;
   					break;
   				case SHIFT_OPT_RIGHT:
   					charCode = 0;
   					keyCode  = rightCode;
   					ctrlDown = true;
   					shiftDown = true;
   					break;
   				case SHIFT_OPT_UP:
   					charCode = 0;
   					keyCode  = upCode;
   					ctrlDown = true;
   					shiftDown = true;
   					break;
   				case SHIFT_OPT_DOWN:
   					charCode = 0;
   					keyCode  = downCode;
   					altDown = true;
   					shiftDown = true;
   					break;
   				case HOME:
   					charCode = 0;
   					keyCode  = 36;
   					break;
   				case END:
   					charCode = 0;
   					keyCode  = 35;
   					break;
   				case SHIFT_HOME:
   					charCode = 0;
   					keyCode  = 36;
   					shiftDown = true;
   					break;
   				case SHIFT_END:
   					charCode = 0;
   					keyCode  = 35;
   					shiftDown = true;
   					break;
   				case CTRL_HOME:
   					charCode = 0;
   					keyCode  = 36;
   					ctrlDown = true;
   					break;
   				case CTRL_END:
   					charCode = 0;
   					keyCode  = 35;
   					ctrlDown = true;
   					break;
   				case SHIFT_CTRL_HOME:
   					charCode = 0;
   					keyCode  = 36;
   					shiftDown = true;
   					ctrlDown = true;
   					break;
   				case SHIFT_CTRL_END:
   					charCode = 0;
   					keyCode  = 35;
   					shiftDown = true;
   					ctrlDown = true;
   					break;
   				case PG_UP:
   					charCode = 0;
   					keyCode  = 33;
   					break;
   				case PG_DOWN:
   					charCode = 0;
   					keyCode  = 34;
   					break;
   				case SHIFT_PG_UP:
   					charCode = 0;
   					keyCode  = 33;
   					shiftDown = true;
   					break;
   				case SHIFT_PG_DOWN:
   					charCode = 0;
   					keyCode  = 34;
   					shiftDown = true;
   					break;
   				case UP:
   					charCode = 0;
   					keyCode  = upCode;
   					break;
   				case DOWN:
   					charCode = 0;
   					keyCode  = downCode;
   					break;
   				case LEFT:
   					charCode = 0;
   					keyCode  = leftCode;
   					break;
   				case RIGHT:
   					charCode = 0;
   					keyCode  = rightCode;
   					break;
   				default:
   					return;
   			}

   			var kEvent:KeyboardEvent = new KeyboardEvent( KeyboardEvent.KEY_DOWN,
				true, false, charCode, keyCode, KeyLocation.STANDARD, ctrlDown, altDown, shiftDown);
			TestFrame.container["dispatchEvent"](kEvent);
   		}

		public function endKeyScrollingTest(scrollPos:Number):void
		{
			// Success or failure will be determined by the bitmap snapshot.
			// Move the cursor to the beginning of the first line.
			SelManager.selectRange(0,0);
			// Hit the End key to scroll to the end of the first line.
			sendKeyboardGesture( END );
			var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
		//	trace("endKeyScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
		//	trace("endKeyScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
			if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				assertTrue( "endKeyScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
			}
			else
			{
				assertTrue( "endKeyScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
			}

		}

		public function homeKeyScrollingTest(scrollPos:Number):void
		{
   			// Success or failure will be determined by the bitmap snapshot.
			// Move the cursor to the beginning of the first line.
			SelManager.selectRange(0,0);
			// Hit the End key to scroll to the end of the first line.
			sendKeyboardGesture( END );
			// Hit the Home key to scroll to the end of the first line.
			sendKeyboardGesture( HOME );
			var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
		//	trace("homeKeyScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
		//	trace("homeKeyScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
			if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				assertTrue( "homeKeyScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
			}
			else
			{
				assertTrue( "homeKeyScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
			}
		}

		public function cursorRightScrollingTest(scrollPos:Number):void
		{
   			// Success or failure will be determined by the bitmap snapshot.
			// Move the cursor to the beginning of the first line.
			SelManager.selectRange(0,0);
			// Hit the End key to scroll to the end of the first line.
			sendKeyboardGesture( END );
			// Hit the Home key to scroll to the end of the first line.
			sendKeyboardGesture( HOME );
			// Move the cursor over to the right.
			for (var i:Number = 0; i < 37; i++)
			{
				sendKeyboardGesture( RIGHT );
			}
			var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
		//	trace("cursorRightScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
		//	trace("cursorRightScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
			if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				assertTrue( "cursorRightScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
			}
			else
			{
				assertTrue( "cursorRightScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
			}
		}

		public function cursorLeftScrollingTest(scrollPos:Number):void
		{
   			// Success or failure will be determined by the bitmap snapshot.
			// Move the cursor to the beginning of the first line.
			SelManager.selectRange(0,0);
			// Hit the End key to scroll to the end of the first line.
			sendKeyboardGesture( END );
			// Move the cursor over to the right.
			for (var i:Number = 0; i < 41; i++)
			{
				sendKeyboardGesture( LEFT );
			}
			var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
		//	trace("cursorLeftScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
		//	trace("cursorLeftScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
			if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				assertTrue( "cursorLeftScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
			}
			else
			{
				assertTrue( "cursorLeftScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
			}
		}

		public function dragRightScrollingTest(scrollPos:Number):void
		{
   			// Success or failure will be determined by the bitmap snapshot.
			// Move the cursor to the beginning of the first line.
			SelManager.selectRange(0,0);
			// Hit the End key to scroll to the end of the first line.
			sendKeyboardGesture( END );
			// Hit the Home key to scroll to the end of the first line.
			sendKeyboardGesture( HOME );
			// Move the cursor to the selection that will cause a drag.
			// Move the cursor over to the right.
			for (var i:Number = 0; i < 36; i++)
			{
				sendKeyboardGesture( RIGHT );
			}
			sendKeyboardGesture( SHIFT_RIGHT );
			var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
		//	trace("dragRightScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
		//	trace("dragRightScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
			if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				assertTrue( "dragRightScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
			}
			else
			{
				assertTrue( "dragRightScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
			}
		}

		public function dragLeftScrollingTest(scrollPos:Number):void
		{
   			// Success or failure will be determined by the bitmap snapshot.
			// Move the cursor to the beginning of the first line.
			SelManager.selectRange(0,0);
			// Hit the End key to scroll to the end of the first line.
			sendKeyboardGesture( END );
			// Move the cursor to the selection that will cause a drag.
			// Move the cursor over to the right.
			for (var i:Number = 0; i < 40; i++)
			{
				sendKeyboardGesture( LEFT );
			}
			sendKeyboardGesture( SHIFT_LEFT );
			var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
		//	trace("dragLeftScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
		//	trace("dragLeftScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
			if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				assertTrue( "dragLeftScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
			}
			else
			{
				assertTrue( "dragLeftScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
			}
		}

		public function characterEntryEndOfFirstLineScrollingTest(scrollPos:Number):void
		{
   			// Success or failure will be determined by the bitmap snapshot.
			// Move the cursor to the beginning of the first line.
			SelManager.selectRange(0,0);
			// Hit the End key to scroll to the end of the first line.
			sendKeyboardGesture( END );
			// Type in ABC and confirm that it scrolls.
			SelManager.insertText(" ABC");
			var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
		//	trace("characterEntryEndOfFirstLineScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
		//	trace("characterEntryEndOfFirstLineScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
			if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				assertTrue( "characterEntryEndOfFirstLineScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
			}
			else
			{
				assertTrue( "characterEntryEndOfFirstLineScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
			}
		}

		public function characterEntryEndOfLastLineScrollingTest(scrollPos:Number):void
		{
   			// Success or failure will be determined by the bitmap snapshot.
			// Move the cursor to the beginning of the first line.
			SelManager.selectRange(0,0);
			// Hit the CTRL+End key to scroll to the end of the last line.
			sendKeyboardGesture( CTRL_END );
			// Type in ABC and confirm that it scrolls.
			SelManager.insertText(" ABC");
			var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
		//	trace("characterEntryEndOfLastLineScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
		//	trace("characterEntryEndOfLastLineScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
			if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				assertTrue( "characterEntryEndOfLastLineScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
			}
			else
			{
				assertTrue( "characterEntryEndOfLastLineScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
			}
		}

		public function spaceEntryEndOfFirstLineScrollingTest(scrollPos:Number):void
		{
   			// Success or failure will be determined by the bitmap snapshot.
			// Move the cursor to the beginning of the first line.
			SelManager.selectRange(0,0);
			// Hit the End key to scroll to the end of the first line.
			sendKeyboardGesture( END );
			// Type in ABC and confirm that it scrolls.
			SelManager.insertText("    ");
			var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
		//	trace("spaceEntryEndOfFirstLineScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
		//	trace("spaceEntryEndOfFirstLineScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
			if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				assertTrue( "spaceEntryEndOfFirstLineScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
			}
			else
			{
				assertTrue( "spaceEntryEndOfFirstLineScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
			}
		}

		public function spaceEntryEndOfLastLineScrollingTest(scrollPos:Number):void
		{
   			// Success or failure will be determined by the bitmap snapshot.
			// Move the cursor to the beginning of the first line.
			SelManager.selectRange(0,0);
			// Hit the CTRL+End key to scroll to the end of the last line.
			sendKeyboardGesture( CTRL_END );
			// Type in ABC and confirm that it scrolls.
			SelManager.insertText("    ");
			var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
		//	trace("spaceEntryEndOfLastLineScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
		//	trace("spaceEntryEndOfLastLineScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
			if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				assertTrue( "spaceEntryEndOfLastLineScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
			}
			else
			{
				assertTrue( "spaceEntryEndOfLastLineScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
			}
		}

		public function backspaceScrollingTest(scrollPos:Number):void
		{
   			// Success or failure will be determined by the bitmap snapshot.
			// Move the cursor to the beginning of the first line.
			SelManager.selectRange(0,0);
			// Hit the End key to scroll to the end of the first line.
			sendKeyboardGesture( END );
			// Move the cursor to the selection that will cause a drag.
			// Move the cursor over to the right.
			for (var i:Number = 0; i < 40; i++)
			{
				sendKeyboardGesture( LEFT );
			}
			for(i = 0; i < 3; i++)
			{
				SelManager.deletePreviousCharacter();
			}
			var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
		//	trace("backspaceScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
		//	trace("backspaceScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
			if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				assertTrue( "backspaceScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
			}
			else
			{
				assertTrue( "backspaceScrollingTest Test Failed.",(scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
			}
		}

		// Horizontal Orientation Left To Right Direction Scrolling Tests.

		public function HOLTR_endKeyScrollingTest():void
		{
			endKeyScrollingTest(19977);
		}

		public function HOLTR_homeKeyScrollingTest():void
		{
			homeKeyScrollingTest(19);
		}

		public function HOLTR_cursorRightScrollingTest():void
		{
			cursorRightScrollingTest(29);
		}

		public function HOLTR_cursorLeftScrollingTest():void
		{
			cursorLeftScrollingTest(19960);
		}

		public function HOLTR_dragRightScrollingTest():void
		{
			dragRightScrollingTest(29);
		}

		public function HOLTR_dragLeftScrollingTest():void
		{
			dragLeftScrollingTest(19960);
		}

		public function HOLTR_characterEntryEndOfFirstLineScrollingTest():void
		{
			characterEntryEndOfFirstLineScrollingTest(19977)
		}

		public function HOLTR_characterEntryEndOfLastLineScrollingTest():void
		{
			characterEntryEndOfLastLineScrollingTest(25178);
		}

		public function HOLTR_spaceEntryEndOfFirstLineScrollingTest():void
		{
			spaceEntryEndOfFirstLineScrollingTest(19977);
		}

		public function HOLTR_spaceEntryEndOfLastLineScrollingTest():void
		{
			spaceEntryEndOfLastLineScrollingTest(25178);
		}

		public function HOLTR_backspaceScrollingTest():void
		{
			backspaceScrollingTest(19936);
		}

		// Vertical Orientation Left To Right Direction Scrolling Tests.

		public function VOLTR_endKeyScrollingTest():void
		{
			endKeyScrollingTest(20326);
		}

		public function VOLTR_homeKeyScrollingTest():void
		{
			homeKeyScrollingTest(19);
		}

		public function VOLTR_cursorRightScrollingTest():void
		{
			cursorRightScrollingTest(378);
		}

		public function VOLTR_cursorLeftScrollingTest():void
		{
			cursorLeftScrollingTest(19960);
		}

		public function VOLTR_dragRightScrollingTest():void
		{
			dragRightScrollingTest(378);
		}

		public function VOLTR_dragLeftScrollingTest():void
		{
			dragLeftScrollingTest(19960);
		}

		public function VOLTR_characterEntryEndOfFirstLineScrollingTest():void
		{
			characterEntryEndOfFirstLineScrollingTest(20326)
		}

		public function VOLTR_characterEntryEndOfLastLineScrollingTest():void
		{
			characterEntryEndOfLastLineScrollingTest(25527);
		}

		public function VOLTR_spaceEntryEndOfFirstLineScrollingTest():void
		{
			spaceEntryEndOfFirstLineScrollingTest(20326);
		}

		public function VOLTR_spaceEntryEndOfLastLineScrollingTest():void
		{
			spaceEntryEndOfLastLineScrollingTest(25527);
		}

		public function VOLTR_backspaceScrollingTest():void
		{
			backspaceScrollingTest(19936);
		}


		// Horizontal Orientation Left To Right Direction Scrolling Tests.

		public function HORTL_endKeyScrollingTest():void
		{
			endKeyScrollingTest(19977);
		}

		public function HORTL_homeKeyScrollingTest():void
		{
			homeKeyScrollingTest(19);
		}

		public function HORTL_cursorRightScrollingTest():void
		{
			cursorRightScrollingTest(29);
		}

		public function HORTL_cursorLeftScrollingTest():void
		{
			cursorLeftScrollingTest(19960);
		}

		public function HORTL_dragRightScrollingTest():void
		{
			dragRightScrollingTest(29);
		}

		public function HORTL_dragLeftScrollingTest():void
		{
			dragLeftScrollingTest(19960);
		}

		public function HORTL_characterEntryEndOfFirstLineScrollingTest():void
		{
			characterEntryEndOfFirstLineScrollingTest(19977)
		}

		public function HORTL_characterEntryEndOfLastLineScrollingTest():void
		{
			characterEntryEndOfLastLineScrollingTest(25178);
		}

		public function HORTL_spaceEntryEndOfFirstLineScrollingTest():void
		{
			spaceEntryEndOfFirstLineScrollingTest(19977);
		}

		public function HORTL_spaceEntryEndOfLastLineScrollingTest():void
		{
			spaceEntryEndOfLastLineScrollingTest(25178);
		}

		public function HORTL_backspaceScrollingTest():void
		{
			backspaceScrollingTest(19936);
		}

		// Vertical Orientation Left To Right Direction Scrolling Tests.

		public function VORTL_endKeyScrollingTest():void
		{
			endKeyScrollingTest(20326);
		}

		public function VORTL_homeKeyScrollingTest():void
		{
			homeKeyScrollingTest(19);
		}

		public function VORTL_cursorRightScrollingTest():void
		{
			cursorRightScrollingTest(378);
		}

		public function VORTL_cursorLeftScrollingTest():void
		{
			cursorLeftScrollingTest(19960);
		}

		public function VORTL_dragRightScrollingTest():void
		{
			dragRightScrollingTest(378);
		}

		public function VORTL_dragLeftScrollingTest():void
		{
			dragLeftScrollingTest(19960);
		}

		public function VORTL_characterEntryEndOfFirstLineScrollingTest():void
		{
			characterEntryEndOfFirstLineScrollingTest(20326)
		}

		public function VORTL_characterEntryEndOfLastLineScrollingTest():void
		{
			characterEntryEndOfLastLineScrollingTest(25527);
		}

		public function VORTL_spaceEntryEndOfFirstLineScrollingTest():void
		{
			spaceEntryEndOfFirstLineScrollingTest(20326);
		}

		public function VORTL_spaceEntryEndOfLastLineScrollingTest():void
		{
			spaceEntryEndOfLastLineScrollingTest(25527);
		}

		public function VORTL_backspaceScrollingTest():void
		{
			backspaceScrollingTest(19936);
		}


	}
}
