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
	import UnitTest.ExtendedClasses.VellumTestCase;
	import UnitTest.Fixtures.TestConfig;

	import flash.text.FontStyle;

	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;

	public class StyleTest extends VellumTestCase
	{
		private var formatResolver:TestFormatResolver;

		public function StyleTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Attributes";
			metaData.productSubArea = "CSS - Styling";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = StyleTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

		public override function setUp():void
		{
			super.setUp();

			formatResolver = new TestFormatResolver();
			TestFrame.textFlow.formatResolver = formatResolver;
		}

		public override function tearDown():void
		{
			TestFrame.textFlow.formatResolver = null;

			super.tearDown();
		}

		public function basicStyleTest():void
		{
			// Set up style resolver
			var testFormat:TextLayoutFormat = new TextLayoutFormat();
			testFormat.textAlign = TextAlign.CENTER;
			formatResolver.addStyle( "flowStyle", testFormat, TestFormatResolver.NAME_STYLE );

			// Assign style and check for result
			TestFrame.textFlow.getChildAt(0).styleName = "flowStyle";
			TestFrame.flowComposer.updateAllControllers();

			var testPara:ParagraphElement = TestFrame.textFlow.getChildAt(0) as ParagraphElement;
			assertTrue( "Format 'flowStyle' was not applied to the first paragraph",
				testPara.computedFormat.textAlign == TextAlign.CENTER );
		}

		public function styleNameInheritTest():void
		{
			// Set up style resolver
			var testFormat:TextLayoutFormat = new TextLayoutFormat();
			testFormat.fontStyle = FontStyle.ITALIC;
			formatResolver.addStyle( "fontStyle", testFormat, TestFormatResolver.NAME_STYLE );

			// Assign style and check for result
			TestFrame.textFlow.getChildAt(0).styleName = "fontStyle";
			TestFrame.flowComposer.updateAllControllers();

			var testSpan:SpanElement = (TestFrame.textFlow.getChildAt(0) as ParagraphElement).getChildAt(0) as SpanElement;
			assertTrue( "Format 'fontStyle' was not inherited by the first span",
				testSpan.computedFormat.fontStyle == FontStyle.ITALIC );
		}

		public function styleInvalidateTest():void
		{
			// Set up style resolver
			var testFormat:TextLayoutFormat = new TextLayoutFormat();
			testFormat.textAlign = TextAlign.CENTER;
			formatResolver.addStyle( "flowStyle", testFormat, TestFormatResolver.NAME_STYLE );

			// Assign style and check for result
			TestFrame.textFlow.getChildAt(0).styleName = "flowStyle";
			TestFrame.flowComposer.updateAllControllers();

			var testPara:ParagraphElement = TestFrame.textFlow.getChildAt(0) as ParagraphElement;
			assertTrue( "Format 'flowStyle' was not applied to the first paragraph",
				testPara.computedFormat.textAlign == TextAlign.CENTER );

			testPara.styleName = "otherStyle";

			assertTrue( "Format 'flowStyle' was still applied after being invalidated",
				testPara.computedFormat.textAlign != TextAlign.CENTER );
		}

		public function styleInvalidateAllTest():void
		{
			// Set up style resolver
			var testFormat:TextLayoutFormat = new TextLayoutFormat();
			testFormat.textAlign = TextAlign.CENTER;
			formatResolver.addStyle( "flowStyle", testFormat, TestFormatResolver.NAME_STYLE );

			// Assign style and check for result
			TestFrame.textFlow.getChildAt(0).styleName = "flowStyle";
			TestFrame.flowComposer.updateAllControllers();

			var testPara:ParagraphElement = TestFrame.textFlow.getChildAt(0) as ParagraphElement;
			assertTrue( "Format 'flowStyle' was not applied to the first paragraph",
				testPara.computedFormat.textAlign == TextAlign.CENTER );

			testFormat.textAlign = TextAlign.RIGHT;
			assertTrue( "Format 'flowStyle' updated without being invalidated",
				testPara.computedFormat.textAlign != TextAlign.RIGHT );

			TestFrame.textFlow.invalidateAllFormats();
			assertTrue( "Format 'flowStyle' was still applied after being invalidated",
				testPara.computedFormat.textAlign == TextAlign.RIGHT );
		}

		public function basicIdTest():void
		{
			// Set up resolver
			var testFormat:TextLayoutFormat = new TextLayoutFormat();
			testFormat.textAlign = TextAlign.CENTER;
			formatResolver.addStyle( "flowid", testFormat, TestFormatResolver.ID_STYLE);

			// Assign id and check for result
			TestFrame.textFlow.getChildAt(0).id = "flowid";
			TestFrame.flowComposer.updateAllControllers();

			var testPara:ParagraphElement = TestFrame.textFlow.getChildAt(0) as ParagraphElement;
			assertTrue( "Format 'flowid' was not applied to the first paragraph",
				testPara.computedFormat.textAlign == TextAlign.CENTER );
		}

		public function idInheritTest():void
		{
			// Set up resolver
			var testFormat:TextLayoutFormat = new TextLayoutFormat();
			testFormat.fontStyle = FontStyle.ITALIC;
			formatResolver.addStyle( "FontStyle", testFormat, TestFormatResolver.ID_STYLE );

			// Assign id and check for result
			TestFrame.textFlow.getChildAt(0).id = "FontStyle";
			TestFrame.flowComposer.updateAllControllers();

			var testSpan:SpanElement = (TestFrame.textFlow.getChildAt(0) as ParagraphElement).getChildAt(0) as SpanElement;
			assertTrue( "Format 'FontStyle' was not inherited by the first span",
				testSpan.computedFormat.fontStyle == FontStyle.ITALIC );
		}

		public function idInvalidateTest():void
		{
			// Set up resolver
			var testFormat:TextLayoutFormat = new TextLayoutFormat();
			testFormat.textAlign = TextAlign.CENTER;
			formatResolver.addStyle( "flowid", testFormat, TestFormatResolver.ID_STYLE );

			// Assign id and check for result
			TestFrame.textFlow.getChildAt(0).id = "flowid";
			TestFrame.flowComposer.updateAllControllers();

			var testPara:ParagraphElement = TestFrame.textFlow.getChildAt(0) as ParagraphElement;
			assertTrue( "Format 'flowid' was not applied to the first paragraph",
				testPara.computedFormat.textAlign == TextAlign.CENTER );

			testPara.id = "otherid";

			assertTrue( "Format 'flowid' was still applied after being invalidated",
				testPara.computedFormat.textAlign != TextAlign.CENTER );
		}

		public function idInvalidateAllTest():void
		{
			// Set up resolver
			var testFormat:TextLayoutFormat = new TextLayoutFormat();
			testFormat.textAlign = TextAlign.CENTER;
			formatResolver.addStyle( "flowid", testFormat, TestFormatResolver.ID_STYLE );

			// Assign id and check for result
			TestFrame.textFlow.getChildAt(0).id = "flowid";
			TestFrame.flowComposer.updateAllControllers();

			var testPara:ParagraphElement = TestFrame.textFlow.getChildAt(0) as ParagraphElement;
			assertTrue( "Format 'flowid' was not applied to the first paragraph",
				testPara.computedFormat.textAlign == TextAlign.CENTER );

			testFormat.textAlign = TextAlign.RIGHT;
			assertTrue( "Format 'flowid' updated without being invalidated",
				testPara.computedFormat.textAlign != TextAlign.RIGHT );

			TestFrame.textFlow.invalidateAllFormats();
			assertTrue( "Format 'flowid' was still applied after being invalidated",
				testPara.computedFormat.textAlign == TextAlign.RIGHT );
		}

		public function basicUserStyleTest():void
		{
			var formatObject:Object = new Object();
			var styleObject:Object = new Object();

			formatResolver.addStyle( "myStyle", formatObject, TestFormatResolver.USER_STYLE );
			assertTrue( "UserStyle failed to return correct format object",
						TestFrame.textFlow.getStyle( "myStyle" ) == formatObject );

			TestFrame.textFlow.setStyle( "myStyle", styleObject );
			assertTrue( "UserStyle failed to return correct format object",
						TestFrame.textFlow.getStyle( "myStyle" ) == styleObject );
		}
	}
}

