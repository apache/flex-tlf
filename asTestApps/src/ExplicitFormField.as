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
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextLayoutFormat;


	[SWF(width="200", height="150")] 

	/** Simple example of two form fields with editable text.  The text only breaks lines on paragraph ends or hard line breaks.  */
	public class ExplicitFormField extends Sprite
	{
		private var msgFlow:TextFlow;
		
		public function ExplicitFormField()
		{
			super();

			msgFlow = addTextSprite(10, 100, 200, 19, "");
			addTextSprite(10, 10, 200, 19, "12:11");
		}

		private function addTextSprite(x:Number, y:Number, width:Number, height:Number, text:String = ""):TextFlow
		{
			var sprite:Sprite = new Sprite();
			var g:Graphics = sprite.graphics;
			g.beginFill(0xEEEEEE);
			g.drawRect(0, 0, width, height);
			g.endFill();
			sprite.x = x;
			sprite.y = y;
			addChild(sprite);

			sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;
			addChild(sprite);


			var textFlow:TextFlow = TextConverter.importToFlow(text, TextConverter.PLAIN_TEXT_FORMAT);

			/*
			textFlow.fontFamily = "Arial";
			textFlow.fontSize = 12;
			textFlow.lineBreak = "explicit";
			textFlow.paddingLeft = 3;
			textFlow.paddingRight = 3;
			textFlow.paddingTop = 5;
			textFlow.paddingBottom = 3;
			*/

			textFlow.hostFormat = TextLayoutFormat.createTextLayoutFormat({fontFamily:"Arial",fontSize:12,lineBreak:LineBreak.EXPLICIT,paddingLeft:3,paddingRight:3,paddingTop:5,paddingBottom:3});
			//textFlow.lineBreak = "explicit";

		//	if (msgFlow)
		//		textFlow.flowComposer.addController(new TestContainerController(sprite, width, height, msgFlow));
		//	else
				textFlow.flowComposer.addController(new ContainerController(sprite, width, height)); 
			textFlow.interactionManager = new EditManager();
			
			textFlow.flowComposer.updateAllControllers();
			return textFlow;
		}
	}
	
}

import flash.display.Sprite;
import flash.events.Event;

import flashx.textLayout.container.ContainerController;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.tlf_internal;

use namespace tlf_internal;

class TestContainerController extends ContainerController
{
	private var msgFlow:TextFlow;
	
	public function TestContainerController(container:Sprite,compositionWidth:Number,compositionHeight:Number, msgFlowValue:TextFlow)
	{
		msgFlow = msgFlowValue;
		super(container, compositionWidth, compositionHeight);
	}
	
	override tlf_internal	function interactionManagerChanged(newInteractionManager:ISelectionManager):void
	{
		var msg:String;
		super.interactionManagerChanged(newInteractionManager);
		if (container["needsSoftKeyboard"])
			msg = "true";
		else
			msg = "false";
		
		var span:SpanElement = msgFlow.getFirstLeaf() as SpanElement;
		span.text = msg;
		msgFlow.flowComposer.updateAllControllers();
	}
	
	override public function softKeyboardActivatingHandler(event:Event):void
	{
		var span:SpanElement = msgFlow.getFirstLeaf() as SpanElement;
		span.text = "softKeyboardActivatingHandler";
		msgFlow.flowComposer.updateAllControllers();
		super.softKeyboardActivatingHandler(event);
	}
}

