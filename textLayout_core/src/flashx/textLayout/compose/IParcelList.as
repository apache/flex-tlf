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
	
	import flashx.textLayout.container.ContainerController;
		
	[ExcludeClass]
	/** @private
	 * The area inside a text container is sub-divided into smaller areas available for
	 * text layout. These smaller areas within the container are called Parcels. The 
	 * ParcelList manages the parcels associated with a TextFlow during composition.
	 * 
	 * A container will always have at least one parcel, which corresponds to the container's
	 * bounding box. If the container has more than one column, each column appears as
	 * a parcel in the parcel list. If the container has wrap applied, the area around the
	 * wrap that is available for layout is divided into rectangular-shaped parcels.
	 * Lastly, parcels may be created during composition for use by flow elements that require
	 * layout within a specific geometry that may not be the same as the columns: for instance, 
	 * a straddle head, a table, or a sidehead.
	 */
	public interface IParcelList  
	{
		/** Initialize the parcel list from the flow composer. The parcel list will
		 * have the bounding box of the controller(s). If the controller has multiple
		 * columns, the parcel list will have a parcel for each column. If the 
		 * controller has wraps, the parcel list may have more parcels to work around
		 * the wrap areas.
		 * @param composer	composer we're using
		 * @param controllerEndIndex	compose through the end of this controller
		 * @param forceComposeToEnd		force composition to compose all lines of the last controller, even if it's scrollable (will not compose overset text)
		 */
		function beginCompose(composer:IFlowComposer, controllerEndIndex:int, forceComposeToEnd:Boolean):void;
		
		/** Callback function to notify clients that we're advancing forward to the next parcel. */
		function get notifyOnParcelChange():Function;
		function set notifyOnParcelChange(val:Function):void
		
		/** Return the left side coordinate of the current parcel.
		 */
		function get left():Number;
		
		/** Return the right side coordinate of the current parcel.
		 */
		function get right():Number;
		
		/** Return the top edge coordinate of the current parcel.
		 */
		function get top():Number;
		
		/** Return the bottom edge coordinate of the current parcel.
		 */
		function get bottom():Number;
		
		/** Return the width of the current parcel.
		 */
		function get width():Number;
		
		/** Return the height of the current parcel.
		 */
		function get height():Number;
		
		/** Returns the column number of the current parcel. */
		function get columnIndex():int;
		
		/** Vertical location within the parcel, as an offset from the top
		 * of the parcel.
		 */
		function get totalDepth():Number;
		function addTotalDepth(value:Number):Number;
		
		/** Return the controller associated with the current parcel.
		 */
		function get controller():ContainerController;
		
		/** Return the current parcel. Null if we're at the end of the parcel list.
		 */
		function get currentParcel():Parcel;

		/** Advance to the next parcel; it will now be the current parcel.
		 * @return Boolean	false if there is no next parcel.
		 */
		function next():Boolean;
		
		/** Returns true if the current parcel is the last.
		 */
		function atLast():Boolean;
		
		/** Returns true if all parcels have been iterated: current parcel is past the last.
		 */
		function atEnd():Boolean;

		/** True if the current parcel is at the top of the column */
		function isColumnStart():Boolean;
		
		/** True if we are not wrapping to the composition logical width */
		function get explicitLineBreaks():Boolean;
		
		/** Create a new parcel within the parcel list, for an item with the
		 * specified geometry. The new parcel is set to the current parcel.
		 * @param parcel	geometry of the new parcel
		 * @param blockProgression direction of the text (horizontal or vertical)
		 * @param verticalJump	true if next parcel goes below this, false if it goes to the right or left
		 * @return Boolean	true if parcel could be create, false if it doesn't fit
		 * @see text.formats.BlockProgression
		 */
		function createParcel(parcel:Rectangle, blockProgression:String, verticalJump:Boolean):Boolean;

		/** Create a new parcel within the parcel list, for an item with the
		 * specified geometry. The new parcel is set to the current parcel.
		 * @param parcel	geometry of the new parcel
		 * @param blockProgression direction of the text (horizontal or vertical)
		 * @param verticalJump	true if next parcel goes below this, false if it goes to the right or left
		 * @return Boolean	true if parcel could be create, false if it doesn't fit
		 * @see text.formats.BlockProgression
		 */
		function createParcelExperimental(parcel:Rectangle, wrapType:String):Boolean;

		/**Return the width for a line that goes at the current vertical location,
		 * and could extend down for at least height pixels. Note that this function
		 * can change the current parcel, and the location within the parcel.
		 * @param height	amount of contiguous vertical space that must be available
		 * @param minWidth	amount of contiguous horizontal space that must be available 
		 * @return amount of contiguous horizontal space actually available
		 */
		function getLineSlug(slugRect:Rectangle,height:Number, minWidth:Number = 0):Boolean;
		
		function getComposeXCoord(slug:Rectangle):Number;
		function getComposeYCoord(slug:Rectangle):Number;
		function getComposeWidth(slug:Rectangle):Number;
		function getComposeHeight(slug:Rectangle):Number;
	}	//end interface
} //end package
