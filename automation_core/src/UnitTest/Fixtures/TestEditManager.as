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
package UnitTest.Fixtures
{
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.ITextExporter;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.operations.FlowOperation;
	import flashx.undo.IUndoManager;
	import flashx.undo.UndoManager;
	
	public class TestEditManager extends EditManager
		{
			private var textExporter:ITextExporter = TextConverter.getExporter(TextConverter.TEXT_LAYOUT_FORMAT);
			public var errors:String;
			
			public function TestEditManager(undoManager:IUndoManager = null)
			{
				super (undoManager);
				errors = "";
			}
			private function addError(newError:String):void
			{
				errors = errors + "\r" + newError;
			}

			override public function doOperation(operation:FlowOperation):void	
			{	
				var snapShotBefore:String = textExporter.export(operation.textFlow, ConversionType.STRING_TYPE) as String;
				super.doOperation(operation);	
				flushPendingOperations();
				var snapShotAfter:String = textExporter.export(operation.textFlow, ConversionType.STRING_TYPE) as String;
				
				//undo operation
				undo();
				flushPendingOperations();
				var snapShotCurrent:String = textExporter.export(operation.textFlow, ConversionType.STRING_TYPE) as String;
				if (snapShotBefore != snapShotCurrent)
				{
					addError ("First Undo didn't work properly");
				}

				//redo operation
				redo();
				flushPendingOperations();
				snapShotCurrent = textExporter.export(operation.textFlow, ConversionType.STRING_TYPE) as String;
				if (snapShotAfter != snapShotCurrent)
				{
					addError ("First Redo didn't work properly");
				}
				
				//undo operation
				undo();
				flushPendingOperations();
				snapShotCurrent = textExporter.export(operation.textFlow, ConversionType.STRING_TYPE) as String;
				if (snapShotBefore != snapShotCurrent)
				{
					addError ("Second Undo didn't work properly");
				}
				
				//redo operation
				redo();
				flushPendingOperations();
				snapShotCurrent = textExporter.export(operation.textFlow, ConversionType.STRING_TYPE) as String;
				if (snapShotAfter != snapShotCurrent)
				{
					addError ("Second Redo didn't work properly");
				}
				
				//undo operation
				undo();
				flushPendingOperations();
				snapShotCurrent = textExporter.export(operation.textFlow, ConversionType.STRING_TYPE) as String;
				if (snapShotBefore != snapShotCurrent)
				{
					addError ("Third Undo didn't work properly");
				}
				
				//redo operation
				redo();
				flushPendingOperations();
				snapShotCurrent = textExporter.export(operation.textFlow, ConversionType.STRING_TYPE) as String;
				if (snapShotAfter != snapShotCurrent)
				{
					addError ("Third Redo didn't work properly");
				}
			}
			
			public function UndoRedoEntireStack(testManager:UndoManager):int
			{
				var i:int = 0;
				while (testManager.canUndo())
				{
					testManager.undo();
					i++;
				}
				while (testManager.canRedo())
				{
					testManager.redo();
				}
				return i;
			}
	}
}
