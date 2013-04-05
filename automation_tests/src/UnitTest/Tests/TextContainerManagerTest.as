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
	import UnitTest.Fixtures.FileRepository;
	import UnitTest.Fixtures.TestConfig;
	import UnitTest.Validation.DamageEventValidator;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditingMode;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.DamageEvent;
	import flashx.textLayout.events.SelectionEvent;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

	import mx.containers.Canvas;
	import mx.core.ByteArrayAsset;
	import mx.utils.LoaderUtil;

	import flash.geom.Point;
	import flash.display.DisplayObject;
	import flashx.textLayout.edit.ISelectionManager;
	import flash.utils.Dictionary;
	import flashx.textLayout.elements.FlowLeafElement;
	import flash.text.engine.TextLine;

	public class TextContainerManagerTest extends VellumTestCase
	{
		[Embed(source="../../../../test/testFiles/markup/tlf/alice.xml",mimeType="application/octet-stream")]
	    private var AliceClass : Class;

		private var TestCanvas:Canvas = null;

		public function TextContainerManagerTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			// important - tells the tearDown method how to cleanup
			containerType = "custom";

			metaData.productArea = "Text Container";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
			FileRepository.readFile(testConfig.baseURL,"backgroundColorTest.xml");

 			var testCaseClass:Class = TextContainerManagerTest;
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

		private function addTCM( applyTestSettings:Boolean = true, xPos:int = 10, yPos:int = 10, configuration:IConfiguration = null ):TextContainerManager
		{
			var newSprite:Sprite = new Sprite();
			newSprite.x = xPos;
			newSprite.y = yPos;
			var newTCM:TextContainerManager = new TextContainerManager(newSprite, configuration);
			TestCanvas.rawChildren.addChild(newSprite);

			if ( applyTestSettings == true )
			{
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.blockProgression = writingDirection[0];
				format.direction = writingDirection[1];
				newTCM.hostFormat = format;
			}

			assertTrue( "container property returning incorrect container", newTCM.container == newSprite );

			return newTCM;
		}

		private function addCustomTCM( xPos:int = 10, yPos:int = 10, configuration:IConfiguration = null ):CustomTCM
		{
			var newSprite:Sprite = new Sprite();
			newSprite.x = xPos;
			newSprite.y = yPos;
			var newTCM:CustomTCM = new CustomTCM(newSprite, configuration);
			TestCanvas.rawChildren.addChild(newSprite);

			var format:TextLayoutFormat = new TextLayoutFormat();
			format.blockProgression = writingDirection[0];
			format.direction = writingDirection[1];
			newTCM.hostFormat = format;

			assertTrue( "container property returning incorrect container", newTCM.container == newSprite );

			return newTCM;
		}

		public function basicTCMTest():void
		{
			var testTCM:TextContainerManager = addTCM(false);

			assertTrue( "defaultConfiguration not assigned to new TCM", Configuration(testTCM.configuration).getImmutableClone() == Configuration(TextContainerManager.defaultConfiguration).getImmutableClone() );
			assertTrue( "hostFormat should not be set by default", testTCM.hostFormat == null );

			var testString:String = "This is a test of the TextContainerManager system!";
			testTCM.setText(testString);
			testTCM.updateContainer();
			assertTrue( "setText/getText failure", testTCM.getText("") == testString );

			testTCM.compositionWidth = 58;
			testTCM.compositionHeight = 24;
			assertTrue( "TCM not set to damaged after composition size change", testTCM.isDamaged() == true );

			testTCM.updateContainer();
			assertTrue( "compositionWidth set incorrectly", testTCM.compositionWidth == 58 );
			assertTrue( "compositionHeight set incorrectly", testTCM.compositionHeight == 24 );
		}

		public function hostFormatTCMTest():void
		{
			var testTCM:TextContainerManager = addTCM();
			testTCM.setText("Testing the TextContainerManager with a hostFormat set");
			testTCM.updateContainer();

			assertTrue( "test-specified blockProgression not set", testTCM.hostFormat.blockProgression == writingDirection[0] );
			assertTrue( "test-specified direction not set", testTCM.hostFormat.direction == writingDirection[1] );
		}
		
		public function hostFormatTabsTCMTestString():void
		{
			var testTCM:TextContainerManager = addTCM();
			testTCM.compositionWidth = 500;
			testTCM.hostFormat = new HostFormatTabsTCMTest();
			testTCM.setText("Col 1\tCol 2\tCol 3\tCol 4");
			testTCM.updateContainer();
		}
		
		public function hostFormatTabsTCMTestTextFlow():void
		{
			var testTCM:TextContainerManager = addTCM();
			testTCM.compositionWidth = 500;
			testTCM.hostFormat = new HostFormatTabsTCMTest();
			testTCM.setText("Col 1\tCol 2\tCol 3\tCol 4");
			testTCM.beginInteraction();
			testTCM.endInteraction();
			testTCM.updateContainer();
		}
		
		public function lineBreakTCMTest():void
		{
			var testTCM:TextContainerManager = addTCM();
			testTCM.setText("Testing the TextContainerManager with a line breaks set to explicit");
			if ( testTCM.hostFormat.blockProgression == BlockProgression.RL )
				testTCM.compositionHeight = 100;
			else
				testTCM.compositionWidth = 100;
			testTCM.updateContainer();
			if ( testTCM.hostFormat.blockProgression == BlockProgression.RL )
				assertTrue( "Content width does not match LineBreak setting", testTCM.getContentBounds().height <= 100 );
			else
				assertTrue( "Content width does not match LineBreak setting", testTCM.getContentBounds().width <= 100 );

			var testFormat:TextLayoutFormat = testTCM.hostFormat as TextLayoutFormat;
			testFormat.lineBreak = LineBreak.EXPLICIT;
			testTCM.hostFormat = testFormat;
			testTCM.updateContainer();

			assertTrue( "LineBreak.EXPLICIT not set", testTCM.hostFormat.lineBreak == LineBreak.EXPLICIT );
			if ( testTCM.hostFormat.blockProgression == BlockProgression.RL )
				assertTrue( "compositionHeight does not match explicit linebreak setting", testTCM.getContentBounds().height > 100 );
			else
				assertTrue( "compositionWidth does not match explicit linebreak setting", testTCM.getContentBounds().width > 100 );
		}

		public function textflowTCMTest():void
		{
			var testTCM:TextContainerManager = addTCM();
			var newFlow:TextFlow = TextConverter.importToFlow( "This is a TextFlow that I will be testing in a TCM and stuff", TextConverter.PLAIN_TEXT_FORMAT );
			testTCM.setTextFlow( newFlow );
			testTCM.updateContainer();

			testTCM.compositionWidth = 13;
			testTCM.compositionHeight = 18;
			testTCM.updateContainer();

			var contentSize:Rectangle = testTCM.getContentBounds();
			if ( testTCM.hostFormat.blockProgression == BlockProgression.RL )
				assertTrue( "Content height incorrect on a textflow TCM", contentSize.height <= 18 );
			else
				assertTrue( "Content width incorrect on a textflow TCM", contentSize.width <= 13 );

			var testFormat:TextLayoutFormat = new TextLayoutFormat();
			testFormat.breakOpportunity = testTCM.hostFormat.breakOpportunity;
			testFormat.direction = testTCM.hostFormat.direction;
			testFormat.lineBreak = LineBreak.EXPLICIT;
			testTCM.hostFormat = testFormat;
			testTCM.updateContainer();

			assertTrue( "LineBreak.EXPLICIT not set", testTCM.hostFormat.lineBreak == LineBreak.EXPLICIT );
			contentSize = testTCM.getContentBounds();
			if ( testTCM.hostFormat.blockProgression == BlockProgression.RL )
				assertTrue( "compositionHeight does not match explicit linebreak setting", testTCM.getContentBounds().height > 18 );
			else
				assertTrue( "compositionWidth does not match explicit linebreak setting", testTCM.getContentBounds().width > 13 );

			assertTrue( "getTextFlow failed to return the original flow", testTCM.getTextFlow() == newFlow );
		}

		// TODO: This needs real scrolling validation - not just checking the get/set properties
		public function scrollPolicyTCMTest():void
		{
			var testTCM:TextContainerManager = addTCM();
			testTCM.setText("Testing the TextContainerManager's scroll policy properties");
			testTCM.updateContainer();

			assertTrue( "vertical scroll policy did not default to AUTO", testTCM.verticalScrollPolicy == ScrollPolicy.AUTO );
			assertTrue( "horizontal scroll policy did not default to AUTO", testTCM.horizontalScrollPolicy == ScrollPolicy.AUTO );

			testTCM.verticalScrollPolicy = ScrollPolicy.OFF;
			assertTrue( "get/set vertical scroll policy to OFF failed", testTCM.verticalScrollPolicy == ScrollPolicy.OFF );
			testTCM.horizontalScrollPolicy = ScrollPolicy.OFF;
			assertTrue( "get/set horizontal scroll policy to OFF failed", testTCM.horizontalScrollPolicy == ScrollPolicy.OFF );

			testTCM.verticalScrollPolicy = ScrollPolicy.ON;
			assertTrue( "get/set vertical scroll policy to ON failed", testTCM.verticalScrollPolicy == ScrollPolicy.ON );
			testTCM.horizontalScrollPolicy = ScrollPolicy.ON;
			assertTrue( "get/set horizontal scroll policy to ON failed", testTCM.horizontalScrollPolicy == ScrollPolicy.ON );
		}

		// TODO: This needs real scrolling validation - not just checking the get/set properties
		public function scrollPositionTCMTest():void
		{
			var testTCM:TextContainerManager = addTCM();
			testTCM.setText("Testing the TextContainerManager's scroll policy position on a textflow long enough to be interesting");
			testTCM.compositionHeight = 15;
			testTCM.updateContainer();

			assertTrue( "vertical scroll position did not default to 0", testTCM.verticalScrollPosition == 0 );
			assertTrue( "horizontal scroll position did not default to 0", testTCM.horizontalScrollPosition == 0 );

			var scrollDelta:Number = testTCM.getScrollDelta(2);
			testTCM.verticalScrollPosition = scrollDelta;
			testTCM.updateContainer();

			assertTrue( "vertical scroll position did change by scroll delta", testTCM.verticalScrollPosition == scrollDelta );
			testTCM.verticalScrollPosition = 0;

			var testFormat:TextLayoutFormat = new TextLayoutFormat();
			testFormat.breakOpportunity = testTCM.hostFormat.breakOpportunity;
			testFormat.direction = testTCM.hostFormat.direction;
			testFormat.lineBreak = LineBreak.EXPLICIT;
			testTCM.hostFormat = testFormat;
			testTCM.updateContainer();

			testTCM.horizontalScrollPosition = 15;
			testTCM.updateContainer();

			assertTrue( "horizontal scroll position did change by scroll delta", testTCM.horizontalScrollPosition == 15);
		}

		public function twoParagraphTCMTest():void
		{
			var newFlow:TextFlow = new TextFlow();
			var p1Text:String = "This is the first paragraph";
			var p2Text:String = "This is the second paragraph";

			var p1:ParagraphElement = new ParagraphElement();
			var s1:SpanElement = new SpanElement();
			s1.text = p1Text;
			p1.addChild(s1);
			newFlow.addChild(p1);

			var testTCM:TextContainerManager = addTCM();
			testTCM.setTextFlow(newFlow);

			assertTrue( "getText failure", testTCM.getText("") == p1Text );

			var p2:ParagraphElement = new ParagraphElement();
			var s2:SpanElement = new SpanElement();
			s2.text = p2Text;
			p2.addChild(s2);
			newFlow.addChild(p2);

			testTCM.updateContainer();

			assertTrue( "getText failure", testTCM.getText("") == p1Text + p2Text );
			//LEGIT:? o longer a legitimate test as \u2029 is not part of paraElem, but this might still be OK.
			assertTrue( "getText separator failure", testTCM.getText() == p1Text + '\u2029' + p2Text );
			assertTrue( "getText separator failure", testTCM.getText("\n") == p1Text + "\n" + p2Text );

			testTCM.compositionWidth = 100;
			testTCM.compositionHeight = 50;
			testTCM.updateContainer();
			assertTrue( "compositionWidth set incorrectly", testTCM.compositionWidth == 100 );
			assertTrue( "compositionHeight set incorrectly", testTCM.compositionHeight == 50 );

			// add some text to the final span and make sure it gets set
			var lastLeaf:SpanElement = testTCM.getTextFlow().getLastLeaf() as SpanElement;
			var extraText:String =". Bye now.";
			lastLeaf.text = lastLeaf.text + extraText;
			assertTrue( "getText failure", testTCM.getText("") == p1Text + p2Text + extraText);


			testTCM.setText( "Testing setText on a TextFlow-generated TCM" );
			testTCM.updateContainer();
			assertTrue( "setText/getText did not match on TextFlow TCM", testTCM.getText("") == "Testing setText on a TextFlow-generated TCM" );
		}
		
		public const scrollToRangeMarkup:String =
			"<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>" +
			"<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec quis metus mi. Morbi augue neque, vestibulum sit amet rhoncus at, interdum quis lectus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Suspendisse potenti. Praesent rutrum erat eget nulla ma<span  color='0xff0000'>lesua</span>da tristique. Nulla sit amet tempus magna. Duis turpis tellus, imperdiet at dignissim nec, vehicula non eros. Vestibulum vel tincidunt arcu. Cras auctor elit vitae lacus tincidunt ut tincidunt turpis gravida. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</p>" +
			"<p>Vivamus id tristique nisl. Proin consectetur laoreet nunc at cursus. Cras pulvinar lorem ut neque adipiscing nec dapibus purus rutrum. Cras sit amet mauris sit amet nisi aliquam dapibus. Proin ipsum dui, semper eu ornare sed, aliquet vitae est. Suspendisse elementum placerat nibh, eget malesuada erat facilisis id. Etiam pretium lorem ac eros rhoncus in fringilla nisl commodo. Sed vel ligula nulla. Donec quis nulla arcu. Mauris et nulla felis, eu aliquet arcu. Vivamus laoreet diam vitae orci pellentesque sed dapibus nibh laoreet.</p>" +
			"<p>Etiam sollicitudin, libero a sagittis egestas, odio ligula euismod odio, nec euismod risus dui id justo. Duis a augue feugiat est luctus porttitor. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Fusce sapien nulla, porta ut facilisis nec, malesuada nec eros. Maecenas eget mauris odio. Aliquam condimentum, magna sit amet bibendum ultricies, augue ipsum egestas metus, eu consequat felis tortor sit amet turpis. Aenean commodo venenatis diam in mollis. Donec et elementum nunc. Integer dignissim adipiscing nunc, eu tincidunt felis suscipit sed. In hac habitasse platea dictumst. Donec vitae sapien vel mi ornare condimentum. Aliquam ornare metus eget nisi viverra ut accumsan lacus varius. Nulla facilisi. Morbi molestie eros sed tellus rhoncus non feugiat neque lacinia. Mauris quis mauris sit amet lorem iaculis posuere. Fusce quis ornare eros. Donec aliquam magna nec metus scelerisque ac luctus sem ultrices.</p>" +
			"</TextFlow>";

		public function scrollToRangeTest():void
		{

	        var tConverter:TextConverter = new TextConverter();
	        var textFlow:TextFlow = TextConverter.importToFlow(scrollToRangeMarkup, TextConverter.TEXT_LAYOUT_FORMAT);
			var testTCM:TextContainerManager = addTCM();
			testTCM.setTextFlow(textFlow);

			var format:TextLayoutFormat = new TextLayoutFormat(TextLayoutFormat.defaultFormat);
	        format.fontFamily = "Arial";
	        format.fontSize = 12;
	        format.paddingLeft = 3;
	        format.paddingTop = 5;
	        format.paddingRight = 3;
	        format.paddingBottom = 3;

	        testTCM.hostFormat = format;
	        testTCM.compositionWidth = 186;
	        testTCM.compositionHeight = 144;

	        testTCM.setTextFlow(textFlow);

	        // ma**lesua**da tristique
	        testTCM.scrollToRange(testTCM.getText().length, testTCM.getText().length);
	        testTCM.scrollToRange(300, 305);
	        testTCM.scrollToRange(0, 0);

	        // text not/barely visible after scroll
	        testTCM.scrollToRange(300, 305);

	        testTCM.updateContainer();
	        assertTrue( "Doesn't get the red text",Math.round(testTCM.verticalScrollPosition) == 16);
		}
		
		public function scrollToRangeExplicitMeasureTest():void
		{
			var tConverter:TextConverter = new TextConverter();
			var textFlow:TextFlow = TextConverter.importToFlow(scrollToRangeMarkup, TextConverter.TEXT_LAYOUT_FORMAT);
			var testTCM:TextContainerManager = addTCM();
			testTCM.setTextFlow(textFlow);
			
			var format:TextLayoutFormat = new TextLayoutFormat(testTCM.hostFormat);
			format.fontFamily = "Arial";
			format.fontSize = 12;
			format.paddingLeft = 3;
			format.paddingTop = 5;
			format.paddingRight = 3;
			format.paddingBottom = 3;
			format.lineBreak = LineBreak.EXPLICIT;
			
			
			testTCM.hostFormat = format;
			testTCM.compositionWidth = format.blockProgression == BlockProgression.RL ? NaN : 186;
			testTCM.compositionHeight = format.blockProgression == BlockProgression.TB ? NaN : 144;
			
			testTCM.setTextFlow(textFlow);
			
			// ma**lesua**da tristique
			testTCM.scrollToRange(testTCM.getText().length, testTCM.getText().length);
			testTCM.scrollToRange(300, 305);
			testTCM.scrollToRange(0, 0);
			
			// text not/barely visible after scroll
			testTCM.scrollToRange(300, 305);
			
			testTCM.updateContainer();
		}

		public function scrollMaxValueTest():void
		{
			var markup:String =
                "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>" +
                "<p>1 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>2 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>3 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>4 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>5 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>6 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>7 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>8 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>9 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>10 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>11 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>12 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>13 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>14 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>15 The quick brown fox jumps over the lazy dog.</p>" +
                "<p>16The quick brown fox jumps over the lazy dog.</p>" +
                "</TextFlow>";

            var tConverter:TextConverter = new TextConverter();
            var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			var testTCM:TextContainerManager = addTCM();
			testTCM.setTextFlow(textFlow);

			var format:TextLayoutFormat = new TextLayoutFormat(TextLayoutFormat.defaultFormat);
            format.fontFamily = "Arial";

            testTCM.hostFormat = format;

            testTCM.compositionWidth = 172;
            testTCM.compositionHeight = 149;

            testTCM.setTextFlow(textFlow);

            var max:uint = uint.MAX_VALUE;
            /*if (max > int.MAX_VALUE)
            	trace("bigger");
            else if (max < int.MAX_VALUE)
                trace("less than");*/

            testTCM.scrollToRange(testTCM.getText().length, int.MAX_VALUE);

            testTCM.updateContainer();
            assertTrue( "Doesn't get the bottom of text", Math.round(testTCM.verticalScrollPosition) == 309);
		}

		public function aliceTCMTest():void
		{
			var alice:ByteArrayAsset = new AliceClass();
			var aliceData:String = alice.readMultiByte(alice.length,"utf-8");
			var aliceFlow:TextFlow = TextConverter.importToFlow( aliceData, TextConverter.TEXT_LAYOUT_FORMAT );
			var testTCM:TextContainerManager = addTCM();
			testTCM.setTextFlow(aliceFlow);
			testTCM.updateContainer();

			testTCM.compositionHeight = 200;
			testTCM.updateContainer();

			testTCM.compositionHeight = 50;
			testTCM.updateContainer();
		}
		var selectionChanged:Boolean = false;
		public function tcmSelectionTest():void
		{
			var sprite:Sprite = new Sprite();
			sprite.x = 0;
			sprite.y = 0;
			TestCanvas.rawChildren.addChild(sprite);
			var testTCM:TextContainerManager = new TextContainerManager(sprite);
			testTCM.preserveSelectionOnSetText = true;
			testTCM.setText("Hello World");
			testTCM.updateContainer();
			var selManager:SelectionManager = testTCM.beginInteraction() as SelectionManager;
			selManager.selectRange(5,5);
			testTCM.endInteraction();
			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.setText( "Good Night" );
			assertTrue("Selection was not maintained after new text was set case 1", testTCM.getTextFlow().interactionManager.activePosition == 5 && testTCM.getTextFlow().interactionManager.anchorPosition == 5);
			testTCM.updateContainer();

			var sprite2:Sprite = new Sprite();
			sprite2.x = 100;
			sprite2.y = 100;
			TestCanvas.rawChildren.addChild(sprite2);
			var testTCM2:TextContainerManager = new TextContainerManager(sprite2);
			testTCM2.setText("Hello World");
			testTCM2.updateContainer();
			var selManager2:SelectionManager = testTCM2.beginInteraction() as SelectionManager;
			selManager2.selectRange(0,5);
			testTCM2.endInteraction();
			testTCM2.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM2.preserveSelectionOnSetText = true;
			testTCM2.setText( "Good Night" );
			assertTrue("Selection was not maintained after new text was set case 2", testTCM2.getTextFlow().interactionManager.activePosition == 5 && testTCM2.getTextFlow().interactionManager.anchorPosition == 0);
			testTCM2.updateContainer();
			
			var sprite3:Sprite = new Sprite();
			sprite3.x = 200;
			sprite3.y = 200;
			TestCanvas.rawChildren.addChild(sprite3);
			var testTCM3:TextContainerManager = new TextContainerManager(sprite3);
			testTCM3.setText("Hello World");
			testTCM3.updateContainer();
			var selManager3:SelectionManager = testTCM3.beginInteraction() as SelectionManager;
			selManager3.selectRange(0,11);
			testTCM3.endInteraction();
			testTCM3.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM3.addEventListener(SelectionEvent.SELECTION_CHANGE, selectionChangeHandler);
			testTCM3.preserveSelectionOnSetText = true;
			testTCM3.setText( "Good" );
			assertTrue("SELECTION_CHANGE was not triggered", selectionChanged);
			assertTrue("Selection was not maintained after new text was set case 3", testTCM3.getTextFlow().interactionManager.activePosition == 4 && testTCM3.getTextFlow().interactionManager.anchorPosition == 0);
			testTCM3.updateContainer();
			
			var selManager4:SelectionManager = testTCM3.beginInteraction() as SelectionManager;
			selManager4.selectRange(-1,-1);
			testTCM3.endInteraction();
			testTCM3.setText( "Good Morning" );
			assertTrue("Selection was not maintained after new text was set case 4", testTCM3.getTextFlow().interactionManager == null && selManager4.anchorPosition == -1 && selManager4.activePosition == -1);
			testTCM3.updateContainer();
		}
		
		private function selectionChangeHandler(event:SelectionEvent):void
		{
			selectionChanged = true;
		}
		
		public function customEventTCMTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.customBehaviorEnabled = true;
			testTCM.setText("Testing the CustomTCM with Selection on focusIn");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.updateContainer();

			var selManager:SelectionManager = testTCM.beginInteraction() as SelectionManager;
			assertTrue( "focusInHandler not called on FocusEvent.FOCUS_IN event",
				selManager.anchorPosition == 0 && selManager.activePosition == 5);
			testTCM.endInteraction();
		}

		public function activationTCMTest():void
		{
			// Verify that createContextMenu get*SelectionFormat, getUndoManager are called on activation
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.updateContainer();

			assertTrue( "createContextMenu not called on activate", testTCM.createContextMenuCallCount > 0 );
			assertTrue( "getFocusedSelectionFormat not called on activate", testTCM.getFocusedSelectionFormatCallCount > 0 );
			assertTrue( "getInactiveSelectionFormat not called on activate", testTCM.getInactiveSelectionFormatCallCount > 0 );
			assertTrue( "getUnfocusedSelectionFormat not called on activate", testTCM.getUnfocusedSelectionFormatCallCount > 0 );
			assertTrue( "getUndoManager not called on activate", testTCM.getUndoManagerCallCount > 0 );
		}

		public function focusInHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.updateContainer();

			assertTrue( "focusInHandler not called on FocusEvent.FOCUS_IN event", testTCM.focusInHandlerCallCount > 0 );
		}

		public function mouseOverHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_OVER ) );
			testTCM.updateContainer();

			assertTrue( "mouseOverHandler not called on MouseEvent.MOUSE_OVER", testTCM.mouseOverHandlerCallCount > 0 );
		}

		public function activateHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new Event( Event.DEACTIVATE ) );
			testTCM.container.dispatchEvent(new Event( Event.ACTIVATE ) );
			testTCM.updateContainer();

			assertTrue( "activateHandlerTest not called on Event.ACTIVATE", testTCM.activateHandlerCallCount > 0 );
		}

		public function deactivateHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new Event( Event.DEACTIVATE ) );
			testTCM.updateContainer();

			assertTrue( "deactivateHandlerTest not called on Event.DEACTIVATE", testTCM.deactivateHandlerCallCount > 0 );
		}

		public function editHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			//testTCM.container.dispatchEvent(new Event( Event. ) );
			testTCM.updateContainer();

			assertTrue( "deactivateHandlerTest not called on activate event", testTCM.deactivateHandlerCallCount > 0 );
		}

		public function focusChangeHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.KEY_FOCUS_CHANGE ) );
			testTCM.updateContainer();

			assertTrue( "focusChangeHandler not called on FocusEvent.KEY_FOCUS_CHANGE", testTCM.focusChangeHandlerCallCount > 0 );
		}

		public function focusOutHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new FocusEvent( Event.DEACTIVATE ) );
			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_OUT ) );
			testTCM.updateContainer();

			assertTrue( "focusOutHandler not called on FocusEvent.FOCUS_OUT", testTCM.focusOutHandlerCallCount > 0 );
		}

		public function keyDownHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new KeyboardEvent( KeyboardEvent.KEY_DOWN ) );
			testTCM.updateContainer();

			assertTrue( "keyDownHandler not called on KeyboardEvent.KEY_DOWN", testTCM.keyDownHandlerCallCount > 0 );
		}

		public function keyUpHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new KeyboardEvent( KeyboardEvent.KEY_DOWN ) );
			testTCM.container.dispatchEvent(new KeyboardEvent( KeyboardEvent.KEY_UP ) );
			testTCM.updateContainer();

			assertTrue( "keyUpHandler not called on KeyboardEvent.KEY_UP", testTCM.keyUpHandlerCallCount > 0 );
		}

		public function menuSelectHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new ContextMenuEvent(ContextMenuEvent.MENU_SELECT ) );
			testTCM.updateContainer();

			assertTrue( "menuSelectHandler not called on ContextMenuEvent.MENU_SELECT", testTCM.menuSelectHandlerCallCount > 0 );
		}

		public function mouseDoubleClickHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.DOUBLE_CLICK ) );
			testTCM.updateContainer();

			assertTrue( "mouseDoubleClickHandler not called on MouseEvent.DOUBLE_CLICK", testTCM.mouseDoubleClickHandlerCallCount > 0 );
		}

		public function mouseDownHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.updateContainer();

			assertTrue( "mouseDownHandler not called on MouseEvent.MOUSE_DOWN", testTCM.mouseDownHandlerCallCount > 0 );
		}

		public function mouseMoveHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.ROLL_OVER ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_MOVE ) );
			testTCM.updateContainer();

			assertTrue( "mouseMoveHandler not called on MouseEvent.MOUSE_MOVE", testTCM.mouseMoveHandlerCallCount > 0 );
		}

		public function mouseOutHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_OUT ) );
			testTCM.updateContainer();

			assertTrue( "mouseOutHandler not called on MouseEvent.MOUSE_OUT", testTCM.mouseOutHandlerCallCount > 0 );
		}

		public function mouseUpHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_UP ) );
			testTCM.updateContainer();

			assertTrue( "mouseUpHandler not called on MouseEvent.MOUSE_UP", testTCM.mouseUpHandlerCallCount > 0 );
		}

		public function mouseWheelHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_WHEEL, true, false, 27, 48 ) );
			testTCM.updateContainer();

			assertTrue( "mouseWheelHandler not called on MouseEvent.MOUSE_WHEEL", testTCM.mouseWheelHandlerCallCount > 0 );
		}

		public function textInputHandlerTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			testTCM.setText("Testing the CustomTCM Event Handler Tests");
			testTCM.updateContainer();

			testTCM.container.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			testTCM.container.dispatchEvent(new MouseEvent( MouseEvent.MOUSE_DOWN ) );
			testTCM.container.dispatchEvent(new TextEvent( TextEvent.TEXT_INPUT ) );
			testTCM.updateContainer();

			assertTrue( "textInputHandler not called on TextEvent.TEXT_INPUT", testTCM.textInputHandlerCallCount > 0 );
		}
		private static const basicBackgroundColorTestMarkup:String = '<?xml version="1.0" encoding="utf-8"?><TextFlow fontSize="14" paddingBottom="inherit" lineBreak="inherit" paddingTop="4" textIndent="15" verticalAlign="inherit" paddingRight="inherit" paddingLeft="4" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p marginBottom="15"><span backgroundColor="0xffff00">ASDF                                 </span></p></TextFlow>';

		public function basicBackgroundColorTest():void
		{
			var textFlow:TextFlow = TextConverter.importToFlow(basicBackgroundColorTestMarkup, TextConverter.TEXT_LAYOUT_FORMAT);
			performBackgroundColorTest(textFlow,"basicBackgroundColorTest");
		}

		public function multiParagraphBackgroundColorTest():void
		{
			var fileData:Object = FileRepository.getFileAsXML(baseURL,"backgroundColorTest.xml");
			var textFlow:TextFlow = TextConverter.importToFlow(fileData, TextConverter.TEXT_LAYOUT_FORMAT);
			performBackgroundColorTest(textFlow,"multiParagraphBackgroundColorTest",400,200);
		}

		private static function listContainerContents(cont:DisplayObjectContainer):void
		{
			// trace("CONTAINER",getQualifiedClassName(cont));
			var idx:int = 0;
			while (idx < cont.numChildren)
			{
				var obj:DisplayObject = cont.getChildAt(idx);
				// trace(idx,getQualifiedClassName(obj),obj.x,obj.y,obj.toString());
				idx++;
			}
		}

		private function performBackgroundColorTest(textFlow:TextFlow,testName:String,width:Number = 100,height:Number = 100):void
		{
			var testTCM:CustomTCM = addCustomTCM();

			// turning off scrolling makes the bitmaps match
			testTCM.horizontalScrollPolicy = ScrollPolicy.OFF;
			testTCM.verticalScrollPolicy = ScrollPolicy.OFF;

			var container:DisplayObjectContainer = testTCM.container;

			testTCM.compositionWidth = width;
			testTCM.compositionHeight =  height;
			testTCM.setTextFlow(textFlow);
			testTCM.updateContainer();

			//listContainerContents(container);
			assertTrue( testName+ " not from using the factory as expected", testTCM.composeState == TextContainerManager.COMPOSE_FACTORY );

			var bits:BitmapData = new BitmapData(container.width,container.height);
			bits.draw(container);


			var factoryData:Bitmap = new Bitmap(bits);

			// convert to a textFlow and redisplay
			testTCM.beginInteraction();
			testTCM.endInteraction();
			//testTCM.updateContainer();
			//listContainerContents(container);
			assertTrue( testName + " not converted from using the factory as expected", testTCM.composeState == TextContainerManager.COMPOSE_COMPOSER );

			// draw again - its not a factory
			bits = new BitmapData(container.width,container.height);
			bits.draw(container);
			var composerData:Bitmap = new Bitmap(bits);


			// compare the bitmaps
			var bounds:Rectangle = new Rectangle(0, 0, container.width, container.height);
			var composerPixels:ByteArray = composerData.bitmapData.getPixels(bounds);
			var factoryPixels:ByteArray = factoryData.bitmapData.getPixels(bounds);
			composerPixels.position = factoryPixels.position = 0;
			assertTrue( testName + " factory and composer have different bytesAvaialable",factoryPixels.bytesAvailable == composerPixels.bytesAvailable);

			var diffCount:int = 0;
			while (factoryPixels.bytesAvailable > 0)
			{
				var factoryByte:int = factoryPixels.readByte();
				var composerByte:int = composerPixels.readByte();
				if (factoryByte != composerByte)
					diffCount++;
			}

			assertTrue( testName + " factory and composer have different rendering",diffCount == 0);
		}

		// this is more of an Argo test when TCM is trying to do in place TextLine recycling
		public function recomposeBackgroundColorRecomposeTest():void
		{
			var fileData:Object = FileRepository.getFileAsXML(baseURL,"backgroundColorTest.xml");
			var textFlow:TextFlow = TextConverter.importToFlow(fileData, TextConverter.TEXT_LAYOUT_FORMAT);

			var testTCM:CustomTCM = addCustomTCM();

  			testTCM.compositionWidth = 400;
  			testTCM.compositionHeight = 400;
  			testTCM.setTextFlow(textFlow);
  			testTCM.updateContainer();

  			testTCM.setText("ABCD");
  			testTCM.updateContainer();

   			testTCM.setTextFlow(textFlow);
  			testTCM.updateContainer();
		}

		private static const hitTestMarkup:String = '<?xml version="1.0" encoding="utf-8"?><TextFlow fontSize="14" fontFamily="Arial" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="15"><span>ABCD</span></p></TextFlow>';

		public function hitTest():void
		{
			var testTCM:CustomTCM = addCustomTCM();
			var textFlow:TextFlow = TextConverter.importToFlow(hitTestMarkup, TextConverter.TEXT_LAYOUT_FORMAT);
			testTCM.setTextFlow(textFlow);
			testTCM.updateContainer();
			assertTrue( "hitTest not from using the factory as expected", testTCM.composeState == TextContainerManager.COMPOSE_FACTORY );

			var localClickPoint:Point = new Point(10, testTCM.compositionHeight/2);
			var mouseOver:MouseEvent = new MouseEvent(MouseEvent.MOUSE_OVER, true, false, localClickPoint.x, localClickPoint.y, testTCM.container);
			testTCM.container.dispatchEvent(mouseOver);
			var mouseDown:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, localClickPoint.x, localClickPoint.y, testTCM.container);
			testTCM.container.dispatchEvent(mouseDown);
		}


		public function damageEventTest():void
		{
 			const testText:String = "Hello There! Dig that DamageEvent, eh?";

 			var testTCM:CustomTCM = addCustomTCM();

   			var validator:DamageEventValidator = new DamageEventValidator(testTCM,
   				new DamageEvent(DamageEvent.DAMAGE, false, false, null, 0, testText.length));

			testTCM.setText(testText);
			testTCM.updateContainer();
   			assertTrue("Expected damage event showing after setting text",validator.validate(1));
		}

		public function editingModeTest():void
		{
 			var testTCM:CustomTCM = addCustomTCM();
 			var im:ISelectionManager;

 			// test that csetting the editingMode to its current value doesn't change it
 			for each (var editingMode:String in [ EditingMode.READ_ONLY, EditingMode.READ_SELECT, EditingMode.READ_WRITE ])
 			{
	 			testTCM.editingMode = editingMode;
				im = testTCM.beginInteraction();
				testTCM.endInteraction();
	 			testTCM.editingMode = editingMode;
				assertTrue("Interaction manager changed on reset to " + editingMode,im == testTCM.beginInteraction());
				testTCM.endInteraction();
 			}

			// test that changing the editingMode preserves the selection
			testTCM.setText("ABCD");
			testTCM.updateContainer();
			testTCM.editingMode = EditingMode.READ_WRITE;
			im = testTCM.beginInteraction();
			im.selectRange(0,1);
			testTCM.endInteraction();

			testTCM.editingMode = EditingMode.READ_SELECT;
			im = testTCM.beginInteraction();
			assertTrue("Interaction manager lost selection on editingMode change to "+ testTCM.editingMode,im.anchorPosition == 0 && im.activePosition == 1);
			testTCM.endInteraction();

			testTCM.editingMode = EditingMode.READ_WRITE;
			im = testTCM.beginInteraction();
			assertTrue("Interaction manager lost selection on editingMode change to "+ testTCM.editingMode,im.anchorPosition == 0 && im.activePosition == 1);
			testTCM.endInteraction();
		}

		private var tempTCM:TextContainerManager;
		public function setTextDamageTest():void
		{
			tempTCM = addTCM();
			tempTCM.addEventListener(DamageEvent.DAMAGE, addAsync(damageHandler, 1000, null));
			tempTCM.setText("test");
		}

		public function damageHandler( evt:Event ):void
		{
			tempTCM.removeEventListener(DamageEvent.DAMAGE, damageHandler);
		}

		public function changeTextLineCreatorTest():void
		{
			var testTCM:TextContainerManager;
			var tlc:TestSWFContext;

			// string factory case
			testTCM = addTCM(true,10,10);
			testTCM.setText("abc");
			testTCM.updateContainer();

			tlc = new TestSWFContext();
			testTCM.swfContext = tlc;
			assertTrue("changeTextLineCreatorTest StringFactory case: Expected damaged", testTCM.isDamaged());

			testTCM.updateContainer();
			assertTrue("changeTextLineCreatorTest StringFactory case: Expected compose", tlc.callCount != 0);

			// textFlow factory case
			testTCM = addTCM(true,10,110);
			testTCM.setTextFlow(TextConverter.importToFlow("abc", TextConverter.PLAIN_TEXT_FORMAT ));
			testTCM.updateContainer();

			tlc = new TestSWFContext();
			testTCM.swfContext = tlc;
			assertTrue("changeTextLineCreatorTest TextFlowFactory case: Expected damaged", testTCM.isDamaged());

			testTCM.updateContainer();
			assertTrue("changeTextLineCreatorTest TextFlowFactory case: Expected compose", tlc.callCount != 0);

			// textFlow flowComposer case
			testTCM = addTCM(true,10,210);
			testTCM.setTextFlow(TextConverter.importToFlow("abc", TextConverter.PLAIN_TEXT_FORMAT ));
			testTCM.beginInteraction();	// forces flowcomposer case
			testTCM.endInteraction();
			testTCM.updateContainer();

			tlc = new TestSWFContext();
			testTCM.swfContext = tlc;
			assertTrue("changeTextLineCreatorTest FlowComposer case: Expected damaged", testTCM.isDamaged());

			testTCM.updateContainer();
			assertTrue("changeTextLineCreatorTest FlowComposer case: Expected compose", tlc.callCount != 0);
		}
		
		public function floatAndBackgroundColorTest():TextContainerManager
		{
			var testTCM:TextContainerManager;
			
			// string factory case
			testTCM = addTCM();
			
			testTCM.compositionWidth = 400;
			testTCM.compositionHeight = 300;
			
			var hello:SpanElement = new SpanElement();
			hello.text = "hello";
			hello.backgroundColor = 0xccccff;
			
			var s:Shape = new Shape();
			s.graphics.beginFill(0xff);
			s.graphics.drawRect(0,0,100,100);
			s.graphics.endFill();
			
			var ilg:InlineGraphicElement = new InlineGraphicElement();
			ilg.width = "100";
			ilg.height = "100";
			ilg.source = s;
			ilg.float = Float.LEFT;
			
			var para:ParagraphElement = new ParagraphElement();
			para.addChild(hello);
			para.addChild(ilg);
			
			var textFlow:TextFlow = new TextFlow();
			textFlow.addChild(para);
			
			testTCM.setTextFlow(textFlow);
			testTCM.updateContainer();
			
			return testTCM;
		}
		
		public function floatAndBackgroundColorTestThenReset():void
		{
			var testTCM:TextContainerManager = floatAndBackgroundColorTest();
			// and now reuse existing TextLines
			testTCM.setText("Hello");
			testTCM.updateContainer();
		}
		
		public function ZOrderHighlightingTest():void
		{
			var newSprite:Sprite = new Sprite();
			newSprite.x = 10;
			newSprite.y = 10;
			var testTCM:TextContainerManager = new CustomHilitedTCM(newSprite);
			TestCanvas.rawChildren.addChild(newSprite);

			testTCM.container.z = 1;

			testTCM.hostFormat = TextLayoutFormat.createTextLayoutFormat({fontSize:18, paddingLeft:10, paddingRight:10});
			testTCM.setText("Hello World");
			testTCM.updateContainer();
			
			var sm:ISelectionManager = testTCM.beginInteraction();
			sm.selectAll();
			sm.refreshSelection();
			sm.setFocus();
			testTCM.endInteraction();
			
		}
		
		public function reuseTextFlow():void
		{
			// Test reusing a TextFlow that's already in another TCM
			var tcm1:TextContainerManager = addTCM(false);
			var textFlow1:TextFlow = TextConverter.importToFlow('<?xml version="1.0" encoding="utf-8"?><TextFlow fontSize="14" fontFamily="Arial" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008">Hello <a>world</a></TextFlow>', TextConverter.TEXT_LAYOUT_FORMAT ) as TextFlow;
			var textFlow2:TextFlow = TextConverter.importToFlow('<?xml version="1.0" encoding="utf-8"?><TextFlow fontSize="14" fontFamily="Arial" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008">Hello <a>world</a></TextFlow>', TextConverter.TEXT_LAYOUT_FORMAT ) as TextFlow;
			tcm1.setTextFlow(textFlow1);
			tcm1.updateContainer();
			var tcm2:TextContainerManager = addTCM(false, 40, 10);
			tcm1.setTextFlow(textFlow2);
			tcm2.setTextFlow(textFlow2);
			tcm1.updateContainer();
			tcm2.updateContainer();
			tcm2.setTextFlow(textFlow1);
			tcm1.compositionWidth = 500;
			tcm1.updateContainer();
			tcm2.updateContainer();
		}
		
		public function emptyTCM():void
		{
			var tcm:TextContainerManager = addTCM(false);
			tcm.compositionWidth = 0;
			tcm.compositionHeight = 0;
			tcm.compose();
		}
		public function getLineAtTest():void
		{
			var textMarkup:String ="Alice was beginning to get very tired of sitting by her sister " +
				"on the bank, and of having nothing to do: once or twice she had peeped into the book " +
				"her sister was reading, but it had no pictures or conversations in it, " +
				"“and what is the use of a book,” thought Alice “without pictures or conversation?”";
			
			
			var testTCM:TextContainerManager = addTCM();
			
			var txtFlow:TextFlow = TextConverter.importToFlow( textMarkup, TextConverter.PLAIN_TEXT_FORMAT );
			
			testTCM.setTextFlow( txtFlow );
			testTCM.updateContainer();
			
			var num:int = testTCM.numLines;
			//using factory to get textlines;
			// this doesn't work in 10.0
			if (Capabilities.version.substr(4,4) != "10,0")
			{
				var factoryLine1:TextLine =  testTCM.getLineAt(0);
				var factoryLine2:TextLine =  testTCM.getLineAt(1);
				
				assertTrue("did not get a TextLine object from getLineAt(0) using factory",factoryLine1);
				assertTrue("did not get a TextLine object from getLineAt(1) using factory",factoryLine2);
				assertTrue("getLineAt(0) and getLineAt(1) returned the same TextLines",factoryLine1 !=factoryLine2);
			}
			
			//using TextFlow to get textlines			
			testTCM.beginInteraction();
			var textflowLine1:TextLine =  testTCM.getLineAt(0);
			var textflowLine2:TextLine =  testTCM.getLineAt(1);
			testTCM.endInteraction();
			
			assertTrue("did not get a TextLine object from getLineAt(0) using TextFlow",textflowLine1);
			assertTrue("did not get a TextLine object from getLineAt(1) using TextFlow",textflowLine2);
			assertTrue("getLineAt(0)'s nextLine is not getLineAt(1).",textflowLine1.nextLine == textflowLine2);
			assertTrue("getLineAt(1)'s previousLine is not getLineAt(0).",textflowLine2.previousLine == textflowLine1);
		}
		
		public function zeroWidthTest():void
		{
			var testTCM:TextContainerManager = addTCM();
			testTCM.setText("Hello World");
			var hostFormat:TextLayoutFormat = new TextLayoutFormat();
			hostFormat.fontSize = 12;
			hostFormat.paddingTop = 4;
			hostFormat.paddingLeft = 4;
			hostFormat.columnCount = 1;
			hostFormat.columnGap = 0;
			testTCM.hostFormat = hostFormat;
			testTCM.compositionWidth = 0;
			testTCM.compositionHeight = 0;
			testTCM.updateContainer();
			
			testTCM.beginInteraction();
			testTCM.endInteraction();
			testTCM.updateContainer();
		}
		
		public function linkAdditionTest():void
		{
			var testTCM:TextContainerManager = addTCM();
			testTCM.setTextFlow(new TextFlow());
			testTCM.updateContainer();
			
			assertTrue("linkAdditionTest: bad composeState for empty TextFlow",testTCM.composeState == TextContainerManager.COMPOSE_FACTORY);
			
			// make a paragraph with a link
			var linkSpan:SpanElement = new SpanElement();
			linkSpan.text = "link";
			var link:LinkElement = new LinkElement();
			link.addChild(linkSpan);
			link.href = "http://www.adobe.com";
			var p:ParagraphElement = new ParagraphElement();
			p.addChild(link);
			
			//add it
			testTCM.getTextFlow().addChild(p);
			testTCM.updateContainer();
			
			assertTrue("linkAdditionTest: bad composeState for TextFlow w Link",testTCM.composeState == TextContainerManager.COMPOSE_COMPOSER);
		}
		
		public function graphicAdditionTest():void
		{
			var testTCM:TextContainerManager = addTCM();
			testTCM.setTextFlow(new TextFlow());
			testTCM.updateContainer();
			
			assertTrue("graphicAdditionTest: bad composeState for empty TextFlow",testTCM.composeState == TextContainerManager.COMPOSE_FACTORY);
			
			// make a paragraph with a ILG
			var span:SpanElement = new SpanElement();
			span.text = "graphic ";
			var ilg:InlineGraphicElement = new InlineGraphicElement();
			ilg.source = "http://www.adobe.com/images/shared/download_buttons/get_adobe_flash_player.png";
			var p:ParagraphElement = new ParagraphElement();
			p.replaceChildren(0,0,span,ilg);
			
			//add it - you won't get to see it
			testTCM.getTextFlow().addChild(p);
			testTCM.updateContainer();
			
			assertTrue("graphicAdditionTest: bad composeState for TextFlow w image",testTCM.composeState == TextContainerManager.COMPOSE_COMPOSER);
		}
	}
}