import flashx.textLayout.elements.IFormatResolver;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.FlowGroupElement;

import flashx.textLayout.formats.TextLayoutFormat;
import flashx.textLayout.formats.ITextLayoutFormat;

import flash.utils.Dictionary;
import flashx.textLayout.elements.TextFlow;

class TestFormatResolver implements IFormatResolver
{
	private var _styleCache:Dictionary;
	private var _nameStyles:Dictionary;
	private var _idStyles:Dictionary;

	private var _userStyles:Dictionary;
	private var _userCache:Dictionary;
	public var userStyleReference:Dictionary;

	public static const ID_STYLE:String = "id";
	public static const NAME_STYLE:String = "class";
	public static const USER_STYLE:String = "user";

	public var getResolverCalled:Boolean = false;
	public var lastOldFlow:TextFlow;
	public var lastNewFlow:TextFlow;

	public function TestFormatResolver()
	{
		_styleCache = new Dictionary();
		_nameStyles = new Dictionary();
		_idStyles = new Dictionary();

		_userStyles = new Dictionary();
		_userCache = new Dictionary();
		userStyleReference = new Dictionary();
	}

	/** Adds a new style to the resolver. The resolve methods will return styleValue for styleName
	 * styleType can be one of TestFormatResolver.ID_STYLE, TestFormatResolver.NAME_STYLE, or
	 * TestFormatResolver.USER_STYLE */
	public function addStyle( styleName:String, styleValue:Object, styleType:String ):void
	{
		if ( styleType == TestFormatResolver.ID_STYLE )
		{
			_idStyles[styleName] = styleValue;
		}
		else if ( styleType == TestFormatResolver.NAME_STYLE )
		{
			_nameStyles[styleName] = styleValue;
		}
		else if ( styleType == USER_STYLE )
		{
			_userStyles[styleName] = styleValue;
		}
		else throw new Error( "TEST ERROR: TestStyleResolver.addStyle() called with unknown styleType" );

		invalidateAll(null);
	}

