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
	import __AS3__.vec.Vector;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontPosture;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
		
	/** Display a paragraph of text with attribute changes in the window.  Rebreak the lines on window resize. */
	public class FTEParagraph extends Sprite
	{
		static private const fontSize:Number = 24;
		
		static private const s1:String = "There are many "
		static private const s2:String = "such"
		static private const s3:String = " lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning."; 

		private var _textBlock:TextBlock;
		private var _sprite:Sprite;
		private var _composeWidth:Number = 0;
		
		public function FTEParagraph()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var content:Vector.<ContentElement> = new Vector.<ContentElement>();
			
			var elementFormat:ElementFormat = new ElementFormat();
			elementFormat.fontSize = fontSize;
			content.push(new TextElement(s1, elementFormat));
			
			elementFormat = new ElementFormat();
			elementFormat.fontSize = fontSize;
			var fontDescription:FontDescription = new FontDescription();
			fontDescription.fontPosture = FontPosture.ITALIC;
			elementFormat.fontDescription = fontDescription;
			content.push(new TextElement(s2, elementFormat));
			
			elementFormat = new ElementFormat();
			elementFormat.fontSize = fontSize;
			content.push(new TextElement(s3, elementFormat));
			
			_textBlock = new TextBlock(new GroupElement(content));
			
			_sprite = new Sprite();
			addChild(_sprite);
			
			_composeWidth = stage.stageWidth;
			displayTextBlock(_textBlock,_sprite,_composeWidth);

			// update the display on resize
			stage.addEventListener(Event.RESIZE, resizeHandler);
		}
		
		private function resizeHandler(e:Event):void
		{
			if (stage.stageWidth != _composeWidth)
			{
				_composeWidth = stage.stageWidth;
				displayTextBlock(_textBlock,_sprite,_composeWidth);
			}
		}
		
		static private function displayTextBlock(textBlock:TextBlock,container:Sprite,width:Number):void
		{
			// clear the old lines if any
			while (container.numChildren)
				container.removeChildAt(0);
			
			var textLine:TextLine;
			var prevLine:TextLine;
			for (;;)
			{
				textLine = textBlock.createTextLine(prevLine,width);
				if (!textLine)
					break;
				textLine.y = prevLine ? prevLine.y + textLine.height : textLine.ascent;
				container.addChild(textLine);
				prevLine = textLine;
			}
		}
	}
}