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
	import UnitTest.Validation.CompositionResults;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;
	import flash.ui.KeyLocation;
	
	import flashx.textLayout.*;
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.edit.TextScrap;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.factory.TruncationOptions;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.ClearFloats;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.VerticalAlign;
	import flashx.textLayout.utils.NavigationUtil;
	use namespace tlf_internal;
	
	import flashx.textLayout.edit.EditManager;
	
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.formats.Float;
	import spark.primitives.Line;
	import flash.events.MouseEvent;
	import flash.events.IEventDispatcher;
	import flash.display.Shape;
	import flashx.textLayout.events.TextLayoutEvent;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.utils.LoaderUtil;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import mx.containers.Canvas;
	
	public class FloatTest extends VellumTestCase
	{
		private var _textFlow:TextFlow;
		private var _flowComposer:IFlowComposer;
		private var _editManager:IEditManager;
		private var _testXML:XML;
		private var _currentContent:String;		// content in TextFlow
		private var _disableVerticalCheck:Boolean;	// don't check floats vertical location; tests that force floats down should set this
		private var _floatColor:int;
		private var _disableBoundsCheck:Boolean = false;
		
		private static var _englishContent:String = "There are many such lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.\n" + 
			"The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Within the furnace were seen the curling and riotous flames, and the burning marble, almost molten with the intensity of heat; while without, the reflection of the fire quivered on the dark intricacy of the surrounding forest, and showed in the foreground a bright and ruddy little picture of the hut, the spring beside its door, the athletic and coal-begrimed figure of the lime-burner, and the half-frightened child, shrinking into the protection of his father's shadow. And when again the iron door was closed, then reappeared the tender light of the half-full moon, which vainly strove to trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, though thus far down into the valley the sunshine had vanished long and long ago."

		private static var _japaneseContent:String = '文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフスする方法について解説しまが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクす。\n文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフスする方法について解説しまが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクす。\n' +
			'文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフスする方法について解説しまが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクす。\n文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフスする方法について解説しまが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクす。';
		
		public function FloatTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super (methodName, testID, testConfig);
			_testXML = testXML;
			TestData.fileName = null;
			
			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Composition";
			_floatColor = 0xFF0000;
		}
		
		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			addTestCase(ts, testConfig, "atFlowStart");
			addTestCase(ts, testConfig, "atFlowStartSpaceBefore");
			addTestCase(ts, testConfig, "atParagraphStart");
			addTestCase(ts, testConfig, "atParagraphStartSpaceBefore");
			addTestCase(ts, testConfig, "atParagraphEnd");
			addTestCase(ts, testConfig, "atLineStart");
			addTestCase(ts, testConfig, "atLineMiddle");
			addTestCase(ts, testConfig, "atLineEnd");
			addTestCase(ts, testConfig, "stackedFloats");
			addTestCase(ts, testConfig, "onTwoSidesSameLine");
			addTestCase(ts, testConfig, "onTwoSidesSuccessiveLines");
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"fillsColumn", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"noEmergencyBreakByFloat", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"fillsColumnRecursion", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"widerThanColumn", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"widerThanColumnScroll", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"contentHeightCheck", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"noFloatsWithMeasureOrExplicit", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"floatOnly", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"noVJ", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"verticalAlignMiddleFloatAtEnd", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"verticalAlignMiddleTextAtEnd", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"verticalAlignBottomFloatAtEnd", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"verticalAlignBottomTextAtEnd", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"verticalAlignBottomFloat2636122", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"textAlignRightAtStart", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"textAlignRightInMiddle", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"leftIndent", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"rightIndent", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"leftBigIndent", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"rightBigIndent", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"clearOneAll", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"clearTwoAll", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"paddingAndMargins", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"negativePaddingAndMargins", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"rightIndentWithTab", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"leftIndentWithTab", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"hoistFailure", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"clearNoPrecedingFloatAll", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"stackedLeftFloats", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"stackedRightFloats", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"smallFloatBigText", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"lineHeightIgnoredOnFloatingImages", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"convertFloatToInline", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"cursorByAnchor", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"insertTextBeforeFloat", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"atControllerEnd", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"resizeControllerWithFloats", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"textIndentAfterFloat", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"composeAcrossControllers", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"deleteAtStart", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"measureWidth", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"inlineWideAndFloat", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"narrowColumnFloat", testConfig, null) );																								
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"infiniteLoop2769562", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest, "verticalAlignInline", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (FloatTest, "pasteManyFloatsWithLoading", testConfig, null) ); 
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"contentBoundsWithFactoryComposition", testConfig, null) );
			// We only need one version of these tests
			if (testConfig.writingDirection[0] == BlockProgression.TB && testConfig.writingDirection[1] == Direction.LTR)
			{
				ts.addTestDescriptor (new TestDescriptor (FloatTest,"inlineAndFloat", testConfig, null) );
				ts.addTestDescriptor (new TestDescriptor (FloatTest,"htmlImportTest", testConfig, null) );
				ts.addTestDescriptor (new TestDescriptor (FloatTest,"overFlowAtStart", testConfig, null) );
				ts.addTestDescriptor (new TestDescriptor (FloatTest,"caretOnEmptyInlineGraphic", testConfig, null) );
				ts.addTestDescriptor (new TestDescriptor (FloatTest,"restartComposeFromStart", testConfig, null) );
				ts.addTestDescriptor (new TestDescriptor (FloatTest,"convertInlineToFloat", testConfig, null) );
				
			}
		}
		
		private static function addTestCase(ts:TestSuiteExtended, testConfig:TestConfig, methodName:String):void
		{
			//ts.addTestDescriptor (new TestDescriptor (MeasurementGridTest,methodName, testConfig, creationType, measureType, lineBreak) );
			var testXML:XML = <TestCase>
								<TestData name="methodName">{methodName}</TestData>
								<TestData name="id">{methodName}</TestData>
							</TestCase>;
			
			ts.addTestDescriptor (new TestDescriptor (FloatTest,"callTestMethod", testConfig, testXML) );
		}
		
		override public function setUp() : void
		{
			super.setUp();
			initializeSourceTextFlow();
			initializeFlow(TextConverter.importToFlow(_englishContent, TextConverter.PLAIN_TEXT_FORMAT));
		}
		
		override public function tearDown(): void
		{
			if (TestFrame && TestFrame.textFlow && !_disableBoundsCheck)
			{
				var s:Sprite = new Sprite();
				testApp.getDisplayObject().rawChildren.addChild(s);
				BoundsChecker.validateAll(TestFrame.textFlow, s, 10, true);
				testApp.getDisplayObject().rawChildren.removeChild(s);
			}
			super.tearDown();
		}
		
		private function initializeFlow(textFlow:TextFlow):void
		{
			_textFlow = textFlow;
			_flowComposer = _textFlow.flowComposer;
			VellumTestCase.testApp.contentChange (_textFlow);
			TestDisplayObject = VellumTestCase.testApp.getDisplayObject();
			TestFrame = _textFlow.flowComposer.getControllerAt(0);
			if (TestFrame.rootElement)
			{
				// Set the writing direction specified by the test
				_textFlow.blockProgression = writingDirection[0];
				_textFlow.direction        = writingDirection[1];
				SelManager = EditManager(_textFlow.interactionManager);
				if(SelManager) 
				{
					SelManager.selectRange(0, 0);
					//make sure there is never any blinking when running these tests
					setCaretBlinkRate (0);
				}
				_editManager = SelManager;
			}
			_textFlow.flowComposer.updateAllControllers();
		}

		private static var sourceTextFlow:Array;
		
		private function setUpFlow(content:String):void
		{
			var sourceFlow:TextFlow;
			if (content == _englishContent)
				sourceFlow = sourceTextFlow[0];
			else if (content == _japaneseContent)
				sourceFlow = sourceTextFlow[1];
			else 
				sourceFlow = TextConverter.importToFlow(content, TextConverter.PLAIN_TEXT_FORMAT);
			
			_textFlow.replaceChildren(0, _textFlow.numChildren);
			assertTrue("Empty TextFlow has incorrect ContainerLength",_textFlow.textLength == _textFlow.flowComposer.getControllerAt(0).textLength);
			var newFlow:TextFlow = sourceFlow.deepCopy() as TextFlow;
			var childCount:int = newFlow.numChildren;
			for (var i:int = newFlow.numChildren - 1; i >= 0; --i)
			{
				var child:FlowElement = newFlow.getChildAt(i);
				_textFlow.addChildAt(0, child);
			}
			_textFlow.flowComposer.updateAllControllers();
			_textFlow.interactionManager.selectRange(0, 0);
			_currentContent = content;
		}
		
		private function initializeSourceTextFlow():void
		{
			sourceTextFlow = [];
			
			// Create english content
			var englishFlow:TextFlow = TextConverter.importToFlow(_englishContent, TextConverter.PLAIN_TEXT_FORMAT);
			sourceTextFlow.push(englishFlow);

			// Create japanese content
			var japaneseFlow:TextFlow = TextConverter.importToFlow(_japaneseContent, TextConverter.PLAIN_TEXT_FORMAT);
			var textFlowFormat:TextLayoutFormat = new TextLayoutFormat();
			textFlowFormat.locale = "ja";
			japaneseFlow.format = textFlowFormat;
			sourceTextFlow.push(japaneseFlow);
		}
		
		// axies
		static private var floatTypeList:Array = [Float.LEFT, Float.RIGHT /*, Float.START, Float.END */];	// start & end disabled to make tests run faster
		static private var contentLanguageList:Array = [ _englishContent, _japaneseContent];
		static private var floatWidthList:Array = [ 5, 20, 50, 100, 200, 400 ]
		static private var floatHeightList:Array = [ 5, 20, 50, 100, 200, 400 ]; 
		
		public function callTestMethod():void
		{
			for each (var content:String in contentLanguageList)
			{
				var TestCase:XML = _testXML;
				var methodName:String = TestCase.TestData.(@name == "methodName").toString();			
				for each (var floatValue:String in floatTypeList)
					for each (var floatWidth:String in floatWidthList)
						for each (var floatHeight:String in floatHeightList)
						{
							setUpFlow(content);
						//	trace(methodName, floatValue, floatWidth.toString(), floatHeight.toString());
							this[methodName](floatValue, floatWidth, floatHeight);
						}
			}
		}
		
		// Test Cases:
		// float at paragraph start (left, right)
		// float at line start (left, right)
		// float in middle of line (left, right)
		// stacked floats (left, right)
		// multiple (stacked) floats at start
		// floats with no graphic
		// float doesn't fit in container (width/height) (*on end last para height = 400 this happens)
		// float does fit in container, following line does not
		// float at end of container
		// floats in multiple columns
		// float fits, not enough space for text (min-width??)
		
		import flashx.textLayout.edit.ElementRange;
		import flashx.textLayout.edit.ParaEdit;
		
		private function addFloatAtPosition(position:int, width:Number, height:Number, float:String):DisplayObject
		{
			var secondColor:int = 0;
			switch(_floatColor)
			{
				case 0xFF0000:	secondColor = 0x770000;
					break;
				case 0x00FF00: 	secondColor = 0x007700;
					break;
				case 0x0000FF:	secondColor = 0x000077;
					break;
			}

			// Create a simple rectangular display object for the float
			// Rectangle is two tone, to make it easier to know which part you're looking at
			var displayObject:Sprite = new Sprite();
			var g:Graphics = displayObject.graphics;
			g.beginFill(_floatColor);
			g.drawRect(0, 0, width/2, height);
			g.endFill();
			g.beginFill(secondColor);
			g.drawRect(width/2, 0, width/2, height);
			g.endFill();
			
			// Cycle through colors so multiple floats can be visually disintguished
			switch (_floatColor)
			{
				case 0xFF0000:	_floatColor = 0x00FF00;
								break;
				case 0x00FF00: 	_floatColor = 0x0000FF;
								break;
				case 0x0000FF:	_floatColor = 0xFF0000;
								break;
			}
			
			// Add it to the TextFlow at the specified location
		//	_editManager.insertInlineGraphic(displayObject, width, height, float, new SelectionState(_textFlow, position, position));

			var range:ElementRange = ElementRange.createElementRange(_textFlow,position, position);		
			var leafNode:FlowElement = range.firstLeaf;
			var leafNodeParent:FlowGroupElement = leafNode.parent;
			
			ParaEdit.createImage(leafNodeParent, position - leafNodeParent.getAbsoluteStart(), displayObject, width, height, float, null);
			return displayObject;
		}
		
		private function atParagraphStartInternal(leaf:FlowLeafElement, width:Number, height:Number, float:String, paragraphSpaceBefore:Number = 0):void
		{
			var paragraph:ParagraphElement = leaf.getParagraph();
			var paraStart:int = paragraph.getAbsoluteStart();
			if (paragraph.computedFormat.paragraphSpaceBefore != paragraphSpaceBefore)
			{
				var paragraphFormat:TextLayoutFormat = new TextLayoutFormat();
				paragraphFormat.paragraphSpaceBefore = paragraphSpaceBefore;
				paragraph.format = paragraphFormat;
			}
			var floatObject:DisplayObject = addFloatAtPosition(paraStart, width, height, float);
			
			verifyFloatInLine(paraStart, width, height, float, floatObject);		
		}
		
		/** Test adding a float to the start of the first and last paragraphs, with either left or right float, and with
		 * spaceBefore either 0 or 15. */
		private function atFlowStart(float:String, width:Number, height:Number):void
		{
			// On the first paragraph, add a float
			atParagraphStartInternal(_textFlow.getFirstLeaf(), width, height, float);			
		}
		
		/** Test adding a float to the start of the first and last paragraphs, with either left or right float, and with
		 * spaceBefore either 0 or 15. */
		private function atFlowStartSpaceBefore(float:String, width:Number, height:Number):void
		{
			// On the first paragraph, add a float
			atParagraphStartInternal(_textFlow.getFirstLeaf(), width, height, float, 15);			
		}
		
		/** Test adding a float to the start of the first and last paragraphs, with either left or right float, and with
		 * spaceBefore either 0 or 15. */
		private function atParagraphStart(float:String, width:Number, height:Number):void
		{
			// On the last paragraph, add a float
			atParagraphStartInternal(_textFlow.getLastLeaf(), width, height, float);			
		}
		
		private function atParagraphStartSpaceBefore(float:String, width:Number, height:Number):void
		{
			// On the last paragraph, add a spaceBefore and a float
			atParagraphStartInternal(_textFlow.getFirstLeaf(), width, height, float, 15);			
		}

		// Certify that the float was added to the container
		// Certify that the float appears below the previous line's descenders
		// Check that float appears at the correct horizontal alignment (left or right)
		// If there's an intersecting float that comes before, it would appear to the left or right of that float (i.e., stacked)
		// Look to see if they overlap in the blockProgression direction; if so, they're going to stack if they have the same float property
		// Check the vertical location of the float. It should go below the previous line's descender, and at or above the next line.
		// The EXCEPTION is if the float was displaced lower because it didn't fit on it's natural position (too wide). In that case,
		// float may appear below following lines. Test needs to flag this so we don't assert false positive.
		private function verifyFloatInLine(pos:int, width:Number, height:Number, float:String, floatObject:DisplayObject):void
		{
			if (float == Float.NONE)		// not a float, nothing to check
				return;
			
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			_textFlow.flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = floatObject.parent;
			var lineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(pos);
			
			var previousTextFlowLine:TextFlowLine;
			var textFlowLine:TextFlowLine;
			
			// Certify that the float was added to the container
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var firstLine:TextFlowLine = controller.getFirstVisibleLine();
			var lastLine:TextFlowLine = controller.getLastVisibleLine();
			var firstLineIndex:int = firstLine ? _textFlow.flowComposer.findLineIndexAtPosition(firstLine.absoluteStart) : -1;
			var lastLineIndex:int = lastLine ? _textFlow.flowComposer.findLineIndexAtPosition(lastLine.absoluteStart) : -1;
			if (lineIndex >= firstLineIndex && lineIndex <= lastLineIndex)
			{
				assertTrue("Float not added as child of the container", controller.container.contains(floatObject));
			
				// Certify that the float appears below the previous line's descenders
				if (lineIndex > firstLineIndex)
				{
					previousTextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex - 1);
				}
				textFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
				
				// Check that float appears at the correct horizontal alignment (left or right)
				// If there's an intersecting float that comes before, it would appear to the left or right of that float (i.e., stacked)
				var currentPos:int = textFlowLine.absoluteStart + textFlowLine.textLength;
				var floatRect:Rectangle = new Rectangle(floatHolder.x, floatHolder.y, floatObject.width, floatObject.height);
				var pos:int = 0;
				var paraFormat:ITextLayoutFormat = textFlowLine.paragraph.computedFormat;
				var maxLeft:Number = 0;
				var maxRight:Number = verticalText ? controller.compositionHeight : controller.compositionWidth;
				var otherDirection:String;
				var otherFloatType:String;
				for (var leaf:FlowLeafElement = _textFlow.getFirstLeaf(); leaf && pos < currentPos; leaf = leaf.getNextLeaf())
				{
					var otherInline:InlineGraphicElement = leaf as InlineGraphicElement;
					if (otherInline)
					{
						if (otherInline.graphic == floatObject)		// this is our float, we're done
							break;
						// Look to see if they overlap in the blockProgression direction; if so, they're going to stack if they have the same float property
						if (verticalText)
						{
							if (Math.floor(otherInline.graphic.parent.x) < Math.floor(floatRect.right))
							{
								otherDirection = otherInline.getParagraph().computedFormat.direction;
								otherFloatType = otherInline.computedFloat;
								if (otherFloatType == Float.START)
									otherFloatType = (otherDirection == Direction.LTR) ? Float.LEFT : Float.RIGHT;
								else if (otherFloatType == Float.END)
									otherFloatType = (otherDirection == Direction.RTL) ? Float.LEFT : Float.RIGHT;
								if (otherFloatType == Float.RIGHT)
									maxRight -= otherInline.elementHeight;
								if (otherFloatType == Float.LEFT)
									maxLeft += otherInline.elementHeight;
							}
						}
						else
						{
							if (otherInline.graphic.parent.y + otherInline.elementHeight > floatRect.top)
							{
								otherDirection = otherInline.getParagraph().computedFormat.direction;
								otherFloatType = otherInline.computedFloat;
								if (otherFloatType == Float.START)
									otherFloatType = (otherDirection == Direction.LTR) ? Float.LEFT : Float.RIGHT;
								else if (otherFloatType == Float.END)
									otherFloatType = (otherDirection == Direction.RTL) ? Float.LEFT : Float.RIGHT;
								if (otherFloatType == Float.LEFT)
									maxLeft += otherInline.elementWidth;
								if (otherFloatType == Float.RIGHT)
									maxRight -= otherInline.elementWidth;
							}
						}
					}
					pos += leaf.textLength;
				}

				// Check the vertical location of the float. It should go below the previous line's descender, and at or above the next line.
				// The EXCEPTION is if the float was displaced lower because it didn't fit on it's natural position (too wide). In that case,
				// float may appear below following lines. Test needs to flag this so we don't assert false positive.
				if (!_disableVerticalCheck)
				{
					var floatAlignsWithPrevious:Boolean = false;
					if (previousTextFlowLine)
					{
						if (verticalText)
							floatAlignsWithPrevious = Math.abs((floatHolder.x + floatObject.width) - (previousTextFlowLine.x - previousTextFlowLine.descent)) < 1;
						else
							floatAlignsWithPrevious = Math.abs(floatHolder.y - (previousTextFlowLine.y + previousTextFlowLine.ascent + previousTextFlowLine.descent)) < 1;
					}
					else  // no previous line, so check it against the container logical top (assume 0)
						if (verticalText)
							floatAlignsWithPrevious = true;
						else
							floatAlignsWithPrevious = Math.abs(floatHolder.y) < 1;
					var floatAlignsWithSameLine:Boolean = false;
					if (verticalText)
						floatAlignsWithSameLine = Math.abs((floatHolder.x + floatObject.width) - (textFlowLine.x - textFlowLine.descent)) < 1;
					else
						floatAlignsWithSameLine = Math.abs(floatHolder.y - (textFlowLine.y + textFlowLine.ascent + textFlowLine.descent)) < 1;
					assertTrue("Float has incorrect logical vertical position", floatAlignsWithPrevious || floatAlignsWithSameLine);
				}

				// Check horizontal location of the float
				if (float == Float.START)
					float = (paraFormat.direction == Direction.LTR) ? Float.LEFT : Float.RIGHT;
				else if (float == Float.END)
					float = (paraFormat.direction == Direction.RTL) ? Float.LEFT : Float.RIGHT;
				if (float == Float.LEFT)
				{
					if (verticalText)
						assertTrue("Float should be on the left", Math.abs(floatHolder.y - maxLeft) < 1);
					else
						assertTrue("Float should be on the left", Math.abs(floatHolder.x - maxLeft) < 1);
				}
				else if (float == Float.RIGHT)
				{
					if (verticalText)
						assertTrue("Float should be on the right", Math.abs(floatRect.bottom - maxRight) < 1);
					else
						assertTrue("Float should be on the right", Math.abs(floatRect.right - maxRight) < 1);
				}
			}
		}
		
		private function atLineStartInternal(lineIndex:int, width:Number, height:Number, float:String):void
		{
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			var pos:int = textFlowLine.absoluteStart;
			var floatObject:DisplayObject = addFloatAtPosition(pos, width, height, float);
			
			verifyFloatInLine(pos, width, height, float, floatObject);
		}
		
		private function atLineMiddleInternal(lineIndex:int, width:Number, height:Number, float:String):void
		{
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			if (!textFlowLine)
				return;
			
			var pos:int = textFlowLine.absoluteStart + (textFlowLine.textLength/2);
			var floatObject:DisplayObject = addFloatAtPosition(pos, width, height, float);
			
			verifyFloatInLine(pos, width, height, float, floatObject);		// aligns with next line
		}
		
		private function atLineEndInternal(lineIndex:int, width:Number, height:Number, float:String):void
		{
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			var pos:int = textFlowLine.absoluteStart + textFlowLine.textLength - 1;
			var floatObject:DisplayObject = addFloatAtPosition(pos, width, height, float);
			
			verifyFloatInLine(pos, width, height, float, floatObject);		// aligns with next line
		}
		
		/** Test adding a float at the start of a line, float should appear below and to the left or right of the line. */
		private function atLineStart(float:String, width:Number, height:Number):void
		{
			// At the start of the second line, add a left float
			atLineStartInternal(1, width, height, float);			
		}

		public function atLineMiddle(float:String, width:Number, height:Number):void
		{
			// At the start of the second line, add a left float
			atLineMiddleInternal(1, width, height, float);			
		}
		
		public function atLineEnd(float:String, width:Number, height:Number):void
		{
			// At the start of the second line, add a left float
			atLineEndInternal(1, width, height, float);			
		}
		
		private function atParagraphEndInternal(paragraph:ParagraphElement, width:Number, height:Number, float:String):void
		{
			var paragraph:ParagraphElement = _textFlow.getFirstLeaf().getParagraph();
			var pos:int = paragraph.getAbsoluteStart() + paragraph.textLength - 1;
			var lineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(pos);
			atLineEndInternal(lineIndex, width, height, float);			
		}
		
		public function atParagraphEnd(float:String, width:Number, height:Number):void
		{
			if (height >= 400)
				return;
			
			// Add float to the end of the first paragraph
			atParagraphEndInternal(_textFlow.getFirstLeaf().getParagraph(), width, height, float);			
		}
		
		// Test multiple floats on successive lines
		public function stackedFloats(float:String, width:Number, height:Number):void
		{
			if (width >= 400)
				return;
			
			atLineMiddleInternal(1, width, height, float);			
			// With a set of wide stacked floats, the second float gets pushed to after the 
			// preceding float, and therefore won't align with previous line's descender.
			// This is correct, but will assert so we turn off the asserts here.
			if ((_textFlow.blockProgression == BlockProgression.RL && height >= 400) ||
				(_textFlow.blockProgression == BlockProgression.TB && width >= 400))
				_disableVerticalCheck = true; 		// floats get pushed down b/c the second doesn't fit on the line, so don't check
			atLineMiddleInternal(2, width, height, float);	
		}
		
		private function flipFloat(float:String):String	{ return Float.LEFT ? Float.RIGHT : Float.LEFT; }
		
		// Test multiple floats on successive lines on each side
		public function onTwoSidesSuccessiveLines(float:String, width:Number, height:Number):void
		{
			// On successive lines
			atLineMiddleInternal(1, width, height, float);			

			// With a set of wide stacked floats, the second float gets pushed to after the 
			// preceding float, and therefore won't align with previous line's descender.
			// This is correct, but will assert so we turn off the asserts here.
			if ((_textFlow.blockProgression == BlockProgression.RL && height >= 400) ||
				(_textFlow.blockProgression == BlockProgression.TB && width >= 400))
				_disableVerticalCheck = true; 		// floats get pushed down b/c the second doesn't fit on the line, so don't check
			
			atLineMiddleInternal(2, width, height, flipFloat(float));	
		}

		// Test multiple floats on the same line, one on each side
		public function onTwoSidesSameLine(float:String, width:Number, height:Number):void
		{
			// On the same line
			atLineMiddleInternal(2, width/2, height/2, float);			

			// With a set of wide stacked floats, the second float gets pushed to after the 
			// preceding float, and therefore won't align with previous line's descender.
			// This is correct, but will assert so we turn off the asserts here.
			if ((_textFlow.blockProgression == BlockProgression.RL && height >= 400) ||
				(_textFlow.blockProgression == BlockProgression.TB && width >= 400))
				_disableVerticalCheck = true; 		// floats get pushed down b/c the second doesn't fit on the line, so don't check
			
			atLineMiddleInternal(2, width, height, flipFloat(float));					
		}
		
		private function logicalContentHeight(controller:ContainerController, verticalText:Boolean):Number { return verticalText ? controller.contentWidth : controller.contentHeight; }
		private function logicalContentWidth(controller:ContainerController, verticalText:Boolean):Number { return verticalText ? controller.contentHeight : controller.contentWidth; }
		
		public function contentHeightCheck():void
		{	
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			
			_textFlow.flowComposer.composeToPosition();
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var contentHeight:Number = logicalContentHeight(controller, verticalText);
			
			// Add a float to the end of the text, make sure it gets taller
			atLineMiddleInternal(_textFlow.flowComposer.numLines - 1, 100, 100, Float.LEFT);
			
			// The float goes even with the line, so not all the 100 pixels are added into the content height...
			assertTrue("Expected larger content height because of trailing float", logicalContentHeight(controller, verticalText) > contentHeight + 70);
		}
		
		public function contentWidthCheckLongFloat():void
		{	// Should be adapted for RL
			var textFlowFormat:TextLayoutFormat = new TextLayoutFormat(_textFlow.format);
			textFlowFormat.lineBreak = LineBreak.EXPLICIT;
			_textFlow.format = textFlowFormat;
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			_textFlow.flowComposer.updateAllControllers();
			var lineNumber:int;
			var contentWidth:Number = logicalContentWidth(controller, verticalText);
			atLineStartInternal(1, 7000, 115, Float.LEFT);		// insert graphic longer than longest line
	//		assertTrue("Expected larger content width because of trailing float", logicalContentWidth(controller, verticalText) > contentWidth);			
		}
		
		public function noFloatsWithMeasureOrExplicit():void
		{	
			// We expect that when text is not wrapping, floats will behave as inlines.

			var oldLinePos:Array;
			var newLinePos:Array;
			var flowComposer:IFlowComposer = _textFlow.flowComposer;
			var controller:ContainerController = flowComposer.getControllerAt(0);
			var textFlowFormat:TextLayoutFormat;
			var width:Number = controller.compositionWidth;
			var height:Number = controller.compositionHeight;
			
			// Create baseline to compare against, using inlines
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			textFlowFormat = new TextLayoutFormat(_textFlow.format);
			textFlowFormat.lineBreak = LineBreak.EXPLICIT;
			_textFlow.format = textFlowFormat;
			atLineMiddleInternal(1, 100, 100, Float.NONE);			
			atLineMiddleInternal(2, 100, 100, Float.NONE);			
			flowComposer.updateAllControllers();
			oldLinePos = getCompositionResults(verticalText, flowComposer);
			
			// Flip inlines to floats
			for (var leaf:FlowLeafElement = _textFlow.getFirstLeaf(); leaf; leaf = leaf.getNextLeaf())
			{
				if (leaf is InlineGraphicElement)
					(leaf as InlineGraphicElement).float = Float.LEFT;
			}

			// Test lineBreak=explicit, with floats
			flowComposer.updateAllControllers();
			newLinePos = getCompositionResults(verticalText, flowComposer);
			assertCompositionMatches(oldLinePos, newLinePos);
			
			// Test with lineBreak=toFit, with measuring
			textFlowFormat = new TextLayoutFormat(_textFlow.format);
			textFlowFormat.lineBreak = LineBreak.TO_FIT;
			_textFlow.format = textFlowFormat;
			if (verticalText)
				controller.setCompositionSize(width, NaN);
			else
				controller.setCompositionSize(NaN, height);
			flowComposer.updateAllControllers();
			newLinePos = getCompositionResults(verticalText, flowComposer);		
			assertCompositionMatches(oldLinePos, newLinePos);
		}
		
		public function hoistFailure():void
			// Test case where a graphic is narrow enough to get a hoist request, but too tall to fit once its composed. 
			// Should fall back to pushing to the next parcel.
		{
			var width:Number = 100;
			var height:Number = 100;
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			controller.horizontalScrollPolicy = ScrollPolicy.OFF;
			controller.verticalScrollPolicy = ScrollPolicy.OFF;
			if (verticalText)
				width = controller.compositionWidth;
			else
				height = controller.compositionHeight;

			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(1);
			if (!textFlowLine)
				return;
			
			var pos:int = textFlowLine.absoluteStart + (textFlowLine.textLength/2);
			var floatObject:DisplayObject = addFloatAtPosition(pos, width, height, Float.LEFT);
			
			_textFlow.flowComposer.updateAllControllers();
			
			assertTrue("Expected float to get pushed out of controller, but its a child of container", !controller.container.contains(floatObject));
			assertTrue("Expected float to get pushed out of controller, but its within controller textLength bounds", pos > controller.absoluteStart + controller.textLength);
		}
		
		public function noEmergencyBreakByFloat():void
		{
			// We should get breaks in the middle of words because a float fills up most but not all of the column.
			// Text should appear below the float if the word doesn't fit next to the float.
			var secondParagraph:ParagraphElement = _textFlow.getChildAt(1) as ParagraphElement;
			var width:Number =  (_textFlow.computedFormat.blockProgression == BlockProgression.RL) ? 458 : 807;
			var floatPosition:int = secondParagraph.getAbsoluteStart();
			var floatObject:DisplayObject = addFloatAtPosition(floatPosition, width, 60, Float.START);
			_textFlow.flowComposer.updateAllControllers(); 
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.findLineAtPosition(floatPosition + 1);
			var lastCharInLine:String = _textFlow.getText(textFlowLine.absoluteStart + textFlowLine.textLength - 1, textFlowLine.absoluteStart + textFlowLine.textLength);
			assertTrue("Line should end with a legal word separator (expected space", lastCharInLine == " ");
		}
		
		public function fillsColumnRecursion():void
		{
			// Detects an infinite recursion in composition
			// Add a float that almost but not quite fits the whole column
			var secondParagraph:ParagraphElement = _textFlow.getChildAt(1) as ParagraphElement;
			var width:Number =  (_textFlow.computedFormat.blockProgression == BlockProgression.RL) ? 458 : 807;
			var floatObject:DisplayObject = addFloatAtPosition(secondParagraph.getAbsoluteStart(), width, 60, Float.START);
			_textFlow.flowComposer.updateAllControllers(); 
		}
		
		public function fillsColumn():void
		{
			var width:Number = 100;
			var height:Number = 100;
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			if (verticalText)
				height = _textFlow.flowComposer.getControllerAt(0).compositionHeight;
			else
				width = _textFlow.flowComposer.getControllerAt(0).compositionWidth;
			atLineMiddleInternal(1, width, height, Float.LEFT);
			_textFlow.flowComposer.updateAllControllers();
		}
		
		public function atControllerEnd():void
		{
			// Float at the end of a scrollable container should appear in the container even if it
			// would otherwise be too tall.
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			controller.verticalScrollPolicy = ScrollPolicy.ON;
			var width:Number = 50;
			var height:Number = controller.compositionHeight + 50;
			if (verticalText)
			{
				width = controller.compositionWidth + 50;
				height = 50;
			}

			var secondPara:ParagraphElement = _textFlow.getChildAt(1) as ParagraphElement;
			var floatPosition:int = secondPara.getAbsoluteStart();
			var floatObject:DisplayObject = addFloatAtPosition(floatPosition, width, height, Float.START);
			_textFlow.flowComposer.updateAllControllers();
			assertTrue("Float should be in the container", controller.container.contains(floatObject));

			if (verticalText)
				controller.horizontalScrollPolicy = ScrollPolicy.OFF;
			else
				controller.verticalScrollPolicy = ScrollPolicy.OFF;
			_textFlow.flowComposer.updateAllControllers();
			assertTrue("Float should not be composed in the container", controller.absoluteStart + controller.textLength <= floatPosition);
			assertTrue("Float should not be displayed in the container", !controller.container.contains(floatObject));
			
			// Turning scrolling off changes the basic coordinate system
			if (verticalText)
				_disableBoundsCheck = true;
	}
		
		public function widerThanColumn():void
		{
			// Float is wider than the container. If the height of the float fits, and there are 
			// no preceeding floats, it should still go in the column, and overlap the adjacent 
			// columns
			setUpContainers(3);

			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;

			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var width:Number = controller.compositionWidth + 50;
			var height:Number = 100;
			if (verticalText)
			{
				width = 100;
				height = controller.compositionHeight + 50;
			}
			_textFlow.flowComposer.updateAllControllers();
			var contentBoundsTextOnly:Rectangle = controller.getContentBounds();

			var floatObject:DisplayObject = addFloatAtPosition(0, width, height, Float.START);
			verifyFloatInLine(0, width, height, Float.START, floatObject);
			_textFlow.flowComposer.updateAllControllers();
			var contentBoundsWithFloat:Rectangle = controller.getContentBounds();
			if (_textFlow.computedFormat.blockProgression == BlockProgression.RL)
			{
				assertTrue("Content bounds with a float wider than the column should be larger than content bounds with just text", contentBoundsWithFloat.height > contentBoundsTextOnly.height);
				assertTrue("Content bounds with a float should be equal to or greater than float alone", contentBoundsWithFloat.height >= height);
			}
			else
			{
				assertTrue("Content bounds with a float wider than the column should be larger than content bounds with just text", contentBoundsWithFloat.width > contentBoundsTextOnly.width);
				assertTrue("Content bounds with a float should be equal to or greater than float alone", contentBoundsWithFloat.width >= width);
			}
			
			// Check that if the float protrudes past the text it's factored into the content height
			SelManager.deleteText(new SelectionState(_textFlow, 50, int.MAX_VALUE));		// delete so there's not so much text
			_textFlow.flowComposer.updateAllControllers();
			var contentBoundsAfterDelete:Rectangle = controller.getContentBounds();
			if (_textFlow.computedFormat.blockProgression == BlockProgression.RL)
			{
				assertTrue("Content bounds doesn't include logical height of float", contentBoundsAfterDelete.width >= width);
			}
			else
			{
				assertTrue("Content bounds doesn't include height of float", contentBoundsAfterDelete.height >= height);
			}
			SelManager.undo();		// undo the delete of the text
			
			// Resize the first container smaller, so the float goes overset
			if (verticalText)
				controller.setCompositionSize(width - 1, controller.compositionHeight);
			else
				controller.setCompositionSize(controller.compositionWidth, height - 1);
			_textFlow.flowComposer.updateAllControllers();
			var secondController:ContainerController = _textFlow.flowComposer.getControllerAt(1);
			assertTrue("Expected the float to get pushed to second container", secondController.absoluteStart == 0);
			assertTrue("Float should be in the second container", secondController.container.contains(floatObject));

			// Try it again with columns instead of containers -- should be the same
			setUpContainers(1);
			controller = _textFlow.flowComposer.getControllerAt(0);
			controller.columnCount = 3;
			verifyFloatInLine(0, width, height, Float.START, floatObject);
			
			// Make the first float smaller, and add a second large float afterwards
			var inlineElement:InlineGraphicElement = _textFlow.findLeaf(0) as InlineGraphicElement;
			inlineElement.width = 50;
			inlineElement.height = 50;
			var secondFloat:DisplayObject = addFloatAtPosition(4, width, height, Float.START);
			_textFlow.flowComposer.updateAllControllers();
			assertTrue("Second float should not appear on the first line", verticalText ? (secondFloat.parent.x < floatObject.parent.x) : (secondFloat.parent.y > floatObject.parent.y));
			assertTrue("Second float should be in the container", controller.container.contains(secondFloat));
		}
		
		public function widerThanColumnScroll():void		// Watson 2762393
		{
			// Float is wider than the container. If any part of the float is visible, the 
			// float should appear in the container. Width of float should be counted in 
			// the contentWidth.

			
			var xml:XML =
				<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>							
					<span fontSize="20">Hello, Dear Guest,</span>
					<p></p>
					<p><span>Donec sed risus nec risus elementum cursus eget non nulla. Integer dui mauris, lobortis at varius quis, elementum at justo. Ut lacinia arcu vitae ipsum pulvinar feugiat a ut risus. Vivamus nulla nisi, varius vitae commodo ut, volutpat quis magna. Cras posuere quam magna. Aenean felis purus, pellentesque nec fringilla id, dignissim quis elit. Praesent velit libero, laoreet quis dignissim id, varius quis neque. Suspendisse vulputate placerat purus. Fusce euismod fringilla ornare. Nulla et urna est. Proin a tellus et tortor feugiat iaculis.</span></p>
					<p><span>Donec sed risus nec risus elementum cursus eget non nulla. Integer dui mauris, lobortis at varius quis, elementum at justo. Ut lacinia arcu vitae ipsum pulvinar feugiat a ut risus. Vivamus nulla nisi, varius vitae commodo ut, volutpat quis magna. Cras posuere quam magna. Aenean felis purus, pellentesque nec fringilla id, dignissim quis elit. Praesent velit libero, laoreet quis dignissim id, varius quis neque. Suspendisse vulputate placerat purus. Fusce euismod fringilla ornare. Nulla et urna est. Proin a tellus et tortor feugiat iaculis.</span></p>
					<p><span>Donec sed risus nec risus elementum cursus eget non nulla. Integer dui mauris, lobortis at varius quis, elementum at justo. Ut lacinia arcu vitae ipsum pulvinar feugiat a ut risus. Vivamus nulla nisi, varius vitae commodo ut, volutpat quis magna. Cras posuere quam magna. Aenean felis purus, pellentesque nec fringilla id, dignissim quis elit. Praesent velit libero, laoreet quis dignissim id, varius quis neque. Suspendisse vulputate placerat purus. Fusce euismod fringilla ornare. Nulla et urna est. Proin a tellus et tortor feugiat iaculis.</span></p>
					<p><span>Donec sed risus nec risus elementum cursus eget non nulla. Integer dui mauris, lobortis at varius quis, elementum at justo. Ut lacinia arcu vitae ipsum pulvinar feugiat a ut risus. Vivamus nulla nisi, varius vitae commodo ut, volutpat quis magna. Cras posuere quam magna. Aenean felis purus, pellentesque nec fringilla id, dignissim quis elit. Praesent velit libero, laoreet quis dignissim id, varius quis neque. Suspendisse vulputate placerat purus. Fusce euismod fringilla ornare. Nulla et urna est. Proin a tellus et tortor feugiat iaculis.</span></p>
					<p><span>Donec sed risus nec risus elementum cursus eget non nulla. Integer dui mauris, lobortis at varius quis, elementum at justo. Ut lacinia arcu vitae ipsum pulvinar feugiat a ut risus. Vivamus nulla nisi, varius vitae commodo ut, volutpat quis magna. Cras posuere quam magna. Aenean felis purus, pellentesque nec fringilla id, dignissim quis elit. Praesent velit libero, laoreet quis dignissim id, varius quis neque. Suspendisse vulputate placerat purus. Fusce euismod fringilla ornare. Nulla et urna est. Proin a tellus et tortor feugiat iaculis.</span></p>
					<p><span>Donec sed risus nec risus elementum cursus eget non nulla. Integer dui mauris, lobortis at varius quis, elementum at justo. Ut lacinia arcu vitae ipsum pulvinar feugiat a ut risus. Vivamus nulla nisi, varius vitae commodo ut, volutpat quis magna. Cras posuere quam magna. Aenean felis purus, pellentesque nec fringilla id, dignissim quis elit. Praesent velit libero, laoreet quis dignissim id, varius quis neque. Suspendisse vulputate placerat purus. Fusce euismod fringilla ornare. Nulla et urna est. Proin a tellus et tortor feugiat iaculis.</span></p>
					<p><span>Donec sed risus nec risus elementum cursus eget non nulla. Integer dui mauris, lobortis at varius quis, elementum at justo. Ut lacinia arcu vitae ipsum pulvinar feugiat a ut risus. Vivamus nulla nisi, varius vitae commodo ut, volutpat quis magna. Cras posuere quam magna. Aenean felis purus, pellentesque nec fringilla id, dignissim quis elit. Praesent velit libero, laoreet quis dignissim id, varius quis neque. Suspendisse vulputate placerat purus. Fusce euismod fringilla ornare. Nulla et urna est. Proin a tellus et tortor feugiat iaculis.</span></p>
					<p></p>
					<p></p>
					<p></p>
					<p><span>Donec sed risus nec risus elementum cursus eget non nulla. Integer dui mauris, lobortis at varius quis, elementum at justo. Ut lacinia arcu vitae ipsum pulvinar feugiat a ut risus. Vivamus nulla nisi, varius vitae commodo ut, volutpat quis magna. Cras posuere quam magna. Aenean felis purus, pellentesque nec fringilla id, dignissim quis elit. Praesent velit libero, laoreet quis dignissim id, varius quis neque. Suspendisse vulputate placerat purus. Fusce euismod fringilla ornare. Nulla et urna est. Proin a tellus et tortor feugiat iaculis.</span></p>
				</TextFlow>;
			
			initializeFlow(TextConverter.importToFlow(xml, TextConverter.TEXT_LAYOUT_FORMAT));
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;

			// Insert a float wider than the column into the empty second paragraph
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var width:Number = controller.compositionWidth + 100;
			var height:Number = controller.compositionHeight + 100;
			var floatPosition:int = _textFlow.getChildAt(1).getAbsoluteStart();
			var floatObject:DisplayObject = addFloatAtPosition(floatPosition, width, height, Float.END);
			_textFlow.flowComposer.updateAllControllers();
			
			verifyFloatInLine(floatPosition, width, height, Float.END, floatObject);
			assertTrue("Float should be visible", controller.container.contains(floatObject));

			var contentBoundsWithFloat:Rectangle = controller.getContentBounds();
			if (_textFlow.computedFormat.blockProgression == BlockProgression.RL)
			{
				assertTrue("Content bounds with a float wider than the column should be larger than content bounds with just text", contentBoundsWithFloat.height > controller.compositionHeight);
				assertTrue("Content bounds with a float should be equal to or greater than float alone", contentBoundsWithFloat.height >= height);
			}
			else
			{
				assertTrue("Content bounds with a float wider than the column should be larger than content bounds with just text", contentBoundsWithFloat.width > controller.compositionWidth);
				assertTrue("Content bounds with a float should be equal to or greater than float alone", contentBoundsWithFloat.width >= width);
			}
			
			controller.verticalScrollPosition = contentBoundsWithFloat.height;
			_textFlow.flowComposer.updateAllControllers();
	//		assertTrue("Float should not be visible", !controller.container.contains(floatObject));

			controller.verticalScrollPosition = 0;
			_textFlow.flowComposer.updateAllControllers();
			assertTrue("Float should be visible", controller.container.contains(floatObject));
			
		}
		
		public function floatOnly():void
		{
			// TextFlow contains only a single float, no text
			setUpFlow("");
			atParagraphStartInternal(_textFlow.getFirstLeaf(), 100, 100, Float.LEFT);
			
			// hittest (Watson 2617901)
			// In RTL, we're getting different results from the Player depending on Astro or Argo...
			if (_textFlow.computedFormat.direction == Direction.LTR || Configuration.playerEnablesArgoFeatures)
			{
				SelManager.selectRange(0, 0);
				_flowComposer.updateAllControllers();
				var controller:ContainerController = _flowComposer.getControllerAt(0);
				var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, 200, 200, controller.container, false, false, false, false);
				controller.container.dispatchEvent(mouseEvent);
				
				assertTrue("Expected insertion point after float", SelManager.absoluteStart == 1);
			}
			
		}
		
		public function inlineAndFloat():void
		{
			// Inline as first leaf, followed by float. Watson 2636066
			
			// TextFlow contains only a single float, no text
			setUpFlow("A");
			var inlineDO:DisplayObject = addFloatAtPosition(0, 100, 100, Float.NONE);
			var floatDO:DisplayObject = addFloatAtPosition(1, 100, 100, Float.LEFT);
			
		} 
		
		public function convertFloatToInline():void
		{
			var floatValueList:Array = [Float.LEFT, Float.RIGHT , Float.NONE, Float.START, Float.END ];	// start & end disabled to make tests run faster

			// Test switching the float type of an inline graphic element
			var floatValue:String = floatValueList[floatTypeList.length - 1];
			var secondParagraph:FlowElement = _textFlow.getChildAt(1);
			var floatPosition:int = secondParagraph.getAbsoluteStart();
			var floatObject:DisplayObject = addFloatAtPosition(floatPosition, 30, 30, floatValue);
			_textFlow.flowComposer.updateAllControllers();
			var inlineGraphicElement:InlineGraphicElement = _textFlow.findLeaf(floatPosition) as InlineGraphicElement;
			SelManager.selectRange(floatPosition, floatPosition + 1);
			for each (floatValue in floatValueList)
				SelManager.modifyInlineGraphic(inlineGraphicElement.source, inlineGraphicElement.width, inlineGraphicElement.height, floatValue);
		}
		
		public function verticalAlignInline():void
			// Make sure that vertical alignment (especially justification) is working correctly with inlines. See 2772554
		{
			// TextFlow contains a single line of text with an inline, should be centered vertically
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			setUpFlow("Vertical align with inlines test");

			// Check for middle
			var textFlowFormat:TextLayoutFormat = new TextLayoutFormat(_textFlow.format);
			textFlowFormat.verticalAlign = VerticalAlign.MIDDLE;
			_textFlow.format = textFlowFormat;
			var floatObject:DisplayObject = addFloatAtPosition(0, 100, 100, Float.NONE);
			_textFlow.flowComposer.updateAllControllers();

			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var bounds:Rectangle = floatObject.getBounds(controller.container);
			if (verticalText)
				assertTrue("Expected float would be in the middle of the container", Math.abs((controller.compositionWidth + bounds.x) - Math.abs(bounds.x + bounds.width)) < controller.compositionWidth * .1);
			else
				assertTrue("Expected float would be in the middle of the container", Math.abs((bounds.y + (bounds.height/2)) - (controller.compositionHeight / 2)) < controller.compositionHeight * .1);

			// Check for bottom. Leave a little wiggle room in this test because the inline is on the baseline and not against the bottom 
			textFlowFormat.verticalAlign = VerticalAlign.BOTTOM;
			_textFlow.format = textFlowFormat;
			_textFlow.flowComposer.updateAllControllers();
			bounds = floatObject.getBounds(controller.container);
			if (verticalText)
				assertTrue("Expected float would be in the bottom of the container", Math.abs(bounds.x + controller.compositionWidth) < 10);
			else
				assertTrue("Expected float would be in the bottom of the container", Math.abs(bounds.y + bounds.height - controller.compositionHeight) < 10);
			
			// Check for justify -- this needs multiple lines. Set alignment to TOP, check position, reset to JUSTIFY, position should have changed.
			setUpFlow("Vertical align with inlines test  dlfkj sdlk jsdlfkj sdlkfj dslkfj sdlkfj dlskfj dslkfj lkdsfj ldksfj dlksfj dslkfj dlskjfdslkjf lsdkjf lsdkfj sdlkfj sdlkfj dslkfj dslkfj sdlkfj dslkf jdslkfj sdlkfj sdlkfj ldskfj ldksfj lsdkfjldskfj lsdkfjdslkfj");
			textFlowFormat.verticalAlign = VerticalAlign.TOP;
			_textFlow.format = textFlowFormat;
			floatObject = addFloatAtPosition(0, 100, 100, Float.NONE);
			_textFlow.flowComposer.updateAllControllers();
			
			controller = _textFlow.flowComposer.getControllerAt(0);
			var topBounds:Rectangle = floatObject.getBounds(controller.container);
			
			textFlowFormat.verticalAlign = VerticalAlign.JUSTIFY;
			_textFlow.format = textFlowFormat;
			_textFlow.flowComposer.updateAllControllers();
			bounds = floatObject.getBounds(controller.container);
			assertTrue(!bounds.equals(topBounds), "Line should have been moved when vertical justification applied");
		}
		
		private function verticalAlignMiddle(content:String):void
		{
			// TextFlow contains a single line of text with a float, should be centered vertically
			// Floats extends past the text
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			setUpFlow(content);
			var textFlowFormat:TextLayoutFormat = new TextLayoutFormat(_textFlow.format);
			textFlowFormat.verticalAlign = VerticalAlign.MIDDLE;
			_textFlow.format = textFlowFormat;
			var floatObject:DisplayObject = addFloatAtPosition(0, 100, 100, Float.LEFT);
			_textFlow.flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = floatObject.parent;

			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			if (verticalText)
				assertTrue("Expected float would be in the middle of the container", Math.abs((controller.compositionWidth + floatHolder.x) - Math.abs(floatHolder.x + floatObject.width)) < controller.compositionWidth * .1);
			else
				assertTrue("Expected float would be in the middle of the container", Math.abs((floatHolder.y + (floatObject.height/2)) - (controller.compositionHeight / 2)) < controller.compositionHeight * .1);
		}
		
		public function verticalAlignMiddleFloatAtEnd():void
		{
			// TextFlow contains a single line of text with a float, should be centered vertically
			// Floats extends past the text
			verticalAlignMiddle("A");
		}
		
		public function verticalAlignMiddleTextAtEnd():void
		{
			// TextFlow contains a single line of text with a float, should be centered vertically
			// Text extends past the float
			verticalAlignMiddle("A\nBBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB ");
		}
		
		private function verticalAlignBottom(content:String):void
		{
			// TextFlow contains a single line of text with a float, should be on the bottom of the container
			// Floats extends past the text
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			setUpFlow(content);
			var textFlowFormat:TextLayoutFormat = new TextLayoutFormat(_textFlow.format);
			textFlowFormat.verticalAlign = VerticalAlign.BOTTOM;
			_textFlow.format = textFlowFormat;
			var floatObject:DisplayObject = addFloatAtPosition(0, 100, 100, Float.LEFT);
			_textFlow.flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = floatObject.parent;

			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			if (verticalText)
				assertTrue("Expected float would be in the bottom of the container", Math.abs(floatHolder.x + controller.compositionWidth) < 1);
			else
				assertTrue("Expected float would be in the bottom of the container", Math.abs(floatHolder.y + floatObject.height - controller.compositionHeight) < 1);
		}
		
		public function verticalAlignBottomFloat2636122():void
		{
			// test for bug 2636122 - very similar to verticalAlignBottom, but not quite
			
			// BoundsChecker fails on this because it sets verticalAlign on controller, BoundsChecker checks whole flow
			_disableBoundsCheck = true;
			
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			setUpFlow("A");
			_textFlow.flowComposer.updateAllControllers();
			var floatObject:DisplayObject = addFloatAtPosition(1, 100, 100, Float.LEFT);
			_textFlow.flowComposer.updateAllControllers();
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var textFlowFormat:TextLayoutFormat = new TextLayoutFormat(controller.format);
			textFlowFormat.verticalAlign = VerticalAlign.BOTTOM;
			controller.format = textFlowFormat;
			_textFlow.flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = floatObject.parent;
			
			if (verticalText)
				assertTrue("Expected float would be in the bottom of the container", Math.abs(floatHolder.x + controller.compositionWidth) < 1);
			else
				assertTrue("Expected float would be in the bottom of the container", Math.abs(floatHolder.y + floatObject.height - controller.compositionHeight) < 1);
			var tfl:TextFlowLine = _textFlow.flowComposer.getLineAt(0);
			if (verticalText)
				assertTrue("Expected line would be in the bottom of the container", Math.abs((tfl.x + tfl.height) - (floatHolder.x + floatHolder.width)) < 1);
			else
				assertTrue("Expected line would be in the bottom of the container", Math.abs(tfl.y + floatObject.height - controller.compositionHeight) < 1);
			
		}
		
		public function verticalAlignBottomFloatAtEnd():void
		{
			// TextFlow contains a single line of text with a float, should be centered vertically
			// Floats extends past the text
			verticalAlignBottom("A");
		}
		
		public function verticalAlignBottomTextAtEnd():void
		{
			// TextFlow contains a single line of text with a float, should be centered vertically
			// Text extends past the float
			verticalAlignBottom("A\nBBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB BBB ");
		}
		
		private function getCompositionResults(verticalText:Boolean, flowComposer:IFlowComposer):Array
		{
			var linePos:Array = [];
			var numLines:int = flowComposer.numLines;
			for  (var i:int = 0; i < numLines; ++i)
			{
				var line:TextFlowLine = flowComposer.getLineAt(i);
				linePos.push(verticalText ? line.x : line.y);
			}
			return linePos;
		}
		
		private function assertCompositionMatches(oldLineArray:Array, newLineArray:Array):void
		{
			assertTrue("Expected same composition, found different line count", oldLineArray.length == newLineArray.length);
			for  (var i:int = 0; i < oldLineArray.length; ++i)
			{
				assertTrue("Expected same composition, found line " + i.toString() + "moved in logical vertical direction", oldLineArray[i] == newLineArray[i]);
			}
		}
		public function noVJ():void
		{
			// We expect that verticalAlign = justify in the presence of floats is identical to verticalAlign = top (i.e.
			// the verticalAlign is ignored.
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			var flowComposer:IFlowComposer = _textFlow.flowComposer;
			var line:TextFlowLine;
			atLineMiddleInternal(1, 100, 100, Float.LEFT);			
			flowComposer.updateAllControllers();
			var oldLinePos:Array = getCompositionResults(verticalText, flowComposer);
			
			var textFlowFormat:TextLayoutFormat = new TextLayoutFormat(_textFlow.format);
			textFlowFormat.verticalAlign = VerticalAlign.JUSTIFY;
			_textFlow.format = textFlowFormat;
			flowComposer.updateAllControllers();
			var newLinePos:Array = getCompositionResults(verticalText, flowComposer);

			assertCompositionMatches(oldLinePos, newLinePos);
		}

		private function textAlignRight(pos:int):void
		{
			// Test that right-aligned floats do not overlap right aligned lines
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			var textFlowFormat:TextLayoutFormat = new TextLayoutFormat(_textFlow.format);
			textFlowFormat.textAlign = TextAlign.RIGHT;
			_textFlow.format = textFlowFormat;
			var floatObject:DisplayObject = addFloatAtPosition(pos, 100, 100, Float.RIGHT);
			_textFlow.flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = floatObject.parent;
			
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var lineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(pos);
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex + 1);
			var textLine:TextLine 
			var bbox:Rectangle = textFlowLine.getBounds();
			if (verticalText)
				assertTrue("Expected float would not overlap text", floatHolder.y >= textFlowLine.y + bbox.width);
			else
				assertTrue("Expected float would not overlap text", Math.abs(floatHolder.x - (textFlowLine.x + bbox.width)) < 2);
		}
		
		public function textAlignRightAtStart():void
		{
			textAlignRight(0);
		}
		
		public function textAlignRightInMiddle():void
		{
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(3);

			textAlignRight(textFlowLine.absoluteStart + textFlowLine.textLength/2);
		}
		
		private const INDENT_AMOUNT:Number = 20;

		public function leftIndent():void
		{
			// Test that floats in indented paragraphs are indented
			
			// Try a left float with a start indent
			var leaf:FlowLeafElement = _textFlow.getFirstLeaf();
			var firstPara:ParagraphElement = leaf.getParagraph();
			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat(firstPara.format);
			if (firstPara.computedFormat.direction == Direction.LTR)
				paragraphFormat.paragraphStartIndent = INDENT_AMOUNT;
			else
				paragraphFormat.paragraphEndIndent = INDENT_AMOUNT;
			paragraphFormat.textAlign = TextAlign.JUSTIFY;
			firstPara.format = paragraphFormat;
			var floatObject:DisplayObject = addFloatAtPosition(200, 100, 100, Float.LEFT);
			_textFlow.flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = floatObject.parent;
			
			if (_textFlow.computedFormat.blockProgression == BlockProgression.RL)
				assertTrue("Expected float to be indented with paragraph", floatHolder.y == INDENT_AMOUNT);
			else
				assertTrue("Expected float to be indented with paragraph", floatHolder.x == INDENT_AMOUNT);
		}

		public function rightIndent():void
		{
			// Test that floats in indented paragraphs are indented
			
			// Try a right float with a right indent
			var leaf:FlowLeafElement = _textFlow.getFirstLeaf();
			var firstPara:ParagraphElement = leaf.getParagraph();
			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat(firstPara.format);
			if (firstPara.computedFormat.direction == Direction.RTL)
				paragraphFormat.paragraphStartIndent = INDENT_AMOUNT;
			else
				paragraphFormat.paragraphEndIndent = INDENT_AMOUNT;
			paragraphFormat.textAlign = TextAlign.JUSTIFY;
			firstPara.format = paragraphFormat;
			var floatObject:DisplayObject = addFloatAtPosition(200, 100, 100, Float.RIGHT);
			_textFlow.flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = floatObject.parent;
			
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			if (_textFlow.computedFormat.blockProgression == BlockProgression.RL)
				assertTrue("Expected float to be indented with paragraph", Math.abs((floatHolder.y + floatObject.height) - (controller.compositionHeight - INDENT_AMOUNT)) < 1);
			else
				assertTrue("Expected float to be indented with paragraph", Math.abs((floatHolder.x + floatObject.width) - (controller.compositionWidth - INDENT_AMOUNT)) < 1);
		}
		
		public function leftBigIndent():void
		{
			var indentAmount:Number = 200;  // bigger than float width
			
			// Add a float, and check that a paragraph with a big indent will wrap to the max of the indent & float
			var leaf:FlowLeafElement = _textFlow.getLastLeaf();
			var secondPara:ParagraphElement = leaf.getParagraph();
			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat(secondPara.format);
			if (secondPara.computedFormat.direction == Direction.LTR)
				paragraphFormat.paragraphStartIndent = indentAmount;
			else
				paragraphFormat.paragraphEndIndent = indentAmount;
			paragraphFormat.textAlign = TextAlign.JUSTIFY;
			secondPara.format = paragraphFormat;
			
			var floatObject:DisplayObject = addFloatAtPosition(200, 100, 100, Float.LEFT);
			_textFlow.flowComposer.updateAllControllers();
			
			var lineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(secondPara.getAbsoluteStart());
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			var bbox:Rectangle = textFlowLine.getBounds();
			if (secondPara.computedFormat.direction == Direction.LTR)
			{
				if (_textFlow.computedFormat.blockProgression == BlockProgression.RL)
					assertTrue("Expected line in second paragraph to have large indent", bbox.top == indentAmount);
				else
					assertTrue("Expected line in second paragraph to have large indent", bbox.left == indentAmount);
			}
		}

		public function rightBigIndent():void
		{
			var indentAmount:Number = 200;  // bigger than float width
			
			// Add a float, and check that a paragraph with a big indent will wrap to the max of the indent & float
			var leaf:FlowLeafElement = _textFlow.getLastLeaf();
			var secondPara:ParagraphElement = leaf.getParagraph();
			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat(secondPara.format);
			if (secondPara.computedFormat.direction == Direction.LTR)
				paragraphFormat.paragraphEndIndent = indentAmount;
			else
				paragraphFormat.paragraphStartIndent = indentAmount;
			paragraphFormat.textAlign = TextAlign.JUSTIFY;
			secondPara.format = paragraphFormat;
			
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var floatObject:DisplayObject = addFloatAtPosition(200, 100, 100, Float.RIGHT);
			_textFlow.flowComposer.updateAllControllers();
			
			var lineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(secondPara.getAbsoluteStart());
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			var bbox:Rectangle = textFlowLine.getBounds();
			if (_textFlow.computedFormat.blockProgression == BlockProgression.RL)
				assertTrue("Expected line in second paragraph to have large indent", Math.abs(bbox.bottom - (controller.compositionHeight - indentAmount)) < 1);
			else
				assertTrue("Expected line in second paragraph to have large indent", Math.abs(bbox.right - (controller.compositionWidth - indentAmount)) < 1);
		}
		
		public function clearNoPrecedingFloatAll():void
		{
			clearAll(clearNoPrecedingFloat, 0);
		}
		
		private function clearNoPrecedingFloat(clear:String, floatCount:int):void
		{
			var indentAmount:Number = 200;  
			var leaf:FlowLeafElement = _textFlow.getLastLeaf();
			var secondPara:ParagraphElement = leaf.getParagraph();
			_textFlow.flowComposer.updateAllControllers();
			if (_textFlow.computedFormat.blockProgression == BlockProgression.RL)
				var secondPara_x:int = secondPara.getAbsoluteStart();
			else
				var secondPara_y:int = secondPara.getAbsoluteStart();
			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat(secondPara.format);
			paragraphFormat.clearFloats = clear;
			if (secondPara.computedFormat.direction == Direction.LTR)
				paragraphFormat.paragraphEndIndent = indentAmount;
			else
				paragraphFormat.paragraphStartIndent = indentAmount;
			paragraphFormat.textAlign = TextAlign.JUSTIFY;
			secondPara.format = paragraphFormat;
			
			_textFlow.flowComposer.updateAllControllers();
			
			if (_textFlow.computedFormat.blockProgression == BlockProgression.RL)
				assertTrue("Second paragraph should not be impacted by clear", secondPara_x == secondPara.getAbsoluteStart());
			else
				assertTrue("Second paragraph should not be impacted by clear", secondPara_y == secondPara.getAbsoluteStart());
		}
		
		public function leftIndentWithTab():void
		{
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("\tThis is test");
			_textFlow.flowComposer.updateAllControllers();
			
			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat(_textFlow.format);
			var leaf:FlowLeafElement = _textFlow.getFirstLeaf();
			var firstPara:ParagraphElement = leaf.getParagraph();
			if (firstPara.computedFormat.direction == Direction.LTR)
				paragraphFormat.paragraphStartIndent = INDENT_AMOUNT;
			else
				paragraphFormat.paragraphEndIndent = INDENT_AMOUNT;
			paragraphFormat.textAlign = TextAlign.JUSTIFY;
			firstPara.format = paragraphFormat;
			
			var floatObject:DisplayObject = addFloatAtPosition(0, 100, 100, Float.LEFT);
			paragraphFormat.tabStops = "e318";
			SelManager.applyParagraphFormat(paragraphFormat);
			_textFlow.flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = floatObject.parent;
			
			var paragraph:ParagraphElement = _textFlow.getFirstLeaf().getParagraph();
			var posStart:int = paragraph.getAbsoluteStart();
			var lineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(posStart);
			var tfl:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			
			if (verticalText)
				assertTrue("Expected float to be indented with paragraph", floatHolder.x <= tfl.x);
			else
				assertTrue("Expected float to be indented with paragraph", floatHolder.y <= tfl.y);
		}
		
		public function rightIndentWithTab():void
		{
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("\tThis is test");
			_textFlow.flowComposer.updateAllControllers();
			
			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat(_textFlow.format);
			var leaf:FlowLeafElement = _textFlow.getFirstLeaf();
			var firstPara:ParagraphElement = leaf.getParagraph();
			
			if (firstPara.computedFormat.direction == Direction.RTL)
				paragraphFormat.paragraphStartIndent = INDENT_AMOUNT;
			else
				paragraphFormat.paragraphEndIndent = INDENT_AMOUNT;
			paragraphFormat.textAlign = TextAlign.JUSTIFY;
			firstPara.format = paragraphFormat;
			var floatObject:DisplayObject = addFloatAtPosition(5, 100, 100, Float.RIGHT);
			paragraphFormat.tabStops = "e300";
			SelManager.applyParagraphFormat(paragraphFormat);
			_textFlow.flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = floatObject.parent;
			
			var paragraph:ParagraphElement = _textFlow.getFirstLeaf().getParagraph();
			var posStart:int = paragraph.getAbsoluteStart();
			var lineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(posStart);
			var tfl:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			
			if (verticalText)
				assertTrue("Expected float to be indented with paragraph",  (floatHolder.y >= (tfl.y + tfl.textLength)));
			else
				assertTrue("Expected float to be indented with paragraph", (( tfl.x+ tfl.textLength )<= floatHolder.x ));
		}
		
		private function stackedLeftRightFloats(float:String):void
		{
			var width:Number = 100;
			var height:Number = 100;
			
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("AAAAAAAAAAAAAAAAAAAAAA\n");
			SelManager.insertText("BBBBBBBBBBBBBBBBBBBBBB\n");
			_textFlow.flowComposer.updateAllControllers();
			
			var tlf1:TextFlowLine = _textFlow.flowComposer.getLineAt(1);
			var tlf2:TextFlowLine = _textFlow.flowComposer.getLineAt(2);
			
			var pos1:int = tlf1.absoluteStart;
			var floatObject1:DisplayObject = addFloatAtPosition(pos1, width, height, float);
			var pos2:int = tlf2.absoluteStart;
			var floatObject2:DisplayObject = addFloatAtPosition(pos2, width, height, float);
			
			verifyFloatInLine(pos1, width, height, float, floatObject1);
			verifyFloatInLine(pos2, width, height, float, floatObject2);
		}
		
		public function stackedLeftFloats():void
		{
			var float:String = "left";
			stackedLeftRightFloats(float); 
		}
		
		public function stackedRightFloats():void
		{	
			var float:String = "right";
			stackedLeftRightFloats(float);
		}
		
		private var clearArray:Array = [ ClearFloats.LEFT, ClearFloats.RIGHT, ClearFloats.BOTH, ClearFloats.START, ClearFloats.END ];
		private function clearAll(method:Function, floatCount:int):void
		{
			for each (var content:String in contentLanguageList)
			{
				for each (var clearValue:String in clearArray)
				{
					setUpFlow(content);
					method(clearValue, floatCount);
				}
			}
		}
		
		public function clearOneAll():void
		{
			clearAll(clearFloatTest, 1);
		}

		
		public function clearTwoAll():void
		{
			clearAll(clearFloatTest, 2);
		}
		
		private function clearFloatTest(clear:String, floatCount:int):void
		{
			var indentAmount:Number = 200;  // bigger than float width
			
			// Add a float, and check that a paragraph with a big indent will wrap to the max of the indent & float
			var leaf:FlowLeafElement = _textFlow.getLastLeaf();
			var secondPara:ParagraphElement = leaf.getParagraph();
			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat(secondPara.format);
			paragraphFormat.clearFloats = clear;
			paragraphFormat.textAlign = TextAlign.JUSTIFY;
			secondPara.format = paragraphFormat;

			var floatAttr:String = (clear == ClearFloats.LEFT) || (clear == ClearFloats.START) ? Float.LEFT : Float.RIGHT;
			if (_textFlow.computedFormat.direction == Direction.RTL)
			{
				if (clear == ClearFloats.START) floatAttr = Float.RIGHT;
				if (clear == ClearFloats.END) floatAttr = Float.LEFT;
			}
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var floatObject:DisplayObject = addFloatAtPosition(200, 100, 100, floatAttr);
			if (floatCount == 2)
			{
				floatObject = addFloatAtPosition(200, 100, 100, floatAttr);
			}
			_textFlow.flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = floatObject.parent;
			
			var lineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(secondPara.getAbsoluteStart());
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			var bbox:Rectangle = textFlowLine.getBounds();
			
			if (_textFlow.computedFormat.blockProgression == BlockProgression.RL)
			{
				assertTrue("ClearFloat:" + clear + " - Second paragraph should be cleared past float " + floatCount, bbox.x + bbox.width < floatHolder.x);
			}
			else
			{
				assertTrue("ClearFloat:" + clear + " - Second paragraph should be cleared past float " + floatCount, bbox.top > floatHolder.y + floatObject.height);
			}
		}
		
		public function paddingAndMarginsInternal(float:String, width:Number, height:Number, paddingLeft:Number, paddingTop:Number, paddingRight:Number, paddingBottom:Number):void
		{
			var verticalText:Boolean = (_textFlow.computedFormat.blockProgression == BlockProgression.RL);
			var graphic:DisplayObject = addFloatAtPosition(0, width, height, float);
			var ilgElement:InlineGraphicElement = _textFlow.findLeaf(0) as InlineGraphicElement;
			var format:TextLayoutFormat = new TextLayoutFormat(ilgElement.format);
			format.paddingLeft = paddingLeft;
			format.paddingTop = paddingTop;
			format.paddingRight = paddingRight;
			format.paddingBottom = paddingBottom;
			ilgElement.format = format;
			format = new TextLayoutFormat(_textFlow.format);
			format.textAlign = TextAlign.JUSTIFY;
			_textFlow.format = format;
			_flowComposer.updateAllControllers();
			var floatHolder:DisplayObjectContainer = graphic.parent;
			assertTrue("Expected to get inline inserted", ilgElement != null);
			var tfl:TextFlowLine = _flowComposer.getLineAt(0);
			assertTrue("Expected padding between container edge and float", Math.abs(paddingTop - floatHolder.y) <= 1);
			if (verticalText)
			{
				assertTrue("Expected padding between float and text", Math.abs(floatHolder.y + graphic.height + paddingBottom - tfl.y) <= 1);
				assertTrue("Expected padding between container edge and float", Math.abs(paddingRight + (floatHolder.x + graphic.width)) <= 1);
			}
			else
			{
				assertTrue("Expected padding between float and text", Math.abs(floatHolder.x + graphic.width + paddingRight - tfl.x) <= 1);
				assertTrue("Expected padding between container edge and float", Math.abs(paddingLeft - floatHolder.x) <= 1);
			}
			
		}
		
		public function negativePaddingAndMargins():void
		{
			_disableBoundsCheck = true;
			paddingAndMarginsInternal(Float.LEFT, 100, 100, -5, -10, -8, -12);
		}
		
		public function paddingAndMargins():void
		{
			paddingAndMarginsInternal(Float.LEFT, 100, 100, 20, 30, 40, 50);
		}
		
		public function lineHeightIgnoredOnFloatingImages():void
		{
			// LineHeight is supposed to be ignored on floating images when calculating line positions. Check that this is so.
			// Insert a float at the start of the paragraph, and set lineheight on it. 
			var secondParagraph:ParagraphElement = _textFlow.getChildAt(1) as ParagraphElement;
			var floatPosition:int = secondParagraph.getAbsoluteStart();
			var floatObject:DisplayObject = addFloatAtPosition(floatPosition, 10, 10, Float.START);
			verifyFloatInLine(floatPosition, 10, 10, Float.START, floatObject);
			var lineIndex:int =  _textFlow.flowComposer.findLineIndexAtPosition(floatPosition + 1);
			var textFlowLine:TextFlowLine =_textFlow.flowComposer.getLineAt(lineIndex);
			var verticalText:Boolean = (_textFlow.computedFormat.blockProgression == BlockProgression.RL);
			var originalPosition:Number = verticalText ? textFlowLine.x : textFlowLine.y;
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var originalContentBounds:Rectangle = new Rectangle(controller.contentLeft, controller.contentTop, controller.contentWidth, controller.contentHeight);
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.lineHeight = 100;
			SelManager.selectRange(floatPosition, floatPosition + 1);
			SelManager.applyLeafFormat(format);
			lineIndex =  _textFlow.flowComposer.findLineIndexAtPosition(floatPosition + 1);
			textFlowLine =_textFlow.flowComposer.getLineAt(lineIndex);
			assertTrue("TextLine moved when lineHeight applied to floating graphic", originalPosition == (verticalText ? textFlowLine.x : textFlowLine.y));
			var contentBounds:Rectangle = new Rectangle(controller.contentLeft, controller.contentTop, controller.contentWidth, controller.contentHeight);
			assertTrue("Content bounds changed when lineHeight applied to floating graphic", contentBounds.equals(originalContentBounds));
		}
		
		private function setUpContainers(containerCount:int):void
		{
			testApp.changeContainerSetup("arrangeSideBySide", 0, containerCount);	
		}
		
		public function smallFloatBigText():void
		{
			// Test case where there is a small initial (leading) float that fits in the container, and a larger line of text that 
			// gets pushed to the following container. Both the float and the line should get pushed to the following container.
			try {
				setUpContainers(2);
				format = new TextLayoutFormat();
				format.fontSize = 14;
				format.paragraphSpaceAfter = 15;
				format.fontFamily = "Times New Roman"; 
				SelManager.applyFormatToElement(_textFlow, format);

				_textFlow.flowComposer.updateAllControllers();
				var secondControllerStart:int = _textFlow.flowComposer.getControllerAt(1).absoluteStart;
				var floatObject:DisplayObject = addFloatAtPosition(secondControllerStart - 10, 10, 10, _textFlow.computedFormat.direction == Direction.RTL ? Float.RIGHT : Float.LEFT);
				_textFlow.interactionManager.selectRange(secondControllerStart - 9 , secondControllerStart - 8);
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.fontSize = 36;
				SelManager.applyLeafFormat(format);
				
				// Float should appear in the top of the second container
				var secondController:ContainerController = _textFlow.flowComposer.getControllerAt(1);
				var verticalText:Boolean = _textFlow.computedFormat.blockProgression == BlockProgression.RL;
				assertTrue("Float should appear in the second container", secondController.container.contains(floatObject));
				var inlineHolder:DisplayObject = floatObject.parent;
				assertTrue("Float should appear at the top of the container", verticalText ? (inlineHolder.x == -inlineHolder.width) : (inlineHolder.y == 0)); 
			}
			finally {
				//setUpContainers(1);
			}
		}
		
		public function cursorByAnchor():void
		{
			// Blinking text cursor should be placed by the anchor point and sized to the line 
			// NOT put next to the float and sized to the float -- see bug 2609350
			
			var secondParagraph:ParagraphElement = _textFlow.getChildAt(1) as ParagraphElement;
			var floatPosition:int = secondParagraph.getAbsoluteStart();
			var floatObject:DisplayObject = addFloatAtPosition(floatPosition, 30, 30, Float.START);
			
			// Turn on the blinking cursor
			_textFlow.interactionManager.focusedSelectionFormat = new SelectionFormat(0xffffff, 1.0, "difference", 0xffffff, 1.0, "difference", 500);
			
			_textFlow.interactionManager.selectRange(floatPosition, floatPosition);
			_textFlow.flowComposer.updateAllControllers();
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var selectionSprite:DisplayObjectContainer = controller.getSelectionSprite(false);
			assertTrue("Expected there to be a blinking cursor selection drawn", selectionSprite != null);
			var cursorBounds:Rectangle = selectionSprite.getBounds(controller.container);
			var lineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(floatPosition);
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			var textLine:TextLine = textFlowLine.getTextLine();
			var atomIndex:int = textLine.getAtomIndexAtCharIndex(floatPosition - secondParagraph.getAbsoluteStart());
			var atomBounds:Rectangle = textLine.getAtomBounds(atomIndex);
			var atomTopLeft:Point = textLine.localToGlobal(atomBounds.topLeft);
			var atomBottomRight:Point = textLine.localToGlobal(atomBounds.bottomRight);
			atomTopLeft = selectionSprite.parent.globalToLocal(atomTopLeft);
			atomBottomRight = selectionSprite.parent.globalToLocal(atomBottomRight);
			atomBounds.topLeft = atomTopLeft;
			atomBounds.bottomRight = atomBottomRight;
			
			var verticalText:Boolean = _textFlow.computedFormat.blockProgression == BlockProgression.RL;
			if (verticalText)
			{
				assertTrue("Expected logical left edge of cursor to align with anchor's atom bounds left", Math.abs(cursorBounds.top - atomBounds.top) < 1);
				assertTrue("Expected logical height of cursor to align with anchor's atom height", Math.abs(cursorBounds.width - textFlowLine.height) < 1);
			}
			else
			{
				assertTrue("Expected left edge of cursor to align with anchor's atom bounds left", Math.abs(cursorBounds.left - atomBounds.left) < 1);
				assertTrue("Expected height of cursor to align with anchor's atom height", Math.abs(cursorBounds.height - textFlowLine.height) < 1);
			}
		}
		
		public function insertTextBeforeFloat():void
		{
			// Test for unreported bug that is caused by retrying lines in composition (backing up to retry floats) and reusing TextLines.
			// Bug is now fixed, this tests the fix.
			
			// Insert a float about 2/3 way along the second line
			_textFlow.flowComposer.updateAllControllers();
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(1);
			var floatPosition:int = textFlowLine.absoluteStart + ((textFlowLine.textLength * 2) / 3);
			var floatObject:DisplayObject = addFloatAtPosition(floatPosition, 100, 100, Float.RIGHT);
			
			// Start editing in the previous line, about half way along
			textFlowLine = _textFlow.flowComposer.getLineAt(0);
			var editPosition:int = textFlowLine.absoluteStart + (textFlowLine.textLength / 2);
			SelManager.selectRange(editPosition, editPosition);
			SelManager.allowDelayedOperations = false;
			for (var i:int = 0; i < 100; ++i)
			{
				SelManager.insertText("x");
				SelManager.insertText(" ");
			}
		}
		
		public function textIndentAfterFloat():void
		{
			var textIndentValue:int = 50;
			var leaf:FlowLeafElement = _textFlow.getFirstLeaf();
			var firstPara:ParagraphElement = leaf.getParagraph();
			var format:TextLayoutFormat = new TextLayoutFormat(firstPara.format);
			format.textIndent = textIndentValue;
			firstPara.format = format;
			var floatObject:DisplayObject = addFloatAtPosition(0, 100, 100, Float.START);
			_textFlow.flowComposer.updateAllControllers();

			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(0);
			var textLine:TextLine = textFlowLine.getTextLine();
			var verticalText:Boolean = _textFlow.computedFormat.blockProgression == BlockProgression.RL;
			if (!verticalText)
			{
				if (firstPara.computedFormat.direction == Direction.LTR)
					assertTrue("There should be 50 pixel indent between float and text", Math.abs(floatObject.parent.x + floatObject.width + textIndentValue - textLine.x) < 1);
				else
					assertTrue("There should be 50 pixel indent between float and text", Math.abs(floatObject.parent.x - textIndentValue - (textFlowLine.x + textLine.textWidth)) < 1);
			}
			else
				assertTrue("There should be 50 pixel indent between float and text", Math.abs(floatObject.parent.y + floatObject.height + textIndentValue - textLine.y) < 1);
			
			// Check that we still get the indent even if the text is pushed to the next line
			_textFlow.interactionManager.selectRange(0, 1);
			EditManager(_textFlow.interactionManager).deleteText();
			floatObject = addFloatAtPosition(0, 400, 400, Float.START);
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			if (!verticalText)
				controller.setCompositionSize(428, controller.compositionHeight);
			else
				controller.setCompositionSize(controller.compositionWidth, 434);
			_textFlow.flowComposer.updateAllControllers();
			textFlowLine = _textFlow.flowComposer.getLineAt(0);
			textLine = textFlowLine.getTextLine();
			if (!verticalText)
			{
				if (firstPara.computedFormat.direction == Direction.LTR)
					assertTrue("There should be 50 pixel indent before 1st line of text", Math.abs(textIndentValue - textLine.x) < 1);
				else
					assertTrue("There should be 50 pixel indent before 1st line of text", Math.abs(controller.compositionWidth - textIndentValue - (textFlowLine.x + textLine.textWidth)) < 1);
			}
			else
				assertTrue("There should be 50 pixel indent before 1st line of text", Math.abs(textIndentValue - textLine.y) < 1);
		}
		
		public function resizeControllerWithFloats():void
		{
			// Repeatedly recompose the text to different bounds
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var maxWidth:Number = controller.compositionWidth;
			var maxHeight:Number = controller.compositionHeight;
			var iterations:int = 200;
			
			// Add a bunch of floats to the text
			addFloatAtPosition(0, 100, 100, Float.LEFT);
			addFloatAtPosition(30, 30, 60, Float.RIGHT);
			addFloatAtPosition(45, 90, 40, Float.RIGHT);
			addFloatAtPosition(80, 50, 50, Float.LEFT);
			addFloatAtPosition(300, 100, 100, Float.LEFT);
			addFloatAtPosition(400, 80, 4, Float.LEFT);
			_textFlow.flowComposer.updateAllControllers();
			
			var newWidth:Number = maxWidth;
			var newHeight:Number = maxHeight;
			var deltaWidth:Number = maxWidth / iterations;
			var deltaHeight:Number = maxHeight / iterations;
			for (var i:int = 0; i < iterations; ++i)
			{
				newWidth -= deltaWidth;
				newHeight -= deltaHeight;
				controller.setCompositionSize(newWidth, newHeight);
				_textFlow.flowComposer.updateAllControllers();
			}
		}
		
		public function composeAcrossControllers():void		// 2661626
		{
			_textFlow.interactionManager.selectAll();
			_editManager.deleteText();
			_editManager.insertText("kldslkfjdlkfjsdlkfjsdlkfjsldkfj");
			_editManager.flushPendingOperations();
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var verticalText:Boolean = _textFlow.computedFormat.blockProgression == BlockProgression.RL;
			if (verticalText)
			{
				addFloatAtPosition(0, 100, 100, Float.LEFT);
				controller.setCompositionSize(97, 491);
			}
			else
			{
				addFloatAtPosition(0, 400, 400, Float.LEFT);
				controller.setCompositionSize(855, 396);
			}
			var format:TextLayoutFormat = new TextLayoutFormat(controller.format);
			format.columnCount = 2;
			controller.format = format;
			_textFlow.flowComposer.updateAllControllers();
			// Expect to get float with one line in second column, containing only the anchor
			// Second line is overset
			var firstLine:TextFlowLine = _textFlow.flowComposer.getLineAt(0);
			assertTrue(firstLine.textLength == 1 && firstLine.columnIndex == 1, "Expected float in second column in a line by itself");
		/*	for (var i:int = 0; i < _textFlow.flowComposer.numLines; ++i)
			{
				var line:TextFlowLine = _textFlow.flowComposer.getLineAt(i);
				trace("Line from ", line.absoluteStart, "length", line.textLength, "x", line.x, "y", line.y, "column", line.columnIndex);
			} 
			assertTrue("Expected two lines", _textFlow.flowComposer.numLines > 1); */
			
			// Do it again, but this time make the float wide enough that it overflows the column bounds
			if (!verticalText)
				controller.setCompositionSize(773, 426);
			else
				controller.setCompositionSize(155, 97);
			/*for (var i:int = 0; i < _textFlow.flowComposer.numLines; ++i)
			{
				var line:TextFlowLine = _textFlow.flowComposer.getLineAt(i);
				trace("Line from ", line.absoluteStart, "length", line.textLength, "x", line.x, "y", line.y, "column", line.columnIndex);
			} */
			
			if (verticalText)
				_disableBoundsCheck = true;
		}
		
		private function findFloat(textFlow:TextFlow):InlineGraphicElement
		{
			var ilg:InlineGraphicElement = null;
			var leaf:FlowLeafElement = textFlow.getFirstLeaf();
			while (leaf && leaf != textFlow.getLastLeaf())
			{
				if (leaf is InlineGraphicElement)
					ilg = leaf as InlineGraphicElement;
				leaf = leaf.getNextLeaf();
			}
			return ilg;
		}
		
		public function htmlImportTest():void
		{
			var htmlString:String = "<HTML><BODY><p>Example paragraph, with a img aligned left<img align='left' src='http://mozcom-cdn.mozilla.net/img/tignish/template/mozilla-logo.png'>more text</p></BODY></HTML>";
			var textFlow:TextFlow = TextConverter.importToFlow(htmlString, TextConverter.TEXT_FIELD_HTML_FORMAT);
			var ilg:InlineGraphicElement = findFloat(textFlow);
			assertTrue(ilg != null, "Expected to find InlineGraphicElement from <img> import");
			assertTrue(ilg.float != Float.LEFT, "align=left <img> import, expected float=left");

			htmlString = "<HTML><BODY><p>Example paragraph, with a img aligned left<img align='right' src='http://mozcom-cdn.mozilla.net/img/tignish/template/mozilla-logo.png'>more text</p></BODY></HTML>";
			textFlow = TextConverter.importToFlow(htmlString, TextConverter.TEXT_FIELD_HTML_FORMAT);
			ilg = findFloat(textFlow);
			assertTrue(ilg != null, "Expected to find InlineGraphicElement from <img> import");
			assertTrue(ilg.float != Float.RIGHT, "align=right <img> import, expected float=right");

			htmlString = "<HTML><BODY><p>Example paragraph, with a img aligned left<img align='foo' src='http://mozcom-cdn.mozilla.net/img/tignish/template/mozilla-logo.png'>more text</p></BODY></HTML>";
			textFlow = TextConverter.importToFlow(htmlString, TextConverter.TEXT_FIELD_HTML_FORMAT);
			ilg = findFloat(textFlow);
			assertTrue(ilg != null, "Expected to find InlineGraphicElement from <img> import");
			assertTrue(ilg.float != Float.NONE, "align=foo (invalid value) <img> import, expected float=none");
		}
		
		public function deleteAtStart():void
		{
			var firstFloat:DisplayObject = addFloatAtPosition(0, 100, 100, Float.LEFT);
			_textFlow.flowComposer.updateAllControllers();
			var secondFloat:DisplayObject = addFloatAtPosition(795, 100, 50, Float.LEFT);
			_textFlow.flowComposer.updateAllControllers();
			SelManager.deleteText(new SelectionState(_textFlow, 0, 1));	
			
			// Check to make sure the first float is still in the display list
			assertTrue("First float was deleted and should not still be visible", !isInDisplayList(TestDisplayObject as DisplayObjectContainer, firstFloat));

			// Check to make sure the second float is still in the display list
			assertTrue("Second float was not deleted and should still be visible", isInDisplayList(TestDisplayObject as DisplayObjectContainer, secondFloat));
			_disableBoundsCheck = true;
		}
		
		private function isInDisplayList(container: DisplayObjectContainer, objectToFind:DisplayObject):Boolean
		{
			var child:DisplayObject;
			
			if (container == objectToFind)
				return true;
			
			for (var i:int = container.numChildren - 1; i >= 0; i--)
			{
				child = container.getChildAt(i);
				if (child == objectToFind)
					return true;
				if ((child is DisplayObjectContainer) && isInDisplayList(child as DisplayObjectContainer, objectToFind))
					return true;
			}
			
			if (container is Container)
			{
				var uiComponent:Container = container as Container;
				for (i = uiComponent.rawChildren.numChildren - 1; i >= 0; i--)
				{
					child = uiComponent.rawChildren.getChildAt(i);
					if (child == objectToFind)
						return true;
					if ((child is DisplayObjectContainer) && isInDisplayList(child as DisplayObjectContainer, objectToFind))
						return true;
				}
			}
			return false;	// not found
		}
		
		public function overFlowAtStart():void		// 2661625
		{
			addFloatAtPosition(0, 400, 400, Float.LEFT);
			_textFlow.fontFamily = "Times New Roman";
			_textFlow.textIndent = 15;
			_textFlow.fontSize = 14;
			_textFlow.paragraphSpaceAfter = 15;
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			controller.setCompositionSize(controller.compositionWidth, 404);
			controller.columnCount = 2;
			_textFlow.flowComposer.updateAllControllers();
			controller.verticalScrollPosition = 300;
			_textFlow.flowComposer.updateAllControllers();
			var bounds:Rectangle = controller.getContentBounds();
			assertTrue("Content bounds should include float at top", bounds.top < _textFlow.flowComposer.getLineAt(0).y); 
			_disableBoundsCheck = true;
			
			// Check for a different bug -- text disappears
			controller.setCompositionSize(controller.compositionWidth, 424);
			_textFlow.flowComposer.updateAllControllers();
			controller.setCompositionSize(controller.compositionWidth, 200);
			_textFlow.flowComposer.updateAllControllers();
			assertTrue("We should be seeing something!", controller.container.numChildren > 0);
		}
		
		public function measureWidth():void
		{
			// When we're measuring, floats come out as inlines
			var floatObject:DisplayObject = addFloatAtPosition(0, 10, 10, Float.LEFT);
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			if (_textFlow.computedFormat.blockProgression == BlockProgression.RL)
				controller.setCompositionSize(500, NaN);
			else
				controller.setCompositionSize(NaN, 500);
			_textFlow.flowComposer.updateAllControllers();
			var floatHolder:DisplayObject = floatObject.parent;
			assertTrue("Float should be treated as inline when measuring in the logical width direction", floatHolder.parent is TextLine);
			_disableBoundsCheck = true;
		}
		
		//watson 2644509
		public function inlineWideAndFloat():void
		{	
			var width:Number = 100;
			var height:Number = 100;
			var float:String = "left";
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			
			var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("A" + "\n");
			_textFlow.flowComposer.updateAllControllers();
			
			var tlf1:TextFlowLine = _textFlow.flowComposer.getLineAt(0);
			var pos1:int = tlf1.absoluteStart;
			var floatObject:DisplayObject = addFloatAtPosition(pos1, width, height, float);
			//to make controller as wide as float
			if (!verticalText)
				controller.setCompositionSize(100, controller.compositionHeight);
			else
				controller.setCompositionSize(controller.compositionWidth, 100);
			_textFlow.flowComposer.updateAllControllers();
			verifyFloatInLine(pos1, width, height, float, floatObject);
			var numlines:int = _textFlow.flowComposer.numLines;
			assertTrue ("incorrect TextLine number", numlines==2);
			
			//update the first TextFlowLine
			tlf1 = _textFlow.flowComposer.getLineAt(0);
			
			//get the TextLine with the Text "A"
			var tlf2:TextFlowLine = _textFlow.flowComposer.getLineAt(1);
			var tl2:TextLine = tlf2.getTextLine();
			
			//verify there is no overlap for float and the text, make sure float is at the previous line
			assertTrue ("float at wrong position.", tl2.previousLine.hasGraphicElement == true);
			
			//verify second line with "A" is under the float
			if (!verticalText)
				assertTrue ("TextLine with text 'A' should be below float TextLine ", tlf1.y < tlf2.y);
			else
				assertTrue ("TextLine with text 'A' should be at left of float TextLine ", tlf1.x > tlf2.x);
			
			_disableBoundsCheck = true;
		} 
		
		//watson 2617914: RTE composing many floats in narrow columns
		public function narrowColumnFloat():void
		{	
			try {
				var width:Number = 100;
				var height:Number = 100;
				var float:String = "right";
				
				//set up multiple columns to make the display narrow
				var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
				controller.columnCount = 3;			
				var verticalText:Boolean = _textFlow.blockProgression == BlockProgression.RL;
				_textFlow.flowComposer.updateAllControllers();
				
				//to add 10 floats to the first 10 text flow lines
				var tlf:TextFlowLine;
				var pos:int;
				
				tlf = _textFlow.flowComposer.getLineAt(1);
				pos = tlf.absoluteStart;
				addFloatAtPosition(pos + 10, width, height, float);
				tlf = _textFlow.flowComposer.getLineAt(2);
				pos = tlf.absoluteStart;
				addFloatAtPosition(pos + 10, width, height, float);
				tlf = _textFlow.flowComposer.getLineAt(3);
				pos = tlf.absoluteStart;
				addFloatAtPosition(pos + 10, width, height, float);
				tlf = _textFlow.flowComposer.getLineAt(4);
				pos = tlf.absoluteStart;
				addFloatAtPosition(pos + 10, width, height, float);
				tlf = _textFlow.flowComposer.getLineAt(5);
				pos = tlf.absoluteStart;
				addFloatAtPosition(pos + 10, width, height, float);
				tlf = _textFlow.flowComposer.getLineAt(6);
				pos = tlf.absoluteStart;
				addFloatAtPosition(pos + 10, width, height, float);
				tlf = _textFlow.flowComposer.getLineAt(7);
				pos = tlf.absoluteStart;
				addFloatAtPosition(pos + 10, width, height, float);
				tlf = _textFlow.flowComposer.getLineAt(8);
				pos = tlf.absoluteStart;
				addFloatAtPosition(pos + 10, width, height, float);
				tlf = _textFlow.flowComposer.getLineAt(9);
				pos = tlf.absoluteStart;
				addFloatAtPosition(pos + 10, width, height, float);
				tlf = _textFlow.flowComposer.getLineAt(10);
				pos = tlf.absoluteStart;
				addFloatAtPosition(pos + 10, width, height, float);
		
				//to reduce the container size to recomposie, make sure display correctly without RTE
				controller.setCompositionSize(controller.compositionWidth -20, controller.compositionHeight -20);
				_textFlow.flowComposer.updateAllControllers();
				
				//to reduce the container size again to recomposie, make sure display correctly without RTE
				controller.setCompositionSize(controller.compositionWidth -20, controller.compositionHeight -20);
				_textFlow.flowComposer.updateAllControllers();
				
				//to reduce the container size again to recomposie, make sure display correctly without RTE
				controller.setCompositionSize(controller.compositionWidth -20, controller.compositionHeight -20);
				_textFlow.flowComposer.updateAllControllers();
				
				_disableBoundsCheck = true;
			}
			catch (e:Error)
			{
				assertTrue ("RTE occurs", !e);
			}
		} 
		
		public function caretOnEmptyInlineGraphic():void		// Bug 2719488
		{
			var markup:String = '<TextFlow whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p textAlign="center" textIndent="0"><span fontSize="24">Amid Blight and Scanenging, Old G.M. Plants Linger</span></p><p textAlign="center" textIndent="0"><span></span></p><p textIndent="0"><img height="auto" width="auto" source="Auto-articleLarge.jpg" float="start"/><span>FLINT, Mich. — By day, hundreds of </span><a href="http://topics.nytimes.com/top/news/business/companies/general_motors_corporation/index.html?inline=nyt-org"><span>General Motors</span></a><span> work­ers make pis­tons and other en­gine parts at a fac­tory on this city’s east side. </span></p></TextFlow>';

			_textFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			_flowComposer = _textFlow.flowComposer;
			_textFlow.interactionManager = new EditManager();
			var flintPara:ParagraphElement = _textFlow.getChildAt(2) as ParagraphElement;
			var pos:int = flintPara.getAbsoluteStart() + 1;
			VellumTestCase.testApp.contentChange (_textFlow);
			TestDisplayObject = VellumTestCase.testApp.getDisplayObject();
			TestFrame = _textFlow.flowComposer.getControllerAt(0);

			_textFlow.flowComposer.updateAllControllers();
			_textFlow.interactionManager.selectRange(pos, pos);
			_textFlow.interactionManager.setFocus();

			var charCode:int = 0;
			var keyCode:int  = 37;		// left arrow key
			var shiftDown:Boolean = true;

			var selState:SelectionState = _textFlow.interactionManager.getSelectionState();
			var keyEvent:KeyboardEvent = new KeyboardEvent( KeyboardEvent.KEY_DOWN,
				true, false, charCode, keyCode, KeyLocation.STANDARD, false, false, shiftDown);
			TestFrame.container["dispatchEvent"](keyEvent);

			_disableBoundsCheck = true;		// for debugging test
		}
		
		public function restartComposeFromStart():void // 2730934
		{
			var pos:int = 81;
			var markup:String = '<TextFlow blockProgression="tb" direction="ltr" whiteSpaceCollapse="preserve" version="2.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p blockProgression="rl" columnCount="inherit" columnGap="inherit" columnWidth="inherit" direction="ltr" textAlign="justify" verticalAlign="inherit"><img height="100" width="100" source="../../test/testFiles/assets/smiling.png" float="left"/><span backgroundColor="#33ff00">This is Markup float left test</span></p><p blockProgression="rl" columnCount="inherit" columnGap="inherit" columnWidth="inherit" direction="ltr" textAlign="justify" verticalAlign="inherit"><img height="100" width="100" source="../../test/testFiles/assets/smiling.png" float="right"/><span>This is Markup float right test</span></p><p blockProgression="rl" columnCount="inherit" columnGap="inherit" columnWidth="inherit" direction="ltr" textAlign="justify" verticalAlign="inherit"><img height="100" width="100" source="../../test/testFiles/assets/smiling.png" float="none"/><span>This is Markup float none test</span></p></TextFlow>';
			_textFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			VellumTestCase.testApp.contentChange (_textFlow);
			TestDisplayObject = VellumTestCase.testApp.getDisplayObject();
			TestFrame = _textFlow.flowComposer.getControllerAt(0);
			TestFrame.setCompositionSize(NaN, TestFrame.compositionHeight);		// we're measuring
			var editManager:IEditManager = _textFlow.interactionManager as IEditManager;
			editManager.selectRange(pos, pos + 1);
			var leafFormat:TextLayoutFormat = new TextLayoutFormat();
			leafFormat.color = 0xFF0000;
			editManager.applyLeafFormat(leafFormat);		// force the span creation here
			_textFlow.flowComposer.updateAllControllers();
		
			var resultsBefore:Array = CompositionResults.getContainerResults(TestFrame.container);	// Save off TextLine positions
			
			_textFlow.flowComposer.updateAllControllers();
			leafFormat = new TextLayoutFormat();
			leafFormat.color = 0xFF00;		// only change the color here
			var leaf:FlowLeafElement = _textFlow.findLeaf(pos);
			leaf.format = leafFormat;
			_textFlow.flowComposer.updateAllControllers();

			var resultsAfter:Array = CompositionResults.getContainerResults(TestFrame.container);	// Save off TextLine positions
			assertTrue("Expected TextLines not to change", CompositionResults.compareResults(resultsBefore, resultsAfter));
		}
		
		public function convertInlineToFloat():void
		{
			var inline:DisplayObject = addFloatAtPosition(954, 100, 100, Float.NONE);
			_textFlow.flowComposer.updateAllControllers();
			assertTrue("Inline should appear as descendent of container", TestFrame.container.contains(inline));
			assertTrue("Inline should appear as descendent of container", inline.parent.parent is TextLine);
			var inlineGraphicElement:InlineGraphicElement = _textFlow.findLeaf(954) as InlineGraphicElement;
			inlineGraphicElement.float = Float.LEFT;
			_textFlow.flowComposer.updateAllControllers();
			assertTrue("Inline should appear as descendent of container", TestFrame.container.contains(inline));
			assertTrue("Inline should appear as child of container", inline.parent.parent == TestFrame.container);
		}
		
		public function infiniteLoop2769562():void
		{
			// Start with empty flow. Add a float left, a float right, and some text with long words following.
			SelManager.allowDelayedOperations = false;		// execute inserts immediately
			SelManager.deleteText(new SelectionState(_textFlow, 0, _textFlow.textLength));
			addFloatAtPosition(0, 100, 100, Float.LEFT);
			addFloatAtPosition(1, 100, 100, Float.RIGHT);
			SelManager.selectRange(_textFlow.textLength - 1, _textFlow.textLength - 1);
			SelManager.insertText("thisisalongword hereis some more text just typing on for a bit then it will be long enough.");
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var originalWidth:Number = controller.compositionWidth;
			controller.setCompositionSize(220, controller.compositionHeight);
			_textFlow.flowComposer.updateAllControllers();
			SelManager.selectRange(0, 0);
			SelManager.splitParagraph();
			
			// bug caused infinite loop here
			controller.setCompositionSize(220, controller.compositionHeight);
		}
		
		private static var pasteCount:int = 12;
		private static var waitingImageCount:int = 0;
		private function imageIsReady(event:StatusChangeEvent):void
		{
			if (event.status == InlineGraphicElementStatus.READY)
				--waitingImageCount;
		}
		public function pasteManyFloatsWithLoading(callback:Object = null):void
		{
			if(!callback)
			{
				callback = true;
				pasteCount = 12;
				TestFrame.container.addEventListener(Event.ENTER_FRAME,addAsync(pasteManyFloatsWithLoading,2500,null),false,0,true);
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, imageIsReady);
				
				// Delete current text
				SelManager.selectRange(0, int.MAX_VALUE);
				SelManager.deleteText();
				
				var baseImageURL:String = LoaderUtil.createAbsoluteURL(baseURL, "../../test/testFiles/assets/");
				var src:String = "gremlin.jpg"; 	// image to use
				var width:int = 20;
				var height:int = 20;
				
				SelManager.selectRange(0, 0);
				var inlineGraphicElement1:InlineGraphicElement = SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),FormatValue.AUTO,FormatValue.AUTO, Float.LEFT);
				var inlineGraphicElement2:InlineGraphicElement = SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),FormatValue.AUTO,FormatValue.AUTO, Float.LEFT);
				var inlineGraphicElement3:InlineGraphicElement = SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),FormatValue.AUTO,FormatValue.AUTO, Float.LEFT);
				var inlineGraphicElement4:InlineGraphicElement = SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),FormatValue.AUTO,FormatValue.AUTO, Float.LEFT);
				SelManager.insertText("abcdef ghijklmopqr stuvwxyz");
				SelManager.flushPendingOperations();
				waitingImageCount = 4;
			}
			else // Make sure the images are ready before we let the snapshot go
			{
				if (waitingImageCount > 0)
				{
					SelManager.textFlow.addEventListener(Event.ENTER_FRAME,addAsync(pasteManyFloatsWithLoading,2500,null),false,0,true);
				}
				else
				{
					if (pasteCount > 0)		// images have loaded -- redraw & do another paste
					{
						TestFrame.container.addEventListener(Event.ENTER_FRAME,addAsync(pasteManyFloatsWithLoading,2500,null),false,0,true);
						SelManager.updateAllControllers();
						var textScrap:TextScrap = TextScrap.createTextScrap(new TextRange(SelManager.textFlow, 0, 32));
						var pos:int = SelManager.textFlow.textLength - 1;
						SelManager.pasteTextScrap(textScrap, new SelectionState(SelManager.textFlow, pos, pos));	// paste to end of story
						waitingImageCount += 4;
						--pasteCount;
					}
					else		// we're done!
						SelManager.textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, imageIsReady);
						SelManager.textFlow.flowComposer.updateAllControllers();
						if (SelManager.textFlow.computedFormat.blockProgression == BlockProgression.RL)
							_disableBoundsCheck = true;
				}
			}
		}
		
		public function contentBoundsWithFactoryComposition():void
		{
			_disableBoundsCheck = true;
			VellumTestCase.testApp.contentChange (null);

			var TestCanvas:Canvas;
			TestDisplayObject = testApp.getDisplayObject();
			if (TestDisplayObject)
			{
				TestCanvas = Canvas(TestDisplayObject);
			}
			var tf:TextFlow;
			
			var lineDisplays:Array = new Array();
			var lineCounter:Number = 0;
			var textFlowFactory:TextFlowTextLineFactory = new TextFlowTextLineFactory();				
			var clearArributes:Array = ["left" , "right", "start", "end", "both", "none"];
			var floatArributes:Array = ["left", "right", "start", "end", "none"];
			var clearArribute:String;
			var floatArribute:String;
			var fs:Sprite;
			var container:Sprite;
			var span:SpanElement = new SpanElement();
			var pic:InlineGraphicElement = new InlineGraphicElement();
			var para1:ParagraphElement = new ParagraphElement();
			var para2:ParagraphElement = new ParagraphElement();
			var factoryFlow:TextFlow; 
			var format:TextLayoutFormat;
			var controller:ContainerController;
			
			para1.addChild( pic );
			para2.addChild( span );
			textFlowFactory.compositionBounds = new Rectangle( 0, 0, 300, 400 );
			
			span.text = "The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Sentences removed. lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Sentences removed.";
			[Embed (source="../../../../test/testFiles/assets/smiley.gif")]
			var Smiley:Class;
			pic.source = Smiley;
			
			function callback(lineOrShape:DisplayObject):void
			{
				fs.addChild(lineOrShape);
				lineDisplays[lineCounter] = lineOrShape;
				lineCounter ++;
			}
			
			for each(floatArribute in floatArributes){
				pic.float = floatArribute;
				for each(clearArribute in clearArributes){
					para2.clearFloats = clearArribute;
					//sprite
					if(fs != null){
						fs.graphics.clear();
						testApp.getDisplayObject().rawChildren.removeChild(fs);
					}
					fs = new Sprite();
					//draw our bounds
					fs.graphics.beginFill(0x555555,.5);
					fs.graphics.drawRect( 0, 0, 300, 400);
					fs.graphics.endFill();
					//set text direction and block progression
					if( format != null)
						format = null;
					format = new TextLayoutFormat();
					format.direction = _textFlow.direction;
					format.blockProgression = _textFlow.blockProgression;
					
					//default text flow in vellum unit, used to get line number
					tf = new TextFlow();
					tf.flowComposer = new StandardFlowComposer();
					tf.addChild(para1);
					tf.addChild(para2);
					if(container != null){
						container.graphics.clear();
						testApp.getDisplayObject().rawChildren.removeChild(container);
					}
					container = new Sprite();
					if(controller != null)
						controller = null;
					var width:Number = 300;
					var height:Number = 400;
					controller = new ContainerController(container,300,400);
					tf.hostFormat = format;
					tf.flowComposer.addController(controller);
					tf.interactionManager = new EditManager();
					tf.flowComposer.updateAllControllers(); 
					//text flow by factory composition 
					if(factoryFlow != null){
						factoryFlow = null;
					}
					factoryFlow = new TextFlow();					
					factoryFlow.replaceChildren(0, factoryFlow.numChildren, [para1, para2]);
					factoryFlow.replaceChildren(0, factoryFlow.numChildren, para1.deepCopy());
					factoryFlow.replaceChildren(factoryFlow.numChildren, factoryFlow.numChildren, para2.deepCopy());
					factoryFlow.flowComposer.updateAllControllers();
					
					factoryFlow.hostFormat = format;
					factoryFlow.flowComposer.updateAllControllers();
					textFlowFactory.createTextLines(callback, factoryFlow);	
					//add sprite to vellum unit UI
					container.x = 300;
					container.y = 0;
					container.width = 300;
					container.height = 400; 
					TestCanvas.rawChildren.addChild(fs);
					TestCanvas.rawChildren.addChild(container);
					//check points
					for(var i:int = 0; i<tf.flowComposer.numLines ;i++){
						var textLine:TextFlowLine = tf.flowComposer.getLineAt(i);
						var textLineBounds:Rectangle = textLine.getTextLine().getBounds(container);	
						var bbox:Rectangle = lineDisplays[i].getBounds(fs);
						
						//trace("Line "+i+"'s left : "+textLineBounds.left +" "+ bbox.left);
						//trace("Line "+i+"'s right : "+textLineBounds.right +" "+ bbox.right);
						//trace("Line "+i+"'s top : "+textLineBounds.top +" "+ bbox.top);
						//trace("Line "+i+"'s bottom : "+textLineBounds.bottom +" "+ bbox.bottom);
						//The code below I cannot explain...but it is correct
						if(_textFlow.blockProgression == BlockProgression.TB){
							assertTrue("contentBounds left doesn't match sprite inked bounds when {\"clear\" : \"" + clearArribute + "\" , \"float\" : \"" +  floatArribute + "\"} at Line "+i+"/"+tf.flowComposer.numLines , Math.abs(textLineBounds.left - bbox.left) < 0.1 );
							assertTrue("contentBounds right doesn't match sprite inked bounds when {\"clear\" : \"" + clearArribute + "\" , \"float\" : \"" +  floatArribute + "\"} at Line "+i+"/"+tf.flowComposer.numLines , Math.abs(textLineBounds.right - bbox.right) < 0.1 );
						}else{
							assertTrue("contentBounds left doesn't match sprite inked bounds when {\"clear\" : \"" + clearArribute + "\" , \"float\" : \"" +  floatArribute + "\"} at Line "+i+"/"+tf.flowComposer.numLines , Math.abs(textLineBounds.left+300 - bbox.left) < 0.1 );
							assertTrue("contentBounds right doesn't match sprite inked bounds when {\"clear\" : \"" + clearArribute + "\" , \"float\" : \"" +  floatArribute + "\"} at Line "+i+"/"+tf.flowComposer.numLines , Math.abs(textLineBounds.right+300 - bbox.right) < 0.1 );
						}
						assertTrue("contentBounds top doesn't match sprite inked bounds when {\"clear\" : \"" + clearArribute + "\" , \"float\" : \"" +  floatArribute + "\"} at Line "+i+"/"+tf.flowComposer.numLines , Math.abs(textLineBounds.top - bbox.top) < 0.1 );
						assertTrue("contentBounds bottom doesn't match sprite inked bounds when {\"clear\" : \"" + clearArribute + "\" , \"float\" : \"" +  floatArribute + "\"} at Line "+i+"/"+tf.flowComposer.numLines , Math.abs(textLineBounds.bottom - bbox.bottom) < 0.1 );
					}
					lineCounter = 0;
				} 
			}
				
		}
	}
}


