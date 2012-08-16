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
	
	import flashx.textLayout.container.*;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.events.StatusChangeEvent;

	/** Hell world text example with an inline graphic */
	public class InlineGraphic extends Sprite
	{
		private var _textFlow:TextFlow;
		
		public function InlineGraphic()
		{
			_textFlow = new TextFlow();
			_textFlow.fontSize = 48;
			var p:ParagraphElement = new ParagraphElement();
			_textFlow.addChild(p);
			
			var span:SpanElement = new SpanElement();
			span.text = "Hello ";
			p.addChild(span);
			
			// InlineGraphicElement has "auto" width/height so the size can't be calculated till the graphic is loaded
			var inlineGraphic:InlineGraphicElement = new InlineGraphicElement();
			inlineGraphic.source = "http://www.adobe.com/shockwave/download/images/flashplayer_100x100.jpg";
			p.addChild(inlineGraphic);
			
			var span2:SpanElement = new SpanElement();
			span2.text = " World";
			p.addChild(span2);
			
			// event sent when graphic is done loading
			_textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,graphicStatusChangeEvent);

			_textFlow.flowComposer.addController(new ContainerController(this,400,200));
			
			// this call compose but the graphic hasn't been loaded from the source URL yet.
			// The actualWidth and actualHeight are zero.  
			_textFlow.flowComposer.updateAllControllers();
		}	
		

		private function graphicStatusChangeEvent(e:StatusChangeEvent):void
		{
			// if the graphic has loaded update the display
			// actualWidth and actualHeight are computed from the graphic's height
			if (e.status == InlineGraphicElementStatus.READY || e.status == InlineGraphicElementStatus.SIZE_PENDING)
			{
				_textFlow.flowComposer.updateAllControllers();
			}
		}
	}
}
