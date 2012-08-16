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
package flashx.textLayout.formats
{
[ExcludeClass]
	/**
	 * An enumeration to describe how a FlowElement should be treated when composed. 
	 * @see text.elements.FlowElement#display
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
	 * These APIs are still in prototype phase
	 * @private
	 */
	public final class FlowElementDisplayType 
	{
			/** Element appears inline in the text; it is placed in its parent's geometry context */
		public static const INLINE:String = "inline";
			/** Element floats with the text, but supplies its own geometry context (e.g., a sidebar or table) */
		public static const FLOAT:String = "float";	
	}
}
