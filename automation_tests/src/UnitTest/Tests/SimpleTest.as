/**
 * Created with IntelliJ IDEA.
 * User: piotr.zarzycki
 * Date: 05.04.14
 * Time: 11:55
 * To change this template use File | Settings | File Templates.
 */
package UnitTest.Tests
{

    import org.flexunit.asserts.assertTrue;

    public class SimpleTest
    {
        public function SimpleTest()
        {
        }

        [Before]
        public function setUp() : void
        {
            var ddd:Object = null;
        }

        [After]
        public function tearDown():void
        {
            var ddd:Object = null;
        }

        [Test]
        public function myTest():void
        {
            assertTrue(true);
        }
    }
}
