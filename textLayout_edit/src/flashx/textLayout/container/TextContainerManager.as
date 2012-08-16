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
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.IMEEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuClipboardItems;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.compose.BaseCompose;
	import flashx.textLayout.compose.ISWFContext;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.compose.TextLineRecycler;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.EditingMode;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.IInteractionEventHandler;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.DamageEvent;
	import flashx.textLayout.events.FlowOperationEvent;
	import flashx.textLayout.events.SelectionEvent;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.events.TextLayoutEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	import flashx.textLayout.external.WeakRef;
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import flashx.textLayout.factory.TextLineFactoryBase;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.EnumStringProperty;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;
	import flashx.undo.IUndoManager;
	import flashx.undo.UndoManager;

	use namespace tlf_internal;
	/**
	 *
	 *  @eventType flashx.textLayout.events.FlowOperationEvent.FLOW_OPERATION_BEGIN
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	 
	[Event(name="flowOperationBegin", type="flashx.textLayout.events.FlowOperationEvent")]
	
	/**
	 * 
	 * @eventType flashx.textLayout.events.FlowOperationEvent.FLOW_OPERATION_END
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	 
	[Event(name="flowOperationEnd", type="flashx.textLayout.events.FlowOperationEvent")]
	
	
	/**
	 * 
	 * @eventType flashx.textLayout.events.FlowOperationEvent.FLOW_OPERATION_COMPLETE
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="flowOperationComplete", type="flashx.textLayout.events.FlowOperationEvent")]
	
	/** Dispatched whenever the selection is changed.  Primarily used to update selection-dependent user interface. 
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="selectionChange", type="flashx.textLayout.events.SelectionEvent")]
	
	/** Dispatched after every recompose. 
	*
	* @playerversion Flash 10
	* @playerversion AIR 1.5
	* @langversion 3.0
	*/
	
	[Event(name="compositionComplete", type="flashx.textLayout.events.CompositionCompleteEvent")]
	
	/** Dispatched when the mouse is pressed down over any link. 
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="mouseDown", type="flashx.textLayout.events.FlowElementMouseEvent")]
	
	/** Dispatched when the mouse is released over any link. 
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="mouseUp", type="flashx.textLayout.events.FlowElementMouseEvent")]
	
	/** Dispatched when the mouse passes over any link. 
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="mouseMove", type="flashx.textLayout.events.FlowElementMouseEvent")]	
	
	/** Dispatched when the mouse first enters any link. 
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="rollOver", type="flashx.textLayout.events.FlowElementMouseEvent")]
	
	/** Dispatched when the mouse goes out of any link. 
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="rollOut", type="flashx.textLayout.events.FlowElementMouseEvent")]	
	
	/** Dispatched when any link is clicked. 
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="click", type="flashx.textLayout.events.FlowElementMouseEvent")]
	
	/** Dispatched when a InlineGraphicElement is resized due to having width or height as auto or percent 
	 * and the graphic has finished loading. 
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="inlineGraphicStatusChanged", type="flashx.textLayout.events.StatusChangeEvent")]
	
	/** Dispatched by a TextFlow object after text is scrolled within a controller container.  
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="scroll", type="flashx.textLayout.events.TextLayoutEvent")]
	
	/** Dispatched by a TextFlow object each time it is damaged 
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="damage", type="flashx.textLayout.events.DamageEvent")]

	/** Dispatched by a TextFlow object each time a container has had new DisplayObjects added or updated as a result of composition.
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	
	[Event(name="updateComplete", type="flashx.textLayout.events.UpdateCompleteEvent")]
		
	[Exclude(name="getBaseSWFContext",kind="method")]
	
	[Exclude(name="callInContext",kind="method")]
	/** Manages text in a container. Assumes that it manages all children of the container. 
	 * Consider using TextContainerManager for better performance in cases where there is a 
	 * one container per TextFlow, and the TextFlow is not the main focus, is static text, or
	 * is infrequently selected. Good for text in form fields, for example.
	 * 
	 * @includeExample examples\TextContainerManager.as -noswf
	 *
 	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 * 
	 * @see ContainerController
	 */			
	public class TextContainerManager extends EventDispatcher implements ISWFContext, IInteractionEventHandler, ISandboxSupport
	{
		static private var _inputManagerTextFlowFactory:TextFlowTextLineFactory = new TextFlowTextLineFactory();
		
		// all events that are listened for need to be in this list.
		static private const eventList:Array = [ 
			FlowOperationEvent.FLOW_OPERATION_BEGIN,
			FlowOperationEvent.FLOW_OPERATION_END,
			FlowOperationEvent.FLOW_OPERATION_COMPLETE,
			SelectionEvent.SELECTION_CHANGE,
			CompositionCompleteEvent.COMPOSITION_COMPLETE,
			MouseEvent.CLICK,		//from FlowElementMouseEvent
			MouseEvent.MOUSE_DOWN,	//from FlowElementMouseEvent
			MouseEvent.MOUSE_OUT,	//from FlowElementMouseEvent
			MouseEvent.MOUSE_UP,	//from FlowElementMouseEvent
			MouseEvent.MOUSE_OVER,	//from FlowElementMouseEvent
			MouseEvent.MOUSE_OUT,	//from FlowElementMouseEvent
			StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,
		 	TextLayoutEvent.SCROLL,
			DamageEvent.DAMAGE,
			UpdateCompleteEvent.UPDATE_COMPLETE
		];
		
		/** Configuration to be used by the TextContainerManager.  This can only be set once and before the inputmanager is used.  */
		static private var _inputManagerConfiguration:IConfiguration = null;
		
		/** The default configuration for this TextContainerManager. Column and padding attributes
		 * are set to <code>FormatValue.INHERIT</code>.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 * 
	 	 * @see flashx.textLayout.elements.IConfiguration IConfiguration
	 	 * @see flashx.textLayout.formats.FormatValue#INHERIT FormatValue.INHERIT
		 */
		static public function get defaultConfiguration():IConfiguration
		{
			if (_inputManagerConfiguration == null)
			{
				var config:Configuration = new Configuration();
				config.flowComposerClass = TextLineFactoryBase.getDefaultFlowComposerClass();
				_inputManagerConfiguration = config;
			}
			return _inputManagerConfiguration; 
		}
		
		static private var stringFactoryDictionary:Dictionary = new Dictionary(true);
		static private function inputManagerStringFactory(config:IConfiguration):StringTextLineFactory
		{
			var factory:StringTextLineFactory = stringFactoryDictionary[config];
			if (factory == null)
			{
				factory = new StringTextLineFactory(config);
				stringFactoryDictionary[config] = factory;
			}
			return factory;
		}
		
		/** Shared definition of the scrollPolicy property. @private */
		static tlf_internal const editingModePropertyDefinition:EnumStringProperty = new EnumStringProperty("editingMode", EditingMode.READ_WRITE, false, null, 
			EditingMode.READ_WRITE, EditingMode.READ_ONLY, EditingMode.READ_SELECT);	
		
		private var _container:Sprite;
		private var _compositionWidth:Number;
		private var _compositionHeight:Number;
		
		private var _text:String;
		private var _textDamaged:Boolean;				// indicates the _text property needs updating when sourceState is SOURCE_TEXTFLOW
		private var _lastSeparator:String;
		
		private var _hostFormat:ITextLayoutFormat;
		private var _hostFormatHash:*;
		
		private var _contentTop:Number;
		private var _contentLeft:Number;
		private var _contentHeight:Number;
		private var _contentWidth:Number;
		
		private var _horizontalScrollPolicy:String;
		private var _verticalScrollPolicy:String;
		
		private var _swfContext:ISWFContext;
		private var _config:IConfiguration;
		
		/** @private */
		static tlf_internal const SOURCE_STRING:int = 0;
		/** @private */
		static tlf_internal const SOURCE_TEXTFLOW:int = 1;
		
		/** @private */
		static tlf_internal const COMPOSE_FACTORY:int = 0;
		/** @private */
		static tlf_internal const COMPOSE_COMPOSER:int = 1;
		
		/** @private */
		static tlf_internal const HANDLERS_NOTADDED:int  = 0;
		/** @private */
		static tlf_internal const HANDLERS_NONE:int      = 1;
		/** @private */
		static tlf_internal const HANDLERS_CREATION:int  = 2;
		/** @private */
		static tlf_internal const HANDLERS_ACTIVE:int    = 3;
		
		private var _sourceState:int;
		private var _composeState:int;
		private var _handlersState:int;
		// track hasFocus.  Depending on various factors focus and mouseDown can occur in different order
		private var _hasFocus:Boolean;
		private var _editingMode:String;
		private var _ibeamCursorSet:Boolean;
		private var _interactionCount:int;
		
		/** @private */
		tlf_internal function get sourceState():int
		{ return _sourceState; }
		/** @private */
		tlf_internal function get composeState():int
		{ return _composeState; }
		/** @private */
		tlf_internal function get handlersState():int
		{ return _handlersState; }
	
		// Tracks damage when sourceState is SOURCE_STRING. TODO - Might be worthwhile to always set and clear this
		private var _damaged:Boolean;			
		private var _textFlow:TextFlow;
		private var _needsRedraw:Boolean;
		
		/** Constructor function - creates a TextContainerManager instance.
		 *
		 * For best results:
		 * <ol>
		 *	<li>Start with TextContainerManager.defaultConfiguration and modify it</li>   
		 *	<li>Share the same Configuration among many InputManagers</li>
		 * </ol>
		 *
		 * @param container The DisplayObjectContainer in which to manage the text lines.
		 * @param config - The IConfiguration instance to use with this TextContainerManager instance. 
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0	 	
		 */
		public function TextContainerManager(container:Sprite,configuration:IConfiguration =  null)
		{
			_container = container;
			_compositionWidth = 100;
			_compositionHeight = 100;
			
			_config = configuration ? configuration : defaultConfiguration;
			_config = Configuration(_config).getImmutableClone();

			_horizontalScrollPolicy = _verticalScrollPolicy = String(ScrollPolicy.scrollPolicyPropertyDefinition.defaultValue);

			_damaged = true;
			_needsRedraw = false;
			_text = "";
			_textDamaged = false;
			
			_sourceState = SOURCE_STRING;
			_composeState = COMPOSE_FACTORY;
			_handlersState = HANDLERS_NOTADDED;
			_hasFocus = false;
			
			_editingMode = editingModePropertyDefinition.defaultValue as String;
			_ibeamCursorSet = false;
			_interactionCount = 0;
			
			if (_container is InteractiveObject)
			{
				_container.doubleClickEnabled = true;
				// so the textlines can be swapped on the first click and a double click still works
				_container.mouseChildren = false;
				_container.focusRect = false;
			}
		}

		/** Returns the container (DisplayObjectContainer) that holds the text that this TextContainerManager manages.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see ContainerController#container
	 	 */
	 	 
		public function get container():Sprite
		{ return _container; }
		
		/** Returns <code>true</code> if the content needs composing. 
		 * 
		 * @return	<code>true</code> if the content needs composing; <code>false</code> otherwise.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		public function isDamaged():Boolean
		{ return _composeState == COMPOSE_FACTORY ? _damaged : _textFlow.flowComposer.isDamaged(_textFlow.textLength); }
		
		/** Editing mode of this TextContainerManager. Modes are reading only, reading and selection permitted, 
		 * and editing (reading, selection, and writing)  permitted. Use the constant values of the EditingMode
		 * class to set this property. 
		 * <p>Default value is READ_WRITE.</p>
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
		 * @see flashx.textLayout.edit.EditingMode EditingMode
		 */
		public function get editingMode():String
		{ return _editingMode; }
		public function set editingMode(val:String):void
		{
			var newMode:String = editingModePropertyDefinition.setHelper(_editingMode, val) as String;
			
			if (newMode != _editingMode)
			{
				if (composeState == COMPOSE_COMPOSER)
				{
					_editingMode = newMode;
					invalidateInteractionManager();
				}
				else
				{
					removeActivationEventListeners();
					_editingMode = newMode;
					// there is no way to turn it on here if going from READ_ONLY to editable and mouse is over the inputmanager field
					if (_editingMode == EditingMode.READ_ONLY)
						removeIBeamCursor();
					addActivationEventListeners();
				}
			}
		}
		 		
		/**
		 * Returns the current text using a separator between paragraphs.
		 * The separator can be specified with the <code>separator</code>
		 * argument. The default value of the <code>separator</code> argument
		 * is the Unicode character <code>'PARAGRAPH SEPARATOR' (U+2029)</code>.
		 *
		 * <p>Calling the setter discards any attached TextFlow. Any selection is lost.</p>
		 * 
		 * @param separator String to set between paragraphs.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
	 	 */
		public function getText(separator:String = '\u2029'):String
		{
			if (_sourceState == SOURCE_STRING)
				return _text;

			if (_textDamaged || _lastSeparator != separator)
			{
				_text = "";
				var firstLeaf:FlowLeafElement = _textFlow.getFirstLeaf();
				if (firstLeaf != null)
				{
					var para:ParagraphElement = firstLeaf.getParagraph();
					while (para)
					{
						var nextPara:ParagraphElement = para.getNextParagraph();
						_text += para.getText();
						_text += nextPara ? separator : "";
						para = nextPara;
					}
				}
				_textDamaged = false;
				_lastSeparator = separator;
			}
			return _text;
		}
		/**
		 * Sets the <code>text</code> property to the specified String.
		 *
		 * Discards any attached TextFlow. Any selection is lost.
		 * 
		 * @param str the String to set
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
	 	 */
		public function setText(text:String):void
		{
			var hadPreviousSelection:Boolean = false;

			if (_sourceState == SOURCE_TEXTFLOW)
			{
				if (_textFlow.interactionManager && _textFlow.interactionManager.hasSelection())
					hadPreviousSelection = true;
				removeTextFlowListeners();
				if (_textFlow.flowComposer)
					_textFlow.flowComposer.removeAllControllers();
				_textFlow = null;
				_sourceState = SOURCE_STRING;
				_composeState = COMPOSE_FACTORY;
				if (_container is InteractiveObject)
					_container.mouseChildren = false;
				addActivationEventListeners();
			}
			_text = text ? text : ""; 
			_damaged = true;
			_textDamaged = false;
			
			// Generate a damage event 
			dispatchEvent(new DamageEvent(DamageEvent.DAMAGE, false, false, null, 0, _text.length));
			
			// generate a selection changed event
			if (hadPreviousSelection)
				dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGE, false, false, null));
			
			if (_hasFocus)
				requiredFocusInHandler(null);
		}
				
		/** Sets the format when display just a string.  If displaying a TextFlow this has no immediate effect.  The supplied ITextLayoutFormat is not copied.  Modifying it without calling this setter has indeterminate effects. */
		public function get hostFormat():ITextLayoutFormat
		{ return _hostFormat; }
		public function set hostFormat(val:ITextLayoutFormat):void
		{
			_hostFormat = val;
			_hostFormatHash = undefined;
			
			if (_sourceState == SOURCE_TEXTFLOW)
				_textFlow.hostFormat = _hostFormat;
			if (_composeState == COMPOSE_FACTORY)
				_damaged = true;
		}
		
		/** Returns the horizontal extent allowed for text inside the container. The value is specified in pixels.
		 * 
		 * <p>After setting this property, the text in the container is damaged and requires composing.</p>
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0  
	 	 */
		public function get compositionWidth():Number
		{ return _compositionWidth; }
		public function set compositionWidth(val:Number):void
		{
			if (_compositionWidth == val || (isNaN(_compositionWidth) && isNaN(val)))
				return;
			_compositionWidth = val; 
			if (_composeState == COMPOSE_COMPOSER)
			{
				getController().setCompositionSize(_compositionWidth,_compositionHeight);
			}
			else
			{
				_damaged = true; 
			}
		}
	
		/** Returns the vertical extent allowed for text inside the container. The value is specified in pixels. 
		 * <p>After setting this property, the text in the container is damaged and requires composing.</p>
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
	 	 
		public function get compositionHeight():Number
		{ return _compositionHeight; }
		public function set compositionHeight(val:Number):void
		{
			if (_compositionHeight == val || (isNaN(_compositionHeight) && isNaN(val)))
				return;
			_compositionHeight = val; 
			if (_composeState == COMPOSE_COMPOSER)
			{
				getController().setCompositionSize(_compositionWidth,_compositionHeight);
			}
			else
			{
				_damaged = true; 
			}
		}
		
		/** The Configuration object for this TextContainerManager. 
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see flashx.textLayout.IConfiguration IConfiguration
	 	 */
		public function get configuration():IConfiguration
		{ return _config; }
			
		/** Creates a rectangle that shows where the last call to either the <code>compose()</code> 
		 * method or the <code>updateContainer()</code> method placed the text.
		 *
		 * @return  the bounds of the content
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see #compose()
	 	 * @see #updateContainer()
		 */
		public function getContentBounds():Rectangle
		{
			if (_composeState == COMPOSE_FACTORY)
				return new Rectangle(_contentLeft, _contentTop, _contentWidth, _contentHeight);
			var controller:ContainerController = getController();
			return controller.getContentBounds();
		}	
		
		/** The current TextFlow. Converts this to a full TextFlow representation if it 
		 * isn't already one. 
		 *
		 * @return 	the current TextFlow object
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		public function getTextFlow():TextFlow
		{
			if (_sourceState != SOURCE_TEXTFLOW)
			{
				var wasDamaged:Boolean = isDamaged();
				convertToTextFlow();
				if (!wasDamaged)
					updateContainer();
			}
			return _textFlow;
		}

		/** Sets a TextFlow into this TextContainerManager replacing any existing TextFlow and discarding the 
		 * current text. 
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		public function setTextFlow(textFlow:TextFlow):void
		{
			if (textFlow == null)
			{
				setText(null);
				return;
			}
			if (_sourceState == SOURCE_TEXTFLOW)
			{
				removeTextFlowListeners();
				if (_textFlow.flowComposer)
					_textFlow.flowComposer.removeAllControllers();
			}
				
			_textFlow = textFlow;
			_textFlow.hostFormat = hostFormat;
			_sourceState = SOURCE_TEXTFLOW;
			_composeState = textFlow.interactionManager || textFlow.mustUseComposer() ? COMPOSE_COMPOSER : COMPOSE_FACTORY;
			_textDamaged = true;
			addTextFlowListeners();
			
			if (_composeState == COMPOSE_COMPOSER)
			{
				// Possible issue - this clear call could be delayed until updateToController
				_container.mouseChildren = true;
				clearContainerChildren(true);
				clearComposedLines();
				_textFlow.flowComposer = new StandardFlowComposer();
				_textFlow.flowComposer.swfContext = _swfContext;
				var controller:TMContainerController = new TMContainerController(_container,_compositionWidth,_compositionHeight,this);
				_textFlow.flowComposer.addController(controller);
				
				invalidateInteractionManager();
				
				// always start with an empty selection
				if (_textFlow.interactionManager)
					_textFlow.interactionManager.selectRange(-1,-1);
			}
			else
				_damaged = true;
			
			if (_hasFocus)
				requiredFocusInHandler(null);
			
			addActivationEventListeners();
		}
		
		/** 
		 * Controls whether the factory generates all text lines or stops when the container bounds are filled.
		 * 
		 * @copy flashx.textLayout.container.ContainerController#horizontalScrollPolicy 
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
	 	 */
	 	public function get horizontalScrollPolicy():String
		{
			return _horizontalScrollPolicy;
		}
		public function set horizontalScrollPolicy(scrollPolicy:String):void
		{
			_horizontalScrollPolicy = ScrollPolicy.scrollPolicyPropertyDefinition.setHelper(_horizontalScrollPolicy, scrollPolicy) as String;
			if (_composeState == COMPOSE_COMPOSER)
				getController().horizontalScrollPolicy = _horizontalScrollPolicy;
			else
				_damaged = true;
		}
		
		/** 
		 * Controls whether the factory generates all text lines or stops when the container bounds are filled.
		 * 
		 * @copy flashx.textLayout.container.ContainerController#verticalScrollPolicy 
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
	 	 */
	 	 
		public function get verticalScrollPolicy():String
		{
			return _verticalScrollPolicy;
		}
		public function set verticalScrollPolicy(scrollPolicy:String):void
		{
			_verticalScrollPolicy = ScrollPolicy.scrollPolicyPropertyDefinition.setHelper(_verticalScrollPolicy, scrollPolicy) as String;
			if (_composeState == COMPOSE_COMPOSER)
				getController().verticalScrollPolicy = _verticalScrollPolicy;
			else
				_damaged = true;
		}
			
		/** 
		 * @copy flashx.textLayout.container.ContainerController#horizontalScrollPosition
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
	 	 */
		public function get horizontalScrollPosition():Number
		{ return _composeState == COMPOSE_COMPOSER ? getController().horizontalScrollPosition : 0; }
		public function set horizontalScrollPosition(val:Number):void
		{ 
			if (val == 0 && _composeState == COMPOSE_FACTORY)
				return;
			if (_composeState != COMPOSE_COMPOSER)
				convertToTextFlowWithComposer();
			getController().horizontalScrollPosition = val;
		}
		
		/** 
		 * @copy flashx.textLayout.container.ContainerController#verticalScrollPosition 
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
	 	 */
		public function get verticalScrollPosition():Number
		{ return _composeState == COMPOSE_COMPOSER ? getController().verticalScrollPosition : 0; }
		public function set verticalScrollPosition(val:Number):void
		{
			if (val == 0 && _composeState == COMPOSE_FACTORY)
				return;
			if (_composeState != COMPOSE_COMPOSER)
				convertToTextFlowWithComposer();
			getController().verticalScrollPosition = val;
		}

		/** 
		* @copy flashx.textLayout.container.ContainerController#getScrollDelta() 
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
		* @langversion 3.0
	 	*/
		public function getScrollDelta(numLines:int):Number
		{
			if (_composeState != COMPOSE_COMPOSER)
				convertToTextFlowWithComposer();
			return getController().getScrollDelta(numLines);
		}
		
		/** 
		* @copy flashx.textLayout.container.ContainerController#scrollToRange() 
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
		* @langversion 3.0
	 	*/
	 	public function scrollToRange(activePosition:int,anchorPosition:int):void
	 	{
			if (_composeState != COMPOSE_COMPOSER)
				convertToTextFlowWithComposer();
			getController().scrollToRange(activePosition,anchorPosition);	 		
	 	}

		/** 
		* Optional ISWFContext instance used to make FTE calls as needed in the proper swf context. 
		*
		* 
		* @see flashx.textLayout.compose.ISWFContext
		* 
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0
	 	*/
 	
		public function get swfContext():ISWFContext
		{ return _swfContext; }
		public function set swfContext(context:ISWFContext):void
		{ 
			_swfContext = context;
			if (_composeState == COMPOSE_COMPOSER)
				_textFlow.flowComposer.swfContext = _swfContext;
			else
				_damaged = true;
		}
		
		/** @private - TextContainerManager wraps an underlying swfcontext - tell it to FlowComposerBase so it can avoid extra invalidation */
		public function getBaseSWFContext():ISWFContext
		{ return _swfContext; }
		
		/** @private - this is part of a performance optimziation for reusing existing TextLines in place iff recreateTextLine is available. */
	    public function callInContext(fn:Function, thisArg:Object, argsArray:Array, returns:Boolean=true):*
		{
			var textBlock:TextBlock = thisArg as TextBlock;
			if (textBlock)
			{
			 	if (fn == textBlock.createTextLine)
					return createTextLine(textBlock,argsArray);
				if (Configuration.playerEnablesArgoFeatures && fn == thisArg["recreateTextLine"])
					return recreateTextLine(textBlock,argsArray);
			}
	        if (returns)
	            return fn.apply(thisArg, argsArray);
	        fn.apply(thisArg, argsArray);
		}
		
		/** 
		 * Uses the <code>textBlock</code> parameter, and calls the <code>TextBlock.createTextLine()</code> method on it 
		 * using the remaining parameters.
		 * WARNING: modifies argsArray
		 *  
		 * @copy flash.text.engine.TextBlock
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		private function createTextLine(textBlock:TextBlock, argsArray:Array):TextLine
		{
			var swfContext:ISWFContext = _swfContext ? _swfContext : BaseCompose.globalSWFContext;
			
			CONFIG::debug { assert(Configuration.playerEnablesArgoFeatures,"Bad call to createTextLine"); }
			if (_composeRecycledInPlaceLines < _composedLines.length)
			{
				var textLine:TextLine = _composedLines[_composeRecycledInPlaceLines++];

				argsArray.splice(0,0,textLine);
				return swfContext.callInContext(textBlock["recreateTextLine"],textBlock,argsArray);
			}

			return swfContext.callInContext(textBlock.createTextLine,textBlock,argsArray);
		}

		/** 
		 * Uses the <code>textBlock</code> parameter, and calls the <code>FlowComposerBase.recreateTextLine()</code> method on it 
		 * using the remaining parameters.
		 *
		 * @param textBlock The TextBlock to which the TextLine belongs.
		 * @param textLine  The TextLine to be recreated.
		 * @param previousLine Specifies the previously broken line after 
		 *	which breaking is to commence. Can be null when breaking the first line.  
		 * @param width Specifies the desired width of the line in pixels. The 
		 * 	actual width may be less.  
		 * @param lineOffset An optional parameter which specifies the difference in 
		 *	pixels between the origin of the line and the origin of the tab stops. This can be used when lines are not aligned, 
		 * 	but it is desirable for their tabs to be so. 
		 * @param fitSomething An optional parameter that instructs the runtime to fit at least one 
		 * 	character into the text line, no matter what width has been specified (even if width is zero or negative, which 
		 * 	would otherwise result in an exception being thrown).  
		 * @return The recreated TextLine instance.
		 *  
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		private function recreateTextLine(textBlock:TextBlock, argsArray:Array):TextLine
		{
			if (_composeRecycledInPlaceLines < _composedLines.length)
			{
				CONFIG::debug {assert(argsArray[0] != _composedLines[_composeRecycledInPlaceLines],"Bad args"); }
				TextLineRecycler.addLineForReuse(argsArray[0]);	// not going to use this one
				argsArray[0] = _composedLines[_composeRecycledInPlaceLines++];
			}
			var swfContext:ISWFContext = _swfContext ? _swfContext : BaseCompose.globalSWFContext;
			return swfContext.callInContext(textBlock["recreateTextLine"],textBlock,argsArray);
		}

		
		/** Returns the current ISelectionManager instance. Converts to TextFlow instance and creates one if necessary. 
		 *
		 * @return  the interaction manager for this TextContainerManager instance.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
	 	 * @see flashx.textLayout.edit.ISelectionManager ISelectionManager
	 	 */
		public function beginInteraction():ISelectionManager
		{
			++_interactionCount;
			if (_composeState != COMPOSE_COMPOSER)
				convertToTextFlowWithComposer();
			return _textFlow.interactionManager;
		}
		
		/** Terminates interaction. 
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see flashx.textLayout.edit.ISelectionManager ISelectionManager
	 	 */
		
		public function endInteraction():void
		{
			--_interactionCount;
		}
		
		/** Call this if you are editing, and want to reset the undo manager used for editing.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 */
		public function invalidateUndoManager():void
		{
			if (_editingMode == EditingMode.READ_WRITE)
				invalidateInteractionManager(true);
		}
		
		
		/** Call this if you change the selection formats (SelectionFormat) and want the interactionManager 
		 * to update. 
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
	 	 */
		public function invalidateSelectionFormats():void
		{
			invalidateInteractionManager();
		}
		
		/** The interactionManager is invalid - update it. Clients should call this if they change the 
		 * selectionFormats.  Its called automatically if editingMode is changed. */
		private function invalidateInteractionManager(alwaysRecreateManager:Boolean = false):void
		{
			if (_composeState == COMPOSE_COMPOSER)
			{
				var interactionManager:ISelectionManager = _textFlow.interactionManager;
				var activePos:int = interactionManager ? interactionManager.activePosition : -1
				var anchorPos:int = interactionManager ? interactionManager.anchorPosition : -1;

				if (_editingMode == EditingMode.READ_ONLY)
				{
					if (interactionManager)
						_textFlow.interactionManager = null;
				}
				else if (_editingMode == EditingMode.READ_WRITE)
				{
					if (alwaysRecreateManager || interactionManager == null || interactionManager.editingMode == EditingMode.READ_SELECT)
					{
						_textFlow.interactionManager = createEditManager(getUndoManager());
						if (_textFlow.interactionManager is SelectionManager)
							SelectionManager(_textFlow.interactionManager).cloneSelectionFormatState(interactionManager);
					}
				}
				else if (_editingMode == EditingMode.READ_SELECT)
				{
					if (alwaysRecreateManager || interactionManager == null || interactionManager.editingMode == EditingMode.READ_WRITE)
					{
						_textFlow.interactionManager = createSelectionManager();
						if (_textFlow.interactionManager is SelectionManager)
							SelectionManager(_textFlow.interactionManager).cloneSelectionFormatState(interactionManager);
					}
				}
				
				interactionManager = _textFlow.interactionManager;
				if (interactionManager)
				{
					interactionManager.unfocusedSelectionFormat  = getUnfocusedSelectionFormat();
					interactionManager.focusedSelectionFormat    = getFocusedSelectionFormat();
					interactionManager.inactiveSelectionFormat = getInactiveSelectionFormat();
					interactionManager.selectRange(anchorPos,activePos);
				}				
			}
		}
		
		/**Create a selection manager to use for selection. Override this method if you have a custom SelectionManager that you
		 * want to use in place of the default.
		 *
		 * @return	a new SelectionManager instance.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 */
		protected function createSelectionManager():ISelectionManager
		{
			return new SelectionManager();
		}
		
		/**Create an edit manager to use for editing. Override this method if you have a custom EditManager that you
		 * want to use in place of the default.
		 *
		 * @param  an IUndoManager instance for the EditManager being created.
		 * @return	the editing manager for this TextContainerManager instance.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 */
		protected function createEditManager(undoManager:flashx.undo.IUndoManager):IEditManager
		{
			return new EditManager(undoManager);
		}
		
		private function getController():TMContainerController
		{ return _textFlow.flowComposer.getControllerAt(0) as TMContainerController; }

		private var _composedLines:Array = [];
		
		/** Return the TextLine at the index from array of composed lines.
		 *
		 * @param index	Finds the line at this index position in the text.
		 *
		 * @return 	the TextLine that occurs at the specified index.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
		 */
		public function getLineAt(index:int):TextLine
		{ 
			// note: this method is not reliable for damaged text
			if (_composeState == COMPOSE_FACTORY)
			{
				// watch out for the empty TCM optimization and make a TextLine
				if (_sourceState == SOURCE_STRING && _text.length == 0 && !_damaged && _composedLines.length == 0)
				{
					// flush the cache and force a recompose -- that will give us a TextLine
					delete _emptyFormatCache[formatHash()];
					
					if (_needsRedraw)
						compose();
					else
						updateContainer();
					CONFIG::debug { assert(_composeState == COMPOSE_FACTORY,"no longer a factory??"); }
				}
				return _composedLines[index];
			}
			var tfl:TextFlowLine = _textFlow.flowComposer.getLineAt(index);
			return tfl ? tfl.getTextLine(true) : null;
		}
		
		/** @copy flashx.textLayout.compose.IFlowComposer#numLines 
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		public function get numLines():int
		{ 
			// note: this method is not reliable for damaged text
			if (_composeState == COMPOSE_COMPOSER)
				return _textFlow.flowComposer.numLines;
			// watch out for possibly optimized zero length text
			if (_sourceState == SOURCE_STRING && _text.length == 0)
				return 1;
			return _composedLines.length; 
		}
		
		private function clearComposedLines():void
		{
			if (_composedLines)
				_composedLines.length = 0;
		}
		
		private function populateComposedLines(displayObject:DisplayObject):void
		{
			_composedLines.push(displayObject);
		}
		
		// TODO FOR ARGO
		private var _composeRecycledInPlaceLines:int;
		private var _composePushedLines:int;
		private function populateAndRecycleComposedLines(object:DisplayObject):void
		{
			var textLine:TextLine = object as TextLine;
			if (textLine)
			{
				CONFIG::debug { assert(_composePushedLines >= _composedLines.length || _composedLines[_composePushedLines] == textLine,"mismatched recycled textline"); }
				if (_composePushedLines >= _composedLines.length)
					_composedLines.push(textLine);
			}
			else	// this is the background color and goes at the head of the list
				_composedLines.splice(0,0,object);
			_composePushedLines++;
		}		
		
		/** @private return the current format hash */
		tlf_internal function formatHash():uint
		{
			if (_hostFormatHash === undefined)
			{
				if (_hostFormat == null)
					_hostFormatHash = 0;
				else
				{	
					var hash:uint = 0;
					for each (var prop:Property in TextLayoutFormat.description)
					{
						var val:Object = _hostFormat[prop.name];
						if (val)
							hash = prop.hash(val,hash);
					}
					_hostFormatHash = hash;
				}
			}

			return _hostFormatHash;
		}
		
		/** @private Cache of emptyFormat bounds */
		static tlf_internal var _emptyFormatCache:Dictionary = new Dictionary();
		
		/** @private lookup bounds for the zero length factory optimization. */
		tlf_internal function lookupZeroLengthTextBounds():Rectangle
		{
			if (_sourceState != SOURCE_STRING || _text.length != 0)
				return null;
				
			var hash:uint = formatHash();
			
			var ref:WeakRef = _emptyFormatCache[hash];
			if (ref == null)
				return null;
				
			var cachedObject:Object = ref.get();
			
			if (cachedObject == null)
				return null;
				
			return TextLayoutFormat.isEqual(_hostFormat,cachedObject.format) ? cachedObject.bounds : null;
		}
		
		/** Composes the container text; calls either the factory or <code>updateAllControllers()</code>.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		public function compose():void
		{
			if (_composeState == COMPOSE_COMPOSER)
				_textFlow.flowComposer.compose();
			else if (_damaged)
			{
				if (_sourceState == SOURCE_TEXTFLOW && _textFlow.mustUseComposer())
					convertToTextFlowWithComposer();
				else
				{
					var bounds:Rectangle = lookupZeroLengthTextBounds();
					if (bounds)
					{
						clearComposedLines();
					}
					else
					{
						var callback:Function;
						if (Configuration.playerEnablesArgoFeatures)
						{
							// if the first thing in the array is not a TextLine its the background color from the last compose - remove it
							var firstObj:Object = _composedLines[0];
							if (firstObj && !(firstObj is TextLine))
								_composedLines.splice(0,1);
							_composeRecycledInPlaceLines = 0;
							_composePushedLines = 0;
							callback = populateAndRecycleComposedLines;
						}
						else
						{
							clearComposedLines();
							callback = populateComposedLines;
						}
	
						var inputManagerFactory:TextLineFactoryBase = (_sourceState == SOURCE_STRING) ? inputManagerStringFactory(_config) : _inputManagerTextFlowFactory;
						inputManagerFactory.verticalScrollPolicy = _verticalScrollPolicy;
						inputManagerFactory.horizontalScrollPolicy = _horizontalScrollPolicy;
						inputManagerFactory.compositionBounds = new Rectangle(0,0,_compositionWidth,_compositionHeight);
						inputManagerFactory.swfContext = Configuration.playerEnablesArgoFeatures ? this : _swfContext;
							
						if (_sourceState == SOURCE_STRING)
						{
							var stringFactory:StringTextLineFactory = inputManagerFactory as StringTextLineFactory;
							// potential bug - here we use the format as textFlow.format but in the TextFlow case it is the hostFormat
							if (!TextLayoutFormat.isEqual(stringFactory.textFlowFormat,_hostFormat))
								stringFactory.textFlowFormat = _hostFormat;
							stringFactory.text = _text;
							stringFactory.createTextLines(callback);
						}
						else
							_inputManagerTextFlowFactory.createTextLines(callback,_textFlow);
							
						if (Configuration.playerEnablesArgoFeatures)
							_composedLines.length = _composePushedLines;

						bounds = inputManagerFactory.getContentBounds();
						
						if (_sourceState == SOURCE_STRING && _text.length == 0)
						{
							var obj:Object = new Object();
							obj.format = _hostFormat;
							obj.bounds = bounds.clone();
							
							_emptyFormatCache[formatHash()] = new WeakRef(obj);
						}
					}
					
					_contentLeft   = bounds.x;
					_contentTop    = bounds.y;
					_contentWidth  = bounds.width;
					_contentHeight = bounds.height;
					_damaged = false;
					
					// generate a compositionComplete event.  Note that the last composed position isn't known
					if (hasEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE))
						dispatchEvent(new CompositionCompleteEvent(CompositionCompleteEvent.COMPOSITION_COMPLETE,false,false,_textFlow,0,-1));						
				}
				_needsRedraw = true;
			}

		}
		
		/** Updates the display; calls either the factory or updateAllControllers().
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		public function updateContainer():void
		{
			compose();

			if (_composeState == COMPOSE_COMPOSER)
				_textFlow.flowComposer.updateAllControllers();
			else if (_needsRedraw)
			{
				var textObject:DisplayObject; 	// scratch - TextLines and background shapes
				if (Configuration.playerEnablesArgoFeatures)
				{
					// if the first child in the container is a Shape - its the background color - lose it
					if (_container.numChildren != 0)
					{
						textObject = _container.getChildAt(0);
						if (textObject && !(textObject is TextLine))
							_container.removeChildAt(0);
					}
						
					// if the first child in _composedLines is a shape push it at the head of the container
					textObject = _composedLines[0];
					if (textObject && !(textObject is TextLine))
						_container.addChildAt(textObject,0);
						
					// expect the leading lines are reused
					while (_container.numChildren < _composedLines.length)
						_container.addChild(_composedLines[_container.numChildren]);
					// recycle any trailing lines
					while (_container.numChildren > _composedLines.length)
					{
						var textLine:TextLine = _container.getChildAt(_composedLines.length) as TextLine;
						_container.removeChildAt(_composedLines.length);
						if (textLine)
						{
							// lines were rebroken but aren't being displayed
							if (textLine.validity == TextLineValidity.VALID)
								textLine.textBlock.releaseLines(textLine,textLine.textBlock.lastLine);
							textLine.userData = null;
							TextLineRecycler.addLineForReuse(textLine);
						}
					}
				}
				else
				{
					clearContainerChildren(false);
					
					for each (textObject in _composedLines)
						_container.addChild(textObject);
						
					clearComposedLines();
				}
									
				updateBackgroundAndVisibleRectangle();
				
				if (_handlersState == HANDLERS_NOTADDED)
					addActivationEventListeners();

				// generate a updateComplete event.  Note that the controller isn't known
				if (hasEventListener(UpdateCompleteEvent.UPDATE_COMPLETE))
					dispatchEvent(new UpdateCompleteEvent(UpdateCompleteEvent.UPDATE_COMPLETE,false,false,null));	
					
				_needsRedraw = false;
			}
		}
		
		/** @private */
		private function updateBackgroundAndVisibleRectangle() :void
		{
			drawBackgroundAndSetScrollRect(0,0);
		}
		
		private function addActivationEventListeners():void
		{	
			var newState:int =  HANDLERS_NONE;
			
			if (_editingMode != EditingMode.READ_ONLY && _composeState == COMPOSE_FACTORY)
				newState = _handlersState == HANDLERS_NOTADDED ? HANDLERS_CREATION : HANDLERS_ACTIVE;
			
			if (newState == _handlersState)
				return;
			
			removeActivationEventListeners();
				
			if (newState == HANDLERS_CREATION)
			{
				_container.addEventListener(FocusEvent.FOCUS_IN, requiredFocusInHandler);				
				_container.addEventListener(MouseEvent.MOUSE_OVER, requiredMouseOverHandler);
			}
			else if (newState == HANDLERS_ACTIVE)
			{
				_container.addEventListener(FocusEvent.FOCUS_IN, requiredFocusInHandler);				
				_container.addEventListener(MouseEvent.MOUSE_OVER, requiredMouseOverHandler);
				_container.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				_container.addEventListener(MouseEvent.MOUSE_OUT,  mouseOutHandler);
				_container.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			//	_container.addEventListener(IMEEvent.IME_START_COMPOSITION, imeStartCompositionHandler);
			// attach by literal event name to avoid Argo dependency
				_container.addEventListener("imeStartComposition", imeStartCompositionHandler);
				_container.contextMenu = getContextMenu();
				if (_container.contextMenu)
		            _container.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, menuSelectHandler);
		            
		        _container.addEventListener(Event.SELECT_ALL, editHandler);
			}
			
			_handlersState = newState;
		}
		
		// The ContextMenu to be used.  The idea is that this is undefined until createContextMenu is called and then 
		// createContextMenu is only called once and the result is shared with the ContainerController when it gets created
		private var _contextMenu:*;
		
		/** @private  Returns the already created contextMenu.  If not created yet create it.  */
		tlf_internal function getContextMenu():ContextMenu
		{
			if (_contextMenu === undefined)
				_contextMenu = createContextMenu();
			return _contextMenu;
		}

		private function removeActivationEventListeners():void
		{
			if (_handlersState == HANDLERS_CREATION)
			{
				_container.removeEventListener(FocusEvent.FOCUS_IN, requiredFocusInHandler);				
				_container.removeEventListener(MouseEvent.MOUSE_OVER, requiredMouseOverHandler);
			}
			else if (_handlersState == HANDLERS_ACTIVE)
			{
				_container.removeEventListener(FocusEvent.FOCUS_IN, requiredFocusInHandler);				
				_container.removeEventListener(MouseEvent.MOUSE_OVER, requiredMouseOverHandler);
				_container.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				_container.removeEventListener(MouseEvent.MOUSE_OUT,  mouseOutHandler);
				_container.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			//	_container.removeEventListener(IMEEvent.IME_START_COMPOSITION, imeStartCompositionHandler);
			// detach by literal event name to avoid Argo dependency
				_container.removeEventListener("imeStartComposition", imeStartCompositionHandler);
				if (_container.contextMenu)	
				{
	            	_container.contextMenu.removeEventListener(ContextMenuEvent.MENU_SELECT, menuSelectHandler);
					_container.contextMenu = null;
				}
		        _container.removeEventListener(Event.SELECT_ALL, editHandler);
			}
			_handlersState = HANDLERS_NOTADDED;
		}
		
		private function addTextFlowListeners():void
		{
			for each (var event:String in eventList)			
				_textFlow.addEventListener(event,dispatchEvent);
		}
		
		private function removeTextFlowListeners():void
		{
			for each (var event:String in eventList)			
				_textFlow.removeEventListener(event,dispatchEvent);
			_handlersState = HANDLERS_NONE;
		}
		
		/**
		 * @copy flash.events.IEventDispatcher#dispatchEvent()
		 * @private
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
 		 */
		public override function dispatchEvent(event:Event):Boolean
		{
			if (event.type == DamageEvent.DAMAGE)
			{
				_textDamaged = true;
				if (_composeState == COMPOSE_FACTORY)
					_damaged = true;
			}
			else if (event.type == FlowOperationEvent.FLOW_OPERATION_BEGIN)
			{
				if (_container.mouseChildren == false)
					_container.mouseChildren = true;
			}
			var result:Boolean = super.dispatchEvent(event);
			if (!result)
				event.preventDefault();
			return result;
		}
		
		private function clearContainerChildren(recycle:Boolean):void
		{
			while(_container.numChildren)
			{
				var textLine:TextLine = _container.getChildAt(0) as TextLine;
				_container.removeChildAt(0);
				if (textLine)
				{
					// releasing all textLines so release each still connected textBlock
					if (textLine.validity != TextLineValidity.INVALID && textLine.validity != TextLineValidity.STATIC)
					{
						var textBlock:TextBlock = textLine.textBlock;
						CONFIG::debug { Debugging.traceFTECall(null,textBlock,"releaseLines",textBlock.firstLine, textBlock.lastLine); }	
						textBlock.releaseLines(textBlock.firstLine,textBlock.lastLine);
					}					
					if (recycle)
					{
						textLine.userData = null;	// clear any userData
						TextLineRecycler.addLineForReuse(textLine);
					}
				}
			}
		}
		
		private function convertToTextFlow():void
		{
			CONFIG::debug { assert(_sourceState != SOURCE_TEXTFLOW,"bad call to convertToTextFlow"); }
									
			_textFlow = new TextFlow(_config);
			_textFlow.hostFormat = _hostFormat;
			if(_swfContext)
			{
				_textFlow.flowComposer.swfContext = _swfContext;
			}
	
			var p:ParagraphElement = new ParagraphElement();
			_textFlow.addChild(p)
			var s:SpanElement = new SpanElement();
			s.text = _text;
			p.addChild(s);
			_sourceState = SOURCE_TEXTFLOW;
			addTextFlowListeners();			
		}
				
		/** @private */
		tlf_internal function convertToTextFlowWithComposer():void
		{
			removeActivationEventListeners();
			
			if (_sourceState != SOURCE_TEXTFLOW)
				convertToTextFlow();
			
			if (_composeState != COMPOSE_COMPOSER)
			{
				clearContainerChildren(true);
				clearComposedLines();
				var controller:TMContainerController = new TMContainerController(_container,_compositionWidth,_compositionHeight,this);
				_textFlow.flowComposer = new StandardFlowComposer();
				_textFlow.flowComposer.addController(controller);
				_textFlow.flowComposer.swfContext = _swfContext;
				_composeState = COMPOSE_COMPOSER;
				
				invalidateInteractionManager();
				updateContainer();
			}
		}
		
		private function get effectiveBlockProgression():String
		{
			if (_textFlow)
				return _textFlow.computedFormat.blockProgression;
			return _hostFormat && _hostFormat.blockProgression && _hostFormat.blockProgression != FormatValue.INHERIT ? _hostFormat.blockProgression : BlockProgression.TB;
		}
		
		/* CONFIG::debug private static function doTrace(msg:String):void
		{ trace(msg); } */
		
		private function removeIBeamCursor():void
		{
			if (_ibeamCursorSet)
			{
				Mouse.cursor = MouseCursor.AUTO;
				_ibeamCursorSet = false;
			}
		}
		
		private var _hasScrollRect:Boolean = false;
		
		/** 
		 * Specifies whether this container has attached a ScrollRect object. Value is <code>true</code>
		 * or <code>false</code>. A display object is cropped to the size defined by the scroll rectangle, and 
		 * it scrolls within the rectangle when you change the x and y properties of the scrollRect object. 
		 *
		 * <p>This property enables a client to test for a ScrollRect object without accessing 
		 * the DisplayObject.scrollRect property, which can have side effects in some cases.</p> 
		 *
		 * @return true if the controller has attached a ScrollRect instance.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 *
		 * @see #drawBackgroundAndSetScrollRect 
		 */
		private function get hasScrollRect():Boolean
		{ return _hasScrollRect; }
		private function set hasScrollRect(value:Boolean):void
		{ _hasScrollRect = value; }
		
		/**   
		 * Returns <code>true</code> if it has filled in the container's scrollRect property.  
		 * This method enables you to test whether <code>scrollRect</code> is set without actually accessing the <code>scrollRect</code> property 
		 * which can possibly create a  performance issue. 
		 * <p>Override this method to draw a background or a border.  Overriding this method can be tricky as the scrollRect <bold>must</bold> 
		 * be set as specified.</p>
		 * 
		 * @param scrollX The starting horizontal position of the scroll rectangle.
		 * @param scrollY The starting vertical position of the scroll rectangle.
		 * 
		 * @return 	<code>true</code> if it has created the <code>scrollRect</code> object.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		public function drawBackgroundAndSetScrollRect(scrollX:Number,scrollY:Number):Boolean
		{
			var cont:Sprite = this.container;

 			var contentWidth:Number;
			var contentHeight:Number;
			if (_composeState == COMPOSE_FACTORY)
			{
				contentWidth = _contentWidth;
				contentHeight = _contentHeight;
			}
			else
			{
				var controller:ContainerController = getController();
				contentWidth = controller.contentWidth;
				contentHeight = controller.contentHeight
			}
			var width:Number;
			if (isNaN(compositionWidth))
			{
				var contentLeft:Number = (_composeState == COMPOSE_FACTORY) ? _contentLeft : controller.contentLeft;
				width = contentLeft + contentWidth;
			}
			else
				width = compositionWidth;
			var height:Number;
			if (isNaN(compositionHeight))
			{ 
				var contentTop:Number = (_composeState == COMPOSE_FACTORY) ? _contentTop : controller.contentTop;
				height = contentTop+contentHeight;
			}
			else
				height = compositionHeight;
			
			if (scrollX == 0 && scrollY == 0 && contentWidth <= width && contentHeight <= height)
			{
				// skip the scrollRect
				if (_hasScrollRect)
				{
					cont.scrollRect = null;
					_hasScrollRect = false;					
				}
			}
			else
			{
				cont.scrollRect = new Rectangle(scrollX, scrollY, width, height);
				_hasScrollRect = true;
				
				// adjust to the values actually in the scrollRect
				scrollX = cont.scrollRect.x;
				scrollY = cont.scrollRect.y;
				width = cont.scrollRect.width;
				height = cont.scrollRect.height;
			}
			
	        // NOTE: must draw a background for interaction support - even it if is 100% transparent
	        var s:Sprite = cont as Sprite;
	        if (s)
	        {
				s.graphics.clear();
				s.graphics.beginFill(0, 0); 
		       	s.graphics.drawRect(scrollX,scrollY,width,height);
		        s.graphics.endFill();
		    }
	
	        return _hasScrollRect;
		}
		
		/** Returns the focusedSelectionFormat - by default get it from the configuration.
		 * This can be overridden in the subclass to supply a different SelectionFormat
		 */
		protected function getFocusedSelectionFormat():SelectionFormat
		{
			return _config.focusedSelectionFormat;
		}
		
		/** Returns the inactiveSelectionFormat - by default get it from the configuration 
		 * This can be overridden in the subclass to supply a different SelectionFormat
		 */
		protected function getInactiveSelectionFormat():SelectionFormat
		{
			return _config.inactiveSelectionFormat;
		}
		
		/** Returns the unfocusedSelectionFormat - by default get it from the configuration 
		 * You can override this method in the subclass to supply a different SelectionFormat.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		protected function getUnfocusedSelectionFormat():SelectionFormat
		{
			return _config.unfocusedSelectionFormat;
		}
		
		/** 
		 * Returns the undo manager to use. By default, creates a unique undo manager. 
		 * You can override this method in the subclass if you want to customize the undo manager
		 * (for example, to use a shared undo manager for multiple TextContainerManager instances).
		 *
		 * @return 	new IUndoManager instance.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
	 	 */
		 
		protected function getUndoManager():IUndoManager
		{
			return new UndoManager();
		}
						
		/** Creates a ContextMenu for the TextContainerManager. Use the methods of the ContextMenu 
		 *  class to add items to the menu. 
		 * <p>You can override this method to define a custom context menu.</p>
		 *
		 * @return 	the created context menu.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 * @see flash.ui.ContextMenu ContextMenu
		 */
		protected function createContextMenu():ContextMenu
		{
			return ContainerController.createDefaultContextMenu();
		}
		/** @copy flashx.textLayout.container.ContainerController#editHandler()
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
 		 *
 		 * @see flash.events.Event Event
		 */	
		public function editHandler(event:Event):void
		{
			if (_composeState == COMPOSE_FACTORY)
			{
				convertToTextFlowWithComposer();
				getController().editHandler(event);
				_textFlow.interactionManager.setFocus();
			}
			else
				getController().editHandler(event);
		}
		
		/** @copy flashx.textLayout.container.ContainerController#keyDownHandler() 
		*
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.KeyboardEvent#KEY_DOWN KeyboardEvent.KEY_DOWN
		*/	
		public function keyDownHandler(event:KeyboardEvent):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().keyDownHandler(event);
		}
		
		/** @copy flashx.textLayout.container.ContainerController#keyUpHandler().
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.KeyboardEvent#KEY_UP KeyboardEvent.KEY_UP
		*/	
		public function keyUpHandler(event:KeyboardEvent):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().keyUpHandler(event);
		}

		/** @copy flashx.textLayout.container.ContainerController#keyFocusChangeHandler().
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 * 	@param	event	the FocusChange event
		 */	
		public function keyFocusChangeHandler(event:FocusEvent):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().keyFocusChangeHandler(event);
		}
		
		/** @copy flashx.textLayout.container.ContainerController#textInputHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.TextEvent#TEXT_INPUT TextEvent.TEXT_INPUT
		*/
		public function textInputHandler(event:TextEvent):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().textInputHandler(event);
		}

		/** Processes the <code>IME_START_COMPOSITION</code> event when the client manages events.
		 *
		 * @param event  The IMEEvent object.
		 *
		 * @playerversion Flash 10.1
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * 
		 *
		 * @see flash.events.IMEEvent#IME_START_COMPOSITION IMEEvent.IME_START_COMPOSITION
		 */
		public function imeStartCompositionHandler(event:IMEEvent):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().imeStartCompositionHandler(event);
		}
		
		/** @copy flashx.textLayout.container.ContainerController#mouseDownHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.MouseEvent#MOUSE_DOWN MouseEvent.MOUSE_DOWN
		*/	
		public function mouseDownHandler(event:MouseEvent):void
		{
			// doTrace("IM:mouseDownHandler");
			// before the mouseDown do a mouseOver
			if (_composeState == COMPOSE_FACTORY)
			{
				CONFIG::debug { assert(event.currentTarget == this.container,"TextContainerManager:mouseDownHandler - unexpected currentTarget"); }
				convertToTextFlowWithComposer();
				getController().requiredFocusInHandler(null);
				getController().requiredMouseOverHandler(event.target != container ? new RemappedMouseEvent(event) : event);
				if (_hasFocus)
					getController().requiredFocusInHandler(null);
				getController().requiredMouseDownHandler(event);
			}
			else
				getController().mouseDownHandler(event);
		}

		/** @copy flashx.textLayout.container.ContainerController#mouseMoveHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.MouseEvent#MOUSE_MOVE MouseEvent.MOUSE_MOVE
		*/	
		public function mouseMoveHandler(event:MouseEvent):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().mouseMoveHandler(event);
		}
		
		/** @copy flashx.textLayout.container.ContainerController#mouseUpHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.MouseEvent#MOUSE_UP MouseEvent.MOUSE_UP
		*/	
		public function mouseUpHandler(event:MouseEvent):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().mouseUpHandler(event);
		}
		
		/** @copy flashx.textLayout.container.ContainerController#mouseDoubleClickHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.MouseEvent#DOUBLE_CLICK MouseEvent.DOUBLE_CLICK
		*/	
		public function mouseDoubleClickHandler(event:MouseEvent):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().mouseDoubleClickHandler(event);
		}

		/** @private Process a mouseOver event.
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
		*/			
		tlf_internal final function requiredMouseOverHandler(event:MouseEvent):void
		{
			if (_composeState == COMPOSE_FACTORY)
				mouseOverHandler(event);
			if (_composeState == COMPOSE_COMPOSER)
				getController().requiredMouseOverHandler(event);
		}
		

		/** Process a mouseOver event.
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.MouseEvent#MOUSE_OVER MouseEvent.MOUSE_OVER
		*/			
		public function mouseOverHandler(event:MouseEvent):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().mouseOverHandler(event);
			else
			{
				// doTrace("IM:mouseOverHandler");
				if (effectiveBlockProgression != BlockProgression.RL)
				{
					Mouse.cursor = MouseCursor.IBEAM;
					_ibeamCursorSet = true;
				}	
				addActivationEventListeners();
			}
		}
		/** @copy flashx.textLayout.container.ContainerController#mouseOutHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.MouseEvent#MOUSE_OUT MouseEvent.MOUSE_OUT
		*/					
		public function mouseOutHandler(event:MouseEvent):void
		{
			// doTrace("IM:mouseOutHandler");
			if (_composeState == COMPOSE_FACTORY)
				removeIBeamCursor();
			else
				getController().mouseOutHandler(event);
		}		
		/** @copy flashx.textLayout.container.ContainerController#focusInHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.FocusEvent#FOCUS_IN FocusEvent.FOCUS_IN
		*/

		
		/** Process a focusIn event.
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
		*/
		public function focusInHandler(event:FocusEvent):void
		{
			_hasFocus = true;
			if (_composeState == COMPOSE_COMPOSER)
				getController().focusInHandler(event);
		}
		
		/** @private hook to get at requiredFocusOutHandler as needed */
		tlf_internal function requiredFocusOutHandler(event:FocusEvent):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().requiredFocusOutHandler(event);
		}
		/** @copy flashx.textLayout.container.ContainerController#focusOutHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.FocusEvent#FOCUS_OUT FocusEvent.FOCUS_OUT
		*/
		public function focusOutHandler(event:FocusEvent):void
		{
			_hasFocus = false;
			if (_composeState == COMPOSE_COMPOSER)
				getController().focusOutHandler(event);
		}

		/** @copy flashx.textLayout.container.ContainerController#activateHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.Event#ACTIVATE Event.ACTIVATE
		*/				
		public function activateHandler(event:Event):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().activateHandler(event);
		}		
		/** @copy flashx.textLayout.container.ContainerController#deactivateHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		* @see flash.events.Event#DEACTIVATE Event.DEACTIVATE
		*/				
		public function deactivateHandler(event:Event):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().deactivateHandler(event);
		}
		
		/** @copy flashx.textLayout.container.ContainerController#focusChangeHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		*
 		* @see flash.events.FocusEvent#KEY_FOCUS_CHANGE FocusEvent.KEY_FOCUS_CHANGE
		* @see flash.events.FocusEvent#MOUSE_FOCUS_CHANGE FocusEvent.MOUSE_FOCUS_CHANGE
		*/				
		public function focusChangeHandler(event:FocusEvent):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().focusChangeHandler(event);
		}
		
		/** @copy flashx.textLayout.container.ContainerController#menuSelectHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		*
 		* @see flash.events.ContextMenuEvent#MENU_SELECT ContextMenuEvent.MENU_SELECT
		*/				
		public function menuSelectHandler(event:ContextMenuEvent):void
		{
			if (_composeState == COMPOSE_FACTORY)
			{
				// there is no selection
				var cbItems:ContextMenuClipboardItems = _container.contextMenu.clipboardItems
				cbItems.selectAll = _editingMode != EditingMode.READ_ONLY;
				cbItems.clear = false;
				cbItems.copy = false;
				cbItems.cut = false;
				cbItems.paste = false;
			}
			else
				getController().menuSelectHandler(event);			
		}
		
		/** @copy flashx.textLayout.container.ContainerController#mouseWheelHandler()
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
 		*
 		* @see flash.events.MouseEvent#MOUSE_WHEEL MouseEvent.MOUSE_WHEEL
		*/				
		public function mouseWheelHandler(event:MouseEvent):void
		{
			if (_composeState == COMPOSE_FACTORY)
			{
				convertToTextFlowWithComposer();
				getController().requiredMouseOverHandler(event);
			}
			getController().mouseWheelHandler(event);
		}

		
		/** @private required FocusIn handler.  Clients override focusInHandler
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
		*/
		tlf_internal final function requiredFocusInHandler(event:FocusEvent):void
		{			
			// doTrace("IM:focusInHandler");
			if (_composeState == COMPOSE_FACTORY)
			{
				addActivationEventListeners();
				focusInHandler(event);
			}			
			if (_composeState == COMPOSE_COMPOSER)
				getController().requiredFocusInHandler(event);
		}
		
		/** 
		 * Called to request clients to begin the forwarding of mouseup and mousemove events from outside a security sandbox.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 */
		public function beginMouseCapture():void
		{ }
		/** 
		 * Called to inform clients that the the forwarding of mouseup and mousemove events from outside a security sandbox is no longer needed.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 */
		public function endMouseCapture():void
		{ }
		/** Client call to forward a mouseUp event from outside a security sandbox.  Coordinates of the mouse up are not needed.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 */
		public function mouseUpSomewhere(e:Event):void
		{
			if (_composeState == COMPOSE_COMPOSER)
				getController().mouseUpSomewhere(e);
		}
		/** Client call to forward a mouseMove event from outside a security sandbox.  Coordinates of the mouse move are not needed.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 *
		 */		
		public function mouseMoveSomewhere(e:Event):void
		{ 
			if (_composeState == COMPOSE_COMPOSER)
				getController().mouseUpSomewhere(e);
		}
		
	}
	
}

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.geom.Point;

