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
package UnitTest.Validation
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditingMode;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

	import flexunit.framework.TestCase;

	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.skins.Border;
	import mx.utils.LoaderUtil;

	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.factory.TextFlowTextLineFactory;

	public class TCMComposition
	{
		private var ItemsToRemove:Array;
		private var testCanvas:Canvas = null;
		private var fileForFactory:String;
		private var textFlow:TextFlow;
		private var curSnapshot:Bitmap = null;
		private var beforeSnapshot:Bitmap = null;
		private var afterSnapshot:Bitmap = null;
		private var errorString:String = "";
		private var containerWidth:Number = 0;
		private var containerHeight:Number = 0;
		private var snapshotWidth:Number = 0;
		private var snapshotHeight:Number = 0;

		private var line:Number = 0;

		public function get ErrorString():String
		{
			return errorString;
		}

		public function set Width(width:Number):void
		{
			snapshotWidth = width;
		}

		public function set Height(height:Number):void
		{
			snapshotHeight = height;
		}

		public function TCMComposition(TestCanvas:Canvas, aFlow:TextFlow)
		{
			testCanvas = TestCanvas;
			textFlow = aFlow;
			if(aFlow.flowComposer)
			{
				var container:DisplayObjectContainer = DisplayObjectContainer(aFlow.flowComposer.getControllerAt(0).container);
				containerWidth = container.width;
				containerHeight = container.height;
			}

		}

		public function compare ():Boolean
		{
			var Result:Boolean = true;

			//1.clear the canvas
			cleanUp();

			//2.Make a new container using TextContainerManager
			var _Sprite:Sprite = new Sprite();
			_Sprite.x = 0;
			_Sprite.y = 0;
			var testTCM:TextContainerManager = new TextContainerManager(_Sprite, null);
			testCanvas.rawChildren.addChild(_Sprite);
			var container:DisplayObjectContainer = testTCM.container;

			//3.Import the markup into a read-only container (composing using the text line factory)
			testTCM.compositionWidth = containerWidth;
			testTCM.compositionHeight =  containerHeight;
			testTCM.editingMode = EditingMode.READ_ONLY;
			textFlow.interactionManager = null;  // To compose using the text line factory
			testTCM.setTextFlow(textFlow);
			testTCM.updateContainer();

			var composeState:Number = testTCM.composeState;
			if(composeState!=0)
			{
				errorString += " not a text_line_factory composer, ";
				Result = false;
				//return false;
			}

			//4.Take a "before" bitmap snapshot
			var bits:BitmapData = new BitmapData(snapshotWidth, snapshotHeight);
			bits.draw(container);
			var factoryData:Bitmap  = new Bitmap(bits);

			// 5.Change the container to be read-write (composing using text flow)
			testTCM.setTextFlow(textFlow);
			testTCM.beginInteraction();
			testTCM.endInteraction();
			testTCM.updateContainer();
			composeState = testTCM.composeState;
			if(composeState!=1)
			{
				errorString += " not a text_flow composer, ";
				Result = false;
				//return false;
			}

			// 6.Take an "after" bitmap snapshot
			bits = new BitmapData(snapshotWidth,snapshotHeight);
			bits.draw(container);
			var composerData:Bitmap = new Bitmap(bits);


			// 7.compare the bitmaps
			if((factoryData)&&(composerData))
			{
				var bounds:Rectangle = new Rectangle(0, 0, snapshotWidth, snapshotHeight);
				var composerPixels:ByteArray = composerData.bitmapData.getPixels(bounds);
				var factoryPixels:ByteArray = factoryData.bitmapData.getPixels(bounds);
				composerPixels.position = factoryPixels.position = 0;

				while (factoryPixels.bytesAvailable > 0)
				{
					var factoryByte:int = factoryPixels.readByte();
					var composerByte:int = composerPixels.readByte();
					if (factoryByte != composerByte)
					{
						errorString += " factoryData and textFlowData are different. ";
						Result = false;
						break;
					}
				}
			}
			else
			{
				errorString += " factoryData or composerData is invalid. ";
				Result = false;
			}

			return Result;
		}

		private function cleanUp() : void
		{
			// remove everything but the Border
			for (var i:int = testCanvas.rawChildren.numChildren - 1; i >= 0; i--)
				if (!(testCanvas.rawChildren.getChildAt(i) is Border))
					testCanvas.rawChildren.removeChildAt(i);
		}
	}
}
