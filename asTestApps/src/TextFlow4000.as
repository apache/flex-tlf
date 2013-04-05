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
package {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.LineJustification;
	import flash.text.engine.SpaceJustifier;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	import flashx.textLayout.TextLayoutVersion;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

	public class TextFlow4000 extends Sprite
	{
  		// sizes for item placement
		public	var textWidth:Number = 30;
		public	var textHeight:Number = 12;

		// data for the current run
		private var numberOfFields:int = 0;
		private var numberOfIterations:int = 0;
		private var testDataText:String;
		private var _bounds:Rectangle = new Rectangle(0,0,300,100);


		private var beginCreationTime:int;
		private var endCreationTime:int;
		private var beginRenderTime:int;

		// state for running tests
		private var currIteration:int = -1;
		private var queueResults:Boolean;

		private var beginThisRender:int;
		private var timingRendering:Boolean = false;

		// timers
		private var beginTestTime:int;
		private var totalCreationTime:int;
		private var totalRenderTime:int;


		private var resultText:TextField;

  		private var _func:String;

		public function TextFlow4000()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
    	    stage.align = StageAlign.TOP_LEFT;
    	    runTheTest();
  		}

		private function getDebugMode():Boolean
		{

			var e:Error = new Error();
			var s:String = e.getStackTrace();
			// seems to work
			return s ? true : false;
		}


		public function runTheTest():void
		{

			// clear the previous run
			/* if (resultText)
			{
				lineHolder.removeChild(resultText);
				resultText = null;
			} */

			//TextFlow.defaultConfiguration.textFlowInitialFormat = null;

			numberOfFields = 4000; // int(numberFieldsInput.text);
			numberOfIterations = 1; // int(numberIterationsInput.text);
			_func = "buildVellumExampleTextFlow"; // testTypeArray[testTypeCombo.selectedIndex].data;
			testDataText = "Hello World";

			currIteration = 0;
			queueResults = false;
			addEventListener(Event.ENTER_FRAME,handleEnterFrame);
			totalCreationTime = 0;
			totalRenderTime = 0;
			beginTestTime = getTimer();
		}

		private var totalTestTime:int;

  		/** generate a report at the next enter frame */
		public function handleEnterFrame(e:Event): void
		{
			if (currIteration == -1)
				return;

			if (timingRendering)
			{
				totalRenderTime += getTimer()-beginThisRender;
				timingRendering = false;
			}

			if (currIteration == numberOfIterations)
			{
				if (queueResults)
				{
					var memoryAllocated:Number = flash.system.System.totalMemory/1024;

					trace(_func,"creation time (msecs)",totalCreationTime.toString(), "render time (msecs)",totalRenderTime.toString(), "total time (msecs)",totalTestTime.toString(), " mem (K)", memoryAllocated);

					var testDescription:String = "fields: " + numberOfFields.toString() + " iters: " + numberOfIterations.toString() + " data: " + testDataText;

					var playerType:String = this.getDebugMode() ? "DEBUGGING PLAYER (not suitable for measuring performance)" : "RELEASE PLAYER "+Capabilities.version;
					var vellumType:String = "Vellum build: " + flashx.textLayout.TextLayoutVersion.BUILD_NUMBER + "\n" + (Configuration.tlf_internal::debugCodeEnabled ? "DEBUG vellum engine (not suitable for measuring performance)" : "RELEASE vellum engine");

					var caching:String = "";
					//CONFIG::debug { caching = "\nSeeks: " + TextFlow._dictionarySeeks + " Hits: " + TextFlow._dictionaryHits + " Collisions: " + TextFlow._dictionaryCollisions; }
					resultText = new TextField();
					resultText.text = _func + "\n" +  testDescription + "\nCreationTime (msecs): " + totalCreationTime.toString() + "\nRenderTime (msec): " + totalRenderTime.toString() + "\nTotalTime (msec): " + totalTestTime.toString()
						+ " \nmem (K): " + memoryAllocated.toString() + "\n" + playerType + "\n" + vellumType + caching;
					resultText.x = 100;
					resultText.y = 140;
					resultText.autoSize = TextFieldAutoSize.LEFT;
					//resultText.setStyle("fontFamily", "Minion Pro");
					//resultText.setStyle("fontSize", 24);
					resultText.opaqueBackground = 0xf0ffff;
					this.addChild(resultText);

					currIteration = -1;
					removeEventListener(Event.ENTER_FRAME,handleEnterFrame);
				}
				else if (!queueResults)
				{
					totalTestTime = getTimer()-beginTestTime;
					flash.system.System.gc();	//mark
					flash.system.System.gc();	//sweep
					// forces gc???
					try {
	                     new LocalConnection().connect('dummy');
	                     new LocalConnection().connect('dummy');
	                } catch (e:*) {}
	                queueResults = true;
				}
			}
			else
			{
				createOneStep();
				currIteration++;
				timingRendering = true;
				beginThisRender = getTimer();
			}
  		}

  		public function createOneStep():void
		{
			while (this.numChildren)
				this.removeChildAt(0);

			var begTime:int = getTimer();

			var funcCall:Function = this[_func];

			/* for (var testNum:int = 0; testNum < numberOfFields; testNum++)
			{
				var example:DisplayObject = funcCall();
				if (example)
				{
					example.x = 10 + (this.stage.stageWidth - 90) * Math.random();
					example.y = 40 + (this.stage.stageHeight-80) * Math.random();
					this.addChild(example);
				}
			} */

			const xInit:Number = 10;
			const yInit:Number = 10;
			const xDelta:Number = 90;
			const yDelta:Number = 15;

			var xpos:Number = xInit;
			var ypos:Number = yInit;

			for (var testNum:int = 0; testNum < numberOfFields; testNum++)
			{
				var example:DisplayObject = funcCall();
				if (example)
				{
					example.x = xpos;
					example.y = ypos;
					this.addChild(example);

					xpos += xDelta;
					if (xpos + xDelta > this.stage.stageWidth)
					{
						xpos = xInit;
						ypos += yDelta;
						if (ypos + 2*yDelta > this.stage.stageHeight)
							ypos = yInit;
					}
				}

			}

			totalCreationTime += getTimer()-begTime;
		}

		public function buildVellumExampleTextFlow():DisplayObject
		{
			var tf:TextFlow = new TextFlow();
			var p:ParagraphElement = new ParagraphElement();
			tf.addChild(p);
			var s:SpanElement = new SpanElement();
			p.addChild(s);
			s.text = testDataText;

			var rslt:Sprite = new Sprite();
			tf.flowComposer.addController(new ContainerController(rslt,_bounds.width,_bounds.height));
			tf.flowComposer.updateAllControllers();
			return rslt;
		}

	}
}
