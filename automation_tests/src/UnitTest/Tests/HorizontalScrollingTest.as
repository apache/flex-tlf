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
    import UnitTest.ExtendedClasses.TestConfigurationLoader;
    import UnitTest.ExtendedClasses.VellumTestCase;
    import UnitTest.Fixtures.TestCaseVo;
    import UnitTest.Fixtures.TestConfig;

    import flash.events.KeyboardEvent;
    import flash.ui.KeyLocation;

    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.formats.BlockProgression;

    import org.flexunit.asserts.assertTrue;

    [TestCase(order=25)]
    [RunWith("org.flexunit.runners.Parameterized")]
    public class HorizontalScrollingTest extends VellumTestCase
    {

        // List of available keyboard gestures
        // Note that on Mac: CTRL == COMMAND
        //              and: ALT == OPTION
        // These are directly mapped in flash player
        private static const CTRL_BACKSPACE:int = 100;
        private static const CTRL_DELETE:int = 101;
        private static const OPT_BACKSPACE:int = 102;
        private static const OPT_DELETE:int = 103;
        private static const CTRL_LEFT:int = 104;
        private static const CTRL_RIGHT:int = 105;
        private static const CTRL_UP:int = 106;
        private static const CTRL_DOWN:int = 107;
        private static const OPT_LEFT:int = 108;
        private static const OPT_RIGHT:int = 109;
        private static const OPT_UP:int = 110;
        private static const OPT_DOWN:int = 111;
        private static const SHIFT_CTRL_LEFT:int = 112;
        private static const SHIFT_CTRL_RIGHT:int = 113;
        private static const SHIFT_CTRL_UP:int = 114;
        private static const SHIFT_CTRL_DOWN:int = 115;
        private static const SHIFT_OPT_LEFT:int = 116;
        private static const SHIFT_OPT_RIGHT:int = 117;
        private static const SHIFT_OPT_UP:int = 118;
        private static const SHIFT_OPT_DOWN:int = 119;
        private static const HOME:int = 120;
        private static const END:int = 121;
        private static const SHIFT_HOME:int = 122;
        private static const SHIFT_END:int = 123;
        private static const CTRL_HOME:int = 124;
        private static const CTRL_END:int = 125;
        private static const SHIFT_CTRL_HOME:int = 126;
        private static const SHIFT_CTRL_END:int = 127;
        private static const PG_UP:int = 128;
        private static const PG_DOWN:int = 129;
        private static const SHIFT_PG_UP:int = 130;
        private static const SHIFT_PG_DOWN:int = 131;
        private static const UP:int = 132;
        private static const DOWN:int = 133;
        private static const LEFT:int = 134;
        private static const RIGHT:int = 135;

        private static const SHIFT_RIGHT:int = 136;
        private static const SHIFT_LEFT:int = 137;

        [DataPoints(loader=HOLTRTestLoader)]
        [ArrayElementType("UnitTest.Fixtures.TestCaseVo")]
        public static var HOLTRTestDp:Array;

        public static var HOLTRTestLoader:TestConfigurationLoader = new TestConfigurationLoader("../../test/testCases/HorizontalScrollingTests.xml", "HOLTR_endKeyScrollingTest");

        [DataPoints(loader=HORTLTestLoader)]
        [ArrayElementType("UnitTest.Fixtures.TestCaseVo")]
        public static var HORTLTestDp:Array;

        public static var HORTLTestLoader:TestConfigurationLoader = new TestConfigurationLoader("../../test/testCases/HorizontalScrollingTests.xml", "HORTL_backspaceScrollingTest");

        [DataPoints(loader=VOLTRTestLoader)]
        [ArrayElementType("UnitTest.Fixtures.TestCaseVo")]
        public static var VOLTRTestDp:Array;

        public static var VOLTRTestLoader:TestConfigurationLoader = new TestConfigurationLoader("../../test/testCases/HorizontalScrollingTests.xml", "VOLTR_endKeyScrollingTest");

        [DataPoints(loader=VORTLTestLoader)]
        [ArrayElementType("UnitTest.Fixtures.TestCaseVo")]
        public static var VORTLDp:Array;

        public static var VORTLTestLoader:TestConfigurationLoader = new TestConfigurationLoader("../../test/testCases/HorizontalScrollingTests.xml", "VORTL_backspaceScrollingTest");

        public function HorizontalScrollingTest()
        {
            super("", "TabTest", TestConfig.getInstance());

            metaData = {};
            // Note: These must correspond to a Watson product area (case-sensitive)
            metaData.productArea = "UI";
            metaData.productSubArea = "Scrolling";
        }

        [After]
        public override function tearDownTest():void
        {
            // Restore default configurations
            super.tearDownTest();
        }

        // Horizontal Orientation Left To Right Direction Scrolling Tests.
        [Test(dataProvider=HOLTRTestDp)]
        public function HOLTR_endKeyScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            endKeyScrollingTest(19977);
        }

        [Test(dataProvider=HOLTRTestDp)]
        public function HOLTR_homeKeyScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            homeKeyScrollingTest(19);
        }

        [Test(dataProvider=HOLTRTestDp)]
        public function HOLTR_cursorRightScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            cursorRightScrollingTest(29);
        }

        [Test(dataProvider=HOLTRTestDp)]
        public function HOLTR_cursorLeftScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            cursorLeftScrollingTest(19960);
        }

        [Test(dataProvider=HOLTRTestDp)]
        public function HOLTR_dragRightScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            dragRightScrollingTest(29);
        }

        [Test(dataProvider=HOLTRTestDp)]
        public function HOLTR_dragLeftScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            dragLeftScrollingTest(19960);
        }

        [Test(dataProvider=HOLTRTestDp)]
        public function HOLTR_characterEntryEndOfFirstLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            characterEntryEndOfFirstLineScrollingTest(19977)
        }

        [Test(dataProvider=HOLTRTestDp)]
        public function HOLTR_characterEntryEndOfLastLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            characterEntryEndOfLastLineScrollingTest(25178);
        }

        [Test(dataProvider=HOLTRTestDp)]
        public function HOLTR_spaceEntryEndOfFirstLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            spaceEntryEndOfFirstLineScrollingTest(19977);
        }

        [Test(dataProvider=HOLTRTestDp)]
        public function HOLTR_spaceEntryEndOfLastLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            spaceEntryEndOfLastLineScrollingTest(25178);
        }

        [Test(dataProvider=HOLTRTestDp)]
        public function HOLTR_backspaceScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            backspaceScrollingTest(19936);
        }

        // Vertical Orientation Left To Right Direction Scrolling Tests.
        [Test(dataProvider=VOLTRTestDp)]
        public function VOLTR_endKeyScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            endKeyScrollingTest(20326);
        }

        [Test(dataProvider=VOLTRTestDp)]
        public function VOLTR_homeKeyScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            homeKeyScrollingTest(19);
        }

        public function VOLTR_cursorRightScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            cursorRightScrollingTest(378);
        }

        [Test(dataProvider=VOLTRTestDp)]
        public function VOLTR_cursorLeftScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            cursorLeftScrollingTest(19960);
        }

        [Test(dataProvider=VOLTRTestDp)]
        public function VOLTR_dragRightScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            dragRightScrollingTest(378);
        }

        [Test(dataProvider=VOLTRTestDp)]
        public function VOLTR_dragLeftScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            dragLeftScrollingTest(19960);
        }

        [Test(dataProvider=VOLTRTestDp)]
        public function VOLTR_characterEntryEndOfFirstLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            characterEntryEndOfFirstLineScrollingTest(20326)
        }

        [Test(dataProvider=VOLTRTestDp)]
        public function VOLTR_characterEntryEndOfLastLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            characterEntryEndOfLastLineScrollingTest(25527);
        }

        [Test(dataProvider=VOLTRTestDp)]
        public function VOLTR_spaceEntryEndOfFirstLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            spaceEntryEndOfFirstLineScrollingTest(20326);
        }

        [Test(dataProvider=VOLTRTestDp)]
        public function VOLTR_spaceEntryEndOfLastLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            spaceEntryEndOfLastLineScrollingTest(25527);
        }

        [Test(dataProvider=VOLTRTestDp)]
        public function VOLTR_backspaceScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            backspaceScrollingTest(19936);
        }


        // Horizontal Orientation Left To Right Direction Scrolling Tests.
        [Test(dataProvider=HORTLTestDp)]
        public function HORTL_endKeyScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            endKeyScrollingTest(19977);
        }

        [Test(dataProvider=HORTLTestDp)]
        public function HORTL_homeKeyScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            homeKeyScrollingTest(19);
        }

        [Test(dataProvider=HORTLTestDp)]
        public function HORTL_cursorRightScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            cursorRightScrollingTest(29);
        }

        [Test(dataProvider=HORTLTestDp)]
        public function HORTL_cursorLeftScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            cursorLeftScrollingTest(19960);
        }

        [Test(dataProvider=HORTLTestDp)]
        public function HORTL_dragRightScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            dragRightScrollingTest(29);
        }

        [Test(dataProvider=HORTLTestDp)]
        public function HORTL_dragLeftScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            dragLeftScrollingTest(19960);
        }

        [Test(dataProvider=HORTLTestDp)]
        public function HORTL_characterEntryEndOfFirstLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            characterEntryEndOfFirstLineScrollingTest(19977)
        }

        [Test(dataProvider=HORTLTestDp)]
        public function HORTL_characterEntryEndOfLastLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            characterEntryEndOfLastLineScrollingTest(25178);
        }

        [Test(dataProvider=HORTLTestDp)]
        public function HORTL_spaceEntryEndOfFirstLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            spaceEntryEndOfFirstLineScrollingTest(19977);
        }

        [Test(dataProvider=HORTLTestDp)]
        public function HORTL_spaceEntryEndOfLastLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            spaceEntryEndOfLastLineScrollingTest(25178);
        }

        [Test(dataProvider=HORTLTestDp)]
        public function HORTL_backspaceScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            backspaceScrollingTest(19936);
        }

        // Vertical Orientation Left To Right Direction Scrolling Tests.
        [Test(dataProvider=VORTLDp)]
        public function VORTL_endKeyScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            endKeyScrollingTest(20326);
        }

        [Test(dataProvider=VORTLDp)]
        public function VORTL_homeKeyScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            homeKeyScrollingTest(19);
        }

        [Test(dataProvider=VORTLDp)]
        public function VORTL_cursorRightScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            cursorRightScrollingTest(378);
        }

        [Test(dataProvider=VORTLDp)]
        public function VORTL_cursorLeftScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            cursorLeftScrollingTest(19960);
        }

        [Test(dataProvider=VORTLDp)]
        public function VORTL_dragRightScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            dragRightScrollingTest(378);
        }

        [Test(dataProvider=VORTLDp)]
        public function VORTL_dragLeftScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            dragLeftScrollingTest(19960);
        }

        [Test(dataProvider=VORTLDp)]
        public function VORTL_characterEntryEndOfFirstLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            characterEntryEndOfFirstLineScrollingTest(20326)
        }

        [Test(dataProvider=VORTLDp)]
        public function VORTL_characterEntryEndOfLastLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            characterEntryEndOfLastLineScrollingTest(25527);
        }

        [Test(dataProvider=VORTLDp)]
        public function VORTL_spaceEntryEndOfFirstLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            spaceEntryEndOfFirstLineScrollingTest(20326);
        }

        [Test(dataProvider=VORTLDp)]
        public function VORTL_spaceEntryEndOfLastLineScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            spaceEntryEndOfLastLineScrollingTest(25527);
        }

        [Test(dataProvider=VORTLDp)]
        public function VORTL_backspaceScrollingTest(testCaseVo:TestCaseVo):void
        {
            TestData.fileName = testCaseVo.fileName;
            super.setUpTest();

            backspaceScrollingTest(19936);
        }


        // Send a keyboard gesture using values listed above
        // Code folding extremely recommended here
        private function sendKeyboardGesture(type:int):void
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
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.RL)
            {
                leftCode = 38;
                rightCode = 40;
                upCode = 39;
                downCode = 37;
            }
            switch (type)
            {
                case CTRL_BACKSPACE:
                    charCode = 8;
                    keyCode = 8;
                    ctrlDown = true;
                    break;
                case CTRL_DELETE:
                    charCode = 127;
                    keyCode = 46;
                    ctrlDown = true;
                    break;
                case OPT_BACKSPACE:
                    charCode = 8;
                    keyCode = 8;
                    altDown = true;
                    break;
                case OPT_DELETE:
                    charCode = 127;
                    keyCode = 46;
                    altDown = true;
                    break;
                case CTRL_LEFT:
                    charCode = 0;
                    keyCode = leftCode;
                    ctrlDown = true;
                    break;
                case CTRL_RIGHT:
                    charCode = 0;
                    keyCode = rightCode;
                    ctrlDown = true;
                    break;
                case CTRL_UP:
                    charCode = 0;
                    keyCode = upCode;
                    ctrlDown = true;
                    break;
                case CTRL_DOWN:
                    charCode = 0;
                    keyCode = downCode;
                    ctrlDown = true;
                    break;
                case OPT_LEFT:
                    charCode = 0;
                    keyCode = leftCode;
                    altDown = true;
                    break;
                case OPT_RIGHT:
                    charCode = 0;
                    keyCode = rightCode;
                    altDown = true;
                    break;
                case OPT_UP:
                    charCode = 0;
                    keyCode = upCode;
                    altDown = true;
                    break;
                case OPT_DOWN:
                    charCode = 0;
                    keyCode = downCode;
                    altDown = true;
                    break;
                case SHIFT_LEFT:
                    charCode = 0;
                    keyCode = leftCode;
                    ctrlDown = false;
                    shiftDown = true;
                    break;
                case SHIFT_RIGHT:
                    charCode = 0;
                    keyCode = rightCode;
                    ctrlDown = false;
                    shiftDown = true;
                    break;
                case SHIFT_CTRL_LEFT:
                    charCode = 0;
                    keyCode = leftCode;
                    ctrlDown = true;
                    shiftDown = true;
                    break;
                case SHIFT_CTRL_RIGHT:
                    charCode = 0;
                    keyCode = rightCode;
                    ctrlDown = true;
                    shiftDown = true;
                    break;
                case SHIFT_CTRL_UP:
                    charCode = 0;
                    keyCode = upCode;
                    ctrlDown = true;
                    shiftDown = true;
                    break;
                case SHIFT_CTRL_DOWN:
                    charCode = 0;
                    keyCode = downCode;
                    ctrlDown = true;
                    shiftDown = true;
                    break;
                case SHIFT_OPT_LEFT:
                    charCode = 0;
                    keyCode = leftCode;
                    ctrlDown = true;
                    shiftDown = true;
                    break;
                case SHIFT_OPT_RIGHT:
                    charCode = 0;
                    keyCode = rightCode;
                    ctrlDown = true;
                    shiftDown = true;
                    break;
                case SHIFT_OPT_UP:
                    charCode = 0;
                    keyCode = upCode;
                    ctrlDown = true;
                    shiftDown = true;
                    break;
                case SHIFT_OPT_DOWN:
                    charCode = 0;
                    keyCode = downCode;
                    altDown = true;
                    shiftDown = true;
                    break;
                case HOME:
                    charCode = 0;
                    keyCode = 36;
                    break;
                case END:
                    charCode = 0;
                    keyCode = 35;
                    break;
                case SHIFT_HOME:
                    charCode = 0;
                    keyCode = 36;
                    shiftDown = true;
                    break;
                case SHIFT_END:
                    charCode = 0;
                    keyCode = 35;
                    shiftDown = true;
                    break;
                case CTRL_HOME:
                    charCode = 0;
                    keyCode = 36;
                    ctrlDown = true;
                    break;
                case CTRL_END:
                    charCode = 0;
                    keyCode = 35;
                    ctrlDown = true;
                    break;
                case SHIFT_CTRL_HOME:
                    charCode = 0;
                    keyCode = 36;
                    shiftDown = true;
                    ctrlDown = true;
                    break;
                case SHIFT_CTRL_END:
                    charCode = 0;
                    keyCode = 35;
                    shiftDown = true;
                    ctrlDown = true;
                    break;
                case PG_UP:
                    charCode = 0;
                    keyCode = 33;
                    break;
                case PG_DOWN:
                    charCode = 0;
                    keyCode = 34;
                    break;
                case SHIFT_PG_UP:
                    charCode = 0;
                    keyCode = 33;
                    shiftDown = true;
                    break;
                case SHIFT_PG_DOWN:
                    charCode = 0;
                    keyCode = 34;
                    shiftDown = true;
                    break;
                case UP:
                    charCode = 0;
                    keyCode = upCode;
                    break;
                case DOWN:
                    charCode = 0;
                    keyCode = downCode;
                    break;
                case LEFT:
                    charCode = 0;
                    keyCode = leftCode;
                    break;
                case RIGHT:
                    charCode = 0;
                    keyCode = rightCode;
                    break;
                default:
                    return;
            }

            var kEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN,
                    true, false, charCode, keyCode, KeyLocation.STANDARD, ctrlDown, altDown, shiftDown);
            TestFrame.container["dispatchEvent"](kEvent);
        }

        private function endKeyScrollingTest(scrollPos:Number):void
        {
            // Success or failure will be determined by the bitmap snapshot.
            // Move the cursor to the beginning of the first line.
            SelManager.selectRange(0, 0);
            // Hit the End key to scroll to the end of the first line.
            sendKeyboardGesture(END);
            var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
            //	trace("endKeyScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
            //	trace("endKeyScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
            {
                assertTrue("endKeyScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
            }
            else
            {
                assertTrue("endKeyScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
            }

        }

        private function homeKeyScrollingTest(scrollPos:Number):void
        {
            // Success or failure will be determined by the bitmap snapshot.
            // Move the cursor to the beginning of the first line.
            SelManager.selectRange(0, 0);
            // Hit the End key to scroll to the end of the first line.
            sendKeyboardGesture(END);
            // Hit the Home key to scroll to the end of the first line.
            sendKeyboardGesture(HOME);
            var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
            //	trace("homeKeyScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
            //	trace("homeKeyScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
            {
                assertTrue("homeKeyScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
            }
            else
            {
                assertTrue("homeKeyScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
            }
        }

        private function cursorRightScrollingTest(scrollPos:Number):void
        {
            // Success or failure will be determined by the bitmap snapshot.
            // Move the cursor to the beginning of the first line.
            SelManager.selectRange(0, 0);
            // Hit the End key to scroll to the end of the first line.
            sendKeyboardGesture(END);
            // Hit the Home key to scroll to the end of the first line.
            sendKeyboardGesture(HOME);
            // Move the cursor over to the right.
            for (var i:Number = 0; i < 37; i++)
            {
                sendKeyboardGesture(RIGHT);
            }
            var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
            //	trace("cursorRightScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
            //	trace("cursorRightScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
            {
                assertTrue("cursorRightScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
            }
            else
            {
                assertTrue("cursorRightScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
            }
        }

        private function cursorLeftScrollingTest(scrollPos:Number):void
        {
            // Success or failure will be determined by the bitmap snapshot.
            // Move the cursor to the beginning of the first line.
            SelManager.selectRange(0, 0);
            // Hit the End key to scroll to the end of the first line.
            sendKeyboardGesture(END);
            // Move the cursor over to the right.
            for (var i:Number = 0; i < 41; i++)
            {
                sendKeyboardGesture(LEFT);
            }
            var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
            //	trace("cursorLeftScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
            //	trace("cursorLeftScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
            {
                assertTrue("cursorLeftScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
            }
            else
            {
                assertTrue("cursorLeftScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
            }
        }


        private function dragRightScrollingTest(scrollPos:Number):void
        {
            // Success or failure will be determined by the bitmap snapshot.
            // Move the cursor to the beginning of the first line.
            SelManager.selectRange(0, 0);
            // Hit the End key to scroll to the end of the first line.
            sendKeyboardGesture(END);
            // Hit the Home key to scroll to the end of the first line.
            sendKeyboardGesture(HOME);
            // Move the cursor to the selection that will cause a drag.
            // Move the cursor over to the right.
            for (var i:Number = 0; i < 36; i++)
            {
                sendKeyboardGesture(RIGHT);
            }
            sendKeyboardGesture(SHIFT_RIGHT);
            var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
            //	trace("dragRightScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
            //	trace("dragRightScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
            {
                assertTrue("dragRightScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
            }
            else
            {
                assertTrue("dragRightScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
            }
        }

        private function dragLeftScrollingTest(scrollPos:Number):void
        {
            // Success or failure will be determined by the bitmap snapshot.
            // Move the cursor to the beginning of the first line.
            SelManager.selectRange(0, 0);
            // Hit the End key to scroll to the end of the first line.
            sendKeyboardGesture(END);
            // Move the cursor to the selection that will cause a drag.
            // Move the cursor over to the right.
            for (var i:Number = 0; i < 40; i++)
            {
                sendKeyboardGesture(LEFT);
            }
            sendKeyboardGesture(SHIFT_LEFT);
            var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
            //	trace("dragLeftScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
            //	trace("dragLeftScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
            {
                assertTrue("dragLeftScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
            }
            else
            {
                assertTrue("dragLeftScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
            }
        }

        private function characterEntryEndOfFirstLineScrollingTest(scrollPos:Number):void
        {
            // Success or failure will be determined by the bitmap snapshot.
            // Move the cursor to the beginning of the first line.
            SelManager.selectRange(0, 0);
            // Hit the End key to scroll to the end of the first line.
            sendKeyboardGesture(END);
            // Type in ABC and confirm that it scrolls.
            SelManager.insertText(" ABC");
            var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
            //	trace("characterEntryEndOfFirstLineScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
            //	trace("characterEntryEndOfFirstLineScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
            {
                assertTrue("characterEntryEndOfFirstLineScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
            }
            else
            {
                assertTrue("characterEntryEndOfFirstLineScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
            }
        }

        private function characterEntryEndOfLastLineScrollingTest(scrollPos:Number):void
        {
            // Success or failure will be determined by the bitmap snapshot.
            // Move the cursor to the beginning of the first line.
            SelManager.selectRange(0, 0);
            // Hit the CTRL+End key to scroll to the end of the last line.
            sendKeyboardGesture(CTRL_END);
            // Type in ABC and confirm that it scrolls.
            SelManager.insertText(" ABC");
            var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
            //	trace("characterEntryEndOfLastLineScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
            //	trace("characterEntryEndOfLastLineScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
            {
                assertTrue("characterEntryEndOfLastLineScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
            }
            else
            {
                assertTrue("characterEntryEndOfLastLineScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
            }
        }

        private function spaceEntryEndOfFirstLineScrollingTest(scrollPos:Number):void
        {
            // Success or failure will be determined by the bitmap snapshot.
            // Move the cursor to the beginning of the first line.
            SelManager.selectRange(0, 0);
            // Hit the End key to scroll to the end of the first line.
            sendKeyboardGesture(END);
            // Type in ABC and confirm that it scrolls.
            SelManager.insertText("    ");
            var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
            //	trace("spaceEntryEndOfFirstLineScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
            //	trace("spaceEntryEndOfFirstLineScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
            {
                assertTrue("spaceEntryEndOfFirstLineScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
            }
            else
            {
                assertTrue("spaceEntryEndOfFirstLineScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
            }
        }

        private function spaceEntryEndOfLastLineScrollingTest(scrollPos:Number):void
        {
            // Success or failure will be determined by the bitmap snapshot.
            // Move the cursor to the beginning of the first line.
            SelManager.selectRange(0, 0);
            // Hit the CTRL+End key to scroll to the end of the last line.
            sendKeyboardGesture(CTRL_END);
            // Type in ABC and confirm that it scrolls.
            SelManager.insertText("    ");
            var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
            //	trace("spaceEntryEndOfLastLineScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
            //	trace("spaceEntryEndOfLastLineScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
            {
                assertTrue("spaceEntryEndOfLastLineScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
            }
            else
            {
                assertTrue("spaceEntryEndOfLastLineScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
            }
        }

        private function backspaceScrollingTest(scrollPos:Number):void
        {
            // Success or failure will be determined by the bitmap snapshot.
            // Move the cursor to the beginning of the first line.
            SelManager.selectRange(0, 0);
            // Hit the End key to scroll to the end of the first line.
            sendKeyboardGesture(END);
            // Move the cursor to the selection that will cause a drag.
            // Move the cursor over to the right.
            for (var i:Number = 0; i < 40; i++)
            {
                sendKeyboardGesture(LEFT);
            }
            for (i = 0; i < 3; i++)
            {
                SelManager.deletePreviousCharacter();
            }
            var tmpContainerController:ContainerController = ContainerController(SelManager.textFlow.flowComposer.getControllerAt(0));
            //	trace("backspaceScrollingTestHP=" + tmpContainerController.horizontalScrollPosition);
            //	trace("backspaceScrollingTestVP=" + tmpContainerController.verticalScrollPosition);
            if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
            {
                assertTrue("backspaceScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.verticalScrollPosition) < (scrollPos + 1)) == true);
            }
            else
            {
                assertTrue("backspaceScrollingTest Test Failed.", (scrollPos < Math.abs(tmpContainerController.horizontalScrollPosition) < (scrollPos + 1)) == true);
            }
        }
    }
}
