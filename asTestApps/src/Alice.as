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
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.undo.IUndoManager;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.elements.TextFlow;
	
	public class Alice extends Sprite 
	{
	    // embed alice - this simplifies things - don't need to trust the swf and pass the xml around with it
	    [Embed(source="../../test/testFiles/markup/tlf/alice.xml",mimeType="application/octet-stream")]
	    private var AliceClass : Class;

		public function Alice()
		{
			if (stage)
			{
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.NO_SCALE;
			}

			var s:Sprite = new Sprite();
			s.x = 100;
			s.y = 100;
			addChild(s);

			var alice:ByteArray = new AliceClass();
			var aliceData:String = alice.readMultiByte(alice.length,"utf-8");
			//var textFlow:TextFlow = TextConverter.importToFlow(aliceData, TextConverter.TEXT_LAYOUT_FORMAT);

			// Version using the inputManager
			/*var inputManager:AliceTextContainerManager = new AliceTextContainerManager(s);
			inputManager.compositionWidth = 500;
			inputManager.compositionHeight = 400;
			inputManager.setTextFlow(textFlow);
			inputManager.updateContainer();*/

			// version doing a direct flowComopser
			var textFlow:TextFlow = TextConverter.importToFlow(aliceData, TextConverter.TEXT_LAYOUT_FORMAT);

			// Version using the inputManager
			/*var inputManager:AliceTextContainerManager = new AliceTextContainerManager(s);
			inputManager.compositionWidth = 500;
			inputManager.compositionHeight = 400;
			inputManager.setTextFlow(textFlow);
			inputManager.updateContainer();*/

			// version doing a direct flowComopser
			var inputManager:AliceTextContainerManager = new AliceTextContainerManager(s);
			inputManager.compositionWidth = 500;
			inputManager.compositionHeight = 400;
			inputManager.setTextFlow(textFlow);
			inputManager.updateContainer();
		}

	}
}

import flash.display.Sprite;
import flash.geom.Rectangle;
import flashx.undo.IUndoManager;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.elements.IConfiguration;
import flashx.textLayout.edit.SelectionFormat;

class AliceTextContainerManager extends TextContainerManager
{
		private var _hasScrollRect:Boolean = false;

	public function AliceTextContainerManager(container:Sprite,configuration:IConfiguration =  null)
	{
		super(container, configuration);
	}
		override protected function getFocusedSelectionFormat():SelectionFormat
		{
			return null;
		}

		override protected function getInactiveSelectionFormat():SelectionFormat
		{
			return null;
		}

		override protected function getUnfocusedSelectionFormat():SelectionFormat
		{
			return null;
		}

		override protected function getUndoManager():IUndoManager
		{
			return null;
		}


}
