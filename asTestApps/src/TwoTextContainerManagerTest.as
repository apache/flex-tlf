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
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.ui.ContextMenu;

	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.undo.IUndoManager;
	import flashx.textLayout.debug.assert;

	public class TwoTextContainerManagerTest extends Sprite
	{
		private var hostFormat:TextLayoutFormat;

		public function TwoTextContainerManagerTest()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			hostFormat = new TextLayoutFormat();
		    hostFormat.fontFamily = "Verdana";
		    hostFormat.fontSize = 12;
		    hostFormat.paddingTop = 4;
		    hostFormat.paddingLeft = 4;

			var s:Sprite = createInputManager(hostFormat);
			s.x = 100;
			s.y = 100;
			addChild(s);

			s = createInputManager(new TextLayoutFormat(hostFormat));
			s.x = 100+250+50;
			s.y = 100;
			addChild(s);
		}

		static private function createInputManager(hostFormat:ITextLayoutFormat):Sprite
		{
			var s:Sprite = new Sprite();

			var tcm:CustomTextContainerManager = new CustomTextContainerManager(s);
			tcm.borderThickness = 3;
			tcm.compositionWidth = 250;
			tcm.compositionHeight = 100;
			tcm.setText("Hello World");
			tcm.hostFormat = hostFormat;
			tcm.updateContainer();

			return s;
		}

	}
}

import flash.display.BlendMode;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.events.FocusEvent;

import flashx.undo.IUndoManager;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.elements.IConfiguration;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.edit.SelectionFormat;

import flashx.textLayout.tlf_internal;
import flash.ui.ContextMenu;
use namespace tlf_internal;

class CustomTextContainerManager extends TextContainerManager
{
	private var _borderThickness:Number;
	private var hasScrollRect:Boolean;

	public function CustomTextContainerManager(container:Sprite,configuration:IConfiguration =  null)
	{
		super(container, configuration);
	}

	override public function drawBackgroundAndSetScrollRect(scrollx:Number,scrolly:Number):Boolean
	{
		var contentBounds:Rectangle = getContentBounds();
		var width:Number  = isNaN(compositionWidth)  ? contentBounds.x+contentBounds.width : compositionWidth;
		var height:Number = isNaN(compositionHeight) ? contentBounds.y+contentBounds.height : compositionHeight;

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

	/* override protected function createContextMenu():ContextMenu
	{ return null; } */
}
