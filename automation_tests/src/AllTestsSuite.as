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
    import UnitTest.Tests.AllEventTest;
    import UnitTest.Tests.AttributeTest;
    import UnitTest.Tests.BoxTest;
    import UnitTest.Tests.ContainerTypeTest;
    import UnitTest.Tests.FloatTest;
    import UnitTest.Tests.OperationTest;
    import UnitTest.Tests.ScrollingTest;

    [Suite]
    [RunWith("org.flexunit.runners.Suite")]
    public dynamic class AllTestsSuite
    {
        public var accessibilityMethodsTest:AccessibilityMethodsTest;
        public var allEventTest:AllEventTest;
        public var attributeTest:AttributeTest;
        public var boxTest:BoxTest;
        public var containerTypeTest:ContainerTypeTest;
        public var floatTest:FloatTest;
        public var operationTest:OperationTest;
        public var scrollingTest:ScrollingTest;
    }

}
