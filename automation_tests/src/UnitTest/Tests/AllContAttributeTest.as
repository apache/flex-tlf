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
	import UnitTest.ExtendedClasses.TestSuiteExtended;
	import UnitTest.Fixtures.TestConfig;

	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.Category;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

	public class AllContAttributeTest extends AllAttributeTest
	{
		public function AllContAttributeTest(methodName:String, testID:String, testConfig:TestConfig, prop:Property, value:*, expected:*)
		{
			super (methodName, testID, testConfig, prop, value, expected);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Container";
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
 			testAllProperties(ts, testConfig, TextLayoutFormat.description, Category.CONTAINER, AllContAttributeTest, "runOneContainerAttributeTest");
   		}

   		public override function tearDown():void
		{
			SelManager.applyContainerFormat(TextLayoutFormat.defaultFormat);
			super.tearDown();
		}

		/**
		 * Generic function to run one container attribute test.  Uses the selection manager to set the attributes on the entire flow at the span level
		 * to value and then validates that the value is expectedValue.
		 */
		 public function runOneContainerAttributeTest():void
		 {
			 if (testProp == null)
				 return;	// must be set

			 SelManager.selectAll();

			 // Test direct change on single leaf
			 var controller:ContainerController = SelManager.textFlow.flowComposer.getControllerAt(0);
			 var originalValue:* = controller[testProp.name];

			 assignmentHelper(controller);

			 var expectedResult:*;
			 if (expectedValue === undefined)
				 expectedResult = testValue === undefined || testValue === null ? undefined : originalValue;
			 else
				 expectedResult = expectedValue;

			 assertTrue("Controller does not have the expected value after direct change", controller[testProp.name] == expectedResult);
			 controller[testProp.name] = originalValue;

			 var ca:TextLayoutFormat = new TextLayoutFormat();
			 assignmentHelper(ca);
			 SelManager.applyContainerFormat(ca);

			 // expect that all FlowLeafElements have expectedValue as the properties value
			 if (expectedValue !== undefined)
				 assertTrue("not all ContainerElements have the expected value", validateContainerPropertyOnEntireFlow(SelManager.textFlow,testProp,expectedValue));
		 }

		// support function to walk all FlowLeafElements and verify that prop is val
		static public function validateContainerPropertyOnEntireFlow(textFlow:TextFlow, prop:Property, val:*):Boolean
		{
			var idx:int = 0;
			var elem:FlowLeafElement = textFlow.getFirstLeaf();
			assertTrue("either the first FlowLeafElement is null or the textFlow length is zero", elem != null || textFlow.textLength == 0);
			while (elem)
			{
				// error if elements have zero length
				assertTrue("The FlowLeafElement has zero length", elem.textLength != 0);

				// expect all values of prop to be supplied val
				var controllerIndex:int = textFlow.flowComposer.findControllerIndexAtPosition(elem.getAbsoluteStart(),false);
				if (controllerIndex != -1)
				{
					var controller:ContainerController = textFlow.flowComposer.getControllerAt(controllerIndex);
					if (controller.format[prop.name] !== val)
						return false;

					// inherit is never computed
					if ((val == FormatValue.INHERIT && controller.computedFormat[prop.name] == val) || controller.computedFormat[prop.name] === undefined)
						return false;
				}

				// skip to the next element
				var nextElem:FlowLeafElement = elem.getNextLeaf();
				var absoluteEnd:int = elem.getAbsoluteStart() + elem.textLength;
				if (nextElem == null)
					assertTrue("absoluteEnd of the last FlowLeafElement is not the end of the textFlow", absoluteEnd == textFlow.textLength);
				else
					assertTrue("the end of this FlowLeafElement does not equal the start of the next", absoluteEnd == nextElem.getAbsoluteStart());

				elem = nextElem;
			}
			return true;
		}
	}
}
