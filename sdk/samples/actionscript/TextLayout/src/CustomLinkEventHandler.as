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
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.DamageEvent;
	import flashx.textLayout.events.FlowElementMouseEvent;

	/** This example demonstrates custom event handling on a LinkElement.  In one case a click handler is added to a LinkElement.  In the other class the click handler is a event:EventName string.  */
	public class CustomLinkEventHandler extends Sprite
	{
		private var textFlow:TextFlow;
		private var pCustomClick:ParagraphElement;
		private var pNamedEvent:ParagraphElement;
		
		private function customClickHandler(e:FlowElementMouseEvent):void
		{
			// change the color of the first span of pCustomClick
			textFlow.addEventListener(DamageEvent.DAMAGE,damageHandler);
			var s:FlowLeafElement = pCustomClick.getFirstLeaf();
			s.color = s.computedFormat.color == 0 ? 0xff0000 : 0;
		}
		public var doCompose:Boolean = false;
		
		private function damageHandler(e:DamageEvent):void
		{
			textFlow.removeEventListener(DamageEvent.DAMAGE,damageHandler);
			doCompose = true;
		}
		
		public function enterFrameHandler(e:Event):void
		{
			if (doCompose)
			{
				textFlow.flowComposer.updateAllControllers();
				doCompose = false;
			}
		}
		
		public function CustomLinkEventHandler()
		{
			if (stage)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			
			textFlow = new TextFlow();
			textFlow.fontSize = 18;
			textFlow.paragraphSpaceBefore = 12;
			var p:ParagraphElement = new ParagraphElement();
			var s:SpanElement = new SpanElement();
			textFlow.addChild(p);
			p.addChild(s);
			s.text = "Demonstrate custom event handlers on LinkElement. \nThe first LinkElement has a custom click handler.";
			
			pCustomClick = new ParagraphElement();
			pCustomClick.fontSize = 24;
			textFlow.addChild(pCustomClick);
			s = new SpanElement();
			s.text = "Custom Click: ";
			pCustomClick.addChild(s);
			var link:LinkElement = new LinkElement();
			link.addEventListener(MouseEvent.CLICK,customClickHandler);
			pCustomClick.addChild(link);
			s = new SpanElement();
			link.addChild(s);
			s.text ="click me for a custom click event.";

			textFlow.flowComposer.addController(new ContainerController(this, stage ? stage.stageWidth : 500, stage ? stage.stageHeight : 500));
			textFlow.flowComposer.updateAllControllers();
			
			textFlow.interactionManager = new SelectionManager();
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
	}
}
