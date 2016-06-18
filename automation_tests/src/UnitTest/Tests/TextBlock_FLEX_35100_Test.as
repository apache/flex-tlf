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
package UnitTest.Tests {
    import UnitTest.ExtendedClasses.VellumTestCase;
    import UnitTest.Fixtures.TestConfig;

    import flash.text.engine.ElementFormat;

    import flash.text.engine.TextBlock;
    import flash.text.engine.TextElement;
    import flash.text.engine.TextLine;
    import flash.text.engine.TextLineCreationResult;

    import org.flexunit.assertThat;
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertNull;

    public class TextBlock_FLEX_35100_Test extends VellumTestCase {

        private static const WIDTH_FOR_TWO_LINES:int = 50;
        private static var _sut:TextBlock;

        public function TextBlock_FLEX_35100_Test()
        {
            super("", "TextBlock_FLEX_35100_Tests", TestConfig.getInstance());

            metaData = {};
        }

        [Before]
        override public function setUpTest():void
        {
            super.setUpTest();
            _sut = new TextBlock(new TextElement("Hello world!", new ElementFormat()));
        }

        [After]
        override public function tearDownTest():void
        {
            super.tearDownTest();
            _sut = null;
        }

        ////////////////////////////////////////////////////////////////////////////////
        //
        // createTextLine()
        //
        ////////////////////////////////////////////////////////////////////////////////


        [Test]
        public function test_createTextLine_returns_a_valid_TextLine_when_previousLine_is_null_and_TextBlock_not_empty():void
        {
            //when
            var textLine:TextLine = _sut.createTextLine(null);

            //then
            assertNotNull(textLine);
        }

        [Test]
        public function test_createTextLine_returns_null_when_width_too_little():void
        {
            //when
            var textLine:TextLine = _sut.createTextLine(null, 1);

            //then
            assertNull(textLine);
        }

        [Test]
        public function test_createTextLine_returns_null_when_width_0():void
        {
            //when
            var textLine:TextLine = _sut.createTextLine(null, 0);

            //then
            assertNull(textLine);
        }

        [Test(expects="ArgumentError")]
        public function test_createTextLine_throws_ArgumentError_when_width_negative():void
        {
            //when
            var textLine:TextLine = _sut.createTextLine(null, -10);

            //then - ArgumentError thrown
        }

        [Test]
        public function test_createTextLine_works_when_fitSomething_true_despite_width_negative():void
        {
            //when
            var textLine:TextLine = _sut.createTextLine(null, -10, 0, true);

            //then
            assertNotNull(textLine);
            assertThat(textLine.rawTextLength > 0);
        }

        [Test]
        public function test_createTextLine_works_when_fitSomething_true_despite_width_insufficient():void
        {
            //when
            var textLine:TextLine = _sut.createTextLine(null, 1, 0, true);

            //then
            assertNotNull(textLine);
            assertThat(textLine.rawTextLength > 0);
        }

        [Test]
        public function test_createTextLine_creates_only_one_TextLine_for_short_text_and_default_width():void
        {
            //when
            var firstTextLine:TextLine = _sut.createTextLine(null);
            var secondTextLine:TextLine = _sut.createTextLine(firstTextLine);

            //then
            assertNull(secondTextLine);
            assertEquals(TextLineCreationResult.COMPLETE, _sut.textLineCreationResult);
        }

        [Test]
        public function test_createTextLine_creates_only_one_TextLine_for_short_text_and_default_width_despite_fitSomething_true():void
        {
            //when
            var firstTextLine:TextLine = _sut.createTextLine(null);
            var secondTextLine:TextLine = _sut.createTextLine(firstTextLine, 10000, 0, true);

            //then
            assertNull(secondTextLine);
            assertEquals(TextLineCreationResult.COMPLETE, _sut.textLineCreationResult);
        }

        [Test]
        public function test_createTextLine_returns_null_when_previousLine_is_null_and_TextBlock_empty():void
        {
            //given
            _sut.content = new TextElement("", new ElementFormat());

            //when
            var textLine:TextLine = _sut.createTextLine(null);

            //then
            assertNull(textLine);
        }

        [Test]
        public function test_createTextLine_returns_null_when_previousLine_is_null_and_TextBlock_empty_despite_fitSomething_true():void
        {
            //given
            _sut.content = new TextElement("", new ElementFormat());

            //when
            var textLine:TextLine = _sut.createTextLine(null, 1000, 0, true);

            //then
            assertNull(textLine);
        }

        [Test]
        public function test_createTextLine_returns_null_when_previousLine_is_null_and_TextBlock_has_null_text():void
        {
            //given
            _sut.content = new TextElement(null, new ElementFormat());

            //when
            var textLine:TextLine = _sut.createTextLine(null);

            //then
            assertNull(textLine);
        }

        [Test(expects="ArgumentError")]
        public function test_createTextLine_throws_ArgumentError_when_previousLine_from_different_TextBlock():void
        {
            //given
            var firstTextLine:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            new TextBlock(new TextElement("Hello World!", new ElementFormat())).createTextLine(firstTextLine);

            //then - ArgumentError thrown
        }


        ////////////////////////////////////////////////////////////////////////////////
        //
        // recreateTextLine()
        //
        ////////////////////////////////////////////////////////////////////////////////

        [Test]
        public function test_recreateTextLine_returns_the_same_TextLine_instance_passed_to_it():void
        {
            //when
            var textLine:TextLine = _sut.createTextLine(null);
            var recreatedTextLine:TextLine = _sut.recreateTextLine(textLine, null);

            //then
            assertEquals(textLine, recreatedTextLine);
        }

        [Test]
        public function test_recreateTextLine_returns_null_when_TextBlock_empty():void
        {
            //given
            var textLine:TextLine = _sut.createTextLine(null);

            //when
            _sut.content = new TextElement("", new ElementFormat());
            var recreatedTextLine:TextLine = _sut.recreateTextLine(textLine, null);

            //then
            assertNull(recreatedTextLine);
        }

        [Test]
        public function test_recreateTextLine_returns_null_when_TextBlock_empty_despite_fitSomething_true():void
        {
            //given
            var textLine:TextLine = _sut.createTextLine(null);

            //when
            _sut.content = new TextElement("", new ElementFormat());
            var recreatedTextLine:TextLine = _sut.recreateTextLine(textLine, null, 1000, 0, true);

            //then
            assertNull(recreatedTextLine);
        }

        [Test(expects="ArgumentError")]
        public function test_recreateTextLine_throws_Argument_Error_when_previousLine_from_different_TextBlock_content():void
        {
            //given
            var firstLine:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            var secondLine:TextLine = _sut.createTextLine(firstLine, WIDTH_FOR_TWO_LINES);

            //when
            _sut.content = new TextElement("Creative Design and development", new ElementFormat());
            var recreatedSecondLine:TextLine = _sut.recreateTextLine(secondLine, firstLine, WIDTH_FOR_TWO_LINES);

            //then - ArgumentError is thrown
        }

        [Test(expects="ArgumentError")]
        public function test_recreateTextLine_throws_Argument_Error_when_line_parameter_is_null():void
        {
            //given
            var firstLine:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            var secondLine:TextLine = _sut.createTextLine(firstLine, WIDTH_FOR_TWO_LINES);

            //when
            var recreatedSecondLine:TextLine = _sut.recreateTextLine(null, firstLine, WIDTH_FOR_TWO_LINES);

            //then
            assertNull(recreatedSecondLine);
        }

        [Test]
        public function test_recreateTextLine_returns_null_when_width_too_little():void
        {
            //when
            var textLine:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            var recreatedTextLine:TextLine = _sut.recreateTextLine(textLine, null, 1);

            //then
            assertNull(recreatedTextLine);
        }

        [Test]
        public function test_recreateTextLine_returns_null_when_width_0():void
        {
            //when
            var textLine:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            var recreatedTextLine:TextLine = _sut.recreateTextLine(textLine, null, 0);

            //then
            assertNull(recreatedTextLine);
        }

        [Test(expects="ArgumentError")]
        public function test_recreateTextLine_throws_ArgumentError_when_width_negative():void
        {
            //when
            var textLine:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            var recreatedTextLine:TextLine = _sut.recreateTextLine(textLine, null, -10);

            //then - ArgumentError thrown
        }

        [Test]
        public function test_recreateTextLine_works_when_fitSomething_true_despite_width_negative():void
        {
            //when
            var textLine:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            var recreatedTextLine:TextLine = _sut.recreateTextLine(textLine, null, -10, 0, true);

            //then
            assertNotNull(recreatedTextLine);
            assertThat(recreatedTextLine.rawTextLength > 0);
        }

        [Test]
        public function test_recreateTextLine_returns_null_when_previousLine_was_last_line():void
        {
            //when
            var firstLine:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            var secondLine:TextLine = _sut.createTextLine(firstLine, WIDTH_FOR_TWO_LINES);

            var copyOfFirstThenThird:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            copyOfFirstThenThird = _sut.recreateTextLine(copyOfFirstThenThird, secondLine, WIDTH_FOR_TWO_LINES);

            //then
            assertNull(copyOfFirstThenThird);
            assertEquals(TextLineCreationResult.COMPLETE, _sut.textLineCreationResult);
        }

        [Test]
        public function test_recreateTextLine_returns_null_when_previousLine_was_last_line_despite_fitSomething_true():void
        {
            //when
            var firstLine:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            var secondLine:TextLine = _sut.createTextLine(firstLine, WIDTH_FOR_TWO_LINES);

            var copyOfFirstThenThird:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            copyOfFirstThenThird = _sut.recreateTextLine(copyOfFirstThenThird, secondLine, WIDTH_FOR_TWO_LINES, 0, true);

            //then
            assertNull(copyOfFirstThenThird);
            assertEquals(TextLineCreationResult.COMPLETE, _sut.textLineCreationResult);
        }

        [Test(expects="ArgumentError")]
        public function test_recreateTextLine_throws_ArgumentError_when_previousLine_is_the_same_as_the_line_to_recreate():void
        {
            //when
            var firstTextLine:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            var secondTextLine:TextLine = _sut.createTextLine(firstTextLine, WIDTH_FOR_TWO_LINES);

            assertNotNull(secondTextLine);

            var firstLineRecreatedAsSecond:TextLine = _sut.recreateTextLine(firstTextLine, firstTextLine, WIDTH_FOR_TWO_LINES);

            //then - error should be thrown
        }

        [Test(expects="ArgumentError")]
        public function test_recreateTextLine_throws_ArgumentError_when_textLine_comes_from_different_block():void
        {
            //when
            var firstTextLine:TextLine = _sut.createTextLine(null, WIDTH_FOR_TWO_LINES);
            var secondTextLine:TextLine = _sut.createTextLine(firstTextLine, WIDTH_FOR_TWO_LINES);

            assertNotNull(secondTextLine);

            var firstLineRecreatedAsSecond:TextLine = new TextBlock(new TextElement("Hello World!", new ElementFormat())).recreateTextLine(secondTextLine, firstTextLine, WIDTH_FOR_TWO_LINES);

            //then - error should be thrown
        }
    }
}
