/**
 * Created with IntelliJ IDEA.
 * User: piotr.zarzycki
 * Date: 24.03.14
 * Time: 20:49
 * To change this template use File | Settings | File Templates.
 */
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
