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
	public class TableFormattedElement extends ContainerFormattedElement
	{
		public function TableFormattedElement()
		{
			super();
		}
		
		/**
		 * Get a reference to the table. We could refactor this since it's accessed multiple times.
		 **/
		public function getTable():TableElement
		{
			// find the root element entry and either return null or the containing textFlow
			var elem:FlowGroupElement = this;
			while ((elem.parent) != null && !( elem.parent is TableElement))
				elem = elem.parent;
			return elem.parent as TableElement;		
		}
		
		
		private var _table:TableElement;
		
		/**
		 * Returns a reference to the table. For this to work we need to set the 
		 * table to null when it's removed. 
		 **/
		public function get table():TableElement {
			
			if (_table) return _table;
			
			// find the root element entry and either return null or the containing textFlow
			var elem:FlowGroupElement = this;
			
			while ((elem.parent) != null && !(elem.parent is TableElement)) {
				elem = elem.parent;
			}
			
			_table = elem.parent as TableElement;
			
			return _table;
		}
		
		/**
		 * @private
		 **/
		public function set table(element:TableElement):void {
			_table = element;
		}
	}
}

