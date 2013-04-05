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
package UnitTest.PerformanceTests
{
	import UnitTest.ExtendedClasses.VellumPerformanceCase;

	import flexunit.framework.TestSuite;

	import perfAppTests.InputTestCanvas;

	public class InputTests extends VellumPerformanceCase
	{
		public var InputTestApp:InputTestCanvas;

		public function InputTests(methodName:String=null, testCaseXML:XML = null)
		{
			super(methodName, testCaseXML);
			TestClass = InputTestCanvas;
		}

		public static function suiteFromXML(testListXML:XML):TestSuite
 		{
 			var testCaseClass:Class = InputTests;
 			return VellumPerformanceCase.suiteFromXML(testCaseClass, testListXML);
 		}

		override public function tearDown() : void
		{
			setUpDuration = InputTestApp.totalCreationTime/1000;
			middleDuration = InputTestApp.totalRenderTime/1000;
			InputTestApp = null;
			super.tearDown();
		}

		public function inputTest():void
		{
			InputTestApp = InputTestCanvas(testApp);
			addAsyncForTestComplete();
			selectByName (InputTestApp.testTypeCombo, (TestData.testType ? TestData.testType: "TextField"));
			InputTestApp.iterationsInput.text = (TestData.iterationsInput ? TestData.iterationsInput: "100");
			InputTestApp.runTest();
		}
	}
}
