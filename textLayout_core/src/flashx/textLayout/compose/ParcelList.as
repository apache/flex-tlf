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
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.container.ColumnState;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.VerticalAlign;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
			
	[ExcludeClass]
	/** @private
	 * Implementation of IParcelList used for composing text containers that have single
	 * column, no wraps, and no floats.
	 * 
	 * ParcelList will always have one parcel, which corresponds to the container's
	 * bounding box. 
	 */
	public class ParcelList implements IParcelList  
	{
		protected var _flowComposer:IFlowComposer;
		
		/** Current vertical position in the parcel. */
		protected var _totalDepth:Number;
		
		/** whether the current parcel has any content */
		protected var _hasContent:Boolean;
		
		/** The list of parcels that are available for text layout.
			They are appear in the array in reading order: the first text goes in the
			first parcel, when it gets filled later text is flowed into the second 
			parcel, and so on.  */
		private var _parcelArray:Array;	/* of Parcel */
		private var _numParcels:int;
		private var _singleParcel:Parcel;
		
		/** Index of the "current" parcel. These next two variables must be kept in sync. */
		protected var _currentParcelIndex:int;
		protected var _currentParcel:Parcel;
		
		/** Callback to notify that we're going to the next parcel */
		protected var _notifyOnParcelChange:Function;
		
		/** Column number of the current parcel */
		private var _columnIndex:int;
		private var _columnController:ContainerController;
		
		private var _explicitLineBreaks:Boolean;
		
		/** true if we should include the last line if any part of it fits */
	//	protected var _includePartialLine:Boolean;
		
		
	//	private var parcel:Parcel;
	
		private static const MAX_HEIGHT:Number = 900000000;		// vertical scroll max - capped to prevent loss of precision - what should it be?
		private static const MAX_WIDTH:Number =  900000000;		// horizontal scroll max - capped to prevent loss of precision - what should it be?

			/** minimum allowable width of a line */
			
		/** Writing mode for vertical, left to right and left to right. @see text.formats.BlockProgression */
		protected var _blockProgression:String;
		
		// a single parcellist that is checked out and checked in
		static private var _sharedParcelList:ParcelList;

		/** @private */
		static tlf_internal function getParcelList():ParcelList
		{
			var rslt:ParcelList = _sharedParcelList ? _sharedParcelList : new ParcelList();
			_sharedParcelList = null;
			return rslt;
		}
		
		/** @private */
		static tlf_internal function releaseParcelList(list:IParcelList):void
		{
			if (_sharedParcelList == null)
			{
				_sharedParcelList = list as ParcelList;
				if (_sharedParcelList)
					_sharedParcelList.releaseAnyReferences();
			}
		}

		/** Constructor. */
		public function ParcelList()
		{ _numParcels = 0;	}
		
		/** prevent any leaks. @private */
		tlf_internal function releaseAnyReferences():void
		{
			this._flowComposer = null;
			this._columnController = null;
			
			_numParcels = 0;
			_parcelArray = null;
			
			if (_singleParcel)
				_singleParcel.releaseAnyReferences();
		}
		
		CONFIG::debug public function getBounds():Array
		{
			var boundsArray:Array = [];
			for (var i:int = 0; i < _numParcels; ++i)
				boundsArray.push(getParcelAtIndex(i));
			return boundsArray;
		}
		
		protected function get numParcels():int
		{ return _numParcels; }
		
		protected function getParcelAtIndex(idx:int):Parcel
		{ return _numParcels == 1 ? _singleParcel : _parcelArray[idx]; }
		
		protected function insertParcel(startIdx:int, parcel:Parcel):void
		{
			if (_numParcels == 0)
				_singleParcel = parcel;
			else
			{
				if (_numParcels == 1)
					_parcelArray = [ _singleParcel ];
				_parcelArray.splice(startIdx, 0, parcel);
			}
			_numParcels++;
		}
		
		protected function set parcels(newParcels:Array):void
		{
			_numParcels = newParcels.length;
			if (_numParcels == 0)
				_parcelArray = null;
			else if (_numParcels == 1)
			{
				_parcelArray = null;
				_singleParcel = newParcels[0];
			}
			else
				_parcelArray = newParcels;
		}
		
		public function get left():Number
		{
			return _currentParcel.left;
		}
		
		public function get right():Number
		{
			return _currentParcel.right;
		}
		
		public function get top():Number
		{
			return _currentParcel.top;
		}
		
		public function get bottom():Number
		{
			return _currentParcel.bottom;
		}
		
		public function get width():Number
		{
			return _currentParcel.width;
		}
		
		public function get height():Number
		{
			return _currentParcel.height;
		}
		
		public function get fitAny():Boolean
		{
			return _currentParcel.fitAny;
		}
				
		public function get controller():ContainerController
		{
			return _columnController;
		}
		
		public function get columnIndex():int
		{ return _columnIndex; }
		
		public function get explicitLineBreaks():Boolean
		{ 
			return _explicitLineBreaks;
		}
		
		private function get measureWidth():Boolean
		{
			if (_explicitLineBreaks)
				return true;
			if (!_currentParcel)
				return false;
			if (_blockProgression == BlockProgression.TB)
				return _currentParcel.measureWidth;
			else
				return _currentParcel.measureHeight;
		}

		private function get measureHeight():Boolean
		{
			if (!_currentParcel)
				return false;
			if (_blockProgression == BlockProgression.TB)
				return _currentParcel.measureHeight;
			else
				return _currentParcel.measureWidth;
		}
		
		public function get totalDepth():Number
		{
			return _totalDepth;
		}
		
		public function get notifyOnParcelChange():Function
		{
			return _notifyOnParcelChange;
		}
		
		public function set notifyOnParcelChange(val:Function):void
		{
			_notifyOnParcelChange = val;
		}
		
		public function addTotalDepth(value:Number):Number
		{
			_hasContent = true;
			_totalDepth += value;	
		//	trace("addTotalDepth", value, "newDepth", totalDepth);
			return _totalDepth;
		}
		
		protected function reset():void
		{
			_totalDepth = 0;
			_hasContent = false;
			_columnIndex = 0;
			_currentParcelIndex = 0;
			
			if (_numParcels != 0)
			{
				_currentParcel    = getParcelAtIndex(_currentParcelIndex);
				_columnController =  _currentParcel.controller;
				_columnIndex      = 0;
			}
			else
			{
				_currentParcel = null;
				_columnController =  null;
				_columnIndex = -1;
			}
		}
		
		private function addParcel(column:Rectangle, cont:ContainerController, col:int, colCoverage:int):void
		{
			var newParcel:Parcel = _numParcels == 0 && _singleParcel 
				? _singleParcel.initialize(column.x,column.y,column.width,column.height,cont,col,colCoverage) 
				: new Parcel(column.x, column.y, column.width, column.height, cont, col, colCoverage)
			if (_numParcels == 0)
				_singleParcel = newParcel;
			else if (numParcels == 1)
				_parcelArray = [  _singleParcel, newParcel ];
			else
				_parcelArray.push(newParcel);
			_numParcels++;
		}
		
		protected function addOneControllerToParcelList(controllerToInitialize:ContainerController):void
		{
			// Initialize new parcels for columns
			var columnState:ColumnState = controllerToInitialize.columnState;
			for (var columnIndex:int = 0; columnIndex < columnState.columnCount; columnIndex++)
			{
				var column:Rectangle = columnState.getColumnAt(columnIndex);
				if (!column.isEmpty())
					addParcel(column, controllerToInitialize, columnIndex, Parcel.FULL_COLUMN);
			}
		}
		
		public function beginCompose(composer:IFlowComposer, controllerEndIndex:int, composeToPosition:Boolean):void
		{
			_flowComposer = composer;
			
			var rootFormat:ITextLayoutFormat = composer.rootElement.computedFormat;
			_explicitLineBreaks = rootFormat.lineBreak == LineBreak.EXPLICIT;
			_blockProgression   = rootFormat.blockProgression;
			
			if (composer.numControllers != 0)
			{
				// if controllerEndIndex is not specified then assume we are composing to position and add all controllers
				if (controllerEndIndex < 0)
					controllerEndIndex = composer.numControllers-1;
				else
					controllerEndIndex = Math.min(controllerEndIndex,composer.numControllers-1);
				var idx:int = 0;
				do
				{
					addOneControllerToParcelList(ContainerController(composer.getControllerAt(idx)));
				} while (idx++ != controllerEndIndex)
				// adjust the last container for scrolling
				if (controllerEndIndex == composer.numControllers-1)
					adjustForScroll(ContainerController(ContainerController(composer.getControllerAt(composer.numControllers-1))), composeToPosition);
			}
			reset();
		}
		
		/** Adjust the size of the parcel corresponding to the last column of the containter, in 
		 * order to account for scrolling.
		 */
		private function adjustForScroll(containerToInitialize:ContainerController, composeToPosition:Boolean):void
		{			
			// Expand the last parcel if scrolling could be enabled. Expand to twice what would fit in available space. 
			// We will start composing from the top, so if we've scrolled down there will be more to compose.
			// We turn on fitAny, so that lines will be included in the container even if only a tiny portion of the line
			// fits. This makes lines that are only partially scrolling in appear. We turn on composeToPosition if we're
			// forcing composition to go through a given position -- this will make all lines fit, and composition will
			// continue until it is past the supplied position.
			if (_blockProgression != BlockProgression.RL)
			{
				if (containerToInitialize.verticalScrollPolicy != ScrollPolicy.OFF)
				{
					var p:Parcel = getParcelAtIndex(_numParcels-1);
					if (p)
					{
						var verticalPaddingAmount:Number = containerToInitialize.effectivePaddingBottom + containerToInitialize.effectivePaddingTop;
						p.bottom = containerToInitialize.verticalScrollPosition + p.height + verticalPaddingAmount;
						p.fitAny = true;
						p.composeToPosition = composeToPosition;
					}
				}
			}
			else	// vertical text case
			{
				if (containerToInitialize.horizontalScrollPolicy != ScrollPolicy.OFF)
				{
					p = getParcelAtIndex(_numParcels-1);
					if (p)
					{
						var horizontalPaddingAmount:Number = containerToInitialize.effectivePaddingRight + containerToInitialize.effectivePaddingLeft;
						p.left = containerToInitialize.horizontalScrollPosition - p.width - horizontalPaddingAmount;
						p.fitAny = true;
						p.composeToPosition = composeToPosition;
					}
				}
			}
		}

		public		function getComposeXCoord(o:Rectangle):Number
		{ 
			// trace("LPL: getComposeXCoord");
			return _blockProgression == BlockProgression.RL ? o.right : o.left;
		}
		public		function getComposeYCoord(o:Rectangle):Number
		{ 
			// trace("LPL: getComposeYCoord");
			return o.top;
		}

		public function getComposeWidth(o:Rectangle):Number
		{ 
			// trace("LPL: getComposeWidth");
			if (measureWidth)
				return TextLine.MAX_LINE_WIDTH;
			return _blockProgression == BlockProgression.RL ? o.height : o.width; 
		}
		public function getComposeHeight(o:Rectangle):Number
		{ 
			// trace("LPL: getComposeHeight");
			if (measureHeight)
				return TextLine.MAX_LINE_WIDTH;
			return _blockProgression == BlockProgression.RL ? o.width : o.height; 
		}		
		/** True if the current parcel is at the top of the column */
		public function isColumnStart():Boolean
		{
			return (!_hasContent && _currentParcel.topOfColumn);
		}
		
		/** Returns true if the current parcel is the last.
		*/
		public function atLast():Boolean
		{
			return _numParcels == 0 || _currentParcelIndex == _numParcels -1;
		}
		
		public function atEnd():Boolean
		{
			return _numParcels == 0 || _currentParcelIndex >= _numParcels;
		}
		
		public function next():Boolean
		{
			CONFIG::debug { assert(_currentParcelIndex >= 0 && _currentParcelIndex < _numParcels, "invalid _currentParcelIndex in ParcelList"); }			
			var nextParcelIsValid:Boolean = (_currentParcelIndex + 1) < _numParcels;

			_notifyOnParcelChange(nextParcelIsValid ? getParcelAtIndex(_currentParcelIndex + 1) : null)
			
			_currentParcelIndex += 1;
			_totalDepth = 0;
			_hasContent = false;
			
			if (nextParcelIsValid)
			{
				_currentParcel = getParcelAtIndex(_currentParcelIndex);
				var nextController:ContainerController = _currentParcel.controller;
				if (nextController == _columnController)
					_columnIndex++;
				else
				{
					_columnIndex = 0;
					_columnController = nextController;
				}
			}
			else
			{
				_currentParcel = null;
				_columnIndex = -1;
				_columnController = null;
			}
	
			return nextParcelIsValid;
		}
		
		public function createParcel(parcel:Rectangle, blockProgression:String, verticalJump:Boolean):Boolean
			// If we can get the requested parcel to fit, create it in the parcels list
		{
			return false;
		}
		
		public function createParcelExperimental(parcel:Rectangle, wrapType:String):Boolean
			// If we can get the requested parcel to fit, create it in the parcels list
		{
			return false;
		}
		
		public function get currentParcel():Parcel
		{ return _currentParcel; }

		/**Return the width for a line that goes at the current vertical location,
		 * and could extend down for at least height pixels. Note that this function
		 * can change the current parcel, and the location within the parcel.
		 * @param height	amount of contiguous vertical space that must be available
		 * @param minWidth	amount of contiguous horizontal space that must be available 
		 * @return amount of contiguous horizontal space actually available
		 */
		public function getLineSlug(slugRect:Rectangle, height:Number, minWidth:Number = 0):Boolean
		{
			// trace("getLineSlug",slugRect,height,minWidth);
			if (_currentParcelIndex < _numParcels) 
			{
				var tileWidth:Number = getComposeWidth(_currentParcel);
				if (tileWidth > minWidth)
				{
					// Fit the line if any part of the line fits in the height. Observe the cast to int!
					if (currentParcel.composeToPosition || _totalDepth + (_currentParcel.fitAny ? 1 : int(height)) <= getComposeHeight(_currentParcel))
					{
						if (_blockProgression != BlockProgression.RL)
						{
							slugRect.x = left;
							slugRect.y = _currentParcel.top + _totalDepth;
							slugRect.width = tileWidth;
							slugRect.height = height;
						}
						else
						{
							slugRect.x = left;
							slugRect.y = _currentParcel.top;
							slugRect.width = _currentParcel.width-_totalDepth;
							slugRect.height = tileWidth;
						}
						return true;
					}
				}
			} 
			return false;
		}
	

	}	//end class
} //end package
