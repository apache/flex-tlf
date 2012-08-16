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

	import perfAppTests.VellumWordTestCanvas;

	public class VellumWordTests extends VellumPerformanceCase
	{
		public var VellumWordTestApp:VellumWordTestCanvas;

		public function VellumWordTests(methodName:String=null, testCaseXML:XML = null)
		{
			super(methodName, testCaseXML);
			TestClass = VellumWordTestCanvas;
		}

		public static function suiteFromXML(testListXML:XML):TestSuite
 		{
 			var testCaseClass:Class = VellumWordTests;
 			return VellumPerformanceCase.suiteFromXML(testCaseClass, testListXML);
 		}

		override public function tearDown() : void
		{
			setUpDuration = VellumWordTestApp.totalCreationTime/1000;
			middleDuration = VellumWordTestApp.totalRenderTime/1000;
			VellumWordTestApp = null;
			super.tearDown();
		}

		public function vellumWordTest():void
		{
			VellumWordTestApp = VellumWordTestCanvas(testApp);
			addAsyncForTestComplete();
			selectByName (VellumWordTestApp.testTypeCombo, (TestData.testType ? TestData.testType: "TextField"));
			VellumWordTestApp.numberFieldsInput.text = (TestData.numberFieldsInput ? TestData.numberFieldsInput: "4000");
			VellumWordTestApp.numberIterationsInput.text = (TestData.iterationsInput ? TestData.iterationsInput: "1");
			VellumWordTestApp.testData.text = (TestData.testData ? TestData.testData: "Hello world");
			VellumWordTestApp.runTheTest();
		}
	}
}
