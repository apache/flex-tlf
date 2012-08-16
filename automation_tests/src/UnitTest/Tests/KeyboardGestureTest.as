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
	import UnitTest.Fixtures.FileRepository;
	import UnitTest.Fixtures.TestConfig;
	
	import flash.events.KeyboardEvent;
	import flash.ui.KeyLocation;
	
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.*;
	import flashx.textLayout.edit.TextScrap;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.elements.ListElement;
	import flashx.textLayout.elements.ListItemElement;

	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	
	import mx.utils.LoaderUtil;

	public class KeyboardGestureTest extends VellumTestCase
	{
		private var version:Number;
		
		public function KeyboardGestureTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Editing";
			metaData.productSubArea = "Keyboard Gestures";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
			FileRepository.readFile(testConfig.baseURL,"../../test/testFiles/markup/tlf/school.xml");
			FileRepository.readFile(testConfig.baseURL,"../../test/testFiles/markup/tlf/tcyTestBase.xml");
 			var testCaseClass:Class = KeyboardGestureTest;
 
			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

   		private const BASIC_TEST:String = "This is a test of the keyboard gesture system.";
   		private const HYPHEN_TEST:String = "This is-a test-of-the keyboard-gesture system.-";

   		public override function setUp():void
   		{
   			super.setUp();

   			SelManager.selectAll();
   			SelManager.deleteNextCharacter();

   			SelManager.insertText(BASIC_TEST);
   			SelManager.flushPendingOperations(); 
   		}

		public override function loadTestFile(fileName:String):void
		{
			super.loadTestFile(fileName);	

			SelManager.textFlow.blockProgression = writingDirection[0];;
			SelManager.textFlow.direction = writingDirection[1];;
			SelManager.flushPendingOperations();
		}

		private function setUpLanguageTest():void
   		{
   			loadTestFile("school.xml");

   			SelManager.selectRange(75,75);
   			SelManager.insertText("abc");
   		}

   		private function setUpTCYTest():void
   		{
   			loadTestFile("tcyTestBase.xml");

			SelManager.textFlow.blockProgression = BlockProgression.RL;
   			SelManager.textFlow.direction = Direction.LTR;
   			SelManager.flushPendingOperations();

			SelManager.selectRange(15,22);
			SelManager.applyTCY(true);
			SelManager.selectRange(62,73);
			SelManager.applyTCY(true);
   		}

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
		private static const TAB:int    		  = 136;
		private static const SHIFT_TAB:int    	  = 137;

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

   			// Gestures are expected to move with visual order for RTL text
   			// Sending the "opposite" direction in order to test for this
   			if( SelManager.textFlow.computedFormat.direction == Direction.RTL )
   			{
   				leftCode = 39;
	   			rightCode = 37;
	   			upCode = 38;
	   			downCode = 40;
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
				case TAB:
					charCode = 9;
					keyCode  = 9;
					break;
				case SHIFT_TAB:
					charCode = 9;
					keyCode  = 9;
					shiftDown = true;
					break;
   				default:
   					return;
   			}

   			var kEvent:KeyboardEvent = new KeyboardEvent( KeyboardEvent.KEY_DOWN,
				true, false, charCode, keyCode, KeyLocation.STANDARD, ctrlDown, altDown, shiftDown);
			TestFrame.container["dispatchEvent"](kEvent);
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

   		// Returns the text contents of the entire textflow
   		private function getAllText(): String
   		{
   			var begIdx:int = SelManager.textFlow.parentRelativeStart;
   			var endIdx:int = SelManager.textFlow.parentRelativeEnd-1;
   			var outString:String = "";

   			for ( var x:int = begIdx; x < endIdx; x++ )
   			{
   				outString += SelManager.textFlow.getCharAtPosition(x);
   			}

   			return outString;
   		}

   		// Returns the presently selected text
   		private function getSelectedText():String
   		{
   			var begIdx:int = SelManager.absoluteStart;
   			var endIdx:int = SelManager.absoluteEnd;
   			var outString:String = "";

   			for ( var x:int = begIdx; x < endIdx; x++ )
   			{
   				outString += SelManager.textFlow.getCharAtPosition(x);
   			}

   			return outString;
   		}

/*********** CTRL-BACKSPACE TESTS **************************************************************/

   		// Test the basic functionality and undo/redo
   		public function CtrlBackspaceGeneralTest():void
   		{
   			BackspaceGeneralTest( CTRL_BACKSPACE );
   		}
   		public function OptBackspaceGeneralTest():void
   		{
   			BackspaceGeneralTest( OPT_BACKSPACE );
   		}
   		public function BackspaceGeneralTest( bsKey:int ):void
		{
			SelManager.selectRange(31,31);

			// Test Generic Functionality

			sendKeyboardGesture( bsKey );

			assertTrue( "Ctrl-Backspace failed to delete previous word",
						 getAllText() == "This is a test of the gesture system." );

			sendKeyboardGesture( bsKey );

			assertTrue( "Ctrl-Backspace failed to delete previous word",
						 getAllText() == "This is a test of gesture system." );

			SelManager.selectAll();
			sendKeyboardGesture( bsKey );

			assertTrue( "Ctrl-Backspace should not remove all text",
						 getAllText() == "This is a test of gesture system." );

			// Undo/Redo it all

			SelManager.undo();
			assertTrue( "Ctrl-Backspace failed to undo",
						 getAllText() == "This is a test of the gesture system." );

			SelManager.undo();
			assertTrue( "Ctrl-Backspace failed to undo",
						 getAllText() == BASIC_TEST );

			SelManager.redo();
			assertTrue( "Ctrl-Backspace failed to redo",
						 getAllText() == "This is a test of the gesture system." );

			SelManager.redo();
			assertTrue( "Ctrl-Backspace failed to redo",
						 getAllText() == "This is a test of gesture system." );
		}

		// Test a bunch of different places in a line that Ctrl-Backspace could be pressed
		public function CtrlBackspaceLocationTest():void
		{
			SelManager.selectRange(0,0);
			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace changed something when exectuted at position 0",
						 getAllText() == BASIC_TEST );

			SelManager.selectRange(46,46);
			sendKeyboardGesture(CTRL_BACKSPACE);

			assertTrue( "Ctrl-Backspace failed on punctutation",
						getAllText() == "This is a test of the keyboard gesture system" );

			SelManager.selectRange(45,45);
			sendKeyboardGesture(CTRL_BACKSPACE);

			assertTrue( "Ctrl-Backspace failed at the end of a line",
						getAllText() == "This is a test of the keyboard gesture " );

			SelManager.selectRange(9,9);
			sendKeyboardGesture(CTRL_BACKSPACE);

			assertTrue( "Ctrl-Backspace failed on a single character word",
						getAllText() == "This is test of the keyboard gesture " );

			SelManager.selectRange(8,8);
			SelManager.insertText("   ");
			SelManager.selectRange(11,11);
			sendKeyboardGesture(CTRL_BACKSPACE);

			assertTrue( "Ctrl-Backspace failed over extra whitespace",
						getAllText() == "This test of the keyboard gesture " );

			SelManager.selectRange(20,20);
			sendKeyboardGesture(CTRL_BACKSPACE);

			assertTrue( "Ctrl-Backspace failed in the middle of a word",
						getAllText() == "This test of the board gesture " );

			SelManager.selectRange(29,29);
			sendKeyboardGesture(CTRL_BACKSPACE);

			assertTrue( "Ctrl-Backspace failed 1 from the end of a word",
						getAllText() == "This test of the board e " );

			SelManager.selectRange(18,18);
			sendKeyboardGesture(CTRL_BACKSPACE);

			assertTrue( "Ctrl-Backspace failed on the first character of a word",
						getAllText() == "This test of the oard e " );

			SelManager.selectRange(10,10);
			sendKeyboardGesture(CTRL_BACKSPACE);

			assertTrue( "Ctrl-Backspace failed after a single whitespace",
						getAllText() == "This of the oard e " );

			SelManager.selectRange(19,19);
			sendKeyboardGesture(CTRL_BACKSPACE);

			assertTrue( "Ctrl-Backspace failed after a training whitespace",
						getAllText() == "This of the oard " );
		}

		public function CtrlBackspaceHyphenTest():void
		{
			SelManager.selectAll();
   			SelManager.deleteNextCharacter();
   			SelManager.flushPendingOperations();
   			SelManager.insertText(HYPHEN_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.insertText(BASIC_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.splitParagraph();

   			SelManager.selectRange(48,48);
   			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed over a paragraph break w/ hypen",
						getAllText() == "This is-a test-of-the keyboard-gesture system.-This is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen punctuation combination",
						getAllText() == "This is-a test-of-the keyboard-gesture system.This is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen punctuation combination",
						getAllText() == "This is-a test-of-the keyboard-gesture This is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen",
						getAllText() == "This is-a test-of-the keyboard-This is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen",
						getAllText() == "This is-a test-of-the keyboardThis is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen",
						getAllText() == "This is-a test-of-the This is a test of the keyboard gesture system." );

			SelManager.selectRange(21,21);

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen",
						getAllText() == "This is-a test-of- This is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen",
						getAllText() == "This is-a test-of This is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen",
						getAllText() == "This is-a test- This is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen",
						getAllText() == "This is-a test This is a test of the keyboard gesture system." );

			SelManager.selectRange(9,9);

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen",
						getAllText() == "This is- test This is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen",
						getAllText() == "This is test This is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_BACKSPACE);
			assertTrue( "Ctrl-Backspace failed with a hyphen",
						getAllText() == "This test This is a test of the keyboard gesture system." );
		}

		public function CtrlBackspaceParagraphTest():void
		{
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);

			SelManager.selectRange(46,46); SelManager.splitParagraph();
			SelManager.selectRange(93,93); SelManager.splitParagraph();
			SelManager.selectRange(140,140); SelManager.splitParagraph();
			SelManager.selectRange(187,187); SelManager.splitParagraph();

			SelManager.selectRange(179,219);
			sendKeyboardGesture(CTRL_BACKSPACE);

			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(179);
  			assertTrue("Ctrl-Backspace failed between paragraphs", elem is SpanElement);

			SelManager.selectRange(171,210);
			SelManager.deleteNextCharacter();

  			SelManager.selectRange(141,141);
  			sendKeyboardGesture(CTRL_BACKSPACE);

  			SelManager.selectRange(0,94); // Should do nothing
  			sendKeyboardGesture(CTRL_BACKSPACE);

  			// This is the correct functionality of Ctrl-Backspace
  			// Bug #1891186 deferred for player fix
  			//SelManager.selectRange(94,186);
  			//assertTrue("Ctrl-Backspace failed across multiple paragraphs",
  			//			getSelectedText() == "This is a test of the keyboard gesture system. This is a test of the keyboard gesture system.");

			SelManager.selectRange(94,186);
  			assertTrue("Ctrl-Backspace behavior across multiple paragraphs changed",
  						getSelectedText() == "This is a test of the keyboard gesture system.This is a test of the keyboard gesture system.");
		}

		public function CtrlBackspaceImageTest():void
		{
			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(26,26);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(32,32);
			SelManager.insertText(" ");
			SelManager.selectRange(33,33);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(37,37);
			sendKeyboardGesture(CTRL_BACKSPACE);
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(34);
  			assertTrue("Ctrl-Backspace removed multiple images in one operation",elem is InlineGraphicElement);

  			sendKeyboardGesture(CTRL_BACKSPACE);
  			elem = SelManager.textFlow.findLeaf(33);
  			assertTrue("Ctrl-Backspace removed multiple images in one operation",elem is InlineGraphicElement);
  			sendKeyboardGesture(CTRL_BACKSPACE);

  			SelManager.selectRange(27,27);
  			sendKeyboardGesture(CTRL_BACKSPACE);
  			elem = SelManager.textFlow.findLeaf(26);
  			assertTrue("Ctrl-Backspace failed to remove image in word",!(elem is InlineGraphicElement));

  			SelManager.selectRange(23,23);
  			sendKeyboardGesture(CTRL_BACKSPACE);
  			sendKeyboardGesture(CTRL_BACKSPACE);
  			elem = SelManager.textFlow.findLeaf(20);
  			assertTrue("Ctrl-Backspace failed to remove image with word",!(elem is InlineGraphicElement));
  			sendKeyboardGesture(CTRL_BACKSPACE);

  			assertTrue("Ctrl-Backspace failed to removed extra text in image test",
  						getAllText() == "This is a test of keyboard gesture system.");
		}

		public function CtrlBackspaceLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( CTRL_BACKSPACE );
			SelManager.selectRange(18,25);
			assertTrue( "Ctrl-Backspace failed in Right to Left Arabic text",
						getSelectedText() == "n رسة i" );

			SelManager.selectRange(76,77);
			SelManager.deleteNextCharacter();

			SelManager.selectRange(82,82);
			sendKeyboardGesture( CTRL_BACKSPACE );
			SelManager.selectRange(66,69);
			assertTrue( "Ctrl-Backspace failed to delete a bidi word",
						getSelectedText() == ", i" );

			SelManager.undo(); SelManager.undo();
			sendKeyboardGesture( CTRL_BACKSPACE );

			SelManager.selectRange(68,78);
			assertTrue( "Ctrl-Backspace changed removal behavior within a bidi word",
						getSelectedText() == "־סֵפֶר in " );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( CTRL_BACKSPACE );

			SelManager.selectRange(257,260);
			assertTrue( "Ctrl-Backspace changed removal behavior within right to left text",
						getSelectedText() == "ل ب" );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( CTRL_BACKSPACE );
			SelManager.selectRange(14,18);
			assertTrue( "Ctrl-Backspace changed removal behavior within TCY text",
						getSelectedText() == "ぜlis" );

			SelManager.selectRange(20,20);
			sendKeyboardGesture( CTRL_BACKSPACE );
			SelManager.selectRange(18,20);
			assertTrue( "Ctrl-Backspace changed removal behavior within TCY text",
						getSelectedText() == "hあ" );
		}

