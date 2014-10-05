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
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.Parcel;
	import flashx.textLayout.compose.ParcelList;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.compose.TextFlowTableBlock;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.TabElement;
	import flashx.textLayout.factory.FactoryDisplayComposer;
	import flashx.textLayout.formats.BackgroundColor;
	import flashx.textLayout.formats.BorderColor;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	/** @private Manages bounds calculation and rendering of backgroundColor character format. */
	public class BackgroundManager
	{
		public static var BACKGROUND_MANAGER_CACHE:Dictionary = null;
		
		public static var TOP_EXCLUDED:String = "topExcluded";
		public static var BOTTOM_EXCLUDED:String = "bottomExcluded";
		public static var TOP_AND_BOTTOM_EXCLUDED:String = "topAndBottomExcluded";
		protected var _lineDict:Dictionary;
		protected var _blockElementDict:Dictionary;
		protected var _rectArray:Array;
		
		public function BackgroundManager()
		{ 
			_lineDict = new Dictionary(true);
			_blockElementDict = new Dictionary(true);
			_rectArray = new Array();
		}		
		
		//clear _rectArray, at the beginning of compose TextFlow
		public function clearBlockRecord():void
		{
			_rectArray.splice(0, _rectArray.length);
		}
		
		//insert the background or border rectangle into the front of _rectArray, to make sure the elements that have 
		//larger z-index will be drawn later
		public function addBlockRect(elem:FlowElement, r:Rectangle, cc:ContainerController = null, style:String = null):void
		{
			var rect:Object = new Object();
			rect.r = r;
			rect.elem = elem;
			rect.cc = cc;
			rect.style = style;
			_rectArray.unshift(rect);
		}
		
		//register the elements that have background or border to _blockElementDict
		public function addBlockElement(elem:FlowElement):void
		{
			//register the elements that have never been registered
			if(!_blockElementDict.hasOwnProperty(elem))
			{
				var format:ITextLayoutFormat = elem.computedFormat;
				var record:Object = new Object();
				record.backgroundColor = format.backgroundColor;
				record.backgroundAlpha = format.backgroundAlpha;
				
				record.borderLeftWidth = format.borderLeftWidth;
				record.borderRightWidth = format.borderRightWidth;
				record.borderTopWidth = format.borderTopWidth;
				record.borderBottomWidth = format.borderBottomWidth;
			

				record.borderLeftColor = format.borderLeftColor;
				record.borderRightColor = format.borderRightColor;
				record.borderTopColor = format.borderTopColor;
				record.borderBottomColor = format.borderBottomColor;
				
				_blockElementDict[elem] = record;
			}
		}
		
		public static function collectTableBlock(_textFlow:TextFlow,block:TextFlowTableBlock,controller:ContainerController):void
		{
			// add block rect for each cell in table block
			
			var bb:BackgroundManager;
			var r:Rectangle;
			var composer:IFlowComposer;

			var cells:Vector.<TableCellElement> = block.getTableCells();
			for each(var cell:TableCellElement in cells){
				if(BackgroundManager.hasBorderOrBackground(cell))
				{
					if(!_textFlow.backgroundManager)
						_textFlow.getBackgroundManager();
					bb = _textFlow.backgroundManager;

					bb.addBlockElement(cell);

					var row:TableRowElement = cell.getRow();
					r = new Rectangle(cell.x, cell.y + block.y, cell.width, row.composedHeight);
					bb.addBlockRect(cell, r, controller);

				}
			}
			block.y;
			
		}
		
		public static function collectBlock(_textFlow:TextFlow, elem:FlowGroupElement, _parcelList:ParcelList = null, tableComposeNotFromBeginning:Boolean = false, tableOutOfView:Boolean = false):void
		{
			var bb:BackgroundManager;
			var r:Rectangle;
			var controller:ContainerController;
			var composer:IFlowComposer;

			if(elem)
			{

				if(BackgroundManager.hasBorderOrBackground(elem))
				{
					//mark the paragraph that has border or background
					if(!_textFlow.backgroundManager)
						_textFlow.getBackgroundManager();
					bb = _textFlow.backgroundManager;
				
					//BackgroundManager should not be null here
					CONFIG::debug { assert(_textFlow.backgroundManager != null ,"BackgroundManager should not be null"); }
					
					bb.addBlockElement(elem);
					
					composer = _textFlow.flowComposer;
					if(composer && elem.textLength > 1)
					{
						if(elem is TableElement)
						{
							// Do we need to do anything for table elements? Not sure...
							var tab:TableElement = elem as TableElement;

						}
						else //for elements like ParagraphElement, DivElement, ListItemElement, ListElement, TextFlow
						{	
							var tb:TextBlock = null;
							var p:ParagraphElement = elem.getFirstLeaf().getParagraph();
							if(p)
								tb = p.getTextBlock();
							while(!tb && p)
							{
								p = p.getNextParagraph();
								tb = p.getTextBlock();
							}
							
							if(composer is StandardFlowComposer && composer.numLines > 0)
							{
								//get the first line and the last line
								var firstLine:TextFlowLine = null;
								var lastLine:TextFlowLine = null;
								
								if(tb && tb.firstLine)
								{
									firstLine = tb.firstLine.userData;
									
									do{
										tb = p.getTextBlock();
										if(tb && tb.lastLine)
											lastLine = tb.lastLine.userData;
										var leaf:FlowLeafElement = p.getLastLeaf().getNextLeaf(elem);
										if(leaf)
											p = leaf.getParagraph();
										else
											p = null;
									}while(p)
								}
								if(firstLine && lastLine)
								{
									var startColumnIndex:int = firstLine.columnIndex;
									var startController:ContainerController = firstLine.controller;
									var endColumnIndex:int = lastLine.columnIndex;
									var endController:ContainerController = lastLine.controller;
									if(startController && endController)
									{
										if(startController == endController && endColumnIndex == startColumnIndex)
										{
											r = startController.columnState.getColumnAt(startColumnIndex);
											r.top = firstLine.y;
											r.bottom = lastLine.y + lastLine.height;
											bb.addBlockRect(elem, r, startController);
										}else
										{
											//start part
											if(startController != endController)
											{
												for(var sIdx:int = startController.columnCount - 1; sIdx > startColumnIndex; sIdx--)
												{
													r = startController.columnState.getColumnAt(sIdx);
													bb.addBlockRect(elem, r, startController);
												}
											}
											if(endColumnIndex != startColumnIndex)
											{
												r = startController.columnState.getColumnAt(startColumnIndex);
												r.top = firstLine.y;
												bb.addBlockRect(elem, r, startController);
											}
											//center part, all parcel should be painted
											var passFirstController:Boolean = false;
											for(var aidx:Number = 0; aidx < composer.numControllers; aidx++)
											{
												var cc:ContainerController = composer.getControllerAt(aidx);
												if(passFirstController)
												{
													for(var cidx:int = 0; cidx < cc.columnCount; cidx++)
													{
														r = cc.columnState.getColumnAt(cidx);
														bb.addBlockRect(elem, r, cc);
													}
												}
												if(cc == endController)
													break;
												if(cc == startController)
													passFirstController = true;
											}
											//end part
											if(startController != endController)
											{
												for(var eIdx:int = 0; eIdx < endColumnIndex; eIdx++)
												{
													r = endController.columnState.getColumnAt(eIdx);
													bb.addBlockRect(elem, r, endController);
												}
											}
											r = endController.columnState.getColumnAt(endColumnIndex);
											r.bottom = lastLine.y + lastLine.height;
											bb.addBlockRect(elem, r, endController);
										}
									}
								}
							}
							//the first time display for TCM
							else if(composer is FactoryDisplayComposer)
							{
								var fLine:TextLine = null;
								var lLine:TextLine = null;
								
								if(tb && tb.firstLine)
								{
									fLine = tb.firstLine;
									
									do{
										tb = p.getTextBlock();
										if(tb && tb.lastLine)
											lLine = tb.lastLine;
										var leafF:FlowLeafElement = p.getLastLeaf().getNextLeaf(elem);
										if(leafF)
											p = leafF.getParagraph();
										else
											p = null;
									}while(p)
								}
								if(fLine && lLine)
								{
									if((composer as Object).hasOwnProperty("tcm"))
									{
										var tcm:TextContainerManager = (composer as Object).tcm;
										if(tcm)
										{
											r =  new Rectangle(0, fLine.y - fLine.height, tcm.compositionWidth, lLine.y - fLine.y + fLine.height);
											bb.addBlockRect(elem, r, composer.getControllerAt(0));
										}
									}
								}
							}
						}
					}
				}
			}
		}
		
		public static function hasBorderOrBackground(elem:FlowElement):Boolean
		{
			var format:ITextLayoutFormat = elem.computedFormat;
			if(format.backgroundColor != BackgroundColor.TRANSPARENT)
				return true;

			if(format.borderLeftWidth != 0  || format.borderRightWidth != 0 || 
				format.borderTopWidth != 0 || format.borderBottomWidth != 0)
				if(format.borderLeftColor != BorderColor.TRANSPARENT ||
					format.borderRightColor != BorderColor.TRANSPARENT || format.borderTopColor != BorderColor.TRANSPARENT ||
					format.borderBottomColor != BorderColor.TRANSPARENT )
					return true;
			return false;
		}
		
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
			//draw background or border for block elements
			var block:Object;
			var rec:Rectangle;
			var style:Object;
			for(var idx:int = 0; idx < _rectArray.length; idx++)
			{
				block = _rectArray[idx];
				rec = block.r;
				style = _blockElementDict[block.elem];
				
				if(rec && style)
				{
					var g:Graphics = bgShape.graphics;
					//draw background
					if(style.backgroundColor != BackgroundColor.TRANSPARENT)
					{
						// The value 0 indicates hairline thickness; 
						g.lineStyle(NaN, style.backgroundColor, style.backgroundAlpha, true);
						g.beginFill(style.backgroundColor, style.backgroundAlpha);
						g.drawRect(rec.x, rec.y, rec.width, rec.height);
						g.endFill();
					}
					//draw top border
					g.moveTo(rec.x + Math.floor(style.borderLeftWidth/2), rec.y + Math.floor(style.borderTopWidth/2));
					if((block.style != BackgroundManager.TOP_EXCLUDED && block.style != BackgroundManager.TOP_AND_BOTTOM_EXCLUDED) &&
						style.borderTopWidth != 0 && style.borderTopColor != BorderColor.TRANSPARENT)
					{
						g.lineStyle(style.borderTopWidth, style.borderTopColor, style.backgroundAlpha, true, "normal", CapsStyle.SQUARE);
						g.lineTo(rec.x + rec.width - Math.floor(style.borderLeftWidth/2), rec.y + Math.floor(style.borderTopWidth/2));
					}
					//draw right border
					g.moveTo(rec.x + rec.width - Math.floor(style.borderRightWidth/2), rec.y + Math.floor(style.borderTopWidth/2));
					if(style.borderRightWidth != 0 && style.borderRightColor != BorderColor.TRANSPARENT)
					{
						g.lineStyle(style.borderRightWidth, style.borderRightColor, style.backgroundAlpha, true, "normal", CapsStyle.SQUARE);
						g.lineTo(rec.x + rec.width - Math.floor(style.borderRightWidth/2), rec.y + rec.height- Math.floor(style.borderTopWidth/2));
					}
					//draw bottom border
					g.moveTo(rec.x + rec.width - Math.floor(style.borderLeftWidth/2), rec.y + rec.height - Math.floor(style.borderBottomWidth/2));
					if((block.style != BackgroundManager.BOTTOM_EXCLUDED && block.style != BackgroundManager.TOP_AND_BOTTOM_EXCLUDED) &&
						style.borderBottomWidth != 0 && style.borderBottomColor != BorderColor.TRANSPARENT)
					{
						g.lineStyle(style.borderBottomWidth, style.borderBottomColor, style.backgroundAlpha, true, "normal", CapsStyle.SQUARE);
						g.lineTo(rec.x + Math.floor(style.borderLeftWidth/2), rec.y + rec.height - Math.floor(style.borderBottomWidth/2));
					}
					//draw left border
					g.moveTo(rec.x + Math.floor(style.borderLeftWidth/2), rec.y + rec.height - Math.floor(style.borderTopWidth/2));
					if(style.borderLeftWidth != 0 && style.borderLeftColor != BorderColor.TRANSPARENT)
					{
						g.lineStyle(style.borderLeftWidth, style.borderLeftColor, style.backgroundAlpha, true, "normal", CapsStyle.SQUARE);
						g.lineTo(rec.x + Math.floor(style.borderLeftWidth/2), rec.y + Math.floor(style.borderTopWidth/2));
					}
				}
			}
			//draw background for span
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
				
				//draw background or border for block elements
				var rec:Rectangle;
				var style:Object;
				var block:Object;
				for(var idx:int = 0; idx < _rectArray.length; idx++)
				{
					block = _rectArray[idx];
					if(block.cc == controller)
					{
						style = _blockElementDict[block.elem];
						if(style != null)
						{
							rec = block.r;
							var g:Graphics = bgShape.graphics;
							//draw background
							if(style.backgroundColor != BackgroundColor.TRANSPARENT)
							{
								// The value 0 indicates hairline thickness; NaN removes line
								g.lineStyle(NaN, style.backgroundColor, style.backgroundAlpha, true);
								g.beginFill(style.backgroundColor, style.backgroundAlpha);
								g.drawRect(rec.x, rec.y, rec.width, rec.height);
								g.endFill();
							}
							//draw top border
							g.moveTo(rec.x + Math.floor(style.borderLeftWidth/2), rec.y + Math.floor(style.borderTopWidth/2));
							if((block.style != BackgroundManager.TOP_EXCLUDED && block.style != BackgroundManager.TOP_AND_BOTTOM_EXCLUDED) &&
								style.borderTopWidth != 0 && style.borderTopColor != BorderColor.TRANSPARENT)
							{
								g.lineStyle(style.borderTopWidth, style.borderTopColor, style.backgroundAlpha, true, "normal", CapsStyle.SQUARE);
								g.lineTo(rec.x + rec.width - Math.floor(style.borderLeftWidth/2), rec.y + Math.floor(style.borderTopWidth/2));
							}
							//draw right border
							g.moveTo(rec.x + rec.width - Math.floor(style.borderRightWidth/2), rec.y + Math.floor(style.borderTopWidth/2));
							if(style.borderRightWidth != 0 && style.borderRightColor != BorderColor.TRANSPARENT)
							{
								g.lineStyle(style.borderRightWidth, style.borderRightColor, style.backgroundAlpha, true, "normal", CapsStyle.SQUARE);
								g.lineTo(rec.x + rec.width - Math.floor(style.borderRightWidth/2), rec.y + rec.height- Math.floor(style.borderTopWidth/2));
							}
							//draw bottom border
							g.moveTo(rec.x + rec.width - Math.floor(style.borderLeftWidth/2), rec.y + rec.height - Math.floor(style.borderBottomWidth/2));
							if((block.style != BackgroundManager.BOTTOM_EXCLUDED && block.style != BackgroundManager.TOP_AND_BOTTOM_EXCLUDED) &&
								style.borderBottomWidth != 0 && style.borderBottomColor != BorderColor.TRANSPARENT)
							{
								g.lineStyle(style.borderBottomWidth, style.borderBottomColor, style.backgroundAlpha, true, "normal", CapsStyle.SQUARE);
								g.lineTo(rec.x + Math.floor(style.borderLeftWidth/2), rec.y + rec.height - Math.floor(style.borderBottomWidth/2));
							}
							//draw left border
							g.moveTo(rec.x + Math.floor(style.borderLeftWidth/2), rec.y + rec.height - Math.floor(style.borderTopWidth/2));
							if(style.borderLeftWidth != 0 && style.borderLeftColor != BorderColor.TRANSPARENT)
							{
								g.lineStyle(style.borderLeftWidth, style.borderLeftColor, style.backgroundAlpha, true, "normal", CapsStyle.SQUARE);
								g.lineTo(rec.x + Math.floor(style.borderLeftWidth/2), rec.y + Math.floor(style.borderTopWidth/2));
							}
						}
					}
				}
				//draw background for span	
				for(var childIdx:int = 0; childIdx<controller.textLines.length; ++childIdx)
				{
					var line:* = controller.textLines[childIdx];
					// skip TextFlowTableBlocks
					if(!(line is TextLine))
						continue;
					var tl:TextLine = line;
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
								if(numberEntry)
								{
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
		
		public function getShapeRectArray():Array
		{
			return _rectArray;
		}
	}
}