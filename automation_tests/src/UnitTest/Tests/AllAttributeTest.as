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
package UnitTest.Tests
{
	import UnitTest.ExtendedClasses.TestDescriptor;
	import UnitTest.ExtendedClasses.TestSuiteExtended;
	import UnitTest.ExtendedClasses.VellumTestCase;
	import UnitTest.Fixtures.TestConfig;
	
	import flash.display.Sprite;
	
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.formats.Category;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.*;

	/** Base class for All*AttributeTest */
	public class AllAttributeTest extends VellumTestCase
	{
		// test specific configuration
		protected var testProp:Property;
		protected var testValue:*;
		protected var expectedValue:*;

		public function AllAttributeTest(methodName:String, testID:String, testConfig:TestConfig, prop:Property, testValue:*, expectedValue:*)
		{
			super (methodName, testID, testConfig);

			// assert(testValue != null,"null?");
			testProp = prop;
			this.testValue = testValue;
			this.expectedValue = expectedValue;

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Attributes";
		}

		/* ************************************************************** */
		/* Use Format description and Property classes to generate testcases for Format in description
		/* ************************************************************** */

		/** Build testcases for all properties in the description. Depending on the property type iterate over possible values and test. */
		static internal function testAllProperties(ts:TestSuiteExtended, testConfig:TestConfig, description:Object, category:String, testClass:Class, methodName:String):void
		{
			testAllNumberPropsFromMinToMax(ts, testConfig, description, category, testClass, methodName);
   			testAllIntPropsFromMinToMax(ts, testConfig, description, category, testClass, methodName);
   			testAllNumberOrPercentPropsFromMinToMax(ts, testConfig, description, category, testClass, methodName);
			testAllBooleanProps(ts, testConfig, description, category, testClass, methodName);
			testAllEnumProps(ts, testConfig, description, category, testClass, methodName);
			testAllSharedValues(ts, testConfig, description, category, testClass, methodName);
		}

		/**
		 * This builds testcases for properties in description that are Number types.  For each number property
		 * testcases are built to set the value to the below the minimum value, step from the minimum value to the maximum value
		 * and then above the maximum value.
		 */
		static internal function testAllNumberPropsFromMinToMax(ts:TestSuiteExtended, testConfig:TestConfig, description:Object, category:String, testClass:Class, methodName:String):void
		{
			for each (var prop:Property in description)
			{
				var handler:NumberPropertyHandler = prop.findHandler(NumberPropertyHandler) as NumberPropertyHandler;
				
				if (handler && prop.category == category)
				{
					var minVal:Number = handler.minValue;
					var maxVal:Number = handler.maxValue;
					assertTrue(true, minVal < maxVal);
					var delta:Number = (maxVal-minVal)/10;
					var includeInMinimalTestSuite:Boolean;

					for (var value:Number = minVal-delta;;)
					{
						var expectedValue:* = value < minVal ? undefined : (value > maxVal ? undefined : value);

						// include in the minmalTest values below the range, min value, max value and values above the range
						includeInMinimalTestSuite = (value <= minVal || value >= maxVal)

						ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, value, expectedValue, includeInMinimalTestSuite) );

						if (value > maxVal)
							break;
						value += delta;
					}
				}
			}
		}
		/**
		 * This builds testcases for properties in attributes in description that are Int types.  For each number property
		 * testcases are built to set the value to the below the minimum value, step from the minimum value to the maximum value
		 * and then above the maximum value.
		 */
		static internal function testAllIntPropsFromMinToMax(ts:TestSuiteExtended, testConfig:TestConfig, description:Object, category:String, testClass:Class, methodName:String):void
		{
			for each (var prop:Property in description)
			{
				if (prop.category == category)
				{
					var handler:IntPropertyHandler = prop.findHandler(IntPropertyHandler) as IntPropertyHandler;
					if (handler)
					{
						var minVal:int = handler.minValue;
						var maxVal:int = handler.maxValue;
						assertTrue(true, minVal < maxVal);
						var delta:int = (maxVal-minVal)/10;
						var includeInMinimalTestSuite:Boolean;
	
						for (var value:Number = minVal-delta;;)
						{
							var expectedValue:* = value < minVal ? undefined : (value > maxVal ? undefined : value);
	
							// include in the minmalTest values below the range, min value, max value and values above the range
							includeInMinimalTestSuite = (value <= minVal || value >= maxVal)
	
							ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, value, expectedValue, includeInMinimalTestSuite) );
	
							if (value > maxVal)
								break;
							value += delta;
						}
					}
				}
			}
		}
		/**
		 * This builds testcases for properties in description that are NumberOrPercent types.  For each number property
		 * testcases are built to set the value to the below the minimum value, step from the minimum value to the maximum value
		 * and then above the maximum value.  This is done first using the min/max number values and then the min/max percent values.
		 */
		static internal function testAllNumberOrPercentPropsFromMinToMax(ts:TestSuiteExtended, testConfig:TestConfig, description:Object, category:String, testClass:Class, methodName:String):void
		{
			for each (var prop:Property in description)
			{
				if (prop.category == category)
				{
					var numberHandler:NumberPropertyHandler = prop.findHandler(NumberPropertyHandler) as NumberPropertyHandler;
					var percentHandler:PercentPropertyHandler = prop.findHandler(PercentPropertyHandler) as PercentPropertyHandler;
					if (numberHandler && percentHandler)
					{
						var minVal:Number = numberHandler.minValue;
						var maxVal:Number = numberHandler.maxValue;
						assertTrue(true, minVal < maxVal);
						var delta:Number = (maxVal-minVal)/10;
						var includeInMinimalTestSuite:Boolean;
	
						for (var value:Number = minVal-delta;;)
						{
							var expectedValue:* = value < minVal ? undefined : (value > maxVal ? undefined : value);
	
							// include in the minmalTest values below the range, min value, max value and values above the range
							includeInMinimalTestSuite = (value <= minVal || value >= maxVal)
	
							ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, value, expectedValue, includeInMinimalTestSuite) );
	
							if (value > maxVal)
								break;
							value += delta;
						}

						// repeat with percent values
						minVal = percentHandler.minValue;
						maxVal = percentHandler.maxValue;
						assertTrue(true, minVal < maxVal);
						delta = (maxVal-minVal)/10;
	
						for (value = minVal-delta;;)
						{
							expectedValue = value < minVal ? undefined : (value > maxVal ? undefined : value.toString()+"%");
							ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, value.toString()+"%", expectedValue, true) );
	
							if (value > maxVal)
								break;
							value += delta;
						}
					}
				}
			}
		}
		/**
		 * This builds testcases for properties in attributes in description that are Boolean types.  A testcase is generated
		 * for true and false for the value.
		 */
		static internal function testAllBooleanProps(ts:TestSuiteExtended, testConfig:TestConfig, description:Object, category:String, testClass:Class, methodName:String):void
		{
			for each (var prop:Property in description)
			{
				if (prop.category == category && prop.findHandler(BooleanPropertyHandler) != null)
				{
					ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, true, true, true) );
					ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, false, false, true) );
				}
			}
		}

		/**
		 * This builds testcases for properties in attributes in description that are Enumerated types types.  A testcase is generated
		 * for each possible enumerated value
		 */
		static internal function testAllEnumProps(ts:TestSuiteExtended, testConfig:TestConfig, description:Object, category:String, testClass:Class, methodName:String):void
		{
			var range:Object;
			var value:Object;
			
			for each (var prop:Property in description)
			{
				// new code
				if (prop.category == category)
				{
					var handler:EnumPropertyHandler = prop.findHandler(EnumPropertyHandler) as EnumPropertyHandler;
					if (handler)
					{
						range = handler.range;
						for (value in range)
						{
							if ( value != FormatValue.INHERIT )
								ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, value, value, true) );
						}
						ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, "foo", undefined, true) );
					}
					
				}
			}
		}
		/**
		 * This builds testcases for setting all properties in description to inherit, null, undefined and an object.
		 */
		static internal function testAllSharedValues(ts:TestSuiteExtended, testConfig:TestConfig, description:Object, category:String, testClass:Class, methodName:String):void
		{
			for each (var prop:Property in description)
			{
				if (prop.category == category)
				{
					ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, FormatValue.INHERIT, FormatValue.INHERIT, true) );
					// try an object, null and undefined
					ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, new Sprite(), undefined, false) );
					ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, null, undefined, false) );
					ts.addTestDescriptor( new TestDescriptor (testClass, methodName, testConfig, null, prop, undefined, undefined, false) );
					ts.addTestDescriptor( new TestDescriptor (testClass,"clearFormatTest", testConfig, null, prop, undefined, undefined, false));
				}
			}
		}

		public function clearFormatTest():void
		{
			SelManager.selectAll();

			var applyFormat:TextLayoutFormat  = new TextLayoutFormat();
			applyFormat[testProp.name] =  testProp.defaultValue;
			var clearFormat:TextLayoutFormat  = new TextLayoutFormat();
			clearFormat[testProp.name] =  FormatValue.INHERIT;

			switch(testProp.category)
			{
				case Category.CHARACTER:
					SelManager.applyFormat(applyFormat,null,null);
					AllCharAttributeTest.validateCharacterPropertyOnEntireFlow(SelManager.textFlow,testProp,testProp.defaultValue);
					SelManager.clearFormat(clearFormat,null,null);
					AllCharAttributeTest.validateCharacterPropertyOnEntireFlow(SelManager.textFlow,testProp,undefined);
					break;
				case Category.PARAGRAPH:
					SelManager.applyFormat(null,applyFormat,null);
					AllParaAttributeTest.validateParagraphPropertyOnEntireFlow(SelManager.textFlow,testProp,testProp.defaultValue);
					SelManager.clearFormat(null,clearFormat,null);
					AllParaAttributeTest.validateParagraphPropertyOnEntireFlow(SelManager.textFlow,testProp,undefined);
					break;
				case Category.CONTAINER:
					SelManager.applyFormat(null,null,applyFormat);
					AllContAttributeTest.validateContainerPropertyOnEntireFlow(SelManager.textFlow,testProp,testProp.defaultValue);
					SelManager.clearFormat(null,null,clearFormat);
					AllContAttributeTest.validateContainerPropertyOnEntireFlow(SelManager.textFlow,testProp,undefined);
					break;
			}
		}

		private var errorHandlerCount:int = 0;
		public function errorHandler(p:Property,value:Object):void
		{
			errorHandlerCount++;
		}

		protected function assignmentHelper(target:Object):void
		{
			Property.errorHandler = errorHandler;
			errorHandlerCount = 0;
			try {
				target[testProp.name] = testValue;
			}
			catch (e:Error)
			{
				Property.errorHandler = Property.defaultErrorHandler;
				assertTrue("Unexpected error in AllAttributeTest.assignmentHelper", false);
				throw(e);
			}
			Property.errorHandler = Property.defaultErrorHandler;

			if (expectedValue == undefined && testValue != undefined)
			{
				// expect an error
				assertTrue("Error expected but no error in AllAttributeTest.assignmentHelper",errorHandlerCount == 1);
			}
			else
			{
				// no error
				assertTrue("Error not expected but error found in AllAttributeTest.assignmentHelper",errorHandlerCount == 0);
			}
		}
	}
}
