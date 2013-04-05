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
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	[SWF(width="500", height="300")]
	public class KeyLogger extends Sprite
	{
		public function KeyLogger()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			textField = new TextField();
			addChild(textField);
			textField.width = 500;
			textField.height = 300;
			textField.selectable = true;
			textField.type = TextFieldType.DYNAMIC;

			sprite = new Sprite();
			sprite.graphics.beginFill(0xff,0);
			sprite.graphics.drawRect(0,0,500,300);
			sprite.graphics.endFill();
			addChild(sprite);
			sprite.focusRect = false;
			stage.focus = sprite;

			sprite.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			sprite.addEventListener(KeyboardEvent.KEY_UP,   keyHandler);
			sprite.addEventListener(TextEvent.TEXT_INPUT,	inputHandler);
			sprite.addEventListener(Event.COPY, miscEventHandler);
			sprite.addEventListener(Event.SELECT_ALL, miscEventHandler);
			sprite.addEventListener(Event.CUT, miscEventHandler);
			sprite.addEventListener(Event.PASTE, miscEventHandler);
			sprite.addEventListener(Event.CLEAR, miscEventHandler);
			sprite.mouseEnabled = false;

			sprite.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,focusChange);
			sprite.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,focusChange);
			stage.addEventListener(Event.ENTER_FRAME,repairFocus);

			reportString(Capabilities.version + " " + Capabilities.os);
		}

		private function focusChange(e:FocusEvent):void
		{
			// if (stage.focus != sprite)
			// stage.focus = sprite;
			repairFocusFlag = true;
			trace("Hey don't click");
		}
		private var repairFocusFlag:Boolean = false;
		private function repairFocus(e:Event):void
		{
			if (stage.focus != sprite)
				stage.focus = sprite;
		}

		private var textField:TextField;
		private var sprite:Sprite;
		private var totalText:String;

		private function reportString(str:String):void
		{
			trace(str);
			if (totalText)
				totalText += "\n" + str;
			else
				totalText = str;
			textField.text =  totalText;
			textField.scrollV = textField.maxScrollV;
			stage.focus = sprite;
		}

		private function keyHandler(e:KeyboardEvent):void
		{
			var charCodeString:String = e.charCode != 0 ? String.fromCharCode(e.charCode) : null;
			var str:String = "KeyboardEvent:" + e.type+" "+"keyCode:"+" "+e.keyCode+" "+"charCode:"+" "+e.charCode+" "+ (charCodeString ? (charCodeString+" ") : "") +"ctrlKey?"+" "+e.ctrlKey+" "+"altKey?"+" "+e.altKey;
			reportString(str);

		}
		private function inputHandler(e:TextEvent):void
		{
			var textString:String = e.text ? e.text : "";
			var str:String = "TextEvent:" + e.type+" "+"text:"+" "+textString;
			reportString(str);
		}

		private function miscEventHandler(e:Event):void
		{
			var str:String = "Event:"+e.type;
			reportString(str);
		}
	}
}
