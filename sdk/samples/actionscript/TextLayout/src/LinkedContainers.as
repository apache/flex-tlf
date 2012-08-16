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
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextLayoutFormat;

	/** TextLayout markup example with two linked containers. */
	public class LinkedContainers extends Sprite
	{
		private const markup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008' fontSize='14' textIndent='15' paragraphSpaceAfter='15' paddingTop='4' paddingLeft='4'>" + 
				"<TextLayoutFormat color='#ff0000' id='hoverOverBrand'/>" + 
				"<TextLayoutFormat color='#00ff00' textDecoration='underline' id='mouseDownOverBrand'/>" + 
				"<TextLayoutFormat color='#0000ff' id='defaultLinkBrand'/>" + 
				"<TextLayoutFormat color='#0000ff' id='hoverOverEmail'/>" + 
				"<TextLayoutFormat color='#0000ff' lineThrough='true' id='mouseDownOverEmail'/>" + 
				"<p fontSize='48'>Ethan Brand</p>" + 
				"<p>The following excerpt is from <a href='http://www.4literature.net/Nathaniel_Hawthorne/Ethan_Brand/' target='_self' linkCharacterFormat='{defaultLinkBrand}' hoverCharacterFormat='{hoverOverBrand}' activeCharacterFormat='{mouseDownOverBrand}'><span>Ethan Brand</span></a> by <a href='mailto:nathaniel_hawthorne@famousauthors.com' target='_self' hoverCharacterFormat='{hoverOverBrand}' activeCharacterFormat='{mouseDownOverEmail}'><span>Nathaniel Hawthorne</span></a>.</p>" + 
				"<p><span>There are many </span><span fontStyle='italic'>such</span><span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.</span></p><p><span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Within the furnace were seen the curling and riotous flames, and the burning marble, almost molten with the intensity of heat; while without, the reflection of the fire quivered on the dark intricacy of the surrounding forest, and showed in the foreground a bright and ruddy little picture of the hut, the spring beside its door, the athletic and coal-begrimed figure of the lime-burner, and the half-frightened child, shrinking into the protection of his father's shadow. And when again the iron door was closed, then reappeared the tender light of the half-full moon, which vainly strove to trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, though thus far down into the valley the sunshine had vanished long and long ago.</span></p></TextFlow>";

		public function LinkedContainers()
		{
			// Makes a single, editable text flow that flows through two containers.
			if (stage)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}

			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer = new StandardFlowComposer();

			// The first container is small, and in the top left. It has an inset, because we're going to stroke it.
			var firstContainer:Sprite = new Sprite();
			firstContainer.x = 10;
			firstContainer.y = 10;
			var firstController:ContainerController = new ContainerController(firstContainer);
			firstController.verticalScrollPolicy = ScrollPolicy.OFF;
			var firstControllerFormat:TextLayoutFormat = new TextLayoutFormat();
			firstControllerFormat.paddingTop = 4;
			firstControllerFormat.paddingRight = 4;
			firstControllerFormat.paddingBottom = 4;
			firstControllerFormat.paddingLeft = 4;
			firstController.format = firstControllerFormat;
			textFlow.flowComposer.addController(firstController);
			firstController.setCompositionSize(500, 60);
			addChild(firstContainer);

			// The second container is below, and has two columns
			var secondContainer:Sprite = new Sprite();
			secondContainer.x = 10;
			secondContainer.y = 100;
			var secondController:ContainerController = new ContainerController(secondContainer);
			var secondControllerFormat:TextLayoutFormat = new TextLayoutFormat();
			secondControllerFormat.columnCount = 2;
			secondControllerFormat.columnGap = 30;
			secondController.format = secondControllerFormat;
			textFlow.flowComposer.addController(secondController);
			secondController.setCompositionSize(500, 450);
			addChild(secondContainer);

			//  Draw the text, and make it editable
			textFlow.flowComposer.updateAllControllers();			
			textFlow.interactionManager = new EditManager();
			
			// Draw a stroke around the first container
			var bounds:Rectangle = new Rectangle(0, 0, firstContainer.width - 1, firstContainer.height - 1);
			firstContainer.graphics.lineStyle(1);
			firstContainer.graphics.moveTo(bounds.left,bounds.top);
			firstContainer.graphics.lineTo(bounds.right,bounds.top);
			firstContainer.graphics.lineTo(bounds.right,bounds.bottom);
			firstContainer.graphics.lineTo(bounds.left,bounds.bottom);
			firstContainer.graphics.lineTo(bounds.left,bounds.top);
		}
	}
}
