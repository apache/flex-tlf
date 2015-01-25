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
package UnitTest.ExtendedClasses
{
    public class TestCaseBase
    {
        public var setUpDuration:Number;
        public var setUpMemInitial:Object;
        public var setUpMemFinal:Object;
        public var middleDuration:Number;
        public var middleMemInitial:Object;
        public var middleMemFinal:Object;
        public var tearDownDuration:Number;
        public var tearDownMemInitial:Object;
        public var tearDownMemFinal:Object;
        public var metaData:Object;

        public var methodName:String;

        public function TestCaseBase(methodName:String = null)
        {
            this.methodName = methodName;
        }

        public function toString():String
        {
            return methodName;
        }
    }
}
