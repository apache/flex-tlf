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
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.*;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.utils.GeometryUtil;
	
	import mx.containers.Canvas;

	public class ScrollToRangeTest extends VellumTestCase
	{
		private var testCanvas:Canvas;
		private var testCaseXML:XML;
		
		public function ScrollToRangeTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);
			//reset containerType and ID
			containerType = "custom";
		/*	TestID = containerType + ":" + writingDirection + ":";
			if (TestData.id)
			{
				TestID = TestID + TestData.id
			}
			else
			{
				TestID = TestID + methodName;
			} */
			
			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Container";
			this.testCaseXML = testCaseXML;
		}
		
		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			var testCaseClass:Class = ScrollToRangeTest;
			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
		}
		
		override public function setUp() : void
		{
			cleanUpTestApp();
			TestDisplayObject = testApp.getDisplayObject();
			if (TestDisplayObject)
			{
				testCanvas = Canvas(TestDisplayObject);
			}
			else
			{
				fail ("Did not get a blank canvas to work with");
			}
		}
		
		private function addChild(s:Sprite):void
		{
			testCanvas.rawChildren.addChild(s);
		}
		
		private static var englishText:String = '<p>Lorem ipsum dolor sit amet, consectetur <span styleName="scrollToThis">visible word</span>elit.</p>';
								private static var arabicText:String = '<p>لمّا كان الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس<span styleName="scrollToThis"> الحرية</span> والعدل.</p>';
								private static var arabicAndEnglishText:String = '<p>لمّا كان الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس الحرية<span styleName="scrollToThis">visible word</span>والعدل.</p>';
								private static var arabicAndEnglishInScrollText1:String = '<p>لمّا كان الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس<span styleName="scrollToThis"> engالحرية</span>والعدل.</p>';
								private static var arabicAndEnglishInScrollText2:String = '<p>لمّا كان الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس<span styleName="scrollToThis"> الحريةeng</span>والعدل.</p>';
		private static var japaneseText:String = '<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフ<span styleName="scrollToThis">にアクセ</span>スする方法について解説します。</p>';
		private static var japaneseTCYText:String = '<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフ<tcy><span styleName="scrollToThis">0123</span></tcy>スする方法について解説します。</p>';
		
		private static var englishTextLong:String = '<p>Lorem ipsum dolor sit amet, consectetur  <span styleName="scrollToThis">visible word</span>elit ipsum dolor sit amet, consectetur.</p>';
								private static var englishArabicSpanTextLong:String = '<p>Lorem ipsum dolor sit amet, consectetur <span styleName="scrollToThis">الحرية</span>elit ipsum dolor sit amet, consectetur.</p>';
								private static var englishArabicAndEnglishSpanTextLong:String = '<p>Lorem ipsum dolor sit amet, consectetur <span styleName="scrollToThis">الحرية eng</span>elit ipsum dolor sit amet, consectetur.</p>';
								private static var englishEnglishAndArabicSpanTextLong:String = '<p>Lorem ipsum dolor sit amet, consectetur <span styleName="scrollToThis">eng الحرية</span>elit ipsum dolor sit amet, consectetur.</p>';
								private static var englishArabicAndEnglishSpanNoSpaceTextLong:String = '<p>Lorem ipsum dolor sit amet, consectetur <span styleName="scrollToThis">الحريةeng</span>elit ipsum dolor sit amet, consectetur.</p>';
								private static var englishEnglishAndArabicSpanNoSpaceTextLong:String = '<p>Lorem ipsum dolor sit amet, consectetur <span styleName="scrollToThis">engالحرية</span>elit ipsum dolor sit amet, consectetur.</p>';
								private static var arabicTextLong:String = '<p>لمّا كان الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس<span styleName="scrollToThis"> الحرية</span> والعدل الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس.</p>';
								private static var arabicAndEnglishTextLong:String = '<p>لمّا كان الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس الحرية<span styleName="scrollToThis">visible word</span>والعدل الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس.</p>';
								private static var arabicAndEnglishInScrollText1Long:String = '<p>لمّا كان الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس<span styleName="scrollToThis"> engالحرية</span>والعدل الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس.</p>';
								private static var arabicAndEnglishInScrollText2Long:String = '<p>لمّا كان الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس<span styleName="scrollToThis"> الحريةeng</span>والعدل الاعتراف بالكرامة المتأصلة في جميع أعضاء الأسرة البشرية وبحقوقهم المتساوية الثابتة هو أساس.</p>';
		private static var japaneseTextLong:String = '<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフ<span styleName="scrollToThis">にアクセ</span>スする方法について解説しますが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセク。</p>';
		private static var japaneseTCYTextLong:String = '<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフ<tcy><span styleName="scrollToThis">0123</span></tcy>スする方法について解説しまが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクす。</p>';

		
		// The following tests all test scrolling to a range that is on a single line. The basic philosphy is to read in a TextFow markup which has text in red, 
		// with styleName "scrollToThis", find the range, and call scrollToThis to force the red text to be in view. We pass an initial scroll position, and
		// note whether scrolling to the "scrollToThis" range should have changed the scroll position, or not (if the text was already in view, then there
		// should have been no scroll). If a scroll was done, then the red text should appear on one of the edges of the container (left, right, top, or bottom). 
		// We check to make sure it aligns, and that all the text is visible.
		static private var singleLineTestData:Array = 
		[
			// English - scroll forward to the right, red text should appear on right
			[ "singleLineEnglishForward", englishText, BlockProgression.TB, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkRight ],
			// Arabic - scroll forward to the left, red text should appear on left
			[ "singleLineArabicForward", arabicText, BlockProgression.TB, Direction.RTL, 0, 0, true /* expect it to need to scroll */, checkLeft ],
			// Arabic text with English range - scroll forward to the left, red text should appear on left
			[ "singleLineArabicAndEnglishForward", arabicAndEnglishText, BlockProgression.TB, Direction.RTL, 0, 0, true /* expect it to need to scroll */, checkLeft ],
			// Arabic text with English & Arabic range - scroll forward to the left, red text should appear on left
			[ "singleLineArabicAndEnglishInScrollForward", arabicAndEnglishInScrollText1, BlockProgression.TB, Direction.RTL, 0, 0, true /* expect it to need to scroll */, checkLeft ],
			// Arabic text with Arabic & English range - scroll forward to the left, red text should appear on left
			[ "singleLineArabicAndEnglishInScrollForward", arabicAndEnglishInScrollText2, BlockProgression.TB, Direction.RTL, 0, 0, true /* expect it to need to scroll */, checkLeft ],
			// Japanese text, vertical - scroll forwardd (down), red text should appear on bottom
			[ "singleLineJapaneseForward", japaneseText, BlockProgression.RL, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkBottom ],
			// Japanese text, vertical, tcy range - scroll forward (down), red text should appear on bottom
			[ "singleLineJapaneseTCYForward", japaneseTCYText, BlockProgression.RL, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkBottom ],


			// English - scroll backward to the left, red text should appear in container
			[ "singleLineEnglishBackward", englishText, BlockProgression.TB, Direction.LTR, 16000, 0, false /* should already have been visible & no scroll */, checkHorizontalInView ],
			// Arabic - scroll backward to the right, red text should appear in container
			[ "singleLineArabicBackward", arabicText, BlockProgression.TB, Direction.RTL, -16000, 0, false /* should already have been visible & no scroll */, checkHorizontalInView ],
			// Arabic text with English range - scroll backward to the right, red text should appear in container
			[ "singleLineArabicAndEnglishBackward", arabicAndEnglishText, BlockProgression.TB, Direction.RTL, -16000, 0, false /* should already have been visible & no scroll */, checkHorizontalInView ],
			// Arabic text with English & Arabic range - scroll backward to the right, red text should appear in container
			[ "singleLineArabicAndEnglishInScrollBackward", arabicAndEnglishInScrollText1, BlockProgression.TB, Direction.RTL, -16000, 0, false /* should already have been visible & no scroll */, checkHorizontalInView ],
			// Arabic text with Arabic & English range  - scroll backward to the right, red text should appear in container
			[ "singleLineEnglishAndArabicInScrollBackward", arabicAndEnglishInScrollText2, BlockProgression.TB, Direction.RTL, -16000, 0, false /* should already have been visible & no scroll */, checkHorizontalInView ],
			// Japanese text, vertical  - scroll backward to the right, red text should appear in container
			[ "singleLineJapaneseBackward", japaneseText, BlockProgression.RL, Direction.LTR, 0, 16000, false /* should already have been visible & no scroll */, checkHorizontalInView ],
			// Japanese text, vertical  - scroll backward to the right, red text should appear in container
			[ "singleLineTCYJapaneseBackward", japaneseTCYText, BlockProgression.RL, Direction.LTR, 0, 16000, false /* should already have been visible & no scroll */, checkTop ],

			// English - scroll forward to the right, red text should appear on right
			[ "singleLineEnglishForwardLong", englishTextLong, BlockProgression.TB, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkRight ],
			// Arabic - scroll forward to the left, red text should appear on left
			[ "singleLineArabicForwardLong", arabicTextLong, BlockProgression.TB, Direction.RTL, 0, 0, true /* expect it to need to scroll */, checkLeft ],
			// Arabic text with English range - scroll forward to the left, red text should appear on left
			[ "singleLineArabicAndEnglishForwardLong", arabicAndEnglishTextLong, BlockProgression.TB, Direction.RTL, 0, 0, true /* expect it to need to scroll */, checkLeft ],
			// Arabic text with English & Arabic range - scroll forward to the left, red text should appear on left
			[ "singleLineArabicAndEnglishInScrollForwardLong", arabicAndEnglishInScrollText1Long, BlockProgression.TB, Direction.RTL, 0, 0, true /* expect it to need to scroll */, checkLeft ],
			// Arabic text with Arabic & English range - scroll forward to the left, red text should appear on left
			[ "singleLineArabicAndEnglishInScrollForwardLong", arabicAndEnglishInScrollText2Long, BlockProgression.TB, Direction.RTL, 0, 0, true /* expect it to need to scroll */, checkLeft ],
			// Japanese text, vertical - scroll forwardd (down), red text should appear on bottom
			[ "singleLineJapaneseForwardLong", japaneseTextLong, BlockProgression.RL, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkBottom ],
			// Japanese text, vertical, tcy range - scroll forward (down), red text should appear on bottom
			[ "singleLineJapaneseTCYForwardLong", japaneseTCYTextLong, BlockProgression.RL, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkBottom ],
			
			// English with Arabic span - scroll back to the right, red text should appear on right
			[ "englishArabicSpanForwardLong", englishArabicSpanTextLong, BlockProgression.TB, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkRight ],
			// English with Arabic & English span - scroll forward to the right, red text should appear on right
			[ "englishArabicAndEnglishSpanForwardLong", englishArabicAndEnglishSpanTextLong, BlockProgression.TB, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkRight ],
			// English with English & Arabic span - scroll forward to the right, red text should appear on right
			[ "englishEnglishAndArabicSpanForwardLong", englishEnglishAndArabicSpanTextLong, BlockProgression.TB, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkRight ],
			// English with English & Arabic span, no space dividing Arabic from English - scroll forward to the right, red text should appear on right
			[ "englishEnglishAndArabicSpanNoSpaceForwardLong", englishEnglishAndArabicSpanNoSpaceTextLong, BlockProgression.TB, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkRight ],
			// English with Arabic & English span, no space dividing Arabic from English - scroll forward to the right, red text should appear on right
			[ "englishArabicAndEnglishSpanNoSpaceForwardLong", englishArabicAndEnglishSpanNoSpaceTextLong, BlockProgression.TB, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkRight ],
			
			// English - scroll backward to the left, red text should appear on the left edge
			[ "singleLineEnglishBackwardLong", englishTextLong, BlockProgression.TB, Direction.LTR, 16000, 0, true /* expect it to need to scroll */, checkLeft ],
			// English with Arabic span - scroll backward to the left, red text should appear on left
			[ "englishArabicSpanBackwardLong", englishArabicSpanTextLong, BlockProgression.TB, Direction.LTR, 16000, 0, true /* expect it to need to scroll */, checkLeft ],
			// English with Arabic & English span - scroll backward to the left, red text should appear on left
			[ "englishArabicAndEnglishSpanBackwardLong", englishArabicAndEnglishSpanTextLong, BlockProgression.TB, Direction.LTR, 16000, 0, true /* expect it to need to scroll */, checkLeft ],
			// English with English & Arabic span - scroll backward to the left, red text should appear on left
			[ "englishEnglishAndArabicSpanBackwardLong", englishEnglishAndArabicSpanTextLong, BlockProgression.TB, Direction.LTR, 16000, 0, true /* expect it to need to scroll */, checkLeft ],
			// English with English & Arabic span, no space dividing Arabic from English - scroll backward to the left, red text should appear on left
			[ "englishEnglishAndArabicSpanNoSpaceBackwardLong", englishEnglishAndArabicSpanNoSpaceTextLong, BlockProgression.TB, Direction.LTR, 16000, 0, true /* expect it to need to scroll */, checkLeft ],
			// English with Arabic & English span, no space dividing Arabic from English - scroll backward to the left, red text should appear on left
			[ "englishArabicAndEnglishSpanNoSpaceBackwardLong", englishArabicAndEnglishSpanNoSpaceTextLong, BlockProgression.TB, Direction.LTR, 16000, 0, true /* expect it to need to scroll */, checkLeft ],
			// Arabic - scroll backward to the right, red text should appear on right
			[ "singleLineArabicBackwardLong", arabicTextLong, BlockProgression.TB, Direction.RTL, -16000, 0, true /* expect it to need to scroll */, checkRight ],
			// Arabic text with English range - scroll backward to the right, red text should appear on right
			[ "singleLineArabicAndEnglishBackwardLong", arabicAndEnglishTextLong, BlockProgression.TB, Direction.RTL, -16000, 0, true /* expect it to need to scroll */, checkRight ],
			// Arabic text with English & Arabic range - scroll backward to the right, red text should appear on right
			[ "singleLineArabicAndEnglishInScrollBackwardLong", arabicAndEnglishInScrollText1Long, BlockProgression.TB, Direction.RTL, -16000, 0, true /* expect it to need to scroll */, checkRight ],
			// Arabic text with Arabic & English range  - scroll backward to the right, red text should appear on right
			[ "singleLineEnglishAndArabicInScrollBackwardLong", arabicAndEnglishInScrollText2Long, BlockProgression.TB, Direction.RTL, -16000, 0, true /* expect it to need to scroll */, checkRight ],
			// Japanese text, vertical  - scroll backward to the right, red text should appear on top
			[ "singleLineJapaneseBackwardLong", japaneseTextLong, BlockProgression.RL, Direction.LTR, 0, 16000, true /* expect it to need to scroll */, checkTop ],
			// Japanese text, vertical  - scroll backward to the right, red text should appear on top
			[ "singleLineTCYJapaneseBackwardLong", japaneseTCYTextLong, BlockProgression.RL, Direction.LTR, 0, 16000, true /* expect it to need to scroll */, checkTop ],
		];
		
		private static var aliceExcerptText:XML = <TextFlow xmlns="http://ns.adobe.com/textLayout/2008" styleName="scrollToThis" textAlign="start" fontFamily="Minion Pro" fontSize="16">I. Down the Rabbit-Hole<p textAlign="center" fontSize="24">Chapter I</p>