import flashx.textLayout.container.ContainerController;
import flashx.textLayout.container.ScrollPolicy;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.edit.IInteractionEventHandler;
import flashx.textLayout.formats.BlockProgression;
import flashx.textLayout.tlf_internal;
import flash.events.MouseEvent;
import flashx.textLayout.formats.BackgroundColor;
import flash.ui.ContextMenu;

use namespace tlf_internal;

class TMContainerController extends ContainerController
{
	private var _inputManager:TextContainerManager;
	
	public function TMContainerController(container:Sprite, compositionWidth:Number, compositionHeight:Number, tm:TextContainerManager)
	{
		super(container,compositionWidth,compositionHeight);
		_inputManager = tm;
		verticalScrollPolicy = tm.verticalScrollPolicy;
		horizontalScrollPolicy = tm.horizontalScrollPolicy;
	}

	/** Reroute to the TextContainerManger's override.  Reuse the one that's already been created. */
	protected override function createContextMenu():ContextMenu
	{ return _inputManager.getContextMenu(); }

	/** @private */
	protected override function get attachTransparentBackground():Boolean
	{ return false; }
	
	/** @private */
	tlf_internal function doUpdateVisibleRectangle():void
	{ updateVisibleRectangle(); }
	
	/** @private. Override clones and enhances parent class functionality. */
	protected override function updateVisibleRectangle() :void
	{
		var xpos:Number;
		var ypos:Number;
		// see the adjustLines boolean in ContainerController.fillShapeChildren - this logic clones that and allows for skipping the scrollRect
		xpos = effectiveBlockProgression == BlockProgression.RL && (verticalScrollPolicy != ScrollPolicy.OFF || horizontalScrollPolicy != ScrollPolicy.OFF) ? horizontalScrollPosition - compositionWidth : horizontalScrollPosition;
		ypos = verticalScrollPosition;
			
		_hasScrollRect = _inputManager.drawBackgroundAndSetScrollRect(xpos,ypos);
	}
		
