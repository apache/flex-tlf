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
	import UnitTest.ExtendedClasses.TestDescriptor;
	import UnitTest.ExtendedClasses.TestSuiteExtended;
	import UnitTest.ExtendedClasses.VellumTestCase;
	import UnitTest.Fixtures.TestConfig;
	import UnitTest.Fixtures.TestEditManager;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.events.FlowOperationEvent;
	import flashx.textLayout.events.SelectionEvent;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.operations.FlowOperation;
	import flashx.textLayout.operations.UndoOperation;
	import flashx.textLayout.tlf_internal;
	import flashx.undo.UndoManager;
 	use namespace tlf_internal;


 	public class GeneralFunctionsTest extends VellumTestCase
	{
		public var SelectionChanged:Boolean;
		private var callback:Boolean;

		public function GeneralFunctionsTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super(methodName, testID, testConfig);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Editing";
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "arrowLeft", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "arrowRight", testConfig) );
			//ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "arrowDown", testConfig) );
			//ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "arrowUp", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "replaceSelectionTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "backSpaceSelectionTest", testConfig) ); // KJT
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "backSpaceInsertionPointTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "backSpaceLowerLimitTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "deleteSelectionTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "deleteInsertionPointTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "deleteUpperLimitTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "splitParagraphInsertionPointTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "splitParagraphSelectionTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "splitParagraphFormatTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "unDoOp", testConfig) ); // undo redo// KJT
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "setSelectionRangeTest", testConfig) );// select range and listen for change event // KJT
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "insertTextTest", testConfig) ); // KJT
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "joinedBackspaceUndoTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "joinedDeleteUndoTest", testConfig) );
			/* Waiting for troubleshooting -*/ ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "joinedInsertUndoTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "joinedSplitParagraphUndoTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "undoLimitTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "transParagraphDeleteTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "emptyParagraphTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "splitUTF16Test", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "splitUTF32Test", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "undoWithModelChangeTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "doubleClickTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "doubleClickHyphenTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "doubleClickPunctuationTest", testConfig) );
			ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "undoRedoStackTest", testConfig) );
			if (testConfig.writingDirection[0] == BlockProgression.TB && testConfig.writingDirection[1] == Direction.LTR)
			{
				ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "replaceChildrenFlowTest", testConfig) );
				ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "resolveInlinesTest", testConfig) );
				ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "nestingTest", testConfig) );
				ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "errorThrowing", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor(GeneralFunctionsTest, "AllNestingTest", testConfig ) );
			}
		}

		/**
		* selecting text from 10 to 20
		*/

		public function selChange(e:Event):void //KJT selection change event method
		{
			SelectionChanged = true;
		}

		public function setSelectionRangeTest():void  //KJT  test selection range and change event
		{
			var startIndx:int = 800;
			var endIndx:int = 933;
			//trace('CALL SET SELECTION');

			SelManager.textFlow.addEventListener(SelectionEvent.SELECTION_CHANGE, selChange, false, 0, true);
			SelManager.selectRange(startIndx,endIndx);

			assertTrue("beginning index should be 800, but is " + SelManager.anchorPosition,
						SelManager.anchorPosition == 800);
			assertTrue("end index should be 933, but is " + SelManager.activePosition,
						SelManager.activePosition == 933);
			assertTrue("SelectionChanged returned false", SelectionChanged == true);
		}
		/**
 		 * Select 40 characters and replaces them with new text
 		 */
		public function replaceSelectionTest():void
		{
			var startIndx:int = 10;
			var endIndx:int = 50;

			var attributes:TextLayoutFormat  = new TextLayoutFormat();
			attributes.fontWeight = FontWeight.BOLD;
			attributes.lineThrough = true;

			SelManager.selectRange(startIndx,endIndx);
			SelManager.applyLeafFormat(attributes);

			SelManager.insertText("New");
			SelManager.flushPendingOperations();

			var leaf:FlowLeafElement = SelManager.textFlow.findLeaf(startIndx);
			var attributesNew:ITextLayoutFormat = leaf.format;
			assertTrue("Invalid point format after block deletion", TextLayoutFormat.isEqual(attributes, attributesNew));
		}
		/**
 		 * Select 40 characters and delete them.
 		 */
		public function backSpaceSelectionTest():void
		{
			var startIndx:int = 10;
			var endIndx:int = 50;

			var attributes:TextLayoutFormat  = new TextLayoutFormat();
			attributes.fontWeight = FontWeight.BOLD;
			attributes.lineThrough = true;

			SelManager.selectRange(startIndx,endIndx);
			SelManager.applyLeafFormat(attributes);

			var initLength:uint = SelManager.textFlow.textLength;
			SelManager.deletePreviousCharacter();
			var endLength:uint = SelManager.textFlow.textLength;

			assertTrue("deleting the selection should have removed " +(endIndx - startIndx) +
						" characters.  It actually removed " + (initLength - endLength),
						endLength == initLength - (endIndx - startIndx) );

			SelManager.insertText("New");
			SelManager.flushPendingOperations();

			var leaf:FlowLeafElement = SelManager.textFlow.findLeaf(startIndx);
			var attributesNew:ITextLayoutFormat = leaf.format;
			assertTrue("Invalid point format after block deletion", TextLayoutFormat.isEqual(attributes, attributesNew));
		}

		/**
 		 * Set the cursor position back ten characters and delete the first ten characters.
 		 */
		public function backSpaceInsertionPointTest():void
		{
			var n:int = 10;
			SelManager.selectRange(n,n);

			var initLength:uint = SelManager.textFlow.textLength;

			for(var i:int = 0; i < n; i++){
				SelManager.deletePreviousCharacter();
			}

			var endLength:uint = SelManager.textFlow.textLength;

			assertTrue("should have removed " + n + " characters.  Actually removed " +
						(initLength - endLength) , endLength == initLength - n);
		}

		/**
 		 * Set the cursor position back nine characters and delete the first ten characters.
 		 * Ensure that only nine characters are deleted.
 		 */
		public function backSpaceLowerLimitTest():void
		{
			var n:int = 9;
			SelManager.selectRange(n,n);

			var initLength:uint = SelManager.textFlow.textLength;

			for(var i:int = 0; i <= n; i++){
				SelManager.deletePreviousCharacter();
			}

			var endLength:uint = SelManager.textFlow.textLength;

			assertTrue("should have removed " + n + " characters.  Actually removed " +
						(initLength - endLength) , endLength == initLength - n);
		}

		/**
 		 * Select 40 characters and delete them.
 		 */
		public function deleteSelectionTest():void
		{
			var startIndx:int = 10;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx,endIndx);

			var initLength:uint = SelManager.textFlow.textLength;
			SelManager.deleteNextCharacter();
			var endLength:uint = SelManager.textFlow.textLength;

			assertTrue("should have removed " + (endIndx - startIndx) + " characters.  Actually removed " +
						(initLength - endLength) , endLength == initLength - (endIndx - startIndx) );
		}

		/**
 		 * Delete the first ten characters.
 		 */
		public function deleteInsertionPointTest():void
		{
			var n:int = 10;
			SelManager.selectRange(0,0);

			var initLength:uint = SelManager.textFlow.textLength;

			for(var i:int = 0; i < n; i++){
				SelManager.deleteNextCharacter();
			}

			var endLength:uint = SelManager.textFlow.textLength;

			assertTrue("should have removed " + n + " characters.  Actually removed " +
						(initLength - endLength), endLength == initLength - n);
		}

		/**
 		 * Set the cursor position back nine characters and delete the first ten characters.
 		 * Ensure that only nine characters are deleted.
 		 */
		public function deleteUpperLimitTest():void
		{
			var n:int = 9;

			var initLength:uint = SelManager.textFlow.textLength;
			SelManager.selectRange(initLength - (n+1), initLength - (n+1));

			for(var i:int = 0; i < n; i++){
				SelManager.deleteNextCharacter();
			}

			var endLength:uint = SelManager.textFlow.textLength;

			assertTrue("should have removed " + n + " characters.  Actually removed " +
						(initLength - endLength) , endLength == initLength - n);
		}

		/**
		 * Splits the paragraph after the first fifty characters.
		 * Verifies that there is one more line in the textFlow than it started with.
		 * Verifies that the first leaf has only 50 characters in it.
		 */
		public function splitParagraphInsertionPointTest():void
		{
			var insertPoint:int = 50;

			SelManager.selectRange(insertPoint, insertPoint);

			var initLines:int = SelManager.textFlow.flowComposer.numLines;
			SelManager.splitParagraph();
			var endLines:int = SelManager.textFlow.flowComposer.numLines;

			assertTrue("expected one additional line after splitting the paragraph.  Actually found " +
						(endLines - initLines), initLines = endLines - 1);

			var lengthFirst:int = SelManager.textFlow.getFirstLeaf().textLength;

			assertTrue("expected the first paragraph would have " + insertPoint +
						" characters.  Actually found " + lengthFirst, lengthFirst = insertPoint);
		}

		/**
		 * 1. Sets attributes before (A, B), after (B', C) and at (B'', D) at split point.
		 * Splits paragraphs, adds new text and verifies that it has attributes (A, B'', C, D)
	     * 2. Tests special case for splitting a paragraph at the end of a link; point format is reset in this case
		 */
		public function splitParagraphFormatTest():void
		{
			var insertPoint:int = 50;

			var attributes:TextLayoutFormat  = new TextLayoutFormat();

			attributes.fontWeight = FontWeight.BOLD;
			attributes.lineThrough = true;
			SelManager.selectRange(insertPoint-5, insertPoint);
			SelManager.applyLeafFormat(attributes);

			attributes.fontWeight = undefined;
			attributes.textDecoration = flashx.textLayout.formats.TextDecoration.UNDERLINE;
			attributes.fontSize = 72;
			SelManager.selectRange(insertPoint, insertPoint+5);
			SelManager.applyLeafFormat(attributes);

			attributes.textDecoration = flashx.textLayout.formats.TextDecoration.UNDERLINE;
			attributes.lineThrough = true;
			attributes.fontFamily = "Verdana";
			SelManager.selectRange(insertPoint, insertPoint);
			SelManager.applyLeafFormat(attributes);

			SelManager.splitParagraph();

			SelManager.insertText("New");
			SelManager.flushPendingOperations();

			var leaf:FlowLeafElement = SelManager.textFlow.findLeaf(insertPoint+1);
			attributes = new TextLayoutFormat(leaf.format);

			assertTrue("Invalid point format for start of a new paragraph", attributes.fontWeight = FontWeight.BOLD);
			assertTrue("Invalid point format for start of a new paragraph", attributes.fontSize = 72);
			assertTrue("Invalid point format for start of a new paragraph", attributes.fontFamily = "Verdana");
			assertTrue("Invalid point format for start of a new paragraph", attributes.textDecoration == flashx.textLayout.formats.TextDecoration.UNDERLINE && attributes.lineThrough);

			insertPoint = 40;

			SelManager.selectRange(insertPoint-10, insertPoint);
			SelManager.applyLink("http://www.google.com", "_self", false);

			SelManager.selectRange(insertPoint, insertPoint);
			SelManager.splitParagraph();

			SelManager.insertText("New");
			SelManager.flushPendingOperations();

			leaf = SelManager.textFlow.findLeaf(insertPoint+1);
			attributes = new TextLayoutFormat(leaf.format);
			assertTrue("Invalid point format for start of a new paragraph after a link", TextLayoutFormat.isEqual(attributes, TextLayoutFormat.emptyTextLayoutFormat));
		}

		/**
		 * Selects the characters between the 10th and 50th characters and splits the paragraph.
		 * Verifies that there is one more line in the textFlow than it started with.
		 * Verifies that the first leaf has only 10 characters in it.
		 * Verifies that the final length has 39 less characters in it.
		 */
		public function splitParagraphSelectionTest():void
		{
			var startIndx:int = 10;
			var endIndx:int = 50;


			SelManager.selectRange(startIndx, endIndx);

			var initLength:int = SelManager.textFlow.textLength;
			var initLines:int = SelManager.textFlow.flowComposer.numLines;

			SelManager.splitParagraph();

			var endLength:int = SelManager.textFlow.textLength;
			var endLines:int = SelManager.textFlow.flowComposer.numLines;

			assertTrue("expected one additional line after splitting the paragraph.  Actually found " +
						(endLines - initLines), initLines = endLines - 1);

			var lengthFirst:int = SelManager.textFlow.getFirstLeaf().textLength;

			assertTrue("expected the first paragraph would have " + startIndx +
						" characters.  Actually found " + lengthFirst, lengthFirst = startIndx);
			assertTrue("expected the entire flow would have " + (initLength - (endIndx - startIndx) + 1) +
						" characters.  Actually found " + endLength,
						endLength == initLength - (endIndx - startIndx) + 1);
		}

		/**
		 * Creates a selection area of six characters at the last index of the flow root
		 * then inserts " BOOGA" into the selection area and verifies the length of the
		 * flow root has increased by 6.
		 */
		public function insertTextTest():void //KJT
		{
			var textLength:uint = SelManager.textFlow.textLength;
			SelManager.selectRange(textLength - 1, textLength + 5);

			SelManager.insertText(" BOOGA");
			SelManager.selectRange(textLength - 1,textLength + 5);

		 	assertTrue("expected to find " + (textLength + 6) + " characters.  Actually found " +
		 				SelManager.textFlow.textLength, SelManager.textFlow.textLength == textLength + 6);
		}

		/**
		 * Sets the insertion point at 50, then generates the "0" keyboard event
		 * and verifies that the selBegIdx is 49.
		 */
		public function arrowLeft():void
		{
			var event:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.LEFT);
			SelManager.selectRange(50,50);
			SelManager.keyDownHandler(event);

			if(SelManager.textFlow.computedFormat.blockProgression == BlockProgression.RL)
			{
//				assertTrue("expected insertion point at position 87. Actually found + " +
//	    				SelManager.anchorPosition, SelManager.anchorPosition == 87);
			}
			else
	    		{
	    			if(SelManager.textFlow.computedFormat.direction == Direction.LTR)
	    			{
	    				assertTrue("expected insertion point at position 49. Actually found + " +
	    				SelManager.activePosition, SelManager.activePosition == 49);
	    			}
	    			else
	    			{
	    				assertTrue("expected insertion point at position 51. Actually found + " +
	    				SelManager.activePosition, SelManager.activePosition == 51);
	    			}
	    		}
		}

		/**
		 * Sets the insertion point at 50, then generates the "0" keyboard event
		 * and verifies that the selBegIdx is 51.
		 */
		public function arrowRight():void
		{
			var event:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.RIGHT);
			SelManager.selectRange(50,50);
			SelManager.keyDownHandler(event);
			if(SelManager.textFlow.computedFormat.blockProgression == BlockProgression.RL)
			{
//				assertTrue("expected insertion point at position 11. Actually found + " +
//	    				SelManager.anchorPosition, SelManager.anchorPosition == 11);
			}
			else
    		{
    			if(SelManager.textFlow.computedFormat.direction == Direction.LTR)
    			{
	    			assertTrue("expected insertion point at position 51. Actually found " +
	    				SelManager.activePosition, SelManager.activePosition == 51);
    			}
    			else
    			{
    				assertTrue("expected insertion point at position 49. Actually found " +
	    				SelManager.activePosition, SelManager.activePosition == 49);
    			}
    		}
		}

		/**
		 * Sets the insertion point at 0, then generates the "40" keyboard event
		 * and verifies that the cursor is on the second line.
		 */
		public function arrowDown():void
		{
			var event:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_UP, true, false,40);
			SelManager.selectRange(0,0);
			SelManager.keyDownHandler(event);
			if(SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				//NYI
			}
			else
    		{
    			var ap:int = SelManager.activePosition;
    			var index:int = SelManager.textFlow.findChildIndexAtPosition(ap);
    			assertTrue("expected index at 2. Actually found " + index, index == 2);
    		}
		}

		/**
		 * Sets the insertion point at the last char, then generates the "38" keyboard event
		 * and verifies that the cursor is on the second to last line.
		 */
		public function arrowUp():void
		{
			var event:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_UP, true, false,38);
			var lastChar:int = SelManager.absoluteEnd;
			var lastLine:int = SelManager.textFlow.findChildIndexAtPosition(lastChar);
			SelManager.selectRange(lastChar,lastChar);
			SelManager.keyDownHandler(event);
			if(SelManager.textFlow.computedFormat.blockProgression == BlockProgression.TB)
			{
				//NYI
			}
			else
    		{
    			var index:int = SelManager.textFlow.findChildIndexAtPosition(SelManager.activePosition);
    			assertTrue("expected index at " + (lastChar - 1) +
    						". Actually found " + index,
    						index == (lastChar - 1)
    			);
    		}
		}

		/**
 		 * Tests the undo and redo stacks by applying typeface changes by undoing
 		 * and redoing them.
 		 */
		public function unDoOp():void  //KJT
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.fontWeight = FontWeight.BOLD;
			SelManager.applyLeafFormat(ca);

			SelManager.undo();
			Redo();

			ca.fontStyle = FontPosture.ITALIC;
			SelManager.applyLeafFormat(ca);

			SelManager.undo();
			SelManager.undo();
		}

		/**
		 * Performs successive backspaces and one undo to see if all the deleted content
		 * is returned, then performs a redo to see if the content is correctly removed
		 * again.
		 */
		public function joinedBackspaceUndoTest():void
		{
			var n:int = 10;
			SelManager.selectRange(10,10);

			var initLength:uint = SelManager.textFlow.textLength;

			for(var i:int = 0; i < n; i++){
				var event:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 8);
				dispatchEvent(event);
			}

			var endLength:uint = SelManager.textFlow.textLength;

			SelManager.undo();

			var undoLength:uint = SelManager.textFlow.textLength;

			assertTrue("expected text length before undo to be " + n + " less.  Was actually " +
						(endLength - initLength) + " less.", endLength == initLength - n );
			assertTrue("expected text length after undo to be identical to the start, but it was off by " +
						(undoLength-initLength), undoLength == initLength);

			Redo();

			var redoLength:uint = SelManager.textFlow.textLength;

			assertTrue("expected redo length to equal undo length, but found " +
						redoLength + " and " + endLength, redoLength == endLength);
		}

		/**
		 * Performs successive deletes and one undo to see if all the deleted content
		 * is returned, then performs a redo to see if the content is correctly removed
		 * again.
		 */
		public function joinedDeleteUndoTest():void
		{
			var n:int = 10;
			SelManager.selectRange(10,10);

			var initLength:uint = SelManager.textFlow.textLength;

			for(var i:int = 0; i < n; i++){
				var event:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 127, Keyboard.DELETE);
				dispatchEvent(event);
			}
			SelManager.flushPendingOperations();

			var endLength:uint = SelManager.textFlow.textLength;

			SelManager.undo();

			var undoLength:uint = SelManager.textFlow.textLength;

			assertTrue("expected text length before undo to be " + n + " less.  Was actually " +
						(endLength - initLength) + " less.", endLength == initLength - n );
			assertTrue("expected text length after undo to be identical to the start, but it was off by " +
						(undoLength-initLength), undoLength == initLength);

			Redo();

			var redoLength:uint = SelManager.textFlow.textLength;

			assertTrue("expected redo length to equal undo length, but found " +
						redoLength + " and " + endLength, redoLength == endLength);
		}

		/**
		 * Places a series of letter a's in and does one undo to see if all the a's
		 * are removed, then performs a redo to see if they're returned.
		 */
		public function joinedInsertUndoTest():void
		{
			var n:int = 10;
			SelManager.selectRange(10,10);

			var initLength:uint = SelManager.textFlow.textLength;

			for(var i:int = 0; i < n; i++){
				var event:TextEvent = new TextEvent(TextEvent.TEXT_INPUT,false,false,"a");
				dispatchEvent(event);
			}

			SelManager.flushPendingOperations();

			var endLength:uint = SelManager.textFlow.textLength;

			SelManager.undo();

			var undoLength:uint = SelManager.textFlow.textLength;

			assertTrue("expected text length before undo to be " + n + " more.  Was actually " +
						(endLength - initLength) + " less.", endLength == initLength + n );
			assertTrue("expected text length after undo to be identical to the start, but it was off by " +
						(undoLength-initLength), undoLength == initLength);
			Redo();

			var redoLength:uint = SelManager.textFlow.textLength;

			assertTrue("expected redo length to equal undo length, but found " +
						redoLength + " and " + endLength, redoLength == endLength);
		}

		/**
		 * Performs successive enters and one undo to see if all paragraph splits are
		 * undone, then performs a redo to see if they're all redone.
		 */
		public function joinedSplitParagraphUndoTest():void
		{
			var n:int = 10;
			SelManager.selectRange(10,10);

			var initLength:uint = SelManager.textFlow.textLength;

			for(var i:int = 0; i < n; i++){
				var event:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 13);
				dispatchEvent(event);
			}

			var endLength:uint = SelManager.textFlow.textLength;

			SelManager.undo();

			var undoLength:uint = SelManager.textFlow.textLength;

			assertTrue("expected text length before undo to be " + n + " more.  Was actually " +
						(endLength - initLength) + " less.", endLength == initLength + n );
			assertTrue("expected text length after undo to be identical to the start, but it was off by " +
						(undoLength-initLength), undoLength == initLength);

			Redo();

			var redoLength:uint = SelManager.textFlow.textLength;

			assertTrue("expected redo length to equal undo length, but found " +
						redoLength + " and " + endLength, redoLength == endLength);
		}

		/**
		 * Create a new undo manager with an undo limit of ten, then perform eleven
		 * undoable operations and see how many times it will let you undo.
		 */
		public function undoLimitTest():void
		{
			var undo:UndoManager = new UndoManager();
			var n:int = 10;
			undo.undoAndRedoItemLimit = n;

			var newSM:EditManager = new EditManager(undo);
			SelManager = newSM;
			TestFrame.rootElement.getTextFlow().interactionManager = newSM;

			//SelManager.selectRange(n,n);

			for(var i:int = 0; i < n + 1; i++){
				SelManager.selectRange(n,n+i);
				var event:KeyboardEvent = (i % 2 == 0) ?
					new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 13):
					new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 8);
				dispatchEvent(event);
				SelManager.selectRange(-1,-1);
			}

			var u:int = 0;
			while(undo.canUndo()){
				SelManager.undo();
				u++;
			}

			assertTrue("expected only " + n + " undos but found " + u, u == n);
		}
		
		
		public function undoRedoStackTest():void
		{
			var undo:UndoManager = new UndoManager();
			var n:int = 10;
			undo.undoAndRedoItemLimit = n;
			
			var newSM:EditManager = new EditManager(undo);
			SelManager = newSM;
			TestFrame.rootElement.getTextFlow().interactionManager = newSM;
			
			//do n operations
			for(var i:int = 0; i < n + 1; i++){
				SelManager.selectRange(n,n+i);
				var event:KeyboardEvent = (i % 2 == 0) ?
					new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 13):
					new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 8);
				dispatchEvent(event);
				SelManager.selectRange(-1,-1);
			}
			var testManager:TestEditManager = new TestEditManager(undo);
			var stackItemNum:int = testManager.UndoRedoEntireStack(undo);

			assertTrue("expected only " + n + " undos but found " + stackItemNum, stackItemNum == n);
		}

		/**
		 * Select a section of text that spans paragraphs then delete it and see if the
		 * size of the flow goes down by the appropriate amount.
		 */
		public function transParagraphDeleteTest():void
		{
			var startLength:int = TestFrame.rootElement.textLength;

			var flow1:FlowElement;
			var flow2:FlowElement;

			var start:int = 0;
			var finish:int = 0;

			var origParas:int = TestFrame.rootElement.numChildren;

			//Look for two back to back paragraphs.
			for(var i:int = 0; i < TestFrame.rootElement.numChildren-1; i++){
				flow1 = TestFrame.rootElement.getChildAt(i);
				flow2 = TestFrame.rootElement.getChildAt(i+1);

				if(flow1 is ParagraphElement && flow2 is ParagraphElement){
					finish = start + flow1.textLength + flow2.textLength/2;
					start = start + flow1.textLength/2;
					break;
				}else{
					start = start + flow1.textLength;
				}
			}

			assertTrue("expected finish to be in the middle of the second para, but it's still 0", finish != 0);

			var para1:ParagraphElement = flow1 as ParagraphElement;
			var para2:ParagraphElement = flow2 as ParagraphElement;

			var attrib1:ITextLayoutFormat = para1.computedFormat;
			var pa:TextLayoutFormat = new TextLayoutFormat();
			if(attrib1.textAlign == TextAlign.CENTER)
				pa.textAlign = TextAlign.LEFT;
			else
				pa.textAlign = TextAlign.CENTER;


			SelManager.selectRange(para2.getAbsoluteStart(),para2.getAbsoluteStart() + 1);

			SelManager.applyParagraphFormat(pa);

			var attrib2:ITextLayoutFormat = para2.computedFormat;
			assertTrue("para1 and para2 paraAttrs must be different for this test to work!",
				!TextLayoutFormat.isEqual(attrib1,attrib2)
			);

			SelManager.selectRange(start,finish);
			SelManager.deleteNextCharacter();
			var finishLength:int = TestFrame.rootElement.textLength;

			assertTrue("expected " + (finish-start) + " less characters but found " +
						(startLength - finishLength) + " less", startLength - finishLength == finish - start);

			/*
			 * TODO: this tests current behavior. Proper behavior would be only one
			 * remaining paragraph.
			 */

			assertTrue("number of paragraphs should have decreased!", origParas > TestFrame.rootElement.numChildren);

			var finalPara:ParagraphElement = TestFrame.rootElement.getChildAt(i) as ParagraphElement;
			var finalAttrs:ITextLayoutFormat = finalPara.computedFormat;

			assertTrue("paragraph attributes changed and should be the same!",TextLayoutFormat.isEqual(attrib1,finalAttrs));
		}

		/**
		 * Create an empty paragraph and select the 0 position in it.
		 * Then delete all the content on the flow and see if the position selected is 0.
		 */
		public function emptyParagraphTest():void
		{
			SelManager.selectRange(0,0);

			var returnevent:KeyboardEvent =
				new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 13);
			dispatchEvent(returnevent);

			SelManager.selectRange(0,0);
			assertTrue("did not start with selection at 0,0", SelManager.anchorPosition == 0 && SelManager.activePosition == 0);
			SelManager.selectAll();
			SelManager.deleteNextCharacter();
			assertTrue("did not end with selection at 0,0 after delete all", SelManager.anchorPosition == 0 && SelManager.activePosition == 0);
		}

		public function splitUTF16Test():void
		{
			// remove all text
			SelManager.selectAll();
			SelManager.deleteNextCharacter();

			var a:uint = 0xD866; var b:uint = 0xDDC1;
			var c:uint = 0xD869; var d:uint = 0xDED6;
			var e:uint = 0xD8BF; var f:uint = 0xDFFD;

			var y:String = String.fromCharCode(a,b,c,d,e,f);
			SelManager.insertText(y);
			SelManager.flushPendingOperations();

			var begin:int = 0;
			var end:int = SelManager.textFlow.textLength;
			var middle:int = ((end-1) - begin)/2;
			SelManager.selectRange(middle, middle);

			var gotRangeError:Boolean = false;
			try
			{
				SelManager.splitParagraph();
				SelManager.flushPendingOperations();
			}
			catch ( e:RangeError )
			{
				gotRangeError = true;
			}
			/* See bug #1798067 */
			assertTrue( "Spliting a surrogate pair did not throw an error", gotRangeError );

			SelManager.selectAll();

			var charAttr:TextLayoutFormat = new TextLayoutFormat();
			charAttr.fontFamily = "Adobe Song Std L";

			SelManager.applyLeafFormat(charAttr);
			SelManager.flushPendingOperations();

			//trace(begin + ", " + middle + ", " + end);
		}

		public function splitUTF32Test():void
		{
			// remove all text
			SelManager.selectAll();
			SelManager.deleteNextCharacter();

			var y:String = String.fromCharCode(0x00028023);
			y = y + y + y;

			SelManager.insertText(y);
			SelManager.flushPendingOperations();

			var begin:int = 0;
			var end:int = SelManager.textFlow.textLength;
			var middle:int = ((end-1) - begin)/2;
			SelManager.selectRange(middle, middle);

			SelManager.splitParagraph();
			SelManager.flushPendingOperations();

			SelManager.selectAll();

			var charAttr:TextLayoutFormat = new TextLayoutFormat();
			charAttr.fontFamily = "Adobe Song Std L";

			SelManager.applyLeafFormat(charAttr);
			SelManager.flushPendingOperations();

			//trace(begin + ", " + middle + ", " + end);
		}


		// pick up the actual operation
		private var flowOp:FlowOperation;

		private function listenForOpBegin(opEvent:FlowOperationEvent):void
		{
			flowOp = opEvent.operation;
		}

		/**
		 * Performs an operation, clear the selection manager and then make sure the operation doesn't undo
		 */
		public function undoWithModelChangeTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var selManager:EditManager = SelManager;

			selManager.selectAll();

			var initLength:uint = SelManager.textFlow.textLength;


			flowOp = null;
			tf.addEventListener(FlowOperationEvent.FLOW_OPERATION_BEGIN,listenForOpBegin,false,0,true);

			// now do an operation
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.color = 0xff;
			selManager.applyFormatToElement(tf, ca);

			assertTrue("no begin operation event",flowOp != null);
			assertTrue("textFlow characterFormat.color should be 0xff",tf.format && tf.format.color == 0xff);

			// clear the selection manager
			tf.interactionManager = null;
			// now I've got a hold of the operation.  do an out of bounds model modification and then attempt an undo
			tf.color = 0xff00;
			assertTrue("textFlow characterFormat.color should be 0xff",tf.format.color == 0xff00);

			// now restore the interactionManager
			tf.interactionManager = selManager;
			// CONFIG::debug { trace("GeneralFunctionsTest.undoWithModelChangeTest: expect to see message regarding skipping undo due to mismatched generation numbers."); }
			// try to do an undo
			selManager.undo();

			// it should be skipped
			assertTrue("no begin operation event",flowOp != null);
			assertTrue("wrong begin operation event",flowOp is UndoOperation);
			assertTrue("textFlow characterFormat.color should be 0xff00",tf.format && tf.format.color == 0xff00);

			selManager.selectRange(0,0);	// prevent assert in tearDown
		}

		private function Redo():void // KJT
		{
			try {
				SelManager.redo();
			}
			catch(e:Error){
				fail("Redo operation failed.");
			}
		}

		private function dispatchEvent(event:Event):void
		{
			// assume containers support dispatchEvent.  Otherwise we get an error
			TestFrame.container["dispatchEvent"](event);
		}

		public function doubleClickTest():void
		{
			SelManager.selectRange( 68, 68 );
			var mEvent:MouseEvent = new MouseEvent( MouseEvent.DOUBLE_CLICK );
			TestFrame.container["dispatchEvent"](mEvent);

			assertTrue( "Double click failed to correctly select word",
						SelManager.anchorPosition == 65 &&
						SelManager.activePosition == 72 );

			SelManager.selectRange( 955, 955 );
			mEvent = new MouseEvent( MouseEvent.DOUBLE_CLICK );
			TestFrame.container["dispatchEvent"](mEvent);

			assertTrue( "Double click failed to correctly select word",
						SelManager.anchorPosition == 954 &&
						SelManager.activePosition == 957 );
		}

		public function doubleClickHyphenTest():void
		{
			SelManager.selectRange( 24, 24 );
			var mEvent:MouseEvent = new MouseEvent( MouseEvent.DOUBLE_CLICK );
			TestFrame.container["dispatchEvent"](mEvent);

			assertTrue( "Double click failed on a hyphen",
						SelManager.anchorPosition == 24 &&
						SelManager.activePosition == 25 );

			SelManager.selectRange( 498, 498 );
			mEvent = new MouseEvent( MouseEvent.DOUBLE_CLICK );
			TestFrame.container["dispatchEvent"](mEvent);

			assertTrue( "Double click failed on a hyphenated word",
						SelManager.anchorPosition == 496 &&
						SelManager.activePosition == 502 );
		}

		public function doubleClickPunctuationTest():void
		{
			SelManager.selectRange( 951, 951 );
			var mEvent:MouseEvent = new MouseEvent( MouseEvent.DOUBLE_CLICK );
			TestFrame.container["dispatchEvent"](mEvent);

			assertTrue( "Double click failed on a word next to punctuation",
						SelManager.anchorPosition == 945 &&
						SelManager.activePosition == 952 );

			SelManager.selectRange( 1964, 1964 );
			mEvent = new MouseEvent( MouseEvent.DOUBLE_CLICK );
			TestFrame.container["dispatchEvent"](mEvent);

			assertTrue( "Double click failed on punctuation",
						SelManager.anchorPosition == 1963 &&
						SelManager.activePosition == 1966 );
		}

		public function replaceChildrenFlowTest():void
		{
			var caught:Boolean = false;

			try
			{
				SelManager.textFlow.replaceChildren( 0,0, new TextFlow() );
			}
			catch ( err:ArgumentError )
			{
				caught = true;
			}

			assertTrue( "TextFlow.replaceChildren with a TextFlow argument should throw an error", caught );
		}
		private function resolveInlines(ilg:InlineGraphicElement):Object
		{
			return ilg.source == "placeholder" ? new Sprite() : ilg.source;
		}

		private var _ilgStatus:String;
		private function graphicStatusChangeEvent(e:StatusChangeEvent):void
		{
			_ilgStatus = e.status;
		}

		public function resolveInlinesTest():void
		{
			var textFlow:TextFlow;
			const markup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008'><flow:p><flow:img source='placeholder'/></flow:p></flow:TextFlow>";

			var config:Configuration = new Configuration();
			config.inlineGraphicResolverFunction = resolveInlines;
			textFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT, config);

			textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,graphicStatusChangeEvent);

			textFlow.flowComposer.addController(new ContainerController(new Sprite(), 400, 200));
			textFlow.flowComposer.updateAllControllers();

			assertTrue( "Inline Graphic resolution failed",	_ilgStatus == InlineGraphicElementStatus.READY ); //

		}

		public function nestingTest():void
		{
			var link1:LinkElement = new LinkElement();
			var tcy1:TCYElement = new TCYElement();
			var link2:LinkElement = new LinkElement();

			var exceptionThrown:Boolean = false;
			try
			{
				link1.addChild(link2);
			}
			catch (e:*)
			{
				exceptionThrown = true;
			}
			assertTrue("Should not be able to add a link child to a link", exceptionThrown);

			exceptionThrown = false;
			link1.addChild(tcy1);

			try
			{
				tcy1.addChild(link2);
			}
			catch (e:*)
			{
				exceptionThrown = true;
			}
			assertTrue("Should not be able to add a link child to a TCY if the latter is contained in a link", exceptionThrown);

			exceptionThrown = false;
			link1.removeChild (tcy1);
			tcy1.addChild(link2);

			try
			{
				link1.addChild(tcy1);
			}
			catch (e:*)
			{
				exceptionThrown = true;
			}
			assertTrue("Should not be able to add a TCY child to a link if the former contains a link", exceptionThrown);

		}

		private static const customResourceDict:Object = 
		{
			invalidFlowElementConstruct_custom:	"Attempted construct of invalid FlowElement subclass",
			badMXMLChildrenArgument_custom: "Bad element of type {0} passed to mxmlChildren",
			malformedTag:	"Malformed tag </p/>",
			XMLParserFailure:	"TypeError: Error #1090: XML parser failure: element is malformed."
		}
		
		tlf_internal static function customResourceStringFunction(resourceName:String, parameters:Array = null):String
		{
			var value:String = String(customResourceDict[resourceName]);
			
			if (value == null)
			{
				value = String(customResourceDict["missingStringResource"]);
				parameters = [ resourceName ];
			}
			
			if (parameters)
				value = customSubstitute(value, parameters);
			
			return value;
		}
		
		/** @private */
		tlf_internal static function customSubstitute(str:String, ... rest):String
		{
			if (str == null) 
				return '';
			
			// Replace all of the parameters in the msg string.
			var len:uint = rest.length;
			var args:Array;
			if (len == 1 && rest[0] is Array)
			{
				args = rest[0] as Array;
				len = args.length;
			}
			else
			{
				args = rest;
			}
			
			for (var i:int = 0; i < len; i++)
			{
				str = str.replace(new RegExp("\\{"+i+"\\}", "g"), args[i]);
			}
			
			return str;
		}
			
		/** Generate errors and make sure we get the right string */
		public function errorThrowing():void
		{
			var exceptionThrown:Boolean;
			
			//use defaultResourceStringFunction to check the error message
			// Invalid flowElement
			exceptionThrown = false;
			try
			{
				new FlowGroupElement();
			}
			catch (e:Error)
			{
				exceptionThrown = true;
				var invalidFlowElementConstruct_message:String = e.message;
				assertTrue("errorThrowing: Error thrown but message is incorrect",e.message == GlobalSettings.resourceStringFunction("invalidFlowElementConstruct"));
				
			}
			assertTrue("errorThrowing: Expected error on new FlowGroupElement did not occur", exceptionThrown);
			
			// invalid mxmlchildren assignment
			exceptionThrown = false;
			try
			{
				var s:Sprite = new Sprite();
				new DivElement().mxmlChildren = [ s ];
			}
			catch (e:Error)
			{
				exceptionThrown = true;
				var badMXMLChildrenArgument_message:String = e.message;
				assertTrue("errorThrowing: Error thrown but message is incorrect",e.message == GlobalSettings.resourceStringFunction("badMXMLChildrenArgument",[ getQualifiedClassName(s) ]));
			}
			assertTrue("errorThrowing: Expected error on bad MXMLChildren argument did not occur", exceptionThrown);
			
			//use customResourceStringFunction to check the error message
			try
			{
				GlobalSettings.resourceStringFunction= customResourceStringFunction;
				
				//check Invalid flowElement and invalid mxmlchildren assignment
				assertTrue("errorThrowing: Error thrown but message is incorrect", GlobalSettings.resourceStringFunction("invalidFlowElementConstruct_custom") == invalidFlowElementConstruct_message);
				assertTrue("errorThrowing: Error thrown but message is incorrect", GlobalSettings.resourceStringFunction("badMXMLChildrenArgument_custom",[ getQualifiedClassName(s) ]) == badMXMLChildrenArgument_message);
				
				//use custom resource string function to test HTML importer error
				exceptionThrown = false;
				var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
				var textFlow:TextFlow;
				
				var markup:String = '<p>Malformed tag next</p/>';
				textFlow = textImporter.importToFlow(markup);
				
				if (textImporter.errors)
				{
					exceptionThrown = true;
					assertTrue("errorThrowing: Error thrown but message is incorrect",textImporter.errors == GlobalSettings.resourceStringFunction("malformedTag"));
				}
				assertTrue("errorThrowing: Expected error on importer did not occur", exceptionThrown);
				
				//use custom resource string function to test Text importer error
				exceptionThrown = false;
				markup = "<TextFlow columnCount='inherit'" 
					+ "<span>Ethan Brand</span></a></p></TextFlow>";
				
		        textImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
				textFlow = textImporter.importToFlow(markup);
			
				if (textImporter.errors)
				{
					exceptionThrown = true;
					assertTrue("errorThrowing: Error thrown but message is incorrect",textImporter.errors == GlobalSettings.resourceStringFunction("XMLParserFailure"));
				}
				assertTrue("errorThrowing: Expected error on XML Parser Failure did not occur", exceptionThrown);
			}
			finally
			{
				GlobalSettings.resourceStringFunction = GlobalSettings.defaultResourceStringFunction;
			}
		
		}
		
		public static const childParentTable:Array = 
		[
			[ "child\parent",			TextFlow,	DivElement, ParagraphElement, LinkElement, TCYElement, SpanElement, InlineGraphicElement, BreakElement, TabElement, ListElement, ListItemElement, SubParagraphGroupElement ],
			[ TextFlow,					"no",		"no",		"no",				"no",		"no",		"no",			"no",				"no",			"no",		"no",		"no",			"no" ],
			[ DivElement,				"yes",		"yes",		"no",				"no",		"no",		"no",			"no",				"no",			"no",		"yes",		"yes",			"no" ],
			[ ParagraphElement,			"yes",		"yes",		"no",				"no",		"no",		"no",			"no",				"no",			"no",		"yes",		"yes",			"no" ],
			[ LinkElement,				"no",		"no",		"yes",				"no",		"yes",		"no",			"no",				"no",			"no",		"no",		"no",			"yes" ],
			[ TCYElement,				"no",		"no",		"yes",				"yes",		"no",		"no",			"no",				"no",			"no",		"no",		"no",			"yes" ],
			[ SpanElement,				"no",		"no",		"yes",				"yes",		"yes",		"no",			"no",				"no",			"no",		"no",		"no",			"yes" ],
			[ InlineGraphicElement,		"no",		"no",		"yes",				"yes",		"yes",		"no",			"no",				"no",			"no",		"no",		"no",			"yes" ],
			[ BreakElement,				"no",		"no",		"yes",				"yes",		"yes",		"no",			"no",				"no",			"no",		"no",		"no",			"yes" ],
			[ TabElement,				"no",		"no",		"yes",				"yes",		"yes",		"no",			"no",				"no",			"no",		"no",		"no",			"yes" ],
			[ ListElement,				"yes",		"yes",		"no",				"no",		"no",		"no",			"no",				"no",			"no",		"yes",		"yes",			"no" ],
			[ ListItemElement,			"no",		"no",		"no",				"no",		"no",		"no",			"no",				"no",			"no",		"yes",		"no",			"no" ],
			[ SubParagraphGroupElement,	"no",		"no",		"yes",				"yes",		"yes",		"no",			"no",				"no",			"no",		"no",		"no",			"yes" ]
		];
		
		/** Using above table for permitted child/parent relationships verify that canOwnFlowElement matches the table. */
		public function AllNestingTest():void
		{			
			var parentRow:Array = childParentTable[0].slice(1);
			var childRow:Array;
			var childClassName:String;
			var childClass:Class;
			
			for each (childRow in childParentTable.slice(1))
			{
				childClassName = "flashx.textLayout.elements." + childRow[0];
				childClass = childRow[0] as Class;
				var childElement:FlowElement = new childClass as FlowElement;
				assertTrue(childElement.defaultTypeName != null,"Bad defaultTypeName in " + childClassName);

				childRow = childRow.slice(1);
				for (var idx:int = 0; idx < childRow.length; idx++)
				{
					var parentClass:Class = parentRow[idx] as Class
					var parentElement:FlowElement = new parentClass as FlowElement;
					
					// trace(parentClass.toString(),childClass.toString(),childRow[idx]);
					
					if (parentElement is FlowGroupElement)
					{
						if (FlowGroupElement(parentElement).canOwnFlowElement(childElement))
							assertTrue("Bad canOwnFlowElement value for expected allowed "+parentClass.toString()+" "+childClass.toString(),childRow[idx] == "yes");
						else
							assertTrue("Bad canOwnFlowElement value for expected not allowed "+parentClass.toString()+" "+childClass.toString(), childRow[idx] == "no");
					}
					else 
						assertTrue("Bad canOwnFlowElement value for a non FlowGroupElement parent "+parentClass.toString()+" "+childClass.toString(),childRow[idx] == "no");
				}
			}
			
			// Check for indirect nesting of SubParagraphGroupElements
			var textFlow:TextFlow = new TextFlow();
			var paragraph:ParagraphElement = new ParagraphElement();
			textFlow.replaceChildren(0, 0, paragraph);
			var parentGroup:SubParagraphGroupElement = new SubParagraphGroupElement();
			paragraph.replaceChildren(0, 0, parentGroup);
			for each (childRow in childParentTable.slice(1))
			{
				childClassName = "flashx.textLayout.elements." + childRow[0];
				childClass = childRow[0] as Class;
				var spgeChildElement:SubParagraphGroupElementBase = new childClass as SubParagraphGroupElementBase;
				if (spgeChildElement)
				{
					var groupElement:SubParagraphGroupElement = new SubParagraphGroupElement();
					groupElement.replaceChildren(0, 0, new SubParagraphGroupElement());

					groupElement.replaceChildren(0, 0, spgeChildElement);
					
					assertTrue (parentGroup.canOwnFlowElement(groupElement), "Expected this nesting to work");
					
					if (!spgeChildElement.allowNesting)
					{
						var nestingParent:SubParagraphGroupElementBase = new childClass as SubParagraphGroupElementBase;
						parentGroup.replaceChildren(parentGroup.numChildren, parentGroup.numChildren, nestingParent);
						var nestingGroup:SubParagraphGroupElement = new SubParagraphGroupElement();
						nestingParent.replaceChildren(nestingParent.numChildren, nestingParent.numChildren, nestingGroup);
						assertTrue("Expected this nesting to fail because of nesting of Link or TCY", !nestingGroup.canOwnFlowElement(groupElement));
					}
				}
			}
		}
	}
}
