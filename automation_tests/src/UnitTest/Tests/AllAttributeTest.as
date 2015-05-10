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

    import flashx.textLayout.elements.FlowLeafElement;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.formats.Category;
    import flashx.textLayout.formats.FormatValue;
    import flashx.textLayout.formats.TextLayoutFormat;
    import flashx.textLayout.property.*;

    import org.flexunit.asserts.assertTrue;

    /**
     * Base class for All*AttributeTest
     */
    public class AllAttributeTest extends VellumTestCase
    {
        // test specific configuration
        protected var testProp:Property;
        protected var testValue:*;
        protected var expectedValue:*;

        private var errorHandlerCount:int = 0;

        public function AllAttributeTest(methodName:String, testID:String, testConfig:TestConfig)
        {
            super(methodName, testID, testConfig);

            metaData = {};
            // Note: These must correspond to a Watson product area (case-sensitive)
            metaData.productArea = "Text Attributes";
        }

        public function clearFormatTest():void
        {
            SelManager.selectAll();

            var applyFormat:TextLayoutFormat = new TextLayoutFormat();
            applyFormat[testProp.name] = testProp.defaultValue;
            var clearFormat:TextLayoutFormat = new TextLayoutFormat();
            clearFormat[testProp.name] = FormatValue.INHERIT;

            switch (testProp.category)
            {
                case Category.CHARACTER:
                    SelManager.applyFormat(applyFormat, null, null);
                    validateCharacterPropertyOnEntireFlow(SelManager.textFlow, testProp, testProp.defaultValue);
                    SelManager.clearFormat(clearFormat, null, null);
                    validateCharacterPropertyOnEntireFlow(SelManager.textFlow, testProp, undefined);
                    break;
                case Category.PARAGRAPH:
                    SelManager.applyFormat(null, applyFormat, null);
                  //  AllParaAttributeTest.validateParagraphPropertyOnEntireFlow(SelManager.textFlow, testProp, testProp.defaultValue);
                    SelManager.clearFormat(null, clearFormat, null);
                   // AllParaAttributeTest.validateParagraphPropertyOnEntireFlow(SelManager.textFlow, testProp, undefined);
                    break;
                case Category.CONTAINER:
                    SelManager.applyFormat(null, null, applyFormat);
                    AllContAttributeTest.validateContainerPropertyOnEntireFlow(SelManager.textFlow, testProp, testProp.defaultValue);
                    SelManager.clearFormat(null, null, clearFormat);
                    AllContAttributeTest.validateContainerPropertyOnEntireFlow(SelManager.textFlow, testProp, undefined);
                    break;
            }
        }

        protected function assignmentHelper(target:Object):void
        {
            Property.errorHandler = errorHandler;
            errorHandlerCount = 0;
            try
            {
                target[testProp.name] = testValue;
            }
            catch (e:Error)
            {
                Property.errorHandler = Property.defaultErrorHandler;
                assertTrue("Unexpected error in AllAttributeTest.assignmentHelper", false);
                throw(e);
            }
            Property.errorHandler = Property.defaultErrorHandler;

            if (expectedValue == undefined && testValue != undefined)
            {
                // expect an error
                assertTrue("Error expected but no error in AllAttributeTest.assignmentHelper", errorHandlerCount == 1);
            }
            else
            {
                // no error
                assertTrue("Error not expected but error found in AllAttributeTest.assignmentHelper", errorHandlerCount == 0);
            }
        }


        /**
         * Generic function to run one character attribute test.  Uses the selection manager to set the attributes on the entire flow at the span level
         * to value and then validates that the value is expectedValue.
         */
        protected function runOneCharacterAttributeTest():void
        {
            if (testProp == null)
                return;	// must be set

            SelManager.selectAll();

            // Test direct change on single leaf
            var leaf:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.absoluteStart);
            var originalValue:* = leaf[testProp.name];

            assignmentHelper(leaf);

            var expectedResult:*;
            if (expectedValue === undefined)
                expectedResult = testValue === undefined || testValue === null ? undefined : originalValue;
            else
                expectedResult = expectedValue;

            assertTrue("FlowLeafElement does not have the expected value after direct change", leaf[testProp.name] == expectedResult);
            leaf[testProp.name] = originalValue;

            var ca:TextLayoutFormat = new TextLayoutFormat();
            assignmentHelper(ca);
            SelManager.applyLeafFormat(ca);

            // expect that all FlowLeafElements have expectedValue as the properties value
            if (expectedValue !== undefined)
                assertTrue("not all FlowLeafElements have the expected value", validateCharacterPropertyOnEntireFlow(SelManager.textFlow, testProp, expectedValue));
        }


        private function errorHandler(p:Property, value:Object):void
        {
            errorHandlerCount++;
        }

        // support function to walk all FlowLeafElements and verify that prop is val
        private function validateCharacterPropertyOnEntireFlow(textFlow:TextFlow, prop:Property, val:*):Boolean
        {
            var elem:FlowLeafElement = textFlow.getFirstLeaf();
            assertTrue("either the first FlowLeafElement is null or the textFlow length is zero", elem != null || textFlow.textLength == 0);
            while (elem)
            {
                // error if elements have zero length
                assertTrue("The FlowLeafElement has zero length", elem.textLength != 0);

                // expect all values of prop to be supplied val
                if (elem.format[prop.name] !== val || elem[prop.name] !== val)
                    return false;

                // inherit is never computed
                if ((val == FormatValue.INHERIT && elem.computedFormat[prop.name] == val) || elem.computedFormat[prop.name] === undefined)
                    return false;

                // skip to the next element
                var nextElem:FlowLeafElement = elem.getNextLeaf();
                var absoluteEnd:int = elem.getAbsoluteStart() + elem.textLength;
                if (nextElem == null)
                    assertTrue("absoluteEnd of the last FlowLeafElement is not the end of the textFlow", absoluteEnd == textFlow.textLength);
                else
                    assertTrue("the end of this FlowLeafElement does not equal the start of the next", absoluteEnd == nextElem.getAbsoluteStart());

                elem = nextElem;
            }
            return true;
        }

    }
}