import flash.display.Sprite;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.text.engine.TextBlock;
import flash.text.engine.TextLine;
import flash.ui.ContextMenu;

import flashx.textLayout.compose.ISWFContext;
import flashx.textLayout.compose.TextLineRecycler;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.edit.SelectionManager;
import flashx.textLayout.compose.ISWFContext;
import flashx.textLayout.compose.TextLineRecycler;
import flashx.textLayout.elements.IConfiguration;
import flashx.textLayout.formats.TextLayoutFormat;

import flashx.undo.IUndoManager;

class CustomTCM extends TextContainerManager
{
	public function CustomTCM(container:Sprite,configuration:IConfiguration =  null)
	{
		super(container, configuration);
	}

	public var customBehaviorEnabled:Boolean = false;

	public var focusInHandlerCallCount:int = 0;
	override public function focusInHandler(event:FocusEvent):void
	{
		focusInHandlerCallCount++;
		super.focusInHandler(event);

		if ( customBehaviorEnabled == true )
		{
			var selManager:SelectionManager = this.beginInteraction() as SelectionManager;
			selManager.selectRange(0,5);
			this.endInteraction();
		}
	}

	public var createContextMenuCallCount:int = 0;
	override protected function createContextMenu():ContextMenu
	{
		createContextMenuCallCount++;
		return super.createContextMenu();
	}

