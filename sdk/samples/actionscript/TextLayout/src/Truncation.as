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
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import flashx.textLayout.factory.TruncationOptions;
	
	[SWF(width="500", height="500")]
	public class Truncation extends Sprite
	{
		
		public function Truncation()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// sample of truncation with the StringFactory
			var stringFactory:StringTextLineFactory = new StringTextLineFactory();
			var stringSprite:Sprite = new Sprite();
			stringSprite.x = 25; stringSprite.y = 25; addChild(stringSprite);
			// this bounds has no maximum height
			stringFactory.compositionBounds = new Rectangle(0,0,200,NaN);
			stringFactory.text = "This is an extremely long and overly verbose string of text that I would like to see trunctated.";
			// truncate after two lines
			stringFactory.truncationOptions = new TruncationOptions(TruncationOptions.HORIZONTAL_ELLIPSIS,2);
			stringFactory.createTextLines(function (obj:DisplayObject):void { stringSprite.addChild(obj); });
			
			// sample of truncation with the TextFlowTextLineFactory
			var flowFactory:TextFlowTextLineFactory = new TextFlowTextLineFactory();
			var flowSprite:Sprite = new Sprite();
			flowSprite.x = 25; flowSprite.y = 75; addChild(flowSprite);
			// this bounds has no maximum height
			flowFactory.compositionBounds = new Rectangle(0,0,200,NaN);
			// truncate after three lines with a big red ellipsis
			flowFactory.truncationOptions = new TruncationOptions(TruncationOptions.HORIZONTAL_ELLIPSIS,3,TextLayoutFormat.createTextLayoutFormat({ fontSize:24, lineHeight:0, color:0xff0000 }));
			flowFactory.createTextLines(function (obj:DisplayObject):void { flowSprite.addChild(obj); },TextConverter.importToFlow(Data.markup, TextConverter.TEXT_LAYOUT_FORMAT));
		}
	}
}
class Data
{
	public static const markup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008' fontSize='10' textIndent='15' paragraphSpaceAfter='15' paddingTop='4' paddingLeft='4'>" + 
		"<p>The following excerpt is from Ethan Brand by Nathaniel Hawthorne.</p>" + 
		"<p><span>There are many </span><span fontStyle='italic'>such</span><span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes" +
		" a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky," +
		" and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come." +
		" Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment " +
		"of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case " +
		"of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.</span></p><p><span>The man who now watched the fire was of a " +
		"different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, " +
		"and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Within the furnace were seen the curling and riotous flames, " +
		"and the burning marble, almost molten with the intensity of heat; while without, the reflection of the fire quivered on the dark intricacy of the surrounding forest, and showed in the " +
		"foreground a bright and ruddy little picture of the hut, the spring beside its door, the athletic and coal-begrimed figure of the lime-burner, and the half-frightened child, shrinking " +
		"into the protection of his father's shadow. And when again the iron door was closed, then reappeared the tender light of the half-full moon, which vainly strove to trace out the " +
		"indistinct shapes of the neighboring mountains; and, in the upper sky, there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, though thus far down " +
		"into the valley the sunshine had vanished long and long ago.</span></p></TextFlow>";
}
