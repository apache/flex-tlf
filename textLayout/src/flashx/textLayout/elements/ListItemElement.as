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
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.IListMarkerFormat;
	import flashx.textLayout.formats.ListMarkerFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	/** 
	 * <p> ListItemElement is an item in a list. It most commonly contains one or more ParagraphElement objects, but could
	 * also have children of type DivElement or ListElement. A ListItemElement always appears within a ListElement.</p>
	 *
	 * <p>A ListItemElement has automatically generated content that appears before the regular content of the list. This is called
	 * the <i>marker</i>, and it is what visually distinguishes the list item. The listStyleType property governs how the marker
	 * is generated and allows the user to control whether the list item is marked with a bullet, a number, or alphabetically.
	 * The listStylePosition governs where the marker appears relative to the list item; specifically it may appear outside, in the 
	 * margin of the list, or inside, beside the list item itself. The ListMarkerFormat defines the TextLayoutFormat of the marker
	 * (by default this will be the same as the list item), as well as an optional suffix that goes at the end of the marker. For 
	 * instance, for a numbered list, it is common to have a "." as a suffix that appears after the number. The ListMarkerFormat also
	 * allows specification of text that goes at the start of the marker, and for numbered lists allows control over the numbering.</p>
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 * @see ParagraphElement
	 * @see flashx.textLayout.formats.ITextLayoutFormat#listStyleType
	 * @see flashx.textLayout.formats.ITextLayoutFormat#listStylePosition
	 * @see flashx.textLayout.formats.ListMarkerFormat
	 */
	public final class ListItemElement extends ContainerFormattedElement
	{		
		/** @private Helps figure out the list number.  Use MAX_VALUE when not set */
		tlf_internal var _listNumberHint:int = int.MAX_VALUE;
		
		/** @private */
		override protected function get abstract():Boolean
		{ return false; }
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "li"; }
		
		/** @private - make more efficient? save and damage results as need be */
		tlf_internal function computedListMarkerFormat():IListMarkerFormat
		{
			var format:IListMarkerFormat = this.getUserStyleWorker(ListElement.LIST_MARKER_FORMAT_NAME) as IListMarkerFormat;
			if (format == null)
			{
				var tf:TextFlow = this.getTextFlow();
				if (tf)
					format = tf.configuration.defaultListMarkerFormat;
			}

			return format;
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
			
			_listNumberHint = int.MAX_VALUE;
			
			// A listItem must have a Paragraph at the start. 
			// note not all browsers behave this way.
			if (normalizeNeedsInitialParagraph())
			{
				var p:ParagraphElement = new ParagraphElement();

				p.replaceChildren(0,0,new SpanElement());
				replaceChildren(0,0,p);	
				p.normalizeRange(0,p.textLength);	
			}
		}
		
		/** @private */
		tlf_internal function getListItemNumber(listMarkerFormat:IListMarkerFormat = null):int
		{
			CONFIG::debug { assert(parent != null,"invalid call to ListItemElement.getListItemNumber"); }
			
			if (_listNumberHint == int.MAX_VALUE)
			{
				if (listMarkerFormat == null)
					listMarkerFormat = 	computedListMarkerFormat();
				
				var counterReset:Object = listMarkerFormat.counterReset;
					
				if (counterReset && counterReset.hasOwnProperty("ordered"))
					_listNumberHint = counterReset.ordered;
				else
				{
					// search backwards for a ListItemElement and call getListItemNumber on it
					var idx:int = parent.getChildIndex(this);
					
					_listNumberHint = 0;	// if none is found this is zero
								
					while (idx > 0)
					{
						idx--;
						var sibling:ListItemElement = parent.getChildAt(idx) as ListItemElement;
						if (sibling)
						{
							_listNumberHint = sibling.getListItemNumber();
							break;
						}
					}
				}
				
				// increment the counter
				var counterIncrement:Object = listMarkerFormat.counterIncrement;
				_listNumberHint += (counterIncrement && counterIncrement.hasOwnProperty("ordered")) ? counterIncrement.ordered : 1;
			}

			return _listNumberHint;
		}
		
		// Fix bug 2800975 ListMarkerFormat.paragraphStartIndent not applied properly in Inside lists.
		/** @private */
		tlf_internal override function getEffectivePaddingLeft():Number
		{
			if(getTextFlow().computedFormat.blockProgression == BlockProgression.TB)
			{
				if(computedFormat.paddingLeft == FormatValue.AUTO)
				{
						if (computedFormat.listMarkerFormat !==undefined && computedFormat.listMarkerFormat.paragraphStartIndent !== undefined)
						{
							return  computedFormat.listMarkerFormat.paragraphStartIndent;
						}
					return 0;
						
				}
				else
				{
					if (computedFormat.listMarkerFormat !==undefined && computedFormat.listMarkerFormat.paragraphStartIndent !== undefined)
					{
						return computedFormat.paddingLeft+computedFormat.listMarkerFormat.paragraphStartIndent;
					}
					return computedFormat.paddingLeft;
				}
			}
			else
			{
				return 0;
			}
		}
		/** @private */
		tlf_internal override function getEffectivePaddingTop():Number
		{
			if(getTextFlow().computedFormat.blockProgression == BlockProgression.RL)
			{
				if(computedFormat.paddingTop == FormatValue.AUTO)
				{
					if (computedFormat.listMarkerFormat !==undefined && computedFormat.listMarkerFormat.paragraphStartIndent !== undefined)
					{
						return  computedFormat.listMarkerFormat.paragraphStartIndent;
					}
					return 0;
					
				}
				else
				{
					if (computedFormat.listMarkerFormat !==undefined && computedFormat.listMarkerFormat.paragraphStartIndent !== undefined)
					{
						return computedFormat.paddingTop+computedFormat.listMarkerFormat.paragraphStartIndent;
					}
					return computedFormat.paddingTop;
				}
			}
			else
			{
				return 0;
			}
		}
		/** @private */
		tlf_internal override function getEffectivePaddingRight():Number
		{
			if(getTextFlow().computedFormat.blockProgression == BlockProgression.TB)
			{
				if(computedFormat.paddingRight == FormatValue.AUTO)
				{
					if (computedFormat.listMarkerFormat !==undefined && computedFormat.listMarkerFormat.paragraphStartIndent !== undefined)
					{
						return  computedFormat.listMarkerFormat.paragraphStartIndent;
					}
					return 0;
					
				}
				else
				{
					if (computedFormat.listMarkerFormat !==undefined && computedFormat.listMarkerFormat.paragraphStartIndent !== undefined)
					{
						return computedFormat.paddingRight+computedFormat.listMarkerFormat.paragraphStartIndent;
					}
					return computedFormat.paddingRight;
				}
			}
			else
			{
				return 0;
			}
		}
		
		/** @private */
		tlf_internal override function getEffectivePaddingBottom():Number
		{
			if(getTextFlow().computedFormat.blockProgression == BlockProgression.RL)
			{
				if(computedFormat.paddingBottom == FormatValue.AUTO)
				{
					if (computedFormat.listMarkerFormat !==undefined && computedFormat.listMarkerFormat.paragraphStartIndent !== undefined)
					{
						return  computedFormat.listMarkerFormat.paragraphStartIndent;
					}
					return 0;
					
				}
				else
				{
					if (computedFormat.listMarkerFormat !==undefined && computedFormat.listMarkerFormat.paragraphStartIndent !== undefined)
					{
						return computedFormat.paddingBottom+computedFormat.listMarkerFormat.paragraphStartIndent;
					}
					return computedFormat.paddingBottom;
				}
			}
			else
			{
				return 0;
			}
		}
		
		
	}
}
