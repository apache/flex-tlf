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
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.text.engine.ContentElement;
	import flash.text.engine.GroupElement;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.events.FlowElementEventDispatcher;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	/** 
	 * The SubParagraphGroupElementBase class groups FlowLeafElements together. A SubParagraphGroupElementBase is a child of a 
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
	 
	public class SubParagraphGroupElementBase extends FlowGroupElement
	{
		private var _groupElement:GroupElement;
		
		/** Maximum precedence value @private */
		tlf_internal static const kMaxSPGEPrecedence:uint = 1000;
		/** Minimum precedence value @private */
		tlf_internal static const kMinSPGEPrecedence:uint = 0;
		
		/** @private the event dispatcher that acts as an event mirror */
		tlf_internal var _eventMirror:FlowElementEventDispatcher = null;

		/** Constructor - creates a new SubParagraphGroupElementBase instance.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		 
		public function SubParagraphGroupElementBase()
		{ super(); }

		/** @private */
		override tlf_internal function createContentElement():void
		{
			if (_groupElement)
				return;
				
			computedFormat;	// BEFORE creating the element
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
			if (_groupElement == null)
				return;
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:FlowElement = getChildAt(i);
				child.releaseContentElement();
			}			
			_groupElement = null;
			_computedFormat = null;
		}
		
		/**
		 * @public getter to return the precedence value of this SubParagraphGroupElementBase
		 * Precedence is used to determine which SPGE element will be the container element
		 * when two or more SPGEs of the same textLength are inside one another.
		 * 
		 * Precedence is used to determine which SubParagraphGroupElementBase is the owner when two or 
		 * more elements have the same text and are embedded within each other.
		 * 
		 * Note: model permits any order and does not enforce precedence.  This is only a feature used by the EditManager
		 * 
		 * Example: SPGEs A(precedence 900), B(precedence 400), C(precedence 600)
		 * Editing Result when all wrap SpanElement "123"
		 * 
		 * <A><C><B>123</B></C></A>
		 * 
		 * If two or more SPGE's have the same precedence value, then the alphabetic order is used:
		 * Example: SPGE A(precedence 400), B(precedence 400), C(precedence 600)
		 * 
		 * <C><A><B>123</B></A></C>
		 * 
		 * Current values for SubParagraphGroupElementBase are:
		 * 	LinkElement - 800
		 * 	TCYElement - 100
		 * 
		 * If the value is not overriden by descendents of SPGE, then value is kMaxSPGEPrecedence;
		 * @private
		 */
		tlf_internal function get precedence():uint 
		{ return kMaxSPGEPrecedence; }
		
		 
		/** @private */
		tlf_internal function get groupElement():GroupElement
		{ return _groupElement; }
		
		/** @private
		 * Gets the EventDispatcher associated with this FlowElement.  Use the functions
		 * of EventDispatcher such as <code>setEventHandler()</code> and <code>removeEventHandler()</code> 
		 * to capture events that happen over this FlowLeafElement object.  The
		 * event handler that you specify will be called after this FlowElement object does
		 * the processing it needs to do.
		 * 
		 * Note that the event dispatcher will only dispatch FlowElementMouseEvent events.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see flash.events.EventDispatcher
		 * @see flashx.textLayout.events.FlowElementMouseEvent
		 */
		tlf_internal override function getEventMirror():IEventDispatcher
		{
			if (!_eventMirror)
				_eventMirror = new FlowElementEventDispatcher(this);
			return _eventMirror;
		}
		
		/** @private
		 * Checks whether an event dispatcher is attached, and if so, if the event dispatcher
		 * has any active listeners.
		 */
		tlf_internal override function hasActiveEventMirror():Boolean
		{ return _eventMirror && (_eventMirror._listenerCount != 0); }
		
		
		/** @private This is done so that the TextContainerManager can discover EventMirrors in a TextFlow. */
		tlf_internal override function appendElementsForDelayedUpdate(tf:TextFlow,changeType:String):void
		{ 
			if (changeType == ModelChange.ELEMENT_ADDED)
			{
				if (this.hasActiveEventMirror())
				{
					tf.incInteractiveObjectCount();
					getParagraph().incInteractiveChildrenCount() ;
				}
			}
			else if (changeType == ModelChange.ELEMENT_REMOVAL)
			{
				if (this.hasActiveEventMirror())
				{
					tf.decInteractiveObjectCount();
					getParagraph().decInteractiveChildrenCount() ;
				}
			}
			super.appendElementsForDelayedUpdate(tf,changeType);
		}
		
		/** @private */
		tlf_internal override function createContentAsGroup():GroupElement
		{ return groupElement; }

		/** @private */
		tlf_internal override function removeBlockElement(child:FlowElement, block:ContentElement):void
		{
			var idx:int = this.getChildIndex(child);
			groupElement.replaceElements(idx,idx+1,null);
			CONFIG::debug { Debugging.traceFTECall(null,groupElement,"replaceElements",idx,idx+1,null); }
		}
		
		/** @private */
		tlf_internal override function insertBlockElement(child:FlowElement, block:ContentElement):void
		{
			if (groupElement)
			{
				var idx:int = this.getChildIndex(child);
				var gc:Vector.<ContentElement> = new Vector.<ContentElement>();
				CONFIG::debug { Debugging.traceFTECall(gc,null,"new Vector.<ContentElement>()") }
				gc.push(block);
				CONFIG::debug { Debugging.traceFTECall(null,gc,"push",block); }
				groupElement.replaceElements(idx,idx,gc);
				CONFIG::debug { Debugging.traceFTECall(null,groupElement,"replaceElements",idx,idx,gc); }
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
		{ return groupElement != null; }
		
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
				
			var applyParams:Array = [beginChildIndex, endChildIndex];
			super.replaceChildren.apply(this, applyParams.concat(rest));
			
			var p:ParagraphElement = this.getParagraph();
			if (p)
				p.ensureTerminatorAfterReplace();
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

		/** @private 
		 * SubParagraphGroupElement allow deep nesting, but LinkElements and TCYElements do not allow nesting (you can't have a link inside another
		 * link no matter how many group elements are in between). This function is called only from within the class hierarchy to find out whether 
		 * a sub-class allows nesting or not. */
		tlf_internal function get allowNesting():Boolean
		{
			return false;
		}
		
		/** A LinkElement cannot be nested in another LinkElement, regardless of what elements are in between in the hierarchy.
		 * Likewise a TCYElemen may not be nested. This function checks an incoming element to see if any of its children would
		 * be disallowed if added to this. */
		private function checkForNesting(element:SubParagraphGroupElementBase):Boolean
		{
			if (element)
			{
				if (!element.allowNesting)
				{
					var elementClass:Class = getDefinitionByName(getQualifiedClassName(element)) as Class;
					if (this is elementClass || this.getParentByType(elementClass))
						return false;
				}
				for (var i:int = element.numChildren - 1; i >= 0; --i)
					if (!checkForNesting(element.getChildAt(i) as SubParagraphGroupElementBase))
						return false;
			}
			return true;
		}
		
		/** @private */
		tlf_internal override function canOwnFlowElement(elem:FlowElement):Boolean
		{
			// Only allow sub-paragraph group elements (with restrictions) and leaf elements 
			if (elem is FlowLeafElement)
				return true;
			
			if (elem is SubParagraphGroupElementBase && checkForNesting(elem as SubParagraphGroupElementBase))
				return true;
			
			return false;
		}
		
		/** Helper function for determination of where text should be inserted.  In the case of LinkElements,
		 * text inserted before the LinkElement and text inserted after the LinkElement should not become
		 * par of the link.  However, for most other SubParagraphGroupElementBase, inserted text should become
		 * part of the SubParagraphGroupElementBase.
		 * @private
		 * */
		tlf_internal function acceptTextBefore():Boolean 
		{ return true; }
		
		/** Helper function for determination of where text should be inserted.  In the case of LinkElements,
		 * text inserted before the LinkElement and text inserted after the LinkElement should not become
		 * par of the link.  However, for most other SubParagraphGroupElementBase, inserted text should become
		 * part of the SubParagraphGroupElementBase.
		 * @private
		 * */
		tlf_internal function acceptTextAfter():Boolean
		{ return true; }
		
		/** @private */
		CONFIG::debug public override function debugCheckFlowElement(depth:int = 0, extraData:String = ""):int
		{
			// debugging function that asserts if the flow element tree is in an invalid state
			var rslt:int = super.debugCheckFlowElement(depth," fte:"+getDebugIdentity(groupElement)+" "+extraData);
			rslt += assert(getParagraph() != null && (parent is ParagraphElement || parent is SubParagraphGroupElementBase), "SubParagraphGroupElementBase must be nested in a pargraph");
			
			//groupElement can be null if the Paragraph is overset or not yet composed.  Don't check elementCount - Watson 2283828
			if(this.groupElement)
				rslt += assert(this.groupElement.elementCount == this.numChildren,"Bad element count in SubParagraphGroupElementBase");
				
			if (parent is ParagraphElement)
				rslt += assert(this.groupElement != ParagraphElement(parent).getTextBlock().content,"Bad group");
			return rslt; 
		}
	}
}
