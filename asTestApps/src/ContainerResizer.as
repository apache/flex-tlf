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
	//import flash.events.UncaughtErrorEvent;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.undo.IUndoManager;
	import flash.text.TextField;
	
	[SWF(width="1000", height="500")]
	public class ContainerResizer extends FlowOpener
	{
		private var _cc1:ContainerController;
		private var _cc2:ContainerController;
		private var _logField:TextField;
		private var _swfHeight:int = 500;
		private var _swfWidth:int = 1000;
		
		public function ContainerResizer()
		{
			super();
			this.stage.addEventListener(Event.RESIZE,resizeHandler);
			//addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			
			var s:Sprite = new Sprite();
			s.x = 10;
			s.y = 100;
			addChild(s);
			var sprite1:Sprite = new Sprite();
			_cc1 = new ContainerController(sprite1,(_swfWidth/2) - 20, (_swfHeight) - 110);
			var sprite2:Sprite = new Sprite();
			_cc2 = new ContainerController(sprite2,(_swfWidth/2) - 20, (_swfHeight) - 110);
			sprite2.x = (_swfWidth/2);
			s.addChild(sprite1);7
			s.addChild(sprite2);			
			
			addButton("Load ..",10,10,0,0,openDialog);
			addButton("Randomly Resize",60,10,0,0,startResizing);
			addButton("Stop",60,40,0,0,stopResizing);
			
			addLogField(160,10,_swfWidth-160-10, 80);
		}
		
		public function resizeHandler(e:Event):void
		{
		}
		
		override public function useTextFlow():void
		{
			_textFlow.flowComposer.addController(_cc1);
			_textFlow.flowComposer.addController(_cc2);
			_textFlow.flowComposer.updateAllControllers();			
		}
		
		public function startResizing(e:Event):void
		{
			this.stage.addEventListener (Event.ENTER_FRAME, resizeControllers);
		}
		
		public function stopResizing(e:Event):void
		{
			this.stage.removeEventListener (Event.ENTER_FRAME, resizeControllers);
			_logField.setSelection(_logField.text.length, _logField.text.length);
		}
		
		public function resizeControllers(e:Event):void
		{
			var pad:int = 75;	// workaround for a bug that happens if the first container is too small to compose one line
			var newWidth:Number = (Math.random() * (_swfWidth-pad)) + pad;
			var newHeight:Number = (Math.random() * (_swfHeight-100-pad)) + pad;
			_logField.appendText("width = " + newWidth + " height = " + newHeight + "\n");
			try
			{
				_cc1.setCompositionSize (newWidth, newHeight);
				_textFlow.flowComposer.updateAllControllers();
			}
			catch (e:Error)
			{
				_logField.appendText(e.message);
				stopResizing(new Event("found a problem"));
			}
			CONFIG::debug
			{
				var check:int = _textFlow.debugCheckTextFlow(true)
				if (check > 0)
				{
					_logField.appendText ("Failed debugCheckTextFlow: " + check)
					stopResizing(new Event("found a problem"));
				}
			}
		}
		
		private function addLogField(x:Number,y:Number,width:Number,height:Number):void
		{
			_logField = new TextField();
			_logField.x = x; _logField.y = y; _logField.height = height; _logField.width = width;
			_logField.border = true;
			_logField.borderColor = 0xff;
			addChild(_logField);
			_logField.selectable = true;
		}
		/*private function onUncaughtError(e:UncaughtErrorEvent):void
		{
		if (e.error is Error)
		{
		var error:Error = e.error as Error;
		trace(error.errorID, error.name, error.message);
		}
		else
		{
		var errorEvent:ErrorEvent = e.error as ErrorEvent;
		trace(errorEvent.errorID);
		}			
		}*/
	}
}