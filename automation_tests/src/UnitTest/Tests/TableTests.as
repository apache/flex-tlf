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
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TableDataCellElement;
	import flashx.textLayout.elements.TableElement;
	import flashx.textLayout.elements.TableRowElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	import mx.containers.Canvas;

    use namespace tlf_internal;
	
	public class TableTests extends VellumTestCase
	{
        // Constants
        private static const INS_SPAN:uint = 1;
        private static const INS_ILG:uint = 2;
        
        private static const VALIDATOR_PREFIX:String = "validate_";
        private static const SETTER_PREFIX:String = "set_";
        private static const EnglishHeader:String = '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">';
        private static const EnglishText:String =  '<p paddingBottom="0"><span>There are many such lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.</span></p>'
                                                 + '<p paddingBottom="0"><span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Within the furnace were seen the curling and riotous flames, and the burning marble, almost molten with the intensity of heat; while without, the reflection of the fire quivered on the dark intricacy of the surrounding forest, and showed in the foreground a bright and ruddy little picture of the hut, the spring beside its door, the athletic and coal-begrimed figure of the lime-burner, and the half-frightened child, shrinking into the protection of his father\'s shadow. And when again the iron door was closed, then reappeared the tender light of the half-full moon, which vainly strove to trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, though thus far down into the valley the sunshine had vanished long and long ago.</span></p>';
        private static const JapaneseHeader:String = '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">';
        private static const JapaneseText:String = '<p paddingBottom="0"><span>2.文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフスする方法について解説しまが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクす。</span></p>';
        
        // Static Markups
        private static var EnglishContent:String = EnglishHeader
                                                 + EnglishText
                                                 + EnglishText
                                                 + '</TextFlow>';
        
        private static var JapaneseContent:String = JapaneseHeader
                                                  + JapaneseText
                                                  + JapaneseText
                                                  + JapaneseText
                                                  + JapaneseText
                                                  + JapaneseText
                                                  + '</TextFlow>';
        // Static members
        [Embed(source="../../../../test/testFiles/assets/smiley.gif")]
        private static var SmileyIcon:Class;
        
        private static var BaseImageURL:String;
        private static var FormatValueList:Array = [0, 1, 5];
        private static var ContentLanguageList:Array = [ EnglishContent, JapaneseContent ];
        private static var SourceTextFlow:Array;
        private static var TableRowCountList:Array = [25];
        private static var TableColumnCountList:Array = [4];
        private static var TableInsertPositionList:Array = [1];

        // Members
        private var _cellBorderWidth:int;
        private var _cellPadding:int;
        private var _cellSpacing:int;
        private var _columnShifts:Array;
        private var _container1:Sprite;
        private var _contentType:uint;
        private var _currentLanguage:String;
        private var _currentInsertPos:uint;
        private var _currentTestMethodName:String;
        private var _currentValidatorMethodName:String;
        private var _currentSetterMethodName:String;
        private var _firstVisibleLineAbsStart:int;
        private var _floatColor:int;
        private var _lastVisibleLineAbsStart:int;
        private var _rtlText:Boolean;
        private var _tableElement:TableElement;
		private var _textFlow:TextFlow;
        private var _textFlowSprite:Sprite;
        private var _testCanvas:Canvas;
		private var _testXML:XML;
        private var _verticalText:Boolean;
        private var _testResultX:*;
        private var _testResultY:*;
        private var _assertMsgX:String;
        private var _assertMsgY:String;
        private var _tableMargin:int;
        private var _tablePaddingTop:int;
        private var _tablePaddingBottom:int;
        private var _tableBorderWidth:int;
		
		public function TableTests(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
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
            addTestCase(ts, testConfig, "cellBorderWidthTest");
            addTestCase(ts, testConfig, "cellPaddingTest");
            addTestCase(ts, testConfig, "cellSpacingTest");
            addTestCase(ts, testConfig, "inlineGraphicTest");
            addTestCase(ts, testConfig, "tableBorderWidthTest");
            addTestCase(ts, testConfig, "tableMarginTest");
            addTestCase(ts, testConfig, "tableAbsPositionTest");
		}
		
		private static function addTestCase(ts:TestSuiteExtended, testConfig:TestConfig, methodName:String):void
		{
			var testXML:XML = <TestCase>
								<TestData name="methodName">{methodName}</TestData>
								<TestData name="id">{methodName}</TestData>
							</TestCase>;
            
            ts.addTestDescriptor (new TestDescriptor (TableTests,"callTestMethod", testConfig, testXML) );
		}
		
		override public function setUp() : void
		{
			super.setUp();
			initializeSourceTextFlow();
			initializeFlow();
		}
		
		override public function tearDown(): void
		{
			super.tearDown();
		}
		
        public function callTestMethod():void
        {
            for each (_currentLanguage in ContentLanguageList)
            {
                var TestCase:XML = _testXML;
                _currentTestMethodName = TestCase.TestData.(@name == "methodName").toString();
                _currentValidatorMethodName = VALIDATOR_PREFIX + _currentTestMethodName;
                _currentSetterMethodName = SETTER_PREFIX + _currentTestMethodName;
                for each (_currentInsertPos in TableInsertPositionList)
                    for each (var rowCount:uint in TableRowCountList)
                        for each (var colCount:uint in TableColumnCountList)
                            this[_currentTestMethodName](rowCount, colCount);
            }
        }
        
		private function initializeFlow():void
		{
            _textFlow = new TextFlow();
            _textFlow.columnCount = 3;
            _testCanvas = myEmptyChilds();
            var controllerWidth:Number = _testCanvas.width;
            var controllerOne:ContainerController;
            _container1 = new Sprite();
            controllerOne = new ContainerController(_container1, controllerWidth, _testCanvas.height);
            _textFlow.flowComposer.addController(controllerOne);
            _textFlow.interactionManager = new EditManager();
            
            _textFlowSprite = new Sprite();
            _textFlowSprite.addChild(_container1);
            
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
            
            calculateColumnShifts();
		}
		
		private function setUpFlow():void
		{
			var sourceFlow:TextFlow;
			if (_currentLanguage == EnglishContent)
				sourceFlow = SourceTextFlow[0];
			else if (_currentLanguage == JapaneseContent)
				sourceFlow = SourceTextFlow[1];
			else 
				sourceFlow = TextConverter.importToFlow(_currentLanguage, TextConverter.TEXT_LAYOUT_FORMAT);
			
			_textFlow.replaceChildren(0, _textFlow.numChildren);
			assertTrue("Empty TextFlow has incorrect ContainerLength",_textFlow.textLength == _textFlow.flowComposer.getControllerAt(0).textLength);
			var newFlow:TextFlow = sourceFlow.deepCopy() as TextFlow;
			var childCount:int = newFlow.numChildren;
			for (var i:int = newFlow.numChildren - 1; i >= 0; --i)
			{
				var child:FlowElement = newFlow.getChildAt(i);
				_textFlow.addChildAt(0, child);
			}
			_textFlow.interactionManager.selectRange(0, 0);
		}
		
		private function initializeSourceTextFlow():void
		{
			SourceTextFlow = [];
			
			// Create english content
			var englishFlow:TextFlow = TextConverter.importToFlow(EnglishContent, TextConverter.TEXT_LAYOUT_FORMAT);
            var engTLF:TextLayoutFormat = new TextLayoutFormat();
            engTLF.locale = "en_US";
            engTLF.fontSize = 14;
            engTLF.fontFamily="Arial" ;
            englishFlow.format = engTLF;
			SourceTextFlow.push(englishFlow);

			// Create japanese content
			var japaneseFlow:TextFlow = TextConverter.importToFlow(JapaneseContent, TextConverter.TEXT_LAYOUT_FORMAT);
			var japTLF:TextLayoutFormat = new TextLayoutFormat();
            japTLF.locale = "ja";
            japTLF.fontSize = 14;
			japaneseFlow.format = japTLF;
			SourceTextFlow.push(japaneseFlow);
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
		
        // Test cases
        private function cellBorderWidthTest(rowCount:uint, colCount:uint):void
        {
            _contentType = INS_SPAN;
            initTestFormats();
            _currentValidatorMethodName = "validate_cellPositionVHTest";
            for each(_cellBorderWidth in FormatValueList)
            {
                beforeSetTableFormat(rowCount, colCount);
                afterSetTableFormat();
            }
            // Validation has to be executed until all images are loaded successfully.
            // So it should be postponed to the event listener.
        }
        
        private function cellPaddingTest(rowCount:uint, colCount:uint):void
        {
            _contentType = INS_SPAN;
            initTestFormats();
            for each(_cellPadding in FormatValueList)
            {
                beforeSetTableFormat(rowCount, colCount);
                afterSetTableFormat();
            }
            // Validation has to be executed until all images are loaded successfully.
            // So it should be postponed to the event listener.
        }
        
        private function cellSpacingTest(rowCount:uint, colCount:uint):void
        {
            _contentType = INS_SPAN;
            initTestFormats();
            _currentValidatorMethodName = "validate_cellPositionVHTest";
            for each(_cellSpacing in FormatValueList)
            {
                beforeSetTableFormat(rowCount, colCount);
                afterSetTableFormat();         
            }
            // Validation has to be executed until all images are loaded successfully.
            // So it should be postponed to the event listener.
        }
        
        private function tableAbsPositionTest(rowCount:uint, colCount:uint):void
        {
            _contentType = INS_SPAN;
            initTestFormats();
            beforeSetTableFormat(rowCount, colCount);
            afterSetTableFormat();
            // Validation has to be executed until all images are loaded successfully.
            // So it should be postponed to the event listener.
        }
        
        private function inlineGraphicTest(rowCount:uint, colCount:uint):void
        {
            _contentType = INS_ILG;
            initTestFormats();
            beforeSetTableFormat(rowCount, colCount);
            afterSetTableFormat();
            // Validation has to be executed until all images are loaded successfully.
            // So it should be postponed to the event listener.
        }
        
        private function tableMarginTest(rowCount:uint, colCount:uint):void
        {
            _contentType = INS_SPAN;
            initTestFormats();
            for each(_tableMargin in FormatValueList)
            {
                beforeSetTableFormat(rowCount, colCount);
                afterSetTableFormat();
            }
            // Validation has to be executed until all images are loaded successfully.
            // So it should be postponed to the event listener.
        }
        
        private function tableBorderWidthTest(rowCount:uint, colCount:uint):void
        {
            _contentType = INS_SPAN;
            initTestFormats();
            for each(_tableBorderWidth in FormatValueList)
            {
                beforeSetTableFormat(rowCount, colCount);
                afterSetTableFormat();
            }
            // Validation has to be executed until all images are loaded successfully.
            // So it should be postponed to the event listener.
        }
        
        private function beforeSetTableFormat(rowCount:uint, colCount:uint):void
        {
            setUpFlow();
            _tableElement = createTable(rowCount, colCount);
            initTableFormat(_tableElement);
        }
        
        private function afterSetTableFormat():void
        {
            _textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, compositionCompleteHandler);
            insertTable(_tableElement, _currentInsertPos);
            _textFlow.flowComposer.updateAllControllers();
            if(_testResultX != undefined && _testResultX == false)
                assertTrue(_assertMsgX, false);
            if(_testResultY != undefined && _testResultY == false)
                assertTrue(_assertMsgY, false);
        }
        
        // Helper functions
        private function createTable(rowCount:uint, colCount:uint):TableElement
        {
            var tableElement:TableElement = new TableElement();
            tableElement.initTableElement(rowCount, colCount);
            createTableRows(tableElement, _contentType);
            setColumnWidth(tableElement);
            return tableElement;
        }
        
        private function createTableRows(table:TableElement, contentInside:uint):void
        {
            for ( var i:uint = 0; i < table.row; i ++ )
            {
                // Create single row
                var rowElement:TableRowElement = new TableRowElement();
                table.addChild(rowElement);
                // Create data cells in row
                for ( var j:uint = 0; j < table.column; j ++ )
                {
                    var dataInCell:String = "cell" + (i*table.column + j);
                    createTableDataCell(rowElement, dataInCell, contentInside);
                }
            }
        }
        
        private function createTableDataCell(rowElement:TableRowElement, dataInCell:String, contentInside:uint):void
        {
            // new ParagraphElement to contain span/float
            var paragraph:ParagraphElement = new ParagraphElement();
            paragraph.paddingTop = 5;
            paragraph.paddingBottom = 5;
            
            switch(contentInside)
            {
                case INS_SPAN:
                    addSpanToParagraph(paragraph, dataInCell);
                    break;
                case INS_ILG:
                    addFloatToParagraph(paragraph, Float.NONE);
                    break;
                default:
                    break;
            }
            
            var cell:TableDataCellElement = new TableDataCellElement();
            var tlf:TextLayoutFormat = new TextLayoutFormat();
            tlf.backgroundAlpha = 1.0;
            tlf.backgroundColor = 0xCCCCCC;
//            tlf.cellPadding = _cellPadding;
            cell.format = tlf;
            cell.setBorderColor(0x000000);
            cell.setBorderWidth(_cellBorderWidth);
            cell.addChild(paragraph);
            
            // Add paragraph to TableRowElement
            rowElement.addChild(cell);
        }
        
        private function addSpanToParagraph(paragraph:ParagraphElement, dataInCell:String):void
        {
            // new Span with null string
            var spanElement:SpanElement = new SpanElement();
            spanElement.text = dataInCell;
            
            paragraph.addChild(spanElement);
        }
        
        private function addFloatToParagraph(paragraph:ParagraphElement, floatPos:String):void
        {   
            // InlineGraphicElement has "auto" width/height so the size can't be calculated till the graphic is loaded
            var inlineGraphic:InlineGraphicElement = new InlineGraphicElement();
            inlineGraphic.source = SmileyIcon;
            paragraph.addChild(inlineGraphic);            
        }
        
        private function calculateColumnShifts():void
        {
            _columnShifts = [];
            
            // We only support single controller for simplification
            var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
            var columnCount:uint = controller.computedFormat.columnCount;
            var columnGap:Number = controller.computedFormat.columnGap;
            // For case which have multiple columns defined in text flow
            var singleColumnShift:Number = (controller.compositionWidth
                - (columnCount - 1) * columnGap) / columnCount + columnGap;
            for (var parcelIndex:int = 0; parcelIndex < columnCount; ++parcelIndex)
                _columnShifts[parcelIndex] = singleColumnShift * parcelIndex;
        }

        private function initTableFormat(tableElement:TableElement):void
        {
            var tableLayoutFormat:TextLayoutFormat = new TextLayoutFormat();
            tableLayoutFormat.tableWidth = 500;
            tableLayoutFormat.textAlign = TextAlign.CENTER;    // Supported
            tableLayoutFormat.backgroundColor = 0xCCCCCC;
            tableElement.format = tableLayoutFormat;
            
            tableElement.cellSpacing = _cellSpacing;
            tableElement.marginLeft = _tableMargin;
            tableElement.marginRight = _tableMargin;
            tableElement.marginTop = _tableMargin;
            tableElement.marginBottom = _tableMargin;
            
            tableElement.setBorderColor(0x550000);
            tableElement.setBorderWidth(_tableBorderWidth);
            
            tableElement.paddingTop = _tablePaddingTop;
            tableElement.paddingBottom = _tablePaddingBottom;
            
            tableElement.cellPadding = _cellPadding;
        }
        
        private function initTestFormats():void
        {
            _cellBorderWidth = 1;
            _cellPadding = 0;
            _cellSpacing = 0;
            _tableBorderWidth = 1;
            _tableMargin = 0;
            _tablePaddingTop = 0;
            _tablePaddingBottom = 0;
        }

        private function insertTable(tableElement:TableElement, pos:uint):uint
        {
            if(pos >= _textFlow.numChildren)
                pos = _textFlow.numChildren - 1;
            
            _textFlow.addChildAt(pos, tableElement);
            
            return pos;
        }
        
        private function setColumnWidth(tableElement:TableElement):void
        {
            var arColWidth:Array = ["30%", "20%", "20%", "80", "70"];
            for ( var i:uint = 0; i < tableElement.column; i ++ )
            {
                tableElement.setColumnWidth(i, arColWidth[i]);
            }
        }

        /*
         *********** Validators *****************
         */
        private function validate_cellPaddingTest(tableElement:TableElement):void
        {
            for(var i:uint = 0; i < tableElement.numChildren; ++i)
            {
                var rowElement:TableRowElement = tableElement.getChildAt(i) as TableRowElement;
                if(!rowElement)
                    continue;
                
                if(!isTableRowVisible(rowElement))
                    break;
                
                for(var j:uint = 0; j < rowElement.numChildren; ++j)
                {
                    var cellElement:TableDataCellElement = rowElement.getChildAt(j) as TableDataCellElement;
                    if(!cellElement)
                        continue;
                    
                    validate_cellPositionVH(rowElement, cellElement);
                }
            }
        }
        
        private function validate_inlineGraphicTest(tableElement:TableElement):void
        {
            validate_tableVPositionTop(tableElement);
            validate_tableVPositionBottom(tableElement);
            validate_tableHPosition(tableElement);
        }
        
        private function validate_tableAbsPositionTest(tableElement:TableElement):void
        {
            var tableAbsStart:int = tableElement.getAbsoluteStart();
            var tableLastLineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(tableAbsStart + tableElement.textLength - 1);
            var nextLine:TextFlowLine = _textFlow.flowComposer.getLineAt(tableLastLineIndex+1);
            if(nextLine)
            {
                var nextLineAbsStart:int = nextLine.absoluteStart;
                _testResultX = (tableAbsStart + tableElement.textLength) == nextLineAbsStart;
                _assertMsgX = "Table is not added in right position!";
            }
            
            var tableFirstLineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(tableAbsStart);
            var previousLine:TextFlowLine = _textFlow.flowComposer.getLineAt(tableFirstLineIndex-1);
            if(previousLine)
            {
                var previousParagraph:ParagraphElement = previousLine.paragraph;
                var computedTableAbsStart:int = previousParagraph.getAbsoluteStart() + previousParagraph.textLength;
                _testResultX = computedTableAbsStart == tableAbsStart;
                _assertMsgX = "Table is not added in right position!";
            }
        }
        
        private function validate_tableBorderWidthTest(tableElement:TableElement):void
        {
            validate_tableVPositionTop(tableElement);
            validate_tableVPositionBottom(tableElement);
            validate_tableHPosition(tableElement);
        }
        
        private function validate_tableMarginTest(tableElement:TableElement):void
        {
            validate_tableVPositionTop(tableElement);
            validate_tableVPositionBottom(tableElement);
            validate_tableHPosition(tableElement);
        }
        
        private function isLineVisible(line:TextFlowLine):Boolean
        {
            if(!line || isNaN(line.height) || isNaN(line.x) || isNaN(line.y))
                return false;
            else
                return true;
        }
        
        private function isTableRowVisible(row:TableRowElement):Boolean
        {
            if(isNaN(row.height) || isNaN(row.x) || isNaN(row.y))
                return false;
            else
                return true;
        }
        
        private function isTableVisible(table:TableElement):Boolean
        {
            if(isNaN(table.height) || isNaN(table.x) || isNaN(table.y))
                return false;
            else
                return true;
        }
        
        private function validate_tableVPositionTop(tableElement:TableElement):void
        {
            if(_verticalText)
                return;
            
            if( !isTableVisible(tableElement) )
                return;
            
            var tableAbsStart:int = tableElement.getAbsoluteStart();
            var tableFirstLineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(tableAbsStart);
            var previousLine:TextFlowLine = _textFlow.flowComposer.getLineAt(tableFirstLineIndex-1);
            
            // Check vertical position
            if(previousLine)
            {
                var previousParagraph:ParagraphElement = previousLine.paragraph;
                _testResultX = Math.abs(tableElement.y - tableElement.getEffectiveMarginTop()
                    - Math.max(tableElement.getEffectivePaddingTop(), previousParagraph.getEffectivePaddingBottom())
                    - previousLine.spaceAfter - previousLine.height
                    - previousLine.y) < 1;
            }
            else
                _testResultX = Math.abs(tableElement.y) < 1;
            
            _assertMsgX = "Table has incorrect top logical vertical position!"; 
        }
        
        private function validate_tableVPositionBottom(tableElement:TableElement):void
        {
            if(_verticalText)
                return;
            
            var tableAbsStart:int = tableElement.getAbsoluteStart();
            var tableLastLineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(tableAbsStart + tableElement.textLength - 1);
            var nextLine:TextFlowLine = _textFlow.flowComposer.getLineAt(tableLastLineIndex+1);
            if(!isLineVisible(nextLine))
                return;
            
            if(nextLine)
            {
                var nextParagraph:ParagraphElement = nextLine.paragraph;
                _testResultX = Math.abs(nextLine.y - tableElement.getEffectiveMarginTop()
                                    - tableElement.y - tableElement.height
                                    - nextLine.spaceBefore
                                    - Math.max(tableElement.getEffectivePaddingBottom(), nextParagraph.getEffectivePaddingTop())) < 1;
            }
            else
            {
                var tableHolder:DisplayObject = TestDisplayObject;
                _testResultX = Math.abs(tableElement.y + tableElement.getEffectiveMarginBottom() + tableElement.height - tableHolder.y) < 1;
            }
            
           _assertMsgX = "Table has incorrect bottom logical vertical position!";
        }
        
        private function validate_tableHPosition(tableElement:TableElement):void
        {
            if(_verticalText)
                return;
            
            if(!isTableVisible(tableElement))
                return;
            
            if (_rtlText)
                _testResultX = Math.abs(tableElement.x + _columnShifts[tableElement.originParcelIndex] + tableElement.computedWidth  + tableElement.getEffectivePaddingRight() + tableElement.getEffectiveMarginRight() - TestDisplayObject.width) < 1;
            else
                _testResultX = Math.abs(tableElement.x - _columnShifts[tableElement.originParcelIndex] - tableElement.getEffectivePaddingLeft() - tableElement.getEffectiveMarginLeft()) < 1;
            
            _assertMsgX = "Table has incorrect logical horizontal position!";
        }
        
        private function validate_cellPositionVHTest(tableElement:TableElement):void
        {
            for(var i:uint = 0; i < tableElement.numChildren; ++i)
            {
                var rowElement:TableRowElement = tableElement.getChildAt(i) as TableRowElement;
                if(!rowElement)
                    continue;
                if(!isTableRowVisible(rowElement))
                    break;
                
                for(var j:uint = 0; j < rowElement.numChildren; ++j)
                {
                    var cellElement:TableDataCellElement = rowElement.getChildAt(j) as TableDataCellElement;
                    if(!cellElement)
                        continue;
                    
                    validate_cellPositionVH(rowElement, cellElement);
                }
            }
        }
        
        private function validate_cellPositionVH(rowElement:TableRowElement, cellElement:TableDataCellElement):void
        {
            if(_verticalText)
                return;
            
            var previousCell:TableDataCellElement = cellElement.getPreviousSibling() as TableDataCellElement;
            var nextCell:TableDataCellElement = cellElement.getNextSibling() as TableDataCellElement;
            
            var cellSpacing:Number = _tableElement.cellSpacing == undefined ? 0 : _tableElement.cellSpacing;
            
            var columnShifts:Number = _columnShifts[rowElement.parcelIndex - _tableElement.originParcelIndex];
            if(_rtlText)
                columnShifts = -columnShifts;

            _assertMsgX = "X Position of cell is incorrect!";
            _assertMsgY = "Y Position of cell is incorrect!";
            
            _testResultY = Math.abs(cellElement.y - rowElement.y) < 1;
            
            if(!previousCell) {
                _testResultX = Math.abs(cellElement.x - cellSpacing - _tableElement.getEffectiveBorderLeftWidth() - columnShifts - _tableElement.x) < 1;
            } else {
                _testResultX = Math.abs(previousCell.x + previousCell.width + cellSpacing - cellElement.x) < 1;
            }
            
            if(_testResultX == false || _testResultY == false)
                return;
            
            if(!nextCell) {
                _testResultX = Math.abs(_tableElement.x + _tableElement.computedWidth + columnShifts - cellSpacing - _tableElement.getEffectiveBorderRightWidth() - cellElement.width - cellElement.x) < 1;
            } else {
                _testResultX = Math.abs(cellElement.x + cellElement.width + cellSpacing - nextCell.x) < 1;
            }
        }
        
        /*
         ********* Event Handlers **********
         */
        private function compositionCompleteHandler(e:CompositionCompleteEvent):void
        {
            _testResultX = undefined;
            _testResultY = undefined;
            _assertMsgX = "";
            _assertMsgY = "";
            this[_currentValidatorMethodName](_tableElement);
        }
    } // !class
}
