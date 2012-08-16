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
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;

	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;

	/** Simple example of two form fields with editable text.  The text only breaks lines on paragraph ends or hard line breaks.  */
	public class ShowAtomBounds extends Sprite
	{
		public function ShowAtomBounds()
		{
			super();
			var textSprite:Sprite = buildFTEExample("I﻿J");
			addChild(textSprite);
		}

		/** build FTE data each time */
		public function buildFTEExample(sampleText:String):Sprite
		{
			var r:Rectangle;
			var elementFormat:ElementFormat = new ElementFormat();
			elementFormat.fontDescription = new FontDescription("Arial");
		//	elementFormat.fontDescription = new FontDescription("Arial Black");
			elementFormat.fontSize = 48;
			var textElement:TextElement = new TextElement(sampleText, elementFormat)
			var textBlock:TextBlock = new TextBlock(textElement);
			var textLine:TextLine = textBlock.createTextLine();
			var sprite:Sprite = new Sprite();
			sprite.addChild(textLine);
			sprite.x = 100;
			sprite.y = 100;
			sprite.graphics.lineStyle(1, 0xFF0000);
			trace("line contains", textLine.atomCount, "atoms");
			for (var i:int = 0; i < textLine.atomCount; i++)
			{
				r = textLine.getAtomBounds(i);
				sprite.graphics.moveTo(r.left, r.top);
				sprite.graphics.lineTo(r.right, r.top);
				sprite.graphics.lineTo(r.right, r.bottom);
				sprite.graphics.lineTo(r.left, r.bottom);
				sprite.graphics.lineTo(r.left, r.top);
				trace("\t atom", i, "bounds is", r.toString());
			}
			return sprite;
		}

	}
}
