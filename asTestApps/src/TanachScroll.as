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
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	import flashx.textLayout.TextLayoutVersion;
	import flashx.textLayout.compose.TextLineRecycler;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
		
	import flash.utils.ByteArray;

	public class TanachScroll extends Sprite
	{
	    // embed tanach - this simplifies things - don't need to trust the swf and pass the xml around with it
		[Embed(source="../../test/testFiles/markup/tlf/tanach.xml",mimeType="application/octet-stream")]
		private var TanachClass : Class;

		public function TanachScroll()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 1000;

			var s:Sprite = new Sprite();
			s.x = 100;
			s.y = 100;
			addChild(s);

			var tanach:ByteArray = new TanachClass();
			var tanachData:String = tanach.readMultiByte(tanach.length,"utf-8");
			
			// Bit of a hack - AliceScroll is ~2178 lines long so lets chop out a bunch of lines
			var paras:Array = tanachData.split("</p>");
			
			tanachData = "";
			for (var idx:int = 0; idx < 2178; idx++)
			{
				tanachData += paras[idx] + "</p>\n";
			}
			tanachData += "</TextFlow>\n";

			var beginParseTime:Number = getTimer();
			textFlow = TextConverter.importToFlow(tanachData, TextConverter.TEXT_LAYOUT_FORMAT);
			
			// Other Bit of a hack - AliceScroll is ~2178 lines long so lets chop out a bunch of lines
			// textFlow.replaceChildren(2178,textFlow.numChildren);
			
			// delete 9/10 the text for faster turnaround on development
			// textFlow.replaceChildren(textFlow.numChildren/10,textFlow.numChildren);
			
			parseTime = getTimer() - beginParseTime;

			// version doing a direct flowComopser
			controller = new ContainerController(s,500,400);
			textFlow.flowComposer.addController(controller);
			textFlow.interactionManager = new EditManager();
			textFlow.flowComposer.updateAllControllers();
			
			addEventListener(Event.ENTER_FRAME,handleEnterFrame);
			testCount++;
		}
		private var textFlow:TextFlow;
		private var controller:ContainerController;
		
		// count of number of tests run this session
		private var testCount:int = 0;
		private var numberOfIterations:int = 1;
		private var deltaLines:Number = 1;
		// private var widthVal:Number;
		
		private var currIteration:int = -1;
		
		private var beginThisRender:int;
		private var timingRendering:Boolean = false;		
		// timers
		private var beginTestTime:int;
		public var totalScrollTime:int;
		public var totalRenderTime:int;
		// last parse time
		private var parseTime:Number;
		
		private var resultText:TextField;
		
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
		
		/** generate a report at the next enter frame */
		public function handleEnterFrame(event:Event): void
		{
			if (timingRendering)
			{
				totalRenderTime += getTimer()-beginThisRender;
				timingRendering = false;
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
				
				trace("TanachScroll scroll time (msecs)",totalScrollTime.toString(), "render time (msec)", totalRenderTime.toString(), "total time (msecs)",totalTestTime.toString(), " mem (K)", memoryAllocated);
				
				var testDescription:String = "numberFrames:" + currIteration + " lps:" + currIteration/totalTestTime*1000;
				
				var playerType:String = (this.debugBuild||Capabilities.isDebugger) ? "DEBUGGING build or player (not suitable for measuring performance)" : "RELEASE build and player " + Capabilities.version;
				var vellumType:String = "Vellum build: " + flashx.textLayout.TextLayoutVersion.BUILD_NUMBER + "\n" + (Configuration.tlf_internal::debugCodeEnabled ? "DEBUG vellum engine (not suitable for measuring performance)" : "RELEASE vellum engine");
				var cacheData:String = "";
				CONFIG::debug { cacheData = "\nTotal: " + TextLineRecycler.tlf_internal::cacheTotal + " Fetch: " + TextLineRecycler.tlf_internal::fetchTotal + " Hit: " + TextLineRecycler.tlf_internal::hitTotal; }
				
				var resultTextText:String = "TanachScroll\n" +  testDescription + "\nParseTime (msec): " + parseTime.toString() + "\nScrollTime (msecs): " + totalScrollTime.toString() + "\nRenderTime (msec): " + totalRenderTime.toString() + "\nTotalTestTime (msec): " + totalTestTime.toString() 
					+ " \nmem (K): " + memoryAllocated.toString() + "\n" + playerType + "\n" + vellumType + cacheData;
				trace(resultTextText);
				var resultText:TextField = new TextField();
				resultText.text = resultTextText;
				resultText.x = 80; 
				resultText.y = 100;
				resultText.width = 400;
				resultText.height = 500;
				resultText.opaqueBackground = 0xFFFFFFFF;
				this.addChild(resultText);
				this.dispatchEvent(new Event(Event.COMPLETE));
				
				removeEventListener(Event.ENTER_FRAME,handleEnterFrame);
				// delta = -controller.verticalScrollPosition;
			}
			else
			{
				var beginThisScroll:int = getTimer();
				controller.verticalScrollPosition += delta;
				totalScrollTime += getTimer()-beginThisScroll;
				
				// prepare for the next iteration
				currIteration++;
				
				// begin timing rendering
				timingRendering = true;
				beginThisRender = getTimer();
			}
		}
	}
}
