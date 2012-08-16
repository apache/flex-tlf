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
	
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ListElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.operations.ApplyElementIDOperation;
	import flashx.textLayout.operations.ApplyElementStyleNameOperation;
	import flashx.textLayout.operations.ApplyElementTypeNameOperation;
	import flashx.textLayout.operations.ApplyElementUserStyleOperation;
	import flashx.textLayout.operations.ApplyFormatToElementOperation;

 	public class ElementOperationTests extends VellumTestCase
	{
		public function ElementOperationTests(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super(methodName, testID, testConfig);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Editing";
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			if (testConfig.writingDirection[0] == "tb" && testConfig.writingDirection[1] == "ltr")
			{
	   			ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changeTextFlowIdTest", testConfig ) );
	   			ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changeFirstParagraphIdTest", testConfig ) );
	   			ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changePartialParagraphIdTest", testConfig ) );
	   			ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changePartialSpanIdTest", testConfig ) );
	
	   			ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changeTextFlowStyleNameTest", testConfig ) );
	   			ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changeFirstParagraphStyleNameTest", testConfig ) );
	   			ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changePartialParagraphStyleNameTest", testConfig ) );
	   			ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changePartialSpanStyleNameTest", testConfig ) );
				
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changeTextFlowTypeNameTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changeFirstParagraphTypeNameTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changePartialParagraphTypeNameTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changePartialSpanTypeNameTest", testConfig ) );
	
	   			ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changeTextFlowUserStyleTest", testConfig ) );
	   			ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changeFirstParagraphUserStyleTest", testConfig ) );
	   			ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changePartialParagraphUserStyleTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "changePartialSpanUserStyleTest", testConfig ) );
	
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "deleteAcrossDivBoundaryTest", testConfig ) );
				
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "splitStyledParagraphTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "BreaksSplitTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "splitStyledListItemTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "splitStyledAnchorTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "spanElementReplaceTextInvalidPos", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "copyErrorMassageTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "applyFormatToElementOperationFormatTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ElementOperationTests, "typeNameSetGetTest", testConfig ) );
			}
   		}

		/**
		 */
		public function changeTextFlowIdTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var origId:String = tf.id;
			var newId:String = "newTFId";

			SelManager.doOperation(new ApplyElementIDOperation(SelManager.getSelectionState(),tf,newId));
			assertTrue("changeTextFlowIdTest doOperation error", tf.id == newId);
			SelManager.undo();
			assertTrue("changeTextFlowIdTest undo error", tf.id == origId);
			SelManager.redo();
			assertTrue("changeTextFlowIdTest redo error", tf.id == newId);
		}

		/**
		 */
		public function changeFirstParagraphIdTest():void
		{
			var p:ParagraphElement = SelManager.textFlow.getChildAt(0) as ParagraphElement;
			var origId:String = p.id;
			var newId:String = "newParaId";

			SelManager.doOperation(new ApplyElementIDOperation(SelManager.getSelectionState(),p,newId));
			assertTrue("changeFirstParagraphIdTest doOperation error", p.id == newId);
			SelManager.undo();
			assertTrue("changeFirstParagraphIdTest undo error", p.id == origId);
			SelManager.redo();
			assertTrue("changeFirstParagraphIdTest redo error", p.id == newId);
		}

		/**
		 */
		public function changePartialParagraphIdTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var numParas:int = tf.numChildren;
			var totalLength:int = tf.textLength;

			var p:ParagraphElement = tf.getChildAt(0) as ParagraphElement;
			var origId:String = p.id;
			var origTextLength:int = p.textLength;
			var newId:String = "newParaId";

			// creates two new paragraphs
			SelManager.doOperation(new ApplyElementIDOperation(SelManager.getSelectionState(),p,newId,10,20));
			p = tf.findLeaf(11).getParagraph();	// prev para gets a terminator added
			assertTrue("changePartialParagraphIdTest doOperation error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphIdTest doOperation error id", p.id == newId);
			assertTrue("changePartialParagraphIdTest doOperation error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphIdTest doOperation error totalLength", tf.textLength == totalLength+2);

			SelManager.undo();
			p = tf.findLeaf(10).getParagraph();
			assertTrue("changePartialParagraphIdTest undo error", p.id == origId && p.textLength == origTextLength);
			assertTrue("changePartialParagraphIdTest undo error numParas", tf.numChildren == numParas);
			assertTrue("changePartialParagraphIdTest undo error totalLength", tf.textLength == totalLength);

			SelManager.redo();
			p = tf.findLeaf(11).getParagraph();
			assertTrue("changePartialParagraphIdTest redo error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphIdTest redo error", p.id == newId);
			assertTrue("changePartialParagraphIdTest redo error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphIdTest redo error totalLength", tf.textLength == totalLength+2);
		}

		/**
		 */
		public function changePartialSpanIdTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var numParas:int = tf.numChildren;
			var totalLength:int = tf.textLength;

			var span:SpanElement = tf.getLastLeaf() as SpanElement;
			assertTrue("changePartialSpanIdTest span is too short for the test",span.textLength > 20);
			var spanStart:int = span.getAbsoluteStart();

			var origId:String = span.id;
			var origSpanLength:int = span.textLength;
			var newId:String = "newSpanId";

			// splits the span
			SelManager.doOperation(new ApplyElementIDOperation(SelManager.getSelectionState(),span,newId,10,20));

			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanIdTest doOperation error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanIdTest doOperation error id", span.id == newId);
			assertTrue("changePartialSpanIdTest doOperation error totalLength", tf.textLength == totalLength);

			SelManager.undo();
			span = tf.findLeaf(spanStart) as SpanElement;
			assertTrue("changePartialSpanIdTest undo error", span.id == origId && span.textLength == origSpanLength);
			assertTrue("changePartialSpanIdTest undo error totalLength", tf.textLength == totalLength);

			SelManager.redo();
			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanIdTest redo error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanIdTest redo error", span.id == newId);
			assertTrue("changePartialSpanIdTest redo error totalLength", tf.textLength == totalLength);
		}

		/**
		 */
		public function changeTextFlowStyleNameTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var origStyleName:String = tf.styleName;
			var newStyleName:String = "newTFStyleName";

			// ApplyElementStyleNameOperation is deprecated
			SelManager.doOperation(new ApplyElementStyleNameOperation(SelManager.getSelectionState(),tf,newStyleName));
			assertTrue("changeTextFlowStyleNameTest doOperation error", tf.styleName == newStyleName);
			SelManager.undo();
			assertTrue("changeTextFlowStyleNameTest undo error", tf.styleName == origStyleName);
			SelManager.redo();
			assertTrue("changeTextFlowStyleNameTest redo error", tf.styleName == newStyleName);
			
			SelManager.undo();
			assertTrue("changeTextFlowStyleNameTest undo error", tf.styleName == origStyleName);
			
			// test using the replacement class
			SelManager.doOperation(new ApplyFormatToElementOperation(SelManager.getSelectionState(),tf,TextLayoutFormat.createTextLayoutFormat({styleName:newStyleName})));
			assertTrue("changeTextFlowStyleNameTest doOperation error", tf.styleName == newStyleName);
			SelManager.undo();
			assertTrue("changeTextFlowStyleNameTest undo error", tf.styleName == origStyleName);
			SelManager.redo();
			assertTrue("changeTextFlowStyleNameTest redo error", tf.styleName == newStyleName);

		}

		/**
		 */
		public function changeFirstParagraphStyleNameTest():void
		{
			var p:ParagraphElement = SelManager.textFlow.getChildAt(0) as ParagraphElement;
			var origStyleName:String = p.styleName;
			var newStyleName:String = "newParaStyleName";

			// ApplyElementStyleNameOperation is deprecated
			SelManager.doOperation(new ApplyElementStyleNameOperation(SelManager.getSelectionState(),p,newStyleName));
			assertTrue("changeFirstParagraphStyleNameTest doOperation error", p.styleName == newStyleName);
			SelManager.undo();
			assertTrue("changeFirstParagraphStyleNameTest undo error", p.styleName == origStyleName);
			SelManager.redo();
			assertTrue("changeFirstParagraphStyleNameTest redo error", p.styleName == newStyleName);
			
			SelManager.undo();
			assertTrue("changeFirstParagraphStyleNameTest undo error", p.styleName == origStyleName);

			// test using the replacement class
			SelManager.doOperation(new ApplyFormatToElementOperation(SelManager.getSelectionState(),p,TextLayoutFormat.createTextLayoutFormat({styleName:newStyleName})));
			assertTrue("changeFirstParagraphStyleNameTest doOperation error", p.styleName == newStyleName);
			SelManager.undo();
			assertTrue("changeFirstParagraphStyleNameTest undo error", p.styleName == origStyleName);
			SelManager.redo();
			assertTrue("changeFirstParagraphStyleNameTest redo error", p.styleName == newStyleName);
			
		}
		
		/**
		 */
		public function changeTextFlowTypeNameTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var origTypeName:String = tf.typeName;
			var newTypeName:String = "newTFTypeName";
			
			SelManager.doOperation(new ApplyElementTypeNameOperation(SelManager.getSelectionState(),tf,newTypeName));
			assertTrue("changeTextFlowTypeNameTest doOperation error", tf.typeName == newTypeName);
			SelManager.undo();
			assertTrue("changeTextFlowTypeNameTest undo error", tf.typeName == origTypeName);
			SelManager.redo();
			assertTrue("changeTextFlowTypeNameTest redo error", tf.typeName == newTypeName);
		}
		
		/**
		 */
		public function changeFirstParagraphTypeNameTest():void
		{
			var p:ParagraphElement = SelManager.textFlow.getChildAt(0) as ParagraphElement;
			var origTypeName:String = p.typeName;
			var newTypeName:String = "newParaTypeName";
			
			SelManager.doOperation(new ApplyElementTypeNameOperation(SelManager.getSelectionState(),p,newTypeName));
			assertTrue("changeFirstParagraphTypeNameTest doOperation error", p.typeName == newTypeName);
			SelManager.undo();
			assertTrue("changeFirstParagraphTypeNameTest undo error", p.typeName == origTypeName);
			SelManager.redo();
			assertTrue("changeFirstParagraphTypeNameTest redo error", p.typeName == newTypeName);
		}

		/**
		 */
		public function changePartialParagraphStyleNameTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var numParas:int = tf.numChildren;
			var totalLength:int = tf.textLength;

			var p:ParagraphElement = tf.getChildAt(0) as ParagraphElement;
			var origStyleName:String = p.styleName;
			var origTextLength:int = p.textLength;
			var newStyleName:String = "newParaStyleName";

			// ApplyElementStyleNameOperation is deprecated
			// creates two new paragraphs
			SelManager.doOperation(new ApplyElementStyleNameOperation(SelManager.getSelectionState(),p,newStyleName,10,20));
			p = tf.findLeaf(11).getParagraph();	// prev para gets a terminator added
			assertTrue("changePartialParagraphStyleNameTest doOperation error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphStyleNameTest doOperation error", p.styleName == newStyleName);
			assertTrue("changePartialParagraphStyleNameTest doOperation error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphStyleNameTest doOperation error totalLength", tf.textLength == totalLength+2);

			SelManager.undo();
			p = tf.findLeaf(10).getParagraph();
			assertTrue("changePartialParagraphStyleNameTest undo error", p.styleName == origStyleName && p.textLength == origTextLength);
			assertTrue("changePartialParagraphStyleNameTest undo error numParas", tf.numChildren == numParas);
			assertTrue("changePartialParagraphStyleNameTest undo error totalLength", tf.textLength == totalLength);

			SelManager.redo();
			p = tf.findLeaf(11).getParagraph();
			assertTrue("changePartialParagraphStyleNameTest redo error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphStyleNameTest redo error", p.styleName == newStyleName);
			assertTrue("changePartialParagraphStyleNameTest redo error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphStyleNameTest redo error totalLength", tf.textLength == totalLength+2);

			// cleanup
			SelManager.undo();
			p = tf.findLeaf(10).getParagraph();
			assertTrue("changePartialParagraphStyleNameTest undo error", p.styleName == origStyleName && p.textLength == origTextLength);
			assertTrue("changePartialParagraphStyleNameTest undo error numParas", tf.numChildren == numParas);
			assertTrue("changePartialParagraphStyleNameTest undo error totalLength", tf.textLength == totalLength);

			// test using the replacement class
			// creates two new paragraphs
			SelManager.doOperation(new ApplyFormatToElementOperation(SelManager.getSelectionState(),p,TextLayoutFormat.createTextLayoutFormat({styleName:newStyleName}),10,20));
			p = tf.findLeaf(11).getParagraph();	// prev para gets a terminator added
			assertTrue("changePartialParagraphStyleNameTest doOperation error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphStyleNameTest doOperation error", p.styleName == newStyleName);
			assertTrue("changePartialParagraphStyleNameTest doOperation error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphStyleNameTest doOperation error totalLength", tf.textLength == totalLength+2);
			
			SelManager.undo();
			p = tf.findLeaf(10).getParagraph();
			assertTrue("changePartialParagraphStyleNameTest undo error", p.styleName == origStyleName && p.textLength == origTextLength);
			assertTrue("changePartialParagraphStyleNameTest undo error numParas", tf.numChildren == numParas);
			assertTrue("changePartialParagraphStyleNameTest undo error totalLength", tf.textLength == totalLength);
			
			SelManager.redo();
			p = tf.findLeaf(11).getParagraph();
			assertTrue("changePartialParagraphStyleNameTest redo error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphStyleNameTest redo error", p.styleName == newStyleName);
			assertTrue("changePartialParagraphStyleNameTest redo error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphStyleNameTest redo error totalLength", tf.textLength == totalLength+2);

		}

		/**
		 */
		public function changePartialSpanStyleNameTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var numParas:int = tf.numChildren;
			var totalLength:int = tf.textLength;

			var span:SpanElement = tf.getLastLeaf() as SpanElement;
			assertTrue("changePartialSpanStyleNameTest span is too short for the test",span.textLength > 20);
			var spanStart:int = span.getAbsoluteStart();

			var origStyleName:String = span.styleName;
			var origSpanLength:int = span.textLength;
			var newStyleName:String = "newSpanStyleName";

			// ApplyElementStyleNameOperation is deprecated
			// splits the span
			SelManager.doOperation(new ApplyElementStyleNameOperation(SelManager.getSelectionState(),span,newStyleName,10,20));

			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanStyleNameTest doOperation error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanStyleNameTest doOperation error id", span.styleName == newStyleName);
			assertTrue("changePartialSpanStyleNameTest doOperation error totalLength", tf.textLength == totalLength);

			SelManager.undo();
			span = tf.findLeaf(spanStart) as SpanElement;
			assertTrue("changePartialSpanStyleNameTest undo error", span.styleName == origStyleName && span.textLength == origSpanLength);
			assertTrue("changePartialSpanStyleNameTest undo error totalLength", tf.textLength == totalLength);

			SelManager.redo();
			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanStyleNameTest redo error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanStyleNameTest redo error", span.styleName == newStyleName);
			assertTrue("changePartialSpanStyleNameTest redo error totalLength", tf.textLength == totalLength);
			
			// cleanup
			SelManager.undo();
			span = tf.findLeaf(spanStart) as SpanElement;
			assertTrue("changePartialSpanStyleNameTest undo error", span.styleName == origStyleName && span.textLength == origSpanLength);
			assertTrue("changePartialSpanStyleNameTest undo error totalLength", tf.textLength == totalLength);

			// test using the replacement function
			
			// splits the span
			SelManager.doOperation(new ApplyFormatToElementOperation(SelManager.getSelectionState(),span,TextLayoutFormat.createTextLayoutFormat({styleName:newStyleName}),10,20));
			
			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanStyleNameTest doOperation error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanStyleNameTest doOperation error id", span.styleName == newStyleName);
			assertTrue("changePartialSpanStyleNameTest doOperation error totalLength", tf.textLength == totalLength);
			
			SelManager.undo();
			span = tf.findLeaf(spanStart) as SpanElement;
			assertTrue("changePartialSpanStyleNameTest undo error", span.styleName == origStyleName && span.textLength == origSpanLength);
			assertTrue("changePartialSpanStyleNameTest undo error totalLength", tf.textLength == totalLength);
			
			SelManager.redo();
			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanStyleNameTest redo error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanStyleNameTest redo error", span.styleName == newStyleName);
			assertTrue("changePartialSpanStyleNameTest redo error totalLength", tf.textLength == totalLength);
		}

		/**
		 */
		public function changePartialParagraphTypeNameTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var numParas:int = tf.numChildren;
			var totalLength:int = tf.textLength;
			
			var p:ParagraphElement = tf.getChildAt(0) as ParagraphElement;
			var origTypeName:String = p.typeName;
			var origTextLength:int = p.textLength;
			var newTypeName:String = "newParaTypeName";
			
			// creates two new paragraphs
			SelManager.doOperation(new ApplyElementTypeNameOperation(SelManager.getSelectionState(),p,newTypeName,10,20));
			p = tf.findLeaf(11).getParagraph();	// prev para gets a terminator added
			assertTrue("changePartialParagraphTypeNameTest doOperation error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphTypeNameTest doOperation error", p.typeName == newTypeName);
			assertTrue("changePartialParagraphTypeNameTest doOperation error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphTypeNameTest doOperation error totalLength", tf.textLength == totalLength+2);
			
			SelManager.undo();
			p = tf.findLeaf(10).getParagraph();
			assertTrue("changePartialParagraphTypeNameTest undo error", p.typeName == origTypeName && p.textLength == origTextLength);
			assertTrue("changePartialParagraphTypeNameTest undo error numParas", tf.numChildren == numParas);
			assertTrue("changePartialParagraphTypeNameTest undo error totalLength", tf.textLength == totalLength);
			
			SelManager.redo();
			p = tf.findLeaf(11).getParagraph();
			assertTrue("changePartialParagraphTypeNameTest redo error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphTypeNameTest redo error", p.typeName == newTypeName);
			assertTrue("changePartialParagraphTypeNameTest redo error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphTypeNameTest redo error totalLength", tf.textLength == totalLength+2);
		}
		
		/**
		 */
		public function changePartialSpanTypeNameTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var numParas:int = tf.numChildren;
			var totalLength:int = tf.textLength;
			
			var span:SpanElement = tf.getLastLeaf() as SpanElement;
			assertTrue("changePartialSpanTypeNameTest span is too short for the test",span.textLength > 20);
			var spanStart:int = span.getAbsoluteStart();
			
			var origTypeName:String = span.typeName;
			var origSpanLength:int = span.textLength;
			var newTypeName:String = "newSpanTypeName";
			
			// splits the span
			SelManager.doOperation(new ApplyElementTypeNameOperation(SelManager.getSelectionState(),span,newTypeName,10,20));
			
			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanTypeNameTest doOperation error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanTypeNameTest doOperation error id", span.typeName == newTypeName);
			assertTrue("changePartialSpanTypeNameTest doOperation error totalLength", tf.textLength == totalLength);
			
			SelManager.undo();
			span = tf.findLeaf(spanStart) as SpanElement;
			assertTrue("changePartialSpanTypeNameTest undo error", span.typeName == origTypeName && span.textLength == origSpanLength);
			assertTrue("changePartialSpanTypeNameTest undo error totalLength", tf.textLength == totalLength);
			
			SelManager.redo();
			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanTypeNameTest redo error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanTypeNameTest redo error", span.typeName == newTypeName);
			assertTrue("changePartialSpanTypeNameTest redo error totalLength", tf.textLength == totalLength);
		}
		
		/**
		 */
		public function changeTextFlowUserStyleTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var styleName:String = "userStyleName";
			var origStyleValue:* = tf.getStyle(styleName);
			var newStyleValue:String = "newTFStyleValue";

			// ApplyElementUserStyleOperation is deprecated
			SelManager.doOperation(new ApplyElementUserStyleOperation(SelManager.getSelectionState(),tf,styleName,newStyleValue));
			assertTrue("changeTextFlowUserStyleTest doOperation error", tf.getStyle(styleName) === newStyleValue);
			SelManager.undo();
			assertTrue("changeTextFlowUserStyleTest undo error", tf.getStyle(styleName) === origStyleValue);
			SelManager.redo();
			assertTrue("changeTextFlowUserStyleTest redo error", tf.getStyle(styleName) === newStyleValue);
			
			// cleanup
			SelManager.undo();
			assertTrue("changeTextFlowUserStyleTest undo error", tf.getStyle(styleName) === origStyleValue);

			// test using the replacement class
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.setStyle(styleName,newStyleValue);
			SelManager.doOperation(new ApplyFormatToElementOperation(SelManager.getSelectionState(),tf,format));
			assertTrue("changeTextFlowUserStyleTest doOperation error", tf.getStyle(styleName) === newStyleValue);
			SelManager.undo();
			assertTrue("changeTextFlowUserStyleTest undo error", tf.getStyle(styleName) === origStyleValue);
			SelManager.redo();
			assertTrue("changeTextFlowUserStyleTest redo error", tf.getStyle(styleName) === newStyleValue);
		}

		/**
		 */
		public function changeFirstParagraphUserStyleTest():void
		{
			var p:ParagraphElement = SelManager.textFlow.getChildAt(0) as ParagraphElement;
			var styleName:String = "userStyleName";
			var origStyleValue:* = p.getStyle(styleName);
			var newStyleValue:String = "newParaStyleValue";

			// ApplyElementUserStyleOperation is deprecated
			SelManager.doOperation(new ApplyElementUserStyleOperation(SelManager.getSelectionState(),p,styleName,newStyleValue));
			assertTrue("changeFirstParagraphUserStyleTest doOperation error", p.getStyle(styleName) === newStyleValue);
			SelManager.undo();
			assertTrue("changeFirstParagraphUserStyleTest undo error", p.getStyle(styleName) === origStyleValue);
			SelManager.redo();
			assertTrue("changeFirstParagraphUserStyleTest redo error", p.getStyle(styleName) === newStyleValue);
			
			// cleanup
			SelManager.undo();
			assertTrue("changeFirstParagraphUserStyleTest undo error", p.getStyle(styleName) === origStyleValue);
			
			// test using the replacement class
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.setStyle(styleName,newStyleValue);
			SelManager.doOperation(new ApplyFormatToElementOperation(SelManager.getSelectionState(),p,format));
			assertTrue("changeFirstParagraphUserStyleTest doOperation error", p.getStyle(styleName) === newStyleValue);
			SelManager.undo();
			assertTrue("changeFirstParagraphUserStyleTest undo error", p.getStyle(styleName) === origStyleValue);
			SelManager.redo();
			assertTrue("changeFirstParagraphUserStyleTest redo error", p.getStyle(styleName) === newStyleValue);			
		}
		/**
		 */
		public function changePartialParagraphUserStyleTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var numParas:int = tf.numChildren;
			var totalLength:int = tf.textLength;

			var p:ParagraphElement = tf.getChildAt(0) as ParagraphElement;
			var origTextLength:int = p.textLength;

			var styleName:String = "userStyleName";
			var origStyleValue:* = p.getStyle(styleName);
			var newStyleValue:String = "newParaStyleValue";

			// ApplyElementUserStyleOperation is deprecated
			// creates two new paragraphs
			SelManager.doOperation(new ApplyElementUserStyleOperation(SelManager.getSelectionState(),p,styleName,newStyleValue,10,20));
			p = tf.findLeaf(11).getParagraph();	// prev para gets a terminator added
			assertTrue("changePartialParagraphUserStyleTest doOperation error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphUserStyleTest doOperation error", p.getStyle(styleName) === newStyleValue);
			assertTrue("changePartialParagraphUserStyleTest doOperation error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphUserStyleTest doOperation error totalLength", tf.textLength == totalLength+2);

			SelManager.undo();
			p = tf.findLeaf(10).getParagraph();
			assertTrue("changePartialParagraphUserStyleTest undo error", p.getStyle(styleName) === origStyleValue && p.textLength == origTextLength);
			assertTrue("changePartialParagraphUserStyleTest undo error numParas", tf.numChildren == numParas);
			assertTrue("changePartialParagraphUserStyleTest undo error totalLength", tf.textLength == totalLength);

			SelManager.redo();
			p = tf.findLeaf(11).getParagraph();
			assertTrue("changePartialParagraphStyleNameTest redo error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphStyleNameTest redo error", p.getStyle(styleName) === newStyleValue);
			assertTrue("changePartialParagraphStyleNameTest redo error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphStyleNameTest redo error totalLength", tf.textLength == totalLength+2);
			
			// cleanup
			SelManager.undo();
			p = tf.findLeaf(10).getParagraph();
			assertTrue("changePartialParagraphUserStyleTest undo error", p.getStyle(styleName) === origStyleValue && p.textLength == origTextLength);
			assertTrue("changePartialParagraphUserStyleTest undo error numParas", tf.numChildren == numParas);
			assertTrue("changePartialParagraphUserStyleTest undo error totalLength", tf.textLength == totalLength);

			// test using the replacement class
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.setStyle(styleName,newStyleValue);
			SelManager.doOperation(new ApplyFormatToElementOperation(SelManager.getSelectionState(),p,format,10,20));
			p = tf.findLeaf(11).getParagraph();	// prev para gets a terminator added
			assertTrue("changePartialParagraphUserStyleTest doOperation error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphUserStyleTest doOperation error", p.getStyle(styleName) === newStyleValue);
			assertTrue("changePartialParagraphUserStyleTest doOperation error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphUserStyleTest doOperation error totalLength", tf.textLength == totalLength+2);
			
			SelManager.undo();
			p = tf.findLeaf(10).getParagraph();
			assertTrue("changePartialParagraphUserStyleTest undo error", p.getStyle(styleName) === origStyleValue && p.textLength == origTextLength);
			assertTrue("changePartialParagraphUserStyleTest undo error numParas", tf.numChildren == numParas);
			assertTrue("changePartialParagraphUserStyleTest undo error totalLength", tf.textLength == totalLength);
			
			SelManager.redo();
			p = tf.findLeaf(11).getParagraph();
			assertTrue("changePartialParagraphStyleNameTest redo error p wrong size", p.textLength == 11 && p.parentRelativeStart == 11);
			assertTrue("changePartialParagraphStyleNameTest redo error", p.getStyle(styleName) === newStyleValue);
			assertTrue("changePartialParagraphStyleNameTest redo error numParas", tf.numChildren == numParas+2);
			assertTrue("changePartialParagraphStyleNameTest redo error totalLength", tf.textLength == totalLength+2);
			
		}

		/**
		 */
		public function changePartialSpanUserStyleTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var numParas:int = tf.numChildren;
			var totalLength:int = tf.textLength;

			var span:SpanElement = tf.getLastLeaf() as SpanElement;
			assertTrue("changePartialSpanStyleNameTest span is too short for the test",span.textLength > 20);
			var spanStart:int = span.getAbsoluteStart();
			var origSpanLength:int = span.textLength;

			var styleName:String = "userStyleName";
			var origStyleValue:* = span.getStyle(styleName);
			var newStyleValue:String = "newSpanStyleValue";

			// ApplyElementUserStyleOperation is deprecated
			// splits the span
			SelManager.doOperation(new ApplyElementUserStyleOperation(SelManager.getSelectionState(),span,styleName,newStyleValue,10,20));

			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanUserStyleTest doOperation error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanUserStyleTest doOperation error", span.getStyle(styleName) === newStyleValue);
			assertTrue("changePartialSpanUserStyleTest doOperation error totalLength", tf.textLength == totalLength);

			SelManager.undo();
			span = tf.findLeaf(spanStart) as SpanElement;
			assertTrue("changePartialSpanUserStyleTest undo error", span.getStyle(styleName) === origStyleValue && span.textLength == origSpanLength);
			assertTrue("changePartialSpanUserStyleTest undo error totalLength", tf.textLength == totalLength);

			SelManager.redo();
			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanUserStyleTest redo error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanUserStyleTest redo error", span.getStyle(styleName) === newStyleValue);
			assertTrue("changePartialSpanUserStyleTest redo error totalLength", tf.textLength == totalLength);
			
			// cleanup
			SelManager.undo();
			span = tf.findLeaf(spanStart) as SpanElement;
			assertTrue("changePartialSpanUserStyleTest undo error", span.getStyle(styleName) === origStyleValue && span.textLength == origSpanLength);
			assertTrue("changePartialSpanUserStyleTest undo error totalLength", tf.textLength == totalLength);

			// splits the span
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.setStyle(styleName,newStyleValue);
			SelManager.doOperation(new ApplyFormatToElementOperation(SelManager.getSelectionState(),span,format,10,20));
			
			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanUserStyleTest doOperation error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanUserStyleTest doOperation error", span.getStyle(styleName) === newStyleValue);
			assertTrue("changePartialSpanUserStyleTest doOperation error totalLength", tf.textLength == totalLength);
			
			SelManager.undo();
			span = tf.findLeaf(spanStart) as SpanElement;
			assertTrue("changePartialSpanUserStyleTest undo error", span.getStyle(styleName) === origStyleValue && span.textLength == origSpanLength);
			assertTrue("changePartialSpanUserStyleTest undo error totalLength", tf.textLength == totalLength);
			
			SelManager.redo();
			span = tf.findLeaf(spanStart+10) as SpanElement;
			assertTrue("changePartialSpanUserStyleTest redo error span wrong size", span.textLength == 10 && span.parentRelativeStart == 10);
			assertTrue("changePartialSpanUserStyleTest redo error", span.getStyle(styleName) === newStyleValue);
			assertTrue("changePartialSpanUserStyleTest redo error totalLength", tf.textLength == totalLength);			
		}
		
		private static const divTestMarkup:String = "<TextFlow whiteSpaceCollapse='preserve' xmlns='http://ns.adobe.com/textLayout/2008'><div><p><span>asd</span></p></div><p><span>asd</span></p></TextFlow>";

		/**
		 */
		public function deleteAcrossDivBoundaryTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var selectFlow:TextFlow = TextConverter.importToFlow(divTestMarkup,TextConverter.TEXT_LAYOUT_FORMAT);
			
			var div:DivElement = selectFlow.getChildAt(0) as DivElement;
			var para:ParagraphElement = selectFlow.getChildAt(1) as ParagraphElement;
			
			// setup
			tf.replaceChildren(0,tf.numChildren, div.deepCopy());
			tf.replaceChildren(1,tf.numChildren, para.deepCopy());
			tf.flowComposer.updateAllControllers();
			
			var lenBefore:int = tf.textLength;

			SelManager.selectRange(3,4);
			EditManager(SelManager).deleteText();
			
			assertTrue("length didn't change after delete across div boundary!", tf.textLength != lenBefore);
			
		}

		/**
		 */
		//Test for bug#2948473, we will not copy the containerBreakAfter, containerBreakBefore
		//columnBreakAfter, columnBreakBefore attribute to the new paragraph
		public function BreaksSplitTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			
			// a simple styled paragraph - always copy
			var p:ParagraphElement = new ParagraphElement();
			p.textAlign = TextAlign.LEFT;
			p.columnBreakAfter = 'always';
			p.columnBreakBefore = 'always';
			p.containerBreakAfter = 'always';
			p.containerBreakBefore = 'always';
			var s:SpanElement = new SpanElement();
			s.fontWeight = FontWeight.BOLD;
			s.text = "Hello";
			p.addChild(s);
			
			// scratch objects
			var p1:ParagraphElement;
			var p2:ParagraphElement;
			var s1:SpanElement;
			var s2:SpanElement;
			
			
			// BEGIN SPLIT AT BEGINNING TEST
			
			// setup
			tf.replaceChildren(0,tf.numChildren,p.deepCopy(0,p.textLength));
			tf.flowComposer.updateAllControllers();
			
			// split at beginning
			SelManager.selectRange(0,0);
			EditManager(SelManager).splitParagraph();
			
			assertTrue("BreaksSplitTest 1: incorrect number of children after split",tf.numChildren == 2);
			p1 = tf.getChildAt(0) as ParagraphElement;
			p2 = tf.getChildAt(1) as ParagraphElement;
			
			assertTrue("BreaksSplitTest 1: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("BreaksSplitTest 1: p2 is incorrect after split",p2 && !TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1 && 
				p2.columnBreakAfter == undefined &&
				p2.columnBreakBefore == undefined &&
				p2.containerBreakAfter == undefined &&
				p2.containerBreakBefore == undefined);
			
			s1 = p1.getChildAt(0) as SpanElement;
			s2 = p2.getChildAt(0) as SpanElement;
			
			assertTrue("BreaksSplitTest 1: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("BreaksSplitTest 1: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT AT BEGINNING TEST
			
			// BEGIN SPLIT AT END TEST
			
			// setup
			tf.replaceChildren(0,tf.numChildren,p.deepCopy(0,p.textLength));
			tf.flowComposer.updateAllControllers();			
			
			// split at end
			SelManager.selectRange(tf.textLength-1,tf.textLength-1);
			EditManager(SelManager).splitParagraph();
			
			assertTrue("BreaksSplitTest 2: incorrect number of children after split",tf.numChildren == 2);
			p1 = tf.getChildAt(0) as ParagraphElement;
			p2 = tf.getChildAt(1) as ParagraphElement;
			
			assertTrue("BreaksSplitTest 2: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("BreaksSplitTest 2: p2 is incorrect after split",p2 && !TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1 &&
				p2.columnBreakAfter == undefined &&
				p2.columnBreakBefore == undefined &&
				p2.containerBreakAfter == undefined &&
				p2.containerBreakBefore == undefined);
			
			s1 = p1.getChildAt(0) as SpanElement;
			s2 = p2.getChildAt(0) as SpanElement;
			
			assertTrue("BreaksSplitTest 2: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("BreaksSplitTest 2: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT AT END TEST
			
			// BEGIN SPLIT IN MIDDLE TEST
			
			// setup
			tf.replaceChildren(0,tf.numChildren,p.deepCopy(0,p.textLength));
			tf.flowComposer.updateAllControllers();			
			
			// split at middle
			SelManager.selectRange(2,2);
			EditManager(SelManager).splitParagraph();
			
			assertTrue("BreaksSplitTest 3: incorrect number of children after split",tf.numChildren == 2);
			p1 = tf.getChildAt(0) as ParagraphElement;
			p2 = tf.getChildAt(1) as ParagraphElement;
			
			assertTrue("BreaksSplitTest 3: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("BreaksSplitTest 3: p2 is incorrect after split",p2 && !TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1 &&
				p2.columnBreakAfter == undefined &&
				p2.columnBreakBefore == undefined &&
				p2.containerBreakAfter == undefined &&
				p2.containerBreakBefore == undefined);
			
			s1 = p1.getChildAt(0) as SpanElement;
			s2 = p2.getChildAt(0) as SpanElement;
			
			assertTrue("BreaksSplitTest 3: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("BreaksSplitTest 3: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT IN MIDDLE TEST
		}
		/**
		 */
		public function splitStyledParagraphTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			
			// a simple styled paragraph - always copy
			var p:ParagraphElement = new ParagraphElement();
			p.textAlign = TextAlign.LEFT;
			var s:SpanElement = new SpanElement();
			s.fontWeight = FontWeight.BOLD;
			s.text = "Hello";
			p.addChild(s);
			
			// scratch objects
			var p1:ParagraphElement;
			var p2:ParagraphElement;
			var s1:SpanElement;
			var s2:SpanElement;
			
			
			// BEGIN SPLIT AT BEGINNING TEST
			
			// setup
			tf.replaceChildren(0,tf.numChildren,p.deepCopy(0,p.textLength));
			tf.flowComposer.updateAllControllers();
			
			// split at beginning
			SelManager.selectRange(0,0);
			EditManager(SelManager).splitParagraph();
			
			assertTrue("splitStyledParagraphTest 1: incorrect number of children after split",tf.numChildren == 2);
			p1 = tf.getChildAt(0) as ParagraphElement;
			p2 = tf.getChildAt(1) as ParagraphElement;
			
			assertTrue("splitStyledParagraphTest 1: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("splitStyledParagraphTest 1: p2 is incorrect after split",p2 && TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1);
			
			s1 = p1.getChildAt(0) as SpanElement;
			s2 = p2.getChildAt(0) as SpanElement;
			
			assertTrue("splitStyledParagraphTest 1: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("splitStyledParagraphTest 1: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT AT BEGINNING TEST
			
			// BEGIN SPLIT AT END TEST
			
			// setup
			tf.replaceChildren(0,tf.numChildren,p.deepCopy(0,p.textLength));
			tf.flowComposer.updateAllControllers();			

			// split at end
			SelManager.selectRange(tf.textLength-1,tf.textLength-1);
			EditManager(SelManager).splitParagraph();

			assertTrue("splitStyledParagraphTest 2: incorrect number of children after split",tf.numChildren == 2);
			p1 = tf.getChildAt(0) as ParagraphElement;
			p2 = tf.getChildAt(1) as ParagraphElement;
			
			assertTrue("splitStyledParagraphTest 2: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("splitStyledParagraphTest 2: p2 is incorrect after split",p2 && TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1);
			
			s1 = p1.getChildAt(0) as SpanElement;
			s2 = p2.getChildAt(0) as SpanElement;
			
			assertTrue("splitStyledParagraphTest 2: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("splitStyledParagraphTest 2: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT AT END TEST
			
			// BEGIN SPLIT IN MIDDLE TEST
			
			// setup
			tf.replaceChildren(0,tf.numChildren,p.deepCopy(0,p.textLength));
			tf.flowComposer.updateAllControllers();			
			
			// split at middle
			SelManager.selectRange(2,2);
			EditManager(SelManager).splitParagraph();
			
			assertTrue("splitStyledParagraphTest 3: incorrect number of children after split",tf.numChildren == 2);
			p1 = tf.getChildAt(0) as ParagraphElement;
			p2 = tf.getChildAt(1) as ParagraphElement;
			
			assertTrue("splitStyledParagraphTest 3: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("splitStyledParagraphTest 3: p2 is incorrect after split",p2 && TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1);
			
			s1 = p1.getChildAt(0) as SpanElement;
			s2 = p2.getChildAt(0) as SpanElement;
			
			assertTrue("splitStyledParagraphTest 3: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("splitStyledParagraphTest 3: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT IN MIDDLE TEST
		}
		
		/**
		 */
		public function splitStyledAnchorTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			
			// a simple styled paragraph - always copy
			var p:ParagraphElement = new ParagraphElement();
			p.textAlign = TextAlign.LEFT;
			var s:SpanElement = new SpanElement();
			s.fontWeight = FontWeight.BOLD;
			s.text = "Hello";
			var a:LinkElement = new LinkElement();
			a.fontSize = 18;
			a.addChild(s);
			p.addChild(a);
			
			// scratch objects
			var p1:ParagraphElement;
			var p2:ParagraphElement;
			var s1:SpanElement;
			var s2:SpanElement;
			
			
			// BEGIN SPLIT AT BEGINNING TEST
			
			// setup
			tf.replaceChildren(0,tf.numChildren,p.deepCopy(0,p.textLength));
			tf.flowComposer.updateAllControllers();
			
			// split at beginning
			SelManager.selectRange(0,0);
			EditManager(SelManager).splitParagraph();
			
			assertTrue("splitStyledParagraphTest 1: incorrect number of children after split",tf.numChildren == 2);
			p1 = tf.getChildAt(0) as ParagraphElement;
			p2 = tf.getChildAt(1) as ParagraphElement;
			
			assertTrue("splitStyledParagraphTest 1: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("splitStyledParagraphTest 1: p2 is incorrect after split",p2 && TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1);
			
			s1 = p1.getChildAt(0) as SpanElement;
			s2 = (p2.getChildAt(0) as FlowGroupElement).getChildAt(0) as SpanElement;
			
			assertTrue("splitStyledParagraphTest 1: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("splitStyledParagraphTest 1: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT AT BEGINNING TEST
			
			// BEGIN SPLIT AT END TEST
			
			// setup
			tf.replaceChildren(0,tf.numChildren,p.deepCopy(0,p.textLength));
			tf.flowComposer.updateAllControllers();			
			
			// split at end
			SelManager.selectRange(tf.textLength-1,tf.textLength-1);
			EditManager(SelManager).splitParagraph();
			
			assertTrue("splitStyledParagraphTest 2: incorrect number of children after split",tf.numChildren == 2);
			p1 = tf.getChildAt(0) as ParagraphElement;
			p2 = tf.getChildAt(1) as ParagraphElement;
			
			assertTrue("splitStyledParagraphTest 2: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("splitStyledParagraphTest 2: p2 is incorrect after split",p2 && TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1);
			
			s1 = (p1.getChildAt(0) as FlowGroupElement).getChildAt(0) as SpanElement;
			s2 = p2.getChildAt(0) as SpanElement;
			
			assertTrue("splitStyledParagraphTest 2: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("splitStyledParagraphTest 2: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT AT END TEST
			
			// BEGIN SPLIT IN MIDDLE TEST
			
			// setup
			tf.replaceChildren(0,tf.numChildren,p.deepCopy(0,p.textLength));
			tf.flowComposer.updateAllControllers();			
			
			// split at middle
			SelManager.selectRange(2,2);
			EditManager(SelManager).splitParagraph();
			
			assertTrue("splitStyledParagraphTest 3: incorrect number of children after split",tf.numChildren == 2);
			p1 = tf.getChildAt(0) as ParagraphElement;
			p2 = tf.getChildAt(1) as ParagraphElement;
			
			assertTrue("splitStyledParagraphTest 3: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("splitStyledParagraphTest 3: p2 is incorrect after split",p2 && TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1);
			
			s1 = (p1.getChildAt(0) as FlowGroupElement).getChildAt(0) as SpanElement;
			s2 = (p2.getChildAt(0) as FlowGroupElement).getChildAt(0) as SpanElement;

			assertTrue("splitStyledParagraphTest 3: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("splitStyledParagraphTest 3: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT IN MIDDLE TEST
		}
		
		private static const listItemMarkup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><list listStylePosition='inside'><li><p textAlign='left'><span fontWeight='bold'>item</span></p></li></list></TextFlow>";
		/**
		 */
		public function splitStyledListItemTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			
			var listFlow:TextFlow = TextConverter.importToFlow(listItemMarkup,TextConverter.TEXT_LAYOUT_FORMAT);
			var list:ListElement = listFlow.getChildAt(0) as ListElement;
			
			var s:SpanElement = list.getFirstLeaf() as SpanElement;
			var p:ParagraphElement = s.parent as ParagraphElement;
			
			// scratch objects
			var p1:ParagraphElement;
			var p2:ParagraphElement;
			var s1:SpanElement;
			var s2:SpanElement;
			var listCopy:ListElement;
			
			
			// BEGIN SPLIT AT BEGINNING TEST
			
			// setup
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			
			// split at beginning
			SelManager.selectRange(0,0);
			EditManager(SelManager).splitElement(listCopy.getChildAt(0) as FlowGroupElement);
			
			assertTrue("splitStyledListItemTest 1: incorrect number of children after split",listCopy.numChildren == 2);
			p1 = (listCopy.getChildAt(0) as FlowGroupElement).getChildAt(0) as ParagraphElement;
			p2 = (listCopy.getChildAt(1) as FlowGroupElement).getChildAt(0) as ParagraphElement;
			
			assertTrue("splitStyledListItemTest 1: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("splitStyledListItemTest 1: p2 is incorrect after split",p2 && TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1);
			
			s1 = p1.getChildAt(0) as SpanElement;
			s2 = p2.getChildAt(0) as SpanElement;
			
			assertTrue("splitStyledListItemTest 1: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("splitStyledListItemTest 1: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT AT BEGINNING TEST
			
			// BEGIN SPLIT AT END TEST
			
			// setup
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();	
			
			
			// split at end
			SelManager.selectRange(tf.textLength-1,tf.textLength-1);
			EditManager(SelManager).splitElement(listCopy.getChildAt(0) as FlowGroupElement);
			
			assertTrue("splitStyledListItemTest 2: incorrect number of children after split",listCopy.numChildren == 2);
			p1 = (listCopy.getChildAt(0) as FlowGroupElement).getChildAt(0) as ParagraphElement;
			p2 = (listCopy.getChildAt(1) as FlowGroupElement).getChildAt(0) as ParagraphElement;
			
			assertTrue("splitStyledListItemTest 2: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("splitStyledListItemTest 2: p2 is incorrect after split",p2 && TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1);
			
			s1 = p1.getChildAt(0) as SpanElement;
			s2 = p2.getChildAt(0) as SpanElement;
			
			assertTrue("splitStyledListItemTest 2: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("splitStyledListItemTest 2: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT AT END TEST
			
			// BEGIN SPLIT IN MIDDLE TEST
			
			// setup
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();			
			
			// split at middle
			SelManager.selectRange(2,2);
			EditManager(SelManager).splitElement(listCopy.getChildAt(0) as FlowGroupElement);
			
			assertTrue("splitStyledListItemTest 3: incorrect number of children after split",listCopy.numChildren == 2);
			p1 = (listCopy.getChildAt(0) as FlowGroupElement).getChildAt(0) as ParagraphElement;
			p2 = (listCopy.getChildAt(1) as FlowGroupElement).getChildAt(0) as ParagraphElement;
			
			assertTrue("splitStyledListItemTest 3: p1 is incorrect after split",p1 && TextLayoutFormat.isEqual(p.format,p1.format) && p1.numChildren == 1);
			assertTrue("splitStyledListItemTest 3: p2 is incorrect after split",p2 && TextLayoutFormat.isEqual(p.format,p2.format) && p2.numChildren == 1);
			
			s1 = p1.getChildAt(0) as SpanElement;
			s2 = p2.getChildAt(0) as SpanElement;
			
			assertTrue("splitStyledListItemTest 3: s1 is incorrect after split",s1 && TextLayoutFormat.isEqual(s.format,s1.format));
			assertTrue("splitStyledListItemTest 3: s2 is incorrect after split",s2 && TextLayoutFormat.isEqual(s.format,s2.format));
			
			// END SPLIT IN MIDDLE TEST
		}
		
		public function spanElementReplaceTextInvalidPos():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			
			var paragraph:ParagraphElement = new ParagraphElement();
			var span:SpanElement = new SpanElement;
			
			span.text = "Does this text flow need to be composed?";
			paragraph.addChild(span);
			SelManager.textFlow.addChild(paragraph);         	
			SelManager.textFlow.flowComposer.updateAllControllers();
			span.replaceText(5, 9, "your");
			if(SelManager.textFlow.flowComposer.getControllerAt(0).isDamaged())
			{
				span.text += " Yes it does.";
			}
		
			//try to replace text at start point <0, should return error
			try
			{
				span.replaceText(-1, 2, "your");
			} catch(e:Error)
			{
				assertTrue ("replaceText should return error.", e.message == "Invalid positions passed to SpanElement.replaceText");
			}
			//try to replace text at end point > text Length, should return error
			try
			{
				var len:int = SelManager.textFlow.textLength;
				span.replaceText(5, len + 1, "your");
			} catch(e:Error)
			{
				assertTrue ("replaceText should return error.", e.message == "Invalid positions passed to SpanElement.replaceText");
			}
			//try to replace text when end point < start point, should return error
			try
			{
				span.replaceText(5, 3, "your");
			} catch(e:Error)
			{
				assertTrue ("replaceText should return error.", e.message == "Invalid positions passed to SpanElement.replaceText");
			}
			SelManager.textFlow.flowComposer.updateAllControllers();   
		}
		
		public function copyErrorMassageTest():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			
			var p:ParagraphElement = new ParagraphElement();
			var span1:SpanElement = new SpanElement();
			var span2:SpanElement = new SpanElement();
			span1.text = "1水z𝄞#####%23456789"; //character 水z𝄞 to make badSurrogatePairCopy error
			
			try{
				span2 = span1.shallowCopy(7, 6) as SpanElement;
			}catch (e:Error)
			{
				assertTrue("Invalid error message for badShallowCopyRange", e.message = "Bad range in shallowCopy");
			}
			try{
				span2 = span1.shallowCopy(2, 4) as SpanElement;
			}catch (e:Error)
			{
				assertTrue("Invalid error message for badSurrogatePairCopy", e.message = "Copying only half of a surrogate pair in SpanElement.shallowCopy");
			}
			p.fontSize = 20;
			p.addChild(span1);
			p.addChild(span2);
		
			SelManager.textFlow.addChild(p);
			SelManager.textFlow.flowComposer.updateAllControllers();   
		}
		
		public function applyFormatToElementOperationFormatTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var styleName:String = "userStyleName";
			var newStyleValue:String = "newUserStyleValue";
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.fontSize = 10;
			format.setStyle(styleName,newStyleValue);
			var op:ApplyFormatToElementOperation = new ApplyFormatToElementOperation(SelManager.getSelectionState(),tf,format);
			//test format setter
			format.fontSize = 20;
			op.format = format;
			SelManager.doOperation(op);
			//test format getter
			assertTrue("format font size is not set correctly", op.format.fontSize == 20 &&
			           tf.getStyle(styleName) == "newUserStyleValue" );
		}
		
		public function typeNameSetGetTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var newTypeName:String = "newTFTypeName1";
			
			var op:ApplyElementTypeNameOperation = new ApplyElementTypeNameOperation(SelManager.getSelectionState(),tf,newTypeName);
			op.typeName = "newTFTypeName2";
			SelManager.doOperation(op);
			assertTrue("ApplyElementTypeNameOperation doesn't set or get correct typeName", op.typeName == "newTFTypeName2");
		}
	}
}
