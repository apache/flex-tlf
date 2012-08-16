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
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.engine.TextLine;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import flashx.textLayout.TextLayoutVersion;
	import flashx.textLayout.compose.TextLineRecycler;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	public class AliceScroll extends Sprite
	{
	    // embed alice - this simplifies things - don't need to trust the swf and pass the xml around with it
		// [Embed(source="../../test/testFiles/markup/tlf/AliceID.xml",mimeType="application/octet-stream")]
		[Embed(source="../../test/testFiles/markup/tlf/alice.xml",mimeType="application/octet-stream")]
		private var AliceClass : Class;
		
		static public const NARROW:String = "narrow";
		static public const NORMAL:String = "normal";
		
		private var _blockProgression:String = BlockProgression.TB;
		private var _dimension:String = NORMAL;
		
		public var helper:ScrollTestHelper;
		public var startButton:TextField;
		public var lpsTextField:TextField;
		
		public function AliceScroll()
		{			
			trace("ALICESCROLL BEGIN", getTimer());

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 1000;
			
			// TextLineRecycler.textLineRecyclerEnabled = false;
			// Debugging.generateDebugTrace = true;
			
			var b:TextField = startButton = addButton("START",10,10,0,0,startTest);
			b = addButton(_blockProgression,b.x+b.width+10,10,0,0,toggleBP);
			b = addButton(_dimension,b.x+b.width+10,10,0,0,toggleDimension);
			b = addButton("GC",b.x+b.width+10,10,0,0,dogc);
			b = addButton("Release",b.x+b.width+10,10,0,0,releaseEverything);
			
			var playerType:String = Capabilities.isDebugger ? " DEBUGGER" : "";
			var vellumType:String = Configuration.debugCodeEnabled ? "DEBUG" : "RELEASE"
			
			// controls
			b = addButton("AliceScroll " + Capabilities.version + playerType + " TLF: " + TextLayoutVersion.tlf_internal::BUILD_NUMBER + " " + vellumType,b.x+b.width+10,10,0,0,null);
			
			lpsTextField = addButton("",b.x+b.width+10,10,0,0,null);
		}
			
		public function startTest(e:Event):void
		{
			startButton.visible = false;
			
			// cleanup previous run
			if (helper)
			{
				this.removeChild(helper.sprite);
				this.removeChild(helper.resultText);
				helper = null;
			}

			var s:Sprite = new Sprite();
			s.x = 100;
			s.y = 100;
			addChild(s);

			var alice:ByteArray = new AliceClass();
			var aliceData:String = alice.readMultiByte(alice.length,"utf-8");

			var beginParseTime:Number = getTimer();
			var textFlow:TextFlow = TextConverter.importToFlow(aliceData, TextConverter.TEXT_LAYOUT_FORMAT);
			var parseTime:Number = getTimer() - beginParseTime;
			
			textFlow.blockProgression = _blockProgression;
			helper = new AliceScrollHelper(this);
			
			// make a thin single column in the NARROW case
			var testWidth:Number = 500;
			var testHeight:Number = 400;
			if (_dimension == NARROW)
			{
				if (_blockProgression == BlockProgression.TB)
					testWidth = 5;
				else
					testHeight = 5;
			}
			
			helper.beginTest("AliceScroll",textFlow,parseTime,s,testWidth,testHeight,this);
			
			trace("TEXTFLOW COMPOSED", getTimer());
		}
		
		public function toggleBP(e:Event):void
		{
			_blockProgression = _blockProgression == BlockProgression.TB ? BlockProgression.RL : BlockProgression.TB;
			e.target.text = _blockProgression;
		}
		
		public function toggleDimension(e:Event):void
		{
			_dimension = _dimension == NORMAL ? NARROW: NORMAL;
			e.target.text = _dimension;
		}
		
		public function dogc(e:Event):void
		{
			System.gc();
		}
		
		public function reportLPS(lps:Number):void
		{
			// report the LPS
			lpsTextField.text = lps.toString();
		}
		
		public function testComplete():void
		{
			// renenable the start button
			startButton.visible = true;
		}
		
		public function releaseEverything(e:Event):void
		{
			trace("	public function releaseEveryThing():void");
			trace("	{");
			helper.textFlow.flowComposer.getControllerAt(0).clearCompositionResults();
			helper = null;
			recursiveReleaseChildren(this);
			TextLineRecycler.emptyReusableLineCache();
			trace("	}");
		}
		
		static public function recursiveReleaseChildren(obj:DisplayObjectContainer):void
		{
			while (obj.numChildren)
			{
				var child:DisplayObject = obj.getChildAt(0);
				if (child is DisplayObjectContainer)
					recursiveReleaseChildren(child as DisplayObjectContainer);
				if (child is TextLine)
					(child as TextLine).userData = null;
				obj.removeChildAt(0);
			}
		}
		
		public function addButton(text:String,x:Number,y:Number,width:Number,height:Number,handler:Function):TextField
		{
			var f1:TextField = new TextField();
			f1.text = text;
			f1.x = x; f1.y = y; 
			if (height > 0)
				f1.height = height;
			if (width > 0)
				f1.width = width;
			f1.autoSize = TextFieldAutoSize.LEFT;
			addChild(f1);
			if (handler != null)
			{
				f1.border = true;
				f1.borderColor = 0xff;
				f1.addEventListener(MouseEvent.CLICK,handler);
			}
			f1.selectable = false;
			
			return f1;
		}
	}
}

class AliceScrollHelper extends ScrollTestHelper
{
	public var _owner:AliceScroll;
	
	public function AliceScrollHelper(owner:AliceScroll)
	{
		_owner = owner;
	}
	
	public override function noteLPS(lps:Number):void
	{
		_owner.reportLPS(lps);
	}
	
	public override function noteTestComplete():void
	{
		_owner.testComplete();
	}
}