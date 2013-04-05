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
package UnitTest.Validation
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.TextFlow;
	
	import flexunit.framework.Assert;
	
	public class CompositionResults
	{
		static public function getContainerResults(container:Sprite):Array
		{
			var result:Array = [];
			for (var i:int = 0; i < container.numChildren; ++i)
			{
				var textLine:TextLine = container.getChildAt(i) as TextLine;
				if (textLine)
				{
					var lineResults:Array = getTextLineResults(textLine, 0);
					result.push(lineResults);
				}
			}
			return result;
		}
		static public function getTextFlowResults(textFlow:TextFlow):Array
		{
			var result:Array = [];
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			flowComposer.composeToPosition();
			for (var i:int = 0; i < flowComposer.numLines; ++i)
			{
				var line:TextFlowLine = textFlow.flowComposer.getLineAt(i);
				var textLine:TextLine = line.getTextLine();
				if (!textLine)
					textLine = line.getTextLine();
				var lineResults:Array = getTextLineResults(textLine, line.absoluteStart);
				result.push(lineResults);
			}
			return result;
		}
		
		static public function getFactoryResults(textLineArray:Array):Array
		{
			var result:Array = [];
			var pos:int = 0;
			for (var i:int = 0; i < textLineArray.length; ++i)
			{
				var textLine:TextLine = textLineArray[i] as TextLine;
				if (!textLine)
					trace("here we are");
				var lineResults:Array = getTextLineResults(textLine, pos);
				result.push(lineResults);
				pos += textLine.rawTextLength;
			}
			return result;
		}
		
		static private function getTextLineResults(textLine:TextLine, lineStart:int):Array
		{
			var lineResults:Array = [];
			lineResults.push(lineStart);
			lineResults.push(textLine.rawTextLength);
			lineResults.push(textLine.x);
			lineResults.push(textLine.y);
			return lineResults;
		}
		
		static public function compareResultsInternal(results1:Array, results2:Array, compareLocation:Boolean = true):int
		{
			// Returns first line # different, or -1 if same
			for (var i:int = 0; i < results2.length && i < results2.length; ++i)
			{
				if (results1[i][0] != results2[i][0] || results1[i][1] != results2[i][1])
					return i;
				if (compareLocation && (results1[i][2] != results2[i][2] || results1[i][3] != results2[i][3]))
					return i;
			}
			return -1;
		}
		
		static public function compareResults(results1:Array, results2:Array, compareLocation:Boolean = true):Boolean
		{
		//	if (compareLocation)
		//		return (results1.toString() == results2.toString());
			
			return (compareResultsInternal(results1, results2, compareLocation) == -1);
		}
		
		static public function assertEquals(message:String, results1:Array, results2:Array, compareLocation:Boolean):void
		{
			var firstLineDifference:int = compareResultsInternal(results1, results2, compareLocation);
			if (firstLineDifference >= 0)
			{
				trace("Composition results differ starting at line", firstLineDifference);
				for (var i:int = 0; i < results2.length && i < results2.length; ++i)
				{
					trace("results1 line", i, ":", results1[i].toString());
					trace("results2 line: ", i, ":", results2[i].toString());
				}
			}
			Assert.assertTrue(message, CompositionResults.compareResults(results1, results2, compareLocation));
		}
		
	}
}
