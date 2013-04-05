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
	
	import flashx.textLayout.TextLayoutVersion;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.FormatDescriptor;
	import flashx.textLayout.conversion.IHTMLImporter;
	import flashx.textLayout.conversion.ITextExporter;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.ITextLayoutImporter;
	import flashx.textLayout.conversion.PlainTextExporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.TextClipboard;
	import flashx.textLayout.edit.TextScrap;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

 	public class ImportAPITest extends VellumTestCase
	{
		public function ImportAPITest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super(methodName, testID, testConfig);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Import/Export";
		}

		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			// We only need one version of these tests
			if (testConfig.writingDirection[0] == BlockProgression.TB && testConfig.writingDirection[1] == Direction.LTR)
			{
				testConfig = testConfig.copyTestConfig();
				testConfig.containerType = "custom";

				ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "importMultipleTimes_TCAL", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "exportMultipleTimes_TCAL", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "importMultipleTimes_Plain", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "exportMultipleTimes_Plain", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "importNewlines_Plain", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "customExportSettings_Plain", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "roundTripLeadingSpace", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "testTabAndBreakMergingInSpanImport", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "testTextImportErrors", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "testHTMLImportErrors", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "testMarkupImportErrors", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "testMarkupImport", testConfig ) );
		   		ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "normalizeTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "testInvalidListStyleTypeErrors", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "imgSourceFilterFunction", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "versionCompatibilityPadding", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "testHTMLMarkup", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "testHTMLMarkupClassAndId", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "testHTMLMarkupCustomTag", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "addAndRemoveFormat", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "clipboardImporterTest", testConfig ) );
				ts.addTestDescriptor (new TestDescriptor (ImportAPITest, "clipboardExporterTest", testConfig ) );
			}
		}

		public function versionCompatibilityPadding():void
		{
			const markup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' fontSize='14' textIndent='15' paragraphSpaceAfter='15' paddingTop='4' paddingLeft='4'><flow:p fontSize='24' textAlign='center'><flow:span>Ethan Brand</flow:span></flow:p><flow:p><flow:span>There are many </flow:span><flow:span fontStyle='italic'>such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.</flow:span></flow:p><flow:p><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door,...</flow:span></flow:p></flow:TextFlow>";
			
			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);

			// Exporting should always get us a <TextFlow> with a version attribute set the current version
			var testVersionExistence:XML = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			assertTrue("Expected version attribute set to current version", testVersionExistence.@["version"] == TextLayoutVersion.getVersionString(TextLayoutVersion.CURRENT_VERSION));
			
			// Importing a 2.0 or later TextFlow should get padding anywhere it was applied
			const markup20WithPadding:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' version='2.0.0' paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:p paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:span>Ethan Brand</flow:span><flow:img paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'/></flow:p><flow:p paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:span>There are many </flow:span></flow:p></flow:TextFlow>";
			textFlow = TextConverter.importToFlow(markup20WithPadding, TextConverter.TEXT_LAYOUT_FORMAT);
			checkPaddingResults(textFlow, false /* expect padding kept */);

			// Importing a 1.0 with no version specified should get padding only on TextFlow
			const markup10WithPadding:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:p paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:span>Ethan Brand</flow:span><flow:img paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'/></flow:p><flow:p paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:span>There are many </flow:span></flow:p></flow:TextFlow>";
			textFlow = TextConverter.importToFlow(markup10WithPadding, TextConverter.TEXT_LAYOUT_FORMAT);
			checkPaddingResults(textFlow, true /* expect padding removed */);

			// Same results if version is explicitly set to 1.0 or 1.1
			const markup10ExplicitWithPadding:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' version='1.0.0' paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:p paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:span>Ethan Brand</flow:span><flow:img paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'/></flow:p><flow:p paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:span>There are many </flow:span></flow:p></flow:TextFlow>";
			textFlow = TextConverter.importToFlow(markup10ExplicitWithPadding, TextConverter.TEXT_LAYOUT_FORMAT);
			checkPaddingResults(textFlow, true /* expect padding removed */);

			// Same results if version is explicitly set to 1.0 or 1.1
			const markup11ExplicitWithPadding:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' version='1.1.0' paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:p paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:span>Ethan Brand</flow:span><flow:img paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'/></flow:p><flow:p paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:span>There are many </flow:span></flow:p></flow:TextFlow>";
			textFlow = TextConverter.importToFlow(markup11ExplicitWithPadding, TextConverter.TEXT_LAYOUT_FORMAT);
			checkPaddingResults(textFlow, true /* expect padding removed */);

			// Should get an error for an unknown version
			const markup12ExplicitWithPadding:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' version='1.2.0' paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:p paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:span>Ethan Brand</flow:span><flow:img paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'/></flow:p><flow:p paddingTop='4' paddingLeft='4' paddingRight='2' paddingBottom='1'><flow:span>There are many </flow:span></flow:p></flow:TextFlow>";
			var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
			textImporter.importToFlow(markup12ExplicitWithPadding);
			assertTrue("Expected unsupported import error",textImporter.errors != null);
		}
		
		private function checkPaddingResults(textFlow:TextFlow, expectRemoved:Boolean):void
		{
			var firstPara:ParagraphElement = textFlow.getFirstLeaf().getParagraph();
			var lastPara:ParagraphElement = textFlow.getLastLeaf().getParagraph();
			var img:InlineGraphicElement = firstPara.getFirstLeaf().getNextSibling() as InlineGraphicElement;
			
			assertTrue("Padding was not propagated to TextFlow", textFlow.format.paddingTop == 4 && textFlow.format.paddingLeft == 4 && textFlow.format.paddingRight == 2 && textFlow.format.paddingBottom == 1);
			
			if (expectRemoved)
			{
				assertTrue("Padding was not removed from first paragraph", firstPara.paddingTop === undefined && firstPara.paddingLeft === undefined && firstPara.paddingRight === undefined && firstPara.paddingBottom === undefined);
				assertTrue("Padding was not removed from last paragraph", lastPara.paddingTop === undefined && lastPara.paddingLeft === undefined && lastPara.paddingRight  === undefined && lastPara.paddingBottom === undefined);
				assertTrue("Padding was not removed from img", img.paddingTop  === undefined && img.paddingLeft  === undefined && img.paddingRight === undefined && img.paddingBottom  === undefined);
			}
			else
			{
				assertTrue("Padding was not propagated to first paragraph", firstPara.format.paddingTop == 4 && firstPara.format.paddingLeft == 4 && firstPara.format.paddingRight == 2 && firstPara.format.paddingBottom == 1);
				assertTrue("Padding was not propagated to last paragraph", lastPara.format.paddingTop == 4 && lastPara.format.paddingLeft == 4 && lastPara.format.paddingRight == 2 && lastPara.format.paddingBottom == 1);
				assertTrue("Padding was not propagated to img", img.format.paddingTop == 4 && img.format.paddingLeft == 4 && img.format.paddingRight == 2 && img.format.paddingBottom == 1);
			}
		}
		
		public function roundTripLeadingSpace():void
		{
			const markup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' fontSize='14' textIndent='15' paragraphSpaceAfter='15' paddingTop='4' paddingLeft='4'><flow:p fontSize='24' textAlign='center'><flow:span>Ethan Brand</flow:span></flow:p><flow:p><flow:span>There are many </flow:span><flow:span fontStyle='italic'>such</flow:span><flow:span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.</flow:span></flow:p><flow:p><flow:span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door,...</flow:span></flow:p></flow:TextFlow>";

			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			var markupAfterFirstExport:String = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			textFlow = TextConverter.importToFlow(markupAfterFirstExport, TextConverter.TEXT_LAYOUT_FORMAT);

			var secondPara:ParagraphElement = textFlow.getChildAt(1) as ParagraphElement;
			var firstSpan:SpanElement = secondPara.getChildAt(0) as SpanElement;
			assertTrue("Expected trailing space", firstSpan.text.charCodeAt(firstSpan.text.length - 1) == 32);
			var markupAfterSecondExport:String = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			assertTrue("Roundtrip not matching", markupAfterFirstExport == markupAfterSecondExport);
		}

		public function importMultipleTimes_TCAL():void
		{
			const markup1:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008'><flow:p><flow:span>Hello</flow:span></flow:p></flow:TextFlow>";
			const markup2:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008'><flow:p><flow:span>Goodbye</flow:span></flow:p></flow:TextFlow>";

			importMultipleTimes(TextConverter.TEXT_LAYOUT_FORMAT, markup1, markup2);
		}

		public function exportMultipleTimes_TCAL():void
		{
			const markup1:String = "<flow:TextFlow  xmlns:flow='http://ns.adobe.com/textLayout/2008'><flow:p><flow:span>Hello</flow:span></flow:p></flow:TextFlow>";
			const markup2:String = "<flow:TextFlow  xmlns:flow='http://ns.adobe.com/textLayout/2008'><flow:p><flow:span>Goodbye</flow:span></flow:p></flow:TextFlow>";

			exportMultipleTimes(TextConverter.TEXT_LAYOUT_FORMAT, markup1, markup2);
		}

		public function importMultipleTimes_Plain():void
		{
			const markup1:String = "Hello";
			const markup2:String = "Goodbye";

			importMultipleTimes(TextConverter.PLAIN_TEXT_FORMAT, markup1, markup2);
		}

		public function exportMultipleTimes_Plain():void
		{
			const markup1:String = "Hello";
			const markup2:String = "Goodbye";

			exportMultipleTimes(TextConverter.PLAIN_TEXT_FORMAT, markup1, markup2);
		}

		public function importNewlines_Plain():void
		{
			const markup:String = "0\r1\n2\r\n3";
			var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT);
			var textFlow:TextFlow = textImporter.importToFlow(markup);

			var para:ParagraphElement = textFlow.getFirstLeaf().getParagraph();
			var i:int = 0;
			while (para != null)
			{
				var paraText:String = para.getText();
				assertTrue("Not all allowed newline indicators recognized as such", int(paraText) == i);
				para = para.getNextParagraph();
				i++;
			}
			assertTrue("Not all allowed newline indicators recognized as such", i == 4);
		}

		public function customExportSettings_Plain():void
		{
			var markup:String = "dis" + "\u00AD" + "cre" + "\u00AD" + "tion" + "\u00AD" + "a" + "\u00AD" + "ry";
			var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT);
			var textFlow:TextFlow = textImporter.importToFlow(markup);

			var exporter:PlainTextExporter = new PlainTextExporter();
			assertTrue("Discretionary hyphens not stripped by default", exporter.export(textFlow, ConversionType.STRING_TYPE) == "discretionary");

			exporter.stripDiscretionaryHyphens = false;
			assertTrue("Discretionary hyphens stripped even when stripDiscretionaryHyphens is false", exporter.export(textFlow, ConversionType.STRING_TYPE) == markup);

			markup = "0\r1";
			textFlow = textImporter.importToFlow(markup);

			assertTrue("Plain text exporter does not use default para separator as expected", exporter.export(textFlow, ConversionType.STRING_TYPE) == "0\n1");

			exporter.paragraphSeparator = "\r";
			assertTrue("Plain text export does not honor custom para separator as expected", exporter.export(textFlow, ConversionType.STRING_TYPE) == "0\r1")
		}

		private function importMultipleTimes(format:String, markup1:String, markup2:String):void
		{
			var textFlow:TextFlow;
			var textImporter:ITextImporter = TextConverter.getImporter(format);
			textFlow = textImporter.importToFlow(markup1);
			assertTrue("Expected string 'Hello'", SpanElement(textFlow.getFirstLeaf()).text == 'Hello');
			assertTrue("Expected no errors import",textImporter.errors == null);
			textFlow = textImporter.importToFlow(markup2);
			assertTrue("Expected string 'Hello'", SpanElement(textFlow.getFirstLeaf()).text == 'Goodbye');
			assertTrue("Expected no errors import",textImporter.errors == null);
		}

		private function exportMultipleTimes(format:String, markup1:String, markup2:String):void
		{
			var textImporter:ITextImporter = TextConverter.getImporter(format);
			var textExporter:ITextExporter = TextConverter.getExporter(format);
			importAndExport(markup1, textImporter, textExporter);
			importAndExport(markup2, textImporter, textExporter);
		}

		private function importAndExport(markup:String, textImporter:ITextImporter, textExporter:ITextExporter):void
		{
			// Import, export, re-import, and compare result
			var textFlow:TextFlow = textImporter.importToFlow(markup);
			var textBefore:String = SpanElement(textFlow.getFirstLeaf()).text;
			var markupResult:String = textExporter.export(textFlow, ConversionType.STRING_TYPE) as String;
			textFlow = textImporter.importToFlow(markupResult);
			assertTrue("Export from TextFlow doesn't match import", textBefore == SpanElement(textFlow.getFirstLeaf()).text);
			assertTrue("Expected no errors import",textImporter.errors == null);
		}

		public function testTabAndBreakMergingInSpanImport():void
		{
			var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
			var textFlow:TextFlow;

			const markup1:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><p><span fontSize='24'>Hello<tab/>World<br/>Goodbye</span></p></TextFlow>";
			textFlow = textImporter.importToFlow(markup1);
			// should all be merged into a single leaf
			assertTrue("Import of tab/break does not merge properly", textFlow.getFirstLeaf() == textFlow.getLastLeaf());
			assertTrue("Expected no errors import",textImporter.errors == null);

			const markup2:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><p><span fontSize='24'><tab/>Hello World<br/></span></p></TextFlow>";
			textFlow = textImporter.importToFlow(markup2);
			// should all be merged into a single leaf
			assertTrue("Import of tab/break does not merge properly", textFlow.getFirstLeaf() == textFlow.getLastLeaf());
			assertTrue("Expected no errors import",textImporter.errors == null);
		}

		public function testTextImportErrors():void
		{
			var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
			var textFlow:TextFlow;

			// no namespace specififed - an error
			const markup1:String = "<TextFlow><p><span>No namespace - must fail</span></p></TextFlow>";
			textFlow = textImporter.importToFlow(markup1);
			assertTrue("Expected one error on import and no TextFlow",textImporter.errors != null && textImporter.errors.length ==1 && textFlow == null);

			// wrong namespace specififed - an error
			const markup2:String = "<TextFlow xmlns='http://not.ns.adobe.com/textLayout/2008'><p><span>Bad namespace - must fail</span></p></TextFlow>";
			textFlow = textImporter.importToFlow(markup2);
			assertTrue("Expected one error on import and no TextFlow",textImporter.errors != null && textImporter.errors.length ==1 && textFlow == null);

			// bad element - an error
			const markup3:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><xyz/></TextFlow>";
			textFlow = textImporter.importToFlow(markup3);
			assertTrue("Expected one error on import and no TextFlow",textImporter.errors != null && textImporter.errors.length == 1);

			// bad element in span
			const markup4:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><p><span>Hello<p/>World</span></p></TextFlow>";
			textFlow = textImporter.importToFlow(markup4);
			assertTrue("Expected one error on import and no TextFlow",textImporter.errors != null && textImporter.errors.length == 1);

		}

		public function testHTMLImportErrors():void
		{
			var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
			var textFlow:TextFlow;

			// start and end modifier
			const markup3:String = '<p>Malformed tag next</p/>';
			textFlow = textImporter.importToFlow(markup3);
			assertTrue("Expected one error on import",textImporter.errors != null && textImporter.errors.length == 1);

			// attr on end tag
			const markup2:String = '<p>Malformed tag next</p align="left">';
			textFlow = textImporter.importToFlow(markup2);
			assertTrue("Expected one error on import ",textImporter.errors != null && textImporter.errors.length ==1);

			// bad text node
			const markup10:String = 'a < b + c'; // should be 'a &lt; b + c'
			textFlow = textImporter.importToFlow(markup10);
			assertTrue("Expected one error on import",textImporter.errors != null && textImporter.errors.length ==1);

			// invalid attribute value
			const markup11:String = '<p align="middle">blah</p>'; // should be "center"
			textFlow = textImporter.importToFlow(markup11);
			assertTrue("Expected one error on import",textImporter.errors != null && textImporter.errors.length ==1);


			// These cases do not apply to the TextFiled HTML dialect, which is what we
			// are supporting now.

			// forbidden end tag
			/*
			const markup1:String = '<br></br>';
			textFlow = textImporter.importToFlow(markup1);
			assertTrue("Expected one error on import and no TextFlow",textImporter.errors != null && textImporter.errors.length ==1 && textFlow == null);

			// missing end tag
			const markup4:String = '<font size="20">end tag is not optional for font element';
			textFlow = textImporter.importToFlow(markup4);
			assertTrue("Expected one error on import and no TextFlow",textImporter.errors != null && textImporter.errors.length == 1);

			// missing end tag
			const markup5:String = '<p><font size="20">end tag is not optional for font element</p>';
			textFlow = textImporter.importToFlow(markup5);
			assertTrue("Expected one error on import and no TextFlow",textImporter.errors != null && textImporter.errors.length == 1);

			// missing start tag
			const markup6:String = 'start tag is not optional for p element</p>';
			textFlow = textImporter.importToFlow(markup6);
			assertTrue("Expected one error on import and no TextFlow",textImporter.errors != null && textImporter.errors.length == 1);

			// unknown element
			const markup8:String = '<image height="19" width="19" src="surprised.png" align="right">';
			textFlow = textImporter.importToFlow(markup8);
			assertTrue("Expected one error on import and no TextFlow",textImporter.errors != null && textImporter.errors.length == 1);

			// unknown attribute
			const markup9:String = '<p textAlign="center">Wrong attr name</p>';
			textFlow = textImporter.importToFlow(markup9);
			assertTrue("Expected one error on import and no TextFlow",textImporter.errors != null && textImporter.errors.length == 1);

			*/
		}

		public function testMarkupImportErrors():void
		{
			const markup:String = "<TextFlow columnCount='inherit' columnGap='inherit' columnWidth='inherit' lineBreak='inherit' " +
			" paddingBottom='inherit' paddingLeft='inherit' paddingRight='inherit' paddingTop='inherit'" +
			" verticalAlign='inherit' whiteSpaceCollapse='preserve'" +
			" xmlns='http://ns.adobe.com/textLayout/2008'><p><a href='http://www.4literature.net/Nathaniel_Hawthorne/Ethan_Brand/' target='_self'>" +
			" <linkHoverFormat color='#ff0000'/>" +
			" <linkActiveFormat color='#00ff00' textDecoration='underline'/>" +
			" <linkNormalFormat color='#0000ff'/>" +
			" <span>Ethan Brand</span></a></p></TextFlow>";

			var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
			var textFlow:TextFlow;
			textFlow = textImporter.importToFlow(markup);
			assertTrue("Expected one error on import and no TextFlow",textImporter.errors[0] == "Expected one and only one TextLayoutFormat in http://ns.adobe.com/textLayout/2008::linkHoverFormat"
			           && textImporter.errors[1] == "Expected one and only one TextLayoutFormat in http://ns.adobe.com/textLayout/2008::linkActiveFormat"
			           && textImporter.errors[2] == "Expected one and only one TextLayoutFormat in http://ns.adobe.com/textLayout/2008::linkNormalFormat"
						);
		}

		public function testMarkupImport():void
		{
			const markup:String = "<TextFlow columnCount='inherit' columnGap='inherit' columnWidth='inherit' lineBreak='inherit' " +
			" paddingBottom='inherit' paddingLeft='inherit' paddingRight='inherit' paddingTop='inherit'" +
			" verticalAlign='inherit' whiteSpaceCollapse='preserve'" +
			" xmlns='http://ns.adobe.com/textLayout/2008'><p><a href='http://www.4literature.net/Nathaniel_Hawthorne/Ethan_Brand/' target='_self'>" +
			" <linkHoverFormat><TextLayoutFormat color='#ff0000'/></linkHoverFormat>" +
			" <linkActiveFormat><TextLayoutFormat color='#00ff00' textDecoration='underline'/></linkActiveFormat>" +
			" <linkNormalFormat><TextLayoutFormat color='#0000ff'/></linkNormalFormat>" +
			" <span>Ethan Brand</span></a></p></TextFlow>";

			var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
			var textFlow:TextFlow;
			textFlow = textImporter.importToFlow(markup);
			assertTrue("Import markup failed. Expected no errors on import", textImporter.errors == null);
		}

		public function normalizeTest():void
		{
			var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);

			var textFlow:TextFlow;
			var leaf:FlowLeafElement;

			const markup1:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><a><span></span></a><a></a></TextFlow>";
			textFlow = textImporter.importToFlow(markup1);
			leaf = textFlow.getFirstLeaf()
			// result is a single paragraph with a single empty span
			// assertTrue("Markup1 - expected paragraph with empty span",textFlow.textLength == 1 && leaf && leaf == textFlow.getLastLeaf() && leaf.parent == textFlow.getChildAt(0));

			const markup2:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><a/></TextFlow>";
			textFlow = textImporter.importToFlow(markup2);
			leaf = textFlow.getFirstLeaf()
			// result is a single paragraph with a single empty span
			assertTrue("Markup2 - expected paragraph with empty span",textFlow.textLength == 1 && leaf && leaf == textFlow.getLastLeaf() && leaf.parent == textFlow.getChildAt(0));

			const markup3:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><a/><span/></TextFlow>";
			textFlow = textImporter.importToFlow(markup3);
			leaf = textFlow.getFirstLeaf()
			// result is a single paragraph with a single empty span
			assertTrue("Markup2 - expected paragraph with empty span",textFlow.textLength == 1 && leaf && leaf == textFlow.getLastLeaf() && leaf.parent == textFlow.getChildAt(0));
		}
		
		public function testInvalidListStyleTypeErrors():void
		{
			var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
			var textFlow:TextFlow;
			
			// wrong listSytleTyle underline
			const markup1:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><list paddingRight='24' paddingLeft='24' listStyleType='underline'><li>underline item</li><li>another</li></list></TextFlow>";
			textFlow = textImporter.importToFlow(markup1);
			assertTrue("Expected out of range error",
				textImporter.errors[0] == "Property listStyleType value underline is out of range")
			
			// wrong listStyleTyle StrikThrough
			const markup2:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><list paddingRight='24' paddingLeft='24' listStyleType='Strikethrough'><li>Strikethrough item</li><li>another</li></list></TextFlow>";
			textFlow = textImporter.importToFlow(markup2);
			assertTrue("Expected out of range error",
				textImporter.errors[0] == "Property listStyleType value Strikethrough is out of range")
			
			// wrong listSytleTyle aaaa
			const markup3:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><list paddingRight='24' paddingLeft='24' listStyleType='aaaa'><li>aaaa item</li><li>another</li></list></TextFlow>";
			textFlow = textImporter.importToFlow(markup3);
			assertTrue("Expected out of range error",
				textImporter.errors[0] == "Property listStyleType value aaaa is out of range")
		}
		
		public function imgSourceFilterFunction():void
		{
			var textFlow:TextFlow;
			var elem:FlowLeafElement;
			var textImporter:ITextImporter;
			var replacedSource:String;
			
			// TEXT_LAYOUT_FORMAT
			replacedSource = "XYZ:";
			textImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
			(textImporter as ITextLayoutImporter).imageSourceResolveFunction = function (source:String):String { replacedSource += source; return replacedSource; };
			textFlow = textImporter.importToFlow("<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><img source='xyz.jpg'/></TextFlow>");
			assertTrue("TextLayoutFormat: Too many calls to imgSourceFilterFunction",replacedSource == "XYZ:xyz.jpg");
			elem = textFlow.getFirstLeaf();
			assertTrue("TextLayoutFormat: Incorrect source on first leaf",elem is InlineGraphicElement && (elem as InlineGraphicElement).source == "XYZ:xyz.jpg");
			
			// TEXT_FIELD_HTML_FORMAT
			replacedSource = "XYZ:";
			textImporter = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
			(textImporter as IHTMLImporter).imageSourceResolveFunction = function (source:String):String { replacedSource += source; return replacedSource; };
			textFlow = textImporter.importToFlow("<img src='xyz.jpg'/>");
			assertTrue("TextFieldHTMLFormat: Too many calls to imgSourceFilterFunction",replacedSource == "XYZ:xyz.jpg");
			elem = textFlow.getFirstLeaf();
			assertTrue("TextFieldHTMLFormat: Incorrect source on first leaf",elem is InlineGraphicElement && (elem as InlineGraphicElement).source == "XYZ:xyz.jpg");			
		}
		
		// helper function convert XML to a string without pretty printing
		static public function makeXMLIntoString(source:XML):String
		{
			var rslt:String;
			// turn off pretty printing when making the string
			var savedPretty:Boolean = XML.prettyPrinting;
			try
			{
				XML.prettyPrinting = false;
				rslt = source.toString();
			}
			finally
			{
				XML.prettyPrinting = savedPretty;
			}
			return rslt;
		}
		
		// helper function - imports and then checks an expected result
		static public function validateMarkup(importer:ITextImporter, testName:String,source:*,expectedResult:String,expectHtmlType:Boolean = false,expectBodyType:Boolean = false):void
		{
			var prefix:String;
			var postfix:String;
			if (expectHtmlType)
				prefix = '<TextFlow typeName="html" whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">';
			else
				prefix = '<TextFlow whiteSpaceCollapse="preserve" version="3.0.0" xmlns="http://ns.adobe.com/textLayout/2008">';
			
			if (expectBodyType)
			{
				prefix += '<div typeName="body">';
				postfix = '</div></TextFlow>'
			}
			else
				postfix = '</TextFlow>';
			
			expectedResult = prefix + expectedResult + postfix;
			
			var textFlow:TextFlow = importer.importToFlow(source);
			var rslt:String = TextConverter.export(textFlow,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			/*if (rslt != expectedResult)
			{
				trace(expectedResult);
				trace(rslt);
			}*/
			assertTrue(testName + ": failed",rslt == expectedResult);
		}
		
		static private const htmlTest1:XML = <HTML> 
		  <BODY> 
			<P ALIGN="left">
			  <FONT FACE="Arial" SIZE="12" COLOR="#AA0000" LETTERSPACING="0" KERNING="1"> 
				  <b><i>hello</i></b> 
				</FONT> 
			</P> 
		  </BODY> 
		</HTML>;
		
		static private const htmlTest2:XML = <HTML> 
		  <BODY> 
			<P ALIGN="left">
			  <FONT FACE="Arial" SIZE="12" COLOR="#AA0000" LETTERSPACING="0" KERNING="1"> 
				  <b><i></i></b> 
				</FONT> 
			</P> 
		  </BODY> 
		</HTML>;
		
		static private const htmlTest3:XML = <p><font><b/></font></p>;
		
		static private const htmlTest4a:XML = <p><b/></p>;
		static private const htmlTest4b:XML = <p>Some Text</p>;
		
		// as XML all the leading/trailing whitespace gets stripped.  Next two should produce indentical results
		static private const htmlTest5a:String = '<p><textformat leading="200%"><i><b>BoldItalic</b></i> </textformat>Plain <i>Italic</i> Plain <b>Bold</b></p>';
		static private const htmlTest5b:String = '<textformat leading="200%"><i><b>BoldItalic</b></i> </textformat>Plain <i>Italic</i> Plain <b>Bold</b>';
		
		// strikeThrough test
		static private const htmlTest6:String = '<p><s><i><b>StrikeThroughBoldItalic</b></i></b></s></p>';
		
		// naked listitem test
		static private const htmlTest7:String = '<li>abcd</li>';
		
		// tests that the group created by the parent of the tested span has the correct typename
		static private const htmlTest8:String = '<P ALIGN="left"><span class="xyz"><FONT FACE="Arial" SIZE="12" COLOR="#000000" LETTERSPACING="0" KERNING="1"><B>Hello</B> <I>World</I></FONT><span></P>'
		
		public function testHTMLMarkup():void
		{
			var importer:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
			
			validateMarkup(importer, "testHTMLMarkup:htmlTest1",htmlTest1,'<p color="#aa0000" fontFamily="Arial" fontSize="12" kerning="auto" textAlign="left" trackingRight="0"><span fontStyle="italic" fontWeight="bold">hello</span></p>');
			validateMarkup(importer, "testHTMLMarkup:htmlTest2",htmlTest2,'<p color="#aa0000" fontFamily="Arial" fontSize="12" kerning="auto" textAlign="left" trackingRight="0"><span fontStyle="italic" fontWeight="bold"></span></p>');
			validateMarkup(importer, "testHTMLMarkup:htmlTest3",htmlTest3,'<p><span fontWeight="bold"></span></p>');
			validateMarkup(importer, "testHTMLMarkup:htmlTest4a",htmlTest4a,'<p><span fontWeight="bold"></span></p>');
			validateMarkup(importer, "testHTMLMarkup:htmlTest4b",htmlTest4b,'<p><span>Some Text</span></p>');
			
			validateMarkup(importer, "testHTMLMarkup:htmlTest1.toString()",makeXMLIntoString(htmlTest1),'<p color="#aa0000" fontFamily="Arial" fontSize="12" kerning="auto" textAlign="left" trackingRight="0"><span fontStyle="italic" fontWeight="bold">hello</span></p>');
			validateMarkup(importer, "testHTMLMarkup:htmlTest2.toString()",makeXMLIntoString(htmlTest2),'<p color="#aa0000" fontFamily="Arial" fontSize="12" kerning="auto" textAlign="left" trackingRight="0"><span fontStyle="italic" fontWeight="bold"></span></p>');
			// validateMarkup(importer, "testHTMLMarkup:htmlTest3.toString()", makeXMLIntoString(htmlTest3),'<p><span fontWeight="bold"></span></p>');
			// validateMarkup(importer, "testHTMLMarkup:htmlTest4.toString()", makeXMLIntoString(htmlTest4),'<p><span fontWeight="bold"></span></p>');
			var test5Result:String = '<p leadingModel="approximateTextField" lineHeight="200%"><span fontStyle="italic" fontWeight="bold">BoldItalic</span><span> Plain </span><span fontStyle="italic">Italic</span><span> Plain </span><span fontWeight="bold">Bold</span></p>';
			validateMarkup(importer, "testHTMLMarkup:htmlTest5a", htmlTest5a, test5Result);
			validateMarkup(importer, "testHTMLMarkup:htmlTest5b", htmlTest5b, test5Result);
			validateMarkup(importer, "testHTMLMarkup:htmlTest6",htmlTest6,'<p><span fontStyle="italic" fontWeight="bold" lineThrough="true">StrikeThroughBoldItalic</span></p>');
			validateMarkup(importer, "testHTMLMarkup:htmlTest7",htmlTest7,'<list listStyleType="disc" paddingLeft="36"><listMarkerFormat><ListMarkerFormat paragraphEndIndent="14"/></listMarkerFormat><li><p><span>abcd</span></p></li></list>');
			validateMarkup(importer, "testHTMLMarkup:htmlTest8",htmlTest8,'<p textAlign="left"><g styleName="xyz" typeName="span"><span color="#000000" fontFamily="Arial" fontSize="12" fontWeight="bold" kerning="auto" trackingRight="0">Hello</span><span color="#000000" fontFamily="Arial" fontSize="12" kerning="auto" trackingRight="0"> </span><span color="#000000" fontFamily="Arial" fontSize="12" fontStyle="italic" kerning="auto" trackingRight="0">World</span></g></p>');
			
			// enable body/html tags
			(importer as IHTMLImporter).preserveHTMLElement = true;
			(importer as IHTMLImporter).preserveBodyElement = true;
			
			validateMarkup(importer, "testHTMLMarkup:htmlTest1",htmlTest1,'<p color="#aa0000" fontFamily="Arial" fontSize="12" kerning="auto" textAlign="left" trackingRight="0"><span fontStyle="italic" fontWeight="bold">hello</span></p>',true, true);
			validateMarkup(importer, "testHTMLMarkup:htmlTest2",htmlTest2,'<p color="#aa0000" fontFamily="Arial" fontSize="12" kerning="auto" textAlign="left" trackingRight="0"><span fontStyle="italic" fontWeight="bold"></span></p>',true, true);
			validateMarkup(importer, "testHTMLMarkup:htmlTest1.toString()",makeXMLIntoString(htmlTest1),'<p color="#aa0000" fontFamily="Arial" fontSize="12" kerning="auto" textAlign="left" trackingRight="0"><span fontStyle="italic" fontWeight="bold">hello</span></p>',true, true);
			validateMarkup(importer, "testHTMLMarkup:htmlTest2.toString()",makeXMLIntoString(htmlTest2),'<p color="#aa0000" fontFamily="Arial" fontSize="12" kerning="auto" textAlign="left" trackingRight="0"><span fontStyle="italic" fontWeight="bold"></span></p>',true, true);

		}
		
		static private const htmlCIDTest1:String = '<span id="x1">abcd</span>';
		static private const htmlCIDTest2:String = '<span id="x1"><span>abcd</span><b>XYZ</b></span>';
		static private const htmlCIDTest3:String = '<span><span>abcd</span><b>XYZ</b></span>';
			
		static private const htmlCIDTest4:String = '<i><span id="x1"><span>abcd</span><b>XYZ</b></span></i>';
		static private const htmlCIDTest5:String = '<i><span><span>abcd</span><b>XYZ</b></span></i>';
	
		static private const htmlCIDTest6:String = '<span class="x1"><span>abcd</span><b>XYZ</b></span>';
		static private const htmlCIDTest7:String = '<span><span>abcd</span><b>XYZ</b></span>';
			
		static private const htmlCIDTest8:String = '<i><span class="x1"><span>abcd</span><b>XYZ</b></span></i>';
		static private const htmlCIDTest9:String = '<i><span><span>abcd</span><b>XYZ</b></span></i>';
		
		static private const htmlCIDTest10:String = '<ul id="ulid"><li id="liid"><p id="pid">noid<span id="spanid">spanid</span><img id="imgid"/></p></li></ul><ol id="olid">olid</ol>';
		static private const htmlCIDTest11:String = '<ul class="ulid"><li class="liclass"><p class="pclass">noclass<span class="spanclass">spanclass</span><img class="imgclass"/></p></li></ul><ol class="olclass">olclass</ol>';

		
		public function testHTMLMarkupClassAndId():void
		{
			var importer:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
			validateMarkup(importer, "testHTMLMarkupClassAndId:htmlCIDTest1",htmlCIDTest1,'<p><span id="x1">abcd</span></p>');
			validateMarkup(importer, "testHTMLMarkupClassAndId:htmlCIDTest2",htmlCIDTest2,'<p><g id="x1" typeName="span"><span>abcd</span><span fontWeight="bold">XYZ</span></g></p>');
			validateMarkup(importer, "testHTMLMarkupClassAndId:htmlCIDTest3",htmlCIDTest3,'<p><span>abcd</span><span fontWeight="bold">XYZ</span></p>');
			validateMarkup(importer, "testHTMLMarkupClassAndId:htmlCIDTest4",htmlCIDTest4,'<p><g fontStyle="italic" id="x1" typeName="span"><span>abcd</span><span fontWeight="bold">XYZ</span></g></p>');
			validateMarkup(importer, "testHTMLMarkupClassAndId:htmlCIDTest5",htmlCIDTest5,'<p><g fontStyle="italic" typeName="span"><span>abcd</span><span fontWeight="bold">XYZ</span></g></p>');
			validateMarkup(importer, "testHTMLMarkupClassAndId:htmlCIDTest6",htmlCIDTest6,'<p><g styleName="x1" typeName="span"><span>abcd</span><span fontWeight="bold">XYZ</span></g></p>');
			validateMarkup(importer, "testHTMLMarkupClassAndId:htmlCIDTest7",htmlCIDTest7,'<p><span>abcd</span><span fontWeight="bold">XYZ</span></p>');
			validateMarkup(importer, "testHTMLMarkupClassAndId:htmlCIDTest8",htmlCIDTest8,'<p><g fontStyle="italic" styleName="x1" typeName="span"><span>abcd</span><span fontWeight="bold">XYZ</span></g></p>');
			validateMarkup(importer, "testHTMLMarkupClassAndId:htmlCIDTest9",htmlCIDTest9,'<p><g fontStyle="italic" typeName="span"><span>abcd</span><span fontWeight="bold">XYZ</span></g></p>');
			validateMarkup(importer, "testHTMLMarkupClassAndId:htmlCIDTest10",htmlCIDTest10,'<list listStyleType="disc" paddingLeft="36" id="ulid"><listMarkerFormat><ListMarkerFormat paragraphEndIndent="14"/></listMarkerFormat><li id="liid"><p id="pid"><span>noid</span><span id="spanid">spanid</span><img id="imgid"/><span></span></p></li></list><list listStyleType="decimal" paddingLeft="36" id="olid"><listMarkerFormat><ListMarkerFormat paragraphEndIndent="14"/></listMarkerFormat><p><span>olid</span></p></list>');
			validateMarkup(importer, "testHTMLMarkupClassAndId:htmlCIDTest11",htmlCIDTest11,'<list listStyleType="disc" paddingLeft="36" styleName="ulid"><listMarkerFormat><ListMarkerFormat paragraphEndIndent="14"/></listMarkerFormat><li styleName="liclass"><p styleName="pclass"><span>noclass</span><span styleName="spanclass">spanclass</span><img styleName="imgclass"/><span styleName="imgclass"></span></p></li></list><list listStyleType="decimal" paddingLeft="36" styleName="olclass"><listMarkerFormat><ListMarkerFormat paragraphEndIndent="14"/></listMarkerFormat><p><span>olclass</span></p></list>');
		}
		static private const customTag1:String = '<foo>ABCD</foo>';
		static private const customTag2:String = '<p><foo><a>ABCD</a></foo></p>';
		static private const customTag3:String = '<p><foo><span>ABCD</span><i> ITALIC</i></foo></p>';
		static private const customTag4:String = '<foo><div id="a">text</div></foo>';
		static private const customTag5:String = '<foo><div>text</div></foo>';
		static private const customTag6:String = '<foo><div>text</div><div>text</div></foo>';
		static private const customTag7:String = '<foo><bar>ABCD</bar></foo>';

		public function testHTMLMarkupCustomTag():void
		{
			var importer:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
			validateMarkup(importer, "testHTMLMarkupCustomTag:customTag1", customTag1, '<p typeName="foo"><span>ABCD</span></p>');
			validateMarkup(importer, "testHTMLMarkupCustomTag:customTag2", customTag2, '<p><a typeName="foo" target="_self"><span>ABCD</span></a></p>');
			validateMarkup(importer, "testHTMLMarkupCustomTag:customTag3", customTag3, '<p><g typeName="foo"><span>ABCD</span><span fontStyle="italic"> ITALIC</span></g></p>');
			validateMarkup(importer, "testHTMLMarkupCustomTag:customTag4", customTag4, '<div typeName="foo"><div id="a"><p><span>text</span></p></div></div>');
			validateMarkup(importer, "testHTMLMarkupCustomTag:customTag5", customTag5, '<div typeName="foo"><p><span>text</span></p></div>');
			validateMarkup(importer, "testHTMLMarkupCustomTag:customTag6", customTag6, '<div typeName="foo"><div><p><span>text</span></p></div><div><p><span>text</span></p></div></div>');
			validateMarkup(importer, "testHTMLMarkupCustomTag:customTag7", customTag7, '<div typeName="foo"><p typeName="bar"><span>ABCD</span></p></div>');
		}
		
		private static function isEqualDescriptor(descriptor1:FormatDescriptor, descriptor2:FormatDescriptor):Boolean
		{
			return descriptor1.format == descriptor2.format && descriptor1.importerClass == descriptor2.importerClass &&
				descriptor1.exporterClass == descriptor2.exporterClass && descriptor1.clipboardFormat == descriptor2.clipboardFormat;
		}
		
		public function addAndRemoveFormat():void
		{
			var i:int;
			
			var descriptor:FormatDescriptor;
			var protoDescriptor:FormatDescriptor = new FormatDescriptor("foo", MyImporter, MyExporter, "air:text");
			// Test simple addFormat, removeFormatAt
			var numFormats:int = TextConverter.numFormats;
			var descriptorArray:Array = [];
			for (i = 0; i < numFormats; ++i)
				descriptorArray.push(TextConverter.getFormatDescriptorAt(i));
			TextConverter.addFormat(protoDescriptor.format, protoDescriptor.importerClass, protoDescriptor.exporterClass, protoDescriptor.clipboardFormat);
			assertTrue("Expected format count to increase by one", TextConverter.numFormats == numFormats + 1);
			for (i = 0; i < numFormats; ++i)
			{
				descriptor = TextConverter.getFormatDescriptorAt(i);
				assertTrue(isEqualDescriptor(descriptor, descriptorArray[i]), "Expected previously existing descriptor to remain unchanged");
			}
			descriptor = TextConverter.getFormatDescriptorAt(TextConverter.numFormats - 1);
			assertTrue(isEqualDescriptor(descriptor, protoDescriptor), "New format doesn't have the correct parameters");
			TextConverter.removeFormatAt(numFormats);
			for (i = 0; i < numFormats; ++i)
			{
				descriptor = TextConverter.getFormatDescriptorAt(i);
				assertTrue(isEqualDescriptor(descriptor, descriptorArray[i]), "Expected previously existing descriptor to remain unchanged");
			}

			// Add at a specified position
			var position:int = 2;
			TextConverter.addFormatAt(position, protoDescriptor.format, protoDescriptor.importerClass, protoDescriptor.exporterClass, protoDescriptor.clipboardFormat);
			assertTrue("Expected format count to increase by one", TextConverter.numFormats == numFormats + 1);
			for (i = 0; i < TextConverter.numFormats; ++i)
			{
				descriptor = TextConverter.getFormatDescriptorAt(i);
				if (i == position)
					assertTrue(isEqualDescriptor(descriptor, protoDescriptor), "Expected previously new descriptor to match parameters to addFormat");
				else if (i < 2)
					assertTrue(isEqualDescriptor(descriptor, descriptorArray[i]), "Expected previously existing descriptor to remain unchanged");
				else 
					assertTrue(isEqualDescriptor(descriptor, descriptorArray[i - 1]), "Expected previously existing descriptor to remain unchanged");
			}
			
			// Add a duplicate
			var duplicateDescriptor:FormatDescriptor = new FormatDescriptor("foo", MyImporter, null, null);
			numFormats = TextConverter.numFormats;
			TextConverter.addFormatAt(0, duplicateDescriptor.format, duplicateDescriptor.importerClass, duplicateDescriptor.exporterClass, duplicateDescriptor.clipboardFormat);
			assertTrue("Expected format count to increase by one", TextConverter.numFormats == numFormats + 1);
			for (i = 0; i < TextConverter.numFormats; ++i)
			{
				descriptor = TextConverter.getFormatDescriptorAt(i);
				if (i == 0)
					assertTrue(isEqualDescriptor(descriptor, duplicateDescriptor), "Expected new dup descriptor to match parameters to addFormat");
				else if (i == position)
					assertTrue(isEqualDescriptor(descriptor, protoDescriptor), "Expected new descriptor to match parameters to addFormat");
				else if (i < position + 1)
					assertTrue(isEqualDescriptor(descriptor, descriptorArray[i - 1]), "Expected previously existing descriptor to remain unchanged");
				else 
					assertTrue(isEqualDescriptor(descriptor, descriptorArray[i - 2]), "Expected previously existing descriptor to remain unchanged");
			}
			var format:String = TextConverter.getFormatAt(position + 1);
			assertTrue("Lookup by index ignores dup", format == protoDescriptor.format);
			var importer:ITextImporter = TextConverter.getImporter(protoDescriptor.format);
			assertTrue("Should use first format found when dups exist", importer is duplicateDescriptor.importerClass);
			TextConverter.removeFormat(duplicateDescriptor.format);
			importer = TextConverter.getImporter(protoDescriptor.format);
			assertTrue("Should remove first format found when dups exist", importer is protoDescriptor.importerClass);
			TextConverter.removeFormatAt(position);
			for (i = 0; i < TextConverter.numFormats; ++i)
			{
				descriptor = TextConverter.getFormatDescriptorAt(i);
				assertTrue(isEqualDescriptor(descriptor, descriptorArray[i]), "Expected previously existing descriptor to remain unchanged");
			}
		}
		
		public function clipboardImporterTest():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.selectRange(0,0);
			var tf:TextFlow = SelManager.textFlow;
			tf.removeChildAt(0);			
			var para1:ParagraphElement = new ParagraphElement();
			var para2:ParagraphElement = new ParagraphElement();
			var span1:SpanElement = new SpanElement();
			var span2:SpanElement = new SpanElement();
			span1.text = "This is a test!";
			span2.text = "There are two paragraph.";
			span1.color = "#FF0000";
			span2.color = "#0000FF";
			para1.addChild(span1);
			para2.addChild(span2);
			tf.addChild(para1);
			tf.addChild(para2);
			
			TextConverter.addFormatAt(0, "VowelsOnly", VowelsOnlyImporter, PlainTextExporter, "air:text");
			TextConverter.addFormatAt(1, "NoVowels", NoVowelsImporter, PlainTextExporter, "air:text" );
			tf.flowComposer.updateAllControllers();
			var originalMarkup:String = TextConverter.export(tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			//trace(originalMarkup);
			SelManager.selectRange(16,40);
			var scrap:TextScrap = SelManager.cutTextScrap();
			var markupAfterCut:String = TextConverter.export(tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			//trace(markupAfterCut);
			assertTrue("Expected less text after cut", markupAfterCut != originalMarkup && markupAfterCut.length < originalMarkup.length);
			SelManager.selectRange(16,16);
			SelManager.pasteTextScrap(scrap);
			var markupAfterPaste:String = TextConverter.export(tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			//trace(markupAfterPaste);
			assertTrue("Expected paste to return to original state", markupAfterPaste == originalMarkup);
			
			SelManager.selectRange(16,40);
			scrap = SelManager.cutTextScrap();
			var clipboard:Object = new Object();
			TextClipboard.exportScrap(scrap, exportToClipboard);
			SelManager.selectRange(0,0);
			scrap = TextClipboard.importScrap(importFromClipboard);
			SelManager.pasteTextScrap(scrap);
			var markupAfterMangledPaste:String = TextConverter.export(tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			//trace(markupAfterMangledPaste);
			assertTrue("Expected paste to *not* to return to original state", markupAfterMangledPaste != originalMarkup);
			var expectedMarkup:String = "<TextFlow blockProgression=\"tb\" direction=\"ltr\" fontFamily=\"Times New Roman\" fontSize=\"14\" paddingLeft=\"4\" paddingTop=\"4\" textIndent=\"15\" whiteSpaceCollapse=\"preserve\" version=\"3.0.0\" xmlns=\"http://ns.adobe.com/textLayout/2008\">" 
				+"<p><span color=\"#ff0000\">Thr r tw prgrph.This is a test!</span></p>" 
				+"<p><span color=\"#0000ff\"></span></p>" 
				+"</TextFlow>";
			assertTrue("Markup after paste from clipboard with custom format doesn't matched expected result", markupAfterMangledPaste == expectedMarkup );
			
			function exportToClipboard(clipboardFormat:String, clipboardData:String):void
			{
				clipboard[clipboardFormat] = clipboardData;
			}
			function importFromClipboard(clipboardFormat:String):String
			{
				return clipboard.hasOwnProperty(clipboardFormat) ? clipboard[clipboardFormat] : null;
			}
		}
		
		public function clipboardExporterTest():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.selectRange(0,0);
			var tf:TextFlow = SelManager.textFlow;
			tf.removeChildAt(0);			
			var para1:ParagraphElement = new ParagraphElement();
			var para2:ParagraphElement = new ParagraphElement();
			var span1:SpanElement = new SpanElement();
			var span2:SpanElement = new SpanElement();
			span1.color = "#FF0000";
			span2.color = "#0000FF";
			span1.text = "This is a test!";
			span2.text = "There are two paragraph.";
			para1.addChild(span1);
			para2.addChild(span2);
			tf.addChild(para1);
			tf.addChild(para2);
			//format NewSeperator will be triggered
			TextConverter.addFormatAt(0, "NewSeperator", PlainTextImporter, NewSeperatorExporter, "air:text");
			TextConverter.addFormatAt(1, "AdditionalList", TLFImporter, AdditionalListExporter, "air:text" );
			tf.flowComposer.updateAllControllers();
			var originalMarkup:String = TextConverter.export(tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			//trace(originalMarkup);		
			SelManager.selectRange(0,40);
			var scrap:TextScrap = SelManager.cutTextScrap();
			var clipboard:Object = new Object();
			TextClipboard.exportScrap(scrap, exportToClipboard);
			SelManager.selectRange(0,0);
			scrap = TextClipboard.importScrap(importFromClipboard);
			SelManager.pasteTextScrap(scrap);
			var markupAfterMangledPaste:String = TextConverter.export(tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			//trace(markupAfterMangledPaste);
			var expectedMarkup:String = "<TextFlow blockProgression=\"tb\" direction=\"ltr\" fontFamily=\"Times New Roman\" fontSize=\"14\" paddingLeft=\"4\" paddingTop=\"4\" textIndent=\"15\" whiteSpaceCollapse=\"preserve\" version=\"3.0.0\" xmlns=\"http://ns.adobe.com/textLayout/2008\">"
				+ "<p><span color=\"#ff0000\">This is a test!</span></p>"
				+ "<p><span color=\"#ff0000\">new seperator</span></p>" 
				+ "<p><span color=\"#ff0000\">There are two paragraph.</span></p>" 
				+ "</TextFlow>";
			assertTrue("Markup after paste from clipboard with NewSeperator format doesn't matched expected result", markupAfterMangledPaste == expectedMarkup );
			
			//start a new case and get the original textflow
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.selectRange(0,0);
			tf = SelManager.textFlow;
			tf.removeChildAt(0);			
			para1.addChild(span1);
			para2.addChild(span2);
			tf.addChild(para1);
			tf.addChild(para2);
			//format PlainTextImporter will be triggered
			TextConverter.addFormatAt(0, "PlainTextImporter", TLFImporter, AdditionalListExporter, "air:text" );
			TextConverter.addFormatAt(1, "NewSeperator", PlainTextImporter, NewSeperatorExporter, "air:text");
			tf.flowComposer.updateAllControllers();
			originalMarkup = TextConverter.export(tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			//trace(originalMarkup);
			
			SelManager.selectRange(0,40);
			scrap = SelManager.cutTextScrap();
			clipboard = new Object();
			TextClipboard.exportScrap(scrap, exportToClipboard);
			SelManager.selectRange(0,0);
			scrap = TextClipboard.importScrap(importFromClipboard);
			SelManager.pasteTextScrap(scrap);
			markupAfterMangledPaste = TextConverter.export(tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
			//trace(markupAfterMangledPaste);
			expectedMarkup = "<TextFlow blockProgression=\"tb\" direction=\"ltr\" fontFamily=\"Times New Roman\" fontSize=\"14\" paddingLeft=\"4\" paddingTop=\"4\" textIndent=\"15\" whiteSpaceCollapse=\"preserve\" version=\"3.0.0\" xmlns=\"http://ns.adobe.com/textLayout/2008\">" 
				+"<p><span color=\"#ff0000\">This is a test!</span></p>"
				+"<p><span color=\"#0000ff\">There are two paragraph.</span>"
				+"</p><list><li><p><span>ab</span></p></li><li><p><span>cd</span></p></li></list>"
				+"<p><span color=\"#0000ff\"></span></p>"
				+"</TextFlow>";
			assertTrue("Markup after paste from clipboard with AdditionalList format doesn't matched expected result", markupAfterMangledPaste == expectedMarkup );
			function exportToClipboard(clipboardFormat:String, clipboardData:String):void
			{
				clipboard[clipboardFormat] = clipboardData;
			}
			function importFromClipboard(clipboardFormat:String):String
			{
				return clipboard.hasOwnProperty(clipboardFormat) ? clipboard[clipboardFormat] : null;
			}
		}
	}
}

import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.ConverterBase;
import flashx.textLayout.elements.IConfiguration;
import flashx.textLayout.elements.TextFlow;

class MyImporter extends ConverterBase implements ITextImporter
{	
	private var _config:IConfiguration;
	
	/** Constructor */
	public function MyImporter()
	{
		super();
	}
	
	public function importToFlow(source:Object):TextFlow
	{
		return null;
	}
	public function get configuration():IConfiguration
	{
		return _config;
	}
	
	public function set configuration(value:IConfiguration):void
	{
		_config = value;
	}
}


import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.ConverterBase;
import flashx.textLayout.elements.TextFlow;

class DupImporter extends MyImporter implements ITextImporter
{	
	/** Constructor */
	public function DupImporter()
	{
		super();
	}
}


import flashx.textLayout.conversion.ITextExporter;
import flashx.textLayout.conversion.ConverterBase;
import flashx.textLayout.elements.TextFlow;

class MyExporter extends ConverterBase implements ITextExporter
{	
	/** Constructor */
	public function MyExporter()
	{
		super();
	}
	
	public function export(source:TextFlow, conversionType:String):Object
	{
		return null;
	}
}

import flashx.textLayout.conversion.TextConverter;

class VowelsOnlyImporter extends ConverterBase implements ITextImporter
{
	protected var _config:IConfiguration = null;
	
	/** Constructor */
	public function VowelsOnlyImporter()
	{
		super();
	}
	
	public function importToFlow(source:Object):TextFlow
	{
		if (source is String)
		{
			var firstChar:String = (source as String).charAt(0);
			firstChar = firstChar.toLowerCase();
			// This filter only applies if the first character is a vowel
			if (firstChar == 'a' || firstChar == 'i' || firstChar == 'e' || firstChar == 'o' || firstChar == 'u')
			{
				var pattern:RegExp = /([b-df-hj-np-tv-z])*/g;
				source = source.replace(pattern, "");
				var importer:ITextImporter = TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT);
				importer.useClipboardAnnotations = this.useClipboardAnnotations;
				importer.configuration = _config;
				return importer.importToFlow(source);
			}
		}
		return null;
	}
	
	public function get configuration():IConfiguration
	{
		return _config;
	}
	
	public function set configuration(value:IConfiguration):void
	{
		_config = value;
	}
}

class NoVowelsImporter extends ConverterBase implements ITextImporter
{
	protected var _config:IConfiguration = null;
	
	/** Constructor */
	public function NoVowelsImporter()
	{
		super();
	}
	
	public function importToFlow(source:Object):TextFlow
	{
		if (source is String)
		{
			var firstChar:String = (source as String).charAt(0);
			firstChar = firstChar.toLowerCase();
			// This filter only applies if the first character is a vowel
			if (!(firstChar == 'a' || firstChar == 'i' || firstChar == 'e' || firstChar == 'o' || firstChar == 'u'))
			{
				var pattern:RegExp = /([aieouAIEOU])*/g;
				source = source.replace(pattern, "");
				var importer:ITextImporter = TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT);
				importer.useClipboardAnnotations = this.useClipboardAnnotations;
				importer.configuration = _config;
				return importer.importToFlow(source);
			}
		}
		return null;
	}
	
	public function get configuration():IConfiguration
	{
		return _config;
	}
	
	public function set configuration(value:IConfiguration):void
	{
		_config = value;
	}
}
import flashx.textLayout.conversion.PlainTextExporter;

class NewSeperatorExporter extends PlainTextExporter
{
	/** Constructor */
	public function NewSeperatorExporter()	
	{
		super();
		this.paragraphSeparator = "\nnew seperator\n";
	}
}

import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.ListElement;
import flashx.textLayout.elements.ListItemElement;

class AdditionalListExporter extends ConverterBase implements ITextExporter
{
	/** Constructor */
	public function AdditionalListExporter()	
	{
		super();
	}
	
	public function export(source:TextFlow, conversionType:String):Object
	{
		if (source is TextFlow)
		{
			source.getChildAt(source.numChildren - 1).setStyle(MERGE_TO_NEXT_ON_PASTE, false);
			
			var list:ListElement = new ListElement();
			var item1:ListItemElement = new ListItemElement();
			var item2:ListItemElement = new ListItemElement();
			var para1:ParagraphElement = new ParagraphElement();
			var para2:ParagraphElement = new ParagraphElement();
			var span1:SpanElement = new SpanElement();
			span1.text = "ab";
			var span2:SpanElement = new SpanElement();
			span2.text = "cd";
			list.addChild(item1);
			list.addChild(item2);
			item1.addChild(para1);
			para1.addChild(span1);
			item2.addChild(para2);
			para2.addChild(span2);
			source.addChild(list);
			
			var exporter:ITextExporter = TextConverter.getExporter(TextConverter.TEXT_LAYOUT_FORMAT);
			exporter.useClipboardAnnotations = this.useClipboardAnnotations;
			return exporter.export(source, conversionType);	
		}
		return null;
	}
}

class PlainTextImporter extends ConverterBase implements ITextImporter
{
	protected var _config:IConfiguration = null;
	
	/** Constructor */
	public function PlainTextImporter()	
	{
		super();
	}
	
	public function importToFlow(source:Object):TextFlow
	{
		if (source is String)
		{
			var importer:ITextImporter = TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT);
			importer.useClipboardAnnotations = this.useClipboardAnnotations;
			importer.configuration = _config;
			return importer.importToFlow(source);
		}
		return null;
	}
	
	public function get configuration():IConfiguration
	{
		return _config;
	}
	
	public function set configuration(value:IConfiguration):void
	{
		_config = value;
	}
}

class TLFImporter extends ConverterBase implements ITextImporter
{
	protected var _config:IConfiguration = null;
	
	/** Constructor */
	public function TLFImporter()	
	{
		super();
	}
	
	public function importToFlow(source:Object):TextFlow
	{
		if (source is String)
		{
			var importer:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
			importer.useClipboardAnnotations = this.useClipboardAnnotations;
			importer.configuration = _config;
			return importer.importToFlow(source);
		}
		return null;
	}
	
	public function get configuration():IConfiguration
	{
		return _config;
	}
	
	public function set configuration(value:IConfiguration):void
	{
		_config = value;
	}
}
