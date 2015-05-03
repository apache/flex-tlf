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
    import UnitTest.Fixtures.FileRepository;
    import UnitTest.Fixtures.TestConfig;

    import flash.events.ErrorEvent;
    import flash.events.Event;

    import org.flexunit.asserts.fail;
    import org.flexunit.internals.runners.statements.MethodRuleBase;
    import org.flexunit.rules.IMethodRule;
    import org.flexunit.token.AsyncTestToken;
    import org.flexunit.token.ChildResult;

    /**
     * This rule helps load files with data required for test cases
     * It should be used in case when data from file couldn't be load enough fast to be ready for test cases
     */
    public class LoadingFileRule extends MethodRuleBase implements IMethodRule
    {
        private var _fileName:String;

        public function LoadingFileRule(fileName:String)
        {
            super();
            _fileName = fileName;
        }

        override public function evaluate(parentToken:AsyncTestToken):void
        {
            super.evaluate(parentToken);

            var testConfig:TestConfig = TestConfig.getInstance();
            var fileExists:String = FileRepository.getFile(testConfig.baseURL, _fileName);
            if (fileExists == null)
            {
                FileRepository.readFile(testConfig.baseURL, _fileName, fileLoadCompleteHandler, fileLoadErrorHandler);
            }
            else
            {
                proceedToNextStatement();
            }
        }

        override protected function handleStatementComplete(result:ChildResult):void
        {
            super.handleStatementComplete(result);
        }

        private function fileLoadCompleteHandler(event:Event):void
        {
           proceedToNextStatement();
        }

        private function fileLoadErrorHandler(event:ErrorEvent):void
        {
            fail("Loading file failed");
        }
    }
}
