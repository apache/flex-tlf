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

	import perfAppTests.VellumAliceScrollCanvas;

	public class VellumAliceScroll extends VellumPerformanceCase
	{
		public var VellumAliceTestApp:VellumAliceScrollCanvas;

		public function VellumAliceScroll(methodName:String=null, testCaseXML:XML = null)
		{
			super(methodName, testCaseXML);
			TestClass = VellumAliceScrollCanvas;
		}

		public static function suiteFromXML(testListXML:XML):TestSuite
 		{
 			var testCaseClass:Class = VellumAliceScroll;
 			return VellumPerformanceCase.suiteFromXML(testCaseClass, testListXML);
 		}

		override public function tearDown() : void
		{
			setUpDuration = VellumAliceTestApp.totalScrollTime/1000;
			middleDuration = VellumAliceTestApp.totalRenderTime/1000;
			VellumAliceTestApp = null;
			super.tearDown();
		}

		public function aliceScroll():void
		{
			VellumAliceTestApp = VellumAliceScrollCanvas(testApp);
			addAsyncForTestComplete	(10000000);
			// VellumAliceTestApp.iterationsInput.text = (TestData.iterationsInput ? TestData.iterationsInput: "1");
			VellumAliceTestApp.runTheTest();
		}
	}
}