	public var getUndoManagerCallCount:int = 0;
	override protected function getUndoManager():IUndoManager
	{
		getUndoManagerCallCount++;
		return super.getUndoManager();
	}

	public var getFocusedSelectionFormatCallCount:int = 0;
	override protected function getFocusedSelectionFormat():SelectionFormat
	{
		getFocusedSelectionFormatCallCount++;
		return super.getFocusedSelectionFormat();
	}

	public var getInactiveSelectionFormatCallCount:int = 0;
	override protected function getInactiveSelectionFormat():SelectionFormat
	{
		getInactiveSelectionFormatCallCount++;
		return super.getInactiveSelectionFormat();
	}

	public var getUnfocusedSelectionFormatCallCount:int = 0;
	override protected function getUnfocusedSelectionFormat():SelectionFormat
	{
		getUnfocusedSelectionFormatCallCount++;
		return super.getUnfocusedSelectionFormat();
	}

	public var activateHandlerCallCount:int = 0;
	override public function activateHandler(event:Event):void
	{
		activateHandlerCallCount++;
		super.activateHandler(event);
	}

	public var deactivateHandlerCallCount:int = 0;
	override public function deactivateHandler(event:Event):void
	{
		deactivateHandlerCallCount++;
		super.deactivateHandler(event);
	}

