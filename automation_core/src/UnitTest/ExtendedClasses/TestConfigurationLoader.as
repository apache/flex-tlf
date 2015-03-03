/**
 * Created by Hellix on 2015-02-22.
 */
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

        public function TestConfigurationLoader(fileName:String, testName:String)
        {
            if (!TestConfig.getInstance().testConfigData)
            {
                httpService = new HTTPService();
                httpService.url = LoaderUtil.createAbsoluteURL(TestConfig.getInstance().normalizedUrl, fileName);
                httpService.resultFormat = "e4x";
            }
            this.token = new ExternalDependencyToken();
            this.testName = testName;
        }

        public function retrieveDependency(testClass:Class):ExternalDependencyToken
        {
            var asyncToken:AsyncToken = httpService ? httpService.send() : new AsyncToken();
            asyncToken.addResponder(this);

            return token;
        }

        public function result(data:Object):void
        {
            var dp:Array = null;
            if (httpService && data.result)
            {
                TestConfig.getInstance().testConfigData = data.result;
                dp = parseTestConfigData(data.result);
            }
            else
            {
                dp = parseTestConfigData(TestConfig.getInstance().testConfigData);
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
    }
}
