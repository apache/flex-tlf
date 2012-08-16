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
package flashx.textLayout.operations
{
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

	/** 
	 * The UndoOperation class encapsulates an undo operation.
	 *
	 * @see flashx.textLayout.edit.EditManager
	 * @see flashx.textLayout.events.FlowOperationEvent
	 * 
	 * @includeExample examples\UndoOperation_example.as -noswf
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
	 */
	public class UndoOperation extends FlowOperation
	{
		private var _operation:FlowOperation;	/** Operation to be undone - here so listeners on FlowOperationEvent can see. */
		
		/** 
		 * Creates an UndoOperation object.
		 * 
		 * @param op	The operation to undo.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0 
		 */
		public function UndoOperation(op:FlowOperation)
		{ 
			super(null);
			_operation = op;
		}
		
		/** 
		 * The operation to undo. 
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 */
		public function get operation():FlowOperation
		{
			return _operation;
		}
		public function set operation(value:FlowOperation):void
		{
			_operation = value;
		}
	}
}
