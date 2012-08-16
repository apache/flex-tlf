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
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.engine.FontMetrics;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextRotation;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.JustificationRule;
	import flashx.textLayout.property.EnumStringProperty;
	import flashx.textLayout.property.NumberOrPercentOrEnumProperty;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	/** The InlineGraphicElement class handles graphic objects that display inline in the text. 
	 * 
	 * <p>You can embed a graphic or any DisplayObject or specify a URl for the location of the graphic. 
	 * The <code>height</code> and <code>width</code> properties of InlineGraphicElement control the actual size 
	 * of the graphic to display.  These values also control how much space to allocate
	 * for the graphic in the TextLine object that contains the graphic.
	 * The <code>height</code> and <code>width</code> properties each can be one of:</p>
	 * <ol>
	 * <li>A number of pixels</li>
	 * <li>A percent of the measured size of the image</li>
	 * <li>The constant, "auto", which computes the size (Default value)</li>
	 * </ol>
	 * There are three properties, or accessors, pertaining to the width and height of a graphic:
	 * <ul>
	 * <li>The <code>width</code> and <code>height</code> properties</li>
	 * <li>The <code>measuredWidth</code> and <code>measuredHeight</code> properties, which are the width or height of the graphic at load time</li>
	 * <li>The <code>actualWidth</code> and <code>actualHeight</code> properties, which are the actual display and compose width and height of the graphic as computed from <code>width</code> or <code>height</code> and <code>measuredWidth</code> or <code>measuredHeight</code></li>
	 * </ul>
	 * <p>The values of the <code>actualWidth</code> and <code>actualHeight</code> properties are always zero until the graphic 
	 * is loaded.</p>
	 *
	 * <p>If <code>source</code> is specified as a URI, the graphic is loaded asynchronously. If it's a DisplayObject, TextLayout uses the <code>width</code> and 
	 * <code>height</code> at the time the graphic is set into the InlineGraphicElement object as <code>measuredHeight</code> and <code>measuredWidth</code>; 
	 * its width and height are read immediately.</p>
	 * <p><strong>Notes</strong>: For graphics that are loaded asynchronously the user must listen for a 
	 * StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE event on the TextFlow and call <code>IFlowComposer.updateAllControllers()</code> to have the 
	 * graphic appear. The value of <code>measuredWidth</code> and <code>measuredHeight</code> for graphics that are in the 
	 * process of loading is zero.</p>
	 *
	 * <p>Some inline graphics are animations or videos that possibly have audio. They begin to run the first time they are composed after they finish loading.  
	 * They don't stop running until the flowComposer on the TextFlow is set to null.  At that time they are stopped and unloaded.</p>
	 * 
	 * The following restrictions apply to InLineGraphicElement objects:
	 * <ol>
	 * 	<li>On export of TLFMarkup, source is converted to a string. If the graphic element is 
	 *		a class, the Text Layout Framework can't export it properly</li>.
	 *	<li>When doing a copy/paste operation of an InlineGraphicElement, if source can't be 
	 * 		used to create a new InLineGraphicElement, it won't be pasted.  For example if 
	 *		source is a DisplayObject, or if the graphic is set directly, it can't be 
	 *		duplicated.  Best results are obtained if the source is the class of an embedded graphic 
	 * 		though that doesn't export/import.</li>
	 * 	<li>InLineGraphicElement objects work in the factory (TextFlowTextLineFactory) only if 
	 * 		the source is a class or if you explicitly set the graphic to a loaded graphic. 
	 * 		InlineGraphic objects that require delayed loads generally do not show up.</li>
	 * </ol>
	 * @includeExample examples\InlineGraphicElementExample.as -noswf
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 * @see #actualHeight
	 * @see #actualWidth
	 * @see flash.display.DisplayObject DisplayObject
	 * @see flashx.textLayout.compose.IFlowComposer#updateAllControllers()
	 * @see flashx.textLayout.events.StatusChangeEvent StatusChangeEvent
	 * @see TextFlow
	 */
	public final class InlineGraphicElement extends FlowLeafElement
	{	
		private var _source:Object;
		
		private var _graphic:DisplayObject;
		
		private var _elementWidth:Number;
		private var _elementHeight:Number;

		// internal status of the graphic.  there are more status here than publicly shown
		private var _graphicStatus:Object;
		
		// set when its ok - must delay until on the stage for dynamically loaded images
		private var okToUpdateHeightAndWidth:Boolean;
		
		private var _width:*;
		private var _height:*;
		
		// stash away the actual width and height of the graphic
		private var _measuredWidth:Number;
		private var _measuredHeight:Number;
		
		private var _float:*;

		/** Constructor - create new InlineGraphicElement object
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 */
		 
		public function InlineGraphicElement():void
		{
			super();
			// The width/height on the FE.fe don't actually take until the InlineGraphicElement is loaded.
			okToUpdateHeightAndWidth = false;
			_measuredWidth = 0;
			_measuredHeight = 0;
			internalSetWidth(undefined);
			internalSetHeight(undefined);
			_float = floatPropertyDefinition.defaultValue;
			_graphicStatus = InlineGraphicElementStatus.LOAD_PENDING;
			setTextLength(1);
			_text = String.fromCharCode(0xFDEF);
		}
		
		/** @private */
		override tlf_internal function createContentElement():void
		{
			if (_blockElement)
				return;
				
			var graphicElement:GraphicElement = new GraphicElement();			
			_blockElement = graphicElement;
			CONFIG::debug { Debugging.traceFTECall(_blockElement,null,"new GraphicElement()"); }
			_blockElement.textRotation = String(rotationPropertyDefinition.defaultValue)
			CONFIG::debug { Debugging.traceFTEAssign(_blockElement,"textRotation",String(rotationPropertyDefinition.defaultValue)); }
			graphicElement.elementHeight = (_float != Float.NONE) ? 0 : elementHeight;
			CONFIG::debug { Debugging.traceFTEAssign(_blockElement,"elementHeight",graphicElement.elementHeight); }
			graphicElement.elementWidth = (_float != Float.NONE) ? 0 : elementWidth;
			CONFIG::debug { Debugging.traceFTEAssign(_blockElement,"elementWidth",graphicElement.elementWidth); }
			graphicElement.graphic = (_float != Float.NONE) ? new Sprite() : graphic;
			CONFIG::debug { Debugging.traceFTEAssign(graphicElement,"graphic",graphic); }	// needs float fix
			super.createContentElement();
	//		trace("text is ", _blockElement.rawText.charCodeAt(0), "length", _blockElement.rawText.length);
			_text = null;
		}
		
		/** @private */
		override tlf_internal function canReleaseContentElement():Boolean
		{
			return false;
		}
		
		/** @private */
		override tlf_internal function releaseContentElement():void
		{
			if (_blockElement == null || !canReleaseContentElement())
				return;
			_text = String.fromCharCode(0xFDEF);		// echo text property we get from FTE
			super.releaseContentElement();
		}
		
		// internal values for _graphicStatus.  It can also be an error code.
		/** load initiated */
		static private const LOAD_INITIATED:String = "loadInitiated";
		/** public status string for open event received status.  @see flash.display.LoaderInfo.Events.open */
		static private const OPEN_RECEIVED:String = "openReceived";
		/** load complete received status.  @see flash.display.LoaderInfo.Events.open */
		static private const LOAD_COMPLETE:String = "loadComplete";
		/** loaded from embed */
		static private const EMBED_LOADED:String = "embedLoaded";
		/** specified as a DisplayObject */
		static private const DISPLAY_OBJECT:String = "displayObject";
		/** null graphic */
		static private const NULL_GRAPHIC:String = "nullGraphic";
		
		
		private function getGraphicElement():GraphicElement
		{ 
			if (!_blockElement)
				createContentElement();
			return GraphicElement(_blockElement); 
		}
		
		private static var isMac:Boolean = (Capabilities.os.search("Mac OS") > -1);				
		
		/** The embedded graphic. 
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*/
	 	
		public function get graphic():DisplayObject
		{
			return _graphic;
		}
		private function setGraphic(value:DisplayObject):void
		{
			if (_blockElement)
			{
				// Update the graphicElement to match the new graphic value. If it's a float,
				// we set it to a placeholder in the ge.graphic in order to be able to navigate
				// to the element.  Without it, the FTE model will remove the atom and selection will not be
				// possible. - gak 12.12.08
				GraphicElement(_blockElement).graphic = (_float != Float.NONE) ? new Sprite() : value;
				CONFIG::debug { Debugging.traceFTEAssign(_blockElement,"graphic",GraphicElement(_blockElement).graphic); }
			}

			_graphic = value;
		// I think this should do a model change. But it will break paste because when we paste we do a reimport,
		// which will cause a delayed update, which will bump the generation number *after* the command. Which 
		// will cause undo of the command not to work.
		//	modelChanged(ModelChange.ELEMENT_MODIFIED,0,textLength);
		}
		
		/** Width used by composition for laying out text around the graphic. @private */
		tlf_internal function get elementWidth():Number
		{
			return _elementWidth;			
		}
		/** Width used by composition for laying out text around the graphic. @private */
		tlf_internal function set elementWidth(value:Number):void
		{
			if (_blockElement)
			{
				GraphicElement(_blockElement).elementWidth = (_float != Float.NONE) ? 0 : value;
				CONFIG::debug { Debugging.traceFTEAssign(GraphicElement(_blockElement),"elementWidth",GraphicElement(_blockElement).elementWidth); }
				
			}

			 _elementWidth = value;
			modelChanged(ModelChange.ELEMENT_MODIFIED,0,textLength,true,false);
		}
		
		/** Height used by composition for laying out text around the graphic. @private */
		tlf_internal function get elementHeight():Number
		{
			return _elementHeight;			
		}
		/** Height used by composition for laying out text around the graphic. @private */
		tlf_internal function set elementHeight(value:Number):void
		{
			if (_blockElement)
			{
				GraphicElement(_blockElement).elementHeight = (_float != Float.NONE) ? 0 : value;	
				CONFIG::debug { Debugging.traceFTEAssign(GraphicElement(_blockElement),"elementHeight",GraphicElement(_blockElement).elementHeight); }
			}
			_elementHeight = value;
			modelChanged(ModelChange.ELEMENT_MODIFIED,0,textLength,true,false);
		}
		
		/** Definition of the height property @private */
		static tlf_internal const heightPropertyDefinition:NumberOrPercentOrEnumProperty = new NumberOrPercentOrEnumProperty("height", FormatValue.AUTO, false, null, 0, 32000, "0%", "1000000%", FormatValue.AUTO );
		
		/** Definition of the width property @private */
		static tlf_internal const widthPropertyDefinition:NumberOrPercentOrEnumProperty = new NumberOrPercentOrEnumProperty("width", FormatValue.AUTO, false, null, 0, 32000, "0%", "1000000%", FormatValue.AUTO );
		
		/** Disabled due to player bug.  @private */
		static tlf_internal const rotationPropertyDefinition:EnumStringProperty = new EnumStringProperty("rotation", TextRotation.ROTATE_0, false, null, 
			TextRotation.ROTATE_0, TextRotation.ROTATE_90, TextRotation.ROTATE_180, TextRotation.ROTATE_270);		
		
		/** Definition of the float property @private */
		static tlf_internal const floatPropertyDefinition:EnumStringProperty = new EnumStringProperty("float", Float.NONE, false, null, 
			 Float.NONE, Float.LEFT, Float.RIGHT);
			
		/** The current status of the image. On each status change the owning TextFlow sends a StatusChangeEvent.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
		 * @return one of LOAD_PENDING, LOADING, SIZE_PENDING, READY, ERROR
		 * @see flashx.textLayout.elements.InlineGraphicElementStatus
		 * @see flashx.textLayout.events.StatusChangeEvent
		 */
		 
		public function get status():String
		{
			switch(_graphicStatus)
			{
				case LOAD_INITIATED:
				case OPEN_RECEIVED:
					return InlineGraphicElementStatus.LOADING;
				case LOAD_COMPLETE:
				case EMBED_LOADED:
				case DISPLAY_OBJECT:
				case NULL_GRAPHIC:
					return InlineGraphicElementStatus.READY;
				case InlineGraphicElementStatus.LOAD_PENDING:
				case InlineGraphicElementStatus.SIZE_PENDING:
					return String(_graphicStatus);
			}
			CONFIG::debug { assert(_graphicStatus is ErrorEvent,"unexpected _graphicStatus"); }
			return InlineGraphicElementStatus.ERROR; 
		}
		
		private function changeGraphicStatus(stat:Object):void
		{
			var oldStatus:String = status;
			_graphicStatus = stat;
			var newStatus:String = status;
			if (oldStatus != newStatus || stat is ErrorEvent)
			{
				var tf:TextFlow = getTextFlow();
				if (tf)
				{
					if (newStatus == InlineGraphicElementStatus.SIZE_PENDING)
						tf.processAutoSizeImageLoaded(this);
					tf.dispatchEvent(new StatusChangeEvent(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, false, false, this, newStatus, stat as ErrorEvent));
				}
			}
		}
				
		/** The width of the graphic. The value can be 'auto', a number of pixels or a percent of the measured width of the image.
		 * 
		 * <p>Legal values are flashx.textLayout.formats.FormatValue.AUTO and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Legal values as a number are from 0 to 32000.</p>
		 * <p>Legal values as a percent are numbers from 0 to 1000000.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined or "inherit" the InlineGraphicElement will use the default value of "auto".</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see #actualWidth
	 	 * @see #measuredWidth
	 	 */
		public function get width():*
		{ return _width; }
		public function set width(w:*):void
		{ 
			internalSetWidth(w);
			modelChanged(ModelChange.ELEMENT_MODIFIED,0,textLength);
		}
		
		/** The natural width of the graphic. This is the width of the graphic at load time.
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*
	 	* @see #actualWidth
	 	* @see #width
	 	*/
	 	
		public function get measuredWidth():Number
		{ return _measuredWidth; }
		
		/** The actual width in effect. This is the display and compose width that's computed from the
		* <code>width</code> and <code>measuredWidth</code> properties.
		*
		* <p>The values of the <code>actualWidth</code>property are computed according to the 
		* following table:</p>
		* <table class="innertable" width="100%">
		* <tr>
		*   <th>width property</th> 
		*   <th>actualWidth</th>
		* </tr>
		* <tr>
		*   <td>auto</td>
		*   <td>measuredWidth</td>
		* </tr>
		* <tr>
		*   <td>w a Percent</td>
		*   <td>w percent of measuredWidth</td>
		* </tr>
		* <tr>
		*   <td>w a Number</td>
		*   <td>w</td>
		* </tr>
		* </table>
		*
		* <p><strong>Notes</strong>: If the inline graphic is a DisplayObject, its width and height are read immediately.
		* If <code>measuredWidth</code> or <code>measuredHeight</code> are zero, then any auto calculations that would cause a divide by zero sets the result to zero.</p>
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*
	 	* @see #measuredWidth
	 	* @see #width
	 	*
	 	*/
	 	
		public function get actualWidth():Number
		{ return elementWidth; }
		
		private function widthIsComputed():Boolean
		{ return internalWidth is String; }
		
		private function get internalWidth():Object
		{ return _width === undefined ? widthPropertyDefinition.defaultValue : _width; }		

		private function computeWidth():Number
		{
			CONFIG::debug { assert(widthIsComputed(),"bad call to InlineGraphicElement.computeWidth"); }
			if (internalWidth == FormatValue.AUTO)
			{
				if (internalHeight == FormatValue.AUTO)
					return _measuredWidth;
				if (_measuredHeight == 0 || _measuredWidth == 0)
					return 0;
				// can't rely on height being calculated yet
				var effHeight:Number = heightIsComputed() ? computeHeight(): Number(internalHeight);
				return effHeight/_measuredHeight * _measuredWidth;
			}
			return widthPropertyDefinition.computeActualPropertyValue(internalWidth,_measuredWidth); 
		}
		
		private function internalSetWidth(w:*):void
		{
			_width = widthPropertyDefinition.setHelper(width,w);
			elementWidth = widthIsComputed() ? 0 : Number(internalWidth);
			if (okToUpdateHeightAndWidth && graphic)
			{
				if (widthIsComputed())
					elementWidth =  computeWidth();
				graphic.width = elementWidth;
				CONFIG::debug { Debugging.traceFTEAssign(graphic,"width",elementWidth); }
				if (internalHeight == FormatValue.AUTO)
				{
					elementHeight =  computeHeight();
					graphic.height = elementHeight;
					CONFIG::debug { Debugging.traceFTEAssign(graphic,"height",elementHeight); }
				}
			}
		}

		/** The height of the image. May be 'auto', a number of pixels or a percent of the measured height. 
		 *
		 * <p>Legal values are flashx.textLayout.formats.FormatValue.AUTO and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Legal values as a number are from 0 to 32000.</p>
		 * <p>Legal values as a percent are numbers from 0 to 1000000.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined or "inherit" the InlineGraphicElement will use the default value of "auto".</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		  * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see #actualHeight
	 	 * @see #measuredHeight
	 	 */
		public function get height():*
		{ return _height; }
		public function set height(h:*):void
		{
			internalSetHeight(h);
			modelChanged(ModelChange.ELEMENT_MODIFIED,0,textLength);
		}
		
		private function get internalHeight():Object
		{ return _height === undefined ? heightPropertyDefinition.defaultValue : _height; }
		
		/** @private - prototype phase only */
		tlf_internal function get float():*
		{
			return _float;
		}
		/** @private - prototype phase only */
		tlf_internal function set float(value:*):*
		{
			if (value === undefined)
				value = floatPropertyDefinition.defaultValue;
			value = floatPropertyDefinition.setHelper(float, value) as String;
			if (_float != value)
			{
				var origWasInline:Boolean = _float == Float.NONE;
				_float = value;
				
				if (_float != Float.NONE)		// it's float; move variables from fte back to floating so fte won't see them
				{
					//only apply the graphicElement width and height if the original graphicElement was not a placeHolder
					//failure to do so will result in a 0 width/height element.
					if(origWasInline && _blockElement)
					{
						var graphicElement:GraphicElement = GraphicElement(_blockElement);
						setGraphic(graphicElement.graphic);
						elementWidth = graphicElement.elementWidth;
						elementHeight = graphicElement.elementHeight;
					}
				}
				else 	// it's inline: move varibles back from floating to where fte will see them
				{
					_graphic.x = 0;		// clear out whatever repositioning was done by floats code
					_graphic.y = 0;
					setGraphic (_graphic);
					elementWidth = _elementWidth;
					elementHeight = _elementHeight;					
				}
				modelChanged(ModelChange.ELEMENT_MODIFIED,0,textLength);
			}					
		}
		
		/** The natural height of the graphic. This is the height of the graphic at load time.
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	* 
	 	* @see #actualHeight
	 	* @see #height
	 	*/
	 	
		public function get measuredHeight():Number
		{ return _measuredHeight; }
			
		/** The actual height in effect. This is the display and compose height that's computed from the
		* <code>height</code> and <code>measuredHeight</code> properties.
		*
		* <p>The values of the <code>actualHeight</code> property are computed according to the following table:</p>
		* <table class="innertable" width="100%">
		* <tr>
		*   <th>height property</th>
		*   <th>actualHeight</th>
		* </tr>
		* <tr>
		*   <td>auto</td>
		*   <td>measuredheight</td>
		* </tr>
		* <tr>
		*   <td>h a Percent</td>
		*   <td>h percent of measuredheight</td>
		* </tr>
		* <tr>
		*   <td>h a Number</td>
		*   <td>h</td>
		* </tr>
		* </table>
		* <p><strong>Notes</strong>: If the inline graphic is a DisplayObject, its width and height are read immmediately.
		* If <code>measuredWidth</code> or <code>measuredHeight</code> are zero, then any auto calculations that would cause a divide by zero sets the result to zero.</p>
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*
	 	* @see #height
	 	* @see #measuredHeight
	 	*/
	 	
		public function get actualHeight():Number
		{ return elementHeight; }
		
		private function heightIsComputed():Boolean
		{ return internalHeight is String; }
		
		private function computeHeight():Number
		{
			CONFIG::debug { assert(heightIsComputed(),"bad call to InlineGraphicElement.computeWidth"); }
			if (internalHeight == FormatValue.AUTO)
			{
				if (internalWidth == FormatValue.AUTO)
					return _measuredHeight;
				if (_measuredHeight == 0 || _measuredWidth == 0)
					return 0;
				// can't rely on width being calculated yet
				var effWidth:Number = widthIsComputed() ? computeWidth(): Number(internalWidth);
				return effWidth/_measuredWidth * _measuredHeight;
			}
			return heightPropertyDefinition.computeActualPropertyValue(internalHeight,_measuredHeight); 
		}
		
		private function internalSetHeight(h:*):void
		{
			_height = heightPropertyDefinition.setHelper(height,h);
			elementHeight = heightIsComputed() ? 0 : Number(internalHeight);
			if (okToUpdateHeightAndWidth && graphic != null)
			{
				if (heightIsComputed())
					elementHeight =  computeHeight();
				graphic.height = elementHeight;
				CONFIG::debug { Debugging.traceFTEAssign(graphic,"height",elementHeight); }

				if (internalWidth == FormatValue.AUTO)
				{
					elementWidth =  computeWidth();
					graphic.width = elementWidth;
					CONFIG::debug { Debugging.traceFTEAssign(graphic,"width",elementWidth); }
				}
			}
		}
		
		private function loadCompleteHandler(e:Event):void
		{			
			CONFIG::debug { Debugging.traceFTECall(null,null,"loadCompleteHandler",this); }
			removeDefaultLoadHandlers();
			CONFIG::debug { assert(okToUpdateHeightAndWidth == false,"invalid call to loadCompleteHandler"); }
			okToUpdateHeightAndWidth = true;
			
			var g:DisplayObject = graphic;
			_measuredWidth = g.width;
			_measuredHeight = g.height;
			
			if (!widthIsComputed())
				g.width  = elementWidth;
			if (!heightIsComputed())
				g.height = elementHeight;
				
			if (e is IOErrorEvent)
				changeGraphicStatus(e);
			else if (widthIsComputed() || heightIsComputed())
			{
				g.visible = false;
				// triggers a delayedElementUpdate
				changeGraphicStatus(InlineGraphicElementStatus.SIZE_PENDING);
			}
			else
				changeGraphicStatus(LOAD_COMPLETE);
		}
				
		private function openHandler(e:Event):void
		{
			changeGraphicStatus(OPEN_RECEIVED);
		}
		
		private function addDefaultLoadHandlers(loader:Loader):void
		{
			var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
			CONFIG::debug { Debugging.traceFTECall(loaderInfo,loader,"contentLoaderInfo"); }
			
			loaderInfo.addEventListener(Event.OPEN, openHandler, false, 0, true);
			CONFIG::debug { Debugging.traceFTECall(null,loaderInfo,"addEventListener",Event.OPEN, "openHandler", false, 0, true); }
			loaderInfo.addEventListener(Event.COMPLETE,loadCompleteHandler,false,0,true);	
			CONFIG::debug { Debugging.traceFTECall(null,loaderInfo,"addEventListener",Event.COMPLETE, "loadCompleteHandler", false, 0, true); }
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadCompleteHandler,false,0,true);	
			CONFIG::debug { Debugging.traceFTECall(null,loaderInfo,"addEventListener",IOErrorEvent.IO_ERROR, "loadCompleteHandler", false, 0, true); }
		}
		
		private function removeDefaultLoadHandlers():void
		{
			var loader:Loader = Loader(graphic);
			CONFIG::debug{ assert(loader != null,"bad call to removeDefaultLoadHandlers"); }
			loader.contentLoaderInfo.removeEventListener(Event.OPEN, openHandler);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadCompleteHandler);
		}
		
		/** Sets the source for the graphic. 
		 * 
		 * The value can be either a String that is interpreted as a URI, a Class that's interpreted as the class of an 
		 * embeddded DisplayObject, a DisplayObject instance, or a URLRequest. Creates a DisplayObject and,
		 * if the InlineGraphicElement object is added into a ParagraphElement in a TextFlow object, causes it to appear
		 * inline in the text.
		 *
		 * @includeExample examples\InlineGraphicElement_sourceExample.as -noswf
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 */
		 
		public function get source():Object
		{
			return _source;
		}
		public function set source(value:Object):void
		{
			stop(true);
			_source = value;
			modelChanged(ModelChange.ELEMENT_MODIFIED,0,textLength);
			changeGraphicStatus(InlineGraphicElementStatus.LOAD_PENDING);
		}
	
		/** @private */
		tlf_internal override function applyDelayedElementUpdate(textFlow:TextFlow,okToUnloadGraphics:Boolean,hasController:Boolean):void
		{
			CONFIG::debug { assert(textFlow != null,"ILG:applyDelayedElementUpdate: null textFlow"); }		
			if (_graphicStatus == InlineGraphicElementStatus.LOAD_PENDING)
			{
				// trace("FEX LOADING", this.toString());
				if (hasController)
				{
					var source:Object = _source;
					if (source is String)
					{
						var inlineGraphicResolver:Function = textFlow.configuration.inlineGraphicResolverFunction;
						if (inlineGraphicResolver != null)
							source = inlineGraphicResolver(this);
					}
					
					var elem:DisplayObject;
					if (source is String || source is URLRequest)
					{
						okToUpdateHeightAndWidth = false;
						var loader:Loader = new Loader();
						CONFIG::debug { Debugging.traceFTECall(loader,null,"new Loader()"); }

						// set the width/height on COMPLETE or IOError
						addDefaultLoadHandlers(loader);
						if (source is String)
						{
 							var myPattern:RegExp = /\\/g;  							
							var src:String = source as String;
							src = src.replace(myPattern, "/");
							//workaround for Watson bug 1896186.  FlashPlayer requres that file
							//names be encoded on Macintosh, but not on Windows.  Grouped this
							//bug with FlashPlayer Watson bug 1899687
							var pictURLReq:URLRequest;
							if (isMac)
							{
								pictURLReq = new URLRequest(encodeURI(src));
								CONFIG::debug { Debugging.traceFTECall(pictURLReq,null,"new URLRequest",encodeURI(src)); }
							}
							else
							{
								pictURLReq = new URLRequest(src);	
								CONFIG::debug { Debugging.traceFTECall(pictURLReq,null,"new URLRequest",src); }									
							}					
							loader.load(pictURLReq);
							CONFIG::debug { Debugging.traceFTECall(null,loader,"load",pictURLReq); }									
						}
						else
							loader.load(URLRequest(source));
								
						setGraphic(loader);		
						changeGraphicStatus(LOAD_INITIATED);
					}
					else if (source is Class)	// value is class --> it is an Embed
					{
						var cls:Class = source as Class;
						elem = DisplayObject(new cls());
						changeGraphicStatus(EMBED_LOADED);
					}
					else if (source is DisplayObject)
					{
						elem = DisplayObject(source);
						changeGraphicStatus(DISPLAY_OBJECT);
					}
					else
					{
						elem = new Shape();
						changeGraphicStatus(NULL_GRAPHIC);
					}
					
					// complete setup of width and height
					if (_graphicStatus != LOAD_INITIATED)
					{
						okToUpdateHeightAndWidth = true;
						_measuredWidth = elem ? elem.width : 0;
						_measuredHeight = elem ? elem.height : 0;

						if (widthIsComputed())
						{
							if (elem)
							{
								elem.width = elementWidth = computeWidth();
								CONFIG::debug { Debugging.traceFTEAssign(elem,"width",elem.width); }
							}
							else
								elementWidth = 0;
						}
						else
						{
							elem.width = Number(width);
							CONFIG::debug { Debugging.traceFTEAssign(elem,"width",elem.width); }
						}
							
						if (heightIsComputed())
						{
							if (elem)
							{
								elem.height = elementHeight = computeHeight();
								CONFIG::debug { Debugging.traceFTEAssign(elem,"height",elem.height); }
							}
							else
								elementHeight = 0;
						}
						else
						{
							elem.height = Number(height);
							CONFIG::debug { Debugging.traceFTEAssign(elem,"height",elem.height); }
						}
							
						setGraphic(elem);
					}
				}
			}
			else
			{
				if (_graphicStatus == InlineGraphicElementStatus.SIZE_PENDING)
				{
					// this is width/height auto case hasn't been set yet - the graphic is hidden!
					updateAutoSizes();
					graphic.visible = true;
					changeGraphicStatus(LOAD_COMPLETE);
				}
				if (!hasController)
				{
					// shutdown the audio on any movie clips
					stop(okToUnloadGraphics);
				}
			}
		}
		
		/** @private This API supports the inputmanager */
		tlf_internal override function updateForMustUseComposer(textFlow:TextFlow):Boolean
		{ 
			applyDelayedElementUpdate(textFlow,false,true);
			return status != InlineGraphicElementStatus.READY;
		}
		
		/** This function updates the size of the graphic element when the size is expressed as a percentage of the graphic's actual size. */
		private function updateAutoSizes():void
		{
			// some discussion about making this function public.  the idea is that if the graphic
			// changes size the client can force it to recompute.  however the measuredWidth and measuredHeight
			// of the graphic doesn't really exist anywhere.
			
			// when public can only call ths for certain values of _graphicStatus
			// if (_graphicStatus == NULL_GRAPHIC || _graphicStatus == LOAD_INITIATED || _graphicStatus == OPEN_RECEIVED)
			//	return;
				
			// if (widthIsComputed() || heightIsComputed())	
			{
				if (widthIsComputed())
				{
					elementWidth = computeWidth();
					graphic.width = elementWidth;
				}
				if (heightIsComputed())
				{
					elementHeight = computeHeight();
					graphic.height = elementHeight;
				}
			}
		}
		
		
		/** stop if its a movieclip */
		private function stop(okToUnloadGraphics:Boolean):Boolean
		{
			
			// watch for changing the source while we've got an event listener on the current graphic
			// if so cancel the load and remove the listeners
			if (_graphicStatus == OPEN_RECEIVED || _graphicStatus == LOAD_INITIATED)
			{
				try
				{
					Loader(graphic).close();	// cancels in process load
				}
				catch (e:Error)
				{ /* ignore */ }
				removeDefaultLoadHandlers();
			}

			// shutdown any running movieclips - this graphic will no longer be referenced
			// for graphics that the client has passed us - just ignore they own the responsibliity
			if (_graphicStatus != DISPLAY_OBJECT)
			{
				if (okToUnloadGraphics)
				{
					recursiveShutDownGraphic(graphic);
					setGraphic(null);
				}
				if (widthIsComputed())
					elementWidth = 0;
				if (heightIsComputed())
					elementHeight = 0;
				changeGraphicStatus(InlineGraphicElementStatus.LOAD_PENDING);
			}
			return true;
		}
		
		// searches through the graphic and stops any playing grpahics
		private static function recursiveShutDownGraphic(graphic:DisplayObject):void
		{
			if (graphic is Loader)
				Loader(graphic).unloadAndStop();
			else if (graphic)
			{
				var container:DisplayObjectContainer = graphic as DisplayObjectContainer;
				if (container)
				{
					for (var idx:int = 0; idx < container.numChildren; idx++)
					{
						recursiveShutDownGraphic(container.getChildAt(idx));
					}
				}

				if (graphic is MovieClip)
					MovieClip(graphic).stop();
			}
		}
		
		/** @private */
		tlf_internal override function getEffectiveFontSize():Number
		{
			if (float != Float.NONE)
				return 0;
			var defaultLeading:Number = super.getEffectiveFontSize();
			return Math.max(defaultLeading, elementHeight);
		}
		
		/** Returns the actual ascent of the image. Used for computing baselines when they are ascent.  @private */
		tlf_internal function getEffectiveAscent():Number
		{
			if (float != Float.NONE)
				return 0;
				
			return elementHeight + GraphicElement(_blockElement).elementFormat.baselineShift;
		}
		
		/** Returns the typographic ascent of the image (i.e. relative to the line's Roman baseline). @private */
		tlf_internal function getTypographicAscent(textLine:TextLine):Number
		{
			if (float != Float.NONE)
				return 0;
				
			var effectiveHeight:Number = elementHeight;
			
			var dominantBaselineString:String;
			if(this._computedFormat.dominantBaseline != FormatValue.AUTO)
			{
				dominantBaselineString = this._computedFormat.dominantBaseline;
			}
			else
			{
				dominantBaselineString = this.getParagraph().getEffectiveDominantBaseline();
			}
			
			var graphicElement:GraphicElement = GraphicElement(_blockElement);
			var alignmentBaseline:String = (graphicElement.elementFormat.alignmentBaseline == flash.text.engine.TextBaseline.USE_DOMINANT_BASELINE ? dominantBaselineString : graphicElement.elementFormat.alignmentBaseline);
				
			var top:Number=0;

			// Calcluate relative to dominant baseline; remains 0 for ASCENT and IDEOGRAPHIC_TOP
			if (dominantBaselineString == flash.text.engine.TextBaseline.IDEOGRAPHIC_CENTER)
				top += effectiveHeight/2;
			else if (dominantBaselineString == flash.text.engine.TextBaseline.IDEOGRAPHIC_BOTTOM || dominantBaselineString == flash.text.engine.TextBaseline.DESCENT || dominantBaselineString == flash.text.engine.TextBaseline.ROMAN)
				top += effectiveHeight;
				
			// re-jig to be relative to the ROMAN baseline rather than whatever baseline is used for alignment
			top += textLine.getBaselinePosition(flash.text.engine.TextBaseline.ROMAN) - textLine.getBaselinePosition(alignmentBaseline);
			
			// finally, account for baseline shift
			top += graphicElement.elementFormat.baselineShift; 
			
			return top;
		}
		
		/** @private */
		 public override function shallowCopy(startPos:int = 0, endPos:int = -1):FlowElement
		{
			if (endPos == -1)
				endPos = textLength;
				
			var retFlow:InlineGraphicElement = super.shallowCopy(startPos, endPos) as InlineGraphicElement;
			retFlow.source = source;
			retFlow.width = width;
			retFlow.height = height;
			retFlow.float = float;
			
			return retFlow;
		}

		/** @private */
		override protected function get abstract():Boolean
		{
			return false;
		}		
		
		/** @private */
		tlf_internal override function appendElementsForDelayedUpdate(tf:TextFlow):void
		{ 
			if (_graphicStatus == InlineGraphicElementStatus.LOAD_PENDING || _graphicStatus == InlineGraphicElementStatus.SIZE_PENDING || !tf.flowComposer || tf.flowComposer.numControllers == 0)
				tf.appendOneElementForUpdate(this);
		}
		
		/** @private */
		tlf_internal override function calculateStrikeThrough(tLine:TextLine, blockProgression:String, metrics:FontMetrics):Number
		{
			if (!this.graphic || status != InlineGraphicElementStatus.READY)
				return super.calculateStrikeThrough(tLine,blockProgression,metrics);
				
			var stOffset:Number = 0;
		//	trace(spanBounds.y);
		//	trace(this.graphic.getBounds(tLine));
			var myBounds:Rectangle = this.graphic.getBounds(tLine);
			
			if(blockProgression != BlockProgression.RL)
			{
				stOffset = myBounds.y + this.elementHeight/2;
			}
			else
			{
				var line:TextFlowLine = tLine.userData as TextFlowLine;
				var elemIdx:int = this.getAbsoluteStart() - line.absoluteStart;
				if(tLine.getAtomTextRotation(elemIdx) != TextRotation.ROTATE_0)
					stOffset = myBounds.x + this.elementHeight/2;
				else
					stOffset = myBounds.x + this.elementWidth/2;
			}
			
			return blockProgression == BlockProgression.TB ? stOffset : -stOffset;
		}
		
		/** @private */
		tlf_internal override function calculateUnderlineOffset(stOffset:Number, blockProgression:String, metrics:FontMetrics, tLine:TextLine):Number
		{
			if (!this.graphic || status != InlineGraphicElementStatus.READY)
				return super.calculateUnderlineOffset(stOffset,blockProgression,metrics,tLine);
				
			var ulOffset:Number = 0;
			if(blockProgression == BlockProgression.TB)
				ulOffset = this.graphic.getBounds(tLine).bottom;
			else
				ulOffset = this.graphic.getBounds(tLine).right;
				
			ulOffset += metrics.underlineOffset + (metrics.underlineThickness/2);
			
			var para:ParagraphElement = this.getParagraph();
			var justRule:String = para.getEffectiveJustificationRule();
			if(justRule == JustificationRule.EAST_ASIAN)
				ulOffset += 1;
		
			return ulOffset;
		}
		// **************************************** 
		// Begin debug support code
		// ****************************************	
		
		/** @private */
		CONFIG::debug public override function toString():String
		{
			return super.toString() + " " + source;
		}
		
		/** @private */
		CONFIG::debug public override function debugCheckFlowElement(depth:int = 0, extraData:String = ""):int
		{
			// debugging function that asserts if the flow element tree is in an invalid state
			
			var rslt:int = super.debugCheckFlowElement(depth,extraData+" url:"+source);

			if (_blockElement)
				rslt += assert(textLength == GraphicElement(_blockElement).rawText.length,"image is different than its textElement");
			rslt += assert(this != getParagraph().getLastLeaf(),"last Leaf in paragraph cannot be image");

			return rslt;
		}
	}
}
