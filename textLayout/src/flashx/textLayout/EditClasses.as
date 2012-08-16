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
package flashx.textLayout
{
	internal class EditClasses
	{
		import flash.text.ime.CompositionAttributeRange; flash.text.ime.CompositionAttributeRange;
		import flash.text.ime.IIMEClient; flash.text.ime.IIMEClient;
		
		import flashx.textLayout.container.TextContainerManager; TextContainerManager;
		
		import flashx.textLayout.events.FlowOperationEvent; FlowOperationEvent;
		import flashx.textLayout.events.SelectionEvent; SelectionEvent;
 
		import flashx.textLayout.edit.EditManager; EditManager;
		import flashx.textLayout.edit.ElementRange; ElementRange;
		import flashx.textLayout.edit.IEditManager; IEditManager;
		import flashx.textLayout.edit.Mark; Mark;
		import flashx.textLayout.edit.SelectionManager; SelectionManager;
		import flashx.textLayout.edit.ModelEdit; ModelEdit;
		import flashx.textLayout.edit.IMemento; IMemento;
		import flashx.textLayout.edit.ElementMark; ElementMark;

		import flashx.textLayout.edit.TextScrap; TextScrap;

		import flashx.textLayout.operations.ApplyFormatOperation; ApplyFormatOperation;
		import flashx.textLayout.operations.ApplyFormatToElementOperation; ApplyFormatToElementOperation;
		import flashx.textLayout.operations.ApplyLinkOperation; ApplyLinkOperation;
		import flashx.textLayout.operations.ApplyTCYOperation; ApplyTCYOperation;
		import flashx.textLayout.operations.ApplyElementIDOperation; ApplyElementIDOperation;
		import flashx.textLayout.operations.ApplyElementStyleNameOperation; ApplyElementStyleNameOperation;
		import flashx.textLayout.operations.ApplyElementTypeNameOperation; ApplyElementTypeNameOperation;
		import flashx.textLayout.operations.CreateDivOperation; CreateDivOperation;
		import flashx.textLayout.operations.ClearFormatOperation; ClearFormatOperation;
		import flashx.textLayout.operations.ClearFormatOnElementOperation; ClearFormatOnElementOperation;
		import flashx.textLayout.operations.CreateListOperation; CreateListOperation;
		import flashx.textLayout.operations.CreateSubParagraphGroupOperation; CreateSubParagraphGroupOperation;
		import flashx.textLayout.operations.CompositeOperation; CompositeOperation;
		import flashx.textLayout.operations.CopyOperation; CopyOperation;
		import flashx.textLayout.operations.CutOperation; CutOperation;
		import flashx.textLayout.operations.DeleteTextOperation; DeleteTextOperation;
		import flashx.textLayout.operations.FlowOperation; FlowOperation;
		import flashx.textLayout.operations.InsertInlineGraphicOperation; InsertInlineGraphicOperation;
		import flashx.textLayout.operations.InsertTextOperation; InsertTextOperation;
		import flashx.textLayout.operations.PasteOperation; PasteOperation;
		import flashx.textLayout.operations.RedoOperation; RedoOperation;
		import flashx.textLayout.operations.ApplyElementUserStyleOperation; ApplyElementUserStyleOperation;
		import flashx.textLayout.operations.SplitParagraphOperation; SplitParagraphOperation;
		import flashx.textLayout.operations.SplitElementOperation; SplitElementOperation;
		import flashx.textLayout.operations.UndoOperation; UndoOperation;

		import flashx.textLayout.utils.NavigationUtil; NavigationUtil;
		
		import flashx.undo.IOperation; flashx.undo.IOperation;
		import flashx.undo.IUndoManager; flashx.undo.IUndoManager;
		import flashx.undo.UndoManager; flashx.undo.UndoManager;

	}
}
