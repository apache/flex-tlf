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

	import perfAppTests.VellumTweenTestCanvas;

	public class TweenTests extends VellumPerformanceCase
	{
		public var TweenTestApp:VellumTweenTestCanvas;

		public function TweenTests(methodName:String=null, testCaseXML:XML = null)
		{
			super(methodName, testCaseXML);
			TestClass = VellumTweenTestCanvas;
		}

		public static function suiteFromXML(testListXML:XML):TestSuite
 		{
 			var testCaseClass:Class = TweenTests;
 			return VellumPerformanceCase.suiteFromXML(testCaseClass, testListXML);
 		}

		override public function tearDown() : void
		{
			setUpDuration = TweenTestApp.totalCreationTime/1000;
			middleDuration = TweenTestApp.totalRenderTime/1000;
			TweenTestApp = null;
			super.tearDown();
		}

		public function tweenTest():void
		{
			TweenTestApp = VellumTweenTestCanvas(testApp);
			addAsyncForTestComplete();
			selectByName (TweenTestApp.testTypeCombo, (TestData.testType ? TestData.testType: "TextField"));
			TweenTestApp.iterationsInput.text = (TestData.iterationsInput ? TestData.iterationsInput: "500");
			TweenTestApp.dataLength.text = (TestData.dataLength ? TestData.dataLength: "5000");
			TweenTestApp.minWidthInput.text = (TestData.minWidthInput ? TestData.minWidthInput : "100");
			TweenTestApp.maxWidthInput.text = (TestData.maxWidthInput ? TestData.maxWidthInput : "1000");
			TweenTestApp.widthStep.text = (TestData.widthStep ? TestData.widthStep: "100");
			TweenTestApp.runTheTest();
		}
	}

}
