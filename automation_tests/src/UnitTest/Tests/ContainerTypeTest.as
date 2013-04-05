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
	import UnitTest.Fixtures.TestConfig;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.*;
	import flash.text.engine.*;
	
	import flashx.textLayout.*;
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.EditingMode;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.utils.NavigationUtil;
	
	import mx.containers.Canvas;

	public class ContainerTypeTest extends VellumTestCase
	{
		private var TestCanvas:Canvas = null;
		private var ItemsToRemove:Array;
		private var hostFormat:TextLayoutFormat;

		private const Markup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' fontSize='14' " +
				"textIndent='0' paragraphSpaceBefore='6' paddingTop='4' paddingBottom='4'>" +
			"<flow:p paragraphSpaceAfter='15' >" +
				"<flow:span>There are many </flow:span>" +
				"<flow:span fontStyle='italic'>such</flow:span>" +
				"<flow:span> lime-kilns in that tract of country, for the purpose of burning the white" +
					" marble which composes a large part of the substance of the hills. Some of them, built " +
					"years ago, and long deserted, with weeds growing in the vacant round of the interior, " +
					"which is open to the sky, and grass and wild-flowers rooting themselves into the chinks " +
					"of the stones, look already like relics of antiquity, and may yet be overspread with the" +
					" lichens of centuries to come. Others, where the lime-burner still feeds his daily and " +
					"nightlong fire, afford points of interest to the wanderer among the hills, who seats " +
					"himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. " +
					"It is a lonesome, and, when the character is inclined to thought, may be an intensely " +
					"thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such " +
					"strange purpose, in days gone by, while the fire in this very kiln was burning.</flow:span>" +
			"</flow:p>" +
			"<flow:p paragraphSpaceAfter='15'>" +
				"<flow:span>" +
					"The man who now watched the fire was of a different order, and troubled himself with no " +
					"thoughts save the very few that were requisite to his business. At frequent intervals, " +
					"he flung back the clashing weight of the iron door, and, turning his face from the " +
					"insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a " +
					"long pole. Within the furnace were seen the curling and riotous flames, and the burning " +
					"marble, almost molten with the intensity of heat; while without, the reflection of the " +
					"fire quivered on the dark intricacy of the surrounding forest, and showed in the " +
					"foreground a bright and ruddy little picture of the hut, the spring beside its door, the " +
					"athletic and coal-begrimed figure of the lime-burner, and the halffrightened child, " +
					"shrinking into the protection of his father's shadow. And when again the iron door was " +
					"closed, then reappeared the tender light of the half-full moon, which vainly strove to " +
					"trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, " +
					"there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, " +
					"though thus far down into the valley the sunshine had vanished long and long ago.</flow:span>" +
			"</flow:p>" +
		"</flow:TextFlow>";

		public function ContainerTypeTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);
			//reset containerType and ID
			containerType = "custom";

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Container";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = ContainerTypeTest;
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

 		/**
		 * Have a single TextLine on the canvas instead of a vellum container
		 */
		public function singleTextLine():void
		{
			var cf:ElementFormat = new ElementFormat();
			cf.fontSize = 24
			var fd:FontDescription = new FontDescription("Times New Roman")
			cf.fontDescription = fd
			var te:TextElement = new TextElement("A TextLine on the Canvas",cf);
			var tb:TextBlock = new TextBlock();
			tb.content = te;
			var tl1:TextLine = tb.createTextLine(null,400);
			tl1.x = 50;
			tl1.y = 50;
			//need to keep track of what I've added in order to remove at teardown?
			TestCanvas.rawChildren.addChild(DisplayObject(tl1));
			ItemsToRemove.push (tl1);
			System.gc();System.gc();	//garbage collect at end so we can compare memory usage versus static lines
		}
 		/**
		 * Have ten TextLines on the canvas instead of a vellum container
		 */
		public function tenTextLines():void
		{
			for (var i:int = 0; i < 10; i++)
			{
				var cf:ElementFormat = new ElementFormat();
				cf.fontSize = 24
				var fd:FontDescription = new FontDescription("Times New Roman")
				cf.fontDescription = fd
				var te:TextElement = new TextElement("TextLine " + i,cf);
				var tb:TextBlock = new TextBlock();
				tb.content = te;
				var tl1:TextLine = tb.createTextLine(null,400);
				tl1.x = 40;
				tl1.y = 40 + (40 * i);
				//need to keep track of what I've added in order to remove at teardown?
				TestCanvas.rawChildren.addChild(DisplayObject(tl1));
				ItemsToRemove.push (tl1);
			}
			System.gc();System.gc();	//garbage collect at end so we can compare memory usage versus static lines
		}
		/**
		 * Have one hundred TextLines on the canvas instead of a vellum container
		 */
		public function oneHundredTextLines():void
		{
			for (var i:int = 0; i < 100; i++)
			{
				var cf:ElementFormat = new ElementFormat();
				cf.fontSize = 2.4
				var fd:FontDescription = new FontDescription("Times New Roman")
				cf.fontDescription = fd
				var te:TextElement = new TextElement("TextLine " + i,cf);
				var tb:TextBlock = new TextBlock();
				tb.content = te;
				var tl1:TextLine = tb.createTextLine(null,400);
				tl1.x = 40;
				tl1.y = 40 + (4 * i);
				//need to keep track of what I've added in order to remove at teardown?
				TestCanvas.rawChildren.addChild(DisplayObject(tl1));
				ItemsToRemove.push (tl1);
			}
			System.gc();System.gc();	//garbage collect at end so we can compare memory usage versus static lines
		}

		public function singleTextLineStatic():void
		{
			singleTextLine();
			TextLine(ItemsToRemove[0]).validity = TextLineValidity.STATIC;
			System.gc();System.gc();	//garbage collect at end so we can compare memory usage versus static lines
		}
		public function tenTextLinesStatic():void
		{
			tenTextLines();
			for (var i:int = 0; i < ItemsToRemove.length; i++)
			{
				TextLine(ItemsToRemove[i]).validity = TextLineValidity.STATIC;
			}
			System.gc();System.gc();	//garbage collect at end so we can compare memory usage versus static lines
		}
		public function oneHundredTextLinesStatic():void
		{
			oneHundredTextLines();
			for (var i:int = 0; i < ItemsToRemove.length; i++)
			{
				TextLine(ItemsToRemove[i]).validity = TextLineValidity.STATIC;
			}
			System.gc();System.gc();	//garbage collect at end so we can compare memory usage versus static lines
		}

		public function clickLinkedContainerTest():void
	    {
			var posOfSelection:int = TestData.posOfSelection;
			var format:TextLayoutFormat = new TextLayoutFormat();
			format = new TextLayoutFormat();
			format.paddingLeft = 20;
			format.paddingRight = 20;
			format.paddingTop = 20;
			format.paddingBottom = 20;

			var textFlow:TextFlow = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer = new StandardFlowComposer();
			var editManager:IEditManager = new EditManager();
        	textFlow.interactionManager = editManager;

        	format.firstBaselineOffset = "auto";
			editManager.applyContainerFormat(format);
			editManager.applyFormatToElement(editManager.textFlow,format);
			editManager.selectRange(0, 0);

			//create two containers
			var container1:Sprite = new Sprite();
			var container2:Sprite = new Sprite();
			var controllerOne:ContainerController = new ContainerController(container1, 200, 250);
			var controllerTwo:ContainerController = new ContainerController(container2, 150, 300);

			TestCanvas.rawChildren.addChild(container1);
			TestCanvas.rawChildren.addChild(container2);
			container1.x = 25;
			container1.y = 50;
			container2.x = 280;
			container2.y = 50;

			// add the controllers to the text flow and update them to display the text
			textFlow.flowComposer.addController(controllerOne);
			textFlow.flowComposer.addController(controllerTwo);
			textFlow.flowComposer.updateAllControllers();

			var tfl:TextFlowLine = textFlow.flowComposer.findLineAtPosition(posOfSelection);
			var adjustedPosOfSelection:int = posOfSelection - tfl.absoluteStart;
			var tl:TextLine = tfl.getTextLine();
			var bounds:Rectangle = tl.getAtomBounds(adjustedPosOfSelection);

  		  	var mouseX:Number = 0;
			var mouseY:Number = 0;

  		  	if (TestData.id == "clickLeftToLinkedContainer")
  		   	{
    			mouseX = bounds.x - 1;
    			mouseY = tl.y;
  		  	} else if (TestData.id == "clickRightToLinkedContainer")
  		   	{
    			mouseX = bounds.x + 1;
    			mouseY = tl.y;
  		   	}
  		 	else if (TestData.id == "clickTopLinkedContainer")
  		  	{
  		   		mouseX = bounds.x;
    			mouseY = tl.y - 1;
  		   	}
  		   	else if (TestData.id == "clickBottomLinkedContainer")
  		   	{
    			mouseX = bounds.x;
    			mouseY = tl.y + 1;
  		   	}

			editManager.setFocus();
 			var mEvent:MouseEvent;
 			mEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, mouseX, mouseY);
 			container1.dispatchEvent(mEvent);
 			editManager.setFocus();

			editManager.flushPendingOperations();
	    	var posAfterClick:int = editManager.activePosition;

	    	assertTrue("Position changed after click." + " Position of selected is: " + posOfSelection
	    	            + " Position of after Click: " + posAfterClick,
	    	            posOfSelection == posAfterClick);

	    }
		
		// linked containers,  check if attribute changed after texts insertion  
		public function checkContainerAttributesAfterTextInsertion():void
		{	
			var textFlow:TextFlow = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer = new StandardFlowComposer();
			var editManager:IEditManager = new EditManager();
			textFlow.interactionManager = editManager;
			
			//create two linked containers containers
			var container1:Sprite = new Sprite();
			var container2:Sprite = new Sprite();
			var controllerOne:ContainerController = new ContainerController(container1, 200, 250);
			var controllerTwo:ContainerController = new ContainerController(container2, 150, 300);
			
			TestCanvas.rawChildren.addChild(container1);
			TestCanvas.rawChildren.addChild(container2);
			container1.x = 25;
			container1.y = 50;
			container2.x = 280;
			container2.y = 50;
			
			// add the controllers to the text flow and update them to display the text
			textFlow.flowComposer.addController(controllerOne);
			textFlow.flowComposer.addController(controllerTwo);
			textFlow.flowComposer.updateAllControllers();
			
			editManager.selectRange(0, 0);
			editManager.setFocus();
			
			var format:TextLayoutFormat = new TextLayoutFormat();
			format = new TextLayoutFormat();
			format.paddingLeft = 20;
			format.paddingRight = 20;
			format.paddingTop = 20;
			format.paddingBottom = 20;
			
			format.firstBaselineOffset = "auto";
			editManager.applyContainerFormat(format);
			editManager.applyFormatToElement(editManager.textFlow,format);
			textFlow.flowComposer.updateAllControllers();
			
			//get container attributes before insertion
			var containerAtts_before:ITextLayoutFormat = controllerOne.format;
			var paddingLeft_before:Number = containerAtts_before.paddingLeft;
			var  paddingRight_before:Number = containerAtts_before.paddingRight;
			var paddingTop_before:Number = containerAtts_before.paddingTop;
			var paddingBottom_before:Number = containerAtts_before.paddingBottom;
			
			var firstContStart:int = controllerOne.absoluteStart;
			var firstContLen:int = controllerOne.textLength;
			var firstContEnd:int = firstContStart + firstContLen;
			
			//get the insertion position
			if (TestData.id == "insertionEndOf1stContainer")
			{
				editManager.selectRange(firstContEnd - 1, firstContEnd - 1);
			} else if (TestData.id == "insertionBeginOf2ndContainer")
			{
				editManager.selectRange(firstContEnd, firstContEnd);
			}
			editManager.insertText("BBB");
			textFlow.flowComposer.updateAllControllers();
			
			//check attributes after insertion
			var containerAtts_after:ITextLayoutFormat = controllerOne.format;
			var paddingLeft_after:Number = containerAtts_after.paddingLeft;
			var  paddingRight_after:Number = containerAtts_after.paddingRight;
			var paddingTop_after:Number = containerAtts_after.paddingTop;
			var paddingBottom_after:Number = containerAtts_after.paddingBottom;
			
			//check if attributes changed after insertion
			assertTrue ("Attributes have been changed after insertion to end of 1st container.",
				paddingLeft_before === paddingLeft_after &&
				paddingRight_before === paddingRight_after &&
				paddingTop_before === paddingTop_after &&
				paddingBottom_before === paddingBottom_after );
		}

	    private var firstFlow:TextFlow;
		private var secondFlow:TextFlow;
		private var firstController:ContainerController;
		private var secondController:ContainerController;

	    private function resizeHandler(event:Event):void
		{
			const verticalGap:Number = 25;
			const stagePadding:Number = 16;
			var stageWidth:Number = TestCanvas.width - stagePadding;
			var stageHeight:Number = TestCanvas.height - stagePadding;
			var firstContaierWidth:Number = stageWidth;
			var firstContaierHeight:Number = stageHeight;
			// Initial compose to get height of headline after resize
			firstController.setCompositionSize(firstContaierWidth, firstContaierHeight);
			firstFlow.flowComposer.compose();
			var rect:Rectangle = firstController.getContentBounds();
			firstContaierHeight = rect.height;
			// Resize and place headline text container
			// Call setCompositionSize() again with updated headline height
			firstController.setCompositionSize(firstContaierWidth, firstContaierHeight );
			firstController.container.x = stagePadding / 2;
			firstController.container.y = stagePadding / 2;
			firstFlow.flowComposer.updateAllControllers();
			// Resize and place second text container
			var secondContainerHeight:Number = (stageHeight - verticalGap -
			firstContaierHeight);
			secondController.setCompositionSize(stageWidth, secondContainerHeight );
			secondController.container.x = (stagePadding/2);
			secondController.container.y = (stagePadding/2) + firstContaierHeight +
				verticalGap;
			secondFlow.flowComposer.updateAllControllers();
		}

	    public function SelectionChangeFocusTest():void
	    {

		    const firstMarkup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008'>" +
				"<flow:p>" + "<flow:span fontSize='14'>first text flow: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA</flow:span>" +
				"</flow:p>" +
			    "</flow:TextFlow>";
		    const secondMarkup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' fontSize='14'> " +
				"<flow:p>" +
				"<flow:span>second text flow: " +
					"as it proved in the case of Ethan Brand, who had mused to such " +
					"strange purpose, in days gone by, while the fire in this very kiln was burning.</flow:span>" +
			    "</flow:p>" +
		        "</flow:TextFlow>";
			var posOfSelection1:int = TestData.posOfSelection1;
			var posOfSelection2:int = TestData.posOfSelection2;

			TestCanvas.addEventListener(flash.events.Event.RESIZE, resizeHandler);

			//create first text flow, import first text, and assign composer
			firstFlow = new TextFlow();
			firstFlow = TextConverter.importToFlow(firstMarkup, TextConverter.TEXT_LAYOUT_FORMAT);
			firstFlow.flowComposer = new StandardFlowComposer();
			//create second text flow, import second text, and assign flow composer
			secondFlow = new TextFlow();
			secondFlow = TextConverter.importToFlow(secondMarkup, TextConverter.TEXT_LAYOUT_FORMAT);
			secondFlow.flowComposer = new StandardFlowComposer();
			// create first container, add controller, position container and add to stage
			var firstContainer:Sprite = new Sprite();
			firstController = new ContainerController(firstContainer, 300, 50);
			var editManager1:IEditManager = new EditManager();
			firstFlow.interactionManager = editManager1;
			firstFlow.flowComposer.addController(firstController);
			firstContainer.x = 120;
			firstContainer.y = 20;
			TestCanvas.rawChildren.addChild(firstContainer);
			firstFlow.flowComposer.updateAllControllers();

			// create container for second text and position it
			var secondContainer:Sprite = new Sprite();
			secondController = new ContainerController(secondContainer, 300, 200);
			secondContainer.x = 125;
			secondContainer.y = 185;
			var editManager2:IEditManager = new EditManager();
			secondFlow.interactionManager = editManager2;
			// add controller, add container to stage, and display second text
			secondFlow.flowComposer.addController(secondController);
			TestCanvas.rawChildren.addChild(secondContainer);
			secondFlow.flowComposer.updateAllControllers();

			//get focus for first flow
			editManager1.selectRange(posOfSelection1,posOfSelection1);
			editManager1.flushPendingOperations();
			editManager1.setFocus();

			assertTrue("Selection Focus doesn't change after selection change from Text Flow 1 to Text Flow 2. ",
	    	            posOfSelection1 == editManager1.activePosition);

			//get focus for second flow
			editManager2.selectRange(posOfSelection2,posOfSelection2);
			editManager2.flushPendingOperations();
			editManager2.setFocus();

			assertTrue("Selection Focus doesn't change properly after selection change from Text Flow 1 to Text Flow 2. "
	    	            + ". The expected focus poisiton should be in second text flow at: " + posOfSelection2
	    	            + " and the actual text flow focus poisiton is: " + editManager2.activePosition ,
	    	         posOfSelection2 == editManager2.activePosition);
	    }

	    public function clickMultiLinkedContainerTest():void
	    {
			var posOfSelection:int = TestData.posOfSelection;
			var format:TextLayoutFormat = new TextLayoutFormat();
			format = new TextLayoutFormat();
			format.paddingLeft = 20;
			format.paddingRight = 20;
			format.paddingTop = 20;
			format.paddingBottom = 20;
			var textFlow:TextFlow = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer = new StandardFlowComposer();
			var editManager:IEditManager = new EditManager();
        	textFlow.interactionManager = editManager;
        	format.firstBaselineOffset = "auto";
			editManager.applyContainerFormat(format);
			editManager.applyFormatToElement(editManager.textFlow,format);
			editManager.selectRange(0, 0);

			//create five containers
			var container1:Sprite = new Sprite();
			var container2:Sprite = new Sprite();
			var container3:Sprite = new Sprite();
			var container4:Sprite = new Sprite();
			var container5:Sprite = new Sprite();
			var controller1:ContainerController = new ContainerController(container1, 200, 200);
			var controller2:ContainerController = new ContainerController(container2, 200, 200);
			var controller3:ContainerController = new ContainerController(container3, 200, 200);
			var controller4:ContainerController = new ContainerController(container4, 200, 200);
			var controller5:ContainerController = new ContainerController(container5, 200, 200);
			TestCanvas.rawChildren.addChild(container1);
			TestCanvas.rawChildren.addChild(container2);
			TestCanvas.rawChildren.addChild(container3);
			TestCanvas.rawChildren.addChild(container4);
			TestCanvas.rawChildren.addChild(container5);
			container1.x = 25;
			container1.y = 50;
			container2.x = 280;
			container2.y = 50;
			container3.x = 535;
			container3.y = 50;
			container4.x = 790;
			container4.y = 50;
			container5.x = 1045;
			container5.y = 50;
			// add the controllers to the text flow and update them to display the text
			textFlow.flowComposer.addController(controller1);
			textFlow.flowComposer.addController(controller2);
			textFlow.flowComposer.addController(controller3);
			textFlow.flowComposer.addController(controller4);
			textFlow.flowComposer.addController(controller5);
			textFlow.flowComposer.updateAllControllers();
			var tfl:TextFlowLine = textFlow.flowComposer.findLineAtPosition(posOfSelection);
			var adjustedPosOfSelection:int = posOfSelection - tfl.absoluteStart;
			var tl:TextLine = tfl.getTextLine();
			var bounds:Rectangle = tl.getAtomBounds(adjustedPosOfSelection);
  		  	var mouseX:Number = 0;
			var mouseY:Number = 0;
  		  	if (TestData.id == "clickLeftToMultiLinkedContainer")
  		   	{
    			mouseX = bounds.x - 1;
    			mouseY = tl.y;
  		  	} else if (TestData.id == "clickRightToMultiLinkedContainer")
  		   	{
    			mouseX = bounds.x + 1;
    			mouseY = tl.y;
  		   	}
  		 	else if (TestData.id == "clickTopMultiLinkedContainer")
  		  	{
  		   		mouseX = bounds.x;
    			mouseY = tl.y - 1;
  		   	}
  		   	else if (TestData.id == "clickBottomMultiLinkedContainer")
  		   	{
    			mouseX = bounds.x;
    			mouseY = tl.y + 1;
  		   	}
			editManager.setFocus();
 			var mEvent:MouseEvent;
 			mEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, mouseX, mouseY);
 			container1.dispatchEvent(mEvent);
 			editManager.setFocus();
			editManager.flushPendingOperations();
	    	var posAfterClick:int = editManager.activePosition;
	    	assertTrue("Position changed after click." + " Position of selected is: " + posOfSelection
	    	            + " Position of after Click: " + posAfterClick,
	    	            posOfSelection == posAfterClick);

	    }
	    /*****************************************************************
	    Drag selection using mouse events and verify the selected range.
	    ******************************************************************/
	    //two text flows, two containers
	    public function draggingSelectioinMultiFlows():void
	    {
	    	//create the first text flow, import texts from markups, and assign flow composer to a container
	    	var flow_1:TextFlow = new TextFlow();
            flow_1 = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);
            flow_1.flowComposer = new StandardFlowComposer();
            var container_1:Sprite = new Sprite();
            var controller_1:ContainerController = new ContainerController(container_1, 300, 250);
            container_1.x = 25;
            container_1.y = 25;

            //Create EditManager to manage edting changes in TextFlow
            var eManager_1:IEditManager = new EditManager();
            flow_1.interactionManager = eManager_1;
            eManager_1.selectRange(0,0);

            //add controllers to the first text flow and update all controller to display texts
            flow_1.flowComposer.addController(controller_1);
            TestCanvas.rawChildren.addChild(container_1);
            flow_1.flowComposer.updateAllControllers();

      		//set points for the selection beginning and end
      		var startFlowLine:TextFlowLine = flow_1.flowComposer.getLineAt(2);
      		var startLine:TextLine = startFlowLine.getTextLine();
      		var endFlowLine:TextFlowLine = flow_1.flowComposer.getLineAt(10);
      		var endLine:TextLine = endFlowLine.getTextLine();
      		var endRect:Rectangle = endLine.getAtomBounds(54);
            var startPoint:Point = new Point(startLine.x, startLine.y);
            var endPoint:Point = new Point(endRect.x, endLine.y);
            var x_point:Number;
   			var y_point:Number;

			x_point = startPoint.x;
			y_point = startPoint.y;

			//selection start point in the first text flow
			eManager_1.setFocus();
			var downPoint:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, x_point, y_point, container_1);
 			container_1.dispatchEvent(downPoint);

 			var startInt:int = startFlowLine.absoluteStart;
 			var activeInt:int = eManager_1.activePosition;
 			var charCount:int = endLine.atomCount;
  			var endLineStart:int = endFlowLine.absoluteStart;
			var endInt:int = (endLineStart + charCount) - 1;

 			if (startInt == activeInt)
			{
				x_point = endPoint.x;
				y_point = endPoint.y;

				//dragging selection
				eManager_1.setFocus();
				var movePoint:MouseEvent =
				new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, x_point, y_point, container_1,false,false,false,true);
				container_1.dispatchEvent(movePoint);

				//dragging is done
				var upPoint:MouseEvent =
				new MouseEvent(MouseEvent.MOUSE_UP, true, false, x_point, y_point, container_1);
				container_1.dispatchEvent(upPoint);
			}

			else
           	{
           		fail ("Mouse down event in the first text flow didn't happen!");
           	}

           	//create the second text flow, import texts from markups, and assign flow composer to a container
       		var flow_2:TextFlow = new TextFlow();
            flow_2 = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);
			flow_2.flowComposer = new StandardFlowComposer();

			//Create EditManager to manage edting changes in TextFlow
			var eManager_2:IEditManager = new EditManager();
           	flow_2.interactionManager = eManager_2;
           	eManager_2.selectRange(0,0);

           	var container_2:Sprite = new Sprite();
       		var controller_2:ContainerController = new ContainerController(container_2, 300, 250);
           	container_2.x = 350;
            container_2.y = 25;

            //add controllers to the second text flow and update all controller to display texts
            flow_2.flowComposer.addController(controller_2);
            TestCanvas.rawChildren.addChild(container_2);
            flow_2.flowComposer.updateAllControllers();

      		//set points for the selection beginning and end
      		var startFlowLine2:TextFlowLine = flow_2.flowComposer.getLineAt(5);
      		var startLine2:TextLine = startFlowLine.getTextLine();
      		var endFlowLine2:TextFlowLine = flow_2.flowComposer.getLineAt(13);
      		var endLine2:TextLine = endFlowLine2.getTextLine();
      		var endRect2:Rectangle = endLine2.getAtomBounds(54);

            var startPoint2:Point = new Point(startLine2.x, startLine2.y);
            var endPoint2:Point = new Point(endRect2.x, endLine2.y);

            var x_point2:Number;
   			var y_point2:Number;

			x_point2 = startPoint2.x;
			y_point2 = startPoint2.y;

			//selection start point in the sencond text flow
			eManager_2.setFocus();
			var downPoint2:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, x_point2, y_point2, container_2);
 			container_2.dispatchEvent(downPoint2);

			x_point2 = endPoint2.x;
			y_point2 = endPoint2.y;

			//dragging selection
			eManager_2.setFocus();
			var movePoint2:MouseEvent =
			new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, x_point2, y_point2, container_2,false,false,false,true);
			container_2.dispatchEvent(movePoint2);

			//dragging is done
			var upPoint2:MouseEvent =
			new MouseEvent(MouseEvent.MOUSE_UP, true, false, x_point2, y_point2, container_2);
			container_2.dispatchEvent(upPoint2);

 			var charCount2:int = endLine2.atomCount;
 			var startInt2:int = startFlowLine2.absoluteStart;
 			var endLineStart2:int = endFlowLine2.absoluteStart;
			var endInt2:int = (endLineStart2 + charCount2) - 1;

			var start:int = 101;
			var end:int = 573;
			assertTrue("Selection range for the first text flow should have been from " +　start + " to " + end +
			" but it was from " + startInt + " to " + endInt, startInt == start && endInt == end);

			var start2:int = 252;
			var end2:int = 733;
			assertTrue("Selection range for the second text flow should have been from " +　start2 + " to " + end2 +
			" but it was from " + startInt2 + " to " + endInt2, startInt2 == start2 && endInt2 == end2);
	    }

	    //two text flows, two containers, select from one flow to another
	    public function DraggingSelectionOneFlowToAnotherTest():void
	    {

		    const firstMarkup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008'>" +
				"<flow:p>" + "<flow:span fontSize='14'>AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA</flow:span>" +
				"</flow:p>" +
			    "</flow:TextFlow>";
		    const secondMarkup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' fontSize='14'> " +
				"<flow:p>" +
				"<flow:span>second text flow: " +
					"as it proved in the case of Ethan Brand, who had mused to such " +
					"strange purpose, in days gone by, while the fire in this very kiln was burning.</flow:span>" +
			    "</flow:p>" +
		        "</flow:TextFlow>";
			var posOfSelection1:int = TestData.posOfSelection1;
			var posOfSelection2:int = TestData.posOfSelection2;

			//create first text flow, import first text, and assign composer
			firstFlow = new TextFlow();
			firstFlow = TextConverter.importToFlow(firstMarkup, TextConverter.TEXT_LAYOUT_FORMAT);
			firstFlow.flowComposer = new StandardFlowComposer();
			//create second text flow, import second text, and assign flow composer
			secondFlow = new TextFlow();
			secondFlow = TextConverter.importToFlow(secondMarkup, TextConverter.TEXT_LAYOUT_FORMAT);
			secondFlow.flowComposer = new StandardFlowComposer();
			// create first container, add controller, position container
			var firstContainer:Sprite = new Sprite();
			firstController = new ContainerController(firstContainer, 300, 50);
			var editManager1:IEditManager = new EditManager();
			firstFlow.interactionManager = editManager1;
			firstFlow.flowComposer.addController(firstController);
			firstContainer.x = 120;
			firstContainer.y = 20;
			TestCanvas.rawChildren.addChild(firstContainer);
			firstFlow.flowComposer.updateAllControllers();

			// create container for second text and position it
			var secondContainer:Sprite = new Sprite();
			secondController = new ContainerController(secondContainer, 300, 200);
			secondContainer.x = 125;
			secondContainer.y = 185;
			var editManager2:IEditManager = new EditManager();
			secondFlow.interactionManager = editManager2;
			// add controller, add container to stage, and display second text
			secondFlow.flowComposer.addController(secondController);
			TestCanvas.rawChildren.addChild(secondContainer);
			secondFlow.flowComposer.updateAllControllers();

		    // make selection in first flow and second flow
			editManager1.selectRange(0, 0);
			var tfl1:TextFlowLine = firstFlow.flowComposer.findLineAtPosition(posOfSelection1);
			var adjustedPosOfSelection1:int = posOfSelection1 - tfl1.absoluteStart;
			var tl1:TextLine = tfl1.getTextLine();
			var bounds1:Rectangle = tl1.getAtomBounds(adjustedPosOfSelection1);
			var tfl2:TextFlowLine = secondFlow.flowComposer.findLineAtPosition(posOfSelection2);
			var adjustedPosOfSelection2:int = posOfSelection2 - tfl2.absoluteStart;
			var tl2:TextLine = tfl2.getTextLine();
			var bounds2:Rectangle = tl2.getAtomBounds(adjustedPosOfSelection2);

  		  	var mouseX:Number = 0;
			var mouseY:Number = 0;
			mouseX = bounds1.x;
    		mouseY = tl1.y;

			// mouse down in first container
			editManager1.setFocus();
 			var mEventD1:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, mouseX, mouseY, firstContainer);
 			firstContainer.dispatchEvent(mEventD1);

 			// mouse move to second container and mouse up
 			mouseX = bounds2.x;
    		mouseY = tl2.y;
    		editManager2.selectRange(0,0);
			editManager2.setFocus();
			var mEventM1:MouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, mouseX, mouseY, secondContainer,false,false,false,true);
			secondContainer.dispatchEvent(mEventM1);
			var mEventU1:MouseEvent = new MouseEvent(MouseEvent.MOUSE_UP, true, false, mouseX, mouseY, secondContainer);
			secondContainer.dispatchEvent(mEventU1);

 			var activePos:Number = editManager2.activePosition;
			assertTrue("Selection should not extend to second container. ",
	    	            activePos == 0);

	    }

	    public function addRemoveMulitiLinkedContainerTest():void
	    {
			var format:TextLayoutFormat = new TextLayoutFormat();
			format = new TextLayoutFormat();
			format.paddingLeft = 20;
			format.paddingRight = 20;
			format.paddingTop = 20;
			format.paddingBottom = 20;
			var textFlow:TextFlow = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer = new StandardFlowComposer();
			var editManager:IEditManager = new EditManager();
        	textFlow.interactionManager = editManager;
        	format.firstBaselineOffset = "auto";
			editManager.applyContainerFormat(format);
			editManager.applyFormatToElement(editManager.textFlow,format);
			editManager.selectRange(0, 0);

			//create five containers and hid two
			var container1:Sprite = new Sprite();
			var container2:Sprite = new Sprite();
			var container3:Sprite = new Sprite();
			var container4:Sprite = new Sprite();
			var container5:Sprite = new Sprite();
			var controller1:ContainerController = new ContainerController(container1, 100, 100);
			var controller2:ContainerController = new ContainerController(container2, 200, 200);
			var controller3:ContainerController = new ContainerController(container3, 300, 300);
			var controller4:ContainerController = new ContainerController(container4, 400, 400);
			var controller5:ContainerController = new ContainerController(container5, 500, 500);
			TestCanvas.rawChildren.addChild(container1);
			TestCanvas.rawChildren.addChild(container2);
			TestCanvas.rawChildren.addChild(container3);
			TestCanvas.rawChildren.addChild(container4);
			TestCanvas.rawChildren.addChild(container5);
			container1.x = 25;
			container1.y = 50;
			container2.x = 280;
			container2.y = 50;
			container3.x = 535;
			container3.y = 50;
			container4.x = 790;
			container4.y = 50;
			container5.x = 1045;
			container5.y = 50;
			container4.visible = false;
			container5.visible = false;

			// add the controllers to the text flow and update them to display the text
			textFlow.flowComposer.addController(controller1);
			textFlow.flowComposer.addController(controller2);
			textFlow.flowComposer.addController(controller3);
			textFlow.flowComposer.addController(controller4);
			textFlow.flowComposer.addController(controller5);
			textFlow.flowComposer.updateAllControllers();

			//removeController
			textFlow.flowComposer.removeController(controller5);
			textFlow.flowComposer.updateAllControllers();
			var containerNumAfterRemove:int = textFlow.flowComposer.numControllers;
			assertTrue("Container has not been removed correctly ", containerNumAfterRemove == 4);

	    	//removeControllerAt
	    	textFlow.flowComposer.removeControllerAt(2);
	    	textFlow.flowComposer.updateAllControllers();
			containerNumAfterRemove = textFlow.flowComposer.numControllers;
			assertTrue("Container has not been removed correctly ", containerNumAfterRemove == 3);

	    	var c1:ContainerController = textFlow.flowComposer.getControllerAt(0);
			var c2:ContainerController = textFlow.flowComposer.getControllerAt(1);
			var c3:ContainerController = textFlow.flowComposer.getControllerAt(2);
			var w1:int = c1.compositionWidth;
			var w2:int = c2.compositionWidth;
			var w3:int = c3.compositionWidth;
			//check if removed correct containers
			assertTrue("Wrong container has been removed ", w1 == 100 && w2 == 200 && w3 == 400);

		   //addController
			textFlow.flowComposer.addController(controller5);
			textFlow.flowComposer.updateAllControllers();
			var containerNumAfterAdd:int = textFlow.flowComposer.numControllers;
			assertTrue("Container has not been added correctly ", containerNumAfterAdd == 4);
			//check if correct container added
			var c4:ContainerController = textFlow.flowComposer.getControllerAt(3);
			var w4:int = c4.compositionWidth;
			assertTrue("Wrong container has been removed ", w4 == 500);

			//addControllerAt
			textFlow.flowComposer.addControllerAt(controller3, 3);
			textFlow.flowComposer.updateAllControllers();
			containerNumAfterAdd = textFlow.flowComposer.numControllers;
			assertTrue("Container has not been added correctly ", containerNumAfterAdd == 5);
			//check if correct container added at correct position
			var c5:ContainerController = textFlow.flowComposer.getControllerAt(3);
			var w5:int = c5.compositionWidth;
			assertTrue("Container has not been added at corrent position ", w5 == 300);
			c4 = textFlow.flowComposer.getControllerAt(4);
			w4 = c4.compositionWidth;
			assertTrue("Container has not been added at corrent position ", w4 == 500);
	    }

		public function containerRecomposeAndConsistenceTest():void
		{
			var textFlow:TextFlow = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer = new StandardFlowComposer();
			var editManager:IEditManager = new EditManager();
			textFlow.interactionManager = editManager;
			editManager.selectRange(0, 0);

			//create five containers and hid two
			var container1:Sprite = new Sprite();
			var container2:Sprite = new Sprite();
			var container3:Sprite = new Sprite();
			var container4:Sprite = new Sprite();
			var container5:Sprite = new Sprite();
			var controller1:ContainerController = new ContainerController(container1, 200, 200);
			var controller2:ContainerController = new ContainerController(container2, 200, 200);
			var controller3:ContainerController = new ContainerController(container3, 200, 200);
			var controller4:ContainerController = new ContainerController(container4, 200, 200);
			var controller5:ContainerController = new ContainerController(container5, 200, 200);
			TestCanvas.rawChildren.addChild(container1);
			TestCanvas.rawChildren.addChild(container2);
			TestCanvas.rawChildren.addChild(container3);
			TestCanvas.rawChildren.addChild(container4);
			TestCanvas.rawChildren.addChild(container5);
			container1.x = 25;
			container1.y = 50;
			container2.x = 280;
			container2.y = 50;
			container3.x = 535;
			container3.y = 50;
			container4.x = 790;
			container4.y = 50;
			container5.x = 1045;
			container5.y = 50;
			container4.visible = false;
			container5.visible = false;

			// add the controllers to the text flow and update them to display the text
			textFlow.flowComposer.addController(controller1);
			textFlow.flowComposer.addController(controller2);
			textFlow.flowComposer.addController(controller3);
			textFlow.flowComposer.addController(controller4);
			textFlow.flowComposer.addController(controller5);
			textFlow.flowComposer.updateAllControllers();

			if (TestData.id == "recomposeContainerTest") //to test if container will be re-composed correctly after some container update
			{
				//recompose controller3
				controller3.setCompositionSize(250, 250);

				var comp0:Boolean = textFlow.flowComposer.composeToController(0);
				var comp1:Boolean = textFlow.flowComposer.composeToController(1);   // shoud be true since last line before first damaged  line will be re-composed
				var comp2:Boolean = textFlow.flowComposer.composeToController(2);	// should be true - controller3
				var comp3:Boolean = textFlow.flowComposer.composeToController(3);	// should be true
				var comp4:Boolean = textFlow.flowComposer.composeToController(4);	// true due to overflow bydesign
				textFlow.flowComposer.updateAllControllers();

				assertTrue ("composeToController returns wrong flag after re-composite.",
					comp0 == false && comp1 == true && comp2 == true && comp3 == true && comp4 == true);
			} else if (TestData.id == "containerConsistenceTest")
			{
				var posOfSelection:int = TestData.posOfSelection;
				var tfl:TextFlowLine = textFlow.flowComposer.findLineAtPosition(posOfSelection);
				var tfl_abs:Number = tfl.absoluteStart;
				var tfl_textLen:Number = tfl.textLength;
				var controller:ContainerController = tfl.controller;

				var index:int =  textFlow.flowComposer.getControllerIndex( controller );
				var con_abs:Number = controller.absoluteStart;
				var con_textLen:Number = controller.textLength;
				var idx:Number = textFlow.flowComposer.findControllerIndexAtPosition(posOfSelection);

				assertTrue("abs start and text length are not consistent for textFlowLines in the container and the container",
				con_abs<=tfl_abs<=con_textLen && tfl_textLen <= con_textLen && index == idx);
			}
		}

		private function findFirstAndLastVisibleLine(flowComposer:IFlowComposer, controller:ContainerController):Array
		{
			var firstLine:int = flowComposer.findLineIndexAtPosition(controller.absoluteStart);
			var lastLine:int = flowComposer.findLineIndexAtPosition(controller.absoluteStart + controller.textLength - 1);
			var lastColumn:int = 0;
			var firstVisibleLine:int = -1;
			var lastVisibleLine:int = -1;
			for (var lineIndex:int = firstLine; lineIndex <= lastLine; lineIndex++)
			{
				var curLine:TextFlowLine = flowComposer.getLineAt(lineIndex);
				if (curLine.controller != controller)
					continue;

				// skip until we find the lines in the last column
				if (curLine.columnIndex != lastColumn)
					continue;

				if (curLine.textLineExists && curLine.getTextLine().parent)
				{
					if (firstVisibleLine < 0)
						firstVisibleLine = lineIndex;

					lastVisibleLine = lineIndex;
				}
			}

			return [firstVisibleLine, lastVisibleLine];
		}

		public function autoAndDragScrollingTest():void
		{

			var textFlow:TextFlow = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer = new StandardFlowComposer();
			var editManager:IEditManager = new EditManager();
			textFlow.interactionManager = editManager;
			editManager.selectRange(0, 0);

			//create three containers
			var container1:Sprite = new Sprite();
			var container2:Sprite = new Sprite();
			var container3:Sprite = new Sprite();
			var controller1:ContainerController = new ContainerController(container1, 200, 200);
			var controller2:ContainerController = new ContainerController(container2, 200, 200);
			var controller3:ContainerController = new ContainerController(container3, 200, 200);

			TestCanvas.rawChildren.addChild(container1);
			TestCanvas.rawChildren.addChild(container2);
			TestCanvas.rawChildren.addChild(container3);

			container1.x = 25;
			container1.y = 50;
			container2.x = 280;
			container2.y = 50;
			container3.x = 535;
			container3.y = 50;

			// add the controllers to the text flow and update them to display the text
			textFlow.flowComposer.addController(controller1);
			textFlow.flowComposer.addController(controller2);
			textFlow.flowComposer.addController(controller3);
			textFlow.flowComposer.updateAllControllers();

			//check first and last visible line in container1 before scrolling
			var beforePosition1:Array = findFirstAndLastVisibleLine(textFlow.flowComposer, controller1);
			var beforeFirstVisibleLine1:int = beforePosition1[0];
			var beforeLastVisibleLine1:int = beforePosition1[1];

			var position1:int = controller1.textLength-1;
			//try to scroll to end of the container
			controller1.scrollToRange(position1,position1);
			textFlow.flowComposer.updateAllControllers();

			// verify that the first and last visible lines no change after scroll
			var afterPosition1:Array = findFirstAndLastVisibleLine(textFlow.flowComposer, controller1);
			var afterFirstVisibleLine1:int = afterPosition1[0];
			var afterLastVisibleLine1:int = afterPosition1[1];
			assertTrue("the container is scrollable.  Expected not scrollable.",
				beforeFirstVisibleLine1 == afterFirstVisibleLine1 &&
				beforeLastVisibleLine1 == afterLastVisibleLine1);

			//check first and last visible line in last container container3 before scrolling
			var beforePosition3:Array = findFirstAndLastVisibleLine(textFlow.flowComposer, controller3);
			var beforeFirstVisibleLine3:int = beforePosition3[0];
			var beforeLastVisibleLine3:int = beforePosition3[1];

			var position3:int = textFlow.textLength-1;
			var pos_start_container3:int = controller1.textLength + controller2.textLength;
			if (TestData.id == "dragScrollingTest")
			{
				editManager.selectRange(position3 - 20, position3);
				editManager.setFocus();

			}
			controller3.scrollToRange(position3 - 20,position3);
			textFlow.flowComposer.updateAllControllers();

			// verify that the first and last visible lines changed after scroll
			var afterPosition3:Array = findFirstAndLastVisibleLine(textFlow.flowComposer, controller3);
			var afterFirstVisibleLine3:int = afterPosition3[0];
			var afterLastVisibleLine3:int = afterPosition3[1];
			assertTrue("the last container is not scrollable.  Expected scrollable.",
				beforeFirstVisibleLine3 < afterFirstVisibleLine3 &&
				beforeLastVisibleLine3 < afterLastVisibleLine3);

		}
		public function navigateByLineTest():void
		{
			var textFlow:TextFlow = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer = new StandardFlowComposer();
			var editManager:IEditManager = new EditManager();
			textFlow.interactionManager = editManager;
			editManager.selectRange(0, 0);

			//create three containers
			var container1:Sprite = new Sprite();
			var container2:Sprite = new Sprite();
			var container3:Sprite = new Sprite();
			var controller1:ContainerController = new ContainerController(container1, 200, 200);
			var controller2:ContainerController = new ContainerController(container2, 200, 200);
			var controller3:ContainerController = new ContainerController(container3, 200, 200);

			TestCanvas.rawChildren.addChild(container1);
			TestCanvas.rawChildren.addChild(container2);
			TestCanvas.rawChildren.addChild(container3);

			container1.x = 25;
			container1.y = 50;
			container2.x = 280;
			container2.y = 50;
			container3.x = 535;
			container3.y = 50;

			// add the controllers to the text flow and update them to display the text
			textFlow.flowComposer.addController(controller1);
			textFlow.flowComposer.addController(controller2);
			textFlow.flowComposer.addController(controller3);
			textFlow.flowComposer.updateAllControllers();

			//try to use previousLine to get to first container and nextLine to get to third container
			var posSecondControllerBegin:int = controller2.absoluteStart;
			var posSecondControllerEnd:int = posSecondControllerBegin + controller2.textLength;
			if (TestData.id == "navigateByPreviousLine")
			{
				//to get the selection range at beginning of second container then previousLine should go to the first container
				editManager.selectRange(posSecondControllerBegin, posSecondControllerBegin + 10);
			}else if (TestData.id == "navigateByNextLine")
			{
				//to get the selection range at end of second container then nextLine should go to the third container
				editManager.selectRange(posSecondControllerEnd - 10, posSecondControllerEnd);
			}
			var selRange:SelectionState = editManager.getSelectionState();
			if (TestData.id == "navigateByPreviousLine")
			{
				NavigationUtil.previousLine(selRange,true);
			}else if (TestData.id == "navigateByNextLine")
			{
				NavigationUtil.nextLine(selRange,true);
			}

			//composes all the text up-to date.
			textFlow.flowComposer.updateAllControllers();
			var positionAfter:int = selRange.activePosition;
			var curControllerIdx:int =  textFlow.flowComposer.findControllerIndexAtPosition( positionAfter );

			if (TestData.id == "navigateByPreviousLine")
			{
				assertTrue ("The previousLine didn't get to correct container.", curControllerIdx == 0);
			}
			else if (TestData.id == "navigateByNextLine")
			{
				assertTrue ("The previousLine didn't get to correct container.", curControllerIdx == 2);
			}
		}

		public function defaultContextMenuOnTest():void
		{
			var textFlow:TextFlow = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer = new StandardFlowComposer();
			var editManager:IEditManager = new EditManager();
			textFlow.interactionManager = editManager;
			editManager.selectRange(0, 0);

			//create a container
			var container:Sprite = new Sprite();
			var controller:ContainerController = new ContainerController(container, 200, 200);
			TestCanvas.rawChildren.addChild(container);

			// add the controller to the text flow and update it to display the text and setFocus to attach contextMenu
			textFlow.flowComposer.addController(controller);
			editManager.setFocus();
			textFlow.flowComposer.updateAllControllers();
			assertTrue ("The default Context Menu should be on when editMode=readWrite.", container.contextMenu != null);
		}

		// Check if the contectMenu is off when editMode=readOnly
		public function contextMenuOffTest():void
		{
			var textFlow:TextFlow = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer = new StandardFlowComposer();
			var editManager:IEditManager = new EditManager();
			textFlow.interactionManager = editManager;
			editManager.selectRange(0, 0);

			//create a container
			var container:Sprite = new Sprite();
			var controller:ContainerController = new ContainerController(container, 200, 200);
			TestCanvas.rawChildren.addChild(container);
			textFlow.flowComposer.addController(controller);
			editManager.setFocus(); //attach default contextMenu
			textFlow.flowComposer.updateAllControllers();
			textFlow.interactionManager = null;	//make editMode=readOnly to disable contextMenu
			assertTrue ("The default Context Menu should be off when editMode=readOnly.", container.contextMenu == null);
		}

		public function overrideContextMenuTestNull():void
		{
			var s:Sprite = createInputManagerNull(hostFormat);
			s.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			TestCanvas.rawChildren.addChild(s);
			assertTrue ("It should be no contextMenu with the override fuction.", s.contextMenu == null);
		}
		static private function createInputManagerNull(hostFormat:ITextLayoutFormat):Sprite
		{
			var s:Sprite = new Sprite();
			var tcm:CustomTextContainerManagerNull = new CustomTextContainerManagerNull(s);
			tcm.compositionWidth = 250;
			tcm.compositionHeight = 100;
			tcm.setText("Hello World");
			tcm.hostFormat = hostFormat;
			tcm.updateContainer();
			return s;
		}

		public function overrideContextMenuTestAll():void
		{
			var s:Sprite = createInputManagerAll(hostFormat);
			s.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			TestCanvas.rawChildren.addChild(s);
			assertTrue ("The contextMenu should be all true.", s.contextMenu.customItems[0].caption== "PageUp"
			&& s.contextMenu.customItems[1].caption == "PageDown")
		}

		static private function createInputManagerAll(hostFormat:ITextLayoutFormat):Sprite
		{
			var s:Sprite = new Sprite();
			var tcm:CustomTextContainerManagerAll = new CustomTextContainerManagerAll(s);
			tcm.compositionWidth = 250;
			tcm.compositionHeight = 100;
			tcm.setText("Hello World");
			tcm.hostFormat = hostFormat;
			tcm.updateContainer();
			return s;
		}

		//to test bug 2500307: TCM shouldn't have contextMenu when read-only
		public function contextMenuReadOnly():void
		{
			var s:Sprite = new Sprite();
			s.x = 0;
			s.y = 0;
			TestCanvas.rawChildren.addChild(s);
			var tcm:TextContainerManager = new TextContainerManager(s);
			tcm.compositionWidth = 250;
			tcm.compositionHeight = NaN;
			tcm.setText("Hello World, there should not be a context menu becasue field is read-only");
			var format:TextLayoutFormat = new TextLayoutFormat(TextLayoutFormat.defaultFormat);
			format.fontFamily = "Arial";
			format.fontSize = 14;
			tcm.hostFormat = format;
			tcm.editingMode = EditingMode.READ_ONLY;
			tcm.updateContainer();
			assertTrue ("The default Context Menu should be off when editMode=readOnly.", tcm.container.contextMenu == null);
		}

		//to test bug 2504032: TCM contextMenu when using the factory and READ_SELECT should not enable the edit clipboard items such as cut and paste
		public function contextMenuReadSelect():void
		{
			var s:Sprite = new Sprite();
			s.x = 0;
			s.y = 0;
			var tcm:TextContainerManager = new TextContainerManager(s);
			tcm.compositionWidth = 250;
			tcm.compositionHeight = NaN;
			tcm.setText("Hello World, TCM contextMenu when using the factory and READ_SELECT should not enable the edit clipboard items such as cut and paste");
			var format:TextLayoutFormat = new TextLayoutFormat(TextLayoutFormat.defaultFormat);
			format.fontFamily = "Arial";
			format.fontSize = 14;
			tcm.hostFormat = format;
			tcm.updateContainer();

			//to make textMenu and clipboardMenu enabled
			s.dispatchEvent(new FocusEvent( FocusEvent.FOCUS_IN ) );
			TestCanvas.rawChildren.addChild(s);
			assertTrue ("The edit clipboard items such as cut and paste were disabled when TCM contextMenu NOT using READ_SELECT", tcm.container.contextMenu.clipboardMenu == true);

			//to make textMenu and clipboardMenu disabled
			tcm.editingMode = EditingMode.READ_SELECT;
			tcm.updateContainer();
			assertTrue ("The edit clipboard items such as cut and paste were enabled when TCM contextMenu using READ_SELECT", tcm.container.contextMenu == null);
		}
	}
}
	import flash.display.Sprite;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.tlf_internal;
	import flash.ui.ContextMenu;
	import flash.events.ContextMenuEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	use namespace tlf_internal;

	class CustomTextContainerManagerNull extends TextContainerManager
	{
		public function CustomTextContainerManagerNull(container:Sprite,configuration:IConfiguration =  null)
		{
			super(container, configuration);
		}
		override protected function createContextMenu():ContextMenu
		{ return null; }
	}


	class CustomTextContainerManagerAll extends TextContainerManager
	{
		public function CustomTextContainerManagerAll(container:Sprite,configuration:IConfiguration =  null)
		{
			super(container, configuration);
		}

		protected override function createContextMenu():ContextMenu
		{
			var menu:ContextMenu = super.createContextMenu();
			var item:ContextMenuItem;
			item = new ContextMenuItem("PageUp");
			menu.customItems.push(item);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
			item = new ContextMenuItem("PageDown");
			menu.customItems.push(item);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
			return menu;
		}

		private function menuItemSelectHandler(e:ContextMenuEvent):void
		{
			var key:KeyboardEvent;
			switch(e.currentTarget.caption)
			{
				case "PageUp":
					key = new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,true,0,Keyboard.PAGE_UP);
					keyDownHandler(key);
					break;
				case "PageDown":
					key = new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,true,0,Keyboard.PAGE_DOWN);
					keyDownHandler(key);
					break;
			}
		}
		
		
	}
		/******************************************************************************
		 Truncation options test for truncation of text composed using TextlineFactory
		 This is temporary till creating indepndent test file for truncation options.
		 Most of functions are modification from ConpositionTest.as
		******************************************************************************/