<p textAlign="center" fontSize="24">Down the Rabbit-Hole</p>
<p>Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, “and what is the use of a book,” thought Alice “without pictures or conversation?”</p>
<p>So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her.</p>
<p>There was nothing so <span fontStyle="italic">very</span> remarkable in that; nor did Alice think it so <span fontStyle="italic">very</span> much out of the way to hear the Rabbit say to itself, “Oh dear! Oh dear! I shall be late!” (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually <span fontStyle="italic">took a watch out of its waistcoat-pocket</span> , and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge.</p>
<p>In another moment down went Alice after it, never once considering how in the world she was to get out again.</p>
<p>The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well.</p>
<p>Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. First, she tried to look down and make out what she was coming to, but it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards and bookshelves; here and there she saw maps and pictures hung upon pegs. She took down a jar from one of the shelves as she passed; it was labelled “Orange Marmalade”, but to her great disappointment it was empty: she did not like to drop the jar for fear of killing somebody, so managed to put it into one of the cupboards as she fell past it.</p>
<p>“Well!” thought Alice to herself, “after such a fall as this, I shall think nothing of tumbling down stairs! How brave they'll all think me at home! Why, I wouldn't say anything about it, even if I fell off the top of the house!” (Which was very likely true.)</p>
<p>Down, down, down. Would the fall <span fontStyle="italic">never</span> come to an end! “I wonder how many miles I've fallen by this time?” she said aloud. “I must be getting somewhere near the centre of the earth. Let me see: that would be four thousand miles down, I think—” (for, you see, Alice had learnt several things of this sort in her lessons in the schoolroom, and though this was not a <span fontStyle="italic">very</span> good opportunity for showing off her knowledge, as there was no one to listen to her, still it was good practice to say it over) “—yes, that's about the right distance—but then I wonder what Latitude or Longitude I've got to?” (Alice had no idea what Latitude was, or Longitude either, but thought they were nice grand words to say.)</p>
<p>Presently she began again. “I wonder if I shall fall right <span fontStyle="italic">through</span> the earth! How funny it'll seem to come out among the people that walk with their heads downward! The Antipathies, I think—” (she was rather glad there Was no one listening, this time, as it didn't sound at all the right word) “—but I shall have to ask them what the name of the country is, you know. Please, Ma'am, is this New Zealand or Australia?” (and she tried to curtsey as she spoke—fancy <span fontStyle="italic">curtseying</span> as you're falling through the air! Do you think you could manage it?) “And what an ignorant little girl she'll think me for asking! No, it'll never do to ask: perhaps I shall see it written up somewhere.”</p>
<p>Down, down, down. There was nothing else to do, so Alice soon began talking again. “Dinah'll miss me very much to-night, I should think!” (Dinah was the cat.) “I hope they'll remember her saucer of milk at tea-time. Dinah my dear! I wish you were down here with me! There are no mice in the air, I'm afraid, but you might catch a bat, and that's very like a mouse, you know. But do cats eat bats, I wonder?” And here Alice began to get rather sleepy, and went on saying to herself, in a dreamy sort of way, “Do cats eat bats? Do cats eat bats?” and sometimes, “Do bats eat cats?” for, you see, as she couldn't answer either question, it didn't much matter which way she put it. She felt that she was dozing off, and had just begun to dream that she was walking hand in hand with Dinah, and saying to her very earnestly, “Now, Dinah, tell me the truth: did you ever eat a bat?” when suddenly, thump! thump! down she came upon a heap of sticks and dry leaves, and the fall was over.</p>
<p>Alice was not a bit hurt, and she jumped up on to her feet in a moment: she looked up, but it was all dark overhead; before her was another long passage, and the White Rabbit was still in sight, hurrying down it. There was not a moment to be lost: away went Alice like the wind, and was just in time to hear it say, as it turned a corner, “Oh my ears and whiskers, how late it's getting!” She was close behind it when she turned the corner, but the Rabbit was no longer to be seen: she found herself in a long, low hall, which was lit up by a row of lamps hanging from the roof.</p>
<p>There were doors all round the hall, but they were all locked; and when Alice had been all the way down one side and up the other, trying every door, she walked sadly down the middle, wondering how she was ever to get out again.</p>
<p>Suddenly she came upon a little three-legged table, all made of solid glass; there was nothing on it except a tiny golden key, and Alice's first thought was that it might belong to one of the doors of the hall; but, alas! either the locks were too large, or the key was too small, but at any rate it would not open any of them. However, on the second time round, she came upon a low curtain she had not noticed before, and behind it was a little door about fifteen inches high: she tried the little golden key in the lock, and to her great delight it fitted!</p>
<p>Alice opened the door and found that it led into a small passage, not much larger than a rat-hole: she knelt down and looked along the passage into the loveliest garden you ever saw. How she longed to get out of that dark hall, and wander about among those beds of bright flowers and those cool fountains, but she could not even get her head though the doorway; “and even if my head <span fontStyle="italic">would</span> go through,” thought poor Alice, “it would be of very little use without my shoulders. Oh, how I wish I could shut up like a telescope! I think I could, if I only know how to begin.” For, you see, so many out-of-the-way things had happened lately, that Alice had begun to think that very few things indeed were really impossible.</p>
<p>There seemed to be no use in waiting by the little door, so she went back to the table, half hoping she might find another key on it, or at any rate a book of rules for shutting people up like telescopes: this time she found a little bottle on it, (“which certainly was not here before,” said Alice,) and round the neck of the bottle was a paper label, with the words “DRINK ME” beautifully printed on it in large letters.</p>
<p>It was all very well to say “Drink me,” but the wise little Alice was not going to do <span fontStyle="italic">that</span> in a hurry. “No, I'll look first,” she said, “and see whether it's marked <span fontStyle="italic">‘poison’</span> or not”; for she had read several nice little histories about children who had got burnt, and eaten up by wild beasts and other unpleasant things, all because they <span fontStyle="italic">would</span> not remember the simple rules their friends had taught them: such as, that a red-hot poker will burn you if you hold it too long; and that if you cut your finger <span fontStyle="italic">very</span> deeply with a knife, it usually bleeds; and she had never forgotten that, if you drink much from a bottle marked “poison,” it is almost certain to disagree with you, sooner or later.</p>
<p>However, this bottle was <span fontStyle="italic">not</span> marked “poison”, so Alice ventured to taste it, and finding it very nice, (it had, in fact, a sort of mixed flavour of cherry-tart, custard, pine-apple, roast turkey, toffee, and hot buttered toast,) she very soon finished it off.</p>
<p>“What a curious feeling!” said Alice; “I must be shutting up like a telescope.”</p>
<p>And so it was indeed: she was now only ten inches high, and her face brightened up at the thought that she was now the right size for going through the little door into that lovely garden. First, however, she waited for a few minutes to see if she was going to shrink any further: she felt a little nervous about this; “for it might end, you know,” said Alice to herself, “in my going out altogether, like a candle. I wonder what I should be like then?” And she tried to fancy what the flame of a candle is like after the candle is blown out, for she could not remember ever having seen such a thing.</p>
<p>After a while, finding that nothing more happened, she decided on going into the garden at once; but, alas for poor Alice! when she got to the door, she found she had forgotten the little golden key, and when she went back to the table for it, she found she could not possibly reach it: she could see it quite plainly through the glass, and she tried her best to climb up one of the legs of the table, but it was too slippery; and when she had tired herself out with trying, the poor little thing sat down and cried.</p>
<p>“Come, there's no use in crying like that!” said Alice to herself, rather sharply; “I advise you to leave off this minute!” She generally gave herself very good advice, (though she very seldom followed it), and sometimes she scolded herself so severely as to bring tears into her eyes; and once she remembered trying to box her own ears for having cheated herself in a game of croquet she was playing against herself, for this curious child was very fond of pretending to be two people. “But it's no use now,” thought poor Alice, “to pretend to be two people! Why, there's hardly enough of me left to make <span fontStyle="italic">one</span> respectable person!”</p>
<p>Soon her eye fell on a little glass box that was lying under the table: she opened it, and found in it a very small cake, on which the words “EAT ME” were beautifully marked in currants. “Well, I'll eat it,” said Alice, “and if it makes me grow larger, I can reach the key; and if it makes me grow smaller, I can creep under the door; so either way I'll get into the garden, and I don't care which happens!”</p>
<p>She ate a little bit, and said anxiously to herself, “Which way? Which way?”, holding her hand on the top of her head to feel which way it was growing, and she was quite surprised to find that she remained the same size: to be sure, this generally happens when one eats cake, but Alice had got so much into the way of expecting nothing but out-of-the-way things to happen, that it seemed quite dull and stupid for life to go on in the common way.</p>
<p>So she set to work, and very soon finished off the cake.</p>II. The Pool of Tears<p textAlign="center" fontSize="24">Chapter II</p>
<p textAlign="center" fontSize="24">The Pool of Tears</p>
<p>“Curiouser and curiouser!” cried Alice (she was so much surprised, that for the moment she quite forgot how to speak good English); “now I'm opening out like the largest telescope that ever was! Good-bye, feet!” (for when she looked down at her feet, they seemed to be almost out of sight, they were getting so far off). “Oh, my poor little feet, I wonder who will put on your shoes and stockings for you now, dears? I'm sure <span fontStyle="italic">I</span> shan't be able! I shall be a great deal too far off to trouble myself about you: you must manage the best way you can; —but I must be kind to them,” thought Alice, “or perhaps they won't walk the way I want to go! Let me see: I'll give them a new pair of boots every Christmas.”</p>
<p>And she went on planning to herself how she would manage it. “They must go by the carrier,” she thought; “and how funny it'll seem, sending presents to one's own feet! And how odd the directions will look!</p>
<p>Oh dear, what nonsense I'm talking!”</p>
<p>Just then her head struck against the roof of the hall: in fact she was now more than nine feet high, and she at once took up the little golden key and hurried off to the garden door.</p>
<p>Poor Alice! It was as much as she could do, lying down on one side, to look through into the garden with one eye; but to get through was more hopeless than ever: she sat down and began to cry again.</p>
<p>“You ought to be ashamed of yourself,” said Alice, “a great girl like you,” (she might well say this), “to go on crying in this way! Stop this moment, I tell you!” But she went on all the same, shedding gallons of tears, until there was a large pool all round her, about four inches deep and reaching half down the hall.</p>
<p>After a time she heard a little pattering of feet in the distance, and she hastily dried her eyes to see what was coming. It was the White Rabbit returning, splendidly dressed, with a pair of white kid gloves in one hand and a large fan in the other: he came trotting along in a great hurry, muttering to himself as he came, “Oh! the Duchess, the Duchess! Oh! won't she be savage if I've kept her waiting!” Alice felt so desperate that she was ready to ask help of any one; so, when the Rabbit came near her, she began, in a low, timid voice, “If you please, sir—” The Rabbit started violently, dropped the white kid gloves and the fan, and skurried away into the darkness as hard as he could go.</p>
<p>Alice took up the fan and gloves, and, as the hall was very hot, she kept fanning herself all the time she went on talking: “Dear, dear! How queer everything is to-day! And yesterday things went on just as usual. I wonder if I've been changed in the night? Let me think: was I the same when I got up this morning? I almost think I can remember feeling a little different. But if I'm not the same, the next question is, Who in the world am I? Ah, That's the great puzzle!” And she began thinking over all the children she knew that were of the same age as herself, to see if she could have been changed for any of them.</p>
<p>“I'm sure I'm not Ada,” she said, “for her hair goes in such long ringlets, and mine doesn't go in ringlets at all; and I'm sure I can't be Mabel, for I know all sorts of things, and she, oh! she knows such a very little! Besides, SHE'S she, and I'm I, and—oh dear, how puzzling it all is! I'll try if I know all the things I used to know. Let me see: four times five is twelve, and four times six is thirteen, and four times seven is—oh dear! I shall never get to twenty at that rate! However, the Multiplication Table doesn't signify: let's try Geography. London is the capital of Paris, and Paris is the capital of Rome, and Rome—no, That's all wrong, I'm certain! I must have been changed for Mabel! I'll try and say ‘How doth the little—’” and she crossed her hands on her lap as if she were saying lessons, and began to repeat it, but her voice sounded hoarse and strange, and the words did not come the same as they used to do:—</p>
<p>“I'm sure those are not the right words,” said poor Alice, and her eyes filled with tears again as she went on, “I must be Mabel after all, and I shall have to go and live in that poky little house, and have next to no toys to play with, and oh! ever so many lessons to learn! No, I've made up my mind about it; if I'm Mabel, I'll stay down here! It'll be no use their putting their heads down and saying ‘Come up again, dear!’ I shall only look up and say ‘Who am I then? Tell me that first, and then, if I like being that person, I'll come up: if not, I'll stay down here till I'm somebody else’—but, oh dear!” cried Alice, with a sudden burst of tears, “I do wish they <span fontStyle="italic">would</span> put their heads down! I am so Very tired of being all alone here!”</p>
<p>As she said this she looked down at her hands, and was surprised to see that she had put on one of the Rabbit's little white kid gloves while she was talking. “How Can I have done that?” she thought. “I must be growing small again.” She got up and went to the table to measure herself by it, and found that, as nearly as she could guess, she was now about two feet high, and was going on shrinking rapidly: she soon found out that the cause of this was the fan she was holding, and she dropped it hastily, just in time to avoid shrinking away altogether.</p>
<p>“That Was a narrow escape!” said Alice, a good deal frightened at the sudden change, but very glad to find herself still in existence; “and now for the garden!” and she ran with all speed back to the little door: but, alas! the little door was shut again, and the little golden key was lying on the glass table as before, “and things are worse than ever,” thought the poor child, “for I never was so small as this before, never! And I declare it's too bad, that it is!”</p>
<p>As she said these words her foot slipped, and in another moment, splash! she was up to her chin in salt water. Her first idea was that she had somehow fallen into the sea, “and in that case I can go back by railway,” she said to herself. (Alice had been to the seaside once in her life, and had come to the general conclusion, that wherever you go to on the English coast you find a number of bathing machines in the sea, some children digging in the sand with wooden spades, then a row of lodging houses, and behind them a railway station.) However, she soon made out that she was in the pool of tears which she had wept when she was nine feet high.</p>
<p>“I wish I hadn't cried so much!” said Alice, as she swam about, trying to find her way out. “I shall be punished for it now, I suppose, by being drowned in my own tears! That Will be a queer thing, to be sure! However, everything is queer to-day.”</p>
<p>Just then she heard something splashing about in the pool a little way off, and she swam nearer to make out what it was: at first she thought it must be a walrus or hippopotamus, but then she remembered how small she was now, and she soon made out that it was only a mouse that had slipped in like herself.</p>
<p>“Would it be of any use, now,” thought Alice, “to speak to this mouse? Everything is so out-of-the-way down here, that I should think very likely it can talk: at any rate, there's no harm in trying.” So she began: “O Mouse, do you know the way out of this pool? I am very tired of swimming about here, O Mouse!” (Alice thought this must be the right way of speaking to a mouse: she had never done such a thing before, but she remembered having seen in her brother's Latin Grammar, “A mouse—of a mouse—to a mouse—a mouse—O mouse!” The Mouse looked at her rather inquisitively, and seemed to her to wink with one of its little eyes, but it said nothing.</p>
<p>“Perhaps it doesn't understand English,” thought Alice; “I daresay it's a French mouse, come over with William the Conqueror.” (For, with all her knowledge of history, Alice had no very clear notion how long ago anything had happened.) So she began again: “Où est ma chatte?” which was the first sentence in her French lesson-book. The Mouse gave a sudden leap out of the water, and seemed to quiver all over with fright. “Oh, I beg your pardon!” cried Alice hastily, afraid that she had hurt the poor animal's feelings. “I quite forgot you didn't like cats.”</p>
<p>“Not like cats!” cried the Mouse, in a shrill, passionate voice. “Would You like cats if you were me?”</p>
<p>“Well, perhaps not,” said Alice in a soothing tone: “don't be angry about it. And yet I wish I could show you our cat Dinah: I think you'd take a fancy to cats if you could only see her. She is such a dear quiet thing,” Alice went on, half to herself, as she swam lazily about in the pool, “and she sits purring so nicely by the fire, licking her paws and washing her face—and she is such a nice soft thing to nurse—and she's such a capital one for catching mice—oh, I beg your pardon!” cried Alice again, for this time the Mouse was bristling all over, and she felt certain it must be really offended. “We won't talk about her any more if you'd rather not.”</p>
<p>“We indeed!” cried the Mouse, who was trembling down to the end of his tail. “As if I would talk on such a subject! Our family always Hated cats: nasty, low, vulgar things! Don't let me hear the name again!”</p>
<p>“I won't indeed!” said Alice, in a great hurry to change the subject of conversation. “Are you—are you fond—of—of dogs?” The Mouse did not answer, so Alice went on eagerly: “There is such a nice little dog near our house I should like to show you! A little bright-eyed terrier, you know, with oh, such long curly brown hair! And it'll fetch things when you throw them, and it'll sit up and beg for its dinner, and all sorts of things—I can't remember half of them—and it belongs to a farmer, you know, and he says it's so useful, it's worth a hundred pounds! He says it kills all the rats and—oh dear!” cried Alice in a sorrowful tone, “I'm afraid I've offended it again!” For the Mouse was swimming away from her as hard as it could go, and making quite a commotion in the pool as it went.</p>
<p>So she called softly after it, “Mouse dear! Do come back again, and we won't talk about cats or dogs either, if you don't like them!” When the Mouse heard this, it turned round and swam slowly back to her: its face was quite pale (with passion, Alice thought), and it said in a low trembling voice, “Let us get to the shore, and then I'll tell you my history, and you'll understand why it is I hate cats and dogs.”</p>
<p>It was high time to go, for the pool was getting quite crowded with the birds and animals that had fallen into it: there were a Duck and a Dodo, a Lory and an Eaglet, and several other curious creatures. Alice led the way, and the whole party swam to the shore.</p>
</TextFlow>;
private static var aliceScrollToParagraphText:XML = <TextFlow xmlns="http://ns.adobe.com/textLayout/2008" textAlign="start" fontFamily="Minion Pro" fontSize="16">I. Down the Rabbit-Hole<p textAlign="center" fontSize="24">Chapter I</p>
	<p textAlign="center" fontSize="24">Down the Rabbit-Hole</p>
	<p>Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, “and what is the use of a book,” thought Alice “without pictures or conversation?”</p>
	<p>So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her.</p>
	<p>There was nothing so <span fontStyle="italic">very</span> remarkable in that; nor did Alice think it so <span fontStyle="italic">very</span> much out of the way to hear the Rabbit say to itself, “Oh dear! Oh dear! I shall be late!” (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually <span fontStyle="italic">took a watch out of its waistcoat-pocket</span> , and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge.</p>
	<p>In another moment down went Alice after it, never once considering how in the world she was to get out again.</p>
	<p styleName="scrollToThis">The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well.</p>
	<p>Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. First, she tried to look down and make out what she was coming to, but it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards and bookshelves; here and there she saw maps and pictures hung upon pegs. She took down a jar from one of the shelves as she passed; it was labelled “Orange Marmalade”, but to her great disappointment it was empty: she did not like to drop the jar for fear of killing somebody, so managed to put it into one of the cupboards as she fell past it.</p>
	<p>“Well!” thought Alice to herself, “after such a fall as this, I shall think nothing of tumbling down stairs! How brave they'll all think me at home! Why, I wouldn't say anything about it, even if I fell off the top of the house!” (Which was very likely true.)</p>
	<p>Down, down, down. Would the fall <span fontStyle="italic">never</span> come to an end! “I wonder how many miles I've fallen by this time?” she said aloud. “I must be getting somewhere near the centre of the earth. Let me see: that would be four thousand miles down, I think—” (for, you see, Alice had learnt several things of this sort in her lessons in the schoolroom, and though this was not a <span fontStyle="italic">very</span> good opportunity for showing off her knowledge, as there was no one to listen to her, still it was good practice to say it over) “—yes, that's about the right distance—but then I wonder what Latitude or Longitude I've got to?” (Alice had no idea what Latitude was, or Longitude either, but thought they were nice grand words to say.)</p>
	</TextFlow>;
private static var aliceScrollToSpanText:XML = <TextFlow xmlns="http://ns.adobe.com/textLayout/2008" textAlign="start" fontFamily="Minion Pro" fontSize="16">I. Down the Rabbit-Hole<p textAlign="center" fontSize="24">Chapter I</p>
	<p textAlign="center" fontSize="24">Down the Rabbit-Hole</p>
	<p>Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, “and what is the use of a book,” thought Alice “without pictures or conversation?”</p>
	<p>So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her.</p>
	<p>There was nothing so very remarkable in that; nor did Alice think it so <span fontStyle="italic">very</span> much out of the way to hear the Rabbit say to itself, “Oh dear! Oh dear! I shall be late!” (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually <span fontStyle="italic">took a watch out of its waistcoat-pocket</span> , and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge.</p>
	<p>In another moment down went Alice after it, never once considering how in the world she was to get out again.</p>
	<p>The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well.</p>
	<p>Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. First, she tried to look <span styleName="scrollToThis">down and make out what she was coming to, but it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards and bookshelves; here and there she saw maps and pictures hung upon pegs. She took down a jar from one of the shelves as she passed; </span>it was labelled “Orange Marmalade”, but to her great disappointment it was empty: she did not like to drop the jar for fear of killing somebody, so managed to put it into one of the cupboards as she fell past it.</p>
	<p>“Well!” thought Alice to herself, “after such a fall as this, I shall think nothing of tumbling down stairs! How brave they'll all think me at home! Why, I wouldn't say anything about it, even if I fell off the top of the house!” (Which was very likely true.)</p>
	<p>Down, down, down. Would the fall <span fontStyle="italic">never</span> come to an end! “I wonder how many miles I've fallen by this time?” she said aloud. “I must be getting somewhere near the centre of the earth. Let me see: that would be four thousand miles down, I think—” (for, you see, Alice had learnt several things of this sort in her lessons in the schoolroom, and though this was not a <span fontStyle="italic">very</span> good opportunity for showing off her knowledge, as there was no one to listen to her, still it was good practice to say it over) “—yes, that's about the right distance—but then I wonder what Latitude or Longitude I've got to?” (Alice had no idea what Latitude was, or Longitude either, but thought they were nice grand words to say.)</p>
	<p>Presently she began again. “I wonder if I shall fall right <span fontStyle="italic">through</span> the earth! How funny it'll seem to come out among the people that walk with their heads downward! The Antipathies, I think—” (she was rather glad there Was no one listening, this time, as it didn't sound at all the right word) “—but I shall have to ask them what the name of the country is, you know. Please, Ma'am, is this New Zealand or Australia?” (and she tried to curtsey as she spoke—fancy <span fontStyle="italic">curtseying</span> as you're falling through the air! Do you think you could manage it?) “And what an ignorant little girl she'll think me for asking! No, it'll never do to ask: perhaps I shall see it written up somewhere.”</p>
	<p>Down, down, down. There was nothing else to do, so Alice soon began talking again. “Dinah'll miss me very much to-night, I should think!” (Dinah was the cat.) “I hope they'll remember her saucer of milk at tea-time. Dinah my dear! I wish you were down here with me! There are no mice in the air, I'm afraid, but you might catch a bat, and that's very like a mouse, you know. But do cats eat bats, I wonder?” And here Alice began to get rather sleepy, and went on saying to herself, in a dreamy sort of way, “Do cats eat bats? Do cats eat bats?” and sometimes, “Do bats eat cats?” for, you see, as she couldn't answer either question, it didn't much matter which way she put it. She felt that she was dozing off, and had just begun to dream that she was walking hand in hand with Dinah, and saying to her very earnestly, “Now, Dinah, tell me the truth: did you ever eat a bat?” when suddenly, thump! thump! down she came upon a heap of sticks and dry leaves, and the fall was over.</p>
	<p>Alice was not a bit hurt, and she jumped up on to her feet in a moment: she looked up, but it was all dark overhead; before her was another long passage, and the White Rabbit was still in sight, hurrying down it. There was not a moment to be lost: away went Alice like the wind, and was just in time to hear it say, as it turned a corner, “Oh my ears and whiskers, how late it's getting!” She was close behind it when she turned the corner, but the Rabbit was no longer to be seen: she found herself in a long, low hall, which was lit up by a row of lamps hanging from the roof.</p>
	<p>There were doors all round the hall, but they were all locked; and when Alice had been all the way down one side and up the other, trying every door, she walked sadly down the middle, wondering how she was ever to get out again.</p>
	</TextFlow>;
