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
	import UnitTest.Fixtures.FileRepository;
	import UnitTest.Validation.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.edit.TextScrap;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.DamageEvent;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.events.FlowOperationEvent;
	import flashx.textLayout.events.ScrollEvent;
	import flashx.textLayout.events.ScrollEventDirection;
	import flashx.textLayout.events.SelectionEvent;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.events.TextLayoutEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.operations.FlowElementOperation;
	import flashx.textLayout.operations.FlowOperation;
	import flashx.textLayout.operations.InsertInlineGraphicOperation;
	import flashx.textLayout.operations.RedoOperation;
	import flashx.textLayout.operations.UndoOperation;
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.utils.GeometryUtil;
	
	import mx.controls.scrollClasses.ScrollBar;
	import mx.utils.LoaderUtil;

	use namespace tlf_internal;

	public class AllEventTest extends VellumTestCase
	{
		public function AllEventTest(methodName:String, testID:String, testConfig:TestConfig,  testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Composition";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
			FileRepository.readFile(testConfig.baseURL,"../../test/testFiles/markup/tlf/ShortTextMouseEventTBLTR.xml");
			FileRepository.readFile(testConfig.baseURL,"../../test/testFiles/markup/tlf/ShortTextMouseEventTBRTL.xml");
			FileRepository.readFile(testConfig.baseURL,"../../test/testFiles/markup/tlf/ShortTextMouseEventRLLTR.xml");
			FileRepository.readFile(testConfig.baseURL,"../../test/testFiles/markup/tlf/ShortTextMouseEventRLRTL.xml");
 			var testCaseClass:Class = AllEventTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

    	private function beginSelectionEventValidation(target:IEventDispatcher, eventCount:int, validater:Function):void
    	{
   			target.addEventListener(SelectionEvent.SELECTION_CHANGE, validater);
    	}

    	//SelectionEvent Test Cases
    	public function selectionEventTest():void
    	{
   			metaData.productArea = "Editing";

   			this.SelManager.selectRange(0,0);

			var textFlow:TextFlow = this.SelManager.textFlow;
			var endIdx:int = 200;
			var startIdx:int = 100;

			var theRects:Array = GeometryUtil.getHighlightBounds(new TextRange(textFlow, startIdx, endIdx));
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
				var index:int = SelectionManager.tlf_internal::computeSelectionIndex(textFlow, theLine, null, rect.x + (rect.width/2), rect.y + (rect.height/2));

				//validate using a calculated index.  If this is a partial line selection, then using the abs start and end isn't valid.
				var checkStart:int = tfl.absoluteStart >= startIdx ? tfl.absoluteStart : startIdx;
				var checkEnd:int = (tfl.absoluteStart + tfl.textLength) <= endIdx ? (tfl.absoluteStart + tfl.textLength) : endIdx;

				//validate
				assertTrue( "the computed index derived from the selection shape must be within the line!", checkStart <= index && checkEnd >= index);
			}

   			// Select All
   			var validator:SelectionEventValidator = new SelectionEventValidator(TestFrame.textFlow,
   				new SelectionEvent(SelectionEvent.SELECTION_CHANGE, false, false, new SelectionState(TestFrame.textFlow, 0, TestFrame.textFlow.textLength - 1)));
			SelManager.selectAll();
   			assertTrue("Expected selection event showing entire flow selected", validator.validate(1));

			// Select range
			validator.reset(new SelectionEvent(SelectionEvent.SELECTION_CHANGE, false, false, new SelectionState(TestFrame.textFlow, 10, 100)));
     		SelManager.selectRange(10, 100);
     		SelManager.refreshSelection();
   			assertTrue("Expected selection event showing range selected", validator.validate(1));

			// Apply format -- expects selection changed on selected area b/c the contents changed
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.fontSize = 48;
   			validator.reset();
			(SelManager as IEditManager).applyLeafFormat(format);
   			assertTrue("Expected selection event after formatting applied", validator.validate(1));

			// Insert text -- expects selection changed on selected area b/c the contents changed
 			const textToInsert:String = "FOO";
 			validator.reset(new SelectionEvent(SelectionEvent.SELECTION_CHANGE, false, false,
 				new SelectionState(TestFrame.textFlow, 20 + textToInsert.length, 20 + textToInsert.length)));
 			SelManager.selectRange(20, 20);
			(SelManager as IEditManager).insertText("FOO");
			SelManager.flushPendingOperations();  // force insert to happen right away
   			assertTrue("Expected selection event after text insertion", validator.validate(1));

			// Change select range - test that client code can change the selection from within a selection event handler
			textFlow.addEventListener(SelectionEvent.SELECTION_CHANGE, changeSelectionHandler);
			SelManager.selectRange(10, 100);
			SelManager.refreshSelection();
			assertTrue("Expected entire flow selected", SelManager.absoluteStart == 0 && SelManager.absoluteEnd == textFlow.textLength - 1);
			
			// Test selection by mouse. We should get one and only one event from this.
			SelManager.selectRange(10, 11);
			theRects = GeometryUtil.getHighlightBounds(new TextRange(textFlow, SelManager.absoluteStart, SelManager.absoluteEnd));
			theLine = theRects[0].textLine as TextLine;
			rect = theRects[0].rect as Rectangle;
			tfl = theLine.userData as TextFlowLine;
			var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, true, rect.x, rect.y, theLine, false, false, false, false);
			validator.reset(new SelectionEvent(SelectionEvent.SELECTION_CHANGE, false, false,
				new SelectionState(TestFrame.textFlow, 10, 10)));
			theLine.dispatchEvent(mouseEvent);
			assertTrue("Expected single selection event after mouse click", validator.validate(1));
		}

		private function changeSelectionHandler(event:SelectionEvent):void
		{
			var textFlow:TextFlow = event.selectionState.textFlow;
			textFlow.removeEventListener(SelectionEvent.SELECTION_CHANGE, changeSelectionHandler);
			textFlow.interactionManager.selectRange(0, textFlow.textLength);
		}

   		// DamageEvent Test Cases
   		public function damageEventTest():void
   		{
   			//Change Color Test
   			var selectionBegin:int = 20;
    		var selectionEnd:int = 400;
   			SelManager.selectRange(selectionBegin,selectionEnd);
   			var validator:DamageEventValidator = new DamageEventValidator(TestFrame.textFlow,
   				new DamageEvent(DamageEvent.DAMAGE, false, false, null, SelManager.absoluteStart, SelManager.absoluteEnd-SelManager.absoluteStart));
   			const fontColor:int = 0xFF0000;
			var ca:TextLayoutFormat = new TextLayoutFormat();

			ca.color = fontColor;
			SelManager.applyLeafFormat(ca);
			SelManager.flushPendingOperations();
   			assertTrue("Expected damage event showing after color change",validator.validate(1));

   			//Delete Text Test
   			validator.reset(new DamageEvent(DamageEvent.DAMAGE, false, false, null, SelManager.absoluteStart, SelManager.absoluteEnd-SelManager.absoluteStart));
   			SelManager.cutTextScrap(SelManager.getSelectionState());
   			SelManager.flushPendingOperations();
   			assertTrue("Expected damage event showing after text deletion",validator.validate(1));

   			//Delete Character Test
   			SelManager.selectRange(90,91);
   			validator.reset(new DamageEvent(DamageEvent.DAMAGE, false, false, null, SelManager.absoluteStart, SelManager.absoluteEnd-SelManager.absoluteStart));
   			SelManager.cutTextScrap(SelManager.getSelectionState());
   			SelManager.flushPendingOperations();
   			assertTrue("Expected damage event showing after character deletion",validator.validate(1));

   			//Change Geometry Test
   			validator.reset(new DamageEvent(DamageEvent.DAMAGE, false, false, TestFrame.textFlow, 0, TestFrame.textFlow.textLength));
   			TestFrame.setCompositionSize(500,500);
			TestFrame.textFlow.flowComposer.updateAllControllers();
			assertTrue("Expected damage event showing after Geometry change",validator.validate(1));

			//Change Block Progression Test
			validator.reset(new DamageEvent(DamageEvent.DAMAGE, false, false, TestFrame.textFlow, 0, TestFrame.textFlow.textLength));
   			TestFrame.textFlow.blockProgression = "rl";
			TestFrame.textFlow.flowComposer.updateAllControllers();
			assertTrue("Expected damage event showing after Block Progression change",validator.validate(1));

			//Change Font Size Test
			validator.reset(new DamageEvent(DamageEvent.DAMAGE, false, false, TestFrame.textFlow, 0, TestFrame.textFlow.textLength));
			TestFrame.textFlow.fontSize = 32;
			TestFrame.textFlow.flowComposer.updateAllControllers();
			assertTrue("Expected DamageEvent showing after Font Size change",validator.validate(1));
   		}

   		public function statusChangeEventTest():void
   		{
			metaData.productArea = "Editing";

			//Insert Picture Test
   			var src:String = LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/leaves.jpg");
   			var element:InlineGraphicElement = new InlineGraphicElement();
   			element.source = src;
   			element.width = 30;
   			element.height = 30;
   			var validator:StatusChangeEventValidator = new StatusChangeEventValidator(TestFrame.textFlow,
   				new StatusChangeEvent(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, false, false, element, "loading", null));

   			var width:int = 30;
	  		var height:int = 30;
	  		var selectionBegin:int = 10;
			var selectionEnd:int = 10;
    		SelManager.selectRange(selectionBegin, selectionEnd);
	  		SelManager.insertInlineGraphic(src,width,height);
	  		SelManager.flushPendingOperations();

	  		assertTrue("Expected StatusChangeEvent showing after picture insertion",validator.validate(1));
   		}
		
		//The following test case is designed to test bug#2929161
		[Embed( source="../../../../test/testFiles/assets/smiley.gif" )]
		private var embeddedGIF:Class;
		public function statusChangeEventHandlerTest():void
		{
			metaData.productArea = "Editing";
			
			TestFrame.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, onStatusChangeHandler);
			function onStatusChangeHandler (event:StatusChangeEvent):void
			{
				var ilg:InlineGraphicElement = event.element as InlineGraphicElement;
				if(ilg && event.status == InlineGraphicElementStatus.READY)
				{
					assertTrue("Expected inline graphic is not null",ilg.graphic != null);
				}
			}
			
			//Insert Display Object
			var yellowCircle:Sprite = new Sprite();
			yellowCircle.graphics.beginFill(0xFFFF33);	// yellow
			yellowCircle.graphics.drawCircle(10,12,10);
			yellowCircle.graphics.endFill();
			
			var width:int = 30;
			var height:int = 30;
			var selectionBegin:int = 10;
			var selectionEnd:int = 10;
			SelManager.selectRange(selectionBegin, selectionEnd);
			SelManager.insertInlineGraphic(yellowCircle,width,height);
			SelManager.flushPendingOperations();
			
			//Insert Class
			selectionBegin = 15;
			selectionEnd = 15;
			SelManager.selectRange(selectionBegin, selectionEnd);
			SelManager.insertInlineGraphic(embeddedGIF,width,height);
			SelManager.flushPendingOperations();
			
			//Insert null object
			selectionBegin = 20;
			selectionEnd = 20;
			SelManager.selectRange(selectionBegin, selectionEnd);
			SelManager.insertInlineGraphic(null,width,height);
			SelManager.flushPendingOperations();
		}

		public function FlowOperationEventTest():void
		{
			metaData.productArea = "Editing";

			var src:String = LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/leaves.jpg");
	  		var width:int = 30;
	  		var height:int = 30;
			var selectionBegin:int = 10;
			var selectionEnd:int = 10;
    		SelManager.selectRange(selectionBegin, selectionEnd);
			var operation:InsertInlineGraphicOperation = new InsertInlineGraphicOperation(SelManager.getSelectionState(),
				src, width, height,"none");
			var beginValidator:FlowOperationEventValidator = new FlowOperationEventValidator(TestFrame.textFlow,
				new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN, false, false, operation, 0, null));
			var endValidator:FlowOperationEventValidator = new FlowOperationEventValidator(TestFrame.textFlow,
				new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END, false, false, operation, 0, null));
			var completeValidator:FlowOperationEventValidator = new FlowOperationEventValidator(TestFrame.textFlow,
				new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_COMPLETE, false, false, operation, 0, null));
			var compositionValidator:CompositionCompleteEventValidator = new CompositionCompleteEventValidator(TestFrame.textFlow,
				new CompositionCompleteEvent(CompositionCompleteEvent.COMPOSITION_COMPLETE, false, false, TestFrame.textFlow, 0, TestFrame.textFlow.textLength+1));
			SelManager.insertInlineGraphic(src,width,height);
	  		assertTrue("Expected FlowOperationBeginEvent during picture insertion", beginValidator.validate(1));
			assertTrue("Expected FlowOperationEndEvent during picture insertion", endValidator.validate(1));
			assertTrue("Expected FlowOperationCompleteEvent during picture insertion", completeValidator.validate(1));
			assertTrue("Expected CompositionCompleEvent during picture insertion", compositionValidator.validate(1));

			// Check undo
			var pseudoUndoOperation:UndoOperation = new UndoOperation(operation);
			beginValidator.reset(new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN, false, false, pseudoUndoOperation, 0, null));
			endValidator.reset(new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END, false, false, pseudoUndoOperation, 0, null));
			completeValidator.reset(new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_COMPLETE, false, false, pseudoUndoOperation, 0, null));

			SelManager.undo();
			
			assertTrue("Expected FlowOperationBeginEvent during undo picture insertion", beginValidator.validate(1));
			assertTrue("Pseudo undo event should have been broadcast", FlowOperationEvent(beginValidator.lastEvent).operation is UndoOperation);
			assertTrue("Expected FlowOperationEndEvent during undo picture insertion", endValidator.validate(1));
			assertTrue("Pseudo undo event should have been broadcast", FlowOperationEvent(endValidator.lastEvent).operation is UndoOperation);
			assertTrue("Expected FlowOperationCompleteEvent undo during picture insertion", completeValidator.validate(1));
			assertTrue("Pseudo undo event should have been broadcast", FlowOperationEvent(completeValidator.lastEvent).operation is UndoOperation);

			// Check redo
			var pseudoRedoOperation:RedoOperation = new RedoOperation(operation);
			beginValidator.reset(new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN, false, false, pseudoRedoOperation, 0, null));
			endValidator.reset(new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END, false, false, pseudoRedoOperation, 0, null));
			completeValidator.reset(new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_COMPLETE, false, false, pseudoRedoOperation, 0, null));

			SelManager.redo();
			
			assertTrue("Expected FlowOperationBeginEvent during redo picture insertion", beginValidator.validate(1));
			assertTrue("Pseudo redo event should have been broadcast", FlowOperationEvent(beginValidator.lastEvent).operation is RedoOperation);
			assertTrue("Expected FlowOperationEndEvent during redo picture insertion", endValidator.validate(1));
			assertTrue("Pseudo redo event should have been broadcast", FlowOperationEvent(endValidator.lastEvent).operation is RedoOperation);
			assertTrue("Expected FlowOperationCompleteEvent redo during picture insertion", completeValidator.validate(1));
			assertTrue("Pseudo redo event should have been broadcast", FlowOperationEvent(completeValidator.lastEvent).operation is RedoOperation);
			
		}

		public function FlowCompositeOperationEventTest():void
		{
			metaData.productArea = "Editing";

			var beginValidator:FlowOperationEventValidator = new FlowOperationEventValidator(TestFrame.textFlow,
				new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN, false, false, new FlowOperation(TestFrame.textFlow), 1, null));
			var endValidator:FlowOperationEventValidator = new FlowOperationEventValidator(TestFrame.textFlow,
				new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END, false, false, new FlowOperation(TestFrame.textFlow), 1, null));
			var completeValidator:FlowOperationEventValidator = new FlowOperationEventValidator(TestFrame.textFlow,
				new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_COMPLETE, false, false, new FlowOperation(TestFrame.textFlow), 0, null));
			var compositionValidator:CompositionCompleteEventValidator = new CompositionCompleteEventValidator(TestFrame.textFlow,
				new CompositionCompleteEvent(CompositionCompleteEvent.COMPOSITION_COMPLETE, false, false, TestFrame.textFlow, 0, TestFrame.textFlow.textLength));

			SelManager.selectAll();
			SelManager.beginCompositeOperation();
			var leafFormat:TextLayoutFormat = new TextLayoutFormat();
			leafFormat.fontSize = 18;
			SelManager.applyLeafFormat(leafFormat);
			var paraFormat:TextLayoutFormat = new TextLayoutFormat();
			paraFormat.textAlign = TextAlign.CENTER;
			SelManager.applyParagraphFormat(paraFormat);
			SelManager.endCompositeOperation();

			assertTrue("Expected FlowOperationBeginEvent during composite operation", beginValidator.validate(2));
			assertTrue("Expected FlowOperationEndEvent during composite operation", endValidator.validate(2));
			assertTrue("Expected FlowOperationCompleteEvent during composite operation", completeValidator.validate(1));
			assertTrue("Expected CompositionCompleEvent during composite operation", compositionValidator.validate(1));
		}
		public function CompositionCompleteEventTest():void
		{
			var validator:CompositionCompleteEventValidator;
			var scroll:ScrollBar = new ScrollBar();
			var textHeight:int = Math.ceil(TestFrame.getContentBounds().height);
    		var textWidth:int = Math.ceil(TestFrame.getContentBounds().width);

			if (TestFrame.textFlow.blockProgression == "rl")
			{
				validator = new CompositionCompleteEventValidator(TestFrame.textFlow,
				new CompositionCompleteEvent(CompositionCompleteEvent.COMPOSITION_COMPLETE, false, false, TestFrame.textFlow, 0, 744));
			}
			else
			{
				validator = new CompositionCompleteEventValidator(TestFrame.textFlow,
				new CompositionCompleteEvent(CompositionCompleteEvent.COMPOSITION_COMPLETE, false, false, TestFrame.textFlow, 0, 831));

			}

			TestFrame.textFlow.fontSize = 30;
    		TestFrame.textFlow.flowComposer.updateAllControllers();
    		assertTrue("Expected CompositionCompleEvent showing after font size changing", validator.validate(1));
		}

		public function UpdateCompleteEventTest():void
		{
			var validator:UpdateCompleteEventValidator = new UpdateCompleteEventValidator(TestFrame.textFlow,
				new UpdateCompleteEvent(UpdateCompleteEvent.UPDATE_COMPLETE, false, false, TestFrame.textFlow, TestFrame));
			var selectionBegin:int = 40;
			var selectionEnd:int = 50;
    		SelManager.selectRange(selectionBegin, selectionEnd);
    		SelManager.deleteNextWord();
    		SelManager.textFlow.flowComposer.updateAllControllers();	// should not result in a compose and not generate an UpdateCompleteEvent
    		assertTrue("Expected One UpdateCompleteEvent showing after deleteNextWord", validator.validate(1));
		}
		
		public function ShortTextMouseEventTBLTRTest():void
		{
			ShortTextMouseEventTest();
		}
		
		public function ShortTextMouseEventTBRTLTest():void
		{
			ShortTextMouseEventTest();
		}
		
		public function ShortTextMouseEventRLLTRTest():void
		{
			ShortTextMouseEventTest();
		}
		
		public function ShortTextMouseEventRLRTLTest():void
		{
			ShortTextMouseEventTest();
		}
		
		// Test cases that should be covered
		// The link on a short text which is less wide than a line
		private function ShortTextMouseEventTest():void
		{
			var validator:FlowElementMouseEventValidator;
			SelManager.selectRange(6, 10);
			
			//get the bounds of the link
			var boundsInfo:Object = GeometryUtil.getHighlightBounds(SelManager.getSelectionState())[0];
			var bounds:Rectangle = boundsInfo.rect as Rectangle;
			var textLine:TextLine = boundsInfo.textLine;
			
			//get the link element
			var leaf:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.absoluteStart);
			var link:LinkElement = leaf.parent as LinkElement;
			
			var cc:ContainerController = SelManager.textFlow.flowComposer.getControllerAt(0);
			var textFlow:TextFlow = SelManager.textFlow;		// save it for later
			SelManager.textFlow.interactionManager = null;		// turn off editing
			var mouseOverEvent:MouseEvent;
			var mouseOutEvent:MouseEvent;
			
			//Make sure it works when scroll policy AUTO case
			cc.horizontalScrollPolicy = ScrollPolicy.AUTO;
			cc.verticalScrollPolicy = ScrollPolicy.AUTO;
			// listen for rollOver event on the link, send an ersatz mouse_over, which will cause a rollOver
			// after mouseOver, link should be in hover state
			validator = new FlowElementMouseEventValidator(link, new FlowElementMouseEvent(FlowElementMouseEvent.ROLL_OVER, false, true, link, null));
			mouseOverEvent = new MouseEvent(MouseEvent.MOUSE_OVER, true, false,
				(bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine);
			textLine.dispatchEvent(mouseOverEvent);
			validator.validate(1);
			assertTrue("after mouseOver, link should be in hover state", link.linkState == LinkState.HOVER);
			
			mouseOutEvent = new MouseEvent(MouseEvent.MOUSE_OUT, true, false,
				bounds.right + 1, bounds.bottom + 1, textLine);
			textLine.dispatchEvent(mouseOutEvent);
			
			//Make sure it works when scroll policy off case
			cc.horizontalScrollPolicy = ScrollPolicy.OFF;
			cc.verticalScrollPolicy = ScrollPolicy.OFF;
			textFlow.flowComposer.updateAllControllers();
			
			textFlow.interactionManager = SelManager;
			SelManager.selectRange(6, 10);
			boundsInfo = GeometryUtil.getHighlightBounds(SelManager.getSelectionState())[0];
			bounds = boundsInfo.rect as Rectangle;
			textLine = boundsInfo.textLine;
			
			textFlow = SelManager.textFlow;		// save it for later
			SelManager.textFlow.interactionManager = null;		// turn off editing
			
			validator = new FlowElementMouseEventValidator(link, new FlowElementMouseEvent(FlowElementMouseEvent.ROLL_OVER, false, true, link, null));
			mouseOverEvent = new MouseEvent(MouseEvent.MOUSE_OVER, true, false,
				(bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine);
			textLine.dispatchEvent(mouseOverEvent);
			validator.validate(1);
			assertTrue("after mouseOver, link should be in hover state", link.linkState == LinkState.HOVER);
			
			mouseOutEvent = new MouseEvent(MouseEvent.MOUSE_OUT, true, false,
				bounds.right + 1, bounds.bottom + 1, textLine);
			textLine.dispatchEvent(mouseOutEvent);
			
			//Test if it works when lineBreak == "toFit";
			cc.horizontalScrollPolicy = ScrollPolicy.AUTO;
			cc.verticalScrollPolicy = ScrollPolicy.AUTO;
			textFlow.lineBreak = LineBreak.TO_FIT;
			textFlow.flowComposer.updateAllControllers();
			
			textFlow.interactionManager = SelManager;
			SelManager.selectRange(6, 10);
			boundsInfo = GeometryUtil.getHighlightBounds(SelManager.getSelectionState())[0];
			bounds = boundsInfo.rect as Rectangle;
			textLine = boundsInfo.textLine;
			
			textFlow = SelManager.textFlow;		// save it for later
			SelManager.textFlow.interactionManager = null;		// turn off editing
			
			validator = new FlowElementMouseEventValidator(link, new FlowElementMouseEvent(FlowElementMouseEvent.ROLL_OVER, false, true, link, null));
			mouseOverEvent = new MouseEvent(MouseEvent.MOUSE_OVER, true, false,
				(bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine);
			textLine.dispatchEvent(mouseOverEvent);
			validator.validate(1);
			assertTrue("after mouseOver, link should be in hover state", link.linkState == LinkState.HOVER);
			
			mouseOutEvent = new MouseEvent(MouseEvent.MOUSE_OUT, true, false,
				bounds.right + 1, bounds.bottom + 1, textLine);
			textLine.dispatchEvent(mouseOutEvent);
			
			//Test if it works when doing measurement for width and/or height
			cc.horizontalScrollPolicy = ScrollPolicy.OFF;
			cc.verticalScrollPolicy = ScrollPolicy.OFF;
			cc.setCompositionSize(300, 300);
			
			textFlow.interactionManager = SelManager;
			SelManager.selectRange(6, 10);
			boundsInfo = GeometryUtil.getHighlightBounds(SelManager.getSelectionState())[0];
			bounds = boundsInfo.rect as Rectangle;
			textLine = boundsInfo.textLine;
			
			textFlow = SelManager.textFlow;		// save it for later
			SelManager.textFlow.interactionManager = null;		// turn off editing
			
			validator = new FlowElementMouseEventValidator(link, new FlowElementMouseEvent(FlowElementMouseEvent.ROLL_OVER, false, true, link, null));
			mouseOverEvent = new MouseEvent(MouseEvent.MOUSE_OVER, true, false,
				(bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine);
			textLine.dispatchEvent(mouseOverEvent);
			validator.validate(1);
			assertTrue("after mouseOver, link should be in hover state", link.linkState == LinkState.HOVER);
			
			
			// avoid tearDown assert about no Selectionmanager
			textFlow.interactionManager = SelManager;
			SelManager.selectRange(0, 0);
		}

		// Test cases that should be covered
		// 1. link on part of the line
		// 2. link across several lines
		// For now, only covering first line in link
		public function FlowElementMouseEventTest():void
		{
			var validator:FlowElementMouseEventValidator;

			var cc:ContainerController = SelManager.textFlow.flowComposer.getControllerAt(0);
			if (TestData.id == "FlowElementMouseEventTestScrollingOn")
			{
				cc.verticalScrollPolicy = ScrollPolicy.ON;
				cc.horizontalScrollPolicy = ScrollPolicy.ON;
			}else if (TestData.id == "FlowElementMouseEventTestScrolled")
			{
				cc.verticalScrollPolicy = ScrollPolicy.ON;
				cc.horizontalScrollPolicy = ScrollPolicy.ON;
				var originalXScroll:Number = cc.horizontalScrollPosition;
				var originalYScroll:Number = cc.verticalScrollPosition;
				
				// Copy and paste the entire text, which should cause a scroll event
				SelManager.selectRange(0, int.MAX_VALUE);
				var scrap:TextScrap = TextScrap.createTextScrap(new TextRange(SelManager.textFlow, 0, SelManager.textFlow.textLength));
				var validator1:EventValidator = new EventValidator(SelManager.textFlow, new ScrollEvent(TextLayoutEvent.SCROLL, false, false));
				SelManager.selectRange(int.MAX_VALUE, int.MAX_VALUE);
				SelManager.pasteTextScrap(scrap);
				assertTrue("Expected to get a scroll event, but didn't", validator1.validate(1));
				
				// Verify that the direction and delta in the event are correct
				var scrollEvent:ScrollEvent = validator1.lastEvent as ScrollEvent;
				validateScrollEvent(validator1.lastEvent as ScrollEvent, originalXScroll, originalYScroll);
				
				// scroll to a new position, and check that works as expected
				originalXScroll = cc.horizontalScrollPosition;
				originalYScroll = cc.verticalScrollPosition;
				validator1.reset(new ScrollEvent(TextLayoutEvent.SCROLL, false, false));
				validateScrollEvent(validator1.lastEvent as ScrollEvent, originalXScroll, originalYScroll);
				TestFrame.textFlow.flowComposer.updateAllControllers();
			}
			
			SelManager.selectRange(76, 85);
			SelManager.applyLink("http://www.adobe.com/go/flashplayer","_self" ,false);
			TestFrame.textFlow.flowComposer.updateAllControllers();
			
			var container:DisplayObjectContainer = SelManager.textFlow.flowComposer.getControllerAt(0).container;
			if (TestData.id == "FlowElementMouseEventTestMeasure")
			{	
				container.height = NaN;
				container.width = NaN;	
			}
     		// Get the bounds of the link in TextLine coordinates
    		var boundsInfo:Object = GeometryUtil.getHighlightBounds(SelManager.getSelectionState())[0];
    		var bounds:Rectangle = boundsInfo.rect as Rectangle;
    		var textLine:TextLine = boundsInfo.textLine;

			// get the event mirror off the link
     		var leaf:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.absoluteStart);
    		var link:LinkElement = leaf.parent as LinkElement;
   			var textFlow:TextFlow = SelManager.textFlow;		// save it for later
     		SelManager.textFlow.interactionManager = null;		// turn off editing

			// before we've done anything, link in normal state
			assertTrue("before we've done anything, link should be in normal state", link.linkState == LinkState.LINK);

    		// listen for rollOver event on the link, send an ersatz mouse_over, which will cause a rollOver
    		// after mouseOver, link should be in hover state
			validator = new FlowElementMouseEventValidator(link, new FlowElementMouseEvent(FlowElementMouseEvent.ROLL_OVER, false, true, link, null));
    		var mouseOverEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_OVER, true, false,
    			(bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine);
			textLine.dispatchEvent(mouseOverEvent);
    		validator.validate(1);
			assertTrue("after mouseOver, link should be in hover state", link.linkState == LinkState.HOVER);

			// mouseMove
			validator = new FlowElementMouseEventValidator(link, new FlowElementMouseEvent(FlowElementMouseEvent.MOUSE_MOVE, false, true, link, null));
    		var mouseMoveEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE, true, false,
    			(bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine);
			textLine.dispatchEvent(mouseMoveEvent);
    		validator.validate(1);

			// mouseDown
			validator = new FlowElementMouseEventValidator(link, new FlowElementMouseEvent(FlowElementMouseEvent.MOUSE_DOWN, false, true, link, null));
    		var mouseDownEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false,
    			(bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine);
			textLine.dispatchEvent(mouseDownEvent);
    		validator.validate(1);
			assertTrue("after mouseDown, link should be in active state", link.linkState == LinkState.ACTIVE);

			// mouseUp -- also generates click
			validator = new FlowElementMouseEventValidator(link, new FlowElementMouseEvent(FlowElementMouseEvent.MOUSE_UP, false, true, link, null));
			var clickValidator:FlowElementMouseEventValidator = new FlowElementMouseEventValidator(link, new FlowElementMouseEvent(FlowElementMouseEvent.CLICK, false, true, link, null));
    		var mouseUpEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_UP, true, false,
    			(bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine);
			textLine.dispatchEvent(mouseUpEvent);
    		validator.validate(1);
    		clickValidator.validate(1);
			assertTrue("after mouseUp, link should be in hover state", link.linkState == LinkState.HOVER);

			// mouseOut
 			validator = new FlowElementMouseEventValidator(link, new FlowElementMouseEvent(FlowElementMouseEvent.ROLL_OUT, false, true, link, null));
    		var mouseOutEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_OUT, true, false,
    			bounds.right + 1, bounds.bottom + 1, textLine);
			textLine.dispatchEvent(mouseOutEvent);
    		validator.validate(1);
 			assertTrue("after mouseOut, link should be in default (normal) state", link.linkState == LinkState.LINK);

    		// avoid tearDown assert about no Selectionmanager
    		textFlow.interactionManager = SelManager;
    		SelManager.selectRange(0, 0);
		}

		
		private function validateScrollEvent(scrollEvent:ScrollEvent, originalXScroll:Number, originalYScroll:Number):void
		{
			var flowComposer:IFlowComposer = SelManager.textFlow.flowComposer;
			var controller:ContainerController = flowComposer.getControllerAt(flowComposer.numControllers - 1);
			if (originalXScroll != controller.horizontalScrollPosition)
			{
				assertTrue("Scrolled horizontally, but got vertical scroll event", scrollEvent.direction == ScrollEventDirection.HORIZONTAL);
				assertTrue("Scroll delta doesn't match expected", scrollEvent.delta == controller.horizontalScrollPosition - originalXScroll);
			}
			if (originalYScroll != controller.verticalScrollPosition)
			{
				assertTrue("Scrolled vertically, but got horizontal scroll event", scrollEvent.direction == ScrollEventDirection.VERTICAL);
				assertTrue("Scroll delta doesn't match expected", scrollEvent.delta == controller.verticalScrollPosition - originalYScroll);
			}
		}
		
		public function scrollEventTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			controller.verticalScrollPolicy = ScrollPolicy.ON;
			controller.horizontalScrollPolicy = ScrollPolicy.ON;
			var originalXScroll:Number = controller.horizontalScrollPosition;
			var originalYScroll:Number = controller.verticalScrollPosition;

			// Copy and paste the entire text, which should cause a scroll event
			SelManager.selectRange(0, int.MAX_VALUE);
			var scrap:TextScrap = TextScrap.createTextScrap(new TextRange(textFlow, 0, textFlow.textLength));
			var validator:EventValidator = new EventValidator(SelManager.textFlow, new ScrollEvent(TextLayoutEvent.SCROLL, false, false));
			SelManager.selectRange(int.MAX_VALUE, int.MAX_VALUE);
			SelManager.pasteTextScrap(scrap);
			assertTrue("Expected to get a scroll event, but didn't", validator.validate(1));

			// Verify that the direction and delta in the event are correct
			var scrollEvent:ScrollEvent = validator.lastEvent as ScrollEvent;
			validateScrollEvent(validator.lastEvent as ScrollEvent, originalXScroll, originalYScroll);

			// Now scroll up, and check that works as expected
			originalXScroll = controller.horizontalScrollPosition;
			originalYScroll = controller.verticalScrollPosition;
			var verticalText:Boolean = textFlow.computedFormat.blockProgression == BlockProgression.RL;
			validator.reset(new ScrollEvent(TextLayoutEvent.SCROLL, false, false));
			if (verticalText)
				controller.horizontalScrollPosition = 0;
			else
				controller.verticalScrollPosition = 0;
			validateScrollEvent(validator.lastEvent as ScrollEvent, originalXScroll, originalYScroll);
		}

	}
}



