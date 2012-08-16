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
package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	import flashx.textLayout.TextLayoutVersion;
	import flashx.textLayout.compose.TextLineRecycler;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	public class ScrollTestHelper
	{
		public var testName:String;
		public var sprite:Sprite;
		public var parent:Sprite;
		public var resultText:TextField;
		
		public function beginTest(testName:String,textFlow:TextFlow,parseTime:Number,s:Sprite,w:Number,h:Number,parent:Sprite):void
		{
			this.testName = testName;
			this.textFlow = textFlow;
			this.parseTime = parseTime;
			this.sprite = s;
			this.parent = parent;
			beginTestTime = getTimer();

			// version doing a direct flowComopser
			controller = new ContainerController(s,w,h);
			textFlow.flowComposer.addController(controller);
			textFlow.interactionManager = new EditManager();
			textFlow.flowComposer.updateAllControllers();
			
			parent.addEventListener(Event.ENTER_FRAME,handleEnterFrame);
			testCount++;
		}
		public var textFlow:TextFlow;
		public var controller:ContainerController;
				
		// count of number of tests run this session
		private var testCount:int = 0;
		private var numberOfIterations:int = 1;
		private var deltaLines:Number = 1;
		// private var widthVal:Number;
		
		public var currIteration:int = -1;
		
		private var beginThisRender:int;
		private var timingRendering:Boolean = false;		
		// timers
		public var beginTestTime:int;
		public var totalScrollTime:int;
		public var totalRenderTime:int;
		// last parse time
		private var parseTime:Number;
		
		
		// tells if this is a debug or release build of the software
		private function setDebugBuildFlag():void
		{
			try
			{
				var e:Error = new Error();
				var s:String = e.getStackTrace();
				// trace(s);
				var i:int = s.indexOf("setDebugFlag");
				if (s.charAt(i + 14) == '[')
					debugBuild = true;
			}
			catch (e2:Error)
			{ }
		}
		
		public var debugBuild:Boolean = false;
		
		// override these functions to observe and behave differently
		public function noteLPS(lps:Number):void
		{
		}
		public function noteTestComplete():void
		{
		}
		
		/** generate a report at the next enter frame */
		public function handleEnterFrame(event:Event): void
		{
			if (timingRendering)
			{
				totalRenderTime += getTimer()-beginThisRender;
				timingRendering = false;
				
				noteLPS(currIteration/(getTimer()-this.beginTestTime)*1000)
			}
			
			var delta:Number = controller.getScrollDelta(deltaLines);
			
			// report results
			if (delta == 0)
			{
				var totalTestTime:int = getTimer()-this.beginTestTime;
				flash.system.System.gc();	//mark
				flash.system.System.gc();	//sweep
				var memoryAllocated:Number = flash.system.System.totalMemory/1024;
				
				setDebugBuildFlag();
				
				trace(testName + " scroll time (msecs)",totalScrollTime.toString(), "render time (msec)", totalRenderTime.toString(), "total time (msecs)",totalTestTime.toString(), " mem (K)", memoryAllocated);
				
				var testDescription:String = "numberFrames:" + currIteration + " lps:" + currIteration/totalTestTime*1000;
				
				var playerType:String = (this.debugBuild||Capabilities.isDebugger) ? "DEBUGGING build or player (not suitable for measuring performance)" : "RELEASE build and player " + Capabilities.version;
				var vellumType:String = "Vellum build: " + flashx.textLayout.TextLayoutVersion.BUILD_NUMBER + "\n" + (Configuration.tlf_internal::debugCodeEnabled ? "DEBUG vellum engine (not suitable for measuring performance)" : "RELEASE vellum engine");
				var cacheData:String = "";
				CONFIG::debug { cacheData = "\nTotal: " + TextLineRecycler.tlf_internal::cacheTotal + " Fetch: " + TextLineRecycler.tlf_internal::fetchTotal + " Hit: " + TextLineRecycler.tlf_internal::hitTotal; }
				
				var resultTextText:String = testName + "\n" +  testDescription + "\nParseTime (msec): " + parseTime.toString() + "\nScrollTime (msecs): " + totalScrollTime.toString() + "\nRenderTime (msec): " + totalRenderTime.toString() + "\nTotalTestTime (msec): " + totalTestTime.toString() 
					+ " \nmem (K): " + memoryAllocated.toString() + "\n" + playerType + "\n" + vellumType + cacheData;
				trace(resultTextText);
				resultText = new TextField();
				resultText.text = resultTextText;
				resultText.x = 80; 
				resultText.y = 100;
				resultText.width = 400;
				resultText.height = 500;
				resultText.opaqueBackground = 0xFFFFFFFF;
				parent.addChild(resultText);
				parent.dispatchEvent(new Event(Event.COMPLETE));
				
				parent.removeEventListener(Event.ENTER_FRAME,handleEnterFrame);
				// delta = -controller.verticalScrollPosition;
				
				noteTestComplete();
			}
			else
			{
				CONFIG::debug
				{
					if (Debugging.generateDebugTrace)
					{
						trace("	public function drawFrame" + (currIteration+2).toString() + "():void")
						trace("	{")
					}
				}
				var beginThisScroll:int = getTimer();
				if (controller.textFlow.computedFormat.blockProgression == BlockProgression.TB)
					controller.verticalScrollPosition += delta;
				else
					controller.horizontalScrollPosition += delta;
				totalScrollTime += getTimer()-beginThisScroll;
				
				// prepare for the next iteration
				currIteration++;
				
				// begin timing rendering
				timingRendering = true;
				beginThisRender = getTimer();
				
				CONFIG::debug
				{
					if (Debugging.generateDebugTrace)
						trace("	}")
				}
			}
		}
	}
}

