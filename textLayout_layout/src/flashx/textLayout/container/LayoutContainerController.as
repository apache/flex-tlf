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
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.LayoutFlowComposer;
	import flashx.textLayout.conversion.LayoutConfiguration;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.ContainerFormattedElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	

	[ExcludeClass]
	/** @private
	 *  A container controller to be used for TextFlows that require extended feature set.
	 */
	public class LayoutContainerController extends ContainerController implements IFloatController
	{
		private var inlineChildren:Array;
		private var lastInlineChildren:Array = []; // inlineChildren during the last compose pass

		private var _wrapList:IWrapManager;
				
		// Composition Results
		private var _numWraps:int;		// number of wraps in this text frame
		
		/** Constructor - creates a new LayoutContainerController instance.
		 *
		 * @param cont The DisplayObjectContainer in which to manage the text lines.
		 * @param compositionWidth The initial width for composing text in the container.
		 * @param compositionHeight The initial height for composing text in the container.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		 
		public function LayoutContainerController(container:Sprite,compositionWidth:Number=100,compositionHeight:Number=100):void
		{
			super(container, compositionWidth, compositionHeight);
		}
		
		public function get wraps():IWrapManager
		{
			return _wrapList;
		}
		
		public function set wraps(wrapsValue:IWrapManager):void
		{
			if (!(flowComposer is LayoutFlowComposer))
				throw new Error("Layout feature set requires LayoutConfiguration");
				
			_wrapList = wrapsValue;
			invalidateContents();
		}

		public function get numWraps():int
		{
			return _numWraps;
		}
		
		public function set numWraps(value:int):void
		{
			_numWraps = value;
		}
			/** @private */
		override tlf_internal function setRootElement(value:ContainerFormattedElement):void
		{
			if (value && wraps != null && !(flowComposer is LayoutFlowComposer))
				throw new Error("Layout feature set requires LayoutConfiguration");
				
			super.setRootElement(value);
		}						

		/** Find the container of the position in the flow */
		//--------------------------------------------------------------------------
		//
		//  Inlines
		//
		//--------------------------------------------------------------------------

		/** inlines */
		private function addInlineChild(child:DisplayObject):void
		{
			if (!container.contains(child))
			{
 				container.addChildAt(child,container.numChildren>0 ? container.numChildren-1 : 0);
 			}
		}
		private function removeInlineChild(child:DisplayObject):void
		{
			// If the graphic was switched from float to inline ("none"), then it has been reparented to a TextLine,
			// which causes it not to be a child of the container anymore. We catch this as an exception that we handle.
			try
			{
				container.removeChild(child);
			}
			catch(e:Error)
			{
				if (e.errorID != 2025)
					throw e;
			}
		}

		public function recordInlineChild(value:DisplayObject):void
		{
			if (!inlineChildren)
				inlineChildren = [];
			else if (inlineChildren.indexOf(value) != -1)
				return;	// don't read it
			inlineChildren.push(value);
		}

		public function computeInlineArea(value:DisplayObject):Rectangle
		{
			// HACK
			var vbc:TextLayoutBaseContainer = value as TextLayoutBaseContainer;
			if (vbc)
			{
				vbc.validateSize();
				return new Rectangle(0, 0, vbc.width, vbc.height);
			}

			var cont:DisplayObjectContainer = value as DisplayObjectContainer;
			
			// HACK Currently using a few weak typing tricks to play
			// nicely with Flex components without compiler dependencies.
			// Undoubtedly there's a better way to do this.
			if (cont.hasOwnProperty("validateNow"))
				cont["validateNow"].call(cont);
			
			// This moves the container from the rawChildren into the parent container for the purpose of layout
			// It gets moved back later in updateCompositionShapes/createShapes
			// TODO: don't do this as its really expensive and forced a complete redraw
			// cont.includeInLayout = false;
			if (cont.hasOwnProperty("includeInLayout"))
				cont["includeInLayout"] = false;
			// TEMP - force add and remove
			// if (container.parent != this && container.parent != null)
			if (cont.parent)
				cont.parent.removeChild(cont);
				
			if (isDamaged())
			{
				// temporary hack until appropriate interface is determined
				if (cont.hasOwnProperty("invalidateSize"))
					Function(cont["invalidateSize"]).call(cont);
				//cont.invalidateSize();
			}
			if (cont.hasOwnProperty("validateNow"))
				cont["validateNow"].call(cont);
			
			var inlineRect:Rectangle = new Rectangle(0, 0, cont.width, cont.height);

			return inlineRect;
		}
		
		/** @private */
		override tlf_internal function clearCompositionResults():void
		{
			super.clearCompositionResults();
			
			clearLastInlineChildren();
			numWraps = 0;
		} 
		
		private function clearLastInlineChildren():void
		{
			if (lastInlineChildren)
			{
				for (var i:int = 0; i < lastInlineChildren.length; i++)
				{
					var oldInline:DisplayObject = DisplayObject(lastInlineChildren[i]);
					if ((inlineChildren.indexOf(oldInline) < 0))
						removeInlineChild(oldInline);
				}
			}
			lastInlineChildren = [];
		}
		
		/** @private */
		override tlf_internal function updateInlineChildren():void
		{
			// Remove the inlines from last time that are not part of what we are going to redisplay this time		
			clearLastInlineChildren();
			
			// synchronize the inline shapes beginning at childIdx
			// Add in the new shapes from this time that are not already in the list
			for each (var inline:DisplayObject in inlineChildren)
			{
				addInlineChild(inline);
				
				// inlines can update themselves if necessary here
				// We need this because editing a table, e.g., curently invalidates
				// through the text flow, rather than through the component hierarchy.
				// (Is this the right thing to do?)
				if (inline is TextLayoutBaseContainer)
					TextLayoutBaseContainer(inline).validateNow();	
			}
			if (inlineChildren)
			{
				lastInlineChildren = inlineChildren.slice();
				inlineChildren.length = 0;
			}
		}

		private function clearInlineSelectionShapes(c:DisplayObjectContainer):void
		{
			if (c.hasOwnProperty("controller"))
				c["controller"].clearAllSelectionShapes();
			else
			{
				for (var idx:int = 0; idx < c.numChildren; idx++)
				{
					var child:DisplayObjectContainer = c.getChildAt(idx) as DisplayObjectContainer;
					if (child)
						clearInlineSelectionShapes(child);
				}
			}
		}
		
		CONFIG::debug tlf_internal override function validateLines():void
		{
			// doesn't work in layout yet
		}
		
	}
}

