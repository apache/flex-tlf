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
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.WhiteSpaceCollapse;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	/** The SpecialCharacterElement class is an abstract base class for elements that represent special characters.
	 *
	 * <p>You cannot create a SpecialCharacterElement object directly. Invoking <code>new SpecialCharacterElement()</code>
	 * throws an error exception.</p>
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 * @see BreakElement
	 * @see TabElement
	 */
	public class SpecialCharacterElement extends SpanElement
	{
		/**  
		 * Base class - invoking <code>new SpecialCharacterElement()</code> throws an error exception.
		 * 
		 * @playerversion Flash 10
	 	 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 */
		 
		public function SpecialCharacterElement()
		{
			super();
		//	blockElement = new TextElement(null, null);
						
			// Set WhiteSpaceCollapse.PRESERVE to prevent merging with a sibling span with WhiteSpaceCollapse.COLLAPSE setting
			// (during normalization). Otherwise the '\t' will be removed during the call to applyWhiteSpaceCollapse (following normalization).
			// Once applyWhiteSpaceCollapse has been called, we can allow merging.
			whiteSpaceCollapse = WhiteSpaceCollapse.PRESERVE; 
		}
		
		/** @private */
		tlf_internal override function mergeToPreviousIfPossible():Boolean
		{
			if (parent)
			{
				var myidx:int = parent.getChildIndex(this);
				if (myidx != 0)
				{
					var sib:SpanElement = parent.getChildAt(myidx-1) as SpanElement;
					if (sib != null && (sib is SpanElement) && TextLayoutFormat.isEqual(sib.format,format))
					{
						CONFIG::debug { assert(this.parent == sib.parent, "Should never merge two spans with different parents!"); }
						
						// Merge them in the Player's TextBlock structure
						var siblingInsertPosition:int = sib.textLength;
						sib.replaceText(siblingInsertPosition, siblingInsertPosition, this.text);
						parent.replaceChildren(myidx,myidx+1);
						return true;
					}
				}
				// make a span and replace ourself
				var newSib:SpanElement = new SpanElement();
				newSib.text = this.text;
				newSib.format = format;
				parent.replaceChildren(myidx,myidx+1,newSib);
				newSib.normalizeRange(0,newSib.textLength);
				return false;
			} 
			return false;
		}
	}
}