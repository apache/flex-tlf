/**
 * Created by Hellix on 2015-02-22.
 */
package UnitTest.Fixtures
{
    public dynamic class TestCaseVo
    {
        private var _testName:String;

        public function TestCaseVo(testName:String)
        {
            this._testName = testName;
        }

        public function get testName():String
        {
            return _testName;
        }
    }
}
