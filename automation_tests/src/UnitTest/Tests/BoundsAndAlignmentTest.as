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
    import UnitTest.Fixtures.MeasureConstants;
    import UnitTest.Fixtures.TestConfig;
    import UnitTest.Validation.BoundsChecker;

    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.geom.Rectangle;

    import flashx.textLayout.compose.StandardFlowComposer;
    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.container.ScrollPolicy;
    import flashx.textLayout.conversion.TextConverter;
    import flashx.textLayout.edit.EditManager;
    import flashx.textLayout.edit.IEditManager;
    import flashx.textLayout.elements.InlineGraphicElementStatus;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.events.StatusChangeEvent;
    import flashx.textLayout.factory.StringTextLineFactory;
    import flashx.textLayout.factory.TextFlowTextLineFactory;
    import flashx.textLayout.formats.BlockProgression;
    import flashx.textLayout.formats.Direction;
    import flashx.textLayout.formats.TextLayoutFormat;

    import mx.containers.Canvas;

    import org.flexunit.asserts.assertTrue;
    import org.flexunit.asserts.fail;

    [RunWith("org.flexunit.runners.Parameterized")]
    public class BoundsAndAlignmentTest extends VellumTestCase implements IEventDispatcher
    {
        // Creation Types
        private static const USE_FLOW:String = "textFlow";
        private static const USE_FACTORY_FLOW:String = "factoryTF";

        private static var textAlignArray:Array = ["left", "center", "right", "start", "end" ];
        private static var verticalAlignArray:Array = ["top", "middle", "bottom"];

        private static var stringFactory:StringTextLineFactory = null;
        private static var textFlowFactory:TextFlowTextLineFactory = null;
        private static var labelFactory:StringTextLineFactory = null;

        public static var data:Array = [
            [
                {measureType: MeasureConstants.MEASURE_WIDTH, blockProgression: BlockProgression.TB, direction: Direction.LTR}
            ],
            [
                {measureType: MeasureConstants.MEASURE_WIDTH, blockProgression: BlockProgression.TB, direction: Direction.RTL}
            ],
            [
                {measureType: MeasureConstants.MEASURE_WIDTH, blockProgression: BlockProgression.RL, direction: Direction.LTR}
            ],
            [
                {measureType: MeasureConstants.MEASURE_WIDTH, blockProgression: BlockProgression.RL, direction: Direction.RTL}
            ],
            [
                {measureType: MeasureConstants.MEASURE_HEIGHT, blockProgression: BlockProgression.TB, direction: Direction.LTR}
            ],
            [
                {measureType: MeasureConstants.MEASURE_HEIGHT, blockProgression: BlockProgression.TB, direction: Direction.RTL}
            ],
            [
                {measureType: MeasureConstants.MEASURE_HEIGHT, blockProgression: BlockProgression.RL, direction: Direction.LTR}
            ],
            [
                {measureType: MeasureConstants.MEASURE_HEIGHT, blockProgression: BlockProgression.RL, direction: Direction.RTL}
            ],
            [
                {measureType: MeasureConstants.MEASURE_BOTH, blockProgression: BlockProgression.TB, direction: Direction.LTR}
            ],
            [
                {measureType: MeasureConstants.MEASURE_BOTH, blockProgression: BlockProgression.TB, direction: Direction.RTL}
            ],
            [
                {measureType: MeasureConstants.MEASURE_BOTH, blockProgression: BlockProgression.RL, direction: Direction.LTR}
            ],
            [
                {measureType: MeasureConstants.MEASURE_BOTH, blockProgression: BlockProgression.RL, direction: Direction.RTL}
            ]
        ];

        private var width:Number = 100;
        private var height:Number = 100;

        private var _blockProgression:String;
        private var _direction:String;
        private var _creationType:String;
        private var _lineBreak:String;
        private var _measureType:String;
        private var eventDispatcher:EventDispatcher;
        // bounds and format of last sprite for comparison function
        private var compareBounds:Rectangle;

        private var tFlowBounds:Rectangle;

        private var notReadyGraphicsCount:int;

        private var scrollPolicy:String = ScrollPolicy.ON;

        private var sprite:Sprite;
        private var testCanvas:Canvas;

        private var editManager:IEditManager;

        public function BoundsAndAlignmentTest()
        {
            super("", "BoundsAndAlignmentTest", TestConfig.getInstance(), null);

            eventDispatcher = new EventDispatcher();
            editManager = new EditManager();
            //reset containerType to avoid assert in tearDown
            containerType = "custom";

            _blockProgression = TestConfig.getInstance().writingDirection[0];
            _direction = TestConfig.getInstance().writingDirection[1];

            //reset ID to include more variables
            TestID = TestID + ":" + _measureType + ":" + _lineBreak;

            // enables snapshots for the measurementgridtest - DO NOT SUBMIT ENABLED - It takes too long!
            // TestData["bitmapSnapshot"] = "true";
            // Note: These must correspond to a Watson product area (case-sensitive)
            metaData = {};
            metaData.productArea = "Text Composition";
        }

        [BeforeClass]
        public static function setUpClass():void
        {
            stringFactory = new StringTextLineFactory();
            textFlowFactory = new TextFlowTextLineFactory();

            labelFactory = new StringTextLineFactory();
            var labelFormat:TextLayoutFormat = new TextLayoutFormat();
            labelFormat.fontSize = 12;
            labelFactory.spanFormat = labelFormat;
        }

        [AfterClass]
        public static function tearDownClass():void
        {
            stringFactory = null;
            textFlowFactory = null;
            labelFactory = null;
        }

        [Before]
        override public function setUpTest():void
        {
            super.setUpTest();

            cleanUpTestApp();
            TestDisplayObject = testApp.getDisplayObject();
            if (!TestDisplayObject)
            {
                fail("Did not get a blank canvas to work with");
            }
        }

        [After]
        override public function tearDownTest():void
        {
            super.tearDownTest();
        }


        /********************** Tests Start Here ***************************/

        [Test]
        public function simpleMultiParagraph():void
        {
            // This is a subset of simple.xml
            // Exposed Watson bug 2559210
            var markup:String = '<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" textIndent="15" paddingTop="4" paddingLeft="4" fontFamily="Times New Roman">' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>There are many </flow:span><flow:span fontStyle="italic">such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Sentences removed.</flow:span></flow:p>' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
                    '</flow:TextFlow>';

            runSingleTest(markup, insertText);
        }

        [Test]
        public function simpleMultiParagraphNoTextIndent():void
        {
            // This is a subset of simple.xml, and has NO first line indent applied to the paragraphs.
            var markup:String = '<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" paddingTop="4" paddingLeft="4" fontFamily="Times New Roman">' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>There are many </flow:span><flow:span fontStyle="italic">such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Sentences removed.</flow:span></flow:p>' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
                    '</flow:TextFlow>';

            runSingleTest(markup);
        }

        [Test]
        public function longSimpleMultiParagraph():void
        {
            // This is a longer version of simple.xml, so the text overflows the visible area and scrolls
            // Exposed Watson bug 2559210
            var markup:String = '<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" textIndent="15" paddingTop="4" paddingLeft="4" fontFamily="Times New Roman">' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>There are many </flow:span><flow:span fontStyle="italic">such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Sentences removed.</flow:span></flow:p>' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
                    '</flow:TextFlow>';

            runSingleTest(markup, insertText);
        }

        [Test]
        public function simpleMultiParagraphNegTextIndent():void
        {
            // This is a subset of simple.xml, and has NO first line indent applied to the paragraphs.
            var markup:String = '<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" textIndent="15" paddingTop="4" paddingLeft="4" fontFamily="Times New Roman">' +
                    '<flow:p paragraphSpaceAfter="30"><flow:span>There are many </flow:span><flow:span fontStyle="italic">such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Sentences removed.</flow:span></flow:p>' +
                    '<flow:p paragraphSpaceAfter="30"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
                    '</flow:TextFlow>';

            runSingleTest(markup);
        }

        [Test]
        public function simpleWithPaddingTopLeft():void
        {
            // This is a subset of simple.xml, and has NO first line indent applied to the paragraphs.
            var markup:String = '<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" paddingTop="40" paddingLeft="20">' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>There are many </flow:span><flow:span fontStyle="italic">such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Sentences removed.</flow:span></flow:p>' +
                    '<flow:p paragraphSpaceAfter="15"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
                    '</flow:TextFlow>';

            runSingleTest(markup);
        }

        [Test]
        public function simpleWithPaddingBottomRight():void
        {
            // This is a subset of simple.xml, and has NO first line indent applied to the paragraphs.
            var markup:String = '<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" paddingBottom="40" paddingRight="20">' +
                    '<flow:p><flow:span>There are many </flow:span><flow:span fontStyle="italic">such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Sentences removed.</flow:span></flow:p>' +
                    '<flow:p><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
                    '</flow:TextFlow>';

            runSingleTest(markup);
        }

        public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
        {
            eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }

        public function dispatchEvent(evt:Event):Boolean
        {
            return eventDispatcher.dispatchEvent(evt);
        }

        public function hasEventListener(type:String):Boolean
        {
            return eventDispatcher.hasEventListener(type);
        }

        public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
        {
            eventDispatcher.removeEventListener(type, listener, useCapture);
        }

        public function willTrigger(type:String):Boolean
        {
            return eventDispatcher.willTrigger(type);
        }

        // end of IEventDispatcher functions

        private function insertText(textFlow:TextFlow):void
        {
            textFlow.interactionManager = editManager;
            editManager.selectRange(textFlow.textLength, textFlow.textLength);
            editManager.insertText("INSERTED TEXT");
            var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
            controller.verticalScrollPosition = int.MAX_VALUE;
            textFlow.flowComposer.updateAllControllers();
        }

        private function addToCanvas(sprite:Sprite):void
        {
            TestDisplayObject = testApp.getDisplayObject();
            if (TestDisplayObject)
            {
                testCanvas = Canvas(TestDisplayObject);
                testCanvas.rawChildren.addChild(sprite);
            }
        }

        // Track the completion of loading inlines, dispatch a completion event when its done
        private function statusChangeHandler(obj:Event):void
        {
            var event:StatusChangeEvent = StatusChangeEvent(obj);
            var textFlow:TextFlow = event.element.getTextFlow();
            switch (event.status)
            {
                case InlineGraphicElementStatus.LOADING:
                case InlineGraphicElementStatus.SIZE_PENDING:
                    break;
                case InlineGraphicElementStatus.READY:
                    notReadyGraphicsCount--;
                    if (notReadyGraphicsCount <= 0)
                    {
                        textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, statusChangeHandler);
                        if (_creationType == USE_FLOW)
                        {
                            this.dispatchEvent(new Event("textFlowsReady"));
                        }
                        else if (_creationType == USE_FACTORY_FLOW)
                        {
                            this.dispatchEvent(new Event("flowFactsReady"));
                        }
                    }
                    break;
                default:
                    assertTrue("unexpected StatusChangeEvent status: " + event.status, false);
                    break;
            }
        }

        private function addTextFlowSprite(parentSprite:Sprite, x:Number, y:Number, width:Number, height:Number, textFlow:TextFlow):Sprite
        {
            sprite = new Sprite();
            sprite.x = x;
            sprite.y = y;

            textFlow.interactionManager = new EditManager();

            var controller:ContainerController = new ContainerController(sprite, width, height);
            controller.verticalScrollPolicy = scrollPolicy;
            controller.horizontalScrollPolicy = scrollPolicy;
            //	controller.format = format;  Test adding padding directly to the container
            // trace(x,y,controller.compositionWidth,controller.compositionHeight,scrollPolicy);
            // trace(TextConverter.export(textFlow,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.STRING_TYPE));

            textFlow.flowComposer.removeAllControllers();
            textFlow.flowComposer.addController(controller);
            textFlow.flowComposer.updateAllControllers();
            parentSprite.addChild(sprite);
            drawFlowComposerBounds(parentSprite, textFlow);
            // trace(controller.getContentBounds());
            // trace("addTextFlowSprite is running");
            return sprite;
        }

        private function drawFlowComposerBounds(parentSprite:Sprite, textFlow:TextFlow):void
        {
            // composition bounds in black
            var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
            var controllerSprite:Sprite = controller.container;
            var scrollx:Number = controllerSprite.scrollRect ? controllerSprite.scrollRect.x : 0;
            var scrolly:Number = controllerSprite.scrollRect ? controllerSprite.scrollRect.y : 0;

            sprite = new Sprite(); // controller.container as Sprite;
            sprite.x = controllerSprite.x;
            sprite.y = controllerSprite.y;
            parentSprite.addChild(sprite);
            var g:Graphics = sprite.graphics;
            g.clear();
            drawCircle(g, 0xff00, 0, 0, 3);
            strokeRect(g, 1, 0x0, 0, 0, width, height);
            // contentBounds in red
            compareBounds = controller.getContentBounds();
            strokeRect(g, 1, 0xFF0000, compareBounds.x - scrollx, compareBounds.y - scrolly, compareBounds.width, compareBounds.height);
            tFlowBounds = controller.getContentBounds();
            tFlowBounds.x = compareBounds.x - scrollx;
            tFlowBounds.y = compareBounds.y - scrolly;
        }

        private function strokeRect(g:Graphics, stroke:Number, color:uint, x:Number, y:Number, width:Number, height:Number):void
        {
            if (width <= 0 || height <= 0)
                return;
            g.lineStyle(stroke, color);
            g.moveTo(x, y);
            g.lineTo(x + width, y);
            g.lineTo(x + width, y + height);
            g.lineTo(x, y + height);
            g.lineTo(x, y);
        }

        private function drawCircle(g:Graphics, color:uint, x:Number, y:Number, radius:Number):void
        {
            g.beginFill(color);
            g.drawCircle(x, y, radius);
            g.endFill();
        }

        /** Run a single markup description in vertical alignment (top, middle, bottom) * horizontal alignment (left, center, right) in
         * both the full compose using ContainerController and a TextFlow Factory case. Compare the results to make sure the text falls
         * in the correct area of the container, that the content bounds is no smaller than the inked bounds, and that the full compose
         * content bounds matches the factory content bounds (or has only fractional differences). Note that the inked bounds may be smaller
         * than the content bounds because (for example) padding or indents have been applied.
         */
        public function runSingleTest(markup:String, manipulateText:Function = null):void
        {
            var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
            textFlow.blockProgression = _blockProgression;
            textFlow.direction = _direction;

            var verticalAlign:String;
            var textAlign:String;
            var contentBounds:Rectangle;
            var compositionBounds:Rectangle = new Rectangle(0, 0, width, height);

            var parentSprite:Sprite = new Sprite();
            addToCanvas(parentSprite);

            for each (verticalAlign in verticalAlignArray)
            {
                textFlow.verticalAlign = verticalAlign;
                for each (textAlign in textAlignArray)
                {
                    textFlow.textAlign = textAlign;

                    while (parentSprite.numChildren > 0)
                        parentSprite.removeChildAt(0);
                    addTextFlowSprite(parentSprite, compositionBounds.left, compositionBounds.top, compositionBounds.width, compositionBounds.height, textFlow);
                    BoundsChecker.validateAll(textFlow, parentSprite);

                    // Try doing some editing
                    if (manipulateText != null)
                    {
                        addTextFlowSprite(parentSprite, compositionBounds.left, compositionBounds.top, compositionBounds.width, compositionBounds.height, textFlow);
                        manipulateText(textFlow);
                        BoundsChecker.validateAll(textFlow, parentSprite);
                    }

                    textFlow.flowComposer = new StandardFlowComposer();		// we may have lost it while generating via the factory
                }
            }

            parentSprite.parent.removeChild(parentSprite);
        }

        // Ideographic baseline examples needed


    }
}
