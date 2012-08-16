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
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	
	[SWF(width="500", height="500")]
	public class LinkEventExample extends Sprite
	{
		public const markup:String = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008" fontSize="24"><p>Text that includes a link to ' +
			'<a href="event:changeTextFlowColor">custom event code</a>. ' +
			'Clicking the link changes the default color of the TextFlow.</p></TextFlow>';
		
		public function LinkEventExample()
		{
			var textFlow:TextFlow = TextConverter.importToFlow(markup,TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.addEventListener("changeTextFlowColor",changeTextFlowColor)
         
            textFlow.flowComposer.addController(new ContainerController(this,stage ? stage.stageWidth : 500, stage ? stage.stageHeight : 500));
            textFlow.flowComposer.updateAllControllers();
		}

		private function changeTextFlowColor(e:FlowElementMouseEvent):void
		{
			var textFlow:TextFlow = e.flowElement.getTextFlow();
			textFlow.color = textFlow.color == 0x00ff00 ? 0 : 0x00ff00;
			textFlow.flowComposer.updateAllControllers();
		}
	}
}

