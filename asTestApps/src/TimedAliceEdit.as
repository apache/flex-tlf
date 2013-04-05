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
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.ui.ContextMenu;
	import flash.utils.ByteArray;
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	
	public class TimedAliceEdit extends Sprite 
	{
		// embed alice - this simplifies things - don't need to trust the swf and pass the xml around with it
		[Embed(source="../../test/testFiles/markup/tlf/alice.xml",mimeType="application/octet-stream")]
		private var AliceClass : Class;
		
		[Embed(source="../../test/testFiles/markup/tlf/simple.xml",mimeType="application/octet-stream")]
		private var SimpleClass : Class;

		private var textFlow:TextFlow;
		
		public function TimedAliceEdit()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var s:Sprite = new Sprite();
			s.x = 100;
			s.y = 100;
			addChild(s);
			
			var alice:ByteArray = new AliceClass();
		//	var alice:ByteArray = new SimpleClass();
			var aliceData:String = alice.readMultiByte(alice.length,"utf-8");
			textFlow = TextConverter.importToFlow(aliceData, TextConverter.TEXT_LAYOUT_FORMAT);
			
			
			// version doing a direct flowComopser
			var controller:ContainerController = new ContainerController(s,500,400);
			textFlow.flowComposer.addController(controller);
			textFlow.flowComposer.updateAllControllers();
			controller.verticalScrollPosition = int.MAX_VALUE;
			textFlow.flowComposer.updateAllControllers();
			
			var timedFunction:TimedExecution = new TimedExecution(this, 20, this["changeLastParagraph"], "AliceEditLastParagraph");
		//	changeLastParagraph();
		}
		
		private function changeLastParagraph():void
		{
			var paragraph:ParagraphElement = textFlow.getLastLeaf().getParagraph();
			var tf:TextLayoutFormat = new TextLayoutFormat(paragraph.format);
			tf.fontSize = 18;
			tf.fontWeight = FontWeight.BOLD;
			paragraph.format = tf;
			textFlow.flowComposer.updateAllControllers();
		}
		
	}
}