/*********** CTRL-DELETE TESTS **************************************************************/

		// Test the basic functionality and undo/redo
   		public function CtrlDeleteGeneralTest():void
   		{
   			DeleteGeneralTest( CTRL_DELETE );
   		}
   		public function OptDeleteGeneralTest():void
   		{
   			DeleteGeneralTest( OPT_DELETE );
   		}
   		public function DeleteGeneralTest( codeKey:int ):void
		{
			SelManager.selectRange(22,22);

			// Test Generic Functionality

			sendKeyboardGesture( codeKey );

			assertTrue( "Ctrl-Delete failed to delete previous word",
						 getAllText() == "This is a test of the gesture system." );

			sendKeyboardGesture( codeKey );

			assertTrue( "Ctrl-Delete failed to delete previous word",
						 getAllText() == "This is a test of the system." );

			SelManager.selectAll();
			sendKeyboardGesture( codeKey );

			// Undo/Redo it all

			SelManager.undo();

			var endPos:int = SelManager.textFlow.textLength - 1;
			
			assertTrue( "Ctrl-Delete failed to undo and place correct selection",
						 SelManager.activePosition == endPos &&
						 SelManager.anchorPosition == 0 );

			assertTrue( "Ctrl-Delete failed to undo",
						 getAllText() == "This is a test of the system." );

			SelManager.undo();
			assertTrue( "Ctrl-Delete failed to undo",
						 getAllText() == "This is a test of the gesture system." );

			SelManager.undo();
			assertTrue( "Ctrl-Delete failed to undo",
						 getAllText() == BASIC_TEST );

			SelManager.redo();
			assertTrue( "Ctrl-Delete failed to redo",
						 getAllText() == "This is a test of the gesture system." );

			SelManager.redo();
			assertTrue( "Ctrl-Delete failed to redo",
						 getAllText() == "This is a test of the system." );
		}

		// Test a bunch of different places in a line that Ctrl-Delete could be pressed
		public function CtrlDeleteLocationTest():void
		{
			SelManager.selectRange(46,46);
			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete changed something when exectuted at end position",
						 getAllText() == BASIC_TEST );

			SelManager.selectRange(45,45);
			sendKeyboardGesture(CTRL_DELETE);

			assertTrue( "Ctrl-Delete failed on punctutation",
						getAllText() == "This is a test of the keyboard gesture system" );

			SelManager.selectRange(39,39);
			sendKeyboardGesture(CTRL_DELETE);

			assertTrue( "Ctrl-Delete failed at the end of a line",
						getAllText() == "This is a test of the keyboard gesture " );

			SelManager.selectRange(8,8);
			sendKeyboardGesture(CTRL_DELETE);

			assertTrue( "Ctrl-Delete failed on a single character word",
						getAllText() == "This is test of the keyboard gesture " );

			SelManager.selectRange(5,5);
			SelManager.insertText( "   " );
			SelManager.selectRange(4,4);
			sendKeyboardGesture(CTRL_DELETE);

			assertTrue( "Ctrl-Delete failed over extra whitespace",
						getAllText() == "This test of the keyboard gesture " );

			SelManager.selectRange(20,20);
			sendKeyboardGesture(CTRL_DELETE);

			assertTrue( "Ctrl-Delete failed in the middle of a word",
						getAllText() == "This test of the key gesture " );

			SelManager.selectRange(27,27);
			sendKeyboardGesture(CTRL_DELETE);

			assertTrue( "Ctrl-Delete failed 1 from the end of a word",
						getAllText() == "This test of the key gestur " );

			SelManager.selectRange(18,18);
			sendKeyboardGesture(CTRL_DELETE);

			assertTrue( "Ctrl-Delete failed on the first character of a word",
						getAllText() == "This test of the k gestur " );

			SelManager.selectRange(25,25);
			sendKeyboardGesture(CTRL_DELETE);

			assertTrue( "Ctrl-Delete failed after a trailing whitespace",
						getAllText() == "This test of the k gestur" );
		}

		public function CtrlDeleteHyphenTest():void
		{
			SelManager.selectAll();
   			SelManager.deleteNextCharacter();
   			SelManager.flushPendingOperations();
   			SelManager.insertText(HYPHEN_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.insertText(BASIC_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.splitParagraph();

   			SelManager.selectRange(47,47);
   			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed over a paragraph break w/ hypen",
						getAllText() == "This is-a test-of-the keyboard-gesture system.-This is a test of the keyboard gesture system." );

			SelManager.selectRange(46,46);
			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen punctuation combination",
						getAllText() == "This is-a test-of-the keyboard-gesture system.This is a test of the keyboard gesture system." );

			SelManager.selectRange(45,45);
			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen punctuation combination",
						getAllText() == "This is-a test-of-the keyboard-gesture system is a test of the keyboard gesture system." );

			SelManager.selectRange(5,5);
			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen",
						getAllText() == "This -a test-of-the keyboard-gesture system is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen",
						getAllText() == "This a test-of-the keyboard-gesture system is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen",
						getAllText() == "This test-of-the keyboard-gesture system is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen",
						getAllText() == "This -of-the keyboard-gesture system is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen",
						getAllText() == "This of-the keyboard-gesture system is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen",
						getAllText() == "This -the keyboard-gesture system is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen",
						getAllText() == "This the keyboard-gesture system is a test of the keyboard gesture system." );

			SelManager.selectRange(9,9);

			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen",
						getAllText() == "This the -gesture system is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen",
						getAllText() == "This the gesture system is a test of the keyboard gesture system." );

			sendKeyboardGesture(CTRL_DELETE);
			assertTrue( "Ctrl-Delete failed with a hyphen",
						getAllText() == "This the system is a test of the keyboard gesture system." );
		}

		public function CtrlDeleteParagraphTest():void
		{
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);

			SelManager.selectRange(46,46); SelManager.splitParagraph();
			SelManager.selectRange(93,93); SelManager.splitParagraph();
			SelManager.selectRange(140,140); SelManager.splitParagraph();
			SelManager.selectRange(187,187); SelManager.splitParagraph();

			SelManager.selectRange(179,219);
			sendKeyboardGesture(CTRL_DELETE);

			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(180);
  			assertTrue("Ctrl-Delete failed across paragraphs",
  						elem is SpanElement );

  			SelManager.selectRange(140,140);
  			sendKeyboardGesture(CTRL_DELETE);

  			SelManager.selectRange(0,94);
  			SelManager.deleteNextCharacter();

  			SelManager.selectRange(0, 85);
  			assertTrue("Ctrl-Delete failed to remove multiple paragraphs",
  						getSelectedText() == "This is a test of the keyboard gesture system.This is a test of the keyboard gesture.");
		}

		public function CtrlDeleteImageTest():void
		{
			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(26,26);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(32,32);
			SelManager.insertText(" ");
			SelManager.selectRange(33,33);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(32,32);
			sendKeyboardGesture(CTRL_DELETE);
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(32);
  			assertTrue("Ctrl-Delete removed multiple images in one operation",elem is InlineGraphicElement);

  			sendKeyboardGesture(CTRL_DELETE);
  			elem = SelManager.textFlow.findLeaf(32);
  			assertTrue("Ctrl-Delete removed multiple images in one operation",elem is InlineGraphicElement);
  			sendKeyboardGesture(CTRL_DELETE);

  			SelManager.selectRange(20,20);
  			sendKeyboardGesture(CTRL_DELETE);
  			elem = SelManager.textFlow.findLeaf(20);
  			assertTrue("Ctrl-Delete failed to remove image in word",!(elem is InlineGraphicElement));

  			SelManager.selectRange(22,22);
  			sendKeyboardGesture(CTRL_DELETE);
  			sendKeyboardGesture(CTRL_DELETE);
  			elem = SelManager.textFlow.findLeaf(20);
  			assertTrue("Ctrl-Delete failed to remove image with word",!(elem is InlineGraphicElement));
  			sendKeyboardGesture(CTRL_DELETE);

  			assertTrue("Ctrl-Delete failed to removed extra text in image test",
  						getAllText() == "This is a test of the gesture system.");
		}

		public function CtrlDeleteLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( CTRL_DELETE );
			SelManager.selectRange(18,24);
			assertTrue( "Ctrl-Delete failed in Right to Left Arabic text",
						getSelectedText() == "n مد i" );

			SelManager.selectRange(75,76);
			SelManager.deleteNextCharacter();

			SelManager.selectRange(66,66);
			sendKeyboardGesture( CTRL_DELETE );
			SelManager.selectRange(65,68);
			assertTrue( "Ctrl-Delete failed to delete a bidi word",
						getSelectedText() == ", i" );

			SelManager.undo(); SelManager.undo();
			SelManager.selectRange(66,66);
			sendKeyboardGesture( CTRL_DELETE );

			SelManager.selectRange(67,75);
			assertTrue( "Ctrl-Delete changed removal behavior within a bidi word",
						getSelectedText() == "סֵפֶר in" );

			SelManager.selectRange(254,254);
			sendKeyboardGesture( CTRL_DELETE );

			SelManager.selectRange(254,257);
			assertTrue( "Ctrl-Delete changed removal behavior within right to left text",
						getSelectedText() == " بع" );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( CTRL_DELETE );
			SelManager.selectRange(14,18);
			assertTrue( "Ctrl-Delete changed removal behavior within TCY text",
						getSelectedText() == "ぜEng" );

			SelManager.selectRange(19,19);
			sendKeyboardGesture( CTRL_DELETE );
			SelManager.selectRange(17,19);
			assertTrue( "Ctrl-Delete changed removal behavior within TCY text",
						getSelectedText() == "gが" );
		}

/*********** CTRL-LEFT TESTS **************************************************************/

		// Test the basic functionality and undo/redo
   		public function CtrlLeftGeneralTest():void
   		{
   			LeftGeneralTest( CTRL_LEFT );
   		}
   		public function OptLeftGeneralTest():void
   		{
   			LeftGeneralTest( OPT_LEFT );
   		}
   		public function LeftGeneralTest( codeKey:int ):void
		{
			SelManager.selectRange(31,31);

			// Test Generic Functionality

			sendKeyboardGesture( codeKey );

			assertTrue( "Ctrl-Left failed to move to previous word",
						 SelManager.activePosition == 22 &&
						 SelManager.anchorPosition == 22 );

			sendKeyboardGesture( codeKey );

			assertTrue( "Ctrl-Left failed to move to previous word",
						 SelManager.activePosition == 18 &&
						 SelManager.anchorPosition == 18 );
		}

		// Test a bunch of different places in a line that Ctrl-Left could be pressed
		public function CtrlLeftLocationTest():void
		{
			SelManager.selectRange(0,0);
			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left changed position when exectuted at position 0",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 0 );

			SelManager.selectRange(46,46);
			sendKeyboardGesture(CTRL_LEFT);

			assertTrue( "Ctrl-Left failed on punctutation",
						SelManager.activePosition == 45 &&
						SelManager.anchorPosition == 45 );

			sendKeyboardGesture(CTRL_LEFT);

			assertTrue( "Ctrl-Left failed at the end of a line",
						SelManager.activePosition == 39 &&
						SelManager.anchorPosition == 39 );

			SelManager.selectRange(9,9);
			sendKeyboardGesture(CTRL_LEFT);

			assertTrue( "Ctrl-Left failed on a single character word",
						SelManager.activePosition == 8 &&
						SelManager.anchorPosition == 8 );

			SelManager.insertText("   ");
			SelManager.selectRange(11,11);
			sendKeyboardGesture(CTRL_LEFT);

			assertTrue( "Ctrl-Left failed over extra whitespace",
						SelManager.activePosition == 5 &&
						SelManager.anchorPosition == 5 );

			SelManager.selectRange(28,28);
			sendKeyboardGesture(CTRL_LEFT);

			assertTrue( "Ctrl-Left failed in the middle of a word",
						SelManager.activePosition == 25 &&
						SelManager.anchorPosition == 25 );

			SelManager.selectRange(40,40);
			sendKeyboardGesture(CTRL_LEFT);

			assertTrue( "Ctrl-Left failed 1 from the end of a word",
						SelManager.activePosition == 34 &&
						SelManager.anchorPosition == 34 );

			SelManager.selectRange(26,26);
			sendKeyboardGesture(CTRL_LEFT);

			assertTrue( "Ctrl-Left failed on the first character of a word",
						SelManager.activePosition == 25 &&
						SelManager.anchorPosition == 25 );

			sendKeyboardGesture(CTRL_LEFT);

			assertTrue( "Ctrl-Left failed after a single whitespace",
						SelManager.activePosition == 21 &&
						SelManager.anchorPosition == 21 );
		}

		public function CtrlLeftHyphenTest():void
		{
			SelManager.selectAll();
   			SelManager.deleteNextCharacter();
   			SelManager.flushPendingOperations();
   			SelManager.insertText(HYPHEN_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.insertText(BASIC_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.splitParagraph();

   			SelManager.selectRange(48,48);
   			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed over a paragraph break w/ hypen",
						SelManager.activePosition == 47 &&
						SelManager.anchorPosition == 47 );

			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen punctuation combination",
						SelManager.activePosition == 46 &&
						SelManager.anchorPosition == 46 );

			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen punctuation combination",
						SelManager.activePosition == 45 &&
						SelManager.anchorPosition == 45 );

			sendKeyboardGesture(CTRL_LEFT);
			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 31 &&
						SelManager.anchorPosition == 31 );

			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 30 &&
						SelManager.anchorPosition == 30 );

			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 22 &&
						SelManager.anchorPosition == 22 );

			SelManager.selectRange(21,21);

			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 18 &&
						SelManager.anchorPosition == 18 );

			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 17 &&
						SelManager.anchorPosition == 17 );

			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 15 &&
						SelManager.anchorPosition == 15 );

			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 14 &&
						SelManager.anchorPosition == 14 );

			SelManager.selectRange(9,9);

			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 8 &&
						SelManager.anchorPosition == 8 );

			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 7 &&
						SelManager.anchorPosition == 7 );

			sendKeyboardGesture(CTRL_LEFT);
			assertTrue( "Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 5 &&
						SelManager.anchorPosition == 5 );
		}

		public function CtrlLeftParagraphTest():void
		{
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);

			SelManager.selectRange(46,46); SelManager.splitParagraph();
			SelManager.selectRange(93,93); SelManager.splitParagraph();
			SelManager.selectRange(140,140); SelManager.splitParagraph();
			SelManager.selectRange(187,187); SelManager.splitParagraph();

			SelManager.selectRange(179,219);
			sendKeyboardGesture(CTRL_LEFT);

  			assertTrue("Ctrl-Left moved cursor with selection across paragraphs",
  						SelManager.activePosition == 179 &&
						SelManager.anchorPosition == 179 );

  			SelManager.selectRange(141,141);
  			sendKeyboardGesture(CTRL_LEFT);

  			assertTrue("Ctrl-Left failed to move between paragraphs",
  						SelManager.activePosition == 140 &&
						SelManager.anchorPosition == 140 );
  		}

		public function CtrlLeftImageTest():void
		{
			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(26,26);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(32,32);
			SelManager.insertText(" ");
			SelManager.selectRange(33,33);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(37,37);
			sendKeyboardGesture(CTRL_LEFT);
  			assertTrue("Ctrl-Left incorrectly navigated around images",
						SelManager.activePosition == 35 &&
						SelManager.anchorPosition == 35 );

  			sendKeyboardGesture(CTRL_LEFT);
  			assertTrue("Ctrl-Left incorrectly navigated around images",
						SelManager.activePosition == 34 &&
						SelManager.anchorPosition == 34 );
  			sendKeyboardGesture(CTRL_LEFT);

  			sendKeyboardGesture(CTRL_LEFT);
  			assertTrue("Ctrl-Left incorrectly navigated around images",
  						SelManager.activePosition == 27 &&
						SelManager.anchorPosition == 27 );

  			sendKeyboardGesture(CTRL_LEFT);
  			assertTrue("Ctrl-Left incorrectly navigated around images",
						SelManager.activePosition == 26 &&
						SelManager.anchorPosition == 26 );

  			sendKeyboardGesture(CTRL_LEFT);
  			assertTrue("Ctrl-Left incorrectly navigated around images",
  						SelManager.activePosition == 23 &&
						SelManager.anchorPosition == 23 );

			sendKeyboardGesture(CTRL_LEFT);
  			assertTrue("Ctrl-Left incorrectly navigated around images",
  						SelManager.activePosition == 21 &&
						SelManager.anchorPosition == 21 );
		}

		public function CtrlLeftLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( CTRL_LEFT );
			assertTrue( "Ctrl-Left failed in Right to Left Arabic text",
						SelManager.activePosition == 20 &&
						SelManager.anchorPosition == 20 );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( CTRL_LEFT );
			assertTrue( "Ctrl-Left failed to move through a bidi word",
						SelManager.activePosition == 79 &&
						SelManager.anchorPosition == 79 );

			sendKeyboardGesture( CTRL_LEFT );
			assertTrue( "Ctrl-Left changed movement behavior within a bidi word",
						SelManager.activePosition == 78 &&
						SelManager.anchorPosition == 78 );

			sendKeyboardGesture( CTRL_LEFT );
			assertTrue( "Ctrl-Left changed movement behavior within a bidi word",
						SelManager.activePosition == 70 &&
						SelManager.anchorPosition == 70 );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( CTRL_LEFT );

			assertTrue( "Ctrl-Left changed movement behavior within right to left text",
						SelManager.activePosition == 257 &&
						SelManager.anchorPosition == 257 );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( CTRL_LEFT );
			assertTrue( "Ctrl-Left changed removal behavior within TCY text",
						SelManager.activePosition == 15 &&
						SelManager.anchorPosition == 15 );

			SelManager.selectRange(23,23);
			sendKeyboardGesture( CTRL_LEFT );
			assertTrue( "Ctrl-Left changed removal behavior within TCY text",
						SelManager.activePosition == 22 &&
						SelManager.anchorPosition == 22 );
		}

