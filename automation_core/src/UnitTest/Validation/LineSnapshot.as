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
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.compose.IFlowComposer;

	public class LineSnapshot
	{
		/* abandoned in favor of the code already in VellumUnit
		 * main entry point -
		 * 1. snapshots the line data for a TextFlow
		 * 2. looks for a baseline based on the test ID
		 * 3a. saves a baseline if none present
		 * 3b. compares against baseline if one is found
		 * 4a. returns differences
		 * 4b. returns null if there are no differences or if 3a occurred

		public function snapshot(aFlow:TextFlow, testID:String):XML
		{
			return takeSnapshot (aFlow);
		}
		*/

		/**
		 * return line data from the TextFlow in XML
		 */
		public function takeSnapshot(aFlow:TextFlow):XML
		{
			var newSnapshot:XML = <LineSnapshot/>;

			for (var i:int = 0; i < aFlow.flowComposer.numLines; i++)
			{
				try
				{
					CONFIG::debug { newSnapshot = newSnapshot.appendChild(aFlow.flowComposer.getLineAt(i).dumpToXML()); }
				}
				catch (m:Error)
				{
					// error for overset text?
				}
			}

			return newSnapshot;
		}

		/**
		 * compare the two snapshots
		 * a list of differences in XML are returned
		 * null is returned if the snapshots are identical
		 */
		public function compare (baseline:XML, current:XML):String
		{
			var differences:String = "";

			var baselineLineCount:int = baseline.child('line').length();
			var currentLineCount:int = current.child('line').length();

			if (baselineLineCount != currentLineCount)
			{
				differences = "line count changed from " + baselineLineCount + " to " + currentLineCount;
				return differences;
			}

			var textLengthDiff:int = 0;

			for (var i:int = 0; i < baselineLineCount; i++)
			{
				textLengthDiff = current.child('line')[i].@textLength - baseline.child('line')[i].@textLength
				if (textLengthDiff != 0)
				{
					differences = differences + "\rline " + i + " textLength off by " + textLengthDiff;
				}
			}
			return differences;
		}
	}
}
