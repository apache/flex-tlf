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
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextLayoutFormat;

	/** TextLayout markup example with two linked containers. */
	public class MultipleContainerColumns extends Sprite
	{
		private const markup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' fontSize='14' textIndent='15' paragraphSpaceAfter='15' paddingTop='4' paddingLeft='4'>" + 
				"<p>The following excerpt is from <flow:a href='http://www.4literature.net/Nathaniel_Hawthorne/Ethan_Brand/' target='_self' ><flow:span>Ethan Brand</flow:span></flow:a> by <flow:a href='mailto:nathaniel_hawthorne@famousauthors.com' target='_self' ><flow:span>Nathaniel Hawthorne</flow:span></flow:a>.</p>" + 
				"<flow:p><flow:span>There are many </flow:span><flow:span fontStyle='italic'>such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.</flow:span></flow:p><flow:p><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Within the furnace were seen the curling and riotous flames, and the burning marble, almost molten with the intensity of heat; while without, the reflection of the fire quivered on the dark intricacy of the surrounding forest, and showed in the foreground a bright and ruddy little picture of the hut, the spring beside its door, the athletic and coal-begrimed figure of the lime-burner, and the half-frightened child, shrinking into the protection of his father's shadow. And when again the iron door was closed, then reappeared the tender light of the half-full moon, which vainly strove to trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, though thus far down into the valley the sunshine had vanished long and long ago.</flow:span></flow:p></flow:TextFlow>";

		private var firstController:ContainerController;
		private var secondController:ContainerController;
		private var textFlow:TextFlow;
		
		public function MultipleContainerColumns()
		{
			// Makes a single, editable text flow that flows through two containers.
			if (stage)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}

			textFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer = new StandardFlowComposer();

			// The first container is small, and in the top left. It has an inset, because we're going to stroke it.
			var firstContainer:Sprite = new Sprite();
			firstController = new ContainerController(firstContainer);
			firstController.verticalScrollPolicy = ScrollPolicy.OFF;
			var containerFormat:TextLayoutFormat = new TextLayoutFormat();
			containerFormat.paddingTop = 4;
			containerFormat.paddingRight = 4;
			containerFormat.paddingBottom = 4;
			containerFormat.paddingLeft = 4;
		//	containerFormat.columnCount = 3;
			containerFormat.columnWidth = 200;
			containerFormat.columnGap = 30;
			firstController.format = containerFormat;
			textFlow.flowComposer.addController(firstController);
			addChild(firstContainer);
			if (stage)
				stage.addEventListener(flash.events.Event.RESIZE, resizeHandler);

			// The second container is below, and has two columns
			var secondContainer:Sprite = new Sprite();
			secondController = new ContainerController(secondContainer);
			var secondContainerFormat:TextLayoutFormat = new TextLayoutFormat();
			secondContainerFormat.columnCount = 2;
			secondContainerFormat.columnGap = 30;
			secondController.format = secondContainerFormat;
			textFlow.flowComposer.addController(secondController);
			addChild(secondContainer);
			
			resizeHandler(null);
		}
		
		private function resizeHandler(event:Event):void
		{
			const verticalGap:Number = 50;
			const stagePadding:Number = 16;
			var stageWidth:Number = (stage ? stage.stageWidth-this.x : 500) - stagePadding;
			var stageHeight:Number = (stage ? stage.stageHeight-this.y : 500) - stagePadding;
			
			var firstContainerHeight:Number = (stageHeight - verticalGap)/2;
			var secondContainerHeight:Number = (stageHeight - verticalGap)/2;
			firstController.setCompositionSize(stageWidth, firstContainerHeight );
			firstController.container.x = stagePadding / 2;
			firstController.container.y = stagePadding / 2;

			secondController.setCompositionSize((stageWidth*2)/3, secondContainerHeight );
			secondController.container.x = (stagePadding/2) + (stageWidth/6);
			secondController.container.y = (stagePadding/2) + firstContainerHeight + verticalGap;

			textFlow.flowComposer.updateAllControllers();			

			drawBorder(firstController);
			drawBorder(secondController);
		}
		
		private function drawBorder(controller:ContainerController):void
		{
			//  Draw a border around the container
			var bounds:Rectangle = new Rectangle(0, 0, controller.compositionWidth, controller.compositionHeight);
			var container:Sprite = controller.container as Sprite;
			container.graphics.clear();
			container.graphics.lineStyle(1);
			container.graphics.moveTo(bounds.left,bounds.top);
			container.graphics.lineTo(bounds.right,bounds.top);
			container.graphics.lineTo(bounds.right,bounds.bottom);
			container.graphics.lineTo(bounds.left,bounds.bottom);
			container.graphics.lineTo(bounds.left,bounds.top);
			container.graphics.beginFill(0xFFFFFF);
			container.graphics.drawRect(bounds.left, bounds.top, bounds.width - 1, bounds.height - 1);
			container.graphics.endFill();

		}
	}
}
