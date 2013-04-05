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
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.ContextMenu;
	import flash.utils.Timer;
	
	import flashx.textLayout.TextLayoutVersion;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.debug.Debugging;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.ListStyleType;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	import flashx.undo.IUndoManager;
	import flashx.undo.UndoManager;
	
	use namespace tlf_internal;

	[SWF(width="1000", height="800")]
	public class OpHammer extends Sprite
	{
		private var _textFlow:TextFlow;
		private var _textFlowMarkup:String;
		private var _sprite:Sprite;
		private var _results:TextField;
		private var _statusField:TextField;
		private var _compress:Boolean = true;	// automatically make the TextFlow smaller
		private var _pointOnly:Boolean = false;	// point selections only
		private var _redo:Boolean = false;		// redo testing
		
		private const spriteX:Number = 10;
		private const spriteY:Number = 70;
		private const spriteWidth:Number = 980;
		private const spriteHeight:Number = 340;
		
		// FileReference requires a reference or it will be garbage collected
		private var _activeFileIndex:int;
		private var _activeFileReferenceList:FileReferenceList;
		private var _activeFileReference:FileReference;
		private var _blockedWaitingForNewFile:Boolean;
		
		private function nextX(b:TextField):Number
		{ return b.x + b.width + 10; }

		public function OpHammer()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 1000;
			
			stage.addEventListener(Event.RESIZE,resizeHandler);
			
			var b:TextField = addButton("Compress:ON",10,10,0,0,toggleCompress);
			b = addButton("PointOnly:OFF",nextX(b),10,0,0,togglePointOnly);
			b = addButton("Redo:OFF",nextX(b),10,0,0,toggleRedo);
			b = addButton("Load..",nextX(b),10,0,0,openDialog);
			b = addButton("STOP",nextX(b),10,0,0,stopTest);
			b = addButton(TextLayoutVersion.BUILD_NUMBER + " " + Capabilities.version,nextX(b),10,0,0,null);
			_statusField = addButton("Ready",nextX(b),10,0,0,null);
			
			b = addButton("DeleteTest",10,40,0,0,runDeleteTest);
			b = addButton("SplitTest",nextX(b),40,0,0,runSplitTest);
			b = addButton("FormatSpan",nextX(b),40,0,0,runFormatSpanTest);
			b = addButton("ApplyLink",nextX(b),40,0,0,runApplyLinkTest);
			b = addButton("RemoveLink",nextX(b),40,0,0,runRemoveLinkTest);
			b = addButton("InsertText",nextX(b),40,0,0,runInsertTextTest);
			b = addButton("FormatThenSplit",nextX(b),40,0,0,runFormatThenSplitTest);
			b = addButton("FormatThenLink",nextX(b),40,0,0,runFormatThenLinkTest);
			b = addButton("CreateList",nextX(b),40,0,0,runCreateListTest);
			b = addButton("SplitElement",nextX(b),40,0,0,runSplitElementTest);
			b = addButton("CreateSubParagraphGroup",nextX(b),40,0,0,runcreateSubParagraphGroupTest);
			b = addButton("CreateDiv",nextX(b),40,0,0,runCreateDivTest);
			
			
			_results = new TextField();
			_results.x = 10;
			_results.y = 420;
			_results.width = 980;
			_results.height = 350;
			_results.backgroundColor = 0xf0f0f0;
			_results.background = true;
			_results.wordWrap = true;
			addChild(_results);
			
			// show the area covered
			/*_sprite = new Sprite;
			_sprite.x = spriteX;
			_sprite.y = spriteY;
			_sprite.graphics.beginFill(0xff,0.5);
			_sprite.graphics.drawRect(0,0,spriteWidth,spriteHeight);
			_sprite.graphics.endFill();
			addChild(_sprite);*/
			
			/*Debugging.verbose = true;
			Debugging.debugCheckTextFlow = true;*/
			
			loadTextFlowFromString(TextConverter.PLAIN_TEXT_FORMAT, "Hello", false);
			
			CONFIG::debug { Debugging.tlf_internal::throwOnAssert = true; }
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
		
		public function toggleCompress(e:Event):void
		{
			_compress = !_compress;
			TextField(e.target).text = _compress ? "Compress:ON" : "Compress:OFF";
		}
		
		public function togglePointOnly(e:Event):void
		{
			_pointOnly = !_pointOnly;
			TextField(e.target).text = _pointOnly ? "PointOnly:ON" : "PointOnly:OFF";
		}
		
		public function toggleRedo(e:Event):void
		{
			_redo = !_redo;
			TextField(e.target).text = _redo ? "Redo:ON" : "Redo:OFF";
		}
		
		// ////////////////////////
		// file loading stuff
		// ////////////////////////
		public function resizeHandler(e:Event):void
		{
			/*if (_textFlow)
			{
				var cont:ContainerController = _textFlow.flowComposer.getControllerAt(0);
				cont.setCompositionSize(stage.stageWidth-20,spriteHeight);
				_textFlow.flowComposer.updateAllControllers();
			}*/
		}
		
		public function openDialog(e:Event):void
		{
			stopTest();
			_activeFileReferenceList = null;
			if (_activeFileReference)
			{
				_activeFileReference.cancel();
				_activeFileReference = null;
			}

			var markupFilter:FileFilter = new FileFilter("Documents","*.xml;*.fxg;*.html");
			_activeFileReferenceList = new FileReferenceList();
			_activeFileReferenceList.addEventListener(Event.SELECT,onFileSelect);
			_activeFileReferenceList.addEventListener(Event.CANCEL,function (e:Event):void { _activeFileReference = null; },false,0,true);
			_activeFileReferenceList.browse([markupFilter]);
		}		
		
		public function onFileSelect(event:Event):void 
		{
			_activeFileIndex = 0;
			loadActiveFileIndex();
		}
		
		public function loadActiveFileIndex():void
		{
			if (_activeFileReferenceList == null)
				return;
			
			_activeFileReference = _activeFileReferenceList.fileList[_activeFileIndex];
			_activeFileReference.addEventListener(Event.COMPLETE,onFileReferenceLoadComplete,false,0,true);
			_activeFileReference.addEventListener(IOErrorEvent.IO_ERROR,errorOnReadFromFileReference,false,0,true);
			_activeFileReference.load();
			_statusField.text = traceResult("LOADING",_activeFileReference.name);
		}
		
		
		public function onFileReferenceLoadComplete(event:Event):void
		{
			if (event.currentTarget == _activeFileReference)
			{
				var format:String = mapExtensionToFormat(getExtension(_activeFileReference.name));
				var fileData:String  = String(_activeFileReference.data);
				loadTextFlowFromString(format, fileData, _compress);
				_activeFileReference = null;
			}
		}
		
		public function errorOnReadFromFileReference(event:IOErrorEvent):void
		{
			if (event.currentTarget == _activeFileReference)
			{
				// Text content will be an error string
				var errorString:String = "Error reading file " + _activeFileReference.name;
				errorString += "\n";
				errorString += event.toString();
				loadTextFlowFromString(TextConverter.PLAIN_TEXT_FORMAT,errorString, false);
				_activeFileReference = null;
			}
		}

		
		static public function getExtension(fileName:String):String
		{
			var dotPos:int = fileName.lastIndexOf(".");
			if (dotPos >= 0)
				return fileName.substring(dotPos + 1);
			return fileName;
		}
		
		static public function mapExtensionToFormat(extension:String):String
		{
			switch (extension.toLowerCase())
			{
				case "xml":		// use Vellum markup
					return TextConverter.TEXT_LAYOUT_FORMAT;
					break;
				case "html":
					return TextConverter.TEXT_FIELD_HTML_FORMAT;
					break;
			}
			return TextConverter.PLAIN_TEXT_FORMAT;
		}

		public function loadTextFlowFromString(format:String,stringData:String, applyCompress:Boolean):void
		{
			if (_textFlow)
			{
				_textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,statusChangeHandler);
				_textFlow = null;
				_textFlowMarkup = null;
			}
			
			var textImporter:ITextImporter = TextConverter.getImporter(format);
			_textFlow = textImporter.importToFlow(stringData);
			if (textImporter.errors)
			{
				traceResult("ERRORS REPORTED ON IMPORT");
				for each(var e:String in textImporter.errors)
					traceResult(e);
			}
			
			// lose the old flow
			if (_sprite)
			{
				removeChild(_sprite);
				_sprite = null;
			}
			
			if (_textFlow)
			{				
				if (applyCompress)
				{
					// make all the spans 3 characters (4 with terminator)
					var leaf:FlowLeafElement = _textFlow.getLastLeaf();
					while (leaf)
					{
						if ((leaf is SpanElement) && leaf.textLength > 3)
							(leaf as SpanElement).replaceText(3,leaf.textLength,null);
						leaf = leaf.getPreviousLeaf();
					}
					// make more visible by giving it multiple columns
					_textFlow.columnWidth = 150;
				}
				_sprite = new Sprite();
				_sprite.x = spriteX;
				_sprite.y = spriteY;
				addChild(_sprite);
				
				var cont:ContainerController = new ContainerController(_sprite,spriteWidth,spriteHeight);
				_textFlow.flowComposer.addController(cont);
				_textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,statusChangeHandler);
				_textFlow.interactionManager = new EditManager(new UndoManager());
				_textFlow.interactionManager.focusedSelectionFormat = new SelectionFormat(0xffffff, 1.0, BlendMode.DIFFERENCE);
				_textFlow.interactionManager.unfocusedSelectionFormat = new SelectionFormat(0xa8c6ee, 1.0, BlendMode.NORMAL, 0xffffff);
				_textFlow.interactionManager.inactiveSelectionFormat = new SelectionFormat(0xe8e8e8, 1.0, BlendMode.NORMAL, 0xffffff);
				_textFlow.flowComposer.updateAllControllers();

				// resizeHandler(null);
				
				// save the markup for testing
				_textFlowMarkup = TextConverter.export(_textFlow,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.STRING_TYPE) as String;
			}
			
			if (_blockedWaitingForNewFile)
			{
				_runningTest.reset(_textFlow);
				_blockedWaitingForNewFile = false;
				traceResult(_textFlowMarkup);
				if (_activeFileIndex == 0)
					_statusField.text = traceResult("BEG TESTING", _runningTest.testName, _textFlow.textLength);									
			}
			else if (_runningTest)
				_runningTest.changeTextFlow(_textFlow);
		}
		
		private function statusChangeHandler(e:StatusChangeEvent):void
		{
			// if the graphic has loaded update the display
			// set the loaded graphic's height to match text height
			if (e.status == InlineGraphicElementStatus.READY || e.status == InlineGraphicElementStatus.SIZE_PENDING)
				_textFlow.flowComposer.updateAllControllers();
		}
		
		// //////////////////////
		// Results logging
		// /////////////////////
		public function traceResult(s:String, ... args):String
		{
			for each (var obj:Object in args)
			{
				s += " " + obj.toString();
			}
			trace(s);
			_results.appendText(s);
			_results.appendText("\n");
			_results.scrollV = _results.maxScrollV;
			return s;
		}
		
		private var _runningTest:ITestCase;
		private var _testCount:int;	
		private var _errorCount:int;	

		// ////////////////
		// Test intiating functions
		// ///////////////
		
		public function get editManager():IEditManager
		{ return _textFlow ? _textFlow.interactionManager as IEditManager : null; }
		
		public function runDeleteTest(e:Event):void
		{
			runStandardTest("deleteText", function ():void { editManager.deleteText(); });
		}
		public function runSplitTest(e:Event):void
		{
			runStandardTest("splitParagraph",function ():void { editManager.splitParagraph(); });
		}	
		public function runFormatSpanTest(e:Event):void
		{
			runStandardTest("applyFormat to span",function ():void { editManager.applyFormat(TextLayoutFormat.createTextLayoutFormat({color:0xf0}),null,null); });
		}
		public function runApplyLinkTest(e:Event):void
		{
			runStandardTest("applyLink",function ():void { editManager.applyLink("http://www.adobe.com"); });			
		}
		public function runRemoveLinkTest(e:Event):void
		{
			runStandardTest(e.target.text,function ():void { editManager.applyLink(""); });			
		}
		public function runcreateSubParagraphGroupTest(e:Event):void
		{
			runStandardTest("createSubParagraphGroup",function ():void { var elem:FlowGroupElement = _runningTest.objectMark.findElement(_textFlow) as FlowGroupElement; editManager.createSubParagraphGroup(elem); },true);			
		}
		public function runCreateDivTest(e:Event):void
		{
			runStandardTest("createDiv",function ():void { editManager.createDiv(); },true);			
			// runStandardTest("createDiv",function ():void { var elem:FlowGroupElement = _runningTest.objectMark.findElement(_textFlow) as FlowGroupElement; editManager.createDiv(elem); },true);			
		}
		public function runInsertTextTest(e:Event):void
		{
			runStandardTest("insertText",function ():void { editManager.insertText("A"); (_textFlow.interactionManager as EditManager).flushPendingOperations()});						
		}
		
		public function runFormatThenSplitTest(e:Event):void
		{
			var formatFunction:Function = function ():void { editManager.applyFormat(TextLayoutFormat.createTextLayoutFormat({color:0xf0}),null,null); };
			var splitFunction:Function  = function ():void { editManager.splitParagraph(); };
			runTest(new NestedTestCase("formatThenSplit",new StandardTestCase("formatThenSplit",formatFunction,_textFlow,false,false),splitFunction,_textFlow,_pointOnly));
		}
		
		public function runFormatThenLinkTest(e:Event):void
		{
			var formatFunction:Function = function ():void { editManager.applyFormat(TextLayoutFormat.createTextLayoutFormat({color:0xf0}),null,null); };
			var linkFunction:Function  = function ():void { editManager.applyLink("http://www.adobe.com"); };
			runTest(new NestedTestCase("formatThenLink",new StandardTestCase("formatThenLink",formatFunction,_textFlow,false,false),linkFunction,_textFlow,_pointOnly));
		}
		
		public function runCreateListTest(e:Event):void
		{
			var listFormat:TextLayoutFormat = new TextLayoutFormat();
			listFormat.paddingLeft=24;
			listFormat.paddingRight=24;
			listFormat.listStyleType = ListStyleType.DISC;

			runStandardTest("createList",function ():void { editManager.createList(null, listFormat); });			
		}
		
		public function runSplitElementTest(e:Event):void
		{
			runStandardTest("splitElement",function ():void { var elem:FlowGroupElement = _runningTest.objectMark.findElement(_textFlow) as FlowGroupElement; editManager.splitElement(elem); }, true);
			// runStandardTest("splitElement",function ():void { editManager.splitElement(null); }, false);
		}
		

		// ////////////////
		// Generic Test
		// ///////////////
		public function runStandardTest(testName:String,f:Function,objectMode:Boolean = false):void
		{ runTest(new StandardTestCase(testName,f,_textFlow,_pointOnly,objectMode)); }
		
		public function runTest(testCase:ITestCase):void
		{
			if (!_textFlow)
				return;
			
			stopTest();	// any that are already running
			
			_runningTest = testCase;
			
			_testCount = 0;
			_errorCount = 0;
			
			if (_activeFileIndex != 0)
			{
				_blockedWaitingForNewFile = true;
				_activeFileIndex = 0;
				loadActiveFileIndex();					
			}
			else
			{
				_statusField.text = traceResult("BEG TESTING", testCase.testName, _textFlow.textLength);				
				traceResult(_textFlowMarkup);
			}
			
			addEventListener(Event.ENTER_FRAME,singleStepTestFunction);
		}
		
		public function stopTest(e:Object = null):void
		{
			if (_runningTest)
			{
				removeEventListener(Event.ENTER_FRAME,singleStepTestFunction);
				_statusField.text = traceResult("END TESTING", _runningTest.testName, "TESTS", _testCount, "ERRORS", _errorCount);
				_runningTest = null;
			}
		}
		
		public function reportError(errorStage:String):void
		{
			traceResult("ERROR",errorStage,_testCount,_runningTest.testName,_runningTest.getErrorInfo());
			_errorCount++;
		}
		
		public function singleStepTestFunction(e:Event):void
		{		
			if (_blockedWaitingForNewFile)
				return;

			_testCount++;

			var testError:Boolean = false;
			var firstPerformMarkup:String;
			var testStage:String;
			try
			{
				testStage = "PERFORM";
				_runningTest.performFunction();
				if (_redo)
				{
					testStage = "EXPORT";
					firstPerformMarkup = TextConverter.export(_textFlow,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.STRING_TYPE) as String;
				}
				testStage = "UNDO";
				_runningTest.undoFunction();
			}
			catch (e:Error)
			{
				traceResult("EXCEPTION CAUGHT",e.toString());
				testError = true;
				reportError(testStage);
			}
			
			if (!testError)
			{
				var afterFirstUndoMarkup:String = TextConverter.export(_textFlow,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.STRING_TYPE) as String;
				if (afterFirstUndoMarkup != _textFlowMarkup)
				{
					trace(_textFlowMarkup);
					trace(afterFirstUndoMarkup);
					testError = true;
					reportError("UNDO MARKUP");
				}
				else if (_redo)
				{
					// redo the operation
					var afterRedoMarkup:String;
					
					try
					{
						testStage = "REDO";
						_runningTest.redoFunction();
						testStage = "EXPORT";
						afterRedoMarkup = TextConverter.export(_textFlow,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.STRING_TYPE) as String;
						testStage = "2ND UNDO";
						_runningTest.undoFunction();
					}
					catch (e:Error)
					{
						traceResult("EXCEPTION CAUGHT",e.toString());
						testError = true;
						reportError(testStage);
					}
					if (!testError)
					{
						if (firstPerformMarkup != afterRedoMarkup)
						{
							testError = true;
							reportError("REDO MARKUP");
						}
						else
						{
							var afterSecondUndoMarkup:String = TextConverter.export(_textFlow,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.STRING_TYPE) as String;
							if (afterSecondUndoMarkup != _textFlowMarkup)
							{
								testError = true;
								reportError("2ND UNDO MARKUP");
							}							
						}
					}
				}
			}
			
			if (testError)
			{
				// on error need to reset the textFlow to its original markup
				loadTextFlowFromString(TextConverter.TEXT_LAYOUT_FORMAT, _textFlowMarkup, false);
				_textFlow.interactionManager.selectRange(_runningTest.begSelIdx,_runningTest.endSelIdx);
				_textFlow.interactionManager.refreshSelection();
			}
			
			if (testError || (_testCount%250) == 0)
				_statusField.text = traceResult("TEST",_runningTest.testName ,_runningTest.getErrorInfo(), "TESTS", _testCount, "ERRORS", _errorCount);
			
			// do and undo the operation with the selection range.  verify that the textflow is unchanged
			if (_runningTest.isTestComplete())
			{
				if (this._activeFileReferenceList == null || this._activeFileIndex >= this._activeFileReferenceList.fileList.length-1)
					stopTest();
				else
				{
					_blockedWaitingForNewFile = true;
					_activeFileIndex++;
					loadActiveFileIndex();					
				}
			}
			else
				_runningTest.incrementTest();
		}
	}
}
import flashx.textLayout.edit.ElementMark;
import flashx.textLayout.edit.IEditManager;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.FlowGroupElement;
import flashx.textLayout.elements.TextFlow;

