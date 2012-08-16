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
	import UnitTest.Fixtures.FileRepository;

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	import flash.xml.*;

	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;

	import spark.components.Group;
	import spark.components.RichText;
	use namespace tlf_internal;

	import mx.managers.SystemManager;
	import flashx.textLayout.elements.DivElement;

 	public class MXMLCompilationTest extends VellumTestCase
	{
		private var listRequest:URLRequest  = new URLRequest("./mxmlTestApps/fileList.txt");
		private var listLoader:URLLoader=new URLLoader();
		private var markupLoader:URLLoader=new URLLoader();
		private var swfLloader:Loader;
		private var ldrContext:LoaderContext;
		private var fileArray:Array = new Array();
		private var testFile:String;
		private var context:LoaderContext;
		//private var baseURL:String;

		public function MXMLCompilationTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			//baseURL = testConfig.baseURL ;
			super("LoadSWF", testConfig, testCaseXML);
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			if((testConfig.writingDirection[0]=="tb")&&(testConfig.writingDirection[1]=="ltr"))
				ts.addTestDescriptor(new TestDescriptor(MXMLCompilationTest, "mxmlCompilationTest", testConfig));
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			if((testConfig.writingDirection[0]=="tb")&&(testConfig.writingDirection[1]=="ltr"))
			{
				var testCaseClass:Class = MXMLCompilationTest;
				VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
			}
		}

		public function LoadSWF():void
		{
			var swfFile:String = (TestData.testFile as String).replace(".xml","") + ".swf";

			swfLloader = new Loader();
			var func:Function = addAsync(onLoadSWFComplete, 10000, null);
			swfLloader.contentLoaderInfo.addEventListener(Event.COMPLETE,  func, false, 0, true);
			swfLloader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, func, false, 0, true);
			swfLloader.load(new URLRequest("./mxmlTestApps/"+swfFile));
		}

		private function onLoadSWFComplete (event:Event):void
		{
			assertTrue("Error loading swf",!(event is ErrorEvent));
			var swfResult:String = TextConverter.export(event.target.loader.content.textExample.content as TextFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String

			var swfUrl:String = event.target.url as String;
			var markupFile:String = swfUrl.substr( swfUrl.lastIndexOf("/")+1,swfUrl.length).replace(".swf","") + ".xml";
			var markup:XML = FileRepository.getFileAsXML(baseURL, markupFile);

			var group:Group = new Group();
			var richText:RichText = new RichText();
			richText.x=10;
			richText.y=10;
			richText.height=600;
			richText.width=800;
			group.addElement(richText);
			var flow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			richText.content = flow;
			var markupResult:String = TextConverter.export(richText.content as TextFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;

			assertTrue(TestData.testFile + " mxml compilation", markupResult == swfResult);
		}
	}
}
