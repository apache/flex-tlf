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
package bxf.ui.controls
{
	import flash.events.Event;

	public class HotTextEvent extends Event
	{
		public static const CHANGE:String = "change";	
		public static const FINISH_CHANGE:String = "finishChange";	
		public static const ACTIVE:String = "active";
		public static const INACTIVE:String = "inactive";	
		
	/**
     *  The new value of the HotText. 
      */
    	public var value:Object;
    	
        public function HotTextEvent(type:String, value:Object = null,
	    							bubbles:Boolean = false,
	                                cancelable:Boolean = false,
	                                triggerEvent:Event = null,
	                                clickTarget:String = null, keyCode:int = -1)
	    {
	        super(type, bubbles, cancelable);
        	this.value = value;
        }
	    
	}
}
