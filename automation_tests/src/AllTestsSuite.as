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
    import UnitTest.Tests.OperationTest;
    import UnitTest.Tests.ScrollingTest;
    import UnitTest.Tests.TabTest;
    import UnitTest.Tests.TextFlowEditTest;
    import UnitTest.Tests.UndoRedoTest;
    import UnitTest.Tests.WritingModeTest;

    [Suite]
    [RunWith("org.flexunit.runners.Suite")]
    public dynamic class AllTestsSuite
    {
		[TestCase(order=1)]
        public var generalFunctionsTest:GeneralFunctionsTest;
		[TestCase(order=2)]
        public var factoryImportTest:FactoryImportTest;
		[TestCase(order=3)]
        public var accessibilityMethodsTest:AccessibilityMethodsTest;
		[TestCase(order=4)]
        public var allChartAttributeTest:AllCharAttributeTest;
		[TestCase(order=5)]
        public var allContAttirbuteTest:AllContAttributeTest;
		[TestCase(order=6)]
        public var allEventTest:AllEventTest;
		[TestCase(order=7)]
        public var allParagraphAttributeTest:AllParaAttributeTest;
		[TestCase(order=8)]
        public var attributeTest:AttributeTest;
		[TestCase(order=9)]
        public var boxTest:BoxTest;
		[TestCase(order=10)]
        public var compositionTest:CompositionTest;
		[TestCase(order=11)]
        public var containerTypeTest:ContainerTypeTest;
		[TestCase(order=12)]
        public var floatTest:FloatTest;
		[TestCase(order=13)]
        public var operationTest:OperationTest;
		[TestCase(order=14)]
        public var scrollingTest:ScrollingTest;
		[TestCase(order=15)]
        public var containerAttributeTest:ContainerAttributeTest;
		[TestCase(order=16)]
        public var boundsAndAlignmentTest:BoundsAndAlignmentTest;
		[TestCase(order=17)]
        public var crossContainerTest:CrossContainerTest;
		[TestCase(order=18)]
        public var elementOperationTest:ElementOperationTest;
		[TestCase(order=19)]
        public var eventOverrideTest:EventOverrideTest;
		[TestCase(order=20)]
        public var flowModelTest:FlowModelTest;
		[TestCase(order=21)]
        public var writingModeTest:WritingModeTest;
		[TestCase(order=22)]
        public var undoRedoTest:UndoRedoTest;
		[TestCase(order=23)]
        public var textFlowEditTest:TextFlowEditTest;
		[TestCase(order=24)]
        public var tabTest:TabTest;
    }

}
