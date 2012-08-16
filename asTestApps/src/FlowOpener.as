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
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.TextFlow;
	
	[SWF(width="500", height="500")]
	public class FlowOpener extends Sprite
	{	
		public var _textFlow:TextFlow;
		
		public function FlowOpener()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			//addButton("Load ..",10,10,0,0,openDialog);
		}
		
		public function useTextFlow():void
		{
			// override this to do something with _textFlow
			// once it's read from the file.
		}
		
		public function openDialog(e:Event):void
		{
			if (_activeFileReference)
				return;
			
			var markupFilter:FileFilter = new FileFilter("Documents","*.xml;*.fxg;*.html");
			_activeFileReference = new FileReference();
			_activeFileReference.addEventListener(Event.SELECT,onFileSelect);
			_activeFileReference.addEventListener(Event.CANCEL,function (e:Event):void { _activeFileReference = null; },false,0,true);
			_activeFileReference.browse([markupFilter]);
		}
		
		// FileReference requires a reference or it will be garbage collected
		protected var _activeFileReference:FileReference;
				
		public function onFileSelect(event:Event):void 
		{
			_activeFileReference.addEventListener(Event.COMPLETE,onFileReferenceLoadComplete,false,0,true);
			_activeFileReference.addEventListener(IOErrorEvent.IO_ERROR,errorOnReadFromFileReference,false,0,true);
			
			
			_activeFileReference.load();
		}
		
		public function onFileReferenceLoadComplete(event:Event):void
		{
			var extension:String = getExtension(_activeFileReference.name).toLowerCase();
			var fileData:String  = String(_activeFileReference.data);
			_textFlow = parseDataFromFile(extension,fileData);
			
			if (_textFlow)
			{
				useTextFlow();
			}
			
			_activeFileReference = null;
		}
		
		
		public function errorOnReadFromFileReference(event:IOErrorEvent):void
		{
			// Text content will be an error string
			var errorString:String = "Error reading file " + _activeFileReference.name;
			errorString += "\n";
			errorString += event.toString();
			var textFlow:TextFlow = parseStringIntoFlow(errorString, TextConverter.PLAIN_TEXT_FORMAT)
			if (textFlow)
			{
				useTextFlow();
			}
			
			_activeFileReference = null;
		}
		
		static private function getExtension(fileName:String):String
		{
			var dotPos:int = fileName.lastIndexOf(".");
			if (dotPos >= 0)
				return fileName.substring(dotPos + 1);
			return fileName;
		}
		
		public function parseDataFromFile(extension:String,fileData:String, config:Configuration = null):TextFlow
		{
			var textFlow:TextFlow;
			switch (extension)
			{
				case "xml":		// use Vellum markup
					textFlow = parseStringIntoFlow(fileData, TextConverter.TEXT_LAYOUT_FORMAT, config);
					break;
				case "txt":
					textFlow = parseStringIntoFlow(fileData, TextConverter.PLAIN_TEXT_FORMAT, config);
					break;
				case "html":
					textFlow = parseStringIntoFlow(fileData, TextConverter.TEXT_FIELD_HTML_FORMAT, config);
					break;
			}
			return textFlow;
		}
		
		static private function parseStringIntoFlow(source:String, format:String, config:Configuration = null):TextFlow
		{
			var textImporter:ITextImporter = TextConverter.getImporter(format, config);
			var newFlow:TextFlow = textImporter.importToFlow(source);
			reportImportErrors(textImporter.errors);
			return newFlow;
		} 
		
		static private function reportImportErrors(errors:Vector.<String>):void
		{
			if (errors)
			{
				trace("ERRORS REPORTED ON IMPORT");
				for each(var e:String in errors)
				trace(e);
			}
		}
		
		public function addButton(text:String,x:Number,y:Number,width:Number,height:Number,handler:Function):TextField
		{
			var f1:TextField = new TextField();
			f1.text = text;
			f1.x = x; f1.y = y; 
			if (height > 0)
				f1.height = height;
			if (width > 0)
				f1.width = width;
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
		
	}
}