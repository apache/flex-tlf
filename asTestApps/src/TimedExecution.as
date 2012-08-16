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
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import flashx.textLayout.TextLayoutVersion;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	public class TimedExecution 
	{		
		private var numberOfIterations:int = 0;
		private var testDescription:String;
		private var sprite:Sprite;
		
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
		
		private var func:Function;	
		
		public function TimedExecution(sprite:Sprite, numberOfIterations:int, functionToRun:Function, testDescription:String)
		{
			this.numberOfIterations = numberOfIterations;
			func = functionToRun;
			this.testDescription = testDescription;
			this.sprite = sprite;
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
			currIteration = 0;
			queueResults = false;
			sprite.addEventListener(Event.ENTER_FRAME,handleEnterFrame);
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
					
					trace("creation time (msecs)",totalCreationTime.toString(), "render time (msecs)",totalRenderTime.toString(), "total time (msecs)",totalTestTime.toString(), " mem (K)", memoryAllocated);
					
					var testDescription:String = " iters: " + numberOfIterations.toString() + this.testDescription;
					
					var playerType:String = this.getDebugMode() ? "DEBUGGING PLAYER (not suitable for measuring performance)" : "RELEASE PLAYER "+Capabilities.version;
					var vellumType:String = "Vellum build: " + flashx.textLayout.TextLayoutVersion.BUILD_NUMBER + "\n" + (Configuration.tlf_internal::debugCodeEnabled ? "DEBUG vellum engine (not suitable for measuring performance)" : "RELEASE vellum engine");
					
					resultText = new TextField();
					resultText.text = testDescription + "\nCreationTime (msecs): " + totalCreationTime.toString() + "\nRenderTime (msec): " + totalRenderTime.toString() + "\nTotalTime (msec): " + totalTestTime.toString() 
						+ " \nmem (K): " + memoryAllocated.toString() + "\n" + playerType + "\n" + vellumType;
					resultText.x = 100; 
					resultText.y = 140;
					resultText.autoSize = TextFieldAutoSize.LEFT;
					//resultText.setStyle("fontFamily", "Minion Pro");
					//resultText.setStyle("fontSize", 24);
					resultText.opaqueBackground = 0xf0ffff;
					sprite.addChild(resultText);
					
					currIteration = -1;
					sprite.removeEventListener(Event.ENTER_FRAME,handleEnterFrame);
				}
				else if (!queueResults)
				{
					totalTestTime = getTimer()-beginTestTime;
					flash.system.System.gc();
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
			while (sprite.numChildren)
				sprite.removeChildAt(0);
			
			var begTime:int = getTimer();		
						
			func();
			
			totalCreationTime += getTimer()-begTime;
		}
		
		
	}	
}
