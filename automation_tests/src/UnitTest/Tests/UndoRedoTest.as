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
    import UnitTest.Fixtures.TestEditManager;

    import flash.display.Sprite;

    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.conversion.TextConverter;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.operations.ApplyLinkOperation;
    import flashx.textLayout.tlf_internal;
    import flashx.undo.IUndoManager;
    import flashx.undo.UndoManager;

    import org.flexunit.asserts.assertTrue;

    use namespace tlf_internal;

    /** Test the state of selection after each operation is done, undone, and redone.
     */
    [TestCase(order=22)]
    [RunWith("org.flexunit.runners.Parameterized")]
    public class UndoRedoTest extends VellumTestCase
    {
        [DataPoints(loader=undoRedoLinkTestLoader)]
        [ArrayElementType("UnitTest.Fixtures.TestCaseVo")]
        public static var undoRedoLinkTestDp:Array;

        public static var undoRedoLinkTestLoader:TestConfigurationLoader = new TestConfigurationLoader("../../test/testCases/UndoRedoTest.xml", "undoRedoLinkTest");

        private var container:Sprite;
        protected var editManager:TestEditManager;
        protected var undoManager:IUndoManager;
        protected var textFlow:TextFlow;

        public function UndoRedoTest()
        {
            super("", "UndoRedoTest", TestConfig.getInstance());
        }

        protected function get initialImport():XML
        {
            return <TextFlow color="#000000" fontFamily="Tahoma" fontSize="14" fontStyle="normal" fontWeight="normal" lineHeight="130%" textDecoration="none" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008">
                <p>
                    <span>aaa</span>
                </p>
                <p styleName="h1">
                    <span>bbb</span>
                </p>
            </TextFlow>
        }

        [Before]
        override public function setUpTest():void
        {
            super.setUpTest();

            container = new Sprite();
            var controllerOne:ContainerController = new ContainerController(container, 500, 500);
            textFlow = TextConverter.importToFlow(initialImport, TextConverter.TEXT_LAYOUT_FORMAT);
            undoManager = new UndoManager();
            editManager = new TestEditManager(undoManager);
            textFlow.interactionManager = editManager;
            textFlow.flowComposer.addController(controllerOne);
            textFlow.flowComposer.updateAllControllers();
        }

        [After]
        override public function tearDownTest():void
        {
            super.tearDownTest();

            container = null;
            undoManager = null;
            editManager = null;
            textFlow = null;
        }

        [Test(dataProvider=undoRedoLinkTestDp)]
        public function undoRedoLinkTest(testCaseVo:TestCaseVo):void
        {
            var posOfSelection:int = testCaseVo.posOfSelection;
            editManager.selectRange(1, posOfSelection);
            editManager.doOperation(new ApplyLinkOperation(editManager.getSelectionState(), "http://flex.apache.org", "_self", true));
            var resultString:String = editManager.errors;
            assertTrue("Undo and Redo not successfully. " + resultString, resultString == "");
        }

    }
}