/*********** CTRL-RIGHT TESTS **************************************************************/

		// Test the basic functionality and undo/redo
   		public function CtrlRightGeneralTest():void
   		{
   			RightGeneralTest( CTRL_RIGHT );
   		}
   		public function OptRightGeneralTest():void
   		{
   			RightGeneralTest( OPT_RIGHT );
   		}
   		public function RightGeneralTest( codeKey:int ):void
		{
			SelManager.selectRange(18,18);

			// Test Generic Functionality

			sendKeyboardGesture( codeKey );

			assertTrue( "Ctrl-Right failed to move to next word",
						 SelManager.activePosition == 22 &&
						 SelManager.anchorPosition == 22 );

			sendKeyboardGesture( codeKey );

			assertTrue( "Ctrl-Right failed to move to next word",
						 SelManager.activePosition == 31 &&
						 SelManager.anchorPosition == 31 );
		}

		// Test a bunch of different places in a line that Ctrl-Right could be pressed
		public function CtrlRightLocationTest():void
		{
			// Extending the selection to include the terminator at the end of the flow works or not depending on
			// the backwards compatibility flag. Version 1.0 does not allow it. Version 2.0 and later does allow it.
			SelManager.selectRange(SelManager.textFlow.textLength - 1,SelManager.textFlow.textLength - 1);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Key code changed position when executed at last position",
				SelManager.activePosition == SelManager.textFlow.textLength - 1 &&
				SelManager.anchorPosition == SelManager.textFlow.textLength - 1 );

			SelManager.selectRange(45,45);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed on punctutation",
						SelManager.activePosition == 46 &&
						SelManager.anchorPosition == 46 );

			SelManager.selectRange(0,0);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed at the beginning of a line",
						SelManager.activePosition == 5 &&
						SelManager.anchorPosition == 5 );

			SelManager.selectRange(8,8);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed on a single character word",
						SelManager.activePosition == 10 &&
						SelManager.anchorPosition == 10 );

			SelManager.insertText("   ");
			SelManager.selectRange(9,9);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed over extra whitespace",
						SelManager.activePosition == 13 &&
						SelManager.anchorPosition == 13 );

			SelManager.selectRange(28,28);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed in the middle of a word",
						SelManager.activePosition == 34 &&
						SelManager.anchorPosition == 34 );

			SelManager.selectRange(40,40);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed 1 from the end of a word",
						SelManager.activePosition == 42 &&
						SelManager.anchorPosition == 42 );

			SelManager.selectRange(26,26);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed on the first character of a word",
						SelManager.activePosition == 34 &&
						SelManager.anchorPosition == 34 );

			SelManager.selectRange(33,33);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed after a single whitespace",
						SelManager.activePosition == 34 &&
						SelManager.anchorPosition == 34 );
		}

		public function CtrlRightHyphenTest():void
		{
			SelManager.selectAll();
   			SelManager.deleteNextCharacter();
   			SelManager.flushPendingOperations();
   			SelManager.insertText(HYPHEN_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.insertText(BASIC_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.splitParagraph();

   			SelManager.selectRange(47,47);
   			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed over a paragraph break w/ hypen",
						SelManager.activePosition == 48 &&
						SelManager.anchorPosition == 48 );

			SelManager.selectRange(46,46);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen punctuation combination",
						SelManager.activePosition == 47 &&
						SelManager.anchorPosition == 47 );

			SelManager.selectRange(45,45);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen punctuation combination",
						SelManager.activePosition == 46 &&
						SelManager.anchorPosition == 46 );

			SelManager.selectRange(5,5);
			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 7 &&
						SelManager.anchorPosition == 7 );

			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 8 &&
						SelManager.anchorPosition == 8 );

			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 10 &&
						SelManager.anchorPosition == 10 );

			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 14 &&
						SelManager.anchorPosition == 14 );

			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 15 &&
						SelManager.anchorPosition == 15 );

			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 17 &&
						SelManager.anchorPosition == 17 );

			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 18 &&
						SelManager.anchorPosition == 18 );

			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 22 &&
						SelManager.anchorPosition == 22 );

			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 30 &&
						SelManager.anchorPosition == 30 );

			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 31 &&
						SelManager.anchorPosition == 31 );

			sendKeyboardGesture(CTRL_RIGHT);
			assertTrue( "Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 39 &&
						SelManager.anchorPosition == 39 );
		}

		public function CtrlRightParagraphTest():void
		{
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);

			SelManager.selectRange(46,46); SelManager.splitParagraph();
			SelManager.selectRange(93,93); SelManager.splitParagraph();
			SelManager.selectRange(140,140); SelManager.splitParagraph();
			SelManager.selectRange(187,187); SelManager.splitParagraph();

			SelManager.selectRange(179,219);
			sendKeyboardGesture(CTRL_RIGHT);

  			assertTrue("Ctrl-Right moved cursor with selection across paragraphs",
  						SelManager.activePosition == 219 &&
						SelManager.anchorPosition == 219 );

  			SelManager.selectRange(140,140);
  			sendKeyboardGesture(CTRL_RIGHT);

  			assertTrue("Ctrl-Right failed to move between paragraphs",
  						SelManager.activePosition == 141 &&
						SelManager.anchorPosition == 141 );
  		}

		public function CtrlRightImageTest():void
		{
			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(26,26);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(32,32);
			SelManager.insertText(" ");
			SelManager.selectRange(33,33);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(18,18);
			sendKeyboardGesture(CTRL_RIGHT);
  			assertTrue("Ctrl-Right incorrectly navigated around images",
						SelManager.activePosition == 20 &&
						SelManager.anchorPosition == 20 );

  			sendKeyboardGesture(CTRL_RIGHT);
  			assertTrue("Ctrl-Right incorrectly navigated around images",
						SelManager.activePosition == 21 &&
						SelManager.anchorPosition == 21 );

  			sendKeyboardGesture(CTRL_RIGHT);
  			assertTrue("Ctrl-Right incorrectly navigated around images",
  						SelManager.activePosition == 23 &&
						SelManager.anchorPosition == 23 );

  			sendKeyboardGesture(CTRL_RIGHT);
  			assertTrue("Ctrl-Right incorrectly navigated around images",
						SelManager.activePosition == 26 &&
						SelManager.anchorPosition == 26 );

  			sendKeyboardGesture(CTRL_RIGHT);
  			assertTrue("Ctrl-Right incorrectly navigated around images",
  						SelManager.activePosition == 27 &&
						SelManager.anchorPosition == 27 );

			sendKeyboardGesture(CTRL_RIGHT);
  			assertTrue("Ctrl-Right incorrectly navigated around images",
  						SelManager.activePosition == 33 &&
						SelManager.anchorPosition == 33 );

			sendKeyboardGesture(CTRL_RIGHT);
  			assertTrue("Ctrl-Right incorrectly navigated around images",
  						SelManager.activePosition == 34 &&
						SelManager.anchorPosition == 34 );

			sendKeyboardGesture(CTRL_RIGHT);
  			assertTrue("Ctrl-Right incorrectly navigated around images",
  						SelManager.activePosition == 35 &&
						SelManager.anchorPosition == 35 );

			sendKeyboardGesture(CTRL_RIGHT);
  			assertTrue("Ctrl-Right incorrectly navigated around images",
  						SelManager.activePosition == 37 &&
						SelManager.anchorPosition == 37 );
		}

		public function CtrlRightLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( CTRL_RIGHT );
			assertTrue( "Ctrl-Right failed in Right to Right Arabic text",
						SelManager.activePosition == 26 &&
						SelManager.anchorPosition == 26 );

			SelManager.selectRange(68,68);
			sendKeyboardGesture( CTRL_RIGHT );
			assertTrue( "Ctrl-Right failed to move through a bidi word",
						SelManager.activePosition == 70 &&
						SelManager.anchorPosition == 70 );

			sendKeyboardGesture( CTRL_RIGHT );
			assertTrue( "Ctrl-Right changed movement behavior within a bidi word",
						SelManager.activePosition == 78 &&
						SelManager.anchorPosition == 78 );

			sendKeyboardGesture( CTRL_RIGHT );
			assertTrue( "Ctrl-Right changed movement behavior within a bidi word",
						SelManager.activePosition == 79 &&
						SelManager.anchorPosition == 79 );

			sendKeyboardGesture( CTRL_RIGHT );
			assertTrue( "Ctrl-Right changed movement behavior within a bidi word",
						SelManager.activePosition == 85 &&
						SelManager.anchorPosition == 85 );

			SelManager.selectRange(257,257);
			sendKeyboardGesture( CTRL_RIGHT );

			assertTrue( "Ctrl-Right changed movement behavior within right to left text",
						SelManager.activePosition == 264 &&
						SelManager.anchorPosition == 264 );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( CTRL_RIGHT );
			assertTrue( "Ctrl-Right changed removal behavior within TCY text",
						SelManager.activePosition == 22 &&
						SelManager.anchorPosition == 22 );

			SelManager.selectRange(14,14);
			sendKeyboardGesture( CTRL_RIGHT );
			assertTrue( "Ctrl-Right changed removal behavior within TCY text",
						SelManager.activePosition == 15 &&
						SelManager.anchorPosition == 15 );
		}

/*********** CTRL-UP AND CTRL-HOME TESTS *****************************************************/

		// Test the basic functionality and undo/redo
   		public function CtrlUpGeneralTest():void
   		{
   			FlowBeginGeneralTest( CTRL_UP, "Ctrl-Up" );
   		}
   		public function OptUpGeneralTest():void
   		{
   			FlowBeginGeneralTest( OPT_UP, "Opt-Up" );
   		}
   		public function CtrlHomeGeneralTest():void
   		{
   			FlowBeginGeneralTest( CTRL_HOME, "Ctrl-Home" );
   		}

   		public function FlowBeginGeneralTest( codeKey:int, strKey:String ):void
		{
			// Test Generic Functionality

			SelManager.selectRange(18,18);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document beginning",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 0 );

			SelManager.selectRange(46,46);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document beginning",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 0 );
		}

		public function CtrlUpLocationTest():void
   		{
   			FlowBeginLocationTest( CTRL_UP, "Ctrl-Up" );
   		}
   		public function CtrlHomeLocationTest():void
   		{
   			FlowBeginLocationTest( CTRL_HOME, "Ctrl-Home" );
   		}

		public function FlowBeginLocationTest( codeKey:int, strKey:String ):void
		{
			SelManager.selectRange(46,46);
			SelManager.insertText( HYPHEN_TEST );
			SelManager.splitParagraph();
			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(26,26);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(32,32);
			SelManager.insertText(" ");
			SelManager.selectRange(33,33);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(53,53);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document beginning from 2nd paragraph",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 0 );

			SelManager.selectRange(35,35);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document beginning from image sandwich",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 0 );

			SelManager.selectRange(71,72);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document beginning from hyphenated word",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 0 );

			SelManager.selectRange(52,52);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document beginning from paragraph end",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 0 );
		}

		public function CtrlUpLanguageTest():void
   		{
   			FlowBeginLanguageTest( CTRL_UP, "Ctrl-Up" );
   		}
   		public function CtrlHomeLanguageTest():void
   		{
   			FlowBeginLanguageTest( CTRL_HOME, "Ctrl-Home" );
   		}

		public function FlowBeginLanguageTest( codeKey:int, strKey:String ):void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed in Right to Left Arabic text",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 0 );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move through a bidi word",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 0 );

			SelManager.selectRange(81,81);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed movement behavior within a bidi word",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 0 );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( codeKey );

			assertTrue( strKey + " changed movement behavior within right to left text",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 0 );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed removal behavior within TCY text",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 0 );

			SelManager.selectRange(22,22);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed removal behavior within TCY text",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 0 );
		}

