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
    import UnitTest.ExtendedClasses.VellumTestCase;
    import UnitTest.Fixtures.TestConfig;

    import flash.events.*;
    import flash.ui.KeyLocation;

    import flashx.textLayout.edit.EditManager;
    import flashx.undo.UndoManager;

    import org.flexunit.asserts.assertTrue;

    public class EventOverrideTest extends VellumTestCase
    {
        public function EventOverrideTest()
        {
            super("", "EventOverrideTest", TestConfig.getInstance());

            if (TestData.eventOverride)
            {
                TestID = TestID + ":" + TestData.eventOverride;
            }
            metaData = {};
            // Note: These must correspond to a Watson product area (case-sensitive)
            metaData.productArea = "Editing";
        }

        [Before]
        public override function setUpTest():void
        {
            super.setUpTest();

            if (TestData.overrideEditManager == "true")
            {
                var testManager:EditManager = new TestEditManager(new UndoManager());
                SelManager.textFlow.interactionManager = testManager;
                SelManager = testManager;
                SelManager.selectRange(0, 0);
            }
        }

        [After]
        public override function tearDownTest():void
        {
            if (TestData.overrideEditManager == "true")
            {
                var newManager:EditManager = new EditManager(new UndoManager());
                SelManager.textFlow.interactionManager = newManager;
                SelManager = newManager;
            }
        }

        /************** TESTS USING DERIVED EDITMANAGER **************************************************/

        [Test]
        [Ignore]
        public function keyDownDerivedTest():void
        {
            SelManager.insertText("StillHere");
            SelManager.selectRange(9, 9);

            // Send a Ctrl-Backspace
            var kEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN,
                    true, false, 8, 8, KeyLocation.STANDARD, true, false, false);
            TestFrame.container["dispatchEvent"](kEvent);

            SelManager.flushPendingOperations();

            assertTrue("Keyboard event executed normally when overridden",
                    getText(0, 9) == "StillHere");

            assertTrue("Keyboard event override was not executed",
                    getAllText() == "StillHereKEYDOWN");
        }

        [Test]
        [Ignore]
        public function mouseDownDerivedTest():void
        {
            var kEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, 0, 0);
            TestFrame.container["dispatchEvent"](kEvent);

            SelManager.flushPendingOperations();

            assertTrue("Mouse Down event override was not executed",
                    getAllText() == "MOUSEDOWN");
        }

        [Test]
        [Ignore]
        public function mouseMoveDerivedTest():void
        {
            (SelManager as TestEditManager).mouseMoved = false;
            var kEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, 0, 0);
            TestFrame.container["dispatchEvent"](kEvent);
            var mEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE, true, false,
                    20, 20);
            TestFrame.container["dispatchEvent"](mEvent);

            SelManager.flushPendingOperations();

            assertTrue("Mouse Move event override was not executed",
                    getAllText() == "MOUSEDOWNMOUSEMOVE");
        }

        [Test]
        [Ignore]
        public function textEventDerivedTest():void
        {
            // Send 'a' string
            var kEvent:TextEvent = new TextEvent(TextEvent.TEXT_INPUT, false, false, "a");
            TestFrame.container["dispatchEvent"](kEvent);

            SelManager.flushPendingOperations();

            assertTrue("Text Event override was not executed",
                    getAllText() == "TEXTEVENT");
        }

        [Test]
        [Ignore]
        public function focusInDerivedTest():void
        {
            var kEvent:FocusEvent = new FocusEvent(FocusEvent.FOCUS_IN);
            TestFrame.container["dispatchEvent"](kEvent);

            SelManager.flushPendingOperations();

            assertTrue("Focus In override was not executed",
                    getAllText() == "FOCUSIN");
        }

        [Test]
        [Ignore]
        public function focusOutDerivedTest():void
        {
            var kEvent:FocusEvent = new FocusEvent(FocusEvent.FOCUS_OUT);
            TestFrame.container["dispatchEvent"](kEvent);

            SelManager.flushPendingOperations();

            assertTrue("Focus Out override was not executed",
                    getAllText() == "FOCUSOUT");
        }

        [Test]
        [Ignore]
        public function activateDerivedTest():void
        {
            var kEvent:Event = new Event(Event.ACTIVATE);
            TestFrame.container["dispatchEvent"](kEvent);

            SelManager.flushPendingOperations();

            assertTrue("Activate override was not executed",
                    getAllText() == "ACTIVATE");
        }

        [Test]
        [Ignore]
        public function deactivateDerivedTest():void
        {
            var kEvent:Event = new Event(Event.DEACTIVATE);
            TestFrame.container["dispatchEvent"](kEvent);

            SelManager.flushPendingOperations();

            assertTrue("Deactivate override was not executed",
                    getAllText() == "DEACTIVATE");
        }

        [Test]
        [Ignore]
        public function deleteNextDerivedTest():void
        {
            (SelManager as TestEditManager).useDefaultKeyDown = true;

            var kEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 127, 46);
            TestFrame.container["dispatchEvent"](kEvent);

            SelManager.flushPendingOperations();

            assertTrue("Delete Next override was not executed by pressing 'Delete'",
                    getAllText() == "DELETENEXT");

            (SelManager as TestEditManager).useDefaultKeyDown = false;
        }

        [Test]
        [Ignore]
        public function deletePreviousDerivedTest():void
        {
            (SelManager as TestEditManager).useDefaultKeyDown = true;

            var kEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 8, 8);
            TestFrame.container["dispatchEvent"](kEvent);

            SelManager.flushPendingOperations();

            assertTrue("Delete Previous override was not executed by pressing 'Backspace'",
                    getAllText() == "DELETEPREVIOUS");

            (SelManager as TestEditManager).useDefaultKeyDown = false;
        }

        [Test]
        [Ignore]
        public function deleteNextWordDerivedTest():void
        {
            (SelManager as TestEditManager).useDefaultKeyDown = true;

            var kEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 127, 46, 0, true);
            TestFrame.container["dispatchEvent"](kEvent);

            SelManager.flushPendingOperations();

            assertTrue("Delete Next override was not executed by pressing 'Ctrl-Delete'",
                    getAllText() == "DELETENEXTWORD");

            (SelManager as TestEditManager).useDefaultKeyDown = false;
        }

        [Test]
        [Ignore]
        public function deletePreviousWordDerivedTest():void
        {
            (SelManager as TestEditManager).useDefaultKeyDown = true;

            var kEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 8, 8, 0, true);
            TestFrame.container["dispatchEvent"](kEvent);

            SelManager.flushPendingOperations();

            assertTrue("Delete Previous override was not executed by pressing 'Ctrl-Backspace'",
                    getAllText() == "DELETEPREVIOUSWORD");

            (SelManager as TestEditManager).useDefaultKeyDown = false;
        }


        // Returns the string from begIdx through and including endIdx
        private function getText(begIdx:int, endIdx:int):String
        {
            var outString:String = "";

            var tt:String = SelManager.textFlow.getText();

            for (var x:int = begIdx; x < endIdx; x++)
            {
                outString += SelManager.textFlow.getCharAtPosition(x);
            }

            return outString;
        }

        // Returns the text contents of the entire textflow
        private function getAllText():String
        {
            var begIdx:int = SelManager.textFlow.parentRelativeStart;
            var endIdx:int = SelManager.textFlow.parentRelativeEnd - 1;
            var outString:String = "";

            for (var x:int = begIdx; x < endIdx; x++)
            {
                outString += SelManager.textFlow.getCharAtPosition(x);
            }

            return outString;
        }
    }
}

