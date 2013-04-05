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
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.ITextExporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;

	public class StringSnapshot
	{
		/**
		 * return PlainText data from the TextFlow in String
		 */
		public function takeSnapshot(aFlow:TextFlow, aFormat:String):String
		{
			var stringSnapshot:String = "aFormat + \"Snapshot\"}";
			// for compatibility with existing snapshots, use the old root tag
			// if we ever get to rebase everything, we could remove this line.
			//if (aFormat == TextConverter.TEXT_LAYOUT_FORMAT) xmlSnapshot = <XFLSnapshot/>;
			var filter:ITextExporter = TextConverter.getExporter(aFormat);
			stringSnapshot = filter.export(aFlow, ConversionType.STRING_TYPE) as String;

			return stringSnapshot;
		}

		public function compare (baseline:String, current:String):Boolean
		{
			var Result:Boolean = true;
			if(baseline.length != current.length)
				Result = false;
			else
			{
				for(var i:int=0;i<baseline.length;i++)
				{
					if(baseline.charAt(i) != current.charAt(i))
						Result = false;
				}
			}
			return Result;
		}


	}
}
