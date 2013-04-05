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
package UnitTest.Tests
{
	import UnitTest.ExtendedClasses.TestSuiteExtended;
	import UnitTest.ExtendedClasses.VellumTestCase;
	import UnitTest.Fixtures.FileRepository;
	import UnitTest.Fixtures.TestConfig;
	
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.System;
	import flash.text.engine.FontPosture;
	import flash.text.engine.TextLineValidity;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.PointFormat;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.edit.TextClipboard;
	import flashx.textLayout.edit.TextScrap;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ListElement;
	import flashx.textLayout.elements.ListItemElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElementBase;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.elements.TextRange;
	import flashx.textLayout.events.*;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.operations.DeleteTextOperation;
	import flashx.textLayout.operations.InsertInlineGraphicOperation;
	import flashx.textLayout.operations.MoveChildrenOperation;
	import flashx.textLayout.operations.PasteOperation;
	import flashx.textLayout.operations.SplitElementOperation;
	import flashx.textLayout.operations.SplitParagraphOperation;
	import flashx.textLayout.operations.ApplyFormatOperation;
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.utils.NavigationUtil;
	import flashx.undo.IUndoManager;
	import flashx.undo.UndoManager;
	
	import mx.utils.LoaderUtil;

	use namespace tlf_internal;

	/** Test the state of selection after each operation is done, undone, and redone.
	 */
 	public class OperationTest extends VellumTestCase
	{
		public function OperationTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);
			TestData.fileName = "severalPages.xml";
			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Editing";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
			FileRepository.readFile(testConfig.baseURL,"../../test/testFiles/markup/tlf/severalPages.xml");
 			var testCaseClass:Class = OperationTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}


    	public override function setUp():void
    	{
    		super.setUp();
     	}

		public override function tearDown():void
		{
			super.tearDown();
		}

		// Check that the actual selection matches what was expected
		private function checkExpectedSelection(expectedStart:int, expectedEnd:int):void
		{
			var actualSelectionStart:int = SelManager.absoluteStart;
			assertTrue("expected selection to start at " + expectedStart + " but got " + actualSelectionStart,
						expectedStart == actualSelectionStart);
			var actualSelectionEnd:int = SelManager.absoluteEnd;
			assertTrue("expected selection to end at " + expectedEnd + " but got " + actualSelectionEnd,
						expectedEnd == actualSelectionEnd);

		}

		private function resetSelection():void
		{
			SelManager.selectRange(-1,-1);
		}

		private function checkUndo(expectedStart:int, expectedEnd:int):void
		{
			resetSelection();
			(SelManager as IEditManager).undo();
			checkExpectedSelection(expectedStart, expectedEnd);
		}

		private function checkRedo(expectedStart:int, expectedEnd:int):void
		{
			resetSelection();
			(SelManager as IEditManager).redo();
			checkExpectedSelection(expectedStart, expectedEnd);
		}

		/**
		 * Test selection with the InsertTextOperation in insert (non-overwrite) mode
		 */
		public function insertTextSelectionTest():void
		{
			const textToInsert:String = "TEST";
			const initialSelectionPosition:int = 10;

			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelectionPosition, initialSelectionPosition);
			(SelManager as IEditManager).insertText(textToInsert);
			SelManager.flushPendingOperations();
			checkExpectedSelection(initialSelectionPosition + textToInsert.length, initialSelectionPosition + textToInsert.length);

			// After undo, back to original caret selection
			checkUndo(initialSelectionPosition, initialSelectionPosition);

			// After redo, caret selection should be restored to after the inserted text
			checkRedo(initialSelectionPosition + textToInsert.length, initialSelectionPosition + textToInsert.length);
		}

		/**
		 * Test selection with the InsertTextOperation in overwrite mode
		 */
		public function overwriteTextSelectionTest():void
		{
			const textToInsert:String = "T";		// Looks like overwrite mode only works with single characters
			const initialSelectionPosition:int = 10;

			var flowLength:int = SelManager.textFlow.textLength;

			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelectionPosition, initialSelectionPosition);
			(SelManager as IEditManager).overwriteText(textToInsert);
			SelManager.flushPendingOperations();
			checkExpectedSelection(initialSelectionPosition + textToInsert.length, initialSelectionPosition + textToInsert.length);
			assertTrue("Flow length changed after insert in overwrite mode", SelManager.textFlow.textLength == flowLength);

			// After undo, back to original caret selection
			checkUndo(initialSelectionPosition, initialSelectionPosition);
			assertTrue("Flow length changed after undo insert in overwrite mode", SelManager.textFlow.textLength == flowLength);

			// After redo, caret selection should be restored to after the inserted text
			checkRedo(initialSelectionPosition + textToInsert.length, initialSelectionPosition + textToInsert.length);
			assertTrue("Flow length changed after redo insert in overwrite mode", SelManager.textFlow.textLength == flowLength);
		}

		public function splitParagraphTest():void
		{
			// Change the character format at the end of a para, insert a new para after, insert some text,
			// it should have the char format from the previous para

			SelManager.selectRange(0, 0);
			var leaf:FlowLeafElement = SelManager.textFlow.findLeaf(0);
			var para:ParagraphElement = leaf.getParagraph();
			leaf = para.getLastLeaf();
			var charFormat:TextLayoutFormat = new TextLayoutFormat(leaf.format);
			charFormat.fontSize = Number(leaf.computedFormat.fontSize) * 2;
			SelManager.selectRange(para.textLength - 2, para.textLength);
			(SelManager as IEditManager).applyLeafFormat(charFormat);
			SelManager.selectRange(para.textLength - 1, para.textLength - 1);
			(SelManager as IEditManager).splitParagraph();
			SelManager.selectRange(para.textLength, para.textLength);
			(SelManager as IEditManager).insertText("HI THERE");
		 	SelManager.flushPendingOperations();
			leaf = SelManager.textFlow.findLeaf(para.textLength);
			assertTrue("Failure inserting paragraph", leaf.getParagraph() != para);
			assertTrue("Failure to pick up format from previous para", leaf.computedFormat.fontSize == charFormat.fontSize);
		}

		public function deleteTextSelectionTest():void
		{
			const initialSelectionStart:int = 10;
			const initialSelectionEnd:int = 20;


			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelectionStart, initialSelectionEnd);
			(SelManager as IEditManager).deleteNextCharacter();
			checkExpectedSelection(initialSelectionStart, initialSelectionStart);

			// After undo, deleted text should be selected
			checkUndo(initialSelectionStart, initialSelectionEnd);

			// After redo, caret selection should be restored to original state
			checkRedo(initialSelectionStart, initialSelectionStart);
		}

		public function deleteNextWordTest():void
		{
			deleteNextWordFromCaret(10);
		/*	This test code not yet debugged -- basic problem is that nextWord can't accurately predict what should be deleted
			SelManager.selectRange(343, 343);
			SelManager.previousWord();
			deleteNextWordFromRange(SelManager.absoluteStart, 652);		// pick a position that is at the start of the word
			var paragraph:ParagraphFormattedElement = SelManager.textFlow.findLeaf(343).getParagraph();
			var paragraphEnd:int = paragraph.getAbsoluteStart() + paragraph.textLength - 1;
			deleteNextWordFromRange(paragraphEnd, SelManager.textFlow.textLength - 10);
			deleteNextWordFromCaret(paragraphEnd); */
		}

		private function deleteNextWordFromCaret(start:int):void
		{
			const initialSelection:int = start;

			var flowLength:int = SelManager.textFlow.textLength;

			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelection, initialSelection);
			var originalSelectionState:SelectionState = SelManager.getSelectionState();

			var wordSelState:SelectionState = SelManager.getSelectionState();
			NavigationUtil.nextWord(wordSelState,true);
			var wordLength:int = wordSelState.absoluteEnd - wordSelState.absoluteStart;
			(SelManager as IEditManager).deleteNextWord();
			checkExpectedSelection(initialSelection, initialSelection);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after deletion by word", SelManager.textFlow.textLength == flowLength - wordLength);

			// After undo, selection returns to original state
			checkUndo(originalSelectionState.absoluteStart, originalSelectionState.absoluteEnd);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after undo of deletion by word", SelManager.textFlow.textLength == flowLength);

			// After redo, caret selection should be restored to original state
			checkRedo(initialSelection, initialSelection);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after redo of deletion by word", SelManager.textFlow.textLength == flowLength - wordLength);
		}

		public function deleteNextWordFromRange(anchorPosition:int, activePosition:int):void
		{
			var flowLength:int = SelManager.textFlow.textLength;

			SelManager.selectRange(anchorPosition, activePosition);
			SelManager.selectRange(SelManager.absoluteStart, SelManager.absoluteStart);
			var wordSelState:SelectionState = SelManager.getSelectionState();
			NavigationUtil.nextWord(wordSelState,true);
			var wordLength:int = wordSelState.absoluteEnd - wordSelState.absoluteStart;

			// Try a range selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(anchorPosition, activePosition);
			var originalSelectionState:SelectionState = SelManager.getSelectionState();
			(SelManager as IEditManager).deleteNextWord();
			checkExpectedSelection(originalSelectionState.absoluteStart, originalSelectionState.absoluteStart);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after deletion by word", SelManager.textFlow.textLength == flowLength - wordLength);

			// After undo, selection returns to original state
			checkUndo(originalSelectionState.absoluteStart, originalSelectionState.absoluteEnd);
		//	checkUndo(initialSelection, initialSelection + wordLength);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after undo of deletion by word", SelManager.textFlow.textLength == flowLength);

			// After redo, caret selection should be restored to original state
			checkRedo(originalSelectionState.absoluteStart, originalSelectionState.absoluteStart);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after redo of deletion by word", SelManager.textFlow.textLength == flowLength - wordLength);
		}

		/*public function deleteNextPage():void
		{
			TestData.fileName = "severalPages.xml";
			readTestFile(TestData.fileName);
			var textRange:TextRange = new TextRange(SelManager.textFlow, 100, 200);
			var aa:Boolean = NavigationUtil.nextPage(textRange);

		}*/

		public function deleteNextPageTest():void
		{
			var onePageRange:TextRange = new TextRange(SelManager.textFlow, 1, 5000);
			var aa:Boolean = NavigationUtil.nextPage(onePageRange);
			deletePreviousWordFromRange(5000, 10000);
		}

		public function deletePreviousPageTest():void
		{
			var onePageRange:TextRange = new TextRange(SelManager.textFlow, 5000, 10000);
			var aa:Boolean = NavigationUtil.nextPage(onePageRange);
			deletePreviousWordFromRange(1, 5000);
		}

		public function deletePreviousWordTest():void
		{
			deletePreviousWordFromCaret(10);
			deletePreviousWordFromRange(347, 652);
			// need case for start of paragraph - deletes previous newline
		}

		public function deletePreviousWordFromCaret(initialSelection:int):void
		{
			var flowLength:int = SelManager.textFlow.textLength;

			SelManager.selectRange(initialSelection, initialSelection);
			SelManager.selectRange(SelManager.activePosition, SelManager.activePosition);
			var wordSelState:SelectionState = SelManager.getSelectionState();
			NavigationUtil.previousWord(wordSelState,true);
			var wordLength:int = wordSelState.absoluteEnd - wordSelState.absoluteStart;

			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelection, initialSelection);
			var originalSelectionState:SelectionState = SelManager.getSelectionState();

			(SelManager as IEditManager).deletePreviousWord();
			checkExpectedSelection(initialSelection - wordLength, initialSelection - wordLength);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after deletion by word", SelManager.textFlow.textLength == flowLength - wordLength);

			// After undo, selection returns to original state
			checkUndo(originalSelectionState.absoluteStart, originalSelectionState.absoluteEnd);
		//	checkUndo(initialSelection, initialSelection + wordLength);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after undo of deletion by word", SelManager.textFlow.textLength == flowLength);

			// After redo, caret selection should be restored to original state
			checkRedo(initialSelection - wordLength, initialSelection - wordLength);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after redo of deletion by word", SelManager.textFlow.textLength == flowLength - wordLength);
		}

		public function deletePreviousWordFromRange(anchorPosition:int, activePosition:int):void
		{
			var flowLength:int = SelManager.textFlow.textLength;

			SelManager.selectRange(anchorPosition, activePosition);
			SelManager.selectRange(SelManager.absoluteStart, SelManager.absoluteStart);
			var wordSelState:SelectionState = SelManager.getSelectionState();
			NavigationUtil.previousWord(wordSelState,true);
			var wordLength:int = wordSelState.absoluteEnd - wordSelState.absoluteStart;

			// Try a range selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(anchorPosition, activePosition);
			var originalSelectionState:SelectionState = SelManager.getSelectionState();
			(SelManager as IEditManager).deletePreviousWord();
			checkExpectedSelection(originalSelectionState.absoluteStart - wordLength, originalSelectionState.absoluteStart - wordLength);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after deletion by word", SelManager.textFlow.textLength == flowLength - wordLength);

			// After undo, selection returns to original state
			checkUndo(originalSelectionState.absoluteStart, originalSelectionState.absoluteEnd);
		//	checkUndo(initialSelection, initialSelection + wordLength);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after undo of deletion by word", SelManager.textFlow.textLength == flowLength);

			// After redo, caret selection should be restored to original state
			checkRedo(originalSelectionState.absoluteStart - wordLength, originalSelectionState.absoluteStart - wordLength);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after redo of deletion by word", SelManager.textFlow.textLength == flowLength - wordLength);
		}

		/** Test forward delete from a caret position */
		public function deleteNextCharacterTest():void
		{
			const initialSelection:int = 10;

			var flowLength:int = SelManager.textFlow.textLength;

			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelection, initialSelection);
			var originalSelectionState:SelectionState = SelManager.getSelectionState();

			var characterSelState:SelectionState = SelManager.getSelectionState();
			NavigationUtil.nextCharacter(characterSelState,true);
			var characterLength:int = characterSelState.absoluteEnd - characterSelState.absoluteStart;
			(SelManager as IEditManager).deleteNextCharacter();
			checkExpectedSelection(initialSelection, initialSelection);
			assertTrue("deleteNextCharacterTest: TextFlow length not as expected after deletion by word", SelManager.textFlow.textLength == flowLength - characterLength);

			// After undo, selection returns to original state
			checkUndo(originalSelectionState.absoluteStart, originalSelectionState.absoluteEnd);
			assertTrue("deleteNextCharacterTest: TextFlow length not as expected after undo of deletion by word", SelManager.textFlow.textLength == flowLength);

			// After redo, caret selection should be restored to original state
			checkRedo(initialSelection, initialSelection);
			assertTrue("deleteNextCharacterTest: TextFlow length not as expected after redo of deletion by word", SelManager.textFlow.textLength == flowLength - characterLength);
		}

		/** Test backspace from a caret position */
		public function deletePreviousCharacterTest():void
		{
			const initialSelection:int = 10;

			var flowLength:int = SelManager.textFlow.textLength;

			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelection, initialSelection);
			var originalSelectionState:SelectionState = SelManager.getSelectionState();

			var characterSelState:SelectionState = SelManager.getSelectionState();
			NavigationUtil.nextCharacter(characterSelState,true);
			var characterLength:int = characterSelState.absoluteEnd - characterSelState.absoluteStart;
			(SelManager as IEditManager).deletePreviousCharacter();
			checkExpectedSelection(initialSelection - characterLength, initialSelection - characterLength);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after deletion by word", SelManager.textFlow.textLength == flowLength - characterLength);

			// After undo, selection returns to original state
			checkUndo(originalSelectionState.absoluteStart, originalSelectionState.absoluteEnd);
		//	checkUndo(initialSelection, initialSelection + characterLength);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after undo of deletion by word", SelManager.textFlow.textLength == flowLength);

			// After redo, caret selection should be restored to original state
			checkRedo(initialSelection - characterLength, initialSelection - characterLength);
			assertTrue("deleteNextWordTest: TextFlow length not as expected after redo of deletion by word", SelManager.textFlow.textLength == flowLength - characterLength);
		}

		public function applyCharacterFormatSelectionTest():void
		{
			const initialSelectionStart:int = 10;
			const initialSelectionEnd:int = 20;

			var characterFormat:TextLayoutFormat = new TextLayoutFormat();
			characterFormat.color = 0xFF0000;

			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelectionStart, initialSelectionEnd);
			(SelManager as IEditManager).applyLeafFormat(characterFormat);
			checkExpectedSelection(initialSelectionStart, initialSelectionEnd);

			// After undo, inserted text should be selected
			checkUndo(initialSelectionStart, initialSelectionEnd);

			// After redo, caret selection should be restored to after the inserted text
			checkRedo(initialSelectionStart, initialSelectionEnd);
		}

		public function applyParagraphFormatSelectionTest():void
		{
			const initialSelectionStart:int = 10;
			const initialSelectionEnd:int = 20;

			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat();
			paragraphFormat.paragraphStartIndent = 15;

			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelectionStart, initialSelectionEnd);
			(SelManager as IEditManager).applyParagraphFormat(paragraphFormat);
			checkExpectedSelection(initialSelectionStart, initialSelectionEnd);

			// After undo, inserted text should be selected
			checkUndo(initialSelectionStart, initialSelectionEnd);

			// After redo, caret selection should be restored to after the inserted text
			checkRedo(initialSelectionStart, initialSelectionEnd);
		}

		public function applyContainerFormatSelectionTest():void
		{
			const initialSelectionStart:int = 10;
			const initialSelectionEnd:int = 20;

			var containerFormat:TextLayoutFormat = new TextLayoutFormat();
			containerFormat.paddingLeft = 15;

			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelectionStart, initialSelectionEnd);
			(SelManager as IEditManager).applyContainerFormat(containerFormat);
			checkExpectedSelection(initialSelectionStart, initialSelectionEnd);

			// After undo, inserted text should be selected
			checkUndo(initialSelectionStart, initialSelectionEnd);

			// After redo, caret selection should be restored to after the inserted text
			checkRedo(initialSelectionStart, initialSelectionEnd);
		}

		public function applyLinkSelectionTest():void
		{
			const initialSelectionStart:int = 10;
			const initialSelectionEnd:int = 20;


			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelectionStart, initialSelectionEnd);
			(SelManager as IEditManager).applyLink("http://www.cnn.com");
			checkExpectedSelection(initialSelectionStart, initialSelectionEnd);

			// After undo, inserted text should be selected
			checkUndo(initialSelectionStart, initialSelectionEnd);

			// After redo, caret selection should be restored to after the inserted text
			checkRedo(initialSelectionStart, initialSelectionEnd);
		}

		public function applyTCYSelectionTest():void
		{
			const initialSelectionStart:int = 10;
			const initialSelectionEnd:int = 20;


			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelectionStart, initialSelectionEnd);
			(SelManager as IEditManager).applyTCY(true);
			checkExpectedSelection(initialSelectionStart, initialSelectionEnd);

			// After undo, inserted text should be selected
			checkUndo(initialSelectionStart, initialSelectionEnd);

			// After redo, caret selection should be restored to after the inserted text
			checkRedo(initialSelectionStart, initialSelectionEnd);
		}

		public function insertInlineGraphicSelectionTest():void
		{
			const initialSelectionPosition:int = 10;


			// Try a caret selection. After do, selection should be a caret point following the inserted text
			SelManager.selectRange(initialSelectionPosition, initialSelectionPosition);
			(SelManager as IEditManager).insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/surprised.png"), Number(10), Number(10));
			checkExpectedSelection(initialSelectionPosition + 1, initialSelectionPosition + 1);

			// After undo, inserted text should be selected
			checkUndo(initialSelectionPosition, initialSelectionPosition);

			// After redo, caret selection should be restored to after the inserted text
			checkRedo(initialSelectionPosition + 1, initialSelectionPosition + 1);
		}


		public function copyAndPasteSelectionTest():void
		{
			const copyStart:int = 10;
			const copyEnd:int = 14;
			const pastePosition:int = 20;
			var pasteLength:int = copyEnd - copyStart;

			SelManager.selectRange(copyStart, copyEnd);

			var scrap:TextScrap = TextScrap.createTextScrap(SelManager.getSelectionState());

			var flowLength:int = SelManager.textFlow.textLength;

			var markup:XML = new XML(TextClipboard.exportForClipboard(scrap, TextConverter.TEXT_LAYOUT_FORMAT));
			assertTrue("Get the expected string from clipboard", markup..*::p..*::span == TextClipboard.exportForClipboard(scrap, TextConverter.PLAIN_TEXT_FORMAT));

			SelManager.selectRange(pastePosition, pastePosition);

			(SelManager as IEditManager).pasteTextScrap(scrap);
			checkExpectedSelection(pastePosition + pasteLength, pastePosition + pasteLength);

			var resultString:String = TestFrame.textFlow.getCharAtPosition(20) + TestFrame.textFlow.getCharAtPosition(21) +
							TestFrame.textFlow.getCharAtPosition(22) + TestFrame.textFlow.getCharAtPosition(23);
			assertTrue("Paste the exact string from clipboard", resultString == TextClipboard.exportForClipboard(scrap, TextConverter.PLAIN_TEXT_FORMAT));

			assertTrue("Paste found unexpected textFlow length, was expecting " + flowLength + pasteLength + " actual " + SelManager.textFlow.textLength,
				SelManager.textFlow.textLength == flowLength + pasteLength );

			checkUndo(pastePosition, pastePosition);
			assertTrue("Paste undo, textFlow not set back to original size ", SelManager.textFlow.textLength == flowLength);

			checkRedo(pastePosition + pasteLength, pastePosition + pasteLength);
			assertTrue("Paste redo, textFlow not set back to pasted size ", SelManager.textFlow.textLength == flowLength + pasteLength);
			
			if (Configuration.playerEnablesArgoFeatures)
				System["disposeXML"](markup);
		}
		
		public function textScrapCloneTest():void
		{
			const copyStart:int = 10;
			const copyEnd:int = 14;
			const pastePosition:int = 20;
			var pasteLength:int = copyEnd - copyStart;
			
			SelManager.selectRange(copyStart, copyEnd);
			
			var scrap:TextScrap = TextScrap.createTextScrap(SelManager.getSelectionState());
			var scrap_clone:TextScrap = scrap.clone();
			
			var flowLength:int = SelManager.textFlow.textLength;
			
			var markup:XML = new XML(TextClipboard.exportForClipboard(scrap_clone, TextConverter.TEXT_LAYOUT_FORMAT));
			assertTrue("Get the expected string from clipboard", markup..*::p..*::span == TextClipboard.exportForClipboard(scrap, TextConverter.PLAIN_TEXT_FORMAT));
			
			SelManager.selectRange(pastePosition, pastePosition);
			
			(SelManager as IEditManager).pasteTextScrap(scrap_clone);
			checkExpectedSelection(pastePosition + pasteLength, pastePosition + pasteLength);
			
			var resultString:String = TestFrame.textFlow.getCharAtPosition(20) + TestFrame.textFlow.getCharAtPosition(21) +
				TestFrame.textFlow.getCharAtPosition(22) + TestFrame.textFlow.getCharAtPosition(23);
			assertTrue("Paste the exact string from clipboard", resultString == TextClipboard.exportForClipboard(scrap, TextConverter.PLAIN_TEXT_FORMAT));
			
			assertTrue("Paste found unexpected textFlow length, was expecting " + flowLength + pasteLength + " actual " + SelManager.textFlow.textLength,
				SelManager.textFlow.textLength == flowLength + pasteLength );
		}

		public function cutAndPasteSelectionTest():void
		{
			cutAndPasteSelectionCaret();
			cutAndPasteSelectionRange();
		}

		public function cutAndPasteSelectionCaret():void
		{
			const cutStart:int = 10;
			const cutEnd:int = 20;
			const pastePosition:int = 10;
			var pasteLength:int = cutEnd - cutStart;

			// Paste into a point selection
			SelManager.selectRange(cutStart, cutEnd);
			var scrap:TextScrap = SelManager.cutTextScrap();

			var flowLength:int = SelManager.textFlow.textLength;
			SelManager.selectRange(pastePosition, pastePosition);
			(SelManager as IEditManager).pasteTextScrap(scrap);
			checkExpectedSelection(pastePosition + pasteLength, pastePosition + pasteLength);
			assertTrue("Paste found unexpected textFlow length, was expecting " + flowLength + pasteLength + " actual " + SelManager.textFlow.textLength,
				SelManager.textFlow.textLength == flowLength + pasteLength);

			checkUndo(pastePosition, pastePosition);
			assertTrue("Paste undo, textFlow not set back to original size ", SelManager.textFlow.textLength == flowLength);

			checkRedo(pastePosition + pasteLength, pastePosition + pasteLength);
			assertTrue("Paste redo, textFlow not set back to pasted size ", SelManager.textFlow.textLength == flowLength + pasteLength);
		}

		public function cutAndPasteSelectionRange():void
		{
			const cutStart:int = 10;
			const cutEnd:int = 20;
			const pastePosition:int = 10;
			var pasteLength:int = cutEnd - cutStart;

			// Paste into a point selection
			SelManager.selectRange(cutStart, cutEnd);
			var scrap:TextScrap = SelManager.cutTextScrap();

			var flowLength:int = SelManager.textFlow.textLength;
			const amtToDelete:int = 10;
			SelManager.selectRange(pastePosition, pastePosition + amtToDelete);
			(SelManager as IEditManager).pasteTextScrap(scrap);
			checkExpectedSelection(pastePosition + pasteLength, pastePosition + pasteLength);
			assertTrue("Paste found unexpected textFlow length, was expecting " + (flowLength + pasteLength - amtToDelete).toString + " actual " + SelManager.textFlow.textLength,
				SelManager.textFlow.textLength == flowLength + pasteLength - amtToDelete);

			checkUndo(pastePosition, pastePosition + amtToDelete);
			assertTrue("Paste undo, textFlow not set back to original size ", SelManager.textFlow.textLength == flowLength);

			checkRedo(pastePosition + pasteLength, pastePosition + pasteLength);
			assertTrue("Paste redo, textFlow not set back to pasted size ", SelManager.textFlow.textLength == flowLength + pasteLength - amtToDelete);
		}

		public function limitPasteTest(callback:Object = null):void
		{
			const pastePosition:int = 10;
			const maxFlowLength:int = 10552;

  			if(!callback)
  			{
		 		callback = true;
				const cutStart:int = 10;
				const cutEnd:int = 20;
				var pasteLength:int = cutEnd - cutStart;

				// Paste into a point selection
				SelManager.selectRange(cutStart, cutEnd);
				var scrap:TextScrap = SelManager.cutTextScrap();

			 	SelManager.textFlow.addEventListener(FlowOperationEvent.FLOW_OPERATION_END,limitPasteTest,false,0,true);

				var flowLength:int = SelManager.textFlow.textLength;
				SelManager.selectRange(pastePosition, pastePosition);
				(SelManager as IEditManager).pasteTextScrap(scrap);
				var afterDoLength:int = SelManager.textFlow.textLength;
				assertTrue("pasted too much", SelManager.textFlow.textLength <= maxFlowLength);
				(SelManager as IEditManager).undo();
				assertTrue("unexpected text Length after undo, was expecting " + flowLength.toString() + "got " + SelManager.textFlow.textLength.toString(), SelManager.textFlow.textLength == flowLength);
				(SelManager as IEditManager).redo();
				assertTrue("unexpected text length after redo", SelManager.textFlow.textLength == afterDoLength);
  			}
  			else
  			{
			 	SelManager.textFlow.removeEventListener(FlowOperationEvent.FLOW_OPERATION_END,limitPasteTest);
  				var operation:PasteOperation = (callback is FlowOperationEvent) ? FlowOperationEvent(callback).operation as PasteOperation : null;
  				if (operation && SelManager.textFlow.textLength > maxFlowLength)
  				{
  					var trimAmt:int = SelManager.textFlow.textLength - maxFlowLength;
  					var pasteEnd:int = pastePosition + (operation.absoluteEnd - operation.absoluteStart);
					SelManager.selectRange(pasteEnd - trimAmt, pasteEnd);
  					(SelManager as IEditManager).deleteNextCharacter();
  				}
  			}
		}

		public function deleteNextCharExceptionTest(callback:Object = null):void
		{
			var gotException:Boolean = false;

			const pastePosition:int = 10;

  			if(!callback)
  			{
		 		callback = true;
				const cutStart:int = 10;
				const cutEnd:int = 20;
				var pasteLength:int = cutEnd - cutStart;

				// Paste into a point selection
				SelManager.selectRange(cutStart, cutEnd);
				var scrap:TextScrap = SelManager.cutTextScrap();

			 	SelManager.textFlow.addEventListener(FlowOperationEvent.FLOW_OPERATION_END,deleteNextCharExceptionTest,false,0,true);

				var flowLength:int = SelManager.textFlow.textLength;
				SelManager.selectRange(pastePosition, pastePosition);
				(SelManager as IEditManager).pasteTextScrap(scrap);
  			}
  			else
  			{
			 	SelManager.textFlow.removeEventListener(FlowOperationEvent.FLOW_OPERATION_END,deleteNextCharExceptionTest);
  				var operation:PasteOperation = (callback is FlowOperationEvent) ? FlowOperationEvent(callback).operation as PasteOperation : null;
  				if (operation)
  				{
  					try
  					{
  						(SelManager as IEditManager).deleteNextCharacter();
  					}
  					catch (e:Error)
  					{
						// EditManager used to remap the error when deleteNextCharacter was working on an INVALID TextBlock
						// This was silly - there's lots of other conditiosn this can happen - deleteNextWord etc.
						// Changed so that the error just goes through.  Besides the "remapped" error doesn't really help users now does it.
  						gotException = e is IllegalOperationError;
  					}
  					finally
  					{
						// While fix bug#2835316 also fix this bug, so now there should no exception. So change this case
  						assertTrue("Expected special exception for deleting from a caret selection on damaged text", gotException == false);
  					}
  				}
  			}
		}

		public function cancelSplitParagraphTest(callback:Object = null):void
		{
  			if(!callback)
  			{
		 		callback = true;

			 	SelManager.textFlow.addEventListener(FlowOperationEvent.FLOW_OPERATION_BEGIN,cancelSplitParagraphTest,false,0,true);

				// Paste into a point selection
				SelManager.selectRange(0, 0);
				(SelManager as IEditManager).insertText("h");
				(SelManager as IEditManager).insertText("e");
				(SelManager as IEditManager).insertText("l");
				(SelManager as IEditManager).insertText("l");
				(SelManager as IEditManager).insertText("o");
				(SelManager as IEditManager).splitParagraph();
  			}
  			else
  			{
  				var operation:SplitParagraphOperation = (callback is FlowOperationEvent) ? FlowOperationEvent(callback).operation as SplitParagraphOperation : null;
  				if (operation && operation.absoluteStart == 0)
  				{
			 		SelManager.textFlow.removeEventListener(FlowOperationEvent.FLOW_OPERATION_BEGIN,cancelSplitParagraphTest);
  					FlowOperationEvent(callback).preventDefault();
  					SelManager.selectRange(0, 0);
  				}
  			}
		}

		public function cancelCopyOperationTest(callback:Object = null):void
		{
			var cancelCalled:Boolean = false;
			function cancelCopyOperation(e:FlowOperationEvent):void
			{ e.preventDefault(); cancelCalled = true; }

			SelManager.textFlow.addEventListener(FlowOperationEvent.FLOW_OPERATION_BEGIN,cancelCopyOperation);
			SelManager.editHandler(new Event(Event.COPY));
			assertTrue("cancelCopyOperationTest expect cancel to be called",cancelCalled);
		}

		public function compositeOperationTest():void
		{
			var editManager:IEditManager = SelManager as IEditManager;
			var insertPos:int = 15;
			var insertText:String = "Hello There";
			var insertSize:Number = 48;
			var originalSize:Number = Number(SelManager.textFlow.findLeaf(insertPos).computedFormat.fontSize);
			var flowLength:int = SelManager.textFlow.textLength;

			editManager.beginCompositeOperation();
			SelManager.selectRange(insertPos, insertPos);
			editManager.insertText(insertText);
			SelManager.selectRange(insertPos, insertPos + insertText.length);
			var charFormat:TextLayoutFormat = new TextLayoutFormat();
			charFormat.fontSize = insertSize;
			editManager.applyFormat(charFormat,null,null);
			editManager.endCompositeOperation();
			assertTrue("Point size not as expected", Number(SelManager.textFlow.findLeaf(insertPos).computedFormat.fontSize) == insertSize);
			assertTrue("TextFlow length not as expected", SelManager.textFlow.textLength == flowLength + insertText.length);

			// State after a single undo should be back to original at start of function
			editManager.undo();
			assertTrue("Point size not as expected", Number(SelManager.textFlow.findLeaf(insertPos).computedFormat.fontSize) == originalSize);
			assertTrue("TextFlow length not as expected", SelManager.textFlow.textLength == flowLength);

			// State after a single redo should be back to after operation done
			editManager.redo();
			assertTrue("Point size not as expected", Number(SelManager.textFlow.findLeaf(insertPos).computedFormat.fontSize) == insertSize);
			assertTrue("TextFlow length not as expected", SelManager.textFlow.textLength == flowLength + insertText.length);
		}

		// Compare the selected text to the keystring, and assert if they are different
		private function checkSelectedText(keyString:String):void
		{
			var leaf:FlowLeafElement = SelManager.textFlow.findLeaf(SelManager.absoluteStart);
			var compareString:String = leaf.text.substr(SelManager.absoluteStart - leaf.getAbsoluteStart(), keyString.length);
			assertTrue ("Selected text doesn't match expected", compareString == keyString);

		}
		// Test operations that don't apply to the selection, and make sure selection is maintained across the operations
		public function programmaticOperationTest():void
		{
			var editManager:IEditManager = SelManager as IEditManager;

			// Test selection after the change
			const initialSelectionStart:int = 100;
			var keyString:String = "Hello there";

			// Insert text with no selection
			editManager.insertText(keyString, new SelectionState(editManager.textFlow, initialSelectionStart, initialSelectionStart));
			editManager.flushPendingOperations();
			// Set the selection to the text we just inserted
			SelManager.selectRange(initialSelectionStart, initialSelectionStart + keyString.length);
			checkSelectedText(keyString);

			// Insert a string right before
			editManager.insertText("ABC", new SelectionState(editManager.textFlow, initialSelectionStart, initialSelectionStart));
			editManager.flushPendingOperations();
			checkSelectedText(keyString);
			// Delete a string right before
			editManager.deleteNextCharacter(new SelectionState(editManager.textFlow, initialSelectionStart, initialSelectionStart + 3));
			checkSelectedText(keyString);

			// Insert a string right after
			editManager.insertText("ABC", new SelectionState(editManager.textFlow, initialSelectionStart + keyString.length, initialSelectionStart + keyString.length));
			editManager.flushPendingOperations();
			checkSelectedText(keyString);
			// Delete a string right after
			editManager.deleteNextCharacter(new SelectionState(editManager.textFlow, initialSelectionStart + keyString.length, initialSelectionStart + keyString.length + 3));
			checkSelectedText(keyString);

		}

		public function deleteLastSpanTest():void
		{
  			var indx:int = 50;

  			var width:int = 20;
  			var height:int = 20;
  			SelManager.selectRange(indx, indx);
  			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/smiling.png"),width,height);

  			var origFlowLength:int = SelManager.textFlow.textLength;


			var amtToDelete:int = SelManager.textFlow.textLength - (indx + 1) - 1;	// Carriage return at the end not deleted
			SelManager.selectRange(indx + 1, SelManager.textFlow.textLength);
			(SelManager as EditManager).deleteNextCharacter();

			assertTrue("Unexpected length after delete", SelManager.textFlow.textLength == origFlowLength - amtToDelete);

			(SelManager as EditManager).undo();

			assertTrue("Unexpected length after undo delete", SelManager.textFlow.textLength == origFlowLength);

			(SelManager as EditManager).redo();

			assertTrue("Unexpected length after redo delete", SelManager.textFlow.textLength == origFlowLength - amtToDelete);
		}

		public function mergeEventMirrorTest( e:Event = null ):void
		{
			if ( e != null )
				return;

			SelManager.selectAll();
			SelManager.deleteText();

			var p:ParagraphElement = new ParagraphElement();

			var span1:SpanElement = new SpanElement();
			span1.text = "A";

			var span2:SpanElement = new SpanElement();
			span2.text = "B";

			// This should cause the spans not to merge - Event.FULLSCREEN was chosen at random
			// It is not enough to have a single mirror - both span elements need to
			// have active mirrors
			span1.getEventMirror().addEventListener( Event.FULLSCREEN, mergeEventMirrorTest );
			span2.getEventMirror().addEventListener( Event.FULLSCREEN, mergeEventMirrorTest );

			p.addChild(span1);
			p.addChild(span2);

			TestFrame.textFlow.addChild(p);
			TestFrame.textFlow.flowComposer.updateAllControllers();

			assertTrue( "Spans should not merge if an active event listener is attached to both", p.numChildren == 2 );

			span1.getEventMirror().removeEventListener( Event.FULLSCREEN, mergeEventMirrorTest );
			span2.getEventMirror().removeEventListener( Event.FULLSCREEN, mergeEventMirrorTest );
			TestFrame.textFlow.flowComposer.updateAllControllers();
		}

		public function applyLeafFormatTest():void
		{
			// Applying a leaf format to an empty paragraph should apply immediately to the paragraph
			var textFlow:TextFlow = SelManager.textFlow;
			SelManager.selectRange(textFlow.textLength - 1, textFlow.textLength - 1);
			SelManager.splitParagraph();
			SelManager.selectRange(textFlow.textLength - 1, textFlow.textLength - 1);
			var newSize:int = textFlow.getLastLeaf().computedFormat.fontSize + 10;
			var leafFormat:TextLayoutFormat = new TextLayoutFormat();
			leafFormat.fontSize = newSize;
			SelManager.applyLeafFormat(leafFormat);
			assertTrue("Expected point size change to be applied immediately to empty paragraph", textFlow.getLastLeaf().computedFormat.fontSize == newSize);
			
			// Applying a leaf format to a paragraph with content should not change the paragraph, 
			// but should change the pointFormat.
			SelManager.selectRange(0, 0);
			var originalSize:int = textFlow.getFirstLeaf().computedFormat.fontSize;
			newSize = originalSize + 10;
			leafFormat = new TextLayoutFormat();
			leafFormat.fontSize = newSize;
			SelManager.applyLeafFormat(leafFormat);
			assertTrue("Expected point size change to be delayed", textFlow.getFirstLeaf().computedFormat.fontSize == originalSize);
			SelManager.allowDelayedOperations = false;
			SelManager.insertText("X");
			assertTrue("Expected point size change to be applied to newly inserted text", textFlow.getFirstLeaf().computedFormat.fontSize == newSize);
			
			// Applying a leaf format to a para with content, followed by applying to an empty paragraph, should result in inserted text in the font of the second apply
			// Watson 2791491
			SelManager.selectRange(0, textFlow.textLength - 1);
			SelManager.deleteText();
			leafFormat = new TextLayoutFormat();
			leafFormat.fontFamily = "Courier";
			SelManager.applyLeafFormat(leafFormat);
			SelManager.insertText("A");
			assertTrue("Expected fontFamily change to be applied to newly inserted text", textFlow.getFirstLeaf().computedFormat.fontFamily == "Courier");
			SelManager.selectRange(0, textFlow.textLength - 1);
			SelManager.deleteText();
			leafFormat.fontFamily = "Verdana";
			SelManager.applyLeafFormat(leafFormat);
			SelManager.insertText("B");
			assertTrue("Expected fontFamily change to be applied to newly inserted text", textFlow.getFirstLeaf().computedFormat.fontFamily == "Verdana");
			
		}
		
		public function undoApplyFormatToElementTest():void
		{
			// Test for scenario in Watson bug# 2315405
			var textFlow:TextFlow = SelManager.textFlow;
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.color = 0xff; // character category
			format.leadingModel = LeadingModel.ASCENT_DESCENT_UP; // paragraph category
			format.columnCount = 2; // container category

			var beforeFormat:ITextLayoutFormat = textFlow.format ? textFlow.format : TextLayoutFormat.emptyTextLayoutFormat;

			SelManager.applyFormatToElement(textFlow, format);

			assertTrue( "applyFormatToElement did not work", textFlow.color == format.color);
			assertTrue( "applyFormatToElement did not work", textFlow.leadingModel == format.leadingModel);
			assertTrue( "applyFormatToElement did not work", textFlow.columnCount == format.columnCount);

			SelManager.undo();

			assertTrue( "undo applyFormatToElement did not work", textFlow.color === beforeFormat.color);
			assertTrue( "undo applyFormatToElement did not work", textFlow.leadingModel === beforeFormat.leadingModel);
			assertTrue( "undo applyFormatToElement did not work", textFlow.columnCount === beforeFormat.columnCount);

		}

		// Test for scenario in Watson bug# 2366728
		public function applyFormatToElementTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var format1:TextLayoutFormat = new TextLayoutFormat();
			format1.color = 0xff;
			format1.fontSize = 30;
			var elem1:FlowElement = SelManager.textFlow.findLeaf(1);

			SelManager.applyFormatToElement(elem1, format1);

			var elem2:FlowElement = SelManager.textFlow.findLeaf(30);
			var format2:TextLayoutFormat = new TextLayoutFormat();
			format2.color = elem2.color;
			format2.fontSize = elem2.fontSize;

			assertTrue("applyFormatToElement ignores targetElements and applies changes to the TextFlow. ",
			            format1.color != format2.color && format1.fontSize != format2.fontSize );

		}

		public function clearFormatOnElementTest():void
		{
			var format1:TextLayoutFormat = new TextLayoutFormat();
			format1.color = 0xff;
			format1.fontSize = 30;
			var para:FlowElement = SelManager.textFlow.getFirstLeaf().getParagraph();

			SelManager.applyFormatToElement(para, format1);

			assertTrue("clearFormatOnElementTest failed to apply formats. ",
				para.color == format1.color && para.fontSize == format1.fontSize );

			// now lets undefine them
			SelManager.clearFormatOnElement(para,format1);

			assertTrue("clearFormatOnElementTest failed to undefine formats. ",
				para.color === undefined && para.fontSize === undefined );
		}

		private function changeOperationTestEventListener(event:FlowOperationEvent):void
		{
			event.operation.textFlow.removeEventListener(FlowOperationEvent.FLOW_OPERATION_BEGIN,changeOperationTestEventListener);
			event.operation = new DeleteTextOperation(SelManager.getSelectionState());
		}

		/** Change the operation in the flowOperationBegin event handler */
		public function changeOperationTest():void
		{
			SelManager.selectAll();
			SelManager.textFlow.addEventListener(FlowOperationEvent.FLOW_OPERATION_BEGIN,changeOperationTestEventListener);
			// start out changing the fontSize
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.fontSize = 88;
			SelManager.applyLeafFormat(format);

			assertTrue("changeOperationTest failed to delete text.", SelManager.textFlow.textLength == 1);
		}

		public function pendingFlushTest():void
		{
			SelManager.selectRange(0,0);
			var beforeLen:int = SelManager.textFlow.textLength;
			SelManager.insertText("XYZ ");
			SelManager.deletePreviousWord();
			SelManager.flushPendingOperations();
			var afterLen:int = SelManager.textFlow.textLength;
			assertTrue("pending operation wasn't flushed before deletePreviousWord", beforeLen == afterLen);

			// textflow should just have XYZ after this
			SelManager.selectRange(0,0);
			var operationState:SelectionState = new SelectionState(SelManager.textFlow,0,SelManager.textFlow.textLength-1);
			SelManager.insertText("XYZ");
			SelManager.deleteText(operationState);

			var para:ParagraphElement = SelManager.textFlow.getFirstLeaf().getParagraph();
			var paraText:String = para.getText(0,-1,"");

			assertTrue("Incorrect textFlow in pendingFlushTest",SelManager.textFlow.textLength == 4 && paraText == "XYZ");
		}

		private var eventCount:int;
		private var expectedEvents:Array;

		// verifies that events are recieved in the order expected
		private function catchEvent(e:Event):void
		{
			var expected:Object = expectedEvents[eventCount++];
			assertTrue("Unexpected event caught",e.type);
			assertTrue("Unexecpted event type",e.type == expected.name);
			if (e is FlowOperationEvent)
			{
				assertTrue("Unexpected level",FlowOperationEvent(e).level == expected.level);
				var className:String = flash.utils.getQualifiedClassName(FlowOperationEvent(e).operation);
				var baseClassName:String = className.substr(className.lastIndexOf(":")+1);
				assertTrue("Unexpected operation class name",baseClassName == expected.operation);
			}
		}

		public function compositeOperationEventTest():void
		{
			eventCount = 0;

			// events in order they are expected
			expectedEvents = [
				{name:"flowOperationBegin",level:0,operation:"CompositeOperation"},
				{name:"flowOperationBegin",level:1,operation:"CompositeOperation"},
				{name:"flowOperationBegin",level:2,operation:"InsertTextOperation"},
				{name:"flowOperationEnd",level:2,operation:"InsertTextOperation"},
				{name:"flowOperationBegin",level:2,operation:"InsertTextOperation"},
				{name:"flowOperationEnd",level:2,operation:"InsertTextOperation"},
				{name:"flowOperationEnd",level:1,operation:"CompositeOperation"},
				{name:"flowOperationBegin",level:1,operation:"ApplyFormatOperation"},
				{name:"flowOperationEnd",level:1,operation:"ApplyFormatOperation"},
				{name:"flowOperationEnd",level:0,operation:"CompositeOperation"},
				{name:"compositionComplete"},
				{name:"updateComplete"},
				{name:"flowOperationComplete",level:0,operation:"CompositeOperation"} ];

			var eventsToCatch:Array = [
				FlowOperationEvent.FLOW_OPERATION_BEGIN,
				FlowOperationEvent.FLOW_OPERATION_END,
				FlowOperationEvent.FLOW_OPERATION_COMPLETE,
				CompositionCompleteEvent.COMPOSITION_COMPLETE,
				UpdateCompleteEvent.UPDATE_COMPLETE
				];

			var textFlow:TextFlow = SelManager.textFlow;
			var eventName:String;

			for each(eventName in eventsToCatch)
				textFlow.addEventListener(eventName,catchEvent);

			SelManager.beginCompositeOperation();

			SelManager.beginCompositeOperation();
			SelManager.selectRange(int.MAX_VALUE, int.MAX_VALUE);
			SelManager.insertText(" wor");
			SelManager.insertText("ld");
			SelManager.endCompositeOperation();

			SelManager.selectAll();
			var newLeafFormat:TextLayoutFormat = new TextLayoutFormat();
			newLeafFormat.color = 0xff;
			SelManager.applyFormat(newLeafFormat,null,null);

			SelManager.endCompositeOperation();
			assertTrue("Events missing",eventCount == expectedEvents.length);

			for each(eventName in eventsToCatch)
				textFlow.removeEventListener(eventName,catchEvent);
		}
		
		public function delayedRedrawTest():void
			// Test EditManager.delayUpdates flag. When set, calls on the EditManager should update the model,
			// but not recompose or update the view. When clear, calls on the EditManager should synchronously
			// recompose and update.
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var editManager:EditManager = textFlow.interactionManager as EditManager;
			var container:Sprite = SelManager.textFlow.flowComposer.getControllerAt(0).container;
			var originalRedrawSetting:Boolean = editManager.delayUpdates;
			try 
			{
				// Turn delayUpdates on, make a change. The model should be updated, but the text
				// should not be recomposed and the container display list should not be touched.
				editManager.delayUpdates = true;
				SelManager.selectRange(0, int.MAX_VALUE);
				flowComposer.updateAllControllers();	// force lines to be generated
				EditManager(SelManager).deleteText();
				assertTrue("textFlow deletion not done?", textFlow.textLength <= 1);
				assertTrue("textFlow composition wasn't delayed?", flowComposer.getLineAt(0).validity == TextLineValidity.INVALID);
				assertTrue("textFlow update wasn't delayed?", container.numChildren > 2);
				
				// Force an update. After this, text should be recomposed, and display list updated.
				EditManager(SelManager).updateAllControllers();
				assertTrue("textFlow composition wasn't delayed?", flowComposer.numLines <= 1);
				assertTrue("textFlow update wasn't delayed?", container.numChildren == 2);	// one for selection shape, one for empty line
				
				// Turn delayUpdates off, then undo. The model should be updated, the text should be
				// recomposed and the container should be updated.
				editManager.delayUpdates = false;
				EditManager(SelManager).undo();
				assertTrue("textFlow undo of deletion not done?", textFlow.textLength > 1);
				assertTrue("textFlow composition was delayed after undo?", flowComposer.numLines > 1);
				assertTrue("textFlow composition was delayed?", flowComposer.getLineAt(0).validity == TextLineValidity.VALID);
				assertTrue("textFlow update was delayed after undo?", container.numChildren > 2);
				
				// Turn delayUpdates on, then edit, then switch to read-only mode. Watson 2765114
				editManager.delayUpdates = true;
				editManager.selectRange(0, 0);
				editManager.insertText("hello there");
			
				// 2793943 - delayUpdates on TextFlow with no controllers
				var textFlowNoController:TextFlow = textFlow.deepCopy() as TextFlow;
				var emNoController:EditManager = new EditManager();
				textFlowNoController.interactionManager = emNoController;
				emNoController.allowDelayedOperations = false;
				emNoController.delayUpdates = true;
				emNoController.selectRange(0, 0);
				emNoController.insertText("hello");
				textFlowNoController.flowComposer.updateAllControllers();
								
				// test for 
				var extraEditmanager:EditManager = new EditManager();
				var testEditManager:EditManager = new EditManager();
				assertTrue("EditManager delayUpdates by default should be false", testEditManager.delayUpdates == false);
				testEditManager.delayUpdates = true;
				assertTrue("EditManager delayUpdates by default should be false", extraEditmanager.delayUpdates == false);
				
				textFlow.interactionManager = new SelectionManager();
				SelManager = null; 		// avoid tearDown assert for inactive SelectionManager
			}
			finally
			{
				editManager.delayUpdates = originalRedrawSetting;
			}
		}
		
		public function delayUpdateNoFlowComposer(callBack:Object = null):void // 2785924
		{
			if (!callBack)
			{
				// test for 2785924
				var textFlow:TextFlow = TextConverter.importToFlow("Hello world", TextConverter.PLAIN_TEXT_FORMAT);
				textFlow.flowComposer.addController(new ContainerController(new Sprite(), 200, 300)); 
				var editManager:EditManager = new EditManager();
				editManager.delayUpdates = true;
				textFlow.interactionManager = editManager;
				textFlow.flowComposer.updateAllControllers();	
				editManager.selectRange(0, textFlow.textLength);
				var leafFormat:TextLayoutFormat = new TextLayoutFormat();
				leafFormat.fontSize = 60;
				editManager.applyLeafFormat(leafFormat);
				textFlow.flowComposer = null; 
				
				var delay:Boolean = true;
				TestFrame.container.addEventListener(Event.ENTER_FRAME, addAsync(delayUpdateNoFlowComposer,2500,null),false,0,true);
			}
			else
			{
			}
		}
		
		public function allowDelayedOperations():void
		{
			// When delayed operations are turned off, insertion should happen immediately
			SelManager.selectRange(0, 0);
			SelManager.allowDelayedOperations = false;
			var originalTextLength:int = SelManager.textFlow.textLength;
			SelManager.insertText("A");
			assertTrue("Expected immediate insertion", SelManager.textFlow.textLength > originalTextLength);
			
			// When delayed operations are turned on, insertion should NOT happen immediately, but should happen after flush
			SelManager.allowDelayedOperations = true;
			originalTextLength = SelManager.textFlow.textLength;
			SelManager.insertText("A");
			assertTrue("Expected delayed insertion", SelManager.textFlow.textLength == originalTextLength);
			SelManager.flushPendingOperations();
			assertTrue("Expected insertion after flush", SelManager.textFlow.textLength > originalTextLength);
			
			// If an operation is queued up, and allowDelayedOperations is turned off, it should get flushed
			originalTextLength = SelManager.textFlow.textLength;
			SelManager.insertText("A");
			assertTrue("Expected delayed insertion (2)", SelManager.textFlow.textLength == originalTextLength);
			SelManager.allowDelayedOperations = false;
			assertTrue("Expected insertion after allowDelayedOperations turned off", SelManager.textFlow.textLength > originalTextLength);
		}
		
		public function undoApplyParagraphFormat():void
			// Apply a paragraph format to an empty paragraph, and undo. Should get back to the original state. Watson 2629735
		{
			var textFlow:TextFlow = SelManager.textFlow;
			SelManager.selectRange(0, textFlow.textLength);
			SelManager.deleteText();
			SelManager.selectRange(0, 0);
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.paragraphStartIndent = 25;		// give it some initial value so we don't have to check for undefined
			SelManager.applyParagraphFormat(format);
			
			// Save off original value
			var leaf:FlowLeafElement = textFlow.findLeaf(0);
			var para:ParagraphElement = leaf.getParagraph();
			var indent:Number = para.format.paragraphStartIndent;
			
			format = new TextLayoutFormat();
			format.paragraphStartIndent = indent + 25;
			SelManager.applyParagraphFormat(format);
			SelManager.undo();
			
			leaf = textFlow.findLeaf(0);
			para = leaf.getParagraph();
			assertTrue("Expected original value back in paragraph format after undo", para.format.paragraphStartIndent == indent);
		}		
		
		private function undoHelper(markup:String, startPos:int, endPos:int, doFunction:Function, expectedResult:String = null):void
		{
			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			var originalMarkup:String = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			testApp.contentChange(textFlow);
			var editManager:IEditManager = (textFlow.interactionManager as IEditManager);
			textFlow.interactionManager.selectRange(startPos,endPos);
			var selectAnchorPosition:int = textFlow.interactionManager.anchorPosition;
			var selectActivePosition:int = textFlow.interactionManager.activePosition;
			doFunction(textFlow);
			var afterDoMarkup:String = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			var afterDoAnchorPos:int = textFlow.interactionManager.anchorPosition;
			var afterDoActivePos:int = textFlow.interactionManager.activePosition;
			assertTrue("expected undoable operation on the stack", editManager.undoManager.canUndo());
			if (expectedResult)
			{
				if (afterDoMarkup != expectedResult)
				{
					trace(afterDoMarkup);
					trace(expectedResult);
				}
				assertTrue("Actual result after edit doesn't match expected result", afterDoMarkup == expectedResult);
			}
			editManager.undo();
			var afterUndoAnchorPos:int = textFlow.interactionManager.anchorPosition;
			var afterUndoActivePos:int = textFlow.interactionManager.activePosition;
			var afterUndoMarkup:String = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			assertTrue("Didn't get back to original model state after undo", afterUndoMarkup == originalMarkup);
			assertTrue("Didn't return selection to original state after undo", afterUndoAnchorPos == selectAnchorPosition && afterUndoActivePos == selectActivePosition);
			editManager.redo();
			var afterRedoAnchorPos:int = textFlow.interactionManager.anchorPosition;
			var afterRedoActivePos:int = textFlow.interactionManager.activePosition;
			var afterRedoMarkup:String = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			assertTrue("Didn't get back to post-Do model state after redo", afterRedoMarkup == afterDoMarkup);
			assertTrue("Didn't return selection to original state after redo", afterRedoAnchorPos == afterDoAnchorPos && afterRedoActivePos == afterDoActivePos);
		}
		
		public function undoDelete():void
		{
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><list><p><span>para1</span></p><li><p><span>para2</span></p><list><p><span>para3</span></p></list></li></list></TextFlow>',
				5, 6, deleteText);
			undoHelper('<TextFlow columnWidth="150" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><div id="1"><p><span>[1]</span></p><div id="2"><p><span>[2]</span></p><p id="3"><span>[3]</span><a id="4"><span>[4]</span><tcy id="5"><span>[5]</span><g id="6"><span>[6]</span><g id="7"><span>[7]</span><span id="8">[8]</span></g><span id="9">[9]</span></g><span id="10">[10</span></tcy><g id="11"><span>[11</span><tcy id="12"><span>[12</span><span id="13">[13</span></tcy><span id="14">[14</span></g><span id="15">[15</span></a><tcy id="16"><span>[16</span><a id="17"><span>[17</span><span id="18">[18</span></a><span id="19">[19</span></tcy><g id="20"><span>[20</span><a id="21"><span>[21</span><span id="22">[22</span></a><span id="23">[23</span></g><span id="24">[24</span></p><list id="25"><p><span>[25</span></p><div id="26"><p><span>[26</span></p></div><p id="27"><span>[27</span><span id="28">[28</span></p><list id="29"><p><span>[29</span></p><li id="30"><p><span>[30</span></p><div id="31"><p><span>[31</span></p></div><p id="32"><span>[32</span><span id="33">[33</span></p><list id="34"><p><span>[34</span></p></list></li></list></list></div></div><p id="35"><span>[35</span><span id="36">[36</span></p><p><span>[37</span></p></TextFlow>',
				93, 94, deleteText);
			undoHelper('<TextFlow columnWidth="150" paddingLeft="4" paddingTop="4" version="3.0.0" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>BEF</span></p><list listStylePosition="inside" listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><list listStylePosition="inside" listStyleType="decimal" paddingLeft="0" tabStops="e20 s24"><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="&#x9;" fontSize="14"/></listMarkerFormat><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li></list><list listStylePosition="outside" listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list></li></list><p><span>AFT</span></p><p><span></span></p></TextFlow>',
				53, 60, deleteText);
			undoHelper('<TextFlow columnWidth="150" paddingLeft="4" paddingTop="4" version="3.0.0" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>BEF</span></p><list listStylePosition="inside" listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><list listStylePosition="inside" listStyleType="decimal" paddingLeft="0" tabStops="e20 s24"><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="&#x9;" fontSize="14"/></listMarkerFormat><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li></list><list listStylePosition="outside" listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list></li></list><p><span>AFT</span></p><p><span></span></p></TextFlow>',
				60, 61, deleteText);
			undoHelper('<TextFlow columnWidth="150" paddingLeft="4" paddingTop="4" version="3.0.0" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>BEF</span></p><list listStylePosition="inside" listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><list listStylePosition="inside" listStyleType="decimal" paddingLeft="0" tabStops="e20 s24"><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="&#x9;" fontSize="14"/></listMarkerFormat><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li></list><list listStylePosition="outside" listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list></li></list><p><span>AFT</span></p><p><span></span></p></TextFlow>',
				1, 60, deleteText);
			undoHelper('<TextFlow columnWidth="150" paddingLeft="4" paddingTop="4" version="3.0.0" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>BEF</span></p><list listStylePosition="inside" listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><list listStylePosition="inside" listStyleType="decimal" paddingLeft="0" tabStops="e20 s24"><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="&#x9;" fontSize="14"/></listMarkerFormat><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li></list><list listStylePosition="outside" listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list></li></list><p><span>AFT</span></p><p><span></span></p></TextFlow>',
				0, 4, deleteText);
			undoHelper('<TextFlow columnWidth="150" paddingLeft="4" paddingTop="4" version="3.0.0" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>BEF</span></p><list listStylePosition="inside" listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><list listStylePosition="inside" listStyleType="decimal" paddingLeft="0" tabStops="e20 s24"><listMarkerFormat><ListMarkerFormat afterContent="&#x9;" beforeContent="&#x9;" fontSize="14"/></listMarkerFormat><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li><li><p><span>ano</span></p></li></list><list listStylePosition="outside" listStyleType="decimal" paddingLeft="24" paddingRight="24"><li><p><span>ite</span></p></li><li><p><span>ano</span></p></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p><list paddingLeft="12"><li><p><span></span></p></li></list></li></list></li></list><p><span>AFT</span></p><p><span></span></p></TextFlow>',
				8, 12, deleteText);
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="15"><span>The</span><span fontStyle="italic">suc</span><span> li</span></p><p paragraphSpaceAfter="15"><span>The</span></p></TextFlow>',
				1, 9, deleteText);
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="15"><span>The</span><span fontStyle="italic">suc</span><span> li</span></p><p paragraphSpaceAfter="15"><span>The</span></p></TextFlow>',
				1, 9, deleteText);
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" paragraphSpaceAfter="15" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>The</span><a href="http://www.4literature.net/Nathaniel_Hawthorne/Ethan_Brand/" target="_self"><linkActiveFormat><TextLayoutFormat color="#00ff00" textDecoration="underline"/></linkActiveFormat><linkHoverFormat><TextLayoutFormat color="#ff0000"/></linkHoverFormat><linkNormalFormat><TextLayoutFormat color="#0000ff"/></linkNormalFormat><span>Eth</span></a><span> by</span><a href="mailto:nathaniel_hawthorne@famousauthors.com" target="_self"><linkActiveFormat><TextLayoutFormat color="#0000ff" lineThrough="true"/></linkActiveFormat><linkHoverFormat><TextLayoutFormat color="#0000ff"/></linkHoverFormat><span>Nat</span></a><span>.</span></p><p><span>The</span><span fontStyle="italic">suc</span><span> li</span></p><p><span>The</span></p></TextFlow>',
				1, 13, deleteText); 
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><div><p paragraphSpaceAfter="15"><span>The</span><span fontStyle="italic">suc</span><span> li</span></p></div><p paragraphSpaceAfter="15"><span>The</span></p></TextFlow>', 
				1, 10, deleteText);
			undoHelper('<TextFlow fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><div><p paragraphSpaceAfter="15"><span>There are many </span><span fontStyle="italic">such</span><span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.</span></p></div><p paragraphSpaceAfter="15"><span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Within the furnace were seen the curling and riotous flames, and the burning marble, almost molten with the intensity of heat; while without, the reflection of the fire quivered on the dark intricacy of the surrounding forest, and showed in the foreground a bright and ruddy little picture of the hut, the spring beside its door, the athletic and coal-begrimed figure of the lime-burner, and the half-frightened child, shrinking into the protection of his fathers shadow. And when again the iron door was closed, then reappeared the tender light of the half-full moon, which vainly strove to trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, though thus far down into the valley the sunshine had vanished long and long ago.</span></p></TextFlow>', 
				0, 1, deleteText);
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>test</span></p><p><span></span></p></TextFlow>', 0, 5, deleteText);
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>AAA</span></p><div><p><span>BBB</span></p><p><span>CCC</span></p></div><p><span>DDD</span></p></TextFlow>',
				4, 10, deleteText);		// delete partial <div>, starts on <div>, ends partway through 2nd para
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>AAA</span></p><div><p><span>BBB</span></p><p><span>CCC</span></p></div><p><span>DDD</span></p></TextFlow>',
				5, 12, deleteText);		// delete partial <div>, starts partway through 1st para, ends on </div>
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>AAA</span></p><div><p><span>BBB</span></p><p><span>CCC</span></p></div><p><span>DDD</span></p></TextFlow>',
				5, 10, deleteText);		// delete partial <div>, starts partway through 1st para, ends partway through 2nd para
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>AAA</span></p><div><p><span>BBB</span></p><p><span>CCC</span></p></div><p><span>DDD</span></p></TextFlow>',
				4, 12, deleteText);		// delete entire <div>
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="15"><span>The</span><span fontStyle="italic">suc</span><span> li</span></p><p paragraphSpaceAfter="15"><span>The</span></p></TextFlow>',
				1,14, deleteText);
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="15"><span>The</span><span fontStyle="italic">suc</span><span> li</span></p><p paragraphSpaceAfter="15"><span>The</span></p></TextFlow>',
				9, 10, deleteText);
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="15"><span>The</span><span fontStyle="italic">suc</span><span> li</span></p><p paragraphSpaceAfter="15"><span>The</span></p></TextFlow>',
				1, 2, deleteText);
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="15"><span>The</span><span fontStyle="italic">suc</span><span> li</span></p><p paragraphSpaceAfter="15"><span>The</span></p></TextFlow>',
 				10, 14, deleteText);
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="15"><span>The</span><span fontStyle="italic">suc</span><span> li</span></p><p paragraphSpaceAfter="15"><span>The</span></p></TextFlow>',
				0, 14, deleteText); 
			undoHelper('<TextFlow fontFamily="Times New Roman" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ab</span></p><p textAlign="center"><span>cd</span></p></TextFlow>', 
				1, 4, deleteText);	// 2637755
			undoHelper('<TextFlow fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="15"><span>one</span></p><p paragraphSpaceAfter="15"><span>two</span></p><p paragraphSpaceAfter="15"><span>three</span></p><p paragraphSpaceAfter="15"><span>four</span></p><p paragraphSpaceAfter="15"><span></span></p></TextFlow>',
				3, 13, deleteText); // 2593736
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="20"><span>one</span></p><div><p paragraphSpaceAfter="20"><span>two</span></p></div><p paragraphSpaceAfter="20"><span>three</span></p></TextFlow>',
				4, 8, deleteText); // 	2593734
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" paragraphSpaceAfter="15" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>The</span><a href="http://www.4literature.net/Nathaniel_Hawthorne/Ethan_Brand/" target="_self"><linkActiveFormat><TextLayoutFormat color="#00ff00" textDecoration="underline"/></linkActiveFormat><linkHoverFormat><TextLayoutFormat color="#ff0000"/></linkHoverFormat><linkNormalFormat><TextLayoutFormat color="#0000ff"/></linkNormalFormat><span>Eth</span></a><span> by</span><a href="mailto:nathaniel_hawthorne@famousauthors.com" target="_self"><linkActiveFormat><TextLayoutFormat color="#0000ff" lineThrough="true"/></linkActiveFormat><linkHoverFormat><TextLayoutFormat color="#0000ff"/></linkHoverFormat><span>Nat</span></a><span>.</span></p><p><span>The</span><span fontStyle="italic">suc</span><span> li</span></p><p><span>The</span></p></TextFlow>',
				0, 23, deleteText);
			// Test for deleting an entire flow that ends with a list should delete the list - 2662563
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><list listStyleType="disc"><li><p><span>a</span></p></li><list><li><p><span>b</span></p></li></list></list></TextFlow>',
				0, 3, deleteText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span></span></p></TextFlow>');
			// Test for deleting starting from the start of the last element in the flow that ends with a list should delete the list - 2662563
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span></span></p><list listStyleType="disc"><li><p><span>a</span></p></li><list><li><p><span>b</span></p></li></list></list></TextFlow>',
				1, 4, deleteText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span></span></p><p><span></span></p></TextFlow>');
			// Test for deleting starting from before the start of the last element in the flow that ends with a list should delete the list - 2662563
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Filler</span></p><p><span>Before list</span></p><list listStyleType="disc"><li><p><span>a</span></p></li><list><li><p><span>b</span></p></li></list></list></TextFlow>',
				8, 22, deleteText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Filler</span></p><p><span>B</span></p></TextFlow>');
			
			function deleteText(textFlow:TextFlow):void
			{
				(textFlow.interactionManager as IEditManager).deleteText();
			}
		}
		
		public function undoApplyLink():void
		{
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" paragraphSpaceAfter="15" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>The</span><a href="http://www.4literature.net/Nathaniel_Hawthorne/Ethan_Brand/" target="_self"><linkActiveFormat><TextLayoutFormat color="#00ff00" textDecoration="underline"/></linkActiveFormat><linkHoverFormat><TextLayoutFormat color="#ff0000"/></linkHoverFormat><linkNormalFormat><TextLayoutFormat color="#0000ff"/></linkNormalFormat><span>Eth</span></a><span> by</span><a href="mailto:nathaniel_hawthorne@famousauthors.com" target="_self"><linkActiveFormat><TextLayoutFormat color="#0000ff" lineThrough="true"/></linkActiveFormat><linkHoverFormat><TextLayoutFormat color="#0000ff"/></linkHoverFormat><span>Nat</span></a><span>.</span></p><p><span>The</span><span fontStyle="italic">suc</span><span> li</span></p><p><span>The</span></p></TextFlow>',
				14, 15, applyLink);
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><div><p paragraphSpaceAfter="15"><span>The</span><span fontStyle="italic">suc</span><span> li</span></p></div><p paragraphSpaceAfter="15"><span>The</span></p></TextFlow>',
				1, 10, applyLink);
			undoHelper('<TextFlow columnWidth="250" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="15"><span>The</span><span fontStyle="italic">suc</span><span> lim</span></p><p paragraphSpaceAfter="15"><span>The </span></p></TextFlow>',
				1, 15, applyLink);
			undoHelper('<TextFlow columnWidth="150" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" paragraphSpaceAfter="15" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Bar</span></p><p><span>The</span></p><p><span>The</span></p></TextFlow>',
				4, 11, applyLink);
			undoHelper('<TextFlow fontFamily="Times New Roman" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ab</span></p><p textAlign="center"><span>cd</span></p></TextFlow>', 
				1, 4, applyLink);	// 2637755

			function applyLink(textFlow:TextFlow):void
			{
				(textFlow.interactionManager as IEditManager).applyLink("cnn.com");
			}
		}
	
		public function undoSplitParagraph():void
		{
			var markup:String = '<TextFlow columnWidth="250" fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" textIndent="15" whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p paragraphSpaceAfter="15"><span>The</span><span fontStyle="italic">suc</span><span> lim</span></p><p paragraphSpaceAfter="15"><span>The </span></p></TextFlow>';
			undoHelper(markup, 1, 15, splitParagraph);
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>here &gt;&lt; more</span></p></TextFlow>', 
				6, 6, splitParagraph);  // 2632249

			function splitParagraph(textFlow:TextFlow):void
			{
				(textFlow.interactionManager as IEditManager).splitParagraph();
			}
		}
		
		public function insertTextTest():void
		{
			// Insert cases to test:
			// 1. insert point format null
			// 2. insert point format not null
			// 3. insert at start of existing span
			// 4. insert at end of existing span
			// 5. insert at start of existing para
			// 6. insert at end of existing para
			// 7. insert at start of existing link
			// 8. insert at end of existing link
			// 9. at start of existing tcy
			// 10. insert at end of existing tcy
			// 11. insert at start of existing group
			// 12. regular insert at end of existing group
			
			// All of the above, with range selected for deletion
			//	range including (partial before, all, partial after): plain text, formatted text, link, tcy, group, paragraph, span
			// All of the above, in the second paragraph
			
			var markup:String = '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy>0123</tcy></p>' + 
				'</TextFlow>';
			var pointFormat:PointFormat = null;

			// Insert after a link that covers the entire flow
			undoHelper('<TextFlow fontFamily="Times New Roman" fontSize="14" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><a href="foo"><span>There are many.</span></a></p></TextFlow>', 
				0, 10000, insertText, '<TextFlow fontFamily="Times New Roman" fontSize="14" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><a href="foo"><span>X</span></a></p></TextFlow>');
			undoHelper('<TextFlow fontFamily="Times New Roman" fontSize="14" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><a href="foo"><span>There are many.</span></a></p></TextFlow>', 
				10000, 10000, insertText, '<TextFlow fontFamily="Times New Roman" fontSize="14" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><a href="foo"><span>There are many.</span></a><span>X</span></p></TextFlow>');

			// Insert to start of span at start
			undoHelper(markup, 0, 0, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>Xone</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			
			undoHelper(markup, 3, 3, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>oneX</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			// Insert to end of second span
			undoHelper(markup, 6, 6, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">twoX</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			pointFormat = new PointFormat();
			// Insert to middle of second span with point format for overriding character style
			pointFormat.fontStyle = FontPosture.ITALIC;
			undoHelper(markup, 4, 4, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">t</span><span fontStyle="italic" fontWeight="bold">X</span><span fontWeight="bold">wo</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			// Insert to middle of second span with point format for overriding character style and tcy
			pointFormat.tcyElement = new TCYElement();
			undoHelper(markup, 4, 4, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">t</span><tcy><span fontStyle="italic" fontWeight="bold">X</span></tcy><span fontWeight="bold">wo</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			// Insert to middle of second span with point format for overriding link only
			pointFormat = new PointFormat();
			pointFormat.linkElement = new LinkElement();
			pointFormat.linkElement.href = "http://cnn.com";
			undoHelper(markup, 4, 4, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">t</span><a href="http://cnn.com"><span fontWeight="bold">X</span></a><span fontWeight="bold">wo</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			pointFormat = null;
			
			// Insert blank (empty) string
			undoHelper(markup, 0, 0, insertEmptyString, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			
			// Insert blank (empty) string with PointFormat set
			pointFormat = new PointFormat();
			pointFormat.fontStyle = FontPosture.ITALIC;
			undoHelper(markup, 0, 0, insertEmptyString, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			pointFormat = null;
			
			// Inserting at the start of a link should not add the text to the link
			undoHelper(markup, 16, 16, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">fourX</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			// Inserting at the end of a link should not add the text to the link (or the following tcy)
			undoHelper(markup, 20, 20, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><span>X</span><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			// Inserting at the start of a link wrapped in a group
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><g><a href="http://www.adobe.com"><span>Link</span></a></g><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>', 16, 16, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">fourX</span><g><a href="http://www.adobe.com"><span>Link</span></a></g><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			// Inserting at the end of a link wrapped in a group should not add the text to the link
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><g><a href="http://www.adobe.com"><span>Link</span></a></g><span>0123</span></p>' + 
				'</TextFlow>', 20, 20, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><g><a href="http://www.adobe.com"><span>Link</span></a><span>X</span></g><span>0123</span></p>' + 
				'</TextFlow>');
			// Inserting at the end of a link wrapped in a group should not add the text to the link (or the following tcy)
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><g><a href="http://www.adobe.com"><span>Link</span></a></g><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>', 20, 20, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><g><a href="http://www.adobe.com"><span>Link</span></a><span>X</span></g><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');

			// insert after a formatted link element should copy the formatting
			undoHelper("<TextFlow  xmlns='http://ns.adobe.com/textLayout/2008'><a><span fontSize='24'>ABCD</span></a></TextFlow>", 4, 4, insertText, 
				'<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><a><span fontSize="24">ABCD</span></a><span fontSize="24">X</span></p></TextFlow>');
			
			// insert before a linkelement with multiple children
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><a href="xyz"><span>text</span><img height="auto" width="auto" source="../../test/testFiles/assets/surprised.png" float="left"/><span>text</span></a></p></TextFlow>',
				0,0, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>X</span><a href="xyz"><span>text</span><img height="auto" width="auto" source="../../test/testFiles/assets/surprised.png" float="left"/><span>text</span></a></p></TextFlow>');
			

			// Inserting at the start of a tcy should not add the text to the tcy
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>', 16, 16, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">fourX</span><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			// Inserting at the end of a tcy should add the text to the tcy 
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>', 20, 20, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><tcy><span>0123X</span></tcy></p>' + 
				'</TextFlow>');
			// Inserting at the end of a group should add the text to the group 
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><g><span>0123</span></g></p>' + 
				'</TextFlow>', 20, 20, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><g><span>0123X</span></g></p>' + 
				'</TextFlow>');

			// Inserting after deleting an element with user styles should result in inserted text having user style applied
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span myUserStyle="funky" fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>', 3, 6, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span fontWeight="bold" myUserStyle="funky">X</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
					
			// Inserting with user styles set in the point format should cause the user styles to be applied to the inserted text
			pointFormat = new PointFormat();
			pointFormat.setStyle("myUserStyle", "funky");
			undoHelper(markup, 3, 3, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span myUserStyle="funky">X</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			pointFormat = null;
					
			// Check that styleName is propagated from the left side leaf
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span styleName="foo">one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy>0123</tcy></p>' + 
				'</TextFlow>', 3, 3, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span styleName="foo">oneX</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');

			// Check that styleName is propagated from a text deleted as part of a replace
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span styleName="foo">one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy>0123</tcy></p>' + 
				'</TextFlow>', 0, 3, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span styleName="foo">X</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');

			// Check that styleName is propagated from the left side leaf, even when we're adding via pointFormat
			pointFormat = new PointFormat();
			pointFormat.fontStyle = FontPosture.ITALIC;
			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span styleName="foo">one</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy>0123</tcy></p>' + 
				'</TextFlow>', 3, 3, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span styleName="foo">one</span><span fontStyle="italic" styleName="foo">X</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			pointFormat = null;

			// Check that styleName is propagated from the pointformat is applied
			pointFormat = new PointFormat();
			pointFormat.setStyle("styleName", "bar");
			undoHelper(markup, 3, 3, insertText, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">' +
				'<p><span>one</span><span styleName="bar">X</span><span fontWeight="bold">two</span></p>' + 
				'<p><span>three</span><span fontWeight="bold">four</span><a href="http://www.adobe.com"><span>Link</span></a><tcy><span>0123</span></tcy></p>' + 
				'</TextFlow>');
			pointFormat = null;
			
			// Check that inserting over a range of text with a link applied applies the same link back again
			undoHelper('<TextFlow xmlns="http://ns.adobe.com/textLayout/2008" fontSize="14" textIndent="15" paragraphSpaceAfter="15" paddingTop="4" paddingLeft="4" fontFamily="Times New Roman"><p>This from <a href="http://www.4literature.net/Nathaniel_Hawthorne/Ethan_Brand/" target="_self"><linkHoverFormat><TextLayoutFormat color="0xff0000"/></linkHoverFormat><linkActiveFormat><TextLayoutFormat color="#00ff00" textDecoration="underline"/></linkActiveFormat><linkNormalFormat><TextLayoutFormat color="#0000ff"/></linkNormalFormat><span>Ethan Brand</span></a> by <a href="mailto:nathaniel_hawthorne@famousauthors.com" target="_self"><linkHoverFormat><TextLayoutFormat color="#0000ff"/></linkHoverFormat><linkActiveFormat><TextLayoutFormat color="#0000ff" lineThrough="true"/></linkActiveFormat><span>Nathaniel Hawthorne</span></a>.</p></TextFlow>', 
				10, 21, insertText, '<TextFlow fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" paragraphSpaceAfter="15" textIndent="15" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>This from </span><a href="http://www.4literature.net/Nathaniel_Hawthorne/Ethan_Brand/" target="_self"><linkActiveFormat><TextLayoutFormat color="#00ff00" textDecoration="underline"/></linkActiveFormat><linkHoverFormat><TextLayoutFormat color="#ff0000"/></linkHoverFormat><linkNormalFormat><TextLayoutFormat color="#0000ff"/></linkNormalFormat><span>X</span></a><span> by </span><a href="mailto:nathaniel_hawthorne@famousauthors.com" target="_self"><linkActiveFormat><TextLayoutFormat color="#0000ff" lineThrough="true"/></linkActiveFormat><linkHoverFormat><TextLayoutFormat color="#0000ff"/></linkHoverFormat><span>Nathaniel Hawthorne</span></a><span>.</span></p></TextFlow>');

			// Check that deleting a link and then inserting it does NOT apply the same link back again
			pointFormat = null;
			undoHelper('<TextFlow xmlns="http://ns.adobe.com/textLayout/2008" fontSize="14" textIndent="15" paragraphSpaceAfter="15" paddingTop="4" paddingLeft="4" fontFamily="Times New Roman"><p>This from <a href="http://www.4literature.net/Nathaniel_Hawthorne/Ethan_Brand/" target="_self"><linkHoverFormat><TextLayoutFormat color="0xff0000"/></linkHoverFormat><linkActiveFormat><TextLayoutFormat color="#00ff00" textDecoration="underline"/></linkActiveFormat><linkNormalFormat><TextLayoutFormat color="#0000ff"/></linkNormalFormat><span>Ethan Brand</span></a> by <a href="mailto:nathaniel_hawthorne@famousauthors.com" target="_self"><linkHoverFormat><TextLayoutFormat color="#0000ff"/></linkHoverFormat><linkActiveFormat><TextLayoutFormat color="#0000ff" lineThrough="true"/></linkActiveFormat><span>Nathaniel Hawthorne</span></a>.</p></TextFlow>', 
				10, 21, deleteAndInsertText, '<TextFlow fontFamily="Times New Roman" fontSize="14" paddingLeft="4" paddingTop="4" paragraphSpaceAfter="15" textIndent="15" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>This from X by </span><a href="mailto:nathaniel_hawthorne@famousauthors.com" target="_self"><linkActiveFormat><TextLayoutFormat color="#0000ff" lineThrough="true"/></linkActiveFormat><linkHoverFormat><TextLayoutFormat color="#0000ff"/></linkHoverFormat><span>Nathaniel Hawthorne</span></a><span>.</span></p></TextFlow>');

			undoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><list listStyleType="disc"><li><p><span>one</span></p><div><p><span>para in div in list item</span></p></div></li></list></TextFlow>',
				0, 4, insertText);
			
			function insertText(textFlow:TextFlow):void
			{
				var selectionState:SelectionState = textFlow.interactionManager.getSelectionState();
				(textFlow.interactionManager as IEditManager).insertText('X', 
					new SelectionState(textFlow, selectionState.anchorPosition, selectionState.activePosition, pointFormat));
				textFlow.interactionManager.flushPendingOperations();
			}

			function deleteAndInsertText(textFlow:TextFlow):void
			{
				(textFlow.interactionManager as IEditManager).beginCompositeOperation();
				(textFlow.interactionManager as IEditManager).deleteText();

				var selectionState:SelectionState = textFlow.interactionManager.getSelectionState();
				(textFlow.interactionManager as IEditManager).insertText('X', 
					new SelectionState(textFlow, selectionState.anchorPosition, selectionState.activePosition, pointFormat));
				(textFlow.interactionManager as IEditManager).endCompositeOperation();
			}

			function insertEmptyString(textFlow:TextFlow):void
			{
				var selectionState:SelectionState = textFlow.interactionManager.getSelectionState();
				(textFlow.interactionManager as IEditManager).insertText('', 
					new SelectionState(textFlow, selectionState.anchorPosition, selectionState.activePosition, pointFormat));
				textFlow.interactionManager.flushPendingOperations();
			}
			
	}
		
		private function pasteUndoHelper(markup:String, startPos:int, endPos:int, doFunction:Function, selectAfterPosition:int, expectedResult:String):void
		{
			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			var originalMarkup:String = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			testApp.contentChange(textFlow);
			textFlow.interactionManager.selectRange(startPos,endPos);
			doFunction(textFlow, selectAfterPosition);
			var afterDoMarkup:String = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			var afterDoAnchorPos:int = textFlow.interactionManager.anchorPosition;
			var afterDoActivePos:int = textFlow.interactionManager.activePosition;
			assertTrue("Markup after Do() doesn't matched expected result", afterDoMarkup == expectedResult);
			(textFlow.interactionManager as IEditManager).undo();
			var afterUndoAnchorPos:int = textFlow.interactionManager.anchorPosition;
			var afterUndoActivePos:int = textFlow.interactionManager.activePosition;
			var afterUndoMarkup:String = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			assertTrue("Didn't get back to original model state after undo", afterUndoMarkup == originalMarkup);
	//		assertTrue("Didn't return selection to original state after undo", afterUndoAnchorPos == selectAfterPosition && afterUndoActivePos == selectAfterPosition);
			(textFlow.interactionManager as IEditManager).redo();
			var afterRedoAnchorPos:int = textFlow.interactionManager.anchorPosition;
			var afterRedoActivePos:int = textFlow.interactionManager.activePosition;
			var afterRedoMarkup:String = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			assertTrue("Didn't get back to post-Do model state after redo", afterRedoMarkup == afterDoMarkup);
		}
		
		public function copyPasteUndoRedo():void
		{
			var pointFormat:PointFormat;
			
			// Create a TextFlow based on the mark, copy the range arg2-arg3, do function (pasteScrap) then paste at arg5

			// lists
			var scrapFlow:TextFlow = null;
			
			// copy the first word in a list item, paste it right after
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Next paragraph is in a list</span></p><list listStyleType="disc"><li><p><span>First item</span></p><p>Second paragraph of first item</p></li><li><p><span>Second item</span></p></li><li><p><span>Third Item </span></p></li><li><p><span>fourth item</span></p></li></list><p><span>This paragraph is after the list</span></p></TextFlow>',
				28, 34, pasteScrap, 34, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Next paragraph is in a list</span></p><list listStyleType="disc"><li><p><span>First First item</span></p><p><span>Second paragraph of first item</span></p></li><li><p><span>Second item</span></p></li><li><p><span>Third Item </span></p></li><li><p><span>fourth item</span></p></li></list><p><span>This paragraph is after the list</span></p></TextFlow>');
			// copy an entire list item to an empty paragraph where there is no list
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Next paragraph is in a list</span></p><list listStyleType="box"><li><p><span>First item</span></p><p><span>Second paragraph of first item</span></p></li><li><p><span>Second item</span></p></li><li><p><span>Third Item </span></p></li><li><p><span>fourth item</span></p></li></list><p><span>This paragraph is after the list</span></p><p><span></span></p><p><span></span></p></TextFlow>',
				70, 82, pasteScrap, 139, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Next paragraph is in a list</span></p><list listStyleType="box"><li><p><span>First item</span></p><p><span>Second paragraph of first item</span></p></li><li><p><span>Second item</span></p></li><li><p><span>Third Item </span></p></li><li><p><span>fourth item</span></p></li></list><p><span>This paragraph is after the list</span></p><list listStyleType="box"><li><p><span>Second item</span></p></li></list><p><span></span></p><p><span></span></p></TextFlow>');
			// copy an entire list item to a paragraph with content where there is no list
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Before a list</span></p><list listStyleType="disc"><li><p><span>First item</span></p></li><li><p><span>Second item</span></p></li><li><p><span>Third Item </span></p></li></list><p><span>After the list</span></p><p/></TextFlow>',
				25, 37, pasteScrap, 64, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Before a list</span></p><list listStyleType="disc"><li><p><span>First item</span></p></li><li><p><span>Second item</span></p></li><li><p><span>Third Item </span></p></li></list><p><span>After the list</span></p><list listStyleType="disc"><li><p><span>Second item</span></p></li></list><p><span></span></p></TextFlow>');
			
			// divs
			
			// copy an entire two paragraph div to in the middle of the following two paragraph div
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><div><p><span>AAA</span></p><p><span>BBB</span></p></div><div><p><span>CCC</span></p><p><span>DDD</span></p></div><p/></TextFlow>',
				0, 8, pasteScrap, 9, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><div><p><span>AAA</span></p><p><span>BBB</span></p></div><div><p><span>CAAA</span></p><div><p><span>BBB</span></p></div><p><span>CC</span></p><p><span>DDD</span></p></div><p><span></span></p></TextFlow>');
			// copy a partial two paragraph div  to right before the last para as child of TextFlow
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><div><p><span>AAA</span></p><p><span>BBB</span></p></div><div><p><span>CCC</span></p><p><span>DDD</span></p></div><p/></TextFlow>',
				0, 7, pasteScrap, 16, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><div><p><span>AAA</span></p><p><span>BBB</span></p></div><div><p><span>CCC</span></p><p><span>DDD</span></p></div><p><span>AAA</span></p><p><span>BBB</span></p></TextFlow>');
			// copy an entire two paragraph div to right before the last para as child of TextFlow
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><div><p><span>AAA</span></p><p><span>BBB</span></p></div><div><p><span>CCC</span></p><p><span>DDD</span></p></div><p/></TextFlow>',
				0, 8, pasteScrap, 16, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><div><p><span>AAA</span></p><p><span>BBB</span></p></div><div><p><span>CCC</span></p><p><span>DDD</span></p></div><div><p><span>AAA</span></p><p><span>BBB</span></p></div><p><span></span></p></TextFlow>');

			// simple multiple paste objects
			
			// copy text from one paragraph into another, should keep the same format in the destination (consistent with TLF 1.1
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>one</span></p><p textAlign="right"><span>two</span></p><p><span>three</span></p></TextFlow>',
				0, 4, pasteScrap, 5, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>one</span></p><p textAlign="right"><span>tone</span></p><p textAlign="right"><span>wo</span></p><p><span>three</span></p></TextFlow>');
			// copy the last two spans and the the start of the following paragraph and insert into to the middle of the third paragraph
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span fontSize="48">AB</span><span fontSize="48" fontStyle="italic">C</span></p><p><span fontSize="48">DEF</span></p><p><span fontSize="48">GHI</span></p></TextFlow>',
				1, 6, pasteScrap, 9, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span fontSize="48">AB</span><span fontSize="48" fontStyle="italic">C</span></p><p><span fontSize="48">DEF</span></p><p><span fontSize="48">GB</span><span fontSize="48" fontStyle="italic">C</span></p><p><span fontSize="48">DEHI</span></p></TextFlow>');
			// copy the last two spans and the following paragraph and insert into to the middle of the third paragraph
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span fontSize="48">AB</span><span fontSize="48" fontStyle="italic">C</span></p><p><span fontSize="48">DEF</span></p><p><span fontSize="48">GHI</span></p></TextFlow>',
				1, 8, pasteScrap, 9, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span fontSize="48">AB</span><span fontSize="48" fontStyle="italic">C</span></p><p><span fontSize="48">DEF</span></p><p><span fontSize="48">GB</span><span fontSize="48" fontStyle="italic">C</span></p><p><span fontSize="48">DEF</span></p><p><span fontSize="48">HI</span></p></TextFlow>');
			// copy the last two spans of the first paragraph and insert into the middle of the second paragraph
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span fontSize="48">AB</span><span fontSize="48" fontStyle="italic">C</span></p><p><span fontSize="48">DEF</span></p></TextFlow>',
				1, 4, pasteScrap, 5, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span fontSize="48">AB</span><span fontSize="48" fontStyle="italic">C</span></p><p><span fontSize="48">DB</span><span fontSize="48" fontStyle="italic">C</span></p><p><span fontSize="48">EF</span></p></TextFlow>');

			// very simple paste cases
			
			// copy the last character of one paragrah and the first character of the next paragraph, paste in place
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ABC</span></p><p><span>DEF</span></p></TextFlow>',
				3, 6, pasteInPlace, 3, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ABC</span></p><p><span>DEF</span></p></TextFlow>');			
			// paste a single char in the middle of the first para
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ABC</span></p></TextFlow>',
				1, 2, pasteScrap, 2, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ABBC</span></p></TextFlow>');
			// paste a single char in the middle of the second para
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ABC</span></p><p><span>DEF</span></p></TextFlow>',
				6, 7, pasteScrap, 7, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ABC</span></p><p><span>DEFF</span></p></TextFlow>');
			// paste a single entire paragraph after the first para
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ABC</span></p><p><span>DEF</span></p><p><span>GHI</span></p></TextFlow>',
				0, 4, pasteScrap, 8, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ABC</span></p><p><span>DEF</span></p><p><span>ABC</span></p><p><span>GHI</span></p></TextFlow>');
			// paste a single entire paragraph in the middle of the second para
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ABC</span></p><p><span>DEF</span></p></TextFlow>',
				0, 4, pasteScrap, 5, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>ABC</span></p><p><span>DABC</span></p><p><span>EF</span></p></TextFlow>');
			
			
			// Copy an unformatted span after a link, check that it picks up formatting from surrounding text from preceding span
			scrapFlow = TextConverter.importToFlow('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p mergeToNextOnPaste="true"><span>pastedText</span></p></TextFlow>', 
				TextConverter.TEXT_LAYOUT_FORMAT);
				// merges with following span (same format)
			pasteUndoHelper('<TextFlow fontSize="24" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><a href="foo"><span fontFamily="Minion Pro">Link</span></a><span fontFamily="Minion Pro">Not</span></p></TextFlow>',
				4, 4, pasteScrap, 4, '<TextFlow fontSize="24" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><a href="foo"><span fontFamily="Minion Pro">Link</span></a><span fontFamily="Minion Pro">pastedTextNot</span></p></TextFlow>');
				// following span has italic applied (different format, different span)
			pasteUndoHelper('<TextFlow fontSize="24" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><a href="foo"><span fontFamily="Minion Pro">Link</span></a><span fontFamily="Minion Pro" fontStyle="italic">Not</span></p></TextFlow>',
				4, 4, pasteScrap, 4, '<TextFlow fontSize="24" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><a href="foo"><span fontFamily="Minion Pro">Link</span></a><span fontFamily="Minion Pro">pastedText</span><span fontFamily="Minion Pro" fontStyle="italic">Not</span></p></TextFlow>');

			// Copy a formatted paragraph from the scrap into an empty paragraph - (copies para format)
			scrapFlow = TextConverter.importToFlow('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p textAlign="center" mergeToNextOnPaste="true"><span>pastedText</span></p></TextFlow>', 
				TextConverter.TEXT_LAYOUT_FORMAT);
			pasteUndoHelper('<TextFlow fontSize="24" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>A</span></p><p><span>B</span></p></TextFlow>',
				4, 4, pasteScrap, 2, '<TextFlow fontSize="24" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>A</span></p><p><span>pastedTextB</span></p></TextFlow>');
			scrapFlow = null;
			
			// Copy unformatted text as a complete paragraph, check that attributes from the destination are applied
			// 2746688
		//	scrapFlow = TextConverter.importToFlow('pastedText\n', 
		//		TextConverter.PLAIN_TEXT_FORMAT);		// creates 2 paragraphs
			scrapFlow = TextConverter.importToFlow('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>pastedText</span></p></TextFlow>', 
				TextConverter.TEXT_LAYOUT_FORMAT);
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span color="#0000ff"></span></p></TextFlow>', 
				4, 4, pasteScrap, 0, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span color="#0000ff">pastedText</span></p><p><span color="#0000ff"></span></p></TextFlow>');
			scrapFlow = null; 
			
			// Copy unformatted text with the pointFormat set, check that the pointFormat is applied to pasted text - Watson 2759997
			scrapFlow = TextConverter.importToFlow('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p mergeToNextOnPaste="true"><span>pastedText</span></p></TextFlow>', 
				TextConverter.TEXT_LAYOUT_FORMAT);
			pointFormat = new PointFormat();
			pointFormat.fontStyle = FontPosture.ITALIC;
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span color="#0000ff"></span></p></TextFlow>', 
				4, 4, pasteScrap, 0, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span color="#0000ff" fontStyle="italic">pastedText</span></p></TextFlow>');

			// Copy unformatted text with the pointFormat set, check that the pointFormat is applied to pasted text & paragraph attributes are picked up from surrounding text - Watson 2761051
			scrapFlow = TextConverter.importToFlow('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>A</span></p><p><span>B</span></p><p><span>C</span></p></TextFlow>', 
				TextConverter.TEXT_LAYOUT_FORMAT);
			pointFormat = new PointFormat();
			pointFormat.fontStyle = FontPosture.ITALIC;
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span></span></p><p textAlign="center"><span></span></p><p><span></span></p></TextFlow>', 
				0, 0, pasteScrap, 1, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span></span></p><p textAlign="center"><span fontStyle="italic">A</span></p><p textAlign="center"><span fontStyle="italic">B</span></p><p textAlign="center"><span fontStyle="italic">C</span></p><p textAlign="center"><span></span></p><p><span></span></p></TextFlow>');
			
			
			// Copy a formatted paragraph from the scrap into a non-empty paragraph - (does not copy para format)
			scrapFlow = TextConverter.importToFlow('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p textAlign="center" mergeToNextOnPaste="true"><span>pastedText</span></p></TextFlow>', 
				TextConverter.TEXT_LAYOUT_FORMAT);
			pasteUndoHelper('<TextFlow fontSize="24" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>A</span></p><p><span/></p></TextFlow>',
				4, 4, pasteScrap, 2, '<TextFlow fontSize="24" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>A</span></p><p textAlign="center"><span>pastedText</span></p></TextFlow>');
			scrapFlow = null;
			
			// Copy multiple formatted paragraphs from the scrap into an empty paragraph - 2796531
			//scrapFlow = TextConverter.importToFlow('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p textIndent="30"><span>a</span></p><p><span>b</span></p><p paragraphStartIndent="60" mergeToNextOnPaste="true"><span>c</span></p></TextFlow>', 
			//	TextConverter.TEXT_LAYOUT_FORMAT);
			//pasteUndoHelper('<TextFlow fontSize="24" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span></span></p></TextFlow>',
			//	0, 0, pasteScrap, 0, '<TextFlow fontSize="24" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p textIndent="30"><span>a</span></p><p><span>b</span></p><p><span>c</span></p></TextFlow>');
			//scrapFlow = null;
			
			//bug #2826905 - TLF Text Pasted loses last line of Formatting [SelectionContainer]
			scrapFlow = TextConverter.importToFlow('<TextFlow mergeToNextOnPaste="true" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Line One Left</span></p><p fontSize="16" fontWeight="bold" mergeToNextOnPaste="true" textAlign="right"><span mergeToNextOnPaste="true">Line Four Right Bold Large</span></p></TextFlow>', 
				TextConverter.TEXT_LAYOUT_FORMAT);
			pasteUndoHelper('<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span></span></p></TextFlow>',
				0, 0, pasteScrap, 0, '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Line One Left</span></p><p fontSize="16" fontWeight="bold" textAlign="right"><span>Line Four Right Bold Large</span></p></TextFlow>');
			scrapFlow = null;
			
			function pasteInPlace(textFlow:TextFlow, pasteAbsoluteStart:int):void
			{
				var textScrap:TextScrap;
				if (scrapFlow != null)
					textScrap = new TextScrap(scrapFlow);
				else	// copy the selection
					textScrap = TextScrap.createTextScrap(textFlow.interactionManager.getSelectionState());
				var editManager:IEditManager = textFlow.interactionManager as IEditManager;
				editManager.beginCompositeOperation();
				editManager.deleteText();
				editManager.pasteTextScrap(textScrap, new SelectionState(textFlow, pasteAbsoluteStart, pasteAbsoluteStart));
				editManager.endCompositeOperation();
			}
			function pasteScrap(textFlow:TextFlow, pasteAbsoluteStart:int):void
			{
				// copy the selection
				var textScrap:TextScrap;
				if (scrapFlow != null)
					textScrap = new TextScrap(scrapFlow);
				else	// copy the selection
					textScrap = TextScrap.createTextScrap(textFlow.interactionManager.getSelectionState());
				(textFlow.interactionManager as IEditManager).pasteTextScrap(textScrap, new SelectionState(textFlow, pasteAbsoluteStart, pasteAbsoluteStart, pointFormat));
			}
		}
		
		public function splitParagraphAsElement():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			var p1:ParagraphElement = new ParagraphElement();
			var s1:SpanElement = new SpanElement()
			var f1:TextLayoutFormat = new TextLayoutFormat();
			f1.fontSize = 24;
			s1.text = "one";
			p1.format = f1;
			p1.addChild(s1);
			var p2:ParagraphElement = new ParagraphElement();
			var s2:SpanElement = new SpanElement()
			s2.text = "two";
			p2.addChild(s2);
			TestFrame.textFlow.replaceChildren(0,1,p1);
			//TestFrame.textFlow.addChild(p1);
			TestFrame.textFlow.addChild(p2);
			TestFrame.flowComposer.updateAllControllers();
			// split paragraph at the position before and after the terminator
			var newParaFontSize:Number;
			var newParaLength:int;
			var oldParaLength:int;
			for (var i:int=3; i<5; i++)
			{
				SelManager.selectRange(i,i);
				SelManager.splitElement(p1);
				oldParaLength = TestFrame.textFlow.getChildAt(0).textLength;
				assertTrue ("Old paragraph should have a textLength of 4, but is " + oldParaLength + " instead", oldParaLength == 4);
				newParaLength = TestFrame.textFlow.getChildAt(1).textLength;
				assertTrue ("New paragraph should only have a terminator but has " + newParaLength + " characters", newParaLength == 1);
				newParaFontSize = TestFrame.textFlow.getChildAt(1).format.fontSize;
				assertTrue ("Font size for new paragraph should be " + 24 + " but is " + newParaFontSize, newParaFontSize == 24);
				SelManager.undo();
			}
		}
		
		public function selectAllAndSplitParagraph():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			
			assertTrue ("selectAllAndSplitParagraph: expect one paragraph", textFlow.getElementsByTypeName("p").length == 1);
			// this test needs two paragraphs - severalpages.xml only has one
			SelManager.selectRange(textFlow.textLength/2,textFlow.textLength/2);
			SelManager.splitParagraph();
			assertTrue ("selectAllAndSplitParagraph: expect two paragraphs", textFlow.getElementsByTypeName("p").length == 2);
			SelManager.selectAll();
			SelManager.splitParagraph();
			assertTrue ("selectAllAndSplitParagraph: expect two empty paragraphs", textFlow.textLength == 2 && textFlow.getElementsByTypeName("p").length == 2);
		}
		
		// Test for Watson 2758434
		public function undoRedo2758434():void
		{
			var textFlow:TextFlow = new TextFlow();
			testApp.contentChange(textFlow);
			
			var editManager:IEditManager = textFlow.interactionManager as IEditManager;
			
			/* 1. Run Flow, set point size to 60
			2. Insert this:
			A
			B
			C
			D
			E
			3. Select D and E and delete
			4. Undo (D & E come back)
			5. Undo again (all text goes away)
			6. Redo (text comes back)
			7. Redo (redo delete)
			8. Undo
			*/

			editManager.selectRange(0, 0);
			editManager.insertText("A");
			editManager.splitParagraph();
			editManager.insertText("B");
			editManager.splitParagraph();
			editManager.insertText("C");
			editManager.splitParagraph();
			editManager.insertText("D");
			editManager.splitParagraph();
			editManager.insertText("E");
			editManager.selectRange(6, 9);
			var expectedEndState:String = TextConverter.export(editManager.textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			editManager.deleteText();
			editManager.undo();		// undo delete
			editManager.undo();		// undo previous inserts
			editManager.redo();		// redo previous inserts
			editManager.redo();		// redo delete
			editManager.undo();		// undo delete
			var actualEndState:String = TextConverter.export(editManager.textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			assertTrue("Undo of delete should return to original state", actualEndState == expectedEndState);
		}
		public function moveChildrenOperation():void
		{
			var ParentElementArray:Array = [DivElement, ParagraphElement, ListElement, ListItemElement, LinkElement, TCYElement];
			var TargetElementArray:Array = [DivElement, ParagraphElement, ListElement, ListItemElement, LinkElement, TCYElement];
			var ChildElementArray:Array =  [DivElement, ParagraphElement, ListElement, ListItemElement, LinkElement, TCYElement, SpanElement, InlineGraphicElement];
			var textFlow:TextFlow;
			var subroot:FlowGroupElement;
			var parent:FlowGroupElement;
			var target:FlowGroupElement;
			var target2:FlowGroupElement;
			var child:FlowElement;	
			var child2:FlowElement;
			var combinationArray:Array;			
			var subrootId:int = 1;			
			var parentId:int = 2;
			var targetId:int = 3;
			var childId:int = 4;
			
			
			for(var i:int = 0; i< ParentElementArray.length; i++)
			{				
				for(var j:int = 0; j< TargetElementArray.length; j++)
				{					
					for(var k:int = 0; k < ChildElementArray.length; k++)
					{
						textFlow = new TextFlow;
						subroot = textFlow;		
						parent = new ParentElementArray[i]();
						parent.id = parentId.toString();
						target = new TargetElementArray[j]();
						target.id = targetId.toString();
						child = new ChildElementArray[k]();
						child.id = childId.toString();
						
						target2 = new TargetElementArray[j]();
						child2 = new ChildElementArray[k]();
						
						combinationArray = doCombination(textFlow,subroot,parent,target,target2,child,child2);
						
						if(combinationArray == null){
							continue;
						}		
						checkOperation(combinationArray);
					}
				}
			}
		}
		private function doCombination(textFlow:TextFlow,subroot:FlowGroupElement, parent:FlowGroupElement, target:FlowGroupElement,target2:FlowGroupElement, child:FlowElement, child2:FlowElement):Array
		{
			//maybe bugs
			if((parent is ListItemElement) && (target is DivElement) && (child is ListElement)){
				return null;
			}
			if((parent is ListItemElement) && (target is ListElement) && (child is ListElement)){
				return null;
			}
			if((parent is ListItemElement) && (target is ListItemElement) && (child is ListElement)){
				return null;
			}
			//ERROR: Bad getChildIndex
			if((parent is ParagraphElement) && (target is ParagraphElement) && (child is LinkElement)){
				return null;
			}
			//ERROR: Bad getChildIndex
			if((parent is ParagraphElement) && (target is ParagraphElement) && (child is TCYElement)){
				return null;
			}			
			var span:SpanElement;
			
			//add the parent to the textflow
			try{
				if(parent is SubParagraphGroupElementBase){					
					var p:ParagraphElement = new ParagraphElement();
					p.addChild(parent);
					textFlow.addChild(p);
					subroot = p;
				}else if(parent is ListItemElement){
					var list:ListElement = new ListElement();
					list.addChild(parent);
					textFlow.addChild(list);
					subroot = list;
				}else{
					textFlow.addChild(parent);
				}
				subroot.id = "1";
				
			}catch(e:ArgumentError){
				return null;
			}			
			//advoid elements merge
			if(parent is SubParagraphGroupElementBase && target is SubParagraphGroupElementBase){
				span = new SpanElement();
				span.text = "avoidmerge";
				subroot.addChild(span);
			}			
			//add the target to the textflow
			try{
				if(target is SubParagraphGroupElementBase){
					span = new SpanElement();
					span.text = "target";
					target.addChild(span);
				}
				subroot.addChild(target);
			}catch(e:ArgumentError){
				return null;
			}
			//add the child to the parent
			try{
				if(child is SubParagraphGroupElementBase){
					span = new SpanElement();
					span.text = "child";
					(child as SubParagraphGroupElementBase).addChild(span);
				}
				parent.addChild(child);					
				//test if the target is able to add the child
				target2.addChild(child2);			
			}catch(e:ArgumentError){
				return null;
			}
			if(child is SpanElement){
				(child as SpanElement).text = "text";
			}		
			return new Array(textFlow,subroot,parent,target,child);
		}
		private function checkOperation(combinationArray:Array):void
		{
			var textFlow:TextFlow = combinationArray[0];
			var subroot:FlowGroupElement = combinationArray[1]
			var parent:FlowGroupElement = combinationArray[2];
			var target:FlowGroupElement = combinationArray[3];
			var child:FlowElement = combinationArray[4];
			//operate, undo, redo
			
			var undoMan:IUndoManager = new UndoManager();
			var editMan:EditManager = new EditManager(undoMan);
			textFlow.interactionManager = editMan;
			textFlow.flowComposer.updateAllControllers();	
			//before move
			var combinedNames:String = parent.typeName + " " + target.typeName + " " + child.typeName;
			
			if(!(parent is SubParagraphGroupElementBase && target is SubParagraphGroupElementBase)){
				//no span between parent and target				
				assertTrue(combinedNames + ": parent.id != 2 or target.id != 3 or child.id != 4.",
					subroot.getChildAt(0).id == "2" 
					&& subroot.getChildAt(1).id == "3"
					&& (subroot.getChildAt(0) as FlowGroupElement).getChildAt(0).id == "4");					
				try{
					//move child
					editMan.selectAll();	
					editMan.moveChildren(parent,0,1,target,0);				
					textFlow.flowComposer.updateAllControllers();				
					if(subroot.getChildAt(1) == null){					
						assertTrue(combinedNames + ": fail to move.",
							subroot.getChildAt(0).id == "3" 
							&& subroot.getChildAt(1) == null
							&& (subroot.getChildAt(0) as FlowGroupElement).getChildAt(0).id == "4");					
					}else{					
						assertTrue(combinedNames + ": fail to move.",
							subroot.getChildAt(0).id == "2"
							&& subroot.getChildAt(1).id == "3"
							&& (subroot.getChildAt(1) as FlowGroupElement).getChildAt(0).id == "4");
					}
					//undo
					editMan.undo();
					textFlow.flowComposer.updateAllControllers();
					assertTrue(combinedNames + ": fail to undo",
						subroot.getChildAt(0).id == "2" 
						&& subroot.getChildAt(1).id == "3"
						&& (subroot.getChildAt(0) as FlowGroupElement).getChildAt(0).id == "4")
					//redo
					editMan.redo();
					textFlow.flowComposer.updateAllControllers();				
					if(subroot.getChildAt(1) == null){					
						assertTrue(combinedNames + ": fail to redo.",
							subroot.getChildAt(0).id == "3" 
							&& subroot.getChildAt(1) == null
							&& (subroot.getChildAt(0) as FlowGroupElement).getChildAt(0).id == "4");					
					}else{					
						assertTrue(combinedNames + ": fail to redo.",
							subroot.getChildAt(0).id == "2"
							&& subroot.getChildAt(1).id == "3"
							&& (subroot.getChildAt(1) as FlowGroupElement).getChildAt(0).id == "4");
					}				
				}catch(e:Error){
					assertTrue(combinedNames + ": " + e.getStackTrace(),false);
				}		
			}else{
				//there is a span betweeen parent and target
				assertTrue(combinedNames + ": parent.id != 2 or target.id != 3 or child.id != 4.",
					subroot.getChildAt(0).id == "2" 
					&& subroot.getChildAt(2).id == "3"
					&& (subroot.getChildAt(0) as FlowGroupElement).getChildAt(0).id == "4");					
				try{
					//move child
					editMan.selectAll();	
					editMan.moveChildren(parent,0,1,target,0);				
					textFlow.flowComposer.updateAllControllers();				
					if(subroot.getChildAt(0) is SpanElement){					
						assertTrue(combinedNames + ": fail to move.",
							subroot.getChildAt(1).id == "3" 
							&& subroot.getChildAt(0) is SpanElement
							&& (subroot.getChildAt(1) as FlowGroupElement).getChildAt(0).id == "4");					
					}else{					
						assertTrue(combinedNames + ": fail to move.",
							subroot.getChildAt(0).id == "2"
							&& subroot.getChildAt(2).id == "3"
							&& (subroot.getChildAt(2) as FlowGroupElement).getChildAt(0).id == "4");
					}
					//undo
					editMan.undo();
					textFlow.flowComposer.updateAllControllers();
					assertTrue(combinedNames + ": fail to undo",
						subroot.getChildAt(0).id == "2" 
						&& subroot.getChildAt(2).id == "3"
						&& (subroot.getChildAt(0) as FlowGroupElement).getChildAt(0).id == "4")
					//redo
					editMan.redo();
					textFlow.flowComposer.updateAllControllers();				
					if(subroot.getChildAt(0) is SpanElement){					
						assertTrue(combinedNames + ": fail to redo.",
							subroot.getChildAt(1).id == "3" 
							&& subroot.getChildAt(0) is SpanElement
							&& (subroot.getChildAt(1) as FlowGroupElement).getChildAt(0).id == "4");					
					}else{					
						assertTrue(combinedNames + ": fail to redo.",
							subroot.getChildAt(0).id == "2"
							&& subroot.getChildAt(2).id == "3"
							&& (subroot.getChildAt(2) as FlowGroupElement).getChildAt(0).id == "4");
					}				
				}catch(e:Error){
					assertTrue(combinedNames + ": " + e.getStackTrace(),false);
				}		
			}					
		}
		
		public function createDivOperation():void
		{
			var divElementCreated:DivElement = SelManager.createDiv();
			var tf:TextFlow = SelManager.textFlow;
			
			var divFound:int = 0;
			var elem:FlowElement = tf.getChildAt(0);
			while (elem)
			{
				if (elem as DivElement)
				{
					var divElement:DivElement = elem as DivElement;
					assertTrue("div element found doesn't match what was returned by createDiv()", divElement == divElementCreated);
					divFound++;
				}
				elem = elem.getNextSibling();
			}
			assertTrue("Expected one div element in the flow found: " + divFound, divFound == 1);
		}
		
		public function InsertInlineGraphicOperationSetGetTest():void
		{
			var src:String = LoaderUtil.createAbsoluteURL(baseURL,"../../test/testFiles/assets/leaves.jpg");
			var width:int = 30;
			var height:int = 30;
			
			var selectionBegin:int = 10;
			var selectionEnd:int = 10;
			SelManager.selectRange(selectionBegin, selectionEnd);
			var operation:InsertInlineGraphicOperation = new InsertInlineGraphicOperation(SelManager.getSelectionState(),
						src, width, height,"none");
			//set and get source
			operation.source = "../../test/testFiles/assets/smiling.png";
			var src_exp:Object = operation.source;
			//set and get width
			operation.width = 50;
			var width_exp:Object = operation.width;
			//set and get height
			operation.height = 50;
			var height_exp:Object = operation.height;
			assertTrue("operation didn't get expected width and height.", width_exp == 50 && height_exp == 50
			           && src_exp == "../../test/testFiles/assets/smiling.png");
			SelManager.insertInlineGraphic(src_exp,width_exp,height_exp);
			SelManager.textFlow.flowComposer.updateAllControllers();
		}
		
		public function MoveChildrenOperationTest():void
		{	
			var tf:TextFlow = SelManager.textFlow;
			SelManager.selectAll();
			SelManager.deleteText();
			
			var s1:SpanElement = new SpanElement();
			s1.text = "first span";
			var s2:SpanElement = new SpanElement();
			s2.text = "second span";
			var p1:ParagraphElement = new ParagraphElement();
			p1.addChild(s1);
			var p2:ParagraphElement = new ParagraphElement();
			p2.addChild(s2);
			var list:ListElement = new ListElement();
			list.listStyleType = ListStyleType.DECIMAL;
			
			SelManager.textFlow.addChild(list);
			var item1:ListItemElement = new ListItemElement();
			var item2:ListItemElement = new ListItemElement();
			list.addChild(item1);
			list.addChild(item2);
			item1.addChild(p1);
			item2.addChild(p2);
			list.addChild(new ListItemElement());
			SelManager.textFlow.flowComposer.updateAllControllers();
			SelManager.selectRange(16, 16);
			var selectionState:SelectionState = SelManager.getSelectionState();
			var leaf:FlowLeafElement = SelManager.textFlow.findLeaf(selectionState.absoluteStart);
			var para:ParagraphElement = leaf.getParagraph();
			var source:FlowGroupElement = para.parent.parent;
			var numElementsToMove:int = 2;
			var target:FlowGroupElement = para.parent.parent;
			var targetIndex:int = target.getChildIndex(source);
			
			var operation:MoveChildrenOperation = new MoveChildrenOperation(selectionState, source, 5, numElementsToMove, target, targetIndex);
			//reset value for operation to test setter
			operation.sourceIndex = 0;
			operation.destinationIndex = 0;
			operation.source = para.parent;
			operation.numChildren = 1;
			operation.destination = para.parent.parent;
			SelManager.doOperation(operation);
			
			//Verify values after get to test getter
			assertTrue ("Value has been changed after set and get", operation.sourceIndex == 0 && operation.destinationIndex ==1
				&& operation.source.defaultTypeName == "li" && operation.numChildren == 1
				&& operation.destination.defaultTypeName == "list");
		}
		
		public function ApplyFormatOperationTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			SelManager.selectAll();
			SelManager.deleteText();
			
			var s:SpanElement = new SpanElement();
			s.text = "AAAAAAAAAAAAAAAAAAAAAAA";
			var p:ParagraphElement = new ParagraphElement();
			p.addChild(s);
			SelManager.textFlow.addChild(p);
		
			SelManager.textFlow.flowComposer.updateAllControllers();
			var selectState:SelectionState = new SelectionState(SelManager.textFlow, 3, 6);
			var leafFormat:TextLayoutFormat = new TextLayoutFormat();
			leafFormat.fontSize = 18;
			var paragraphFormat:TextLayoutFormat = new TextLayoutFormat();
			paragraphFormat.paragraphSpaceBefore = 10;
			var containerFormat:TextLayoutFormat = new TextLayoutFormat();
			containerFormat.columnCount = 1;
			
			var op:ApplyFormatOperation = new ApplyFormatOperation(
					selectState, leafFormat, paragraphFormat, containerFormat);
			var success:Boolean = op.doOperation();
			
			assertTrue("ApplyFormatOperation failed.", success == true );
		
			//to test getter for leafFormat, paragraphFormat and containerFormat
			assertTrue("ApplyFormatOpeartion didn't get correct values.",
				        op.leafFormat.fontSize == 18 &&
						op.paragraphFormat.paragraphSpaceBefore == 10 &&
						op.containerFormat.columnCount == 1);
		}
	}
}
