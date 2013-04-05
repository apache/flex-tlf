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
	import UnitTest.Fixtures.TestConfig;

	import flashx.textLayout.property.*;

	import flexunit.framework.Test;

	public class TestDescriptor
	{
		public var testClass:Class;
		public var testMethod:String;
		public var config:TestConfig;
		public var testXML:XML;

		// AllAttributeTest properties
		public var prop:Property = null;
		public var testValue:*;	// overloading this with the Array from FETest
		public var expectedValue:*;
		public var minimal:Boolean;

		public var testID:String;

		public function TestDescriptor(theClass:Class,
									   theMethod:String,
									   theConfig:TestConfig,
									   theXML:XML = null,
									   theProp:Property = null,
									   theTestValue:* = null,
									   theExpectedValue:* = null,
									   includeInMinimalTestSuite:Boolean = true)
		{
			testClass = theClass;
			testMethod = theMethod;
			config = theConfig.copyTestConfig();
			testXML = theXML;
			prop = theProp;
			testValue = theTestValue;
			expectedValue = theExpectedValue;
			minimal = includeInMinimalTestSuite;

			testID = className() + ":";
			if (testXML && testXML.TestData.(@name == "id").toString() != "")
			{
				testID = testID + testXML.TestData.(@name == "id").toString();
			}
			else if (prop)
			{
				testID = testID + prop.name + "=" + String(testValue);
			}
			else
			{
				testID = testID + testMethod;
			}
			testID = testID + "(" + config.containerType + "," + config.writingDirection + ")";

			if (testXML && testXML.TestData.(@name == "minimal").toString() != "")
			{
				minimal = (testXML.TestData.(@name == "minimal").toString() == "true");
			}
		}

		public function makeTest():Test
		{
			if (prop)
			{
				return new testClass(testMethod, testID, config, prop, testValue, expectedValue);
			}
			else if (testValue) // should be an array for the FETests
			{
				return new testClass(testMethod, testID, testValue, config, testXML);
			}
			else
			{
				return new testClass(testMethod, testID, config, testXML);
			}
		}

		public function className():String
		{
			// strip [class ]
			var tempStr:String = String(testClass);
			return tempStr.substr(7,tempStr.length - 8);
		}
	}
}
