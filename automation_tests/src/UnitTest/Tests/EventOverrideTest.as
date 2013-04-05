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

	import flash.events.*;
	import flash.ui.KeyLocation;

	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.TextFlow;
	import flashx.undo.UndoManager;

	public class EventOverrideTest extends VellumTestCase
	{
		public function EventOverrideTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			if ( TestData.eventOverride )
   			{
   				TestID = TestID + ":" + TestData.eventOverride;
   			}

   			// Note: These must correspond to a Watson product area (case-sensitive)
   			metaData.productArea = "Editing";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = EventOverrideTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

   		public override function setUp():void
   		{
   			/*if ( TestData.eventOverride )
   			{
   				TextFlow.defaultConfiguration.manageEventListeners = false;
   			}*/

   			super.setUp();

   			if ( TestData.overrideEditManager == "true" )
   			{
	   			var testManager:EditManager = new TestEditManager(new UndoManager());
	   			SelManager.textFlow.interactionManager = testManager;
	   			SelManager = testManager;
	   			SelManager.selectRange(0,0);
	   		}
   		}

   		public override function tearDown():void
   		{
   			/*if ( TestData.eventOverride )
   			{
	   			TextFlow.defaultConfiguration.manageEventListeners = true;
	   			// Make sure we leave without a broken TextFlow
				loadTestFile("empty.xml");
   			}*/

   			if ( TestData.overrideEditManager == "true" )
   			{
	   			var newManager:EditManager = new EditManager(new UndoManager());
	   			SelManager.textFlow.interactionManager = newManager;
	   			SelManager = newManager;
	   		}
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

/******* Framework for event override tests (Not using derived editmanager ***********************/
/** Removing for expected ARB-related updates - probably to be removed permanently
 *
   		private function eventFromText( textID:String, addListener:Boolean, removeListener:Boolean = false ):Event
   		{
			var outEvent:Event;

			switch ( textID )
			{
				case "MOUSE_DOWN":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( MouseEvent.MOUSE_DOWN, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( MouseEvent.MOUSE_DOWN, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new MouseEvent( MouseEvent.MOUSE_DOWN, true, false, 0, 0 );
						return outEvent;
					}
					break;
				case "MOUSE_OVER":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( MouseEvent.MOUSE_OVER, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( MouseEvent.MOUSE_OVER, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new MouseEvent( MouseEvent.MOUSE_OVER, true, false, 0, 0 );
						return outEvent;
					}
					break;
				case "MOUSE_OUT":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( MouseEvent.MOUSE_OUT, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( MouseEvent.MOUSE_OUT, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new MouseEvent( MouseEvent.MOUSE_OUT, true, false, 0, 0 );
						return outEvent;
					}
					break;
				case "MOUSE_WHEEL":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( MouseEvent.MOUSE_WHEEL, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( MouseEvent.MOUSE_WHEEL, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new MouseEvent( MouseEvent.MOUSE_WHEEL, true, false, 0, 0 );
						return outEvent;
					}
					break;
				case "DOUBLE_CLICK":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( MouseEvent.DOUBLE_CLICK, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( MouseEvent.DOUBLE_CLICK, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new MouseEvent( MouseEvent.DOUBLE_CLICK, true, false, 0, 0 );
						return outEvent;
					}
					break;
				case "KEY_DOWN":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( KeyboardEvent.KEY_DOWN, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( KeyboardEvent.KEY_DOWN, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new KeyboardEvent( KeyboardEvent.KEY_DOWN, true, false,
											 8, 8, KeyLocation.STANDARD, true, false, false);
						return outEvent;
					}
					break;
				case "FOCUS_IN":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( FocusEvent.FOCUS_IN, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( FocusEvent.FOCUS_IN, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new FocusEvent( FocusEvent.FOCUS_IN );
						return outEvent;
					}
					break;
				case "FOCUS_OUT":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( FocusEvent.FOCUS_OUT, eventHandler );
					}
					else
					if (addListener)
					{
						SelManager.textFlow.addEventListener( FocusEvent.FOCUS_OUT, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new FocusEvent( FocusEvent.FOCUS_OUT );
						return outEvent;
					}
					break;
				case "TEXT_INPUT":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( TextEvent.TEXT_INPUT, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( TextEvent.TEXT_INPUT, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new TextEvent( TextEvent.TEXT_INPUT, false, true, "WONTSEEME" );
						return outEvent;
					}
					break;
				case "ACTIVATE":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( Event.ACTIVATE, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( Event.ACTIVATE, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new Event( Event.ACTIVATE );
						return outEvent;
					}
					break;
				case "DEACTIVATE":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( Event.DEACTIVATE, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( Event.DEACTIVATE, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new Event( Event.DEACTIVATE );
						return outEvent;
					}
					break;
				case "MENU_SELECT":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( ContextMenuEvent.MENU_SELECT, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( ContextMenuEvent.MENU_SELECT, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new ContextMenuEvent( ContextMenuEvent.MENU_SELECT );
						return outEvent;
					}
					break;
				case "SELECT_ALL":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( Event.SELECT_ALL, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( Event.SELECT_ALL, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new Event( Event.SELECT_ALL );
						return outEvent;
					}
					break;
				case "COPY":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( Event.COPY, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( Event.COPY, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new Event( Event.COPY );
						return outEvent;
					}
					break;
				case "CUT":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( Event.CUT, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( Event.CUT, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new Event( Event.CUT );
						return outEvent;
					}
					break;
				case "PASTE":
					if ( removeListener )
					{
						SelManager.textFlow.removeEventListener( Event.PASTE, eventHandler );
					}
					else if (addListener)
					{
						SelManager.textFlow.addEventListener( Event.PASTE, eventHandler, false, 0, true );
						return null;
					}
					else
					{
						outEvent = new Event( Event.PASTE );
						return outEvent;
					}
					break;
			}

			return null;
   		}

   		// Generic event handler
   		// How can this be made more even specific?
   		private function eventHandler( event:Event ):void
   		{
   			SelManager.insertText("EVENT");
   		}

   		// Generic test case for all event overrides
   		public function testEventOverride():void
   		{
   			SelManager.insertText("StillHere");
   			SelManager.selectRange(9,9);

   			// Add event listener
   			eventFromText( TestData.eventOverride, true );

   			var newEvent:Event = eventFromText( TestData.eventOverride, false );
   			assertTrue( "Test Case Failure: Unable to find event specified in XML",
   						newEvent != null );
   			SelManager.textFlow.dispatchEvent(newEvent);

   			SelManager.flushPendingOperations();
   			assertTrue( TestData.eventOverride + " event was not executed after override",
						getAllText() == "StillHereEVENT" );
			assertTrue( TestData.eventOverride + " event shouldn't change selection",
						SelManager.activePosition == 14 && SelManager.anchorPosition == 14 );

			// Remove event listener
			eventFromText( TestData.eventOverride, false, true );
   		}
*/
/************** TESTS USING DERIVED EDITMANAGER **************************************************/

   		public function keyDownDerivedTest():void
   		{
   			SelManager.insertText("StillHere");
   			SelManager.selectRange(9,9);

   			// Send a Ctrl-Backspace
   			var kEvent:KeyboardEvent = new KeyboardEvent( KeyboardEvent.KEY_DOWN,
				true, false, 8, 8, KeyLocation.STANDARD, true, false, false);
			TestFrame.container["dispatchEvent"](kEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Keyboard event executed normally when overridden",
						getText(0,9) == "StillHere" );

			assertTrue( "Keyboard event override was not executed",
						getAllText() == "StillHereKEYDOWN" );
   		}

   		public function mouseDownDerivedTest():void
   		{
   			var kEvent:MouseEvent = new MouseEvent( MouseEvent.MOUSE_DOWN, true, false, 0, 0 );
			TestFrame.container["dispatchEvent"](kEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Mouse Down event override was not executed",
						getAllText() == "MOUSEDOWN" );
   		}

   		public function mouseMoveDerivedTest():void
   		{
   			(SelManager as TestEditManager).mouseMoved = false;
   			var kEvent:MouseEvent = new MouseEvent( MouseEvent.MOUSE_DOWN, true, false, 0, 0 );
			TestFrame.container["dispatchEvent"](kEvent);
   			var mEvent:MouseEvent = new MouseEvent( MouseEvent.MOUSE_MOVE, true, false,
   											 20, 20 );
			TestFrame.container["dispatchEvent"](mEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Mouse Move event override was not executed",
						getAllText() == "MOUSEDOWNMOUSEMOVE" );
   		}

   		public function textEventDerivedTest():void
   		{
   			// Send 'a' string
   			var kEvent:TextEvent = new TextEvent( TextEvent.TEXT_INPUT, false, false, "a" );
			TestFrame.container["dispatchEvent"](kEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Text Event override was not executed",
						getAllText() == "TEXTEVENT" );
   		}

   		public function focusInDerivedTest():void
   		{
   			var kEvent:FocusEvent = new FocusEvent( FocusEvent.FOCUS_IN );
			TestFrame.container["dispatchEvent"](kEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Focus In override was not executed",
						getAllText() == "FOCUSIN" );
   		}

   		public function focusOutDerivedTest():void
   		{
   			var kEvent:FocusEvent = new FocusEvent( FocusEvent.FOCUS_OUT );
			TestFrame.container["dispatchEvent"](kEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Focus Out override was not executed",
						getAllText() == "FOCUSOUT" );
   		}

   		public function activateDerivedTest():void
   		{
   			var kEvent:Event = new Event( Event.ACTIVATE );
			TestFrame.container["dispatchEvent"](kEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Activate override was not executed",
						getAllText() == "ACTIVATE" );
   		}

   		public function deactivateDerivedTest():void
   		{
   			var kEvent:Event = new Event( Event.DEACTIVATE );
			TestFrame.container["dispatchEvent"](kEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Deactivate override was not executed",
						getAllText() == "DEACTIVATE" );
   		}

   		public function deleteNextDerivedTest():void
   		{
   			(SelManager as TestEditManager).useDefaultKeyDown = true;

   			var kEvent:KeyboardEvent = new KeyboardEvent( KeyboardEvent.KEY_DOWN, true, false, 127, 46 );
			TestFrame.container["dispatchEvent"](kEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Delete Next override was not executed by pressing 'Delete'",
						getAllText() == "DELETENEXT" );

			(SelManager as TestEditManager).useDefaultKeyDown = false;
   		}

   		public function deletePreviousDerivedTest():void
   		{
   			(SelManager as TestEditManager).useDefaultKeyDown = true;

   			var kEvent:KeyboardEvent = new KeyboardEvent( KeyboardEvent.KEY_DOWN, true, false, 8, 8 );
			TestFrame.container["dispatchEvent"](kEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Delete Previous override was not executed by pressing 'Backspace'",
						getAllText() == "DELETEPREVIOUS" );

			(SelManager as TestEditManager).useDefaultKeyDown = false;
   		}

   		public function deleteNextWordDerivedTest():void
   		{
   			(SelManager as TestEditManager).useDefaultKeyDown = true;

   			var kEvent:KeyboardEvent = new KeyboardEvent( KeyboardEvent.KEY_DOWN, true, false, 127, 46, 0, true );
			TestFrame.container["dispatchEvent"](kEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Delete Next override was not executed by pressing 'Ctrl-Delete'",
						getAllText() == "DELETENEXTWORD" );

			(SelManager as TestEditManager).useDefaultKeyDown = false;
   		}

   		public function deletePreviousWordDerivedTest():void
   		{
   			(SelManager as TestEditManager).useDefaultKeyDown = true;

   			var kEvent:KeyboardEvent = new KeyboardEvent( KeyboardEvent.KEY_DOWN, true, false, 8, 8, 0, true );
			TestFrame.container["dispatchEvent"](kEvent);

			SelManager.flushPendingOperations();

			assertTrue( "Delete Previous override was not executed by pressing 'Ctrl-Backspace'",
						getAllText() == "DELETEPREVIOUSWORD" );

			(SelManager as TestEditManager).useDefaultKeyDown = false;
   		}
	}
}

