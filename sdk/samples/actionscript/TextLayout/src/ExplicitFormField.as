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
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.TextFlow;

	/** Simple example of two form fields with editable text.  The text only breaks lines on paragraph ends or hard line breaks.  */
	public class ExplicitFormField extends Sprite
	{
		public function ExplicitFormField()
		{
			super();
			
			addTextSprite(10, 10, 300, 50, "Hello");
			addTextSprite(10, 100, 300, 50, "");
		}
		
		private function addTextSprite(x:Number, y:Number, width:Number, height:Number, text:String = ""):void
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
			textFlow.interactionManager = new EditManager();
					
			textFlow.fontFamily = "Arial";
			textFlow.fontSize = 20;
			textFlow.lineBreak = "explicit";
			
			textFlow.flowComposer.addController(new ContainerController(sprite,width,height));
			textFlow.flowComposer.updateAllControllers();
		}
	}
}
