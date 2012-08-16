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
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;
	import flash.text.engine.TextRotation;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.utils.GeometryUtil;
	
	import mx.utils.LoaderUtil;

	public class SelectionTest extends VellumTestCase
	{
		public function SelectionTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			if ( TestData.rotationAmount )
				TestID = TestID + ":" + TestData.rotationAmount;


			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Editing";
			metaData.productSubArea = "Selection";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = SelectionTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

   		public override function setUp():void
   		{
			super.setUp();
   		}

   		public override function tearDown():void
   		{
   			super.tearDown();
   		}

   		// Tests the default SelectionFormat
   		public function defaultColorTest():void
		{
			assertTrue( "Default focus selection format alpha is unexpected",
						SelManager.focusedSelectionFormat.rangeAlpha == 1 );
			assertTrue( "Default focus selection format blend mode is unexpected",
						SelManager.focusedSelectionFormat.rangeBlendMode == BlendMode.DIFFERENCE );
			assertTrue( "Default focus selection format color is unexpected",
						SelManager.focusedSelectionFormat.rangeColor == 0xffffff );

			assertTrue( "Default no focus selection format alpha is unexpected",
						SelManager.unfocusedSelectionFormat.rangeAlpha == 1 );
			assertTrue( "Default no focus selection format blend mode is unexpected",
						SelManager.unfocusedSelectionFormat.rangeBlendMode == BlendMode.DIFFERENCE );
			assertTrue( "Default no focus selection format color is unexpected",
						SelManager.unfocusedSelectionFormat.rangeColor == 0xffffff );

			// inactive
			assertTrue( "Overridden non-default inactive selection format alpha is incorrect",
						SelManager.inactiveSelectionFormat.rangeAlpha == 1 );
			assertTrue( "Overridden non-default inactive selection format blend mode is incorrect",
						SelManager.inactiveSelectionFormat.rangeBlendMode == BlendMode.DIFFERENCE );
			assertTrue( "Overridden non-default inactive selection format color is incorrect",
						SelManager.inactiveSelectionFormat.rangeColor == 0xffffff );
		}

		// Tests overridding the default SelectionFormat in the Configuration.
		// Default SelectionFormat set in setUp based on XML flag
		public function overrideDefaultColorTest():void
		{
			var config:Configuration = TextFlow.defaultConfiguration.clone();

			config.focusedSelectionFormat = new SelectionFormat(0x00ff00, 0.5, BlendMode.DARKEN, 0x00ff00, 0.5, BlendMode.DARKEN, 0);
			config.unfocusedSelectionFormat = new SelectionFormat(0x00ffff, 0, BlendMode.ALPHA, 0x00ffff, 0, BlendMode.ALPHA, 0);
			config.inactiveSelectionFormat = new SelectionFormat(0xf0000f, 0.1, BlendMode.LAYER, 0xf0000f, 0.1, BlendMode.LAYER, 0);

			var textFlow:TextFlow = new TextFlow(config);
			textFlow.interactionManager = new SelectionManager();

			assertTrue( "Overridden default focus selection format alpha is incorrect",
						textFlow.interactionManager.focusedSelectionFormat.rangeAlpha == 0.5 );
			assertTrue( "Overridden default focus selection format blend mode is incorrect",
						textFlow.interactionManager.focusedSelectionFormat.rangeBlendMode == BlendMode.DARKEN );
			assertTrue( "Overridden default focus selection format color is incorrect",
						textFlow.interactionManager.focusedSelectionFormat.rangeColor == 0x00ff00 );

			// no focus
			assertTrue( "Overridden default no focus selection format alpha is incorrect",
						textFlow.interactionManager.unfocusedSelectionFormat.rangeAlpha == 0 );
			assertTrue( "Overridden default no focus selection format blend mode is incorrect",
						textFlow.interactionManager.unfocusedSelectionFormat.rangeBlendMode == BlendMode.ALPHA );
			assertTrue( "Overridden default no focus selection format color is incorrect",
						textFlow.interactionManager.unfocusedSelectionFormat.rangeColor == 0x00ffff );

			// inactive
			assertTrue( "Overridden non-default inactive selection format alpha is incorrect",
						textFlow.interactionManager.inactiveSelectionFormat.rangeAlpha == 0.1 );
			assertTrue( "Overridden non-default inactive selection format blend mode is incorrect",
						textFlow.interactionManager.inactiveSelectionFormat.rangeBlendMode == BlendMode.LAYER );
			assertTrue( "Overridden non-default inactive selection format color is incorrect",
						textFlow.interactionManager.inactiveSelectionFormat.rangeColor == 0xf0000f );
		}

		// Tests overridding the default SelectionFormat
		public function overrideColorTest():void
		{
			assertTrue(SelManager == SelManager.textFlow.interactionManager,"SelManager mismatch");

			SelManager.textFlow.interactionManager.focusedSelectionFormat    = new SelectionFormat(0xffff00, 0.25, BlendMode.HARDLIGHT, 0xffff00, 0.25, BlendMode.HARDLIGHT, 0);
			SelManager.textFlow.interactionManager.unfocusedSelectionFormat  = new SelectionFormat(0xf0ff0f, 0.75, BlendMode.INVERT, 0xf0ff0f, 0.75, BlendMode.INVERT, 0);
			SelManager.textFlow.interactionManager.inactiveSelectionFormat = new SelectionFormat(0x0f00f0, 0.44, BlendMode.LIGHTEN, 0x0f00f0, 0.44, BlendMode.LIGHTEN, 0);

			// Set to active

			assertTrue( "Overridden active focus selection format alpha is incorrect",
						SelManager.focusedSelectionFormat.rangeAlpha == 0.25 );
			assertTrue( "Overridden active focus selection format blend mode is incorrect",
						SelManager.focusedSelectionFormat.rangeBlendMode == BlendMode.HARDLIGHT );
			assertTrue( "Overridden active focus selection format color is incorrect",
						SelManager.focusedSelectionFormat.rangeColor == 0xffff00 );

			// No Focus
			assertTrue( "Overridden no focus selection format alpha is incorrect",
						SelManager.unfocusedSelectionFormat.rangeAlpha == 0.75 );
			assertTrue( "Overridden no focus selection format blend mode is incorrect",
						SelManager.unfocusedSelectionFormat.rangeBlendMode == BlendMode.INVERT );
			assertTrue( "Overridden no focus selection format color is incorrect",
						SelManager.unfocusedSelectionFormat.rangeColor == 0xf0ff0f );

			// inactive
			assertTrue( "Overridden non-default inactive selection format alpha is incorrect",
						SelManager.inactiveSelectionFormat.rangeAlpha == 0.44 );
			assertTrue( "Overridden non-default inactive selection format blend mode is incorrect",
						SelManager.inactiveSelectionFormat.rangeBlendMode == BlendMode.LIGHTEN );
			assertTrue( "Overridden non-default inactive selection format color is incorrect",
						SelManager.inactiveSelectionFormat.rangeColor == 0x0f00f0 );
		}

		// Tests overridding the SelectionFormat when the default SelectionFormat was overridden
		// Default SelectionFormat set in setUp based on XML flag
		public function overriddenColorTest():void
		{
			// Set to active

			SelManager.textFlow.interactionManager.focusedSelectionFormat = new SelectionFormat(0xfffff0, 1, BlendMode.ERASE, 0xfffff0, 1, BlendMode.ERASE, 0);
			SelManager.textFlow.interactionManager.unfocusedSelectionFormat = new SelectionFormat(0xff00ff, 0.5, BlendMode.NORMAL, 0xff00ff, 0.5, BlendMode.NORMAL, 0);
			SelManager.textFlow.interactionManager.inactiveSelectionFormat = new SelectionFormat(0xf000ff, 0.77, BlendMode.SHADER, 0xf000ff, 0.77, BlendMode.SHADER, 0);

			assertTrue( "Overridden non-default active focus selection format alpha is incorrect",
						SelManager.focusedSelectionFormat.rangeAlpha == 1 );
			assertTrue( "Overridden non-default active focus selection format blend mode is incorrect",
						SelManager.focusedSelectionFormat.rangeBlendMode == BlendMode.ERASE );
			assertTrue( "Overridden non-default active focus selection format color is incorrect",
						SelManager.focusedSelectionFormat.rangeColor == 0xfffff0 );

			// no focus
			assertTrue( "Overridden non-default no focus selection format alpha is incorrect",
						SelManager.unfocusedSelectionFormat.rangeAlpha == 0.5 );
			assertTrue( "Overridden non-default no focus selection format blend mode is incorrect",
						SelManager.unfocusedSelectionFormat.rangeBlendMode == BlendMode.NORMAL );
			assertTrue( "Overridden non-default no focus selection format color is incorrect",
						SelManager.unfocusedSelectionFormat.rangeColor == 0xff00ff );

			// inactive
			assertTrue( "Overridden non-default inactive selection format alpha is incorrect",
						SelManager.inactiveSelectionFormat.rangeAlpha == 0.77 );
			assertTrue( "Overridden non-default inactive selection format blend mode is incorrect",
						SelManager.inactiveSelectionFormat.rangeBlendMode == BlendMode.SHADER );
			assertTrue( "Overridden non-default inactive selection format color is incorrect",
						SelManager.inactiveSelectionFormat.rangeColor == 0xf000ff );
		}

		public function makeRangeShapes():void
		{
			//deselect everything
			this.SelManager.selectRange(0,0);

			var tFlow:TextFlow = this.SelManager.textFlow;
			var endIdx:int = 283;
			var startIdx:int = 84;

			var theRects:Array = GeometryUtil.getHighlightBounds(new TextRange(tFlow, startIdx, endIdx));
			for each(var lineRectPair:Object in theRects)
			{
				var theLine:TextLine = lineRectPair.textLine as TextLine;
				var rect:Rectangle = lineRectPair.rect as Rectangle;
				var tfl:TextFlowLine = theLine.userData as TextFlowLine;
				assertTrue( "userData on a textLine should be a TextFlowLine!", tfl);

				var parentObj:DisplayObjectContainer = theLine.parent;
				var selObj:Shape = new Shape();

				var globalStart:Point = new Point(rect.x, rect.y);

				//first "click" inside the bounds of the rect and make sure we have a point within the selection range:
				var index:int = SelectionManager.tlf_internal::computeSelectionIndex(tFlow, theLine, null, rect.x + (rect.width/2), rect.y + (rect.height/2));

				//validate using a calculated index.  If this is a partial line selection, then using the abs start and end isn't valid.
				var checkStart:int = tfl.absoluteStart >= startIdx ? tfl.absoluteStart : startIdx;
				var checkEnd:int = (tfl.absoluteStart + tfl.textLength) <= endIdx ? (tfl.absoluteStart + tfl.textLength) : endIdx;

				//validate
				assertTrue( "the computed index derived from the selection shape must be within the line!", checkStart <= index && checkEnd >= index);


				//draw the shape - this can serve as an example as to how to use this method for internal dev.
		 		/*globalStart = theLine.localToGlobal(globalStart);
		 		globalStart = parentObj.globalToLocal(globalStart);
				rect.x = globalStart.x;
				rect.y = globalStart.y;

				selObj.graphics.beginFill(0x27FEE0);
				selObj.alpha = .5
	 			var cmds:Vector.<int> = new Vector.<int>();
	 			var pathPoints:Vector.<Number> = new Vector.<Number>();

	 			//set the start point - topLeft
	 			cmds.push(GraphicsPathCommand.MOVE_TO);
	 			pathPoints.push(rect.x);
	 			pathPoints.push(rect.y);

	 			//line to topRight
	 			cmds.push(GraphicsPathCommand.LINE_TO);
	 			pathPoints.push(rect.x + rect.width);
	 			pathPoints.push(rect.y);

	 			//line to botRight
	 			cmds.push(GraphicsPathCommand.LINE_TO);
	 			pathPoints.push(rect.x + rect.width);
	 			pathPoints.push(rect.y + rect.height);

	 			//line to botLeft
	 			cmds.push(GraphicsPathCommand.LINE_TO);
	 			pathPoints.push(rect.x);
	 			pathPoints.push(rect.y + rect.height);

	 			//line to close the path - topLeft
	 			cmds.push(GraphicsPathCommand.LINE_TO);
	 			pathPoints.push(rect.x);
	 			pathPoints.push(rect.y);

	 			selObj.graphics.drawPath(cmds, pathPoints, flash.display.GraphicsPathWinding.NON_ZERO);
	 			parentObj.addChild(selObj);*/

			}
		}

		// Bitmap snapshots are used as validation for this test
		public function selectedTextRotationTest():void
		{
			if ( !TestData.rotationAmount )
				fail( "Test Error: Rotation amount not specified" );

			var newRotation:String;

			switch( TestData.rotationAmount )
			{
				case "auto":
					newRotation = TextRotation.AUTO;
					break;
				case "0":
					newRotation = TextRotation.ROTATE_0;
					break;
				case "90":
					newRotation = TextRotation.ROTATE_90;
					break;
				case "180":
					newRotation = TextRotation.ROTATE_180;
					break;
				case "270":
					newRotation = TextRotation.ROTATE_270;
					break;
				default:
					fail( "Test Error: Rotation amount not recognized: " + TestData.rotationAmount );
			}

			SelManager.selectAll();
			var rotationFormat:TextLayoutFormat = new TextLayoutFormat();
			rotationFormat.textRotation = newRotation;
			SelManager.applyLeafFormat( rotationFormat );
		}

		public function wordSelection():void
		{
			var textLine:String;
			var doubleClickIndexStart:int;
			var doubleClickIndexEnd:int;
			var selectStart:int;
			var selectEnd:int;
  			var width:int = 20;
  			var height:int = 20;

  			// get data from XML file
  			textLine = TestData.inputString;
  			doubleClickIndexStart = TestData.doubleClickIndexStart;
			doubleClickIndexEnd = TestData.doubleClickIndexStart;
			if (TestData.doubleClickIndexEnd)
				doubleClickIndexEnd = TestData.doubleClickIndexEnd;
			selectStart = TestData.selectStart;
			selectEnd = TestData.selectEnd;

  			SelManager.insertText(textLine);
  			if ( TestData.id == "imageWordSelection")
  			{
  				SelManager.selectRange(5,5);
  				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/smiley.gif"),width,height);
  			}else if ( TestData.id == "linkWordSelection")
  			{
  				SelManager.selectRange(0,4);
  				SelManager.applyLink("http://www.google.com", "_self", false);
  				var fl:FlowElement = SelManager.textFlow.findLeaf((doubleClickIndexStart + doubleClickIndexEnd) / 2) as FlowElement;
				var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;
  			}

		    SelManager.selectRange(doubleClickIndexStart,doubleClickIndexEnd);
			var mEvent:MouseEvent = new MouseEvent( MouseEvent.DOUBLE_CLICK );
			TestFrame.container["dispatchEvent"](mEvent);
			assertTrue( "Selection should have been from " + selectStart + " to " + selectEnd +
" but was actually from " + SelManager.absoluteStart + " to " + SelManager.absoluteEnd,
			SelManager.absoluteStart == selectStart &&
			SelManager.absoluteEnd == selectEnd );

		}

		/* this is for testing the bug 2365787.  Selecting text with shift-down breaks on last empty line
		*/
		public function SelectLineBreakOnLastEmptyLine():void
		{
			var longWordText:String = "longlonglonglonglonglong" + "\n";
		 	SelManager.insertText(longWordText);

		 	// get the rect where the first character of the second line is  displayed
        	SelManager.selectRange(0,0);
        	var testLine:TextLine =  SelManager.textFlow.flowComposer.getLineAt(1).getTextLine();
        	var characterBounds:Rectangle = testLine.getAtomBounds(0);
    		characterBounds.offset (testLine.x, testLine.y);
        	var testRect:Rectangle = new Rectangle;
        	testRect.height = characterBounds.height;
        	testRect.width = characterBounds.width;
        	var containerMatrix:Matrix = new Matrix (1,0,0,1,-characterBounds.x, -characterBounds.y);

     		//save bitmap of that rect
    		var beforeBitmapData:BitmapData = new  BitmapData(testRect.width,testRect.height);
    		beforeBitmapData.draw(TestFrame.container as IBitmapDrawable, containerMatrix, null, null, testRect);
        	var beforeBitmap:Bitmap = new Bitmap (beforeBitmapData);
        	var beforePixels:ByteArray = beforeBitmap.bitmapData.getPixels(testRect);

        	//select All Texts including the line breaker in second line
        	SelManager.selectAll();
		 	TestFrame.flowComposer.updateAllControllers();

		 	//save bitmap select All
    		var afterBitmapData:BitmapData = new  BitmapData(testRect.width,testRect.height);
    		afterBitmapData.draw(TestFrame.container as IBitmapDrawable,containerMatrix, null, null, testRect);
        	var afterBitmap:Bitmap = new Bitmap(afterBitmapData);

    		// This will do the bitmap compare of the two bitmaps.
    		var bounds:Rectangle = new Rectangle(0, 0, afterBitmap.width,afterBitmap.height);
    		var afterPixels:ByteArray = afterBitmap.bitmapData.getPixels(bounds)
            var diffPixels:ByteArray = beforeBitmap.bitmapData.getPixels(bounds);

    		afterPixels.position = 0;
    		diffPixels.position = 0;
    		var pixelCount:Number = diffPixels.bytesAvailable;
    		var diffCount:Number = 0;

   			while (diffPixels.bytesAvailable > 0)
    		{
     			var p1:int = diffPixels.readByte();
                var p2:int = afterPixels.readByte();
                if (p1 != p2)
                {
                    diffCount ++;
                }
             }

    		var diff:Number = diffCount/pixelCount*100;
   			assertTrue("The selection didn't select the last line breaker, otherwise diff > diffTolerance" + " The diff is "+
    				diff + " And the diffTolerance is " + diffTolerance, diff > diffTolerance);

		}

		private function dispatchEvent(event:Event):void
		{
			// assume containers support dispatchEvent.  Otherwise we get an error
			TestFrame.container["dispatchEvent"](event);
		}

		//click to left of line, on left edge of line, on right edge of line, to right of line, between lines, after last line
	    public function clickSelection():void
	    {
			var textInput:String = TestData.inputString;
			var posOfSelection:int = TestData.posOfSelection;
			var format:TextLayoutFormat = new TextLayoutFormat();
			format = new TextLayoutFormat();
			format.paddingLeft = 30;
			format.paddingRight = 30;
			format.paddingTop = 40;
			format.paddingBottom = 40;
			format.lineHeight = 30;
			SelManager.insertText(textInput);
			textInput = "Second line in test";
			SelManager.insertText(textInput);
			SelManager.selectRange(14, 14);
    		SelManager.splitParagraph();
  		    var tf:TextFlow = SelManager.textFlow;
			SelManager.applyFormatToElement(SelManager.textFlow,format);
  		    var firstLine:TextLine = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine();
  		    var secondLine:TextLine = SelManager.textFlow.flowComposer.getLineAt(1).getTextLine();
 			var lastLine:TextLine = secondLine;
 			var offset:Number = 0;

  		    SelManager.selectRange(0,0);
  		    if (posOfSelection <= 14) 		//selection in first line
    		{
    			var bounds_1:Rectangle = firstLine.getAtomBounds(posOfSelection);
    		}
    		else
    		{
    			var tfl_2:TextFlowLine = SelManager.textFlow.flowComposer.findLineAtPosition(posOfSelection);
    			var adjustedPosOfSelection:int = posOfSelection - tfl_2.absoluteStart;
    			var bounds_2:Rectangle = lastLine.getAtomBounds(adjustedPosOfSelection);
    		}

    		var mouseX:Number;
 			var mouseY:Number;
 			if (posOfSelection <= 14)
 			{
 				mouseX = bounds_1.x + format.paddingLeft;
 				mouseY = firstLine.y;
 			}
 			else
 			{
 				mouseX = bounds_2.x + format.paddingLeft;
 				mouseY = lastLine.y;
 			}

 			if (TestData.id == "clickAboveFirstLine")
 			{
 				mouseY = firstLine.y - 1;
 			} else if (TestData.id == "clickOnLeftOfLine")
 			{
 				mouseX = mouseX - 1;
 			} else if (TestData.id == "clickOnRightOfLine")
 			{
 				mouseX = mouseX + 1; //make sure right of the line
 			}
 			else if (TestData.id == "clickBelowLastLine")
 			{
 			    mouseY = lastLine.y + 1; // make sure click below last line
 			}
 			else if (TestData.id == "clickBetweenLinesFor2ndLine")
 			{
 				offset = (lastLine.y - firstLine.y) / 3;
 				mouseY = firstLine.y + 2*offset;  // this will go to second line
 			}
 			else if (TestData.id == "clickBetweenLinesFor1stLine")
 			{
 				offset = (lastLine.y - firstLine.y) / 3;
 				mouseY = firstLine.y + offset;  // this will go to first line
 			}

 			var mEvent:MouseEvent;
 			mEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, mouseX, mouseY, TestFrame.container);
 			TestFrame.container.dispatchEvent(mEvent);
			SelManager.flushPendingOperations();

	    	var posAfterClick:int = SelManager.activePosition;
	    	assertTrue("Position changed after click." + " Position of selected is: " + posOfSelection
	    	            + " Position of after Click: " + posAfterClick,
	    	            posOfSelection == posAfterClick);
	    }

	    //click between columns (closer to left, close to right, before first column and after last column)
	    public function clickSelectionOnColumn():void
	    {
			var ca:TextLayoutFormat = new TextLayoutFormat(TestFrame.format);
			ca.columnCount = 3;
			ca.columnGap = 10;
			ca.paddingTop = 40;
			ca.paddingLeft = 30;
			ca.paddingRight = 30;
			ca.paddingBottom = 40;
			ca.firstBaselineOffset = "auto";
			SelManager.applyContainerFormat(ca);
			SelManager.applyFormatToElement(SelManager.textFlow,ca);

			// position 34 in 2nd line of first column
		 	var x1:int = SelManager.textFlow.flowComposer.findLineAtPosition(34).x;

		 	// position 725 in 1st line of second column
		 	var x2:int = SelManager.textFlow.flowComposer.findLineAtPosition(725).x;

			// position 1493 in 3rd line of third column
		 	var x3:int = SelManager.textFlow.flowComposer.findLineAtPosition(1493).x;

			var mouseX:Number = 0;
			var mouseY:Number = 0;
			var posOfSelection:int = TestData.posOfSelection;
			var tfl:TextFlowLine = SelManager.textFlow.flowComposer.findLineAtPosition(posOfSelection);
    		var adjustedPosOfSelection:int = posOfSelection - tfl.absoluteStart;
    		var tl:TextLine = tfl.getTextLine();
    		var bounds:Rectangle = tl.getAtomBounds(adjustedPosOfSelection);

			if (TestData.id == "clickCloseToLeftColumn")
			{
 				// for this case, posOfselection = 75 which is the end of the 2nd line in 1st paragraph.
 				// bounds.x+ x1 +1 to make sure click position is closer to left column
    			mouseX = bounds.x + x1 + 1;
    			mouseY = tl.y;
 			}
 			else if (TestData.id == "clickCloseToRightColumn")
 			{
 				// for this case, posOfselection = 725 which is the beginning of the first line in second
 				// column. bounds.x + x2 - 1 to make sure click position is closer to right column
    			mouseX = bounds.x + x2 - 1;
    			mouseY = tl.y;
  			}
  			else if (TestData.id == "clickBeforeFirstColumn")
 			{
    			mouseX = bounds.x + x1 - 1; // bounds.x + x1 - 1 to make sure click position is before first column
    			mouseY = tl.y;
  			}
  			else if (TestData.id == "clickAfterLastColumn")
 			{
    			mouseX = bounds.x + x3 + 1;
    			mouseY = tl.y;
  			}

 			SelManager.selectRange(0,0);
 			var mEvent:MouseEvent;
 			mEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, mouseX, mouseY, TestFrame.container);
 			TestFrame.container.dispatchEvent(mEvent);
			SelManager.flushPendingOperations();

	    	var posAfterClick:int = SelManager.activePosition;
	    	assertTrue("Position changed after click." + " Position of selected is: " + posOfSelection
	    	            + " Position of after Click: " + posAfterClick,
	    	            posOfSelection == posAfterClick);
	    }

	    public function clickSelectionTest():void
	    {
	    	var textInput:String = TestData.inputString;
			var posOfSelection:int = TestData.posOfSelection;
			SelManager.insertText(textInput);
			if (TestData.id == "clickAtEndOfLineWithSpaces" || TestData.id == "clickEndOfLineWithSpacesAtSpace")
			{
				textInput = "      ";
				SelManager.insertText(textInput);
			}
			SelManager.selectRange(0, 0);
  		    var tl:TextLine = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine();
  		    var bounds:Rectangle = tl.getAtomBounds(posOfSelection);
  		    var mouseX:Number = bounds.x;
    		var	mouseY:Number = tl.y;
			SelManager.selectRange(0,0);
 			var mEvent:MouseEvent;
 			mEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, mouseX, mouseY, TestFrame.container);
 			TestFrame.container.dispatchEvent(mEvent);
			SelManager.flushPendingOperations();

	    	var posAfterClick:int = SelManager.activePosition;
	    	assertTrue("Position changed after click." + " Position of selected is: " + posOfSelection
	    	            + " Position of after Click: " + posAfterClick,
	    	            posOfSelection == posAfterClick);
	    }

	     public function clickContainerTest():void
	    {
	    	var textInput:String = "This is a Container test";
			var posOfSelection:int = TestData.posOfSelection;
			var format:TextLayoutFormat = new TextLayoutFormat();
			format = new TextLayoutFormat();
			format.paddingLeft = 30;
			format.paddingRight = 30;
			format.paddingTop = 40;
			format.paddingBottom = 40;

			SelManager.insertText(textInput);

			format.firstBaselineOffset = "auto";
			SelManager.applyContainerFormat(format);
			SelManager.applyFormatToElement(SelManager.textFlow,format);

			SelManager.selectRange(0, 0);

			var controller:ContainerController = SelManager.textFlow.flowComposer.getControllerAt(0);
		    var containerXPos:Number = controller.container.x;
		    var containerYPos:Number = controller.container.y;
		    var containerWidth:Number = controller.container.width;
		    var containerHeight:Number = controller.container.height;

  		  	var mouseX:Number;
    	   	var	mouseY:Number;
  		   	if (TestData.id == "clickLeftToContainer")
  		   	{
  		   		mouseX = containerXPos - 1;
    			mouseY = containerYPos;
  		  	} else if (TestData.id == "clickRightToContainer")
  		   	{
  		   		mouseX = containerXPos + containerWidth ;
    			mouseY = containerYPos;
  		   	}
  		 	else if (TestData.id == "clickTopContainer")
  		  	{
  		   		mouseX = containerXPos;
    			mouseY = containerYPos - 1;
  		   	}
  		   	else if (TestData.id == "clickBottomContainer")
  		   	{
  		   		mouseX = containerXPos + containerWidth;
    			mouseY = containerYPos + containerHeight + 1;
  		   	}

 			var mEvent:MouseEvent;
 			mEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, mouseX, mouseY, TestFrame.container);
 			TestFrame.container.dispatchEvent(mEvent);
			SelManager.flushPendingOperations();

	    	var posAfterClick:int = SelManager.activePosition;

	    	assertTrue("Position changed after click." + " Position of selected is: " + posOfSelection
	    	            + " Position of after Click: " + posAfterClick,
	    	            posOfSelection == posAfterClick);
	    }


	    public function clickInTCY():void
	    {
	    	//clean the stage, get attributes from tcyTestBase.xml, and insert texts
	    	SelManager.selectAll();
   			SelManager.deleteText();
	    	var TestText:String = "\nこれは縦中横テストです";
		 	SelManager.insertText(TestText);

	    	//appy TCY to "縦中横" in the texts
	    	var letterT:int = 4;
	    	var letterY:int = 7;
	    	SelManager.selectRange(letterT,letterY);
   			SelManager.applyTCY(true);

   			//deselct
   			SelManager.selectRange(0,0);

   			var line:TextLine = SelManager.textFlow.flowComposer.getLineAt(1).getTextLine();
 			var flowLine:TextFlowLine = line.userData as TextFlowLine;
 			var bounds:Rectangle = line.getAtomBounds(3); //set position after letter "は"
 			var mousePoint:Point =  new Point(flowLine.x, bounds.y);
   			var x_point:Number;
   			var y_point:Number;

 				if (TestData.id == "clickInTCYBeginning")
				{
					//click point after letter "は"
					x_point = mousePoint.x;
					y_point = mousePoint.y;
 				}

 				else if (TestData.id == "clickInTCYMiddle")
				{
					//click point between letter "縦" and"中"
					x_point = mousePoint.x;
					y_point = mousePoint.y + 18;
 				}

 				else if (TestData.id == "clickInTCYMiddle2")
 				{
					//click point between letter"中" and"横"
 					 x_point = mousePoint.x + 18;
					 y_point = mousePoint.y + 18;
 				}

 				else if (TestData.id == "clickInTCYEnd")
 				{
					//click point after letter "横"
 					 x_point = mousePoint.x + 36;
					 y_point = mousePoint.y + 18;
 				}

   			var TCYpoint:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, x_point, y_point, TestFrame.container);
 			TestFrame.container.dispatchEvent(TCYpoint);

 			var activePoint:int = SelManager.activePosition;
			var clickPoint:int = TestData.clickPoint; //local point after click
			assertTrue("Position changed after click in TCY." + " Position clicked was " + activePoint + "."
	    	+ " Position trying to click was " + "." + clickPoint, activePoint == clickPoint);
		}
		
		public function selectInEmptyFlow():void
		{
			// test selection in an empty, not yet normalized TextFlow
			var textFlow:TextFlow = new TextFlow();
			textFlow.interactionManager = new SelectionManager();
			textFlow.interactionManager.selectRange(0, 0);
			assertTrue("Selection at start of flow", textFlow.interactionManager.absoluteStart == 0 && textFlow.interactionManager.absoluteEnd == 0);
		}

		public function selectAll():void
		{
			SelManager.selectAll();
			assertTrue("Expected entire flow expect last CR to be selected", SelManager.absoluteStart == 0 && SelManager.absoluteEnd == SelManager.textFlow.textLength - 1);
		}
		
		public function clickEndOfLine():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			//create four text lines
			SelManager.insertText("AAAAAAAA\n");
			SelManager.insertText("AAAAAAAA\n");
			SelManager.insertText("AAAAAAAA\n");
			SelManager.insertText("AAAAAAAA");
			TestFrame.textFlow.flowComposer.updateAllControllers();
			
			var container:Sprite = TestFrame.textFlow.flowComposer.getControllerAt(0).container;
			var textLine:TextLine = container.getChildAt(0) as TextLine;
			var line:TextFlowLine = textLine.userData;
			var selectStart:int = line.absoluteStart + line.textLength - 1;
			var selectEnd:int = selectStart;
			
			// Simulate a click in the container
			var xLineEnd:int = textLine.x + textLine.textWidth + 5 /* fudge factor */;
			var yLineEnd:int = textLine.y - 2 /* fudge factor so it won't be below the midline */;		// baseline
			container.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, true, xLineEnd, yLineEnd, container));
			assertTrue( "Selection should have been from " + selectStart + " to " + selectEnd +
				" but was actually from " + SelManager.absoluteStart + " to " + SelManager.absoluteEnd,
				SelManager.absoluteStart == selectStart &&
				SelManager.absoluteEnd == selectEnd ); 

			// try again using the TextLine as relatedObject
			xLineEnd = textLine.textWidth + 5 /* fudge factor */;
			yLineEnd = -2 /* fudge factor so it won't be below the midline */;		// baseline
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, true, xLineEnd, yLineEnd, textLine));
			assertTrue( "Selection should have been from " + selectStart + " to " + selectEnd +
				" but was actually from " + SelManager.absoluteStart + " to " + SelManager.absoluteEnd,
				SelManager.absoluteStart == selectStart &&
				SelManager.absoluteEnd == selectEnd ); 

		}
		
		public function FlowElement_deepCopy():void
		{
			var container:Sprite = new Sprite();
			var p:ParagraphElement = new ParagraphElement();
			var span1:SpanElement = new SpanElement();
			var span2:SpanElement = new SpanElement();
			// add text to the spans and spans to the paragraph
			span1.text = "Hello, ";
			span2.text = "World!";
			p.fontSize = 48;
			p.addChild(span1);
			p.addChild(span2);
			// make a deep copy of paragraph p, starting at relative offset 3; copy to end
			var p2:ParagraphElement = p.deepCopy(3, -1) as ParagraphElement; 
			// add copied paragraph (p2) to textflow; add composer and controller 
			SelManager.textFlow.addChild(p); // original 'Hello, World!"
			SelManager.textFlow.addChild(p2); // 'lo, World!'
			
			//make sure the second paragraph textlength is 3 less than the original lenth
			assertTrue ("deepCopy doesn't copy the correct texts.", (p.textLength - 3 ) == p2.textLength);
			
			// make a deep copy by default parameters
			var p3:ParagraphElement = p.deepCopy() as ParagraphElement;
			SelManager.textFlow.addChild(p3); // 'Hello, World!'
			//make sure the third paragraph textlength is same as the original lenth
			assertTrue ("deepCopy doesn't copy the correct texts.", p.textLength == p3.textLength);
			
			// make a copy starting from index 0
			var p4:ParagraphElement = p.deepCopy(0, -1) as ParagraphElement; 
			SelManager.textFlow.addChild(p4); // 'Hello, World!'
			//make sure the fourth paragraph textlength is same as the original lenth
			
			assertTrue ("deepCopy doesn't copy the correct texts.", p.textLength == p4.textLength);
			var controller:ContainerController = new ContainerController(container, 200, 300 );
			SelManager.textFlow.flowComposer.addController(controller);
			SelManager.textFlow.flowComposer.updateAllControllers();    
		}
		
		private function initializeFlow(textFlow:TextFlow):TextFlow
		{
			VellumTestCase.testApp.contentChange (textFlow);
			TestDisplayObject = VellumTestCase.testApp.getDisplayObject();
			TestFrame = textFlow.flowComposer.getControllerAt(0);
			if (TestFrame.rootElement)
			{
				SelManager = EditManager(textFlow.interactionManager);
				if(SelManager) 
				{
					//make sure there is never any blinking when running these tests
					setCaretBlinkRate (0);
				}
			}
			return textFlow;
		}
		
		private function selectionHelper(markup:String, startPos:int, endPos:int):void
		{
			var textFlow:TextFlow = initializeFlow(TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT));
			textFlow.flowComposer.updateAllControllers();
			SelManager.selectRange(startPos, startPos);
			textFlow.flowComposer.updateAllControllers();
			if (startPos != endPos)
			{
				SelManager.selectRange(startPos, endPos);
				textFlow.flowComposer.updateAllControllers();
			}
		}
		
		public function selectRangeTest():void
		{
			// 2792266 - select in ltr paragraph all whose chars are rtl
			selectionHelper('<TextFlow fontFamily="Times New Roman" fontSize="24" whiteSpaceCollapse="preserve" version="2.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p direction="ltr" locale="he"><span> ארבע חמש שש שבע שמונה תשע</span></p>' +
				'<p direction="rtl" locale="ar"><span>0123456789 سلام ﾠصفر واحد إثنان ثلاثة أربعة خمسة ستة سبعة ثمانية</span></p></TextFlow>', 24, 34);

			// 2545628 - select 'fl' ligature char
			selectionHelper("<TextFlow xmlns='http://ns.adobe.com/textLayout/2008' fontSize='36' fontWeight='bold' typographicCase='uppercase' color='#ff0000'>ﬁﬂ</TextFlow>",
				2, 2);
		}

	// Selection Tests  -ltr/rtl/rl
	/*	1 - 11, 14, 15, 20, 12(partial) Done
	// 16 - 18 Done

	// Selection Tests  -ltr/rtl/rl
	/*	1 - 7 Done
		1. Click to left of line (ltr/rtl)
		2. Click on left edge of line {ltr/rtl)
		3. Click on right edge of line (rtl/ltr)
		4. Click to the right of line (ltr/rtl)
		5. Click above first line (in padding)
		6. Click between lines (in leading)
		7. Click after last line (in padding)
		8. Click between columns (closer to left)
		9. Click between columns (closer to right)
		10. Click before first column (in padding)
		11. Click after last column (in padding)
		12. Click on stage near container (left/top/right/bottom)
			-> linked containers with different width/height
		13. Emulate drag select from one container to the next
		14 Click between Arabic & English (leading edge/trailing edge)
		15. Click between English & Arabic (leading edge/trailing edge)
		16. Click in TCY at start
		17. Click in TCY at end
		18. Click in TCY in middle

	Validate selection highlight in all cases
	Test with extend selection
	*/
	}
}
