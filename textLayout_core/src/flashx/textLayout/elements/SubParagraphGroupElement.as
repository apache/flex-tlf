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
	import __AS3__.vec.Vector;
	
	import flash.events.EventDispatcher;
	import flash.text.engine.ContentElement;
	import flash.text.engine.GroupElement;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	/** 
	 * The SubParagraphGroupElement class groups FlowLeafElements together. A SubParagraphGroupElement is a child of a 
	 * ParagraphElement object and it can contain one or more FlowLeafElement objects as children.
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 * 
	 * @see FlowLeafElement
	 * @see LinkElement
	 * @see ParagraphElement
	 * @see TCYElement
	 */
	 
	public class SubParagraphGroupElement extends FlowGroupElement
	{
		private var _groupElement:GroupElement;
		
		/** @private - no listeners attached */
		tlf_internal static const NO_ATTACHED_LISTENERS:uint       	= 0;
		/** @private - only internal listeners attached */
		tlf_internal static const INTERNAL_ATTACHED_LISTENERS:uint = 1;
		/** @private - *may* be client attached listeners. */
		tlf_internal static const CLIENT_ATTACHED_LISTENERS:uint   = 2;
		
		/** bit field describing attached listeners */
		private var _attachedListenerStatus:uint;
		
		/** Maximum precedence value @private */
		tlf_internal static const kMaxSPGEPrecedence:uint = 1000;
		/** Minimum precedence value @private */
		tlf_internal static const kMinSPGEPrecedence:uint = 0;
		
		private var _canMerge:Boolean; 	// true if element is bound to an external data source - generated text

		/** Constructor - creates a new SubParagraphGroupElement instance.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		 
		public function SubParagraphGroupElement()
		{
			_canMerge = true;
			_attachedListenerStatus = NO_ATTACHED_LISTENERS;
			super();
		}
		
		/** @private */
		public override function shallowCopy(startPos:int = 0, endPos:int = -1):FlowElement
		{
			var retFlow:SubParagraphGroupElement = super.shallowCopy(startPos, endPos) as SubParagraphGroupElement;
			if (_groupElement)
				retFlow.createContentElement();
			return retFlow;
		}

		/** @private */
		override tlf_internal function createContentElement():void
		{
			if (_groupElement)
				return;
				
			_groupElement = new GroupElement(null);
			CONFIG::debug { Debugging.traceFTECall(_groupElement,null,"new GroupElement",null); }  
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:FlowElement = getChildAt(i);
				child.createContentElement();
			}			
			if (parent)
				parent.insertBlockElement(this, _groupElement);
		}
		
		/** @private */
		override tlf_internal function releaseContentElement():void
		{
			if (!canReleaseContentElement() || groupElement == null)
				return;
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:FlowElement = getChildAt(i);
				child.releaseContentElement();
			}			
			_groupElement = null;
		}
		
		/** @private */
		override tlf_internal function canReleaseContentElement():Boolean
		{
			return _attachedListenerStatus == NO_ATTACHED_LISTENERS;
		}
		
		/**
		 * @public getter to return the precedence value of this SubParagraphGroupElement
		 * Precedence is used to determine which SPGE element will be the container element
		 * when two or more SPGEs of the same textLength are inside one another.
		 * 
		 * Precedence is used to determine which SubParagraphGroupElement is the owner when two or 
		 * more elements have the same text and are embedded within each other.
		 * 
		 * Example: SPGEs A(precedence 900), B(precedence 400), C(precedence 600)
		 * Model Result when all wrap SpanElement "123"
		 * 
		 * <A><C><B>123</B></C></A>
		 * 
		 * If two or more SPGE's have the same precedence value, then the alphabetic order is used:
		 * Example: SPGE A(precedence 400), B(precedence 400), C(precedence 600)
		 * 
		 * <C><A><B>123</B></A></C>
		 * 
		 * Current values for SubParagraphGroupElements are:
		 * 	LinkElement - 800
		 * 	TCYElement - 100
		 * 
		 * If the value is not overriden by descendents of SPGE, then value is kMaxSPGEPrecedence;
		 * @private
		 */
		tlf_internal function get precedence():uint { return kMaxSPGEPrecedence; }
		
		 
		/** @private */
		tlf_internal function get groupElement():GroupElement
		{ return _groupElement; }
		
		/** @private */
		tlf_internal function get attachedListenerStatus():int
		{ return _attachedListenerStatus; }
		
		/** @private */
		tlf_internal override function createContentAsGroup():GroupElement
		{
			return groupElement;
		}
		/** @private */
		tlf_internal override function removeBlockElement(child:FlowElement, block:ContentElement):void
		{
			var idx:int = this.getChildIndex(child);
			groupElement.replaceElements(idx,idx+1,null);

		}
		
		/** @private */
		tlf_internal override function insertBlockElement(child:FlowElement, block:ContentElement):void
		{
			if (groupElement)
			{
				var idx:int = this.getChildIndex(child);
				var gc:Vector.<ContentElement> = new Vector.<ContentElement>();
				gc.push(block);
				groupElement.replaceElements(idx,idx,gc);
			}
			else
			{
				child.releaseContentElement();
				
				var para:ParagraphElement = getParagraph();
				if (para)
					para.createTextBlock();
			}
		}
		

		/** @private */
		tlf_internal override function hasBlockElement():Boolean
		{
			return groupElement != null;
		}
		
		/** @private */
		override tlf_internal function setParentAndRelativeStart(newParent:FlowGroupElement,newStart:int):void
		{
			if (newParent == parent)
				return;
		
			// remove textElement from the parent content
			if (parent && parent.hasBlockElement() && groupElement)
				parent.removeBlockElement(this,groupElement);
			if (newParent && !newParent.hasBlockElement() && groupElement)
				newParent.createContentElement();
					
			super.setParentAndRelativeStart(newParent,newStart);
			
			// Update the FTE ContentElement structure. If the parent has FTE elements, then create FTE elements for the leaf node 
			// if it doesn't already have them, and add them in. If the parent does not have FTE elements, release the leaf's FTE
			// elements also so they match.
			if (parent && parent.hasBlockElement())
			{
				if (!groupElement)
					createContentElement();
				else
					parent.insertBlockElement(this,groupElement);
			}
		}
		
		/** @private */
		public override function replaceChildren(beginChildIndex:int,endChildIndex:int,...rest):void
		{
			var p:ParagraphElement = this.getParagraph();
			
			// are we replacing the last element?
			var oldLastLeaf:FlowLeafElement = p ? p.getLastLeaf() : null;
				
			var applyParams:Array = [beginChildIndex, endChildIndex];
			super.replaceChildren.apply(this, applyParams.concat(rest));
			
			if (p)
				p.ensureTerminatorAfterReplace(oldLastLeaf);
		}
		
		 /** @private
		  * Returns the EventDispatcher associated with this SubParagraphGroupElement instance.  Use the functions
		  * of EventDispatcher such as <code>addEventHandler()</code> and <code>removeEventHandler()</code> to 
		  * capture events that happen over this SubParagraphGroupElement instance.  
		  *
		  * The event handling that you specify is called after this element does its processing.
		  *
		  * @playerversion Flash 10
		  * @playerversion AIR 1.5
		  * @langversion 3.0
		  *
		  * @see flash.events.EventDispatcher
		  * @see flash.text.engine.TextLineMirrorRegion
		  */
		  
		tlf_internal function getEventMirror(statusMask:uint = CLIENT_ATTACHED_LISTENERS):EventDispatcher
		{
			if (!_groupElement)
			{
				var para:ParagraphElement = getParagraph();
				if (para)
					para.getTextBlock();
				else
					createContentElement();
			}
			if (_groupElement.eventMirror == null)
			{				
				_groupElement.eventMirror = new EventDispatcher();
			}
			_attachedListenerStatus |= statusMask;
			return (_groupElement.eventMirror);
		}

		/** @private */
		tlf_internal override function normalizeRange(normalizeStart:uint,normalizeEnd:uint):void
		{
			var idx:int = findChildIndexAtPosition(normalizeStart);
			if (idx != -1 && idx < numChildren)
			{
				var child:FlowElement = getChildAt(idx);
				normalizeStart = normalizeStart-child.parentRelativeStart;
				
				CONFIG::debug { assert(normalizeStart >= 0, "bad normalizeStart in normalizeRange"); }
				for (;;)
				{
					// watch out for changes in the length of the child
					var origChildEnd:int = child.parentRelativeStart+child.textLength;
					child.normalizeRange(normalizeStart,normalizeEnd-child.parentRelativeStart);
					var newChildEnd:int = child.parentRelativeStart+child.textLength;
					normalizeEnd += newChildEnd-origChildEnd;	// adjust
					
					// no zero length children
					if (child.textLength == 0 && !child.bindableElement)
						replaceChildren(idx,idx+1);
					else if (child.mergeToPreviousIfPossible())
					{
						var prevElement:FlowElement = this.getChildAt(idx-1);
						// possibly optimize the start to the length of prevelement before the merge
						prevElement.normalizeRange(0,prevElement.textLength);
					}
					else
						idx++;

					if (idx == numChildren)
						break;
					
					// next child
					child = getChildAt(idx);
					
					if (child.parentRelativeStart > normalizeEnd)
						break;
						
					normalizeStart = 0;		// for the next child	
				}
			}
			// empty subparagraphgroups not allowed after normalize
			if (numChildren == 0 && parent != null)
			{
				var s:SpanElement = new SpanElement();
				replaceChildren(0,0,s);
				s.normalizeRange(0,s.textLength);
			}
		}

		/** @private */
		tlf_internal override function canOwnFlowElement(elem:FlowElement):Boolean
		{
			// Only allow sub-paragraph group elements (with restrictions) and leaf elements 
			if (elem is FlowLeafElement)
				return true;
			
			var subParagraphGroupElem:SubParagraphGroupElement = elem as SubParagraphGroupElement;
			if (subParagraphGroupElem)
			{ 
				// Sub-paragraph group elements of the same kind cannot nest, even indirectly.
				// For example, a link cannot contain a link, nor can it contain a TCY whose child is a link and so on.				
				// We assume that the two trees being joined are themselves valid, so the above rule can only be violated if
				// a) elem's type is same as my type
				// b) elem's type is same as my parent's type
				// c) an elem's child's type is same as my type
				// [Note: this is valid only because we have just two kinds of sub-paragraph groups. Any more, and we'll need more
				// complex rules]  

				var myClass:String = getQualifiedClassName(this);
				var elemClass:String = getQualifiedClassName(elem);
				var parentClass:String = parent ? getQualifiedClassName(parent) : null;
				
				if (elemClass == myClass || elemClass == parentClass)
					return false;
					
				for (var i:int=0; i<subParagraphGroupElem.numChildren; i++)
				{
					if (getQualifiedClassName(subParagraphGroupElem.getChildAt(i)) == myClass)
						return false;
				}
				
				return true;
			}
			
			return false;
		}
		
		/** Helper function for determination of where text should be inserted.  In the case of LinkElements,
		 * text inserted before the LinkElement and text inserted after the LinkElement should not become
		 * par of the link.  However, for most other SubParagraphGroupElements, inserted text should become
		 * part of the SubParagraphGroupElement.
		 * @private
		 * */
		tlf_internal function acceptTextBefore():Boolean 
		{ 
			return true; 
		}
		
		/** Helper function for determination of where text should be inserted.  In the case of LinkElements,
		 * text inserted before the LinkElement and text inserted after the LinkElement should not become
		 * par of the link.  However, for most other SubParagraphGroupElements, inserted text should become
		 * part of the SubParagraphGroupElement.
		 * @private
		 * */
		tlf_internal function acceptTextAfter():Boolean
		{
			return true;
		}
		
		/** @private */
		CONFIG::debug public override function debugCheckFlowElement(depth:int = 0, extraData:String = ""):int
		{
			// debugging function that asserts if the flow element tree is in an invalid state
			var rslt:int = super.debugCheckFlowElement(depth," fte:"+getDebugIdentity(groupElement)+" "+extraData);
			rslt += assert(getParagraph() != null && (parent is ParagraphElement || parent is SubParagraphGroupElement), "SubParagraphGroupElement must be nested in a pargraph");
			
			//groupElement can be null if the Paragraph is overset or not yet composed.  Don't check elementCount - Watson 2283828
			if(this.groupElement)
				rslt += assert(this.groupElement.elementCount == this.numChildren,"Bad element count in SubParagraphGroupElement");
				
			if (parent is ParagraphElement)
				rslt += assert(this.groupElement != ParagraphElement(parent).getTextBlock().content,"Bad group");
			return rslt; 
		}
	}
}
