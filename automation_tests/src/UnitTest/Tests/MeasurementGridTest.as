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
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	import flash.system.*;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
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
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	import mx.containers.Canvas;
	import mx.utils.LoaderUtil;

	public class MeasurementGridTest extends VellumTestCase  implements IEventDispatcher
	{
		// Don't check in with true
		private static const kVerbose:Boolean = false;

		// Creation Types
		private static const USE_FLOW:String = "textFlow";
		private static const USE_FACTORY_STRING:String = "factoryStr";
		private static const USE_FACTORY_FLOW:String = "factoryTF";
		private static const USE_TCM:String = "textContainerManager";

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



		public function MeasurementGridTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML) //measureType:String, lineBreak:String)
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

		private function spriteHandler(event:Event, data:Array):void
		{
  			var xOrigin:Number = 10;
			var yOrigin:Number = 10;
			_creationType = USE_FACTORY_FLOW;
			var textFlowArray:Array = createTextFlows(data[4]);
			addTestSet(data[0], data[1], data[2], data[3], textFlowArray, data[5], _creationType, _lineBreak, marginOfError);
			assertTrue("fFactBounds doesn't have the same output as tFlowBounds", Math.abs(fFactBounds.x - tFlowBounds.x) <= 1 && Math.abs(fFactBounds.y - tFlowBounds.y) <= 1 &&
											Math.abs(fFactBounds.width - tFlowBounds.width) <= 1 && Math.abs(fFactBounds.height - tFlowBounds.height) <= 1);
			//assertTrue("Doesn't get the same output", fFactBounds.x == tFlowBounds.x );
		}

		// These tests run all creation types -- flow, textFlowfactory and string factory
		private static var testsToRun:Array = [
			"testSimpleText",
			"testMultipleLines",
			"testTrailingSpaces",
			"testWidthNoHeight",
			"testHeightNoWidth",
			"testEmptyText",
			"testPaddingLeftAndTop",
			"testPaddingRightAndBottom",
			"testMultipleColumns",
			"testStartIndent",
			"testEndIndent",
			"testNegTextIndent",
			"testSpaceBefore",
			"testSpaceAfter"
			];

		// These tests run flow &  textFlowfactory creation types (they don't work on string factory)
		private static var testsToRunOnFlowAndTFFactory:Array = [
			"testInlineAtStartOfFlow",
			"testInlineAtStartOfFlowBigText",
		//	"testInlineOnFirstLineInContainer",
		//	"testInlineOnFirstLineOfSecondContainer",
		//	"testInlineOnMiddleLineCentered"
			];

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
   			// These tests run on all creation types
   			var methodName:String;
   			var creationType:String;
   			var measureType:String;
   			var lineBreak:String;
   			for each (methodName in testsToRun)
   			{
   				for each (measureType in measureTypes)
	   				for each (lineBreak in lineBreakArray)
		  				addTestCase(ts, testConfig, methodName, measureType, lineBreak);

   			}

   			// These tests run on TextFlow and TextFlow Factory only

   			for each (methodName in testsToRunOnFlowAndTFFactory)
   			{
   				for each (measureType in measureTypes)
		   			for each (lineBreak in lineBreakArray)
			  			addTestCase(ts, testConfig, methodName, measureType, lineBreak);
   			}
   		}

 		private static function addTestCase(ts:TestSuiteExtended, testConfig:TestConfig, methodName:String, /*creationType:String,*/ measureType:String, lineBreak:String):void
 		{
			//ts.addTestDescriptor (new TestDescriptor (MeasurementGridTest,methodName, testConfig, creationType, measureType, lineBreak) );
			var testXML:XML = <TestCase>
								<TestData name="measureType">{measureType}</TestData>
								<TestData name="lineBreak">{lineBreak}</TestData>
								<TestData name="id">{methodName}-{measureType}-{lineBreak}</TestData>
							</TestCase>;

			ts.addTestDescriptor (new TestDescriptor (MeasurementGridTest,methodName, testConfig, testXML) );
 		}

		private const logicalWidth:Number = 200;
		private const logicalHeight:Number = 40;

		private function createDefaultTextLayoutFormat():TextLayoutFormat
		{
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.fontFamily = "Arial";
			format.fontSize = 20;
			format.direction = _direction;
			format.blockProgression = _blockProgression;
			return format;
		}

		private function runTest(sampleText:String, format:TextLayoutFormat):void
		{
			var xOrigin:Number = 10;
			var yOrigin:Number = 10;
			var item:String;
			var tempBool:Boolean = false;

			_creationType = USE_FLOW;
			var textFlowArray:Array = createTextFlows(sampleText);
			if (notReadyGraphicsCount > 0)
			{
				addEventListener("spriteInUse", addAsync(spriteHandler, 5000,
					[xOrigin, yOrigin, width, height, sampleText, format]), false, 0, true);
				addTestSet(xOrigin, yOrigin, width, height, textFlowArray, format, _creationType, _lineBreak, marginOfError);
			}
			else
			{
				addTestSet(xOrigin, yOrigin, width, height, textFlowArray, format, _creationType, _lineBreak, marginOfError);
				_creationType = USE_FACTORY_FLOW;
				addTestSet(xOrigin, yOrigin, width, height, textFlowArray, format, _creationType, _lineBreak, marginOfError);
			}
			
			// TCM converts graphics to textflow so no point in testing
			if (notReadyGraphicsCount == 0)
			{
				_creationType = USE_TCM;
				addTestSet(xOrigin, yOrigin, width, height, textFlowArray, format, _creationType, _lineBreak, marginOfError);
			}
			

			//notReadyGraphicsCount = 0;

			tempBool = false;
			for(var i:int = 0; i < testsToRunOnFlowAndTFFactory.length; i++)
			{
				if ( testsToRunOnFlowAndTFFactory[i] == methodName)
				{
					tempBool = true;
					break;
				}
			}

			if (!tempBool)
			{
				_creationType = USE_FACTORY_STRING;
				addTestSet(xOrigin, yOrigin, width, height, sampleText, format, _creationType, _lineBreak, marginOfError);
				/*
				assertTrue("sFactBounds doesn't have the same output as tFlowBounds", Math.abs(sFactBounds.x - tFlowBounds.x) <= 1 && Math.abs(sFactBounds.y - tFlowBounds.y) <= 1 &&
											Math.abs(sFactBounds.width - tFlowBounds.width) <= 1 && Math.abs(sFactBounds.height - tFlowBounds.height) <= 1);
				*/
			}


		}

		private function createTextFlows(text:String):Array
		{
			var textFlowArray:Array = [];
			var flowCount:int = verticalAlignArray.length * textAlignArray.length;
			for (var i:int = 0; i < flowCount; ++i)
				textFlowArray.push(createTextFlow(text));
			for (i = 0; i < flowCount; ++i)		// remove any dummy controllers
				textFlowArray[i].flowComposer.removeAllControllers();

			return textFlowArray;
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
				case InlineGraphicElementStatus.LOAD_PENDING:
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

 		private function labelVAlignColumns(xOrigin:Number, yOrigin:Number):void
		{
			var x:Number;
			var y:Number;

			x = xOrigin;
			for each (var verticalAlign:String in verticalAlignArray)
			{
				y = yOrigin;
				addLabel(x, yOrigin, labelWidth, labelHeight, verticalAlign);	//label
				x += w + horizontalGap;
			}
		}

		private function asyncAddTestSet(event:Event, data:Array):void
		{
			addTestSet(data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8]);
		}

		private function addTestSet(xOrigin:Number, yOrigin:Number, compositionWidth:Number, compositionHeight:Number,
			text:Object, format:TextLayoutFormat, creationType:String, lineBreak:String, marginOfError:int):void
		{

			var x:Number = xOrigin;
			var y:Number = yOrigin;
			var lineBreak:String;
			var verticalAlign:String;
			var textAlign:String;

			var useString:Boolean = text is String;

			var flowIndex:int = 0;
			var sampleText:String = text as String;
			var textFlowArray:Array = text as Array;


			// Test against specified width and height
			if (_blockProgression == BlockProgression.TB)
			{
				// Labels for columns
				labelVAlignColumns(xOrigin, yOrigin);

				yOrigin += 30;
				x = xOrigin;
				for each (verticalAlign in verticalAlignArray)
				{
					y = yOrigin;
					for each (textAlign in textAlignArray)
					{
						addTextSprite(x, y, compositionWidth, compositionHeight, textAlign, verticalAlign, lineBreak, useString ? sampleText : textFlowArray[flowIndex++], format, creationType);
						y += h + verticalGap;
					}
					x += w + horizontalGap;
				}
				addLabel(x, yOrigin - 30, labelWidth, labelHeight, lineBreak);	//label
				y = yOrigin;
				for each (textAlign in textAlignArray)
				{
					addLabel(x, y, labelWidth, labelHeight, textAlign);
					y += h + verticalGap;
				}
			}
			else
			{
				var newColumn:Boolean = true;
				x = xOrigin;
				for each (verticalAlign in verticalAlignArray)
				{
					addLabel(x, yOrigin, labelWidth, labelHeight, verticalAlign);
					for each (textAlign in textAlignArray)
					{
						if (newColumn)
						{
							y = yOrigin + 20;
							newColumn = false;
						}
						addLabel(x, y, labelWidth, labelHeight, textAlign);
						addTextSprite(x, y + 20, compositionWidth, compositionHeight, textAlign, verticalAlign, lineBreak, useString ? sampleText:textFlowArray[flowIndex++], format, creationType);
						y += h + verticalGap;
						if (y > 400)
						{
							newColumn = true;
							x += w + horizontalGap;
						}
					}
					x += w + horizontalGap;
				}
			}

			this.dispatchEvent(new Event("spriteInUse"));
			// trace("Sprite is ready now!!!!!!!!!!");

		}

		private function addTextSprite(x:Number, y:Number, width:Number, height:Number, textAlign:String, verticalAlign:String, lineBreak:String, text:Object,
			format:TextLayoutFormat, creationType:String):void
		{
			switch (creationType)
			{
				case USE_FLOW:
					addTextFlowSprite(x, y, width, height, textAlign, verticalAlign, lineBreak, text as TextFlow, format);
					comparision(x, y, width, height, textAlign, verticalAlign, marginOfError, format);
					break;
				case USE_FACTORY_STRING:
					addTextFactoryFromStringSprite(x, y, width, height, textAlign, verticalAlign, lineBreak, text as String, format);
					comparision(x, y, width, height, textAlign, verticalAlign, marginOfError, format);
					break;
				case USE_FACTORY_FLOW:
					addTextFactoryFromFlowSprite(x, y, width, height, textAlign, verticalAlign, lineBreak, text as TextFlow, format);
					comparision(x, y, width, height, textAlign, verticalAlign, marginOfError, format);
					break;
				case USE_TCM:
					addTCMSprite(x, y, width, height, textAlign, verticalAlign, lineBreak, text as TextFlow, format);
					break;
			}
		}

		private function comparision(x:Number, y:Number, width:Number, height:Number, textAlign:String, verticalAlign:String, marginOfError:int, compareFormat:ITextLayoutFormat):void
        {

			if (isNaN(width) || isNaN(height))
				return;
			// these comparision tests barely work for TB and not at all for RL content.  Really their functioning at this time is conincidental
			// the general rule for contentBounds is that it is the size you can setting compositionHeight to contentBounds.height and compositionWidth to contentBounds.width
			// will give you the same line breaks and the same size of contentBounds.  That means it includes padding.  So when verifying center/bottom/justified text you must
			// to subtract off the padding values in order to verify these bounds calculations.  Its not happening here so this entire section should be revisited.
			if (compareFormat.blockProgression == BlockProgression.TB)
			{
				switch (verticalAlign)
	            {
	               case "top":
	                   //assertTrue("not top aligned", Math.abs(bounds.top) <= marginOfError);
	                   switch (textAlign)
	                   {
	                       case "left":
	                          assertTrue("not top-left aligned", Math.abs(compareBounds.y) <= marginOfError ||
	                          				Math.abs(compareBounds.left) <= marginOfError);
	                          break;
	                       case "center":
	                          assertTrue("not top-center aligned", Math.abs((compareBounds.y + compareBounds.height/2) - height/2) <= marginOfError ||
	                          				Math.abs((compareBounds.left + compareBounds.width/2) - width/2) <= marginOfError);
	                          break;
	                       case "right":
	                          assertTrue("not top-right aligned", Math.abs(compareBounds.bottom - height) <= marginOfError ||
	                          				Math.abs(compareBounds.y - height) <= marginOfError ||
	                          				Math.abs(compareBounds.left - width) <= marginOfError ||
	                          				Math.abs(compareBounds.right - width) <= marginOfError);
	                          break;
	                       case "start":
	                       	  if (_direction == Direction.LTR)
	                          assertTrue("not top-start-lrt aligned", Math.abs(compareBounds.y) <= marginOfError ||
	                          				Math.abs(compareBounds.left) <= marginOfError);
	                          else
	                          assertTrue("not top-start-rtl aligned", Math.abs(compareBounds.right - width) <= marginOfError ||
	                          				Math.abs(compareBounds.left - width) <= marginOfError);
	                          break;
	                       case "end":
	                          if (_direction == Direction.RTL)
	                          assertTrue("not top-end-rtl aligned", Math.abs(compareBounds.y) <= marginOfError ||
	                          				Math.abs(compareBounds.left) <= marginOfError);
	                          else
	                          assertTrue("not top-end-ltr aligned", Math.abs(compareBounds.y - height) <= marginOfError ||
	                          				Math.abs(compareBounds.left - width) <= marginOfError ||
	                          				Math.abs(compareBounds.right - width) <= marginOfError ||
	                          				Math.abs(compareBounds.bottom - height) <= marginOfError);
	                          break;

	                   }
	                   break;

	               case "middle":
	               	   //assertTrue("not middle aligned", Math.abs(compareBounds.y + compareBounds.height/2 - height/2) <= marginOfError);
	                   switch (textAlign)
	                   {
	                      case "left":
	                          assertTrue("not middle-left aligned", Math.abs(compareBounds.y) <= marginOfError ||
	                          				Math.abs(compareBounds.left) <= marginOfError);
	                          break;
	                       case "center":
	                          assertTrue("not middle-center aligned", Math.abs((compareBounds.y + compareBounds.height/2) - height/2) <= marginOfError ||
	                          				Math.abs((compareBounds.left + compareBounds.width/2) - width/2) <= marginOfError);
	                          break;
	                       case "right":
	                          assertTrue("not middle-right aligned", Math.abs(compareBounds.bottom - height) <= marginOfError ||
	                          				Math.abs(compareBounds.y - height) <= marginOfError ||
	                          				Math.abs(compareBounds.left - width) <= marginOfError ||
	                          				Math.abs(compareBounds.right - width) <= marginOfError);
	                          break;
	                       case "start":
	                       	  if (_direction == Direction.LTR)
	                          assertTrue("not middle-start-ltr aligned", Math.abs(compareBounds.y) <= marginOfError ||
	                          				Math.abs(compareBounds.left) <= marginOfError);
	                          else
	                          assertTrue("not middle-start-rtl aligned", Math.abs(compareBounds.right - width) <= marginOfError ||
	                          				Math.abs(compareBounds.left - width) <= marginOfError);
	                          break;
	                       case "end":
	                          if (_direction == Direction.RTL)
	                          assertTrue("not middle-end-rtl aligned", Math.abs(compareBounds.y) <= marginOfError ||
	                          				Math.abs(compareBounds.left) <= marginOfError);
	                          else
	                          assertTrue("not middle-end-ltr aligned", Math.abs(compareBounds.bottom - height) <= marginOfError ||
	                          				Math.abs(compareBounds.y - height) <= marginOfError ||
	                          				Math.abs(compareBounds.left - width) <= marginOfError ||
	                          				Math.abs(compareBounds.right - width) <= marginOfError);
	                          break;

	                   }
	                   break;

	               case "bottom":
	                   //assertTrue("not middle aligned", Math.abs(compareBounds.bottom - height) <= marginOfError);
	                   switch (textAlign)
	                   {
	                      case "left":
	                          assertTrue("not bottom-left aligned", Math.abs(compareBounds.y) <= marginOfError ||
	                          				Math.abs(compareBounds.left) <= marginOfError);
	                          break;
	                       case "center":
	                          assertTrue("not bottom-center aligned", Math.abs((compareBounds.y + compareBounds.height/2) - height/2) <= marginOfError ||
	                          				Math.abs((compareBounds.left + compareBounds.width/2) - width/2) <= marginOfError);
	                          break;
	                       case "right":
	                          assertTrue("not bottom-right aligned", Math.abs(compareBounds.bottom - height) <= marginOfError ||
	                          				Math.abs(compareBounds.y - height) <= marginOfError ||
	                          				Math.abs(compareBounds.left - width) <= marginOfError ||
	                          				Math.abs(compareBounds.right - width) <= marginOfError);
	                          break;
	                       case "start":
	                       	  if (_direction == Direction.LTR)
	                          assertTrue("not bottom-start-ltr aligned", Math.abs(compareBounds.y) <= marginOfError ||
	                          				Math.abs(compareBounds.left) <= marginOfError);
	                          else
	                          assertTrue("not bottom-start-rtl aligned", Math.abs(compareBounds.right - width) <= marginOfError ||
	                          				Math.abs(compareBounds.left - width) <= marginOfError);
	                          break;
	                       case "end":
	                          if (_direction == Direction.RTL)
	                          assertTrue("not bottom-end-rtl aligned", Math.abs(compareBounds.y) <= marginOfError ||
	                          				Math.abs(compareBounds.left) <= marginOfError);
	                          else
	                          assertTrue("not bottom-end-ltr aligned", Math.abs(compareBounds.bottom - height) <= marginOfError ||
	                          				Math.abs(compareBounds.y - height) <= marginOfError ||
	                          				Math.abs(compareBounds.left - width) <= marginOfError ||
	                          				Math.abs(compareBounds.right - width) <= marginOfError);
	                          break;

	                   }
	                   break;

	            }


			}

			if (compareFormat.blockProgression == BlockProgression.RL)
			{
				switch (verticalAlign)
				{
					case "top":
						//assertTrue("not top aligned", Math.abs(bounds.top) <= marginOfError);
						switch (textAlign)
						{
							case "left":
								assertTrue("not top-left aligned", Math.abs(compareBounds.y + compareBounds.height + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
									Math.abs(compareBounds.height - width) <= marginOfError);

								break;
							case "center":
								assertTrue("not top-center aligned", Math.abs((Math.abs(compareBounds.height) + compareBounds.bottom + paddingHeight/2) - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - 23 - height) <= marginOfError);

								break;
							case "right":
								assertTrue("not top-right aligned", Math.abs(compareBounds.y + paddingHeight - height - 200) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
									Math.abs(compareBounds.y + compareBounds.height + paddingHeight - height) <= marginOfError);

								break;
							case "start":
								if (_direction == Direction.LTR)
									assertTrue("not top-start-lrt aligned", Math.abs(compareBounds.y + compareBounds.height + paddingHeight - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError);

								else
									assertTrue("not top-start-rtl aligned", Math.abs(compareBounds.y - height - paddingHeight) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError);

								break;
							case "end":
								if (_direction == Direction.RTL)
									assertTrue("not top-start-rtl aligned", Math.abs(compareBounds.y - height - paddingHeight) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError);

								else
									assertTrue("not top-start-lrt aligned", Math.abs(compareBounds.height + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
									Math.abs(compareBounds.height + paddingHeight - 46 - height) <= marginOfError);

								break;

						}
						break;

					case "middle":
						//assertTrue("not middle aligned", Math.abs(compareBounds.y + compareBounds.height/2 - height/2) <= marginOfError);
						switch (textAlign)
						{
							case "left":
								assertTrue("not top-left aligned", Math.abs(compareBounds.y + compareBounds.height + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError);

								break;
							case "center":
								assertTrue("not top-center aligned", Math.abs((Math.abs(compareBounds.height) + compareBounds.bottom + paddingHeight/2) - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - 23 - height) <= marginOfError);

								break;
							case "right":
								assertTrue("not top-right aligned", Math.abs(compareBounds.y + paddingHeight - height - 200) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
									Math.abs(compareBounds.y + compareBounds.height + paddingHeight - height) <= marginOfError);

								break;
							case "start":
								if (_direction == Direction.LTR)
									assertTrue("not top-start-lrt aligned", Math.abs(compareBounds.y + compareBounds.height + paddingHeight - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError);

								else
									assertTrue("not top-start-rtl aligned", Math.abs(compareBounds.y - height - paddingHeight) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError);

								break;
							case "end":
								if (_direction == Direction.RTL)
									assertTrue("not top-start-rtl aligned", Math.abs(compareBounds.y - height - paddingHeight) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError);

								else
									assertTrue("not top-start-lrt aligned", Math.abs(compareBounds.height + paddingHeight - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
										Math.abs(compareBounds.height + paddingHeight - 46 - height) <= marginOfError);

								break;

						}
						break;

					case "bottom":
						//assertTrue("not middle aligned", Math.abs(compareBounds.bottom - height) <= marginOfError);
						switch (textAlign)
						{
							case "left":
								assertTrue("not top-left aligned", Math.abs(compareBounds.y + compareBounds.height + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError);

								break;
							case "center":
								assertTrue("not top-center aligned", Math.abs((Math.abs(compareBounds.height) + compareBounds.bottom + paddingHeight/2) - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - 23 - height) <= marginOfError);

								break;
							case "right":
								assertTrue("not top-right aligned", Math.abs(compareBounds.y + paddingHeight - height - 200) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
									Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
									Math.abs(compareBounds.y + compareBounds.height + paddingHeight - height) <= marginOfError);

								break;
							case "start":
								if (_direction == Direction.LTR)
									assertTrue("not top-start-lrt aligned", Math.abs(compareBounds.y + compareBounds.height + paddingHeight - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError);

								else
									assertTrue("not top-start-rtl aligned", Math.abs(compareBounds.y - height - paddingHeight) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError);

								break;
							case "end":
								if (_direction == Direction.RTL)
									assertTrue("not top-start-rtl aligned", Math.abs(compareBounds.y - height - paddingHeight) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError);

								else
									assertTrue("not top-start-lrt aligned", Math.abs(compareBounds.height + paddingHeight - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + paddingHeight - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 102 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 16 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) + 89 - height) <= marginOfError ||
										Math.abs(Math.abs(compareBounds.height) - 46 - height) <= marginOfError ||
										Math.abs(compareBounds.height + paddingHeight - 46 - height) <= marginOfError);

								break;

						}
						break;

				}


			}



        }


		private function addTextFactoryFromStringSprite(x:Number, y:Number, width:Number, height:Number, textAlign:String, verticalAlign:String, lineBreak:String, text:String,
			format:TextLayoutFormat):void
		{

			// trace("addTextFactoryFromStringSprite",x,y,width,height,textAlign,verticalAlign,lineBreak,text);
			sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;

			var scratchFormat:TextLayoutFormat = new TextLayoutFormat(format);
			scratchFormat.textAlign = textAlign;
			scratchFormat.verticalAlign = verticalAlign;
			scratchFormat.lineBreak = lineBreak;

			stringFactory.compositionBounds = new Rectangle(0,0,width?width:NaN,height?height:NaN);
			stringFactory.text = text;
			stringFactory.textFlowFormat = scratchFormat;
			stringFactory.createTextLines(callback);
			addToCanvas(sprite);


			function callback(tl:TextLine):void
			{
				sprite.addChild(tl);
			}

			// composition compareBounds in black
			// contentBounds in red
			// put it in another sprite on top
			sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;
			addToCanvas(sprite);

			compareBounds = stringFactory.getContentBounds();
			var g:Graphics = sprite.graphics;
			drawCircle(g, 0xff00, 0, 0, 3);
			strokeRect(g, 1, 0x0, 0, 0, width, height);
			strokeRect(g, 1, 0xFF0000, compareBounds.left, compareBounds.top, compareBounds.width, compareBounds.height);
			// trace("addTextFactoryFromStringSprite is running");
			sFactBounds = stringFactory.getContentBounds();

			if (kVerbose)
				trace(TestID,_creationType,textAlign,verticalAlign,lineBreak,width,height,sFactBounds);
			// trace("bounds",sFactBounds);


		}

		private function addTextFactoryFromFlowSprite(x:Number, y:Number, width:Number, height:Number, textAlign:String, verticalAlign:String, lineBreak:String, textFlow:TextFlow,
			format:ITextLayoutFormat):void
		{
			// trace("addTextFactoryFromFlowSprite",x,y,width,height,textAlign,verticalAlign,lineBreak);

			sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;

			addToCanvas(sprite);

			textFlowFactory.compositionBounds = new Rectangle(0,0,width?width:NaN,height?height:NaN);

			// trace("RSLT",textFlowFactory.compositionBounds);

			// For factory using TextFlow use this...
			// If we got a TextFlow, just use it. Otherwise create one from the String.
			textFlow.format = format;
			textFlow.textAlign = textAlign;
			textFlow.verticalAlign = verticalAlign;
			textFlow.lineBreak = lineBreak;


			// trace(TextConverter.export(textFlow,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.STRING_TYPE));
			textFlowFactory.createTextLines(callback,textFlow);
			addToCanvas(sprite);

			function callback(tl:TextLine):void
			{
				sprite.addChild(tl);
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

			if (kVerbose)
				trace(TestID,_creationType,textAlign,verticalAlign,lineBreak,width,height,fFactBounds);
			// trace("bounds",sFactBounds);
		}
		
		private function addTCMSprite(x:Number, y:Number, width:Number, height:Number, textAlign:String, verticalAlign:String, lineBreak:String, textFlow:TextFlow,
										   format:TextLayoutFormat):void
		{
			sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;
			
			var tcm:TextContainerManager = new TextContainerManager(sprite);

			
			textFlow.format = format;
			textFlow.textAlign = textAlign;
			textFlow.verticalAlign = verticalAlign;
			textFlow.lineBreak = lineBreak;
			
			tcm.compositionHeight = height;
			tcm.compositionWidth = width;
			tcm.verticalScrollPolicy = scrollPolicy;
			tcm.horizontalScrollPolicy = scrollPolicy;
				
			tcm.updateContainer();
			
			assertTrue("MGT:addTCMSprite expected factoryComposer",tcm.composeState == TextContainerManager.COMPOSE_FACTORY);
			
			var firstBounds:Rectangle = tcm.getContentBounds();
			
			var g:Graphics = sprite.graphics;
			drawCircle(g, 0xff00, 0, 0, 3);
			strokeRect(g, 1, 0x0, 0, 0, width, height);
			strokeRect(g, 1, 0xFF0000, firstBounds.left, firstBounds.top, firstBounds.width, firstBounds.height);
			// trace("addTextFactoryFromFlowSprite is running");

			if (kVerbose)
				trace("1",TestID,_creationType,textAlign,verticalAlign,lineBreak,width,height,firstBounds);

			tcm.beginInteraction();
			tcm.endInteraction();
			
			assertTrue("MGT:addTCMSprite expected standardComposer",tcm.composeState == TextContainerManager.COMPOSE_COMPOSER);
			
			var secondBounds:Rectangle = tcm.getContentBounds();
			if (kVerbose)
				trace("2",TestID,_creationType,textAlign,verticalAlign,lineBreak,width,height,secondBounds);
			
			assertTrue("MGT:addTCMSprite bad x coord",firstBounds.x == secondBounds.x);
			assertTrue("MGT:addTCMSprite bad y coord",firstBounds.y == secondBounds.y);
			assertTrue("MGT:addTCMSprite bad width",firstBounds.width == secondBounds.width);
			assertTrue("MGT:addTCMSprite bad height",firstBounds.height == secondBounds.height);
		}

		private function addTextFlowSprite(x:Number, y:Number, width:Number, height:Number, textAlign:String, verticalAlign:String, lineBreak:String, textFlow:TextFlow,
			format:TextLayoutFormat):void
		{
			sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;

			textFlow.interactionManager = new EditManager();


			textFlow.format = format;
			textFlow.textAlign = textAlign;
			textFlow.verticalAlign = verticalAlign;
			textFlow.lineBreak = lineBreak;

			var controller:ContainerController = new ContainerController(sprite,width,height);
			controller.verticalScrollPolicy = scrollPolicy;
			controller.horizontalScrollPolicy = scrollPolicy;
		//	controller.format = format;  Test adding padding directly to the container
			// trace(x,y,controller.compositionWidth,controller.compositionHeight,scrollPolicy);
			// trace(TextConverter.export(textFlow,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.STRING_TYPE));

			textFlow.flowComposer.addController(controller);
			textFlow.flowComposer.updateAllControllers();
			addToCanvas(sprite);
			drawFlowComposerBounds(textFlow);
			// trace(controller.getContentBounds());
			// trace("addTextFlowSprite is running");
		}

		private function drawFlowComposerBounds(textFlow:TextFlow):void
		{
			// composition bounds in black
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			var controllerSprite:Sprite = controller.container;
			var scrollx:Number = controllerSprite.scrollRect ? controllerSprite.scrollRect.x : 0;
			var scrolly:Number = controllerSprite.scrollRect ? controllerSprite.scrollRect.y : 0;

			sprite = new Sprite(); // controller.container as Sprite;
			sprite.x = controllerSprite.x;
			sprite.y = controllerSprite.y;
			addToCanvas(sprite);
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
			
			if (kVerbose)
				trace(TestID,_creationType,textFlow.textAlign,textFlow.verticalAlign,textFlow.lineBreak,width,height,compareBounds);
		}

		private function addLabel(x:Number, y:Number, width:Number, height:Number, text:String = ""):void
		{
			var sprite:Sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;
			labelFactory.compositionBounds = new Rectangle(0,0,width,height);
			labelFactory.text = text;

			labelFactory.createTextLines(callback);
			addToCanvas(sprite);

			function callback(tl:TextLine):void
			{
				sprite.addChild(tl);
			}
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



		/********************** Tests Start Here ***************************/

		public function testSimpleText():void
		{
			runTest("Hello again", createDefaultTextLayoutFormat());
		}


		public function testMultipleLines():void
		{
			// Multiple Lines
			marginOfError = 35;
			runTest("Hello again\nAnother longer line to test", createDefaultTextLayoutFormat());
		}

		public function testExtraLines():void
		{
			// Multiple Lines
			runTest("Line1\nLine2\nLine3", createDefaultTextLayoutFormat());
		}

		public function testTrailingSpaces():void
		{
			// Trailing spaces
			marginOfError = 12;
			runTest("Hello again  ", createDefaultTextLayoutFormat());
		}

		public function testHeightNoWidth():void
		{
			// Height but no width
			width = NaN;
			runTest("Hello again", createDefaultTextLayoutFormat());
		}

		public function testWidthNoHeight():void
		{
			// Width but no height
			height = NaN;
			runTest("Hello again", createDefaultTextLayoutFormat());
		}

		public function testEmptyText():void
		{
			// Empty text
			paddingWidth = 22;
			paddingHeight = 200;
			runTest("", createDefaultTextLayoutFormat());
		}

		public function testPaddingLeftAndTop():void
		{
			// Padding on left and top
			var format:TextLayoutFormat = createDefaultTextLayoutFormat();
			format.paddingLeft = 20;
			format.paddingTop = 10;
			paddingHeight = 92;
			runTest("Hello again", format);
		}

		public function testPaddingRightAndBottom():void
		{
			// Padding on right and bottom
			var format:TextLayoutFormat = createDefaultTextLayoutFormat();
			format.paddingRight = 20;
			format.paddingBottom = 10;
			paddingHeight = 92;
			runTest("Hello again", format);
		}

		public function testMultipleColumns():void
		{
			// Multiple Columns
			var format:TextLayoutFormat = createDefaultTextLayoutFormat();
			format.columnGap = 10;
			format.columnCount = 2;
			paddingHeight = 48;
			runTest("Hello again", format);
		}

		public function testInlineAtStartOfFlow():void
		{
			var format:TextLayoutFormat = createDefaultTextLayoutFormat();
			format.fontSize = 12;
			var markup:String = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008"><img id="im" width="25" height="25" source="' + LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/smiley.gif") + '" />The quick brown fox</TextFlow>';
			paddingHeight = 66;
			runTest(markup, format);
		}

		public function testInlineAtStartOfFlowBigText():void
		{
			var format:TextLayoutFormat = createDefaultTextLayoutFormat();
			format.fontSize = 48;
			var markup:String = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008"><img id="im" width="25" height="25" source="' + LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/smiley.gif") + '" />Hi</TextFlow>';
			paddingHeight = 130;
			runTest(markup, format);
		}

		public function testStartIndent():void
		{
			var format:TextLayoutFormat = createDefaultTextLayoutFormat();
			format.fontSize = 24;
			format.paragraphStartIndent = 30;
			marginOfError = 47;
			runTest('The quick brown fox', format);
		}

		public function testEndIndent():void
		{
			var format:TextLayoutFormat = createDefaultTextLayoutFormat();
			format.fontSize = 24;
			format.paragraphEndIndent = 30;
			marginOfError = 3;
			paddingHeight = 65;
			runTest('The quick brown fox', format);
		}

		public function testNegTextIndent():void
		{
			var format:TextLayoutFormat = createDefaultTextLayoutFormat();
			format.fontSize = 24;
			format.textIndent = -30;
			marginOfError = 30;
			runTest('The quick brown fox', format);
		}

		public function testSpaceBefore():void
		{
			var format:TextLayoutFormat = createDefaultTextLayoutFormat();
			format.fontSize = 24;
			format.paragraphSpaceBefore = 30;
			marginOfError = 3;
			paddingHeight = 22;
			runTest('The quick brown fox', format);
		}

		public function testSpaceAfter():void
		{
			var format:TextLayoutFormat = createDefaultTextLayoutFormat();
			format.fontSize = 24;
			format.paragraphSpaceAfter = 30;
			marginOfError = 3;
			paddingHeight = 22;
			runTest('The quick brown fox', format);
		}


		// Ideographic baseline examples needed


	}
}
