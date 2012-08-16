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
	import flash.geom.Rectangle;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.TextFlow;

	/** Same as the "Hello, World" text example except that text is read in dynamically based on markup string.  */
	[SWF(width="1000", height="1000")]
	public class ScrollAndVerticalAlign extends Sprite
	{ 
		private var _textFlow:TextFlow;
		
		public function ScrollAndVerticalAlign()
		{
			var markupTest:String = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ScrollON</span></p><p><span>B</span></p><p><span>C</span></p></TextFlow>';
			addChild(createSprite(50, 50, 300, 20, markupTest, true));

			var markupTestBottom:String = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008" verticalAlign="bottom"><p><span>ScrollON</span></p><p><span>B</span></p><p><span>C</span></p></TextFlow>';
		//	addChild(createSprite(450, 50, 300, 20, markupTestBottom, true));

			var markupTestShort:String = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ScrollON</span></p></TextFlow>';
		//	addChild(createSprite(50, 200, 300, 20, markupTestShort, true));

			var markupTestBottomShort:String = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008" verticalAlign="bottom"><p><span>ScrollON</span></p></TextFlow>';
		//	addChild(createSprite(450, 200, 300, 20, markupTestBottomShort, true));

			// Scroll off
	//		addChild(createSprite(50, 350, 300, 20, markupTest, false));

		//	addChild(createSprite(450, 350, 300, 20, markupTestBottom, false));

		//	addChild(createSprite(50, 500, 300, 20, markupTestShort, false));

		//	addChild(createSprite(450, 500, 300, 20, markupTestBottomShort, false));
			
			_textFlow.interactionManager.setFocus();
		}

		private function createSprite(x:Number, y:Number, w:Number, h:Number, markup:String, scrollOn:Boolean):Sprite
		{
			var sprite:Sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;
			createController(markup, sprite, w, h, scrollOn);
			return sprite;
		}

		private function createController(markup:String, sprite:Sprite, w:Number, h:Number, scrollOn:Boolean):ContainerController
		{
			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			if (!_textFlow)
				_textFlow = textFlow;
			textFlow.interactionManager = new EditManager();
			textFlow.interactionManager.selectRange(0, 0);
			var controller:ContainerController = new ContainerController(sprite, w, h);
		//	if (!scrollOn)
		//		controller.verticalScrollPolicy = controller.horizontalScrollPolicy = ScrollPolicy.OFF;
			textFlow.flowComposer.addController(controller);
			textFlow.flowComposer.updateAllControllers();
		/*	var bounds:Rectangle = controller.getContentBounds();
			var g:Graphics = sprite.graphics;
			g.clear();
			g.lineStyle(1, 0xFF0000);
			g.moveTo(bounds.x, bounds.y);
			g.lineTo(bounds.x + bounds.width, bounds.y);
			g.lineTo(bounds.x + bounds.width, bounds.y + bounds.height);
			g.lineTo(bounds.x, bounds.y + bounds.height);
			g.lineTo(bounds.x, bounds.y);
			trace("contentBounds", bounds.toString());

			// draw the composition bounds in black
			g.lineStyle(1, 0x0);
			g.moveTo(0, 0);
			g.lineTo(controller.compositionWidth, 0);
			g.lineTo(controller.compositionWidth, controller.compositionHeight);
			g.lineTo(0, controller.compositionHeight);
			g.lineTo(0, 0);
			trace("compositionWidth and height", controller.compositionWidth, controller.compositionHeight);
*/
			return controller;
		}
	}

}
