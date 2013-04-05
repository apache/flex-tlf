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
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.system.*;
	import flash.text.*;
	import flash.text.engine.*;
	import flash.ui.*;
	import flash.utils.*;
	import flash.xml.*;
	
	import flashx.textLayout.elements.*;
	import flashx.textLayout.property.*;
	import flashx.textLayout.tlf_internal;
	
	import mx.containers.Canvas;
	import mx.utils.LoaderUtil;

	public class SWFTest extends VellumTestCase
	{
		public function SWFTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);
		}
		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = SWFTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

		public var ldr:Loader;
		public var load_file:String;
		public var thing1:Sprite = new Sprite();

		public function LoadTestSWF():void
        {
			load_file = TestData.swf;
			ldr = new Loader();
			ldr.load(new URLRequest(LoaderUtil.createAbsoluteURL(baseURL,"../../asPrivateTestApps/bin/" + load_file)));
			var func:Function = addAsync(validateLoad, 10000, null);
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,  func, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, func, false, 0, true);
		}
		
		public function validateLoad(e:Event):void
		{
			// If privateTestApps doesn't exist, then don't error.
			// There are some tests that rely on embedded fonts we can't distribute.
			if (!(e is ErrorEvent))
			{
				var canvas:Canvas = testApp.getDisplayObject();
				canvas.rawChildren.addChild(thing1);
				
				thing1.addChild(ldr);
				var result:String = ldr.content["validateTest"]();
				assertTrue (result, result=="");
			}
		}
		
		public function TextLayoutFormatInspectable():void
		{ load_file = TestData.swf; LoadInspectableTest("../../asTestApps/bin/" + load_file); }
		public function TabStopFormatInspectable():void
		{ load_file = TestData.swf; LoadInspectableTest("../../asTestApps/bin/" + load_file); }
		
		private function LoadInspectableTest(fileName:String):void
		{
			ldr = new Loader();
			ldr.load(new URLRequest(LoaderUtil.createAbsoluteURL(baseURL,fileName)));
			var func:Function = addAsync(validateInspectableLoad, 10000, null);
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,  func, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, func, false, 0, true);
		}
		
		public function validateInspectableLoad(e:Event):void
		{
			assertTrue("Error loading inspectable swf:" + e.toString(),!(e is ErrorEvent));
			var canvas:Canvas = testApp.getDisplayObject();
			canvas.rawChildren.addChild(thing1);
			
			// can causes a preloader failure
			thing1.addChild(ldr);
			
			ldr.content["validate"]();
		}
		
		private var exceptionList:Array;
		
		/** Load a dependency checking swf */
		private function loadDC(exceptions:Array):void
		{
			load_file = TestData.swf;
			ldr = new Loader();
			// load these into a separate application domain
			var loaderContext:LoaderContext = new LoaderContext(false, new ApplicationDomain());
			ldr.load(new URLRequest(LoaderUtil.createAbsoluteURL(baseURL,"../../asPrivateTestApps/bin/" + load_file)),loaderContext);
			var func:Function = addAsync(validateLoadDC, 10000, null);
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,  func, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, func, false, 0, true);
			exceptionList = exceptions;
		}
		
		/** This is for a known compiler bug.  The event metadata on TextFlow causes these classes to be included in the final SWF. 
		 * Remove this when http://bugs.adobe.com/jira/browse/ASC-4092 is fixed. */
		static private var DCCoreOnlyExceptions:Array = [
			"flashx.textLayout.events.FlowOperationEvent",
			"flashx.textLayout.events.SelectionEvent",
			"flashx.textLayout.edit.IEditManager",
			"flashx.textLayout.edit.TextScrap",
			"flashx.textLayout.edit.EditManager",
			"flashx.textLayout.edit.ElementRange",
			"flashx.textLayout.edit.ElementMark",
			"flashx.textLayout.edit.IMemento",
			"flashx.textLayout.edit.Mark",
			"flashx.textLayout.edit.ModelEdit",
			"flashx.textLayout.edit.SelectionManager",
			"flashx.textLayout.operations.ApplyFormatOperation",
			"flashx.textLayout.operations.ApplyFormatToElementOperation",
			"flashx.textLayout.operations.ApplyLinkOperation",
			"flashx.textLayout.operations.ApplyTCYOperation",
			"flashx.textLayout.operations.ApplyElementIDOperation",
			"flashx.textLayout.operations.ClearFormatOperation",
			"flashx.textLayout.operations.ClearFormatOnElementOperation",
			"flashx.textLayout.operations.CreateListOperation",
			"flashx.textLayout.operations.CreateSubParagraphGroupOperation",
			"flashx.textLayout.operations.CompositeOperation",
			"flashx.textLayout.operations.CopyOperation",
			"flashx.textLayout.operations.CutOperation",
			"flashx.textLayout.operations.DeleteTextOperation",
			"flashx.textLayout.operations.FlowOperation",
			"flashx.textLayout.operations.InsertInlineGraphicOperation",
			"flashx.textLayout.operations.InsertTextOperation",
			"flashx.textLayout.operations.MoveChildrenOperation",
			"flashx.textLayout.operations.PasteOperation",
			"flashx.textLayout.operations.RedoOperation",
			"flashx.textLayout.operations.SplitParagraphOperation",
			"flashx.textLayout.operations.SplitElementOperation",
			"flashx.textLayout.operations.UndoOperation",
			"flashx.textLayout.conversion.ITextImporter",
			"flashx.textLayout.conversion.ITextExporter",
			"flashx.textLayout.conversion.TextConverter",
			"flashx.textLayout.conversion.TextLayoutImporter",
			"flashx.textLayout.container.TextContainerManager",
			"flashx.textLayout.utils.NavigationUtil",
			"flashx.undo.IOperation",
			"flashx.undo.IUndoManager",
			"flashx.undo.UndoManager"
			];
		
		public function LoadDCCoreOnly():void
		{ loadDC(DCCoreOnlyExceptions); }

		public function LoadDCCoreConversionOnly():void
		{ loadDC(DCCoreOnlyExceptions); }
		
		public function LoadDCCoreSelectionManagerOnly():void
		{ loadDC(DCCoreOnlyExceptions); }
		
		public function validateLoadDC(e:Event):void
		{
			// If privateTestApps doesn't exist, then don't error.
			// There are some tests that rely on embedded fonts we can't distribute.
			if (!(e is ErrorEvent))
			{
				var canvas:Canvas = testApp.getDisplayObject();
				canvas.rawChildren.addChild(thing1);
				
				thing1.addChild(ldr);
				var result:String = ldr.content["validateTest"](exceptionList);
				assertTrue (result, result=="");
			}
		}

		public override function tearDown():void
		{
			if (thing1.parent)
			{
				var canvas:Canvas = testApp.getDisplayObject();
				canvas.rawChildren.removeChild(thing1);
			}
			super.tearDown();
		}
	}
}
