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
package
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.TextLayoutVersion;
	import flashx.textLayout.tlf_internal;
	
	import mx.core.FlexGlobals;
	
	
	
	[SWF(width="1024", height="768")]
	public class FTEGridTestAS extends Sprite
	{
		// embed the fonts - note also add code to embed the font
		public static const embedFonts:Boolean = false;
		// work off the display list
		public static const offDisplayList:Boolean = false;
		
		// supported tests
		public static const CREATE_TEST:String = "create";
		public static const UPDATE_TEST:String = "update";
		
		public const testTable:Array = [ 
			  { name:TextFieldTest.name, 		build:TextFieldTest.build, 		refresh:TextFieldTest.refresh }
			, { name:Rectangle.name, 			build:Rectangle.build, 			refresh:Rectangle.refresh }
			, { name:FTEField.name, 			build:FTEField.build, 			refresh:FTEField.refresh }
			, { name:FlexFTETextField.name, 	build:FlexFTETextField.build, 	refresh:FlexFTETextField.refresh }
			, { name:FlexFTETextField41.name, 	build:FlexFTETextField41.build, refresh:FlexFTETextField41.refresh }
			, { name:FlexFTETextFieldNew.name, 	build:FlexFTETextFieldNew.build, refresh:FlexFTETextFieldNew.refresh }
			, { name:TCM.name, 					build:TCM.build, 				refresh:TCM.refresh }
			, { name:TextFlowTest.name, 		build:TextFlowTest.build, 		refresh:TextFlowTest.refresh }
			, { name:TextFlowLinkTest.name, 	build:TextFlowLinkTest.build, 	refresh:TextFlowLinkTest.refresh }
		];
		
		
		// buttons
		public var createTestButton:TextField;
		public var updateTestButton:TextField;
		public var testNameButton:TextField;
		
		public function FTEGridTestAS()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 1000;
			
			var playerType:String = Capabilities.isDebugger ? " DEBUGGER" : "";
			var vellumType:String = Configuration.tlf_internal::debugCodeEnabled ? "DEBUG" : "RELEASE"

			// controls
			var b:TextField = addButton("FTEGridTestAS " + Capabilities.version + playerType + " TLF: " + TextLayoutVersion.tlf_internal::BUILD_NUMBER + " " + vellumType,10,10,0,0,null);
			b = createTestButton= addButton("CreateTest",b.x+b.width+10,10,0,0,runCreateTest);
			b = updateTestButton = addButton("UpdateTest",b.x+b.width+10,10,0,0,runUpdateTest);
			b = testNameButton = addButton(testTable[0].name,b.x+b.width+10,10,0,0,testSelectHandler);
			
			// enables this application to test Flex's FTETextField class
			FlexGlobals.topLevelApplication = this;
			
			SharedGlobals.initializeGlobals();
		}
		
		public function addButton(text:String,x:Number,y:Number,width:Number,height:Number,handler:Function):TextField
		{
			var f1:TextField = new TextField();
			f1.text = text;
			f1.x = x; f1.y = y; // f1.height = height; f1.width = width;
			f1.autoSize = TextFieldAutoSize.LEFT;
			addChild(f1);
			if (handler != null)
			{
				f1.border = true;
				f1.borderColor = 0xff;
				f1.addEventListener(MouseEvent.CLICK,handler);
			}
			f1.selectable = false;
			
			return f1;
		}
		
		// click through the list of possible tests
		public function testSelectHandler(e:Event):void
		{
			for (var currIndex:int = 0; currIndex < testTable.length; currIndex++)
				if (testTable[currIndex].name ==  testNameButton.text)
					break;
			
			currIndex = currIndex >= testTable.length-1 ? 0 : currIndex+1;
			testNameButton.text = testTable[currIndex].name;
		}
		
		// each test is parented by this sprite.
		public var lineHolder:Sprite;
		
		public const LINEHOLDER_YOFFSET:Number = 30;
		
		
		// data for the current run
		private var sampleText:String="";
		private var _currTestTableEntry:Object;
		
		// call before starting the test
		private function initNewTest(testName:String):void
		{
			testType = testName;
			totalCreationTime = 0;
			totalRenderTime = 0;
			
			// setup _currTestTableEntry for running the test
			for (var currIndex:int = 0; currIndex < testTable.length; currIndex++)
				if (testTable[currIndex].name ==  testNameButton.text)
					break;
			_currTestTableEntry = testTable[currIndex];
			
			if (lineHolder)
				removeChild(lineHolder);
			
			lineHolder = new Sprite();
			lineHolder.y = LINEHOLDER_YOFFSET;
			addChild(lineHolder);
			
			// hide the buttons
			createTestButton.visible = false;  
			updateTestButton.visible = false; 
			
			// set iteration to zero and add the handler
			currIteration = 0;
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}

		
		public function runCreateTest(e:Event):void
		{
			initNewTest(CREATE_TEST);
			sampleText="";
		}
		
		public function runUpdateTest(e:Event):void
		{	
			initNewTest(UPDATE_TEST);
			// populate the grid
			createGrid();
		}

		
		// number of times each test is repeated.  Could make a control for this
		private const numberOfIterations:int = 100;
		
		private var dataLengthVal:Number;
		
		private var minWidthVal:Number;
		private var maxWidthVal:Number;
		private var widthStepVal:Number;
		
		private var currIteration:int = -1;
		private var currWidthVal:Number;
		
		private var beginThisRender:int;
		private var timingRendering:Boolean = false;
		
		// timers
		private var beginTestTime:int;
		public var totalCreationTime:int;
		public var totalRenderTime:int;
		
		public var cols:int = 15;
		
		private var testType:String = "";
		
		private var desiredColSize:Number;
		
		private function Step():void
		{
			if (testType == CREATE_TEST)
			{
				while (lineHolder.numChildren)
					lineHolder.removeChildAt(0);
				
				var t1:Number = getTimer();
				createGrid();
				totalCreationTime = totalCreationTime + (getTimer() - t1);
			} 
			else if (testType == UPDATE_TEST)
			{
				t1 = getTimer();
				sampleText = "update_" + currIteration;
				updateGrid();
				totalCreationTime = totalCreationTime + (getTimer() - t1);
			}
		}
		
		
		/** generate a report at the next enter frame */
		public function handleEnterFrame(e:Event): void
		{
			if (currIteration == -1)
				return;
			
			if (timingRendering)
			{
				totalRenderTime += getTimer() - beginThisRender;
				timingRendering = false;
			}
			
			// report results if appropriate
			if (currIteration < numberOfIterations)
			{
				Step();
				
				// prepare for the next iteration
				currIteration++;
				
				// begin timing rendering
				timingRendering = true;
				beginThisRender = getTimer();
			}
			else
			{ 
				// force a garbage collect?????
				/*try {
				new LocalConnection().connect('dummy');
				new LocalConnection().connect('dummy');
				} catch (e:*) {}*/
				
				
				createTestButton.visible = true;  
				updateTestButton.visible = true;  
				currIteration = -1;
				reportResults();
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
			
		}
		
		static public const deltay:Number = 9;
		static public var cellCount:int = 0;
		
		
		// Grid generator.
		private function createGrid():void
		{
			var target:Sprite = new Sprite();
			target.x = target.y = 0;
			
			if (!offDisplayList)
				lineHolder.addChild(target);
			
			var cellWidth:Number = lineHolder.stage.stageWidth / cols;
			// var isFTE:Boolean = testTypeCombo.selectedLabel == "FTE";
			var curY:Number = 0;
			var cell:DisplayObject;
			var rowCount:Number = 0;
			cellCount = 0;
			
			var totalHeight:Number = this.stage.stageHeight-LINEHOLDER_YOFFSET;
			
			while (curY < totalHeight)
			{
				var curX:Number = 0;
				for (var c:int = 0; c < cols; c++)
				{
					var st:String = sampleText != "" ? sampleText : currIteration + ": " + int(c+1) + "," + int(rowCount+1);
					_currTestTableEntry.build(st, cellWidth, target, curX, curY);
					curX += cellWidth;
					cellCount++;
				}
				rowCount = rowCount + 1;
				curY += deltay ; // isFTE ? cell.height + 7: cell.height;
				
				if ((curY + deltay) >= totalHeight)
					break;
			}
			
			if (offDisplayList)
				lineHolder.addChild(target);
		}
		
		// Grid Updater
		private function updateGrid():void
		{
			var cellWidth:Number = lineHolder.width / cols;
			var target:Sprite = lineHolder.getChildAt(0) as Sprite;
			if (offDisplayList)
				lineHolder.removeChildAt(0);
			
			// var isFTE:Boolean = testTypeCombo.selectedLabel == "FTE";
			var curY:Number = 0;
			var rowCount:Number = 0;
			cellCount = 0;
			
			var totalHeight:Number = this.stage.stageHeight-LINEHOLDER_YOFFSET;
			
			while (curY < totalHeight)
			{
				var curX:Number = 0;
				for (var c:int = 0; c < cols; c++)
				{
					_currTestTableEntry.refresh(sampleText, cellWidth, target, cellCount, curX, curY);
					
					curX += cellWidth;
					cellCount++;
				}
				rowCount = rowCount + 1;
				curY += deltay ; // isFTE ? cell.height + 7: cell.height;
				
				if ((curY + deltay) >= totalHeight)
					break;
			}
			
			if (offDisplayList)
				lineHolder.addChild(target);
		}
		
		
		private function reportResults():void
		{
			var totalTestTime:int = totalRenderTime + totalCreationTime;
			flash.system.System.gc();	//mark
			flash.system.System.gc();	//sweep
			var memoryAllocated:Number = flash.system.System.totalMemory/1024;
			
			var vellumType:String = "Vellum Build: " + TextLayoutVersion.tlf_internal::BUILD_NUMBER + "\n";
			
			var resultText:TextField = new TextField();
			var format:TextFormat = new TextFormat;
			format.font = "Verdana";
			format.size = 18;
			resultText.defaultTextFormat = format;
			
			resultText.text = "CreationTime (msecs): " + totalCreationTime.toString() + "\nRenderTime (msec): " + totalRenderTime.toString() + "\nTotalTime (msec): " + totalTestTime.toString() 
				+ " \nmem (K): " + memoryAllocated.toString() + " cellCount: " + cellCount.toString() + "\n" + vellumType;
			resultText.x = 80; 
			resultText.y = 140;
			resultText.width = 400;
			resultText.height = 300;
			
			resultText.opaqueBackground = 0xFFFFFFFF;
			lineHolder.addChild(resultText);    
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.engine.*;

import flashx.textLayout.container.ContainerController;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.elements.LinkElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.formats.TextLayoutFormat;

import mx.core.FTETextField;



class SharedGlobals
{
	// TextField Factory 
	static public var defaultTextFormat:TextFormat;
	
	static private function initDefaultTextFormat():void
	{
		defaultTextFormat = new TextFormat();
		defaultTextFormat.size = 10;
		defaultTextFormat.leading = 0;
		
		if (FTEGridTestAS.embedFonts)
			defaultTextFormat.font = "TFArial";
		else
			defaultTextFormat.font = "Verdana";
	}
	
	// FTE factory 
	static public var templateTextElement:TextElement = null;
	static public var templateTextBlock:TextBlock = null;
	
	static public function initializeTemplateText():void
	{
		var elementFormat:ElementFormat = new ElementFormat();
		var fontDescription:FontDescription = new FontDescription();
		if (FTEGridTestAS.embedFonts)
		{
			fontDescription.fontName = "FTEArial";
			fontDescription.fontLookup = FontLookup.EMBEDDED_CFF;
		}
		else
			fontDescription.fontName = "Verdana";
		elementFormat.fontSize = 10;
		elementFormat.fontDescription = fontDescription;
		templateTextElement = new TextElement();
		templateTextElement.elementFormat = elementFormat;
		templateTextBlock = new TextBlock(templateTextElement); 
		templateTextBlock.textJustifier = new SpaceJustifier("en",LineJustification.UNJUSTIFIED,false);         
	}
	
	static public var defaultTextLayoutFormat:TextLayoutFormat;
	
	static private function initDefaultTextLayoutFormat():void
	{
		defaultTextLayoutFormat = new TextLayoutFormat();
		defaultTextLayoutFormat.fontSize = 10;
		defaultTextLayoutFormat.lineHeight = 10;
		
		if (FTEGridTestAS.embedFonts)
			defaultTextLayoutFormat.fontFamily = "TFArial";
		else
			defaultTextLayoutFormat.fontFamily = "Verdana";
	}
	
	public static function initializeGlobals():void
	{
		initDefaultTextFormat();
		initializeTemplateText();
		initDefaultTextLayoutFormat();
	}
}

class TextFieldTest
{
	public static const name:String = "TextField";
	
	static public function build(text:String, width:Number, parent:DisplayObjectContainer, currX:Number, currY:Number):DisplayObject
	{   
		var a:TextField = new TextField();
		a.defaultTextFormat = SharedGlobals.defaultTextFormat;
		a.embedFonts = FTEGridTestAS.embedFonts;
		a.text = text;
		a.width = width;
		a.autoSize = "left";
		a.multiline = true;
		a.wordWrap = true;
		
		a.x = currX;
		a.y = currY;
		parent.addChild(a);
		
		return a;
	}
	
	static public function refresh(text:String, width:Number, parent:DisplayObjectContainer, idx:int, currX:Number, currY:Number):DisplayObject
	{
		var a:TextField = parent.getChildAt(idx) as TextField;
		
		if (text)
			a.text = text;
		/* a.width = width;
		a.autoSize = "left";
		a.multiline = true;
		a.wordWrap = true; */
		return a;
	}
}

class Rectangle
{
	public static const name:String = "Rectangles";
	
	public static var nextColor:uint = 0;
	
	// Rectangle Factory 
	static public function build(text:String, width:Number, parent:DisplayObjectContainer, currX:Number, currY:Number):DisplayObject
	{
		var s:Shape = new Shape();
		s.x = currX;
		s.y = currY;
		s.graphics.beginFill(nextColor);
		nextColor += 0x010101;
		s.graphics.lineStyle(1, 0xFFFFFF);
		s.graphics.drawRect(0,0,width,15);
		s.graphics.endFill();
		parent.addChild(s);
		return s;
	}
	
	static public function refresh(text:String, width:Number, parent:DisplayObjectContainer, idx:int, currX:Number, currY:Number):void
	{
		if (idx == 0)
			while (parent.numChildren)
				parent.removeChildAt(0);
		build(text,width,parent,currX,currY);
	}
}

class FTEField
{
	public static const name:String = "FTE TextLine";
	
	
	static private function fillinFTEField(text:String, width:Number, rslt:DisplayObjectContainer):void
	{
		
		if (text)
			SharedGlobals.templateTextElement.text = text;
		
		var textLine:TextLine = null;
		var y:Number = 10.5;
		
		var textBlock:TextBlock = SharedGlobals.templateTextBlock;
		var textLength:int = textBlock.content.text.length;
		var lenUsed:int = 0;
		
		// more efficient use of FTE is to track the length used and stop after all text is consumed
		while (lenUsed < textLength)
		{
			textLine = SharedGlobals.templateTextBlock.createTextLine(textLine,width,0,true);
			textLine.x = 2;
			textLine.y = y;
			y += 12.2;
			rslt.addChild(textLine);
			lenUsed += textLine.rawTextLength;
		}
		
		textBlock.releaseLines(textBlock.firstLine,textBlock.lastLine);
	}
	
	static public function build(text:String, width:Number, target:DisplayObjectContainer, currX:Number, currY:Number):DisplayObject
	{
		var rslt:Sprite = new Sprite();
		
		fillinFTEField(text,width,rslt);
		
		rslt.x = currX;
		rslt.y = currY;
		target.addChild(rslt);
		
		return rslt; 
	}
	
	static public function refresh(text:String, width:Number, parent:DisplayObjectContainer, idx:int, currX:Number, currY:Number):DisplayObject
	{
		var target:Sprite = parent.getChildAt(idx) as Sprite;
		
		while (target.numChildren)
			target.removeChildAt(0);
		
		fillinFTEField(text, width, target);
		
		return target;
	}
}

// FTETextField is a Flex wrapper for FTE
class FlexFTETextField
{
	public static const name:String = "Flex FTETextField";
	
	static public function build(text:String, width:Number, parent:DisplayObjectContainer, currX:Number, currY:Number):DisplayObject
	{	
		var a:FTETextField = new FTETextField();
		a.defaultTextFormat = SharedGlobals.defaultTextFormat;
		a.text = text;
		a.width = width;
		a.autoSize = "left";
		a.multiline = true;
		a.wordWrap = true;
		
		a.x = currX;
		a.y = currY;
		parent.addChild(a);
		
		return a;
	}
	
	static public function refresh(text:String, width:Number, parent:DisplayObjectContainer, idx:int, currX:Number, currY:Number):DisplayObject
	{
		var a:FTETextField = parent.getChildAt(idx) as FTETextField;
		
		if (text)
			a.text = text;
		/* a.width = width;
		a.autoSize = "left";
		a.multiline = true;
		a.wordWrap = true; */
		return a;
	}
}

class TCM
{
	public static const name:String = "TCM";
	
	static public function build(text:String, width:Number, parent:DisplayObjectContainer, currX:Number, currY:Number):DisplayObject
	{	
		var s:TCMSprite = new TCMSprite();
		var tcm:TextContainerManager = new TextContainerManager(s);
		s.tcm = tcm;
		tcm.compositionHeight = NaN; tcm.compositionWidth = width;
		tcm.setText(text);
		tcm.hostFormat = SharedGlobals.defaultTextLayoutFormat;
		tcm.updateContainer();
		
		s.x = currX;
		s.y = currY;
		parent.addChild(s);
		
		return s;
	}
	
	static public function refresh(text:String, width:Number, parent:DisplayObjectContainer, idx:int, currX:Number, currY:Number):DisplayObject
	{
		var a:TCMSprite = parent.getChildAt(idx) as TCMSprite;
		var tcm:TextContainerManager = a.tcm;
		
		if (text)
		{
			tcm.setText(text);
			tcm.updateContainer();
		}
		
		return a;
	}
}

class TCMSprite extends Sprite
{
	public var tcm:TextContainerManager;
}

class TextFlowTest
{
	public static const name:String = "TextFlow";
	
	static public function build(text:String, width:Number, parent:DisplayObjectContainer, currX:Number, currY:Number):DisplayObject
	{	
		var s:TextFlowSprite = new TextFlowSprite();
		var textFlow:TextFlow = new TextFlow();
		textFlow.hostFormat = SharedGlobals.defaultTextLayoutFormat;
		var p:ParagraphElement = new ParagraphElement();
		var span:SpanElement = new SpanElement();
		span.text = text;
		
		// no links case - remove when doing links test
		p.addChild(span);
		
		// alternate for above to test a link
//		var link:LinkElement = new LinkElement;
//		link.addChild(span);
//		p.addChild(link);
		
		// put p in the TextFlow
		textFlow.addChild(p);
		
		textFlow.flowComposer.addController(new ContainerController(s,NaN,NaN));
		textFlow.flowComposer.updateAllControllers();
		s.textFlow = textFlow;
		
		s.x = currX;
		s.y = currY;
		parent.addChild(s);
		
		return s;
	}
	
	static public function refresh(text:String, width:Number, parent:DisplayObjectContainer, idx:int, currX:Number, currY:Number):DisplayObject
	{
		var a:TextFlowSprite = parent.getChildAt(idx) as TextFlowSprite;
		var textFlow:TextFlow = a.textFlow;
		
		if (text)
		{
			(textFlow.getFirstLeaf() as SpanElement).text = text;
			textFlow.flowComposer.updateAllControllers();
		}
		
		return a;
	}
}

class TextFlowLinkTest
{
	public static const name:String = "TextFlow with Link";
	
	static public function build(text:String, width:Number, parent:DisplayObjectContainer, currX:Number, currY:Number):DisplayObject
	{	
		var s:TextFlowSprite = new TextFlowSprite();
		var textFlow:TextFlow = new TextFlow();
		textFlow.hostFormat = SharedGlobals.defaultTextLayoutFormat;
		var p:ParagraphElement = new ParagraphElement();
		var span:SpanElement = new SpanElement();
		span.text = text;
		
		// no links case - remove when doing links test
		// p.addChild(span);
		
		// alternate for above to test a link
		var link:LinkElement = new LinkElement;
		link.addChild(span);
		p.addChild(link);
		
		// put p in the TextFlow
		textFlow.addChild(p);
		
		textFlow.flowComposer.addController(new ContainerController(s,NaN,NaN));
		textFlow.flowComposer.updateAllControllers();
		s.textFlow = textFlow;
		
		s.x = currX;
		s.y = currY;
		parent.addChild(s);
		
		return s;
	}
	
	static public function refresh(text:String, width:Number, parent:DisplayObjectContainer, idx:int, currX:Number, currY:Number):DisplayObject
	{
		var a:TextFlowSprite = parent.getChildAt(idx) as TextFlowSprite;
		var textFlow:TextFlow = a.textFlow;
		
		if (text)
		{
			(textFlow.getFirstLeaf() as SpanElement).text = text;
			textFlow.flowComposer.updateAllControllers();
		}
		
		return a;
	}
}

class TextFlowSprite extends Sprite
{
	public var textFlow:TextFlow;
}

import helpers.FTETextField41;

class FlexFTETextField41
{
	public static const name:String = "Flex41 FTETextField";
	
	static public function build(text:String, width:Number, parent:DisplayObjectContainer, currX:Number, currY:Number):DisplayObject
	{	
		var a:FTETextField41 = new FTETextField41();
		a.defaultTextFormat = SharedGlobals.defaultTextFormat;
		a.text = text;
		a.width = width;
		a.autoSize = "left";
		a.multiline = true;
		a.wordWrap = true;
		
		a.x = currX;
		a.y = currY;
		parent.addChild(a);
		
		return a;
	}
	
	static public function refresh(text:String, width:Number, parent:DisplayObjectContainer, idx:int, currX:Number, currY:Number):DisplayObject
	{
		var a:FTETextField41 = parent.getChildAt(idx) as FTETextField41;
		
		if (text)
			a.text = text;
		/* a.width = width;
		a.autoSize = "left";
		a.multiline = true;
		a.wordWrap = true; */
		return a;
	}
}

import helpers.FTETextFieldNew;

class FlexFTETextFieldNew
{
	public static const name:String = "FlexNew FTETextField";
	
	static public function build(text:String, width:Number, parent:DisplayObjectContainer, currX:Number, currY:Number):DisplayObject
	{	
		var a:FTETextFieldNew = new FTETextFieldNew();
		a.defaultTextFormat = SharedGlobals.defaultTextFormat;
		a.text = text;
		a.width = width;
		a.autoSize = "left";
		a.multiline = true;
		a.wordWrap = true;
		
		a.x = currX;
		a.y = currY;
		parent.addChild(a);
		
		return a;
	}
	
	static public function refresh(text:String, width:Number, parent:DisplayObjectContainer, idx:int, currX:Number, currY:Number):DisplayObject
	{
		var a:FTETextFieldNew = parent.getChildAt(idx) as FTETextFieldNew;
		
		if (text)
			a.text = text;
		/* a.width = width;
		a.autoSize = "left";
		a.multiline = true;
		a.wordWrap = true; */
		return a;
	}
}
