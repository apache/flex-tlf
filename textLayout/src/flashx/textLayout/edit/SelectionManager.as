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
    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.display.Stage;
    import flash.errors.IllegalOperationError;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.IMEEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.engine.TextLine;
    import flash.text.engine.TextLineValidity;
    import flash.text.engine.TextRotation;
    import flash.ui.ContextMenu;
    import flash.ui.Keyboard;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    import flash.utils.getQualifiedClassName;
    
    import flashx.textLayout.compose.IFlowComposer;
    import flashx.textLayout.compose.TextFlowLine;
    import flashx.textLayout.container.ColumnState;
    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.debug.Debugging;
    import flashx.textLayout.debug.assert;
    import flashx.textLayout.elements.Configuration;
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.elements.FlowLeafElement;
    import flashx.textLayout.elements.GlobalSettings;
    import flashx.textLayout.elements.IConfiguration;
    import flashx.textLayout.elements.InlineGraphicElement;
    import flashx.textLayout.elements.ParagraphElement;
    import flashx.textLayout.elements.TableDataCellElement;
    import flashx.textLayout.elements.TableElement;
    import flashx.textLayout.elements.TableRowElement;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.elements.TextRange;
    import flashx.textLayout.events.FlowOperationEvent;
    import flashx.textLayout.events.SelectionEvent;
    import flashx.textLayout.formats.BlockProgression;
    import flashx.textLayout.formats.Category;
    import flashx.textLayout.formats.Direction;
    import flashx.textLayout.formats.ITextLayoutFormat;
    import flashx.textLayout.formats.TextLayoutFormat;
    import flashx.textLayout.operations.CopyOperation;
    import flashx.textLayout.operations.FlowOperation;
    import flashx.textLayout.property.Property;
    import flashx.textLayout.tlf_internal;
    import flashx.textLayout.utils.NavigationUtil;
    
    use namespace tlf_internal;
    
    /** 
     * The SelectionManager class manages text selection in a text flow.
     * 
     * <p>The selection manager keeps track of the selected text range, manages its formatting, 
     * and can handle events affecting the selection. To allow a user to make selections in
     * a text flow, assign a SelectionManager object to the <code>interactionManager</code>
     * property of the flow. (To allow editing, assign an instance of the EditManager class,
     * which extends SelectionManager.)</p>
     *
     * <p>The following table describes how the SelectionManager class handles keyboard shortcuts:</p>
     *
     * <table class="innertable" width="100%">
     * <thead>
     * <tr><th></th><th></th><th align = "center">TB,LTR</th><th align = "right"></th><th></th><th align = "center">TB,RTL</th><th></th><th></th><th align = "center">TL,LTR</th><th></th><th></th><th align = "center">RL,RTL</th><th></th></tr>
     * <tr><th></th><th>none</th><th>ctrl</th><th>alt|ctrl+alt</th><th>none</th><th>ctrl</th><th>alt|ctrl+alt</th><th>none</th><th>ctrl</th><th>alt|ctrl+alt</th><th>none</th><th>ctrl</th><th>alt|ctrl+alt</th></tr>
     * </thead>
     * <tr><td>leftarrow</td><td>previousCharacter</td><td>previousWord</td><td>previousWord</td><td>nextCharacter</td><td>nextWord</td><td>nextWord</td><td>nextLine</td><td>endOfDocument</td><td>endOfParagraph</td><td>nextLine</td><td>endOfDocument</td><td>endOfParagraph</td></tr>
     * <tr><td>uparrow</td><td>previousLine</td><td>startOfDocument</td><td>startOfParagraph</td><td>previousLine</td><td>startOfDocument</td><td>startOfParagraph</td><td>previousCharacter</td><td>previousWord</td><td>previousWord</td><td>nextCharacter</td><td>nextWord</td><td>nextWord</td></tr>
     * <tr><td>rightarrow</td><td>nextCharacter</td><td>nextWord</td><td>nextWord</td><td>previousCharacter</td><td>previousWord</td><td>previousWord</td><td>previousLine</td><td>startOfDocument</td><td>startOfParagraph</td><td>previousLine</td><td>startOfDocument</td><td>startOfParagraph</td></tr>
     * <tr><td>downarrow</td><td>nextLine</td><td>endOfDocument</td><td>endOfParagraph</td><td>nextLine</td><td>endOfDocument</td><td>endOfParagraph</td><td>nextCharacter</td><td>nextWord</td><td>nextWord</td><td>previousCharacter</td><td>previousWord</td><td>previousWord</td></tr>
     * <tr><td>home</td><td>startOfLine</td><td>startOfDocument</td><td>startOfLine</td><td>startOfLine</td><td>startOfDocument</td><td>startOfLine</td><td>startOfLine</td><td>startOfDocument</td><td>startOfLine</td><td>startOfLine</td><td>startOfDocument</td><td>startOfLine</td></tr>
     * <tr><td>end</td><td>endOfLine</td><td>endOfDocument</td><td>endOfLine</td><td>endOfLine</td><td>endOfDocument</td><td>endOfLine</td><td>endOfLine</td><td>endOfDocument</td><td>endOfLine</td><td>endOfLine</td><td>endOfDocument</td><td>endOfLine</td></tr>
     * <tr><td>pagedown</td><td>nextPage</td><td>nextPage</td><td>nextPage</td><td>nextPage</td><td>nextPage</td><td>nextPage</td><td>nextPage</td><td>nextPage</td><td>nextPage</td><td>nextPage</td><td>nextPage</td><td>nextPage</td></tr>
     * <tr><td>pageup</td><td>previousPage</td><td>previousPage</td><td>previousPage</td><td>previousPage</td><td>previousPage</td><td>previousPage</td><td>previousPage</td><td>previousPage</td><td>previousPage</td><td>previousPage</td><td>previousPage</td><td>previousPage</td></tr>
     * </table>
     *
     * <p><strong>Key:</strong>
     * <ul>
     *  <li>none = no modifier</li>
     *  <li>ctrl, shift, alt = modifiers</li>
     *  <li>alt-key and ctrl+alt-key are the same on all platforms (on some platforms alt-key does not get to the Text Layout Framework (TLF)</li>
     *  <li>shift key modifes to extend the active end of the selection in the specified manner</li>            
     *  <li>TB (top-to-bottom),RL (right-to-left) are textFlow level <code>blockProgression</code> settings</li>                        
     *  <li>LTR (left-to-right),RTL (right-to-left) are textFlow level <code>direction</code> settings</li>                 
     *  <li>next and prev in logical order in the textFlow - the effect in RTL text is that the selection moves in the physical direction</li>
     * </ul></p>
     * 
     * @see EditManager
     * @see flashx.elements.TextFlow
     * 
     * @includeExample examples\SelectionManager_example.as -noswf
     * 
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public class SelectionManager implements ISelectionManager
    {       
        private var _focusedSelectionFormat:SelectionFormat;
        private var _unfocusedSelectionFormat:SelectionFormat;
        private var _inactiveSelectionFormat:SelectionFormat;
        private var _selFormatState:String = SelectionFormatState.UNFOCUSED;
        private var _isActive:Boolean;
        
        /** The TextFlow of the selection. */
        private var _textFlow:TextFlow;
        
        // current range of selection
        /** Anchor point of the current selection, as an index into the TextFlow. */
        private var anchorMark:Mark;
        /** Active end of the current selection, as an index into the TextFlow. */
        private var activeMark:Mark;
        
        // used to save pending attributes at a point selection
        private var _pointFormat:ITextLayoutFormat;
        /** 
         * The format that will be applied to inserted text. 
         * 
         * TBD: pointFormat needs to be extended to remember user styles and "undefine" of formats from calls to IEditManager.undefineFormat with leafFormat values on a point selection.
         */
        protected function get pointFormat():ITextLayoutFormat
        { return _pointFormat; }

        
        /** @private
         * Ignore the next text input event. This is needed because the player may send a text input event
         * following by a key down event when ctrl+key is entered. 
         */
        protected var ignoreNextTextEvent:Boolean = false;
        
        /**
         *  @private
         *  For usability reasons, operations are sometimes grouped (merged) so they 
         *  can be undone together. Certain events, such as changing the selection, may make merging 
         *  inappropriate. This flag is used to keep track of when operation merging
         *  is appropriate.  This might need to be moved to SelectionManager later. I'm keeping it
         *  here for now since I'm unsure if other regular selection operations that we add can
         *  be undone.
         */
        protected var allowOperationMerge:Boolean = false;
        
        private var _mouseOverSelectionArea:Boolean = false;    

        CONFIG::debug 
        {
            protected var id:String;
            static private var smCount:int = 0;
        }
        
        /** 
         * 
         * Creates a SelectionManager object.
         * 
         * <p>Assign a SelectionManager object to the <code>interactionManager</code> property of
         * a text flow to enable text selection.</p>
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function SelectionManager()
        {
            _textFlow = null;
            anchorMark = createMark();
            activeMark = createMark();
            _pointFormat = null;
            _isActive = false;
            CONFIG::debug 
            {
                this.id = smCount.toString();
                smCount++;
            }
        }
        /**
         * @copy ISelectionManager#getSelectionState()
         * 
         * @includeExample examples\SelectionManager_getSelectionState.as -noswf
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         * 
         * @see flashx.textLayout.edit.SelectionState
         */
        public function getSelectionState():SelectionState
        {
            return new SelectionState(_textFlow, anchorMark.position, activeMark.position, pointFormat);
        }
                
        /**
         * @copy ISelectionManager#setSelectionState()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         * 
         * @see flashx.textLayout.edit.SelectionState
         */
        public function setSelectionState(sel:SelectionState):void
        {
            internalSetSelection(sel.textFlow, sel.anchorPosition, sel.activePosition, sel.pointFormat);
        }

        /**
         *  @copy ISelectionManager#hasSelection()
         * 
         * @includeExample examples\SelectionManager_hasSelection.as -noswf
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function hasSelection():Boolean
        { return anchorMark.position != -1; }

        /** 
         *  @copy ISelectionManager#isRangeSelection()
         * 
         * @includeExample examples\SelectionManager_isRangeSelection.as -noswf
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */             
        public function isRangeSelection():Boolean
        { return anchorMark.position != -1 && anchorMark.position != activeMark.position; }
        
        /**
         * The TextFlow object managed by this selection manager. 
         * 
         * <p>A selection manager manages a single text flow. A selection manager can also be
         * assigned to a text flow by setting the <code>interactionManager</code> property of the
         * TextFlow object.</p>
         * 
         * @see flashx.textLayout.elements.TextFlow#interactionManager
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function get textFlow():TextFlow
        {
            return _textFlow;
        }
        public function set textFlow(value:TextFlow):void
        {
            if (_textFlow != value)
            {
                if (_textFlow)
                    flushPendingOperations();
                
                clear();
                
                // If we switch into read-only mode, make sure the cursor isn't showing a text selection IBeam
                if (!value) // see Watson 2637162
                    setMouseCursor(MouseCursor.AUTO);
        
                _textFlow = value;
                
                if (_textFlow && _textFlow.interactionManager != this)
                    _textFlow.interactionManager = this;
            }
        }  
        
        /**
         *  @copy ISelectionManager#editingMode
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         * 
         * @see flashx.textLayout.edit.EditingMode
         */
         public function get editingMode():String
         {
            return EditingMode.READ_SELECT;
         }               
         
        /** 
         *  @copy ISelectionManager#windowActive
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
         public function get windowActive():Boolean
         {
            return _selFormatState != SelectionFormatState.INACTIVE;
         }
         
        /** 
         *  @copy ISelectionManager#focused
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
        */
         public function get focused():Boolean
         {
            return _selFormatState == SelectionFormatState.FOCUSED;
         }
         
        /**
         *  @copy ISelectionManager#currentSelectionFormat
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         * 
         * @see flashx.textLayout.edit.SelectionFormat
         */
         public function get currentSelectionFormat():SelectionFormat
         { 
            if (_selFormatState == SelectionFormatState.UNFOCUSED)
            {
                return unfocusedSelectionFormat;
            }
            else if (_selFormatState == SelectionFormatState.INACTIVE)
            {
                return inactiveSelectionFormat;
            }
            return focusedSelectionFormat;
         }
         
        /**
         *  @copy ISelectionManager#focusedSelectionFormat
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         * 
         * @see flashx.textLayout.edit.SelectionFormat
         */
         public function set focusedSelectionFormat(val:SelectionFormat):void
         { 
            _focusedSelectionFormat = val;
            if (this._selFormatState == SelectionFormatState.FOCUSED)
                refreshSelection();
         }
         
        /**
         * @private - docs on setter
         */
         public function get focusedSelectionFormat():SelectionFormat
         { 
            return _focusedSelectionFormat ? _focusedSelectionFormat : (_textFlow ? _textFlow.configuration.focusedSelectionFormat : null);
         }       

        /**
         *  @copy ISelectionManager#unfocusedSelectionFormat
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         * 
         * @see flashx.textLayout.edit.SelectionFormat
         */
         public function set unfocusedSelectionFormat(val:SelectionFormat):void
         { 
            _unfocusedSelectionFormat = val;
            if (this._selFormatState == SelectionFormatState.UNFOCUSED)
                refreshSelection();
         }          
         
        /**
         *  @private - docs on setter
         */
         public function get unfocusedSelectionFormat():SelectionFormat
         { 
            return _unfocusedSelectionFormat ? _unfocusedSelectionFormat : (_textFlow ? _textFlow.configuration.unfocusedSelectionFormat : null);
         }
         
        /**
         *  @copy ISelectionManager#inactiveSelectionFormat
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         * 
         * @see flashx.textLayout.edit.SelectionFormat
         */
         public function set inactiveSelectionFormat(val:SelectionFormat):void
         { 
            _inactiveSelectionFormat = val;
            if (this._selFormatState == SelectionFormatState.INACTIVE)
                refreshSelection();
         }          
         
        /**
         * @private - docs on setter
         */
         public function get inactiveSelectionFormat():SelectionFormat
         { 
            return _inactiveSelectionFormat ? _inactiveSelectionFormat : (_textFlow ? _textFlow.configuration.inactiveSelectionFormat : null);
         }       
         
         /** @private - returns the selectionFormatState.  @see flashx.textLayout.edit.SelectionFormatState */
         tlf_internal function get selectionFormatState():String
         { return _selFormatState; }
         
         /** @private - sets the SelectionFormatState. @see flashx.textLayout.edit.SelectionFormatState */
         tlf_internal function setSelectionFormatState(selFormatState:String):void
         {
            if (selFormatState != _selFormatState)
            {                   
            //  trace("changing selection state: was", _selFormatState, "switching to", selFormatState, "on selectionManager", id);
                var oldSelectionFormat:SelectionFormat = currentSelectionFormat;
                _selFormatState = selFormatState;
                var newSelectionFormat:SelectionFormat = currentSelectionFormat;
                if (!newSelectionFormat.equals(oldSelectionFormat))
                {
                    refreshSelection();
                }
             }
         }
         
         /** @private */
         tlf_internal function cloneSelectionFormatState(oldISelectionManager:ISelectionManager):void
         {
            var oldSelectionManager:SelectionManager = oldISelectionManager as SelectionManager;
            if (oldSelectionManager)
            {
                _isActive = oldSelectionManager._isActive;
                _mouseOverSelectionArea = oldSelectionManager._mouseOverSelectionArea;
                setSelectionFormatState(oldSelectionManager.selectionFormatState);
            }
         }
         
        /**
         * Gets the SelectionState at the specified mouse position.
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         * @see flashx.textLayout.edit.SelectionState
         * @param currentTarget     The object that is actively processing the Event object with an event listener.
         * @param target            The InteractiveObject instance under the pointing device. The target is not always the object in the display list that registered the event listener. Use the currentTarget property to access the object in the display list that is currently processing the event.
         * @param localX            The horizontal coordinate at which the event occurred relative to the containing sprite.
         * @param localY            The vertical coordinate at which the event occurred relative to the containing sprite.
         * @param extendSelection   Indicates that only activeIndex should move
         * @return the resulting SelectionState
         */                                                                                                              
         private function selectionPoint(currentTarget:Object, target:InteractiveObject, localX:Number, localY:Number, extendSelection:Boolean = false):SelectionState
         {
            //trace("selectionPoint");
            if (!_textFlow) 
                return null;
            if (!hasSelection()) 
                extendSelection = false;
            
            var begIdx:int = anchorMark.position;
            var endIdx:int = activeMark.position;
            
            endIdx = computeSelectionIndex(_textFlow, target, currentTarget, localX, localY);
            if (endIdx == -1)
                return null;    // ignore
                        
            // make sure we aren't selecting after the flow terminating character
            endIdx = Math.min(endIdx, _textFlow.textLength - 1);
            
            if (!extendSelection)
                begIdx = endIdx;                            

            if (begIdx == endIdx)
            {
                begIdx = NavigationUtil.updateStartIfInReadOnlyElement(_textFlow, begIdx);
                endIdx = NavigationUtil.updateEndIfInReadOnlyElement(_textFlow, endIdx);
            } else {
                endIdx = NavigationUtil.updateEndIfInReadOnlyElement(_textFlow, endIdx);
            }           
            return new SelectionState(textFlow, begIdx, endIdx);
         }                       
         
        /** 
         *  @copy ISelectionManager#setFocus()
         * 
         * @includeExample examples\SelectionManager_setFocus.as -noswf
         * 
        * @playerversion Flash 10
        * @playerversion AIR 1.5
         * @langversion 3.0
        */
         public function setFocus():void
         {
             if (!_textFlow)
                 return;
             
            //  trace("setFocus sm", id);

            // container with the activePosition gets the key focus
            if (_textFlow.flowComposer)
                _textFlow.flowComposer.setFocus(activePosition,false);
            setSelectionFormatState(SelectionFormatState.FOCUSED);
         }
         
        /** 
         * Set the Mouse cursor. 
         * @param cursor    New cursor value, MouseCursor.AUTO if mouse is going off text, MouseCursor.IBEAM if mouse is going into text
         * 
         * @playerversion Flash 10.2
         * @playerversion AIR 2.0
         * @langversion 3.0
         */
        protected function setMouseCursor(cursor:String):void
        {
			Mouse.cursor = Configuration.getCursorString(textFlow.configuration, cursor);
        }
        
        /**
         *  @copy ISelectionManager#anchorPosition
         */
        public function get anchorPosition() : int
        {
            return anchorMark.position;
        }
        /**
         *  @copy ISelectionManager#activePosition
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function get activePosition() : int
        {
            return activeMark.position;         
        }
        /**
         *  @copy ISelectionManager#absoluteStart
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function get absoluteStart() : int
        {
            return (anchorMark.position < activeMark.position) ? anchorMark.position : activeMark.position;
        }
        /**
         *  @copy ISelectionManager#absoluteEnd
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function get absoluteEnd() : int
        {
            return (anchorMark.position > activeMark.position) ? anchorMark.position : activeMark.position;
        }
        
        /** 
         *  @copy ISelectionManager#selectAll
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         * 
         * @see flashx.textLayout.compose.IFlowComposer
         */
        public function selectAll() : void
        {
            selectRange(0, int.MAX_VALUE);
        }
        
        /** 
         *  @copy ISelectionManager#selectRange
         * 
         * @includeExample examples\SelectionManager_selectRange.as -noswf
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         * 
         * @see flashx.textLayout.compose.IFlowComposer
         */
        public function selectRange(anchorPosition:int, activePosition:int) : void
        {
            flushPendingOperations();
            
            // anchor and active can be in any order
            // TODO: range check and clamp anchor,active
            if (anchorPosition != anchorMark.position || activePosition != activeMark.position)
            {   
                clearSelectionShapes();
                    
                internalSetSelection(_textFlow, anchorPosition, activePosition);
                
                // selection changed
                selectionChanged();     
                
                allowOperationMerge = false;
            }
        }
        
        private function internalSetSelection(root:TextFlow,anchorPosition:int,activePosition:int,format:ITextLayoutFormat = null) : void
        {
            _textFlow = root;
            
            // clamp anchor/active
            if (anchorPosition < 0 || activePosition < 0)
            {
                anchorPosition = -1;
                activePosition = -1;
            }
            
            var lastSelectablePos:int = (_textFlow.textLength > 0) ? _textFlow.textLength - 1 : 0;
            
            if (anchorPosition != -1 && activePosition != -1)
            {
                if (anchorPosition > lastSelectablePos)
                    anchorPosition = lastSelectablePos;
                
                if (activePosition > lastSelectablePos)
                    activePosition = lastSelectablePos;
            }

            _pointFormat = format;
            anchorMark.position = anchorPosition; // NavigationUtil.updateStartIfInReadOnlyElement(root, anchorPosition);
            activeMark.position = activePosition; // NavigationUtil.updateEndIfInReadOnlyElement(root, activePosition);
        //  trace("Selection ", anchorMark, "to", activeMark.position);
        }       
        
        /** Clear any active selections.
         */
        private function clear(): void
        {
            if (hasSelection())
            {
                flushPendingOperations();
                clearSelectionShapes();
                internalSetSelection(_textFlow, -1, -1);
                // selection cleared
                selectionChanged();
                allowOperationMerge = false;
            }
        }
        
        private function addSelectionShapes():void
        {
            if (_textFlow.flowComposer)
            {
                // selection may need to be constrainted due to model changes that weren't done with the EditManager
                internalSetSelection(_textFlow,anchorMark.position,activeMark.position,_pointFormat);
                
                // zero alpha means nothing is drawn so skip it
                if (currentSelectionFormat && 
                    (((absoluteStart == absoluteEnd) &&  (currentSelectionFormat.pointAlpha != 0)) ||
                     ((absoluteStart != absoluteEnd) && (currentSelectionFormat.rangeAlpha != 0))))
                {
                    var containerIter:int = 0;
                    while(containerIter < _textFlow.flowComposer.numControllers)
                    {
                        _textFlow.flowComposer.getControllerAt(containerIter++).addSelectionShapes(currentSelectionFormat, absoluteStart, absoluteEnd);
                    }
                } 
            }
        }
        
        private function clearSelectionShapes():void
        {
            var flowComposer:IFlowComposer = _textFlow ? _textFlow.flowComposer : null; 
            if (flowComposer)
            {
                var containerIter:int = 0;
                while(containerIter < flowComposer.numControllers)
                {
                    flowComposer.getControllerAt(containerIter++).clearSelectionShapes();
                }
            }
        }
        
        /** 
         *  @copy ISelectionManager#refreshSelection()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
        */
        public function refreshSelection(): void
        {
            if (hasSelection())
            {
                clearSelectionShapes();
                addSelectionShapes();
            }
        }
        
        /** Verifies that the selection is in a legal state. @private */
        CONFIG::debug public function debugCheckSelectionManager():int
        {
            var rslt:int = 0;
            if (hasSelection())
            {
                // both points must be within the flow - may not include trailing \n in final paragraph
                var lastPosition:int = _textFlow.textLength > 0 ? _textFlow.textLength - 1 : 0;
                rslt += assert(anchorMark.position >= 0 && anchorMark.position <= lastPosition,"SelectionManager:validate selBegIdx is out of range");
                rslt += assert(activeMark.position >= 0 && activeMark.position <= lastPosition,"SelectionManager:validate selEndIdx is out of range");
            }
            return rslt;
        }
        
        // ////////////////////////////////////
        // internal selection handling methods
        // ////////////////////////////////////
        
        /** @private
         * Handler function called when the selection has been changed.
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         * @param doDispatchEvent   true if a selection changed event will be sent
         * @param resetPointFormat  true if the attributes associated with the caret should be discarded
         */
        tlf_internal function selectionChanged(doDispatchEvent:Boolean = true, resetPointFormat:Boolean=true):void
        {
            CONFIG::debug { debugCheckSelectionManager(); } // validates the selection
            
            // clear any remembered attributes for the next character
            if (resetPointFormat) 
                _pointFormat = null;
            
            if (doDispatchEvent && _textFlow)
                textFlow.dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGE, false, false, hasSelection() ? getSelectionState() : null));
        }

        // TODO: this routine could be much more efficient - instead of iterating over all lines in the TextFlow it should iterate over 
        // the visible lines in the container.  Todo that move this routine into ContainerController and use the shapeChildren along with the logic in fillShapeChildren
        static private function computeSelectionIndexInContainer(textFlow:TextFlow, controller:ContainerController, localX:Number, localY:Number):int
        {
			var result:int;
            //var origX:Number = localX;
            //var origY:Number = localY;
            var lineIndex:int = -1;
            
            var firstCharVisible:int = controller.absoluteStart;
            var length:int  = controller.textLength;
            
            // try to find a point on the line
            var bp:String = textFlow.computedFormat.blockProgression;
            var isTTB:Boolean = (bp == BlockProgression.RL);
            var isDirectionRTL:Boolean = (textFlow.computedFormat.direction == Direction.RTL);
            
            //Establish perpendicular the coordinate for use with TTB or LTR/RTL lines
            var perpCoor:Number = isTTB ? localX : localY;
            
            //get the nearest column so we can ignore lines which aren't in the column we're looking for.
            //if we don't do this, we won't be able to select across column boundaries.
            var nearestColIdx:int = locateNearestColumn(controller, localX, localY, textFlow.computedFormat.blockProgression,textFlow.computedFormat.direction);
			//For the table feature, we are trying to make sure if the current point is in the table and which cell it is in
			var nearestCell:TableDataCellElement = locateNearestCell(controller, localX, localY, textFlow.computedFormat.blockProgression,textFlow.computedFormat.direction);
            
            var prevLineBounds:Rectangle = null;
            var previousLineIndex:int = -1;
			
			if(nearestCell)
			{
				//To-Do: Need to update the codes to be a real paragraph search sequence
				var cellPara:ParagraphElement = nearestCell.getLastLeaf().getParagraph();
				if(cellPara.getTextFlow() == textFlow)
				{
					//textLine = cellPara.getTextBlock().lastLine;
					
					//result = computeSelectionIndexInLine(textFlow, textLine, localX, localY);
					// trace("computeSelectionIndexInContainer:(",origX,origY,")",textFlow.flowComposer.getControllerIndex(controller).toString(),lineIndex.toString(),result.toString());
					return cellPara.getAbsoluteStart() + cellPara.textLength - 1;
				}
			}
            
            var lastLineIndexInColumn:int = -1;
            
            // Matching TextFlowLine and TextLine - they are not necessarily valid
            var rtline:TextFlowLine;
            var rtTextLine:TextLine;
            
            for (var testIndex:int = textFlow.flowComposer.numLines - 1; testIndex >= 0; testIndex--)
            {
                rtline = textFlow.flowComposer.getLineAt(testIndex);
                if (rtline.controller != controller || rtline.columnIndex != nearestColIdx)
                {
                    // use last line in previous column
                    if (lastLineIndexInColumn != -1)
                    {
                        lineIndex = testIndex+1;
                        break;
                    }
                    continue;
                }
                    
                // is this line even displayed?
                if (rtline.absoluteStart < firstCharVisible || rtline.absoluteStart >= firstCharVisible+length)
                    continue;
                rtTextLine = rtline.getTextLine();
                if (rtTextLine == null || rtTextLine.parent == null)
                    continue;
                
                if (lastLineIndexInColumn == -1)
                    lastLineIndexInColumn = testIndex;
                    
                var bounds:Rectangle = rtTextLine.getBounds(DisplayObject(controller.container));
                // trace(testIndex.toString(),":",bounds.toString());
                
                var linePerpCoor:Number = isTTB ? bounds.left : bounds.bottom;
                var midPerpCoor:Number = -1;//will be a positive value if prevLineBounds is not null
                
                //if this is not the first test loop, use the prevLineBounds to find the mid-point between the current
                //line, which will be logically up from the previous line - we're walking back-to-front
                if(prevLineBounds)
                {
                    //if it's ttb, use the right bounds (ie the top of the line)...
                    var prevPerpCoor:Number = (isTTB ? prevLineBounds.right : prevLineBounds.top);
                    //calculate the midpoint
                    midPerpCoor = (linePerpCoor + prevPerpCoor)/2;
                }
                
                //if the current line is below the click, then this OR the previous line, is the line we're looking for
                var isLineBelow:Boolean = (isTTB ? linePerpCoor > perpCoor : linePerpCoor < perpCoor);
                if(isLineBelow || testIndex == 0)
                {
                    //if we haven't calculated the midPerpCoor (-1), then this is the first loop and we want to use the 
                    //current line,. Otherwise, if the click's perpendicular coordinate is below the mid point between the current
                    //line or below it, then we want to use the line below (ie the previous line, but logically the one after the current)
                    var inPrevLine:Boolean = midPerpCoor != -1 && (isTTB ? perpCoor < midPerpCoor : perpCoor > midPerpCoor);
					if(rtline.paragraph.isInTable())
					{
						//if rtline is the last line of the cell and the isPrevLine is true, find the cell of the column in next row
						//and try to set the line to be 
						if ( inPrevLine && testIndex != lastLineIndexInColumn )
						{
							var rtPara:ParagraphElement = rtline.paragraph;
							var rtCell:TableDataCellElement = rtPara.getTableDataCellElement();
							//get the last element of the cell
							var lastElement:FlowElement = rtCell.getLastLeaf();
							var rtLastTbLine:TextFlowLine = lastElement.getParagraph().getTextBlock().lastLine.userData;
							if( rtline == rtLastTbLine )
							{
								//temproray codes, need to be updated when the column apis are ready
								var rtTable:TableElement = rtCell.getTable();
								var rtRow:TableRowElement = rtCell.parent as TableRowElement;
								var nextRow:TableRowElement = rtRow.getNextSibling() as TableRowElement;
								if ( nextRow && rtCell )
								{
									var nextCell:TableDataCellElement = nextRow.getChildAt(rtCell.colIndex) as TableDataCellElement;
									lineIndex = textFlow.flowComposer.findLineIndexAtPosition(nextCell.getFirstLeaf().getParagraph().getAbsoluteStart());
								}
							}
							else
								lineIndex = testIndex + 1;
						}
						else
							lineIndex = testIndex;
					}
					else
                    	lineIndex = inPrevLine && testIndex != lastLineIndexInColumn ? testIndex+1 : testIndex;
					break;
                }
                else
                {
                    //this line is below the click, so set the prevLineBounds to bounds of the current line and move on...
                    prevLineBounds = bounds;
                    previousLineIndex = testIndex;
                }
            }

            if (lineIndex == -1)
            {
                lineIndex = previousLineIndex;
                if (lineIndex == -1)
                    return -1;  // no lines in container
            }   
                
            //Get a valid textLine -- check to make sure line is valid, regenerate if necessary, make sure it has correct container relative coordinates
            var textFlowLine:TextFlowLine = textFlow.flowComposer.getLineAt(lineIndex);
            var textLine:TextLine = textFlowLine.getTextLine(true);
            
            // adjust localX,localY to be relative to the textLine.  
            // Can't use localToGlobal/globalToLocal because textLine may not be on the display list due to virtualization
            // we may need to bring this back if textline's can be rotated or placed by any mechanism other than a translation
            // but then we'll need to provisionally place a virtualized TextLine in its parent container
            localX -= textLine.x;
            localY -= textLine.y;
            /* var localPoint:Point = DisplayObject(controller.container).localToGlobal(new Point(localX,localY));
            localPoint = textLine.globalToLocal(localPoint);
            localX = localPoint.x;
            localY = localPoint.y; */
            
            
            var startOnNextLineIfNecessary:Boolean = false;
            
            var lastAtom:int = -1;
            if (isDirectionRTL) {
                lastAtom = textLine.atomCount - 1;
            } else {
                if ((textFlowLine.absoluteStart + textFlowLine.textLength) >= textFlowLine.paragraph.getAbsoluteStart() + textFlowLine.paragraph.textLength) {
                    if (textLine.atomCount > 1) lastAtom = textLine.atomCount - 2;
                } else {
                    var lastLinePosInPar:int = textFlowLine.absoluteStart + textFlowLine.textLength - 1;
                    var lastChar:String = textLine.textBlock.content.rawText.charAt(lastLinePosInPar);
                    if (lastChar == " ") {
                        if (textLine.atomCount > 1) lastAtom = textLine.atomCount - 2;
                    } else {
                        startOnNextLineIfNecessary = true;
                        if (textLine.atomCount > 0) lastAtom = textLine.atomCount - 1;
                    }
                }
            }
            var lastAtomRect:Rectangle = (lastAtom > 0) ? textLine.getAtomBounds(lastAtom) : new Rectangle(0, 0, 0, 0);
                        
            if (!isTTB)
            {
                if (localX < 0)
                    localX = 0;
                else if (localX > (lastAtomRect.x + lastAtomRect.width))
                {
                    if (startOnNextLineIfNecessary) 
                        return textFlowLine.absoluteStart + textFlowLine.textLength - 1;
                    if (lastAtomRect.x + lastAtomRect.width > 0)
                        localX = lastAtomRect.x + lastAtomRect.width;
                }
            }
            else
            {   
                if (localY < 0) 
                    localY = 0;
                else if (localY > (lastAtomRect.y + lastAtomRect.height))
                {
                    if (startOnNextLineIfNecessary) 
                        return textFlowLine.absoluteStart + textFlowLine.textLength - 1;    
                    if (lastAtomRect.y + lastAtomRect.height > 0)
                        localY = lastAtomRect.y + lastAtomRect.height;
                }
            }
            
			result = computeSelectionIndexInLine(textFlow, textLine, localX, localY);
            // trace("computeSelectionIndexInContainer:(",origX,origY,")",textFlow.flowComposer.getControllerIndex(controller).toString(),lineIndex.toString(),result.toString());
            return result != -1 ? result : firstCharVisible + length;   
        }
		
		static private function locateNearestCell(container:ContainerController, localX:Number, localY:Number, wm:String, direction:String):TableDataCellElement
		{
			var cellIdx:int = 0;
			//if we only have 1 column, no need to perform calculation...
			var columnState:ColumnState = container.columnState;
			
			var isFound:Boolean = false;
			var curCell:TableDataCellElement = null;
			
			//we need to compare the current column to the nextColmn
			while(cellIdx < columnState.cellCount - 1)
			{
				curCell = columnState.getCellAt(cellIdx);
				var curRect:Rectangle = new Rectangle(curCell.x, curCell.y, curCell.width, curCell.height);
				
				if(curRect.contains(localX, localY)) //in current column
				{
					isFound = true;
					break;
				}
				++cellIdx;
			}
			return isFound? curCell : null;
		}
        
        static private function locateNearestColumn(container:ContainerController, localX:Number, localY:Number, wm:String, direction:String):int
        {
            var colIdx:int = 0;
            //if we only have 1 column, no need to perform calculation...
            var columnState:ColumnState = container.columnState;

            //we need to compare the current column to the nextColmn
            while(colIdx < columnState.columnCount - 1)
            {
                var curCol:Rectangle  = columnState.getColumnAt(colIdx);
                var nextCol:Rectangle = columnState.getColumnAt(colIdx + 1);
                
                if(curCol.contains(localX, localY)) //in current column
                    break;
                
                if(nextCol.contains(localX, localY))//in next column
                {
                    ++colIdx;
                    break;
                }
                else
                {
                    if(wm == BlockProgression.RL)
                    {
                        //if localY is above curCol || between columns, but close to current
                        if(localY < curCol.top || localY < nextCol.top && Math.abs(curCol.bottom - localY) <= Math.abs(nextCol.top - localY))
                            break;
                        
                        if(localY > nextCol.top)//between but closer to nextCol
                        {
                            ++colIdx;
                            break;
                        }
                    }
                    else
                    {
                        if(direction  == Direction.LTR)
                        {
                            //if localX is left of curCol || between columns but closer to current, break here
                            if(localX < curCol.left || localX < nextCol.left && Math.abs(curCol.right - localX) <= Math.abs(nextCol.left - localX)) 
                                break;
                            if(localX < nextCol.left) // between, but closer to next column
                            {
                                ++colIdx;
                                break;
                            }
                        }
                        else
                        {
                            //if localX is right of curCol || between columns, but closer to current
                            if(localX > curCol.right || localX > nextCol.right && Math.abs(curCol.left - localX) <= Math.abs(nextCol.right - localX))
                                break;
                            
                            if(localX > nextCol.right) // between, but closer to next column
                            {
                                ++colIdx;
                                break;
                            }
                        } 
                    }
                }
                
                //increment colIdx.  If this is the last pass through, then the conditions above were never met
                //so we want the last column
                ++colIdx;
            }

            
            return colIdx;
        }
        
        static private function computeSelectionIndexInLine(textFlow:TextFlow, textLine:TextLine,localX:Number,localY:Number):int
        {
            if (!(textLine.userData is TextFlowLine))
                return -1;  // not a TextLayout generated line
                
            var rtline:TextFlowLine = TextFlowLine(textLine.userData);
            if (rtline.validity == TextLineValidity.INVALID)
                return -1;  // not currently composed 
            textLine = rtline.getTextLine(true);    // make sure the TextLine is not released
            
                
            var isTTB:Boolean = textFlow.computedFormat.blockProgression == BlockProgression.RL;
            var perpCoor:Number = isTTB ? localX : localY;
            
            // new code for builds 385 and later
            var pt:Point = new Point();
            pt.x = localX;
            pt.y = localY;
            
            // in most cases, we want to "fixup" the coordiates of the x and y coordinates
            //because we could be getting a positive results for a click in the line, but the
            //coordinates do not match any particular glyph.  However, there are cases where the 
            //fix leads to bad results. For example, if there is a TCY run, this code will always cause
            //a selection to be created in the middle of the run, meaning idividual glyphs cannot be selected.
            //
            //As a result, we need to be performing the less common case check prior to adjusting the 
            //coordinates.
            pt = textLine.localToGlobal(pt);
            var elemIdx:int = textLine.getAtomIndexAtPoint(pt.x,pt.y);
            //trace("global point: " + pt);
            //trace("elemIdx: " + elemIdx);
            if(elemIdx == -1)
            {
                //reset the pt
                pt.x = localX;
                pt.y = localY;
                
                //make adjustments
                if (pt.x < 0 || (isTTB && perpCoor > textLine.ascent))
                    pt.x = 0;
                if (pt.y < 0 || (!isTTB && perpCoor > textLine.descent))
                    pt.y = 0;
                
                //get the global again and get try for the element again
                pt = textLine.localToGlobal(pt);
                elemIdx = textLine.getAtomIndexAtPoint(pt.x,pt.y);
                //trace("global point (second): " + pt);
                //trace("elemIdx (second): " + elemIdx);
            }
            
            //now we REALLY don't have a glyph, so return the head or tail of the line.
            if (elemIdx == -1)
            {
                //we need to use global coordinates here.  reset pt and get conversion...
                pt.x = localX;
                pt.y = localY;
                pt = textLine.localToGlobal(pt);
                if (textLine.parent)
                    pt = textLine.parent.globalToLocal(pt);
                
                if(!isTTB)
                    return (pt.x <= textLine.x) ? rtline.absoluteStart : (rtline.absoluteStart + rtline.textLength - 1);
                else
                    return (pt.y <= textLine.y) ? rtline.absoluteStart : (rtline.absoluteStart + rtline.textLength - 1);
            }
            
            // get the character box and if check we are past the middle select past this character. 
            var glyphRect:Rectangle = textLine.getAtomBounds(elemIdx);
            // trace("idx",elemIdx,"x",glyphRect.x,"y",glyphRect.y,"width",glyphRect.width,"height",glyphRect.height,"localX",localX,"localY",localY,"textLine.x",textLine.x);
            var leanRight:Boolean = false;
            if(glyphRect)
            {   
                //if this is TTB and NOT TCY determine lean based on Y coordinates...
                if(isTTB && textLine.getAtomTextRotation(elemIdx) != TextRotation.ROTATE_0)
                    leanRight = (localY > (glyphRect.y + glyphRect.height/2));
                else //use X..
                    leanRight = (localX > (glyphRect.x + glyphRect.width/2));
            }
            
            var paraSelectionIdx:int;
            if ((textLine.getAtomBidiLevel(elemIdx) % 2) != 0) // Right to left case, right is "start" unicode
                paraSelectionIdx = leanRight ? textLine.getAtomTextBlockBeginIndex(elemIdx) : textLine.getAtomTextBlockEndIndex(elemIdx);
            else  // Left to right case, right is "end" unicode
                paraSelectionIdx = leanRight ? textLine.getAtomTextBlockEndIndex(elemIdx) : textLine.getAtomTextBlockBeginIndex(elemIdx);

            //we again need to do some fixup here.  Unfortunately, we don't have the index into the paragraph until
            
            return rtline.paragraph.getAbsoluteStart() + paraSelectionIdx;
        }
        
        static private function checkForDisplayed(container:DisplayObject):Boolean
        {
            try
            {
                while (container)
                {
                    if (!container.visible)
                        return false;
                    container = container.parent;
                    if (container is Stage)
                        return true;                    
                }
            }
            catch (e:Error)
            { return true; }
            return false;   // not on the stage

        }
        /** @private - given a target and location compute the selectionIndex */
        static tlf_internal function computeSelectionIndex(textFlow:TextFlow, target:Object, currentTarget:Object, localX:Number,localY:Number):int
        {           
            //trace("computeSelectionIndex");
            var rslt:int = 0;
            var containerPoint:Point; // scratch
            
            //Make sure that if the target is a line, that it is part of THIS textFlow and not another.  Can happen
            //when holding down mouse and moving out of one flow and over another. Could also happen when moving over
            //TextLines that are either non-TLF or generated from a factory. 
            var useTargetedTextLine:Boolean = false;
            if (target is TextLine)
            {
                var tfl:TextFlowLine = TextLine(target).userData as TextFlowLine;
                if (tfl)
                {
                    var para:ParagraphElement = tfl.paragraph;
                    if(para.getTextFlow() == textFlow)
                        useTargetedTextLine = true;
                }
            }
            /* trace("got target class", target.toString(), "at (", localX, localY, ")");
            trace("Mapping",localX,localY,"for",target);
            containerPoint = DisplayObject(target).localToGlobal(new Point(localX, localY));
            trace("... Global",containerPoint.x,containerPoint.y);
            containerPoint = DisplayObject(currentTarget).globalToLocal(containerPoint);
            trace("... container Local",containerPoint.x,containerPoint.y); */
            
            if (useTargetedTextLine)
                rslt = computeSelectionIndexInLine(textFlow, TextLine(target), localX, localY);
            else
            {
                var controller:ContainerController;
                for (var idx:int = 0; idx < textFlow.flowComposer.numControllers; idx++)
                {
                    var testController:ContainerController = textFlow.flowComposer.getControllerAt(idx); 
                    if (testController.container == target || testController.container == currentTarget)
                    {
                        controller = testController;
                        break;
                    }
                }
                if (controller)
                {   
                    if (target != controller.container)
                    {
                        containerPoint = DisplayObject(target).localToGlobal(new Point(localX, localY));
                        containerPoint = DisplayObject(controller.container).globalToLocal(containerPoint);
                        localX = containerPoint.x;
                        localY = containerPoint.y;
                    }
                    rslt = computeSelectionIndexInContainer(textFlow, controller, localX, localY);          
                } 
                else 
                {
                    //the point is someplace else on stage.  Map the target 
                    //to the textFlow.container.
                    CONFIG::debug { assert(textFlow.flowComposer && textFlow.flowComposer.numControllers,"computeSelectionIndex: invalid textFlow"); }
                    
                    
                    // result of the search
                    var controllerCandidate:ContainerController = null;
                    var candidateLocalX:Number;
                    var candidateLocalY:Number;
                    var relDistance:Number = Number.MAX_VALUE;
                    
                    for (var containerIndex:int = 0; containerIndex < textFlow.flowComposer.numControllers; containerIndex++)
                    {
                        var curContainerController:ContainerController = textFlow.flowComposer.getControllerAt(containerIndex);
                        
                        // displayed??
                        if (!checkForDisplayed(curContainerController.container as DisplayObject))
                            continue;

                        // handle measured containers??
                        var bounds:Rectangle = curContainerController.getContentBounds();
                        var containerWidth:Number = isNaN(curContainerController.compositionWidth) ? curContainerController.getTotalPaddingLeft()+bounds.width : curContainerController.compositionWidth;
                        var containerHeight:Number = isNaN(curContainerController.compositionHeight) ? curContainerController.getTotalPaddingTop()+bounds.height : curContainerController.compositionHeight;
                        
                        containerPoint = DisplayObject(target).localToGlobal(new Point(localX, localY));
                        containerPoint = DisplayObject(curContainerController.container).globalToLocal(containerPoint);
                        
                        // remove scrollRect effects for the distance test but add it back in for the result
                        var adjustX:Number = 0;
                        var adjustY:Number = 0;
                        
                        if (curContainerController.hasScrollRect)
                        {
                            containerPoint.x -= (adjustX = curContainerController.container.scrollRect.x);
                            containerPoint.y -= (adjustY = curContainerController.container.scrollRect.y);
                        }
                        
                        if ((containerPoint.x >= 0) && (containerPoint.x <= containerWidth) &&
                            (containerPoint.y >= 0) && (containerPoint.y <= containerHeight))
                        {
                            controllerCandidate = curContainerController;
                            candidateLocalX = containerPoint.x+adjustX;
                            candidateLocalY = containerPoint.y+adjustY;
                            break;
                        }
                        
                        // figure minimum distance of containerPoint to curContainerController - 8 cases
                        var relDistanceX:Number = 0;
                        var relDistanceY:Number = 0;

                        if (containerPoint.x < 0)
                        {
                            relDistanceX = containerPoint.x;
                            if (containerPoint.y < 0)
                                relDistanceY = containerPoint.y;
                            else if (containerPoint.y > containerHeight)
                                relDistanceY = containerPoint.y-containerHeight;
                        }
                        else if (containerPoint.x > containerWidth)
                        {
                            relDistanceX = containerPoint.x-containerWidth;
                            if (containerPoint.y < 0)
                                relDistanceY = containerPoint.y;
                            else if (containerPoint.y > containerHeight)
                                relDistanceY = containerPoint.y-containerHeight;
                        }
                        else if (containerPoint.y < 0)
                            relDistanceY = -containerPoint.y;
                        else
                            relDistanceY = containerPoint.y-containerHeight;
                        var tempDist:Number = relDistanceX*relDistanceX + relDistanceY*relDistanceY;    // could do sqrt but why bother - there is no Math.hypot function
                        if (tempDist <= relDistance)
                        {
                            relDistance = tempDist;
                            controllerCandidate = curContainerController;
                            candidateLocalX = containerPoint.x+adjustX;
                            candidateLocalY = containerPoint.y+adjustY;
                        }
                    }


                    rslt = controllerCandidate ? computeSelectionIndexInContainer(textFlow, controllerCandidate, candidateLocalX, candidateLocalY) : -1;
                }
            }
            
            if (rslt >= textFlow.textLength)
                rslt = textFlow.textLength-1;
            return rslt;
        }
        
        /** initialize a new point selection at click point @private */
        tlf_internal function setNewSelectionPoint(currentTarget:Object, target:InteractiveObject, localX:Number, localY:Number, extendSelection:Boolean = false):Boolean
        {
            var selState:SelectionState = selectionPoint(currentTarget, target, localX, localY, extendSelection);
            if (selState == null)
                return false;   // ignore
            
            if (selState.anchorPosition != anchorMark.position || selState.activePosition != activeMark.position)
            {
            //  clear(false);
            //  internalSetSelection(_textFlow, selState.anchorPosition, selState.activePosition);
                selectRange(selState.anchorPosition, selState.activePosition);
                return true;
            }
            return false;
        }
        
        // ///////////////////////////////////
        // Mouse and keyboard methods 
        // ///////////////////////////////////
        
        /** 
         *  @copy IInteractionEventHandler#mouseDownHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */ 
        public function mouseDownHandler(event:MouseEvent):void
        {
            handleMouseEventForSelection(event, event.shiftKey);
        }
        
        /**
         * @copy IInteractionEventHandler#mouseMoveHandler()
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */ 
        public function mouseMoveHandler(event:MouseEvent):void
        {
            var wmode:String = textFlow.computedFormat.blockProgression;            
            if (wmode != BlockProgression.RL) 
                setMouseCursor(MouseCursor.IBEAM);          
            if (event.buttonDown)
                handleMouseEventForSelection(event, true);
        }
        
        /** @private */
        tlf_internal function handleMouseEventForSelection(event:MouseEvent, allowExtend:Boolean):void
        {
            var startSelectionActive:Boolean = hasSelection();
            
            if (setNewSelectionPoint(event.currentTarget, event.target as InteractiveObject, event.localX, event.localY, startSelectionActive && allowExtend))
            {
                if (startSelectionActive)
                    clearSelectionShapes();

                if (hasSelection())
                    addSelectionShapes();
            }       
            allowOperationMerge = false;
        }
        
        /** 
         * @copy IInteractionEventHandler#mouseUpHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */ 
        public function mouseUpHandler(event:MouseEvent):void
        {
            if (!_mouseOverSelectionArea)
            {
                setMouseCursor(MouseCursor.AUTO);
            }
        }
        
        private function atBeginningWordPos(activePara:ParagraphElement, pos:int):Boolean
        {
            if (pos == 0) return true;
			
			// mjzhang : for fix bug 2835316, will force to compose to paragraph end to avoid invalid textLine
			var paraEnd:Number = activePara.getAbsoluteStart() + activePara.textLength;
			activePara.getTextFlow().flowComposer.composeToPosition(paraEnd);
			
            var nextPos:int = activePara.findNextWordBoundary(pos);
            nextPos = activePara.findPreviousWordBoundary(nextPos);
            return (pos == nextPos);
        }
                
        
        /** 
         * @copy IInteractionEventHandler#mouseDoubleClickHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */ 
        public function mouseDoubleClickHandler(event:MouseEvent):void
        {
            if (!hasSelection())
                return;

            // We got a previous single click event that set the selection.
            // Extend it into a selection for the entire word.

            // Adjust the active end to the beginning or end of the nearest word, depending on which end of the selection is active
            var activePara:ParagraphElement = _textFlow.findAbsoluteParagraph(activeMark.position);
            var activeParaStart:int = activePara.getAbsoluteStart();
            var newActiveIndex:int; // adjusted active index
            if (anchorMark.position <= activeMark.position)
                newActiveIndex = activePara.findNextWordBoundary(activeMark.position - activeParaStart) + activeParaStart;
            else
                newActiveIndex = activePara.findPreviousWordBoundary(activeMark.position - activeParaStart) + activeParaStart;
                
            // don't include end of paragraph marker
            if (newActiveIndex == activeParaStart+activePara.textLength)
                newActiveIndex--;

            // Adjust the anchor end. If we're doing a dbl-click shift select to extend the selection, the anchor point stays the same.
            // Otherwise adjust it to the beginning or end of the nearest word, depending on which end of the selection is active
            var newAnchorIndex:int; // adjusted anchor index
            if (event.shiftKey) 
                newAnchorIndex = anchorMark.position;
            else
            {
                var anchorPara:ParagraphElement = _textFlow.findAbsoluteParagraph(anchorMark.position);
                var anchorParaStart:int = anchorPara.getAbsoluteStart();
                if (atBeginningWordPos(anchorPara, anchorMark.position - anchorParaStart))
                {
                    newAnchorIndex = anchorMark.position;                   
                }
                else
                {
                    if (anchorMark.position <= activeMark.position)
                        newAnchorIndex = anchorPara.findPreviousWordBoundary(anchorMark.position - anchorParaStart) + anchorParaStart;
                    else
                        newAnchorIndex = anchorPara.findNextWordBoundary(anchorMark.position - anchorParaStart) + anchorParaStart;
                    // don't include end of paragraph marker
                    if (newAnchorIndex == anchorParaStart+anchorPara.textLength)
                        newAnchorIndex--;
                }   
            }
            
            if (newAnchorIndex != anchorMark.position || newActiveIndex != activeMark.position)
            {
                internalSetSelection(_textFlow, newAnchorIndex, newActiveIndex, null);              
                selectionChanged();
                clearSelectionShapes();

                if (hasSelection())
                    addSelectionShapes();
            }
            
            allowOperationMerge = false;
        }

        /** 
         * @copy IInteractionEventHandler#mouseOverHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */                         
        public function mouseOverHandler(event:MouseEvent):void
        {
            _mouseOverSelectionArea = true;
            var wmode:String = textFlow.computedFormat.blockProgression;
            if (wmode != BlockProgression.RL) 
                setMouseCursor(MouseCursor.IBEAM);  
            else 
                setMouseCursor(MouseCursor.AUTO);                               
        }

        /** 
         * @copy IInteractionEventHandler#mouseOutHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */                 
        public function mouseOutHandler(event:MouseEvent):void
        {
            _mouseOverSelectionArea = false;            
            setMouseCursor(MouseCursor.AUTO);                                   
        }       
        
        /** 
         * @copy IInteractionEventHandler#focusInHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function focusInHandler(event:FocusEvent):void
        {           
            // The focusIn can come before the activate. If so, we don't want the later activate to wipe out the focusIn
            _isActive = true;   
            
            //trace("focusIn event on selectionManager", this.id);
            setSelectionFormatState(SelectionFormatState.FOCUSED);      
        }
         
        /** 
         * @copy IInteractionEventHandler#focusOutHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function focusOutHandler(event:FocusEvent):void
        {
            //trace("focusOut event on selectionManager", this.id);
            if (_isActive)  // don't do it if we aren't active
                setSelectionFormatState(SelectionFormatState.UNFOCUSED);            
        }

        /** 
         * @copy IInteractionEventHandler#activateHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */             
        public function activateHandler(event:Event):void
        {
            //trace("activate selectionManager", id);
            // If there are multiple containers, the selection manager will get multiple activate & deactivate events,
            // one per container. We only want to respond to the first one, because otherwise a focus event that comes
            // in the middle will get its state change overwritten.
            if (!_isActive)
            {       
                _isActive = true;
                setSelectionFormatState(SelectionFormatState.UNFOCUSED);
            }   
        }
        
        /** 
         * @copy IInteractionEventHandler#deactivateHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */             
        public function deactivateHandler(event:Event):void
        {
            //trace("deactivate selectionManager", id);
            // If there are multiple containers, the selection manager will get multiple activate & deactivate events,
            // one per container. We only want to respond to the first one, because otherwise a focus event that comes
            // in the middle will get its state change overwritten.
            if (_isActive)
            {
                _isActive = false;
                setSelectionFormatState(SelectionFormatState.INACTIVE);         
            }
        }
        
        /** Perform a SelectionManager operation - these may never modify the flow but clients still are able to cancel them. 
          * 
          * @playerversion Flash 10
          * @playerversion AIR 1.5
          * @langversion 3.0
          */
        public function doOperation(op:FlowOperation):void
        {
            var opEvent:FlowOperationEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_BEGIN,false,true,op,0,null);
            textFlow.dispatchEvent(opEvent);
            if (!opEvent.isDefaultPrevented())
            {
                op = opEvent.operation;
                
                // only copy operation is allowed
                if (!(op is CopyOperation))
                    throw new IllegalOperationError(GlobalSettings.resourceStringFunction("illegalOperation",[ getQualifiedClassName(op) ]));
                var opError:Error = null;
                try
                {
                    op.doOperation();
                }
                catch(e:Error)
                {
                    opError = e;
                }
                // operation completed - send event whether it succeeded or not.
                opEvent = new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_END,false,true,op,0,opError);
                textFlow.dispatchEvent(opEvent);
                opError = opEvent.isDefaultPrevented() ? null : opEvent.error;
                if (opError)
                    throw (opError);
                textFlow.dispatchEvent(new FlowOperationEvent(FlowOperationEvent.FLOW_OPERATION_COMPLETE,false,false,op,0,null));
            }           
        }

        /** 
         * @copy IInteractionEventHandler#editHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */ 
        public function editHandler(event:Event):void
        {
            switch (event.type)
            {
                case Event.COPY:
                    flushPendingOperations();
                    doOperation(new CopyOperation(getSelectionState()));
                    break;
                case Event.SELECT_ALL:
                    flushPendingOperations();
                    selectAll();
                    refreshSelection();
                    break;  
            }           
        }

        private function handleLeftArrow(event:KeyboardEvent):SelectionState
        {           
            var selState:SelectionState = getSelectionState();
            if(_textFlow.computedFormat.blockProgression != BlockProgression.RL)
            {
                if(_textFlow.computedFormat.direction == Direction.LTR)
                {
                    if (event.ctrlKey || event.altKey)
                        NavigationUtil.previousWord(selState,event.shiftKey);
                    else
                        NavigationUtil.previousCharacter(selState,event.shiftKey);
                }
                else
                {
                    if (event.ctrlKey || event.altKey)
                        NavigationUtil.nextWord(selState,event.shiftKey);
                    else
                        NavigationUtil.nextCharacter(selState,event.shiftKey);
                }
            } 
            else 
            {
                // always test for altkey first - that way ctrl-alt is the same as alt
                if (event.altKey)
                    NavigationUtil.endOfParagraph(selState,event.shiftKey);
                else if (event.ctrlKey)
                    NavigationUtil.endOfDocument(selState,event.shiftKey);
                else
                    NavigationUtil.nextLine(selState,event.shiftKey);
            }
            return selState;
        }
        
        private function handleUpArrow(event:KeyboardEvent):SelectionState
        {           
            var selState:SelectionState = getSelectionState();
            if(_textFlow.computedFormat.blockProgression != BlockProgression.RL)
            {
                // always test for altkey first - that way ctrl-alt is the same as alt
                if (event.altKey)
                    NavigationUtil.startOfParagraph(selState,event.shiftKey);
                else if (event.ctrlKey)
                    NavigationUtil.startOfDocument(selState,event.shiftKey);
                else
                    NavigationUtil.previousLine(selState,event.shiftKey);
            }
            else
            {
                if(_textFlow.computedFormat.direction == Direction.LTR)
                {
                    if (event.ctrlKey || event.altKey)
                        NavigationUtil.previousWord(selState,event.shiftKey);
                    else
                        NavigationUtil.previousCharacter(selState,event.shiftKey); 
                }
                else
                {
                    if (event.ctrlKey || event.altKey)
                        NavigationUtil.nextWord(selState,event.shiftKey);
                    else
                        NavigationUtil.nextCharacter(selState,event.shiftKey);
                }
            }
            return selState;
        }
        
        private function handleRightArrow(event:KeyboardEvent):SelectionState
        {
            var selState:SelectionState = getSelectionState();
            
            if(_textFlow.computedFormat.blockProgression  != BlockProgression.RL)
            {
                if(_textFlow.computedFormat.direction == Direction.LTR)
                {
                    if (event.ctrlKey || event.altKey)
                        NavigationUtil.nextWord(selState,event.shiftKey);
                    else
                        NavigationUtil.nextCharacter(selState,event.shiftKey);
                }
                else
                {
                    if (event.ctrlKey || event.altKey)
                        NavigationUtil.previousWord(selState,event.shiftKey);
                    else
                        NavigationUtil.previousCharacter(selState,event.shiftKey);
                }
            }
            else
            {
                // always test for altkey first - that way ctrl-alt is the same as alt
                if (event.altKey)
                    NavigationUtil.startOfParagraph(selState,event.shiftKey);
                else if (event.ctrlKey)
                    NavigationUtil.startOfDocument(selState,event.shiftKey);
                else
                    NavigationUtil.previousLine(selState,event.shiftKey);
            }
            return selState;
        }
        
        private function handleDownArrow(event:KeyboardEvent):SelectionState
        {
            var selState:SelectionState = getSelectionState();
            
            if(_textFlow.computedFormat.blockProgression != BlockProgression.RL)
            {
                // always test for altkey first - that way ctrl-alt is the same as alt
                if (event.altKey)
                    NavigationUtil.endOfParagraph(selState,event.shiftKey);
                else if (event.ctrlKey)
                    NavigationUtil.endOfDocument(selState,event.shiftKey);
                else
                    NavigationUtil.nextLine(selState,event.shiftKey);
            }
            else
            {
                if(_textFlow.computedFormat.direction == Direction.LTR)
                {
                    if (event.ctrlKey || event.altKey)
                        NavigationUtil.nextWord(selState,event.shiftKey);
                    else
                        NavigationUtil.nextCharacter(selState,event.shiftKey);
                }
                else
                {
                    if (event.ctrlKey || event.altKey)
                        NavigationUtil.previousWord(selState,event.shiftKey);
                    else
                        NavigationUtil.previousCharacter(selState,event.shiftKey); 
                }
            }

            return selState;
        }
        
        private function handleHomeKey(event:KeyboardEvent):SelectionState
        {
            var selState:SelectionState = getSelectionState();
            if (event.ctrlKey && !event.altKey)
                NavigationUtil.startOfDocument(selState,event.shiftKey);
            else
                NavigationUtil.startOfLine(selState,event.shiftKey);
            return selState;
        }
        
        private function handleEndKey(event:KeyboardEvent):SelectionState
        {
            var selState:SelectionState = getSelectionState();
            if (event.ctrlKey && !event.altKey)
                NavigationUtil.endOfDocument(selState,event.shiftKey);
            else
                NavigationUtil.endOfLine(selState,event.shiftKey);
            return selState;
        }
        
        private function handlePageUpKey(event:KeyboardEvent):SelectionState
        {
            var selState:SelectionState = getSelectionState();
            NavigationUtil.previousPage(selState,event.shiftKey);
            return selState;
        }

        private function handlePageDownKey(event:KeyboardEvent):SelectionState
        {
            var selState:SelectionState = getSelectionState();
            NavigationUtil.nextPage(selState,event.shiftKey);
            return selState;
        }       
                        
        private function handleKeyEvent(event:KeyboardEvent):void
        {
            var selState:SelectionState = null;
            flushPendingOperations();           
            
            switch(event.keyCode)
            {
                case Keyboard.LEFT:
                    selState = handleLeftArrow(event);
                    break;
                case Keyboard.UP:
                    selState = handleUpArrow(event);
                    break;
                case Keyboard.RIGHT:
                    selState = handleRightArrow(event);
                    break;
                case Keyboard.DOWN:
                    selState = handleDownArrow(event);
                    break;
                case Keyboard.HOME:
                    selState = handleHomeKey(event);
                    break;
                case Keyboard.END:
                    selState = handleEndKey(event);
                    break;
                case Keyboard.PAGE_DOWN:
                    selState = handlePageDownKey(event);
                    break;
                case Keyboard.PAGE_UP:
                    selState = handlePageUpKey(event);
                    break;
            }

            if (selState != null)
            {
                event.preventDefault();
                updateSelectionAndShapes(_textFlow, selState.anchorPosition, selState.activePosition);

                // make sure the active end is visible in the container -- scroll if necessary
                if (_textFlow.flowComposer && _textFlow.flowComposer.numControllers != 0)
                     _textFlow.flowComposer.getControllerAt(_textFlow.flowComposer.numControllers-1).scrollToRange(selState.activePosition,selState.activePosition);
            }
            allowOperationMerge = false;
        }                                                                                                       
            
        /** 
         * @copy IInteractionEventHandler#keyDownHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */ 
        public function keyDownHandler(event:KeyboardEvent):void
        {
            if (!hasSelection() || event.isDefaultPrevented())
                return;

            if (event.charCode == 0)
            {   
                // the keycodes that we currently handle
                switch(event.keyCode)
                {
                    case Keyboard.LEFT:
                    case Keyboard.UP:
                    case Keyboard.RIGHT:
                    case Keyboard.DOWN:
                    case Keyboard.HOME:
                    case Keyboard.END:
                    case Keyboard.PAGE_DOWN:
                    case Keyboard.PAGE_UP:
                    case Keyboard.ESCAPE:
                        handleKeyEvent(event);
                        break;
                }
            }
            else if (event.keyCode == Keyboard.ESCAPE)
                handleKeyEvent(event);
        }

        /** 
         * @copy IInteractionEventHandler#keyUpHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         *  @param  event   the keyUp event
         */         
        public function keyUpHandler(event:KeyboardEvent):void
        {
            //do nothing here
        }
        
        /** 
         * @copy IInteractionEventHandler#keyFocusChangeHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         *  @param  event   the FocusChange event
         */ 
        public function keyFocusChangeHandler(event:FocusEvent):void
        {
            return; // ignores manageTabKey if not editable
        }   
        
        /** 
         * @copy IInteractionEventHandler#textInputHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
        */
        public function textInputHandler(event:TextEvent):void
        {
            // do nothing
            ignoreNextTextEvent = false;
        }

        /** 
         * @copy IInteractionEventHandler#imeStartCompositionHandler()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
        */
        public function imeStartCompositionHandler(event:IMEEvent):void
        {
            // Do nothing -- this is handled in the EditManager if editing is supported
            // If there is no EditManager, doing nothing will refuse the IME session.
        }
        
        /** 
         * @copy IInteractionEventHandler#softKeyboardActivatingHandler()
         * 
         * @playerversion Flash 10.2
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function softKeyboardActivatingHandler(event:Event):void
        {
            // Do nothing -- this is handled in the EditManager if editing is supported
        }
        
        /**
         *  @private
         * 
         *  Execute asynchronous operations at the beginning of a frame. This
         *  event listener is called only if there is work that needs to be done.
         */
        protected function enterFrameHandler(event:Event):void
        {
            flushPendingOperations();
        }

        /**
         * @copy IInteractionEventHandler#focusChangeHandler()
         */
        public function focusChangeHandler(event:FocusEvent):void
        { }
        
        /**
         * @copy IInteractionEventHandler#menuSelectHandler()
         */
        public function menuSelectHandler(event:ContextMenuEvent):void
        {
            var menu:ContextMenu = event.target as ContextMenu;
            
            if (activePosition != anchorPosition)
            {
                menu.clipboardItems.copy = true;
                menu.clipboardItems.cut = editingMode == EditingMode.READ_WRITE;
                menu.clipboardItems.clear = editingMode == EditingMode.READ_WRITE;
            } else {
                menu.clipboardItems.copy = false;
                menu.clipboardItems.cut = false;
                menu.clipboardItems.clear = false;
            }
            
            var systemClipboard:Clipboard = Clipboard.generalClipboard;
            if (activePosition != -1 && editingMode == EditingMode.READ_WRITE && (systemClipboard.hasFormat(TextClipboard.TEXT_LAYOUT_MARKUP) || systemClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)))
            {
                menu.clipboardItems.paste = true;
            } else {
                menu.clipboardItems.paste = false;
            }
            menu.clipboardItems.selectAll = true;       
        }
        
        /**
         * @copy IInteractionEventHandler#mouseWheelHandler()
         */
        public function mouseWheelHandler(event:MouseEvent):void
        { }             
        /**
         * @copy IInteractionEventHandler#flushPendingOperations()
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function flushPendingOperations():void
        {   }

        /**
         * @copy ISelectionManager#getCommonCharacterFormat()
         * 
         * @includeExample examples\SelectionManager_getCommonCharacterFormat.as -noswf
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function getCommonCharacterFormat(range:TextRange=null):TextLayoutFormat
        {
            if (!range && !hasSelection())
                return null;
            
            var selRange:ElementRange = ElementRange.createElementRange(_textFlow, range ? range.absoluteStart : absoluteStart, range? range.absoluteEnd : absoluteEnd);
            var rslt:TextLayoutFormat = selRange.getCommonCharacterFormat();
                
            // include any attributes set on a point selection but not yet applied  
            if (selRange.absoluteEnd == selRange.absoluteStart && pointFormat)
                rslt.apply(pointFormat)
    
            return rslt;
        }
        
         
         /**
         * @copy ISelectionManager#getCommonParagraphFormat()
         * 
         * @includeExample examples\SelectionManager_getCommonParagraphFormat.as -noswf
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function getCommonParagraphFormat (range:TextRange=null):TextLayoutFormat
        {
            if (!range && !hasSelection())
                return null;
            
            return ElementRange.createElementRange(_textFlow, range ? range.absoluteStart : absoluteStart, range? range.absoluteEnd : absoluteEnd).getCommonParagraphFormat();
         }
         
        /**
         * @copy ISelectionManager#getCommonContainerFormat()
         * 
         * @includeExample examples\SelectionManager_getCommonContainerFormat.as -noswf
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function getCommonContainerFormat (range:TextRange=null):TextLayoutFormat
        {
            if (!range && !hasSelection())
                return null;
            
            return ElementRange.createElementRange(_textFlow, range ? range.absoluteStart : absoluteStart, range? range.absoluteEnd : absoluteEnd).getCommonContainerFormat();
        }
         
        /**
         * Refreshes and displays TextFlow selection defined by a beginning and ending index.
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        private function updateSelectionAndShapes(tf:TextFlow, begIdx:int, endIdx:int):void
        {
            internalSetSelection(tf, begIdx, endIdx);
            if (_textFlow.flowComposer && _textFlow.flowComposer.numControllers != 0)
                _textFlow.flowComposer.getControllerAt(_textFlow.flowComposer.numControllers-1).scrollToRange(activeMark.position,anchorMark.position);
                
            selectionChanged();
            clearSelectionShapes();
            addSelectionShapes();
        }
        
        /** @private */
        CONFIG::debug tlf_internal function debugCheckTextFlow():int
        {
            if (flashx.textLayout.debug.Debugging.debugOn)
                return _textFlow.debugCheckTextFlow();
            return 0;
        }
        
        private var marks:Array = [];
        
        /** @private */
        tlf_internal function createMark():Mark
        {
            var mark:Mark = new Mark(-1);
            marks.push(mark);
            return mark;
        }
        /** @private */
        tlf_internal function removeMark(mark:Mark):void
        {
            var idx:int = marks.indexOf(mark);
            if (idx != -1)
                marks.splice(idx,idx+1);
        }
        
        /** 
         * @copy ISelectionManager#notifyInsertOrDelete()
         * 
         * @includeExample examples\SelectionManager_notifyInsertOrDelete.as -noswf
         * 
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function notifyInsertOrDelete(absolutePosition:int, length:int):void
        {
            if (length == 0)
                return;
            for (var i:int = 0; i < marks.length; i++)
            {
                var mark:Mark = marks[i];
                if (mark.position >= absolutePosition)
                {
                    if (length < 0)
                        mark.position = (mark.position + length < absolutePosition) ? absolutePosition : mark.position + length;
                    else
                        mark.position += length;
                }
            }
        }
    }
}
