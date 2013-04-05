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
	import flash.events.TimerEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import flashx.textLayout.TextLayoutVersion;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;

	[SWF(width="500", height="500")]
	public class TCMTester extends FlowOpener
	{
		private var _tcm:TextContainerManager;
		private var _precompose:Boolean = false;
		private var _measureW:Boolean = false;
		private var _measureH:Boolean = false;
		private var _delay:Boolean = false;
		private var _timer:Timer;
		
		private var _blockProgression:String = BlockProgression.TB;
		private var _direction:String = Direction.LTR;
		private var _lineBreak:String = LineBreak.TO_FIT;
		
		private var _status:TextField;
		
		public const StatusHeight:Number = 100;
		
		// padding around the Sprite
		public const SpritePadding:Number = 25;

		public function TCMTester()
		{
			this.stage.addEventListener(Event.RESIZE,resizeHandler);
			
			var b:TextField = addButton("Reset",10,10,0,0,resetTCM);
			b = addButton("Load ..",b.x+b.width+10,10,0,0,openDialog);
			//b = addButton("Precompose OFF",b.x+b.width+10,10,0,0,togglePrecompose);
			//b = addButton("Delay OFF",b.x+b.width+10,10,0,0,toggleDelay);
			b = addButton("MeasureW OFF",b.x+b.width+10,10,0,0,toggleMeasureW);
			b = addButton("MeasureH OFF",b.x+b.width+10,10,0,0,toggleMeasureH);
			// b = addButton("IncColumnCount",b.x+b.width+10,10,0,0,increaseColumnCount);
			// b = addButton("DecColumnCount",b.x+b.width+10,10,0,0,decreaseColumnCount);
			b = addButton("BP " + _blockProgression,b.x+b.width+10,10,0,0,toggleBP);
			b = addButton("DIR " + _direction,b.x+b.width+10,10,0,0,toggleDirection);
			b = addButton("LineBreak " + _lineBreak,b.x+b.width+10,10,0,0,toggleLineBreak);

			_status = addButton("",10,40,500-20,StatusHeight,null);
			_status.autoSize = TextFieldAutoSize.NONE;
			_status.background = true;
			_status.backgroundColor = 0x99ffff;
			_status.selectable = true;
			
			var s:Sprite = new Sprite();
			s.x = SpritePadding;
			s.y = _status.y+StatusHeight+SpritePadding;
			addChild(s);
			
			// CONFIG::debug { Debugging.generateDebugTrace = true; }
			
			_tcm = createInputManager(s,500-2*SpritePadding,500-StatusHeight-SpritePadding-_status.y-SpritePadding);
			_tcm.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE,updateComposeInformation);
			_tcm.updateContainer();
			
			appendStatusText("Build: " + TextLayoutVersion.BUILD_NUMBER + Capabilities.version);
		}
		
		public function appendStatusText(str:String):void
		{
			_status.appendText(str);
			_status.appendText("\n");
			_status.scrollV = _status.maxScrollV;
		}
		
		public override function parseDataFromFile(extension:String,fileData:String, config:Configuration = null):TextFlow
		{
			var beginParseTime:Number = getTimer();
			var textFlow:TextFlow = super.parseDataFromFile(extension,fileData,config);
			var parseTime:Number = getTimer()-beginParseTime;
			appendStatusText("ParseTime: " + parseTime);
			
			return textFlow;
		}
		
		public function resizeHandler(e:Event):void
		{
			if (_tcm)
			{
				_tcm.compositionWidth = _measureW ? NaN : Math.max(10,stage.stageWidth-2*SpritePadding);
				_tcm.compositionHeight = _measureH ? NaN : Math.max(10,stage.stageHeight-StatusHeight-SpritePadding-_status.y-SpritePadding);
				_tcm.updateContainer();
				
				_status.width = Math.max(10,stage.stageWidth-20);
			}
		}
		
		public function resetTCM(e:Event):void
		{
			if (_tcm.composeState == TextContainerManager.COMPOSE_COMPOSER)
			{
				var flow:TextFlow = _tcm.getTextFlow();
				flow.interactionManager = null;
				_tcm.setText("");
				_tcm.setTextFlow(flow);
			}
			else
				_tcm.setText("Hello World");
			_tcm.updateContainer();
		}
		
		public function togglePrecompose(e:Event):void
		{
			_precompose = !_precompose;
			TextField(e.target).text = _precompose ? "Precompose ON" : "Precompose OFF";
		}
		
		public function toggleMeasureW(e:Event):void
		{
			_measureW = !_measureW;
			TextField(e.target).text = _measureW ? "MeasureW ON" : "MeasureW OFF";
			resizeHandler(null);
		}
		
		public function toggleMeasureH(e:Event):void
		{
			_measureH = !_measureH;
			TextField(e.target).text = _measureH ? "MeasureH ON" : "MeasureH OFF";
			resizeHandler(null);
		}
		
		public function toggleBP(e:Event):void
		{
			_blockProgression = _blockProgression == BlockProgression.TB ? BlockProgression.RL : BlockProgression.TB;
			TextField(e.target).text = "BP " + _blockProgression;
			
			var hostFormat:TextLayoutFormat = new TextLayoutFormat(_tcm.hostFormat);
			hostFormat.blockProgression = _blockProgression;
			_tcm.hostFormat = hostFormat;
			_tcm.updateContainer();
		}
		
		public function toggleDirection(e:Event):void
		{
			_direction = _direction == Direction.LTR ? Direction.RTL : Direction.LTR;
			TextField(e.target).text = "DIR " + _direction;
			
			var hostFormat:TextLayoutFormat = new TextLayoutFormat(_tcm.hostFormat);
			hostFormat.direction = _direction;
			_tcm.hostFormat = hostFormat;
			_tcm.updateContainer();
		}
		
		public function toggleLineBreak(e:Event):void
		{
			_lineBreak = _lineBreak == LineBreak.EXPLICIT ? LineBreak.TO_FIT : LineBreak.EXPLICIT;
			TextField(e.target).text = "LineBreak " + _lineBreak;
			
			var hostFormat:TextLayoutFormat = new TextLayoutFormat(_tcm.hostFormat);
			hostFormat.lineBreak = _lineBreak;
			_tcm.hostFormat = hostFormat;
			_tcm.updateContainer();
		}
		
		public function toggleDelay(e:Event):void
		{
			_delay = !_delay;
			TextField(e.target).text = _delay ? "Delay ON" : "Delay OFF";
		}
		
		public function get mode():String
		{
			return _tcm.composeState == TextContainerManager.COMPOSE_COMPOSER ? "Standard" :  "Factory";
		}
		
		public function updateComposeInformation(e:Event):void
		{
			appendStatusText(mode + " Bounds: " + _tcm.getContentBounds());
		}
		
		public function displayActualLines(e:Event):void
		{
			// mode changes after getActualNumlines call
			appendStatusText(mode + " ActualNumLines: " + _tcm.getActualNumLines());
		}
		
		public function increaseColumnCount(e:Event):void
		{
			if (_tcm)
			{
				var format:TextLayoutFormat = new TextLayoutFormat(_tcm.hostFormat);
				if (format.columnCount === undefined)
					format.columnCount = 2;
				else
					format.columnCount = Number(format.columnCount) + 1;
				_tcm.hostFormat = format;
				appendStatusText("ColumnCount: " + format.columnCount);
				_tcm.updateContainer();
			}		
		}
		
		public function decreaseColumnCount(e:Event):void
		{
			if (_tcm)
			{
				var format:TextLayoutFormat = new TextLayoutFormat(_tcm.hostFormat);
				if (format.columnCount !== undefined)
				{
					if (format.columnCount == 2)
						format.columnCount = undefined;
					else
						format.columnCount = Number(format.columnCount) - 1;
					_tcm.hostFormat = format;
					appendStatusText("ColumnCount: " + format.columnCount);
					_tcm.updateContainer();
				}
			}		
		}

		override public function useTextFlow():void
		{
			// first compose it so that we can test composing loaded graphics
			if (_precompose)
			{
				var s:Sprite = new Sprite();
				_textFlow.flowComposer.addController(new ContainerController(s,NaN,NaN));
				_textFlow.flowComposer.updateAllControllers();
				
				if (_delay)
				{
					_textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,statusChangeHandler,false,0,true);
					
					if (_timer)
						_timer.stop();
					
					// 15 second delay
					_timer = new Timer(15000, 1);
					_timer.addEventListener("timer", timerHandler);
					_timer.start();
					
					return;
				}
			}
			
			_tcm.setTextFlow(_textFlow);
			_tcm.updateContainer();
		}
				
		private function timerHandler(event:TimerEvent):void
		{
			if (event.target == _timer)
			{
				_timer.removeEventListener("timer", timerHandler);
				_timer = null;
				
				if (_textFlow)
				{
					_textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,statusChangeHandler);
					_tcm.setTextFlow(_textFlow);
					_tcm.updateContainer();					
				}
			}
		}
		
		private function statusChangeHandler(e:StatusChangeEvent):void
		{
			// if the graphic has loaded update the display
			// set the loaded graphic's height to match text height
			if (e.status == InlineGraphicElementStatus.READY || e.status == InlineGraphicElementStatus.SIZE_PENDING)
				_textFlow.flowComposer.updateAllControllers();
		}

		private function createInputManager(s:Sprite,width:Number,height:Number):CustomTextContainerManager
		{
			var tcm:CustomTextContainerManager = new CustomTextContainerManager(s);
			tcm.borderThickness = 3;
			tcm.compositionWidth = width < 50 ? 50 : width;
			tcm.compositionHeight = height < 50 ? 50 : height;
			tcm.setText("Hello World");
			
			var hostFormat:TextLayoutFormat = new TextLayoutFormat();
			hostFormat.fontSize = 12;
			hostFormat.paddingTop = 4;
			hostFormat.paddingLeft = 4;
			hostFormat.direction = _direction;
			hostFormat.blockProgression = _blockProgression;
			hostFormat.lineBreak = _lineBreak;
			tcm.hostFormat = hostFormat;
			
			return tcm;
		}
	}
}

