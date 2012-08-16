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


	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.system.*;
	import flash.text.engine.TextLine;

	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import flashx.textLayout.formats.TextLayoutFormat;


	public class InputTest extends Sprite
	{

		private var bounds:Rectangle;
		private var sFactBounds:Rectangle;
		private var fFactBounds:Rectangle;
		private var tFlowBounds:Rectangle;

		private var notReadyGraphicsCount:int;

		private var scrollPolicy:String = ScrollPolicy.ON;

		private var stringFactory:StringTextLineFactory = new StringTextLineFactory();
		private var textFlowFactory:TextFlowTextLineFactory = new TextFlowTextLineFactory();
		private static var labelFactory:StringTextLineFactory = null;
		private var sprite:Sprite;
		private var text:String = "To keep up with diverse consumer needs and each product’s short lifecycle.";

		//private var testCanvas:Canvas;
		private var textFlow:TextFlow = TextConverter.importToFlow(text, TextConverter.PLAIN_TEXT_FORMAT);


		public function InputTest()
		{
			super();
       		addTextFactoryFromStringSprite(10, 10, 300, 19, text);
			addTextFactoryFromFlowSprite(10, 40, 300, 19, textFlow);
			addTextFlowSprite(10, 80, 300, 19, textFlow);
			trace("Can't get the same content bounds : ", sFactBounds.height == fFactBounds.height && fFactBounds.height == tFlowBounds.height &&
			 													sFactBounds.right == fFactBounds.right && fFactBounds.right == tFlowBounds.right);

		}

		private function createDefaultTextLayoutFormat():TextLayoutFormat
		{
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.fontFamily = "Arial";
			format.fontSize = 20;

			return format;
		}


		private function addTextFactoryFromStringSprite(x:Number, y:Number, width:Number, height:Number, text:String = ""):void
		{

			sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;

			var scratchFormat:TextLayoutFormat = new TextLayoutFormat(createDefaultTextLayoutFormat());
			scratchFormat.textAlign = "left";
			scratchFormat.verticalAlign = "top";
			scratchFormat.lineBreak = "explicit";
			stringFactory.compositionBounds = new Rectangle(0,0,width?width:NaN,height?height:NaN);
			stringFactory.text = text;
			stringFactory.textFlowFormat = scratchFormat;
			stringFactory.createTextLines(callback);



			function callback(tl:TextLine):void
			{
				sprite.addChild(tl);
			}

			addChild(sprite);
			sFactBounds = stringFactory.getContentBounds();



		}

		private function addTextFactoryFromFlowSprite(x:Number, y:Number, width:Number, height:Number, textFlow:TextFlow):void
		{

			sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;

			addChild(sprite);

			textFlowFactory.compositionBounds = new Rectangle(0,0,width?width:NaN,height?height:NaN);


			textFlow.format = createDefaultTextLayoutFormat();
			textFlow.textAlign = "left";
			textFlow.verticalAlign = "top";
			textFlow.lineBreak = "explicit";



			textFlowFactory.createTextLines(callback,textFlow);
			addChild(sprite);

			function callback(tl:TextLine):void
			{
				sprite.addChild(tl);
			}

			fFactBounds = textFlowFactory.getContentBounds();

		}

		private function addTextFlowSprite(x:Number, y:Number, width:Number, height:Number, textFlow:TextFlow):void
		{
			var textFlow:TextFlow = TextConverter.importToFlow(text, TextConverter.PLAIN_TEXT_FORMAT);
			sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;

			textFlow.interactionManager = new EditManager();


			textFlow.format = createDefaultTextLayoutFormat();
			textFlow.textAlign = "left";
			textFlow.verticalAlign = "top";
			textFlow.lineBreak = "explicit";


			var controller:ContainerController = new ContainerController(sprite,width,height);
			controller.verticalScrollPolicy = scrollPolicy;
			controller.horizontalScrollPolicy = scrollPolicy;


			textFlow.flowComposer.addController(controller);
			textFlow.flowComposer.updateAllControllers();
			addChild(sprite);
			tFlowBounds = controller.getContentBounds();

			trace("addTextFlowSprite is running");
		}


	}
}