/*********** CTRL-DOWN AND CTRL-END TESTS *****************************************************/

		// Test the basic functionality and undo/redo
   		public function CtrlDownGeneralTest():void
   		{
   			FlowEndGeneralTest( CTRL_DOWN, "Ctrl-Down" );
   		}
   		public function OptDownGeneralTest():void
   		{
   			FlowEndGeneralTest( OPT_DOWN, "Opt-Down" );
   		}
   		public function CtrlEndGeneralTest():void
   		{
   			FlowEndGeneralTest( CTRL_END, "Ctrl-End" );
   		}

   		public function FlowEndGeneralTest( codeKey:int, strKey:String ):void
		{
			// Test Generic Functionality

			SelManager.selectRange(18,18);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document end",
						 SelManager.activePosition == SelManager.textFlow.textLength - 1 &&
						 SelManager.anchorPosition == SelManager.textFlow.textLength - 1 );

			SelManager.selectRange(0,0);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document end",
						 SelManager.activePosition == SelManager.textFlow.textLength - 1 &&
						 SelManager.anchorPosition == SelManager.textFlow.textLength - 1 );
		}

		public function CtrlDownLocationTest():void
   		{
   			FlowEndLocationTest( CTRL_DOWN, "Ctrl-Down" );
   		}
   		public function CtrlEndLocationTest():void
   		{
   			FlowEndLocationTest( CTRL_END, "Ctrl-End" );
   		}

		public function FlowEndLocationTest( codeKey:int, strKey:String ):void
		{
			SelManager.selectRange(46,46);
			SelManager.insertText( HYPHEN_TEST );
			SelManager.splitParagraph();
			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(26,26);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(32,32);
			SelManager.insertText(" ");
			SelManager.selectRange(33,33);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(53,53);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document end from 2nd paragraph",
						 SelManager.activePosition == 100 &&
						 SelManager.anchorPosition == 100 );

			SelManager.selectRange(35,35);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document end from image sandwich",
						 SelManager.activePosition == 100 &&
						 SelManager.anchorPosition == 100 );

			SelManager.selectRange(71,72);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document end from hyphenated word",
						 SelManager.activePosition == 100 &&
						 SelManager.anchorPosition == 100 );

			SelManager.selectRange(52,52);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document end from paragraph end",
						 SelManager.activePosition == 100 &&
						 SelManager.anchorPosition == 100 );
		}

		public function CtrlDownLanguageTest():void
   		{
   			FlowEndLanguageTest( CTRL_DOWN, "Ctrl-Down" );
   		}
   		public function CtrlEndLanguageTest():void
   		{
   			FlowEndLanguageTest( CTRL_END, "Ctrl-End" );
   		}

		public function FlowEndLanguageTest( codeKey:int, strKey:String ):void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed in Right to Left Arabic text",
						SelManager.activePosition == 297 &&
						SelManager.anchorPosition == 297 );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move through a bidi word",
						SelManager.activePosition == 297 &&
						SelManager.anchorPosition == 297 );

			SelManager.selectRange(81,81);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed movement behavior within a bidi word",
						SelManager.activePosition == 297 &&
						SelManager.anchorPosition == 297 );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( codeKey );

			assertTrue( strKey + " changed movement behavior within right to left text",
						SelManager.activePosition == 297 &&
						SelManager.anchorPosition == 297 );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed removal behavior within TCY text",
						SelManager.activePosition == 88 &&
						SelManager.anchorPosition == 88 );

			SelManager.selectRange(22,22);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed removal behavior within TCY text",
						SelManager.activePosition == 88 &&
						SelManager.anchorPosition == 88 );
		}

/*********** SHIFT-CTRL-LEFT TESTS **************************************************************/

		// Test the basic functionality and undo/redo
   		public function ShiftCtrlLeftGeneralTest():void
   		{
   			ShiftLeftGeneralTest( SHIFT_CTRL_LEFT );
   		}
   		public function ShiftOptLeftGeneralTest():void
   		{
   			ShiftLeftGeneralTest( SHIFT_OPT_LEFT );
   		}
   		public function ShiftLeftGeneralTest( codeKey:int ):void
		{
			SelManager.selectRange(31,31);

			// Test Generic Functionality

			sendKeyboardGesture( codeKey );

			assertTrue( "Shift-Ctrl-Left failed to move to previous word",
						 SelManager.activePosition == 22 &&
						 SelManager.anchorPosition == 31 );

			sendKeyboardGesture( codeKey );

			assertTrue( "Shift-Ctrl-Left failed to move to previous word",
						 SelManager.activePosition == 18 &&
						 SelManager.anchorPosition == 31 );
		}

		// Test a bunch of different places in a line that Shift-Ctrl-Left could be pressed
		public function ShiftCtrlLeftLocationTest():void
		{
			SelManager.selectRange(0,0);
			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left changed position when exectuted at position 0",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 0 );

			SelManager.selectRange(46,46);
			sendKeyboardGesture(SHIFT_CTRL_LEFT);

			assertTrue( "Shift-Ctrl-Left failed on punctutation",
						SelManager.activePosition == 45 &&
						SelManager.anchorPosition == 46 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);

			assertTrue( "Shift-Ctrl-Left failed at the end of a line",
						SelManager.activePosition == 39 &&
						SelManager.anchorPosition == 46 );

			SelManager.selectRange(9,9);
			sendKeyboardGesture(SHIFT_CTRL_LEFT);

			assertTrue( "Shift-Ctrl-Left failed on a single character word",
						SelManager.activePosition == 8 &&
						SelManager.anchorPosition == 9 );

			SelManager.insertText("   ");
			SelManager.selectRange(12,12);
			sendKeyboardGesture(SHIFT_CTRL_LEFT);

			assertTrue( "Shift-Ctrl-Left failed over extra whitespace",
						SelManager.activePosition == 5 &&
						SelManager.anchorPosition == 12 );

			SelManager.selectRange(28,28);
			sendKeyboardGesture(SHIFT_CTRL_LEFT);

			assertTrue( "Shift-Ctrl-Left failed in the middle of a word",
						SelManager.activePosition == 24 &&
						SelManager.anchorPosition == 28 );

			SelManager.selectRange(40,40);
			sendKeyboardGesture(SHIFT_CTRL_LEFT);

			assertTrue( "Shift-Ctrl-Left failed 1 from the end of a word",
						SelManager.activePosition == 33 &&
						SelManager.anchorPosition == 40 );

			SelManager.selectRange(25,25);
			sendKeyboardGesture(SHIFT_CTRL_LEFT);

			assertTrue( "Shift-Ctrl-Left failed on the first character of a word",
						SelManager.activePosition == 24 &&
						SelManager.anchorPosition == 25 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);

			assertTrue( "Shift-Ctrl-Left failed after a single whitespace",
						SelManager.activePosition == 20 &&
						SelManager.anchorPosition == 25 );
		}

		public function ShiftCtrlLeftHyphenTest():void
		{
			SelManager.selectAll();
   			SelManager.deleteNextCharacter();
   			SelManager.flushPendingOperations();
   			SelManager.insertText(HYPHEN_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.insertText(BASIC_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.splitParagraph();

   			SelManager.selectRange(48,48);
   			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed over a paragraph break w/ hypen",
						SelManager.activePosition == 47 &&
						SelManager.anchorPosition == 48 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen punctuation combination",
						SelManager.activePosition == 46 &&
						SelManager.anchorPosition == 48 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen punctuation combination",
						SelManager.activePosition == 45 &&
						SelManager.anchorPosition == 48 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 31 &&
						SelManager.anchorPosition == 48 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 30 &&
						SelManager.anchorPosition == 48 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 22 &&
						SelManager.anchorPosition == 48 );

			SelManager.selectRange(21,21);

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 18 &&
						SelManager.anchorPosition == 21 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 17 &&
						SelManager.anchorPosition == 21 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 15 &&
						SelManager.anchorPosition == 21 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 14 &&
						SelManager.anchorPosition == 21 );

			SelManager.selectRange(9,9);

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 8 &&
						SelManager.anchorPosition == 9 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 7 &&
						SelManager.anchorPosition == 9 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
			assertTrue( "Shift-Ctrl-Left failed with a hyphen",
						SelManager.activePosition == 5 &&
						SelManager.anchorPosition == 9 );
		}

		public function ShiftCtrlLeftParagraphTest():void
		{
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);

			SelManager.selectRange(46,46); SelManager.splitParagraph();
			SelManager.selectRange(93,93); SelManager.splitParagraph();
			SelManager.selectRange(140,140); SelManager.splitParagraph();
			SelManager.selectRange(187,187); SelManager.splitParagraph();

			SelManager.selectRange(179,219);
			sendKeyboardGesture(SHIFT_CTRL_LEFT);

  			assertTrue("Shift-Ctrl-Left moved cursor with selection across paragraphs",
  						SelManager.activePosition == 210 &&
						SelManager.anchorPosition == 179 );

  			SelManager.selectRange(141,141);
  			sendKeyboardGesture(SHIFT_CTRL_LEFT);

  			assertTrue("Shift-Ctrl-Left failed to move between paragraphs",
  						SelManager.activePosition == 140 &&
						SelManager.anchorPosition == 141 );
  		}

		public function ShiftCtrlLeftImageTest():void
		{
			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(26,26);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(32,32);
			SelManager.insertText(" ");
			SelManager.selectRange(33,33);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(37,37);
			sendKeyboardGesture(SHIFT_CTRL_LEFT);
  			assertTrue("Shift-Ctrl-Left incorrectly navigated around images",
						SelManager.activePosition == 35 &&
						SelManager.anchorPosition == 37 );

  			sendKeyboardGesture(SHIFT_CTRL_LEFT);
  			assertTrue("Shift-Ctrl-Left incorrectly navigated around images",
						SelManager.activePosition == 34 &&
						SelManager.anchorPosition == 37 );
  			sendKeyboardGesture(SHIFT_CTRL_LEFT);

  			sendKeyboardGesture(SHIFT_CTRL_LEFT);
  			assertTrue("Shift-Ctrl-Left incorrectly navigated around images",
  						SelManager.activePosition == 27 &&
						SelManager.anchorPosition == 37 );

  			sendKeyboardGesture(SHIFT_CTRL_LEFT);
  			assertTrue("Shift-Ctrl-Left incorrectly navigated around images",
						SelManager.activePosition == 26 &&
						SelManager.anchorPosition == 37 );

  			sendKeyboardGesture(SHIFT_CTRL_LEFT);
  			assertTrue("Shift-Ctrl-Left incorrectly navigated around images",
  						SelManager.activePosition == 23 &&
						SelManager.anchorPosition == 37 );

			sendKeyboardGesture(SHIFT_CTRL_LEFT);
  			assertTrue("Shift-Ctrl-Left incorrectly navigated around images",
  						SelManager.activePosition == 21 &&
						SelManager.anchorPosition == 37 );
		}

		public function ShiftCtrlLeftLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( SHIFT_CTRL_LEFT );
			assertTrue( "Shift-Ctrl-Left failed in Right to Left Arabic text",
						SelManager.activePosition == 20 &&
						SelManager.anchorPosition == 22 );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( SHIFT_CTRL_LEFT );
			assertTrue( "Shift-Ctrl-Left failed to move through a bidi word",
						SelManager.activePosition == 79 &&
						SelManager.anchorPosition == 85 );

			sendKeyboardGesture( SHIFT_CTRL_LEFT );
			assertTrue( "Shift-Ctrl-Left changed movement behavior within a bidi word",
						SelManager.activePosition == 78 &&
						SelManager.anchorPosition == 85 );

			sendKeyboardGesture( SHIFT_CTRL_LEFT );
			assertTrue( "Shift-Ctrl-Left changed movement behavior within a bidi word",
						SelManager.activePosition == 70 &&
						SelManager.anchorPosition == 85 );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( SHIFT_CTRL_LEFT );

			assertTrue( "Shift-Ctrl-Left changed movement behavior within right to left text",
						SelManager.activePosition == 257 &&
						SelManager.anchorPosition == 261 );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( SHIFT_CTRL_LEFT );
			assertTrue( "Shift-Ctrl-Left changed removal behavior within TCY text",
						SelManager.activePosition == 15 &&
						SelManager.anchorPosition == 18 );

			SelManager.selectRange(23,23);
			sendKeyboardGesture( SHIFT_CTRL_LEFT );
			assertTrue( "Shift-Ctrl-Left changed removal behavior within TCY text",
						SelManager.activePosition == 22 &&
						SelManager.anchorPosition == 23 );

			sendKeyboardGesture( SHIFT_CTRL_LEFT );
			assertTrue( "Shift-Ctrl-Left changed removal behavior within TCY text",
						SelManager.activePosition == 15 &&
						SelManager.anchorPosition == 23 );
		}

