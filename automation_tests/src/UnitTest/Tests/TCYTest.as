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
    import UnitTest.ExtendedClasses.LoadingFileRule;
    import UnitTest.ExtendedClasses.VellumTestCase;
    import UnitTest.Fixtures.TestConfig;

    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.ErrorEvent;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.engine.TextLine;

    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.conversion.TextConverter;
    import flashx.textLayout.edit.*;
    import flashx.textLayout.elements.DivElement;
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.elements.FlowGroupElement;
    import flashx.textLayout.elements.FlowLeafElement;
    import flashx.textLayout.elements.LinkElement;
    import flashx.textLayout.elements.ParagraphElement;
    import flashx.textLayout.elements.SpanElement;
    import flashx.textLayout.elements.TCYElement;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.events.FlowElementMouseEvent;
    import flashx.textLayout.formats.TextLayoutFormat;
    import flashx.textLayout.tlf_internal;
    import flashx.textLayout.utils.GeometryUtil;

    import mx.containers.Canvas;

    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertTrue;
    import org.flexunit.asserts.fail;
    import org.flexunit.async.Async;

    use namespace tlf_internal;

    [TestCase(order=37)]
    public class TCYTest extends VellumTestCase
    {
        [Rule]
        public var loadingFileRule:LoadingFileRule = new LoadingFileRule("../../test/testFiles/markup/tlf/tcyTestBase.xml");

        public function TCYTest()
        {
            super("", "TCYTest", TestConfig.getInstance());
            TestData.fileName = "tcyTestBase.xml";
            metaData = {};
            // moving this to suiteFromXML
            //readTestFile(TestData.fileName);

            // Note: These must correspond to a Watson product area (case-sensitive)
            metaData.productArea = "TCY";
        }

        [Before]
        override public function setUpTest():void
        {
            super.setUpTest();
        }

        [Test]
        public function makeLTR_TCYTest():void
        {
            verifyLoad();

            SelManager.selectRange(15, 22);
            var tcyElement:TCYElement = SelManager.applyTCY(true);
            var leaf:FlowLeafElement = SelManager.textFlow.findLeaf(15);
            var tcyStart:TCYElement = leaf.getParentByType(TCYElement) as TCYElement;
            assertTrue("EditManager.applyTCY not returning first tcy Created", tcyStart == tcyElement);
        }

        [Test]
        public function makeRTL_TCYTest():void
        {
            verifyLoad();

            SelManager.selectRange(62, 73);
            SelManager.applyTCY(true);
        }

        [Test]
        public function makeJ_TCYTest():void
        {
            verifyLoad();

            SelManager.selectRange(31, 34);
            SelManager.applyTCY(true);
        }

        [Test]
        public function headOfLineTest():void
        {
            verifyLoad();

            SelManager.selectRange(0, 0);
            SelManager.insertText("TCY");
            SelManager.selectRange(0, 3);
            SelManager.applyTCY(true);

            var fbe:FlowGroupElement = SelManager.textFlow.findAbsoluteFlowGroupElement(0);

            assertTrue("TCY was not applied to line head!", fbe is TCYElement);
        }

        [Test]
        public function endOfLineTest():void
        {
            verifyLoad();

            var lastIndx:int = SelManager.textFlow.textLength - 1;

            SelManager.selectRange(lastIndx, lastIndx);
            SelManager.insertText("TCY");
            SelManager.selectRange(lastIndx, lastIndx + 3);
            SelManager.applyTCY(true);

            var fbe:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(lastIndx + 1);

            assertTrue("TCY was not applied to line end!", fbe is TCYElement);
        }

        [Test]
        public function linkCrossingTCYTest():void
        {
            verifyLoad();

            var half:int = SelManager.textFlow.textLength / 2;

            SelManager.selectRange(half, half);
            SelManager.insertText("TCY");
            SelManager.selectRange(half, half + 3);
            SelManager.applyTCY(true);

            var fbe:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(half + 1);

            assertTrue("TCY was not applied to line!", fbe is TCYElement);

            SelManager.selectRange(half + 2, half + 5);
            SelManager.applyLink(
                    "http://www.google.com",
                    "_self",
                    false
            );

            var fl:FlowElement = SelManager.textFlow.findLeaf(half + 4) as FlowElement;
            var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;

            assertTrue("Link Element was created spanning a TCY element!", linkEl == null);
        }

        [Test]
        public function linkInsideTCYTest():void
        {
            verifyLoad();

            var half:int = SelManager.textFlow.textLength / 2;

            SelManager.selectRange(half, half);
            SelManager.insertText("TCY");
            SelManager.selectRange(half, half + 3);
            SelManager.applyTCY(true);

            var fbe:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(half + 1);

            assertTrue("TCY was not applied to line!", fbe is TCYElement);

            SelManager.selectRange(half, half + 3);
            SelManager.applyLink(
                    "http://www.google.com",
                    "_self",
                    false
            );

            var fl:FlowElement = SelManager.textFlow.findLeaf(half + 2) as FlowElement;
            var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;

            assertTrue("Link Element was not created in the TCY element!", linkEl != null);
            assertTrue("Link Element was not created in the TCY element!", linkEl.target == "_self");
            assertTrue("Link Element was not created in the TCY element!", linkEl.href == "http://www.google.com");
        }

        [Test]
        public function inlineInsideTCYTest():void
        {
            verifyLoad();

            var half:int = SelManager.textFlow.textLength / 2;

            SelManager.selectRange(half, half);
            SelManager.insertText("TCY");
            SelManager.selectRange(half, half + 3);
            SelManager.applyTCY(true);

            var fbe:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(half + 1);

            assertTrue("TCY was not applied to line!", fbe is TCYElement);

            var displayObject:Sprite = new Sprite();
            var g:Graphics = displayObject.graphics;
            g.beginFill(0xFF0000);
            g.drawRect(0, 0, 50, 50);
            g.endFill();

            SelManager.selectRange(half + 2, half + 2);
            SelManager.insertInlineGraphic(displayObject, 50, 50);
            // bug #2724129 - the line above caused a RTE before the fix.
        }

        [Test]
        [Ignore]
        public function undoOverlappingTCYTest():void
        {
            verifyLoad();

            var half:int = SelManager.textFlow.textLength / 2;
            half = half - 6;

            SelManager.selectRange(half, half);
            SelManager.insertText("TCY");
            SelManager.selectRange(half, half + 3);
            SelManager.applyTCY(true);

            var fbe:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(half + 1);

            SelManager.flushPendingOperations();

            assertTrue("TCY was not applied to line!", fbe is TCYElement);

            SelManager.selectRange(half - 1, half + 1);
            SelManager.applyTCY(true);

            SelManager.flushPendingOperations();

            var fge:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(half);

            assertTrue("TCY was not applied to line!", fge is TCYElement);
            assertTrue("TCY was merged with previous TCY!", fge != fbe);

            SelManager.undo();

            var fge2:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(half + 1);

            assertTrue("TCY Element was not reconstituted correctly on undo",
                    fge2.getAbsoluteStart() == fbe.getAbsoluteStart() &&
                    fge2.textLength == fbe.textLength
            );
            assertTrue("Ghost TCY Element still points to valid text flow after removal.",
                    fge.getTextFlow() == null
            );
        }

        [Test]
        public function paragraphCrossingTCYTest():void
        {
            verifyLoad();

            var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(0);
            var absoluteParaStart:int = para.getAbsoluteStart();
            var end:int = absoluteParaStart + para.textLength;

            SelManager.selectRange(end, end);
            SelManager.insertText("TCYYCT");
            SelManager.selectRange(end, end + 6);
            SelManager.applyTCY(true);

            SelManager.selectRange(end + 3, end + 3);
            SelManager.splitParagraph();
            SelManager.flushPendingOperations();

            var first:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(end + 1);
            var second:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(end + 5);

            assertTrue("TCY was not applied to first line!", first is TCYElement);
            assertTrue("TCY was not applied to second line!", second is TCYElement);
            assertFalse("First and second TCYs are the same FlowGroupElement!", first === second);
        }

        [Test]
        public function tcySplittingTest():void
        {
            verifyLoad();
            var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(0);
            var absoluteParaStart:int = para.getAbsoluteStart();
            var end:int = absoluteParaStart + para.textLength;
            var half:int = end / 2;

            SelManager.selectRange(half, half);
            SelManager.insertText("HelloWorld");
            SelManager.selectRange(half, half + 10);
            SelManager.applyTCY(true);
            SelManager.selectRange(half, half + 5);
            var format:TextLayoutFormat = new TextLayoutFormat();
            format.fontFamily = "Arial";
            format.fontSize = 56;
            format.blockProgression = "tb";
            (SelManager as IEditManager).applyLeafFormat(format);
            SelManager.selectRange(half + 5, half + 10);
            format.fontSize = 36;
            (SelManager as IEditManager).applyLeafFormat(format);
            SelManager.selectRange(half + 5, half + 5);
            SelManager.splitParagraph();
            SelManager.flushPendingOperations();

            var spanHello:FlowGroupElement = SelManager.textFlow.findAbsoluteFlowGroupElement(half + 2);
            var spanWorld:FlowGroupElement = SelManager.textFlow.findAbsoluteFlowGroupElement(half + 7);

            assertTrue("TCY was not applied to first line!", spanHello is TCYElement);
            assertTrue("TCY was not applied to second line!", spanWorld is TCYElement);
        }

        [Test]
        public function overwriteTextLeftOfTCYTest():void
        {
            verifyLoad();
            SelManager.selectRange(15, 22);
            SelManager.applyTCY(true);

            SelManager.selectRange(14, 15);
            SelManager.insertText("d");

            SelManager.flushPendingOperations();

            var tcy:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(15);
            var left:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(14);

            assertTrue("Text left of TCY was added to TCY!", !(left is TCYElement));
            assertTrue("TCY was altered by insertion of text outside TCY!", tcy is TCYElement);
            assertTrue("TCY element length changed!", tcy.textLength == 7);
        }

        [Test]
        public function overwriteTextRightOfTCYTest():void
        {
            verifyLoad();
            SelManager.selectRange(15, 22);
            SelManager.applyTCY(true);

            SelManager.selectRange(22, 23);
            SelManager.insertText("d");

            SelManager.flushPendingOperations();

            var tcy:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(21);
            var right:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(22);

            assertTrue("Text right of TCY was added to TCY!", !(right is TCYElement));
            assertTrue("TCY was altered by insertion of text outside TCY!", tcy is TCYElement);
            assertTrue("TCY element length changed!", tcy.textLength == 7);
        }

        [Test]
        public function overwriteFirstCharOfTCYTest():void
        {
            verifyLoad();
            SelManager.selectRange(15, 22);
            SelManager.applyTCY(true);

            SelManager.selectRange(15, 16);
            SelManager.insertText("d");

            SelManager.flushPendingOperations();

            var tcy:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(19);
            assertTrue("Expected TCY at this position!", tcy is TCYElement);
            assertTrue("TCY element length changed!", tcy.textLength == 7);

        }

        [Test]
        public function overwriteLastCharOfTCYTest():void
        {
            verifyLoad();
            SelManager.selectRange(15, 22);
            SelManager.applyTCY(true);

            SelManager.selectRange(21, 22);
            SelManager.insertText("d");

            SelManager.flushPendingOperations();

            var tcy:FlowGroupElement =
                    SelManager.textFlow.findAbsoluteFlowGroupElement(19);
            assertTrue("Expected TCY at this position!", tcy is TCYElement);
            assertTrue("TCY element length changed!", tcy.textLength == 7);
        }

        [Test]
        public function makeAllIntoTCY():void
        {
            verifyLoad();
            SelManager.selectAll();
            SelManager.applyTCY(true);

            SelManager.flushPendingOperations();

            var elem:FlowLeafElement = SelManager.textFlow.getFirstLeaf();
            var para:ParagraphElement = elem.getParagraph();
            var paraIter:int = 0;
            while (para != null)
            {
                assertTrue("Each paragraph should only have 1 element! Paragraph number " + paraIter, para.numChildren == 1);
                assertTrue("All paragraph elements should only have a TCY Element! Paragraph number " + paraIter, para.getChildAt(0) is TCYElement);
                para = para.getNextParagraph();
                ++paraIter;
            }
        }

        private function verifyLoad():void
        {
            TestFrame.textFlow.flowComposer.updateAllControllers();

            SelManager.selectRange(0, 0);
        }

        private var tf:TextFlow = new TextFlow();

        [Test(async)]
        public function tcyMouseDownEventMirrorTest():void
        {
            SelManager.selectAll();
            SelManager.deleteText();

            var format:TextLayoutFormat = new TextLayoutFormat();
            format.fontFamily = "Arial";
            format.fontSize = 16;
            format.direction = "ltr";
            format.blockProgression = "rl";
            tf.hostFormat = format;
            var p:ParagraphElement = new ParagraphElement();
            tf.addChild(p);
            var span:SpanElement = new SpanElement();
            span.text = "\nこれは縦中横テストです";
            p.addChild(span);
            var editmanager:EditManager = new EditManager();
            tf.interactionManager = editmanager;
            editmanager.selectRange(4, 7);
            var tcy:TCYElement = editmanager.applyTCY(true);

            tcy.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_DOWN,
                    Async.asyncHandler(this, checkMouseDownEvent, 50, {timeOut: "Timeout reached checkMouseDownEvent"}, tcyTestsTimeout), false, 0, true);

            var container:Sprite = new Sprite();
            var TestCanvas:Canvas = testApp.getDisplayObject();
            TestCanvas.rawChildren.addChild(container);

            var cc:ContainerController = new ContainerController(container, 200, 400);
            tf.flowComposer.addController(cc);
            tf.flowComposer.updateAllControllers();

            var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
            var bounds:Rectangle = boundsInfo.rect as Rectangle;
            var textLine:TextLine = boundsInfo.textLine;
            tf.interactionManager = null;
            var mouseDownEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine);
            textLine.dispatchEvent(mouseDownEvent);
            tf.interactionManager = editmanager;
            editmanager.selectRange(0, 0);
        }

        [Test(async)]
        public function tcyMouseClickEventMirrorTest():void
        {
            SelManager.selectAll();
            SelManager.deleteText();

            var format:TextLayoutFormat = new TextLayoutFormat();
            format.fontFamily = "Arial";
            format.fontSize = 16;
            format.direction = "ltr";
            format.blockProgression = "rl";
            tf.hostFormat = format;
            var p:ParagraphElement = new ParagraphElement();
            tf.addChild(p);
            var span:SpanElement = new SpanElement();
            span.text = "\nこれは縦中横テストです";
            p.addChild(span);
            var editmanager:EditManager = new EditManager();
            tf.interactionManager = editmanager;
            editmanager.selectRange(4, 7);
            var tcy:TCYElement = editmanager.applyTCY(true);

            tcy.getEventMirror().addEventListener(FlowElementMouseEvent.CLICK,
                    Async.asyncHandler(this, checkMouseClickEvent, 50, {timeOut: "Timeout reached checkMouseClickEvent"}, tcyTestsTimeout), false, 0, true);

            var container:Sprite = new Sprite();
            var TestCanvas:Canvas = testApp.getDisplayObject();
            TestCanvas.rawChildren.addChild(container);

            var cc:ContainerController = new ContainerController(container, 200, 400);
            tf.flowComposer.addController(cc);
            tf.flowComposer.updateAllControllers();

            // Get the bounds of the link in TextLine coordinates
            var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
            var bounds:Rectangle = boundsInfo.rect as Rectangle;
            var textLine:TextLine = boundsInfo.textLine;

            tf.interactionManager = null;
            //dispatch mouse events
            textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            textLine.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));

            tf.interactionManager = editmanager;
            editmanager.selectRange(0, 0);
        }

        [Test(async)]
        public function tcyMouseMoveEventMirrorTest():void
        {
            SelManager.selectAll();
            SelManager.deleteText();

            var format:TextLayoutFormat = new TextLayoutFormat();
            format.fontFamily = "Arial";
            format.fontSize = 16;
            format.direction = "ltr";
            format.blockProgression = "rl";
            tf.hostFormat = format;
            var p:ParagraphElement = new ParagraphElement();
            tf.addChild(p);
            var span:SpanElement = new SpanElement();
            span.text = "\nこれは縦中横テストです";
            p.addChild(span);
            var editmanager:EditManager = new EditManager();
            tf.interactionManager = editmanager;
            editmanager.selectRange(4, 7);
            var tcy:TCYElement = editmanager.applyTCY(true);

            tcy.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_MOVE,
                    Async.asyncHandler(this, checkMouseMoveEvent, 50, {timeOut: "Timeout reached checkMouseMoveEvent"}, tcyTestsTimeout), false, 0, true);

            var container:Sprite = new Sprite();
            var TestCanvas:Canvas = testApp.getDisplayObject();
            TestCanvas.rawChildren.addChild(container);

            var cc:ContainerController = new ContainerController(container, 200, 400);
            tf.flowComposer.addController(cc);
            tf.flowComposer.updateAllControllers();

            // Get the bounds of the link in TextLine coordinates
            var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
            var bounds:Rectangle = boundsInfo.rect as Rectangle;
            var textLine:TextLine = boundsInfo.textLine;

            tf.interactionManager = null;

            textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            tf.interactionManager = editmanager;
            editmanager.selectRange(0, 0);
        }

        [Test(async)]
        public function tcyMouseUpEventMirrorTest():void
        {
            SelManager.selectAll();
            SelManager.deleteText();

            var format:TextLayoutFormat = new TextLayoutFormat();
            format.fontFamily = "Arial";
            format.fontSize = 16;
            format.direction = "ltr";
            format.blockProgression = "rl";
            tf.hostFormat = format;

            var p:ParagraphElement = new ParagraphElement();
            tf.addChild(p);
            var span:SpanElement = new SpanElement();
            span.text = "\nこれは縦中横テストです";
            p.addChild(span);
            var editmanager:EditManager = new EditManager();
            tf.interactionManager = editmanager;
            editmanager.selectRange(4, 7);
            var tcy:TCYElement = editmanager.applyTCY(true);

            tcy.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_UP,
                    Async.asyncHandler(this, checkMouseUpEvent, 50, {timeOut: "Timeout reached checkMouseUpEvent"}, tcyTestsTimeout), false, 0, true);

            var container:Sprite = new Sprite();
            var TestCanvas:Canvas = testApp.getDisplayObject();
            TestCanvas.rawChildren.addChild(container);

            var cc:ContainerController = new ContainerController(container, 200, 400);
            tf.flowComposer.addController(cc);
            tf.flowComposer.updateAllControllers();

            var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
            var bounds:Rectangle = boundsInfo.rect as Rectangle;
            var textLine:TextLine = boundsInfo.textLine;
            tf.interactionManager = null;

            textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));

            tf.interactionManager = editmanager;
            editmanager.selectRange(0, 0);
        }

        [Test(async)]
        public function tcyRollOverEventMirrorTest():void
        {
            SelManager.selectAll();
            SelManager.deleteText();

            var format:TextLayoutFormat = new TextLayoutFormat();
            format.fontFamily = "Arial";
            format.fontSize = 16;
            format.direction = "ltr";
            format.blockProgression = "rl";
            tf.hostFormat = format;
            var p:ParagraphElement = new ParagraphElement();
            tf.addChild(p);
            var span:SpanElement = new SpanElement();
            span.text = "\nこれは縦中横テストです";
            p.addChild(span);
            var editmanager:EditManager = new EditManager();
            tf.interactionManager = editmanager;
            editmanager.selectRange(4, 7);
            var tcy:TCYElement = editmanager.applyTCY(true);

            tcy.getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OVER,
                    Async.asyncHandler(this, checkMouseRollOverEvent, 2500, {timeOut: "Timeout reached checkMouseRollOverEvent"}, tcyTestsTimeout), false, 0, true);

            var container:Sprite = new Sprite();
            var TestCanvas:Canvas = testApp.getDisplayObject();
            TestCanvas.rawChildren.addChild(container);

            var cc:ContainerController = new ContainerController(container, 200, 400);
            tf.flowComposer.addController(cc);
            tf.flowComposer.updateAllControllers();

            var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
            var bounds:Rectangle = boundsInfo.rect as Rectangle;
            var textLine:TextLine = boundsInfo.textLine;

            tf.interactionManager = null;

            textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            textLine.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));

            tf.interactionManager = editmanager;
            editmanager.selectRange(0, 0);
        }

        [Test(async)]
        public function tcyRollOutEventMirrorTest():void
        {
            SelManager.selectAll();
            SelManager.deleteText();

            var format:TextLayoutFormat = new TextLayoutFormat();
            format.fontFamily = "Arial";
            format.fontSize = 16;
            format.direction = "ltr";
            format.blockProgression = "rl";
            tf.hostFormat = format;

            var p:ParagraphElement = new ParagraphElement();
            tf.addChild(p);
            var span:SpanElement = new SpanElement();
            span.text = "\nこれは縦中横テストです";
            p.addChild(span);
            var editmanager:EditManager = new EditManager();
            tf.interactionManager = editmanager;
            editmanager.selectRange(4, 7);
            var tcy:TCYElement = editmanager.applyTCY(true);

            tcy.getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OUT,
                    Async.asyncHandler(this, checkMouseRollOutEvent, 2500, {timeOut: "Timeout reached checkMouseRollOutEvent"}, tcyTestsTimeout), false, 0, true);

            var container:Sprite = new Sprite();
            var TestCanvas:Canvas = testApp.getDisplayObject();
            TestCanvas.rawChildren.addChild(container);

            var cc:ContainerController = new ContainerController(container, 200, 400);
            tf.flowComposer.addController(cc);
            tf.flowComposer.updateAllControllers();

            var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
            var bounds:Rectangle = boundsInfo.rect as Rectangle;
            var textLine:TextLine = boundsInfo.textLine;
            tf.interactionManager = null;
            textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true, false, bounds.right + 1, bounds.bottom + 1, textLine));
            textLine.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            tf.interactionManager = editmanager;
            editmanager.selectRange(0, 0);
        }

        /**
         * FIXME: Events commented in this method do not work - please fix if you can
         */
        [Test(async)]
        public function tcyAllMouseEventMirrorTest():void
        {
            SelManager.selectAll();
            SelManager.deleteText();

            var format:TextLayoutFormat = new TextLayoutFormat();
            format.fontFamily = "Arial";
            format.fontSize = 16;
            format.direction = "ltr";
            format.blockProgression = "rl";
            tf.hostFormat = format;
            var p:ParagraphElement = new ParagraphElement();
            tf.addChild(p);
            var span:SpanElement = new SpanElement();
            span.text = "\nこれは縦中横テストです";
            p.addChild(span);
            var editmanager:EditManager = new EditManager();
            tf.interactionManager = editmanager;
            editmanager.selectRange(4, 7);
            var tcy:TCYElement = editmanager.applyTCY(true);
            //listen for all FlowElementMouseEvents
            tcy.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_DOWN, Async.asyncHandler(this, checkMouseDownEvent, 100, {timeOut: "Timeout reached checkMouseDownEvent"}, tcyTestsTimeout));
            tcy.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_UP, Async.asyncHandler(this, checkMouseUpEvent, 100, {timeOut: "Timeout reached checkMouseUpEvent"}, tcyTestsTimeout));
            tcy.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_MOVE, Async.asyncHandler(this, checkMouseMoveEvent, 100, {timeOut: "Timeout reached checkMouseMoveEvent"}, tcyTestsTimeout));

           /* tcy.getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OVER, Async.asyncHandler(this, checkMouseRollOverEvent, 200, {timeOut: "Timeout reached checkMouseRollOverEvent"}, tcyTestsTimeout));
            tcy.getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OUT, Async.asyncHandler(this, checkMouseRollOutEvent, 200, {timeOut: "Timeout reached checkMouseRollOutEvent"}, tcyTestsTimeout));
            tcy.getEventMirror().addEventListener(FlowElementMouseEvent.CLICK, Async.asyncHandler(this, checkMouseClickEvent, 2000, {timeOut: "Timeout reached checkMouseClickEvent"}, tcyTestsTimeout));
               */
            var container:Sprite = new Sprite();
            var TestCanvas:Canvas = testApp.getDisplayObject();
            TestCanvas.rawChildren.addChild(container);

            var cc:ContainerController = new ContainerController(container, 200, 400);
            tf.flowComposer.addController(cc);
            tf.flowComposer.updateAllControllers();

            // Get the bounds of the link in TextLine coordinates
            var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
            var bounds:Rectangle = boundsInfo.rect as Rectangle;
            var textLine:TextLine = boundsInfo.textLine;
            tf.interactionManager = null;
            //dispatch all mouse events
            textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            /*textLine.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            textLine.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            textLine.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
            textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true, false, bounds.right + 1, bounds.bottom + 1, textLine));    */

            tf.interactionManager = editmanager;
            editmanager.selectRange(0, 0);
        }

        private function checkMouseDownEvent(e:FlowElementMouseEvent, passThroughData:Object):void
        {
            assertTrue("mouseDown event is not fired", !(e is ErrorEvent));
            tf.removeEventListener(FlowElementMouseEvent.MOUSE_DOWN, checkMouseDownEvent);
        }

        private function checkMouseUpEvent(e:FlowElementMouseEvent, passThroughData:Object):void
        {
            assertTrue("mouseUp event is not fired", !(e is ErrorEvent));
            tf.removeEventListener(FlowElementMouseEvent.MOUSE_UP, checkMouseUpEvent);
        }

        private function checkMouseClickEvent(e:FlowElementMouseEvent, passThroughData:Object):void
        {
            assertTrue("mouseClick event is not fired", !(e is ErrorEvent));
            tf.removeEventListener(FlowElementMouseEvent.CLICK, checkMouseClickEvent);
        }

        private function checkMouseMoveEvent(e:FlowElementMouseEvent, passThroughData:Object):void
        {
            assertTrue("mouseMove event is not fired", !(e is ErrorEvent));
            tf.removeEventListener(FlowElementMouseEvent.MOUSE_MOVE, checkMouseMoveEvent);
        }

        private function checkMouseRollOverEvent(e:FlowElementMouseEvent, passThroughData:Object):void
        {
            assertTrue("mouseRollOver event is not fired", !(e is ErrorEvent));
            tf.removeEventListener(FlowElementMouseEvent.ROLL_OVER, checkMouseRollOverEvent);
        }

        private function checkMouseRollOutEvent(e:FlowElementMouseEvent, passThroughData:Object):void
        {
            assertTrue("mouseRollOut event is not fired", !(e is ErrorEvent));
            tf.removeEventListener(FlowElementMouseEvent.ROLL_OUT, checkMouseRollOutEvent);
        }

        private function tcyTestsTimeout(passThroughData:Object = null):void
        {
            fail(passThroughData.timeOut);
        }

        [Test]
        public function addDivInTcyTest():void
        {
            SelManager.selectAll();
            SelManager.deleteText();

            var format:TextLayoutFormat = new TextLayoutFormat();
            format.fontFamily = "Arial";
            format.fontSize = 16;
            format.direction = "ltr";
            format.blockProgression = "rl";
            tf.hostFormat = format;
            var p:ParagraphElement = new ParagraphElement();
            tf.addChild(p);
            var span:SpanElement = new SpanElement();
            span.text = "\nこれは縦中横テストです";
            p.addChild(span);

            var divElement:DivElement = SelManager.createDiv();
            divElement.addChild(p);
            var tcyElement:TCYElement = new TCYElement();
            try
            {
                tcyElement.addChild(divElement);
            } catch (e:Error)
            {
                assertTrue("There should be error returned when adding Div to Tcy.", e != null);
            }
        }

        /**
         * mjzhang : Bug#2808701 RTE removing TCY from a span in a link at the beginning of a flow
         */
        [Test]
        public function disableTCYTest():void
        {
            SelManager.selectAll();
            SelManager.deleteText();

            var textFlow:TextFlow = SelManager.textFlow;
            var markup:String = '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><a href="asdf"><tcy><span>a</span></tcy></a></p></TextFlow>';
            var textFlowNew:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);

            var paraElement:ParagraphElement = textFlowNew.getChildAt(0) as ParagraphElement;
            var paraElementCopy:ParagraphElement = paraElement.deepCopy(0, paraElement.textLength) as ParagraphElement;
            textFlow.replaceChildren(0, textFlow.numChildren, paraElementCopy);

            SelManager.selectAll();
            try
            {
                SelManager.applyTCY(false);
            } catch (e:Error)
            {
                assertTrue("Expect TCY disabled normally, but we met error/exception.", false);
            }
        }
    }
}
