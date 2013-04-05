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
	import UnitTest.Validation.CompositionResults;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.TextLayoutFormat;

 	public class ImportTest extends VellumTestCase
	{
		//private var importFileName:String;

		public function ImportTest(fileToImport:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super ("doThis", testID, testConfig, testCaseXML);
			TestData.fileName = TestData.testFile;

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Import/Export";
		}

		private var _errors:Vector.<String>;

		public override function importContent (content:Object):void
		{
			var parser:ITextImporter = importParser;
			var textFlow:TextFlow = parser.importToFlow(content);
			_errors = parser.errors;

			setUpFlowForTest(textFlow);
		}

		public function doThis():void
		{
			var tf:TextFlow = TestFrame.rootElement.getTextFlow();
			// only change it if different.  doesn't disturb existing results this way.
			if (tf.computedFormat.blockProgression != writingDirection[0])
				tf.blockProgression = this.writingDirection[0];
			if (tf.computedFormat.direction != writingDirection[1])
				tf.direction = this.writingDirection[1];
			if (this.TestData.hasOwnProperty("locale"))
				tf.locale = TestData.locale;
			tf.flowComposer.updateAllControllers();

			// assertTrue("Errors found on import",_errors == null);

			SelManager = EditManager(tf.interactionManager);
			checkForInlines();
		}
		
		override public function tearDown():void
		{
			compareResultsToFactory();
			super.tearDown();
		}


		private static var textFlowFactory:TextFlowTextLineFactory = new TextFlowTextLineFactory();
		
		private function compareResultsToFactory():void
		{
			// When we load simple, we overrode lots of stuff in the controller, making this comparison invalid
			if (fileName == defaultFileName)
				return;
			
			// Compare the results we get running through ComposeState to what we get from SimpleCompose (the factory composer).
			// Results should match unless the format values are overridden in the controller, which is invisible to the factory.
			var textFlow:TextFlow = SelManager.textFlow;
			
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			var verticalText:Boolean = textFlow.computedFormat.blockProgression == BlockProgression.RL;
			var tfResults:Array = CompositionResults.getTextFlowResults(textFlow);
			var textLineArray:Array = [];
			textFlowFactory.compositionBounds = new Rectangle(0, 0, controller.compositionWidth, controller.compositionHeight);
			//textFlow.flowComposer = null; // this releases all the inlinegraphics
			textFlowFactory.createTextLines(gatherLines, textFlow);
			textFlow.flowComposer = new StandardFlowComposer();
			textFlow.flowComposer.addController(controller);
			var factoryResults:Array = CompositionResults.getFactoryResults(textLineArray);
			CompositionResults.assertEquals("Factory and TextFlow composition should match", tfResults, factoryResults, !verticalText);
			
			
			function gatherLines(displayObject:DisplayObject):void
			{
				if (displayObject is TextLine)
					textLineArray.push(displayObject);
			}
		}
		
		private function updateCompletionHandler(event:Event):void
		{	 }

		private var notReadyGraphicsCount:int;

		// If there are inlines still loading, add a call back so we snapshot after load is complete
 		private function checkForInlines(callBack:Object = null):void
 		{
			var textFlow:TextFlow = TestFrame.rootElement.getTextFlow();
 			if (!callBack)
 			{
 				notReadyGraphicsCount = 0;
 				for (var leaf:FlowLeafElement = textFlow.getFirstLeaf(); leaf != null; leaf = leaf.getNextLeaf())
 					if (leaf is InlineGraphicElement && InlineGraphicElement(leaf).status != InlineGraphicElementStatus.READY)
 						notReadyGraphicsCount++;
 				if (notReadyGraphicsCount != 0)
	 				textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(checkForInlines,2500,null),false,0,true);
		 	}
		 	else
		 	{
		 		var event:StatusChangeEvent = StatusChangeEvent(callBack);
				switch (event.status)
				{
					case InlineGraphicElementStatus.LOADING:
					case InlineGraphicElementStatus.SIZE_PENDING:
						textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(checkForInlines,2500,null),false,0,true);
						break;
					case InlineGraphicElementStatus.READY:
						notReadyGraphicsCount--;
						if (notReadyGraphicsCount != 0)
							textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(checkForInlines,2500,null),false,0,true);
						else if (textFlow.flowComposer.composing)
							textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE,addAsync(updateCompletionHandler,2500,null),false,0,true);
						else
							textFlow.flowComposer.updateAllControllers();
						break;
					default:
						assertTrue("unexpected StatusChangeEvent status: "+event.status,false);
						break;
				}
		 	}
 		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = ImportTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}
	}
}
