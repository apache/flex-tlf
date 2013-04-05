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
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontWeight;
	import flash.text.engine.TextLine;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.GlobalSettings;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ListElement;
	import flashx.textLayout.elements.ListItemElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.ListStyleType;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.*;
	import flashx.textLayout.tlf_internal;
	import flashx.undo.IUndoManager;
	import flashx.undo.UndoManager;
	
	import mx.core.FTETextField;
	import mx.utils.LoaderUtil;

	use namespace tlf_internal;

	public class FlowModelTest extends VellumTestCase
	{
		public function FlowModelTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super(methodName, testID, testConfig);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Container";
			metaData.productSubArea = "Flow";
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			if (testConfig.writingDirection[0] == BlockProgression.TB && testConfig.writingDirection[1] == Direction.LTR)
			{
	   			ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "basicAPITest1", testConfig ) );
	   			ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "basicAPITest2", testConfig ) );
	   			ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "basicAPITest3", testConfig ) );
	   			ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "basicAPITest4", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "basicAPITest5", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "textFlowHostCharacterFormat", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "iterateParagraphForward", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "iterateParagraphBackward", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "cascadeValidation", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "elementMovingTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "emptyTextFlowTests", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "emptyElementCopyTests", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "fontMappingTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "insertLinkNoUpdateAPI", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "insertLinkNoUpdateViaEditManager", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "testUndo", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "testFindControllerIndexAtPosition", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "testFTETextField", testConfig ) );
				
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "listItemInsertion", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "replaceChildrenTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "resolveFontLookupTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "bindableSpan", testConfig ) );
				//ts.addTestDescriptor (new TestDescriptor (FlowModelTest, "softKeyboardFlagTest", testConfig ) );
			}
   		}

   		private var beginTime:int;
   		private function beginAPITest():void
   		{
   			beginTime = getTimer();
			SelManager.selectRange(-1,-1);
   		}
   		private function endAPITest():void
   		{
			SelManager.selectRange(0,0);
			SelManager.textFlow.flowComposer.updateAllControllers();
   		}

		/**
		 * Direct usage of the flow APIs. No validation - just look for crashes.
		 * This test changes the color of the entire text.
		 */
		public function basicAPITest1():void
		{
			// set the color on the entire flow
			beginAPITest();
			SelManager.textFlow.color = 0xff0000;
			endAPITest();
		}

		/**
		 * Direct usage of the flow APIs. No validation - just look for crashes.
		 * This test deletes every other character in the entire text.
		 */
		public function basicAPITest2():void
		{
			// delete every other character in the textflow
			beginAPITest();

			var idx:int = 0;
			while (idx < SelManager.textFlow.textLength)
			{
				var span:SpanElement = SelManager.textFlow.findLeaf(idx) as SpanElement;
				if (span)
				{
					var spanStart:int = span.getAbsoluteStart();
					span.replaceText(idx-spanStart,idx-spanStart+1,null);
				}
				idx++;

			}
			endAPITest();
		}

		/**
		 * Direct usage of the flow APIs. No validation - just look for crashes.
		 * This test adds another paragraph to the flow containing the text "Hello World"
		 * in 24 point font.
		 */
		public function basicAPITest3():void
		{
			// add a paragraph
			beginAPITest();
			var p:ParagraphElement = new ParagraphElement();
			var s:SpanElement = new SpanElement();
			s.text = "Hello world";
			s.fontSize = 24;
			p.replaceChildren(0,0,s);
			SelManager.textFlow.replaceChildren(SelManager.textFlow.numChildren,SelManager.textFlow.numChildren,p);
			endAPITest();
		}

		/**
		 * This test performs a series of changes and validates the changes after they're performed.
		 */
		public function basicAPITest4():void
		{
			// more comprehensive set of tests - several manipulations to the flow and then display it

			// generic begin to an API test
			beginAPITest();

			// get the textflow
			var textFlow:TextFlow = SelManager.textFlow;

			// remove all the textflow children
			textFlow.replaceChildren(0,textFlow.numChildren);
			assertTrue("expected no elements on the flow, but found " + textFlow.numChildren,
						textFlow.numChildren == 0);

			// create a paragraph
			var p:ParagraphElement = new ParagraphElement();

			// create a span
			var s:SpanElement = new SpanElement();
			s.text = "Hello world. ";
			s.fontSize = 24;

			// split the span
			var nextSpan:SpanElement = s.splitAtPosition(6) as SpanElement;
			// set the color - color can be a string or an unsigned integer
			nextSpan.color = "0xff";
			assertTrue("expected that the color would be 255, but found " + uint(nextSpan.format.color),
						uint(nextSpan.format.color) == 255);

			// put the two spans in the paragraph
			p.replaceChildren(0,0,s);
			CONFIG::debug { assertTrue("debugCheckFlowElement() failed after adding one span",
										p.debugCheckFlowElement() == 0); }
			p.replaceChildren(1,1,nextSpan);
			CONFIG::debug { assertTrue("debugCheckFlowElement() failed after adding second span",
										p.debugCheckFlowElement() == 0); }
			assertTrue("expected the element count to be 2, but it was " + p.numChildren,
						p.numChildren == 2);

			// add another span
			s = new SpanElement();
			s.text = "Start:"
			p.replaceChildren(0,0,s);
			CONFIG::debug { assertTrue("debugCheckFlowElement() failed after adding third span",
										p.debugCheckFlowElement() == 0); }

			// put the paragraph in the TextFlow
			textFlow.replaceChildren(0,0,p);
			assertTrue("text flow should have one element but has " + textFlow.numChildren,
						textFlow.numChildren == 1);
			CONFIG::debug { assertTrue("debugCheckFlowElement() failed after adding para to flow",
										textFlow.debugCheckFlowElement() == 0) }

			// make another paragraph
			p = new ParagraphElement();
			s = new SpanElement();
			p.replaceChildren(0,0,s);
			s.text="NEW FIRST PARAGRAPH";

			// set the paragraph attributes directly
			p.textIndent = 20;
			// set the paragraph attributes via clone and set
			var pa:TextLayoutFormat = new TextLayoutFormat(p.format);
			pa.textAlign = TextAlign.RIGHT;
			p.format = pa;

			// into the textFlow at the beginning
			textFlow.replaceChildren(0,0,p);
			CONFIG::debug {assertTrue("debugCheckFlowElement() failed after adding para to beginning",
										textFlow.debugCheckFlowElement() == 0); }

			// generic end to an API test
			endAPITest();
		}

		/**
		 * This test inserts an FE in the middle of a paragraph
		 */
		public function basicAPITest5():void
		{
			// more comprehensive set of tests - several manipulations to the flow and then display it

			// generic begin to an API test
			beginAPITest();

			// get the textflow
			var textFlow:TextFlow = SelManager.textFlow;

			// create a paragraph empty the flow and insert it
			var p:ParagraphElement = new ParagraphElement();
			textFlow.replaceChildren(0,textFlow.numChildren,p);

			// create a span
			var s:SpanElement = new SpanElement();
			s.text = "Hello world. ";
			s.fontSize = 24;

			// put it in the paragraph
			p.replaceChildren(0,0,s);

			// split the span
			var nextSpanElement:SpanElement = s.splitAtPosition(6) as SpanElement;
			assertTrue("Incorrect elementCount after split", p.numChildren == 2);

			// create and insert an image between the spans
			var image:InlineGraphicElement = new InlineGraphicElement();
			image.width = 19;
			image.height = 19;
			image.source = LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/surprised.png");
			p.replaceChildren(1,1,image);

			assertTrue("failed length on new InlineGraphicElement", image.textLength == 1);
			assertTrue("failed elementCount after image insert", p.numChildren == 3);
			assertTrue("bad first child",p.getChildAt(0) is SpanElement);
			assertTrue("bad first child",p.getChildAt(1) is InlineGraphicElement);
			assertTrue("bad first child",p.getChildAt(2) is SpanElement);
			
			// set a userStyle on a ContainerController
			var saveFormat:ITextLayoutFormat = ContainerController.containerControllerInitialFormat;
			try
			{
				ContainerController.containerControllerInitialFormat = null;
				var controller:ContainerController = new ContainerController(new Sprite());
				controller.setStyle("foo","blah");
			}
			catch (e:Error)
			{
				ContainerController.containerControllerInitialFormat = saveFormat;
				throw(e);			
			}
			ContainerController.containerControllerInitialFormat = saveFormat;

			// generic end to an API test
			endAPITest();
		}

		/** Test setting hostCharacterFormat on the TextFlow */
		public function textFlowHostCharacterFormat():void
		{
			// generic begin to an API test
			beginAPITest();

			// get the textflow
			var textFlow:TextFlow = SelManager.textFlow;
			var leaf:FlowLeafElement = textFlow.getFirstLeaf();

			// make it red
			var cf:TextLayoutFormat = new TextLayoutFormat();
			cf.color = 0xff0000;
			textFlow.hostFormat = cf;
			assertTrue("host character format set color failed",leaf.computedFormat.color == 0xff0000);

			// make it blue
			textFlow.color = 0xff;
			assertTrue("textFlow character format color override failed",leaf.computedFormat.color == 0xff);

			// clear the blue
			textFlow.color = undefined;
			assertTrue("textFlow color clear failed",leaf.computedFormat.color == 0xff0000);

			// clear the hostCharacterFormat
			textFlow.hostFormat = null;
			assertTrue("host character format clear failed",leaf.computedFormat.color == 0);

			endAPITest();
		}

		private function initTextFlowAAA():TextFlow
		{
			var textFlow:TextFlow = new TextFlow();
			var p:ParagraphElement = new ParagraphElement();
			var span:SpanElement = new SpanElement();
			span.text = "aaa";
			p.replaceChildren(0, 0, span);
			textFlow.replaceChildren(0, 0, p);
			return textFlow;
		}

		// Insert a link to a paragraph that hasn't ever been updated.
		public function insertLinkNoUpdateAPI():void
		{
			var textFlow:TextFlow = new TextFlow();
			var p:ParagraphElement = new ParagraphElement();
			var link:LinkElement = new LinkElement();
			link.href = "http://www.cnn.com";
			link.target = "_self";
			var span:SpanElement = new SpanElement();
			span.text = "aaa";
			link.replaceChildren(0, 0, span);
			p.replaceChildren(0, 0, link);
			textFlow.replaceChildren(0, 0, p);
		}

		// Insert a link to a paragraph that hasn't ever been updated.
		public function insertLinkNoUpdateViaEditManager():void
		{
			var textFlow:TextFlow = initTextFlowAAA();
			var editManager:IEditManager = new EditManager();
			textFlow.interactionManager = editManager;

			editManager.selectRange(1,2);
			editManager.applyLink("http://livedocs.adobe.com/", "_self", true);
		}

		// undo in a flow that has no controllers
		public function testUndo():void
		{
			var textFlow:TextFlow = initTextFlowAAA();
			var undoManager:IUndoManager = new UndoManager();
			var editManager:IEditManager = new EditManager(undoManager);
			textFlow.interactionManager = editManager;

			editManager.selectRange(1,2);
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.fontWeight = FontWeight.BOLD;
			editManager.applyLeafFormat(format);

			undoManager.undo();
		}

		private function createParaIterationModel():TextFlow
		{
			// Creates 3 divs, each have 4 paras
			const paraTotal:int = 4;
			var paraCount:int;
			const divTotal:int = 3;
			var divCount:int;

			var flow:TextFlow = new TextFlow();
			for (var j:int = 0; j < divTotal; j++)
			{
				var div:DivElement = new DivElement();
				for (var i:int = 0; i < paraTotal; i++)
				{
					var para:ParagraphElement = new ParagraphElement();
					var span:SpanElement = new SpanElement();
					span.text = paraCount.toString();
					para.addChild(span);
					div.addChild(para);
					paraCount++;
				}
				flow.addChild(div);
			}
			return flow;
		}

		public function iterateParagraphForward():void
		{
			var flow:TextFlow = createParaIterationModel();
			var para:ParagraphElement = flow.getFirstLeaf().getParagraph();
			var i:int = 0;
			while (para != null)
			{
				var cStr:String = para.getText();
				assertTrue("Text not as expected", int(cStr) == i);
				para = para.getNextParagraph();
				i++;
			}
			assertTrue("Unexpected paragraph count", i == 12);
		}

		public function iterateParagraphBackward():void
		{
			//const kParaTerminator:String = '\u2029';

			var flow:TextFlow = createParaIterationModel();
			var para:ParagraphElement = flow.getLastLeaf().getParagraph();
			var i:int = 11;
			//These two tests are no longer valid due to PARB changes to removed the terminator
			//parameter from getText on a paragraph element.
			//
			//var terminatorTestStr:String = para.getText("\n");
			//assertTrue("Should have newline as terminator", terminatorTestStr.substr(terminatorTestStr.length - 1, 1) == '\n');
			//terminatorTestStr = para.getText();
			//assertTrue("Should have paragraph terminator as terminator", terminatorTestStr.substr(terminatorTestStr.length - 1, 1) == kParaTerminator);
			while (para != null)
			{
				var cStr:String = para.getText();
				assertTrue("Text not as expected", int(cStr) == i);
				para = para.getPreviousParagraph();
				i--;
			}
			assertTrue("Unexpected paragraph count", i == -1);
		}
		public function cascadeValidation():void
		{
			var flow:TextFlow = new TextFlow();
			var para:ParagraphElement = new ParagraphElement();
			var span:SpanElement = new SpanElement();
			flow.addChild(para);
			para.addChild(span);
			flow.backgroundColor = 0xff;
			assertTrue("backgroundColor should not inherit",TextLayoutFormat.backgroundColorProperty.inherited == false);
			assertTrue("bad flow backGroundColor", flow.computedFormat.backgroundColor == 0xff);
			assertTrue("bad para backGroundColor", para.computedFormat.backgroundColor == TextLayoutFormat.backgroundColorProperty.defaultValue);
			assertTrue("bad span backGroundColor", span.computedFormat.backgroundColor == TextLayoutFormat.backgroundColorProperty.defaultValue);
		}

		// tests api change to automatically remove a flowelements children when using replaceChildren
		public function elementMovingTest():void
		{
			var lengthBefore:int;

			// this flow should have two paragraphs as children
			var flow:TextFlow = SelManager.textFlow.deepCopy() as TextFlow;	// clone the flow

			var firstPara:FlowElement = flow.getChildAt(0);
			lengthBefore = flow.textLength;
			//firstPara.parent.removeChild(firstPara);	// soon to no longer be needed
			//assertTrue("elementMovingTest: removing para incorrect lengths",flow.textLength == lengthBefore-firstPara.textLength);

			lengthBefore = SelManager.textFlow.textLength;
			SelManager.textFlow.addChild(firstPara);
			assertTrue("elementMovingTest: adding para incorrect lengths",SelManager.textFlow.textLength == lengthBefore+firstPara.textLength);

			var lastLeaf:FlowElement = flow.getLastLeaf();
			var lastLeafLength:int = lastLeaf.textLength;
			//lastLeaf.parent.removeChild(lastLeaf);	// soon to no longer be needed
			lengthBefore = SelManager.textFlow.textLength;
			SelManager.textFlow.getLastLeaf().parent.addChild(lastLeaf);
			assertTrue("elementMovingTest: adding span incorrect lengths",SelManager.textFlow.textLength == lengthBefore+lastLeafLength-1);
		}

		// Empty Flow Tests - verify that empty/partially empty TextFlow's are normalized correctly
		public function emptyTextFlowTests():void
		{
			var tf:TextFlow;

			// just an empty TextFlow
			tf = new TextFlow();
			tf.flowComposer.addController(new ContainerController(new Sprite()));
			tf.flowComposer.updateAllControllers();

			// empty TextFlow with paragraph
			tf = new TextFlow();
			tf.addChild(new ParagraphElement());
			tf.flowComposer.addController(new ContainerController(new Sprite()));
			tf.flowComposer.updateAllControllers();

			// empty TextFlow with paragraph and ILG
			tf = new TextFlow();
			var p:ParagraphElement = new ParagraphElement();
			p.addChild(new InlineGraphicElement());
			tf.addChild(p);
			tf.flowComposer.addController(new ContainerController(new Sprite()));
			tf.flowComposer.updateAllControllers();

			// empty TextFlow with paragraph and empty LinkElement
			tf = new TextFlow();
			p = new ParagraphElement();
			p.addChild(new LinkElement());
			tf.addChild(p);
			tf.flowComposer.addController(new ContainerController(new Sprite()));
			tf.flowComposer.updateAllControllers();

			// empty TextFlow with paragraph and empty TCYElement
			tf = new TextFlow();
			p = new ParagraphElement();
			p.addChild(new TCYElement());
			tf.addChild(p);
			tf.flowComposer.addController(new ContainerController(new Sprite()));
			tf.flowComposer.updateAllControllers();

			// a more complex example
			tf = new TextFlow();
			p = new ParagraphElement();
			var tcy:TCYElement = new TCYElement();
			tcy.addChild(new InlineGraphicElement());
			tcy.addChild(new SpanElement());
			p.addChild(tcy);
			tf.addChild(p);
			tcy.removeChildAt(1);
			tf.flowComposer.addController(new ContainerController(new Sprite()));
			tf.flowComposer.updateAllControllers();

			// several empty spans
			tf = new TextFlow();
			p = new ParagraphElement();
			tf.addChild(p);
			p.addChild(new SpanElement());
			p.addChild(new SpanElement());
			p.addChild(new SpanElement());
			tf.flowComposer.addController(new ContainerController(new Sprite()));
			tf.flowComposer.updateAllControllers();
		}
		
		public function emptyElementCopyTests():void
		{
			var elemList:Array = GeneralFunctionsTest.childParentTable[0];
			for (var idx:int = 1; idx < elemList.length; idx++)
			{
				var elem:FlowElement = new elemList[idx];
				elem.shallowCopy();
				elem.deepCopy();
			}
		}

		private function validateBitmap(actual:Bitmap, expected:Bitmap):Boolean
		{
			actual.bitmapData.draw(expected, null, null, "difference");
			var bounds:Rectangle = new Rectangle(0, 0, actual.width, actual.height);
			var diffPixels:ByteArray = actual.bitmapData.getPixels(bounds);
			diffPixels.position = 0;
			while (diffPixels.bytesAvailable > 0)
			{
				if (diffPixels.readByte() > 0)
					return false;
			}

			return true;
		}

		private function myFontMapper(fd:FontDescription):void
		{
			if (fd.fontName == "Arial Black")
			{
				fd.fontName = "Arial";
				fd.fontWeight = FontWeight.BOLD;
			}
		}

		/** Tests fontMapping */
		public function fontMappingTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var container:DisplayObjectContainer = DisplayObjectContainer(textFlow.flowComposer.getControllerAt(0).container);

			textFlow.fontFamily = "Arial";
			textFlow.fontWeight = FontWeight.BOLD;
			textFlow.flowComposer.updateAllControllers();

			var arialBoldBits:BitmapData = new BitmapData(container.width,container.height);
			arialBoldBits.draw(container as DisplayObjectContainer);
			var arialBoldData:Bitmap = new Bitmap(arialBoldBits);

			textFlow.fontFamily = "Arial Black";
			textFlow.fontWeight = undefined;
			textFlow.flowComposer.updateAllControllers();

			var arialBlackBits:BitmapData = new BitmapData(container.width,container.height);
			arialBlackBits.draw(container as DisplayObjectContainer);
			var arialBlackData:Bitmap = new Bitmap(arialBlackBits);

			GlobalSettings.fontMapperFunction = myFontMapper;
			textFlow.invalidateAllFormats();

			try
			{
				textFlow.flowComposer.updateAllControllers();
			}
			finally
			{
				GlobalSettings.fontMapperFunction = null;
				textFlow.invalidateAllFormats();
			}

			var mappedBits:BitmapData = new BitmapData(container.width,container.height);
			mappedBits.draw(container as DisplayObjectContainer);
			var mappedData:Bitmap = new Bitmap(mappedBits);

			assertTrue("font mapping failed", validateBitmap(mappedData, arialBoldData));

			textFlow.flowComposer.updateAllControllers();

			var mappingClearedBits:BitmapData = new BitmapData(container.width,container.height);
			mappingClearedBits.draw(container as DisplayObjectContainer);
			var mappingClearedData:Bitmap = new Bitmap(mappingClearedBits);

			assertTrue("clearing font mapping failed", validateBitmap(mappingClearedData, arialBlackData));

		}

		/** test the binary search algorithm which in findControllerIndexAtPosition - tricky bits wrt handling of zero length containers */
		public function testFindControllerIndexAtPosition():void
		{
			var s:Sprite = new Sprite();	// scratch
			var controller:ContainerController;	// scratch
			var composer:StandardFlowComposer = new StandardFlowComposer();
			// ideally shouldn't need TextFlow but because containercontrollers find their owning composer via the textflow its needed
			var textFlow:TextFlow = new TextFlow();
			textFlow.flowComposer = composer;
			textFlow.mxmlChildren = [ "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678" ];

			controller = new ContainerController(s);
			controller.verticalScrollPolicy = "off";
			composer.addController(controller);
			controller.setTextLength(100);
			controller.verticalScrollPolicy = "off";

			assertTrue("Bad result in findControllerIndexAtPosition 9",composer.findControllerIndexAtPosition(0)== 0);
			assertTrue("Bad result in findControllerIndexAtPosition 10",composer.findControllerIndexAtPosition(100,true)== 0);
			assertTrue("Bad result in findControllerIndexAtPosition 11",composer.findControllerIndexAtPosition(100,false)== -1);

			for (var idx1:int  = 0; idx1 < 4; idx1++)
			{
				for (var idx2:int = 0; idx2 < 4 ; idx2++)
				{
					var idx:int;

					composer = new StandardFlowComposer();
					textFlow = new TextFlow();
					textFlow.flowComposer = composer;
					textFlow.mxmlChildren = [ "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678" ];

					// add some empties
					for (idx = 0; idx < idx1; idx++)
						composer.addController(new ContainerController(s));
					// add one of length one
					controller = new ContainerController(s);
					controller.verticalScrollPolicy = "off";	// scrolling confuses it
					composer.addController(controller);
					controller.setTextLength(100);				// internal API
					// add some empties
					for (idx = 0; idx < idx2; idx++)
						composer.addController(new ContainerController(s));
					assertTrue("Bad result in findControllerIndexAtPosition 1",composer.findControllerIndexAtPosition(0)== 0);
					assertTrue("Bad result in findControllerIndexAtPosition 2",composer.findControllerIndexAtPosition(0,true)== 0);
					assertTrue("Bad result in findControllerIndexAtPosition 3",composer.findControllerIndexAtPosition(100,true)== idx1);
					assertTrue("Bad result in findControllerIndexAtPosition 4",composer.findControllerIndexAtPosition(100,false)== -1);
					// add one with some length
					textFlow.mxmlChildren = [ "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678" ];
					controller.setTextLength(100);
					controller = new ContainerController(s);
					controller.verticalScrollPolicy = "off";	// scrolling confuses it
					composer.addController(controller);
					controller.setTextLength(100);				// internal API
					assertTrue("Bad result in findControllerIndexAtPosition 5",composer.findControllerIndexAtPosition(100,true)== idx1);
					assertTrue("Bad result in findControllerIndexAtPosition 6",composer.findControllerIndexAtPosition(100,false)== idx1+1);
					assertTrue("Bad result in findControllerIndexAtPosition 7",composer.findControllerIndexAtPosition(200,true)== idx1+idx2+1);
					assertTrue("Bad result in findControllerIndexAtPosition 8",composer.findControllerIndexAtPosition(200,false)== -1);
				}
			}

		}

		
		private static function checkListLines(textFlow:TextFlow,numLines:int,prefix:String):void
		{
			for (var idx:int = 0; idx < numLines; idx++)
			{
				var tfl:TextFlowLine = textFlow.flowComposer.getLineAt(idx);
				assertTrue(prefix+": Missing TextFlowLine: "+idx,tfl != null);
				var textLine:TextLine = tfl.getTextLine();
				assertTrue(prefix+": Missing TextLine: "+idx,textLine != null);
				var numberLine:TextLine = textLine.getChildAt(0) as TextLine;
				assertTrue(prefix+": Missing NumberLine: "+idx,numberLine != null);
				/* var numberString:String = numberLine.userData as String;
				var expectedString:String = (idx+1).toString() + ".";	// for numeric lists
				assertTrue(prefix+": NumberLine missing userData: "+idx,numberString != null);
				assertTrue(prefix+": Incorrect NumberLine userData: "+idx,numberLine.userData as String == expectedString); 
				assertTrue(prefix+": Incorrect NumberLine rawTextLength: "+idx,numberString.length+1 == numberLine.rawTextLength); */
			}
		}
		
		public function listItemInsertion():void
		{
			// some validations that ensure ListElement is correctly setup for list processing
			
			// every ListStyleType must have an entry in ListElement.listSuffixes
			var handler:EnumPropertyHandler = TextLayoutFormat.listStyleTypeProperty.findHandler(EnumPropertyHandler) as EnumPropertyHandler;
			assertTrue("listItemInsertion: missing handler for ListStyleType", handler != null && handler.range != null);

			var	range:Object = handler.range;
			var value:String;
			
			var numberedListStyles:Object = { };
			for (value in ListElement.algorithmicListStyles)
			{
				assertTrue("listItemInsertion: table entry duplicated",numberedListStyles[value] === undefined);
				numberedListStyles[value] = ListElement.algorithmicListStyles[value];
			}
			for (value in ListElement.numericListStyles)
			{
				assertTrue("listItemInsertion: table entry duplicated",numberedListStyles[value] === undefined);
				numberedListStyles[value] = ListElement.numericListStyles[value];
			}
			for (value in ListElement.alphabeticListStyles)
			{
				assertTrue("listItemInsertion: table entry duplicated",numberedListStyles[value] === undefined);
				numberedListStyles[value] = ListElement.alphabeticListStyles[value];
			}
			
			for (value in range)
			{
				if (value != FormatValue.INHERIT)
				{
					// must be a numbered list or an unnumbered list but not both
					assertTrue("listItemInsertion: listStyleType must be numbered or unnumbered but not both: "+value,
						numberedListStyles[value] !== undefined && ListElement.constantListStyles[value] === undefined
						|| numberedListStyles[value] === undefined && ListElement.constantListStyles[value] !== undefined)
					// numbered lists must have a suffix
					if ( ListElement.constantListStyles[value] === undefined)
						assertTrue("listItemInsertion: missing suffix property: " + value,ListElement.listSuffixes[value] !== undefined);
				}
			}
			
			// verify that all constantListStyles are in range
			for (value in ListElement.constantListStyles)
				assertTrue("listItemInsertion: invalid value in constantListStyles: " + value, range[value] !== undefined);
			// verify that all numberedListStyles are in range
			for (value in numberedListStyles)
				assertTrue("listItemInsertion: invalid value in numberedListStyles: " + value, range[value] !== undefined);
			// verify that all listSuffixes are in range
			for (value in ListElement.listSuffixes)
				assertTrue("listItemInsertion: invalid value in listSuffixes: " + value, range[value] !== undefined);			
				
			SelManager.selectRange(0,0);

			// remove all the children and put in a list
			var textFlow:TextFlow = SelManager.textFlow;
			
			textFlow.replaceChildren(0,textFlow.numChildren);
			
			var list:ListElement = new ListElement();
			list.listStyleType = ListStyleType.DECIMAL;
			
			textFlow.addChild(list);
			var item:ListItemElement = new ListItemElement();
			list.addChild(item);
			
			textFlow.flowComposer.updateAllControllers();
			
			assertTrue("listItemInsertion: incorrect normalize",textFlow.findAbsoluteParagraph(0).parent == item);
			
			// append two items and compose
			list.addChild(new ListItemElement());
			list.addChild(new ListItemElement());
			textFlow.flowComposer.updateAllControllers();
			
			// check the three textlines
			checkListLines(textFlow,3,"listItemInsertion1");
			
			// now insert a brand new ListItem at the head and verify
			list.replaceChildren(0,0,new ListItemElement());
			textFlow.flowComposer.updateAllControllers();
			
			// check four textlines
			checkListLines(textFlow,4,"listItemInsertion2");
			
			// remove a list item
			list.removeChildAt(1);
			textFlow.flowComposer.updateAllControllers();
			
			// check three textLines
			checkListLines(textFlow,3,"listItemInsertion3");
			
			// add another list in the first ListItemElement
			item = list.getChildAt(0) as ListItemElement;
			var newList:ListElement = new ListElement();
			item.addChild(newList);
			textFlow.flowComposer.updateAllControllers();
			
			// assert the empty list is deleted
			assertTrue("listItemInsertion: newList not normalized",newList.numChildren == 1);

		}
		
		public function testFTETextField():void
		{
			// use the TextFlow's container
			var fieldParent:Sprite = SelManager.textFlow.flowComposer.getControllerAt(0).container;
			// remove the controller so the the textFlow isn't displayed in it
			SelManager.textFlow.flowComposer.removeControllerAt(0);
			
			var field:FTETextField = new FTETextField();
			field.htmlText = "Hello world";
			fieldParent.addChild(field);
		}
		
		public function replaceChildrenTest():void
		{
			SelManager.selectRange(0,0);
			
			// remove all the children 
			var textFlow:TextFlow = SelManager.textFlow;
			textFlow.replaceChildren(0,textFlow.numChildren);
			
			var p:ParagraphElement = new ParagraphElement();
			textFlow.addChild(p);
			
			var link:LinkElement = new LinkElement();
			link.href = "XXX";
			p.addChild(link);
			var span:SpanElement = new SpanElement();
			span.text = "Hello, ";
			span.fontSize = 24;
			link.addChild(span);
			
			var link2:LinkElement = new LinkElement();
			link2.href = "YYY";
			p.addChild(link2);
			
			var span2:SpanElement = new SpanElement();
			span2.text = "world ";
			span2.fontSize = 24;
			link2.addChild(span2);
			
			textFlow.flowComposer.updateAllControllers();
			
			link.replaceChildren(link2.numChildren,link2.numChildren,link2.mxmlChildren);
			p.removeChild(link2);
			textFlow.flowComposer.updateAllControllers();
			
			assertTrue("replaceChildrenTest: extra line - look for extra terminator",textFlow.flowComposer.numLines == 1);
		}
		
		private function myFontLookup(context:mySwfContext, tlf:ITextLayoutFormat):Function
		{
			return myFontLookup;
		}
		
		public function resolveFontLookupTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			
			textFlow.fontFamily = "Arial";
			textFlow.fontWeight = FontWeight.BOLD;
			textFlow.fontLookup = "device";
			textFlow.flowComposer.updateAllControllers();
			
			var swfContext:mySwfContext = new mySwfContext();
			try
			{
				GlobalSettings.resolveFontLookupFunction = myFontLookup(swfContext, textFlow.format);
				textFlow.flowComposer.updateAllControllers();
				assertTrue ("fontLookup not matched.", textFlow.fontLookup = swfContext.myFontlookup);
			}
			finally
			{
				GlobalSettings.resolveFontLookupFunction = null;
			}
		}
		
		public function bindableSpan():void
		{
			// Bindable span should not lose its formatting
			var textFlow:TextFlow = new TextFlow();
			var paragraph:ParagraphElement =  new ParagraphElement();
			var span1:SpanElement = new SpanElement();
			var span2:SpanElement = new SpanElement();
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.fontWeight = FontWeight.BOLD;
			span2.format = format;
			paragraph.mxmlChildren = [ span1, span2 ];
			textFlow.mxmlChildren = [ paragraph ];
			textFlow.flowComposer.addController(new ContainerController(new Sprite()));
			textFlow.flowComposer.compose();		// force normalize
			assertTrue("Spans should not be merged!", span2.parent == span1.parent && paragraph.numChildren == 2);
			assertTrue("Formatting on second span should be preserved!", span2.fontWeight == FontWeight.BOLD);
		}
		
		// This test does not work in our current build environment, since playerEnablesSpicyFeatures will always be false.
		// Once we have a method of compiling VellumUnit as a 10.2 swf, this test should be enabled.
		public function softKeyboardFlagTest():void
		{
			if (Configuration.playerEnablesSpicyFeatures)	// only run the rest of the test if we're in 10.2 or higher
			{
				// test 1 - add controller, then interaction manager
				var sprite:Sprite = new Sprite();
				var textFlow:TextFlow = new TextFlow();
				textFlow.flowComposer.addController(new ContainerController(sprite));
				textFlow.interactionManager = new EditManager();
				assertTrue("needsSoftKeyboard should be true after adding EditManager", sprite["needsSoftKeyboard"] == true);
				// test 2 - add another controller
				var sprite1:Sprite = new Sprite();
				textFlow.flowComposer.addController(new ContainerController(sprite1));
				assertTrue("needsSoftKeyboard should be true for a second container", sprite1["needsSoftKeyboard"] == true);		

				// test 3 - add interaction manager, then controller
				var sprite2:Sprite = new Sprite();
				var textFlow2:TextFlow = new TextFlow();
				textFlow2.interactionManager = new EditManager();
				textFlow2.flowComposer.addController(new ContainerController(sprite2));
				assertTrue("needsSoftKeyboard should be true after adding controller", sprite2["needsSoftKeyboard"] == true);
			}
		}
	}
}

import flash.text.engine.FontLookup;
import flashx.textLayout.compose.ISWFContext;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.formats.TextLayoutFormat;

class mySwfContext implements ISWFContext
{	
	public var myFontlookup:String = FontLookup.EMBEDDED_CFF;
	
	public function callInContext(fn:Function, thisArg:Object, argsArray:Array, returns:Boolean=true):*
	{
		var tf:TextFlow = thisArg as TextFlow;
		tf.fontLookup = FontLookup.EMBEDDED_CFF;
		if (returns)
			return fn.apply(thisArg, argsArray);
		fn.apply(thisArg, argsArray);
	}
	
}
