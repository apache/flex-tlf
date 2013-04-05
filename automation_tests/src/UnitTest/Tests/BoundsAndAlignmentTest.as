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
	import UnitTest.ExtendedClasses.TestDescriptor;
	import UnitTest.ExtendedClasses.TestSuiteExtended;
	import UnitTest.ExtendedClasses.VellumTestCase;
	import UnitTest.Fixtures.TestConfig;
	import UnitTest.Validation.BoundsChecker;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	import flash.system.*;
	import flash.text.engine.TextLine;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.VerticalAlign;
	
	import mx.containers.Canvas;
	import mx.utils.LoaderUtil;
	
	public class BoundsAndAlignmentTest extends VellumTestCase  implements IEventDispatcher
	{
		// Creation Types
		private static const USE_FLOW:String = "textFlow";
		private static const USE_FACTORY_STRING:String = "factoryStr";
		private static const USE_FACTORY_FLOW:String = "factoryTF";
		private static var creationTypes:Array = [USE_FLOW, USE_FACTORY_STRING, USE_FACTORY_FLOW ];
		
		private static const MEASURE_WIDTH:String = "measureW";
		private static const MEASURE_HEIGHT:String = "measureH";
		private static const MEASURE_BOTH:String = "measureWH";
		private static const MEASURE_NONE:String = "explicitWH";
		private static var measureTypes:Array = [ MEASURE_NONE, MEASURE_BOTH ];
		
		private static var textAlignArray:Array = ["left", "center", "right", "start", "end" ];
		private static var verticalAlignArray:Array = ["top", "middle", "bottom"];
		private static var lineBreakArray:Array = ["toFit", "explicit" ];
		private const horizontalGap:Number = 30;
		private const verticalGap:Number = 10;
		private var w:Number = 210;
		private var h:Number = 40;
		private var width:Number;
		private var height:Number;
		private var paddingWidth:int = 0;
		private var paddingHeight:int = 0;
		
		private var labelWidth:Number = 210;
		private var labelHeight:Number = 50;
		
		private var _blockProgression:String;
		private var _direction:String;
		private var _creationType:String;
		private var _lineBreak:String;
		private var _measureType:String;
		private var eventDispatcher:EventDispatcher;
		// bounds and format of last sprite for comparison function
		private var compareBounds:Rectangle;
		
		private var marginOfError:int = 3;
		private var sFactBounds:Rectangle;
		private var fFactBounds:Rectangle;
		private var tFlowBounds:Rectangle;
		
		private var notReadyGraphicsCount:int;
		
		private var scrollPolicy:String = ScrollPolicy.ON;
		
		private static var stringFactory:StringTextLineFactory = null;
		private static var textFlowFactory:TextFlowTextLineFactory = null;
		private static var labelFactory:StringTextLineFactory = null;
		private var sprite:Sprite;
		private var testCanvas:Canvas;
		
		
		
		public function BoundsAndAlignmentTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML) //measureType:String, lineBreak:String)
		{
			super(methodName, testID, testConfig, null);
			
			eventDispatcher = new EventDispatcher();
			
			if (!stringFactory)
				stringFactory = new StringTextLineFactory();
			if (!textFlowFactory)
				textFlowFactory = new TextFlowTextLineFactory();
			if (!labelFactory)
			{
				labelFactory = new StringTextLineFactory();
				var labelFormat:TextLayoutFormat = new TextLayoutFormat();
				labelFormat.fontSize = 12;
				labelFactory.spanFormat = labelFormat;
			}
			
			//reset containerType to avoid assert in tearDown
			containerType = "custom";
			
			_blockProgression = testConfig.writingDirection[0];
			_direction = testConfig.writingDirection[1];
			//_creationType = creationType;
			_measureType = testXML.TestData.(@name == "measureType").toString();
			_lineBreak = testXML.TestData.(@name == "lineBreak").toString();
			
			//reset ID to include more variables
			TestID = TestID + ":" + _measureType + ":" + _lineBreak;
			
			width = logicalWidth;
			height = logicalHeight;
			switch (_measureType)
			{
				case MEASURE_BOTH:	width = NaN;
					height = NaN;
					break;
				
				case MEASURE_WIDTH:	width = NaN;
					break;
				
				case MEASURE_HEIGHT:
					height = NaN;
					break;
			}
			if (_blockProgression == BlockProgression.RL)		// swap coordinates if we're vertical
			{
				var tmp:Number = width;
				width = height;
				height = tmp;
				
				tmp = w;
				w = h;
				h = tmp;
			}
			
			// enables snapshots for the measurementgridtest - DO NOT SUBMIT ENABLED - It takes too long!
			// TestData["bitmapSnapshot"] = "true";
			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Composition";
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false): void
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
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false): void
		{
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return eventDispatcher.willTrigger(type);
		}
		// end of IEventDispatcher functions
		
		override public function setUp() : void
		{
			cleanUpTestApp();
			TestDisplayObject = testApp.getDisplayObject();
			if (!TestDisplayObject)
			{
				fail ("Did not get a blank canvas to work with");
			}
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
		
		private function clearCanvas():void
		{
			TestDisplayObject = testApp.getDisplayObject();
			if (TestDisplayObject)
			{
				testCanvas = Canvas(TestDisplayObject);
				while (testCanvas.rawChildren.numChildren > 0)
					testCanvas.rawChildren.removeChildAt(0);
			}
		}
		
		// These tests run all creation types -- flow, textFlowfactory and string factory
		private static var testsToRun:Array = [
		];
		
		// These tests run flow &  textFlowfactory creation types (they don't work on string factory)
		private static var testsToRunOnFlowAndTFFactory:Array = [
			"simpleMultiParagraph",
			"simpleMultiParagraphNoTextIndent",
			"simpleWithPaddingTopLeft",
			"simpleWithPaddingBottomRight",
			"simpleMultiParagraphNegTextIndent",
			"longSimpleMultiParagraph",
		];
		
		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			// These tests run on all creation types
			createTests(testConfig, ts, testsToRun);

			// These tests run on TextFlow and TextFlow Factory only
			createTests(testConfig, ts, testsToRunOnFlowAndTFFactory);
		}
	
		private static function createTests(testConfig:TestConfig, ts:TestSuiteExtended, testsToRun:Array):void
		{
			var methodName:String;
			var creationType:String;
			var measureType:String;
			var lineBreak:String;
			var verticalAlign:String;
			var textAlign:String;

			for each (methodName in testsToRun)
			{
				addTestCase(testConfig, ts, methodName, measureType, lineBreak, verticalAlign, textAlign);
			}
		}
		
		private static function addTestCase(testConfig:TestConfig, ts:TestSuiteExtended, methodName:String, measureType:String, lineBreak:String, verticalAlign:String, textAlign:String):void
		{
			var testXML:XML = <TestCase>
								<TestData name="measureType">{measureType}</TestData>
								<TestData name="lineBreak">{lineBreak}</TestData>
								<TestData name="id">{methodName}-{measureType}-{lineBreak}</TestData>
								<TestData name="verticalAlign">{verticalAlign}</TestData>
								<TestData name="textAlign">{textAlign}</TestData>
							</TestCase>;
			
			ts.addTestDescriptor (new TestDescriptor (BoundsAndAlignmentTest,methodName, testConfig, testXML) );
		}
		
		private const logicalWidth:Number = 400;
		private const logicalHeight:Number = 400;
		
		private function createDefaultTextLayoutFormat():TextLayoutFormat
		{
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.fontFamily = "Arial";
			format.fontSize = 20;
			format.direction = _direction;
			format.blockProgression = _blockProgression;
			return format;
		}
		
		private function createTextFlow(markup:String):TextFlow
		{
			if (markup.length <= 0 || markup.charAt(0) != "<")
				return TextConverter.importToFlow(markup, TextConverter.PLAIN_TEXT_FORMAT);
			
			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			var flowNotReadyGraphicsCount:int = 0;
			
			// check for inlines
			for (var leaf:FlowLeafElement = textFlow.getFirstLeaf(); leaf != null; leaf = leaf.getNextLeaf())
				if (leaf is InlineGraphicElement && InlineGraphicElement(leaf).status != InlineGraphicElementStatus.READY)
					flowNotReadyGraphicsCount++;
			if (flowNotReadyGraphicsCount != 0)
			{
				textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,statusChangeHandler,false,0,true);
				textFlow.flowComposer.addController(new ContainerController(new Sprite()));	// add dummy controller so we get status change events
				textFlow.flowComposer.updateAllControllers();
				notReadyGraphicsCount += flowNotReadyGraphicsCount;
			}
			return textFlow;
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
						textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,statusChangeHandler);
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
					assertTrue("unexpected StatusChangeEvent status: "+event.status,false);
					break;
			}
		}
		
		private function addTextFactoryFromFlowSprite(x:Number, y:Number, width:Number, height:Number, textFlow:TextFlow):Sprite
		{
			// trace("addTextFactoryFromFlowSprite",x,y,width,height,textAlign,verticalAlign,lineBreak);
			
			var factorySprite:Sprite = new Sprite();
			factorySprite.x = x;
			factorySprite.y = y;
			
			addToCanvas(factorySprite);
			
			textFlowFactory.compositionBounds = new Rectangle(0,0,width?width:NaN,height?height:NaN);
			
			textFlowFactory.createTextLines(callback,textFlow);
			clearCanvas();
			addToCanvas(factorySprite);
			
			function callback(tl:TextLine):void
			{
				factorySprite.addChild(tl);
			}
			
			// composition bounds in black
			// contentBounds in red
			// put it in another sprite on top
			sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;
			addToCanvas(sprite);
			
			compareBounds = textFlowFactory.getContentBounds();
			var g:Graphics = sprite.graphics;
			drawCircle(g, 0xff00, 0, 0, 3);
			strokeRect(g, 1, 0x0, 0, 0, width, height);
			strokeRect(g, 1, 0xFF0000, compareBounds.left, compareBounds.top, compareBounds.width, compareBounds.height);
			// trace("addTextFactoryFromFlowSprite is running");
			fFactBounds = textFlowFactory.getContentBounds();
			
			// trace("bounds",sFactBounds);
			return factorySprite;
		}
		
		private function addTextFlowSprite(parentSprite:Sprite, x:Number, y:Number, width:Number, height:Number, textFlow:TextFlow):Sprite
		{
			sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;
			
			textFlow.interactionManager = new EditManager();
			
			var controller:ContainerController = new ContainerController(sprite,width,height);
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
			strokeRect(g, 1, 0xFF0000, compareBounds.x-scrollx, compareBounds.y-scrolly, compareBounds.width, compareBounds.height);
			tFlowBounds = controller.getContentBounds();
			tFlowBounds.x = compareBounds.x-scrollx;
			tFlowBounds.y = compareBounds.y-scrolly;
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
			g.drawCircle(x,y,radius);
			g.endFill();
		}
		
		
		private function validateContentBounds(s:Sprite, contentBounds:Rectangle, marginOfError:Number):void
		{
			// Check that the content bounds includes all the places within the container that have text	
			s.graphics.clear();
			var bbox:Rectangle = s.getBounds(s);
			
			// The content bounds should always include the inked bounds, or be very close to it. In practice, how far it may be off by is proportional to the text size.
			assertTrue("contentBounds left doesn't match sprite inked bounds", contentBounds.left <= bbox.left || Math.abs(contentBounds.left - bbox.left) < marginOfError);
			assertTrue("contentBounds top doesn't match sprite inked bounds", contentBounds.top <= bbox.top || Math.abs(contentBounds.top - bbox.top) < marginOfError);
			assertTrue("contentBounds right doesn't match sprite inked bounds", contentBounds.right >= bbox.right || Math.abs(contentBounds.right - bbox.right) < marginOfError);
			assertTrue("contentBounds bottom doesn't match sprite inked bounds", contentBounds.bottom >= bbox.bottom || Math.abs(contentBounds.bottom - bbox.bottom) < marginOfError);
		}
		
		private function validateAlignment(verticalAlign:String, textAlign:String, textFlow:TextFlow, compositionBounds:Rectangle, contentBounds:Rectangle, expectContentsToFit:Boolean, marginOfError:Number):void
		{
			// Check that the text was put in the appropriate area of the container, given the vertical & horizontal alignment values
			if (expectContentsToFit)
			{
				assertTrue("contents expected to fit, but overflow in height", contentBounds.height <= compositionBounds.height || contentBounds.height - compositionBounds.height < 1);
				assertTrue("contents expected to fit, but overflow in width", contentBounds.width <= compositionBounds.width || contentBounds.width - compositionBounds.width < 1);
			}
	
			// Resolve direction dependent alignment
			if (textAlign == TextAlign.START)
				textAlign = textFlow.computedFormat.direction == Direction.LTR ? TextAlign.LEFT : TextAlign.RIGHT;
			if (textAlign == TextAlign.END)
				textAlign = textFlow.computedFormat.direction == Direction.RTL ? TextAlign.LEFT : TextAlign.RIGHT;

			// Swap alignment values for validate call if text is rotated (vertical text)
			if (_blockProgression == BlockProgression.RL)
			{
				var originalTextAlign:String = textAlign;
				switch (verticalAlign)
				{
					case VerticalAlign.TOP:
						textAlign = TextAlign.RIGHT;
						break;
					case VerticalAlign.MIDDLE:
						textAlign = TextAlign.CENTER;
						break;
					case VerticalAlign.BOTTOM:
						textAlign = TextAlign.LEFT;
						break;
					default:
						break;
				}
				switch (originalTextAlign)
				{
					case TextAlign.LEFT:
						verticalAlign = VerticalAlign.TOP;
						break;
					case TextAlign.CENTER:
						verticalAlign = VerticalAlign.MIDDLE;
						break;
					case TextAlign.RIGHT:
						verticalAlign = VerticalAlign.BOTTOM;
						break;
					default:
						break;
				}
			}
			
			switch (verticalAlign)
			{
				case VerticalAlign.TOP:
					assertTrue("Vertical alignment top - content not at top", Math.abs(contentBounds.top - compositionBounds.top) < marginOfError);
					break;
				case VerticalAlign.MIDDLE:
					assertTrue("Vertical alignment middle - content not at middle", Math.abs(Math.abs(contentBounds.top - compositionBounds.top) - Math.abs(contentBounds.bottom - compositionBounds.bottom)) < marginOfError);
					break;
				case VerticalAlign.BOTTOM:
					assertTrue("Vertical alignment bottom - content not at bottom", Math.abs(contentBounds.bottom - compositionBounds.bottom) < marginOfError);
					break;
				default:
					break;
			}
			switch (textAlign)
			{
				case TextAlign.LEFT:
					assertTrue("Horizontal alignment left - content not at left", Math.abs(contentBounds.left - compositionBounds.left) < marginOfError);
					break;
				case TextAlign.CENTER:
					assertTrue("Horizontal alignment center - content not at center", Math.abs(Math.abs(contentBounds.left - compositionBounds.left) - Math.abs(contentBounds.right - compositionBounds.right)) < marginOfError);
					break;
				case TextAlign.RIGHT:
					assertTrue("Horizontal alignment right - content not at right", Math.abs(contentBounds.right - compositionBounds.right) < marginOfError);
					break;
				default:
					break;
			}
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
					addTextFlowSprite(parentSprite, compositionBounds.left, compositionBounds.top, compositionBounds.width, compositionBounds.height,textFlow);
					BoundsChecker.validateAll(textFlow, parentSprite);
					
					// Try doing some editing	
					if (manipulateText != null)
					{
						addTextFlowSprite(parentSprite, compositionBounds.left, compositionBounds.top, compositionBounds.width, compositionBounds.height,textFlow);
						manipulateText(textFlow);
						BoundsChecker.validateAll(textFlow, parentSprite);
					}

					textFlow.flowComposer = new StandardFlowComposer();		// we may have lost it while generating via the factory
				}
			}
			
			parentSprite.parent.removeChild(parentSprite);
		}
		
		/********************** Tests Start Here ***************************/
		
		private var editManager:IEditManager = new EditManager();
		private function insertText(textFlow:TextFlow):void
		{
			textFlow.interactionManager = editManager;
			editManager.selectRange(textFlow.textLength, textFlow.textLength);
			editManager.insertText("INSERTED TEXT");
			var controller:ContainerController  = textFlow.flowComposer.getControllerAt(0);
			controller.verticalScrollPosition = int.MAX_VALUE;
			textFlow.flowComposer.updateAllControllers();
		}
		
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
		
		public function simpleMultiParagraphNoTextIndent():void
		{
			// This is a subset of simple.xml, and has NO first line indent applied to the paragraphs.
			var markup:String = '<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" paddingTop="4" paddingLeft="4" fontFamily="Times New Roman">' +
				'<flow:p paragraphSpaceAfter="15"><flow:span>There are many </flow:span><flow:span fontStyle="italic">such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Sentences removed.</flow:span></flow:p>' + 
				'<flow:p paragraphSpaceAfter="15"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
				'</flow:TextFlow>';
			
			runSingleTest(markup);
		}
		
		public function simpleMultiParagraphNegTextIndent():void
		{
			// This is a subset of simple.xml, and has NO first line indent applied to the paragraphs.
			var markup:String = '<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" textIndent="15" paddingTop="4" paddingLeft="4" fontFamily="Times New Roman">' +
				'<flow:p paragraphSpaceAfter="30"><flow:span>There are many </flow:span><flow:span fontStyle="italic">such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Sentences removed.</flow:span></flow:p>' + 
				'<flow:p paragraphSpaceAfter="30"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
				'</flow:TextFlow>';
			
			runSingleTest(markup);
		}
		
		public function simpleWithPaddingTopLeft():void
		{
			// This is a subset of simple.xml, and has NO first line indent applied to the paragraphs.
			var markup:String = '<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" paddingTop="40" paddingLeft="20">' +
				'<flow:p paragraphSpaceAfter="15"><flow:span>There are many </flow:span><flow:span fontStyle="italic">such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Sentences removed.</flow:span></flow:p>' + 
				'<flow:p paragraphSpaceAfter="15"><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
				'</flow:TextFlow>';
			
			runSingleTest(markup);
		}
		
		public function simpleWithPaddingBottomRight():void
		{
			// This is a subset of simple.xml, and has NO first line indent applied to the paragraphs.
			var markup:String = '<flow:TextFlow xmlns:flow="http://ns.adobe.com/textLayout/2008" fontSize="14" paddingBottom="40" paddingRight="20">' +
				'<flow:p><flow:span>There are many </flow:span><flow:span fontStyle="italic">such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Sentences removed.</flow:span></flow:p>' + 
				'<flow:p><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed.</flow:span></flow:p>' +
				'</flow:TextFlow>';
			
			runSingleTest(markup);
		}
		
		
		
		// Ideographic baseline examples needed
		
		
	}
}
