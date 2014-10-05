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
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.ListMarkerFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
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
		
		/** format settings on this FlowElement. @private */
		private var _format:FlowValueHolder;
		
		/** @private computed formats applied to the element */
		protected var _computedFormat:TextLayoutFormat;
			
		/** start, _start of element, relative to parent; tlf_internal to eliminate getter calls  */
		private var _parentRelativeStart:int = 0;		
		
		/** _textLength (number of chars) in the element, including child content; tlf_internal to eliminate getter calls */
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
		* makes a copy of the userStyles set in the format of this element. 
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
		*
		*/
		public function get userStyles():Object
		{ return _format ? _format.userStyles : null; }
		public function set userStyles(styles:Object):void
		{
			var val:String;
			// clear the existing userstyles
			for (val in userStyles)
				this.setStyle(val,undefined);
			
			// set the new ones
			for (val in styles)
			{
				if (!TextLayoutFormat.description.hasOwnProperty(val))
					this.setStyle(val,styles[val]);
			}
		}
		
		public function setBorderWidth(width:Number):void
		{
			this.borderBottomWidth = width;
			this.borderLeftWidth = width;
			this.borderRightWidth = width;
			this.borderTopWidth = width;
		}
		
		public function setBorderColor(color:uint):void
		{
			this.borderBottomColor = color;
			this.borderLeftColor = color;
			this.borderRightColor = color;
			this.borderTopColor = color;
		}
		
		/** Returns the <code>coreStyles</code> on this FlowElement.  Note that the getter makes a copy of the core 
		 * styles dictionary. The coreStyles object encapsulates the formats that are defined by TextLayoutFormat and are in TextLayoutFormat.description. The
		 * <code>coreStyles</code> object consists of an array of <em>stylename-value</em> pairs.
		 * 
		 * @see flashx.textLayout.formats.TextLayoutFormat
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get coreStyles():Object
		{ return _format ? _format.coreStyles : null; }
		
		/** Returns the styles on this FlowElement.  Note that the getter makes a copy of the  
		 * styles dictionary. The returned object encapsulates all styles set in the format property including core and user styles. The
		 * returned object consists of an array of <em>stylename-value</em> pairs.
		 * 
		 * @see flashx.textLayout.formats.TextLayoutFormat
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get styles():Object
		{ return _format ? _format.styles : null; }

		/** @private */
		tlf_internal function setStylesInternal(styles:Object):void
		{
			if (styles)
				writableTextLayoutFormat().setStyles(Property.shallowCopy(styles),false);
			else if (_format)
				_format.clearStyles();
				
			formatChanged();		
		}
		
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
			return Property.equalStyles(this.userStyles,otherElement.userStyles,null);
		}
		
		/** @private Compare the styles of two elements for merging.  Return true if they can be merged. */
		tlf_internal function equalStylesForMerge(elem:FlowElement):Boolean
		{
			return this.id == elem.id && this.typeName == elem.typeName && TextLayoutFormat.isEqual(elem.format,format);
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
			var retFlow:FlowElement = new (getDefinitionByName(getQualifiedClassName(this)) as Class);
			if (_format !=  null)
				retFlow._format = new FlowValueHolder(_format);
			
			CONFIG::debug { assert(retFlow.styleName == styleName,"Failed top copy styleName"); }
			CONFIG::debug { assert(retFlow.typeName == typeName,"Failed top copy typeName"); }
			CONFIG::debug { assert(retFlow.id == id,"Failed top copy id"); }

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
				relativeEnd = _textLength;
				
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
			if ((relativePosition < 0) || (relativePosition > _textLength))
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

		/** Returns the parent of this FlowElement object. Every FlowElement has at most one parent.
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*/
	 	
		public function get parent():FlowGroupElement
		{ 
			// must be final to prevent overrides for safe internal access to _parent
			return _parent; 
		}
		
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
		{
			// make final to prevent overrides and enable direct internal read access
			return _parentRelativeStart; 
		}
		
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
		{ return _format ? _format.getPrivateData(styleName) : undefined; }

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
				writableTextLayoutFormat().setPrivateData(styleName,val);
				modelChanged(ModelChange.STYLE_SELECTOR_CHANGED,this,0,this._textLength);
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
		
		private static const typeNameString:String ="typeName";

		/**
		 * Each FlowElement has a <code>typeName</code>.  <code>typeName</code> defaults to the string the <code>textLayoutFormat</code> TextConverter uses.  This API
		 * can be used to set a different <code>typeName</code> to a <code>FlowElement</code>.  Typically this is done to support <code>type</code> selectors in CSS.  
		 * 
		 * <p>See the <code>TEXT_FIELD_HTML_FORMAT</code> documentation for how this used..</p>
		 * 
		 * @see flashx.textLayout.conversion.TextConverter
		 * @see flashx.textLayout.conversion.TextConverter#TEXT_FIELD_HTML_FORMAT
		 * @see flashx.textLayout.conversion.IHTMLImporter
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get typeName():String
		{ 
			var typeName:String = getPrivateStyle(typeNameString); 
			return typeName ? typeName : defaultTypeName;
		}
		public function set typeName(val:String):void
		{ 
			// extra testing here to avoid saving defaultTypeName in privateStyles
			if (val != typeName)
				setPrivateStyle(typeNameString, val == defaultTypeName ? undefined : val);
		}
		
		/** @private */
		tlf_internal function get defaultTypeName():String
		{ return null; }
		
		private static const impliedElementString:String = "impliedElement";
		/** @private */
		tlf_internal function get impliedElement():Boolean
		{
			return getPrivateStyle(impliedElementString) !== undefined;
		}
		/** @private */		
		tlf_internal function set impliedElement(value:*):void
		{
			CONFIG::debug { assert(value === true || value === undefined,"Bad value to FlowElement.impliedElement"); }
			setPrivateStyle(impliedElementString, value);
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
		{ return _format; }
		public function set format(value:ITextLayoutFormat):void
		{
			if (value == _format)
				return;
			
			var oldStyleName:String = this.styleName;
			
			if (value == null)
				_format.clearStyles();
			else
				writableTextLayoutFormat().copy(value);
			formatChanged();
			
			if (oldStyleName != this.styleName)
				styleSelectorChanged();
		}
		
		/** @private */
		tlf_internal function writableTextLayoutFormat():FlowValueHolder
		{
			if (_format == null)
				_format = new FlowValueHolder();
			return _format;
		}

		/** This gets called when an element has changed its attributes. This may happen because an
		 * ancestor element changed it attributes.
		 * @private 
		 */
		tlf_internal function formatChanged(notifyModelChanged:Boolean = true):void
		{
			if (notifyModelChanged)
				modelChanged(ModelChange.TEXTLAYOUT_FORMAT_CHANGED,this,0,_textLength);
			// require recompute of computedFormat
			_computedFormat = null;
		}
		
		/** This gets called when an element has changed its style selection related attributes. This may happen because an
		 * ancestor element changed it attributes.
		 * @private 
		 */		
		tlf_internal function styleSelectorChanged():void
		{
			modelChanged(ModelChange.STYLE_SELECTOR_CHANGED,this,0,this._textLength);
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
				var elemStyle:TextLayoutFormat  = tf.getTextLayoutFormatStyle(this);
				var explicitStyle:TextLayoutFormat  = tf.getExplicitStyle(this);
				
				if (elemStyle || explicitStyle)
				{
					var localFormat:ITextLayoutFormat = format;
					var rslt:TextLayoutFormat = new TextLayoutFormat();
					if (elemStyle)
						rslt.apply(elemStyle);
					if (localFormat)
						rslt.apply(localFormat);
					if (explicitStyle)
						rslt.apply(explicitStyle);
					return rslt;
				}
			}
			return _format;
		}
		
		/** @private  Shared scratch element for use in computedFormat methods only */
		static tlf_internal var _scratchTextLayoutFormat:TextLayoutFormat = new TextLayoutFormat();
		
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
			if (_computedFormat == null)
				_computedFormat = doComputeTextLayoutFormat();		
			return _computedFormat;
		}
		
		/** @private */
		tlf_internal function doComputeTextLayoutFormat():TextLayoutFormat
		{
			var parentPrototype:TextLayoutFormat = _parent ? TextLayoutFormat(_parent.computedFormat): null;
			return FlowElement.createTextLayoutFormatPrototype(formatForCascade,parentPrototype);
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
				return computedFormat.getStyle(styleProp);
			
			var tf:TextFlow = getTextFlow();
			if (!tf || !tf.formatResolver)
				return computedFormat.getStyle(styleProp);
			
			return getUserStyleWorker(styleProp); 
		}
		// { return TextLayoutFormat.description.hasOwnProperty(styleProp) ? computedFormat.getStyle(styleProp) : getUserStyleWorker(styleProp); } }
		
		/** @private worker function - any styleProp */
		tlf_internal function getUserStyleWorker(styleProp:String):*
		{
			// CONFIG::debug { assert(TextLayoutFormat.description[styleProp] === undefined,"bad call to getUserStyleWorker"); }
			
			if (_format != null)
			{
				var userStyle:* = _format.getStyle(styleProp)
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
			return _parent ? _parent.getUserStyleWorker(styleProp) : undefined;
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
			if (TextLayoutFormat.description[styleProp])
				this[styleProp] = newValue;
			else
			{
				writableTextLayoutFormat().setStyle(styleProp,newValue);
				formatChanged();
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
		
		/**
		 * Called when an element is removed. Used for container elements to run any clean up code. 
		 **/
		tlf_internal function removed():void
		{
			// override in sub classes
		}
		
		/**
		 * Called whenever the model is modified.  Updates the TextFlow and notifies the selection manager - if it is set.
		 * This method has to be called while the element is still in the flow
		 * @param changeType - type of change
		 * @param element - the actual element that is modified
		 * @param start - elem relative offset of start of damage
		 * @param len - length of damage
		 * @see flow.model.ModelChange
		 * @private
		 */
		tlf_internal function modelChanged(changeType:String, element:FlowElement, changeStart:int, changeLen:int, needNormalize:Boolean = true, bumpGeneration:Boolean = true):void
		{
			var tf:TextFlow = this.getTextFlow();
			if (tf)
				tf.processModelChanged(changeType, element, getAbsoluteStart()+changeStart, changeLen, needNormalize, bumpGeneration);
		}
		
		/** @private */
		tlf_internal function appendElementsForDelayedUpdate(tf:TextFlow,changeType:String):void
		{ }
		
		/** @private */
		tlf_internal function applyDelayedElementUpdate(textFlow:TextFlow,okToUnloadGraphics:Boolean,hasController:Boolean):void
		{ }
						
		/** @private */
		tlf_internal function getEffectivePaddingLeft():Number
		{ return computedFormat.paddingLeft == FormatValue.AUTO ? 0 : computedFormat.paddingLeft; }
		/** @private */
		tlf_internal function getEffectivePaddingRight():Number
		{ return computedFormat.paddingRight == FormatValue.AUTO ? 0 : computedFormat.paddingRight; }
		/** @private */
		tlf_internal function getEffectivePaddingTop():Number
		{ return computedFormat.paddingTop == FormatValue.AUTO ? 0 : computedFormat.paddingTop; }
		/** @private */
		tlf_internal function getEffectivePaddingBottom():Number
		{ return computedFormat.paddingBottom == FormatValue.AUTO ? 0 : computedFormat.paddingBottom; }
		
		/** @private */
		tlf_internal function getEffectiveBorderLeftWidth():Number
		{ return computedFormat.borderLeftWidth; }
		/** @private */
		tlf_internal function getEffectiveBorderRightWidth():Number
		{ return computedFormat.borderRightWidth; }
		/** @private */
		tlf_internal function getEffectiveBorderTopWidth():Number
		{ return computedFormat.borderTopWidth; }
		/** @private */
		tlf_internal function getEffectiveBorderBottomWidth():Number
		{ return computedFormat.borderBottomWidth; }
		
		/** @private */
		tlf_internal function getEffectiveMarginLeft():Number
		{ return computedFormat.marginLeft; }
		/** @private */
		tlf_internal function getEffectiveMarginRight():Number
		{ return computedFormat.marginRight; }
		/** @private */
		tlf_internal function getEffectiveMarginTop():Number
		{ return computedFormat.marginTop; }
		/** @private */
		tlf_internal function getEffectiveMarginBottom():Number
		{ return computedFormat.marginBottom; }
		
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

		/** Strips white space from the element and its children, according to the whitespaceCollaspse
		 *  value that has been applied to the element or inherited from its parent.
		 *  If a FlowLeafElement's attrs are set to WhiteSpaceCollapse.PRESERVE, then collapse is
		 *  skipped.
		 *  @see text.formats.WhiteSpaceCollapse
		 * @private 
		 */
		tlf_internal function applyWhiteSpaceCollapse(collapse:String):void
		{
			// clear it if its set
			if (whiteSpaceCollapse !== undefined)
				whiteSpaceCollapse = undefined;
			
			setPrivateStyle(impliedElementString, undefined);
		}
				
		// **************************************** 
		// End import helper code
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
			var rslt:int = _parentRelativeStart;
			for (var elem:FlowElement = _parent; elem; elem = elem._parent)
				rslt += elem._parentRelativeStart;
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
			var rslt:int = _parentRelativeStart;
			for (var elem:FlowElement = _parent; elem && elem != ancestorElement; elem = elem._parent)
				rslt += elem._parentRelativeStart;
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
			while (elem._parent != null)
				elem = elem._parent;
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
			var para:ParagraphElement = null;
			var rslt:FlowElement = this;
			while (rslt)
			{
				para = rslt as ParagraphElement;
				if (para)
					break;
				rslt = rslt._parent;
			}
			return para;
		}
		
		
		public function isInTable():Boolean
		{
			var tf:TextFlow = getTextFlow();
			return tf && tf.parentElement && tf.parentElement is TableCellElement;
		}
		
		public function getParentCellElement():TableCellElement
		{
			var tf:TextFlow = getTextFlow();
			
			if(!tf)
				return null;
			if(tf.parentElement && tf.parentElement is TableCellElement)
				return tf.parentElement as TableCellElement;
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
			var curElement:FlowElement = _parent;
			while (curElement)
			{
				if (curElement is elementType)
					return curElement;
				curElement = curElement._parent;
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
			if(!_parent)
				return null;
				
			var idx:int = _parent.getChildIndex(this);
			return idx == 0 ? null : _parent.getChildAt(idx-1);
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
			if (!_parent)
				return null;

			var idx:int = _parent.getChildIndex(this);
			return idx == _parent.numChildren-1 ? null : _parent.getChildAt(idx+1);
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

		/** @private apply function to all elements until it says stop */
		tlf_internal function applyFunctionToElements(func:Function):Boolean
		{ return func(this); }
		
		/** @private
		 * Gets the EventDispatcher associated with this FlowElement.  Use the functions
		 * of EventDispatcher such as <code>setEventHandler()</code> and <code>removeEventHandler()</code> 
		 * to capture events that happen over this FlowLeafElement object.  The
		 * event handler that you specify will be called after this FlowElement object does
		 * the processing it needs to do. If the FlowElement cannot dispatch events, the return
		 * value is null.
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
		tlf_internal function getEventMirror():IEventDispatcher
		{
			return null;
		}

		/** @private
		 * Checks whether an event dispatcher is attached, and if so, if the event dispatcher
		 * has any active listeners.
		 */
		tlf_internal function hasActiveEventMirror():Boolean
		{
			return false;
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
			setParentRelativeStart(_parentRelativeStart + len);
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
			setTextLength(_textLength + len);		
			var p:FlowGroupElement = _parent;	
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
			if (textFlow == null || textFlow.flowComposer == null)
				return null;
						
			var curItem:FlowElement = this;
			while (curItem && (!(curItem is ContainerFormattedElement) || ContainerFormattedElement(curItem).flowComposer == null))
			{
				curItem = curItem._parent;
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
							var previousEnclosingWithContent:ContainerController = enclosingController;
							CONFIG::debug { assert(myIdx >= 0,"FlowElement.deleteContainerText: bad return from getContainerControllerIndex"); }
							while (myIdx+1 < flowComposer.numControllers && enclosingController.absoluteStart + enclosingController.textLength < endPos)
							{
								enclosingController = flowComposer.getControllerAt(myIdx+1);
								if (enclosingController.textLength)
								{
									previousEnclosingWithContent = enclosingController;
									break;
								}
								myIdx++;
							}
						}
						if (!enclosingController || !enclosingController.textLength)
							enclosingController = previousEnclosingWithContent;
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
			_format = sibling._format ? new FlowValueHolder(sibling._format) : null;
			_computedFormat = null;
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

				trace("FlowElement:",depth.toString(),getDebugIdentity(this),"start:",_parentRelativeStart.toString(),"length:",_textLength.toString(),extraData);
			}
			return 0;
		}
		
		CONFIG::debug public static function elementPath(element:FlowElement):String
		{
			var result:String;
			
			if (element != null)
			{
				if (element._parent != null)
					result = elementPath(element._parent) + "." + element.name + "[" + element._parent.getChildIndex(element) + "]";
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
			return "flowElement:" + name + " start:" + _parentRelativeStart.toString() + " absStart:" + this.getAbsoluteStart().toString() + " textLength:" + _textLength.toString();			
		}
		// **************************************** 
		// End debug support code
		// ****************************************	

		// //////////////////////////////////////////////////////////////////////
		// BEGIN PROTOTYPING CASCADE SUPPORT 
		// //////////////////////////////////////////////////////////////////////
		

					
		/** @private */
		tlf_internal static function createTextLayoutFormatPrototype(localStyles:ITextLayoutFormat,parentPrototype:TextLayoutFormat):TextLayoutFormat
		{			
			var parentPrototypeUsable:Boolean = true;
			var hasStylesSet:Boolean = false;
			// the actual prototype to use
			var parentStylesPrototype:Object;
			// create a new stylesObject with a parentPrototype
			if (parentPrototype)
			{
				parentStylesPrototype = parentPrototype.getStyles();
				if (parentStylesPrototype.hasNonInheritedStyles !== undefined)
				{
					// its either a boolean or if its been used once an object that has the non-inheriting styles reset
					if (parentStylesPrototype.hasNonInheritedStyles === true)
					{
						// create a modified prototype and give it all default non-inherited values
						var noInheritParentStylesPrototype:Object = Property.createObjectWithPrototype(parentStylesPrototype); 
						TextLayoutFormat.resetModifiedNoninheritedStyles(noInheritParentStylesPrototype);
						// now save it in the parent for reuse
						parentStylesPrototype.hasNonInheritedStyles = noInheritParentStylesPrototype;
						parentStylesPrototype = noInheritParentStylesPrototype;
					}
					else
					{
						parentStylesPrototype = parentStylesPrototype.hasNonInheritedStyles;
					}
					parentPrototypeUsable = false;	// can't use it
				}
			}
			else
			{
				parentPrototype = TextLayoutFormat.defaultFormat as TextLayoutFormat;
				parentStylesPrototype = parentPrototype.getStyles();
			}

			var stylesObject:Object = Property.createObjectWithPrototype(parentStylesPrototype); 
			
			var key:String;
			var val:*;
			var prop:Property;
			// has nonInherited Styles that are *different* from the default
			var hasNonInheritedStyles:Boolean = false;	

			// two cases depending on how localStyles are supplied
			if (localStyles != null)
			{
				var lvh:TextLayoutFormat = localStyles as TextLayoutFormat;
				if (lvh)
				{
					var coreStyles:Object = lvh.getStyles();
					
					for (key in coreStyles)
					{
						val = coreStyles[key];
						if (val == FormatValue.INHERIT)
						{
							if (parentPrototype)
							{
								prop = TextLayoutFormat.description[key];
								if (prop && !prop.inherited)
								{
									// actually do the inheritance - might have been wiped out above!
									val = parentPrototype[key];
									if (stylesObject[key] != val)
									{
										stylesObject[key] = val;
										hasNonInheritedStyles = true;
										hasStylesSet = true;
										// CONFIG::debug { assert(val != prop.defaultValue,"Unexpected non-inheritance"); }
									}
								}
							}
						}
						else
						{
							if (stylesObject[key] != val)
							{
								prop = TextLayoutFormat.description[key];
								if (prop && !prop.inherited)
								{
									// CONFIG::debug { assert(val != prop.defaultValue,"Unexpected non-inheritance"); }
									hasNonInheritedStyles = true;
								}
								stylesObject[key] = val;
								hasStylesSet = true;	// doesn't matter if inherited or not
							}
						}
					}
				}
				else
				{					
					for each (prop in TextLayoutFormat.description)
					{
						key = prop.name;
						val = localStyles[key];
						if (val !== undefined)
						{	
							if (val == FormatValue.INHERIT)
							{
								if (parentPrototype)
								{
									if (!prop.inherited)
									{
										// actually do the inheritance - might have been wiped out above!
										val = parentPrototype[key];
										if (stylesObject[key] != val)
										{
											stylesObject[key] = val;
											hasNonInheritedStyles = true;
											hasStylesSet = true;
											// CONFIG::debug { assert(val != prop.defaultValue,"Unexpected non-inheritance"); }
										}
									}
								}
							}
							else
							{
								if (stylesObject[key] != val)
								{
									if (!prop.inherited)
									{
										// CONFIG::debug { assert(val != prop.defaultValue,"Unexpected non-inheritance"); }
										hasNonInheritedStyles = true;
									}
									stylesObject[key] = val;
									hasStylesSet = true;	// doesn't matter if inherited or not
								}
							}
						}
					}
				}
			}
			
			var rslt:TextLayoutFormat;
			
			if (!hasStylesSet)
			{
				// nothing has changed from the parent so just reuse it
				CONFIG::debug { assert(hasNonInheritedStyles == false,"stylesCount mismatch with hasNonInheritedStyles"); }
				if (parentPrototypeUsable)
					return parentPrototype;
				// we can use the parentStylesPrototype but not the parentPrototype
				rslt = new TextLayoutFormat();
				rslt.setStyles(stylesObject,true);
				return rslt;
			}

			if (hasNonInheritedStyles)
			{
				// if its not identical in stylesObject need to set it
				CONFIG::debug { assert(stylesObject.hasNonInheritedStyles !== hasNonInheritedStyles,"unexpected nonInheritedStyles"); }
				stylesObject.hasNonInheritedStyles = true;
				stylesObject.setPropertyIsEnumerable("hasNonInheritedStyles",false);
			}
			else if (stylesObject.hasNonInheritedStyles !== undefined)
			{
				stylesObject.hasNonInheritedStyles = undefined;
				stylesObject.setPropertyIsEnumerable("hasNonInheritedStyles",false);				
			}
				
			rslt = new TextLayoutFormat();
			rslt.setStyles(stylesObject,false);
			return rslt;
		}
	}

}
