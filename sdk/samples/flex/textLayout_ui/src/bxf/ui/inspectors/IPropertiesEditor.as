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
package bxf.ui.inspectors
{
	import flash.events.IEventDispatcher;
	
	public interface IPropertiesEditor extends IEventDispatcher
	{
		/**An instance of an IPropertiesEditor can be cached and re-used across multiple instances of the same
			object type.  The 'reset()' function is called on an existing property editor when a different
			instance of the component is selected.  The intent is that any internal state related to a previous
			editing session is removed and the editor is in a condition similar to it was upon initial
			construction */
		function reset():void;
		
		function get properties():Object;	// associative array of property IDs and their values. 
		
		function rebuildUI():void;
		
		//function draw():void;	// Use this for any custom drawing. Dynamic renderer needs it; dont' think anyone else does
	}
}
