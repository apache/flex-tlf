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
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.engine.FontPosture;
	import flash.utils.getTimer;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	[SWF(width="800", height="500")]
	public class EventMirrorExample extends Sprite
	{
		public const StatusHeight:Number = 100;
		
		// padding around the Sprite
		public const SpritePadding:Number = 25;
		
		public var textFlow:TextFlow;
		public var infoField:TextField;
		
		public function EventMirrorExample()
		{			
			// Display status information here
			infoField = new TextField();
			infoField.x = 10;
			infoField.y = 40;
			infoField.width = 780;
			infoField.autoSize = TextFieldAutoSize.NONE;
			infoField.background = true;
			infoField.backgroundColor = 0x99ffff;
			infoField.selectable = true;
			addChild(infoField);

			var s:Sprite = new Sprite();
			s.x = SpritePadding;
			s.y = infoField.y+StatusHeight+SpritePadding;
			addChild(s);

			textFlow = new TextFlow();
			textFlow.fontSize = 24;
			
			// log hits to infoField on a SubParagraphGroupElement
			var s1:SpanElement = new SpanElement();
			s1.text = "GroupEvent";
			var s2:SpanElement = new SpanElement();
			s2.text = "Listener";
			s2.fontStyle = FontPosture.ITALIC;
			var g:SubParagraphGroupElement =  new SubParagraphGroupElement();
			g.replaceChildren(0,0,s1,s2);
			var p:ParagraphElement = new ParagraphElement();
			p.addChild(g);
			textFlow.addChild(p);
			
			var mirror:IEventDispatcher = g.getEventMirror();
			mirror.addEventListener(FlowElementMouseEvent.MOUSE_DOWN,traceEvent);
			mirror.addEventListener(FlowElementMouseEvent.MOUSE_UP,traceEvent);
			mirror.addEventListener(FlowElementMouseEvent.MOUSE_MOVE,traceEvent);
			mirror.addEventListener(FlowElementMouseEvent.ROLL_OVER,traceEvent);
			mirror.addEventListener(FlowElementMouseEvent.ROLL_OUT,traceEvent);
			mirror.addEventListener(FlowElementMouseEvent.CLICK,traceEvent);
			
			// log hits to infoField on a SpanElement
			s1 = new SpanElement();
			s1.text = "Span w/Listener, ";
			s2 = new SpanElement();
			s2.text ="Span no listener";
			p =  new ParagraphElement();
			p.replaceChildren(0,0,s1,s2);
			textFlow.addChild(p);
			
			mirror = s1.getEventMirror();
			mirror.addEventListener(FlowElementMouseEvent.MOUSE_DOWN,traceEvent);
			mirror.addEventListener(FlowElementMouseEvent.MOUSE_UP,traceEvent);
			mirror.addEventListener(FlowElementMouseEvent.MOUSE_MOVE,traceEvent);
			mirror.addEventListener(FlowElementMouseEvent.ROLL_OVER,traceEvent);
			mirror.addEventListener(FlowElementMouseEvent.ROLL_OUT,traceEvent);
			mirror.addEventListener(FlowElementMouseEvent.CLICK,traceEvent);
			
			// roll over and roll out changes color of a span
			s1 = new SpanElement();
			s1.text = "Roll over and roll out changes color";
			p = new ParagraphElement();
			p.addChild(s1);
			textFlow.addChild(p);
			
			mirror = s1.getEventMirror();
			mirror.addEventListener(FlowElementMouseEvent.ROLL_OVER,toRed);
			mirror.addEventListener(FlowElementMouseEvent.ROLL_OUT,toDefault);

			// click changes the text			
			s1 = new SpanElement();
			s1.text = "Click to Toggle: Hello, World";
			p = new ParagraphElement();
			p.addChild(s1);
			textFlow.addChild(p);			

			s1.getEventMirror().addEventListener(FlowElementMouseEvent.CLICK,toggleText);
			
			// interaction manager isn't needed.  Note: if its an EditManager then the CTRL key must be pressed to get mirrored events
			textFlow.interactionManager = new SelectionManager();
			textFlow.flowComposer.addController(new ContainerController(s,500-2*SpritePadding,500-StatusHeight-SpritePadding-infoField.y-SpritePadding));
			textFlow.flowComposer.updateAllControllers();
		}
		
		public function toggleText(e:FlowElementMouseEvent):void
		{
			traceEvent(e);
			var span:SpanElement = e.flowElement as SpanElement;
			if (span)
			{
				span.text = span.text == "Click to Toggle: Hello, World" ? "Click to Toggle: Goodbye, World" : "Click to Toggle: Hello, World";
				span.getTextFlow().flowComposer.updateAllControllers();
			}
		}
		public function toRed(e:FlowElementMouseEvent):void
		{
			traceEvent(e);
			e.flowElement.color = 0xff0000;
			e.flowElement.getTextFlow().flowComposer.updateAllControllers();
		}
		public function toDefault(e:FlowElementMouseEvent):void
		{
			traceEvent(e);
			e.flowElement.color = undefined;
			e.flowElement.getTextFlow().flowComposer.updateAllControllers();
		}
		
		public function traceEvent(event:FlowElementMouseEvent):void
		{ appendStatusText(event.flowElement.defaultTypeName+ " " + getTimer() + " " + event.toString() + event.originalEvent.toString()); }
		
		public function appendStatusText(str:String):void
		{
			infoField.appendText(str+"\n");
			infoField.scrollV = infoField.maxScrollV;
		}
	}
}