import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.FocusEvent;
import flash.geom.Rectangle;
import flash.ui.ContextMenu;

import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.IConfiguration;
import flashx.textLayout.tlf_internal;
import flashx.undo.IUndoManager;

use namespace tlf_internal;

class CustomTextContainerManager extends TextContainerManager
{
	private var _borderThickness:Number;
	private var hasScrollRect:Boolean;

	public function CustomTextContainerManager(container:Sprite,configuration:Configuration =  null)
	{
		super(container, configuration);
	}

	override public function drawBackgroundAndSetScrollRect(scrollx:Number,scrolly:Number):Boolean
	{
		// return super.drawBackgroundAndSetScrollRect(scrollx,scrolly);
		
		var contentBounds:Rectangle = getContentBounds();
		var width:Number  = isNaN(compositionWidth)  ? contentBounds.x+contentBounds.width-scrollx : compositionWidth;
		var height:Number = isNaN(compositionHeight) ? contentBounds.y+contentBounds.height-scrolly : compositionHeight;

		if (scrollx == 0 && scrolly == 0 && contentBounds.width <= width && contentBounds.height <= height)
		{
			// skip the scrollRect
			if (hasScrollRect)
			{
				container.scrollRect = null;
				hasScrollRect = false;
			}
		}
		else 
		{
			//trace("INPUT",scrollx,scrolly,compositionWidth,compositionHeight);
			// scrollRect = new Rectangle(scrollx-_borderThickness, scrolly-_borderThickness, compositionWidth+2*_borderThickness, compositionHeight+2*_borderThickness);
			container.scrollRect = new Rectangle(scrollx, scrolly, width+_borderThickness, height+_borderThickness);
			hasScrollRect = true;

			// adjust to the values actually in the scrollRect
			scrollx = container.scrollRect.x;
			scrolly = container.scrollRect.y;
			width = container.scrollRect.width-_borderThickness;
			height = container.scrollRect.height-_borderThickness;
			//trace("RESULT",scrollx,scrolly,width,height);
		}

		container.graphics.clear();
		container.graphics.beginFill(0xFFFFF0);
        container.graphics.lineStyle(_borderThickness, composeState == TextContainerManager.COMPOSE_FACTORY ? 0x000000 : 0xff);
        // NOTE: client must draw a background - even it if is 100% transparent
       	container.graphics.drawRect(scrollx,scrolly,width,height);
		container.graphics.endFill();
		
		var r:Rectangle = this.getContentBounds();
		container.graphics.lineStyle(_borderThickness,0xff0000);
		container.graphics.beginFill(0,0);
		container.graphics.drawRect(r.x,r.y,r.width,r.height);
		container.graphics.endFill();

        return hasScrollRect;
	}

