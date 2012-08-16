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

	import flash.accessibility.AccessibilityImplementation;
	import flash.display.Sprite;
	import flash.events.IMEEvent;
	import flash.system.Capabilities;
	import flash.text.ime.IIMEClient;

	import flashx.textLayout.accessibility.TextAccImpl;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextLineRecycler;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.GlobalSettings;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;

	import mx.containers.Canvas;

	use namespace tlf_internal;

	public class AccessibilityMethodsTest extends VellumTestCase
	{
		private var textFlow:TextFlow;
		private var container:Sprite;

		public function AccessibilityMethodsTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super(methodName, testID, testConfig);
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
   			ts.addTestDescriptor (new TestDescriptor (AccessibilityMethodsTest, "selectionReportingTests", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (AccessibilityMethodsTest, "searchIndexTests", testConfig ) );
			if (Configuration.versionIsAtLeast(10,1))
			{
   				ts.addTestDescriptor (new TestDescriptor (AccessibilityMethodsTest, "textReportingTests", testConfig ) );
   				ts.addTestDescriptor (new TestDescriptor (AccessibilityMethodsTest, "textSelectTests", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (AccessibilityMethodsTest, "multiParaTest", testConfig ) );
			}
		}

		override public function setUp() : void
		{
			cleanUpTestApp();
			TestDisplayObject = testApp.getDisplayObject();
			createTextFlow(getFileData("simple.xml"));
			TestFrame = textFlow.flowComposer.getControllerAt(0);	//pacify assert in tearDown
		}

		override public function tearDown():void
		{
			super.tearDown();
			if (container.parent)		// this should've been done already
				container.parent.removeChild(container);
			container = null;
			textFlow = null;
		}

		private function createTextFlow(flowData:Object):void
		{
			// We need to create a new TextFlow even if there's a cached one so that we set it up with the correct Configuration
			var configuration:Configuration = TextFlow.defaultConfiguration.clone();
			configuration.enableAccessibility = true;
			textFlow = TextConverter.importToFlow(flowData, TextConverter.TEXT_LAYOUT_FORMAT, configuration);

			// Add a container to attach the accessibility object onto.
			container = new Sprite();
			textFlow.flowComposer.addController(new ContainerController(container, 300, 300));
			var testCanvas:Canvas = testApp.getDisplayObject();
			testCanvas.rawChildren.addChild(container);
		}

		private function getAccessibilityImplementation():AccessibilityImplementation
		{
			// Hack! The accessibilityImplementation may not be on the container if the Player does
			// not detect that accessibility is turned on in the OS/browser. We want the test to run
			// even in that case, so we push the accessibility implementation in anyway. If accessibility
			// is turned on, we should not hit this case -- accImpl should be there already
			if (container.accessibilityImplementation == null &&
				 textFlow.flowComposer.getControllerAt(0).container == container)
			{
				assertTrue("Accessibility object wasn't added to container", !flash.system.Capabilities.hasAccessibility);
				container.accessibilityImplementation = new TextAccImpl(container, textFlow);
			}

			return container.accessibilityImplementation;
		}
   		/**
		 */

		public function selectionReportingTests():void
		{

			var accessibilityObject:AccessibilityImplementation = getAccessibilityImplementation();

			//start with no interaction - should return false
			textFlow.interactionManager = null;

			//we no longer have a selection manager, so there should be no selection.  Make sure
			//that we report -1 for anchor and active.
			assertTrue("selectionActiveIndex should report -1 when there is no Manager or EditingMode is READ_ONLY!", accessibilityObject["selectionActiveIndex"] == -1);
			assertTrue("selectionAnchorIndex should report -1 when there is no Manager or EditingMode is READ_ONLY!", accessibilityObject["selectionAnchorIndex"] == -1);

			textFlow.interactionManager = new SelectionManager();
			textFlow.interactionManager.selectRange(25, 50);
			assertTrue("selectionActiveIndex should report 50 but is " + accessibilityObject["selectionActiveIndex"], accessibilityObject["selectionActiveIndex"] == 50);
			assertTrue("selectionAnchorIndex should report 25 but is "+ accessibilityObject["selectionAnchorIndex"], accessibilityObject["selectionAnchorIndex"] == 25);
			assertTrue("selectionActiveIndex should match. SelMgr reports " + textFlow.interactionManager.activePosition +
				 " but container reports " + accessibilityObject["selectionActiveIndex"], textFlow.interactionManager.activePosition == accessibilityObject["selectionActiveIndex"]);
			assertTrue("selectionAnchorIndex should match. SelMgr reports " + textFlow.interactionManager.anchorPosition +
				 " but container reports " + accessibilityObject["selectionAnchorIndex"], textFlow.interactionManager.anchorPosition == accessibilityObject["selectionAnchorIndex"]);

			textFlow.interactionManager = new EditManager();
			textFlow.interactionManager.selectRange(15, 10);
			assertTrue("selectionActiveIndex should report 10 but is " + accessibilityObject["selectionActiveIndex"], accessibilityObject["selectionActiveIndex"] == 10);
			assertTrue("selectionAnchorIndex should report 15 but is "+ accessibilityObject["selectionAnchorIndex"], accessibilityObject["selectionAnchorIndex"] == 15);
			assertTrue("selectionActiveIndex should match. EditMgr reports " + textFlow.interactionManager.activePosition +
				 " but container reports " + accessibilityObject["selectionActiveIndex"], textFlow.interactionManager.activePosition == accessibilityObject["selectionActiveIndex"]);
			assertTrue("selectionAnchorIndex should match. EditMgr reports " + textFlow.interactionManager.anchorPosition +
				 " but container reports " + accessibilityObject["selectionAnchorIndex"], textFlow.interactionManager.anchorPosition == accessibilityObject["selectionAnchorIndex"]);
		}


		private function createIMEClient():IIMEClient
		{
			// We're mimicing an IME startComposition event, so that we can get an IME client. But under pre-Argo (10.1) players,
			// there is no imeStartComposition event, so in that case we can't return
			var imeEvent:IMEEvent = new IMEEvent("imeStartComposition");
			// figure out which controller we're targetting and set focus on it so the ime event will be received
			var i:int;
			for (i = 0; i < textFlow.flowComposer.numControllers && textFlow.flowComposer.getControllerAt(i).container != container; ++i)
			{
				// empty loop: prevent compiler warning
			}
			if (textFlow.interactionManager)
				textFlow.interactionManager.selectRange(-1, -1);
			textFlow.flowComposer.getControllerAt(i).setFocus();
			container.dispatchEvent(imeEvent);
			if (imeEvent["imeClient"] !== undefined)
				return imeEvent["imeClient"];
			return null;
		}

		public function textReportingTests():void
		{
			// Construct an IMEClient just for testing its getTextInRange in isolation.
			var editManager:EditManager = new EditManager();
			textFlow.interactionManager = editManager;
			var imeClient:IIMEClient = createIMEClient();

			//textFlow.textLength includes all para terminators.  However, we dont' include the final one for the last
			//paragraph when getting text - since there may not be a carriage return on it
			var textLen:int = textFlow.textLength - 1;

			var totalText:String = imeClient.getTextInRange(-1, -1);
			assertTrue("getTextInRange with default values should get all text in the Flow, but only got " + totalText.length
				+ " characters out of " + textLen + ".", totalText.length == textLen);

			var para:ParagraphElement = textFlow.getFirstLeaf().getParagraph();
			var paraEnd:int = para.textLength - 1;
			var selEnd:int = 64 < paraEnd ? 64 : paraEnd;
			var selStart:int = selEnd >= 10 ? selEnd - 10 : 0;
			var expectedLen:int = selEnd - selStart;

			//assert that we have legit values.
			CONFIG::debug{ assert(selStart != selEnd, "We need to have text to make this test work!  Where did it go!?")};

			var subText:String = imeClient.getTextInRange(selStart, selEnd);
			var outOfOrderText:String = imeClient.getTextInRange(selEnd, selStart);
			assertTrue("getTextInRange with values (" + selStart + ", " + selEnd + ") should have a text length of " + expectedLen
				 + " but is " + subText.length,subText.length == expectedLen);
			assertTrue("getTextInRange with values (" + selEnd + ", " + selStart + ") should have a text length of " + expectedLen
				 + " but is " + outOfOrderText.length, outOfOrderText.length == expectedLen);

			assertTrue("getTextInRange with values both in and out of order should have the same text!",
				outOfOrderText == subText);

			//get text directly from paragraph.  Since this is the first one, the absolute positions and relative positions should match
			var paraText:String = para.getText().substring(selStart, selEnd);
			assertTrue("getTextInRange did not report the same text as the paragraph!  paraText is \'" + paraText
				+ "\' while result is \'" + subText + "\'.", paraText == subText);

			//get text from second paragraph
			var nextPara:ParagraphElement = para.getNextParagraph();
			if(nextPara)
			{
				var nextAbsStart:int = nextPara.getAbsoluteStart();
				//remember that nextPara.textLength includes the para terminator mark, which will
				//be included in this calculation.  When we pull the paragraph text, we need to decrement the
				//value by 1 to prevent a false negative as getText will not include the terminator.
				selStart = nextAbsStart + nextPara.textLength - 26;
				selEnd = selStart + 25;
				subText = imeClient.getTextInRange(selStart, selEnd);

				//make sure that it is 1 < the absStart.  See note above
				var nextParaText:String = nextPara.getText().substring(selStart - nextAbsStart, selEnd - nextAbsStart);
				assertTrue("getTextInRange did not report the same text as the paragraph!  nextParaText is \'" + nextParaText
				+ "\' while result is \'" + subText + "\'.", nextParaText == subText);

				//perform tests accross para boundaries
				selStart = nextAbsStart - 20;
				selEnd = nextAbsStart + 20;
				var boundaryText:String = imeClient.getTextInRange(selStart, selEnd);

				assertTrue("getTextInRange across boundaries should be 40, but is " + boundaryText.length, boundaryText.length == 40);

				//again, in first para, absolute is same as local indicies - substring - all chars up to endIdx, so CR is not included,
				//which means we only compare the first 19 glyphs of boundaryText
				var firstBoundaryText:String = para.getText().substring(selStart, selStart + 20);
				assertTrue("getTextInRange across boundaries did not report the same text as the first paragraph!  paraText is \'" + firstBoundaryText
				+ "\' while result is \'" + boundaryText.substr(0, 19) + "\'.", firstBoundaryText == boundaryText.substr(0, 19));

				var secondBoundaryText:String = nextPara.getText().substring(0, 20);
				//use a start idx of 20 so we skip the CR
				assertTrue("getTextInRange across boundaries did not report the same text as the second paragraph!  paraText is \'" + secondBoundaryText
				+ "\' while result is \'" + boundaryText.substr(20, 20) + "\'.", secondBoundaryText == boundaryText.substr(20, 20));

			}


			//now do negative tests and make sure we fail properly
			var nullText:String = imeClient.getTextInRange(-2, 0);
			assertTrue("getTextInRange should return null with an invalid startIndex!", nullText == null);

			nullText = imeClient.getTextInRange(0, -23);
			assertTrue("getTextInRange should return null with an invalid endIndex!", nullText == null);

			nullText = imeClient.getTextInRange(textLen + 1, 1);
			assertTrue("getTextInRange should return null with a startIndex > the text length!", nullText == null);

			nullText = imeClient.getTextInRange(0, textLen + 1);
			assertTrue("getTextInRange should return null with an endIndex > the text length!", nullText == null);

			editManager.endIMESession();
		}

		public function searchIndexTests():void
		{
			var accessibilityObject:AccessibilityImplementation = getAccessibilityImplementation();

			var saveEnableSearch:Boolean = GlobalSettings.enableSearch;

			// Turn search index on and check the length and content of the result
			GlobalSettings.enableSearch = true;
			var entireContent:String = accessibilityObject["searchText"];
			assertTrue("length of searchText should match TextFlow length, got " + entireContent.length.toString + " expected " + (textFlow.textLength - 1).toString, entireContent.length == textFlow.textLength - 1);
			var checkContent:String = TextConverter.export(textFlow, TextConverter.PLAIN_TEXT_FORMAT, ConversionType.STRING_TYPE) as String;
			assertTrue("expected content of searchText to match exported plain text", entireContent == checkContent);

			// Turn search index off and check that we get nothing
			GlobalSettings.enableSearch = false;
			entireContent = accessibilityObject["searchText"];
			assertTrue("enableSearchIndex is off, but searchText return result", entireContent == null || entireContent.length == 0);

			GlobalSettings.enableSearch = saveEnableSearch;
		}

		public function textSelectTests():void
		{
			//start with no interaction - should return false
			textFlow.interactionManager = null;
			var imeClient:IIMEClient = createIMEClient();
			assertTrue("imeClient should be null on read-only textFlow", imeClient == null);

			// try a SelectionManager (read-only) should return null
			textFlow.interactionManager = new SelectionManager();
			imeClient = createIMEClient();
			assertTrue("imeClient should be null on read-select textFlow", imeClient == null);

			// Construct an IMEClient just for testing its selectRange in isolation.
			var editManager:EditManager = new EditManager();
			textFlow.interactionManager = editManager;
			imeClient = createIMEClient();
			imeClient.selectRange(15, 10);
			assertTrue("selectionActiveIndex should report 15 but is " + imeClient.selectionActiveIndex, imeClient.selectionActiveIndex == 10);
			assertTrue("selectionAnchorIndex should report 10 but is "+ imeClient.selectionAnchorIndex, imeClient.selectionAnchorIndex == 15);

			editManager.endIMESession();
		}

		private const Markup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' fontSize='14' " +
				"textIndent='0' paragraphSpaceBefore='6' paddingTop='4' paddingBottom='4' fontFamily='Times New Roman'>" +
				"<flow:p paragraphSpaceAfter='15' >" +
					"<flow:span>There are many </flow:span>" +
					"<flow:span fontStyle='italic'>such</flow:span>" +
					"<flow:span> lime-kilns in that tract of country, for the purpose of burning the white" +
						"himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. " +
						"It is a lonesome, and, when the character is inclined to thought, may be an intensely " +
						"thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such " +
						"strange purpose, in days gone by, while the fire in this very kiln was burning.</flow:span>" +
				"</flow:p>" +
				"<flow:p paragraphSpaceAfter='15'>" +
					"<flow:span>" +
						"The man who now watched the fire was of a different order, and troubled himself with no " +
						"trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, " +
						"there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, " +
						"though thus far down into the valley the sunshine had vanished long and long ago.</flow:span>" +
				"</flow:p>" +
				"<flow:p paragraphSpaceAfter='15'>" +
					"<flow:span>" +
						"The man who now watched the fire was of a different order, and troubled himself with no " +
						"trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, " +
						"there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, " +
						"though thus far down into the valley the sunshine had vanished long and long ago.</flow:span>" +
				"</flow:p>" +
				"<flow:p paragraphSpaceAfter='15'>" +
					"<flow:span>" +
						"The man who now watched the fire was of a different order, and troubled himself with no " +
						"trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, " +
						"there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, " +
						"though thus far down into the valley the sunshine had vanished long and long ago.</flow:span>" +
				"</flow:p>" +
				"<flow:p paragraphSpaceAfter='15'>" +
					"<flow:span>" +
						"The man who now watched the fire was of a different order, and troubled himself with no " +
						"trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, " +
						"there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, " +
						"though thus far down into the valley the sunshine had vanished long and long ago.</flow:span>" +
				"</flow:p>" +
				"<flow:p paragraphSpaceAfter='15'>" +
					"<flow:span>" +
						"The man who now watched the fire was of a different order, and troubled himself with no " +
						"trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, " +
						"there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, " +
						"though thus far down into the valley the sunshine had vanished long and long ago.</flow:span>" +
				"</flow:p>" +
				"<flow:p paragraphSpaceAfter='15'>" +
					"<flow:span>" +
						"The man who now watched the fire was of a different order, and troubled himself with no " +
						"trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, " +
						"there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, " +
						"though thus far down into the valley the sunshine had vanished long and long ago.</flow:span>" +
				"</flow:p>" +
				"<flow:p paragraphSpaceAfter='15'>" +
					"<flow:span>" +
						"The man who now watched the fire was of a different order, and troubled himself with no " +
						"trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, " +
						"there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, " +
						"though thus far down into the valley the sunshine had vanished long and long ago.</flow:span>" +
				"</flow:p>" +
			"</flow:TextFlow>";

		private var TestCanvas:Canvas = null;

		public function multiParaTest():void
		{
			cleanUpTestApp();
			var posOfSelection:int = TestData.posOfSelection;
			var format:TextLayoutFormat = new TextLayoutFormat();
			format = new TextLayoutFormat();
			format.paddingLeft = 20;
			format.paddingRight = 20;
			format.paddingTop = 20;
			format.paddingBottom = 20;

			createTextFlow(Markup);
			textFlow.flowComposer = new StandardFlowComposer();
			var editManager:EditManager = new EditManager();
        	textFlow.interactionManager = editManager;

        	format.firstBaselineOffset = "auto";
			editManager.applyContainerFormat(format);
			editManager.applyFormatToElement(editManager.textFlow,format);
			editManager.selectRange(0, 0);

			//create two containers
			container = new Sprite();
			var container2:Sprite = new Sprite();
			var controllerOne:ContainerController = new ContainerController(container, 200, 500);
			var controllerTwo:ContainerController = new ContainerController(container2, 200, 500);

			addToCanvas(container);
			addToCanvas(container2);
			container.x = 50;
			container.y = 50;
			container2.x = 300;
			container2.y = 50;

			// add the controllers to the text flow and update them to display the text
			textFlow.flowComposer.addController(controllerOne);
			textFlow.flowComposer.addController(controllerTwo);
			textFlow.flowComposer.updateAllControllers();

			var accessibilityObject:AccessibilityImplementation = getAccessibilityImplementation();

			textFlow.interactionManager = new SelectionManager();
			textFlow.interactionManager.selectRange(200, 2000);
			assertTrue("selectionActiveIndex should report 2000 but is " + accessibilityObject["selectionActiveIndex"], accessibilityObject["selectionActiveIndex"] == 2000);
			assertTrue("selectionAnchorIndex should report 200 but is "+ accessibilityObject["selectionAnchorIndex"], accessibilityObject["selectionAnchorIndex"] == 200);
			assertTrue("selectionActiveIndex should match. SelMgr reports " + textFlow.interactionManager.activePosition +
				 " but container reports " + accessibilityObject["selectionActiveIndex"], textFlow.interactionManager.activePosition == accessibilityObject["selectionActiveIndex"]);
			assertTrue("selectionAnchorIndex should match. SelMgr reports " + textFlow.interactionManager.anchorPosition +
				 " but container reports " + accessibilityObject["selectionAnchorIndex"], textFlow.interactionManager.anchorPosition == accessibilityObject["selectionAnchorIndex"]);

			textFlow.interactionManager = new EditManager();
			textFlow.interactionManager.selectRange(200, 2000);
			assertTrue("selectionActiveIndex should report 2000 but is " + accessibilityObject["selectionActiveIndex"], accessibilityObject["selectionActiveIndex"] == 2000);
			assertTrue("selectionAnchorIndex should report 200 but is "+ accessibilityObject["selectionAnchorIndex"], accessibilityObject["selectionAnchorIndex"] == 200);
			assertTrue("selectionActiveIndex should match. EditMgr reports " + textFlow.interactionManager.activePosition +
				 " but container reports " + accessibilityObject["selectionActiveIndex"], textFlow.interactionManager.activePosition == accessibilityObject["selectionActiveIndex"]);
			assertTrue("selectionAnchorIndex should match. EditMgr reports " + textFlow.interactionManager.anchorPosition +
				 " but container reports " + accessibilityObject["selectionAnchorIndex"], textFlow.interactionManager.anchorPosition == accessibilityObject["selectionAnchorIndex"]);

			// Construct an IMEClient just for testing its getTextInRange in isolation.
			var imeClient:IIMEClient = createIMEClient();

			var textLen:int = textFlow.textLength - 1;
			var totalText:String = imeClient.getTextInRange(-1, -1);
			assertTrue("getTextInRange with default values should get all text in the Flow, but only got " + totalText.length
				+ " characters out of " + textLen + ".", totalText.length == textLen);


			var firstPara:ParagraphElement = textFlow.getFirstLeaf().getParagraph();
			var secondPara:ParagraphElement = firstPara.getNextParagraph();
			var thirdPara:ParagraphElement = secondPara.getNextParagraph();
			var fourthPara:ParagraphElement = thirdPara.getNextParagraph();
			var secondParaStart:int = secondPara.getAbsoluteStart();
			var thirdParaEnd:int = fourthPara.getAbsoluteStart() - 1;
			var subText:String = imeClient.getTextInRange(secondParaStart, thirdParaEnd);
			var paraText:String = secondPara.getText() + '\n' + thirdPara.getText();
			var paraLength:int = paraText.length;
			var subLength:int = subText.length;
			var secondParaLength:int = secondPara.textLength;

			assertTrue("getTextInRange did not report the same text as the paragraph!  paraText is \'" + paraText
				+ "\' while result is \'" + subText + "\'.", paraText.length == subText.length);
			assertTrue("getTextInRange did not report the same text as the paragraph!  paraText is \'" + paraText
				+ "\' while result is \'" + subText + "\'.", paraText == subText);
			EditManager(textFlow.interactionManager).endIMESession();

			//start with no interaction - should return false
			textFlow.interactionManager = null;

			//we no longer have a selection manager, so there should be no selection.  Make sure
			//that we report -1 for anchor and active.
			assertTrue("textSelectTests should report -1 when there is no Manager or EditingMode is READ_ONLY!", accessibilityObject["selectionActiveIndex"] == -1);
			assertTrue("textSelectTests should report -1 when there is no Manager or EditingMode is READ_ONLY!", accessibilityObject["selectionAnchorIndex"] == -1);

			textFlow.interactionManager = new SelectionManager();
			textFlow.interactionManager.selectRange(200, 2000);
			assertTrue("selectionActiveIndex should report 2000 but is " + accessibilityObject["selectionActiveIndex"], accessibilityObject["selectionActiveIndex"] == 2000);
			assertTrue("selectionAnchorIndex should report 200 but is "+ accessibilityObject["selectionAnchorIndex"], accessibilityObject["selectionAnchorIndex"] == 200);


			textFlow.interactionManager = new EditManager();
			textFlow.interactionManager.selectRange(20, 2000);
			assertTrue("selectionActiveIndex should report 2000 but is " + accessibilityObject["selectionActiveIndex"], accessibilityObject["selectionActiveIndex"] == 2000);
			assertTrue("selectionAnchorIndex should report 200 but is "+ accessibilityObject["selectionAnchorIndex"], accessibilityObject["selectionAnchorIndex"] == 20);

		}

		private function addToCanvas(sprite:Sprite):void
		{
			TestDisplayObject = testApp.getDisplayObject();
			if (TestDisplayObject is Canvas)
				Canvas(TestDisplayObject).rawChildren.addChild(sprite);
		}



	}
}
