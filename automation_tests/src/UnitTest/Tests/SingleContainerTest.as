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
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.VerticalAlign;
	import flashx.textLayout.tlf_internal;
	import flashx.undo.UndoManager;
	
	use namespace tlf_internal;
	
	[SWF (width="500", height="700", backgroundColor="#FFFFFF")]
	
	public class SingleContainerTest extends Sprite
	{
		
		protected var tf:TextFlow;
		protected var em:EditManager;
		protected var um:flashx.undo.UndoManager
		protected var _bg:Sprite;
		protected var _spr:Sprite;
		protected var _cc:ContainerController
		protected var _init_fmt:TextLayoutFormat;
		protected var _btn:Sprite;
		protected var _playing:Boolean = false;
		protected var _count:int = 0;
		
		protected var _graph:Sprite;
		protected var _print_out:TextField;
		protected var _last_time:Date = new Date();
		protected var _last_five:Array = [];
		
		public function SingleContainerTest()
		{
			
//			stage.scaleMode = StageScaleMode.NO_SCALE;
//			stage.align = StageAlign.TOP_LEFT;
			
			var cw:Number = 200; // the container width
			var ch:Number = 600;  // the container height
			
			_bg = new Sprite();
			_bg.graphics.lineStyle(.25, 0);
			_bg.graphics.drawRect(0,0,cw,ch);
			addChild(_bg);
			
			_spr = new Sprite();
			addChild(_spr);
			
			_graph = new Sprite();
			_graph.x = cw + 10;
			_graph.y = 250;
			addChild(_graph);
			
			_print_out = new TextField();
			var fmt:TextFormat = _print_out.defaultTextFormat;
			fmt.font = "_sans";
			_print_out.wordWrap = true;
			_print_out.multiline = true;
//			_print_out.width = stage.stageWidth - (10 + _graph.x);
			_print_out.x = _graph.x;
			_print_out.y = _graph.y + 10;
			addChild(_print_out);
			
			//define TextFlow and manager objects
			tf = new TextFlow();
			um = new UndoManager();
			em = new EditManager(um);
			tf.interactionManager = em;  
			
			//compose TextFlow to display
			_cc = new ContainerController(_spr,cw,ch);
			//_cc.verticalAlign = VerticalAlign.BOTTOM;
			//_cc.verticalScrollPolicy = ScrollPolicy.ON;
			tf.flowComposer.addController(_cc);
			tf.flowComposer.updateAllControllers();
			
			//make a button to add Inline Graphic elements
			_btn = new Sprite();
			_btn.graphics.beginFill(0xFF0000,1);
			_btn.graphics.drawRect(0,0,120,30);
			addChild(_btn);
			_btn.addEventListener(MouseEvent.CLICK, btnClicked);
			_btn.y = 600;
			
			addMessage("1");
			addMessage("2");
			addMessage("3", true);
			
		}
		
		public function addMessage(msg:String, add_image:Boolean = false):void {
			//define elements to contain text
			var d:DivElement = new DivElement();
			var p:ParagraphElement = new ParagraphElement();
			var s:SpanElement = new SpanElement();
			s.text = msg;
			//add these elements to the TextFlow
			p.addChild(s);
			d.addChild(p);
			if(add_image){
				var sp:Sprite = new Sprite();
				sp.graphics.beginFill(0xFFCC00);
				sp.graphics.drawRect(0,0,100,20);
				var i:InlineGraphicElement = new InlineGraphicElement();
				i.source = sp;
				i.width = 100;
				i.height = 20;
				p.addChild(i);
			}
			tf.addChild(d);
			tf.flowComposer.updateAllControllers();
			_cc.verticalScrollPosition = _cc.getContentBounds().height;
			tf.flowComposer.updateAllControllers();
		}
		
		protected function btnClicked(e:MouseEvent):void {
			_playing = !_playing;
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if(_playing){
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		protected function onEnterFrame(e:Event):void {
			_count++;
			
			if(_count > 100){
				tf.removeChildAt(0);
			}
			
			addMessage("Message Number: " + _count + " " + randomString());
			printOut()
		}
		
		protected function printOut():void {
			var now:Date = new Date();
			var tm:Number = (now.getTime() - _last_time.getTime());
			_last_five.push(tm);
			if(_last_five.length > 10) _last_five.shift();
			var avg_tm:Number = 0;
			for(var i:int = 0; i < _last_five.length; i++) avg_tm += _last_five[i];
			avg_tm = Math.round(avg_tm/_last_five.length);
			var elapsed_str:String = "message: \t\t\t"+_count
				+ "\ntime: \t\t\t\t" + tm + "ms"
				+ "\navg of last 10:\t\t" + avg_tm +"ms";
			//trace(elapsed_str );
			_print_out.text = elapsed_str;
			_last_time = now;
			drawGraph(tm);
		}
		
		protected function drawGraph(tm:Number):void {
			if(_count % 5 == 0){
				_graph.graphics.beginFill(0x0);
				_graph.graphics.drawRect(_count/10,-Math.round(tm/10),1,1);
				_graph.graphics.beginFill(0xFF0000);
				_graph.graphics.drawRect(_count/10,-Math.round(System.totalMemory/1000000),1,1);
			}
		}
		
		protected function randomString():String {
			var chars:String = "abcdefghijklmnopqrstuvwzyz                    ";
			var chars_len:Number = chars.length;
			var random_str:String = "";
			var num_chars:Number = Math.round(Math.random() * 100);
			for (var i:int =0; i < num_chars; i++){
				random_str = random_str + chars.charAt(Math.round(Math.random() * chars_len));
			}
			return random_str;
		}
	}
}