/********Editmanager for overriding events - Internal Helper Class**********************************/

import flashx.textLayout.edit.EditManager;
import flashx.undo.IUndoManager;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.events.FocusEvent;
import flash.events.Event;
import flashx.textLayout.edit.SelectionState;

internal class TestEditManager extends EditManager
{
	public var mouseMoved:Boolean;
	public var useDefaultKeyDown:Boolean;

	public function TestEditManager(undo:IUndoManager = null)
	{
		super(undo);

		useDefaultKeyDown = false;

		// Don't react to this event and ruin a different test
		mouseMoved = true;
	}

	public override function keyDownHandler(event:KeyboardEvent):void
	{
		if ( useDefaultKeyDown == true )
			super.keyDownHandler(event);
		else
			insertText("KEYDOWN");
	}

	public override function mouseDownHandler(event:MouseEvent):void
	{ insertText("MOUSEDOWN"); }

	public override function mouseMoveHandler(event:MouseEvent):void
	{
		// Don't react to this event more than once
		if ( !mouseMoved)
		{
			insertText("MOUSEMOVE");
			mouseMoved = true;
		}
	}

	public override function textInputHandler(event:TextEvent):void
	{ insertText("TEXTEVENT"); }

	public override function focusInHandler(event:FocusEvent):void
	{ insertText("FOCUSIN"); }

	public override function focusOutHandler(event:FocusEvent):void
	{ insertText("FOCUSOUT"); }

	public override function activateHandler(event:Event):void
	{ insertText("ACTIVATE"); }

	public override function deactivateHandler(event:Event):void
	{ insertText("DEACTIVATE"); }

	/***** EDITMANAGER OVERRIDES *****/

	public override function deleteNextCharacter(operationState:SelectionState=null):void
	{ insertText("DELETENEXT"); }

	public override function deletePreviousCharacter(operationState:SelectionState=null):void
	{ insertText("DELETEPREVIOUS"); }

	public override function deleteNextWord(operationState:SelectionState=null):void
	{ insertText("DELETENEXTWORD"); }

	public override function deletePreviousWord(operationState:SelectionState=null):void
	{ insertText("DELETEPREVIOUSWORD"); }

}
