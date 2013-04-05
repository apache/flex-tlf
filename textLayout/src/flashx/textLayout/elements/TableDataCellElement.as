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
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	/** 
	 * <p> TableDataCellElement is an item in a TableRowElement. It most commonly contains one or more ParagraphElement objects, 
	 * A TableDataCellElement always appears within a TableRowElement.</p>
	 *
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 */
	public final class TableDataCellElement extends TableFormattedElement
	{		
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		private var _parcelIndex:int;
		
		private var _rowIndex:int;
		private var _colIndex:int;
		
		/** @private */
		override protected function get abstract():Boolean
		{ return false; }
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "td"; }
		
		/** @private if its in a numbered list expand the damage to all list items - causes the numbers to be regenerated */
		tlf_internal override function modelChanged(changeType:String, elem:FlowElement, changeStart:int, changeLen:int, needNormalize:Boolean = true, bumpGeneration:Boolean = true):void
		{
			super.modelChanged(changeType,elem,changeStart,changeLen,needNormalize,bumpGeneration);
		}
		
		/** @private ListItems must begin with zero or more divs with a paragraph */
		tlf_internal function normalizeNeedsInitialParagraph():Boolean
		{
			var p:FlowGroupElement = this;
			while (p)
			{
				p = p.getChildAt(0) as FlowGroupElement;
				if (p is ParagraphElement)
					return false;
				if (!(p is DivElement))
					return true;
			}
			return true;
		}
		
		/** @private */
		tlf_internal override function normalizeRange(normalizeStart:uint,normalizeEnd:uint):void
		{
			super.normalizeRange(normalizeStart,normalizeEnd);
			
			// A TableDataCellElement must have a Paragraph at the start. 
			// note not all browsers behave this way.
			if (normalizeNeedsInitialParagraph())
			{
				var p:ParagraphElement = new ParagraphElement();
				
				p.replaceChildren(0,0,new SpanElement());
				replaceChildren(0,0,p);	
				p.normalizeRange(0,p.textLength);	
			}
		}
		
		public function get parcelIndex():int
		{
			return _parcelIndex;
		}
		
		public function set parcelIndex(value:int):void
		{
			_parcelIndex = value;
		}
		
		public function get rowIndex():int
		{
			return _rowIndex;
		}
		
		public function set rowIndex(value:int):void
		{
			_rowIndex = value;
		}
		
		public function get colIndex():int
		{
			return _colIndex;
		}
		
		public function set colIndex(value:int):void
		{
			_colIndex = value;
		}
		
	}
}
