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
	
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	
	import mx.containers.Canvas;


 	public class FactoryImportTest extends VellumTestCase
	{
		private var ItemsToRemove:Array;
		private var TestCanvas:Canvas = null;
		private var fileForFactory:String;
		private var flowFromXML:TextFlow;

		public function FactoryImportTest(fileToImport:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super ("doThis", testID, testConfig, testCaseXML);
			containerType = "custom";
			fileForFactory = fileToImport;

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Import/Export";
		}

		public function doThis():void
		{
			var xmlRoot:XML = FileRepository.getFileAsXML(baseURL,"../../test/testFiles/markup/tlf/" + fileForFactory);
			if (!xmlRoot)
			{
				fail("File not loaded -- timeout?");
				return;
			}
			var parser:ITextImporter = testDataImportParser;
			flowFromXML = parser.importToFlow(xmlRoot);
			processInlines(flowFromXML);
			buildVellumFactory();
			//TestCanvas.rawChildren.addChild(_rslt);
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = FactoryImportTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

		override public function setUp() : void
		{
			cleanUpTestApp();
			ItemsToRemove = [];
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

		private static function getExtension(fileName:String):String
		{
			var dotPos:int = fileName.lastIndexOf(".");
			if (dotPos >= 0)
				return fileName.substring(dotPos + 1);
			return fileName;
		}

		protected function get testDataImportParser():ITextImporter
		{
			var extension:String = getExtension(fileForFactory);
			if (extension == "xml")
				extension = TextConverter.TEXT_LAYOUT_FORMAT;
			else if (extension == "txt")
				extension = TextConverter.PLAIN_TEXT_FORMAT;
			return TextConverter.getImporter(extension);
		}
		
		private function processInlines(textFlow:TextFlow):void
		{
			for (var leaf:FlowLeafElement = textFlow.getFirstLeaf(); leaf; leaf = leaf.getNextLeaf())
			{
				if (leaf is InlineGraphicElement /* && InlineGraphicElement(leaf).source == null */)
				{
					var ilg:InlineGraphicElement = InlineGraphicElement(leaf);

					// Create a filler inline, simple filled rect
					var displayObject:Sprite = new Sprite();
					var g:Graphics = displayObject.graphics;
					g.beginFill(0xFF0000);
					g.drawRect(0, 0, Number(ilg.width), Number(ilg.height));
					g.endFill();
					ilg.source = displayObject;
				}
			}
		}

		public function callback(dispObj:DisplayObject):void
		{
			TestCanvas.rawChildren.addChild(dispObj);

			if(dispObj is TextLine)
			{
				ItemsToRemove.push (dispObj as TextLine);
			}
		}
		/** use the vellum factory via the callback */
		public function buildVellumFactory():void //DisplayObject
		{
			var factory:TextFlowTextLineFactory = new TextFlowTextLineFactory();
			factory.compositionBounds = new Rectangle(0, 0, TestCanvas.width, TestCanvas.height);
			factory.createTextLines(callback,flowFromXML);
		}
	}
}
