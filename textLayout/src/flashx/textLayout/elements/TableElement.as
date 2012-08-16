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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.events.FlowElementEventDispatcher;
	import flashx.textLayout.events.FlowElementMouseEventManager;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	
	/** 
	 * The TableElement class is used for grouping together items into a table. 
	 * A TableElement's children must be of type TableRowElement, TableColElement, TableColGroupElement, TableBodyElement.
	 * 
	 * 
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 */
	public class TableElement extends TableFormattedElement 
	{
		private var _row:int;
		private var _column:int;
		
		private var _height:Array = []; // parcel-indexed
		public var computedWidth:Number;
		
		public var x:Number;
		public var y:Number;
		
		//These attributes is from the original loop prototype. Maybe changed later
		public var totalRowDepth:Number = undefined;
		public var originParcelIndex:Number;
		public var numAcrossParcels:int;
        public var curRowIdx:int = 0; // this value should be only used while composing
        public var outOfLastParcel:Boolean = false; 
			
		private var arColumn:Array = [];
		
		public function TableElement()
		{
			super();
		}
		
		public function initTableElement(row:Number, column:Number):void
		{
			_row = row;
			_column = column;
			
			for ( var i:int = 0; i < column; i ++ )
			{
				var col:TableColElement = new TableColElement();	
				arColumn[i] = col;
			}
		}
		
		/** @private */
		override protected function get abstract():Boolean
		{ return false; }
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "table"; }
		
		/** @private */
		tlf_internal override function canOwnFlowElement(elem:FlowElement):Boolean
		{
			return  (elem is TableBodyElement) || (elem is TableRowElement) || (elem is TableColElement) || (elem is TableColGroupElement);
		}
		
		/** @private if its in a numbered list expand the damage to all list items - causes the numbers to be regenerated */
		tlf_internal override function modelChanged(changeType:String, elem:FlowElement, changeStart:int, changeLen:int, needNormalize:Boolean = true, bumpGeneration:Boolean = true):void
		{
			super.modelChanged(changeType,elem,changeStart,changeLen,needNormalize,bumpGeneration);
		}
		
		public function get row():int
		{
			return _row;
		}
		
		public function get column():int
		{
			return _column;
		}

		public function getColumnAt(columnIndex:int):TableColElement
		{
			if ( columnIndex < 0 || columnIndex >= _column )
				return null;
			return arColumn[columnIndex];
		}
		
		public function setColumnWidth(columnIndex:int, value:*):Boolean
		{
			var tableColElement:TableColElement = getColumnAt(columnIndex) as TableColElement;
			if ( ! tableColElement )
				return false;
			
			tableColElement.tableColumnWidth = value;
			return true;
		}
		
		public function getColumnWidth(columnIndex:int):*
		{
			var tableColElement:TableColElement = getColumnAt(columnIndex) as TableColElement;
			if ( tableColElement )
				return tableColElement.tableColumnWidth;
			return 0;
        }
        
        public function get height():Number
        {
            return _height[numAcrossParcels];
        }
        
        public function set height(val:*):void
        {
            _height[numAcrossParcels] = val;
        }
        
        public function get heightArray():Array
        {
            return _height;
        }
        
        public function set heightArray(newArray:Array):void
        {
            _height = newArray;
        }
		
	}
}
