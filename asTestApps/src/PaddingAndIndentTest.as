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
package {
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	import flashx.undo.UndoManager;
	
	use namespace tlf_internal;
	
	/** Same as the "Hello, World" text example except that text is read in dynamically based on markup string.  */
	[SWF(width="1000", height="1000")]
	public class PaddingAndIndentTest extends Sprite
	{
		private var _textFlow:TextFlow;
		private var _editManager:EditManager;
		
		private static var _englishContent:String = "There are many such lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.\n" + 
			"The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Within the furnace were seen the curling and riotous flames, and the burning marble, almost molten with the intensity of heat; while without, the reflection of the fire quivered on the dark intricacy of the surrounding forest, and showed in the foreground a bright and ruddy little picture of the hut, the spring beside its door, the athletic and coal-begrimed figure of the lime-burner, and the half-frightened child, shrinking into the protection of his father's shadow. And when again the iron door was closed, then reappeared the tender light of the half-full moon, which vainly strove to trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, though thus far down into the valley the sunshine had vanished long and long ago."

		public function PaddingAndIndentTest()
		{
			var s:Sprite = new Sprite();
			s.x = 10;
			s.y = 10;
			addChild(s);
			_textFlow = TextConverter.importToFlow(_englishContent, TextConverter.PLAIN_TEXT_FORMAT);
			_textFlow.flowComposer.addController(new ContainerController(s, 500, 500));
			_textFlow.flowComposer.updateAllControllers();
			_textFlow.interactionManager = new EditManager(new UndoManager());
			_editManager = _textFlow.interactionManager as EditManager;
		//	singleStackedFloat();
			floatsOnTwoSides(Float.LEFT, 100, 100);
		}
		
		private function addFloatAtPosition(position:int, width:Number, height:Number, float:String):DisplayObject
		{
			// Create a simple rectangular display object for the float
			var displayObject:Sprite = new Sprite();
			var g:Graphics = displayObject.graphics;
			g.beginFill(0xFF0000);
			g.drawRect(0, 0, width, height);
			g.endFill();
			
			// Add it to the TextFlow at the specified location
			_editManager.insertInlineGraphic(displayObject, width, height, float, new SelectionState(_textFlow, position, position));
			return displayObject;
		}
		
		private function floatAtParagraphStartInternal(leaf:FlowLeafElement, width:Number, height:Number, float:String, paragraphSpaceBefore:Number = 0):void
		{
			_editManager.beginCompositeOperation();
			var paragraph:ParagraphElement = leaf.getParagraph();
			var paraStart:int = paragraph.getAbsoluteStart();
			if (paragraph.computedFormat.paragraphSpaceBefore != paragraphSpaceBefore)
			{
				var paragraphFormat:TextLayoutFormat = new TextLayoutFormat();
				paragraphFormat.paragraphSpaceBefore = paragraphSpaceBefore;
				_editManager.applyFormat(null, paragraphFormat, null, new SelectionState(_textFlow, paraStart, paraStart + 1));
			}
			var floatObject:DisplayObject = addFloatAtPosition(paraStart, width, height, float);
			_editManager.endCompositeOperation();
			
			var lineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(paraStart);
			verifyFloatInLine(lineIndex, width, height, float, floatObject);		
		}
		
		/** Test adding a float to the start of the first and last paragraphs, with either left or right float, and with
		 * spaceBefore either 0 or 15. */
		private function floatAtParagraphStart(float:String, width:Number, height:Number):void
		{
			// On the first paragraph, add a left float
			floatAtParagraphStartInternal(_textFlow.getFirstLeaf(), width, height, float);			
			_editManager.undo();		// remove the float
			
			// On the first paragraph, add a right float
			floatAtParagraphStartInternal(_textFlow.getFirstLeaf(), width, height, float);
			_editManager.undo();		// remove the float
			
			// On the first paragraph, add a spaceBefore and a float
			floatAtParagraphStartInternal(_textFlow.getFirstLeaf(), width, height, float, 15);			
			_editManager.undo();		// remove the float
			
			// On the last paragraph, add a left float
			floatAtParagraphStartInternal(_textFlow.getLastLeaf(), width, height, float);			
			_editManager.undo();		// remove the float
			
			// On the last paragraph, add a right float
			floatAtParagraphStartInternal(_textFlow.getLastLeaf(), width, height, float);
			_editManager.undo();		// remove the float
			
			// On the last paragraph, add a spaceBefore and a float
			floatAtParagraphStartInternal(_textFlow.getFirstLeaf(), width, height, float, 15);			
			_editManager.undo();		// remove the float	
		}
		
		private function verifyFloatInLine(lineIndex:int, width:Number, height:Number, float:String, floatObject:DisplayObject):void
		{
			var textFlowLine:TextFlowLine;
			
			// Certify that the float was added to the container
			var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
			var firstLine:TextFlowLine = controller.getFirstVisibleLine();
			var lastLine:TextFlowLine = controller.getLastVisibleLine();
			var firstLineIndex:int = firstLine ? _textFlow.flowComposer.findLineIndexAtPosition(firstLine.absoluteStart) : -1;
			var lastLineIndex:int = lastLine ? _textFlow.flowComposer.findLineIndexAtPosition(lastLine.absoluteStart) : -1;
			if (lineIndex >= firstLineIndex && lineIndex <= lastLineIndex)
			{
				CONFIG::debug { assert(floatObject.parent == controller.container, "Float not added as child of the container"); }
				
				// Certify that the float appears below the previous line's descenders
				if (lineIndex > firstLineIndex)
				{
					textFlowLine = _textFlow.flowComposer.getLineAt(lineIndex - 1);
					CONFIG::debug { assert(Math.abs(floatObject.y - (textFlowLine.y + textFlowLine.ascent + textFlowLine.descent)) < 1, "Float should aline with previous line's descenders"); }
				}
				
				textFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
				CONFIG::debug { assert(floatObject.y <= textFlowLine.y, "Float should be at or before next line"); }
			}
		}
		
		private function floatAtLineStartInternal(lineIndex:int, width:Number, height:Number, float:String):void
		{
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			var floatObject:DisplayObject = addFloatAtPosition(textFlowLine.absoluteStart, width, height, float);
			
			verifyFloatInLine(lineIndex, width, height, float, floatObject);
		}
		
		private function floatAtLineMiddleInternal(lineIndex:int, width:Number, height:Number, float:String):void
		{
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			var floatObject:DisplayObject = addFloatAtPosition(textFlowLine.absoluteStart + (textFlowLine.textLength/2), width, height, float);
			
			verifyFloatInLine(lineIndex + 1, width, height, float, floatObject);		// aligns with next line
		}
		
		private function floatAtLineEndInternal(lineIndex:int, width:Number, height:Number, float:String):void
		{
			var textFlowLine:TextFlowLine = _textFlow.flowComposer.getLineAt(lineIndex);
			var floatObject:DisplayObject = addFloatAtPosition(textFlowLine.absoluteStart + textFlowLine.textLength - 1, width, height, float);
			
			verifyFloatInLine(lineIndex + 1, width, height, float, floatObject);		// aligns with next line
		}
		
		/** Test adding a float at the start of a line, float should appear below and to the left or right of the line. */
		private function floatAtLineStart(float:String, width:Number, height:Number):void
		{
			// At the start of the second line, add a left float
			floatAtLineStartInternal(1, width, height, float);			
			_editManager.undo();		// remove the float
		}
		
		public function floatAtLineMiddle(float:String, width:Number, height:Number):void
		{
			// At the start of the second line, add a left float
			floatAtLineMiddleInternal(1, width, height, float);			
			_editManager.undo();		// remove the float
		}
		
		public function floatAtLineEnd(float:String, width:Number, height:Number):void
		{
			// At the start of the second line, add a left float
			floatAtLineEndInternal(1, width, height, float);			
			_editManager.undo();		// remove the float
		}
		
		private function floatAtParagraphEndInternal(paragraph:ParagraphElement, width:Number, height:Number, float:String):void
		{
			var paragraph:ParagraphElement = _textFlow.getFirstLeaf().getParagraph();
			var pos:int = paragraph.getAbsoluteStart() + paragraph.textLength - 1;
			var lineIndex:int = _textFlow.flowComposer.findLineIndexAtPosition(pos);
			floatAtLineEndInternal(lineIndex, width, height, float);			
		}
		
		public function floatAtParagraphEnd(float:String, width:Number, height:Number):void
		{
			// Add float to the end of the first paragraph
			floatAtParagraphEndInternal(_textFlow.getFirstLeaf().getParagraph(), width, height, float);			
			_editManager.undo();		// remove the float
		}
		
		public function singleStackedFloat():void
		{
			stackedFloats(Float.LEFT, 30, 24);
		}
		
		// Test multiple floats on successive lines
		public function stackedFloats(float:String, width:Number, height:Number):void
		{
			floatAtLineMiddleInternal(1, width, height, float);			
			floatAtLineMiddleInternal(2, width, height, float);	
			_editManager.undo();		// remove the float
			floatAtLineMiddleInternal(3, width, height, float);			
			floatAtLineMiddleInternal(4, width/2, height/2, float);		
			
			_editManager.undo();		// remove the float
			_editManager.undo();		// remove the float
			_editManager.undo();		// remove the float 
		}
		
		private function flipFloat(float:String):String	{ return Float.LEFT ? Float.RIGHT : Float.LEFT; }
		
		// Test multiple floats on successive lines on each side
		public function floatsOnTwoSides(float:String, width:Number, height:Number):void
		{
			// On successive lines
			floatAtLineMiddleInternal(1, width, height, float);			
			floatAtLineMiddleInternal(2, width, height, flipFloat(float));	
			_editManager.undo();		// remove the float
			_editManager.undo();		// remove the float
			floatAtLineMiddleInternal(1, width, height, flipFloat(float));			
			floatAtLineMiddleInternal(2, width, height, float);	
			_editManager.undo();		// remove the float
			_editManager.undo();		// remove the float
			
			// On the same line
			floatAtLineMiddleInternal(3, width/2, height/2, float);			
			floatAtLineMiddleInternal(3, width, height, flipFloat(float));					
			_editManager.undo();		// remove the float
			_editManager.undo();		// remove the float
			
			floatAtLineMiddleInternal(3, width/2, height/2, flipFloat(float));			
			floatAtLineMiddleInternal(3, width, height, float);					
			//	_editManager.undo();		// remove the float
			//	_editManager.undo();		// remove the float
		}
	}

}
