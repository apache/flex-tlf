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
    import UnitTest.Fixtures.TestCaseVo;
    import UnitTest.Fixtures.TestConfig;

    import mx.rpc.AsyncToken;
    import mx.rpc.IResponder;
    import mx.rpc.http.HTTPService;
    import mx.utils.LoaderUtil;

    import org.flexunit.runner.external.ExternalDependencyToken;
    import org.flexunit.runner.external.IExternalDependencyLoader;

    public class TestConfigurationLoader implements IExternalDependencyLoader, IResponder
    {
        private var httpService:HTTPService;
        private var token:ExternalDependencyToken;
        private var testName:String;
        private var fileName:String;

        public function TestConfigurationLoader(fileName:String, testName:String)
        {
            this.token = new ExternalDependencyToken();
            this.fileName = fileName;
            this.testName = testName;
            createHttpService();
        }

        public function retrieveDependency(testClass:Class):ExternalDependencyToken
        {
            var asyncToken:AsyncToken = httpService.send();
            asyncToken.addResponder(this);

            return token;
        }

        public function result(data:Object):void
        {
            var dp:Array = null;
            if (data && data.result)
            {
                dp = parseTestConfigData(data.result);
            }
            else
            {
                token.notifyFault("Unable to load data tests");
                return;
            }

            token.notifyResult(dp);
        }

        public function fault(info:Object):void
        {
            token.notifyFault("Unable to load data tests");
        }

        private function parseTestConfigData(xmlData:XML):Array
        {
            var testConfigData:Array = [];
            var testCases:XMLList = xmlData.TestCase.(@functionName == testName);
            for each (var testCase:XML in testCases)
            {
                var testsData:XMLList = testCase.TestData;
                var testCaseVo:TestCaseVo = new TestCaseVo(testCase.@functionName);
                for each (var testData:XML in testsData)
                {
                    testCaseVo[testData.@name] = testData.toString();
                }
                testConfigData.push([testCaseVo]);
            }

            return testConfigData;
        }

        private function createHttpService():void
        {
            httpService = new HTTPService();
            httpService.url = LoaderUtil.createAbsoluteURL(TestConfig.getInstance().normalizedUrl, fileName);
            httpService.resultFormat = "e4x";
        }
    }
}