	public var editHandlerCallCount:int = 0;
	override public function editHandler(event:Event):void
	{
		editHandlerCallCount++;
		super.editHandler(event);
	}

	public var focusChangeHandlerCallCount:int = 0;
	override public function focusChangeHandler(event:FocusEvent):void
	{
		focusChangeHandlerCallCount++;
		super.focusChangeHandler(event);
	}

	public var focusOutHandlerCallCount:int = 0;
	override public function focusOutHandler(event:FocusEvent):void
	{
		focusOutHandlerCallCount++;
		super.focusOutHandler(event);
	}

	public var keyDownHandlerCallCount:int = 0;
	override public function keyDownHandler(event:KeyboardEvent):void
	{
		keyDownHandlerCallCount++;
		super.keyDownHandler(event);
	}

	public var keyUpHandlerCallCount:int = 0;
	override public function keyUpHandler(event:KeyboardEvent):void
	{
		keyUpHandlerCallCount++;
		super.keyUpHandler(event);
	}

	public var menuSelectHandlerCallCount:int = 0;
	override public function menuSelectHandler(event:ContextMenuEvent):void
	{
		menuSelectHandlerCallCount++;
		super.menuSelectHandler(event);
	}

	public var mouseDoubleClickHandlerCallCount:int = 0;
	override public function mouseDoubleClickHandler(event:MouseEvent):void
	{
		mouseDoubleClickHandlerCallCount++;
		super.mouseDoubleClickHandler(event);
	}