/*********** SHIFT-CTRL-RIGHT TESTS **************************************************************/

		// Test the basic functionality and undo/redo
   		public function ShiftCtrlRightGeneralTest():void
   		{
   			ShiftRightGeneralTest( SHIFT_CTRL_RIGHT );
   		}
   		public function ShiftOptRightGeneralTest():void
   		{
   			ShiftRightGeneralTest( SHIFT_OPT_RIGHT );
   		}
   		public function ShiftRightGeneralTest( codeKey:int ):void
		{
			SelManager.selectRange(18,18);

			// Test Generic Functionality

			sendKeyboardGesture( codeKey );

			assertTrue( "Shift-Ctrl-Right failed to select the next word",
						 SelManager.activePosition == 22 &&
						 SelManager.anchorPosition == 18 );

			sendKeyboardGesture( codeKey );

			assertTrue( "Shift-Ctrl-Right failed to select the next word",
						 SelManager.activePosition == 31 &&
						 SelManager.anchorPosition == 18 );
		}

		// Test a bunch of different places in a line that Shift-Ctrl-Right could be pressed
		public function ShiftCtrlRightLocationTest():void
		{
			// Extending the selection to include the terminator at the end of the flow works or not depending on
			// the backwards compatibility flag. Version 1.0 does not allow it. Version 2.0 and later does allow it.
			var lastRangeSelectionPos:int = SelManager.textFlow.textLength - 1;
			
			SelManager.selectRange(SelManager.textFlow.textLength - 1,SelManager.textFlow.textLength - 1);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right should be at end when executed at last position",
				SelManager.activePosition == lastRangeSelectionPos &&
				SelManager.anchorPosition == SelManager.textFlow.textLength - 1 );

			SelManager.selectRange(45,45);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed on punctutation",
						SelManager.activePosition == 46 &&
						SelManager.anchorPosition == 45 );

			SelManager.selectRange(0,0);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed at the beginning of a line",
						SelManager.activePosition == 5 &&
						SelManager.anchorPosition == 0 );

			SelManager.selectRange(8,8);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed on a single character word",
						SelManager.activePosition == 10 &&
						SelManager.anchorPosition == 8 );

			SelManager.insertText("   ");
			SelManager.selectRange(7,7);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed over extra whitespace",
						SelManager.activePosition == 11 &&
						SelManager.anchorPosition == 7 );

			SelManager.selectRange(26,26);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed in the middle of a word",
						SelManager.activePosition == 32 &&
						SelManager.anchorPosition == 26 );

			SelManager.selectRange(38,38);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed 1 from the end of a word",
						SelManager.activePosition == 40 &&
						SelManager.anchorPosition == 38 );

			SelManager.selectRange(24,24);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed on the first character of a word",
						SelManager.activePosition == 32 &&
						SelManager.anchorPosition == 24 );

			SelManager.selectRange(31,31);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed after a single whitespace",
						SelManager.activePosition == 32 &&
						SelManager.anchorPosition == 31 );
		}

		public function ShiftCtrlRightHyphenTest():void
		{
			SelManager.selectAll();
   			SelManager.deleteNextCharacter();
   			SelManager.flushPendingOperations();
   			SelManager.insertText(HYPHEN_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.insertText(BASIC_TEST);
   			SelManager.selectRange(47,47);
   			SelManager.splitParagraph();

   			SelManager.selectRange(47,47);
   			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed over a paragraph break w/ hypen",
						SelManager.activePosition == 48 &&
						SelManager.anchorPosition == 47 );

			SelManager.selectRange(46,46);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen punctuation combination",
						SelManager.activePosition == 47 &&
						SelManager.anchorPosition == 46 );

			SelManager.selectRange(45,45);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen punctuation combination",
						SelManager.activePosition == 46 &&
						SelManager.anchorPosition == 45 );

			SelManager.selectRange(5,5);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 7 &&
						SelManager.anchorPosition == 5 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 8 &&
						SelManager.anchorPosition == 5 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 10 &&
						SelManager.anchorPosition == 5 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 14 &&
						SelManager.anchorPosition == 5 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 15 &&
						SelManager.anchorPosition == 5 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 17 &&
						SelManager.anchorPosition == 5 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 18 &&
						SelManager.anchorPosition == 5 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 22 &&
						SelManager.anchorPosition == 5 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 30 &&
						SelManager.anchorPosition == 5 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 31 &&
						SelManager.anchorPosition == 5 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
			assertTrue( "Shift-Ctrl-Right failed with a hyphen",
						SelManager.activePosition == 39 &&
						SelManager.anchorPosition == 5 );
		}

		public function ShiftCtrlRightParagraphTest():void
		{
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);
			SelManager.insertText(BASIC_TEST);

			SelManager.selectRange(46,46); SelManager.splitParagraph();
			SelManager.selectRange(93,93); SelManager.splitParagraph();
			SelManager.selectRange(140,140); SelManager.splitParagraph();
			SelManager.selectRange(187,187); SelManager.splitParagraph();

			SelManager.selectRange(179,219);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);

  			assertTrue("Shift-Ctrl-Right moved cursor with selection across paragraphs",
  						SelManager.activePosition == 227 &&
						SelManager.anchorPosition == 179 );

  			SelManager.selectRange(140,140);
  			sendKeyboardGesture(SHIFT_CTRL_RIGHT);

  			assertTrue("Shift-Ctrl-Right failed to move between paragraphs",
  						SelManager.activePosition == 141 &&
						SelManager.anchorPosition == 140 );
  		}

		public function ShiftCtrlRightImageTest():void
		{
			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(26,26);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(32,32);
			SelManager.insertText(" ");
			SelManager.selectRange(33,33);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(18,18);
			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
  			assertTrue("Shift-Ctrl-Right incorrectly selected around images",
						SelManager.activePosition == 20 &&
						SelManager.anchorPosition == 18 );

  			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
  			assertTrue("Shift-Ctrl-Right incorrectly selected around images",
						SelManager.activePosition == 21 &&
						SelManager.anchorPosition == 18 );

  			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
  			assertTrue("Shift-Ctrl-Right incorrectly selected around images",
  						SelManager.activePosition == 23 &&
						SelManager.anchorPosition == 18 );

  			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
  			assertTrue("Shift-Ctrl-Right incorrectly selected around images",
						SelManager.activePosition == 26 &&
						SelManager.anchorPosition == 18 );

  			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
  			assertTrue("Shift-Ctrl-Right incorrectly selected around images",
  						SelManager.activePosition == 27 &&
						SelManager.anchorPosition == 18 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
  			assertTrue("Shift-Ctrl-Right incorrectly selected around images",
  						SelManager.activePosition == 33 &&
						SelManager.anchorPosition == 18 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
  			assertTrue("Shift-Ctrl-Right incorrectly selected around images",
  						SelManager.activePosition == 34 &&
						SelManager.anchorPosition == 18 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
  			assertTrue("Shift-Ctrl-Right incorrectly selected around images",
  						SelManager.activePosition == 35 &&
						SelManager.anchorPosition == 18 );

			sendKeyboardGesture(SHIFT_CTRL_RIGHT);
  			assertTrue("Shift-Ctrl-Right incorrectly selected around images",
  						SelManager.activePosition == 37 &&
						SelManager.anchorPosition == 18 );
		}

		public function ShiftCtrlRightLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( SHIFT_CTRL_RIGHT );
			assertTrue( "Shift-Ctrl-Right failed in Right to Right Arabic text",
						SelManager.activePosition == 26 &&
						SelManager.anchorPosition == 22 );

			SelManager.selectRange(68,68);
			sendKeyboardGesture( SHIFT_CTRL_RIGHT );
			assertTrue( "Shift-Ctrl-Right failed to move through a bidi word",
						SelManager.activePosition == 70 &&
						SelManager.anchorPosition == 68 );

			sendKeyboardGesture( SHIFT_CTRL_RIGHT );
			assertTrue( "Shift-Ctrl-Right changed movement behavior within a bidi word",
						SelManager.activePosition == 78 &&
						SelManager.anchorPosition == 68 );

			sendKeyboardGesture( SHIFT_CTRL_RIGHT );
			assertTrue( "Shift-Ctrl-Right changed movement behavior within a bidi word",
						SelManager.activePosition == 79 &&
						SelManager.anchorPosition == 68 );

			sendKeyboardGesture( SHIFT_CTRL_RIGHT );
			assertTrue( "Shift-Ctrl-Right changed movement behavior within a bidi word",
						SelManager.activePosition == 85 &&
						SelManager.anchorPosition == 68 );

			SelManager.selectRange(257,257);
			sendKeyboardGesture( SHIFT_CTRL_RIGHT );

			assertTrue( "Shift-Ctrl-Right changed movement behavior within right to left text",
						SelManager.activePosition == 264 &&
						SelManager.anchorPosition == 257 );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( SHIFT_CTRL_RIGHT );
			assertTrue( "Shift-Ctrl-Right changed removal behavior within TCY text",
						SelManager.activePosition == 22 &&
						SelManager.anchorPosition == 18 );

			SelManager.selectRange(14,14);
			sendKeyboardGesture( SHIFT_CTRL_RIGHT );
			assertTrue( "Shift-Ctrl-Right changed removal behavior within TCY text",
						SelManager.activePosition == 15 &&
						SelManager.anchorPosition == 14 );

			sendKeyboardGesture( SHIFT_CTRL_RIGHT );
			assertTrue( "Shift-Ctrl-Right changed removal behavior within TCY text",
						SelManager.activePosition == 22 &&
						SelManager.anchorPosition == 14 );
		}


/*********** SHIFT-CTRL-UP AND SHIFT-CTRL-HOME TESTS *****************************************************/

		// Test the basic functionality and undo/redo
   		public function ShiftCtrlUpGeneralTest():void
   		{
   			SelectBeginGeneralTest( SHIFT_CTRL_UP, "Shift-Ctrl-Up" );
   		}
   		public function ShiftOptUpGeneralTest():void
   		{
   			SelectBeginGeneralTest( SHIFT_OPT_UP, "Shift-Opt-Up" );
   		}
   		public function ShiftCtrlHomeGeneralTest():void
   		{
   			SelectBeginGeneralTest( SHIFT_CTRL_HOME, "Shift-Ctrl-Home" );
   		}

   		public function SelectBeginGeneralTest( codeKey:int, strKey:String ):void
		{
			// Test Generic Functionality

			SelManager.selectRange(18,18);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document beginning",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 18 );

			SelManager.selectRange(46,46);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to move to document beginning",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 46 );
		}

		public function ShiftCtrlUpLocationTest():void
   		{
   			SelectBeginLocationTest( SHIFT_CTRL_UP, "Shift-Ctrl-Up" );
   		}
   		public function ShiftCtrlHomeLocationTest():void
   		{
   			SelectBeginLocationTest( SHIFT_CTRL_HOME, "Shift-Ctrl-Home" );
   		}

		public function SelectBeginLocationTest( codeKey:int, strKey:String ):void
		{
			SelManager.selectRange(46,46);
			SelManager.insertText( HYPHEN_TEST );
			SelManager.splitParagraph();
			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(26,26);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(32,32);
			SelManager.insertText(" ");
			SelManager.selectRange(33,33);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(53,53);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select to document beginning from 2nd paragraph",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 53 );

			SelManager.selectRange(35,35);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select to document beginning from image sandwich",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 35 );

			SelManager.selectRange(71,72);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select to document beginning from hyphenated word",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 71 );

			SelManager.selectRange(52,52);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select to document beginning from paragraph end",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 52 );

			SelManager.selectRange(43,62);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to extend selection to document beginning",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 43 );
		}

		public function ShiftCtrlUpLanguageTest():void
   		{
   			ShiftFlowBeginLanguageTest( SHIFT_CTRL_UP, "Ctrl-Shift-Up" );
   		}
   		public function ShiftCtrlHomeLanguageTest():void
   		{
   			ShiftFlowBeginLanguageTest( SHIFT_CTRL_HOME, "Ctrl-Shift-Home" );
   		}

		public function ShiftFlowBeginLanguageTest( codeKey:int, strKey:String ):void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed in Right to Left Arabic text",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 22 );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select through a bidi word",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 85 );

			SelManager.selectRange(81,81);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed selection behavior within a bidi word",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 81 );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( codeKey );

			assertTrue( strKey + " changed selection behavior within right to left text",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 261 );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed selection behavior within TCY text",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 18 );

			SelManager.selectRange(22,22);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed selection behavior within TCY text",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 22 );
		}

/*********** SHIFT-CTRL-DOWN AND SHIFT-CTRL-END TESTS *****************************************************/

		// Test the basic functionality and undo/redo
   		public function ShiftCtrlDownGeneralTest():void
   		{
   			SelectEndGeneralTest( SHIFT_CTRL_DOWN, "Shift-Ctrl-Down" );
   		}
   		public function ShiftOptDownGeneralTest():void
   		{
			var paragraph:ParagraphElement = SelManager.textFlow.findLeaf(18).getParagraph();
			SelManager.selectRange(18,18);
			sendKeyboardGesture( SHIFT_OPT_DOWN );
			assertTrue( "Shift-Opt-Down failed to select to paragraph end",
				SelManager.activePosition == paragraph.getAbsoluteStart() + paragraph.textLength - 1 &&
				SelManager.anchorPosition == 18 );
			
			paragraph = SelManager.textFlow.findLeaf(0).getParagraph();
			SelManager.selectRange(0,0);
			sendKeyboardGesture( SHIFT_OPT_DOWN );
			assertTrue( "Shift-Opt-Down failed to select to document end",
				SelManager.activePosition == paragraph.getAbsoluteStart() + paragraph.textLength - 1 &&
				SelManager.anchorPosition == 0 );
   		}
   		public function ShiftCtrlEndGeneralTest():void
   		{
   			SelectEndGeneralTest( SHIFT_CTRL_END, "Shift-Ctrl-End" );
   		}

   		public function SelectEndGeneralTest( codeKey:int, strKey:String ):void
		{
			// Test Generic Functionality
			var lastCharacterRangePos:int = SelManager.textFlow.textLength - 1;

			SelManager.selectRange(18,18);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select to document end",
						 SelManager.activePosition == lastCharacterRangePos &&
						 SelManager.anchorPosition == 18 );

			SelManager.selectRange(0,0);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select to document end",
				SelManager.activePosition == lastCharacterRangePos &&
				SelManager.anchorPosition == 0 );
		}

		public function ShiftCtrlDownLocationTest():void
   		{
   			SelectEndLocationTest( SHIFT_CTRL_DOWN, "Shift-Ctrl-Down" );
   		}
   		public function ShiftCtrlEndLocationTest():void
   		{
   			SelectEndLocationTest( SHIFT_CTRL_END, "Shift-Ctrl-End" );
   		}

		public function SelectEndLocationTest( codeKey:int, strKey:String ):void
		{
			SelManager.selectRange(SelManager.textFlow.textLength - 1,SelManager.textFlow.textLength - 1);
			SelManager.insertText( HYPHEN_TEST );
			SelManager.splitParagraph();
			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(26,26);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(32,32);
			SelManager.insertText(" ");
			SelManager.selectRange(33,33);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			// Versions before 2.0 don't allow selection of last char
			var lastSelectableRangePos:int = SelManager.textFlow.textLength - 1;
			SelManager.selectRange(53,53);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select to document end from 2nd paragraph",
						 SelManager.activePosition == lastSelectableRangePos &&
						 SelManager.anchorPosition == 53 );

			SelManager.selectRange(35,35);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select to document end from image sandwich",
						 SelManager.activePosition == lastSelectableRangePos &&
						 SelManager.anchorPosition == 35 );

			SelManager.selectRange(72,72);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select to document end from hyphenated word",
						 SelManager.activePosition == lastSelectableRangePos &&
						 SelManager.anchorPosition == 72 );

			SelManager.selectRange(52,52);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select to document end from paragraph end",
						 SelManager.activePosition == lastSelectableRangePos &&
						 SelManager.anchorPosition == 52 );

			SelManager.selectRange(43,62);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to extend selection to document end",
						 SelManager.activePosition == lastSelectableRangePos &&
						 SelManager.anchorPosition == 43 );
		}

		public function ShiftCtrlDownLanguageTest():void
   		{
   			ShiftFlowEndLanguageTest( SHIFT_CTRL_DOWN, "Shift-Ctrl-Down" );
   		}
   		public function ShiftCtrlEndLanguageTest():void
   		{
   			ShiftFlowEndLanguageTest( SHIFT_CTRL_END, "Shift-Ctrl-End" );
   		}

		public function ShiftFlowEndLanguageTest( codeKey:int, strKey:String ):void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( codeKey );

			// Versions before 2.0 don't allow selection of last char
			var lastSelectableRangePos:int = SelManager.textFlow.textLength - 1;

			assertTrue( strKey + " failed in Right to Left Arabic text",
						SelManager.activePosition == lastSelectableRangePos &&
						SelManager.anchorPosition == 22 );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " failed to select through a bidi word",
						SelManager.activePosition == lastSelectableRangePos &&
						SelManager.anchorPosition == 85 );

			SelManager.selectRange(81,81);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed selection behavior within a bidi word",
						SelManager.activePosition == lastSelectableRangePos &&
						SelManager.anchorPosition == 81 );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( codeKey );

			assertTrue( strKey + " changed selection behavior within right to left text",
						SelManager.activePosition == lastSelectableRangePos &&
						SelManager.anchorPosition == 261 );

			setUpTCYTest();

			lastSelectableRangePos = SelManager.textFlow.textLength - 1;

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed removal behavior within TCY text",
						SelManager.activePosition == lastSelectableRangePos &&
						SelManager.anchorPosition == 18 );

			SelManager.selectRange(22,22);
			sendKeyboardGesture( codeKey );
			assertTrue( strKey + " changed removal behavior within TCY text",
						SelManager.activePosition == lastSelectableRangePos &&
						SelManager.anchorPosition == 22 );
		}

