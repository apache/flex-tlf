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
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.formats.FlowElementDisplayType;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormatValueHolder;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	[IMXMLObject]	

/**
 * The text in a flow is stored in tree form with the elements of the tree representing logical
 * divisions within the text. The FlowElement class is the abstract base class of all the objects in this tree.
 * FlowElement objects represent paragraphs, spans of text within paragraphs, and
 * groups of paragraphs.
 *
 * <p>The root of a composable FlowElement tree is always a TextFlow object. Leaf elements of the tree are always 
 * subclasses of the FlowLeafElement class. All leaves arranged in a composable TextFlow have a ParagraphElement ancestor.
 * </p> 
 *
 * <p>You cannot create a FlowElement object directly. Invoking <code>new FlowElement()</code> throws an error 
 * exception.</p>
 *
 * @playerversion Flash 10
 * @playerversion AIR 1.5
 * @langversion 3.0
 * 
 * @see FlowGroupElement
 * @see FlowLeafElement
 * @see InlineGraphicElement
 * @see ParagraphElement
 * @see SpanElement
 * @see TextFlow
 */
	public class FlowElement implements ITextLayoutFormat
	{
		/** every FlowElement has at most one parent */
		private var _parent:FlowGroupElement;
		
		/** format settings on this FlowElement */
		private var _formatValueHolder:FlowValueHolder;
		
		/** @private computed formats applied to the element */
		protected var _computedFormat:ITextLayoutFormat;
		
		/** start, _start of element, relative to parent.  */
		private var _parentRelativeStart:int = 0;		
		
		/** _textLength (number of chars) in the element, including child content */
		private var _textLength:int = 0;	
	
		/** Base class - invoking <code>new FlowElement()</code> throws an error exception.
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*/
		public function FlowElement()
		{
			// not a valid FlowElement class
			if (abstract)
				throw new Error(GlobalSettings.resourceStringFunction("invalidFlowElementConstruct"));
		}
		
		/** Called for MXML objects after the implementing object has been created and all component properties specified on the MXML tag have been initialized. 
		 * @param document The MXML document that created the object.
		 * @param id The identifier used by document to refer to this object.
		 **/
		public function initialized(document:Object, id:String):void
		{
			this.id = id;
		}

		/** Returns true if the class is an abstract base class,
		 * false if its OK to construct. Attempting to instantiate an
		 * abstract FlowElement class will cause an exception.
		 * @return Boolean 	true if this is an abstract class
		 * @private
		 */
		protected function get abstract():Boolean
		{
			return true;
		}
		
		/** Allows you to read and write user styles on a FlowElement object.  Note that reading this property
		* makes a copy of the user-styles dictionary. 
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
		*
		*/
		public function get userStyles():Object
		{
			var styles:Object = _formatValueHolder == null ? null : _formatValueHolder.userStyles;
			return styles ? Property.shallowCopy(styles) : null;
		}
		public function set userStyles(styles:Object):void
		{
			var newStyles:Object;
			if (styles)
			{
				newStyles = new Object();
				for (var val:Object in styles)
					newStyles[val] = styles[val];
			}
			writableTextLayoutFormatValueHolder().userStyles = newStyles;
			modelChanged(ModelChange.USER_STYLE_CHANGED,0,this.textLength,true);
		}
		
		/** Returns the core styles on a FlowElement instance. Returns a copy of the core styles. 
		 *  
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 *
		 */
		 
		public function get coreStyles():Object
		{
			var styles:Object = _formatValueHolder == null ? null : _formatValueHolder.coreStyles;
			return styles ? Property.shallowCopy(styles) : null;
		}
		
		/** @private */
		tlf_internal function setCoreStylesInternal(styles:Object):void
		{
			var newStyles:Object;
			if (styles)
			{
				newStyles = new Object();
				for (var val:Object in styles)
				{
					var value:* = styles[val];
					if (value != undefined)
						newStyles[val] = value;
				}
			}
			writableTextLayoutFormatValueHolder().coreStyles = newStyles;
			formatChanged();		
		}
		

		public function set linkNormalFormat(value:*):void
		{ setStyle(LinkElement.LINK_NORMAL_FORMAT_NAME,value); }
		/** Defines the formatting attributes used for links in normal state. This value will cascade down the hierarchy and apply to any links that are descendants.
		 * Equivalent to setStyle(linkNormalFormat,value).  Expects a dictionary of properties.  Converts an array of objects with key and value as members to a dictionary. */
		public function get linkNormalFormat():*
		{ return getStyle(LinkElement.LINK_NORMAL_FORMAT_NAME); }
		

		public function set linkActiveFormat(value:*):void
		{ setStyle(LinkElement.LINK_ACTIVE_FORMAT_NAME,value); }
		/** Defines the formatting attributes used for links in active state, when the mouse is down on a link. This value will cascade down the hierarchy and apply to any links that are descendants.
		 * Equivalent to setStyle(linkActiveFormat,value).  Expects a dictionary of properties.  Converts an array of objects with key and value as members to a dictionary. */
		public function get linkActiveFormat():*
		{ return getStyle(LinkElement.LINK_ACTIVE_FORMAT_NAME); }
		

		public function set linkHoverFormat(value:*):void
		{ setStyle(LinkElement.LINK_HOVER_FORMAT_NAME,value); }
		/** Defines the formatting attributes used for links in hover state, when the mouse is within the bounds (rolling over) a link. This value will cascade down the hierarchy and apply to any links that are descendants.
		 * Equivalent to setStyle(linkHoverFormat,value).  Expects a dictionary of properties.  Converts an array of objects with key and value as members to a dictionary. */
		public function get linkHoverFormat():*
		{ return getStyle(LinkElement.LINK_HOVER_FORMAT_NAME); }
		
		/** Compare the userStyles of this with otherElement's userStyles. 
		 *
		 * @param otherElement the FlowElement object with which to compare user styles
		 *
		 * @return 	true if the user styles are equal; false otherwise.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
	 	 * @includeExample examples\FlowElement_equalUserStylesExample.as -noswf
	 	 * 
	 	 * @see #getStyle()
	 	 * @see #setStyle()
	 	 * @see #userStyles
		 */
		public function equalUserStyles(otherElement:FlowElement):Boolean
		{
			var myStyles:Object = _formatValueHolder ? _formatValueHolder.userStyles : null;
			var elemStyles:Object = otherElement._formatValueHolder ? otherElement._formatValueHolder.userStyles : null;
			return Property.equalStyleObjects(myStyles,elemStyles);
		}
		
		/** @private Compare the styles of two elements for merging.  Return true if they can be merged. */
		tlf_internal function equalStylesForMerge(elem:FlowElement):Boolean
		{
			return this.id == elem.id && this.styleName == elem.styleName && TextLayoutFormat.isEqual(elem.format,format) && equalUserStyles(elem);
		}
		
		/**
		 * Makes a copy of this FlowElement object, copying the content between two specified character positions.
		 * It returns the copy as a new FlowElement object. Unlike <code>deepCopy()</code>, <code>shallowCopy()</code> does
		 * not copy any of the children of this FlowElement object. 
		 * 
		 * <p>With no arguments, <code>shallowCopy()</code> defaults to copying all of the content.</p>
		 *
		 * @param relativeStart	The relative text position of the first character to copy. First position is 0.
		 * @param relativeEnd	The relative text position of the last character to copy. A value of -1 indicates copy to end.
		 *
		 * @return 	the object created by the copy operation.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @includeExample examples\FlowElement_shallowCopyExample.as -noswf
		 *
	 	 * @see #deepCopy()
	 	 */
		 
		public function shallowCopy(relativeStart:int = 0, relativeEnd:int = -1):FlowElement
		{
			if (relativeEnd == -1)
				relativeEnd = textLength;
				
			var retFlow:FlowElement = new (getDefinitionByName(getQualifiedClassName(this)) as Class);
			retFlow.styleName = styleName;
			retFlow.id = id;	// ???? copy me ?????
			if (_formatValueHolder !=  null)
				retFlow._formatValueHolder = new FlowValueHolder(_formatValueHolder);
			return retFlow;
		}

		/**
		 * Makes a deep copy of this FlowElement object, including any children, copying the content between the two specified
		 * character positions and returning the copy as a FlowElement object.
		 * 
		 * <p>With no arguments, <code>deepCopy()</code> defaults to copying the entire element.</p>
		 * 
		 * @param relativeStart	relative text position of the first character to copy. First position is 0.
		 * @param relativeEnd	relative text position of the last character to copy. A value of -1 indicates copy to end.
		 *
		 * @return 	the object created by the deep copy operation.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @includeExample examples\FlowElement_deepCopyExample.as -noswf
	 	 * 
	 	 * @see #shallowCopy()
		 */
		 
		public function deepCopy(relativeStart:int = 0, relativeEnd:int = -1):FlowElement
		{
			if (relativeEnd == -1)
				relativeEnd = textLength;
				
			return shallowCopy(relativeStart, relativeEnd);
		}
		
		/** 
		 * Gets the specified range of text from a flow element.
		 * 
		 * @param relativeStart The starting position of the range of text to be retrieved, relative to the start of the FlowElement
		 * @param relativeEnd The ending position of the range of text to be retrieved, relative to the start of the FlowElement, -1 for up to the end of the element
		 * @param paragraphSeparator character to put between paragraphs
		 * 
		 * @return The requested text.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 */
		public function getText(relativeStart:int=0, relativeEnd:int=-1, paragraphSeparator:String="\n"):String
		{
			return "";
		}

		/** 
		 * Splits this FlowElement object at the position specified by the <code>relativePosition</code> parameter, which is
		 * a relative position in the text for this element. This method splits only SpanElement and FlowGroupElement 
		 * objects.
		 *
		 * @param relativePosition the position at which to split the content of the original object, with the first position being 0.
		 * 
		 * @return	the new object, which contains the content of the original object, starting at the specified position.
		 *
		 * @throws RangeError if <code>relativePosition</code> is greater than <code>textLength</code>, or less than 0.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 */
		 
		public function splitAtPosition(relativePosition:int):FlowElement
		{
			if ((relativePosition < 0) || (relativePosition > textLength))
				throw RangeError(GlobalSettings.resourceStringFunction("invalidSplitAtPosition"));
			return this;
		}
		
		/** @private Set to indicate the element may be "bound" in Flex - only used on FlowLeafElement and SubParagraphBlock elements. */
		tlf_internal function get bindableElement():Boolean
		{ return getPrivateStyle("bindable") == true; }
		
		/** @private */
		tlf_internal function set bindableElement(value:Boolean):void
		{ setPrivateStyle("bindable", value); }

		
		/** Merge flow element into previous flow element if possible. @private
		 * @Return true--> did the merge
		 */
		 
		tlf_internal function mergeToPreviousIfPossible():Boolean
		{
			return false;
		}
		
		/** @private 
		 * Create and initialize the FTE data structure that corresponds to the FlowElement
		 */
		tlf_internal function createContentElement():void
		{
			// overridden in the base class -- we should not get here
			CONFIG::debug { assert(false,"invalid call to createContentElement"); }
		}
		
		/** @private 
		 * Release the FTE data structure that corresponds to the FlowElement, so it can be gc'ed
		 */
		tlf_internal function releaseContentElement():void
		{
			// overridden in the base class -- we should not get here
			CONFIG::debug { assert(false,"invalid call to createContentElement"); }
		}

		/** @private 
		 * True if it is safe to release the corresponding FTE data structure.
		 */
		tlf_internal function canReleaseContentElement():Boolean
		{
			return true;
		}
		
		/** Returns the parent of this FlowElement object. Every FlowElement has at most one parent.
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*/
	 	
		public function get parent():FlowGroupElement
		{ return _parent; }
		
		/** @private parent setter. */
		
		tlf_internal function setParentAndRelativeStart(newParent:FlowGroupElement,newStart:int):void
		{ _parent = newParent; _parentRelativeStart = newStart; attributesChanged(false); }
		
				
		/** @private Used when the textBlock.content is already correctly configured. */
		tlf_internal function setParentAndRelativeStartOnly(newParent:FlowGroupElement,newStart:int):void
		{ _parent = newParent;  _parentRelativeStart = newStart; }
			
		/**
		 * Returns the total length of text owned by this FlowElement object and its children.  If an element has no text, the 
		 * value of <code>textLength</code> is usually zero. 
		 * 
		 * <p>ParagraphElement objects have a final span with a paragraph terminator character for the last 
		 * SpanElement object.The paragraph terminator is included in the value of the <code>textLength</code> of that 
		 * SpanElement object and all its parents.  It is not included in <code>text</code> property of the SpanElement
		 * object.</p>
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see #textLength
		 */
		 
		public function get textLength():int
		{ return _textLength; }
		
		/** @private textLength setter.  */
		tlf_internal function setTextLength(newLength:int):void
		{ _textLength = newLength; }	
		
		/** Returns the relative start of this FlowElement object in the parent. If parent is null, this value is always zero.  
		 * If parent is not null, the value is the sum of the text lengths of all previous siblings.
		 *
		 * @return offset
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 * 
	 	 * @see #textLength
		 */
		 
		public function get parentRelativeStart():int
		{ return _parentRelativeStart; }
		
		/** @private start setter. */
		tlf_internal function setParentRelativeStart(newStart:int):void
		{ _parentRelativeStart = newStart; }
		
		/** Returns the relative end of this FlowElement object in the parent. If the parent is null this is always equal to <code>textLength</code>.  If 
		 * the parent is not null, the value is the sum of the text lengths of this and all previous siblings, which is effectively
		 * the first character in the next FlowElement object.
		 *
		 * @return offset
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see FlowGroupElement
	 	 * @see #textLength
		 */
		 
		public function get parentRelativeEnd():int
		{ return _parentRelativeStart + _textLength; }
				
		/**
		 * Tag for the item, used for debugging.
		 */
		CONFIG::debug public function get name():String
		{
			return flash.utils.getQualifiedClassName(this);
		}
		
		/** Returns the ContainerFormattedElement that specifies its containers for filling. This ContainerFormattedElement
		 * object has its own columns and can control ColumnDirection and BlockProgression. 
		 *
		 * @return 	the ancestor, with its container, of this FlowElement object.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 * 
	 	 * @private
		 */
		 
		tlf_internal function getAncestorWithContainer():ContainerFormattedElement
		{
			var elem:FlowElement = this;
			while (elem)
			{
				var contElement:ContainerFormattedElement = elem as ContainerFormattedElement;
				if (contElement)
				{
					if (!contElement._parent || contElement.flowComposer)
						return contElement;
				}
				elem = elem._parent; 
			}
			return null;
		}
		
		
		/**
		 * @private
		 * Generic mechanism for fetching private data from the element.
		 * @param styleName	name of the property
		 */
		tlf_internal function getPrivateStyle(styleName:String):*
		{ return _formatValueHolder ? _formatValueHolder.getPrivateData(styleName) : undefined; }

		/**
		 * @private
		 * Generic mechanism for adding private data to the element.
		 * @param styleName	name of the property
		 * @param val value of the property
		 */
		tlf_internal function setPrivateStyle(styleName:String, val:*):void
		{
			if (getPrivateStyle(styleName) != val)
			{
				writableTextLayoutFormatValueHolder().setPrivateData(styleName,val);
				modelChanged(ModelChange.STYLE_SELECTOR_CHANGED,0,this.textLength);
			}
		}
		
		private static const idString:String ="id";

		/**
		 * Assigns an identifying name to the element, making it possible to set a style for the element
		 * by referencing the <code>id</code>. For example, the following line sets the color for
		 * a SpanElement object that has an id of span1:
		 *
		 * <listing version="3.0" >
		 * textFlow.getElementByID("span1").setStyle("color", 0xFF0000);
		 * </listing>
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see TextFlow#getElementByID()
		 */
		public function get id():String
		{ return getPrivateStyle(idString); }
		public function set id(val:String):void
		{ return setPrivateStyle(idString, val);	}
		
		private static const styleNameString:String ="styleName";

		/**
		 * Assigns an identifying class to the element, making it possible to set a style for the element
		 * by referencing the <code>styleName</code>. 
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get styleName():String
		{ return getPrivateStyle(styleNameString); }
		public function set styleName(val:String):void
		{ return setPrivateStyle(styleNameString, val);	}
		
		private static const impliedElementString:String = "impliedElement";
		/** @private */
		tlf_internal function get impliedElement():Boolean
		{
			return getPrivateStyle(impliedElementString) !== undefined;
		}
		/** @private */		
		tlf_internal function set impliedElement(value:Boolean):void
		{
			setPrivateStyle(impliedElementString, "true");
		}
				
		// **************************************** 
		// Begin TLFFormat Related code
		// ****************************************
		include "../formats/TextLayoutFormatInc.as"
		
		/** TextLayoutFormat properties applied directly to this element.
		 * <p>Each element may have properties applied to it as part of its format. Properties applied to this element override properties inherited from the parent. Properties applied to this element will in turn be inherited by element's children if they are not overridden on the child. If no properties are applied to the element, this will be null.</p>
		 * @see flashx.textLayout.formats.ITextLayoutFormat
		 */
		public function get format():ITextLayoutFormat
		{ return _formatValueHolder; }
		public function set format(value:ITextLayoutFormat):void
		{
			if (value == null)
			{
				if (_formatValueHolder == null || _formatValueHolder.coreStyles == null)
					return; // no change
				_formatValueHolder.coreStyles = null;
			}
			else
				writableTextLayoutFormatValueHolder().format = value;
			formatChanged();
		}
		
		private function writableTextLayoutFormatValueHolder():FlowValueHolder
		{
			if (_formatValueHolder == null)
				_formatValueHolder = new FlowValueHolder();
			return _formatValueHolder;
		}

		/** This gets called when an element has changed its attributes. This may happen because an
		 * ancestor element changed it attributes.
		 * @private 
		 */
		tlf_internal function formatChanged(notifyModelChanged:Boolean = true):void
		{
			if (notifyModelChanged)
				modelChanged(ModelChange.TEXTLAYOUT_FORMAT_CHANGED,0,textLength);
			// wipe out whatever values were cached
			_computedFormat = null;
		}
		
		/** 
		 * Concatenates tlf attributes with any other tlf attributes
		 * 
		 * Return the concatenated result
		 * 
		 * @private
		 */
		tlf_internal function get formatForCascade():ITextLayoutFormat
		{
			var tf:TextFlow = getTextFlow();
			if (tf)
			{
				var elemStyle:ITextLayoutFormat  = tf.getTextLayoutFormatStyle(this);
				if (elemStyle)
				{
					var localFormat:ITextLayoutFormat = format;
					if (localFormat == null)
						return elemStyle;
						
					var rslt:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder();
					rslt.apply(elemStyle);
					rslt.apply(localFormat);
					return rslt;
				}
			}
			return format;
		}
		
		/** @private  Shared scratch element for use in computedFormat methods only */
		static tlf_internal var _scratchTextLayoutFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder();
		
		/** 
		 * Returns the computed format attributes that are in effect for this element.
		 * Takes into account the inheritance of attributes from parent elements.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
		 * @see flashx.textLayout.formats.ITextLayoutFormat ITextLayoutFormat
		 */

		public function get computedFormat():ITextLayoutFormat
		{		
			if (!_computedFormat)
				doComputeTextLayoutFormat(formatForCascade);
			return _computedFormat;
		}
		
		/** @private */
		tlf_internal function doComputeTextLayoutFormat(formatForCascade:ITextLayoutFormat):void
		{
			var element:FlowElement = parent;
			var parentFormatForCascade:ITextLayoutFormat;
			
			if (element)
			{
				parentFormatForCascade = element.formatForCascade;
				if (TextLayoutFormat.isEqual(formatForCascade,TextLayoutFormat.emptyTextLayoutFormat) && TextLayoutFormat.isEqual(parentFormatForCascade,TextLayoutFormat.emptyTextLayoutFormat))
				{
					_computedFormat = element.computedFormat;
					return;
				}
			}
			
			var tf:TextFlow;
			// compute the cascaded attributes	
			_scratchTextLayoutFormat.format = formatForCascade;
			if (element)
			{
				if (parentFormatForCascade)
					_scratchTextLayoutFormat.concatInheritOnly(parentFormatForCascade);
				while (element.parent)
				{
					element = element.parent;
					var concatAttrs:ITextLayoutFormat = element.formatForCascade;
					if (concatAttrs)
						_scratchTextLayoutFormat.concatInheritOnly(concatAttrs);
				}
				tf = element as TextFlow;
			}
			else
				tf = this as TextFlow;
			var defaultFormat:ITextLayoutFormat;
			var defaultFormatHash:uint;
			if (tf)
			{
				defaultFormat = tf.getDefaultFormat();
				defaultFormatHash = tf.getDefaultFormatHash();
			}
			_computedFormat = TextFlow.getCanonical(_scratchTextLayoutFormat,defaultFormat,defaultFormatHash);
		}

		// **************************************** 
		// End CharacterFormat Related code
		// ****************************************

		
		/** @private */
		tlf_internal function attributesChanged(notifyModelChanged:Boolean = true):void
		{
			// TODO: REMOVE ME???
			formatChanged(notifyModelChanged);
		}
		
		/** Returns the value of the style specified by the <code>styleProp</code> parameter, which specifies
		 * the style name and can include any user style name. Accesses an existing span, paragraph, text flow,
		 * or container style. Searches the parent tree if the style's value is <code>undefined</code> on a 
		 * particular element.
		 *
		 * @param styleProp The name of the style whose value is to be retrieved.
		 *
		 * @return The value of the specified style. The type varies depending on the type of the style being
		 * accessed. Returns <code>undefined</code> if the style is not set.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @includeExample examples\FlowElement_getStyleExample.as -noswf
	 	 *
	 	 * @see #clearStyle()
		 * @see #setStyle()
		 * @see #userStyles
		 */
		public function getStyle(styleProp:String):*
		{
			if (TextLayoutFormat.description.hasOwnProperty(styleProp))
				return computedFormat[styleProp];
			return getUserStyleWorker(styleProp);
		}
		
		/** Sets the style specified by the <code>styleProp</code> parameter to the value specified by the
		* <code>newValue</code> parameter. You can set a span, paragraph, text flow, or container style, including
		* any user name-value pair.
		*
		* <p><strong>Note:</strong> If you assign a custom style, Text Layout Framework can import and export it but
		* compiled MXML cannot support it.</p>
		*
		* @param styleProp The name of the style to set.
		* @param newValue The value to which to set the style.
		*.
		* @playerversion Flash 10
		* @playerversion AIR 1.5
		* @langversion 3.0
		*
		* @includeExample examples\FlowElement_setStyleExample.as -noswf
		*		
		* @see #clearStyle()
		* @see #getStyle()
		* @see #userStyles
		*/
		public function setStyle(styleProp:String,newValue:*):void
		{
			if (TextLayoutFormat.description[styleProp] !== undefined)
				this[styleProp] = newValue;
			else
			{
				writableTextLayoutFormatValueHolder().setUserStyle(styleProp,newValue);
				modelChanged(ModelChange.USER_STYLE_CHANGED,0,this.textLength,true);
			}
		}
		
		/** Clears the style specified by the <code>styleProp</code> parameter from this FlowElement object. Sets 
		 * the value to <code>undefined</code>.
		 *
		 * @param styleProp The name of the style to clear.
		 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @includeExample examples\FlowElement_clearStyleExample.as -noswf
		 *
		 * @see #getStyle()
		 * @see #setStyle()
		 * @see #userStyles
		 * 
		 */
		public function clearStyle(styleProp:String):void
		{ setStyle(styleProp,undefined); }
		
		/** @private worker function - any styleProp */
		tlf_internal function getUserStyleWorker(styleProp:String):*
		{
			CONFIG::debug { assert(TextLayoutFormat.description[styleProp] === undefined,"bad call to getUserStyleWorker"); }
			
			if (_formatValueHolder != null)
			{
				var userStyle:* = _formatValueHolder.getUserStyle(styleProp)
				if (userStyle !== undefined)
					return userStyle;
			}
				
			var tf:TextFlow = getTextFlow();
			if (tf && tf.formatResolver)
			{
				userStyle = tf.formatResolver.resolveUserFormat(this,styleProp);
				if (userStyle !== undefined)
					return userStyle;
			}
			// TODO: does TextFlow need to ask a "psuedo parent"				
			return parent ? parent.getUserStyleWorker(styleProp) : undefined;
		}
		
		/**
		 * Called whenever the model is modified.  Updates the TextFlow and notifies the selection manager - if it is set.
		 * This method has to be called while the element is still in the flow
		 * @param changeType - type of change
		 * @param start - elem relative offset of start of damage
		 * @param len - length of damage
		 * @see flow.model.ModelChange
		 * @private
		 */
		tlf_internal function modelChanged(changeType:String, changeStart:int, changeLen:int, needNormalize:Boolean = true, bumpGeneration:Boolean = true):void
		{
			var tf:TextFlow = this.getTextFlow();
			if (tf)
				tf.processModelChanged(changeType, this, changeStart, changeLen, needNormalize, bumpGeneration);
		}
		
		/** @private */
		tlf_internal function appendElementsForDelayedUpdate(tf:TextFlow):void
		{ }
		
		/** @private */
		tlf_internal function applyDelayedElementUpdate(textFlow:TextFlow,okToUnloadGraphics:Boolean,hasController:Boolean):void
		{ }
						
		// **************************************** 
		// Begin display property Related code
		// ****************************************
		/**
		 * Indicates how the element should be composed. It may be either inline, and appear as part of a line, or be float, 
		 * in which case it appears in a container of its own.
		 * 
		 * @see text.elements.FlowElementDisplayType#INLINE
		 * @see text.elements.FlowElementDisplayType#FLOAT
		 * 
		 * This feature still in prototype phase - has to be the main namespace so it is accessible through mxml
		 * @private
		 */
		public function get display():String
		{
			return FlowElementDisplayType.INLINE;
		}
		
		// **************************************** 
		// End display property Related code
		// ****************************************	

 		// **************************************** 
		// Begin tracking property Related code
		// ****************************************

		/**
		 * Sets the tracking and is synonymous with the <code>trackingRight</code> property. Specified as a number of
		 * pixels or a percent of <code>fontSize</code>.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see #trackingRight
		 */
		public function set tracking(trackingValue:Object):void
		{
			trackingRight = trackingValue;
		}
		
		// **************************************** 
		// End tracking property Related code
		// ****************************************	

		// **************************************** 
		// Begin import helper code
		// ****************************************			

		/**
		 *  @private Create the default container for the element.
		 */
		tlf_internal function createGeometry(parentToBe:DisplayObjectContainer):void
		{
			return;
		}
		
		/** Strips white space from the element and its children, according to the whitespaceCollaspse
		 *  value that has been applied to the element or inherited from its parent.
		 *  If a FlowLeafElement's attrs are set to WhiteSpaceCollapse.PRESERVE, then collapse is
		 *  skipped.
		 *  @see text.formats.WhiteSpaceCollapse
		 * @private 
		 */
		tlf_internal function applyWhiteSpaceCollapse():void
		{
			if (_formatValueHolder && _formatValueHolder.whiteSpaceCollapse !== undefined)
				whiteSpaceCollapse = undefined;
			
			setPrivateStyle(impliedElementString, undefined);
		}
				
		// **************************************** 
		// End import helper code
		// ****************************************	

		// **************************************** 
		// Begin helper code for tables
		// ****************************************			
		
		/** Determines whether a particular FlowElement should be treated as a single selection.
		 * @private
		 */
		tlf_internal function isReadOnlyFlowElement():Boolean
		{
			return false;
		}

		/** Gets the highest parent that is a read only flow element
		 * @private
		 */		
		tlf_internal function getHighestReadOnlyFlowElement():FlowElement
		{
			var highestReadOnlyFlowElement:FlowElement = null;
			if (this.isReadOnlyFlowElement())
			{
				highestReadOnlyFlowElement = this;
			}
			
			var curFlowElement:FlowElement = parent;
			while (curFlowElement != null)
			{
				if (curFlowElement.isReadOnlyFlowElement())
				{
					highestReadOnlyFlowElement = curFlowElement;
				}
				curFlowElement = curFlowElement.parent;
			}
			return highestReadOnlyFlowElement;
		}
		
		// **************************************** 
		// End helper code for tables
		// ****************************************							

		// **************************************** 
		// Begin tree navigation code
		// ****************************************
		
		 /**
		 * Returns the start location of the element in the text flow as an absolute index. The first character in the flow
		 * is position 0.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 * 
		 * @includeExample examples\FlowElement_getAbsoluteStartExample.as -noswf
		 *
 		 * @return The index of the start of the element from the start of the TextFlow object.
 		 *
 		 * @see #parentRelativeStart
 		 * @see TextFlow
	 	 */
	 	 
		public function getAbsoluteStart():int
		{
			var rslt:int = parentRelativeStart;
			for (var elem:FlowElement = parent; elem; elem = elem.parent)
				rslt += elem.parentRelativeStart;
			return rslt;
		}
		
		/**
		 * Returns the start of this element relative to an ancestor element. Assumes that the
		 * ancestor element is in the parent chain. If the ancestor element is the parent, this is the
		 * same as <code>this.parentRelativeStart</code>.  If the ancestor element is the grandparent, this is the same as 
		 * <code>parentRelativeStart</code> plus <code>parent.parentRelativeStart</code> and so on.
		 * 
		 * @param ancestorElement The element from which you want to find the relative start of this element.
		 *
		 * @return  the offset of this element.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @includeExample examples\FlowElement_getElementRelativeStartExample.as -noswf
		 * 
		 * @see #getAbsoluteStart()
		 */
		 
		public function getElementRelativeStart(ancestorElement:FlowElement):int
		{
			var rslt:int = parentRelativeStart;
			for (var elem:FlowElement = parent; elem && elem != ancestorElement; elem = elem.parent)
				rslt += elem.parentRelativeStart;
			return rslt;
		}
		
		/**
		 * Climbs the text flow hierarchy to return the root TextFlow object for the element.
		 *
		 * @return	The root TextFlow object for this FlowElement object.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @includeExample examples\FlowElement_getTextFlowExample.as -noswf
	 	 *
	 	 * @see TextFlow
		 */
		 
		public function getTextFlow():TextFlow
		{
			// find the root element entry and either return null or the containing textFlow
			var elem:FlowElement = this;
			while (elem.parent != null)
				elem = elem.parent;
			return elem as TextFlow;		
		}	

		/**
		 * Returns the ParagraphElement object associated with this element. It looks up the text flow hierarchy and returns 
		 * the first ParagraphElement object.
		 *
		 * @return	the ParagraphElement object that's associated with this FlowElement object.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @includeExample examples\FlowElement_getParagraphExample.as -noswf
	 	 * 
	 	 * @see #getTextFlow()
	 	 * @see ParagraphElement
		 */
		 
		public function getParagraph():ParagraphElement
		{
			var rslt:FlowElement = this;
			while (rslt)
			{
				if (rslt is ParagraphElement)
					return rslt as ParagraphElement;
				rslt = rslt.parent;
			}
			return null;
		}
		
		
		/** 
		 * Returns the FlowElement object that contains this FlowElement object, if this element is contained within 
		 * an element of a particular type. 
		 * 
		 * Returns the FlowElement it is contained in. Otherwise, it returns null.
		 * 
		 * @private
		 *
		 * @param elementType	type of element for which to check
		 */
		public function getParentByType(elementType:Class):FlowElement
		{
			var curElement:FlowElement = parent;
			while (curElement)
			{
				if (curElement is elementType)
					return curElement;
				curElement = curElement.parent;
			}
			return null;
		}
		
		/** Returns the previous FlowElement sibling in the text flow hierarchy. 
		*
		* @includeExample examples\FlowElement_getPreviousSiblingExample.as -noswf
		*
		* @return 	the previous FlowElement object of the same type, or null if there is no previous sibling.
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*
	 	* @see #getNextSibling()
		*/
		public function getPreviousSibling():FlowElement
		{
			//this can happen if FE is on the scrap and doesn't have a parent. - gak 06.25.08
			if(!parent)
				return null;
				
			var idx:int = parent.getChildIndex(this);
			return idx == 0 ? null : parent.getChildAt(idx-1);
		}
		
		/** Returns the next FlowElement sibling in the text flow hierarchy. 
		*
		* @return the next FlowElement object of the same type, or null if there is no sibling.
		*
		* @includeExample examples\FlowElement_getNextSiblingExample.as -noswf
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*
	 	* @see #getPreviousSibling()
	 	*/
	 	
		public function getNextSibling():FlowElement
		{
			if (!parent)
				return null;

			var idx:int = parent.getChildIndex(this);
			return idx == parent.numChildren-1 ? null : parent.getChildAt(idx+1);
		}
		
		/** 
		* Returns the character at the specified position, relative to this FlowElement object. The first
		* character is at relative position 0.
		* 
		* @param relativePosition	The relative position of the character in this FlowElement object.
		* @return String containing the character.
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*
	 	* @includeExample examples\FlowElement_getCharAtPositionExample.as -noswf
	 	* 
	 	* @see #getCharCodeAtPosition()
	 	*/
		
		public function getCharAtPosition(relativePosition:int):String
		{
			return null;
		}
		
		/** Returns the character code at the specified position, relative to this FlowElement. The first
		* character is at relative position 0.
		*
		* @param relativePosition 	The relative position of the character in this FlowElement object.
		*
		* @return	the Unicode value for the character at the specified position.
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*
	 	* @includeExample examples\FlowElement_getCharCodeAtPositionExample.as -noswf
	 	*
	 	* @see #getCharAtPosition()
	 	*/
	 	
		public function getCharCodeAtPosition(relativePosition:int):int
		{
			var str:String = getCharAtPosition(relativePosition);
			return str && str.length > 0 ? str.charCodeAt(0) : 0;
		}
		
		/** @private return an element or matching idName. */
		tlf_internal function getElementByIDHelper(idName:String):FlowElement
		{
			if (this.id == idName)
				return this;
			return null;
		}
		
		/** @private return adding elements with matching styleName to an array. */
		tlf_internal function getElementsByStyleNameHelper(a:Array,styleName:String):void
		{
			if (this.styleName == styleName)
				a.push(this);
		}
		
		// **************************************** 
		// End tree navigation code
		// ****************************************	
		
		// **************************************** 
		// Begin tree modification support code
		// ****************************************	

		/**
		 * Update the FlowElement to account for text added before it.
		 *
		 * @param len	number of characters added (may be negative if deletion)
		 */
		private function updateRange(len:int): void
		{
			setParentRelativeStart(parentRelativeStart + len);
		}
		
		/** Update the FlowElements in response to an insertion or deletion.
		 *  The length of the element inserted to is updated, and the length of 
		 *  each of its ancestor element. Each of the elements following siblings
		 *  start index is updated (start index is relative to parent).
		 * @private
		 * @param startIdx		absolute index in flow where text was inserted
		 * @param len			number of characters added (negative if removed)
		 * updateLines			?? true if lines should be damaged??
		 * @private 
		 */
		tlf_internal function updateLengths(startIdx:int,len:int,updateLines:Boolean):void
		{
			setTextLength(textLength + len);		
			var p:FlowGroupElement = parent;	
			if (p)
			{
				// update the elements following this in parent's children				
				var idx:int = p.getChildIndex(this)+1;
				CONFIG::debug { assert(idx != -1,"bad parent in FlowElement.updateLengths"); }
				
				var pElementCount:int = p.numChildren;
				while (idx < pElementCount)
				{
					var child:FlowElement = p.getChildAt(idx++);
					child.updateRange(len);
				}
				
				// go up the tree to the root and update ancestor's lengths
				p.updateLengths(startIdx,len,updateLines);
			}
		}
		
		/** @private */
		tlf_internal function getEnclosingController(relativePos:int) : ContainerController
		{
			// CONFIG::debug { assert(pos <= length,"getEnclosingController - bad pos"); }
			
			var textFlow:TextFlow = getTextFlow();
			
			//more than likely, we are building up spans for the very first time.
			//the container has not yet been created
			if (textFlow == null || textFlow.flowComposer == null || textFlow.flowComposer.numLines == 0)
				return null;
			
			var curItem:FlowElement = this;
			while (curItem && (!(curItem is ContainerFormattedElement) || ContainerFormattedElement(curItem).flowComposer == null))
			{
				curItem = curItem.parent;
			}
			
			var flowComposer:IFlowComposer = ContainerFormattedElement(curItem).flowComposer;
			if (!flowComposer)
				return null;
				
			var controllerIndex:int = ContainerFormattedElement(curItem).flowComposer.findControllerIndexAtPosition(getAbsoluteStart() + relativePos,false);
			return controllerIndex != -1 ? flowComposer.getControllerAt(controllerIndex) : null;
		}

		
		/** @private */
		tlf_internal function deleteContainerText(endPos:int,deleteTotal:int):void
		{
			// update container counts
					
			if (getTextFlow())		// update container lengths only for elements that are attached to the rootElement
			{
				var absoluteEndPos:int = getAbsoluteStart() + endPos;
				var absStartIdx:int = absoluteEndPos-deleteTotal;
				
				while (deleteTotal > 0)
				{
					var charsDeletedFromCurContainer:int;
					var enclosingController:ContainerController = getEnclosingController(endPos-1);
					if (!enclosingController)
					{
						// The end of the deleted text may be overset, so it doesn't appear in a container.
						// Find the last container that contains the deleted text.
						enclosingController = getEnclosingController(endPos - deleteTotal);
						if (enclosingController)
						{
							var flowComposer:IFlowComposer = enclosingController.flowComposer;
							var myIdx:int = flowComposer.getControllerIndex(enclosingController);
							CONFIG::debug { assert(myIdx >= 0,"FlowElement.deleteContainerText: bad return from getContainerControllerIndex"); }
							while (myIdx+1 < flowComposer.numControllers && enclosingController.absoluteStart + enclosingController.textLength < endPos)
							{
								enclosingController = flowComposer.getControllerAt(myIdx+1);
								if (enclosingController.textLength)
									break;
								myIdx++;
							}
						}
						if (!enclosingController)
							break;
					}
					var enclosingControllerBeginningPos:int = enclosingController.absoluteStart;
					if (absStartIdx < enclosingControllerBeginningPos)
					{
						charsDeletedFromCurContainer = absoluteEndPos - enclosingControllerBeginningPos + 1;
					}
					else if (absStartIdx < enclosingControllerBeginningPos + enclosingController.textLength)
					{
						charsDeletedFromCurContainer = deleteTotal;
					} 
					// Container textFlowLength may contain fewer characters than the those to be deleted in case of overset text. 
					var containerTextLengthDelta:int = enclosingController.textLength < charsDeletedFromCurContainer ? enclosingController.textLength : charsDeletedFromCurContainer;
					if (containerTextLengthDelta <= 0)
						break;		// overset text is not in the last container -- we've deleted the container count, so exit
					// working backwards - can't call setTextLength as it examines previous controllers and gets confused in the composeCompleteRatio logic
					ContainerController(enclosingController).setTextLengthOnly(enclosingController.textLength -  containerTextLengthDelta);
					deleteTotal -= containerTextLengthDelta;
					absoluteEndPos -= containerTextLengthDelta;
					endPos -= containerTextLengthDelta;
				}
			}
		}
		
		/** @private */
		tlf_internal function normalizeRange(normalizeStart:uint,normalizeEnd:uint):void
		{
			// default is do nothing
		}
		
		/** Support for splitting FlowLeafElements.  Does a quick copy of _characterFormat if necessary.  @private */
		tlf_internal function quickCloneTextLayoutFormat(sibling:FlowElement):void
		{
			_formatValueHolder = sibling._formatValueHolder ? new FlowValueHolder(sibling._formatValueHolder) : null;
		}
			
		// **************************************** 
		// End tree modification support code
		// ****************************************	
		
		/** @private This API supports the inputmanager */
		tlf_internal function updateForMustUseComposer(textFlow:TextFlow):Boolean
		{ return false; }

		// **************************************** 
		// Begin debug support code
		// ****************************************	
		
		CONFIG::debug static private var debugDictionary:Dictionary = new Dictionary(true);
		CONFIG::debug static private var nextKey:int = 1;
		
		CONFIG::debug static public function getDebugIdentity(o:Object):String
		{
			if (debugDictionary[o] == null)
			{
				var s:String = flash.utils.getQualifiedClassName(o);
				if (s)
					s = s.substr( s.lastIndexOf(":")+1);
				else
					s = "";
				debugDictionary[o] = s + "." + nextKey.toString();
				nextKey++;
			}
			return debugDictionary[o];
		}
		
		/**
		 * Check FlowElement for internal consistency.
		 * @private
		 * Lots of internal checks are done on FlowElements, some are dependent
		 * on the type of element. 
		 * @return Number of errors found
		 */
		CONFIG::debug public function debugCheckFlowElement(depth:int = 0, extraData:String = ""):int
		{
			if (Debugging.verbose)
			{			
				if (depth == 0)
					trace("----------------------------------");

				trace("FlowElement:",depth.toString(),getDebugIdentity(this),"start:",parentRelativeStart.toString(),"length:",textLength.toString(),extraData);
			}
			return 0;
		}
		
		CONFIG::debug public static function elementPath(element:FlowElement):String
		{
			var result:String;
			
			if (element != null)
			{
				if (element.parent != null)
					result = elementPath(element.parent) + "." + element.name + "[" + element.parent.getChildIndex(element) + "]";
				else
					result = element.name;
			}
			return result;
		}

		/**
		 * debugging only - show element as string
		 */
		CONFIG::debug public function toString():String
		{
			return "flowElement:" + name + " start:" + parentRelativeStart.toString() + " absStart:" + this.getAbsoluteStart().toString() + " textLength:" + textLength.toString();			
		}
		// **************************************** 
		// End debug support code
		// ****************************************	

	}
}