private static var japaneseParagraphText:XML = <TextFlow xmlns="http://ns.adobe.com/textLayout/2008">
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p styleName="scrollToThis">文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	</TextFlow>
private static var japaneseSpanText:XML = <TextFlow xmlns="http://ns.adobe.com/textLayout/2008">
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、<span styleName="scrollToThis">このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コ</span>ードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	</TextFlow>
	//this listElement is similar to aliceScrollToParagraphText
private static var aliceScrollToListElementText:XML =  <TextFlow xmlns="http://ns.adobe.com/textLayout/2008" textAlign="start" fontFamily="Minion Pro" fontSize="16">
	<list listStylePosition="inside" listStyleType="upperRoman"><li>Down the Rabbit-Hole</li></list>
	<p textAlign="center" fontSize="24">Chapter I</p>
	<p textAlign="center" fontSize="24">Down the Rabbit-Hole</p>
	<p>Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, “and what is the use of a book,” thought Alice “without pictures or conversation?”</p>
	<p>So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her.</p>
	<p>There was nothing so very remarkable in that; nor did Alice think it so <span fontStyle="italic">very</span> much out of the way to hear the Rabbit say to itself, “Oh dear! Oh dear! I shall be late!” (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually <span fontStyle="italic">took a watch out of its waistcoat-pocket</span> , and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge.</p>
	<p>In another moment down went Alice after it, never once considering how in the world she was to get out again.</p>
	<p>The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well.</p>
	<p>Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. First, she tried to look </p>
	
	<list styleName="scrollToThis" paddingRight="24" paddingLeft="24" listStyleType="decimal"><li>down and make out what she was coming to, but it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards and bookshelves; here and there she saw maps and pictures hung upon pegs. She took down a jar from one of the shelves as she passed; </li></list>
	
	<p>it was labelled “Orange Marmalade”, but to her great disappointment it was empty: she did not like to drop the jar for fear of killing somebody, so managed to put it into one of the cupboards as she fell past it.</p>
	<p>“Well!” thought Alice to herself, “after such a fall as this, I shall think nothing of tumbling down stairs! How brave they'll all think me at home! Why, I wouldn't say anything about it, even if I fell off the top of the house!” (Which was very likely true.)</p>
	<p>Down, down, down. Would the fall <span fontStyle="italic">never</span> come to an end! “I wonder how many miles I've fallen by this time?” she said aloud. “I must be getting somewhere near the centre of the earth. Let me see: that would be four thousand miles down, I think—” (for, you see, Alice had learnt several things of this sort in her lessons in the schoolroom, and though this was not a <span fontStyle="italic">very</span> good opportunity for showing off her knowledge, as there was no one to listen to her, still it was good practice to say it over) “—yes, that's about the right distance—but then I wonder what Latitude or Longitude I've got to?” (Alice had no idea what Latitude was, or Longitude either, but thought they were nice grand words to say.)</p>
	<p>Presently she began again. “I wonder if I shall fall right <span fontStyle="italic">through</span> the earth! How funny it'll seem to come out among the people that walk with their heads downward! The Antipathies, I think—” (she was rather glad there Was no one listening, this time, as it didn't sound at all the right word) “—but I shall have to ask them what the name of the country is, you know. Please, Ma'am, is this New Zealand or Australia?” (and she tried to curtsey as she spoke—fancy <span fontStyle="italic">curtseying</span> as you're falling through the air! Do you think you could manage it?) “And what an ignorant little girl she'll think me for asking! No, it'll never do to ask: perhaps I shall see it written up somewhere.”</p>
	<p>Down, down, down. There was nothing else to do, so Alice soon began talking again. “Dinah'll miss me very much to-night, I should think!” (Dinah was the cat.) “I hope they'll remember her saucer of milk at tea-time. Dinah my dear! I wish you were down here with me! There are no mice in the air, I'm afraid, but you might catch a bat, and that's very like a mouse, you know. But do cats eat bats, I wonder?” And here Alice began to get rather sleepy, and went on saying to herself, in a dreamy sort of way, “Do cats eat bats? Do cats eat bats?” and sometimes, “Do bats eat cats?” for, you see, as she couldn't answer either question, it didn't much matter which way she put it. She felt that she was dozing off, and had just begun to dream that she was walking hand in hand with Dinah, and saying to her very earnestly, “Now, Dinah, tell me the truth: did you ever eat a bat?” when suddenly, thump! thump! down she came upon a heap of sticks and dry leaves, and the fall was over.</p>
	<p>Alice was not a bit hurt, and she jumped up on to her feet in a moment: she looked up, but it was all dark overhead; before her was another long passage, and the White Rabbit was still in sight, hurrying down it. There was not a moment to be lost: away went Alice like the wind, and was just in time to hear it say, as it turned a corner, “Oh my ears and whiskers, how late it's getting!” She was close behind it when she turned the corner, but the Rabbit was no longer to be seen: she found herself in a long, low hall, which was lit up by a row of lamps hanging from the roof.</p>
	<p>There were doors all round the hall, but they were all locked; and when Alice had been all the way down one side and up the other, trying every door, she walked sadly down the middle, wondering how she was ever to get out again.</p>
	</TextFlow>;
	//this listItemElement is similar to aliceScrollToSpanText