/*********** HOME TESTS ***********************************************************************/

		// Test the basic functionality and undo/redo
   		public function HomeGeneralTest():void
		{
			// Test Generic Functionality
			loadTestFile( "simple.xml" );

			SelManager.selectRange(342,342);
			sendKeyboardGesture( HOME );

			assertTrue( "Home failed to select the correct line",
						 SelManager.textFlow.flowComposer.findLineAtPosition(342) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Home failed to select to line beginning",
						 elem is SpanElement );

			SelManager.selectRange(2155,2155);
			sendKeyboardGesture( HOME );

			assertTrue( "Home failed to select the correct line",
						 SelManager.textFlow.flowComposer.findLineAtPosition(2155) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Home failed to select to line beginning",
						 elem is SpanElement );
		}

		public function HomeLocationTest():void
		{
			loadTestFile( "simple.xml" );

			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(959,959);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(606,606);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(608,608);
			sendKeyboardGesture( HOME );
			assertTrue( "Home failed to move the correct line from image sandwich",
						 SelManager.textFlow.flowComposer.findLineAtPosition(608) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Home failed to move to line beginning from image sandwich",
						 elem is SpanElement );

			sendKeyboardGesture( HOME );
			assertTrue( "Home failed to move the correct line when excuted twice",
						 SelManager.textFlow.flowComposer.findLineAtPosition(608) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Home failed to move to line beginning when excuted twice",
						 elem is SpanElement );

			SelManager.selectRange(26,26);
			sendKeyboardGesture( HOME );
			assertTrue( "Home failed to move to line beginning from hyphenated word",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 0 );

			SelManager.selectRange(957,957);
			sendKeyboardGesture( HOME );
			assertTrue( "Home failed to move the correct line from paragraph end",
						 SelManager.textFlow.flowComposer.findLineAtPosition(957) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Home failed to move to line beginning from paragraph end",
						 elem is SpanElement );

			SelManager.selectRange(1741,1762);
			sendKeyboardGesture( HOME );
			assertTrue( "Home failed to move the correct line",
						 SelManager.textFlow.flowComposer.findLineAtPosition(1762) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Home failed to move to line beginning",
						 elem is SpanElement );
		}

		public function HomeLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( HOME );
			assertTrue( "Home failed in Right to Left Arabic text",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 0 );
			assertTrue( "Home failed to move the correct line in Right to Left Arabic text",
						 SelManager.textFlow.flowComposer.findLineAtPosition(22) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( HOME );
			assertTrue( "Home failed to move the correct line  through a bidi word",
						 SelManager.textFlow.flowComposer.findLineAtPosition(85) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Home failed to move to line beginning  through a bidi word",
						 elem is SpanElement );

			SelManager.selectRange(77,77);
			sendKeyboardGesture( HOME );
			assertTrue( "Home failed to move the correct line within a bidi word",
						 SelManager.textFlow.flowComposer.findLineAtPosition(77) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Home failed to move to line beginning within a bidi word",
						 elem is SpanElement );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( HOME );
			assertTrue( "Home failed to move the correct line within right to left text",
						 SelManager.textFlow.flowComposer.findLineAtPosition(261) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Home failed to move to line beginning within right to left text",
						 elem is SpanElement );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( HOME );
			assertTrue( "Home changed removal behavior within TCY text",
						SelManager.activePosition == 8 &&
						SelManager.anchorPosition == 8 );

			SelManager.selectRange(22,22);
			sendKeyboardGesture( HOME );
			assertTrue( "Home changed removal behavior within TCY text",
						SelManager.activePosition == 8 &&
						SelManager.anchorPosition == 8 );
		}

/*********** END TESTS ************************************************************************/

		// Test the basic functionality and undo/redo

   		public function EndGeneralTest():void
		{
			// Test Generic Functionality
			loadTestFile( "simple.xml" );

			SelManager.selectRange(342,342);
			sendKeyboardGesture( END );
			assertTrue( "End failed to move the correct line end",
						 SelManager.textFlow.flowComposer.findLineAtPosition(342) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "End failed to move to line end",
						 elem is SpanElement );

			SelManager.selectRange(2009,2009);
			sendKeyboardGesture( END );
			assertTrue( "End failed to move the correct line end",
						 SelManager.textFlow.flowComposer.findLineAtPosition(2009) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "End failed to move to line end",
						 elem is SpanElement );
		}

		public function EndLocationTest():void
		{
			loadTestFile( "simple.xml" );

			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(959,959);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(606,606);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(608,608);
			sendKeyboardGesture( END );
			SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.anchorPosition)
			assertTrue( "End failed to move the correct line end from image sandwich",
						 SelManager.textFlow.flowComposer.findLineAtPosition(608) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "End failed to move to line end from image sandwich",
						 elem is SpanElement );

			SelManager.selectRange(25,25);
			sendKeyboardGesture( END );
			assertTrue( "End failed to move the correct line end from hyphenated word",
						 SelManager.textFlow.flowComposer.findLineAtPosition(25) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "End failed to move to line end from hyphenated word",
						 elem is SpanElement );

			sendKeyboardGesture( END );
			assertTrue( "End failed to move the correct line end when executed twice",
						 SelManager.textFlow.flowComposer.findLineAtPosition(25) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "End failed to move to line end when executed twice",
						 elem is SpanElement );

			SelManager.selectRange(957,957);
			sendKeyboardGesture( END );
			assertTrue( "End failed to move the correct line end when executed twice",
						 SelManager.textFlow.flowComposer.findLineAtPosition(957) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "End failed to move to line end when executed twice",
						 elem is SpanElement );

			SelManager.selectRange(1741,1762);
			sendKeyboardGesture( END );
			assertTrue( "End failed to move the correct line end from selection to line end",
						 SelManager.textFlow.flowComposer.findLineAtPosition(1762) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "End failed to move to line end from selection to line end",
						 elem is SpanElement );
		}

		public function EndLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( END );
			assertTrue( "End failed to move the correct line end from Right to Left text",
						 SelManager.textFlow.flowComposer.findLineAtPosition(22) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "End failed to move to line end from Right to Left text",
						 elem is SpanElement );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( END );
			assertTrue( "End failed to move the correct line end from a bidi word",
						 SelManager.textFlow.flowComposer.findLineAtPosition(85) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "End failed to move to line end from a bidi word",
						 elem is SpanElement );

			SelManager.selectRange(77,77);
			sendKeyboardGesture( END );
			assertTrue( "End changed movement behavior within a bidi word",
						 SelManager.textFlow.flowComposer.findLineAtPosition(77) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "End changed movement behavior within a bidi word",
						 elem is SpanElement );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( END );
			assertTrue( "End changed movement behavior within right to left text",
						 SelManager.textFlow.flowComposer.findLineAtPosition(263) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "End changed movement behavior within right to left text",
						 elem is SpanElement );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( END );
			assertTrue( "End changed removal behavior within TCY text",
						SelManager.activePosition == 27 &&
						SelManager.anchorPosition == 27 );

			SelManager.selectRange(22,22);
			sendKeyboardGesture( END );
			assertTrue( "End changed removal behavior within TCY text",
						SelManager.activePosition == 27 &&
						SelManager.anchorPosition == 27 );
		}

/*********** SHIFT-HOME TESTS ***********************************************************************/

		// Test the basic functionality and undo/redo
   		public function ShiftHomeGeneralTest():void
		{
			// Test Generic Functionality
			loadTestFile( "simple.xml" );

			SelManager.selectRange(342,342);
			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home failed to select to line beginning",
						 SelManager.anchorPosition == 342 );
			assertTrue( "Shift-Home failed to select the correct line",
						 SelManager.textFlow.flowComposer.findLineAtPosition(342) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Shift-Home failed to select to line beginning",
						 elem is SpanElement );

			SelManager.selectRange(2155,2155);
			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home failed to select to line beginning",
						 SelManager.anchorPosition == 2155 );
			assertTrue( "Shift-Home failed to select the correct line",
						 SelManager.textFlow.flowComposer.findLineAtPosition(2155) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Shift-Home failed to select to line beginning",
						 elem is SpanElement );
		}

		public function ShiftHomeLocationTest():void
		{
			loadTestFile( "simple.xml" );

			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(959,959);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(606,606);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(608,608);
			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home failed to move to line beginning from image sandwich",
						 SelManager.anchorPosition == 608 );
			assertTrue( "Shift-Home failed to move the correct line from image sandwich",
						 SelManager.textFlow.flowComposer.findLineAtPosition(608) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Shift-Home failed to move to line beginning from image sandwich",
						 elem is SpanElement );

			SelManager.selectRange(26,26);
			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home failed to move to line beginning from hyphenated word",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 26 );

			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home failed when executed twice",
						 SelManager.activePosition == 0 &&
						 SelManager.anchorPosition == 26 );

			SelManager.selectRange(957,957);
			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home failed to move to line beginning from paragraph end",
						 SelManager.anchorPosition == 957 );
			assertTrue( "Shift-Home failed to move the correct line from paragraph end",
						 SelManager.textFlow.flowComposer.findLineAtPosition(957) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Shift-Home failed to move to line beginning from paragraph end",
						 elem is SpanElement );

			SelManager.selectRange(1741,1762);
			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home failed to move from selection to line beginning",
						 SelManager.anchorPosition == 1741 );
			assertTrue( "Shift-Home failed to select the correct line",
						 SelManager.textFlow.flowComposer.findLineAtPosition(1762) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Shift-Home failed to select to line beginning",
						 elem is SpanElement );
		}

		public function ShiftHomeLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home failed in Right to Left text",
						SelManager.activePosition == 0 &&
						SelManager.anchorPosition == 22 );
			assertTrue( "Shift-Home failed to select the correct line in Right to Left text",
						 SelManager.textFlow.flowComposer.findLineAtPosition(22) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home failed to move through a bidi word",
						SelManager.anchorPosition == 85 );
			assertTrue( "Shift-Home failed to select the correct line through a bidi word",
						 SelManager.textFlow.flowComposer.findLineAtPosition(85) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Shift-Home failed to select to line beginning through a bidi word",
						 elem is SpanElement );

			SelManager.selectRange(77,77);
			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home changed movement behavior within a bidi word",
						SelManager.anchorPosition == 77 );
			assertTrue( "Shift-Home failed to select the correct line within a bidi word",
						 SelManager.textFlow.flowComposer.findLineAtPosition(77) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Shift-Home failed to select to line beginning within a bidi word",
						 elem is SpanElement );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( SHIFT_HOME );

			assertTrue( "Shift-Home changed movement behavior within right to left text",
						SelManager.anchorPosition == 261 );
			assertTrue( "Shift-Home failed to select the correct line within right to left text",
						 SelManager.textFlow.flowComposer.findLineAtPosition(261) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition-1);
			assertTrue( "Shift-Home failed to select to line beginning within right to left text",
						 elem is SpanElement );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home changed removal behavior within TCY text",
						SelManager.activePosition == 8 &&
						SelManager.anchorPosition == 18 );

			SelManager.selectRange(22,22);
			sendKeyboardGesture( SHIFT_HOME );
			assertTrue( "Shift-Home changed removal behavior within TCY text",
						SelManager.activePosition == 8 &&
						SelManager.anchorPosition == 22 );
		}