	public var mouseDownHandlerCallCount:int = 0;
	override public function mouseDownHandler(event:MouseEvent):void
	{
		mouseDownHandlerCallCount++;
		super.mouseDownHandler(event);
	}

	public var mouseMoveHandlerCallCount:int = 0;
	override public function mouseMoveHandler(event:MouseEvent):void
	{
		mouseMoveHandlerCallCount++;
		super.mouseMoveHandler(event);
	}

	public var mouseOutHandlerCallCount:int = 0;
	override public function mouseOutHandler(event:MouseEvent):void
	{
		mouseOutHandlerCallCount++;
		super.mouseOutHandler(event);
	}

	public var mouseOverHandlerCallCount:int = 0;
	override public function mouseOverHandler(event:MouseEvent):void
	{
		mouseOverHandlerCallCount++;
		super.mouseOverHandler(event);
	}

	public var mouseUpHandlerCallCount:int = 0;
	override public function mouseUpHandler(event:MouseEvent):void
	{
		mouseUpHandlerCallCount++;
		super.mouseUpHandler(event);
	}

	public var mouseWheelHandlerCallCount:int = 0;
	override public function mouseWheelHandler(event:MouseEvent):void
	{
		mouseWheelHandlerCallCount++;
		super.mouseWheelHandler(event);
	}

