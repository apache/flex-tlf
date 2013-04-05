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
	import UnitTest.ExtendedClasses.TestSuiteExtended;
	import UnitTest.ExtendedClasses.VellumTestCase;
	import UnitTest.Fixtures.TestConfig;
	import UnitTest.Validation.MD5;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	import flash.system.*;
	import flash.text.engine.*;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.*;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextLineRecycler;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import mx.containers.Canvas;
	import mx.core.ByteArrayAsset;
	import mx.utils.LoaderUtil;

	use namespace tlf_internal;

	public class TextLineFilterTest extends VellumTestCase
	{
		private var displayobject:DisplayObject;
		private var TestCanvas:Canvas = null;
		private var ItemsToRemove:Array;
		private var text:String = 'There are many such lime-kilns in that tract of country. ';
		private var headingFlow:TextFlow;
        private var bodyFlow:TextFlow;
        private var headController:CustomContainerController;
        private var bodyController:CustomContainerController;

        private const bodyMarkup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' fontSize='18' " +
                "textIndent='10' paragraphSpaceBefore='6' paddingTop='8' paddingBottom='8' paddingLeft='8' paddingRight='8'>" +
            "<flow:p paragraphSpaceBefore='inherit' >" +
                "<flow:span>There are many </flow:span>" +
                "<flow:span fontStyle='italic'>such</flow:span>" +
                "<flow:span> lime-kilns in that tract of country, for the purpose of burning the white" +
                    " marble which composes a large part of the substance of the hills. Some of them, built " +
                    "years ago, and long deserted, with weeds growing in the vacant round of the interior, " +
                    "which is open to the sky, and grass and wild-flowers rooting themselves into the chinks " +
                    "of the stones, look already like relics of antiquity, and may yet be overspread with the" +
                    " lichens of centuries to come. Others, where the lime-burner still feeds his daily and " +
                    "nightlong fire, afford points of interest to the wanderer among the hills, who seats " +
                    "himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. " +
                    "It is a lonesome, and, when the character is inclined to thought, may be an intensely " +
                    "thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such " +
                    "strange purpose, in days gone by, while the fire in this very kiln was burning.</flow:span>" +
            "</flow:p>" +
            "<flow:p paragraphSpaceBefore='inherit'>" +
                "<flow:span>" +
                    "The man who now watched the fire was of a different order, and troubled himself with no " +
                    "thoughts save the very few that were requisite to his business. At frequent intervals, " +
                    "he flung back the clashing weight of the iron door, and, turning his face from the " +
                    "insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a " +
                    "long pole. Within the furnace were seen the curling and riotous flames, and the burning " +
                    "marble, almost molten with the intensity of heat; while without, the reflection of the " +
                    "fire quivered on the dark intricacy of the surrounding forest, and showed in the " +
                    "foreground a bright and ruddy little picture of the hut, the spring beside its door, the " +
                    "athletic and coal-begrimed figure of the lime-burner, and the halffrightened child, " +
                    "shrinking into the protection of his father's shadow. And when again the iron door was " +
                    "closed, then reappeared the tender light of the half-full moon, which vainly strove to " +
                    "trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, " +
                    "there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, " +
                    "though thus far down into the valley the sunshine had vanished long and long ago.</flow:span>" +
            "</flow:p>" +
        "</flow:TextFlow>";

		// embed alice - this simplifies things - don't need to trust the swf and pass the xml around with it
		[Embed(source="../../../../test/testFiles/markup/tlf/alice.xml",mimeType="application/octet-stream")]
		private var AliceClass : Class;

		public function TextLineFilterTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			ItemsToRemove = new Array();
			super(methodName, testID, testConfig, testCaseXML);
			//reset containerType and ID
			containerType = "custom";

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Container";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = TextLineFilterTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

		override public function setUp() : void
		{
			cleanUpTestApp();
			TestDisplayObject = testApp.getDisplayObject();
			if (TestDisplayObject)
			{
				TestCanvas = Canvas(TestDisplayObject);
			}
			else
			{
				fail ("Did not get a blank canvas to work with");
			}

		}
		private var bodyContainer:Sprite;
		public function initApp():void
		{
			// create body text flow, import body text, and assign flow composer
            bodyFlow = new TextFlow();
            bodyFlow = TextConverter.importToFlow(bodyMarkup, TextConverter.TEXT_LAYOUT_FORMAT);
            bodyFlow.flowComposer = new StandardFlowComposer();
			bodyContainer = new Sprite();
            bodyController = new CustomContainerController(bodyContainer, 800, 1000);
            bodyController.updateCompositionShapes();
            //bodyController.addTextLine(tl1, 0);
            bodyContainer.x = 20;
            bodyContainer.y = 20;
            // create container format to specify columns
            var bodyContainerFormat:TextLayoutFormat = new TextLayoutFormat();
            bodyContainerFormat.columnWidth = 390;
            bodyContainerFormat.columnGap = 15;
            bodyController.format = bodyContainerFormat;
            // enable scrolling
            bodyController.verticalScrollPolicy = ScrollPolicy.AUTO;
		}

 		/**
		 * Apply a filter to the text lines and the selection
		 */
		public function textlineAndSelectionFilterTest():void
		{
			initApp();
            bodyFlow.interactionManager = new SelectionManager();
            var selectManager:ISelectionManager = bodyFlow.interactionManager;
            selectManager.selectRange(0, 107);
            selectManager.refreshSelection();

            // add controller, add container to stage, and display body text
            bodyFlow.flowComposer.addController(bodyController);
            bodyFlow.flowComposer.updateAllControllers();



			TestCanvas.rawChildren.addChild(DisplayObject(bodyContainer));
			ItemsToRemove.push(bodyContainer);
			System.gc();	//mark
			System.gc();	//sweep

		}

		public function getBitmapFilter():BitmapFilter {
            var blurX:Number = 3;
            var blurY:Number = 3;
            return new BlurFilter(blurX, blurY, BitmapFilterQuality.HIGH);
        }

 		/**
		 * Apply a filter to the text lines, but not the selection
		 */

		public function textlinesFilterTest():void
		{
			initApp();
            bodyFlow.interactionManager = new SelectionManager();
            var selectManager:ISelectionManager = bodyFlow.interactionManager;


            // add controller, add container to stage, and display body text
            bodyFlow.flowComposer.addController(bodyController);
            bodyFlow.flowComposer.updateAllControllers();



			TestCanvas.rawChildren.addChild(DisplayObject(bodyContainer));
			ItemsToRemove.push(bodyContainer);
			System.gc();	//mark
			System.gc();	//sweep
		}

		/**
		 * Apply a filter to the selection, but not the textline
		 */
		public function selectionFilterTest():void
		{
			initApp();
            bodyFlow.interactionManager = new SelectionManager();
            var selectManager:ISelectionManager = bodyFlow.interactionManager;
            selectManager.selectRange(1000, 2000);
            selectManager.refreshSelection();

            // add controller, add container to stage, and display body text
            bodyFlow.flowComposer.addController(bodyController);
            bodyFlow.flowComposer.updateAllControllers();

			TestCanvas.rawChildren.addChild(DisplayObject(bodyContainer));
			ItemsToRemove.push(bodyContainer);
			System.gc();	//mark
			System.gc();	//sweep
		}

		private var recycledTextLine:TextLine;
		private var composedTextLine:TextLine;
		private var _lines:Array;
		private var textLine_invalid:TextLine;

		private static function createInvalidTextLine():TextLine
		{
			var elementFormat:ElementFormat = new ElementFormat();
			var textElement:TextElement = new TextElement("aaa", elementFormat)
			var textBlock:TextBlock = new TextBlock(textElement);
			var textLine:TextLine = textBlock.createTextLine();
			textLine.validity = TextLineValidity.INVALID;
			return textLine;
		}

		public function recycleLineByFlowComposer():void
		{
			//create an invald TextLine to recycle
			textLine_invalid = createInvalidTextLine();
			//recycle the invalid TextLine
			TextLineRecycler.emptyReusableLineCache();
			TextLineRecycler.addLineForReuse(textLine_invalid);
			recycledTextLine = textLine_invalid;

			//create a TextFlow
			var textFlow:TextFlow = new TextFlow();
			textFlow.mxmlChildren = [ "Hello, World" ];
			var textContainer:Sprite = new Sprite();
			var textController:ContainerController = new CustomContainerController(textContainer, 800, 1000);
			textFlow.flowComposer.addController(textController);

			//compose a single line which should be from recycler
			textFlow.flowComposer.updateAllControllers();
			TestCanvas.rawChildren.addChild(DisplayObject(textContainer));

			//check if the composed line is same as the recycled one
			composedTextLine = textFlow.flowComposer.getLineAt(0).getTextLine();
			assertTrue("The composed line is not same as recycled line.", recycledTextLine === composedTextLine);
		}

		public function recycleLineByFlowFactory():void
		{
			_lines = new Array();

			//create an invald TextLine to recycle
			textLine_invalid = createInvalidTextLine();

			//recycle the invalid TextLine
			TextLineRecycler.emptyReusableLineCache();
			TextLineRecycler.addLineForReuse(textLine_invalid);
			recycledTextLine = textLine_invalid;

			var factory:TextFlowTextLineFactory = new TextFlowTextLineFactory();
			factory.compositionBounds = new Rectangle( 100, 100, 200, 130 );
			var flow:TextFlow = new TextFlow();
			var span:SpanElement = new SpanElement();
			span.text = "Hello World.";
			var para:ParagraphElement = new ParagraphElement();
			para.addChild( span );
			flow.addChild( para );

			//compose a single line which should be from recycler
			factory.createTextLines(useTextLines, flow );

			//check if the composed line is same as the recycled one
			composedTextLine = _lines[0];
			assertTrue("The composed line is not same as recycled line.", recycledTextLine === composedTextLine);
		}

		public function recycleLineByStringFactory():void
		{
			_lines = new Array();

			//create an invald TextLine to recycle
			textLine_invalid = createInvalidTextLine();

			//recycle the invalid TextLine
			TextLineRecycler.emptyReusableLineCache();
			TextLineRecycler.addLineForReuse(textLine_invalid);
			recycledTextLine = textLine_invalid;

			var factory:StringTextLineFactory = new StringTextLineFactory();
			factory.compositionBounds = new Rectangle( 100, 100, 200, 130 );
			factory.text = "Hello World";

			//compose a single line which should be from recycler
			factory.createTextLines(useTextLines);

			//check if the composed line is same as the recycled one
			composedTextLine = _lines[0];
			assertTrue("The composed line is not same as recycled line.", recycledTextLine === composedTextLine);
		}
		
		public function stringFactoryBackgroundColor():void
		{
			_lines = new Array();
			
			var factory:StringTextLineFactory = new StringTextLineFactory();
			factory.compositionBounds = new Rectangle( 100, 100, 200, 130 );
			factory.text = "Hello World";
			
			factory.textFlowFormat = TextLayoutFormat.createTextLayoutFormat({blockProgression:writingDirection[0],direction:writingDirection[1]});
			factory.spanFormat = TextLayoutFormat.createTextLayoutFormat({backgroundColor:0xffff4F,fontSize:48});
			factory.createTextLines(useTextLines);
		}

		private function useTextLines( tl:DisplayObject ):void
		{
			_lines.push(tl);
			TestCanvas.rawChildren.addChild( tl );
		}

		public function recycleLineByCustomLineCreatorTextFlow():void
		{
			//create an invald TextLine to recycle
			textLine_invalid = createInvalidTextLine();

			//recycle the invalid TextLine
			TextLineRecycler.emptyReusableLineCache();
			TextLineRecycler.addLineForReuse(textLine_invalid);
			recycledTextLine = textLine_invalid;

			//Create a TextFlow
			var textFlow:TextFlow = new TextFlow();
			textFlow.mxmlChildren = [ "Hello, World" ];
			var textContainer:Sprite = new Sprite();
			var textController:ContainerController = new CustomContainerController(textContainer, 800, 1000);
			textFlow.flowComposer.addController(textController);

			//monitor if the TextLine created from recycler
			var myswfContext:MySwfContext = new MySwfContext()
			textFlow.flowComposer.swfContext = myswfContext;
			textFlow.flowComposer.updateAllControllers();

			//check if composed line is same as recycled line and if createTextLine gets the recycled line
			composedTextLine = textFlow.flowComposer.getLineAt(0).getTextLine();
			assertTrue("The composed line is not same as recycled line.", recycledTextLine === composedTextLine
				&& myswfContext.numRecycledLines == 1);

			//monitor if the TextLine created from new
			textFlow.mxmlChildren = [ "Again, Hello, World " ];
			textFlow.flowComposer.swfContext = myswfContext;
			textFlow.flowComposer.updateAllControllers();
			assertTrue("The composed line is not newly created", myswfContext.numLinesCreated == 1);

			TestCanvas.rawChildren.addChild(DisplayObject(textContainer));
		}

		public function recycleLineByTCM():void
		{
			//create an invald TextLine to recycle
			textLine_invalid = createInvalidTextLine();
			//recycle the invalid TextLine
			TextLineRecycler.emptyReusableLineCache();
			TextLineRecycler.addLineForReuse(textLine_invalid);
			recycledTextLine = textLine_invalid;

			//create a TextFlow by TCM using the recycled line
			var sprite:Sprite = new Sprite();
			sprite.x = 50; sprite.y = 50;
			var tcm:TextContainerManager = new TextContainerManager(sprite);
			tcm.setText("Hello World");
			tcm.updateContainer();
			var editManager:EditManager = EditManager(tcm.beginInteraction())
			editManager.selectRange(0, 0);
			var textFlow:TextFlow = tcm.getTextFlow();

			//check if the composed line is same as the recycled one
			composedTextLine = textFlow.flowComposer.getLineAt(0).getTextLine();
			assertTrue("The composed line is not same as recycled line.", recycledTextLine === composedTextLine);
			TestCanvas.rawChildren.addChild(DisplayObject(sprite));
			TestCanvas.rawChildren.addChild(sprite);
		}

		public function recycleLineByCustomLineCreatorFlowFactory():void
		{
			_lines = new Array();

			//create an invald TextLine to recycle
			textLine_invalid = createInvalidTextLine();

			//recycle the invalid TextLine
			TextLineRecycler.emptyReusableLineCache();
			TextLineRecycler.addLineForReuse(textLine_invalid);
			recycledTextLine = textLine_invalid;

			var factory:TextFlowTextLineFactory = new TextFlowTextLineFactory();
			factory.compositionBounds = new Rectangle( 100, 100, 200, 130 );

			//Create a TextFlow
			var flow:TextFlow = new TextFlow();
			flow.mxmlChildren = [ "Hello, World" ];

			//create custom TextLine creator
			var myswfContext:MySwfContext = new MySwfContext()
			flow.flowComposer.swfContext = myswfContext;
			factory.swfContext = flow.flowComposer.swfContext;

			//compose a single line which should be from recycler using FlowFactory
			factory.createTextLines(useTextLines, flow );

			//check if the composed line is same as the recycled one
			composedTextLine = _lines[0];
			assertTrue("The composed line is not same as recycled line.", recycledTextLine === composedTextLine
			&& myswfContext.numRecycledLines == 1);

			//monitor if the TextLine created from new
			flow.mxmlChildren = [ "Again, Hello, World " ];
			factory.compositionBounds = new Rectangle( 100, 200, 200, 130 );
			factory.createTextLines(useTextLines, flow );
			assertTrue("The composed line is not newly created", myswfContext.numLinesCreated == 1);
		}

		public function recycleLineByCustomLineCreatorStringFactory():void
		{
			_lines = new Array();

			//create an invald TextLine to recycle
			textLine_invalid = createInvalidTextLine();

			//recycle the invalid TextLine
			TextLineRecycler.emptyReusableLineCache();
			TextLineRecycler.addLineForReuse(textLine_invalid);
			recycledTextLine = textLine_invalid;

			var factory:StringTextLineFactory = new StringTextLineFactory();
			factory.compositionBounds = new Rectangle( 100, 100, 200, 130 );
			factory.text = "Hello World";

			//create custom TextLine creator
			var myswfContext:MySwfContext = new MySwfContext()
			factory.swfContext = myswfContext;

			//compose a single line which should be from recycler using FlowFactory
			factory.createTextLines(useTextLines);

			//check if the composed line is same as the recycled one
			composedTextLine = _lines[0];
			assertTrue("The composed line is not same as recycled line.", recycledTextLine === composedTextLine
			&& myswfContext.numRecycledLines == 1);

			//monitor if the TextLine created from new
			factory.text = "Again, Hello World";
			factory.compositionBounds = new Rectangle( 100, 200, 200, 130 );
			factory.createTextLines(useTextLines);
			assertTrue("The composed line is not newly created", myswfContext.numLinesCreated == 1);
		}

		public function recycleLineByCustomLineCreatorTCM():void
		{
			_lines = new Array();

			//create an invald TextLine to recycle
			textLine_invalid = createInvalidTextLine();

			//recycle the invalid TextLine
			TextLineRecycler.emptyReusableLineCache();
			TextLineRecycler.addLineForReuse(textLine_invalid);
			recycledTextLine = textLine_invalid;

			//create a TextFlow by TCM using the recycled line
			var sprite:Sprite = new Sprite();
			sprite.x = 50; sprite.y = 50;
			var tcm:TextContainerManager = new TextContainerManager(sprite);
			tcm.setText("Hello World");
			tcm.updateContainer();
			var editManager:EditManager = EditManager(tcm.beginInteraction());
			editManager.selectRange(0, 0);
			var textFlow:TextFlow = tcm.getTextFlow();

			//check if the composed line is same as the recycled one
			composedTextLine = textFlow.flowComposer.getLineAt(0).getTextLine();
			assertTrue("The composed line is not same as recycled line.", recycledTextLine === composedTextLine);
			TestCanvas.rawChildren.addChild(sprite);
		}

		public function recycleLineInSuite():void
		{
			var alice:ByteArrayAsset = new AliceClass();
			var aliceData:String = alice.readMultiByte(alice.length,"utf-8");
			var textFlow:TextFlow = TextConverter.importToFlow(aliceData, TextConverter.TEXT_LAYOUT_FORMAT);

			TextLineRecycler.emptyReusableLineCache();
			TextLineRecycler.textLineRecyclerEnabled = false;
			var s:Sprite = new Sprite();
			s.x = 50; s.y = 50;
			var tcm:TextContainerManager = new TextContainerManager(s);
			tcm.compositionWidth = 500;
			tcm.compositionHeight = NaN;
			tcm.setTextFlow(textFlow);
			tcm.updateContainer();

			displayobject = testApp.getDisplayObject();
			var bits:BitmapData = new BitmapData(displayobject.width, displayobject.height);
			bits.draw(TestDisplayObject as IBitmapDrawable);
			bitmapSnapshot = new Bitmap(bits);
			bits = null;
			var pixels:ByteArray = bitmapSnapshot.bitmapData.getPixels(bitmapSnapshot.bitmapData.rect);
			pixels.compress();
			pixels.position = 0;
			var checksumRecyclingOff:String = MD5.hashBinary(pixels);

			//create a bunch(100) of invald TextLines to recycle
			TextLineRecycler.emptyReusableLineCache();
			TextLineRecycler.textLineRecyclerEnabled = true;
			var i:int = 0;
			while (i<=100)
			{
				var textLine_invalid:TextLine = createInvalidTextLine();
				TextLineRecycler.addLineForReuse(textLine_invalid);
				i++;
			}

			//recompose the text flow with the recycled lines
			tcm.updateContainer();

			//get checksum for recycling on
			var bits_2:BitmapData = new BitmapData(displayobject.width, displayobject.height);
			bits_2.draw(TestDisplayObject as IBitmapDrawable);
			bitmapSnapshot = new Bitmap(bits_2);
			bits_2 = null;
			pixels = bitmapSnapshot.bitmapData.getPixels(bitmapSnapshot.bitmapData.rect);
			pixels.compress();
			pixels.position = 0;
			var checksumRecyclingOn:String = MD5.hashBinary(pixels);

			//check if there is any rendering difference
			assertTrue("the rendering changed between recycle on and off.", checksumRecyclingOn == checksumRecyclingOff);
			TestCanvas.rawChildren.addChild(DisplayObject(s));
		}
		
		private var tf:TextFlow = new TextFlow();
		
		public function embeddedInlineGraphics(callback:Object = null):void
		{	
			if(!callback)
			{
				callback = true;
				tf.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(embeddedInlineGraphics,2500,null),false,0,true);	
				var TestCanvas:Canvas;
				TestDisplayObject = testApp.getDisplayObject();
				if (TestDisplayObject)
				{
					TestCanvas = Canvas(TestDisplayObject);
				}
				
				var container:Sprite = new Sprite();
				TestCanvas.rawChildren.addChild(container);

				var p:ParagraphElement = new ParagraphElement();
				var span:SpanElement = new SpanElement();
				
				// add text to the span
				span.text = "AAAAAAAA";
				
				p.addChild(span);
				tf.addChild(p);
				
				// update controller to display text
				var controller:ContainerController = new CustomContainerController(container, 400, 200);
				tf.flowComposer.addController(controller);
				tf.flowComposer.updateAllControllers();
				
				var src:String = "smiley.gif";
				var width:int = 20;
				var height:int = 20;
				var baseImageURL:String = LoaderUtil.createAbsoluteURL(baseURL, "../../test/testFiles/assets/");
				var selectManager:IEditManager = new EditManager();
				tf.interactionManager = selectManager;
						
				selectManager.setFocus();
				selectManager.selectRange(3, 3);
				
				var inlineGraphicElement:InlineGraphicElement = selectManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
				tf.flowComposer.updateAllControllers();				
			}
			else // Make sure the image is ready before we let the snapshot go
			{
					
				var img:InlineGraphicElement = tf.findLeaf(3) as InlineGraphicElement;
				if(img.status != InlineGraphicElementStatus.READY)
				{
					tf.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(embeddedInlineGraphics,2500,null),false,0,true);
				}
			}
			
		}
	}
}

