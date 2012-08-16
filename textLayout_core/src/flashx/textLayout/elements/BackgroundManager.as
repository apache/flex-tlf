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
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.events.DamageEvent;
	import flashx.textLayout.formats.BackgroundColor;
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.utils.GeometryUtil;
	
	use namespace tlf_internal;
	
	[ExcludeClass]
	/** @private Manages bounds calculation and rendering of backgroundColor character format. */
	public class BackgroundManager
	{
		private var _textFlow:TextFlow;
		private var _lineDict:Dictionary;

		public function BackgroundManager():void
		{
			_lineDict = new Dictionary(true);
		}	
			
		public function set textFlow(t:TextFlow):void
		{
			_textFlow = t;
		}
		
		public function get textFlow():TextFlow
		{
			return _textFlow;
		}
		
		public function addRect(line:TextFlowLine, fle:FlowLeafElement, r:Rectangle, color:uint, alpha:Number):void
		{
			var tl:TextLine = line.getTextLine();
			
			if(_lineDict[tl] == null)
			{
				_lineDict[tl] = new Array();
			}
			var obj:Object = new Object();
			obj.rect = r;
			obj.fle = fle;
			obj.color = color;
			obj.alpha = alpha;
			var insert:Boolean = true;
			var fleAbsoluteStart:int = fle.getAbsoluteStart();
			
			for(var i:int = 0; i < _lineDict[tl].length; ++i)
			{
				if(_lineDict[tl][i].fle.getAbsoluteStart() == fleAbsoluteStart)
				{
					_lineDict[tl][i] = obj;
					insert = false;
				}
			}
			if(insert)
			{
				_lineDict[tl].push(obj);
			}
		}
		
		public function finalizeLine(line:TextFlowLine):void
		{ return; }	// nothing to do here
		
		/** @private */
		tlf_internal function get lineDict():Dictionary
		{
			return _lineDict;
		}
		
		// This version is used for the TextLineFactory
		public function drawAllRects(bgShape:Shape,controller:ContainerController):void
		{
			for (var line:Object in _lineDict)
			{
				var a:Array = _lineDict[line];
				if(a.length)
				{
					var columnRect:Rectangle = a[0].columnRect;	// set in TextLineFactoryBase.finalizeLine
					var r:Rectangle;
					var obj:Object;
					for(var i:int = 0; i<a.length; ++i)
					{
						obj = a[i];
						r = obj.rect;
						r.x += line.x;
						r.y += line.y;
						TextFlowLine.constrainRectToColumn(textFlow, r, columnRect, 0, 0, controller.compositionWidth, controller.compositionHeight)						
						
						bgShape.graphics.beginFill(obj.color, obj.alpha);
						bgShape.graphics.moveTo(r.left, r.top);
						bgShape.graphics.lineTo(r.right, r.top);
						bgShape.graphics.lineTo(r.right, r.bottom);
						bgShape.graphics.lineTo(r.left, r.bottom);
						bgShape.graphics.endFill();
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
			var container:DisplayObjectContainer = controller.container as DisplayObjectContainer;
			var bgShape:Shape;
			
			if(container && container.numChildren)
			{
				bgShape = controller.getBackgroundShape();
				bgShape.graphics.clear();
				
				for(var childIdx:int = 0; childIdx<controller.textLines.length; ++childIdx)
				{
					var tl:TextLine = controller.textLines[childIdx];
		
					if(_lineDict[tl])
					{
						if(!_lineDict[tl].length) 
						{
							continue;
						}	
						
						for(var i:int = 0; i<_lineDict[tl].length; ++i)
						{
							var r:Rectangle = _lineDict[tl][i].rect.clone();
							var tfl:TextFlowLine = tl.userData as TextFlowLine;
							//make sure we actually got a tlf from the userData
							if(tfl)
								tfl.convertLineRectToContainer(r, true);
							
							bgShape.graphics.beginFill(_lineDict[tl][i].color, _lineDict[tl][i].alpha);
							bgShape.graphics.moveTo(r.left, r.top);
							bgShape.graphics.lineTo(r.right, r.top);
							bgShape.graphics.lineTo(r.right, r.bottom);
							bgShape.graphics.lineTo(r.left, r.bottom);
							bgShape.graphics.endFill();
						}
					}
				}
			}
		}
	}
}