interface ITestCase
{
	function get begSelIdx():int;
	function get endSelIdx():int;
	function get objectMark():ElementMark;
	
	function get testName():String;
	function isTestComplete():Boolean;
	function incrementTest():void;

	function performFunction():void;
	function undoFunction():void;
	function redoFunction():void;
	
	/** call to reset a test case for reuse */
	function reset(textFlow:TextFlow):void;
	
	/** Used when running a test discovers an error to get the TextFlow back to the correct test version. */
	function changeTextFlow(newFlow:TextFlow):void;
	
	function getErrorInfo():String;

}

class StandardTestCase implements ITestCase
{
	private var _testName:String;
	private var _testFunction:Function;
	protected var _textFlow:TextFlow;
	
	private var _begSelIdx:int;
	private var _endSelIdx:int;
	private var _pointOnly:Boolean;
	private var _objectMode:Boolean;
	
	// used in _objectMode to track the current object
	private var _objectMark:ElementMark;
	private var _objectMarkArray:Array;
	
	// don't use original textFlow.length but the maximum length ever seen in performTest - that's because the textFlow may vary in length
	protected var _maxTextFlowLength:int;
	
	public function StandardTestCase(testName:String, func:Function,textFlow:TextFlow,pointOnly:Boolean,objectMode:Boolean)
	{
		_testName = testName;
		_testFunction = func;
		_pointOnly = pointOnly;
		_objectMode = objectMode;
		reset(textFlow);
	}
	