import flash.display.BlendMode;
import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObjectContainer;
import flash.text.engine.TextLine;
import flashx.textLayout.container.ContainerController;
import flash.filters.*;
import flashx.textLayout.tlf_internal;
import flash.display.DisplayObject;

use namespace tlf_internal;

class CustomContainerController extends ContainerController
{
	
	public function CustomContainerController(container:Sprite,compositionWidth:Number=100,compositionHeight:Number=100)
	{
		super(container,compositionWidth,compositionHeight);

		// We'll put all text lines in a nested container
 		// Filters applied to this container won't affect other objects like selection or background shapes
		_textLineContainer = new Sprite();
		//_textLineContainer.filters = [ new DropShadowFilter() ]; // apply a filter  (for illustration)
		container.addChild(_textLineContainer);
 	}
	// Return the index where the first text line should appear in its parent
	// Since our _textLineContainer only holds text lines, return zero
	protected override function getFirstTextLineChildIndex():int
	{
		return 0;
	}
	// Add a text line at the specified index
	protected override function addTextLine(textLine:TextLine, index:int):void
	{
    	if(index == 0)
        textLine.filters = [ new BlurFilter(3, 3, BitmapFilterQuality.HIGH) ];
        _textLineContainer.addChildAt(textLine, index);
	}
	
