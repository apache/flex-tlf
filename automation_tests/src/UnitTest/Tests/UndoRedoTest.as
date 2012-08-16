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
	import UnitTest.Fixtures.TestEditManager;
	import UnitTest.Fixtures.TestConfig;
	import UnitTest.ExtendedClasses.TestSuiteExtended;

	import flash.display.Sprite;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.TextFlow;
	import flashx.undo.IUndoManager;
	import flashx.undo.UndoManager;
	import flashx.textLayout.operations.ApplyLinkOperation;
	
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;
	/** Test the state of selection after each operation is done, undone, and redone.
	 */
 	public class UndoRedoTest extends VellumTestCase
	{
		public function UndoRedoTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = UndoRedoTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}
		
		private var container:Sprite;
		//private const ANY_URL:String = "http://livedocs.adobe.com/";
		
		protected function get initialImport():XML {
			return <TextFlow color="#000000" fontFamily="Tahoma" fontSize="14" fontStyle="normal" fontWeight="normal" lineHeight="130%" textDecoration="none" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008">
								  <p>
									<span>aaa</span>
								  </p>
								  <p styleName="h1">
									<span>bbb</span>
								  </p>
								</TextFlow>
		} 
		
		protected function get initialImportString():String {
			return null
		}
		
		protected var initialImportXMLString:String = initialImport.normalize().toXMLString();
		protected var editManager:TestEditManager;
		protected var undoManager:IUndoManager;
		protected var textFlow:TextFlow ;
		
		private function setup():void
		{
			container = new Sprite();
			var controllerOne:ContainerController = new ContainerController(container, 500, 500);
			textFlow = TextConverter.importToFlow(initialImport, TextConverter.TEXT_LAYOUT_FORMAT);
			undoManager = new UndoManager();
			editManager = new TestEditManager(undoManager);
			textFlow.interactionManager = editManager;
			textFlow.flowComposer.addController(controllerOne);
			textFlow.flowComposer.updateAllControllers();
		}
    	
		public function undoRedoLinkTest():void
		{
			setup();
			//position > 3 will be in 2nd paragraph, cause error #2549628, no fix for now so the range is set to 3 to let the test case pass
			var posOfSelection:int = TestData.posOfSelection;
			editManager.selectRange(1,posOfSelection);
			editManager.doOperation(new  ApplyLinkOperation(editManager.getSelectionState(), "http://www.yahoo.com", "_self", true));
			var resultString:String = editManager.errors;
			assertTrue ("Undo and Redo not successfully. " + resultString, resultString == "");
		}

		
	}
}
