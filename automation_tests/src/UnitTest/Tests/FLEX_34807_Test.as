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

////////////////////////////////////////////////////////////////////////////////
//
// This file contains content from Ethan Brand by Nathaniel Hawthorne,
// now in the public domain.
//
////////////////////////////////////////////////////////////////////////////////

package UnitTest.Tests
{

    import UnitTest.ExtendedClasses.VellumTestCase;
    import UnitTest.Fixtures.TestConfig;

    import flashx.textLayout.conversion.ConversionType;
    import flashx.textLayout.conversion.TextConverter;
    import flashx.textLayout.edit.TextScrap;
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.formats.ITextLayoutFormat;
    import flashx.textLayout.formats.TextLayoutFormat;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertTrue;

    public class FLEX_34807_Test extends VellumTestCase
    {
        private static const PASTED_TEXT:String = '|Hey world!|';
        private static const PASTED_HTML:String = '<span style="fontSize:12">|<i>Hey<b> world</b>!</i>|</span>';
        private static const PASTE:TextScrap = new TextScrap(TextConverter.importToFlow(PASTED_HTML, TextConverter.TEXT_FIELD_HTML_FORMAT));

        private static var PASTE_CHAR_STYLES:Array = [];

        private var sourceAsPlainText:String;
        private var leftBefore:ITextLayoutFormat;
        private var rightBefore:ITextLayoutFormat;
        private var leftAfter:ITextLayoutFormat;
        private var rightAfter:ITextLayoutFormat;
        private var initialTextLength:Number = NaN;

        public function FLEX_34807_Test()
        {
            super("", "FLEX_34807_Test", TestConfig.getInstance());

            metaData = {};

            TestData.fileName = "HtmlTest.xml";
        }

        [BeforeClass]
        public static function setUpClass():void
        {
            analyseStylesOfPastedText();
        }

        private static function analyseStylesOfPastedText():void
        {
            for (var i:int = 0; i < PASTED_TEXT.length; i++)
            {
                PASTE_CHAR_STYLES.push(getFormatOfCharFromFlow(i, PASTE.textFlow));
            }
        }

        [Before]
        override public function setUpTest():void
        {
            super.setUpTest();

            if (!sourceAsPlainText)
                sourceAsPlainText = TextConverter.export(testApp.getTextFlow(), TextConverter.PLAIN_TEXT_FORMAT, ConversionType.STRING_TYPE) as String;

            if (isNaN(initialTextLength))
                initialTextLength = SelManager.textFlow.textLength;
        }

        [After]
        public override function tearDownTest():void
        {
            super.tearDownTest();
        }

        [Test]
        public function paste_in_beginning():void
        {
            //given
            recordTextFormatsBeforeOperation(0);

            //when
            SelManager.selectFirstPosition();
            SelManager.pasteTextScrap(PASTE);

            //then
            assertAdjacentTextFormatsNotAltered(0);
            assertFormattingOfPastedTextNotAltered(0);
            assertTextPastedCorrectlyAndExistingTextNotChanged(0);
        }

        [Test]
        public function paste_in_first_paragraph():void
        {
            //given
            const PASTE_POSITION:int = 5; //after "There"
            recordTextFormatsBeforeOperation(PASTE_POSITION);

            //when
            SelManager.selectRange(PASTE_POSITION, PASTE_POSITION);
            SelManager.pasteTextScrap(PASTE);

            //then
            assertAdjacentTextFormatsNotAltered(PASTE_POSITION);
            assertFormattingOfPastedTextNotAltered(PASTE_POSITION);
            assertTextPastedCorrectlyAndExistingTextNotChanged(PASTE_POSITION);
        }

        [Test]
        public function paste_in_first_paragraph_in_middle_of_bold_section():void
        {
            //given
            const PASTE_POSITION:int = 16;
            recordTextFormatsBeforeOperation(PASTE_POSITION);

            //when
            SelManager.selectRange(PASTE_POSITION, PASTE_POSITION);
            SelManager.pasteTextScrap(PASTE);

            //then
            assertAdjacentTextFormatsNotAltered(PASTE_POSITION);
            assertFormattingOfPastedTextNotAltered(PASTE_POSITION);
            assertTextPastedCorrectlyAndExistingTextNotChanged(PASTE_POSITION);
        }

        [Test]
        public function paste_in_second_paragraph():void
        {
            //given
            const PASTE_POSITION:int = 170;
            recordTextFormatsBeforeOperation(PASTE_POSITION);

            //when
            SelManager.selectRange(PASTE_POSITION, PASTE_POSITION);
            SelManager.pasteTextScrap(PASTE);

            //then
            assertAdjacentTextFormatsNotAltered(PASTE_POSITION);
            assertFormattingOfPastedTextNotAltered(PASTE_POSITION);
            assertTextPastedCorrectlyAndExistingTextNotChanged(PASTE_POSITION);
        }

        [Test]
        public function paste_at_end():void
        {
            //given
            const PASTE_POSITION:int = SelManager.textFlow.textLength - 1;
            recordTextFormatsBeforeOperation(PASTE_POSITION);

            //when
            SelManager.selectRange(PASTE_POSITION, PASTE_POSITION);
            SelManager.pasteTextScrap(PASTE);

            //then
            assertAdjacentTextFormatsNotAltered(PASTE_POSITION);
            assertFormattingOfPastedTextNotAltered(PASTE_POSITION);
            assertTextPastedCorrectlyAndExistingTextNotChanged(PASTE_POSITION);
        }

        private function assertFormattingOfPastedTextNotAltered(pastePosition:int):void
        {
            for (var i:int = 0; i < PASTED_TEXT.length; i++)
            {
                var formatOfPastedChar:ITextLayoutFormat = getFormatOfCharAt(pastePosition + i);
                assertTrue("The style of the pasted text has been altered!", TextLayoutFormat.isEqual(PASTE_CHAR_STYLES[i], formatOfPastedChar));
            }
        }

        private function assertAdjacentTextFormatsNotAltered(pastePosition:int):void
        {
            recordTextFormatsAfterOperation(pastePosition);
            assertAdjacentTextFormatsArePreserved(pastePosition);
        }

        private function assertAdjacentTextFormatsArePreserved(pastePosition:int):void
        {
            if (pastePosition)
            {
                assertNotNull("Couldn't manage to find the format of the character to the left of the pasted text, before the paste operation!", leftBefore);
                assertNotNull("Couldn't manage to find the format of the character to the left of the pasted text, after the paste operation!", leftAfter);
                assertTrue("The style of the original text has been altered! (left)", TextLayoutFormat.isEqual(leftBefore, leftAfter));
            }

            if (pastePosition < initialTextLength - 1)
            {
                assertNotNull("Couldn't manage to find the format of the character to the right of the pasted text, before the paste operation!", rightBefore);
                assertNotNull("Couldn't manage to find the format of the character to the right of the pasted text, after the paste operation!", rightAfter);
                assertTrue("The style of the original text has been altered! (right)", TextLayoutFormat.isEqual(rightBefore, rightAfter));
            }
        }

        private function recordTextFormatsBeforeOperation(pastePosition:int):void
        {
            leftBefore = pastePosition ? getFormatOfCharAt(pastePosition - 1) : null;
            rightBefore = pastePosition < initialTextLength - 1 ? getFormatOfCharAt(pastePosition + 1) : null;
        }

        private function recordTextFormatsAfterOperation(pastePosition:int):void
        {
            leftAfter = pastePosition ? getFormatOfCharAt(pastePosition - 1) : null;
            rightAfter = pastePosition < initialTextLength - 1 ? getFormatOfCharAt(pastePosition + 1 + PASTED_TEXT.length) : null;
        }

        private function getFormatOfCharAt(position:int, flow:TextFlow = null):ITextLayoutFormat
        {
            return getFormatOfCharFromFlow(position, flow || SelManager.textFlow);
        }

        private static function getFormatOfCharFromFlow(position:int, flow:TextFlow):ITextLayoutFormat
        {
            const elementAtPosition:FlowElement = flow.findLeaf(position);
            return elementAtPosition ? elementAtPosition.format : null;
        }

        private function assertTextPastedCorrectlyAndExistingTextNotChanged(pastePosition:int):void
        {
            const currentSourceAsPlainText:String = TextConverter.export(testApp.getTextFlow(), TextConverter.PLAIN_TEXT_FORMAT, ConversionType.STRING_TYPE) as String;
            assertEquals("Not all the pasted content appears in the new TextFlow!", sourceAsPlainText.substr(0, pastePosition) + PASTED_TEXT + "\n" + sourceAsPlainText.substr(pastePosition), currentSourceAsPlainText);
        }
    }
}