	protected override function addInlineGraphicElement(parent:DisplayObjectContainer, inlineGraphicElement:DisplayObject, index:int):void
	{
		parent.addChildAt(inlineGraphicElement, index);
		
	}	
	
	// Remove a text line, but only if it is in _textLineContainer
	// (A text line may have moved to another container because of 'shuffling')
	protected override function removeTextLine(textLine:TextLine):void
	{
		if (_textLineContainer.contains(textLine))
		{
			textLine.filters = null;
  			_textLineContainer.removeChild(textLine);
		}
	}

	// Add the container for selection shapes (block or point selection)
	protected override function addSelectionContainer(selectionContainer:DisplayObjectContainer):void
	{
		// If selection container is opaque or has normal blend mode, put selection container behind the text lines, else in front
		var filter:BlurFilter = new BlurFilter(10, 10, BitmapFilterQuality.HIGH);
        var myFilters:Array = new Array();
        myFilters.push(filter);
        selectionContainer.filters = myFilters;
		var index:int = selectionContainer.blendMode == BlendMode.NORMAL && selectionContainer.alpha == 1 ? container.getChildIndex(_textLineContainer) : container.numChildren;
		container.addChildAt(selectionContainer, index);
	}

	// Remove the container for selection shapes
	protected override function removeSelectionContainer(selectionContainer:DisplayObjectContainer):void
	{
		container.removeChild(selectionContainer);
	}

	// Add the background shape
	protected override function addBackgroundShape(shape:Shape):void
	{
		container.addChildAt(shape, 0); // behind everything else, so use index 0
	}
	private var _textLineContainer:Sprite;

}

import flashx.textLayout.formats.TextLayoutFormat;
import flashx.textLayout.compose.ISWFContext;
import flash.text.engine.TextBlock;
import flashx.textLayout.elements.Configuration;

class MySwfContext implements ISWFContext
{
	public var numLinesCreated:int = 0;
	public var numRecycledLines:int = 0;

	public function callInContext(fn:Function, thisArg:Object, argsArray:Array, returns:Boolean=true):*
	{
		var textBlock:TextBlock = thisArg as TextBlock;
		if (textBlock)
		{
			if (fn == textBlock.createTextLine)
			{
				numLinesCreated++;      // COUNT: create a new TextLine
			}
			else if (Configuration.playerEnablesArgoFeatures && fn == thisArg["recreateTextLine"])
			{
				numRecycledLines++;     // COUNT: make a TextLine using a recycled line
			}
		}
		if (returns)
			return fn.apply(thisArg, argsArray);
		fn.apply(thisArg, argsArray);
	}
}