/********Editmanager for overriding events - Internal Helper Class**********************************/

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;

import flashx.textLayout.edit.EditManager;
import flashx.textLayout.edit.SelectionState;
import flashx.undo.IUndoManager;

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
        if (useDefaultKeyDown == true)
            super.keyDownHandler(event);
        else
            insertText("KEYDOWN");
    }

    public override function mouseDownHandler(event:MouseEvent):void
    {
        insertText("MOUSEDOWN");
    }

    public override function mouseMoveHandler(event:MouseEvent):void
    {
        // Don't react to this event more than once
        if (!mouseMoved)
        {
            insertText("MOUSEMOVE");
            mouseMoved = true;
        }
    }

    public override function textInputHandler(event:TextEvent):void
    {
        insertText("TEXTEVENT");
    }

    public override function focusInHandler(event:FocusEvent):void
    {
        insertText("FOCUSIN");
    }

    public override function focusOutHandler(event:FocusEvent):void
    {
        insertText("FOCUSOUT");
    }

    public override function activateHandler(event:Event):void
    {
        insertText("ACTIVATE");
    }

    public override function deactivateHandler(event:Event):void
    {
        insertText("DEACTIVATE");
    }

    /***** EDITMANAGER OVERRIDES *****/

    public override function deleteNextCharacter(operationState:SelectionState = null):void
    {
        insertText("DELETENEXT");
    }

    public override function deletePreviousCharacter(operationState:SelectionState = null):void
    {
        insertText("DELETEPREVIOUS");
    }

    public override function deleteNextWord(operationState:SelectionState = null):void
    {
        insertText("DELETENEXTWORD");
    }

    public override function deletePreviousWord(operationState:SelectionState = null):void
    {
        insertText("DELETEPREVIOUSWORD");
    }

}