	/** @private */
	tlf_internal override function getInteractionHandler():IInteractionEventHandler
	{ return _inputManager; }

}

// remap the mouse event for processing inside TLF.  This is just the initial click.  Make it as if the event was on the container and not the textline
class RemappedMouseEvent extends MouseEvent
{
	private var _event:MouseEvent;
	
	public function RemappedMouseEvent(event:MouseEvent,cloning:Boolean = false)
	{
		var containerPoint:Point;
		if (!cloning)
		{
			containerPoint = DisplayObject(event.target).localToGlobal(new Point(event.localX, event.localY));
			containerPoint = DisplayObject(event.currentTarget).globalToLocal(containerPoint);
		}
		else
			containerPoint = new Point();

		/* event.commandKey,event.controlKey,event.clickCount are also supported in AIR.  IMHO they are a nonissue for the initial click */
		super(event.type,event.bubbles,event.cancelable,containerPoint.x,containerPoint.y,event.relatedObject,event.ctrlKey,event.altKey,event.shiftKey,event.buttonDown,event.delta);
		
		_event = event;
	}

	// override methods/getters for things we couldn't set in the base class	

	public override function get target():Object
	{ return _event.currentTarget; }
	
	public override function get currentTarget():Object
	{ return _event.currentTarget; }
	
	public override function get eventPhase():uint
	{ return _event.eventPhase; }
	
	public override function get isRelatedObjectInaccessible():Boolean
	{ return _event.isRelatedObjectInaccessible; }
	
	public override function get stageX():Number
	{ return _event.stageX; }
	
	public override function get stageY():Number
	{ return _event.stageY; }
	
	public override function clone():Event
	{ 
		var rslt:RemappedMouseEvent = new RemappedMouseEvent(_event,true); 
		rslt.localX = localX;
		rslt.localY = localY;
		return rslt;
	}
	
	public override function updateAfterEvent():void
	{ _event.updateAfterEvent(); }
	
	public override function isDefaultPrevented():Boolean
	{ return _event.isDefaultPrevented(); }
	
	public override function preventDefault():void
	{ _event.preventDefault(); }
	
	public override function stopImmediatePropagation():void
	{ _event.stopImmediatePropagation(); }
	
	public override function stopPropagation():void
	{ _event.stopPropagation(); }
}
