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

	import flash.text.engine.TabAlignment;
	import flash.text.engine.TextLine;
	import flash.geom.Rectangle;

	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TabStopFormat;
	import flashx.textLayout.formats.TextLayoutFormat;


	public class TabTest extends VellumTestCase
	{
		public function TabTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Tabs";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = TabTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}


 		/****************************************************
 		  Main codes strat here.
 		  Validate parsing of string-based tab stop formats
 		 ****************************************************/

   		/* ************************************************************** */
		/* Enter tab without specifying tab stop */
		/* ************************************************************** */

   		public function noTabStop():void
   		{
   		//change the text and recompose
   		SelManager.selectAll();
   		SelManager.deleteText();
   		SelManager.insertText("\tN");
   		TestFrame.flowComposer.updateAllControllers();

   		// get the first line
   		var initialLine:TextLine;
   		initialLine = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine(true);

   		//default single tab value
   		var tabValue:Number = 50;

		//get the position of the second character, "N"
   		var valueAfterTab:Number;
   		valueAfterTab = initialLine.getAtomBounds(1).left;

   		//Check the the correct value is in the tab
   		assertTrue("tab should be " + tabValue + " but is " + valueAfterTab, valueAfterTab == tabValue);
   		}

   		 // TabStops string parsing for "Start"
   		public function StartTabStopString():void
   		{
   			var p1:TextLayoutFormat = new TextLayoutFormat();
			p1.tabStops = "s300 S200 100";
   			SelManager.applyParagraphFormat(p1);

   			var p2:ITextLayoutFormat = SelManager.getCommonParagraphFormat();
   			assertTrue("Start tabStops could not be found", p2.tabStops != undefined);

   			//Validating the alignment type string for start
   			assertTrue("Not parsing tabStop string correctly for s300 (type)", p2.tabStops[2].alignment == TabAlignment.START);
   			assertTrue("Not parsing tabStop string correctly for S200 (type)", p2.tabStops[1].alignment == TabAlignment.START);
   			assertTrue("Not parsing tabStop string correctly for 100 (type)", p2.tabStops[0].alignment == TabAlignment.START);

   			//Validating the alignment position for each tabStop
   			assertTrue("Not parsing tabStop string correctly for s300 (position)", p2.tabStops[2].position == 300);
   			assertTrue("Not parsing tabStop string correctly for S200 (position)", p2.tabStops[1].position == 200);
   			assertTrue("Not parsing tabStop string correctly for 100 (position)", p2.tabStops[0].position == 100);
   		}


   		// TabStops string parsing for "Center"
   		public function CenterTabStopString():void
   		{
			var p3:TextLayoutFormat = new TextLayoutFormat();
			p3.tabStops = "c500 C400";
			SelManager.applyParagraphFormat(p3);

			var p4:ITextLayoutFormat = SelManager.getCommonParagraphFormat();
			assertTrue("Center tabStops could not be found", p4.tabStops != undefined);

			//Validating the alignment type string for center
			assertTrue("Not parsing tabStop string correctly for c500 (type)", p4.tabStops[1].alignment == TabAlignment.CENTER);
			assertTrue("Not parsing tabStop string correctly for C400 (type)", p4.tabStops[0].alignment == TabAlignment.CENTER);

			//Validating the alignment position for each tabStop
			assertTrue("Not parsing tabStop string correctly for c500 (position)", p4.tabStops[1].position == 500);
   			assertTrue("Not parsing tabStop string correctly for C400 (position)", p4.tabStops[0].position == 400);
   		}

   		// TabStops string parsing for "End"
   		public function EndTabStopString():void
   		{
			var p5:TextLayoutFormat = new TextLayoutFormat();
			p5.tabStops = "e700 E600";
			SelManager.applyParagraphFormat(p5);

			var p6:ITextLayoutFormat = SelManager.getCommonParagraphFormat();
			assertTrue("End tabStops could not be found", p6.tabStops != undefined);

			//Validating the alignment type string for end
			assertTrue("Not parsing tabStop string correctly for e700 (type)", p6.tabStops[1].alignment == TabAlignment.END);
			assertTrue("Not parsing tabStop string correctly for E600 (type)", p6.tabStops[0].alignment == TabAlignment.END);

			//Validating the alignment position for each tabStop
			assertTrue("Not parsing tabStop string correctly for e700 (position)", p6.tabStops[1].position == 700);
   			assertTrue("Not parsing tabStop string correctly for E600 (position)", p6.tabStops[0].position == 600);
   		}

   		// TabStops string parsing for "Decimal"
   		public function DecimalTabStopString():void
   		{
			var p7:TextLayoutFormat = new TextLayoutFormat();
			p7.tabStops = "d900 D800";
			SelManager.applyParagraphFormat(p7);

			var p8:ITextLayoutFormat = SelManager.getCommonParagraphFormat();
			assertTrue("Decimal tabStops could not be found", p8.tabStops != undefined);

			//Validating the alignment type string for dicimal
			assertTrue("Not parsing tabStop string correctly for d900 (type)", p8.tabStops[1].alignment == TabAlignment.DECIMAL);
			assertTrue("Not parsing tabStop string correctly for D800 (type)", p8.tabStops[0].alignment == TabAlignment.DECIMAL);

			//Validating the alignment position for each tabStop
			assertTrue("Not parsing tabStop string correctly for d900 (position)", p8.tabStops[1].position == 900);
   			assertTrue("Not parsing tabStop string correctly for D800 (position)", p8.tabStops[0].position == 800);
   		}

   		//Same position tabStops
   		public function SamePositionTabStops():void
   		{
   			var p9:TextLayoutFormat = new TextLayoutFormat();
   			p9.tabStops = "250 c250";
   			SelManager.applyParagraphFormat(p9);

   			var p10:ITextLayoutFormat = SelManager.getCommonParagraphFormat();
			assertTrue("Same position tabStops could not be found", p10.tabStops != undefined);

			//Validating alignment type string for the same position tabStops
			assertTrue("Not parsing tabStop string correctly for 250 (type)", p10.tabStops[0].alignment == TabAlignment.START);
			assertTrue("Not parsing tabStop string correctly for c250 (type)", p10.tabStops[1].alignment == TabAlignment.CENTER);

			assertTrue("Not parsing tabStop string correctly for 250 (position)", p10.tabStops[0].position == 250);
			assertTrue("Not parsing tabStop string correctly for c250 (position)", p10.tabStops[1].position == 250);
   		}


   		public function UniqueNumberTabStops():void
   		{
   			//Decimal number
   			var p11:TextLayoutFormat = new TextLayoutFormat();
   			p11.tabStops = "100.345678";
   			SelManager.applyParagraphFormat(p11);

   			var p12:ITextLayoutFormat = SelManager.getCommonParagraphFormat();
			assertTrue("Long decimal number tabStops could not be found", p12.tabStops != undefined);

			assertTrue("Not parsing tabStop string correctly for 100.345678 (type)", p12.tabStops[0].alignment == TabAlignment.START);
   			assertTrue("Not parsing tabStop string correctly for 100.345678 (position)", p12.tabStops[0].position == 100.345678);

			//Number in scientific notation
			var p13:TextLayoutFormat = new TextLayoutFormat();
   			p13.tabStops = "150.567e-2";
   			SelManager.applyParagraphFormat(p13);

   			var p14:ITextLayoutFormat = SelManager.getCommonParagraphFormat();
			assertTrue("scientific notation tabStops could not be found", p14.tabStops != undefined);

			assertTrue("Not parsing tabStop string correctly for 150.567e-2 (type)", p14.tabStops[0].alignment == TabAlignment.START);
   			assertTrue("Not parsing tabStop string correctly for 150.567e-2 (position)", p14.tabStops[0].position == 150.567e-2);


   			//Very long tabStop string
   			var p15:TextLayoutFormat = new TextLayoutFormat();
   			p15.tabStops = "c34.789763333333";
   			SelManager.applyParagraphFormat(p15);

   			var p16:ITextLayoutFormat = SelManager.getCommonParagraphFormat();
			assertTrue("Long string tabStops could not be found", p16.tabStops != undefined);

   			assertTrue("Not parsing tabStop string correctly for c34.789763333333 (type)", p16.tabStops[0].alignment == TabAlignment.CENTER);
   			assertTrue("Not parsing tabStop string correctly for c34.789763333333 (position)", p16.tabStops[0].position == 34.789763333333);
   	    }


   		public function AlignmentToken():void
   		{
   			var p17:TextLayoutFormat = new TextLayoutFormat();
   			p17.tabStops = "d10|.  D20|\\\\  d30  D40|*  d50|\\ ";
   			SelManager.applyParagraphFormat(p17);

   			var p18:ITextLayoutFormat = SelManager.getCommonParagraphFormat();
			assertTrue("Alignment token tabStops could not be found", p18.tabStops != undefined);

			//Validating alignment tokens
			assertTrue("Not parsing tabStop string correctly for d10|. (alignment token)", p18.tabStops[0].decimalAlignmentToken == ".");
			assertTrue("Not parsing tabStop string correctly for D20|\\\\  (alignment token)", p18.tabStops[1].decimalAlignmentToken == "\\");
			assertTrue("Not parsing tabStop string correctly for d30 (alignment token)", p18.tabStops[2].decimalAlignmentToken == ".");
			assertTrue("Not parsing tabStop string correctly for D40|* (alignment token)", p18.tabStops[3].decimalAlignmentToken == "*");
			assertTrue("Not parsing tabStop string correctly for d50|\\ (algnment token)", p18.tabStops[4].decimalAlignmentToken == " ");
   		}

   		/* ************************************************************** */
		/* copy() method */
		/* ************************************************************** */

		public function copyMethod():void
		{
			//Create DECIMAL tabStop (receiving)
			var tabStop1:TabStopFormat = new TabStopFormat();
			tabStop1.alignment = flash.text.engine.TabAlignment.DECIMAL;
			tabStop1.decimalAlignmentToken = undefined;
			tabStop1.position = 200;

			//create another tabStop (incoming)
			var tabStop2:TabStopFormat = new TabStopFormat();
			tabStop2.alignment = flash.text.engine.TabAlignment.START;
			tabStop2.decimalAlignmentToken = ".";
			tabStop2.position = undefined;

			//Copy tabStop properies to tabStop1
			tabStop1.copy(tabStop2);

			//All properties should be copied from tabStop2 including "undefined" position value.
			assertTrue("Tab stop alignment should be copied to " + flash.text.engine.TabAlignment.START,
			tabStop1.alignment == flash.text.engine.TabAlignment.START);
			assertTrue("Tab stop align token should be copied to " + tabStop2.decimalAlignmentToken,
			tabStop1.decimalAlignmentToken == ".");
			assertTrue("tabstop position should be copied to ", + tabStop2.position, tabStop1.position == undefined);
			}

		/* ************************************************************** */
		/* copy() method with null values initializes object
			with undefined value for all properties*/
		/* ************************************************************** */

		public function copyNullObject():void
		{
			//Create DECIMAL tabStop (receiving)
			var tabStop1:TabStopFormat = new TabStopFormat();
			tabStop1.alignment = flash.text.engine.TabAlignment.DECIMAL;
			tabStop1.decimalAlignmentToken = undefined;
			tabStop1.position = 200;

			//Copy null object to tabStop2 (explicit difference from apply methond)
			tabStop1.copy(null);

			//All properties should be copied from tabStop2 including "undefined" position value.
			assertTrue("Tab stop alignment should not remain as " + flash.text.engine.TabAlignment.DECIMAL + " but, actually is "
				 + tabStop1.alignment, tabStop1.alignment == undefined);
			assertTrue("Tab stop align token should remain as undefined but, actually is " + tabStop1.decimalAlignmentToken,
				tabStop1.decimalAlignmentToken == undefined);
			assertTrue("tabstop position should not remain as 200 but, actually is", + tabStop1.position, tabStop1.position == undefined);
			}

		/* ************************************************************** */
		/* concat() method */
		/* ************************************************************** */

		public function concatMethod():void
		{
			//Create tabstop with some properties set
			var tabStop1:TabStopFormat = new TabStopFormat();
			tabStop1.decimalAlignmentToken = ".";
			tabStop1.position = undefined;

			//Create another tabstop with all properties set
			var tabStop2:TabStopFormat = new TabStopFormat();
			tabStop2.alignment = flash.text.engine.TabAlignment.DECIMAL;
			tabStop2.decimalAlignmentToken = ",";
			tabStop2.position = 300;

			//Concatinate from incoming (no properties set) to receiving (all properties set)
			tabStop1.concat(tabStop2);

			//Alignment non-inheritable and becomes computed default value <START>
			assertTrue("Tab stop alignment should become START, but is actually " + tabStop1.alignment,
				tabStop1.alignment == flash.text.engine.TabAlignment.START);
			//decimal Alignment Token is set in both so it won't be concatieated
			assertTrue("Tab stop decimal alignnment token should not be " + tabStop2.decimalAlignmentToken + " and it should be " +
				tabStop1.decimalAlignmentToken, tabStop1.decimalAlignmentToken == ".");
			//position is non-heritable and becomes computed default value <0>
			assertTrue("Tab stop position should become 0, but is actually " + tabStop1.position, tabStop1.position == 0);
		}


		/* ************************************************************** */
		/* concatInheritOnly() method */
		/* ************************************************************** */

		public function concatInheritOnlyMethod():void
		{
			//create tabstop without setting propery value.
			var tabStop1:TabStopFormat = new TabStopFormat();
			tabStop1.decimalAlignmentToken = undefined;
			tabStop1.position = 300;

			//create tabstop with all property value set
			var tabStop2:TabStopFormat = new TabStopFormat();
			tabStop2.alignment = flash.text.engine.TabAlignment.DECIMAL;
			tabStop2.decimalAlignmentToken = ".";
			tabStop2.position = 200;

			//Concatinate inherit property only.  (alignment, decimalAlignToken and position are non-inheritable property)
			tabStop1.concatInheritOnly(tabStop2);

			//alignmen should be remained as default in tabStop1
			assertTrue("Tab stop alignment should not be concatenated to " + tabStop2.alignment + " but is actually " +
				flash.text.engine.TabAlignment.DECIMAL, tabStop1.alignment == undefined);
			//decimalAlignToken should be remained as undefined as default in tabStop1
			assertTrue("Tab stop alignment token should not be concatenated to " + tabStop2.decimalAlignmentToken + " but is actually " +
				tabStop2.decimalAlignmentToken, tabStop1.decimalAlignmentToken == undefined);
			//position is set as "300" in tabStop1 and it shold not be concatenated by tabStop2
			assertTrue("Tab stop position should not be concatenated to " + tabStop2.position + " but is actually " +
				tabStop2.position, tabStop1.position == 300);
		}

		/* ************************************************************** */
		/* apply()
		/* ************************************************************** */

		public function applyMethod():void
		{
			//Create tabStop1 (receiving)
			var tabStop1:TabStopFormat = new TabStopFormat();
			tabStop1.alignment = flash.text.engine.TabAlignment.DECIMAL;
			tabStop1.decimalAlignmentToken = undefined;
			tabStop1.position = 200;

			//create tabStop2 (incoming)
			var tabStop2:TabStopFormat = new TabStopFormat();
			tabStop2.alignment = flash.text.engine.TabAlignment.START;
			tabStop2.decimalAlignmentToken = ".";
			tabStop2.position = undefined;

			//Apply tabStop properies to tabStop1
			tabStop1.apply(tabStop2);

			//All properties should be applied from tabStop2 excluding undefined value.
			assertTrue("tabstop1 alignment should be " + tabStop2.alignment + " but, actually is " + tabStop1.alignment,
				tabStop1.alignment == flash.text.engine.TabAlignment.START);
			assertTrue("decimalaligntopen should be " + tabStop2.decimalAlignmentToken + " but, actually is " + tabStop1.decimalAlignmentToken,
				tabStop1.decimalAlignmentToken == ".");
			//"undefined" value should not be applied
			assertTrue("tabstop1 position should be 200 " + "but, actually is " + tabStop2.position,
			tabStop1.position == 200);
		}

		/* ************************************************************** */
		/* isEqual() method  (two objects are identical)*/
		/* ************************************************************** */

		public function twoSameObjects():void
		{
			//create tabStop1 object
			var tabStop1:TabStopFormat = new TabStopFormat();
			tabStop1.alignment = flash.text.engine.TabAlignment.START;
			tabStop1.decimalAlignmentToken = ".";
			tabStop1.position = 200;

			//create identical object, tabStop2
			var tabStop2:TabStopFormat = new TabStopFormat(tabStop1);

			//compare two object
			TabStopFormat.isEqual(tabStop1,tabStop2);

			var result:Boolean = TabStopFormat.isEqual(tabStop1,tabStop2);

			//two objects should be identical based on the result
			assertTrue("two objects are same and the result should be " + result, result == true);
		}

		/* ************************************************************** */
		/* isEqual() method (two objects are not identical)*/
		/* ************************************************************** */

		public function twoDifferentObjects():void
		{
			//create tabStop1 object including undefined value
			var tabStop1:TabStopFormat = new TabStopFormat();
			tabStop1.alignment = flash.text.engine.TabAlignment.DECIMAL;
			tabStop1.decimalAlignmentToken = ".";
			tabStop1.position = undefined;

			//create identical object, tabStop2
			var tabStop2:TabStopFormat = new TabStopFormat();
			tabStop2.alignment = flash.text.engine.TabAlignment.END;
			tabStop2.decimalAlignmentToken = undefined;
			tabStop2.position = 300;

			//compare two object
			TabStopFormat.isEqual(tabStop1,tabStop2);

			var result:Boolean = TabStopFormat.isEqual(tabStop1,tabStop2);

			//two objects are not identical based on the result
			assertTrue("two objects are not identical and the result should be " + result, result == false);
		}

		/* ************************************************************** */
		/* removeClashing() method */
		/* ************************************************************** */
		// tabStop1 and tabStop2 has differnt property values
		public function removeClashing():void
		{
			//Create DECIMAL tabStop1 (receiving)
			var tabStop1:TabStopFormat = new TabStopFormat();
			tabStop1.alignment = flash.text.engine.TabAlignment.DECIMAL;
			tabStop1.decimalAlignmentToken = ",";
			tabStop1.position = 200;

			//create another tabStop (incoming) with different property values
			var tabStop2:TabStopFormat = new TabStopFormat();
			tabStop2.alignment = flash.text.engine.TabAlignment.START;
			tabStop2.decimalAlignmentToken = ".";
			tabStop2.position = 100;

			//run removeClashing method
			tabStop1.removeClashing(tabStop2);

			//Sets properties in tabStop1 to undefined if they do not match those in the tabStop2 (incoming).
			assertTrue("Tab stop alignment should be undefined, but actually is " + tabStop1.alignment,
			tabStop1.alignment == undefined);
			assertTrue("Tab stop align token should be undefined, but actually is " + tabStop1.decimalAlignmentToken,
			tabStop1.decimalAlignmentToken == undefined);
			assertTrue("tabstop position should be undefined, but actually is ", + tabStop1.position, tabStop1.position == undefined);
		}

		/* ************************************************************** */
		/* removeMatching() method */
		/* ************************************************************** */

		public function removeMatching():void
		{
			//Create DECIMAL tabStop1 (receiving)
			var tabStop1:TabStopFormat = new TabStopFormat();
			tabStop1.alignment = flash.text.engine.TabAlignment.DECIMAL;
			tabStop1.decimalAlignmentToken = ",";
			tabStop1.position = 200;

			//create another tabStop object (incoming) wtih same property values
			var tabStop2:TabStopFormat = new TabStopFormat();
			tabStop2.alignment = flash.text.engine.TabAlignment.DECIMAL;
			tabStop2.decimalAlignmentToken = ",";
			tabStop2.position = 200;

			//run removeMatching method
			tabStop1.removeMatching(tabStop2);

			//Sets properties in tabStop1 to undefined if they do not match those in the tabStop2 (incoming).
			assertTrue("Tab stop alignment should be undefined, but actually is " + tabStop1.alignment,
				tabStop1.alignment == undefined);
			assertTrue("Tab stop align token should be undefined, but actually is " + tabStop1.decimalAlignmentToken,
				tabStop1.decimalAlignmentToken == undefined);
			assertTrue("tab stop position should be undefined, but actually is ", + tabStop1.position,
				tabStop1.position == undefined);
			}

   	//wating for a bug fix : Bug # 2275363
   	/***
   		public function InvalidTabStopString():void
   		{
   			var p19:TextLayoutFormat = new TextLayoutFormat();
   			p19.tabStops = "k300";
   			SelManager.applyParagraphFormat(p19);

   			var p20:ITextLayoutFormat = SelManager.getCommonParagraphFormat();
			assertTrue("Parsing invalid tabStop string!", p20.tabStops == undefined);

   		}
   	***/
		//automate a end TAB bug test.  When End Tab has a long string value, it didn't display correctly. It is a Player bug.
		public function endTabLongStringTest():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("\tAAAAAAA\tBBBBBB");
			
			var tlf:TextLayoutFormat = new TextLayoutFormat();
			
			//the long string value is the correct test data.  Since this is a Player bug, we can't check in the correct test data until Player fixes the bug. 
			//Need to remove the comment to check in the correct test data once Player fixes the bug.
			tlf.tabStops = "e700 e269";
			//tlf.tabStops = "e700 e269.1499999999998";
			SelManager.applyParagraphFormat(tlf);
			TestFrame.flowComposer.updateAllControllers();
			
			var tl:TextLine = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine();
			//second end TAB start at position 8
			var bounds:Rectangle = tl.getAtomBounds(8);
			var W:Number = bounds.width;
			
			assertTrue("end TAB was not displayed when end Tab with long string value.", W != 0);
		}
		
		public function TabStopFormatTest():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("1\txxx\txxx\txxx\n2\tyyyyyy\tyyyyyy\tyyyyyy\n3\tzz\tzz\tzz");
			
			var format:TextLayoutFormat = new TextLayoutFormat();
			var tabStop1:TabStopFormat = new TabStopFormat();
			var tabStop2:TabStopFormat = new TabStopFormat();
			var tabStop3:TabStopFormat = new TabStopFormat();
			
			tabStop1.alignment = flash.text.engine.TabAlignment.START;
			var posSet:int = 300;
			tabStop1.setStyle("position", posSet);
			var posAfterGet:int = tabStop1.getStyle("position");
			assertTrue("position after getStyle doesn't match the position set", posSet == posAfterGet);
			
			tabStop2.alignment = flash.text.engine.TabAlignment.CENTER;
			tabStop2.position = 150;
			tabStop3.alignment = flash.text.engine.TabAlignment.END;
			tabStop3.position = 250;
			format.tabStops = new Array(tabStop1,tabStop2,tabStop3);
			SelManager.textFlow.hostFormat = format;
			SelManager.textFlow.flowComposer.updateAllControllers(); 
		}

	}
}


