	public function reset(textFlow:TextFlow):void
	{
		_begSelIdx = 0;
		_endSelIdx = 0;
		_textFlow = textFlow;
		_maxTextFlowLength = _textFlow.textLength;
		
		if (_objectMode)
		{
			// just build a list of ElementMarks
			_objectMarkArray = [];
			buildFlowGroupChildList(_objectMarkArray,_textFlow);
			_objectMark = _objectMarkArray.shift();
			_begSelIdx = _endSelIdx = _objectMark.findElement(_textFlow).getAbsoluteStart();
		}
	}
		
	public static function buildFlowGroupChildList(a:Array,elem:FlowGroupElement):void
	{
		for (var idx:int = 0; idx < elem.numChildren; idx++)
		{
			var child:FlowElement = elem.getChildAt(idx);
			if (child is FlowGroupElement)
			{
				buildFlowGroupChildList(a,child as FlowGroupElement);
				a.push(new ElementMark(child,0));
			}
		}
	}
	
	public function get testName():String
	{ return _testName; }
	
	public function get begSelIdx():int
	{ return _begSelIdx; }

	public function get endSelIdx():int
	{ return _endSelIdx; }
	
	public function get objectMark():ElementMark
	{ return _objectMark; }

	public function get pointOnly():Boolean
	{ return _pointOnly; }
	