	public var textInputHandlerCallCount:int = 0;
	override public function textInputHandler(event:TextEvent):void
	{
		textInputHandlerCallCount++;
		super.textInputHandler(event);
	}
}

class TestSWFContext implements ISWFContext
{
	public var callCount:int = 0;
	public function callInContext(fn:Function, thisArg:Object, argsArray:Array, returns:Boolean=true):*
	{
		callCount++;
		if (returns)
	    	return fn.apply(thisArg, argsArray);
		fn.apply(thisArg, argsArray);
	}
}

class HostFormatTabsTCMTest extends TextLayoutFormat
{
	public function HostFormatTabsTCMTest()
	{
		super();
		this.tabStops = "100 200 300";
	}
}

import flash.display.BlendMode;

class CustomHilitedTCM extends TextContainerManager
{
	public function CustomHilitedTCM(container:Sprite,configuration:IConfiguration =  null)
	{
		super(container, configuration);
	}
	
	static private var	_focusedSelectionFormat:SelectionFormat    = new SelectionFormat(0xa8c6ee, 1.0, BlendMode.NORMAL, 0x0,1.0,BlendMode.NORMAL,500);
	
	override protected function getFocusedSelectionFormat():SelectionFormat
	{ return _focusedSelectionFormat; }
	override protected function getUnfocusedSelectionFormat():SelectionFormat
	{ return _focusedSelectionFormat; }
	override protected function getInactiveSelectionFormat():SelectionFormat
	{ return _focusedSelectionFormat; }
}