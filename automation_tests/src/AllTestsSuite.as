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
package
{

    import UnitTest.Tests.AccessibilityMethodsTest;
    import UnitTest.Tests.AllCharAttributeTest;
    import UnitTest.Tests.AllContAttributeTest;
    import UnitTest.Tests.AllEventTest;
    import UnitTest.Tests.AllParaAttributeTest;
    import UnitTest.Tests.AttributeTest;
    import UnitTest.Tests.BoundsAndAlignmentTest;
    import UnitTest.Tests.BoxTest;
    import UnitTest.Tests.CompositionTest;
    import UnitTest.Tests.ContainerAttributeTest;
    import UnitTest.Tests.ContainerTypeTest;
    import UnitTest.Tests.CrossContainerTest;
    import UnitTest.Tests.ElementOperationTest;
    import UnitTest.Tests.EventOverrideTest;
    import UnitTest.Tests.FactoryImportTest;
    import UnitTest.Tests.FloatTest;
    import UnitTest.Tests.FlowModelTest;
    import UnitTest.Tests.GeneralFunctionsTest;
    import UnitTest.Tests.HorizontalScrollingTest;
    import UnitTest.Tests.ImpliedParagraphTest;
    import UnitTest.Tests.ImportAPITest;
    import UnitTest.Tests.KeyboardGestureTest;
    import UnitTest.Tests.OperationTest;
    import UnitTest.Tests.ScrollingTest;
    import UnitTest.Tests.TabTest;
    import UnitTest.Tests.TextFlowEditTest;
    import UnitTest.Tests.UndoRedoTest;
    import UnitTest.Tests.WritingModeTest;

    [Suite(order=1)]
    [RunWith("org.flexunit.runners.Suite")]
    public dynamic class AllTestsSuite
    {
        public var generalFunctionsTest:GeneralFunctionsTest;
        public var factoryImportTest:FactoryImportTest;
        public var accessibilityMethodsTest:AccessibilityMethodsTest;
        public var allChartAttributeTest:AllCharAttributeTest;
        public var allContAttirbuteTest:AllContAttributeTest;
        public var allEventTest:AllEventTest;
        public var allParagraphAttributeTest:AllParaAttributeTest;
        public var attributeTest:AttributeTest;
        public var boxTest:BoxTest;
        public var compositionTest:CompositionTest;
        public var containerTypeTest:ContainerTypeTest;
        public var floatTest:FloatTest;
        public var operationTest:OperationTest;
        public var scrollingTest:ScrollingTest;
        public var containerAttributeTest:ContainerAttributeTest;
        public var boundsAndAlignmentTest:BoundsAndAlignmentTest;
        public var crossContainerTest:CrossContainerTest;
        public var elementOperationTest:ElementOperationTest;
        public var eventOverrideTest:EventOverrideTest;
        public var flowModelTest:FlowModelTest;
        public var writingModeTest:WritingModeTest;
        public var undoRedoTest:UndoRedoTest;
        public var textFlowEditTest:TextFlowEditTest;
        public var tabTest:TabTest;
        public var horizontalScrollingTest:HorizontalScrollingTest;
        public var impliedParagraphTest:ImpliedParagraphTest;
        public var importApiTest:ImportAPITest;
        public var KeyboardGestureTest:KeyboardGestureTest;
    }

}