	public function changeTextFlow(newFlow:TextFlow):void
	{
		_textFlow = newFlow;
	}

	public function performFunction():void
	{
		_maxTextFlowLength = Math.max(_maxTextFlowLength,_textFlow.textLength);
		_textFlow.interactionManager.selectRange(_begSelIdx,_endSelIdx);
		_textFlow.interactionManager.refreshSelection();
		_testFunction();
	}
	
	public function undoFunction():void
	{
		(_textFlow.interactionManager as IEditManager).undo();
	}
	
	public function redoFunction():void
	{
		(_textFlow.interactionManager as IEditManager).redo();
	}
	
	public function incrementTest():void
	{
		if (_objectMode)
		{
			if (_pointOnly)
			{
				var elem:FlowGroupElement = _objectMark.findElement(_textFlow) as FlowGroupElement;
				var elemStart:int = _objectMark.elemStart;
				if (elemStart < elem.textLength)
					_objectMark = new ElementMark(elem,elemStart+1);
				else
					_objectMark = _objectMarkArray.shift();
				_begSelIdx = _endSelIdx = _objectMark.findElement(_textFlow).getAbsoluteStart() + _objectMark.elemStart;
			}
			else
			{
				var object:FlowElement = _objectMark.findElement(_textFlow);
				var objectEnd:int = object.getAbsoluteStart() + object.textLength;
				if (_begSelIdx == objectEnd && _endSelIdx == objectEnd)
				{
					_objectMark = _objectMarkArray.shift();
					object = _objectMark.findElement(_textFlow);
					_begSelIdx = _endSelIdx = object.getAbsoluteStart();
				}
				else if (_begSelIdx == _endSelIdx)
				{
					_begSelIdx = object.getAbsoluteStart();
					_endSelIdx++;
				}
				else
					_begSelIdx++;
			}
		}
		else if (_pointOnly)
		{
			_begSelIdx++;
			_endSelIdx = _begSelIdx;
		}
		else if (_begSelIdx < _endSelIdx)
			_begSelIdx++;
		else
		{
			_endSelIdx++;
			_begSelIdx = 0;
		}
	}
	