private static var aliceScrollToListItemElementText:XML = <TextFlow xmlns="http://ns.adobe.com/textLayout/2008" textAlign="start" fontFamily="Minion Pro" fontSize="16">
	<list listStylePosition="inside" listStyleType="upperRoman"><li>Down the Rabbit-Hole</li></list>
	<p textAlign="center" fontSize="24">Chapter I</p>
	<p textAlign="center" fontSize="24">Down the Rabbit-Hole</p>
	<p>Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, “and what is the use of a book,” thought Alice “without pictures or conversation?”</p>
	<p>So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her.</p>
	<p>There was nothing so very remarkable in that; nor did Alice think it so <span fontStyle="italic">very</span> much out of the way to hear the Rabbit say to itself, “Oh dear! Oh dear! I shall be late!” (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually <span fontStyle="italic">took a watch out of its waistcoat-pocket</span> , and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge.</p>
	<p>In another moment down went Alice after it, never once considering how in the world she was to get out again.</p>
	<p>The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well.</p>
	
	<list paddingRight="24" paddingLeft="24" listStyleType="decimal"><li styleName="scrollToThis">Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. First, she tried to look down and make out what she was coming to, but it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards and bookshelves; here and there she saw maps and pictures hung upon pegs. She took down a jar from one of the shelves as she passed;it was labelled “Orange Marmalade”, but to her great disappointment it was empty: she did not like to drop the jar for fear of killing somebody, so managed to put it into one of the cupboards as she fell past it. </li></list>
	
	<p>“Well!” thought Alice to herself, “after such a fall as this, I shall think nothing of tumbling down stairs! How brave they'll all think me at home! Why, I wouldn't say anything about it, even if I fell off the top of the house!” (Which was very likely true.)</p>
	<p>Down, down, down. Would the fall <span fontStyle="italic">never</span> come to an end! “I wonder how many miles I've fallen by this time?” she said aloud. “I must be getting somewhere near the centre of the earth. Let me see: that would be four thousand miles down, I think—” (for, you see, Alice had learnt several things of this sort in her lessons in the schoolroom, and though this was not a <span fontStyle="italic">very</span> good opportunity for showing off her knowledge, as there was no one to listen to her, still it was good practice to say it over) “—yes, that's about the right distance—but then I wonder what Latitude or Longitude I've got to?” (Alice had no idea what Latitude was, or Longitude either, but thought they were nice grand words to say.)</p>
	<p>Presently she began again. “I wonder if I shall fall right <span fontStyle="italic">through</span> the earth! How funny it'll seem to come out among the people that walk with their heads downward! The Antipathies, I think—” (she was rather glad there Was no one listening, this time, as it didn't sound at all the right word) “—but I shall have to ask them what the name of the country is, you know. Please, Ma'am, is this New Zealand or Australia?” (and she tried to curtsey as she spoke—fancy <span fontStyle="italic">curtseying</span> as you're falling through the air! Do you think you could manage it?) “And what an ignorant little girl she'll think me for asking! No, it'll never do to ask: perhaps I shall see it written up somewhere.”</p>
	<p>Down, down, down. There was nothing else to do, so Alice soon began talking again. “Dinah'll miss me very much to-night, I should think!” (Dinah was the cat.) “I hope they'll remember her saucer of milk at tea-time. Dinah my dear! I wish you were down here with me! There are no mice in the air, I'm afraid, but you might catch a bat, and that's very like a mouse, you know. But do cats eat bats, I wonder?” And here Alice began to get rather sleepy, and went on saying to herself, in a dreamy sort of way, “Do cats eat bats? Do cats eat bats?” and sometimes, “Do bats eat cats?” for, you see, as she couldn't answer either question, it didn't much matter which way she put it. She felt that she was dozing off, and had just begun to dream that she was walking hand in hand with Dinah, and saying to her very earnestly, “Now, Dinah, tell me the truth: did you ever eat a bat?” when suddenly, thump! thump! down she came upon a heap of sticks and dry leaves, and the fall was over.</p>
	<p>Alice was not a bit hurt, and she jumped up on to her feet in a moment: she looked up, but it was all dark overhead; before her was another long passage, and the White Rabbit was still in sight, hurrying down it. There was not a moment to be lost: away went Alice like the wind, and was just in time to hear it say, as it turned a corner, “Oh my ears and whiskers, how late it's getting!” She was close behind it when she turned the corner, but the Rabbit was no longer to be seen: she found herself in a long, low hall, which was lit up by a row of lamps hanging from the roof.</p>
	<p>There were doors all round the hall, but they were all locked; and when Alice had been all the way down one side and up the other, trying every door, she walked sadly down the middle, wondering how she was ever to get out again.</p>
	</TextFlow>;
	//this listElement is similar to japaneseParagraphText
