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

	import perfAppTests.VellumParaTestCanvas;

	public class VellumParaTests extends VellumPerformanceCase
	{
		public var VellumParaTestApp:VellumParaTestCanvas;

		public function VellumParaTests(methodName:String=null, testCaseXML:XML = null)
		{
			super(methodName, testCaseXML);
			TestClass = VellumParaTestCanvas;
		}

		public static function suiteFromXML(testListXML:XML):TestSuite
 		{
 			var testCaseClass:Class = VellumParaTests;
 			return VellumPerformanceCase.suiteFromXML(testCaseClass, testListXML);
 		}

		override public function tearDown() : void
		{
			setUpDuration = VellumParaTestApp.creationTimeElapsed/1000;
			middleDuration = VellumParaTestApp.renderTimeElapsed/1000;
			VellumParaTestApp = null;
			super.tearDown();
		}

		public function vellumParaTest():void
		{
			VellumParaTestApp = VellumParaTestCanvas(testApp);
			addAsyncForTestComplete();
			selectByName (VellumParaTestApp.testTypeCombo, (TestData.testType ? TestData.testType: "TextField"));
			VellumParaTestApp.iterationsInput.text = (TestData.iterationsInput ? TestData.iterationsInput: "100");
			VellumParaTestApp.paraLength.text = (TestData.paraLength ? TestData.paraLength: "5000");
			VellumParaTestApp.paraWidth.text = (TestData.paraWidthInput ? TestData.paraWidthInput : "1100");
			VellumParaTestApp.runTheTest();
		}
	}
}