	public function isTestComplete():Boolean
	{
		return _begSelIdx >= _textFlow.textLength && _endSelIdx >= _textFlow.textLength && (!_objectMode || _objectMarkArray.length == 0);
	}
	
	public function getErrorInfo():String
	{
		return "(" + begSelIdx + "," + endSelIdx + ")";
	}
}
class NestedTestCase extends StandardTestCase
{
	private var _firstTest:ITestCase;
	
	public function NestedTestCase(testName:String,firstTest:ITestCase,secondFunction:Function,textFlow:TextFlow,pointOnly:Boolean)
	{
		super(testName,secondFunction,textFlow,pointOnly,false);
		_firstTest = firstTest; // ;
	}
	
	public override function changeTextFlow(newFlow:TextFlow):void
	{
		super.changeTextFlow(newFlow);
		_firstTest.changeTextFlow(newFlow);
	}
	
	public override function reset(textFlow:TextFlow):void
	{
		_firstTest.reset(textFlow);
		super.reset(textFlow);
	}
	
	public override function isTestComplete():Boolean
	{
		return _firstTest.isTestComplete() && super.isTestComplete();
	}
	
	public override function performFunction():void
	{
		_firstTest.performFunction();
		super.performFunction();
	}
	
	public override function undoFunction():void
	{
		super.undoFunction();
		_firstTest.undoFunction();
	}
	
	public override function redoFunction():void
	{
		_firstTest.redoFunction();
		super.redoFunction();	
	}
	
	public override function incrementTest():void
	{
		if (_firstTest.isTestComplete())
		{
			_firstTest.reset(_textFlow);
			super.incrementTest();
		}
		else
			_firstTest.incrementTest();
	}
	
	public override function getErrorInfo():String
	{
		return _firstTest.getErrorInfo() + " " + super.getErrorInfo();
	}
}