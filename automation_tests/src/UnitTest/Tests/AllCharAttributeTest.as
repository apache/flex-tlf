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
    import UnitTest.Fixtures.TestConfig;

    import flashx.textLayout.formats.Category;
    import flashx.textLayout.formats.TextLayoutFormat;

    import flashx.textLayout.tlf_internal;

    use namespace tlf_internal;

    public class AllCharAttributeTest extends AllAttributeTest
    {
        public function AllCharAttributeTest()
        {
            super("", "AllCharAttributeTest", TestConfig.getInstance(), null, null, null);
            // Note: These must correspond to a Watson product area (case-sensitive)
            metaData.productArea = "Text Attributes";
            metaData.productSubArea = "Character Attributes";
        }


        [Before]
        override public function setUpTest():void
        {
            super.setUpTest();

            testProp = null;
            expectedValue = null;
            testValue = null;
        }

        [After]
        override public function tearDownTest():void
        {
            super.tearDownTest();
        }

        [Test]
        public function propertiesCharacterTests():void
        {
            testAllNumberPropsFromMinToMax(TestConfig.getInstance(), TextLayoutFormat.description, Category.CHARACTER);
            testAllIntPropsFromMinToMax(TestConfig.getInstance(), TextLayoutFormat.description, Category.CHARACTER);
            testAllNumberOrPercentPropsFromMinToMax(TestConfig.getInstance(), TextLayoutFormat.description, Category.CHARACTER);
            testAllBooleanProps(TestConfig.getInstance(), TextLayoutFormat.description, Category.CHARACTER);
            testAllEnumProps(TestConfig.getInstance(), TextLayoutFormat.description, Category.CHARACTER);
            testAllSharedValues(TestConfig.getInstance(), TextLayoutFormat.description, Category.CHARACTER);
        }
    }
}
