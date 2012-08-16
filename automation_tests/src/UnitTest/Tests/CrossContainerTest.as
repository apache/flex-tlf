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
	
	import flash.display.Sprite;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	import mx.containers.Canvas;

    use namespace tlf_internal;
	
	public class CrossContainerTest extends VellumTestCase
	{
        // Members
        private var _flowComposer:IFlowComposer;
		private var _textFlow:TextFlow;
		private var _testXML:XML;
		private var _verticalText:Boolean;
		private var _rtlText:Boolean;
		private var _testCanvas:Canvas;
		private var _textFlowSprite:Sprite;
		private var _container1:Sprite;
		private var _container2:Sprite;
		private var _container3:Sprite;
		
		public function CrossContainerTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super (methodName, testID, testConfig);
			_testXML = testXML;
			TestData.fileName = null;
			
			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Composition";
		}
		
		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
            addTestCase(ts, testConfig, "crossContainerTest");
		}
		
		private static function addTestCase(ts:TestSuiteExtended, testConfig:TestConfig, methodName:String):void
		{
			var testXML:XML = <TestCase>
								<TestData name="methodName">{methodName}</TestData>
								<TestData name="id">{methodName}</TestData>
							</TestCase>;

			ts.addTestDescriptor (new TestDescriptor (CrossContainerTest,"callTestMethod", testConfig, testXML) );
		}
		
		override public function setUp() : void
		{
			super.setUp();
			setupTextFlow();
			initializeFlow();
		}
		
		private function setupTextFlow():void
		{
			var textFlow:TextFlow = new TextFlow();
			var para1String:String = "In the first paragraph of a "
			var para1String2:String = "cheap"
			var para1String3:String ="Western novel, a cowboy meets a saloon girl.";
			var para2String:String = "In the middle of the cheap novel a really bad guy, "+
				"who is having a relationship with the saloon girl, sees the cowboy help "+
				"her onto her horse as she smiles at him warmly."
			var para3String:String = "In the last paragraph of the cheap novel, the cowboy kills "+
				"the really bad guy in a shootout in the middle of main street and "+
				"then rides into the sunset with the saloon girl on the back of his";
			
			var controllerOne:ContainerController;
			var controllerTwo:ContainerController;
			
			_container1 = new Sprite();
			_container2 = new Sprite();
			
			controllerOne = new ContainerController(_container1, 200, 210);
			controllerTwo = new ContainerController(_container2, 200, 220);
			
			var textLayoutFormat:TextLayoutFormat = new TextLayoutFormat();
			var paragraph1:ParagraphElement = new ParagraphElement();
			
			var paragraph2:ParagraphElement = new ParagraphElement();
			var paragraph3:ParagraphElement = new ParagraphElement();
			
			var p1Span1:SpanElement = new SpanElement();
			var p1Span2:SpanElement = new SpanElement();
			var p1Span3:SpanElement = new SpanElement();
			var p2Span:SpanElement = new SpanElement();
			var p3Span:SpanElement = new SpanElement();
			
			p1Span1.text = para1String;
			p1Span2.text = para1String2;
			p1Span3.text = para1String3;
			
			paragraph1.addChild(p1Span1);
			paragraph1.addChild(p1Span2);
			paragraph1.addChild(p1Span3);
			
			p2Span.text = para2String;
			paragraph2.addChild(p2Span);
			
			p3Span.text = para3String;
			
			var img:InlineGraphicElement = new InlineGraphicElement();
			img.source = "../../test/testFiles/assets/smiley.gif"
			img.width = 100;
			img.height = 100;
			
			paragraph3.addChild(p3Span);
			paragraph3.addChild(img);
			
			textFlow.addChild(paragraph1);
			textFlow.addChild(paragraph2);
			textFlow.addChild(paragraph3);
			
			textLayoutFormat.fontSize = 14;
			textLayoutFormat.textIndent = 15;
			textLayoutFormat.paragraphSpaceAfter = 15;
			textLayoutFormat.paddingTop = 4;
			textLayoutFormat.paddingLeft = 4;
			
			textFlow.hostFormat = textLayoutFormat;
			textFlow.interactionManager = new EditManager();
			_container1.x = 0;
			_container1.y = 100;
			_container2.x = 255;
			_container2.y = 100; 
			textFlow.flowComposer.addController(controllerOne);
			textFlow.flowComposer.addController(controllerTwo);
			textFlow.flowComposer.updateAllControllers();
			
			_container3 = new Sprite();
			var controllerThree:ContainerController = new ContainerController(_container3, 200, 220);
			_container3.x = 510;
			_container3.y = 100; 
			var textLayoutFormat1:TextLayoutFormat = new TextLayoutFormat();
			
			textLayoutFormat1.fontSize = 18;
			textLayoutFormat1.textIndent = 15;
			textLayoutFormat1.paragraphSpaceAfter = 15;
			textLayoutFormat1.paddingTop = 4;
			textLayoutFormat1.paddingLeft = 4;
			textFlow.hostFormat = textLayoutFormat1;
			textFlow.flowComposer.addController(controllerThree);
			
			_textFlowSprite = new Sprite();
			_textFlowSprite.addChild(_container1);
			_textFlowSprite.addChild(_container2);
			_textFlowSprite.addChild(_container3);
		
			_textFlow = textFlow;
		}
		
		override public function tearDown(): void
		{
			super.tearDown();
		}
		
		private function initializeFlow():void
		{
			_flowComposer = _textFlow.flowComposer;
			_testCanvas = myEmptyChilds();
			_testCanvas.rawChildren.addChild(_textFlowSprite);
			
            // Set the writing direction specified by the test
			_textFlow.blockProgression = writingDirection[0];
			_textFlow.direction        = writingDirection[1];
			
            _verticalText = (_textFlow.blockProgression == BlockProgression.RL);
            _rtlText = (_textFlow.direction == Direction.RTL);
            
			SelManager = EditManager(_textFlow.interactionManager);
			if(SelManager) 
			{
				SelManager.selectRange(0, 0);
				//make sure there is never any blinking when running these tests
				setCaretBlinkRate (0);
			}
            
			_textFlow.flowComposer.updateAllControllers();
		}
		
		private function myEmptyChilds():Canvas
		{
			var TestCanvas:Canvas = null;
			TestDisplayObject = testApp.getDisplayObject();
			if (TestDisplayObject)
			{
				TestCanvas = Canvas(TestDisplayObject);
				TestCanvas.removeAllChildren();
				var iCnt:int = TestCanvas.rawChildren.numChildren;
				for ( var a:int = 0; a < iCnt; a ++ )
				{
					TestCanvas.rawChildren.removeChildAt(0);
				}
			}
			
			return TestCanvas;
		}
		
		public function callTestMethod():void
		{
				var TestCase:XML = _testXML;
				var methodName:String = TestCase.TestData.(@name == "methodName").toString();
				this[methodName]();
		}
		
		private function crossContainerTest():void
		{
			var tb:TextBlock = (_textFlow.getChildAt(2) as ParagraphElement).getTextBlock();
			assertTrue ("The _textBlock of the second paragraph should not be null",  tb);
			var fLine:TextLine = tb.firstLine;
			assertTrue ("The first TextLine of the second paragraph should not be null",  fLine);
			assertTrue ("The first TextLine of the second paragraph should be on the second container",  fLine.parent == _container2);
		}
		
    } // !class
}
