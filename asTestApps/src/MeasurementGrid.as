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
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;

	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;

	/** Simple example of two form fields with editable text.  The text only breaks lines on paragraph ends or hard line breaks.  */
	[SWF(width="900", height="1000")]
	public class MeasurementGrid extends Sprite
	{
		private const USE_FLOW:int = 0;
		private const USE_FACTORY_STRING:int = 1;
		private const USE_FACTORY_FLOW:int = 2;

		private static var stringFactory:StringTextLineFactory = new StringTextLineFactory();
		private static var textFlowFactory:TextFlowTextLineFactory = new TextFlowTextLineFactory();

		private var creationTypes:Array = [USE_FLOW, USE_FACTORY_STRING, USE_FACTORY_FLOW ];
		private var textAlignArray:Array = ["left", "center", "right", "start", "end" ];
		private var verticalAlignArray:Array = ["top", "middle", "bottom"];
		private var lineBreakArray:Array = ["toFit", "explicit" ];
		private const horizontalGap:Number = 30;
		private const verticalGap:Number = 10;
		private var w:Number = 210;
		private var h:Number = 40;

		private var labelWidth:Number = 210;
		private var labelHeight:Number = 50;

		private var scrollPolicy:String = ScrollPolicy.ON;

		private var format:TextLayoutFormat;

		private var sampleText:String;

		public function MeasurementGrid()
		{
			super();
			this.mouseEnabled = true;

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.focus = this;

			queueTests(BlockProgression.TB, Direction.LTR);
			queueTests(BlockProgression.TB, Direction.RTL);
			queueTests(BlockProgression.RL, Direction.LTR);
			queueTests(BlockProgression.RL, Direction.RTL);

			testCases.reverse();

			addEventListener(flash.events.KeyboardEvent.KEY_DOWN, doNext);
		}

		private var testCases:Array = [];

		private function doNext(event:KeyboardEvent):void
		{
			// Clear what's currently visible
			while (numChildren > 0)
				removeChildAt(0);

			if (testCases.length == 0)
				removeEventListener(flash.events.KeyboardEvent.KEY_DOWN, doNext);
			else
				runNextTest();
		}

		private function queueTestSet(width:Number, height:Number, sampleText:String, format:TextLayoutFormat, description:String):void
		{
			var o:Object;

			for each (var creationType:int in creationTypes)
			{
				o = new Object();
				o.width = width;
				o.height = height;
				o.sampleText = sampleText;
				o.format = format;
				o.useFactory = creationType;
				o.description = description;
				testCases.push(o);
			}
		}

		private function runNextTest():void
		{
			var o:Object = testCases.pop();

			var xOrigin:Number = 10;
			var yOrigin:Number = 10;

			if (o.width)
				w = o.width;
			if (o.height)
				h = o.height;

			// Test against specified width and height
			trace(o.description);
			addTestSet(xOrigin, yOrigin, o.width, o.height, o.sampleText, o.format, o.useFactory);
			if (width > height)
				yOrigin += (h + verticalGap) * 12;
			else
				xOrigin += (w + horizontalGap) * 5;
			// Try it with measurement - compute both width and height
			addTestSet(xOrigin, yOrigin, NaN, NaN, o.sampleText, o.format, o.useFactory);
		}

		private function queueTests(blockProgression:String, direction:String):void
		{
			const logicalWidth:Number = 200;
			const logicalHeight:Number = 40;

			var width:Number;
			var height:Number;
			if (blockProgression == BlockProgression.TB)
			{
				width = logicalWidth;
				height = logicalHeight;
			}
			else
			{
				width = logicalHeight;
				height = logicalWidth;
			}

			format = new TextLayoutFormat();
			format.fontFamily = "Arial";
			format.fontSize = 20;
			format.direction = direction;
			format.blockProgression = blockProgression;

		//	sampleText = "Hello again\nAnother longer line to test";
			sampleText = "ZZZZZ XXXXX YYY Hello again";

			queueTestSet(width, height, sampleText, format, "simple short phrase");

			// Multiple Lines
			sampleText = "Hello again\nAnother longer line to test";
			queueTestSet(width, height, sampleText, format, "two unmatched lines");

			// Trailing spaces
			sampleText = "Hello again  ";
			queueTestSet(width, height, sampleText, format, "trailing spaces");

			// Height but no width
			sampleText = "Hello again";
			queueTestSet(NaN, height, sampleText, format, "height but no width");

			// Width but no height
			queueTestSet(width, NaN, sampleText, format, "width but no height");

			// Empty text
			sampleText = "";
			queueTestSet(width, height, sampleText, format, "empty text");

			// Padding on left and top
			sampleText = "Hello again";
			format = new TextLayoutFormat();
			format.blockProgression = blockProgression;
			format.direction = direction;
			format.fontFamily = "Arial";
			format.fontSize = 20;
			format.paddingLeft = 20;
			format.paddingTop = 10;
			queueTestSet(width, height, sampleText, format, "padding top and left");

			// Padding on right and bottom
			format = new TextLayoutFormat();
			format.blockProgression = blockProgression;
			format.direction = direction;
			format.fontFamily = "Arial";
			format.fontSize = 20;
			format.paddingRight = 20;
			format.paddingBottom = 10;
			queueTestSet(width, height, sampleText, format, "padding right and bottom");

			// Multiple Columns
			format = new TextLayoutFormat();
			format.blockProgression = blockProgression;
			format.direction = direction;
			format.fontFamily = "Arial";
			format.fontSize = 20;
			format.columnGap = 10;
			format.columnCount = 2;
			queueTestSet(width, height, sampleText, format, "multiple columns");

			// Ideographic baseline examples needed


		//	addTextSprite(xOrigin, yOrigin, width, height, "left", "middle", "toFit", sampleText);
		}

		private function addTestSet(xOrigin:Number, yOrigin:Number, compositionWidth:Number, compositionHeight:Number,
			sampleText:String, format:TextLayoutFormat, useFactory:int):void
		{
			var x:Number;
			var y:Number;
			var lineBreak:String;
			var verticalAlign:String;
			var textAlign:String;

			// Labels for columns
			x = xOrigin;
			for each (verticalAlign in verticalAlignArray)
			{
				y = yOrigin;
				addLabel(x, yOrigin, labelWidth, labelHeight, verticalAlign);	//label
				x += w + horizontalGap;
			}
			yOrigin += 30;

			// Test against specified width and height
			for each (lineBreak in lineBreakArray)
			{
				x = xOrigin;
				for each (verticalAlign in verticalAlignArray)
				{
					y = yOrigin;
					for each (textAlign in textAlignArray)
					{
						addTextSprite(x, y, compositionWidth, compositionHeight, textAlign, verticalAlign, lineBreak, sampleText, format, useFactory);
						y += h + verticalGap;
					}
					x += w + horizontalGap;
				}
				addLabel(x, yOrigin - 30, labelWidth, labelHeight, lineBreak);	//label
				y = yOrigin;
				for each (textAlign in textAlignArray)
				{
					addLabel(x, y, labelWidth, labelHeight, textAlign);
					y += h + verticalGap;
				}
				yOrigin += (h + verticalGap) * textAlignArray.length + 40;
			}
		}

		static private function makeFormatString(format:ITextLayoutFormat):String
		{
			var rslt:String =  "";
			for each (var prop:Property in TextLayoutFormat.tlf_internal::description)
			{
				var name:String = prop.name;
				var val:* = format[name];
				if (val != undefined)
				{
					if (rslt != "")
						rslt += " "
					rslt += name + '=' + prop.toXMLString(val);
				}
			}
			return rslt;
		}
		private function addTextSprite(x:Number, y:Number, width:Number, height:Number, textAlign:String, verticalAlign:String, lineBreak:String, text:String,
			format:ITextLayoutFormat, useFactory:int):void
		{
			trace(useFactory,x,y,width,height,'"'+text+'"',"textAlign="+textAlign,"verticalAlign="+verticalAlign,"lineBreak="+lineBreak,makeFormatString(format));
			switch (useFactory)
			{
				case USE_FLOW:
					addTextFlowSprite(x, y, width, height, textAlign, verticalAlign, lineBreak, text, format);
					break;
				case USE_FACTORY_STRING:
					addTextFactoryFromStringSprite(x, y, width, height, textAlign, verticalAlign, lineBreak, text, format);
					break;
				case USE_FACTORY_FLOW:
					addTextFactoryFromFlowSprite(x, y, width, height, textAlign, verticalAlign, lineBreak, text, format);
					break;
			}
		}

		private function addTextFactoryFromStringSprite(x:Number, y:Number, width:Number, height:Number, textAlign:String, verticalAlign:String, lineBreak:String, text:String,
			format:ITextLayoutFormat):void
		{
			var sprite:Sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;

			var scratchFormat:TextLayoutFormat = new TextLayoutFormat(format);
			scratchFormat.textAlign = textAlign;
			scratchFormat.verticalAlign = verticalAlign;
			scratchFormat.lineBreak = lineBreak;

			stringFactory.compositionBounds = new Rectangle(0,0,width?width:NaN,height?height:NaN);
			stringFactory.text = text;
			stringFactory.textFlowFormat = scratchFormat;
			stringFactory.createTextLines(callback);
			var bounds:Rectangle = stringFactory.getContentBounds();

			addChild(sprite);

			function callback(tl:TextLine):void
			{
				sprite.addChild(tl);
			}

			addChild(sprite);
			var xoff:Number = sprite.scrollRect ? -sprite.scrollRect.x : 0;
			var yoff:Number = sprite.scrollRect ? -sprite.scrollRect.y : 0;
			// composition bounds in black
			// contentBounds in red
			var topSprite:Sprite = new Sprite();
			topSprite.x = sprite.x;
			topSprite.y = sprite.y;
			var g:Graphics = topSprite.graphics;
			drawCircle(g, 0xff00, 0, 0, 3);
			strokeRect(g, 1, 0x0, 0, 0, width, height);
			strokeRect(g, 1, 0xFF0000, bounds.left+xoff, bounds.top+yoff, bounds.width, bounds.height);
			trace("bounds", bounds.toString());
			addChild(topSprite);
		}

		private function addTextFactoryFromFlowSprite(x:Number, y:Number, width:Number, height:Number, textAlign:String, verticalAlign:String, lineBreak:String, text:String,
			format:ITextLayoutFormat):void
		{
			var sprite:Sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;


			// For factory using TextFlow use this...
			var textFlow:TextFlow = TextConverter.importToFlow(text, TextConverter.PLAIN_TEXT_FORMAT);
			textFlow.format = format;
			textFlow.textAlign = textAlign;
			textFlow.verticalAlign = verticalAlign;
			textFlow.lineBreak = lineBreak;
			textFlowFactory.compositionBounds = new Rectangle(0,0,width?width:NaN,height?height:NaN);
			textFlowFactory.createTextLines(callback,textFlow);
			var bounds:Rectangle = textFlowFactory.getContentBounds();

			addChild(sprite);

			function callback(tl:TextLine):void
			{
				sprite.addChild(tl);
			}

			addChild(sprite);
			var xoff:Number = sprite.scrollRect ? -sprite.scrollRect.x : 0;
			var yoff:Number = sprite.scrollRect ? -sprite.scrollRect.y : 0;
			// composition bounds in black
			// contentBounds in red
			var topSprite:Sprite = new Sprite();
			topSprite.x = sprite.x;
			topSprite.y = sprite.y;
			var g:Graphics = topSprite.graphics;
			drawCircle(g, 0xff00, 0, 0, 3);
			strokeRect(g, 1, 0x0, 0, 0, width, height);
			strokeRect(g, 1, 0xFF0000, bounds.left+xoff, bounds.top+yoff, bounds.width, bounds.height);
			addChild(topSprite);
		}

		private function addTextFlowSprite(x:Number, y:Number, width:Number, height:Number, textAlign:String, verticalAlign:String, lineBreak:String, text:String,
			format:ITextLayoutFormat):void
		{
			var sprite:Sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;

			var textFlow:TextFlow = TextConverter.importToFlow(text, TextConverter.PLAIN_TEXT_FORMAT);
			textFlow.interactionManager = new EditManager();


			textFlow.format = format;
			textFlow.textAlign = textAlign;
			textFlow.verticalAlign = verticalAlign;
			textFlow.lineBreak = lineBreak;

			var controller:ContainerController = new ContainerController(sprite,width,height);
			controller.verticalScrollPolicy = scrollPolicy;
			controller.horizontalScrollPolicy = scrollPolicy;
		//	controller.format = format;  Test adding padding directly to the container

			textFlow.flowComposer.addController(controller);
			textFlow.flowComposer.updateAllControllers();
			addChild(sprite);
			var xoff:Number = sprite.scrollRect ? -sprite.scrollRect.x : 0;
			var yoff:Number = sprite.scrollRect ? -sprite.scrollRect.y : 0;
			// composition bounds in black
			var topSprite:Sprite = new Sprite();
			topSprite.x = sprite.x;
			topSprite.y = sprite.y;
			var g:Graphics = topSprite.graphics;
			drawCircle(g, 0xff00, 0, 0, 3);
			strokeRect(g, 1, 0x0, 0, 0, width, height);
			// contentBounds in red
			var contentBounds:Rectangle = controller.getContentBounds();
			strokeRect(g, 1, 0xFF0000, contentBounds.x + xoff, contentBounds.y + yoff, contentBounds.width, contentBounds.height);
			// trace(contentBounds);
			addChild(topSprite);
		}

		private function addLabel(x:Number, y:Number, width:Number, height:Number, text:String = ""):void
		{
			var sprite:Sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;
			stringFactory.compositionBounds = new Rectangle(0,0,width,height);
			stringFactory.text = text;
			stringFactory.createTextLines(callback);
			addChild(sprite);

			function callback(tl:TextLine):void
			{
				sprite.addChild(tl);
			}
		}

		private function strokeRect(g:Graphics, stroke:Number, color:int, x:Number, y:Number, width:Number, height:Number):void
		{
			if (width <= 0 || height <= 0)
				return;
			if (isNaN(width) || isNaN(height))
				return;
			g.lineStyle(stroke, color);
			g.moveTo(x, y);
			g.lineTo(x + width, y);
			g.lineTo(x + width, y + height);
			g.lineTo(x, y + height);
			g.lineTo(x, y);
		}
		private function drawCircle(g:Graphics, color:uint, x:Number, y:Number, radius:Number):void
		{
			g.beginFill(color);
			g.drawCircle(x,y,radius);
			g.endFill();
		}
	}
}
