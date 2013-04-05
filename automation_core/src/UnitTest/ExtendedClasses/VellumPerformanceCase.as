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
package UnitTest.ExtendedClasses
{
	import flash.events.Event;

	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;

	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.containers.Canvas;

	public class VellumPerformanceCase extends TestCase
	{
		private static const standardTimeout:int = 1000000;
		public static var testApp:Canvas;
		public var TestClass:Class;
		public var TestData:Object;
		public var TestID:String;

		public function VellumPerformanceCase(methodName:String=null, testCaseXML:XML = null)
		{
			TestData = new Object();

			if (testCaseXML)
			{
				for each (var testDataXML:XML in testCaseXML.*)
				{
					TestData[testDataXML.@name] = testDataXML.toString();
				}
			}

			// always add className to the TestID
			TestID = className.substr(className.lastIndexOf(':')+1) + '.';
			TestID = TestID + ((TestData.id) ? TestData.id : methodName);

			super(methodName);
		}

		override public function toString():String
		{
			return TestID + " (" + className + ")";
		}

		public static function suiteFromXML(testCaseClass:Class, testListXML:XML):TestSuite
		{
			var ts:TestSuite = new TestSuite();
 			for each (var testCaseXML:XML in testListXML.*)
			{
				ts.addTest (new testCaseClass(testCaseXML.@functionName, testCaseXML));
			}
   			return ts;
		}

		override public function tearDown() : void
		{
			TestData = null;
		}

		public function addAsyncForTestComplete (timeout:int = standardTimeout):void
		{
			testApp.addEventListener(Event.COMPLETE, addAsync(testComplete, timeout, null));
		}

		/** empty testComplete to call once the performance app sends
		 * its COMPLETE event.
		 */
		public function testComplete(eventObj:Event):void
		{
			testApp.removeEventListener(Event.COMPLETE, testComplete);
			//continue on to tearDown
		}

		/** this function assumes a ComboBox with an ArrayCollection as
		 * a dataProvider
		 */
		public function selectByName (aComboBox:ComboBox, strValue:String):Boolean
		{
			var a:ArrayCollection = ArrayCollection(aComboBox.dataProvider);
			for (var i:Number=0; i<a.length; i++)
			{
				if (a[i].label == strValue)
				{
					aComboBox.selectedIndex = i;
					return true;
				}
			}
			return false;
		}

	}
}
