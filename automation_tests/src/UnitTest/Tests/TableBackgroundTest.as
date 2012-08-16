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
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.elements.BackgroundManager;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TableDataCellElement;
	import flashx.textLayout.elements.TableElement;
	import flashx.textLayout.elements.TableRowElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;
	
	import mx.containers.Canvas;
	
	use namespace tlf_internal;
	
	public class TableBackgroundTest extends VellumTestCase
	{
		private var _tf:TextFlow;
		private var _tab:TableElement;
		private var _canvas:Canvas;
		private var _c1:Sprite;
		private var _cc1:ContainerController;
		private var _c2:Sprite;
		private var _cc2:ContainerController;
		private var _c3:Sprite;
		private var _cc3:ContainerController;
		
		public function TableBackgroundTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);
		}
		
		override public function setUp():void
		{
			// TODO Auto Generated method stub
			super.setUp();
			_canvas = VellumTestCase.testApp.getDisplayObject() as Canvas;
		}
		
		
		override public function tearDown():void
		{	
			super.tearDown();
		}
		
		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			ts.addTestDescriptor (new TestDescriptor (TableBackgroundTest,"tableAcrossColumnsAndContainers", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (TableBackgroundTest,"tableScrolling", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (TableBackgroundTest,"tableEditing", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (TableBackgroundTest,"tableInTCMScrolling", testConfig, null) );
			ts.addTestDescriptor (new TestDescriptor (TableBackgroundTest,"tableInTCMEditing", testConfig, null) );
		}
		
		public function tableInTCMScrolling():void
		{
			createTCM();
			createTextFlow();
			var arColWidth:Array = ["20%", "30%", "30%", "20%"];
			createTable(30, 4, arColWidth, 5, 2, 0x000000, 0xff2299, 2, 0x000000, 0xffff00);
			insertParagraph(1);
			_tf.addChild(_tab);
			_tf.addChild(createParagraph());
			var tcm:TextContainerManager = new TextContainerManager(_c1);
			tcm.compositionWidth = 800;
			tcm.compositionHeight = 300;
			_tf.columnCount = 4;
			tcm.setTextFlow(_tf);
			tcm.updateContainer();
			var rects:Array = BackgroundManager.BACKGROUND_MANAGER_CACHE[_tf];
			assertTrue("Background drawing is incorrect before scrolling in TCM.", countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 96
				&& countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 4);
			//Scroll to bottom, then all rects should be recorded
			tcm.verticalScrollPosition += 1000;
			rects = _tf.backgroundManager.getShapeRectArray();
			assertTrue("Background drawing is incorrect after scrolling in TCM.", countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 120
				&& countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 4);
			//All rects should be recorded
			for(var i:int = 0; i < 15; i++)
			{
				var j:int;
				if(i >= 10)
					j = 10 - i;
				else
					j = i
				tcm.horizontalScrollPosition += j*40;
				assertTrue("Background drawing is incorrect after scrolling in TCM.", countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 120
					&& countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 4);
			}
		}
		
		public function tableInTCMEditing():void
		{
			createTCM();
			createTextFlow();
			var arColWidth:Array = ["20%", "30%", "30%", "20%"];
			createTable(30, 4, arColWidth, 5, 2, 0x000000, 0xff2299, 2, 0x000000, 0xffff00);
			insertParagraph(1);
			_tf.addChild(_tab);
			_tf.addChild(createParagraph());
			var tcm:TextContainerManager = new TextContainerManager(_c1);
			tcm.compositionWidth = 800;
			tcm.compositionHeight = 300;
			_tf.columnCount = 4;
			tcm.setTextFlow(_tf);
			tcm.updateContainer();
			var em:EditManager = new EditManager();
			_tf.interactionManager = em;
			//Scroll to enable StandardFlowComposer in TCM, or insertText() cannot work
			tcm.verticalScrollPosition += 10;
			var rects:Array = _tf.backgroundManager.getShapeRectArray();
			var i:int;
			//All rects should be recorded when being edited
			//Edit before table
			em.insertText("在前面输入一行让它换行，在前面输入一行让它换行，在前面输入一行让它换行。",new SelectionState(_tf,0,0));
			assertTrue("Background drawing is incorrect when editing before table in TCM.", countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 92
				&& countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 4);
			em.deleteText(new SelectionState(_tf,0,25));
			assertTrue("Background drawing is incorrect when editing before table in TCM.", countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 92
				&& countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 4);
			//Edit within table
			for(i = 0; i < 10; i++)
			{
				em.insertText("a",new SelectionState(_tf,250,250));
				assertTrue("Background drawing is incorrect when editing within table in TCM.", countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 92
					&& countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 4);
			}
			em.deleteText(new SelectionState(_tf,250,260));
			assertTrue("Background drawing is incorrect when editing within table in TCM.", countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 92
				&& countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 4);
			//Edit after table
			tcm.verticalScrollPosition += 1000;
			for(i = 0; i < 5; i++)
			{
				em.insertText("a",new SelectionState(_tf,_tf.textLength - 1,_tf.textLength - 1));
				assertTrue("Background drawing is incorrect when editing after table in TCM.", countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 120
					&& countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 4);
			}
			em.deleteText(new SelectionState(_tf,_tf.textLength - 1,_tf.textLength - 6));
			assertTrue("Background drawing is incorrect when editing after table in TCM.", countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 120
				&& countRects(rects, Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 4);
		}
		
		public function tableEditing():void
		{
			createScrollableContainersWithColumns();
			createTextFlow();
			var arColWidth:Array = ["25%", "25%", "25%", "80"];
			createTable(30, 4, arColWidth, 5, 2, 0x000000, 0xff2299, 2, 0x000000, 0xffff00);
			_tf.addChild(_tab);	
			insertParagraph(2);
			_tf.flowComposer.addController(_cc1);
			_tf.flowComposer.addController(_cc2);
			_tf.flowComposer.updateAllControllers();
			var em:EditManager = new EditManager();
			_tf.interactionManager = em;
			//Before editing
			assertTrue("Background drawing is incorrect before editing.", 
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) == 68
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 3
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) ==3
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) == 52
			);
			//Edit before table
			var i:int = 0;
			em.insertText("在前面输入一行让它换行，在前面输入一行让它换行，在前面输入一行让它换行。",new SelectionState(_tf,0,0));
			assertTrue("Background drawing is incorrect when editing before table.", 
					countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) == 64
					&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 3
					&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) ==3
					&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) >= 52
			);
			em.deleteText(new SelectionState(_tf,0,50));
			assertTrue("Background drawing is incorrect before editing.", 
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) == 68
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 3
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) ==3
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) == 52
			);
			//Edit within table
			for(i = 0; i < 10; i++)
			{
				em.insertText("a",new SelectionState(_tf,250,250));
				assertTrue("Background drawing is incorrect when editing within table.", 
					countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) >= 56
					&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 3
					&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) ==3
					&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) >= 52
				);
			}
			em.deleteText(new SelectionState(_tf,250,260));
			assertTrue("Background drawing is incorrect when editing within table.", 
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) == 68
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 3
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) ==3
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) == 52
			);
			//Edit after table
			_tf.addChild(createParagraph());
			_tf.flowComposer.updateAllControllers();
			for(i = 0; i < 5; i++)
			{
				em.insertText("a",new SelectionState(_tf,_tf.textLength - 1,_tf.textLength - 1));
				assertTrue("Background drawing is incorrect when editing after table.", 
					//countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) >= 56
					//&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 3 &&
					countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) ==3
					&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) == 52
				);
			}
			em.deleteText(new SelectionState(_tf,_tf.textLength - 1,_tf.textLength - 6));
			assertTrue("Background drawing is incorrect when editing within table.", 
				//countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) == 68
				//&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 3 &&
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) ==3
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) == 52
			);
		}
		
		public function tableScrolling():void
		{
			createScrollableContainersWithColumns();
			createTextFlow();
			var arColWidth:Array = ["25%", "25%", "25%", "80"];
			createTable(100, 4, arColWidth, 5, 2, 0x000000, 0xff2299, 2, 0x000000, 0xffff00);
			_tf.addChild(_tab);	
			_tf.flowComposer.addController(_cc1);
			_tf.flowComposer.addController(_cc2);
			_tf.flowComposer.updateAllControllers();
			//Before scrolling
			assertTrue("Background drawing is incorrect before scrolling.", 
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) == 72
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 3
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) ==3
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) == 72
			);
			//Scroll downward and upward several times
			for(var i:int = 0; i < 20; i++)
			{
				var j:int;
				if(i >= 10)
					j = 10 - i;
				else
					j = i
				_cc2.verticalScrollPosition += j*30;
				var numTable:int = countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2);
				var numCell:int = countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2);
				assertTrue("Background drawing is incorrect when scrolling.", numTable >=1 && numTable<= 3 && numCell >= 72 && numCell <= 328);
			}
		}
		
		public function tableAcrossColumnsAndContainers():void
		{
			create3ContainersWithColumns();
			createTextFlow();
			var arColWidth:Array = ["30%", "20%", "20%", "80", "70"];
			createTable(10, 4, arColWidth, 5, 2, 0x000000, 0xff2299, 2, 0x000000, 0xffff00);
			_tf.addChild(_tab);
			_tf.flowComposer.addController(_cc1);
			_tf.flowComposer.addController(_cc2);
			_tf.flowComposer.addController(_cc3);
			_tf.flowComposer.updateAllControllers();
			_tf.interactionManager = new EditManager();
			//Across single column
			assertTrue("Background drawing is incorrect when crossing single column.", 
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 40
			&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 2 
			);
			insertParagraph(10);
			_tf.flowComposer.updateAllControllers();
			//Across two columns
			assertTrue("Background drawing is incorrect when crossing columns.", 
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 40
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 3 
			);
			insertParagraph(10);
			_tf.flowComposer.updateAllControllers();
			//Across one column and one container
			assertTrue("Background drawing is incorrect when crossing columns and containers.", 
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement"))) == 40
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement"))) == 3 
			);
			insertParagraph(1);
			_tf.flowComposer.updateAllControllers();
			//Across one column and one container and just move one line down
			assertTrue("Background drawing is incorrect when crossing columns and containers.", 
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) == 32
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 2 
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) == 4
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) == 1
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc3) == 4
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc3) == 1
			);
			insertParagraph(10);
			_tf.flowComposer.updateAllControllers();
			//Across two container
			assertTrue("Background drawing is incorrect when crossing columns and containers.", 
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) == 16
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 1 
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) == 4
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) == 1
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc3) == 8
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc3) == 2
			);
			insertParagraph(5);
			_tf.flowComposer.updateAllControllers();
			//Containers cannot hold table completely
			assertTrue("Background drawing is incorrect when crossing columns and containers.", 
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) == 8
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 1 
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) == 4
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) == 1
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc3) == 8
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc3) == 2
			);
			
			//Roll back one step
			deleteParagraphFrombeginning(5);
			_tf.flowComposer.updateAllControllers();
			assertTrue("Background drawing is incorrect when crossing columns and containers.", 
				countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc1) == 16
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc1) == 1 
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc2) == 4
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc2) == 1
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableDataCellElement")), _cc3) == 8
				&& countRects(_tf.backgroundManager.getShapeRectArray(), Class(getDefinitionByName("flashx.textLayout.elements.TableElement")), _cc3) == 2
			);
		}
		
		private function countRects(total:Array, limit:Class, controller:ContainerController = null):int
		{
			var rectCounter:int = 0;
			for each (var o:Object in total)
			{
				if(o.elem is limit && (controller == null || controller == o.cc))
					rectCounter ++;
			}
			return rectCounter;
		}
		
		private function createTextFlow():TextFlow
		{
			if(_tf)
			{
				for each(var e:FlowElement in _tf)
				_tf.removeChild(e);
			}
			else
				_tf = new TextFlow();
			return _tf;
		}
		
		private function createTable(row:int, col:int, widths:Array, cellspacing:int = 0, cellBorderWidth:int = 0, cellBorderColor:* = "transparent", 
									 cellBackgroundColor:* = "transparent", tableBorderWidth:int = 0, tableBorderColor:* = "transparent", tableBackgroundColor:* = "transparent"):TableElement
		{
			_tab = new TableElement();
			_tab.initTableElement(row, col);
			_tab.setBorderWidth(tableBorderWidth);
			_tab.cellSpacing = cellspacing;
			if(tableBorderColor is uint)
				_tab.setBorderColor(tableBorderColor);
			_tab.backgroundColor = tableBackgroundColor;
			for(var r:int = 0; r < row; r++)
			{
				var tableRow:TableRowElement = new TableRowElement();
				_tab.addChild(tableRow);
				for(var c:int = 0; c < col; c++)
				{
					var cell:TableDataCellElement = new TableDataCellElement();
					cell.addChild(createParagraph());
					cell.setBorderWidth(cellBorderWidth);
					if(cellBorderColor is uint)
						cell.setBorderColor(cellBorderColor);
					cell.backgroundColor = cellBackgroundColor;
					tableRow.addChild(cell);
				}
			}
			
			for ( var i:uint = 0; i < _tab.column; i ++ )
			{
				_tab.setColumnWidth(i, widths[i]);
			}
			
			return _tab;
		}
		private function insertParagraph(num:int):void
		{
			for(var i:int = 0; i < num; i++)
				_tf.addChildAt(0,createParagraph());
		}
		
		private function deleteParagraphFrombeginning(num:int):void
		{
			for(var i:int = 0; i < num; i++)
				_tf.removeChildAt(0);
		}
		
		private function createParagraph():ParagraphElement
		{
			var para:ParagraphElement = new ParagraphElement();
			var span:SpanElement = new SpanElement();
			para.addChild(span);
			span.text = "Text String";
			return para;
		}
		
		private function create3ContainersWithColumns():void
		{
			_canvas = emptyChilds();
			_c1 = new Sprite();
			_c1.x = 10;
			_c1.y = 50;
			_canvas.rawChildren.addChild(_c1);
			_cc1 = new ContainerController(_c1, 800, 200);
			_cc1.columnCount = 3;
			
			_c2 = new Sprite();
			_c2.x = 10;
			_c2.y = 250;
			_canvas.rawChildren.addChild(_c2);
			_cc2 = new ContainerController(_c2, 800, 50);
			
			_c3 = new Sprite();
			_c3.x = 10;
			_c3.y = 350;
			_canvas.rawChildren.addChild(_c3);
			_cc3 = new ContainerController(_c3, 800, 50);
			_cc3.columnCount = 2;
		}
		
		private function createScrollableContainersWithColumns():void
		{
			_canvas = emptyChilds();
			_c1 = new Sprite();
			_c1.x = 10;
			_c1.y = 50;
			_canvas.rawChildren.addChild(_c1);
			_cc1 = new ContainerController(_c1, 800, 200);
			_cc1.columnCount = 3;
			
			_c2 = new Sprite();
			_c2.x = 10;
			_c2.y = 250;
			_canvas.rawChildren.addChild(_c2);
			_cc2 = new ContainerController(_c2, 800, 200);
			_cc2.columnCount = 3;
			_cc2.verticalScrollPolicy = ScrollPolicy.AUTO;
		}
		
		private function createTCM():void
		{
			_canvas = emptyChilds();
			_c1 = new Sprite();
			_c1.x = 10;
			_c1.y = 50;
			_canvas.rawChildren.addChild(_c1);
		}
		
		private function emptyChilds():Canvas
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
	}
}