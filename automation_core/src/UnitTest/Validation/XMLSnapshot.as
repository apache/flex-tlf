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
	import flash.utils.ByteArray;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.ITextExporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;

	public class XMLSnapshot
	{
		private var baselineXMLStack:Array = new Array();
		private var currentXMLStack:Array = new Array();

		/**
		 * return line data from the TextFlow in XML
		 */
		public function takeSnapshot(aFlow:TextFlow, aFormat:String):XML
		{
			var xmlSnapshot:XML = <{aFormat + "Snapshot"}/>;
			// for compatibility with existing snapshots, use the old root tag
			// if we ever get to rebase everything, we could remove this line.
			//if (aFormat == TextConverter.TEXT_LAYOUT_FORMAT) xmlSnapshot = <XFLSnapshot/>;
			var filter:ITextExporter = TextConverter.getExporter(aFormat);
			xmlSnapshot = filter.export(aFlow, ConversionType.XML_TYPE) as XML;

			var xmlDataBytes:ByteArray = new ByteArray();
			xmlSnapshot.normalize();
			xmlDataBytes.writeObject (xmlSnapshot);
			xmlDataBytes.compress();
			xmlDataBytes.uncompress();
			xmlSnapshot = new XML(xmlDataBytes.readObject());
			xmlSnapshot.normalize();

			return xmlSnapshot;
		}

		/**
		 * compare the two snapshots
		 * a list of differences in XML are returned
		 * null is returned if the snapshots are identical
		 */

		private function removeExtraSpace(tmpString:String):String
		{
			var iCount:Number = tmpString.length;
			var newString:String = "";
			for (var i:Number = iCount; i > 0; i--)
			{
				var tmpChar:Number = tmpString.charCodeAt(i);
				if (!((tmpChar == 32) || (tmpChar == 10)))
					newString += tmpString.charAt(i);
			}
			return newString;
		}

		public function compare (baseline:XML, current:XML):Boolean
		{
			var Result:Boolean = true;

			baseline.normalize();
			current.normalize();
			var strBaseline:String = baseline.toXMLString();
			var strCurrent:String = current.toXMLString();

			if (strBaseline != strCurrent)
				Result = false;

			return Result;
		}

		public function compareAdvanced (baseline:XML, current:XML):Boolean
		{
			baseline.normalize();
			current.normalize();

			if (!compareElements(baseline, current))
				return false;

			return compareAdvancedChildren(baseline, current);
		}
		
		private function compareAdvancedChildren (baseline:XML, current:XML):Boolean
		{
			var result:Boolean = true;
			var baselineStack:Array = new Array();
			var currentStack:Array = new Array();
			var baselineChild:XML;
			var currentChild:XML;
			
			var baselineChildren:XMLList = baseline.children();
			var currentChildren:XMLList = current.children();
			
			for each (baselineChild in baselineChildren)
			{
				baselineStack.push(baselineChild);
				//trace(baselineChild.toString());
			}
			for each (currentChild in currentChildren)
			{
				currentStack.push(currentChild);
				//trace(currentChild.toString());
			}
			baselineChild = baselineStack.shift();
			currentChild = currentStack.shift();
			while ((baselineChild != null) && (currentChild != null) && result)
			{
				if (!compareElements(baselineChild, currentChild))
					return false;
				result = compareAdvancedChildren(baselineChild, currentChild);
				if (result)
				{
					baselineChild = baselineStack.shift();
					currentChild = currentStack.shift();
				}
			}
			return result;
			
			
		}
		private function compareElements(baselineChild:XML, currentChild:XML):Boolean
		{
			if (baselineChild.nodeKind() != currentChild.nodeKind())
				return false;
 			else if (baselineChild.name() != currentChild.name())
				return false;
			else if (baselineChild.text() != currentChild.text())
				return false;
			else if (baselineChild.children().length() != currentChild.children().length())
				return false;
			else if (!(compareAttributes (baselineChild, currentChild)))
				return false;
			return true;
		}

		public function createDiff (baseline:XML, current:XML):Boolean
		{
			var Result:Boolean = true;
			var baselineStack:Array = new Array();
			var currentStack:Array = new Array();
			var baselineChild:XML;
			var currentChild:XML;
			var strProblem:String;

			baseline.normalize();
			current.normalize();
			var baselineChildren:XMLList = baseline.children();
			var currentChildren:XMLList = current.children();

			for each (baselineChild in baselineChildren)
			{
				baselineStack.push(baselineChild);
			}

			for each (currentChild in currentChildren)
			{
				currentStack.push(currentChild);
			}

			baselineChild = baselineStack.shift();
			currentChild = currentStack.shift();

			while ((baselineChild != null) && (currentChild != null))
			{
				strProblem = "";
				if (baselineChild.nodeKind() != currentChild.nodeKind())
				{
					strProblem = "Type";
					//trace("Not the same kind of node.");
					// Mark node with problem attribute.
					currentChild.@compError = "type";
				}
				else if (baselineChild.name() != currentChild.name())
				{
					strProblem = "Name";
					//trace("Names not the same.");
					currentChild.@compError = "name";
				}
				else if (baselineChild.text() != currentChild.text())
				{
					strProblem = "Text";
					//trace("Text is not the same");
					// Mark node with problem attribute.
					currentChild.@compError = "text";
				}
				else if (baselineChild.children().length() != currentChild.children().length())
				{
					strProblem = "Count";
					//trace("Not the same number of kids.");
				}
				else if (!(compareAttributes (baselineChild, currentChild)))
				{
					strProblem = "Attributes";
					//trace("Attributes not the same.");
					currentChild.@compError = "attribute";
				}

				baselineXMLStack.push(baselineChild.toString());
				createDiff(baselineChild, currentChild);
				baselineChild = baselineStack.shift();
				currentChild = currentStack.shift();
			}

			while (baselineChild != null)
			{
				//trace("A -" + baselineChild.nodeKind() + " - " + baselineChild.name() + " - " + baselineChild.text());
				baselineChild.@compError = "extra";
				baselineChild = baselineStack.shift();
			}


			while (currentChild != null)
			{
				//trace("B -" + currentChild.nodeKind() + " - " + currentChild.name() + " - " + currentChild.text()  );
				currentChild.@compError = "extra";
				currentChild = currentStack.shift();
			}

			return Result;


		}


		private function compareAttributes(baseline:XML, current:XML):Boolean
		{
			var Result:Boolean = true;

			var baselineAttributes:XMLList = baseline.attributes();
			var baselineAttribute:XML;
			var arBaseAttributes:Array = new Array();
			var arCurrentAttributes:Array = new Array();

			for each (baselineAttribute in baselineAttributes)
			{
				arBaseAttributes.push({Name:baselineAttribute.name(), Value:baselineAttribute.toString()});
			}
			var currentAttributes:XMLList = current.attributes();
			var currentAttribute:XML;
			for each (currentAttribute in currentAttributes)
			{
				arCurrentAttributes.push({Name:currentAttribute.name(), Value:currentAttribute.toString()});
			}

			if (arBaseAttributes.length != arCurrentAttributes.length)
				Result = false;
			else
			{
				arCurrentAttributes.sortOn("Name");
				arBaseAttributes.sortOn("Name");

				var tmpBaseAttribute:Object = arCurrentAttributes.shift();
				var tmpCurrentAttribute:Object = arBaseAttributes.shift();

				while (tmpBaseAttribute != null)
				{
					if (!((tmpBaseAttribute.Name == tmpCurrentAttribute.Name) && (tmpBaseAttribute.Value == tmpCurrentAttribute.Value)))
					{
						Result = false;
						break;
					}
					tmpBaseAttribute = arCurrentAttributes.shift();
					tmpCurrentAttribute = arBaseAttributes.shift();
				}
			}

			return Result;
		}

	}
}