	public function resolveFormat(elem:Object):ITextLayoutFormat
 	{
 		// Add to the cache if it's not already there
 		if ( !_styleCache[elem] )
 		{
 			_styleCache[elem] = new TextLayoutFormat();

 			// If we have an ContainerController, give up
 			if ( !(elem is FlowElement) )
 			{
 				return undefined;
 			}

 			if ( _nameStyles[elem.styleName] )
 			{
 				_styleCache[elem].concat( _nameStyles[elem.styleName] );
 			}

 			if ( _idStyles[elem.id] )
 			{
 				_styleCache[elem].concat( _idStyles[elem.id] );
 			}
 		}

 		return _styleCache[elem];
 	}

	/** any cached styling information is now invalid and need recomputing */
	public function invalidateAll(tf:TextFlow):void
	{
		_styleCache = new Dictionary();
 		_userCache = new Dictionary();
	}

	/** cached information on this element is now invalid (e.g. parent changed, id changed, styleName changed) */
	public function invalidate(target:Object):void
	{
		delete _styleCache[target];

 		var blockElem:FlowGroupElement = target as FlowGroupElement;
 		if (blockElem)
 		{
 			for (var idx:int = 0; idx < blockElem.numChildren; idx++)
 				invalidate(blockElem.getChildAt(idx));
 		}
	}

	/** Given a FlowElement or ContainerController and the name of a style property return a style value or undefined*/
	public function resolveUserFormat(elem:Object,userStyle:String):*
	{
		if ( _userCache[userStyle] )
			return _userCache[userStyle];
		else if ( !_userStyles[userStyle] )
			return undefined;
		else
			_userCache[userStyle] = _userStyles[userStyle];

		return _userCache[userStyle];
	}

	/** Called when the owning TextFlow is copied. One TestStyleResolver is used for all instances. */
	public function getResolverForNewFlow(oldFlow:TextFlow,newFlow:TextFlow):IFormatResolver
	{
		getResolverCalled = true;
		lastOldFlow = oldFlow;
		lastNewFlow = newFlow;

		return this;
	}
}
