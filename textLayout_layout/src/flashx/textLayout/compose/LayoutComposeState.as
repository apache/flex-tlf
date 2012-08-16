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
package flashx.textLayout.compose
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.TextBaseline;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.IFloatController;
	import flashx.textLayout.elements.ContainerFormattedElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.tlf_internal;
		
	use namespace tlf_internal;
	
	/** Keeps track of internal state during composition. 
	 * 
	 * This is the advanced layout version, used when there are floats, wraps, or columns.
	 */
	public class LayoutComposeState extends ComposeState 
	{
		// a single ComposeState that is checked out and checked in
		static private var _sharedLayoutComposeState:LayoutComposeState;

		/** @private */
		static tlf_internal function getLayoutComposeState():LayoutComposeState
		{
			var rslt:LayoutComposeState = _sharedLayoutComposeState ? _sharedLayoutComposeState : new LayoutComposeState();
			_sharedLayoutComposeState = null;
			return rslt;
		}
		
		/** @private */
		static tlf_internal function releaseLayoutComposeState(state:ComposeState):void
		{
			if (_sharedLayoutComposeState == null)
				_sharedLayoutComposeState = state as LayoutComposeState;
		}
		
		public function LayoutComposeState()
		{
			super();
		}
		/** @private */
		protected override function createParcelList():IParcelList
		{
			return LayoutParcelList.getLayoutParcelList();

		}
		/** @private */
		protected override function releaseParcelList(list:IParcelList):void
		{
			LayoutParcelList.releaseLayoutParcelList(list);
		}
		
		// Debugging code to show parcel edges - requires removing graphics.clear from ContainerControllerBase
	/*	CONFIG::debug override public function composeTextFlow(textFlow:TextFlow):int
		{
			var value:int = super.composeTextFlow(textFlow);
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			if (controller)
			{
				var container:Sprite = textFlow.flowComposer.getControllerAt(0).container as Sprite;
				var graphics:Graphics = container.graphics;
				graphics.clear();
				graphics.lineStyle(1, 0xFF0000);
				var boundsArray:Array = LayoutParcelList(_parcelList).getBounds();
				for (var i:int = 0; i < boundsArray.length; ++i)
				{
					var bounds:Rectangle = boundsArray[i] as Rectangle;
					graphics.moveTo(bounds.x, bounds.y);
					graphics.lineTo(bounds.right, bounds.y);
					graphics.lineTo(bounds.right, bounds.bottom);
					graphics.lineTo(bounds.left, bounds.bottom);
					graphics.lineTo(bounds.left, bounds.top);
				}
			}
			
			return value;
		} */
		
		/* @private */
		override protected function parcelHasChanged(newParcel:Parcel):void
		{
			if (_curParcel && newParcel && _curParcel.controller == newParcel.controller && _curParcel.column == newParcel.column)
				vjDisableThisParcel = true;
			super.parcelHasChanged(newParcel);
		}
		
		/* @private */
		protected override function composeFloat(elem:ContainerFormattedElement,composeFrame:ContainerController):void
		{
			elem.createGeometry(null);
			// TODO: support arbitrary containers?
			var floatContainer:DisplayObjectContainer = ContainerFormattedElement(elem).flowComposer.getControllerAt(0).container as DisplayObjectContainer;
			// var floatContainer:DisplayObjectContainer = ContainerFormattedElement(elem).container as DisplayObjectContainer;
			if (floatContainer != null) // is inline
			{
				if (!(composeFrame is IFloatController))
					throw("need a float layout-capable controller!");
				// Add as an inline, figure out the size of the inline, wrap around the inline
				var parcelRect:Rectangle = IFloatController(composeFrame).computeInlineArea(floatContainer);

				// See if it fits. If so, update the state to show the change. If not, remove the item.
				if (parcelList.createParcel(parcelRect, elem.computedFormat.blockProgression, true /* next text goes below */))
				{
					floatContainer.x = parcelList.left;
					floatContainer.y = parcelList.top;
					floatContainer.height = parcelRect.height;
					IFloatController(parcelList.controller).recordInlineChild(floatContainer);

					//_contentAlignmentWidth = Math.max(_contentAlignmentWidth, parcelList.right);
					parcelList.addTotalDepth(parcelRect.height);
					parcelList.next();		 // advance to next parcel
				}
			}
			
			_curLineIndex = composeFrame.rootElement.getTextFlow().flowComposer.findLineIndexAtPosition(elem.getAbsoluteStart() + elem.textLength);
			vjDisableThisParcel = true;
			vjBeginLineIndex = _curLineIndex;
		}

		/*
		 * Compose a floating graphic
		 * 
		 * @param elem	float we'e composing
		 */
		protected function composeFloatInline(elem:InlineGraphicElement):void
		{
			if (elem.elementHeight == 0 || elem.elementWidth == 0)		// can't compose yet -- graphic isn't ready
				return;
			
			var containerElement:ContainerFormattedElement = elem.getAncestorWithContainer();
			var blockProgression:String = containerElement.computedFormat.blockProgression;
			
		// HACK!!!
		//	if the baselineZero is set to ideographicTop, then the descent is the point size (measured from ideographic top)
		//	but in this case we've already factored that into the line height, so we're adding twice. Very confusing.
			var effectiveLastLineDescent:Number = 0;
			if (!isNaN(_lastLineDescent))
				effectiveLastLineDescent = _lastLineDescent;
			
			var floatRect:Rectangle = new Rectangle(parcelList.left, parcelList.top, elem.elementWidth, elem.elementHeight);
			if (blockProgression == BlockProgression.RL)
			{				
				floatRect.left -= effectiveLastLineDescent;
				if (elem.float == Float.RIGHT)
					floatRect.offset(0, (parcelList.bottom - elem.elementHeight) - floatRect.y);
			}
			else
			{				
				floatRect.bottom += effectiveLastLineDescent;
				if (elem.float == Float.RIGHT)
					floatRect.offset((parcelList.right - elem.elementWidth) - floatRect.x, 0);
			}
				
			// See if it fits. If so, update the state to show the change. If not, remove the item.
			if (parcelList.createParcelExperimental(floatRect, elem.float == Float.RIGHT ? "left" : "right"))
			{
				var graphic:DisplayObject = elem.graphic;
				if (graphic)
				{
					IFloatController(parcelList.controller).recordInlineChild(graphic);
					graphic.x = parcelList.left;
					graphic.y = parcelList.top;
					if (blockProgression == BlockProgression.TB)
						graphic.y += effectiveLastLineDescent;
				}

				if (blockProgression == BlockProgression.TB)
				{
					parcelList.addTotalDepth(floatRect.height);
					//_contentAlignmentWidth = Math.max(_contentAlignmentWidth, floatRect.width);
					
				}
				else
				{
					parcelList.addTotalDepth(floatRect.width);
					//_contentAlignmentWidth = Math.max(_contentAlignmentWidth, floatRect.height);					
				}
				parcelList.next();		 // advance to next parcel
			}
			
		//	_curLineIndex = _curParcel.controller.rootElement.getTextFlow().getAbsoluteLineIndex(elem.getAbsoluteStart() + elem.textLength);
			vjDisableThisParcel = true;
		//	vjBeginLineIndex = _curLineIndex;
		}
		
		// Called from composeParagraphElement when we are starting to compose a line. Has hooks to handle floats.
		protected override function startLine():void
		{
			// Compose floats that appear at the start of the line, before processing any text. That way the following text will
			// wrap correctly
			if (_curElement is InlineGraphicElement && InlineGraphicElement(_curElement).float != Float.NONE)
			{
				var graphic:InlineGraphicElement = InlineGraphicElement(_curElement);
				while (graphic && graphic.float != Float.NONE)
				{
					composeFloatInline(graphic);
					graphic = graphic.getNextLeaf() as InlineGraphicElement;
				}
			}
		}

		// Called from composeParagraphElement when we are starting to compose a line. Has hooks to handle floats.
		protected override function endLine():void
		{
			var currentOffset:int = _curElementOffset;
			var currentElementStart:int = _curElementStart;
			var element:FlowLeafElement = _curElement;
			
			// advance to the next element, using the rootElement of the container as a limitNode
			// to prevent going past the content bound to this container
			if (currentOffset >= element.textLength)
			{
				// We may have composed ahead over several spans; skip until we match up
				// Loop until we use catch up to where the line we just composed ended (pos).
				// Stop if we run out of elements. Skip empty inline elements, and skip floats
				// that came at the start of the line before any text -- they've already been 
				// processed.
				var firstTextSpan:Boolean = true;
				do{
					if (element is InlineGraphicElement && InlineGraphicElement(element).float != Float.NONE)
					{
						if (!firstTextSpan)
							composeFloatInline(element as InlineGraphicElement);
					}
					else firstTextSpan = false;
					currentOffset -= element.textLength;
					currentElementStart  += _curElement.textLength;
					if (currentElementStart == _curParaStart+_curParaElement.textLength)
					{
						break;		// reached end of paragraph
					}
					element = element.getNextLeaf();
				} while (element != null && (currentOffset >= element.textLength || element.textLength == 0 ));
			}
		}

	}
}
