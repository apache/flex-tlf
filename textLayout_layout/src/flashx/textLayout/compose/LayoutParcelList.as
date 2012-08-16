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
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.IFloatController;
	import flashx.textLayout.container.IWrapManager;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.formats.BlockProgression;
	
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;		
	/** The area inside a text container is sub-divided into smaller areas available for
	 * text layout. These smaller areas within the container are called Parcels. The 
	 * ParcelList manages the parcel associated with a TextFlow during composition.
	 * 
	 * A container will always have at least one parcel, which corresponds to the container's
	 * bounding box. If the container has more than one column, each column appears as
	 * a parcel in the parcel list. If the container has wrap applied, the area around the
	 * wrap that is available for layout is divided into rectangular-shaped parcels.
	 * Lastly, parcels may be created during composition for use by flow elements that require
	 * layout within a specific geometry that may not be the same as the columns: for instance, 
	 * a straddle head, a table, or a sidehead.
	 */
	internal class LayoutParcelList extends ParcelList
	{	
		/** This is a list of the wraps, or parcels that are NOT available for text layout. */
		private var wraps:Array;	/* of Rectangle */
		
		/** Inlines can extend across columns, so we have a separate parcel list
			that is independent of columns (just has container bboxes) used for
			creating new parcels that can extend across columns. */
		// private var inlineWrap:LayoutParcelList;
	
		/** minimum allowable width of a line */
		private static const MIN_WIDTH:Number = 40;
		
		// a single parcellist that is checked out and checked in
		static private var _sharedLayoutParcelList:LayoutParcelList;

		/** @private */
		static tlf_internal function getLayoutParcelList():LayoutParcelList
		{
			var rslt:LayoutParcelList = _sharedLayoutParcelList ? _sharedLayoutParcelList : new LayoutParcelList();
			_sharedLayoutParcelList = null;
			return rslt;
		}
		
		/** @private */
		static tlf_internal function releaseLayoutParcelList(list:IParcelList):void
		{
			if (_sharedLayoutParcelList == null)
			{
				_sharedLayoutParcelList = list as LayoutParcelList;
				if (_sharedLayoutParcelList)
					_sharedLayoutParcelList.releaseAnyReferences();
			}
		}
			
		/** Constructor */
		public function LayoutParcelList()
		{
			super();
		}

		/** prevent any leaks. @private */
		tlf_internal override function releaseAnyReferences():void
		{
			super.releaseAnyReferences();
			wraps = null;
		}
				
		override protected function addOneControllerToParcelList(controllerToInitialize:ContainerController):void
		{
			super.addOneControllerToParcelList(controllerToInitialize);
			if (controllerToInitialize is IFloatController)
			{
				if (IFloatController(controllerToInitialize).wraps)
					this.wraps = IFloatController(controllerToInitialize).wraps.wraps;
				for each (var wrapExclude:Rectangle in wraps)
					addWrap(wrapExclude, controllerToInitialize, false /* wrap around the sides */);
			}
		}

		private function isNextAdjacent():Boolean
		{
			// trace("LPL: isNextAdjacent");
			CONFIG::debug { assert(_currentParcelIndex >= 0 && _currentParcelIndex < numParcels, "invalid _currentParcelIndex in ParcelList"); }
			if (_currentParcelIndex + 1 >= numParcels)
				return false;
			var nextParcel:Parcel = getParcelAtIndex(_currentParcelIndex + 1);
			if(_blockProgression != BlockProgression.RL)
			{
				if (_currentParcel.bottom != nextParcel.top || _currentParcel.left > nextParcel.right)
					return false;
			} 
			else
			{
				if(_currentParcel.left != nextParcel.right || _currentParcel.top > nextParcel.bottom)
					return false;
			}
			return true;
		}

		private function getBBox(controller:ContainerController):Rectangle
		{
			// trace("LPL: getBBox");
			var bbox:Rectangle = null;
			for (var idx:int = 0; idx < numParcels; idx++)
			{
				var p:Parcel = getParcelAtIndex(idx);
				if (p.controller == controller)
				{
					if (!bbox)
						bbox = p.clone();
					else
						bbox = bbox.union(p);
				}					
			}
			return bbox;
		}
		
		private function intersects(r:Rectangle, rectArray:Array):Boolean
			// true if r intersects any of the rectangles in rectArray
		{
			// trace("LPL: getBBox");
			if (rectArray)
			{
				for each (var i:Rectangle in rectArray)
				{
					if (i.intersects(r))
						return true;
				}
			}
			return false;
		}
		
			/** @private */
		override public function createParcel(parcel:Rectangle, blockProgression:String, verticalJump:Boolean):Boolean
			// If we can get the requested parcel to fit, create it in the parcels list
		{
			// trace("LPL: createParcel");
		//	trace("createParcel start", parcel.toString());
		//	traceOut();
			
			var fitRect:Rectangle = new Rectangle();
			do {
				getLineSlug(fitRect,parcel.height);
				if (!fitRect || atEnd())	// Can't find contiguous vertical space for the parcel
					return false;
				else 
				{
					if (blockProgression == BlockProgression.TB)
						parcel.offset(0, fitRect.top - parcel.top);		// parcel location may have been adjusted by getLineSlug
					else
						parcel.offset(fitRect.left - parcel.left, 0);		// parcel location may have been adjusted by getLineSlug

					if (fitRect.width >= parcel.width)
						break;		// found enough vertical & horizontal space

					// Found vertical space, but not enough horizontal.
					// It could be that parcel would fit across contiguous columns. Check for a wrap.
					// Check that it fits within the bounding box for the container, 
					// and doesn't intersect any wraps	
					var bbox:Rectangle = getBBox(_currentParcel.controller);
					if (bbox.containsRect(parcel) && !intersects(parcel, wraps))
						break;

					next();		// keep looking in other parcels

					if (_currentParcelIndex >= numParcels)
						return false;		// hit the end: space not found
				}
			} while (fitRect.width < parcel.width);
				
			// Create a new parcel, and insert it in the correct location in the parcels array
			var targetController:ContainerController = _currentParcel.controller;
			addWrap(parcel, targetController, verticalJump /* jumpOver */);
			for (var l:int = 0; l < numParcels; l++)
			{
				var testParcel:Parcel = getParcelAtIndex(l);
				if (testParcel.top > parcel.top && 
					!((testParcel.left > parcel.right) || (testParcel.right < parcel.left)))
				{
					if (testParcel.controller == targetController)
						break;
				}
			}
			var splitParcel:Parcel = getParcelAtIndex(l);
			var splitCoverage:int = splitParcel.columnCoverage;
			
			// clear top of column splitParcel is not that anymore
			splitParcel.columnCoverage = splitCoverage & ~Parcel.TOP_OF_COLUMN;
			// we're inserting before so its bot_of_column - we aren't
			insertParcel(l,new Parcel(parcel.x, parcel.y, parcel.width, parcel.height, targetController, splitParcel.column, splitCoverage&~Parcel.BOT_OF_COLUMN));

			// Set the current parcel to be the one we just added
			_currentParcelIndex = l;
			_currentParcel = getParcelAtIndex(l);
			
	//		trace("createParcel done");
	//		traceOut();
				
			return true;
		}

		/** @private */
		override public function getLineSlug(slugRect:Rectangle,height:Number, minWidth:Number = 0):Boolean
		{
			return (_currentParcelIndex < numParcels) && getWidthInternal(slugRect, height, minWidth);
		}
		
		/**Helper function for getLineSlug, used internally. Similar to getWidth, but
		 * although it allows a line to extend across parcels, if necessary, the line
		 * will always start in the current parce. If a line does not fit starting
		 * from the current parcel, this function (unlike getWidth) will return
		 * 0 instead of changing the parcel.
		 * @param height	amount of contiguous vertical space that must be available
		 * @param minWidth	amount of contiguous horizontal space that must be available 
		 * @return amount of contiguous horizontal space actually available
		 */
		private function getWidthInternal(slugRect:Rectangle, height:Number, minWidth:Number):Boolean
		{
			// trace("LPL: getWidthInternal");
			CONFIG::debug { assert(_currentParcelIndex >= 0 && _currentParcelIndex < numParcels, "invalid position in ParcelList"); }
			
			// See if it fits in the current parcel
			var tileWidth:Number = getComposeWidth(_currentParcel);
			if (tileWidth <= minWidth)
				return false;
			var requiredHeight:Number = currentParcel.fitAny ? 1 : height;
			if (currentParcel.composeToPosition || _totalDepth + requiredHeight <= getComposeHeight(_currentParcel))
			{
				if (this._blockProgression != BlockProgression.RL)
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

			// This tile won't fit in the parcel. Look at the next parcel(s) that are adejacent,
			// as many as are required fit the tile. The width of the tile will be the minimum
			// of this list. If the width of the tile is less than the minimum specified by the 
			// caller, or if there aren't enough adejacent parcels to fit the tile, 
			// return 0 to indicate the tile doesn't fit in the parcel. The client code can try 
			// again on the next parcel.
			var offset:Number = getComposeHeight(_currentParcel) - _totalDepth;
			var heightRemaining:Number = height - offset;
			var leftEdge:Number = _currentParcel.left;
			var rightEdge:Number = _currentParcel.right;
			var topEdge:Number = _currentParcel.top;
			if (_blockProgression == BlockProgression.RL)
				rightEdge -= _totalDepth;
			else
				topEdge += _totalDepth;
			do 
			{
				// Next parcel isn't adejacent. We can't fit the tile.
				if (!isNextAdjacent())
					return false;
				next();
				tileWidth = Math.min(tileWidth, getComposeWidth(_currentParcel));
				if (tileWidth <= minWidth)
					return false;	// try again on next tile
				var newDepth:Number;
				if (_blockProgression == BlockProgression.RL)
				{
					topEdge = Math.max(topEdge, _currentParcel.top);
					newDepth = -(height - heightRemaining);
					heightRemaining -= Math.min(heightRemaining, _currentParcel.width);
				}
				else
				{
					leftEdge = Math.max(leftEdge, _currentParcel.left);
					newDepth = -(height - heightRemaining);
					heightRemaining -= Math.min(heightRemaining, _currentParcel.height);
				}
			} while (heightRemaining > 0)

			_totalDepth = newDepth;
			_hasContent = true;
			
			slugRect.x = leftEdge;
			slugRect.y = topEdge;
			if (_blockProgression == BlockProgression.RL)
			{
				slugRect.x = rightEdge - height;
				slugRect.width = height;
				slugRect.height = tileWidth;
			}
			else
			{
				slugRect.width = tileWidth;
				slugRect.height = height;
			}
			return true;
		}
		
		private function getSlugParcel(parcel:Rectangle, blockProgression:String):Rectangle
		{
			var fitRect:Rectangle = new Rectangle();
			do {
				getLineSlug(fitRect,parcel.height);
				if (!fitRect || atEnd())	// Can't find contiguous vertical space for the parcel
					return null;
				else 
				{
					if (blockProgression == BlockProgression.TB)
						parcel.offset(0, fitRect.top - parcel.top);		// parcel location may have been adjusted by getLineSlug
					else
						parcel.offset(fitRect.right - parcel.right, 0);		// parcel location may have been adjusted by getLineSlug

					if (fitRect.width >= parcel.width)
						break;		// found enough vertical & horizontal space

					// Found vertical space, but not enough horizontal.
					// It could be that parcel would fit across contiguous columns. Check for a wrap.
					// Check that it fits within the bounding box for the container, 
					// and doesn't intersect any wraps	
					var bbox:Rectangle = getBBox(_currentParcel.controller);
					if (bbox.containsRect(parcel) && !intersects(parcel, wraps))
						break;

					next();		// keep looking in other parcels

					if (_currentParcelIndex >= numParcels)
						return null;		// hit the end: space not found
				}
			} while (fitRect.width < parcel.width);
			return parcel;			
		}
		
		public const NONE:String = "none";			// don't wrap -- allow overlap
		public const LEFT:String = "left";			// allow text to the left
		public const RIGHT:String = "right";		// allow text to the right
	//	public const BIGGEST:String = "biggest";	// wrap either left or right, whichever is a bigger space - not yet supported
	//	public const BOTH:String = "both";			// "allow text on left and right - BUT jump-overs not supported
				
			/** @private */
		override public function createParcelExperimental(parcel:Rectangle, wrapType:String) : Boolean
		{
			// trace("LPL: createParcel");
		//	trace("createParcel start", parcel.toString());
		//	traceOut();			
			parcel = getSlugParcel(parcel, _blockProgression);
			if (!parcel)
				return false;	// doesn't fit
			
			
		//	trace("before");
		//	traceOut();
		//	trace("parcel", parcel.toString());

			var p:Parcel = getParcelAtIndex(0);
			var rotationPoint:Point = new Point(p.left, p.top);
			if (_blockProgression == BlockProgression.RL)
			{
				// rotate parcels to TB orientation
				for (var i:int = 0; i < numParcels; i++)
				{
					p = getParcelAtIndex(i);
					p.replaceBounds(transformRect(p, rotationPoint, true));
				}	
				parcel = transformRect(parcel, rotationPoint, true);
			}

			// Create a new parcel, and insert it in the correct location in the parcels array
			var targetController:ContainerController = _currentParcel.controller;
			addWrapExperimental(parcel, targetController, wrapType);
			_currentParcelIndex = numParcels;
			_currentParcel = null;
			for (var l:int = 0; l < numParcels; l++)
			{
				p = getParcelAtIndex(l);
				if (p.equals(parcel))
				{
					_currentParcelIndex = l;
					_currentParcel =  p;
					break;
				}
			}
			CONFIG::debug { assert (_currentParcelIndex != numParcels, "New parcel not current!"); }
			
			if (_blockProgression == BlockProgression.RL)
			{
				// rotate back
				parcel = transformRect(parcel, rotationPoint, false);				
				for (i = 0; i < numParcels; i++)
				{
					p = getParcelAtIndex(i);
					p.replaceBounds(transformRect(p, rotationPoint, false));
				}
			}
			
		//	trace("createParcel done");
		//	traceOut();
				
			return true;			
		}
		
		private function transformRect(r:Rectangle, rotationPoint:Point, up:Boolean):Rectangle
		{
			var dx:Number = r.x - rotationPoint.x;
			var dy:Number = (up ? r.y : r.bottom) - rotationPoint.y;
			if (up)
				return new Rectangle((rotationPoint.x + dy), (rotationPoint.y - dx) - r.width, r.height, r.width);
			return new Rectangle((rotationPoint.x - dy), (rotationPoint.y + dx), r.height, r.width);
		}
		
		
		private function addWrapExperimental(wrap:Rectangle, controller:ContainerController, wrapType:String):void
		{
		//	trace("addWrap", wrap.toString());
		//	traceOut();
			
			// Subtracts the wrap from the space available for laying out text.
			var insertWrap:Boolean = true;
			var newparcels:Array = new Array();	/* of Parcel */
			for (var idx:int = 0; idx < numParcels; idx++)
			{
				var p:Parcel = getParcelAtIndex(idx);
				if (p.controller == controller && wrap.intersects(p))
				{
					// If the wrap intersects the area, return the unintersected 
					// part of the area as an array of parcels that replaces
					// the area. If the area is entirely contained within the wrap,
					// this will remove the area.
					//
					// If the wrap appears inside the area, pick the larger side
					// to be in the area, and let the smaller side drop out as if
					// it were part of the wrap. Note that this means we do not
					// support jump-overs.
					unintersectExperimental(newparcels, p, wrap, wrapType, insertWrap);
					insertWrap = false;
				}
				else
					newparcels.push(p);
			}
			
			
		        // Keep track of the number of wraps per text frame.  It is needed to for vertical alignment.
		    if (controller.container is IFloatController)
				IFloatController(controller.container).numWraps++;
			
			parcels = newparcels;
			CONFIG::debug { validate(); }
		//	trace("after");
		//	traceOut();
		}
		
		private function unintersectExperimental(result:Array, parcel:Parcel, wrap:Rectangle, wrapType:String, insertWrap:Boolean):void
		{
			var area:Rectangle = parcel;
			// trace("LPL: unintersect");
			var columnCoverage:int = parcel.columnCoverage;
						
			// Return the unintersected part of the area that wrap does not
			// intersect as an array of parcels
			var r:Rectangle = area.intersection(wrap);
			
			// split into zero, one, two or three chunks
			var addTopParcel:Boolean = r.top > area.top;
			var addMidParcel:Boolean = ((r.left - area.left > Math.max(area.right - r.right, MIN_WIDTH)) || (area.right > r.right && area.right - r.right > MIN_WIDTH));
			var addBotParcel:Boolean = area.bottom > r.bottom;
			
			var newCoverage:int;	// scratch for computing coverage
			
			var parcelRect:Rectangle;
			
			// Space above the intersection
			if (addTopParcel)
			{
				newCoverage = columnCoverage;
				if (addBotParcel || addMidParcel)
					newCoverage &= ~Parcel.BOT_OF_COLUMN;
				columnCoverage &= ~Parcel.TOP_OF_COLUMN;
				
				result.push(new Parcel(area.left, area.top, area.width, r.top - area.top, parcel.controller, parcel.column, newCoverage));
			}

			newCoverage = columnCoverage;
			if (addBotParcel)
				newCoverage &= ~Parcel.BOT_OF_COLUMN;
			columnCoverage &= ~Parcel.TOP_OF_COLUMN;

			// Push our parcel
			if (insertWrap)
				result.push(new Parcel(wrap.x, wrap.y, wrap.width, wrap.height, parcel.controller, parcel.column, newCoverage));
			
			// Allocate space beside the parcel, depending on wrapType
			if (wrapType == LEFT)
			{
				if (r.left - area.left  > MIN_WIDTH)
					result.push(new Parcel(area.left, r.top, r.left - area.left, r.height, parcel.controller, parcel.column, newCoverage));
		}
			if (wrapType == RIGHT)
			{
				if (area.right - r.right  > MIN_WIDTH)
					result.push(new Parcel(r.right, r.top, area.right - r.right, r.height, parcel.controller, parcel.column, newCoverage));
			}

			// Space along the bottom
			if (addBotParcel)
				result.push(new Parcel(area.left, r.bottom, area.width, area.bottom - r.bottom, parcel.controller, parcel.column, columnCoverage));
		}

		private function addWrap(wrap:Rectangle, controller:ContainerController, verticalJump:Boolean):void
		{
			// trace("LPL: addWrap");
		//	trace("addWrap", wrap.toString());
		//	trace("before");
		//	traceOut();
			
			// Subtracts the wrap from the space available for laying out text.
			var newparcels:Array = new Array();	/* of Parcel */
			for (var idx:int = 0; idx < numParcels; idx++)
			{
				var p:Parcel = getParcelAtIndex(idx);
				if (p.controller == controller && wrap.intersects(p))
				{
					// If the wrap intersects the area, return the unintersected 
					// part of the area as an array of parcels that replaces
					// the area. If the area is entirely contained within the wrap,
					// this will remove the area.
					//
					// If the wrap appears inside the area, pick the larger side
					// to be in the area, and let the smaller side drop out as if
					// it were part of the wrap. Note that this means we do not
					// support jump-overs.
					unintersect(newparcels, p, wrap, verticalJump);
				//	verticalJump = false; // Yuck! Turning off multiple insertions
				}
				else
					newparcels.push(p);
			}
			
			
		        // Keep track of the number of wraps per text frame.  It is needed to for vertical alignment.
		    if (controller.container is IFloatController)
				IFloatController(controller.container).numWraps++;
			
			parcels = newparcels;
			CONFIG::debug { validate(); }
		//	trace("after");
		//	traceOut();
		}
		
		private function unintersect(result:Array, parcel:Parcel, wrap:Rectangle, verticalJump:Boolean):void
		{
			// trace("LPL: unintersect");
			var area:Rectangle = parcel;
			var columnCoverage:int = parcel.columnCoverage;
			
			// Return the unintersected part of the area that wrap does not
			// intersect as an array of parcels
			var r:Rectangle = area.intersection(wrap);
			
			// split into zero, one, two or three chunks
			var addTopParcel:Boolean = r.top > area.top;
			var addMidParcel:Boolean = !verticalJump && ((r.left - area.left > Math.max(area.right - r.right, MIN_WIDTH)) || (area.right > r.right && area.right - r.right > MIN_WIDTH));
			var addBotParcel:Boolean = area.bottom > r.bottom;
			
			var newCoverage:int;	// scratch for computing coverage
			
			// Space above the intersection
			if (addTopParcel)
			{
				newCoverage = columnCoverage;
				if (addBotParcel || addMidParcel)
					newCoverage &= ~Parcel.BOT_OF_COLUMN;
				columnCoverage &= ~Parcel.TOP_OF_COLUMN;
				
				result.push(new Parcel(area.left, area.top, area.width, r.top - area.top, parcel.controller, parcel.column, newCoverage));
			}
			// Space along the left side of the intersection, if the width is great than on the right
			if (addMidParcel)
			{
				newCoverage = columnCoverage;
				if (addBotParcel)
					newCoverage &= ~Parcel.BOT_OF_COLUMN;
				columnCoverage &= ~Parcel.TOP_OF_COLUMN;
				
				if (r.left - area.left > Math.max(area.right - r.right, MIN_WIDTH))
					result.push(new Parcel(area.left, r.top, r.left - area.left, r.height, parcel.controller,  parcel.column, newCoverage));
				// Space along the right side if that's bigger
				else // if (area.right > r.right && area.right - r.right > MIN_WIDTH)
					result.push(new Parcel(r.right, r.top, area.right - r.right, r.height, parcel.controller, parcel.column, newCoverage));
			}
			// Space along the bottom
			if (addBotParcel)
				result.push(new Parcel(area.left, r.bottom, area.width, area.bottom - r.bottom, parcel.controller, parcel.column, columnCoverage));
		}

		/** @private */
		CONFIG::debug private function validate():void
		{
			// Check that there are no empty parcels, and that no parcels intersect any other parcel.
			for (var idx:int; idx < numParcels; idx++)
			{
				var i:Parcel = getParcelAtIndex(idx);
				var parcelRect:Rectangle = i;
				
				assert(parcelRect.height != 0 && parcelRect.width != 0, "empty parcel");
			//	assert(parcelRect.width > MIN_WIDTH, "parcel too small"); we can get a small parcel if we explicitly ask for it (e.g., for a small float)
				for (var nidx:int; nidx < numParcels; nidx++)
				{
					var n:Parcel = getParcelAtIndex(nidx);
					assert(i == n || i.controller != n.controller || !parcelRect.intersects(n), "parcels intersect");
				}
			}
		}
		
		CONFIG::debug {
			private function traceOut():void
			{
				trace("parcels\n");
				for (var idx:int; idx < numParcels; idx++)
				{
					var p:Parcel = getParcelAtIndex(idx);
					trace(idx.toString(), ":", p, "controller", p.controller);
				}
		//		traceRects("wraps\n", wraps);
			}
		}

		CONFIG::debug {
			private function traceRects(description:String, rects:Array):void
			{
				trace(description);
				var count:int = 0;
				for each (var i:Rectangle in rects)
				{
					trace(count.toString(), i);
					count++;
				}
			}
		}
		
		CONFIG::debug {
			private function traceParcels(description:String, parcels:Array /* of Parcel */):void
			{
				trace(description);
				var count:int = 0;
				for each (var i:Parcel in parcels)
				{
					trace(count.toString(), ":", i, "controller", i.controller);
					count++;
				}
			}
		}

	}	//end class
} //end package
