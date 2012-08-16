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
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.*;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineMirrorRegion;
	import flash.text.engine.TextLineValidity;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.edit.EditingMode;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormatValueHolder;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
			
	/** 
	 * Dispatched when the mouse is pressed down over a link.
	 * @eventType flashx.textLayout.events.FlowElementMouseEvent.MOUSE_DOWN
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	[Event(name="mouseDown", type="flashx.textLayout.events.FlowElementMouseEvent")]
	
	/** 
	 * Dispatched when the mouse is released over a link. 
	 * @eventType flashx.textLayout.events.FlowElementMouseEvent.MOUSE_UP
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
 	 */
	[Event(name="mouseUp", type="flashx.textLayout.events.FlowElementMouseEvent")]	
	/** 
	 * Dispatched when the mouse passes over the link. 
	 * @eventType flashx.textLayout.events.FlowElementMouseEvent.MOUSE_MOVE
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
	 */
	[Event(name="mouseMove", type="flashx.textLayout.events.FlowElementMouseEvent")]	
	/**
	 * Dispatched when the mouse first enters the link. 
	 * @eventType flashx.textLayout.events.FlowElementMouseEvent.ROLL_OVER
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
	 */			
	[Event(name="rollOver", type="flashx.textLayout.events.FlowElementMouseEvent")]
	/** 
	 * Dispatched when the mouse goes out of the link. 
	 * @eventType flashx.textLayout.events.FlowElementMouseEvent.ROLL_OUT
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
	 */
	[Event(name="rollOut", type="flashx.textLayout.events.FlowElementMouseEvent")]	
	/** 
	 * Dispatched when the link is clicked. 
	 * Clients may override how the link handles the event by handling it themselves, and calling preventDefault().
	 * @eventType flashx.textLayout.events.FlowElementMouseEvent.CLICK
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
	 */	
	[Event(name="click", type="flashx.textLayout.events.FlowElementMouseEvent")]

	/** The LinkElement class defines a link to a URI (Universal Resource Identifier), which is executed when the user clicks it.
	 * The LinkElement class is a subclass of the SubParagraphGroupElement class and it can contain
	 * one or more FlowElement objects, such as a SpanElement object that stores the link text. An empty
	 * LinkElement, which does not contain a FlowElement object, is ignored.
	 * <p>If you specify a target, it must be one of the following values:
	 * <table class="innertable" width="100%">
	 * <tr>
	 *   <th>Target value</th> 
	 *   <th>description</th>
	 * </tr>
	 * <tr>
	 *   <td>_self</td>
	 *   <td>Replaces the current HTML page. If it is in a frame or frameset, it will load within that frame. If it is
	 *       the full browser, it opens to replace the page from which it came.</td>
	 * </tr>
	 * <tr>
	 *   <td>_blank</td>
	 *   <td>Opens a new browser name with no name.</td>
	 * </tr>
	 * <tr>
	 *   <td>_parent</td>
	 *   <td>Replaces the HTML page from which it came.</td>
	 * </tr>
	 * <tr>
	 *   <td>_top</td>
	 *   <td>Loads in the current browser, replacing anything within it, such as a frameset.</td>
	 * </tr>
	 * </table>
	 * </p>
	 *
	 * @includeExample examples\LinkElementExample.as -noswf
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 * @see LinkState
	 * @see FlowElement#linkActiveFormat FlowElement.linkActiveFormat
	 * @see FlowElement#linkHoverFormat FlowElement.linkHoverFormat
	 * @see FlowElement#linkNormalFormat FlowElement.linkNormalFormat
	 * @see TextFlow
	 *
	 */ 
	 
	public final class LinkElement extends SubParagraphGroupElement implements IEventDispatcher
	{
		private var _uriString:String;
		private var _targetString:String;
		private var _linkState:String;
		private var _ignoreNextMouseOut:Boolean = false;
		private var _mouseInLink:Boolean = false;
		private var _isSelecting:Boolean = false;
		private var _keyEventsAdded:Boolean = false;
		private var eventDispatcher:EventDispatcher;
		private var _mouseDownInLink:Boolean = false;

		private static var _mouseInLinkElement:LinkElement;
		
		/** Constructor - creates a new LinkElement instance.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		public function LinkElement()
		{
			super();
			
           eventDispatcher = new EventDispatcher();
            _linkState = LinkState.LINK;
            _mouseDownInLink = false;
            _isSelecting = false;
        }
        
		/** @private */
		override tlf_internal function createContentElement():void
		{
			super.createContentElement();
			
			var eventMirror:EventDispatcher = getEventMirror(SubParagraphGroupElement.INTERNAL_ATTACHED_LISTENERS);
 			eventMirror.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			eventMirror.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
			eventMirror.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true);
			eventMirror.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true);
			eventMirror.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
		}
		
		/** @private */
        tlf_internal override function get precedence():uint { return 800; }
        
		/**
		* @param type The type of event.
		* @param listener The listener function that processes the event. This function must accept an event object 
		* as its only parameter and must return nothing, as this example shows:
		* <p><code>function(evt:Event):void</code></p>
		* The function can have any name.
		* @param useCapture Determines whether the listener works in the capture phase or the target 
		* and bubbling phases. If <code>useCapture</code> is set to <code>true</code>, the  
		* listener processes the event only during the capture phase and not in the target or 
		* bubbling phase. If <code>useCapture</code> is <code>false</code>, the listener processes the event only
		* during the target or bubbling phase. To listen for the event in all three phases, call 
		* <code>addEventListener()</code> twice, once with <code>useCapture</code> set to <code>true</code>, 
		* then again with <code>useCapture</code> set to <code>false</code>.
		* @param priority The priority level of the event listener. Priorities are designated by a 32-bit integer. The higher the number, the higher the priority. All listeners with priority <em>n</em> are processed before listeners of priority <em>n-1</em>. If two or more listeners share the same priority, they are processed in the order in which they were added. The default priority is 0. 
		* @param useWeakReference Determines whether the reference to the listener is strong or weak. A strong 
		* reference (the default) prevents your listener from being garbage-collected. A weak 
		* reference does not. <p>Class-level member functions are not subject to garbage 
		* collection, so you can set <code>useWeakReference</code> to <code>true</code> for 
		* class-level member functions without subjecting them to garbage collection. If you set
		* <code>useWeakReference</code> to <code>true</code> for a listener that is a nested inner 
		* function, the function will be garbge-collected and no longer persistent. If you create 
		* references to the inner function (save it in another variable) then it is not 
		* garbage-collected and stays persistent.</p>
		*
		* @copy flash.events.IEventDispatcher#addEventListener()
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
		* @langversion 3.0
		*/
 		 
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false): void
		{
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		/**
		 * @copy flash.events.IEventDispatcher#dispatchEvent()
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
 		 */
 		 
		public function dispatchEvent(evt:Event):Boolean
		{
			return eventDispatcher.dispatchEvent(evt);
		}
		
		/**
		 * @copy flash.events.IEventDispatcher#hasEventListener()
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
 		 */
 		 
		public function hasEventListener(type:String):Boolean
		{
			return eventDispatcher.hasEventListener(type);
		}
		
		/**
		 *
		 * @param type The type of event.
		 * @param listener The listener object to remove.
		 * @param useCapture Specifies whether the listener was registered for the capture phase or the target and bubbling phases. If the listener was registered for both the capture phase and the target and bubbling phases, two calls to <code>removeEventListener()</code> are required to remove both: one call with <code>useCapture</code> set to <code>true</code>, and another call with <code>useCapture</code> set to <code>false</code>. 
		 *
		 * @copy flash.events.IEventDispatcher#removeEventListener().
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
 		 */
 		 
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false): void
		{
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}

		/**
		 * @copy flash.events.IEventDispatcher#willTrigger()
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
 		 */
 		 
		public function willTrigger(type:String):Boolean
		{
			return eventDispatcher.willTrigger(type);
		}
		// end of IEventDispatcher functions
		
		/** @private */
		override protected function get abstract():Boolean
		{
			return false;
		}		
		
		
		/**
		 * The Uniform Resource Identifier (URI) associated with the LinkElement object.  The URI can be any URI 
		 * supported by the <code>flash.net.navigateToURL()</code> method. This property maps
		 * to the <code>request</code> parameter for that method.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see ../../../flash/net/package.html#navigateToURL() flash.net.navigateToURL()
		 */
		 
		public function get href():String
		{
			return _uriString;
		}
		 
		public function set href(newUriString:String):void
		{
			_uriString = newUriString;
			modelChanged(ModelChange.ELEMENT_MODIFIED,0,textLength);
		}

		/**
		 * The Target value associated with the LinkElement. Possible values are "_self", "_blank",
		 * "_parent", and "_top". This value maps to the <code>window</code> parameter of the
		 * <code>flash.net.navigateToURL()</code> method.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see ../../../flash/net/package.html#navigateToURL() flash.net.navigateToURL()
		 */
		 
		public function get target():String
		{
			return _targetString;
		}
		public function set target(newTargetString:String):void
		{
			_targetString = newTargetString;
			modelChanged(ModelChange.ELEMENT_MODIFIED,0,textLength);
		}

		/**
		 * The current state of the link.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see LinkState
		 */
		 
		public function get linkState():String
		{ return _linkState; }
		
		/** @private */
		 public override function shallowCopy(startPos:int = 0, endPos:int = -1):FlowElement
		{
			if (endPos == -1)
				endPos = textLength;
				
			var retFlow:LinkElement = super.shallowCopy(startPos, endPos) as LinkElement;
			retFlow.href = href;
			retFlow.target = target;
			return retFlow;
		}
		
		/** @private */
		tlf_internal override function mergeToPreviousIfPossible():Boolean
		{		
			// in links the eventMirror exists.  TLF ignores that when merging.  The risk is that everything matches but the user has added a custom listener to the eventMirror.
			var theParent:FlowGroupElement = parent;
			if (theParent && !bindableElement)
			{
				var myidx:int = theParent.getChildIndex(this);
				if (textLength == 0)
				{
					theParent.replaceChildren(myidx, myidx + 1, null);
					return true;
				}
				
				if (myidx != 0 && (attachedListenerStatus & SubParagraphGroupElement.CLIENT_ATTACHED_LISTENERS) == 0)
				{
					var sib:LinkElement = theParent.getChildAt(myidx-1) as LinkElement;
					if (sib != null && (sib.attachedListenerStatus & SubParagraphGroupElement.CLIENT_ATTACHED_LISTENERS) == 0)
					{
						if ((this.href == sib.href) && (this.target == sib.target) && equalStylesForMerge(sib))
						{
							var curFlowElement:FlowElement = null;
				   
							if (numChildren > 0)
							{
								while (numChildren > 0)
								{
									curFlowElement = getChildAt(0);
									replaceChildren(0, 1);
									sib.replaceChildren(sib.numChildren, sib.numChildren, curFlowElement);
								}
							}
							theParent.replaceChildren(myidx, myidx + 1, null);											
							return true;
						}
					}
				}
			} 
			return false;
		}
		
		/** 
		 * Specifies the name of the text format element of a LinkElement when the link is in the normal state.
		 * @private
		 * @playerversion Flash 10
	 	 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		static tlf_internal const LINK_NORMAL_FORMAT_NAME:String = "linkNormalFormat";
		
		/** 
		 * Specifies the name of the text format element of a LinkElement when the link is in the active state. 
		 * @private
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
	 	 */
		static tlf_internal const LINK_ACTIVE_FORMAT_NAME:String = "linkActiveFormat";
		
		/** Specifies the name of the text format element of a LinkElement when the cursor is hovering over the link. 
		 * @private
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
	 	 */
		static tlf_internal const LINK_HOVER_FORMAT_NAME:String  = "linkHoverFormat";
		
		private function computeLinkFormat(formatName:String):ITextLayoutFormat
		{
			var linkStyle:Object = getStyle(formatName);
			if (linkStyle == null)
			{
				var tf:TextFlow = getTextFlow();
				var formatStr:String = formatName.substr(1);
				return tf == null ? null : tf.configuration["defaultL" + formatStr];
			}
			else if (linkStyle is ITextLayoutFormat)
				return ITextLayoutFormat(linkStyle);
		
			// We need to convert the linkStyle object into a ITextLayoutFormat object		
			var ca:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder;
			var desc:Object = TextLayoutFormat.description;
			for (var prop:String in desc)
			{
				if (linkStyle[prop] != undefined)
					ca[prop] = linkStyle[prop];
			}
			return ca;
		}
		/** 
		 * The state-dependent character attributes for the link.
		 * @private
		 */
		
		tlf_internal function get effectiveLinkElementTextLayoutFormat():ITextLayoutFormat
		{	
			var cf:ITextLayoutFormat;
			if (_linkState == LinkState.ACTIVE)
			{
				cf = computeLinkFormat(LINK_ACTIVE_FORMAT_NAME);
				if (cf)
					return cf;
			}
			if (_linkState == LinkState.HOVER)
			{
				cf = computeLinkFormat(LINK_HOVER_FORMAT_NAME);
				if (cf)
					return cf;
			}

			return computeLinkFormat(LINK_NORMAL_FORMAT_NAME);
		}
		
		/** @private */
		tlf_internal override function get formatForCascade():ITextLayoutFormat
		{
			var superFormat:ITextLayoutFormat = format;
			var effectiveFormat:ITextLayoutFormat = effectiveLinkElementTextLayoutFormat;
			if (effectiveFormat || superFormat)
			{
				if (effectiveFormat && superFormat)
				{
					var resultingTextLayoutFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder(effectiveFormat);
					if (superFormat)
						resultingTextLayoutFormat.concatInheritOnly(superFormat);
					return resultingTextLayoutFormat;
				}
				return superFormat ? superFormat : effectiveFormat;
			}
			return null;
		}
		
		/** @private */
		CONFIG::debug tlf_internal override function setParentAndRelativeStart(newParent:FlowGroupElement,newStart:int):void
		{
			
			if (groupElement)
			{
				var groupTextLength:int = groupElement.rawText ? groupElement.rawText.length : null;
				assert(groupTextLength == this.textLength, "LinkElement - gc = " + this.groupElement.rawText + " this.textLength = " + this.textLength);
			}
			
			super.setParentAndRelativeStart(newParent,newStart);
				
		}
		
		private function redrawLink(ignoreNextMouseOut:Boolean=true):void
		{
			parent.formatChanged(true);
			var tf:TextFlow = getTextFlow();
			if (tf && tf.flowComposer)
			{
				tf.flowComposer.updateAllControllers();
				if (_linkState != LinkState.HOVER) 
					_ignoreNextMouseOut = ignoreNextMouseOut;
			}
		}
		
		private function setToState(linkState:String, ignoreNextMouseOut:Boolean=true):void
		{
			if (_linkState != linkState)
			{
				var oldCharAttrs:ITextLayoutFormat = effectiveLinkElementTextLayoutFormat;
				_linkState = linkState;
				var newCharAttrs:ITextLayoutFormat = effectiveLinkElementTextLayoutFormat;
				if (!(TextLayoutFormat.isEqual(oldCharAttrs, newCharAttrs)))
				{
					redrawLink(ignoreNextMouseOut);
				}		
			}
		}				
		
		private function setHandCursor(state:Boolean=true):void
		{
			var tf:TextFlow = getTextFlow();
			if (tf != null && tf.flowComposer && tf.flowComposer.numControllers)
			{
				doToAllControllers(setContainerHandCursor);
				if (state)
					Mouse.cursor = MouseCursor.AUTO;
				else
				{
					var wmode:String = tf.computedFormat.blockProgression;									
					if (tf.interactionManager && (wmode != BlockProgression.RL))
						Mouse.cursor = MouseCursor.IBEAM;
					else
						Mouse.cursor = MouseCursor.AUTO;
				}
			}
			function setContainerHandCursor(controller:ContainerController):void
			{
				var container:Sprite = controller.container as Sprite;
				if (container)
				{
					container.buttonMode = state;
					container.useHandCursor = state;
				}
			}
		
		}
		
		private function handleEvent(event:FlowElementMouseEvent):Boolean
		{
			eventDispatcher.dispatchEvent(event);
			if (event.isDefaultPrevented())
				return true;
			var textFlow:TextFlow = getTextFlow();
			if (textFlow)
			{
				textFlow.dispatchEvent(event);
				if (event.isDefaultPrevented())
					return true;
			}
			return false;
		}
		
		private function mouseDownHandler(evt:MouseEvent):void
		{
			CONFIG::debug { assert(getTextFlow() != null,"Invalid TextFlow"); }

			if ((evt.ctrlKey) || (getTextFlow().interactionManager == null) || (getTextFlow().interactionManager.editingMode == EditingMode.READ_SELECT))
			{									
				if (_mouseInLink)
				{
					_mouseDownInLink = true;					
					var event:FlowElementMouseEvent = new FlowElementMouseEvent("mouseDown", false, true, this, evt);
					if (handleEvent(event)) return;
					setHandCursor(true);
					setToState(LinkState.ACTIVE, false);
				}
				evt.stopImmediatePropagation();								
			}
			else
			{
				setHandCursor(false);
				setToState(LinkState.LINK);
			}
		}

		private function mouseMoveHandler(evt:MouseEvent):void
		{
			CONFIG::debug { assert(getTextFlow() != null,"Invalid TextFlow"); }
			if (_isSelecting) return;
			if ((evt.ctrlKey) || (getTextFlow().interactionManager == null) || (getTextFlow().interactionManager.editingMode == EditingMode.READ_SELECT))
			{
				if (_mouseInLink)
				{
					var event:FlowElementMouseEvent = new FlowElementMouseEvent("mouseMove", false, true, this, evt);
					if (handleEvent(event)) return;				
					setHandCursor(true);
					if (evt.buttonDown)
					{
						setToState(LinkState.ACTIVE, false);
					}
					else
					{
						setToState(LinkState.HOVER);
					}
				}
			}
			else
			{
				_mouseInLink = true;
				setHandCursor(false);
				setToState(LinkState.LINK);
			}
		}
				
		private function mouseOutHandler(evt:MouseEvent):void
		{
			if (!_ignoreNextMouseOut)
			{
				_mouseInLink = false;
				LinkElement.removeLinkFromMouseInArray(this);							
				_isSelecting = false;
				_mouseDownInLink = false;
				var event:FlowElementMouseEvent = new FlowElementMouseEvent(MouseEvent.ROLL_OUT, false, true, this, evt);
				if (handleEvent(event)) return;				
				setHandCursor(false);
				setToState(LinkState.LINK);
			}
			_ignoreNextMouseOut = false;		
		}
		
		private static function addLinkToMouseInArray(linkEl:LinkElement):void
		{
			CONFIG::debug { assert(_mouseInLinkElement == null, "Multiple links active"); }
			_mouseInLinkElement = linkEl;
			attachContainerEventHandlers(linkEl);
		}
		
		private static function removeLinkFromMouseInArray(linkEl:LinkElement):void
		{
			_mouseInLinkElement = null;
			detachContainerEventHandlers(linkEl);
		}
		
		/** @private */
		// This function is a workaround for Flash Player bug in Astro where mouseOut event is not sent from eventMirror if mouse
		// has left the TextLine at the next sample point (i.e., mouse leaves TextLine rapidly).
		private static function stageMouseMoveHandler(evt:MouseEvent):void
		{
			CONFIG::debug { assert(_mouseInLinkElement != null, "containerMouseMoveHandler shouldn't be active listener now"); }

			 // Check to see if we are still in the link. We could be over an InlineGraphicElement, which could be part of the link.
			 // In that case, we don't want to turn off the link.
			var target:DisplayObject = evt.target as DisplayObject;
			while (target && !(target is TextLine))
				target = target.parent;
			 
			if (target)
			{
				var textLine:TextLine = target as TextLine;
				if (textLine.validity != TextLineValidity.INVALID)
				{
					var mirrorRegions:Vector.<TextLineMirrorRegion> = textLine.mirrorRegions;
					var found:Boolean = false;
					if (mirrorRegions)
					{
						for (var i:int = 0; i < mirrorRegions.length; i++)
						{
							if (_mouseInLinkElement.groupElement == (mirrorRegions[i].element as GroupElement))
								found = true;
						}
					}
					if (!found)
						target = null;
				}
			}
			if (!target)		
			{
				LinkElement.setLinksToDefaultState(evt);
				Mouse.cursor = MouseCursor.AUTO;
			}
		}
		
		/** @private */
		private static function setLinksToDefaultState(evt:MouseEvent, linkEl:LinkElement = null):void
		{
			//FIXME - HBS.  Workaround for bug 1918187.  The problem is that the mouseOut event isn't
			//always sent to the link when the mouse rolls over the link very quickly. So, we simulate
			//the mouseOut when the next mouseMove over something other than a link is sent.  The problem
			//is probably that the mouseOut is being sent before the LinkElement is fully constructed.
			if (_mouseInLinkElement && (linkEl != _mouseInLinkElement))
			{
				var linkElement:LinkElement = _mouseInLinkElement;
				removeLinkFromMouseInArray(linkElement);
				linkElement._mouseInLink = false;
				linkElement._isSelecting = false;
				linkElement._mouseDownInLink = false;
				var mouseMoveEvt:MouseEvent = new MouseEvent(MouseEvent.MOUSE_OUT, evt.bubbles, evt.cancelable, evt.localX, evt.localY, evt.relatedObject, evt.ctrlKey, evt.altKey, evt.shiftKey, evt.buttonDown, evt.delta); 
				var event:FlowElementMouseEvent = new FlowElementMouseEvent(MouseEvent.ROLL_OUT, false, true, linkElement, mouseMoveEvt);
				if (linkElement.handleEvent(event)) return;				
				linkElement.setHandCursor(false);
				linkElement.setToState(LinkState.LINK);
				linkElement._ignoreNextMouseOut = false;
			}
		}
		
		private function doToAllControllers(functionToCall:Function):void
		{
			var textFlow:TextFlow = getTextFlow();
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var start:int = getAbsoluteStart();
			var controllerIndex:int = flowComposer.findControllerIndexAtPosition(start);
			var lastController:int = flowComposer.findControllerIndexAtPosition(start + textLength - 1);
			while (controllerIndex <= lastController)
			{
				functionToCall(flowComposer.getControllerAt(controllerIndex));
				controllerIndex++;
			}
		}
		
		private static function findRootForEventHandlers(linkElement:LinkElement):DisplayObject
		{
			var textFlow:TextFlow = linkElement.getTextFlow();
			if (textFlow)
			{
				var flowComposer:IFlowComposer = textFlow.flowComposer;
				if (flowComposer && flowComposer.numControllers != 0)
					return flowComposer.getControllerAt(0).getContainerRoot();
			}
			return null;
		}
				
		private static function attachContainerEventHandlers(linkElement:LinkElement):void
		{
			var root:DisplayObject = findRootForEventHandlers(linkElement);
			if (root)
				root.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler, false, 0, true);
		}

		private static function detachContainerEventHandlers(linkElement:LinkElement):void
		{
			var root:DisplayObject = findRootForEventHandlers(linkElement);
			if (root)
				root.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
		}
		
		private function mouseOverHandler(evt:MouseEvent):void
		{
			if (_mouseInLink) return;
			CONFIG::debug { assert(getTextFlow() != null,"Invalid TextFlow"); }									
			if (evt.buttonDown) _isSelecting = true;
			if (_isSelecting) return;
			_mouseInLink = true;
			LinkElement.setLinksToDefaultState(evt, this);			
			LinkElement.addLinkToMouseInArray(this);
			
			if ((evt.ctrlKey) || (getTextFlow().interactionManager == null) || (getTextFlow().interactionManager.editingMode == EditingMode.READ_SELECT))
			{
				var event:FlowElementMouseEvent = new FlowElementMouseEvent(MouseEvent.ROLL_OVER, false, true, this, evt);
				if (handleEvent(event)) return;				
				setHandCursor(true);
				if (evt.buttonDown)
				{
					setToState(LinkState.ACTIVE, false);
				}
				else
				{
					setToState(LinkState.HOVER, false);
				}
			}
			else
			{
				setHandCursor(false);
				setToState(LinkState.LINK);
			}
		}
		
		private function mouseUpHandler(evt:MouseEvent):void
		{
			CONFIG::debug { assert(getTextFlow() != null,"Invalid TextFlow"); }
			if (_isSelecting) {_isSelecting = false; return; }												
			if (_mouseInLink && ((evt.ctrlKey) || (getTextFlow().interactionManager == null) || (getTextFlow().interactionManager.editingMode == EditingMode.READ_SELECT)))
			{
				var event:FlowElementMouseEvent = new FlowElementMouseEvent("mouseUp", false, true, this, evt);
				if (!handleEvent(event))				
				{
					setHandCursor(true);				
					setToState(LinkState.HOVER);
					evt.stopImmediatePropagation();
				}
				if (_mouseDownInLink) mouseClickHandler(evt);
			} else {
				setHandCursor(false);
				setToState(LinkState.LINK);
			}
			_mouseDownInLink = false;
		}
		
		private function mouseClickHandler(evt:MouseEvent):void
		{
			CONFIG::debug { assert(getTextFlow() != null,"Invalid TextFlow"); }
			if (_isSelecting) return;
			
			if (((evt.ctrlKey) || (getTextFlow().interactionManager == null) || (getTextFlow().interactionManager.editingMode == EditingMode.READ_SELECT)))
			{															
				if (_mouseInLink)
				{
					var event:FlowElementMouseEvent = new FlowElementMouseEvent("click", false, true, this, evt);
					if (handleEvent(event)) return;
				
					if (_uriString != null)
					{
						if ((_uriString.length > 6) && (_uriString.substr(0, 6) == "event:"))
						{
							event = new FlowElementMouseEvent(_uriString.substring(6, _uriString.length), false, true, this, evt);
							handleEvent(event);
						} else 
						{
		        			var u:URLRequest = new URLRequest(encodeURI(_uriString));
		        			flash.net.navigateToURL(u, target);
		   				}
					}
				}
				evt.stopImmediatePropagation();		
			}			
		}
		
		/** @private */
		tlf_internal override function acceptTextBefore():Boolean 
		{ 
			return false; 
		}
		
		/** @private */
		tlf_internal override function acceptTextAfter():Boolean
		{
			return false;
		}
		
		/** @private */
		/*public override function replaceChildren(beginChildIndex:int,endChildIndex:int,...rest):void
		{
			var applyParams:Array = [beginChildIndex, endChildIndex];
			super.replaceChildren.apply(this, applyParams.concat(rest));
			
			//make sure that all elements of Link recalculate their attributes when
			//something is added to the link.
			
			var len:int = numChildren;
			var i:int = 0;
			var fl:FlowElement;
			while (i < len)
			{
				fl = getChildAtIndex(i);
				fl.formatChanged(true);
				i++;
			}
		}*/
					
		/** @private This is done so that the TextContainerManager can discover LinkElements in a TextFlow. */
		tlf_internal override function appendElementsForDelayedUpdate(tf:TextFlow):void
		{ 
			tf.appendOneElementForUpdate(this);
			super.appendElementsForDelayedUpdate(tf);
		}
		
		/** @private This API supports the inputmanager */
		tlf_internal override function updateForMustUseComposer(textFlow:TextFlow):Boolean
		{ return true; }

	}
}
