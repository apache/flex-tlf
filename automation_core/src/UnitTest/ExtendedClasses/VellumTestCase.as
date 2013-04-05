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
package UnitTest.ExtendedClasses
{
	import UnitTest.Fixtures.FileRepository;
	import UnitTest.Fixtures.TestApp;
	import UnitTest.Fixtures.TestConfig;
	import UnitTest.Validation.BoundsChecker;
	import UnitTest.Validation.LineSnapshot;
	import UnitTest.Validation.MD5;
	import UnitTest.Validation.StringSnapshot;
	import UnitTest.Validation.TCMComposition;
	import UnitTest.Validation.XMLSnapshot;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.EditingMode;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;
	
	import flexunit.framework.TestCase;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.skins.Border;


	public class VellumTestCase extends TestCase
	{
		//public static var app:VellumUnit = Application.application as VellumUnit;
		public static var testApp:TestApp;
		public var TestID:String;
		public var TestData:Object;
		public var TestFrame:ContainerController;
		public var TestDisplayObject:DisplayObject;
		public var SelManager:EditManager;
		public var containerType:String;
		public var writingDirection:Array;
		public var useEmbeddedFonts:Boolean;
		public var baseURL:String;		// baseURL for loading files
		public var doBeforeAfterCompare:Boolean;
		public var diffTolerance:Number;

		public var bitmapBaseline:Bitmap;
		public var lineBaseline:XML;
		public var plaintextBaseline:String;
		public var xflBaseline:XML;
		public var htmlBaseline:XML;

		//checksum for the baseline
		public var bitmapBaselineChecksum:String = null;
		public var lineBaselineChecksum:String = null;
		public var plaintextBaselineChecksum:String = null;
		public var xflBaselineChecksum:String = null;
		public var htmlBaselineChecksum:String = null;

		//checksum for the snapshot
		public var bitmapSnapshotChecksum:String = null;
		public var lineSnapshotChecksum:String = null;
		public var plaintextSnapshotChecksum:String = null;
		public var xflSnapshotChecksum:String = null;
		public var htmlSnapshotChecksum:String = null;

		//result link for the failed snapshot
		public static var snapAdminServerUrl:String = "";
		public var runID:Number;

		public var fileName:String = null;
		public var beforeData:BitmapData = null;
		public var afterData:Bitmap = null;

		public var bitmapSnapshot:Bitmap = null;
		public var lineSnapshot:XML = null;
		public var plaintextSnapshot:String = null;
		public var xflSnapshot:XML = null;
		public var htmlSnapshot:XML = null;


		public var TCMCompositionResult:Boolean = true;
		public var bitmapResult:Boolean = true;
		public var lineResult:Boolean = true;
		public var plaintextResult:Boolean = true;
		public var xflResult:Boolean = true;
		public var htmlResult:Boolean = true;

		private var failString:String = "";
		private var endOfSetupTime:Number;
		
		protected var addDefaultTestSettings:Boolean;

		private static var useRandom:Boolean = false;
		private static var LineSnapshotUtils:LineSnapshot = new LineSnapshot();
		private static var XMLSnapshotUtils:XMLSnapshot = new XMLSnapshot();
		private static var StringSnapshotUtils:StringSnapshot = new StringSnapshot();

		public function VellumTestCase(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML = null)
		{
			TestData = new Object();

			// set defaults to some items in TestData - these can be overridden
			// in a specific test case's constructor or in an XML file
			TestData.bitmapSnapshot = "false";
			TestData.lineSnapshot = "false";
			TestData.xflSnapshot = "false";
			TestData.minimal = "true";

			if (testCaseXML)
			{
				for each (var testDataXML:XML in testCaseXML.*)
				{
					TestData[testDataXML.@name] = testDataXML.toString();
				}
			}

			if (TestData["bitmapSnapshotTolerance"] != null)
				diffTolerance = TestData["bitmapSnapshotTolerance"];
			else
				diffTolerance = 0.001;

			writingDirection = testConfig.writingDirection;
			containerType = testConfig.containerType;
			doBeforeAfterCompare = testConfig.doBeforeAfterCompare;
			useEmbeddedFonts = testConfig.useEmbeddedFonts;
			baseURL = testConfig.baseURL;
			addDefaultTestSettings = true;

			TestID = testID;

			super (methodName);

		}

		public static function suiteFromXML(testCaseClass:Class, testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
		{
  			var writingDirection:String = testConfig.writingDirection[0] + "_" + testConfig.writingDirection[1];
			for each (var testCaseXML:XML in testListXML.*)
			{
				var testFile:String = testCaseXML.TestData.(@name == "testFile").toString();
				if (testFile != "")
				{
					var extension:String = getExtension(testFile);
					var folderName:String = "";
					if (extension == "html")
						folderName = "html/";
					else if (extension == "txt")
						folderName = "plainText/";
					else
						folderName = "tlf/";
					FileRepository.readFile(testConfig.baseURL, "../../test/testFiles/markup/" + folderName + testFile);
				}
				if ((testCaseXML.TestData.(@name == writingDirection).toString() != "false") &&
					(testCaseXML.TestData.(@name == testConfig.containerType).toString() != "false") &&
					(testCaseXML.TestData.(@name == testConfig.flashVersion) != "false"))
				{
					ts.addTestDescriptor (new TestDescriptor (testCaseClass, testCaseXML.@functionName, testConfig, testCaseXML));
				}
			}
		}

		static public var defaultFileName:String = "simple.xml";
		static private var DEFAULT_COMPOSITION_WIDTH:Number = 826;
		static private var DEFAULT_COMPOSITION_HEIGHT:Number = 477;

		/** start every test with nothing on the canvas
		 */
		public function cleanUpTestApp() : void
		{
			testApp.detachActiveFlow(true);
			var canvas:Canvas = testApp.getDisplayObject();
			// remove everything but the Border
			for (var i:int = canvas.rawChildren.numChildren - 1; i >= 0; i--)
				if (!(canvas.rawChildren.getChildAt(i) is Border))
					canvas.rawChildren.removeChildAt(i);
		}

		override public function setUp() : void
		{
			//trace("Beginning test: " + TestID);

			// Make sure whatever was left from last test is cleared
			cleanUpTestApp();

			testApp.contentChange(null);
			testApp.setInteractionManager(EditingMode.READ_WRITE);
			testApp.changeContainerSetup("arrangeSideBySide", 0, 1);

	//		if (TestData.requiresLayout == "true")
	//		{
	//			trace ("-----------set up layout-enabled container here-----------");
	//		}

			fileName = TestData.fileName == undefined ? defaultFileName : TestData.fileName;

			loadTestFile(fileName);

			TestFrame = TextFlow(testApp.getTextFlow()).flowComposer.getControllerAt(0);
			TestDisplayObject = testApp.getDisplayObject();

			// all of this should eventually go away, but some tests are depending
			// on it at the moment.  I'm assuming that:
			// 1. Container attributes should either stay the default, or these
			//    attributes should get put into the default file.
			// 2. Tests that depend on scrolling being off should do that themselves
			// 3. Writing direction for the default file should be handled in loadTestFile.
			if (fileName == defaultFileName && addDefaultTestSettings)
			{
		 		// set the container attributes to the same as those in the Flex TextContainer (see the flow:TextContaienr below)
		 		var containerAttr:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
		 		containerAttr.columnCount = 2;
	 			containerAttr.columnGap = 10;
	 			//containerAttr.paddingLeft = 4;
	 			containerAttr.paddingRight = 4;
	 			//containerAttr.paddingTop = 4;
	  			TestFrame.horizontalScrollPolicy = ScrollPolicy.OFF;
	 			TestFrame.verticalScrollPolicy = ScrollPolicy.OFF;
	  			TestFrame.format = containerAttr;
	 			containerAttr = null;
				if (TestFrame.compositionWidth != DEFAULT_COMPOSITION_WIDTH || TestFrame.compositionHeight != DEFAULT_COMPOSITION_HEIGHT)
					TestFrame.setCompositionSize(DEFAULT_COMPOSITION_WIDTH, DEFAULT_COMPOSITION_HEIGHT);

			}

			// Set the writing direction specified by the test
			if (fileName == defaultFileName && TestFrame.rootElement)
			{
				TestFrame.rootElement.blockProgression = writingDirection[0];
				TestFrame.rootElement.direction        = writingDirection[1];
			}
			
			TextFlow(testApp.getTextFlow()).flowComposer.updateAllControllers();

			if (TestFrame.rootElement)
			{
				SelManager = EditManager(TestFrame.rootElement.getTextFlow().interactionManager);
				if(SelManager)
				{
					setSelectionRange();
					//make sure there is never any blinking when running these tests
					setCaretBlinkRate (0);
				}
			}
			//endOfSetupTime = getTimer();
		}

		override public function tearDown() : void
		{
		//	trace ("Beginning of teardown.");

			if (TestFrame && TestFrame.flowComposer)
				TestFrame.flowComposer.updateAllControllers();

			//middleDuration = (getTimer() - endOfSetupTime);

			// generic validation
			// note: why must the selectionmanager be active?
			if (SelManager)
			{
				assertTrue ("teardown assert for active SelectionManager failed", SelManager.hasSelection());
				CONFIG::debug
				{
					assertTrue("teardown assert for SelManager.debugCheckSelectionManager() failed", SelManager.debugCheckSelectionManager() == 0);
					assertTrue("teardown assert for SelManager.textFlow.debugCheckTextFlow() failed", SelManager.textFlow.debugCheckTextFlow() == 0);
				}
			}

			if (containerType == "sprite")
				assertTrue ("TestFrame should be a Sprite, but is not", TestFrame.container is Sprite);


			//Only run this test if VellumUnit is set to do it.
			if (doBeforeAfterCompare)
			{
				var tempSelManager:EditManager = new EditManager();
				var fFormat:SelectionFormat = SelManager.focusedSelectionFormat;
				var nfFormat:SelectionFormat = SelManager.unfocusedSelectionFormat;
				var inFormat:SelectionFormat = SelManager.inactiveSelectionFormat;
				tempSelManager.focusedSelectionFormat = new SelectionFormat(fFormat.rangeColor, fFormat.rangeAlpha, fFormat.rangeBlendMode, fFormat.pointColor, fFormat.pointAlpha, fFormat.pointBlendMode, 1000);
				tempSelManager.unfocusedSelectionFormat = new SelectionFormat(nfFormat.rangeColor, nfFormat.rangeAlpha, nfFormat.rangeBlendMode, nfFormat.pointColor, nfFormat.pointAlpha, nfFormat.pointBlendMode, 1000);
				tempSelManager.inactiveSelectionFormat = new SelectionFormat(inFormat.rangeColor, inFormat.rangeAlpha, inFormat.rangeBlendMode, inFormat.pointColor, inFormat.pointAlpha, inFormat.pointBlendMode, 1000);

				var TestCanvas:Canvas = testApp.getDisplayObject();
				var curTextFlow:TextFlow = TextFlow(testApp.getTextFlow());

				var TCMCompositionUtils:TCMComposition = new TCMComposition(TestCanvas, curTextFlow);
				TCMCompositionUtils.Height = testApp.getDisplayObject().height;
				TCMCompositionUtils.Width = testApp.getDisplayObject().width;
				TCMCompositionResult = TCMCompositionUtils.compare();

				if (!TCMCompositionResult)
				{
					failString += " TextContainerManager composition: " + TCMCompositionUtils.ErrorString;
				}

				SelManager = tempSelManager;
			}

			if (TestData.bitmapSnapshot == true)
			{
				// Create the afterData snapshot.
				if (TestDisplayObject is mx.core.UIComponent)
					mx.core.UIComponent(TestDisplayObject).validateNow();
				var bits:BitmapData = new BitmapData(TestDisplayObject.width, TestDisplayObject.height);
				bits.draw(TestDisplayObject as IBitmapDrawable);
				bitmapSnapshot = new Bitmap(bits);
				bits = null;

				var pixels:ByteArray = bitmapSnapshot.bitmapData.getPixels(bitmapSnapshot.bitmapData.rect);
				pixels.compress();
				pixels.position = 0;
				bitmapSnapshotChecksum = MD5.hashBinary(pixels);

				// If there is a baseline, then run a compare. If not, (gcai) we'll report an error about what's wrong there.
				//bitmapResult = true;
				if (bitmapBaseline != null)
				{
					if(bitmapSnapshotChecksum != bitmapBaselineChecksum)
					{
						// If the checksum is different, do the bitmap compare of the two bitmaps to make the diffTolerance enabled.
						bitmapBaseline.bitmapData.draw(bitmapSnapshot, null, null, "difference");
						var diffPixels:ByteArray = bitmapBaseline.bitmapData.getPixels(bitmapBaseline.bitmapData.rect);
						diffPixels.position = 0;
						var pixelCount:uint = diffPixels.bytesAvailable;
						var diffCount:uint = 0;
						var redDiff:uint = 0;
						var greenDiff:uint = 0;
						var blueDiff:uint = 0;
						var componentTolerance:uint = 20;
						
						while (diffPixels.bytesAvailable > 0)
						{
							// throw away alpha
							diffPixels.readUnsignedByte();
							
							redDiff = diffPixels.readUnsignedByte();
							greenDiff = diffPixels.readUnsignedByte();
							blueDiff = diffPixels.readUnsignedByte();
							
							// only count pixels where the difference is visible
							if (redDiff > componentTolerance || greenDiff > componentTolerance || blueDiff > componentTolerance)
							{
								// previously we'd count the number of pixels that were different
								//diffCount ++;
								// now we're summing the amount of the differences - so a small number of very different
								// pixels will error, but only a large number of slightly different pixels will error
								diffCount += redDiff + greenDiff + blueDiff
							}
							
							redDiff = 0;
							greenDiff = 0;
							blueDiff = 0;
						}

						// If this is larger than the tolerance, then something changed and it is a bug.
						// previous pixel count threshold
						//bitmapResult = (((diffCount/(pixelCount/4))*100) < diffTolerance);
						// new summed differences threshold
						bitmapResult = diffCount < (pixelCount/4)*diffTolerance*255*3;
						//trace ("  TestID: " + TestID + " count: "+ diffCount + " threshold: " + (pixelCount/4)*diffTolerance*255);

						if (!bitmapResult)
						{
							failString += "Bitmap data snapshot differed from the baseline. Detail:"+getUrl("Bitmap");
							failString += "  Bitmap compare failed by " + ((diffCount/pixelCount)*100) + " percent of pixels compared.";
						}
     				}
				}
				else
				{
					bitmapResult = false;
					failString += "Don't have any bitmap baseline for current case. Detail:"+getUrl("Bitmap");
				}
			}

			if (TestData.lineSnapshot == true)
			{
				lineSnapshot = LineSnapshotUtils.takeSnapshot(TestFrame.rootElement.getTextFlow());
				var lineDataBytes:ByteArray = new ByteArray();
				lineSnapshot.normalize();
				lineDataBytes.writeObject (lineSnapshot);
				lineDataBytes.compress();
				lineDataBytes.uncompress();
				lineSnapshot = new XML(lineDataBytes.readObject());
				lineSnapshot.normalize();

				lineSnapshotChecksum = getChecksum(lineSnapshot);
				// Do a compare as long as there is a baseline.
				if (lineBaseline != null)
				{
					if(lineSnapshotChecksum != lineBaselineChecksum)
					{
						lineResult = XMLSnapshotUtils.compareAdvanced(lineBaseline, lineSnapshot);
						if (!lineResult)
						{
							failString += "  , Line data snapshot differed from the baseline. Detail:"+getUrl("Line");
						}
					}
				}
				else
				{
					lineResult = false;
					failString += " , Don't have any line baseline for current case. Detail:"+getUrl("Line");
				}
			}

			if (TestData.plaintextSnapshot == true)
			{
				plaintextSnapshot = StringSnapshotUtils.takeSnapshot(TestFrame.rootElement.getTextFlow(), TextConverter.PLAIN_TEXT_FORMAT);
				plaintextSnapshotChecksum = MD5.hash(plaintextSnapshot);
				// Do a compare as long as there is a baseline.
				if (plaintextBaseline != null)
				{
					if(plaintextSnapshotChecksum != plaintextBaselineChecksum)
					{
						plaintextResult = StringSnapshotUtils.compare(plaintextBaseline, plaintextSnapshot);
						if (!plaintextResult)
						{
							failString += "  , PlainText data snapshot differed from the baseline. Detail:" + getUrl("PlainText");
						}
					}
				}
				else
				{
					plaintextResult = false;
					failString += " , Don't have any PlainText baseline for current case. Detail:"+getUrl("PlainText");
				}
			}

			if (TestData.xflSnapshot == true)
			{
				xflSnapshot = XMLSnapshotUtils.takeSnapshot(TestFrame.rootElement.getTextFlow(), TextConverter.TEXT_LAYOUT_FORMAT);
				xflSnapshotChecksum = getChecksum(xflSnapshot);
				// Do a compare as long as there is a baseline.
				if (xflBaseline != null)
				{
					if(xflSnapshotChecksum != xflBaselineChecksum)
					{
						xflResult = XMLSnapshotUtils.compareAdvanced(xflBaseline, xflSnapshot);
						if (!xflResult)
						{
							failString += "  , XFL data snapshot differed from the baseline. Detail:" + getUrl("XFL");
						}
					}
				}
				else
				{
					xflResult = false;
					failString += " , Don't have any xfl baseline for current case. Detail:"+getUrl("XFL");
				}
			}

			if (TestData.htmlSnapshot == true)
			{
				htmlSnapshot = XMLSnapshotUtils.takeSnapshot(TestFrame.rootElement.getTextFlow(), TextConverter.TEXT_FIELD_HTML_FORMAT);
				htmlSnapshotChecksum = getChecksum(htmlSnapshot);
				// Do a compare as long as there is a baseline.
				if (htmlBaseline != null)
				{
					if(htmlBaselineChecksum != htmlSnapshotChecksum)
					{
						htmlResult = XMLSnapshotUtils.compareAdvanced(htmlBaseline, htmlSnapshot);
						if (!htmlResult)
						{
							failString += "  , HTML data snapshot differed from the baseline. Detail:"+getUrl("HTML");
						}
					}
				}
				else
				{
					htmlResult = false;
					failString += " , Don't have any HTML baseline for current case. Detail:"+getUrl("HTML");
				}
			}

		//	Comment this code in to enable bounds checking on each test. 
		/*	if (TestFrame && TestFrame.textFlow)
			{
				var s:Sprite = new Sprite();
				testApp.getDisplayObject().rawChildren.addChild(s);
				BoundsChecker.boundsValidation(TestFrame.textFlow, s);
				testApp.getDisplayObject().rawChildren.removeChild(s);
			} */


			//	trace ("Ending test: " + TestID);

			//*****************************************************
			if (SelManager)
			{
				//turn caret blinking back on
				setCaretBlinkRate (1000);
			}
			// Nulls for garbage collection
			TestFrame = null;
			SelManager = null;
	//		trace ("End of teardown.");
			
			
			// This code breaks snapshotting of XML - need to move the disposeXML calls somewhere else
			/*if (Configuration.playerEnablesArgoFeatures)
				System["disposeXML"](lineSnapshot);
			lineSnapshot = null;
			plaintextSnapshot = null;
			if (Configuration.playerEnablesArgoFeatures)
				System["disposeXML"](xflSnapshot);
			xflSnapshot = null;
			if (Configuration.playerEnablesArgoFeatures)
				System["disposeXML"](htmlSnapshot);
			htmlSnapshot = null;*/

			
			// The assert makes it end the test, so we need to put that at the very
			// end of everything, so that all snapshot tests get a chance to run.
			assertTrue (failString, ((TCMCompositionResult) && (bitmapResult) && (lineResult) && (xflResult) && (htmlResult)));
//				fail(failString);
		}

		private function getUrl(snapShotType:String):String
		{
			return snapAdminServerUrl+"runid="+runID+";caseid="+TestID+";snapshottype="+snapShotType;
		}

		private function getChecksum(file:XML):String
		{
			var dataBytes:ByteArray = new ByteArray();
			dataBytes.writeObject (file);
			dataBytes.compress();
			dataBytes.position = 0;

			return MD5.hashBinary(dataBytes);
		}

		override public function toString():String
		{
			return TestID;
		}

		private function getRandomInteger(start:int, end:int):int
			// Return a random number between start and end
		{
			var num:Number = Math.random();
			return Math.ceil((num * (end - start)) + start);
		}

		private function setSelectionRange():void
		{
			if (useRandom)
			{
				var startIdx:int = getRandomInteger(0, SelManager.textFlow.textLength);
				var endIdx:int = getRandomInteger(0, SelManager.textFlow.textLength);
				if (startIdx > endIdx)
				{
					var tmp:int = startIdx;
					startIdx = endIdx;
					endIdx = tmp;
				}
				SelManager.selectRange(startIdx, endIdx);
			}
			else
			{
				if(SelManager.textFlow.textLength > 60){
					SelManager.selectRange(22, 60);
				}else{
					SelManager.selectRange(0, SelManager.textFlow.textLength / 2);
				}
			}
		}

		public function setCaretBlinkRate (caretBlinkRate:int):void
		{
			var fFormat:SelectionFormat = SelManager.focusedSelectionFormat;
			var nfFormat:SelectionFormat = SelManager.unfocusedSelectionFormat;
			var inFormat:SelectionFormat = SelManager.inactiveSelectionFormat;
			SelManager.focusedSelectionFormat = new SelectionFormat(fFormat.rangeColor, fFormat.rangeAlpha, fFormat.rangeBlendMode, fFormat.pointColor, fFormat.pointAlpha, fFormat.pointBlendMode, caretBlinkRate);
			SelManager.unfocusedSelectionFormat = new SelectionFormat(nfFormat.rangeColor, nfFormat.rangeAlpha, nfFormat.rangeBlendMode, nfFormat.pointColor, nfFormat.pointAlpha, nfFormat.pointBlendMode, caretBlinkRate);
			SelManager.inactiveSelectionFormat = new SelectionFormat(inFormat.rangeColor, inFormat.rangeAlpha, inFormat.rangeBlendMode, inFormat.pointColor, inFormat.pointAlpha, inFormat.pointBlendMode, caretBlinkRate);
		}

		protected function get importParser():ITextImporter
		{
			var extension:String = getExtension(fileName);
			if (extension == "xml")
				extension = TextConverter.TEXT_LAYOUT_FORMAT;
			else if (extension == "txt")
				extension = TextConverter.PLAIN_TEXT_FORMAT;
			else if (extension == "html")
				extension = TextConverter.TEXT_FIELD_HTML_FORMAT;
			return TextConverter.getImporter(extension);
		}

		public static function getExtension(fileName:String):String
		{
			var dotPos:int = fileName.lastIndexOf(".");
			if (dotPos >= 0)
				return fileName.substring(dotPos + 1);
			return fileName;
		}

  		public function importContent (content:Object):void
		{
			var beginTime:int = getTimer();
			//TestFrame.removeAllChildren();
			var parser:ITextImporter = importParser;
			var textFlow:TextFlow = parser.importToFlow(content);

			setUpFlowForTest(textFlow);
		}

		public function setUpFlowForTest(textFlow:TextFlow):void
		{
			textFlow.flowComposer = null;
			testApp.contentChange (textFlow);

			TestFrame = TextFlow(testApp.getTextFlow()).flowComposer.getControllerAt(0);
			if (TestFrame.rootElement)
			{
				SelManager = EditManager(TestFrame.rootElement.getTextFlow().interactionManager);
				if(SelManager) setSelectionRange();
			}

			if (textFlow.flowComposer)
				textFlow.flowComposer.compose();
		}


		public function getFileData(fileName:String):Object
		{
			var fileData:Object; // XML or String

			var extension:String = getExtension(fileName);
			if (extension == "html")
				fileData = FileRepository.getFile(baseURL, "../../test/testFiles/markup/html/" + fileName);
			else if (extension == "txt")
				fileData = FileRepository.getFile(baseURL, "../../test/testFiles/markup/plainText/" + fileName);
			else
				fileData = FileRepository.getFileAsXML(baseURL, "../../test/testFiles/markup/tlf/" + fileName);
			return fileData;
		}

		static private var cacheTestFile:TextFlow;
		public function loadTestFile (fileName:String):void
		{
			var containerFormat:TextLayoutFormat;

			if (fileName == defaultFileName && cacheTestFile != null)
			{
				var textFlow:TextFlow = cacheTestFile.deepCopy(0, cacheTestFile.textLength) as TextFlow;
				setUpFlowForTest(textFlow);
			}
			else
			{
				var fileData:Object = getFileData(fileName); // XML or String
				if (fileData is XML)
				{
					var flowNS:Namespace = fileData.namespace("flow");
					if (writingDirection[0] != "tb" && writingDirection[1] != "ltr")
					{
						fileData.flowNS::TextFlow.@blockProgression = writingDirection[0];
						fileData.flowNS::TextFlow.@direction = writingDirection[1];
					}
					if (useEmbeddedFonts)
					{
						fileData.flowNS::TextFlow.@fontLookup = "embeddedCff";
					}
				}
				importContent(fileData);
			}

			if (!cacheTestFile && fileName == defaultFileName)
			{
				var resultFlow:TextFlow = TestFrame.rootElement as TextFlow;
				cacheTestFile = resultFlow.deepCopy() as TextFlow;
			}
		}
	}
}
