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
package perfAppTests
{
	import flash.display.Sprite;
	import flash.ui.ContextMenu;

	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.TextFlow;
	import flashx.undo.IUndoManager;
	import flashx.undo.UndoManager;

	public class InputTestTextContainerManager extends TextContainerManager
	{
		public function InputTestTextContainerManager(container:Sprite, configuration:IConfiguration= null)
		{
			super(container, configuration);
		}

        override public function drawBackgroundAndSetScrollRect(scrollx:Number,scrolly:Number):Boolean
		{
			var bg:Sprite = container as Sprite;

			bg.graphics.clear();
            bg.graphics.beginFill(0xFFFFFF);
            bg.graphics.lineStyle(1, 0x000000);

            // client must draw a background - even it if is 100% transparent
            bg.graphics.drawRect(scrollx,scrolly,compositionWidth,compositionHeight);
            bg.graphics.endFill();

            return false;	// TODO
		}

	}
}
