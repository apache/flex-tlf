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

	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.system.*;
	import flash.text.*;
	import flash.text.engine.*;
	import flash.ui.*;
	import flash.utils.*;
	import flash.xml.*;

	import flashx.textLayout.elements.*;
	import flashx.textLayout.property.*;

	import mx.utils.LoaderUtil;


	public class FontEmbedTest extends VellumTestCase
	{
		public function FontEmbedTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);
		}
		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = FontEmbedTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

		public var ldr:Loader;
		public var thing1:Sprite;
		private var isFontLoss:Boolean;
		public function embeddedFontsLossTest():void
		{
			isFontLoss = true;
			thing1 = new Sprite();
			TestFrame.container.addChild(thing1);
			thing1.graphics.beginFill(0xFF0000);
			thing1.graphics.drawRect(0, 0, 500, 400);
			thing1.graphics.endFill();
			ldr = new Loader();
			thing1.addChild(ldr);
			ldr.load(new URLRequest(LoaderUtil.createAbsoluteURL(baseURL,"../../asTestApps/moduleFontLoss.swf")));
			var func:Function = addAsync(finished_loading, 10000, null);
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, func, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, func, false, 0, true);
		}

		public function embeddedFontsDisplayTest():void
		{
			isFontLoss = false;
			thing1 = new Sprite();
			TestFrame.container.addChild(thing1);
			thing1.graphics.beginFill(0xFF0000);
			thing1.graphics.drawRect(0, 0, 500, 400);
			thing1.graphics.endFill();
			ldr = new Loader();
			thing1.addChild(ldr);
			ldr.load(new URLRequest(LoaderUtil.createAbsoluteURL(baseURL,"../../asTestApps/moduleFontDisplay.swf")));
			var func:Function = addAsync(finished_loading, 10000, null);
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, func, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, func, false, 0, true);
		}

		public function finished_loading (e:Event):void
		{
			assertTrue("Error loading embeddedfont swf",!(e is ErrorEvent));
			var mc:MovieClip = MovieClip(ldr.content); // cast 'DisplayObject' to 'MovieClip'
			var tl:TextLine = mc.thing2.textLine;
			var tf:TextFlow = mc.thing2.textFlow;
			var textLineWidth:Number = tl.textWidth;
			var textFlowLine:TextLine =  tf.flowComposer.getLineAt(0).getTextLine();
			var textFlowLineWidth:Number =  textFlowLine.textWidth;

			if (isFontLoss)
			{
				assertTrue( "This is a negative test. The embedded fonts supposed to be lost but not. " + "textLineWidth : " + textLineWidth
				+ "textFlowLineWidth : " + textFlowLineWidth,
				( Math.abs(85.1484 - textLineWidth) >  0.001)
				|| ( Math.abs(84.4746 - textFlowLineWidth) > 0.001));

			}
			else
			{
				assertTrue( "embedded fonts have been lost. " + "textLineWidth : " + textLineWidth
				+ "textFlowLineWidth : " + textFlowLineWidth,
				( Math.abs(85.1484 - textLineWidth) <  0.001)
				&& ( Math.abs(84.4746 - textFlowLineWidth) < 0.001));
			}
		}

	}
}