/****
		var lines:Array;
		var textLength:int;
		var bounds:Rectangle;
		var contentTextLength:int = textLength;
		var line0:TextLine = lines[0] as TextLine;
		var line0Extent:Number = TextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line0.y - line0.ascent : line0.y + line0.descent;
		var line0TextLen:int = line0.rawTextLength;
		var line1:TextLine = lines[1] as TextLine;
		var line1Extent:Number = TextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line1.y - line1.ascent : line1.y + line1.descent;
		var contentHeight:Number = bounds.height;
		var line:TextLine;
		var lineExtent:Number;
		var testTruncationIndicator:String
		var testFactory:TextLineFactory = new TextLineFactory();
		var originalContentPrefix:String;

		var singleLineText:String = "A single text line for truncation options test.";

		var rtlText:String =
								'مدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسة'+
								'مدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسة'+
								'مدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسة'+
								'مدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسةمدرسة';

		var accentedText:String =
		'\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A' +
		'\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A' +
		'\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A' +
		'\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A' +
		'\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A\u0041\u030A';


		//function to display the text object
		private function Callback(t1:TextLine):void
		{
			textLength += t1.rawTextLength ;
			lines.push(t1);
		}

		public function TruncationOptSingleLineCustom():void
		{
			var bounds:Rectangle = new Rectangle(40,40,100,NaN);
			testTruncationIndicator = "@@@"
			testFactory.text = singleLineText;
			var atMark:String = "@@@"
			var truncatedTxt:String = "A text line fo@@@";
			var truncationIndicatorLength:int;

			testFactory.textLinesFromString(Callback,bounds,new TruncationOptions(testTruncationIndicator,1));
			truncationIndicatorLength = truncatedTxt.lastIndexOf(testTruncationIndicator);
			assertTrue("Truncation indicator, was not @@@!", testTruncationIndicator == atMark);
			assertTrue("Truncation indicator didn't appear at the end of sentence!", truncatedTxt.length == truncationIndicatorLength+testTruncationIndicator.length);
		}

		public function TruncationOptSingleLineDefault():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = 200; bounds.height = NaN; testFactory.text = singleLineText;
			bounds.left = 0; bounds.top = 0;
			testFactory.textLinesFromString(Callback, bounds, new TruncationOptions(null, 2));
			truncationIndicatorIndex = testFactory.truncatedText.lastIndexOf(TruncationOptions.HORIZONTAL_ELLIPSIS);
			assertTrue("Default truncation indicator not present at the end of the truncated string",
			truncationIndicatorIndex+TruncationOptions.HORIZONTAL_ELLIPSIS.length == testFactory.truncatedText.length);
			originalContentPrefix = testFactory.truncatedText.slice(0, truncationIndicatorIndex);
			assertTrue("Original content before truncation indicator mangled", singleLineText.indexOf(originalContentPrefix) == 0);
		}


		public function UnspecifiedWidthTruncation():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = NaN;	bounds.height = NaN;
			bounds.left = 0; bounds.top = 0;
			TextLineFactory.createTextLinesFromString(Callback,singleLineText,bounds,null,null,null,new TruncationOptions(null, 0));
			assertTrue("Caused truncation despite unspecified width", textLength == contentTextLength);
		}

		public function ExplicitLineBreakingTruncation():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = 200; bounds.height = NaN;
			bounds.left = 0; bounds.top = 0;
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.lineBreak = LineBreak.EXPLICIT;
			TextLineFactory.createTextLinesFromString(Callback,singleLineText,bounds,null,null, format,new TruncationOptions(null, 0));
			assertTrue("Caused truncation despite explicit line breaks", textLength == contentTextLength);
		}

		public function ComposeHeightNoLine():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = 200; bounds.height = line0Extent/2;
			bounds.left = 0; bounds.top = 0;
			TextLineFactory.createTextLinesFromString(Callback,singleLineText,bounds,null,null, null,new TruncationOptions());
			assertTrue("Composed one or more lines when compose height allows none", lines.length == 0);
		}

		public function ZeroLineCountLimit():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = 200; bounds.height = contentHeight;
			bounds.left = 0; bounds.top = 0;
			TextLineFactory.createTextLinesFromString(Callback, singleLineText, bounds, null, null, null,new TruncationOptions(null, 0));
			assertTrue("Composed one or more lines when line count limit is 0", lines.length == 0);
		}

		public function UnfitTruncationIndicator():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = 200; bounds.height = contentHeight -1;
			bounds.left = 0; bounds.top = 0;
			TextLineFactory.createTextLinesFromString(Callback,singleLineText,bounds,null, null, null,new TruncationOptions(singleLineText));
			assertTrue("Composed one or more lines when compose height does not allow truncation indicator itself to fit", lines.length == 0);
		}

		public function ComposingFitToBounds():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = 200; bounds.height = NaN;
			bounds.left = 0; bounds.top = 0;
			TextLineFactory.createTextLinesFromString(Callback,singleLineText,bounds,null, null, null,new TruncationOptions(null, 2));
			assertTrue("Invalid truncation results when composing to fit in a line count limit", lines.length == 2);
		}

		public function CompostitngFitLineCountLimit():void
		{
			lines.splice(0); textLength = 0;
			bounds.left = 0; bounds.top = 0;
			TextLineFactory.createTextLinesFromString(Callback,singleLineText,bounds,null, null, null,new TruncationOptions(null, 2));
			assertTrue("Invalid truncation results when multiple truncation criteria provided",lines.length == 1);
			line = lines[0] as TextLine;
			lineExtent = TextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line.y - line.ascent : line.y + line.descent;
			assertTrue("Invalid truncation results when multiple truncation criteria provided", lineExtent <= line0Extent);
		}

		public function ComposingFitBoundsAndLineCountLimit():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = 200; bounds.height = NaN;
			bounds.left = 0; bounds.top = 0;
			TextLineFactory.createTextLinesFromString(Callback,singleLineText,bounds,null, null, null,new TruncationOptions(null, 2));
			assertTrue("Invalid truncation results when composing to fit in a line count limit", lines.length == 2);
		}

		public function ComposingFitBoundsAndLineCountLimit_2():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = 200; bounds.height = line1Extent;
			bounds.left = 0; bounds.top = 0;
			TextLineFactory.createTextLinesFromString(Callback,singleLineText,bounds,null, null, null,new TruncationOptions(null, 1));
			assertTrue("Invalid truncation results when multiple truncation criteria provided", lines.length == 1);
			line = lines[0] as TextLine;
			lineExtent = TextLineFactory.defaultConfiguration.overflowPolicy == OverflowPolicy.FIT_ANY ? line.y - line.ascent : line.y + line.descent;
			assertTrue("Invalid truncation results when multiple truncation criteria provided", lineExtent <= line1Extent);;
		}

		public function OriginalTextReplacement():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = 200; bounds.height = NaN; testFactory.text = singleLineText;
			bounds.left = 0; bounds.top = 0;
			testTruncationIndicator = '\u200B';
			testFactory.textLinesFromString(Callback, bounds, new TruncationOptions(testTruncationIndicator, 1));
			assertTrue("Replacing more original content than is neccessary", testFactory.truncatedText.length == line0TextLen+customTruncationIndicator.length);
		}

		public function OriginalTextReplacementRTL():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = 200; bounds.height = NaN; testFactory.text = rtlText;
			bounds.left = 0; bounds.top = 0;
			testTruncationIndicator = '\u200B';
			testFactory.textLinesFromString(Callback, bounds, new TruncationOptions(testTruncationIndicator, 1));
		}

		public function TruncationAtomsBoundaries():void
		{
			lines.splice(0); textLength = 0;
			bounds.width = 200; bounds.height = NaN; testFactory.text = accentedText;
			bounds.left = 0; bounds.top = 0;
			testTruncationIndicator = '<' + '\u200A' + '>'; // what precedes and succeeds the hair space is irrelevant
			testFactory.textLinesFromString(Callback, bounds, new TruncationOptions(testTruncationIndicator, 1));
			assertTrue("[Not a code bug] Fix test case so that truncation indicator itself fits", lines.length == 1); // baseline

			var initialTruncationPoint:int =  testFactory.truncatedText.length - testTruncationIndicator.length;
			assertTrue("[Not a code bug] Fix test case so that some of the original content is left behind on first truncation attempt", initialTruncationPoint > 0); // baseline
			assertTrue("Truncation in the middle of an atom!", initialTruncationPoint % 2 == 0);
			var nextTruncationPoint:int;
			do
			{
				bounds.height = NaN;
				// add another hair space in each iteration, making truncation indicator wider (ever so slightly)
				testTruncationIndicator = testTruncationIndicator.replace('\u200A', '\u200A\u200A');
				testFactory.textLinesFromString(Callback, bounds, new TruncationOptions(testTruncationIndicator, 1));

				nextTruncationPoint =  testFactory.truncatedText.length - testTruncationIndicator.length;
				if (nextTruncationPoint != initialTruncationPoint)
				{
					assertTrue("Truncation in the middle of an atom!", nextTruncationPoint % 2 == 0);
					assertTrue("Sub-optimal replacement of original content?", nextTruncationPoint == initialTruncationPoint-2);
					initialTruncationPoint = nextTruncationPoint;
				}

			} while (nextTruncationPoint);
		}
****/

