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
package flashx.textLayout.edit
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IMEEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.engine.TextLine;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.GlobalSettings;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ListElement;
	import flashx.textLayout.elements.ListItemElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TableCellElement;
	import flashx.textLayout.elements.TableElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.elements.TextRange;
	import flashx.textLayout.events.FlowOperationEvent;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.formats.IListMarkerFormat;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.operations.ApplyElementIDOperation;
	import flashx.textLayout.operations.ApplyElementTypeNameOperation;
	import flashx.textLayout.operations.ApplyFormatOperation;
	import flashx.textLayout.operations.ApplyFormatToElementOperation;
	import flashx.textLayout.operations.ApplyLinkOperation;
	import flashx.textLayout.operations.ApplyTCYOperation;
	import flashx.textLayout.operations.ClearFormatOnElementOperation;
	import flashx.textLayout.operations.ClearFormatOperation;
	import flashx.textLayout.operations.CompositeOperation;
	import flashx.textLayout.operations.CreateDivOperation;
	import flashx.textLayout.operations.CreateListOperation;
	import flashx.textLayout.operations.CreateSubParagraphGroupOperation;
	import flashx.textLayout.operations.CutOperation;
	import flashx.textLayout.operations.DeleteTextOperation;
	import flashx.textLayout.operations.FlowOperation;
	import flashx.textLayout.operations.InsertInlineGraphicOperation;
	import flashx.textLayout.operations.InsertTableElementOperation;
	import flashx.textLayout.operations.InsertTextOperation;
	import flashx.textLayout.operations.ModifyInlineGraphicOperation;
	import flashx.textLayout.operations.MoveChildrenOperation;
	import flashx.textLayout.operations.PasteOperation;
	import flashx.textLayout.operations.RedoOperation;
	import flashx.textLayout.operations.SplitElementOperation;
	import flashx.textLayout.operations.SplitParagraphOperation;
	import flashx.textLayout.operations.UndoOperation;
	import flashx.textLayout.utils.CharacterUtil;
	import flashx.textLayout.utils.GeometryUtil;
	import flashx.textLayout.utils.NavigationUtil;
	import flashx.undo.IOperation;
	import flashx.undo.IUndoManager;
		
	use namespace tlf_internal;
	
	/** 
	 * The EditManager class manages editing changes to a TextFlow. 
	 * 
	 * <p>To enable text flow editing, assign an EditManager object to the <code>interactionManager</code> 
	 * property of the TextFlow object. The edit manager handles changes to the text (such as insertions, 
	 * deletions, and format changes). Changes are reversible if the edit manager has an undo manager. The edit
	 * manager triggers the recomposition and display of the text flow, as necessary.</p>
	 *
	 * <p>The EditManager class supports the following keyboard shortcuts:</p>
	 * 
	 * <table class="innertable" width="100%">
	 *  <tr><th>Keys</th><th>Result</th></tr>
	 *  <tr><td>ctrl-z</td><td>undo</td></tr>					
	 * 	<tr><td>ctrl-y</td><td>redo</td></tr>					
	 * 	<tr><td>ctrl-backspace</td><td>deletePreviousWord</td></tr>					
	 * 	<tr><td>ctrl-delete</td><td>deleteNextWord</td></tr>					
	 * 	<tr><td>alt+delete</td><td>deleteNextWord</td></tr>					
	 * 	<tr><td>ctrl+alt-delete</td><td>deleteNextWord</td></tr>					
	 * 	<tr><td>ctrl-shift-hyphen</td><td>insert discretionary hyphen</td></tr>					
	 * 	<tr><td>ctrl+backspace</td><td>deletePreviousWord</td></tr>					
	 * 	<tr><td>alt+backspace</td><td>deletePreviousWord</td></tr>					
	 * 	<tr><td>ctrl+alt-backspace</td><td>deletePreviousWord</td></tr>					
	 * 	<tr><td>INSERT</td><td>toggles overWriteMode</td></tr>					
	 * 	<tr><td>backspace</td><td>deletePreviousCharacter</td></tr>					
	 * 	<tr><td>ENTER</td><td>if textFlow.configuration.manageEnterKey in a list it creates a new list item, otherwise creates a new paragraph</td></tr>					
	 * 	<tr><td>shift-ENTER</td><td>if textFlow.configuration.manageEnterKey creates a new paragraph</td></tr>					
	 * 	<tr><td>TAB</td><td>if textFlow.configuration.manageTabKey in a list it creates nested list, otherwise inserts a TAB or overwrites next character with a TAB</td></tr>    
	 * 	<tr><td>shift-TAB</td><td>if textFlow.configuration.manageTabKey in the first item of a list it moves the item out of the list (promotes it)</td></tr>    
	 * </table>
	 *
	 * <p><strong>Note:</strong> The following keys do not work on Windows: alt-backspace, alt-delete, ctrl+alt-backspace,
	 * and ctrl+alt-delete. These keys do not generate an event for the runtime.</p>						
 	 * 
 	 * @see flashx.textLayout.elements.TextFlow
 	 * @see flashx.undo.UndoManager
	 *
	 * @includeExample examples\EditManager_example.as -noswf
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	 */			
	public class EditManager extends SelectionManager implements IEditManager
	{
		static tlf_internal var handleShiftAsSoftReturn:Boolean = true;
		 /**
		 *  To minimize expensive recompositions during fast typing, inserts
		 *  don't necessarily take place immediately. An insert operation that
		 *  hasn't yet executed is held here.
		 */
		private var pendingInsert:InsertTextOperation;
		
		/* 
		 * The object that has the ENTER_FRAME event listener attached to perform pending inserts.
		 */
		private var enterFrameListener:DisplayObjectContainer;

		/* True if updates get handled on enter_frame, and not immediately. */
		private var _delayUpdates:Boolean = false;
		
		/* True if some operations (e.g., handling of text events) can be delayed to next enterFrame by default. False for immediate handling */
		private var _allowDelayedOperations:Boolean = true;
		
		/*
		 * The object that has the ENTER_FRAME event listener attached to perform pending updates.
		 */
		private var redrawListener:DisplayObjectContainer;

		/*
		 *  Some operations can be undone & redone. The undoManager keeps track
		 *  of the operations that have been done or undone so that they can be undone or
		 *  redone.  I'm not sure if only text operations can be undone. If so, the undoManager
		 *  should probably be moved to EditManager.
		 */
		private var _undoManager:flashx.undo.IUndoManager;
		
		private var _imeSession:IMEClient;
		private var _imeOperationInProgress:Boolean;
		
		/** 
		 * Indicates whether overwrite mode is on or off.
		 * 
		 * <p>If <code>true</code>, then a keystroke overwrites the character following the cursor.
		 * If <code>false</code>, then a keystroke is inserted at the cursor location.</p> 
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		*/		
		public static var overwriteMode:Boolean = false;
		
		/** 
		 * Creates an EditManager object.
		 * 
		 * <p>Assign an EditManager object to the <code>interactionManager</code> property
		 * of a text flow to enable editing of that text flow. </p>
		 *
		 * <p>To enable support for undoing and redoing changes, pass an 
		 * IUndoManager instance to the EditManager constructor. You can use
		 * the <code>flashx.undo.UndoManager</code> class
		 * or create a custom IUndoManager instance. Use a custom IUndoManager instance
		 * to integrate Text Layout Framework changes with an existing
		 * undo manager that is not an instance of the UndoManager class.
		 * To create a custom IUndoManager instance, ensure that the class
		 * you use to define the undo manager 
		 * implements the IUndoManager interface.</p>
		 * 
		 * 
		 * @param undo	The UndoManager for the application
		 * 
		 * @see flashx.textLayout.elements.TextFlow#interactionManager
		 * @see flashx.undo.IUndoManager
		 * 
		 * @includeExample examples\EditManager_constructor.as -noswf
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		public function EditManager(undoManager:flashx.undo.IUndoManager = null)
		{
			super();
			_undoManager = undoManager;
		}

		/**  
		 * The IUndoManager assigned to this edit manager.
		 * 
		 * <p>To allow edits to be undone (and redone), pass an IUndoManager instance to the EditManager
		 * constructor. The undo manager maintains a stack of operations that have been executed, and it can 
		 * undo or redo individual operations. </p>
		 * 
		 * <p><b>Note:</b> If the TextFlow is modified directly (not via
		 * calls to the EditManager, but directly via calls to the managed FlowElement objects), then the EditManager
		 * clears the undo stack to prevent the stack from getting out of sync with the current state.</p>
		 * 
	 	 * @playerversion Flash 10
	 	 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */	
		public function get undoManager():flashx.undo.IUndoManager
		{
			return _undoManager;
		}
		
		// Backdoor provided so that IMEClient can temporarily use an undo manager to maintain the IME session state.
		/** @private */
		tlf_internal function setUndoManager(undoManager:flashx.undo.IUndoManager):void
		{
			_undoManager = undoManager;
		}
		
		/** @private */
		override public function editHandler(event:Event):void
		{
			if (event.isDefaultPrevented())
				return;

			super.editHandler(event);
			switch (event.type)
			{
				case Event.CUT: 
				case Event.CLEAR:
					if (activePosition != anchorPosition)
					{
						if (event.type == Event.CUT)
							TextClipboard.setContents(cutTextScrap());
						else
							deleteText(null);
						event.preventDefault();
					}
					break;
				case Event.PASTE:
					pasteTextScrap(TextClipboard.getContents());
					event.preventDefault();
					break;
			}
		}

		// ///////////////////////////////////
		// keyboard methods 
		// ///////////////////////////////////
		
		/** @private */
		public override function keyDownHandler(event:KeyboardEvent):void
		{
			var listItem:ListItemElement;
			var operationState:SelectionState;
			
			if (!hasSelection() || event.isDefaultPrevented())
				return;
			
			if (redrawListener)		// pending redraw; handle this before anything else so TextLines on screen will be up to date
				updateAllControllers();
			
			super.keyDownHandler(event);
			
			if (event.ctrlKey)
			{
				// The player subsequently sends a text input event (which should be ignored) as listed below:
				// CTRL/CMD+z: Only on Mac when using a pre-Argo player version
				// CTRL/CMD+y: On all platforms (the exact char code for the text input event is platform dependent) 
				if (!event.altKey)
				{
					if (_imeSession != null && ((event.charCode == 122) || (event.charCode == 121)))
						_imeSession.compositionAbandoned();		// must be done before undo or redo start b/c IME session uses undo also for its own rollback
					// do Operation will also cancel the session.
					
					switch(event.charCode)
					{
						case 122:	// small z
							/* pre-Argo and on the mac then ignoreNextTextEvent */ 
							if (!Configuration.versionIsAtLeast(10,1) && (Capabilities.os.search("Mac OS") > -1)) 
								ignoreNextTextEvent = true;
							if(event.shiftKey){
								redo();
								event.preventDefault();

							} else {
								undo();
								event.preventDefault();
							}
							break;
						case 121:	// small y
							ignoreNextTextEvent = true;
							redo();
							event.preventDefault();
							break;
						case Keyboard.BACKSPACE:
							if (_imeSession)
								_imeSession.compositionAbandoned();
							deletePreviousWord();
							event.preventDefault();
							break;
					}
					if (event.keyCode == Keyboard.DELETE)
					{
						if (_imeSession)
							_imeSession.compositionAbandoned();
						deleteNextWord();
						event.preventDefault();
					}
					
					if (event.shiftKey)
					{
						// detect ctrl-shift-"-" (cnd-shift-"-" on mac) and insert a DH
						if (event.charCode == 95)
						{
							if (_imeSession)
								_imeSession.compositionAbandoned();
							
							//a discretionary hyphen is being inserted. 
							var discretionaryHyphenString:String = String.fromCharCode(0x000000AD);
							overwriteMode ? overwriteText(discretionaryHyphenString) : insertText(discretionaryHyphenString);
							event.preventDefault();
						}
					}
				}
			} 
			else if (event.altKey)
			{
				if (event.charCode == Keyboard.BACKSPACE)
				{
					deletePreviousWord();
					event.preventDefault();
				}
				else if (event.keyCode == Keyboard.DELETE)
				{
					deleteNextWord();
					event.preventDefault();
				}
			}
			// not ctrl key or alt key
			else if (event.keyCode == Keyboard.DELETE) //del
			{
				deleteNextCharacter();
				event.preventDefault();
			}
			else if (event.keyCode == Keyboard.INSERT) //insert
			{
				overwriteMode = !overwriteMode;				
				event.preventDefault();
			}
			else switch(event.charCode) {
				case Keyboard.BACKSPACE:
					deletePreviousCharacter();
					event.preventDefault();
					break;
				case Keyboard.ENTER:
					if (textFlow.configuration.manageEnterKey) 
					{
						var firstLeaf:FlowLeafElement = textFlow.findLeaf(absoluteStart);
						listItem = firstLeaf.getParentByType(ListItemElement) as ListItemElement;
						// if the listitem has a ListElement child then treat this as a regular Paragraph
						if (listItem && firstLeaf.getParentByType(ListElement) != listItem.getParentByType(ListElement))
							listItem = null;
						
						// inside a list shift-enter splits a paragraph and enter splits the listitem
						if (listItem && !event.shiftKey)
						{
							// if on last item of list and it's empty, remove it and put cursor on a new para immediatly following the list (new para should be wrapped in a new list item if parent of list is another list).
							if(listItem.textLength == 1 && listItem.parent.getChildIndex(listItem) == listItem.parent.numChildren - 1)
							{
								operationState = defaultOperationState();
								if (!operationState)
									return;
								
								doOperation(new MoveChildrenOperation(operationState, listItem.parent, listItem.parent.getChildIndex(listItem), 1, listItem.parent.parent, listItem.parent.parent.getChildIndex(listItem.parent) + 1));
							}
							else
							{
								splitElement(listItem);
								// push cursor past the marker
								selectRange(absoluteStart+1,absoluteStart+1);
								refreshSelection();
							}
						}
						else if(event.shiftKey &&
							((!listItem && textFlow.configuration.shiftEnterLevel > 0) ||
							textFlow.configuration.shiftEnterLevel > 1)
						)
						{
							overwriteMode ? overwriteText("\u2028") : insertText("\u2028");
						}
						else
							splitParagraph();
						event.preventDefault();
						event.stopImmediatePropagation();
					}
					break;
				case Keyboard.TAB:
					if (textFlow.configuration.manageTabKey) 
					{
						listItem  = textFlow.findLeaf(absoluteStart).getParentByType(ListItemElement) as ListItemElement;
						if (listItem && listItem.getAbsoluteStart() == absoluteStart)
						{
							operationState = defaultOperationState();
							if (!operationState)
								return;
							
							if(event.shiftKey)
							{
								// unindent by moving list element(s) out of parent into grandparent
								
								// first make sure there is a grandparent
								if(listItem.parent.parent is ListElement && listItem.parent.getChildIndex(listItem) == 0)
								{
									var source:FlowGroupElement;
									var target:FlowGroupElement;
									var numElements:int;
									var sourceIndex:int;
									var targetIndex:int;
									
									{
										source = listItem.parent;
										target = listItem.parent.parent;
										numElements = listItem.parent.numChildren;
										sourceIndex = 0;
										targetIndex = listItem.parent.parent.getChildIndex(listItem.parent);
									}
									doOperation(new MoveChildrenOperation(operationState, source, sourceIndex, numElements, target, targetIndex));
								}
							}
							else
							{
								// create new list from list element(s)
								var element:FlowGroupElement = listItem;
								if(listItem.parent.getChildIndex(listItem) == 0) 
									element = listItem.parent;
								
								doOperation(new CreateListOperation(new SelectionState(textFlow, element.getAbsoluteStart(), element.getAbsoluteStart() + element.textLength), listItem.parent));
							}
						}
						else if (textFlow.nestedInTable()) {
							var cell:TableCellElement;
							
							if (event.shiftKey) {
								cell = (textFlow.parentElement as TableCellElement).getPreviousCell();
							}
							else {
								cell = (textFlow.parentElement as TableCellElement).getNextCell();
							}
							
							// select next cell in table
							if (cell && cell.textFlow && cell.textFlow.interactionManager is EditManager) {
								//cell.textFlow.interactionManager.selectLastPosition();
								cell.textFlow.interactionManager.selectAll();
								cell.textFlow.interactionManager.setFocus();
							}
						}
						else
						{
							overwriteMode ? overwriteText(String.fromCharCode(event.charCode)) : insertText(String.fromCharCode(event.charCode));
						}
						event.preventDefault();
					}
					break;
			}
		}
		
		/** @private */
		public override function keyUpHandler(event:KeyboardEvent):void
		{
			if (!hasSelection() || event.isDefaultPrevented())
				return;
				
			super.keyUpHandler(event);
			
			if ((textFlow.configuration.manageEnterKey && event.charCode == Keyboard.ENTER) || (textFlow.configuration.manageTabKey && event.charCode == Keyboard.TAB)) {
				event.stopImmediatePropagation();
			}
		}
		
		/** @private */	
		public override function keyFocusChangeHandler(event:FocusEvent):void
		{
			if (textFlow.configuration.manageTabKey) 
				event.preventDefault();
		}
	
		/** @private */
		public override function mouseDownHandler(event:MouseEvent):void
		{
			if (redrawListener)
				updateAllControllers();
			super.mouseDownHandler(event);
		}
		
		/** @private */
		public override function textInputHandler(event:TextEvent):void
		{
			if (!ignoreNextTextEvent)
			{
				var charCode:int = event.text.charCodeAt(0);
				// only if its a space or larger - ignore control characters here
				if (charCode >=  32)
					overwriteMode ? overwriteText(event.text) : insertText(event.text);
			}
			ignoreNextTextEvent = false;
		}
		
		/** @private */
		override public function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			if (_imeSession && selectionFormatState != SelectionFormatState.FOCUSED)
				_imeSession.compositionAbandoned();
		}
		
		/** @private */
		override public function deactivateHandler(event:Event):void
		{
			super.deactivateHandler(event);
			if (_imeSession)
				_imeSession.compositionAbandoned();
		}
		
		/** @private */
		override public function imeStartCompositionHandler(event:IMEEvent):void
		{
			CONFIG::debug{ assert(!_imeSession, "IME session already in progress: IME not reentrant!"); }
		//	CONFIG::debug { Debugging.traceOut("imeStartComposition event"); }

			// any pending operations must be executed first, to
			// preserve operation order.
			flushPendingOperations();
			
			// Coded to avoid dependency on Argo (10.1). 
			if (!(event["imeClient"]))
			{
				_imeSession = new IMEClient(this);
				_imeOperationInProgress = false;
				event["imeClient"] = _imeSession;
			}
		}
		
		/** @private */
		override public function setFocus():void
		{
			var flowComposer:IFlowComposer = textFlow ? textFlow.flowComposer : null;
			if (_imeSession && flowComposer && flowComposer.numControllers > 1)
			{
				// container with the ime start position gets the key focus
				_imeSession.setFocus();

				setSelectionFormatState(SelectionFormatState.FOCUSED);
			}
			else
				super.setFocus();
			
			/* CONFIG::debug
			{
				if (textFlow.flowComposer.getControllerAt(0).container.stage)
				{
					var focusDI:DisplayObject = textFlow.flowComposer.getControllerAt(0).container.stage.focus;
					trace("set focus to ", focusDI.hasOwnProperty("name") ? focusDI["name"] : focusDI.toString());
				}
			} */
		}
		/** @private */		
		tlf_internal function endIMESession():void
		{
			_imeSession = null;
			var flowComposer:IFlowComposer = textFlow ? textFlow.flowComposer : null;
			if (flowComposer && flowComposer.numControllers > 1)
				setFocus();
		}
		/** @private */
		tlf_internal function beginIMEOperation():void
		{
			_imeOperationInProgress = true;
			beginCompositeOperation();
		}
		/** @private */
		tlf_internal function endIMEOperation():void
		{
			endCompositeOperation();
			_imeOperationInProgress = false;
		}

		/** @private We track the nesting level of the doOperation, because in finalize we need to know if
		we are at the outermost level and need to push the operation on the undo stack and redraw
		the screen, or if we're in a nested level and need to append the operation to the next
		level up. */
		tlf_internal var captureLevel:int = 0;

		/** 
		  * @copy IEditManager#doOperation()
		  * 
		  * @includeExample examples\EditManager_doOperation.as -noswf
		  * 
		  * @playerversion Flash 10
		  * @playerversion AIR 1.5
 	 	  * @langversion 3.0
		  */
		public override function doOperation(operation:FlowOperation):void
		{
			CONFIG::debug { assert(operation.textFlow == this.textFlow,"Operation from a different TextFlow"); }
			
			// If we get any operation during an IME session that is not owned by the session, we cancel the IME
			if (_imeSession && !_imeOperationInProgress)
				_imeSession.compositionAbandoned();
			
			// any pending operations must be executed first, to
			// preserve operation order.
			flushPendingOperations();
			
			try
			{
				captureLevel++;
				operation = doInternal(operation);
			}
			catch(e:Error)
			{
				captureLevel--;
				throw(e);
			}
			captureLevel--;
			
			if (operation)			// don't finalize if operation was cancelled
				finalizeDo(operation);
		}

		private function finalizeDo(op:FlowOperation):void
		{
			// Handle operation if we're in a beginCompositeOperation/endCompositeOperation context
			// In this case any nested commands we do will get added to the composite operation when 
			// they're done instead of added to the undo stack.
			var parentOperation:CompositeOperation;
			if (parentStack && parentStack.length > 0)
			{
				var parent:Object = parentStack[parentStack.length - 1];
				if (parent.captureLevel == captureLevel)
					parentOperation = parent.operation as CompositeOperation;
			}

	//		CONFIG::debug { assert(captureLevel == 0 || parentOperation != null, "missing parent for nested operation"); }
			
			if (parentOperation)
				parentOperation.addOperation(op);
			
			else if (captureLevel == 0)
			{
				captureOperations.length = 0; 
				if (_undoManager)
				{
					if (_undoManager.canUndo() && allowOperationMerge)
					{
						var lastOp:FlowOperation = _undoManager.peekUndo() as FlowOperation;
						if (lastOp)
						{
							// Try to merge the last operation on the stack with the current
							// operation. This may modify lastOp, or return a new operation
							var combinedOp:FlowOperation = lastOp.merge(op);
							if (combinedOp)
							{
								CONFIG::debug { assert(combinedOp.endGeneration == textFlow.generation,"Who did what?"); }
								CONFIG::debug { assert(combinedOp.canUndo() && combinedOp.endGeneration == op.endGeneration,"Bad operation merge in EditManager") };
								_undoManager.popUndo();
								op = combinedOp;
							}
						}
					}
					if (op.canUndo())
						_undoManager.pushUndo(op);
					allowOperationMerge = true;

					// following operations are no longer redoable
					_undoManager.clearRedo();
				}

				handleUpdate();			

				if (!_imeSession)
				{	
					var opEvent:FlowOperationEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_COMPLETE,false,false,op,0,null);
					textFlow.dispatchEvent(opEvent);
				}
			}	
		}
		
		private var captureOperations:Array = [];

		/** Internal guts of a dooperation - Execute a FlowOperation.  This function proceeds in steps.
		  * <p>Step 2. Send a canceallable OperationEvent.  If cancelled this method returns immediately.</p>
		  * If it is not cancelled, the listener may "do" other operations by calling back into the EditManager. This will result
		  * in a nested call to do which will post additional commands to the captureOperations array.
		  * <p>Step 3. Execute the operation.  The operation returns true or false.  false indicates no changes were made.</p>
		  * <p>Step 7. Send a OperationEvent. </p>
		  * The listener may "do" other operations by calling back into the EditManager. This will result
		  * in a nested call to do which will post additional commands to the captureOperations array.
		  * <p>Exception handling.  If the operation throws the exception is caught and the error is attached to the event dispatched
		  * at step 7.  If the event is not cancelled the error is rethrown.</p>
		  */
		private function doInternal(op:FlowOperation):FlowOperation
		{
			CONFIG::debug { assert(op.textFlow == this.textFlow,"Operation from a different TextFlow"); }
			
			var captureStart:int = captureOperations.length;
			var success:Boolean = false;
			var opEvent:FlowOperationEvent;
			
			// tell any listeners about the operation
			if (!_imeSession)
			{
				opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN,false,true,op,captureLevel-1,null);
				textFlow.dispatchEvent(opEvent);
				if (opEvent.isDefaultPrevented())
					return null;
				// user may replace the operation - TODO: WHAT IF SWITCH TO UNDO/REDO????
				op = opEvent.operation;
				if ((op is UndoOperation) || (op is RedoOperation))
					throw new IllegalOperationError(GlobalSettings.resourceStringFunction("illegalOperation",[ getQualifiedClassName(op) ]));
			}
				
			var opError:Error = null;
			try
			{
				// begin this op after pending ops are flushed
				CONFIG::debug 
				{ 
					if (captureLevel <= 1)
						debugCheckTextFlow(); 
				}
				
				// null return implies no operation was done - just discard it
				var beforeGeneration:uint = textFlow.generation;
				op.setGenerations(beforeGeneration,0);
	
				captureOperations.push(op);
				success = op.doOperation();
				if (success)		// operation succeeded
				{
					textFlow.normalize();   //force normalization at this point. Don't compose unless the captureLevel is 0
					
					// This has to be done after the normalize, because normalize increments the generation number
					op.setGenerations(beforeGeneration,textFlow.generation);					
				} 
				else 
				{
					var index:int = captureOperations.indexOf(op);
					if (index >= 0) 
						captureOperations.splice(index, 1);
				}
			}
			catch(e:Error)
			{
				opError = e;
			}
			
			// operation completed - send event whether it succeeded or not.
			// client can check generation number for changes
			if (!_imeSession)
			{
				opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END,false,true,op,captureLevel-1,opError);
				textFlow.dispatchEvent(opEvent);
				opError = opEvent.isDefaultPrevented() ? null : opEvent.error;
			}

			if (opError)
				throw (opError);
				
			// If we fired off any subsidiary operations, create a composite operation to hold them all
		 	if (captureOperations.length - captureStart > 1)
		 	{
				op = new CompositeOperation(captureOperations.slice(captureStart));
				op.setGenerations(FlowOperation(CompositeOperation(op).operations[0]).beginGeneration,textFlow.generation);
				allowOperationMerge = false;
				captureOperations.length = captureStart;		
		 	}
			 	
			return success ? op : null;
		}

		/** @private **/
		override public function set textFlow(value:TextFlow):void
		{
			flushPendingOperations();
			if (redrawListener)	// detach handler if there is one
				updateAllControllers();
			super.textFlow = value;
		}  
		
		/**
		 * @copy IEditManager.delayUpdates
		 */
		public function get delayUpdates():Boolean
		{
			return _delayUpdates;
		}
		public function set delayUpdates(value:Boolean):void
		{
			_delayUpdates = value;
		}
		
		private function redrawHandler(e:Event):void
		{
			// This is here because it has to take an argument
			updateAllControllers();
		}

		/** @copy IEditManager.updateAllControllers
		 */
		public function updateAllControllers():void
		{
			flushPendingOperations();

			if (redrawListener)	// detach handler if there is one
			{
				redrawListener.removeEventListener(Event.ENTER_FRAME, redrawHandler);
				redrawListener = null;
			}

			var cellHeight:Number = 0;
			if (textFlow.flowComposer)
			{
				if(superManager && superManager is IEditManager)
				{
					var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
					if (controller)
					{
						cellHeight = controller.container.height;
					}
				}


				 textFlow.flowComposer.updateAllControllers(); 

				// Scroll to selection
				if (hasSelection())
				{
					var controllerIndex:int = textFlow.flowComposer.findControllerIndexAtPosition(activePosition);
					if (controllerIndex >= 0)
						textFlow.flowComposer.getControllerAt(controllerIndex).scrollToRange(activePosition,anchorPosition);	
				}
				if(superManager && superManager is IEditManager)
				{
					if(controller.container.height != cellHeight)
					{
						var setFormat:String = selectionFormatState;
						var table:TableElement = (textFlow.parentElement as TableCellElement).getTable();
						table.modelChanged(ModelChange.ELEMENT_MODIFIED, table, 0, table.textLength);
						(superManager as IEditManager).updateAllControllers();
						if(setFormat == SelectionFormatState.FOCUSED)
							setFocus();
					}
				}
			}

			selectionChanged(true, false);
				
			CONFIG::debug { debugCheckTextFlow(); }
		}

		// By default, the EditManager will update in response to a model change immediately.
		// Client may also request a delayed update; in this case, we schedule an update on the
		// next enter frame event.
		private function handleUpdate():void
		{
			if (_delayUpdates)
			{
				if (!redrawListener)	// only need to attach if we're not already
				{
					var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
					if (controller)
					{
						redrawListener = controller.container;
						if (redrawListener)
							redrawListener.addEventListener(Event.ENTER_FRAME, redrawHandler, false, 1.0, true);			
					}
				}
			}
			else		// redraw now
			{
				updateAllControllers();
			}
		}
			
		/** @copy IEditManager#allowDelayedOperations() */
		public function get allowDelayedOperations():Boolean
		{
			return _allowDelayedOperations;
		}
		public function set allowDelayedOperations(value:Boolean):void
		{
			if (!value)
				flushPendingOperations();
			_allowDelayedOperations = value;
		}
		
		/** @private */
		public override function flushPendingOperations():void
		{
			super.flushPendingOperations();
			if (pendingInsert)
			{
				var pi0:InsertTextOperation = pendingInsert;
				pendingInsert = null;
				if (enterFrameListener)
				{
					enterFrameListener.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
					enterFrameListener = null;
				}
				doOperation(pi0);
			}
		}

		/** 
		 * @copy IEditManager#undo()
		 * @includeExample examples\EditManager_undo.as -noswf
		 * 
		 * @see flashx.undo.IUndoManager#undo()
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		public function undo():void
		{
			// Cancel out of an IME session if there is one. 
			// Some IMEs are on all the time, and so the undo has to win over the IME, 
			// otherwise you would never be able to undo in Korean.
			if (_imeSession)
				_imeSession.compositionAbandoned();
			
			if (undoManager)
				undoManager.undo();
		}
		 			
		/** @private */
		public function performUndo(theop:IOperation):void
		{
			var operation:FlowOperation = theop as FlowOperation;
			if ((!operation) || (operation.textFlow != textFlow)) 
				return;			
			// tell any listeners about the operation
			if (!_imeSession)
			{
				var undoPsuedoOp:UndoOperation = new UndoOperation(operation);
				var opEvent:FlowOperationEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN,false,true,undoPsuedoOp,0,null);
				textFlow.dispatchEvent(opEvent);
				if (opEvent.isDefaultPrevented())
				{
					//operation cancelled by user. Push the operation back onto the undo stack
					undoManager.pushUndo(operation);
					return;
				}
				undoPsuedoOp = opEvent.operation as UndoOperation;
				if (!undoPsuedoOp)
					throw new IllegalOperationError(GlobalSettings.resourceStringFunction("illegalOperation",[ getQualifiedClassName(opEvent.operation) ]));
				operation = undoPsuedoOp.operation;
			}
					
			if (operation.endGeneration != textFlow.generation)
			{
				//CONFIG::debug { trace("EditManager.undo: skipping undo due to mismatched generation numbers. textFlow",textFlow.generation,flash.utils.getQualifiedClassName(operation),operation.endGeneration); }
				return;
			}
				
			var opError:Error = null;
			try
			{
				CONFIG::debug { debugCheckTextFlow(); }
	
				var rslt:SelectionState;
				rslt = operation.undo();
	
				CONFIG::debug { assert(rslt != null,"undoable operations must return a SelectionState"); }
				setSelectionState(rslt);
				if (_undoManager)
					_undoManager.pushRedo(operation);

			}
			catch(e:Error)
			{
				opError = e;
			}
				
			// tell user its complete and give them a chance to cancel the rethrow
			if (!_imeSession)
			{
				opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END,false,true,undoPsuedoOp,0,opError);
				textFlow.dispatchEvent(opEvent);
				opError = opEvent.isDefaultPrevented() ? null : opEvent.error;
			}

			if (opError)
				throw (opError);
			
			handleUpdate();
			
			// push the generation of the textFlow backwards - must be done after update which does a normalize
			textFlow.setGeneration(operation.beginGeneration);
			
			if (!_imeSession)
			{
				opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_COMPLETE,false,false,undoPsuedoOp,0,null);
				textFlow.dispatchEvent(opEvent);
			}
		}
		
		/** 
		 * @copy IEditManager#redo()
		 * @includeExample examples\EditManager_redo.as -noswf
		 * 
		 * @see flashx.undo.IUndoManager#redo()
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		public function redo():void
		{
			// Cancel out of an IME session if there is one. 
			// Some IMEs are on all the time, and so the undo has to win over the IME, 
			// otherwise you would never be able to undo in Korean.
			if (_imeSession)
				_imeSession.compositionAbandoned();
			
			if (undoManager)
				undoManager.redo();
		}
		
		/** @private */
		public function performRedo(theop:IOperation):void
		{
			var opEvent:FlowOperationEvent;
			var op:FlowOperation = theop as FlowOperation;
			if ((!op) || (op.textFlow != textFlow)) 
				return;
			// tell any listeners about the operation
			if (!_imeSession)
			{
				var redoPsuedoOp:RedoOperation = new RedoOperation(op);
				opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN,false,true,redoPsuedoOp,0,null);
				textFlow.dispatchEvent(opEvent);
				if (opEvent.isDefaultPrevented() && _undoManager)
				{
					//user cancelled the event. Push the operation back onto the redo stack
					_undoManager.pushRedo(op);
					return;
				}
				redoPsuedoOp = opEvent.operation as RedoOperation;
				if (!redoPsuedoOp)
					throw new IllegalOperationError(GlobalSettings.resourceStringFunction("illegalOperation",[ getQualifiedClassName(opEvent.operation) ]));
				op = redoPsuedoOp.operation;
			}
					
			if (op.beginGeneration != textFlow.generation)
			{
				//CONFIG::debug { trace("EditManager.redo: skipping redo due to mismatched generation numbers."); }
				return;
			}
				
			var opError:Error = null;
			try
			{
				CONFIG::debug { debugCheckTextFlow(); }					
				var rslt:SelectionState;
				rslt = op.redo();
					
				CONFIG::debug { assert(rslt != null,"redoable operations must return a SelectionState"); }
				setSelectionState(rslt);
				if (_undoManager)
					_undoManager.pushUndo(op);

			
			}
			catch(e:Error)
			{
				opError = e;
			}
				
			// tell user its complete and give them a chance to cancel the rethrow
			if (!_imeSession)
			{
				opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END,false,true,redoPsuedoOp,0,opError);
				textFlow.dispatchEvent(opEvent);
				opError = opEvent.isDefaultPrevented() ? null : opEvent.error;
			}
			if (opError)
				throw (opError);
			
			handleUpdate();
			
			// push the generation of the textFlow backwards - must be done after update which does a normalize
			// set the generation of the textFlow to end of redoOp.
			textFlow.setGeneration(op.endGeneration);
			
			if (hasSelection())
			{
				var controllerIndex:int = textFlow.flowComposer.findControllerIndexAtPosition(activePosition);
				if (controllerIndex >= 0)
					textFlow.flowComposer.getControllerAt(controllerIndex).scrollToRange(activePosition,anchorPosition);						
			}	
			if (!_imeSession)
			{
				opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_COMPLETE,false,false,redoPsuedoOp,0,null);
				textFlow.dispatchEvent(opEvent);			
			}
		}
		
		/**
		 * @private
		 * Returns the editing mode (READ_ONLY, READ_SELECT, or READ_WRITE) of the EditManager.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 * @see flashx.textLayout.edit.EditingMode.
		 */
		 public override function get editingMode():String
		 {
		 	return EditingMode.READ_WRITE;
		 }				 		
		
		// Resolve the operationState.
		//		If the operation state is null...
		//			Return the active selection
		//			If there's no active selection, return null. The caller will have to check
		//		Otherwise (operation not null)
		//			just return it
		/** @private */
		tlf_internal function defaultOperationState(operationState:SelectionState = null):SelectionState
		{
			if (operationState)
			{
				// flush any pending operations and use marks to preserve the operationState positions
				var markActive:Mark = createMark();
				var markAnchor:Mark = createMark();
				try
				{
					markActive.position = operationState.activePosition;
					markAnchor.position = operationState.anchorPosition;
					flushPendingOperations();
				}
				finally
				{
					removeMark(markActive);
					removeMark(markAnchor);
					operationState.activePosition = markActive.position;
					operationState.anchorPosition = markAnchor.position;
				}
			}
			else
			{
				flushPendingOperations();
				if (hasSelection())
				{
					// tell the operation that the state is from the SelectionManager so it will update pending point formats
					operationState = getSelectionState();
					operationState.selectionManagerOperationState = true;
				}
			}
			return operationState;
		}

		/** 
		 * @copy IEditManager#splitParagraph()
		 * @includeExample examples\EditManager_splitParagraph.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		public function splitParagraph(operationState:SelectionState = null):ParagraphElement
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return null;

			var op:SplitElementOperation = new SplitParagraphOperation(operationState);
			doOperation(op);
			return op.newElement as ParagraphElement;
		}
		
		
		/** @copy IEditManager#splitElement() */
		public function splitElement(target:FlowGroupElement, operationState:SelectionState = null):FlowGroupElement
		{ 
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return null;
			var op:SplitElementOperation = new SplitElementOperation(operationState, target);
			doOperation(op);
			return op.newElement;
		}
		
		/** @copy IEditManager#createDiv() */
		public function createDiv(parent:FlowGroupElement = null, format:ITextLayoutFormat = null, operationState:SelectionState = null):DivElement
		{ 
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return null;
			
			var operation:CreateDivOperation = new CreateDivOperation(operationState, parent, format);
			doOperation(operation);
			return operation.newDivElement;
		}		
		
		/** @copy IEditManager#createList() */
		public function createList(parent:FlowGroupElement = null, format:ITextLayoutFormat = null, operationState:SelectionState = null):ListElement
		{ 
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return null;
			
			var operation:CreateListOperation = new CreateListOperation(operationState, parent, format);
			doOperation(operation);
			return operation.newListElement;
		}
		
		/** @copy IEditManager#moveChildren() */
		public function moveChildren(source:FlowGroupElement, sourceIndex:int, numChildren:int, destination:FlowGroupElement, destinationIndex:int, selectionState:SelectionState = null):void
		{ 
			selectionState = defaultOperationState(selectionState);
			if (!selectionState)
				return;

			var operation:MoveChildrenOperation = new MoveChildrenOperation(selectionState, source, sourceIndex, numChildren, destination, destinationIndex);
			doOperation(operation);
		}
		
		/** @copy IEditManager#createSubParagraphGroup() */
		public function createSubParagraphGroup(parent:FlowGroupElement = null, format:ITextLayoutFormat = null, operationState:SelectionState = null):SubParagraphGroupElement
		{ 
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return null;
			
			var operation:CreateSubParagraphGroupOperation = new CreateSubParagraphGroupOperation(operationState, parent, format);
			doOperation(operation);
			return operation.newSubParagraphGroupElement;
		}

		/** 
		 * @copy IEditManager#deleteText()
		 * @includeExample examples\EditManager_deleteText.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		public function deleteText(operationState:SelectionState = null):void
		{

			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;

			doOperation(new DeleteTextOperation(operationState, operationState, false /* don't allow merge when deleting by range */));				
		}		
		
		/**
		 * @copy IEditManager#deleteNextCharacter()
		 * @includeExample examples\EditManager_deleteNextCharacter.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		public function deleteNextCharacter(operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;

			/*
			This should not be necessary...
			// mjzhang : fix for table
			var leaf:FlowLeafElement = textFlow.findLeaf(operationState.absoluteStart);
			var para:ParagraphElement = leaf.getParagraph();
			if ( para.isInTable() )
				return;
			*/
			// Delete the next character if it's a caret selection, and allow adejacent delete next's to merge
			// If it's a range selection, delete the range and disallow merge
			var deleteOp:DeleteTextOperation;
			if (operationState.absoluteStart == operationState.absoluteEnd)
			{
				var nextPosition:int = NavigationUtil.nextAtomPosition(textFlow, absoluteStart);
				deleteOp = new DeleteTextOperation(operationState, new SelectionState(textFlow, absoluteStart, nextPosition, pointFormat), true /* allowMerge for deleteForward */);	
			}
			else 
				deleteOp = new DeleteTextOperation(operationState, operationState, false /* don't allow merge when deleting by range */);			
			doOperation(deleteOp);			

		}

		/** 
		 * @copy IEditManager#deleteNextWord()
		 * @includeExample examples\EditManager_deleteNextWord.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */		
		public function deleteNextWord(operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if ((!operationState) || ((operationState.anchorPosition == operationState.activePosition) && (operationState.anchorPosition >= textFlow.textLength - 1)))
				return;
				
			var nextWordSelState:SelectionState = getNextWordForDelete(operationState.absoluteStart);
			if (nextWordSelState.anchorPosition == nextWordSelState.activePosition)
				//nothing to delete. No operation required.
				return;			

			setSelectionState(new SelectionState(textFlow, operationState.absoluteStart, operationState.absoluteStart, new TextLayoutFormat(textFlow.findLeaf(operationState.absoluteStart).format)));
			doOperation(new DeleteTextOperation(operationState, nextWordSelState, false));						
		}

		// Sadly, this is NOT the same as the cursor key movement - specialized for delete forward one word
		private function getNextWordForDelete(absoluteStart:int):SelectionState
		{
			var leafEl:FlowLeafElement = textFlow.findLeaf(absoluteStart);
			var paraEl:ParagraphElement = leafEl.getParagraph();
			var paraElAbsStart:int = paraEl.getAbsoluteStart();
			
			var nextPosition:int = -1;
			
			if ((absoluteStart - paraElAbsStart) >= (paraEl.textLength - 1))
			{
				// We're at the end of the paragraph, delete the following newline
				nextPosition = NavigationUtil.nextAtomPosition(textFlow, absoluteStart);
			}
			else
			{
				var curPos:int = absoluteStart - paraElAbsStart;			
				var curPosCharCode:int = paraEl.getCharCodeAtPosition(curPos);
				var prevPosCharCode:int = -1;
				if (curPos > 0) prevPosCharCode = paraEl.getCharCodeAtPosition(curPos - 1);
				var nextPosCharCode:int = paraEl.getCharCodeAtPosition(curPos + 1);
				if (!CharacterUtil.isWhitespace(curPosCharCode) && ((curPos == 0) || ((curPos > 0) && CharacterUtil.isWhitespace(prevPosCharCode)))) {
					nextPosition = NavigationUtil.nextWordPosition(textFlow, absoluteStart);
				} else {
					if (CharacterUtil.isWhitespace(curPosCharCode) && ((curPos > 0) && !CharacterUtil.isWhitespace(prevPosCharCode))) {
						//if at beginning of space word then get through all the spaces					
						curPos = paraEl.findNextWordBoundary(curPos);
					}
					nextPosition = paraElAbsStart + paraEl.findNextWordBoundary(curPos);
				}
			}
			return new SelectionState(textFlow, absoluteStart, nextPosition, pointFormat);
		}
		
		/**
		 * @copy IEditManager#deletePreviousCharacter()
		 * @includeExample examples\EditManager_deletePreviousCharacter.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */		
		public function deletePreviousCharacter(operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;

			var deleteOp:DeleteTextOperation;
			if (operationState.absoluteStart == operationState.absoluteEnd)
			{	
				// with a caret selection, generally delete the previous character, but also check whether to move the paragraph out of its parent chain (like backspacing at the beginning of a list)
				var leaf:FlowLeafElement = textFlow.findLeaf(operationState.absoluteStart);
				var para:ParagraphElement = leaf.getParagraph();
				var parent:FlowGroupElement = para.parent;
				
				var movePara:Boolean = false;
				if(!(parent is TextFlow))
				{
					if(operationState.absoluteStart == para.getAbsoluteStart() && parent.getChildIndex(para) == 0 && // cursor is at start of this paragraph AND para is at beginning of parent AND
						(!(parent is ListItemElement) || parent.parent.getChildIndex(parent) == 0)) // if parent is a listItem, it's the first item in the list
					{
						movePara = true;
					}
				}
				if(movePara)
				{
					/*
					should not be necessary...
					// mjzhang: fix for table feature
					if ( para.isInTable() )
						return;
					*/
					var source:FlowGroupElement;
					var target:FlowGroupElement;
					var numElementsToMove:int;
					var targetIndex:int;
					
					if(parent is ListItemElement)
					{
						if(parent.parent.parent is ListElement)
						{
							// move the whole list item to grandparent list
							source = parent.parent;
							numElementsToMove = 1;
							target = parent.parent.parent;
							targetIndex = parent.parent.parent.getChildIndex(parent.parent);
						}
						else
						{
							// move everything inside the list item out into grandparent
							source = para.parent;
							numElementsToMove = para.parent.numChildren;
							target = parent.parent.parent;
							targetIndex = parent.parent.parent.getChildIndex(parent.parent);
						}
					}
					else
					{
						// move just the first paragraph out into grandparent
						source = para.parent;
						numElementsToMove = 1;
						target = parent.parent;
						targetIndex = parent.parent.getChildIndex(parent);
					}
					doOperation(new MoveChildrenOperation(operationState, source, 0, numElementsToMove, target, targetIndex));
				}
				else
				{
					var beginPrevious:int = NavigationUtil.previousAtomPosition(textFlow, operationState.absoluteStart);
					deleteOp = new DeleteTextOperation(operationState, new SelectionState(textFlow, beginPrevious, operationState.absoluteStart), true /* allowMerge */);
					doOperation(deleteOp);
				}
			}
			else	// just delete the range
			{
				deleteOp = new DeleteTextOperation(operationState);
				doOperation(deleteOp);
			}
		}
		
		/** 
		 * @copy IEditManager#deletePreviousWord()
		 * @includeExample examples\EditManager_deletePreviousWord.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */		
		public function deletePreviousWord(operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;
				
			var prevWordSelState:SelectionState = getPreviousWordForDelete(operationState.absoluteStart);
			if (prevWordSelState.anchorPosition == prevWordSelState.activePosition)
				//there is nothing to delete.  No operation required
				return;			
				
			setSelectionState(new SelectionState(textFlow, operationState.absoluteStart, operationState.absoluteStart, new TextLayoutFormat(textFlow.findLeaf(operationState.absoluteStart).format)));
			doOperation(new DeleteTextOperation(operationState, prevWordSelState, false /* don't allow merge */));						
		}		
		
		// Sadly, this is NOT the same as the cursor key movement - specialized for delete backward one word
		private function getPreviousWordForDelete(absoluteStart:int):SelectionState
		{
			var leafEl:FlowLeafElement = textFlow.findLeaf(absoluteStart);
			var paraEl:ParagraphElement = leafEl.getParagraph();
			var paraElAbsStart:int = paraEl.getAbsoluteStart();

			if (absoluteStart == paraElAbsStart)		// at the start of the paragraph, delete the previous newline. Should insert a space after punctuation.
			{
				var beginPrevious:int = NavigationUtil.previousAtomPosition(textFlow, absoluteStart);
				return new SelectionState(textFlow, beginPrevious, absoluteStart);				
			}

			var curPos:int = absoluteStart - paraElAbsStart;
			var curPosCharCode:int = paraEl.getCharCodeAtPosition(curPos);
			var prevPosCharCode:int = paraEl.getCharCodeAtPosition(curPos - 1);
			var curAbsStart:int = absoluteStart;
			
			if (CharacterUtil.isWhitespace(curPosCharCode) && (curPos != (paraEl.textLength - 1)))
			{
				if (CharacterUtil.isWhitespace(prevPosCharCode)) //this will get you past the spaces
				{
					curPos = paraEl.findPreviousWordBoundary(curPos);
				}
				if (curPos > 0) {
					curPos = paraEl.findPreviousWordBoundary(curPos); //this will get you to the beginning of the word before the space.
					if (curPos > 0) {
						prevPosCharCode = paraEl.getCharCodeAtPosition(curPos - 1);
						if (CharacterUtil.isWhitespace(prevPosCharCode)) {
							curPos = paraEl.findPreviousWordBoundary(curPos);
						}
					}
				}
			} else { //you are here if you are not on a space
				if (CharacterUtil.isWhitespace(prevPosCharCode))
				{
					curPos = paraEl.findPreviousWordBoundary(curPos); //this will get you past the spaces
					if (curPos > 0) {
						curPos = paraEl.findPreviousWordBoundary(curPos);
						// mjzhang : Fix for bug#2821844 Text controls make bad assumptions with Ctrl Backspace
						//if (curPos > 0) {
						//	prevPosCharCode = paraEl.getCharCodeAtPosition(curPos - 1);
						//	if (!CharacterUtil.isWhitespace(prevPosCharCode)) {
						//		curAbsStart--; //Microsoft Word insists on keeping the original space
						//		               //if the ending position does not have a space.
						//	}
						//}
					}
				} else { //just delete to the previous word boundary
					curPos = paraEl.findPreviousWordBoundary(curPos);
				}
			}
			return new SelectionState(textFlow, paraElAbsStart + curPos, curAbsStart);
		}		

		public function insertTableElement(table:TableElement, operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;
			
			var operation:InsertTableElementOperation = new InsertTableElementOperation(operationState, table);
			doOperation(operation);
		}
		
		/** 
		 * @copy IEditManager#insertText()
		 * @includeExample examples\EditManager_insertText.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */	
		public function insertText(text:String, origOperationState:SelectionState = null):void
		{
			// if there's another insert operation waiting to be executed, 
			// just add to it, if possible
			if (origOperationState == null && pendingInsert)
				pendingInsert.text += text;
			else 
			{
				var operationState:SelectionState = defaultOperationState(origOperationState);
				if (!operationState)
					return;
				
				// rather than execute the insert immediately, create
				// it and wait for the next frame, in order to batch
				// keystrokes.
				pendingInsert = new InsertTextOperation(operationState, text);
				
				var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
				if (captureLevel == 0 && origOperationState == null && controller && controller.container && allowDelayedOperations)
				{
					enterFrameListener = controller.container;
					enterFrameListener.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 1.0, true);
				}
				else
					flushPendingOperations();
			}
		}
				

		
		/** 
		 * @copy IEditManager#overwriteText()
		 * 
		 * @includeExample examples\EditManager_overwriteText.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */	
		public function overwriteText(text:String, operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;
			var selState:SelectionState = getSelectionState();
			NavigationUtil.nextCharacter(selState,true);
			doOperation(new InsertTextOperation(operationState, text, selState));
		}

		/** 
		 * @copy IEditManager#insertInlineGraphic()
		 * Returns the new InlineGraphicElement that was created.
		 * @includeExample examples\EditManager_insertInlineGraphic.as -noswf
		 * 
		 * @playerversion Flash 10 + 10.2
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 * @see flash.text.engine.TextRotation
		 */			
		public function insertInlineGraphic(source:Object, width:Object, height:Object, options:Object = null, operationState:SelectionState = null):InlineGraphicElement
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return null;

			var operation:InsertInlineGraphicOperation = new InsertInlineGraphicOperation(operationState, source, width, height, options);
			doOperation(operation);
			return operation.newInlineGraphicElement;
		}	
		
		/** 
		 * @copy IEditManager#modifyInlineGraphic()
		 * @includeExample examples\EditManager_modifyInlineGraphic.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */			
		public function modifyInlineGraphic(source:Object, width:Object, height:Object, options:Object = null, operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;

			doOperation(new ModifyInlineGraphicOperation(operationState, source, width, height, options));
		}					
		
		/** 
		 * @copy IEditManager#applyFormat()
		 * 
		 * @includeExample examples\EditManager_applyFormat.as -noswf
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */		
		public function applyFormat(leafFormat:ITextLayoutFormat, paragraphFormat:ITextLayoutFormat, containerFormat:ITextLayoutFormat, operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;

			// apply to the current selection else remember new format for next char typed
			doOperation(new ApplyFormatOperation(operationState, leafFormat, paragraphFormat, containerFormat));
		}
		/** 
		 * @copy IEditManager#clearFormat()
		 * 
		 * Known issue is that undefines of leafFormat values with a point selection are not applied at the next insertion.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function clearFormat(leafFormat:ITextLayoutFormat, paragraphFormat:ITextLayoutFormat, containerFormat:ITextLayoutFormat, operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;
			
			// apply to the current selection else remember new format for next char typed
			doOperation(new ClearFormatOperation(operationState, leafFormat, paragraphFormat, containerFormat));
		}
		/** 
		 * @copy IEditManager#applyLeafFormat()
		 * 
		 * @includeExample examples\EditManager_applyLeafFormat.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */		
		public function applyLeafFormat(characterFormat:ITextLayoutFormat, operationState:SelectionState = null):void
		{
			applyFormat(characterFormat, null, null, operationState);
		}

		/** 
		 * @copy IEditManager#applyParagraphFormat()
		 * 
		 * @includeExample examples\EditManager_applyParagraphFormat.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
 		 */		
		public function applyParagraphFormat(paragraphFormat:ITextLayoutFormat, operationState:SelectionState = null):void
		{
			applyFormat(null, paragraphFormat, null, operationState);
		}

		/** 
		 * @copy IEditManager#applyContainerFormat()
		 * 
		 * @includeExample examples\EditManager_applyContainerFormat.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */		
		public function applyContainerFormat(containerFormat:ITextLayoutFormat, operationState:SelectionState = null):void
		{
			applyFormat(null, null, containerFormat, operationState);
		}
		
		/** 
		 * @copy IEditManager#applyFormatToElement()
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */	
		public function applyFormatToElement(targetElement:FlowElement, format:ITextLayoutFormat, relativeStart:int = 0, relativeEnd:int = -1, operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;

			doOperation(new ApplyFormatToElementOperation(operationState, targetElement, format, relativeStart, relativeEnd));
		}

		/** 
		 * @copy IEditManager#clearFormatOnElement()
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */	
		public function clearFormatOnElement(targetElement:FlowElement, format:ITextLayoutFormat, operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;
			
			doOperation(new ClearFormatOnElementOperation(operationState, targetElement, format));
		}
		
		/** 
		 * @copy IEditManager#cutTextScrap()
		 * @includeExample examples\EditManager_cutTextScrap.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
 	 	 * 
		 *  @see flashx.textLayout.edit.TextScrap
		 */
		public function cutTextScrap(operationState:SelectionState = null):TextScrap
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return null;
				
			if (operationState.anchorPosition == operationState.activePosition)
				return null;

			var tScrap:TextScrap = TextScrap.createTextScrap(operationState);			
			var beforeOpLen:int = textFlow.textLength;						
			doOperation(new CutOperation(operationState, tScrap));
			if (operationState.textFlow.textLength != beforeOpLen)
			{
				return tScrap;
			}									
			return null;			
		}
		
		/** 
		 * @copy IEditManager#pasteTextScrap()
		 * @includeExample examples\EditManager_pasteTextScrap.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
 	 	 * 
		 *  @see flashx.textLayout.edit.TextScrap
		 */
		public function pasteTextScrap(scrapToPaste:TextScrap, operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;

			doOperation(new PasteOperation(operationState, scrapToPaste));	
		}
		
		/** 
		 * @copy IEditManager#applyTCY()
		 * Returns the new TCYElement that was created.
		 * @includeExample examples\EditManager_applyTCY.as -noswf
		 * 
		 * @playerversion Flash 10 + 10.2
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */			
		public function applyTCY(tcyOn:Boolean, operationState:SelectionState = null):TCYElement
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return null;

			var operation:ApplyTCYOperation = new ApplyTCYOperation(operationState, tcyOn);
			doOperation(operation);
			return operation.newTCYElement;
		}
		
		/** 
		 * @copy IEditManager#applyLink()
		 * Returns the new LinkElement that was created.
		 * @includeExample examples\EditManager_applyLink.as -noswf
		 * 
		 * @playerversion Flash 10 + 10.2
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */			
		public function applyLink(href:String, targetString:String = null, extendToLinkBoundary:Boolean=false, operationState:SelectionState = null):LinkElement
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return null;
				
			if (operationState.absoluteStart == operationState.absoluteEnd)
				return null;

			var operation:ApplyLinkOperation = new ApplyLinkOperation(operationState, href, targetString, extendToLinkBoundary);
			doOperation(operation);
			return operation.newLinkElement;
		}
		
		/**
		 * @copy IEditManager#changeElementID()
		 * @includeExample examples\EditManager_changeElementID.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
	 	*/
		public function changeElementID(newID:String, targetElement:FlowElement, relativeStart:int = 0, relativeEnd:int = -1, operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;
				
			if (operationState.absoluteStart == operationState.absoluteEnd)
				return;

			doOperation(new ApplyElementIDOperation(operationState, targetElement, newID, relativeStart, relativeEnd));
		}
		
		[Deprecated(replacement="applyFormatToElement", deprecatedSince="2.0")]
		/**
		 * @copy IEditManager#changeStyleName()
		 * @includeExample examples\EditManager_changeStyleName.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0 
		 */
		public function changeStyleName(newName:String, targetElement:FlowElement, relativeStart:int = 0, relativeEnd:int = -1, operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;
			
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.styleName = newName;
			doOperation(new ApplyFormatToElementOperation(operationState, targetElement, format, relativeStart, relativeEnd));
		}
		
		/**
		 * @copy IEditManager#changeTypeName()
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0 
		 */
		public function changeTypeName(newName:String, targetElement:FlowElement, relativeStart:int = 0, relativeEnd:int = -1, operationState:SelectionState = null):void
		{
			operationState = defaultOperationState(operationState);
			if (!operationState)
				return;
			
			doOperation(new ApplyElementTypeNameOperation(operationState, targetElement, newName, relativeStart, relativeEnd));
		}
		
		/* CompositeOperations
			Normally when you call doOperation, it gets executed immediately. By calling beginCompositeOperation, you can instead accumulate the
			operations into a CompositeOperation. The CompositeOperation is completed and returned when you call endCompositeOperation, and 
			processing returns to normal state. The client code can then either call doOperation on the CompositeOperation that was returned, 
			or just drop it if the operation should be aborted.
			
			The parentStack is a stack of pending CompositeOperations. 
		*/
		private var parentStack:Array;
		
		/** 
		 * @copy IEditManager#beginCompositeOperation()
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
 	 	 * 
		 * @includeExample examples\EditManager_beginCompositeOperation.as -noswf
		 */
		public function beginCompositeOperation():void
		{
			flushPendingOperations();
			
			if (!parentStack)
				parentStack = [];
			var operation:CompositeOperation = new CompositeOperation();
			
			if (!_imeSession)
			{	
				var opEvent:FlowOperationEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN,false,false,operation,captureLevel,null);
				textFlow.dispatchEvent(opEvent);
			}
			
			CONFIG::debug { assert(!operation.operations  || operation.operations.length == 0, "opening a composite operation that already has operations"); }
			operation.setGenerations(textFlow.generation, 0);
			++captureLevel;
			var parent:Object = new Object();
			parent.operation = operation;
			parent.captureLevel = captureLevel;
			parentStack.push(parent);
		}
		
		/** 
		 * @copy IEditManager#endCompositeOperation()
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
 	 	 * 
		 * @includeExample examples\EditManager_beginCompositeOperation.as -noswf
		 */
		public function endCompositeOperation():void
		{
			CONFIG::debug { assert( parentStack.length > 0 || captureLevel <= 0, "EditManager.endOperation - no composite operation in progress"); }
			
			--captureLevel;
			
			var parent:Object = parentStack.pop();
			var operation:FlowOperation = parent.operation;
			if (!_imeSession)
			{	
				var opEvent:FlowOperationEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END,false,false,operation,captureLevel,null);
				textFlow.dispatchEvent(opEvent);
			}
			operation.setGenerations(operation.beginGeneration, textFlow.generation);
			finalizeDo(operation);
		}
		
		/** @private
		 * Handler function called when the selection has been changed.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 * @param doDispatchEvent	true if a selection changed event will be sent
		 * @param resetPointFormat	true if the attributes associated with the caret should be discarded
		 */
		tlf_internal override function selectionChanged(doDispatchEvent:Boolean = true, resetPointFormat:Boolean=true):void
		{	
			if (_imeSession)
				_imeSession.selectionChanged();
			
			super.selectionChanged(doDispatchEvent, resetPointFormat);
		}


	}
}
