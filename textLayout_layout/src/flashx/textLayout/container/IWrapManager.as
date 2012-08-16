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
package flashx.textLayout.container
{
[ExcludeClass]
	/** @private The wrap manager keeps track of rectangular text wrap regions.
	 * A wrap manager keeps track of a list of wraps. 
	 */
	public interface IWrapManager
	{		
		/** Array of rectangular wraps. Each entry is expected to be a flash rectangle object. */
		function get wraps():Array;
		function set wraps(wrapsValue:Array):void;
	}
}