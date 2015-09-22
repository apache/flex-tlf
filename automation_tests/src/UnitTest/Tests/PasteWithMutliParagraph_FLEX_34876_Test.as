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
package UnitTest.Tests
{
    import UnitTest.ExtendedClasses.VellumTestCase;
    import UnitTest.Fixtures.TestConfig;

    import flash.text.engine.ContentElement;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;

    import flashx.textLayout.compose.TextFlowLine;
    import flashx.textLayout.conversion.TextConverter;
    import flashx.textLayout.edit.EditManager;
    import flashx.textLayout.edit.TextClipboard;
    import flashx.textLayout.edit.TextScrap;
    import flashx.textLayout.elements.ParagraphElement;
    import flashx.textLayout.elements.SpanElement;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.tlf_internal;

    import org.flexunit.asserts.assertTrue;

    use namespace tlf_internal;

    [TestCase(order=44)]
    public class PasteWithMutliParagraph_FLEX_34876_Test extends VellumTestCase
    {
        private const inputString:String = "line 1\nline 2\nline 3\nline 4\nline 5";
        private const spanColor:uint = 0xFF0000;
        private const spanFontSize:int = 20;

        public function PasteWithMutliParagraph_FLEX_34876_Test()
        {
            super("", "PasteWithMutliParagraph_FLEX_34876_Test", TestConfig.getInstance());

            metaData = {};
        }

        [Before]
        override public function setUpTest():void
        {
            super.setUpTest();
        }

        [After]
        public override function tearDownTest():void
        {
             super.tearDownTest();
        }

        [Test]
        public function multiLinePasteElementFormatCheckTest():void
        {
            reproduceIssueFlex_34876();

            var textFlowNumLines:int = SelManager.textFlow.flowComposer.numLines;
            var textFlowLine:TextFlowLine = null;
            var textLine:TextLine = null;
            var textBlock:TextBlock = null;
            var contentElement:ContentElement = null;
            var elementFormat:ElementFormat = null;

            for (var i:int = 0; i < textFlowNumLines; i++)
            {
                textFlowLine = SelManager.textFlow.flowComposer.getLineAt(i);
                textLine = textFlowLine.getTextLine();
                textBlock = textLine.textBlock;
                contentElement = textBlock.content;
                elementFormat = contentElement.elementFormat;

                assertTrue("Text color for TextFlowLine was not applied correctly", elementFormat.color == spanColor);
                assertTrue("Font size for TextFlowLine was not applied correctly", elementFormat.fontSize == spanFontSize);
            }
        }

        private function reproduceIssueFlex_34876():void
        {
            setUpFlowForTest(new TextFlow());

            var para:ParagraphElement = new ParagraphElement();
            var span:SpanElement = new SpanElement();
            span.color = spanColor;
            span.fontSize = spanFontSize;

            para.addChild(span);
            SelManager.textFlow.addChild(para);
            (SelManager.textFlow.interactionManager as EditManager).selectAll();

            var multiLineScrap:TextScrap = TextClipboard.importToScrap(inputString, TextConverter.PLAIN_TEXT_FORMAT);

            (SelManager.textFlow.interactionManager as EditManager).pasteTextScrap(multiLineScrap);
        }
    }
}
