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
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.engine.TextLine;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import flashx.textLayout.compose.TextLineRecycler;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	public class AliceScroll extends Sprite
	{
	    // embed alice - this simplifies things - don't need to trust the swf and pass the xml around with it
		// [Embed(source="../../test/testFiles/markup/tlf/AliceID.xml",mimeType="application/octet-stream")]
		[Embed(source="../../test/testFiles/markup/tlf/alice.xml",mimeType="application/octet-stream")]
		private var AliceClass : Class;
		
		private var helper:ScrollTestHelper;
		
		public function AliceScroll()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 1000;
			
			// TextLineRecycler.textLineRecyclerEnabled = false;
			// Debugging.generateDebugTrace = true;
			
			var b:TextField = addButton("GC",10,10,0,0,dogc);
			addButton("Release",b.x+b.width+10,10,0,0,releaseEverything);

			var s:Sprite = new Sprite();
			s.x = 100;
			s.y = 100;
			addChild(s);

			var alice:ByteArray = new AliceClass();
			var aliceData:String = alice.readMultiByte(alice.length,"utf-8");

			var beginParseTime:Number = getTimer();
			var textFlow:TextFlow = TextConverter.importToFlow(aliceData, TextConverter.TEXT_LAYOUT_FORMAT);
			var parseTime:Number = getTimer() - beginParseTime;
			
			helper = new ScrollTestHelper();
			helper.beginTest("AliceScroll",textFlow,parseTime,s,500,400,this);
		}
		
		public function dogc(e:Event):void
		{
			System.gc();
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

