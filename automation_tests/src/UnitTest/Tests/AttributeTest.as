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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.engine.BreakOpportunity;
	import flash.text.engine.CFFHinting;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.Kerning;
	import flash.text.engine.RenderingMode;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextLine;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.elements.TextRange;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Category;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.*;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

 	public class AttributeTest extends VellumTestCase
	{
		public function AttributeTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super(methodName, testID, testConfig);
			
			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Attributes";
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setSelectionTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "selectAllTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setBoldOn", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setBoldOff", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setItalicOn", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setItalicOff", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setFontValid", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setFontSizeValid", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setFontSizeInvalid", testConfig ) );
   			// ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setFontSizeOutOfBounds" ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setFontColorValid", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setFontColorInvalid", testConfig ) );
    		ts.addTestDescriptor (new TestDescriptor( AttributeTest, "metricskernoff", testConfig ) );  //KJT
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "metricskernon", testConfig ) );  //KJT

   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "track_right_positive", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "track_right_negative", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "track_left_positive", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "track_left_negative", testConfig ) );

   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "baseline_shift", testConfig ) );  //KJT

   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "element_baseline_ideographictop", testConfig ) );  //KJT
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "element_baseline_ideographiccenter", testConfig ) );  //KJT

   		 	ts.addTestDescriptor (new TestDescriptor( AttributeTest, "breakopportunityAll", testConfig ) );  //KJT
   		 	ts.addTestDescriptor (new TestDescriptor( AttributeTest, "breakopportunityAny", testConfig ) );  //KJT
   		  	ts.addTestDescriptor (new TestDescriptor( AttributeTest, "breakopportunityAutomatic", testConfig ) );  //KJT
   		    ts.addTestDescriptor (new TestDescriptor( AttributeTest, "breakopportunityNone", testConfig ) );  //KJT

   		    ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setRenderingModeTest", testConfig) ); //HBS
   		    ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setCFFHintingTest", testConfig) ); //HBS
   		    ts.addTestDescriptor (new TestDescriptor( AttributeTest, "getCommonFormatTest", testConfig) );

			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setUnderlineOn", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setUnderlineOff", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setStrikethroughOn", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setStrikethroughOff", testConfig ) );

   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setStrikethroughAndBaselinePos", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setUnderlineAndBaselinePos", testConfig ) );

   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setStrikethroughAndBaselineNeg", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setUnderlineAndBaselineNeg", testConfig ) );

   		    ts.addTestDescriptor (new TestDescriptor( AttributeTest, "setAndVerifyBackgroundColor", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor( AttributeTest, "formatResolverTest", testConfig ) );

			if (testConfig.writingDirection[0] == "tb" && testConfig.writingDirection[1] == "ltr")
			{
	   		    ts.addTestDescriptor (new TestDescriptor( AttributeTest, "copyTextLayoutFormat", testConfig ) );
	   		    ts.addTestDescriptor (new TestDescriptor( AttributeTest, "concatenateTextFormat", testConfig ) );
	   		    ts.addTestDescriptor (new TestDescriptor( AttributeTest, "concatinateInheritOnly", testConfig ) );
	   		    ts.addTestDescriptor (new TestDescriptor( AttributeTest, "removeClashing", testConfig ) );
	   		    ts.addTestDescriptor (new TestDescriptor( AttributeTest, "removeMatching", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor( AttributeTest, "getCommonCharacterFormatAtPoint", testConfig ) );
			}
			
  		}

		/**
		* selecting text from 10 to 20
		*/
		public function setSelectionTest():void
		{
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx,endIndx);
		}

		/**
		* calls SelManager.selectRange()
		*/
		public function selectAllTest():void
		{
			SelManager.selectAll();
			SelManager.refreshSelection();
		}

		/* ************************************************************** */
		/* Bold Tests */
		/* ************************************************************** */

		public function setBoldOn():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.fontWeight = FontWeight.BOLD;
			SelManager.applyLeafFormat(ca);
			assertTrue("Bold was not turned on", getBold() == FontWeight.BOLD);
		}

		public function setBoldOff():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.fontWeight = FontWeight.NORMAL;
			SelManager.applyLeafFormat(ca);
			assertTrue("Bold was not turned off", getBold() == FontWeight.NORMAL);
		}

		private function getBold():String
		{
			var idxToUse:int = SelManager.anchorPosition;
			var fontAttribute:String = "";
			for (var i:int = idxToUse; i < SelManager.activePosition; i++)
			{
				var elem:FlowElement = SelManager.textFlow.findLeaf(i);
				// A value of null indicates that the format has never had that value set for it.
				if (elem.format.fontWeight != null)
				{
					if (fontAttribute == "")
						fontAttribute = elem.format.fontWeight;
					else if (fontAttribute != elem.format.fontWeight)
						fontAttribute = "mixed";
				}
			}
			return fontAttribute;
		}


		/* ************************************************************** */
		/* Italic Tests */
		/* ************************************************************** */

		public function setItalicOn():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.fontStyle = FontPosture.ITALIC;
			SelManager.applyLeafFormat(ca);
			assertTrue("Italic was not turned on", getItalic() == FontPosture.ITALIC);
		}

		public function setItalicOff():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.fontStyle = FontPosture.NORMAL;
			SelManager.applyLeafFormat(ca);
			assertTrue("Italic was not turned off", getItalic() == FontPosture.NORMAL);
		}

		private function getItalic():String
		{
			var idxToUse:int = SelManager.anchorPosition;
			var fontAttribute:String = "";
			for (var i:int = idxToUse; i < SelManager.activePosition; i++)
			{
				var elem:FlowElement = SelManager.textFlow.findLeaf(i);
				// A value of null indicates that the format has never had that value set for it.
				if (elem.format.fontStyle != null)
				{
					if (fontAttribute == "")
						fontAttribute = elem.format.fontStyle;
					else if (fontAttribute != elem.format.fontStyle)
						fontAttribute = "mixed";
				}
				else
				{
					fontAttribute = FontPosture.NORMAL;
					return fontAttribute;
				}
			}
			return fontAttribute;
		}

		/* ************************************************************** */
		/* Underline Tests */
		/* ************************************************************** */

		public function setUnderlineOn():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.textDecoration = TextDecoration.UNDERLINE;
			SelManager.applyLeafFormat(ca);
			assertTrue("Underline was not turned on", getUnderline() == TextDecoration.UNDERLINE);
		}

		public function setUnderlineOff():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.textDecoration = TextDecoration.NONE;
			SelManager.applyLeafFormat(ca);
			assertTrue("Underline was not turned off", getUnderline() == TextDecoration.NONE);
		}

		private function getUnderline():String
		{
			// Walk through all of the characters in the
			// selection to check the Underline attribute.
			var fontAttribute:String = "";
			for (var i:int = SelManager.anchorPosition; i < SelManager.activePosition; i++)
			{
				var elem:FlowElement = SelManager.textFlow.findLeaf(i);
				if (elem.format.textDecoration)
				{
					if (fontAttribute == "")
						fontAttribute = elem.format.textDecoration;
					else if (fontAttribute != elem.format.textDecoration)
						fontAttribute = "mixed";
				}
			}
			return fontAttribute;
		}

		/* ************************************************************** */
		/* Strikethrough Tests */
		/* ************************************************************** */

		public function setStrikethroughOn():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.lineThrough = true;
			SelManager.applyLeafFormat(ca);
			assertTrue("Strikethrough was not turned on", getStrikethrough() == "true");
		}

		public function setStrikethroughOff():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.lineThrough = false;
			SelManager.applyLeafFormat(ca);
			assertTrue("Strikethrough was not turned off", getStrikethrough() == "false");
		}

		private function getStrikethrough():String
		{
			// Walk through all of the characters in the
			// selection to check the Strikethrough attribute.
			var fontAttribute:String = "";
			for (var i:int = SelManager.anchorPosition; i < SelManager.activePosition; i++)
			{
				var elem:FlowElement = SelManager.textFlow.findLeaf(i);
				if (elem.format.lineThrough != null)
				{
					if (fontAttribute == "")
						fontAttribute = elem.format.lineThrough ? "true" : "false";
					else if (fontAttribute != (elem.format.lineThrough ? "true" : "false"))
						fontAttribute = "mixed";
				}
			}
			return fontAttribute;
		}

		/* ************************************************************** */
		/* breakOpportunity Tests */
		/* Adding a string of text and testing each break oppertunity so see the difference is line rendeirng*/
		/* ************************************************************** */


		public function breakopportunityAll():void // KJT
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();

			SelManager.selectRange(20, 77);
			ca.breakOpportunity = BreakOpportunity.ALL;
			SelManager.applyLeafFormat(ca);
			//trace ('break after after every char');;

			SelManager.insertText("BOOGAaaaaaaaaaaaaaaaaaaaaaaaaaa||aaaa break->aaaaaaaaa123");
			SelManager.applyLeafFormat(ca);

			assertTrue("Break opportuntiy was not set to all", ca.breakOpportunity == BreakOpportunity.ALL);
		}

		public function breakopportunityNone():void // KJT
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();

			SelManager.selectRange(20, 77);
			ca.breakOpportunity = BreakOpportunity.NONE;
			SelManager.applyLeafFormat(ca);

			SelManager.insertText("BOOGAaaaaaaaaaaaaaaaaaaaaaaaaaa||aaaa break->aaaaaaaaa123");


			SelManager.applyLeafFormat(ca);

			assertTrue("Break opportuntiy was not set to none", ca.breakOpportunity == BreakOpportunity.NONE);
		}

		public function breakopportunityAutomatic():void // KJT
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();

			SelManager.selectRange(20, 77);
			ca.breakOpportunity = BreakOpportunity.AUTO;
			SelManager.applyLeafFormat(ca);

			SelManager.insertText("BOOGAaaaaaaaaaaaaaaaaaaaaaaaaaa||aaaa break->aaaaaaaaa123");


			SelManager.applyLeafFormat(ca);

			assertTrue(true, ca.breakOpportunity == BreakOpportunity.AUTO);
		}

		public function breakopportunityAny():void // KJT
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();

			SelManager.selectRange(20, 77);
			ca.breakOpportunity = BreakOpportunity.ANY;
			SelManager.applyLeafFormat(ca);

			SelManager.insertText("BOOGAaaaaaaaaaaaaaaaaaaaaaaaaaa||aaaa break->aaaaaaaaa123");


			SelManager.applyLeafFormat(ca);

			assertTrue("Break opportuntiy was not set to automatic", ca.breakOpportunity == BreakOpportunity.ANY);
		}
		/* ************************************************************** */
		/* Baseline Shift Tests */
		/* Element & Line Baseline Tests */
		/* ************************************************************** */






		public function element_baseline_ideographictop():void // KJT
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			SelManager.selectRange(10,50);

			ca.dominantBaseline = TextBaseline.IDEOGRAPHIC_TOP;
			SelManager.applyLeafFormat(ca);


			assertTrue("dominant baseline is not " + TextBaseline.IDEOGRAPHIC_TOP, ca.dominantBaseline == TextBaseline.IDEOGRAPHIC_TOP);
		}



		public function element_baseline_ideographiccenter():void // KJT
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			SelManager.selectRange(10,50);

			ca.dominantBaseline = TextBaseline.IDEOGRAPHIC_CENTER;
			SelManager.applyLeafFormat(ca);

			assertTrue("dominant baseline is not " + TextBaseline.IDEOGRAPHIC_CENTER, ca.dominantBaseline == TextBaseline.IDEOGRAPHIC_CENTER);
		}


	   public function baseline_shift():void // KJT
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();

			ca.baselineShift = -500;
			SelManager.applyLeafFormat(ca);

			assertTrue("baseline shift is not -500", ca.baselineShift == -500);
		}


		/* ************************************************************** */
		/* Font Kerning Tests */
		/* ************************************************************** */

		public function metricskernon():void // KJT
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.kerning = Kerning.ON;
			SelManager.applyLeafFormat(ca);
			assertTrue("kerning is not true", getKern() == Kerning.ON);
		}


		public function metricskernoff():void // KJT
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.kerning = Kerning.OFF;
			SelManager.applyLeafFormat(ca);
			assertTrue("kerning is not false", getKern() == Kerning.OFF);
		}

		private function getKern():String  //KJT
		{
			// TODO: QE FOLKS What does this code do?
		 	for (var i:int = SelManager.anchorPosition; i < SelManager.activePosition; i++)
			{
				var elem:FlowElement = SelManager.textFlow.findLeaf(i);
				// A value of null indicates that the format has never had that value set for it.

			}

			return String(elem.format.kerning);
		}

		/* ************************************************************** */
		/* TrackingRight Tests */
		/* ************************************************************** */

		//positive tracking right

		public function track_right_positive():void
		{
			//change the text and recompose
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("tracking test");
			TestFrame.flowComposer.updateAllControllers();

			//get the line width before the change
			var initialLineWidth:Number;
			initialLineWidth = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine(true).textWidth;

			//Apply positive tracking right
			var trackValue:Number = 0.5;
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.trackingRight = trackValue;

			//check that the correct value is in the format object
			assertTrue("track right should be " + trackValue + " but is " + ca.trackingRight, ca.trackingRight == trackValue);
			SelManager.selectAll();
			SelManager.applyLeafFormat(ca);

			//check that the value was applied to the text
			var appliedValue:Number;
			appliedValue = SelManager.getCommonCharacterFormat().trackingRight;
			assertTrue("track right shold be " + trackValue + " but is " + appliedValue, appliedValue == trackValue);

			//check that the line length increased
			TestFrame.flowComposer.updateAllControllers();
			var endLineWidth:Number;
			endLineWidth = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine(true).textWidth;
			assertTrue("Line length should have increased, but changed from " + initialLineWidth + " to " + endLineWidth, endLineWidth > initialLineWidth);
		}


		//negative tracking right

		public function track_right_negative():void
		{
			//change the text and recompose
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("tracking test");
			TestFrame.flowComposer.updateAllControllers();

			//get the line width before the change
			var initialLineWidth:Number;
			initialLineWidth = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine(true).textWidth;

			//Apply negative tracking right
			var trackValue:Number = -1.0;
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.trackingRight = trackValue;

			//check that the correct value is in the format object
			assertTrue("track right should be " + trackValue + " but is " + ca.trackingRight, ca.trackingRight == trackValue);
			SelManager.selectAll();
			SelManager.applyLeafFormat(ca);

			//check that the value was applied to the text
			var appliedValue:Number;
			appliedValue = SelManager.getCommonCharacterFormat().trackingRight;
			assertTrue("track right should be " + trackValue + " but to " + appliedValue, appliedValue == trackValue);

			//check that the line length decreased
			TestFrame.flowComposer.updateAllControllers();
			var endLineWidth:Number;
			endLineWidth = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine(true).textWidth;
			assertTrue("Line length should have decreased, but changed from " + initialLineWidth + " to " + endLineWidth, endLineWidth < initialLineWidth);
		}


		/* ************************************************************** */
		/* TrackingLeft Tests */
		/* ************************************************************** */

		//positive tracking left

		public function track_left_positive():void
		{
			//change the text and compose
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("tracking test");
			TestFrame.flowComposer.updateAllControllers();

			//get the line width before the change
			var initialLineWidth:Number;
			initialLineWidth = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine(true).textWidth;

			//Apply positive tracking left
			var trackValue:Number = 0.5;
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.trackingLeft = trackValue;

			//check that the correct value is in the format object
			assertTrue("track left should be " + trackValue + " but is " + ca.trackingLeft, ca.trackingLeft == trackValue);
			SelManager.selectAll();
			SelManager.applyLeafFormat(ca);

			//check that the value was applied to the text
			var appliedValue:Number;
			appliedValue = SelManager.getCommonCharacterFormat().trackingLeft;
			assertTrue("track left should be " + trackValue + " but is " + appliedValue, appliedValue == trackValue);

			//check the line length increased
			TestFrame.flowComposer.updateAllControllers();
			var endLineWidth:Number;
			endLineWidth = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine(true).textWidth;
			assertTrue("Line length should have increased, but changed from " + initialLineWidth + " to " + endLineWidth, endLineWidth > initialLineWidth);
		}


		//negative tracking left

		public function track_left_negative():void
		{
			//Change the text and compose
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("tracking test");
			TestFrame.flowComposer.updateAllControllers();

			//get the line width before the change
			var initialLineWidth:Number;
			initialLineWidth = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine(true).textWidth;

			//Apply negative tracking left
			var trackValue:Number = -1.0;
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.trackingLeft = trackValue;

			//check that the correct value is in the format object
			assertTrue("track left should be " + trackValue + " but is " + ca.trackingLeft, ca.trackingLeft == trackValue);
			SelManager.selectAll();
			SelManager.applyLeafFormat(ca);

			//check the value was applied to the text
			var appliedValue:Number;
			appliedValue = SelManager.getCommonCharacterFormat().trackingLeft;
			assertTrue("track left should be " + trackValue + " but is " + appliedValue, appliedValue == trackValue);

			//check that the line length decreased
			TestFrame.flowComposer.updateAllControllers();
			var endLineWidth:Number
			endLineWidth = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine(true).textWidth;
			assertTrue("Line length should have decreased, but changed from " + initialLineWidth + " to " + endLineWidth, endLineWidth < initialLineWidth);
		}


		/* ************************************************************** */
		/* Font Name Tests */
		/* ************************************************************** */

		public function setFontValid():void
		{
			const fontName:String = "Courier New";
			try {
				var ca:TextLayoutFormat = new TextLayoutFormat();
				ca.fontFamily = fontName;
				SelManager.applyLeafFormat(ca);
			}
			catch (e:Error) {}
			assertTrue ("font is not " + fontName, (getFont() == fontName));
		}

		private function getFont():String
		{
			var fontName:String = "";
			for (var i:int = SelManager.anchorPosition; i < SelManager.activePosition; i++)
			{
				var elem:FlowElement = SelManager.textFlow.findLeaf(i);
				// A value of null indicates that the format has never had that value set for it.
				if (elem.format.fontFamily != null)
				{
					if (fontName == "")
					{
						fontName = String(elem.format.fontFamily);
					}
					else if (elem.format.fontFamily != fontName)
					{
						fontName = "";
						break;
					}
				}
				else
				{
					return fontName;
				}
			}
			return fontName;
		}

		/* ************************************************************** */
		/* Font Size Tests */
		/* ************************************************************** */

		public function setFontSizeValid():void
		{
			try {
				setFontSize(48);
			}
			catch (e:Error) {}
			assertTrue ("font size is not 48", (getFontSize() == 48));
		}

		public function setFontSizeInvalid():void
		{
			try {
				setFontSize(-1);
			}
			catch (e:Error) {}
			assertTrue ("font size was set to -1", (getFontSize() != -1));
		}

		public function setFontSizeOutOfBounds():void
		{
			try {
				setFontSize(999);
			}
			catch (e:Error) {}
			assertTrue ("font size was set to 999", (getFontSize() == 999));
		}

		private function setFontSize(size:Number):void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.fontSize = size;
			SelManager.applyLeafFormat(ca);
		}

		private function getFontSize():int
		{
			var fontSize:int = 0;
			for (var i:int = SelManager.anchorPosition; i < SelManager.activePosition; i++)
			{
				var elem:FlowElement = SelManager.textFlow.findLeaf(i);

				// A value of null indicates that the format has never had that value set for it.
				if (elem.format && elem.format.fontSize !== undefined)
				{
					if (fontSize == 0)
					{
						fontSize = int(elem.format.fontSize);
					}
					else if (elem.format.fontSize != fontSize)
					{
						fontSize = 0;
						break;
					}
				}
				else
				{
					return fontSize;
				}
			}
			return fontSize;
		}

		/* ************************************************************** */
		/* Font Color Tests */
		/* ************************************************************** */

		public function setFontColorValid():void
		{
			const fontColor:int = 0xFF0000;
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.color = fontColor;
			SelManager.applyLeafFormat(ca);
			assertTrue("font color was not " + fontColor, (getFontColor() == fontColor));
		}

		// Booga - Is this a valid test.
		public function setFontColorInvalid():void
		{
			var errorCaught:Boolean = false;
			var ca:TextLayoutFormat = new TextLayoutFormat();
			try
			{
				const fontColor:int = -1;
				ca.color = fontColor;
			}
			catch (e:Error)
			{
				errorCaught = true;
			}
			assertTrue("Setting fontColor to -1 not caught", errorCaught);
		}

		//sets various anti alias properties to see if they take.
		public function setRenderingModeTest():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.renderingMode = RenderingMode.NORMAL;
			SelManager.applyLeafFormat(ca);
			assertTrue("rendering type is not " + RenderingMode.NORMAL, getRenderingMode() == RenderingMode.NORMAL);
			ca.renderingMode = RenderingMode.CFF;
			SelManager.applyLeafFormat(ca);
			assertTrue("rendering type is not " + RenderingMode.CFF, getRenderingMode() == RenderingMode.CFF);
		}

		//sets the grid fit type anti-alias type
		public function setCFFHintingTest():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.cffHinting = CFFHinting.NONE;
			ca.renderingMode = RenderingMode.CFF;
			SelManager.applyLeafFormat(ca);
			assertTrue("renderingMode cffHinting type is not " + RenderingMode.NORMAL, getCFFHinting() == CFFHinting.NONE);
			ca.cffHinting = CFFHinting.HORIZONTAL_STEM;
			ca.renderingMode = RenderingMode.CFF;
			SelManager.applyLeafFormat(ca);
			assertTrue("renderingMode cffHinting type is not " + CFFHinting.HORIZONTAL_STEM, getCFFHinting() == CFFHinting.HORIZONTAL_STEM);
		}

		private function getCFFHinting():String
		{
			var cffHinting:String = "";
			for (var i:int = SelManager.anchorPosition; i < SelManager.activePosition; i++)
			{
				var elem:FlowLeafElement = SelManager.textFlow.findLeaf(i) as FlowLeafElement;

				// A value of null indicates that the format has never had that value set for it.
				if (elem.computedFormat != null)
				{
					if (cffHinting == "")
					{
						cffHinting = String(elem.computedFormat.cffHinting);
					}
					else if (elem.computedFormat.cffHinting != cffHinting)
					{
						cffHinting = "";
						break;
					}
				}
				else
				{
					return cffHinting;
				}
			}
			return cffHinting;
		}

		private function getRenderingMode():String
		{
			var renderingMode:String = "";
			for (var i:int = SelManager.anchorPosition; i < SelManager.activePosition; i++)
			{
				var elem:FlowElement = SelManager.textFlow.findLeaf(i);

				// A value of null indicates that the format has never had that value set for it.
				if (elem.format.renderingMode != null)
				{
					if (renderingMode == "")
					{
						renderingMode = String(elem.format.renderingMode);
					}
					else if (elem.format.renderingMode != renderingMode)
					{
						renderingMode = "";
						break;
					}
				}
				else
				{
					return renderingMode;
				}
			}
			return renderingMode;
		}

		private function getFontColor():int
		{
			var fontColor:int = -1;
			for (var i:int = SelManager.anchorPosition; i < SelManager.activePosition; i++)
			{
				var elem:FlowElement = SelManager.textFlow.findLeaf(i);

				// A value of null indicates that the format has never had that value set for it.
				if (elem.format.color != null)
				{
					if (fontColor == -1)
					{
						fontColor = int(elem.format.color);
					}
					else if (elem.format.color != fontColor)
					{
						fontColor = -1;
						break;
					}
				}
				else
				{
					return fontColor;
				}
			}
			return fontColor;
		}

		public function getCommonFormatTest():void
		{
			var begin:uint = 0;
			var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(begin);
			var end:uint = para.textLength;
			var spanLen:uint = end/3;
			assertTrue("getCommonCharacterFormat test needs at least 3 characters in the first para", spanLen > 0);

			SelManager.selectRange(begin,end-1);
			SelManager.applyLeafFormat(TextLayoutFormat.defaultFormat);	// Reset

			SelManager.selectRange(begin,2*spanLen);
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.fontWeight = FontWeight.BOLD;
			SelManager.applyLeafFormat(ca);

			SelManager.selectRange(spanLen,end-1);
			ca = new TextLayoutFormat();
			ca.fontSize = 20;
			SelManager.applyLeafFormat(ca);

			// Should be 3 leaves now
			var leaf1:FlowLeafElement = SelManager.textFlow.findLeaf(0);
			var leaf2:FlowLeafElement = leaf1.getNextLeaf();
			var leaf3:FlowLeafElement = leaf2.getNextLeaf();

			var leaf1Start:int = leaf1.getAbsoluteStart();
			var leaf2Start:int = leaf2.getAbsoluteStart();
			var leaf3Start:int = leaf3.getAbsoluteStart();

			SelManager.selectRange(leaf1Start, leaf2Start + leaf2.textLength);
			ca = new TextLayoutFormat(SelManager.getCommonCharacterFormat());
			assertTrue("getCommonCharacterFormat returned non-null value for an attribute that does not match", ca.fontSize == null);
			assertTrue("getCommonCharacterFormat with null text range returned different results from getCommonCharacterFormat with equivalent text range",
				TextLayoutFormat.isEqual(ca, SelManager.getCommonCharacterFormat(new TextRange(SelManager.textFlow, SelManager.anchorPosition, SelManager.activePosition))));
			ca.fontSize = 20;
			var compareAttrs:ITextLayoutFormat = Property.extractInCategory(TextLayoutFormat,TextLayoutFormat.description,leaf2.computedFormat,Category.CHARACTER, false) as ITextLayoutFormat;
			assertTrue("getCommonCharacterFormat returned unexpected value for an attribute that matches", TextLayoutFormat.isEqual(ca, compareAttrs));

			SelManager.selectRange(leaf2Start, leaf3Start + leaf3.textLength);
			ca = new TextLayoutFormat(SelManager.getCommonCharacterFormat());
			assertTrue("getCommonCharacterFormat returned non-null value for an attribute that does not match", ca.fontWeight == null);
			assertTrue("getCommonCharacterFormat with null text range returned different results from getCommonCharacterFormat with equivalent text range",
				TextLayoutFormat.isEqual(ca, SelManager.getCommonCharacterFormat(new TextRange(SelManager.textFlow, SelManager.anchorPosition, SelManager.activePosition))));
			ca.fontWeight = FontWeight.BOLD;
			compareAttrs = Property.extractInCategory(TextLayoutFormat,TextLayoutFormat.description,leaf2.computedFormat,Category.CHARACTER, false) as ITextLayoutFormat;
			assertTrue("getCommonCharacterFormat returned unexpected value for an attribute that matches", TextLayoutFormat.isEqual(ca, compareAttrs));

			SelManager.selectRange(0,end-1);
			ca = new TextLayoutFormat(SelManager.getCommonCharacterFormat()); // no parameters; use current selection
			assertTrue("getCommonCharacterFormat returned non-null value for an attribute that does not match", ca.fontWeight == null && ca.fontSize == null);
			assertTrue("getCommonCharacterFormat with null text range returned different results from getCommonCharacterFormat with equivalent text range",
				TextLayoutFormat.isEqual(ca, SelManager.getCommonCharacterFormat(new TextRange(SelManager.textFlow, SelManager.anchorPosition, SelManager.activePosition))));
			ca.fontSize = 20;
			ca.fontWeight = FontWeight.BOLD;
			compareAttrs = Property.extractInCategory(TextLayoutFormat,TextLayoutFormat.description,leaf2.computedFormat,Category.CHARACTER, false) as ITextLayoutFormat;
			assertTrue("getCommonCharacterFormat returned unexpected value for an attribute that matches", TextLayoutFormat.isEqual(ca, compareAttrs));

			SelManager.textFlow.flowComposer.compose();

			var para2:ParagraphElement = para.splitAtPosition(spanLen) as ParagraphElement;
			para.format = TextLayoutFormat.defaultFormat;
			para2.format = TextLayoutFormat.defaultFormat;

			para2.textAlign = flashx.textLayout.formats.TextAlign.CENTER;

			leaf1 = para.getFirstLeaf();
			leaf2 = para2.getFirstLeaf();

			SelManager.selectRange(leaf1.getAbsoluteStart(), leaf2.getAbsoluteStart() + leaf2.textLength);
			var pa:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonParagraphFormat());
			assertTrue("getCommonParagraphFormat returned non-null value for an attribute that does not match", pa.textAlign == null);
			assertTrue("getCommonParagraphFormat with null text range returned different results from getCommonParagraphFormat with equivalent text range",
				TextLayoutFormat.isEqual(pa, SelManager.getCommonParagraphFormat(new TextRange(SelManager.textFlow, SelManager.anchorPosition, SelManager.activePosition))));
			pa.textAlign = flashx.textLayout.formats.TextAlign.CENTER;
			compareAttrs = Property.extractInCategory(TextLayoutFormat,TextLayoutFormat.description,para2.computedFormat,Category.PARAGRAPH, false) as ITextLayoutFormat;
			assertTrue("getCommonParagraphFormat returned unexpected value for an attribute that matches", TextLayoutFormat.isEqual(pa, compareAttrs));

			SelManager.selectRange(0,0);
			var controller:ContainerController = SelManager.textFlow.flowComposer.getControllerAt(0);
			var containerAtts:TextLayoutFormat = new TextLayoutFormat(SelManager.getCommonContainerFormat());
			compareAttrs = Property.extractInCategory(TextLayoutFormat,TextLayoutFormat.description,controller.computedFormat,Category.CONTAINER, false) as ITextLayoutFormat;
			assertTrue("getCommonContainerFormat returned unexpected value", TextLayoutFormat.isEqual(containerAtts, compareAttrs));
			assertTrue("getCommonContainerFormat with null text range returned different results from getCommonContainerFormat with equivalent text range",
				TextLayoutFormat.isEqual(containerAtts, SelManager.getCommonContainerFormat(new TextRange(SelManager.textFlow, SelManager.anchorPosition, SelManager.activePosition))));

			SelManager.selectRange(-1,-1);
			assertTrue("getCommonContainerFormat expect null on no active selection", SelManager.getCommonContainerFormat() ==  null);
			assertTrue("getCommonCharacterFormat expect null on no active selection", SelManager.getCommonCharacterFormat() ==  null);
			assertTrue("getCommonParagraphFormat expect null on no active selection", SelManager.getCommonParagraphFormat() ==  null);

			SelManager.textFlow.flowComposer.compose();

			// TearDown likes a selection
			SelManager.selectRange(0,0);
		}

		/* ************************************************************** */
		/* Baseline + Decoration Tests */
		/* ************************************************************** */

		public function setStrikethroughAndBaselinePos():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.lineThrough = true;
			ca.baselineShift = 10;
			SelManager.applyLeafFormat(ca);
			assertTrue("Strikethrough was not turned on", getStrikethrough() == "true");
			assertTrue("baseline shift is not 10", ca.baselineShift == 10);
		}

		public function setUnderlineAndBaselinePos():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.textDecoration = TextDecoration.UNDERLINE;
			ca.baselineShift = 10;
			SelManager.applyLeafFormat(ca);
			assertTrue("Underline was not turned on", getUnderline() == TextDecoration.UNDERLINE);
			assertTrue("baseline shift is not 10", ca.baselineShift == 10);
		}

		public function setStrikethroughAndBaselineNeg():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.lineThrough = true;
			ca.baselineShift = -10;
			SelManager.applyLeafFormat(ca);
			assertTrue("Strikethrough was not turned on", getStrikethrough() == "true");
			assertTrue("baseline shift is not -10", ca.baselineShift == -10);
		}

		public function setUnderlineAndBaselineNeg():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.textDecoration = TextDecoration.UNDERLINE;
			ca.baselineShift = -10;
			SelManager.applyLeafFormat(ca);
			assertTrue("Underline was not turned on", getUnderline() == TextDecoration.UNDERLINE);
			assertTrue("baseline shift is not -10", ca.baselineShift == -10);
		}

		public function setAndVerifyBackgroundColor():void
		{
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.backgroundColor = 0xFFFF00;
			ca.backgroundAlpha = 1;
			SelManager.applyLeafFormat(ca);

			// get bounding rects for the current selection
			var boundsRects:Array;

			for (var i:int = SelManager.anchorPosition; i < SelManager.activePosition; i++)
			{
				var elem:FlowElement = SelManager.textFlow.findLeaf(i);
				var tl:TextLine = elem.getParagraph().getTextBlock().firstLine;
				assertTrue("No TextLine in TextBlock!", tl != null);
				boundsRects = (elem as FlowLeafElement).getSpanBoundsOnLine(tl, elem.computedFormat.blockProgression);

				// get background rects for the first textline of this leaf element
				var rects:Array = SelManager.textFlow.backgroundManager.getEntry(tl);
				assertTrue("Line has no background rects!", rects != null);
				var rectsToFind:int = rects.length;

				// make sure that every background rect in the textline occurs in the set of bounding rects gotten above
				for(var j:int = 0; j<boundsRects.length; ++j)
				{
					var r:Rectangle = boundsRects[j].clone();
					var globalStart:Point = new Point(r.x, r.y);
					globalStart = tl.localToGlobal(globalStart);
					globalStart = tl.parent.globalToLocal(globalStart);
					r.x = globalStart.x;
					r.y = globalStart.y;

					for(var k:int = 0; k<rects.length; ++k)
					{
						// TODO: check for exact equality.  I couldn't get the offset between line and container coordinates to
						// match up in every case, so let's just do the width and height comparison for now.
						if(shapeEquals(r, rects[k].rect))
						{
							rectsToFind--;
							if(rectsToFind == 0)
							{
								break;
							}
						}
					}
				}
				assertTrue("Background rects on TextLine don't match rects from getSpanBoundsOnLine()!", rectsToFind == 0);

			}

		}

		private function shapeEquals(r1:Rectangle, r2:Rectangle):Boolean
		{
			if(Math.abs(r1.width - r2.width) == 0 &&
				Math.abs(r1.height - r2.height) == 0)
				return true;

			return false;
		}
		/* ************************************************************** */
		/* copy Method*/
		/* ************************************************************** */

		public function copyTextLayoutFormat():void
		{

		//create two textLayoutFormat1
		var textLayoutFormat1:TextLayoutFormat = new TextLayoutFormat();

		//set format attributes in textLayoutFormat1
		textLayoutFormat1.fontFamily =  "Arial, Helvetica, _sans";
		textLayoutFormat1.fontSize = 20;
		textLayoutFormat1.color = 0x2200ff;
		textLayoutFormat1.fontStyle = FontPosture.ITALIC;
		textLayoutFormat1.lineHeight = "140%";
		textLayoutFormat1.textIndent = 15;

		//Create textLayoutformat2 and copy format attributes from textLayoutFormat1
		var textLayoutFormat2:TextLayoutFormat = new TextLayoutFormat(textLayoutFormat1);

		//velidate
		assertTrue("Font family should be copied, but it is not copied", textLayoutFormat2.fontFamily == "Arial, Helvetica, _sans");
		assertTrue("Font size should be copied, but it is not copied", textLayoutFormat2.fontSize == 20);
		assertTrue("Text color should be copied, but it is not copied", textLayoutFormat2.color == 0x2200ff);
		assertTrue("Font style should be copied, but it is not copied", textLayoutFormat2.fontStyle == FontPosture.ITALIC);
		assertTrue("Line height should be copied, but it is not copied", textLayoutFormat2.lineHeight = "140%");
		assertTrue("Text indent should be copied, but it is not copied", textLayoutFormat2.textIndent == 15);
		}

		/* ************************************************************** */
		/* concat Method*/
		/* ************************************************************** */
		public function concatenateTextFormat():void
		{
			//create textLayoutFormat1 and  assign format attributes value
			var textLayoutFormat1:TextLayoutFormat = new TextLayoutFormat;

			textLayoutFormat1.fontSize = 14;
			textLayoutFormat1.color = 0x336633;

			//create textLayoutFormat2 and assign format attributes value
			var textLayoutFormat2:TextLayoutFormat = new TextLayoutFormat;

			textLayoutFormat2.fontSize = 18;
			textLayoutFormat2.color = 0x0000cc;
			textLayoutFormat2.textIndent = 24;
			textLayoutFormat2.fontFamily = "Arial, Helvetica, _sans";

			//concatenate the value of properties in textLayoutFormat2 (incoming) with the value of textLayoutFormat1 (receiving).
			textLayoutFormat1.concat(textLayoutFormat2);

			//velidate
			assertTrue("Font size of textLayoutFormat1 should not concatenate.", textLayoutFormat1.fontSize != 18);
			assertTrue("Font size of textLayoutFormat1 should remain,", textLayoutFormat1.fontSize == 14);
			assertTrue("Font color of textLayoutFormat1 should not concatenate.", textLayoutFormat1.color != 0x0000cc);
			assertTrue("Font color of textLayoutFormat1 should remain,", textLayoutFormat1.color == 0x336633);
			assertTrue("Text Indent of textLayoutFormat1 should concatenate,", textLayoutFormat1.textIndent == 24);
			assertTrue("Font family of textLayoutFormat1 sould concatenate.", textLayoutFormat1.fontFamily == "Arial, Helvetica, _sans");

		}
		/* ************************************************************** */
		/* concatenateInheritOnly Method*/
		/* ************************************************************** */

		public function concatinateInheritOnly():void
		{

		//create two textLayoutFormat
		var textLayoutFormat1:TextLayoutFormat = new TextLayoutFormat();
		var textLayoutFormat2:TextLayoutFormat = new TextLayoutFormat();

		//set format attributes on textLayoutFormat1
		textLayoutFormat1.color = 0x336633;
		textLayoutFormat1.backgroundAlpha = 1;

		//set format attributes on textLayoutFormat2
		textLayoutFormat2.color = 0x3366ff;
		textLayoutFormat2.fontSize = 18;
		textLayoutFormat2.backgroundAlpha = 0.5;
		textLayoutFormat2.backgroundColor = 0x2200ff;


		//concatenate textLayotFormat2 settings
		textLayoutFormat1.concatInheritOnly(textLayoutFormat2);

		//velidate
		assertTrue("Text color should remain", textLayoutFormat1.color == 0x336633);
		assertTrue("Text color should remain", textLayoutFormat1.color != 0x3366ff);
		assertTrue("Font size is not inherited even it is inheritable", textLayoutFormat1.fontSize == 18);
		assertTrue("Background color is inherited even it is non-inheritable", textLayoutFormat1.backgroundColor !=0x2200ff);
		assertTrue("Background Alpha should remain", textLayoutFormat1.backgroundAlpha == 1);
		assertTrue("Background Alpha is inherited even it is non-inhertable", textLayoutFormat1.backgroundAlpha != 0.5);
		}

		/* ************************************************************** */
		/* removeClashing Method*/
		/* ************************************************************** */

		public function removeClashing():void
		{

		//create textLayoutFormat1 and set property values
		var textLayoutFormat1:TextLayoutFormat = new TextLayoutFormat();
		textLayoutFormat1.color = 0x336633;
		textLayoutFormat1.backgroundAlpha = 1;
		textLayoutFormat1.setStyle("Foo","bar");
		textLayoutFormat1.setStyle("Foo1","bar1");
		textLayoutFormat1.setStyle("Foo2","bar2");

		//create textLayoutFormat2 and set property values
		var textLayoutFormat2:TextLayoutFormat = new TextLayoutFormat();
		textLayoutFormat2.color = 0x3366ff;
		textLayoutFormat2.fontSize = 18;
		textLayoutFormat2.backgroundAlpha = 0.5;
		textLayoutFormat2.backgroundColor = 0x2200ff;
		textLayoutFormat2.setStyle("Foo","bar");
		textLayoutFormat2.setStyle("Foo1","bar2");
		textLayoutFormat2.setStyle("Foo3","bar2");

		//apply removeClashing method
		textLayoutFormat1.removeClashing(textLayoutFormat2);

		//velidate
		assertTrue("Text color should be undefined, but actually is " + textLayoutFormat1.color,
			textLayoutFormat1.color == undefined);
		assertTrue("background alpha should be undefined, but actually is " + textLayoutFormat1.backgroundAlpha,
			textLayoutFormat1.backgroundAlpha == undefined);
		assertTrue("font size should be undefined, but actually is " + textLayoutFormat1.fontSize,
			textLayoutFormat1.fontSize == undefined);
		assertTrue("Background color should be undefined, but actually is " + textLayoutFormat1.backgroundColor,
			textLayoutFormat1.backgroundColor == undefined);
		assertTrue("alignmentBaseLine should be undefined, but actually is " + textLayoutFormat1.alignmentBaseline,
			textLayoutFormat1.alignmentBaseline == undefined);
		}

		/* ************************************************************** */
		/* removeMatchingMethod*/
		/* ************************************************************** */

		public function removeMatching():void
		{

		//create textLayoutFormat1 and set property values
		var textLayoutFormat1:TextLayoutFormat = new TextLayoutFormat();
		textLayoutFormat1.color = 0x3366ff;
		textLayoutFormat1.fontSize = 18;
		textLayoutFormat1.backgroundAlpha = 0.5;
		textLayoutFormat1.backgroundColor = 0x2200ff;
		textLayoutFormat1.setStyle("Foo","bar");
		textLayoutFormat1.setStyle("Foo1","bar1");
		textLayoutFormat1.setStyle("Foo2","bar2");

		//create textLayoutFormat2 and set property values
		var textLayoutFormat2:TextLayoutFormat = new TextLayoutFormat(textLayoutFormat1);
		textLayoutFormat2.setStyle("Foo","bar");
		textLayoutFormat2.setStyle("Foo1","bar2");
		textLayoutFormat2.setStyle("Foo3","bar2");

		//apply removeClashing method
		textLayoutFormat1.removeMatching(textLayoutFormat2);

		//velidate
		assertTrue("Text color should be undefined, but actually is " + textLayoutFormat1.color,
			textLayoutFormat1.color == undefined);
		assertTrue("font size should be undefined, but actually is " + textLayoutFormat1.fontSize,
			textLayoutFormat1.fontSize == undefined);
		assertTrue("background alpha should be undefined, but actually is " + textLayoutFormat1.backgroundAlpha,
			textLayoutFormat1.backgroundAlpha == undefined);
		assertTrue("Background color should be undefined, but actually is " + textLayoutFormat1.backgroundColor,
			textLayoutFormat1.backgroundColor == undefined);
		assertTrue("alignmentBaseLine should be undefined, but actually is " + textLayoutFormat1.alignmentBaseline,
			textLayoutFormat1.alignmentBaseline == undefined);
		}

		// test for Watson 2758274
		public function getCommonCharacterFormatAtPoint():void
		{
			var markup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' >" + 
				"<flow:p><flow:span fontSize='40' breakOpportunity='any'>A</flow:span><flow:span fontSize='20' breakOpportunity='all'>B</flow:span></flow:p>" + 
				"</flow:TextFlow>";

			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			var s:Sprite = new Sprite();
			textFlow.flowComposer.addController(new ContainerController(s));
			textFlow.flowComposer.updateAllControllers();
			textFlow.interactionManager = new SelectionManager();
			textFlow.interactionManager.selectRange(1, 1);
			var format:ITextLayoutFormat = textFlow.interactionManager.getCommonCharacterFormat();
			assertTrue("Expected format to show settings applied to character to left of current selection", format.fontSize == 40);
		}
		
		public function formatResolverTest():void
		{
			var simpleText:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
				+ "<p styleName='center' textAlign='right'>" +
					"<span>There are many </span>" +
					"<span styleName='italic'>such</span>" +
					"<span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.</span>" +
					"<span>The man who now watched the </span>" +
					"<span id='bold'>fire</span><span> was of a </span>" +
					"<span typeName='foo'>different</span>" +
					"<span> order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Within the furnace were seen the curling and riotous flames, and the burning marble, almost molten with the intensity of heat; while without, the reflection of the fire quivered on the dark intricacy of the surrounding forest, and showed in the foreground a bright and ruddy little picture of the hut, the spring beside its door, the athletic and coal-begrimed figure of the lime-burner, and the half-frightened child, shrinking into the protection of his father's shadow. And when again the iron door was closed, then reappeared the tender light of the half-full moon, which vainly strove to trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, though thus far down into the valley the sunshine had vanished long and long ago.</span>" +
					"</p>"
				+ "</TextFlow>";
			
			[Embed(source="../../SimpleCSS.css",mimeType="application/octet-stream")]
			var SimpleCSS : Class;
			
			var textFlow:TextFlow = TextConverter.importToFlow(simpleText, TextConverter.TEXT_LAYOUT_FORMAT);
			// wipe out the default inherits - format take precendence over CSS - this simplifies the example
			textFlow.format = null;
			
			// create a styleSheet - use the subclass with the transform override
			var styleSheet:StyleSheet = new TLFStyleSheet;
			
			// parse a styleSheet
			var cssByteArray:ByteArray = new SimpleCSS();
			var cssText:String = cssByteArray.readMultiByte(cssByteArray.length,"utf-8");
			styleSheet.parseCSS(cssText);
			
			// attach a format resolver
			textFlow.formatResolver = new CSSFormatResolver(styleSheet);
			
			// set it into the editor
			textFlow.flowComposer.addController(new ContainerController(new Sprite(),500,500));
			textFlow.flowComposer.updateAllControllers();
			var spans:Array = (textFlow.getChildAt(0) as ParagraphElement).mxmlChildren;
			var format:ITextLayoutFormat = (spans[0] as SpanElement).computedFormat;
			assertTrue("Format of the first span is incorrect after fetching styles from css file", format.fontSize == 18 && format.textIndent == 15);
			format = (spans[1] as SpanElement).computedFormat;
			assertTrue("Format of the second span is incorrect after fetching styles from css file", format.fontSize == 18 && format.textIndent == 15);
			format = (spans[5] as SpanElement).computedFormat;
			assertTrue("Format of the sixth span is incorrect after fetching styles from css file", format.fontSize == 20 && format.color == 0xff00 && format.textIndent == 15);
		
			// attach a format resolver
			textFlow.formatResolver = new CustomFormatResolver(styleSheet);
			textFlow.flowComposer.updateAllControllers();
			format = (spans[0] as SpanElement).computedFormat;
			assertTrue("Format of the first span is incorrect after fetching styles from css file", format.fontSize == 18 && format.textIndent == 15 && format.textAlign == TextAlign.CENTER);
			format = (spans[1] as SpanElement).computedFormat;
			assertTrue("Format of the second span is incorrect after fetching styles from css file", format.fontSize == 30 && format.textIndent == 15 && format.color == 0xff && format.fontStyle == FontPosture.ITALIC && format.textAlign == TextAlign.CENTER);
			format = (spans[3] as SpanElement).computedFormat;
			assertTrue("Format of the fourth span is incorrect after fetching styles from css file", format.fontSize == 18 && format.fontWeight == FontWeight.BOLD && format.textIndent == 15 && format.textAlign == TextAlign.CENTER);
			format = (spans[5] as SpanElement).computedFormat;
			assertTrue("Format of the sixth span is incorrect after fetching styles from css file", format.fontSize == 20 && format.color == 0xff00 && format.textIndent == 15 && format.textAlign == TextAlign.CENTER);
		}
	}	
}
import flash.text.StyleSheet;
import flash.text.TextFormat;

class TLFStyleSheet extends StyleSheet
{
	// override transform - skip making a TextFormat
	public override function transform(formatObject:Object):TextFormat
	{
		return null;
	}
}

