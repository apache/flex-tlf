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
    import UnitTest.Fixtures.FileRepository;
    import UnitTest.Fixtures.TestConfig;

    import flashx.textLayout.conversion.ConversionType;
    import flashx.textLayout.conversion.TextConverter;
    import flashx.textLayout.edit.TextScrap;
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.formats.ITextLayoutFormat;
    import flashx.textLayout.formats.TextLayoutFormat;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertTrue;

    public class FLEX_34807_Test extends VellumTestCase
    {
        private const PASTED_TEXT:String = '...Hello world!...';
        private const PASTED_HTML:String = '...<i>Hello<b> world</b>!</i>...';
        private const PASTE:TextScrap = new TextScrap(TextConverter.importToFlow(PASTED_HTML, TextConverter.TEXT_FIELD_HTML_FORMAT));

        private var sourceAsPlainText:String;
        private var leftBefore:ITextLayoutFormat;
        private var rightBefore:ITextLayoutFormat;
        private var leftAfter:ITextLayoutFormat;
        private var rightAfter:ITextLayoutFormat;

        public function FLEX_34807_Test()
        {
            //	super(methodName, testID, testConfig, testCaseXML);
            super("", "FLEX_34807_Test", TestConfig.getInstance());

            metaData = {};

            TestData.fileName = "HtmlTest.xml";
        }

        [BeforeClass]
        public static function setUpClass():void
        {
            FileRepository.readFile(TestConfig.getInstance().baseURL, "../../test/testFiles/markup/tlf/HtmlTest.xml");
        }

        [Before]
        override public function setUpTest():void
        {
            super.setUpTest();
            if(!sourceAsPlainText)
                sourceAsPlainText = TextConverter.export(testApp.getTextFlow(), TextConverter.PLAIN_TEXT_FORMAT, ConversionType.STRING_TYPE) as String;
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
            assertTextPastedCorrectlyAndExistingTextNotChanged(0);
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
            assertTextPastedCorrectlyAndExistingTextNotChanged(PASTE_POSITION);
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
            assertTextPastedCorrectlyAndExistingTextNotChanged(PASTE_POSITION);
        }

        private function assertAdjacentTextFormatsNotAltered(pastePosition:int):void
        {
            recordTextFormatsAfterOperation(pastePosition);
            assertAdjacentTextFormatsArePreserved(pastePosition);
        }

        private function assertAdjacentTextFormatsArePreserved(pastePosition:int):void
        {
            if(pastePosition)
            {
                assertNotNull(leftBefore);
                assertNotNull(leftAfter);
                assertTrue(TextLayoutFormat.isEqual(leftBefore, leftAfter));
            }

            if(pastePosition < SelManager.textFlow.textLength - 1)
            {
                assertNotNull(rightBefore);
                assertNotNull(rightAfter);
                assertTrue(TextLayoutFormat.isEqual(rightBefore, rightAfter));
            }
        }

        private function recordTextFormatsBeforeOperation(pastePosition:int):void
        {
            leftBefore = pastePosition ? getFormatOfCharAt(pastePosition - 1) : null;
            rightBefore = pastePosition < SelManager.textFlow.textLength - 1 ?  getFormatOfCharAt(pastePosition + 1) : null;
        }

        private function recordTextFormatsAfterOperation(pastePosition:int):void
        {
            leftAfter = pastePosition ? getFormatOfCharAt(pastePosition - 1) : null;
            rightAfter = pastePosition < SelManager.textFlow.textLength - PASTED_TEXT.length - 1 ? getFormatOfCharAt(pastePosition + 1 + PASTED_TEXT.length) : null;
        }

        private function getFormatOfCharAt(pastePosition:int):ITextLayoutFormat
        {
            const charLeftOfPasteBeforeOperation:FlowElement = SelManager.textFlow.findLeaf(pastePosition);
            return charLeftOfPasteBeforeOperation ? charLeftOfPasteBeforeOperation.format : null;
        }

        private function assertTextPastedCorrectlyAndExistingTextNotChanged(pastePosition:int):void
        {
            const currentSourceAsPlainText:String = TextConverter.export(testApp.getTextFlow(), TextConverter.PLAIN_TEXT_FORMAT, ConversionType.STRING_TYPE) as String;
            assertEquals("Not all the pasted content appears in the new TextFlow!", sourceAsPlainText.substr(0, pastePosition) + PASTED_TEXT + sourceAsPlainText.substr(pastePosition), currentSourceAsPlainText);
        }
    }
}