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
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;
	
	/** 
	 * The DivElement class defines an element for grouping paragraphs (ParagraphElement objects). If you want a group of paragraphs
	 * to share the same formatting attributes, you can group them in a DivElement object and apply the attributes to it. The paragraphs
	 * will inherit the attributes from the DivElement object.
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 * @includeExample examples\DivElementExample.as -noswf
	 *
	 * @see ParagraphElement
	 * @see TextFlow
	 */
	public final class DivElement extends ContainerFormattedElement
	{	
		/** @private */
		override protected function get abstract():Boolean
		{ return false; }
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "div"; }		
	}
}