	static private var	_focusedSelectionFormat:SelectionFormat    = new SelectionFormat(0xffffff, 1.0, BlendMode.DIFFERENCE);
	static private var	_unfocusedSelectionFormat:SelectionFormat = new SelectionFormat(0xa8c6ee, 1.0, BlendMode.NORMAL, 0xa8c6ee, 1.0, BlendMode.NORMAL, 0);
	static private var	_inactiveSelectionFormat:SelectionFormat  = new SelectionFormat(0xe8e8e8, 1.0, BlendMode.NORMAL, 0xe8e8e8, 1.0, BlendMode.NORMAL, 0);

	override protected function getFocusedSelectionFormat():SelectionFormat
	{ return _focusedSelectionFormat; }
	override protected function getUnfocusedSelectionFormat():SelectionFormat
	{ return _unfocusedSelectionFormat; }
	override protected function getInactiveSelectionFormat():SelectionFormat
	{ return _inactiveSelectionFormat; }

	public function get borderThickness():Number
	{
		return _borderThickness;
	}
	public function set borderThickness(value:Number):void
	{
		_borderThickness = value;
	}

	override public function focusInHandler(event:FocusEvent):void
    {
    	/* trace("focusInHandler");

    	var im:ISelectionManager = beginInteraction();
        im.setSelection(0,0);
        updateContainer()
        endInteraction(); */

        super.focusInHandler(event);
	}
}
