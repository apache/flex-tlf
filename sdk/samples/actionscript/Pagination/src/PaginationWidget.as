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
﻿package
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.SelectionEvent;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	public class PaginationWidget extends Sprite
	{
		// width and height this widget should use
		private var _width:int;
		private var _height:int;
		
		// current textflow, the list of pages and current page and display position
		private var _textFlow:TextFlow;
		private var _pageList:Array;
		private var _curPage:int;
		private var _curPosition:int;	// really the first visible character - during resize keep this in view
		
		// some configuration values - ContainerFormat for all containers and constraints on container width
		private var _containerFormat:TextLayoutFormat;
		private const _minContainerWidth:int = 100;
		private const _maxContainerWidth:int = 10000;
		
		// derived values - based on width/height compute these values
		private var _containerHeight:int;
		private var _containerWidth:int;
		private var _containersToShow:int;
		private var _containerMargin:Number;
		
		
		public function PaginationWidget()
		{
			_curPage = -1; 
			_curPosition = 0;
			_pageList = new Array();
			
			// all containers formatted this way
			_containerFormat = new TextLayoutFormat();
			_containerFormat.columnCount = 1;
			_containerFormat.paddingTop = 10;
			_containerFormat.paddingBottom = 10;
			_containerFormat.paddingLeft = 10;
			_containerFormat.paddingRight = 10;
			
			_containersToShow = 0;
			
			this.focusRect = false;
		}
		
		/** Sets a new width and height into the widget.  
		 * Uses simple heuristics to decide how big the containers are and how many are visible.
		 * Don't resize the containers on every size change - instead wait for a larger change 
		 */
		public function setSize(w:int,h:int):void
		{
			if (w == _width && h == _height)
				return;
			
			_width = w;
			_height = h;
			
			var newContainerMargin:int = 25;
			// width <= 250 one column
			// width <= 500 two columns
			// width <= 1000 three columns
			// width > 1000 four colunmns
			var newContainersToShow:int = 0;
			if (_width <= 300)
				newContainersToShow = 1;
			else if (_width <= 550)
				newContainersToShow = 2;
			else if (_width <= 1050)
				newContainersToShow = 3;
			else
				newContainersToShow = 4;
			
			var newContainerHeight:int = _height;
			var newContainerWidth:int = Math.max((_width-2*newContainerMargin)/newContainersToShow,_minContainerWidth);

			// only change if things go out of view or height changes by more than one line - call it 12
			// this is a heuristic that can be easily refined.  the goal is to not reflow the text every time things change just a little to give much smoother performance
			if (newContainersToShow != _containersToShow || Math.abs(_containerWidth-newContainerWidth)>36 || Math.abs(newContainerHeight-_containerHeight) > 12 || (_containerMargin + _containerWidth * _containersToShow) > _width)
			{ 
				_containerWidth = newContainerWidth;
				_containerHeight = newContainerHeight;
				_containersToShow = newContainersToShow;
				_containerMargin = newContainerMargin;
				
				if (_textFlow)
				{
					recomputeContainers();
					goToCurrentPosition(true);
				}
			}
			else
			{
				// decided not to recompose but lets redo the margins so things look nice
				newContainerMargin = Math.max((_width - _containersToShow * _containerWidth) / 2.0,0);
				if (newContainerMargin != _containerMargin)
				{
					var savePage:int = _curPage;
					_containerMargin = newContainerMargin;
					goToPage(-1,false);
					goToPage(savePage,false);
				}
			}
		}
		private var inRecomputeContainers:Boolean = false;
		/** The worker function.  Reflows based on the parameters computed in setSize */
		private function recomputeContainers():void
		{
			var idx:int;	// scratch
			inRecomputeContainers = true;

			// clear list of pages
			_pageList.splice(0);
				
			// resize existing containers
			for (idx = 0; idx < _textFlow.flowComposer.numControllers; idx++)
			{
				_textFlow.flowComposer.getControllerAt(idx).setCompositionSize(_containerWidth,_containerHeight);
			}

			var controller:ContainerController;
				
			for (;;)
			{
				// compose the current chain of continers
				if (_textFlow.flowComposer.numControllers)
				{
					_textFlow.flowComposer.compose();
					
					// add just the containers with content to pageList.  Stop at first empty container or when all text is placed
					while (_pageList.length < _textFlow.flowComposer.numControllers)
					{
						controller = _textFlow.flowComposer.getControllerAt(_pageList.length);
						_pageList.push(Sprite(controller.container));
						
						if (controller.textLength == 0 || controller.absoluteStart + controller.textLength >= _textFlow.textLength)
						{
							// all the text has fit into the containers.  now display the textlines and done
							_textFlow.flowComposer.updateAllControllers();
							inRecomputeContainers = false;
							return;
						} 
					}
				}
				
				// create new containers in batches - 10 at a time
				for (idx = 0; idx < 10; idx++)
				{
					controller = new MyDisplayObjectContainerController(new Sprite(),_containerWidth,_containerHeight, this);
					controller.horizontalScrollPolicy = ScrollPolicy.OFF;
					controller.verticalScrollPolicy = ScrollPolicy.OFF;
					controller.format = _containerFormat;
					
					_textFlow.flowComposer.addController(controller);
				}
			}
		}
		
		
		/** The TextFlow to display */
		public function get textFlow():TextFlow
		{ return _textFlow; }
		
		public function set textFlow(newFlow:TextFlow):void
		{
			// clear any old flow if present
			if (_textFlow)
			{
				_textFlow.interactionManager = null;
				goToPage(-1, false);
				_textFlow.flowComposer.removeAllControllers();
				_textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,graphicStatusChangeEvent);	
				_textFlow.removeEventListener(SelectionEvent.SELECTION_CHANGE,selectionChangeEvent);
				_textFlow.removeEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE,compositionDoneEvent);
				_textFlow = null;
			}
			_textFlow = newFlow;
			if (_textFlow)
			{
				// Disable the interactionManager
				// _textFlow.interactionManager = new EditManager();
				// _textFlow.interactionManager.selectRange(0,0);

				// setup event listener ILG loaded
				_textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,graphicStatusChangeEvent);	
				_textFlow.addEventListener(SelectionEvent.SELECTION_CHANGE,selectionChangeEvent);
				_textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE,compositionDoneEvent);
				_textFlow.interactionManager = new SelectionManager();
				
				recomputeContainers();
				goToPage(0);
			}
		}
		
		/** Receives an event any time an ILG with a computed size finishes loading. */
 		private function graphicStatusChangeEvent(evt:StatusChangeEvent):void
		{
			// recompose if the evt is from an element in this textFlow
			if (_textFlow && evt.element.getTextFlow() == _textFlow)
			{
				recomputeContainers();
				goToCurrentPosition();
			}
		}
		
		private function selectionChangeEvent(e:SelectionEvent):void
		{
			goToCurrentPosition();
		}
		
		private function compositionDoneEvent(evt:CompositionCompleteEvent):void
		{
			if (inRecomputeContainers)
				return;
			// is the entire flow in a container
			var lastLine:TextFlowLine = _textFlow.flowComposer.getLineAt(_textFlow.flowComposer.numLines-1);
			if (lastLine.controller == null || _textFlow.flowComposer.findControllerIndexAtPosition(lastLine.absoluteStart) != _pageList.length-1)
			{
				recomputeContainers();
				goToCurrentPosition();
			}
		}
		
		/** Go to the first page of the current textFlow. */
		public function firstPage():void
		{ 
			if (_curPage != -1 &&_pageList.length)
				goToPage(0); 
		}
		
		/** Go to the last page of the current textFlow. */
		public function lastPage():void
		{ 
			if (_curPage != -1 &&_pageList.length)
				goToPage(_pageList.length-1); 
		}
		
		/** Go to the next page of the current textFlow. */
		public function nextPage():void
		{ 
			if (_curPage != -1)
				goToPage(_curPage+_containersToShow); 
		}
		
		/** Go to the previous page of the current textFlow. */
		public function prevPage():void
		{ 
			if (_curPage != -1)
				goToPage(Math.max(0,_curPage-_containersToShow)); 
		}
		
		private function goToCurrentPosition(alwaysgo:Boolean = false):void
		{
			var activePosition:int = _textFlow.interactionManager ? _textFlow.interactionManager.activePosition : _curPosition;
				
			var pageToShow:int = _textFlow.flowComposer.findControllerIndexAtPosition(activePosition,activePosition == _textFlow.textLength);
			pageToShow = Math.max(0,Math.min(pageToShow,_pageList.length-_containersToShow));	
			// if its already visible do nothing
			if (alwaysgo || _curPage == -1 || _curPage > pageToShow || _curPage+_containersToShow <= pageToShow)
			{
				goToPage(-1,false);						
				goToPage(pageToShow,false);
				if (_textFlow.interactionManager)
					_textFlow.interactionManager.refreshSelection();
			}
		}
		
		/** Go to a specific page.
		 * @param pageNum - page to go to
		 * @param updateCurPosition - remember first character so that on resize that character stays in view.
		 */
		public function goToPage(pageNum:int,updateCurPosition:Boolean = true):void
		{
			if (pageNum >= _pageList.length)
				pageNum = _pageList.length-1;
			if (pageNum != _curPage)
			{
				while (numChildren)
					removeChildAt(0);
				_curPage = pageNum;
				
				if (_curPage != -1)
				{
					// now add in the correct number of pages
					var pageAfter:int = Math.min(_pageList.length,_curPage+this._containersToShow);
					var xpos:Number = this._containerMargin;
					for (var idx:int = _curPage; idx < pageAfter; idx++)
					{
						var pageToShow:Sprite = _pageList[idx];
						pageToShow.x = xpos;
						addChild(pageToShow);
						xpos += _containerWidth;
					}
				}
			}
			// focus on the first page
			this.stage.focus = _curPage == -1 ? null : _pageList[_curPage];
			if (updateCurPosition)
				_curPosition = _curPage == -1 ? 0 : _textFlow.flowComposer.getControllerAt(_curPage).absoluteStart;
		}
		
		/** KeyDown helper function for keyboard navigation.
		 * @returns true --> keyboard event handled here. */
		public function processKeyDownEvent(e:KeyboardEvent):Boolean
		{
			if (e.charCode == 0 && !e.shiftKey)
			{	
				// the keycodes for navigating within a TextFlow
				switch(e.keyCode)
				{
					case Keyboard.LEFT:
					case Keyboard.UP:
					case Keyboard.PAGE_UP:
							prevPage();
							return true;
					case Keyboard.RIGHT:
					case Keyboard.DOWN:
					case Keyboard.PAGE_DOWN:
							nextPage();
							return true;
					case Keyboard.HOME:
							firstPage();
							return true;
					case Keyboard.END:
							lastPage();
							return true;
				}
			}
			return false;
		}
	}
}

import flash.display.Sprite;
import flash.events.KeyboardEvent;

import flashx.textLayout.container.ContainerController;

/** overrides processKeyDownEvent to add keyboard navigation */
class MyDisplayObjectContainerController extends ContainerController
{
	private var _widget:PaginationWidget;
	
	public function MyDisplayObjectContainerController(cont:Sprite,compositionWidth:Number,compositionHeight:Number,widget:PaginationWidget)
	{
		super(cont,compositionWidth,compositionHeight);
		_widget = widget;
	}
	
	public override function keyDownHandler(e:KeyboardEvent):void
	{
		if (_widget.processKeyDownEvent(e))
		{
			e.preventDefault();
			return;
		}
		super.keyDownHandler(e);
	}
}