private static var japaneseListElementText:XML = <TextFlow xmlns="http://ns.adobe.com/textLayout/2008">
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	
	<list paddingTop="24" listStyleType="decimal" styleName="scrollToThis"><li>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</li></list>
	
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	</TextFlow>
	//this listItemElement is similar to japaneseSpanText
private static var japaneseListItemElementText:XML = <TextFlow xmlns="http://ns.adobe.com/textLayout/2008">
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	
	<list paddingTop="24" listStyleType="decimal"><li styleName="scrollToThis">文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</li></list>
	
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	<p>文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。文字コードが割り当てられていないグリフの大半は既に文字コードが割り当てられているグリフの異体字です。次のセクションでは、このようなグリフにアクセスする方法について解説します。</p>
	</TextFlow>

		// The following tests all test scrolling to a range that is on multiple lines. The basic philosphy is to read in a TextFow markup which has text in red, 
		// with styleName "scrollToThis", find the range, and call scrollToThis to force the red text to be in view. We pass an initial scroll position, and
		// note whether scrolling to the "scrollToThis" range should have changed the scroll position, or not (if the text was already in view, then there
		// should have been no scroll). If a scroll was done, then the red text should appear on one of the edges of the container (left, right, top, or bottom). 
		// We check to make sure it aligns, and that all the text is visible.
		static private var multiLineTestData:Array = 
			[
				// Scroll to entire text
				[ "aliceTest", aliceExcerptText, BlockProgression.TB, Direction.LTR, 0, 0, false /* expect it to need to scroll */, checkBottomOrBelow ],
				[ "englishParagraphForwardTest", aliceScrollToParagraphText, BlockProgression.TB, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkBottomOrBelow ],
				[ "englishMultiLineSpanForwardTest", aliceScrollToSpanText, BlockProgression.TB, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkBottomOrBelow ],
				[ "englishParagraphBackwardTest", aliceScrollToParagraphText, BlockProgression.TB, Direction.LTR, 0, 16000, true /* expect it to need to scroll */, checkTop ],
				[ "englishMultiLineSpanBackwardTest", aliceScrollToSpanText, BlockProgression.TB, Direction.LTR, 0, 16000, true /* expect it to need to scroll */, checkTop ],
				[ "japaneseParagraphForwardTest", japaneseParagraphText, BlockProgression.RL, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkLeft ],
				[ "japaneseParagraphBackwardTest", japaneseParagraphText, BlockProgression.RL, Direction.LTR, -16000, 0, true /* expect it to need to scroll */, checkRight ],
				[ "japaneseSpanForwardTest", japaneseSpanText, BlockProgression.RL, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkLeft ],
				[ "japaneseSpanBackwardTest", japaneseSpanText, BlockProgression.RL, Direction.LTR, -16000, 0, true /* expect it to need to scroll */, checkRight ],
				[ "englishMultiLineListElementForwardTest", aliceScrollToListElementText, BlockProgression.TB, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkBottomOrBelow ],
				[ "englishMultiLineListElementBackwardTest", aliceScrollToListElementText, BlockProgression.TB, Direction.LTR, 0, 16000, true /* expect it to need to scroll */, checkTop ],
				[ "englishMultiLineListItemElementForwardTest", aliceScrollToListItemElementText, BlockProgression.TB, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkBottomOrBelow ],
				[ "englishMultiLineListItemElementBackwardTest", aliceScrollToListItemElementText, BlockProgression.TB, Direction.LTR, 0, 16000, true /* expect it to need to scroll */, checkTop ],
				[ "japaneseListElementForwardTest", japaneseListElementText, BlockProgression.RL, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkLeft ],
				[ "japaneseListElementBackwardTest", japaneseListElementText, BlockProgression.RL, Direction.LTR, -16000, 0, true /* expect it to need to scroll */, checkRight ],
				[ "japaneseListItemElementForwardTest", japaneseListItemElementText, BlockProgression.RL, Direction.LTR, 0, 0, true /* expect it to need to scroll */, checkLeft ],
				[ "japaneseListItemElementBackwardTest", japaneseListItemElementText, BlockProgression.RL, Direction.LTR, -16000, 0, true /* expect it to need to scroll */, checkRight ],
				
			];
		
		public function multiLineTest():TextRange
		{
			// get id and run the right test
			for each (var testData:Array in multiLineTestData)
			{
				if (testData[0] == TestData.id)
				{
					return scrollMultiLine(testData[1], testData[2], testData[3], testData[4], testData[5], testData[6], testData[7]);
				}
			}
			assertTrue("XML test case didn't match XML test data", false);
			return null;
		}
		
		public function singleLineTest():TextRange
		{
		
			var r:TextRange;
			
			// get id and run the right test
			for each (var testData:Array in singleLineTestData)
			{
				if (testData[0] == TestData.id)
				{
					return scrollSingleLine(testData[1], testData[2], testData[3], testData[4], testData[5], testData[6], testData[7]);
				}
			}
			assertTrue("XML test case didn't match XML test data", false);
			return null;
		}
		
		// Check that we don't force composition to end of range
		public function aliceTest():void
		{
			var r:TextRange = multiLineTest();
			assertTrue("Scroll to range shouldn't force composition to end of range", r.textFlow.flowComposer.damageAbsoluteStart < r.textFlow.textLength - 100);
		}
		
		public function aboveAndBelow():void
		{
			var markup:String = '<TextFlow fontSize ="60" whiteSpaceCollapse="preserve" version="2.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>one two three four</span></p><p><span>five six</span></p><p><span>seven eight</span></p><p><span>nine ten </span></p><p><span>eleven twelve</span></p><p><span>thirteen fourteen</span></p><p><span>fifteen sixteen</span></p><p><span>seventeen eighteen</span></p><p><span>nineteen twenty</span></p><p><span>twenty-one twenty-two</span></p><p><span>twenty-three twenty-four twenty-five twenty-six twenty-seven</span></p></TextFlow>';
			
			// Test scroll to range when the range extends both above and below the visible area
			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			VellumTestCase.testApp.contentChange (textFlow);
			VellumTestCase.testApp.changeContainerSetup("arrangeSideBySide", 0, 2);
			var secondController:ContainerController = textFlow.flowComposer.getControllerAt(1);
			secondController.verticalScrollPosition = 50;		// scroll to arbitrary location, not at 0.
			var oldScrollPos:Number = secondController.verticalScrollPosition;
			secondController.scrollToRange(0, textFlow.textLength - 1);
			assertTrue("Should be no scroll when range is above *and* below", oldScrollPos == secondController.verticalScrollPosition);
			VellumTestCase.testApp.changeContainerSetup("arrangeSideBySide", 0, 1);
		}
			
		private function scrollMultiLine(text:XML, blockProgression:String, direction:String, initialHorizontalScroll:Number, initialVerticalScroll:Number, expectScroll:Boolean, checkWhere:Function):TextRange
		{
			var width:Number = 300;
			var height:Number = 400;
			
			if (blockProgression == BlockProgression.RL)// swap width & height
			{
				var tmp:Number = width;
				width = height;
				height = tmp;
			}
			var r:TextRange = setUpForTest(text, LineBreak.TO_FIT, blockProgression, direction, initialHorizontalScroll, initialVerticalScroll, width, height);	
			var controller:ContainerController = r.textFlow.flowComposer.getControllerAt(0);
			var oldScrollPosition:Number = controller.verticalScrollPosition;
			controller.scrollToRange(r.absoluteStart, r.absoluteEnd);
			if (!expectScroll)
				assertTrue("Expected no scrolling", oldScrollPosition == controller.verticalScrollPosition);
			checkWhere(r);
			return r;
		}
		
		private function scrollSingleLine(text:String, blockProgression:String, direction:String, initialHorizontalScroll:Number, initialVerticalScroll:Number, expectScroll:Boolean, checkWhere:Function):TextRange
		{
			var width:Number = 186;
			var height:Number = 149;
			
			if (blockProgression == BlockProgression.RL)// swap width & height
			{
				var tmp:Number = width;
				width = height;
				height = tmp;
			}
			var r:TextRange = setUpForTest(text, LineBreak.EXPLICIT, blockProgression, direction, initialHorizontalScroll, initialVerticalScroll, width, height);	
			var controller:ContainerController = r.textFlow.flowComposer.getControllerAt(0);
			var oldScrollPosition:Number = controller.horizontalScrollPosition;
			controller.scrollToRange(r.absoluteStart, r.absoluteEnd);
			if (!expectScroll)
				assertTrue("Expected no scrolling", oldScrollPosition == controller.horizontalScrollPosition);
			checkWhere(r);
			return r;
		}
		
		static private function getBBox(r:TextRange, controller:ContainerController):Rectangle
		{
			var container:Sprite = controller.container;
			
			r.absoluteEnd = Math.min(r.absoluteEnd, r.textFlow.flowComposer.damageAbsoluteStart - 1);
			
			// if we can't get the bounding box it might not be visible		
			var result:Array = GeometryUtil.getHighlightBounds(r);
			assertTrue("Expecting at least one line in range", result.length > 0);
			if (result.length > 0)
				assertTrue("Expected to see red text - is it not visible?", result[0].rect != null);
			
			// collect the bounding box in global coords
			var bbox:Rectangle = null;
			for (var i:int = 0; i < result.length; ++i)
			{
				var textLine:TextLine = result[i].textLine;
				if (!textLine.parent)
				{
					var textFlowLine:TextFlowLine = textLine.userData as TextFlowLine;
					textLine = textFlowLine.getTextLine();
				}
				if (textLine.parent)
				{
					var tmpBox:Rectangle = result[i].rect.clone();
					tmpBox.topLeft = textLine.localToGlobal(tmpBox.topLeft);
					tmpBox.bottomRight = textLine.localToGlobal(tmpBox.bottomRight);
					bbox = bbox ? bbox.union(tmpBox) : tmpBox;
				}
			}
			if (bbox)	// translate to container coords
			{
				bbox.topLeft = container.globalToLocal(bbox.topLeft);
				bbox.bottomRight = container.globalToLocal(bbox.bottomRight);
			}
			return bbox;
		}
		
		// Expecting range to appear in the container
		static private function checkHorizontalInView(r:TextRange):void
		{
			var controller:ContainerController = r.textFlow.flowComposer.getControllerAt(0);
			var bbox:Rectangle = getBBox(r, controller);
			
			// bounding box should be within 10% of the container right edge
			assertTrue(bbox.left > controller.horizontalScrollPosition - 2 &&
				bbox.right < (controller.compositionWidth - controller.horizontalScrollPosition) + 2, "Expected bounding box to be in view");
			var distanceFromLeftEdge:Number = bbox.left - controller.horizontalScrollPosition;
		}
		
		static private function getController(r:TextRange):ContainerController
		{
			var controllerIndex:int = r.textFlow.flowComposer.findControllerIndexAtPosition(r.absoluteStart);
			if (controllerIndex >= 0)
				return r.textFlow.flowComposer.getControllerAt(controllerIndex);
			return null;
		}

		static private function checkOnScreen(bbox:Rectangle, controller:ContainerController):void
		{
			var screenBBox:Rectangle;
			var screenLeft:Number = controller.horizontalScrollPosition;
			
			if (controller.rootElement.blockProgression == BlockProgression.RL)
				screenLeft -= controller.compositionWidth;
			
			screenBBox = new Rectangle(screenLeft, controller.verticalScrollPosition, controller.compositionWidth, controller.compositionHeight);
			assertTrue("Range should appear somewhere on screen", bbox.intersects(screenBBox));
		}
		
		// Expecting range to appear on the left edge, assert if not
		static private function checkLeft(r:TextRange):void
		{
			var controller:ContainerController = getController(r);
			var bbox:Rectangle = getBBox(r, controller);
			checkOnScreen(bbox, controller);
			
			// bounding box should be within 10% of the container right edge
			var distanceFromLeftEdge:Number;
			if (r.textFlow.blockProgression == BlockProgression.RL)
				distanceFromLeftEdge = bbox.left - (controller.horizontalScrollPosition - controller.compositionWidth);
			else   // don't check logical horizontal position
				distanceFromLeftEdge = 0; //bbox.left - controller.horizontalScrollPosition;
			assertTrue("Expected to see red text on left edge of container", Math.abs(distanceFromLeftEdge) < 10);
		}
		
		// Expecting range to appear on the right edge, assert if not
		static private function checkRight(r:TextRange):void
		{
			var controller:ContainerController = getController(r);
			var bbox:Rectangle = getBBox(r, controller);
			checkOnScreen(bbox, controller);
			
			// bounding box should be within 10% of the container right edge
			var distanceFromRightEdge:Number;
			if (r.textFlow.blockProgression == BlockProgression.RL)
				distanceFromRightEdge = bbox.right - controller.horizontalScrollPosition;
			else   //don't check logical horizontal position
				distanceFromRightEdge = 0; // bbox.right - controller.compositionWidth - controller.horizontalScrollPosition;
			assertTrue("Expected to see red text on right edge of container", Math.abs(distanceFromRightEdge) < 10);
		}
		
		// Expecting range to appear on the top edge, assert if not
		static private function checkTop(r:TextRange):void
		{
			var controller:ContainerController = getController(r);
			var bbox:Rectangle = getBBox(r, controller);
			checkOnScreen(bbox, controller);
			
			// bounding box should be within 10% of the container right edge
			var distanceFromTopEdge:Number = bbox.top - controller.verticalScrollPosition;
			assertTrue("Expected to see red text on top edge of container", Math.abs(distanceFromTopEdge) < 10);
		}

		// Expecting range to appear on the top edge, assert if not
		static private function checkTopOrAbove(r:TextRange):void
		{
			var controller:ContainerController = getController(r);
			var bbox:Rectangle = getBBox(r, controller);
			checkOnScreen(bbox, controller);
			
			// bounding box should straddle the top edge
			var containerTop:Number = controller.verticalScrollPosition;
			assertTrue("Expected to see red text on top edge of container", bbox.top < containerTop && bbox.bottom >= containerTop);
		}
		
		// Expecting range to appear intersecting the bottom edge, assert if not
		static private function checkBottomOrBelow(r:TextRange):void
		{
			var controller:ContainerController = getController(r);
			var bbox:Rectangle = getBBox(r, controller);
			checkOnScreen(bbox, controller);
			
			// bounding box should straddle the bottom edge
			var containerBottom:Number = controller.compositionHeight + controller.verticalScrollPosition;
			assertTrue("Expected to see red text on bottom edge of container", bbox.top < containerBottom+1 && bbox.bottom >= containerBottom-1);
		}
		
		// Expecting range to appear on the bottom edge, assert if not
		static private function checkBottom(r:TextRange):void
		{
			var controller:ContainerController = getController(r);
			var bbox:Rectangle = getBBox(r, controller);
			checkOnScreen(bbox, controller);
			
			// bounding box should be within 10% of the container right edge
			
			var distanceFromBottomEdge:Number = bbox.bottom - (controller.verticalScrollPosition + controller.compositionHeight);
			assertTrue("Expected to see red text on bottom edge of container", Math.abs(distanceFromBottomEdge) < 10);
		}
		
		private function setUpForTest(content:Object, lineBreak:String, blockProgression:String, direction:String, 
									  initialHorizontalScrollPosition:int, initialVerticalScrollPosition:int,
									  width:Number, height:Number):TextRange
		{
			var bg:Sprite = new Sprite();
			bg.x = 100;
			bg.y = 100;
			var container:Sprite = new Sprite();
			addChild(container);
			var g:Graphics = bg.graphics;
			g.beginFill(0x777777);
			g.drawRect(0, 0, width, height);
			g.endFill();
			
			if (content is String)
				content = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008">' + content + '</TextFlow>';
			
			var textFlow:TextFlow = TextConverter.importToFlow(content, TextConverter.TEXT_LAYOUT_FORMAT);
			var controller:ContainerController = new ContainerController(container, width, height);
			textFlow.flowComposer.addController(controller);
			
			var format:TextLayoutFormat = new TextLayoutFormat(TextLayoutFormat.defaultFormat);
			format.fontFamily = "Arial";
			format.blockProgression = blockProgression;
			format.direction = direction;
			format.fontSize = 12;
			format.lineBreak = lineBreak;
			format.styleName = textFlow.styleName;
			textFlow.format = format;
			textFlow.interactionManager = new EditManager();
			
			// Find the scroll to this span, mark it in red to make it easy to see
			var scrollToElement:FlowElement = findScrollToElement(textFlow);
			assertTrue("Test missing scrollToThis span", scrollToElement != null);
			var scrollStart:int = scrollToElement.getAbsoluteStart();
			setFormatOfRange(textFlow, scrollStart, scrollStart + scrollToElement.textLength);
			
			textFlow.interactionManager.selectRange(0, 0);
			controller.horizontalScrollPosition = initialHorizontalScrollPosition;
			controller.verticalScrollPosition = initialVerticalScrollPosition;
			textFlow.flowComposer.updateAllControllers();
			return new TextRange(textFlow, scrollStart, scrollStart + scrollToElement.textLength);
		}
		
		static private function findScrollToElement(element:FlowElement):FlowElement
		{
			if (element.styleName == "scrollToThis")
				return element;
			var scrollToElement:FlowElement = null;
			if (element is FlowGroupElement)
			{
				var group:FlowGroupElement = FlowGroupElement(element);
				for (var i:int = group.numChildren - 1; i >= 0 && !scrollToElement; --i)
					scrollToElement = findScrollToElement(group.getChildAt(i));
			}
			return scrollToElement;
		}
				
		static private function setFormatOfRange(textFlow:TextFlow, anchorPosition:int,
										 activePosition:int):void
		{
			var characterFormat:TextLayoutFormat;
			
			characterFormat =  new TextLayoutFormat();
			characterFormat["color"] = "0xFF0000";
			
			var selectionState:SelectionState =
				new SelectionState(textFlow, anchorPosition, activePosition);
			
			(textFlow.interactionManager as EditManager).applyFormat(characterFormat, null, null, selectionState);
		}
		
	}
}
	
// Test the ability to scroll ahead in logical order, to the right
// Cases:
//	- scroll * ^ # tb-ltr
// 	- scroll * ^ # tb-rtl (arabic text)
//	- scroll * ^ # rl-ltr (J text)
//	- scroll * ^ # rl-ltr (J text with tcy)
//	- scroll * ^ # rl-ltr (J text selection in tcy)
//	- scroll * ^ # rl-ltr (J text selection in two different tcy's)
//	- scroll * ^ # tb-ltr
// 	- scroll * ^ # tb-rtl (arabic text)
//
// * = ahead or back in logical order
// ^ = 	select in same line; 
//		selection in different lines, same column, same container;
//		selection in different lines, different column, same container
//		selection in different lines, different column, different containers, all visible (have containers & attached to stage)
//		selection in different lines, different column, different containers, some visible
//		selection in different lines, different column, different containers, none visible
// # 	lineBreak = toFit or explicit
//
//	test when its already there: assert that it didn't scroll
// 	test when it had to scroll that part of selection is now visible
//
// Test:
// 		iterate lines in range
//			at least one should have:
//				parent = container
//				bbox intersects container
//		if one line in range
//			get bbox of span
//			bbox intersects container
//		


