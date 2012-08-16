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
package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.Font;
	import flash.text.engine.FontLookup;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;

	public class AliceScrollEmbed extends Sprite
	{
	    // embed alice - this simplifies things - don't need to trust the swf and pass the xml around with it
		// [Embed(source="../../test/testFiles/markup/tlf/AliceID.xml",mimeType="application/octet-stream")]
		[Embed(source="../../test/testFiles/markup/tlf/alice.xml",mimeType="application/octet-stream")]
		private var AliceClass : Class;
		
		[Embed(mimeType="application/x-font", exportSymbol="MinionProRegular", embedAsCFF="true", source="../../fonts/MinionPro-Regular.otf", fontName="myMinionPro")]
		private const MinionProRegular:Class;

		public function AliceScrollEmbed()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 1000;

			var s:Sprite = new Sprite();
			s.x = 100;
			s.y = 100;
			addChild(s);

			var alice:ByteArray = new AliceClass();
			var aliceData:String = alice.readMultiByte(alice.length,"utf-8");

			var beginParseTime:Number = getTimer();
			var textFlow:TextFlow = TextConverter.importToFlow(aliceData, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.fontLookup = FontLookup.EMBEDDED_CFF;
			textFlow.fontFamily = "myMinionPro";
			var parseTime:Number = getTimer() - beginParseTime;

			var helper:ScrollTestHelper = new ScrollTestHelper();
			helper.beginTest("AliceScrollEmbed",textFlow,parseTime,s,500,400,this);
		}
	}
}