/*********** SHIFT-END TESTS ************************************************************************/

		// Test the basic functionality and undo/redo

   		public function ShiftEndGeneralTest():void
		{
			// Test Generic Functionality
			loadTestFile( "simple.xml" );

			SelManager.selectRange(342,342);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End failed to select to line end",
						 SelManager.anchorPosition == 342 );
			assertTrue( "Shift-End failed to move the correct line end",
						 SelManager.textFlow.flowComposer.findLineAtPosition(342) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "Shift-End failed to move to line end",
						 elem is SpanElement );

			SelManager.selectRange(2009,2009);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End failed to select to line end",
						 SelManager.anchorPosition == 2009 );
			assertTrue( "Shift-End failed to move the correct line end",
						 SelManager.textFlow.flowComposer.findLineAtPosition(2009) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "Shift-End failed to move to line end",
						 elem is SpanElement );
		}

		public function ShiftEndLocationTest():void
		{
			loadTestFile( "simple.xml" );

			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(959,959);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(606,606);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(608,608);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End failed to select to line end from image sandwich",
						 SelManager.anchorPosition == 608 );
			assertTrue( "Shift-End failed to move the correct line end from image sandwich",
						 SelManager.textFlow.flowComposer.findLineAtPosition(608) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "Shift-End failed to move to line end from image sandwich",
						 elem is SpanElement );

			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End failed from hyphenated word",
						 SelManager.anchorPosition == 608 );
			assertTrue( "Shift-End failed to move the correct line end from hyphenated word",
						 SelManager.textFlow.flowComposer.findLineAtPosition(608) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "Shift-End failed to move to line end from hyphenated word",
						 elem is SpanElement );

			SelManager.selectRange(25,25);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End failed to select to line end from hyphenated word",
						 SelManager.anchorPosition == 25 );
			assertTrue( "Shift-End failed to move the correct line end from hyphenated word",
						 SelManager.textFlow.flowComposer.findLineAtPosition(25) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "Shift-End failed to move to line end from hyphenated word",
						 elem is SpanElement );

			SelManager.selectRange(957,957);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End failed to select to line end from paragraph end",
						 SelManager.anchorPosition == 957 );
			assertTrue( "Shift-End failed to move the correct line end when executed twice",
						 SelManager.textFlow.flowComposer.findLineAtPosition(957) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "Shift-End failed to move to line end when executed twice",
						 elem is SpanElement );

			SelManager.selectRange(1741,1762);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End failed to extend selection to line end",
						 SelManager.anchorPosition == 1741 );
			assertTrue( "Shift-End failed to move the correct line end from selection to line end",
						 SelManager.textFlow.flowComposer.findLineAtPosition(1762) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "Shift-End failed to move to line end from selection to line end",
						 elem is SpanElement );
		}

		public function ShiftEndLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(22,22);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End failed in Right to Left text",
						SelManager.anchorPosition == 22 );
			assertTrue( "Shift-End failed to select the correct line end from selection in Right to Left text",
						 SelManager.textFlow.flowComposer.findLineAtPosition(22) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "Shift-End failed to select to line end from selection in Right to Left text",
						 elem is SpanElement );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End failed to select through a bidi word",
						SelManager.anchorPosition == 85 );
			assertTrue( "Shift-End failed to select the correct line end from selection within a bidi word",
						 SelManager.textFlow.flowComposer.findLineAtPosition(85) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "Shift-End failed to select to line end from selection within a bidi word",
						 elem is SpanElement );

			SelManager.selectRange(77,77);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End changed selection behavior within a bidi word",
						SelManager.anchorPosition == 77 );
			assertTrue( "Shift-End failed to select the correct line end from selection within a bidi word",
						 SelManager.textFlow.flowComposer.findLineAtPosition(77) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "Shift-End failed to select to line end from selection within a bidi word",
						 elem is SpanElement );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End changed selection behavior within right to left text",
						SelManager.anchorPosition == 261 );
			assertTrue( "Shift-End failed to select the correct line end from selection within right to left text",
						 SelManager.textFlow.flowComposer.findLineAtPosition(261) ==
						 SelManager.textFlow.flowComposer.findLineAtPosition(SelManager.activePosition) );
			elem = SelManager.textFlow.findLeaf(SelManager.activePosition);
			assertTrue( "Shift-End failed to select to line end from selection within right to left text",
						 elem is SpanElement );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End changed removal behavior within TCY text",
						SelManager.activePosition == 27 &&
						SelManager.anchorPosition == 18 );

			SelManager.selectRange(22,22);
			sendKeyboardGesture( SHIFT_END );
			assertTrue( "Shift-End changed removal behavior within TCY text",
						SelManager.activePosition == 27 &&
						SelManager.anchorPosition == 22 );
		}

/*********** PG_UP TESTS ***********************************************************************/

		// Test the basic functionality and undo/redo
   		public function PgUpGeneralTest():void
		{
			// Test Generic Functionality
			loadTestFile( "simple.xml" );
			SelManager.selectRange(0,2155);
			var plainTextExporter:ITextExporter = TextConverter.getExporter(TextConverter.PLAIN_TEXT_FORMAT);
			var tempText:String; // = plainTextExporter.export( SelManager.createTextScrap().textFlow, ConversionType.STRING_TYPE ) as String;
			SelManager.selectRange(2155,2155);
			SelManager.insertText(tempText);
			SelManager.insertText(tempText);
			SelManager.flushPendingOperations();

			SelManager.selectRange(6067,6067);
			sendKeyboardGesture( PG_UP );
			assertTrue( "PgUp failed to select 7/8 page up",
						 SelManager.activePosition == 3052 &&
						 SelManager.anchorPosition == 3052 );

			SelManager.selectRange(1314,1314);
			sendKeyboardGesture( PG_UP );
			assertTrue( "PgUp failed to select to top line",
						 SelManager.activePosition == 72 &&
						 SelManager.anchorPosition == 72 );
		}

		public function PgUpLocationTest():void
		{
			loadTestFile( "simple.xml" );
			SelManager.selectRange(0,2155);
			var plainTextExporter:ITextExporter = TextConverter.getExporter(TextConverter.PLAIN_TEXT_FORMAT);
			var tempText:String; // = plainTextExporter.export( SelManager.createTextScrap().textFlow, ConversionType.STRING_TYPE ) as String;
			SelManager.selectRange(2155,2155);
			SelManager.insertText(tempText);
			SelManager.insertText(tempText);
			SelManager.flushPendingOperations();

			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(959,959);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(606,606);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(608,608);
			sendKeyboardGesture( PG_UP );
			assertTrue( "PageUp failed to move up from image sandwich",
						 SelManager.activePosition == 36 &&
						 SelManager.anchorPosition == 36 );

			SelManager.selectRange(6183,6183);
			sendKeyboardGesture( PG_UP );
			assertTrue( "PageUp failed to move up from hyphenated word",
						 SelManager.activePosition == 2724 &&
						 SelManager.anchorPosition == 2724 );
			sendKeyboardGesture( PG_UP );
			assertTrue( "PageUp failed when executed twice",
						 SelManager.activePosition == 1855 &&
						 SelManager.anchorPosition == 1855 );

			SelManager.selectRange(957,957);
			sendKeyboardGesture( PG_UP );
			assertTrue( "PageUp failed to move up from paragraph end",
						 SelManager.activePosition == 122 &&
						 SelManager.anchorPosition == 122 );

			SelManager.selectRange(4316,1346);
			sendKeyboardGesture( PG_UP );
			assertTrue( "PageUp failed to move up from line beginning",
						 SelManager.activePosition == 835 &&
						 SelManager.anchorPosition == 835 );
		}

		public function PgUpLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(73,73);
			sendKeyboardGesture( PG_UP );
			assertTrue( "PageUp failed in Right to Left Arabic text",
						SelManager.activePosition == 21 &&
						SelManager.anchorPosition == 21 );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( PG_UP );
			assertTrue( "PageUp failed to move through a bidi word",
						SelManager.activePosition == 33 &&
						SelManager.anchorPosition == 33 );

			SelManager.selectRange(77,77);
			sendKeyboardGesture( PG_UP );
			assertTrue( "PageUp changed movement behavior within a bidi word",
						SelManager.activePosition == 25 &&
						SelManager.anchorPosition == 25 );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( PG_UP );

			assertTrue( "PageUp changed movement behavior within right to left text",
						SelManager.activePosition == 51 &&
						SelManager.anchorPosition == 51 );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( PG_UP );
			assertTrue( "PageUp changed removal behavior within TCY text",
						SelManager.activePosition == 1 &&
						SelManager.anchorPosition == 1 );

			SelManager.selectRange(22,22);
			sendKeyboardGesture( PG_UP );
			assertTrue( "PageUp changed removal behavior within TCY text",
						SelManager.activePosition == 1 &&
						SelManager.anchorPosition == 1 );
		}

/*********** SHIFT_PG_UP TESTS ***********************************************************************/

		// Test the basic functionality and undo/redo
   		public function ShiftPgUpGeneralTest():void
		{
			// Test Generic Functionality
			loadTestFile( "simple.xml" );
			SelManager.selectRange(0,2155);
			var plainTextExporter:ITextExporter = TextConverter.getExporter(TextConverter.PLAIN_TEXT_FORMAT);
			var tempText:String; // = plainTextExporter.export( SelManager.createTextScrap().textFlow, ConversionType.STRING_TYPE ) as String;
			SelManager.selectRange(2155,2155);
			SelManager.insertText(tempText);
			SelManager.insertText(tempText);
			SelManager.flushPendingOperations();

			SelManager.selectRange(6067,6067);
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp failed to select 7/8 page up",
						 SelManager.activePosition == 3052 &&
						 SelManager.anchorPosition == 6067 );

			SelManager.selectRange(1314,1314);
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp failed to select to top line",
						 SelManager.activePosition == 72 &&
						 SelManager.anchorPosition == 1314 );
		}

		public function ShiftPageUpLocationTest():void
		{
			loadTestFile( "simple.xml" );
			SelManager.selectRange(0,2155);
			var plainTextExporter:ITextExporter = TextConverter.getExporter(TextConverter.PLAIN_TEXT_FORMAT);
			var tempText:String; // = plainTextExporter.export( SelManager.createTextScrap().textFlow, ConversionType.STRING_TYPE ) as String;
			SelManager.selectRange(2155,2155);
			SelManager.insertText(tempText);
			SelManager.insertText(tempText);
			SelManager.flushPendingOperations();

			SelManager.selectRange(20,20);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(959,959);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 60);

			SelManager.selectRange(606,606);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 40);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/gremlin.jpg"), 60, 50);

			SelManager.selectRange(608,608);
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp failed to move up from image sandwich",
						 SelManager.activePosition == 36 &&
						 SelManager.anchorPosition == 608 );

			SelManager.selectRange(6183,6183);
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp failed to move up from hyphenated word",
						 SelManager.activePosition == 2724 &&
						 SelManager.anchorPosition == 6183 );
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp failed when executed twice",
						 SelManager.activePosition == 1855 &&
						 SelManager.anchorPosition == 6183 );

			SelManager.selectRange(957,957);
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp failed to move up from paragraph end",
						 SelManager.activePosition == 122 &&
						 SelManager.anchorPosition == 957 );

			SelManager.selectRange(4316,1346);
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp failed to move up from line beginning",
						 SelManager.activePosition == 835 &&
						 SelManager.anchorPosition == 4316 );
		}

		public function ShiftPageUpLanguageTest():void
		{
			setUpLanguageTest();

			SelManager.selectRange(73,73);
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp failed in Right to Left Arabic text",
						SelManager.activePosition == 21 &&
						SelManager.anchorPosition == 73 );

			SelManager.selectRange(85,85);
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp failed to move through a bidi word",
						SelManager.activePosition == 33 &&
						SelManager.anchorPosition == 85 );

			SelManager.selectRange(77,77);
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp changed movement behavior within a bidi word",
						SelManager.activePosition == 25 &&
						SelManager.anchorPosition == 77 );

			SelManager.selectRange(261,261);
			sendKeyboardGesture( SHIFT_PG_UP );

			assertTrue( "Shift-PageUp changed movement behavior within right to left text",
						SelManager.activePosition == 51 &&
						SelManager.anchorPosition == 261 );

			setUpTCYTest();

			// TCY Tests
			SelManager.selectRange(18,18);
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp changed removal behavior within TCY text",
						SelManager.activePosition == 1 &&
						SelManager.anchorPosition == 18 );

			SelManager.selectRange(22,22);
			sendKeyboardGesture( SHIFT_PG_UP );
			assertTrue( "Shift-PageUp changed removal behavior within TCY text",
						SelManager.activePosition == 1 &&
						SelManager.anchorPosition == 22 );
		}

