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

    import org.flexunit.asserts.assertEquals;

    public class FLEX_34807_Test extends VellumTestCase
    {
        private const PASTED_TEXT:String = '...Hello world!...';
        private const PASTED_HTML:String = '...<i>Hello<b> world</b>!</i>...';
        private const PASTE:TextScrap = new TextScrap(TextConverter.importToFlow(PASTED_HTML, TextConverter.TEXT_FIELD_HTML_FORMAT));

        private var sourceAsPlainText:String;

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
            SelManager.selectFirstPosition();

            //when
            SelManager.pasteTextScrap(PASTE);

            //then
            const result:String = TextConverter.export(testApp.getTextFlow(), TextConverter.PLAIN_TEXT_FORMAT, ConversionType.STRING_TYPE) as String;
            assertAllTextHasBeenPasted(result, 0);
        }

        [Test]
        public function paste_in_first_paragraph():void
        {
            //given
            const PASTE_POSITION:int = 5; //after "That"
            SelManager.selectRange(PASTE_POSITION, PASTE_POSITION);

            //when
            SelManager.pasteTextScrap(PASTE);

            //then
            const result:String = TextConverter.export(testApp.getTextFlow(), TextConverter.PLAIN_TEXT_FORMAT, ConversionType.STRING_TYPE) as String;
            assertAllTextHasBeenPasted(result, PASTE_POSITION);
        }

        [Test]
        public function paste_in_first_paragraph_in_middle_of_bold_section():void
        {
            //given
            const PASTE_POSITION:int = 16;
            SelManager.selectRange(PASTE_POSITION, PASTE_POSITION);

            //when
            SelManager.pasteTextScrap(PASTE);

            //then
            const result:String = TextConverter.export(testApp.getTextFlow(), TextConverter.PLAIN_TEXT_FORMAT, ConversionType.STRING_TYPE) as String;
            assertAllTextHasBeenPasted(result, PASTE_POSITION);
        }

        private function assertAllTextHasBeenPasted(currentSourceAsPlainText:String, pastePosition:int):void
        {
            assertEquals("Not all the pasted content appears in the new TextFlow!", sourceAsPlainText.substr(0, pastePosition) + PASTED_TEXT + sourceAsPlainText.substr(pastePosition), currentSourceAsPlainText);
        }
    }
}