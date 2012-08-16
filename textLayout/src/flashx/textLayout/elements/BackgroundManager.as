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
package flashx.textLayout.elements
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	[ExcludeClass]
	/** @private Manages bounds calculation and rendering of backgroundColor character format. */
	public class BackgroundManager
	{
		protected var _lineDict:Dictionary;

		public function BackgroundManager()
		{ _lineDict = new Dictionary(true);	}
		
		public function addRect(tl:TextLine, fle:FlowLeafElement, r:Rectangle, color:uint, alpha:Number):void
		{
			var entry:Array = _lineDict[tl];
			if (entry == null)
				entry = _lineDict[tl] = new Array();
			
			var record:Object = new Object();
			record.rect = r;
			record.fle = fle;
			record.color = color;
			record.alpha = alpha;
			var fleAbsoluteStart:int = fle.getAbsoluteStart();
			
			for (var i:int = 0; i < entry.length; ++i)
			{
				var currRecord:Object = entry[i];
				if (currRecord.hasOwnProperty("fle") && currRecord.fle.getAbsoluteStart() == fleAbsoluteStart)
				{
					// replace it
					entry[i] = record;
					return;
				}
			}
			entry.push(record);
		}
		
		public function addNumberLine(tl:TextLine, numberLine:TextLine):void
		{
			var entry:Array = _lineDict[tl];
			if (entry == null)
				entry = _lineDict[tl] = new Array();
			entry.push({numberLine:numberLine});
		}

		
		public function finalizeLine(line:TextFlowLine):void
		{ return; }	// nothing to do here
		
		/** @private */
		tlf_internal function getEntry(line:TextLine):*
		{
			return _lineDict ? _lineDict[line] : undefined; 
		}
		
		// This version is used for the TextLineFactory
		public function drawAllRects(textFlow:TextFlow,bgShape:Shape,constrainWidth:Number,constrainHeight:Number):void
		{
			for (var line:Object in _lineDict)
			{
				var entry:Array = _lineDict[line];
				if (entry.length)
				{
					var columnRect:Rectangle = entry[0].columnRect;	// set in TextLineFactoryBase.finalizeLine
					var r:Rectangle;
					var record:Object;
					for(var i:int = 0; i<entry.length; ++i)
					{
						record = entry[i];
						if (record.hasOwnProperty("numberLine"))
						{
							var numberLine:TextLine = record.numberLine;
							var backgroundManager:BackgroundManager = TextFlowLine.getNumberLineBackground(numberLine);
							var numberEntry:Array = backgroundManager._lineDict[numberLine];
							for (var ii:int = 0; ii < numberEntry.length; ii++)
							{
								var numberRecord:Object = numberEntry[ii];
								r = numberRecord.rect;
								r.x += line.x + numberLine.x;
								r.y += line.y + numberLine.y;
								TextFlowLine.constrainRectToColumn(textFlow, r, columnRect, 0, 0, constrainWidth, constrainHeight)						
								
								bgShape.graphics.beginFill(numberRecord.color, numberRecord.alpha);
								bgShape.graphics.drawRect(r.x,r.y,r.width,r.height);
								bgShape.graphics.endFill();
							}
						}
						else
						{
							r = record.rect;
							r.x += line.x;
							r.y += line.y;
							TextFlowLine.constrainRectToColumn(textFlow, r, columnRect, 0, 0, constrainWidth, constrainHeight)						
							
							bgShape.graphics.beginFill(record.color, record.alpha);
							bgShape.graphics.drawRect(r.x,r.y,r.width,r.height);
							bgShape.graphics.endFill();
						}
					}
				}
			}
		}		
		
		public function removeLineFromCache(tl:TextLine):void
		{
			delete _lineDict[tl];
		}

		// This version is used for the TextFlow/flowComposer standard model
		public function onUpdateComplete(controller:ContainerController):void
		{
			var container:Sprite = controller.container;
			var bgShape:Shape;
			
			if(container && container.numChildren)
			{
				bgShape = controller.getBackgroundShape();
				bgShape.graphics.clear();
				
				for(var childIdx:int = 0; childIdx<controller.textLines.length; ++childIdx)
				{
					var tl:TextLine = controller.textLines[childIdx];
					var entry:Array = _lineDict[tl];
		
					if (entry)
					{
						var r:Rectangle;
						var tfl:TextFlowLine = tl.userData as TextFlowLine;
						// assert we actually got a tlf from the userData
						CONFIG::debug { assert(tfl != null, "BackgroundManager missing TextFlowLine!"); }
						
						for(var i:int = 0; i < entry.length; i++)
						{
							var record:Object = entry[i];
							// two kinds of records - numberLines and regular
							if (record.hasOwnProperty("numberLine"))
							{
								var numberLine:TextLine = record.numberLine;
								var backgroundManager:BackgroundManager = TextFlowLine.getNumberLineBackground(numberLine);
								var numberEntry:Array = backgroundManager._lineDict[numberLine];
								for (var ii:int = 0; ii < numberEntry.length; ii++)
								{
									var numberRecord:Object = numberEntry[ii];
									r = numberRecord.rect.clone();
									r.x += numberLine.x;
									r.y += numberLine.y;
									tfl.convertLineRectToContainer(r, true);
									
									bgShape.graphics.beginFill(numberRecord.color, numberRecord.alpha);
									bgShape.graphics.drawRect(r.x,r.y,r.width,r.height);
									bgShape.graphics.endFill();
								}
							}
							else
							{
								r = record.rect.clone();
								tfl.convertLineRectToContainer(r, true);
								
								bgShape.graphics.beginFill(record.color, record.alpha);
								bgShape.graphics.drawRect(r.x,r.y,r.width,r.height);
								bgShape.graphics.endFill();
							}
						}
					}
				}
			}
		}
	}
}