/*********** OTHER TESTS ********************************************************************************/

		// Tests keyboard navigation on an overflowed non-scrolling container
		public function overflowNavigationTest():void
		{
			loadTestFile("simple.xml");
			TestFrame.verticalScrollPolicy = ScrollPolicy.OFF;
			TestFrame.horizontalScrollPolicy = ScrollPolicy.OFF;
			SelManager.selectAll();
			var scrap:TextScrap = TextScrap.createTextScrap(SelManager.getSelectionState());
			SelManager.pasteTextScrap(scrap);
			SelManager.pasteTextScrap(scrap);
			SelManager.pasteTextScrap(scrap);
			SelManager.pasteTextScrap(scrap);

			try
			{
				SelManager.selectRange(3500,3500);
				while ( SelManager.activePosition < 8000 )
					sendKeyboardGesture( DOWN );

				while ( SelManager.activePosition > 3500 )
					sendKeyboardGesture( UP );

				while ( SelManager.activePosition < 8000 )
					sendKeyboardGesture( DOWN );

				while ( SelManager.activePosition > 3500 )
					sendKeyboardGesture( LEFT );
			}
			catch ( e:Error )
			{
				fail( "Error thrown when navigating past the end of an overflowed non-scrolling container" );
			}
		}

		// Tests that all arrow navigation keys work from any place in the text
		public function bidiNavigationTest():void
		{
			loadTestFile("school.xml");
			var key:int;

			TestFrame.flowComposer.updateAllControllers();

			try
			{
				for ( var type:int = 1; type <= 4; type++ )
				{
					switch ( type )
					{
						case 1:
							key = UP; break;
						case 2:
							key = DOWN; break;
						case 3:
							key = LEFT; break;
						case 4:
							key = RIGHT; break;
					}

					for ( var loc:int = 0; loc < SelManager.textFlow.textLength; loc++ )
					{
						SelManager.selectRange(loc,loc);

						sendKeyboardGesture( key );
					}
				}
			}
			catch ( e:Error )
			{
				fail( "Error thrown when using arrow keys to navigate text" );
			}
		}
		
		public function oversetText_2754698():void
		{
			// When text is overset, because it can't fit (exceeds the width) it can go overset in a scrollable container. Test to make sure this doesn't crash.
			importContent('<TextFlow columnCount="1" columnWidth="150" fontSize="12" paddingLeft="4" paddingTop="4" whiteSpaceCollapse="preserve" version="2.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span></span></p><p><span>Big</span></p><p><span>BEF</span></p><list listStylePosition="inside" listStyleType="upperAlpha" paddingLeft="36" paddingRight="36"><listMarkerFormat><ListMarkerFormat color="#ff0000" fontSize="300" paddingLeft="40" paddingRight="90" paragraphEndIndent="4"/></listMarkerFormat><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>cou</span></p><p><span>BEF</span></p><list listStylePosition="outside" listStyleType="decimal" paddingLeft="24"><listMarkerFormat><ListMarkerFormat counterIncrement="ordered -1"/></listMarkerFormat><li><listMarkerFormat><ListMarkerFormat counterIncrement="ordered 0" counterReset="ordered 10"/></listMarkerFormat><p><span>ite</span></p></li><li><p><span>ano</span></p></li><li><p><span></span></p></li><li><p><span></span></p></li><li><p><span></span></p></li><li><p><span></span></p></li><li><p><span></span></p></li><li><p><span></span></p></li><li><p><span></span></p></li><li><p><span></span></p></li></list><list listStyleType="decimal" paddingLeft="96" paddingRight="24"><listMarkerFormat><ListMarkerFormat afterContent="YY" beforeContent="XX" counterIncrement="ordered -1" fontSize="16"/></listMarkerFormat><li><p><span>con</span></p></li><li><p><span>ano</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Suf</span></p><p><span>BEF</span></p><list listStyleType="upperAlpha" paddingLeft="36" paddingRight="36"><listMarkerFormat><ListMarkerFormat color="#ff0000" counterReset="ordered 2" fontSize="20" paragraphEndIndent="4" suffix="auto"/></listMarkerFormat><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li></list><list listStyleType="upperAlpha" paddingLeft="36" paddingRight="36"><listMarkerFormat><ListMarkerFormat color="#ff0000" counterReset="ordered 2" fontSize="20" paragraphEndIndent="4" suffix="none"/></listMarkerFormat><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li></list><list listStyleType="devanagari" paddingLeft="36" paddingRight="36"><listMarkerFormat><ListMarkerFormat color="#cc0000" counterIncrement="ordered 2" fontSize="10" paragraphEndIndent="4" suffix="auto"/></listMarkerFormat><li><p><span>dev</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li></list><list listStyleType="devanagari" paddingLeft="36" paddingRight="36"><listMarkerFormat><ListMarkerFormat color="#cc0000" counterIncrement="ordered 2" fontSize="10" paragraphEndIndent="4" suffix="none"/></listMarkerFormat><li><p><span>dev</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Cus</span></p><p><span>BEF</span></p><list listStyleType="disc" paddingLeft="96" paddingRight="24"><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="Section " content="counters(ordered,&quot;  *&quot;,upperRoman)" fontSize="16"/></listMarkerFormat><li><p><span>con</span></p></li><li><p><span>ano</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Div</span></p><p><span>BEF</span></p><list listStylePosition="outside" listStyleType="decimal" paddingLeft="44"><li><div><p><span>div</span></p></div><div><p><span>div</span></p></div><div><p><span>div</span></p></div></li><li><div><p><span>div</span></p></div></li><li><div><p><span>div</span></p></div></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Par</span></p><p><span>BEF</span></p><list listStylePosition="outside" listStyleType="decimal" paddingLeft="44"><li><p><span>par</span></p><p><span>par</span></p><p><span>par</span></p></li><li><p><span>par</span></p></li><li><p><span>par</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Ord</span></p><p><span>BEF</span></p><list counterIncrement="ordered 10" counterReset="ordered 2" listStyleType="disc" paddingLeft="24" paddingRight="24"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Neg</span></p><p><span>BEF</span></p><list listStyleType="upperAlpha" paddingLeft="96" paddingRight="24"><listMarkerFormat><ListMarkerFormat afterContent="YY" beforeContent="XX" counterIncrement="ordered -1" fontSize="16"/></listMarkerFormat><li><p><span>con</span></p></li><li><p><span>ano</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Lis</span></p><p><span>BEF</span></p><list listStyleType="upperRoman" paddingLeft="96" paddingRight="24"><listMarkerFormat><ListMarkerFormat counterIncrement="ordered -1" fontSize="16"/></listMarkerFormat><li><p><span>fir</span></p></li><li><p><span>sec</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Bot</span></p><p><span>BEF</span></p><list listStyleType="upperAlpha" paddingLeft="36" paddingRight="36"><listMarkerFormat><ListMarkerFormat counterIncrement="ordered -1" fontSize="20"/></listMarkerFormat><li><listMarkerFormat><ListMarkerFormat counterReset="ordered -1" fontSize="20"/></listMarkerFormat><p><span>fir</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Spa</span></p><p><span>BEF</span></p><list listStyleType="upperAlpha" paddingLeft="96" paddingRight="24"><listMarkerFormat><ListMarkerFormat afterContent=" YY " beforeContent="  XX  " counterIncrement="ordered -1" fontSize="16"/></listMarkerFormat><li><p><span>con</span></p></li><li><p><span>ano</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span> Fi</span></p><p><span>BEF</span></p><list listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>nes</span></p><list listStyleType="upperAlpha" paddingLeft="24" paddingRight="24"><li><p><span>nes</span></p><list listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>nes</span></p><list listStyleType="lowerAlpha" paddingLeft="24" paddingRight="24"><li><p><span>nes</span></p><list listStyleType="cjkEarthlyBranch" paddingLeft="24" paddingRight="24"><li><p><span>nes</span></p></li><li><p><span>aga</span></p></li><li><p><span>aga</span></p></li></list></li><li><p><span>aga</span></p></li><li><p><span>aga</span></p></li></list></li><li><p><span>aga</span></p></li><li><p><span>and</span></p></li></list></li><li><p><span>nes</span></p></li><li><p><span>and</span></p></li><li><p><span>and</span></p></li><li><p><span>and</span></p></li></list></li><li><p><span>ano</span></p></li><li><p><span>and</span></p></li><li><p><span>and</span></p></li><li><p><span>and</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Emp</span></p><p><span>BEF</span></p><list listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span></span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Mix</span></p><p><span>BEF</span></p><list listStylePosition="inside" listStyleType="upperAlpha"><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="Chapter " content="counters(ordered,&quot;.&quot;)" fontSize="14"/></listMarkerFormat><li><p><span>Fir</span></p></li><li><p><span>Sec</span></p></li><li><p><span>Thi</span></p><list><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="Chapter " content="counters(ordered,&quot;.&quot;,upperRoman)" fontSize="12"/></listMarkerFormat><li><p><span>sec</span></p></li><li><p><span>ano</span></p></li></list></li></list><p><span>AFT</span></p><p><span></span></p><p><span>cou</span></p><p><span>BEF</span></p><list listStylePosition="inside" listStyleType="decimal"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li><li><listMarkerFormat><ListMarkerFormat counterReset="ordered 0"/></listMarkerFormat><p><span>res</span></p></li><li><p><span>and</span></p></li><li><listMarkerFormat><ListMarkerFormat counterReset="ordered 3"/></listMarkerFormat><p><span>res</span></p></li><li><p><span>ano</span></p></li><li><listMarkerFormat><ListMarkerFormat content="counter(ordered,upperRoman)"/></listMarkerFormat><p><span>upp</span></p></li><li><listMarkerFormat><ListMarkerFormat content="counter(ordered,lowerAlpha)" counterReset="ordered 3"/></listMarkerFormat><p><span>ano</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>dif</span></p><p><span>BEF</span></p><list listStylePosition="outside" listStyleType="upperRoman" paddingLeft="36" paddingRight="24"><listMarkerFormat><ListMarkerFormat counterIncrement="ordered -1" counterReset="ordered 5" fontSize="18"/></listMarkerFormat><li><listMarkerFormat><ListMarkerFormat counterIncrement="ordered -2" counterReset="ordered 10" fontSize="18"/></listMarkerFormat><p><span>cou</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li></list><p><span>AFT</span></p><p><span></span></p><p><span>con</span></p><p><span>BEF</span></p><list listStylePosition="inside" listStyleType="decimal"><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="Chapter " content="counters(ordered,&quot;.&quot;,upperRoman)" fontSize="14"/></listMarkerFormat><li><p><span>Fir</span></p><list><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="Section " content="counters(ordered,&quot;.&quot;,upperRoman)" fontSize="12"/></listMarkerFormat><li><p><span>sec</span></p></li><li><p><span>ano</span></p></li></list></li><li><p><span>Sec</span></p><list><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="Section " content="counters(ordered)" fontSize="12"/></listMarkerFormat><li><p><span>sec</span></p></li><li><p><span>ano</span></p></li></list></li><li><p><span>Thi</span></p><list><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="Section " content="counter(ordered)" fontSize="12"/></listMarkerFormat><li><p><span>sec</span></p></li><li><p><span>ano</span></p></li></list></li></list><p><span>AFT</span></p><p><span></span></p><p><span>Tes</span></p></TextFlow>');
			SelManager.selectRange(0,0);
			TestFrame.flowComposer.updateAllControllers();
			sendKeyboardGesture(CTRL_END);		// select to end of flow
			sendKeyboardGesture(UP);			// go to previous line
		}
		
		//Tab key and Shift Tab key on list element to promote and demote the list
		public function TabPromoteDemoteListTest( ):void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.setFocus();
			SelManager.selectRange(0,0);
			var list:ListElement = new ListElement()
			list.listStyleType = "decimal"; 
			list.listStylePosition = "inside";
			list.paddingLeft = "0";
			var item1:ListItemElement = new ListItemElement();
			var p1:ParagraphElement = new ParagraphElement();
			var s1:SpanElement = new SpanElement();
			s1.text = " First item";
			p1.addChild(s1);
			item1.addChild(p1);
			var item2:ListItemElement = new ListItemElement();
			var p2:ParagraphElement = new ParagraphElement();
			var s2:SpanElement = new SpanElement();
			s2.text = " Second item";
			p2.addChild(s2);
			item2.addChild(p2);
			var item3:ListItemElement = new ListItemElement();
			var p3:ParagraphElement = new ParagraphElement();
			var s3:SpanElement = new SpanElement();
			s3.text = " Third item";
			p3.addChild(s3);
			item3.addChild(p3);
			list.addChild(item1);
			list.addChild(item2);
			list.addChild(item3);
			SelManager.textFlow.addChild(list); 
			SelManager.textFlow.flowComposer.updateAllControllers();
			
			//get all three list items start position
			var firstItemStart:int = item1.getAbsoluteStart();
			var secondItemStart:int = item2.getAbsoluteStart();
			var thirdItemStart:int = item3.getAbsoluteStart();
			var listStart:int = firstItemStart;
			var listBeforeTab:int = SelManager.textFlow.flowComposer.findLineAtPosition(listStart).x;
			
			//first senario, Tab and Shift Tab first list item will promote/demote whole list
			SelManager.selectRange(listStart, listStart);
			sendKeyboardGesture( TAB );
			//check LIST position After dispatch tab event, all items of the list should move a Tab space
			var listAfterTab:int = SelManager.textFlow.flowComposer.findLineAtPosition(listStart).x;
			assertTrue ("Tab key didn't promote the list correctly", listAfterTab > listBeforeTab);
			SelManager.selectRange(listStart, listStart);
			sendKeyboardGesture (SHIFT_TAB);
			var listAfterShiftTab:int = SelManager.textFlow.flowComposer.findLineAtPosition(listStart).x;
			assertTrue ("SHIFT Tab key didn't demote the list correctly", listBeforeTab == listAfterShiftTab);
			
			//second scenario, Tab and Shift Tab second list item will only promote/demote the second list item
			SelManager.selectRange(secondItemStart, secondItemStart);
			sendKeyboardGesture( TAB );
			//check first, second, third LIST Item position After dispatch tab event
			var firstItemAfterTab:int = SelManager.textFlow.flowComposer.findLineAtPosition(firstItemStart).x;
			var secondItemAfterTab:int = SelManager.textFlow.flowComposer.findLineAtPosition(secondItemStart).x;
			var thirdItemAfterTab:int = SelManager.textFlow.flowComposer.findLineAtPosition(thirdItemStart).x;
			assertTrue ("Tab key didn't promote the list correctly", secondItemAfterTab > listBeforeTab && thirdItemAfterTab == listBeforeTab
				&& firstItemAfterTab == listBeforeTab);
			SelManager.selectRange(secondItemStart, secondItemStart);
			sendKeyboardGesture (SHIFT_TAB);
			//check second LIST Item position After dispatch SHIFT TAB event
			var secondItemAfterShiftTab:int = SelManager.textFlow.flowComposer.findLineAtPosition(secondItemStart).x;
			assertTrue ("SHIFT Tab key didn't demote the list correctly",  secondItemAfterShiftTab == listBeforeTab);
			
			//third scenario, Tab and Shift Tab third list item will only promote/demote the third list item
			SelManager.selectRange(thirdItemStart, thirdItemStart);
			sendKeyboardGesture( TAB );
			//check first,second, third LIST Item position After dispatch tab event
			firstItemAfterTab = SelManager.textFlow.flowComposer.findLineAtPosition(firstItemStart).x;
			secondItemAfterTab = SelManager.textFlow.flowComposer.findLineAtPosition(secondItemStart).x;
			thirdItemAfterTab = SelManager.textFlow.flowComposer.findLineAtPosition(thirdItemStart).x;
			assertTrue ("Tab key didn't promote the list correctly", thirdItemAfterTab > listBeforeTab && secondItemAfterTab == listBeforeTab
				&& firstItemAfterTab == listBeforeTab);
			SelManager.selectRange(thirdItemStart, thirdItemStart);
			sendKeyboardGesture (SHIFT_TAB);
			//check second LIST Item position After dispatch SHIFT TAB event
			var thirdItemAfterShiftTab:int = SelManager.textFlow.flowComposer.findLineAtPosition(thirdItemStart).x;
			assertTrue ("SHIFT Tab key didn't demote the list correctly",  thirdItemAfterShiftTab == listBeforeTab);
		}
		
		// mjzhang : Bug# 2821844 Text controls make bad assumptions with Ctrl Backspace
		public function CtrlBackspaceTest_Bug2821844():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			SelManager.selectAll();
			SelManager.deleteText();
			
			var span:SpanElement = new SpanElement();
			span.text = "sad, ";
			var paragraph:ParagraphElement = new ParagraphElement();
			paragraph.addChild(span);
			SelManager.textFlow.addChild(paragraph);
			
			SelManager.selectRange(span.text.length + 1, span.text.length + 1);
			SelManager.textFlow.flowComposer.updateAllControllers();
			
			sendKeyboardGesture(CTRL_BACKSPACE);
			
			assertTrue("Text length should be 3.", span.text.length == 3 );
		}
	}
}
