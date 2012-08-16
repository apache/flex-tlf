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
	import flash.geom.Rectangle;
	
	import flashx.undo.UndoManager;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.operations.CompositeOperation;
	import flashx.textLayout.operations.FlowOperation;
	
	import flashx.undo.IOperation;
	
	/** 
	 * IEditManager defines the interface for handling edit operations of a text flow.
	 * 
	 * <p>To enable text flow editing, assign an IEditManager instance to the <code>interactionManager</code> 
	 * property of the TextFlow object. The edit manager handles changes to the text (such as insertions, 
	 * deletions, and format changes). Changes are reversible if the edit manager has an undo manager. The edit
	 * manager triggers the recomposition and display of the text flow, as necessary.</p>
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
 	 * 
 	 * @see EditManager
 	 * @see flashx.textLayout.elements.TextFlow
 	 * @see flashx.undo.UndoManager
 	 * 
	 */
	public interface IEditManager extends ISelectionManager
	{				

		/** 
		 * The UndoManager object assigned to this EditManager instance, if there is one.
		 * 
		 * <p>An undo manager handles undo and redo operations.</p>
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		function get undoManager():flashx.undo.IUndoManager

		/** 
		 * Changes the formats of the specified (or current) selection.
		 * 
		 * <p>Executes an undoable operation that applies the new formats.
		 * Only style attributes set for the TextLayoutFormat objects are applied.
		 * Undefined attributes in the format objects are not changed.
		 * </p>
 	 	 * 
		 * @param leafFormat	the format to apply to leaf elements such as spans and inline graphics
		 * @param paragraphFormat	format to apply to paragraph elements
		 * @param containerFormat	format to apply to the containers
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 *
 	 	 * @includeExample examples\EditManager_applyFormat.as -noswf
 	 	 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */		
		function applyFormat(leafFormat:ITextLayoutFormat, paragraphFormat:ITextLayoutFormat, containerFormat:ITextLayoutFormat, operationState:SelectionState = null):void

		
		/** 
		 * Undefines formats of the specified (or current) selection.
		 * 
		 * <p>Executes an undoable operation that undefines the specified formats.
		 * Only style attributes set for the TextLayoutFormat objects are applied.
		 * Undefined attributes in the format objects are not changed.
		 * </p>
		 * 
		 * @param leafFormat	 The format whose set values indicate properties to undefine to LeafFlowElement objects in the selected range.
		 * @param paragraphFormat The format whose set values indicate properties to undefine to ParagraphElement objects in the selected range.
		 * @param containerFormat The format whose set values indicate properties to undefine to ContainerController objects in the selected range.
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */		
		function clearFormat(leafFormat:ITextLayoutFormat, paragraphFormat:ITextLayoutFormat, containerFormat:ITextLayoutFormat, operationState:SelectionState = null):void

		/** 
		 * Changes the format applied to the leaf elements in the 
		 * specified (or current) selection.
		 * 
		 * <p>Executes an undoable operation that applies the new format to leaf elements such as
		 * SpanElement and InlineGraphicElement objects.
		 * Only style attributes set for the TextLayoutFormat objects are applied.
		 * Undefined attributes in the format object are changed.</p>
		 * 
		 * @param format	the format to apply.
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_applyLeafFormat.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */		
		function applyLeafFormat(format:ITextLayoutFormat, operationState:SelectionState = null):void;

		/** 
		 * Transforms text into a TCY run, or a TCY run into non-TCY text. 
		 * 
		 * <p>TCY, or tate-chu-yoko, causes text to draw horizontally within a vertical line, and is 
		 * used to make small blocks of non-Japanese text or numbers, such as dates, more readable in vertical text.</p>
		 * 
		 * @param tcyOn	specify <code>true</code> to apply TCY to a text range, <code>false</code> to remove TCY. 
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_applyTCY.as -noswf
		 * @see flashx.textLayout.elements.TCYElement
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
 		 */			
		function applyTCY(tcyOn:Boolean, operationState:SelectionState = null):void;
		
		/** 
		 * Transforms a selection into a link, or a link into normal text.
		 * 
		 * <p>Executes an undoable operation that creates or removes the link.</p>
		 * 
		 *  <p>If a <code>target</code> parameter is specified, it must be one of the following values:</p>
		 * <ul>
		 *	<li>"_self"</li>
		 *  <li>"_blank"</li>
		 *  <li>"_parent"</li>
		 *  <li>"_top"</li>
         * </ul>
		 * <p>In browser-hosted runtimes, a target of "_self" replaces the current html page.  
		 * So, if the SWF content containing the link is in a page within
		 * a frame or frameset, the linked content loads within that frame.  If the page 
		 * is at the top level, the linked content opens to replace the original page.  
		 * A target of "_blank" opens a new browser window with no name.  
		 * A target of "_parent" replaces the parent of the html page containing the SWF content.  
		 * A target of "_top" replaces the top-level page in the current browser window.</p>
		 * 
		 * <p>In other runtimes, such as Adobe AIR, the link opens in the user's default browser and the
		 * <code>target</code> parameter is ignored.</p>
		 * 
		 * <p>The <code>extendToLinkBoundary</code> parameter determines how the edit manager 
		 * treats a selection that intersects with one or more existing links. If the parameter is 
		 * <code>true</code>, then the operation is applied as a unit to the selection and the
		 * whole text of the existing links. Thus, a single link is created that spans from
		 * the beginning of the first link intersected to the end of the last link intersected.
		 * In contrast, if <code>extendToLinkBoundary</code> were <code>false</code> in this situation, 
		 * the existing partially selected links would be split into two links.</p>
		 *
		 * @param href The uri referenced by the link.
		 * @param target The target browser window of the link.
		 * @param extendToLinkBoundary Specifies whether to consolidate selection with any overlapping existing links, and then apply the change.
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_applyLink.as -noswf
		 * @see flashx.textLayout.elements.LinkElement
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */			
		function applyLink(href:String, target:String=null, extendToLinkBoundary:Boolean=false, operationState:SelectionState = null):void;
		
		/**
		* Changes the ID of an element.
		* 
		 * <p>If the <code>relativeStart</code> or <code>relativeEnd</code> parameters are set (to
		 * anything other than the default values), then the element is split. The parts of the element
		 * outside this range retain the original ID. Setting both the <code>relativeStart</code> and 
		 * <code>relativeEnd</code> parameters creates elements with duplicate IDs.</p>
		 * 
		* @param newID the new ID value
		* @param targetElement the element to modify
		* @param relativeStart an offset from the beginning of the element at which to split the element when assigning the new ID
		* @param relativeEnd an offset from the end of the element at which to split the element when assigning the new ID
		* @param operationState	specifies the selection to restore when undoing this operation; 
		* if <code>null</code>, the operation saves the current selection.
		* 
		 * @includeExample examples\EditManager_changeElementID.as -noswf
		 * 
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0 
	 	*/
		function changeElementID(newID:String, targetElement:FlowElement, relativeStart:int = 0, relativeEnd:int = -1, operationState:SelectionState = null):void;
		
		/**
		* Changes the styleName of an element or part of an element.
		 * 
		 * <p>If the <code>relativeStart</code> or <code>relativeEnd</code> parameters are set (to
		 * anything other than the default values), then the element is split. The parts of the element
		 * outside this range retain the original style.</p>
		 * 
		* @param newName the name of the new style.
		* @param targetElement specifies the element to change.
		* @param relativeStart an offset from the beginning of the element at which to split the element when assigning the new style
		* @param relativeEnd an offset from the end of the element at which to split the element when assigning the new style
		* @param operationState	specifies the selection to restore when undoing this operation; 
		* if <code>null</code>, the operation saves the current selection.
		* 
		 * @includeExample examples\EditManager_changeStyleName.as -noswf
		* @playerversion Flash 10
		* @playerversion AIR 1.5
	 	* @langversion 3.0 
	 	*/
		function changeStyleName(newName:String, targetElement:FlowElement, relativeStart:int = 0, relativeEnd:int = -1, operationState:SelectionState = null):void;

		/** 
		 * Deletes a range of text, or, if a point selection is given, deletes the next character.
		 * 
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_deleteNextCharacter.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		function deleteNextCharacter(operationState:SelectionState = null):void;
		
		/** 
		 * Deletes a range of text, or, if a point selection is given, deletes the previous character.
		 * 
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_deletePreviousCharacter.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		function deletePreviousCharacter(operationState:SelectionState = null):void;
		
		/** 
		 * Deletes the next word.
		 * 
		 * <p>If a range is selected, the first word of the range is deleted.</p>
		 * 
		 * @param operationState specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_deleteNextWord.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */		
		function deleteNextWord(operationState:SelectionState = null):void;
		
		/** 
		 * Deletes the previous word.
		 * 
		 * <p>If a range is selected, the first word of the range is deleted.</p>
		 * 
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_deletePreviousWord.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */		
		function deletePreviousWord(operationState:SelectionState = null):void;		
		
		/** 
		 * Deletes a range of text.
		 * 
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_deleteText.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		function deleteText(operationState:SelectionState = null):void

		/** 
		 * Inserts an image.
		 * 
		 * <p>The source of the image can be a string containing a URI, URLRequest object, a Class object representing an embedded asset,
		 * or a DisplayObject instance.</p>
		 *  
		 * <p>The width and height values can be the number of pixels, a percent, or the string, 'auto', 
		 * in which case the actual dimension of the graphic is used.</p>
		 * 
		 * <p>Set the <code>float</code> to one of the constants defined in the Float class to specify whether
		 * the image should be displayed to the left or right of any text or inline with the text.</p>
		 * 
		 *	@param	source	can be either a String interpreted as a uri, a Class interpreted as the class of an Embed DisplayObject, 
		 * 					a DisplayObject instance or a URLRequest. 
		 *	@param	width	width of the image to insert (number, percent, or 'auto')
		 *	@param	height	height of the image to insert (number, percent, or 'auto')
		 *	@param	options	none supported.
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_insertInlineGraphic.as -noswf
		 * 
		 * @see flashx.textLayout.elements.InlineGraphicElement
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
 		 */			
		function insertInlineGraphic(source:Object, width:Object, height:Object, options:Object = null, operationState:SelectionState = null):void;
		
		/** 
		 * Modifies an existing inline graphic.
		 * 
		 * <p>Set unchanging properties to the values in the original graphic. (Modifying an existing graphic object
		 * is typically more efficient than deleting and recreating one.)</p>
		 * 
		 *	@param	source	can be either a String interpreted as a uri, a Class interpreted as the class of an Embed DisplayObject, 
		 * 					a DisplayObject instance or a URLRequest. 
		 *	@param	width	new width for the image (number or percent)
		 *	@param	height	new height for the image (number or percent)
		 *	@param	options	none supported
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_modifyInlineGraphic.as -noswf
		 * 
		 *  @see flashx.textLayout.elements.InlineGraphicElement
		 * 
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */			
		function modifyInlineGraphic(source:Object, width:Object, height:Object, options:Object = null, operationState:SelectionState = null):void;

		/** 
		 * Inserts text.
		 * 
		 * <p>Inserts the text at a position or range in the text. If the location supplied in the 
		 * <code>operationState</code> parameter is a range (or the parameter is <code>null</code> and the
		 * current selection is a range), then the text currently in the range 
		 * is replaced by the inserted text.</p>
		 * 
		 * @param	text		the string to insert
		 * @param operationState	specifies the text in the flow to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_insertText.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */	
		function insertText(text:String, operationState:SelectionState = null):void;
		
		/** 
		 * Overwrites the selected text.
		 * 
		 * <p>If the selection is a point selection, the first character is overwritten by the new text.</p>
		 * 
		 * @param text the string to insert
		 * @param operationState specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_overwriteText.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */	
		function overwriteText(text:String, operationState:SelectionState = null):void;

		/** 
		 * Applies paragraph styles to any paragraphs in the selection.
		 * 
		 * <p>Any style properties in the format object that are <code>null</code> are left unchanged.</p> 
		 * 
 	 	 * @param format the format to apply to the selected paragraphs.
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_applyParagraphFormat.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
 		 */		
		function applyParagraphFormat(format:ITextLayoutFormat, operationState:SelectionState = null):void;

		/** 
		 * Applies container styles to any containers in the selection.
		 * 
		 * <p>Any style properties in the format object that are <code>null</code> are left unchanged.</p> 
		 * 
		 * @param format	the format to apply to the containers in the range
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_applyContainerFormat.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */		
		function applyContainerFormat(format:ITextLayoutFormat, operationState:SelectionState = null):void;
		
		/** 
		 * Applies styles to the specified element.
		 * 
		 * <p>Any style properties in the format object that are <code>null</code> are left unchanged.
		 * Only styles that are relevant to the specified element are applied.</p> 
		 * 
		 * @param 	targetElement the element to which the styles are applied.
		 * @param	format	the format containing the styles to apply
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_applyFormatToElement.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */	
		function applyFormatToElement(targetElement:FlowElement, format:ITextLayoutFormat, operationState:SelectionState = null):void;
		
		/** 
		 * Undefines styles to the specified element.
		 * 
		 * <p>Any style properties in the format object that are <code>undefined</code> are left unchanged.
		 * Any styles that are defined in the specififed format are undefined on the specified element.</p> 
		 * 
		 * @param 	targetElement the element to which the styles are applied.
		 * @param	format	the format containing the styles to undefine
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */	
		function clearFormatOnElement(targetElement:FlowElement, format:ITextLayoutFormat, operationState:SelectionState = null):void;
		
		/** 
		 * Splits the paragraph at the current position.
		 *   
		 * <p>If a range of text is specified, the text 
		 * in the range is deleted.</p>
		 * 
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_splitParagraph.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		function splitParagraph(operationState:SelectionState = null):void;
		
		/** 
		 * Deletes the selected area and returns the deleted area in a TextScrap object. 
		 * 
		 * <p>The resulting TextScrap can be posted to the system clipboard or used in a 
		 * subsequent <code>pasteTextOperation()</code> operation.</p>
		 * 
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * @return the TextScrap that was cut
		 * 
		 * @includeExample examples\EditManager_cutTextScrap.as -noswf
		 * 
		 * @see flashx.textLayout.edit.IEditManager.pasteTextScrap
		 * @see flashx.textLayout.edit.TextClipboard.setContents
		 *  
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */
		function cutTextScrap(operationState:SelectionState = null):TextScrap;
		
		/** 
		 * Pastes the TextScrap into the selected area.
		 * 
		 * <p>If a range of text is specified, the text 
		 * in the range is deleted.</p>
		 * 
		 * @param scrapToPaste	the TextScrap to paste
		 * @param operationState	specifies the text to which this operation applies; 
		 * if <code>null</code>, the operation applies to the current selection.
		 * 
		 * @includeExample examples\EditManager_pasteTextScrap.as -noswf
		 * 
		 * @see flashx.textLayout.edit.IEditManager.cutTextScrap
		 * @see flashx.textLayout.edit.TextClipboard.getContents
		 * @see flashx.textLayout.edit.TextScrap
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */
		 function pasteTextScrap(scrapToPaste:TextScrap, operationState:SelectionState = null):void;		

		/** 
		 * Begins a new group of operations. 
		 * 
		 * <p>All operations executed after the call to <code>beginCompositeOperation()</code>, and before the 
		 * matching call to <code>endCompositeOperation()</code> are executed and grouped together as a single 
		 * operation that can be undone as a unit.</p> 
		 * 
		 * <p>A <code>beginCompositeOperation</code>/<code>endCompositeOperation</code> block can be nested inside another 
		 * <code>beginCompositeOperation</code>/<code>endCompositeOperation</code> block.</p>
		 * 
		 * @includeExample examples\EditManager_beginCompositeOperation.as -noswf
		 * 
		 * @see flashx.textLayout.edit.IEditManager.endCompositeOperation
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		function beginCompositeOperation():void;
		
		/** 
		 * Ends a group of operations. 
		 * 
		 * <p>All operations executed since the last call to <code>beginCompositeOperation()</code> are 
		 * grouped as a CompositeOperation that is then completed. This CompositeOperation object is added 
		 * to the undo stack or, if this composite operation is nested inside another composite operation, 
		 * added to the parent operation.</p>
		 * 
		 * @see flashx.textLayout.edit.IEditManager.beginCompositeOperation
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		function endCompositeOperation():void;

		/** 
		 * Executes a FlowOperation.  
		  * 
		  * <p>The <code>doOperation()</code> method is called by IEditManager functions that 
		  * update the text flow. You do not typically need to call this function directly unless 
		  * you create your own custom operations.</p>
		  * 
		  * <p>This function proceeds in the following steps:</p>
		  * <ol>
		  * <li>Flush any pending operations before performing this operation.</li>
		  * <li>Send a cancelable flowOperationBegin event.  If canceled this method returns immediately.</li>
		  * <li>Execute the operation.  The operation returns <code>true</code> or <code>false</code>.  
		  * <code>False</code> indicates that no changes were made.</li>
		  * <li>Push the operation onto the undo stack.</li>
		  * <li>Clear the redo stack.</li>
		  * <li>Update the display.</li>
		  * <li>Send a cancelable flowOperationEnd event.</li>
		  * </ol>
		  * <p>Exception handling:  If the operation throws an exception, it is caught and the error is 
		  * attached to the flowOperationEnd event.  If the event is not canceled the error is rethrown.</p>
		  * 
		  * @param operation a FlowOperation object
		  * 
		  * @includeExample examples\EditManager_doOperation.as -noswf
		  * 
		  * @playerversion Flash 10
		  * @playerversion AIR 1.5
 	 	  * @langversion 3.0
		  */
		function doOperation(operation:FlowOperation):void;

		/** 
		 * Reverses the previous operation. 
		 * 
		 * <p><b>Note:</b> If the IUndoManager associated with this IEditManager is also associated with 
		 * another IEditManager, then it is possible that the undo operation associated with the other 
		 * IEditManager is the one undone.  This can happen if the FlowOperation of another IEditManager 
		 * is on top of the undo stack.</p>  
		 * 
		 * <p>This function does nothing if undo is not turned on.</p>
		 * 
		 * @includeExample examples\EditManager_undo.as -noswf
		 * 
		 * @see flashx.undo.IUndoManager#undo
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		function undo():void;

		/** 
		 * Reperforms the previous undone operation.
		 * 
		 * <p><b>Note:</b> If the IUndoManager associated with this IEditManager is also associated with 
		 * another IEditManager, then it is possible that the redo operation associated with the other 
		 * IEditManager is the one redone. This can happen if the FlowOperation of another IEditManager 
		 * is on top of the redo stack.</p>  
		 * 
		 * <p>This function does nothing if undo is not turned on.</p>
		 * 
		 * @includeExample examples\EditManager_redo.as -noswf
		 * 
		 * @see flashx.undo.IUndoManager#redo
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 	 	 * @langversion 3.0
		 */
		function redo():void;
		
		/** @private */
		function performUndo(operation:IOperation):void;

		/** @private */
		function performRedo(operation:IOperation):void;
	}
}
