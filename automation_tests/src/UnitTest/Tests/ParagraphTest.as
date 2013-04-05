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
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.IBitmapDrawable;
    import flash.events.*;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.text.engine.TabAlignment;
    import flash.text.engine.TextLine;
    import flash.utils.ByteArray;
    
    import flashx.textLayout.compose.TextFlowLine;
    import flashx.textLayout.elements.*;
    import flashx.textLayout.formats.*;
    import flashx.textLayout.property.NumberPropertyHandler;
    import flashx.textLayout.property.Property;
    import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

 	public class ParagraphTest extends VellumTestCase
	{

		public function ParagraphTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Text Container";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
 			var testCaseClass:Class = ParagraphTest;
 			VellumTestCase.suiteFromXML(testCaseClass, testListXML, testConfig, ts);
 		}

		/* Unused private functions
		private function getParaCount():uint  // return the number of paragraphs KJT
		{

			SelManager.selectAll();
			var startOfPara:int = SelManager.anchorPosition;

			var endOfPara:int = SelManager.activePosition;
			var curCount:uint = 0;
			var i:int;

			for (i = startOfPara; i <= endOfPara; i++)
			{
				var para:Object = SelManager.textFlow.findAbsoluteParagraph(i);

				if(i == ParagraphElement(para).parentRelativeStart){
					curCount++;
				}
			}

			return curCount;
		}

		private function getAparaGraph(index:uint):ParagraphElement  // return a p by index KJT
		{

			SelManager.selectAll();
			var arrayOfP:Array = new Array();
			var startOfPara:int = SelManager.anchorPosition;

			var endOfPara:int = SelManager.activePosition;
			var curCount:uint = 0;
			var i:int;

			for (i = startOfPara; i <= endOfPara; i++)
			{
				var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(i);

				if(i == para.parentRelativeStart){
					arrayOfP.push(para);
					curCount++;
				}
			}

			return ParagraphElement(arrayOfP[index]);
		}
		*/

		/* ************************************************************** */
		/* Alignment Tests */
		/* ************************************************************** */

		/**
		 * Get a short selection and set the alignment to left align and
		 * check that it is set correctly.
		 */
		public function alignLeftTest():void
		{
			// Set the selection.
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx,endIndx);
			// Set the alignment.
			setAlignment(TextAlign.LEFT);
			// Confirm the alignment was set.
			assertTrue("alignment is not left - it's " + getAlignment(), getAlignment() == TextAlign.LEFT);
		}

		/**
		 * Get a short selection and set the alignment to right align and
		 * check that it is set correctly.
		 */
		public function alignRightTest():void
		{
			// Set the selection.
			var startIndx:int = 20;
			var endIndx:int = 40;
			SelManager.selectRange(startIndx,endIndx);
			// Set the alignment.
			setAlignment(TextAlign.RIGHT);
			// Confirm the alignment was set.
			assertTrue("alignment is not right - it's " + getAlignment(), getAlignment() == TextAlign.RIGHT);
		}

		/**
		 * Set the alignment to right align for all of the text and
		 * check that it is set correctly.
		 */
		public function alignAllRightTest():void
		{
			// Set the selection /
			var startIndx:int = 0;
			var endIndx:int = SelManager.textFlow.textLength - 1;
			SelManager.selectRange(startIndx,endIndx);  // select across paragraphs KJT
			// Set the alignment.
			setAlignment(TextAlign.RIGHT);
			// Confirm the alignment was set.
			assertTrue("alignment is not right - it's " + getAlignment(), getAlignment() == TextAlign.RIGHT);
		}

		/**
		 * Set the alignment to START align for all of the text and
		 * check that it is set correctly.
		 */
		public function alignStartTest():void
		{
			// Set the selection.
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx,endIndx);
			// Set the alignment.
			setAlignment(TextAlign.START);
			// Confirm the alignment was set.
			assertTrue("alignment should be " + TextAlign.START + " but, actually is " + getAlignment(), getAlignment() == TextAlign.START);
		}

		/**
		 * Set the alignment to END align for all of the text and
		 * check that it is set correctly.
		 */
		public function alignEndTest():void
		{
			// Set the selection.
			var startIndx:int = 20;
			var endIndx:int = 40;
			SelManager.selectRange(startIndx,endIndx);
			// Set the alignment.
			setAlignment(TextAlign.END);
			// Confirm the alignment was set.
			assertTrue("alignment should be " + TextAlign.END + " but, actually is " + getAlignment(), getAlignment() == TextAlign.END);
		}


		/**
		 * Get a short selection and set the alignment to center align and
		 * check that it is set correctly.
		 */
		public function alignCenterTest():void
		{
			// Set the selection.
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx,endIndx);
			// Set the alignment.
			setAlignment(TextAlign.CENTER);
			// Confirm the alignment was set.
			assertTrue("alignment is not center - it's " + getAlignment(), getAlignment() == TextAlign.CENTER);

		}

		/**
		 * Get a short selection and set the alignment to justify "all including last" and
		 * check that it is set correctly.
		 */
		public function alignJustifyAllTest():void
		{
			// Set the selection.
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx,endIndx);
			// Set the alignment.
			setAlignment(TextAlign.JUSTIFY);
			setAlignmentLast(TextAlign.JUSTIFY);
			// Confirm the alignment was set.
			assertTrue("alignment is not justify - it's " + getAlignment() + " and " + getAlignmentLast(),
						getAlignment() == TextAlign.JUSTIFY && getAlignmentLast() == TextAlign.JUSTIFY);
		}

		/**
		 * Get a short selection and set the alignment to justify "all but last" and
		 * check that it is set correctly.
		 */
		public function alignJustifyAllButLastTest():void
		{
			// Set the selection.
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx,endIndx);
			// Set the alignment.
			setAlignment(TextAlign.JUSTIFY);
			// Confirm the alignment was set.
			assertTrue("alignment is not justify - it's " + getAlignment(), getAlignment() == TextAlign.JUSTIFY);
		}

		/**
		 * Get a short selection and set the alignment to justify with last line start, end, left, center, right and
		 * check that it is set correctly.
		 */
		public function justifyWithLastLineStart():void
		{
			// Set the selection.
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx,endIndx);
			// Set the alignment.
			setAlignment(TextAlign.JUSTIFY);
			setAlignmentLast(TextAlign.START);
			// Confirm the alignment was set.
			assertTrue("alignment should be " + TextAlign.JUSTIFY + " but, actually is " + getAlignment(),
				getAlignment() == TextAlign.JUSTIFY);
			assertTrue("last line alignment should be " + TextAlign.START + " but, actually is " + getAlignmentLast(),
				getAlignmentLast() == TextAlign.START);
		}

		public function justifyWithLastlineEnd():void
		{
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx, endIndx);

			setAlignment(TextAlign.JUSTIFY);
			setAlignmentLast(TextAlign.END);

			assertTrue("alignment should be " + TextAlign.JUSTIFY + " but, actually is " + getAlignment(),
				getAlignment() == TextAlign.JUSTIFY);
			assertTrue("last line alignment should be " + TextAlign.END + " but, actually is " + getAlignmentLast(),
				getAlignmentLast() == TextAlign.END);
		}

		public function justifyWithLastlineLeft():void
		{

			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx, endIndx);

			setAlignment(TextAlign.JUSTIFY);
			setAlignmentLast(TextAlign.LEFT);

			assertTrue("alignmnet should be " + TextAlign.JUSTIFY + " but, actually is " + getAlignment(),
				getAlignment() == TextAlign.JUSTIFY);
			assertTrue("last line alignment should be " + TextAlign.JUSTIFY + " but, actually is " + getAlignmentLast(),
				getAlignmentLast() == TextAlign.LEFT);
		}

		public function justifyWithLastlineCenter():void
		{
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx, endIndx);

			setAlignment(TextAlign.JUSTIFY);
			setAlignmentLast(TextAlign.CENTER);

			assertTrue("alignmnet should be " + TextAlign.JUSTIFY + " but, actually is " + getAlignment(),
				getAlignment() == TextAlign.JUSTIFY);
			assertTrue("last line alignment should be " + TextAlign.CENTER + " but, actually is " + getAlignmentLast(),
				getAlignmentLast() == TextAlign.CENTER);
		}

		public function justifyWithLastlineRight():void
		{
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx, endIndx);

			setAlignment(TextAlign.JUSTIFY);
			setAlignmentLast(TextAlign.RIGHT);

			assertTrue("alignment should be " + TextAlign.JUSTIFY + " but, actually is " + getAlignment(),
				getAlignment() == TextAlign.JUSTIFY);
			assertTrue("last lie alignmnet shold be " + TextAlign.RIGHT + " but, actually is " + getAlignmentLast(),
				getAlignmentLast() == TextAlign.RIGHT);
		}

		public function OnlyLastlineSet():void
		{
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx, endIndx);

			setAlignmentLast(TextAlign.RIGHT);

			assertTrue("alignment should be " + TextAlign.START + " (default) but, actually is " + getAlignment(),
				getAlignment() == TextAlign.START);
			assertTrue("last lie alignmnet shold be " + TextAlign.RIGHT + " but, actually is " + getAlignmentLast(),
				getAlignmentLast() == TextAlign.RIGHT);
		}

		/**
		 * Get a short selection and set the textJustify to INTER_WORD and
		 * check that it is set correctly.
		 */
		public function justifyInterWordTest():void
		{
			// Set the selection.
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx,endIndx);
			// Set the alignment.
			setTextJustify(TextJustify.INTER_WORD);
			// Confirm the alignment was set.
			assertTrue("textJustify is not interWord - it's " + getTextJustify(),
						getTextJustify() == TextJustify.INTER_WORD);
		}

		/**
		 * Set textJustify to INTER_WORD and DISTRIBUTE and verify
		 * that the spacing between glyphs is different on first line.
		 *
		 * Test with both last line set to JUSTIFY and to LEFT.
		 */
		public function justifyLetterSpacingFirstLine():void
		{
			justifyInterWordVsDistributeCore(false, false);
			justifyInterWordVsDistributeCore(false, true);
		}
		/**
		 * Set textJustify to INTER_WORD and DISTRIBUTE and verify
		 * that the spacing between glyphs is different on last line
		 * with last line set to JUSTIFY
		 */
		public function justifyLetterSpacingLastLineJustify():void
		{
			justifyInterWordVsDistributeCore(true, true);
		}
		/**
		 * Set textJustify to INTER_WORD and DISTRIBUTE and verify
		 * that the spacing between glyphs is not different on last line
		 * with last line justification set to LEFT
		 */
		public function justifyLetterSpacingLastLineNoJustify():void
		{
			justifyInterWordVsDistributeCore(true, false);
		}


		private function justifyInterWordVsDistributeCore(lastLine:Boolean, justifyLastLine:Boolean):void
		{
			var longWordText:String = "Longlonglonglonglonglong \
Longlonglonglonglonglong Longlonglonglonglonglong Longlonglonglonglonglong \
Longlonglonglonglonglong Longlonglonglonglonglong Longlonglonglonglonglong \
Longlonglonglonglonglong Longlonglonglonglonglong Longlonglonglonglonglong \
LonglonglonglonglonglongLong longlonglonglonglong Longlonglonglonglonglong.";
			var longWordTextLastPosition:int = longWordText.length - 1;

			SelManager.selectAll();
		 	SelManager.insertText(longWordText);

		 	SelManager.selectRange(1,1);
			setAlignment(TextAlign.JUSTIFY);
			setAlignmentLast(justifyLastLine ? TextAlign.JUSTIFY : TextAlign.LEFT);

			// capture block progression so we know whether glyph spacing will happen
			// along x or y axis.
			var bp:String = SelManager.textFlow.computedFormat.blockProgression;
			var line:TextLine;


			setTextJustify(TextJustify.INTER_WORD);

			if(lastLine)
			{
				line = SelManager.textFlow.flowComposer.findLineAtPosition(longWordTextLastPosition).getTextLine(true);
			}
			else
			{
				line = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine(true);
			}


			var xPosInterWord:Array = new Array();

			// Collect the x coordinates for each glyph
			for ( var i:int = 0; i < line.atomCount; i++)
			{
				var r:Rectangle = line.getAtomBounds(i);
				xPosInterWord.push(Number(bp == BlockProgression.TB ? r.x : r.y));
			}

			setTextJustify(TextJustify.DISTRIBUTE);

			if(lastLine)
			{
				line = SelManager.textFlow.flowComposer.findLineAtPosition(longWordTextLastPosition).getTextLine(true);
			}
			else
			{
				line = SelManager.textFlow.flowComposer.getLineAt(0).getTextLine(true);
			}

			var xPosDistribute:Array = new Array();

			// Collect the x coordinates for each glyph
			for ( i = 0; i < line.atomCount; i++)
			{
				r = line.getAtomBounds(i);
				xPosDistribute.push(Number(bp == BlockProgression.TB ? r.x : r.y));
			}

			var foundDifferentSpacing:Boolean = false;
			for( i=0; i<xPosInterWord.length; ++i)
			{
				if(xPosInterWord[i] != xPosDistribute[i])
				{
					foundDifferentSpacing = true;
				}
			}

			assertTrue("Line length changed as a result of changing textJustify setting! ",
					xPosInterWord.length == xPosDistribute.length);

			if(lastLine && !justifyLastLine)
			{
				assertTrue("Letterspacing on/off moved glyphs on unjustified last line in paragraph!",
					!foundDifferentSpacing);
			}
			else
			{
				assertTrue("Letterspacing on/off did not move glyphs in justified text!",
						foundDifferentSpacing);
			}

		}

		/**
		 *
		 * Get a short selection and set the textJustify to DISTRIBUTE and
		 * check that it is set correctly.
		 */
		public function justifyDistributeTest():void
		{
			// Set the selection.
			var startIndx:int = 10;
			var endIndx:int = 20;
			SelManager.selectRange(startIndx,endIndx);
			// Set the alignment.
			setTextJustify(TextJustify.DISTRIBUTE);
			// Confirm the alignment was set.
			assertTrue("textJustify is not distribute - it's " + getTextJustify(),
						getTextJustify() == TextJustify.DISTRIBUTE);
		}

		private function setAlignment(attrValue:String):void
		{
			var pa:TextLayoutFormat = new TextLayoutFormat();
			pa.textAlign = attrValue;
			SelManager.applyParagraphFormat(pa);
		}

		private function getAlignment():String
		{
			var startOfPara:int = SelManager.anchorPosition;
			var endOfPara:int = SelManager.activePosition;
			var curAlign:Object = null;
			var i:int;

			for (i = startOfPara; i <= endOfPara; i++)
			{
				var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(i);
			    var paraAttr:ITextLayoutFormat = para.computedFormat;
				if (curAlign == null)
					curAlign = paraAttr.textAlign;
				else if (curAlign != String(paraAttr.textAlign))
				{
					curAlign = "Mixed";
					break;
				}
			}
			return String(curAlign);
		}

		private function setTextJustify(attrValue:String):void
		{
			var pa:TextLayoutFormat = new TextLayoutFormat();
			pa.textJustify = attrValue;
			SelManager.applyParagraphFormat(pa);
		}

		private function getTextJustify():String
		{
			var startOfPara:int = SelManager.anchorPosition;
			var endOfPara:int = SelManager.activePosition;
			var curJustify:Object = null;
			var i:int;

			for (i = startOfPara; i <= endOfPara; i++)
			{
				var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(i);
			    var paraAttr:ITextLayoutFormat = para.computedFormat;
				if (curJustify == null)
					curJustify = paraAttr.textJustify;
				else if (curJustify != String(paraAttr.textJustify))
				{
					curJustify = "Mixed";
					break;
				}
			}
			return String(curJustify);
		}

		private function setAlignmentLast(attrValue:String):void
		{
			var pa:TextLayoutFormat = new TextLayoutFormat();
			pa.textAlignLast = attrValue;
			SelManager.applyParagraphFormat(pa);
		}

		private function getAlignmentLast():String
		{
			var startOfPara:int = SelManager.anchorPosition;
			var endOfPara:int = SelManager.activePosition;
			var curAlign:Object = null;
			var i:int;

			for (i = startOfPara; i <= endOfPara; i++)
			{
				var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(i);
			    var paraAttr:ITextLayoutFormat = para.computedFormat;
				if (curAlign == null)
					curAlign = paraAttr.textAlignLast;
				else if (curAlign != String(paraAttr.textAlignLast))
				{
					curAlign = "Mixed";
					break;
				}
			}
			return String(curAlign);
		}

		/* ************************************************************** */
		/* Indent Tests */
		/* ************************************************************** */


		/**
		 * Set an indent of ten and check that it is set correctly.
		 */
		public function setIndentPositiveTest():void
		{
			setIndent(10);
			assertTrue("indent is not 10", getIndent(10));
		}

		/**
		 * Set an indent of negative ten and check that it is set correctly.
		 */
		public function setIndentNegativeTest():void
		{
			setIndent(-10);
			assertTrue("indent is not -10", getIndent(-10));
		}

		private function setIndent(amount:Number):void
		{
			var pa:TextLayoutFormat = new TextLayoutFormat();
			pa.textIndent = amount;
			SelManager.applyParagraphFormat(pa);
		}

		private function getIndent(amount:Number = -1):Boolean
		{
			var startOfPara:int = SelManager.anchorPosition;
			var endOfPara:int = SelManager.activePosition;
			var curIndent:Object =(amount == -1) ? null : Object(amount);
			var i:int;
			var success:Boolean = true;

			for (i = startOfPara; i <= endOfPara; i++)
			{
				var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(i);
			    var paraAttr:ITextLayoutFormat = para.format;

				if (curIndent == -1)
					curIndent = paraAttr.textIndent;
				else if (curIndent != paraAttr.textIndent)
				{

					success = false;
					break;
				}
			}
			return success;
		}

		/* ************************************************************** */
		/* Left Margin Tests */
		/* ************************************************************** */

		/**
		 * Set a left margin of ten and check that it is set correctly.
		 */
		public function setLeftMarginPositiveTest():void
		{
			setLeftMargin(10);
			assertTrue("margin is not 10", getLeftMargin(10));
		}

		/**
		 * Set a left margin of negative ten and check that it is set to zero
		 * (i.e. no negative left margins).
		 */
		public function setLeftMarginNegativeTest():void
		{
			setLeftMargin(-10,true);
			assertTrue("margin is not 0", getLeftMargin(0)); // set test value to 0 I don't think you can have a negative margin KJT
		}

		private var errorCount:int;
		private function myErrorHandler(p:Property,value:Object):void
		{
			errorCount++;
		}


		private function setLeftMargin(amount:Number,expectError:Boolean = false):void
		{
			var savedErrorHandler:Function = Property.errorHandler;
			errorCount = 0;
			Property.errorHandler = myErrorHandler;
			var pa:TextLayoutFormat = new TextLayoutFormat();
			pa.paragraphStartIndent = amount;
			Property.errorHandler = savedErrorHandler;

			if (expectError)
				assertTrue("expected error not received",errorCount == 1);
			else
				assertTrue("unexpected error received",errorCount == 0);

			if (!expectError)
				SelManager.applyParagraphFormat(pa);
		}

		private function getLeftMargin(amount:Number = -1):Boolean
		{
			var startOfPara:int = SelManager.anchorPosition;
			var endOfPara:int = SelManager.activePosition;
			var curAmount:Object = null;
			if (amount != -1)
				curAmount = Object(amount);
			var i:int;
			var success:Boolean = true;

			for (i = startOfPara; i <= endOfPara; i++)
			{
				var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(i);
			    var paraAttr:ITextLayoutFormat = para.computedFormat;
				if (curAmount == null)
					curAmount = paraAttr.paragraphStartIndent;
				else if (curAmount != paraAttr.paragraphStartIndent)
				{
					success = false;
					break;
				}
			}
			return success;
		}

		/* ************************************************************** */
		/* Right Margin Tests */
		/* ************************************************************** */


		/**
		 * Set a right margin of ten and check that it is set correctly.
		 */
		public function setRightMarginPositiveTest():void
		{
			setRightMargin(10);
			assertTrue("right margin is not 10", getRightMargin(10));
		}

		/**
		 * Set a right margin of negative ten and check that it is set to zero
		 * (i.e. no negative right margins).
		 */
		public function setRightMarginNegativeTest():void
		{
			setRightMargin(-10,true);

			assertTrue("right margin is not 0", getRightMargin(0)); // set test value to 0 I don't think you can have a negative margin KJT

		}

		private function setRightMargin(amount:Number,expectError:Boolean = false):void
		{
			var savedErrorHandler:Function = Property.errorHandler;
			errorCount = 0;
			Property.errorHandler = myErrorHandler;
			var pa:TextLayoutFormat = new TextLayoutFormat();
			pa.paragraphEndIndent = amount;
			Property.errorHandler = savedErrorHandler;

			if (expectError)
				assertTrue("expected error not received",errorCount == 1);
			else
				assertTrue("unexpected error received",errorCount == 0);

			if (!expectError)
				SelManager.applyParagraphFormat(pa);
		}

		private function getRightMargin(amount:Number = -1):Boolean
		{
			var startOfPara:int = SelManager.anchorPosition;
			var endOfPara:int = SelManager.activePosition;
			var curAmount:Object = null;
			if (amount != -1)
				curAmount = Object(amount);
			var i:int;
			var success:Boolean = true;

			for (i = startOfPara; i <= endOfPara; i++)
			{
				var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(i);
			    var paraAttr:ITextLayoutFormat = para.computedFormat;
				if (curAmount == null)
					curAmount = paraAttr.paragraphEndIndent;
				else if (curAmount != paraAttr.paragraphEndIndent)
				{

					success = false;
					break;
				}
			}
			return success;
		}

		/* ************************************************************** */
		/* Space Before Tests */
		/* ************************************************************** */

		/**
		 * Set space before value to twenty-five and check that it is set correctly.
		 */
		public function setSpaceBeforePositiveTest():void
		{
			setSpaceBefore(25);
			assertTrue("space before is not 25", getSpaceBefore(25));
		}

		/**
		 * Set space before value to negative fifty and check that it is zero
		 * (i.e. no negative space before values).
		 */
		public function setSpaceBeforeNegativeTest():void
		{
			setSpaceBefore(-50,true);
			assertTrue("space before is not 0", getSpaceBefore(0)); // set test value to 0 I don't think you can have a negative spaceBefore KJT

		}

		private function setSpaceBefore(spaceBeforeValue:Number,expectError:Boolean = false):void
		{
			var savedErrorHandler:Function = Property.errorHandler;
			errorCount = 0;
			Property.errorHandler = myErrorHandler;
			var pa:TextLayoutFormat = new TextLayoutFormat();
			pa.paragraphSpaceBefore = spaceBeforeValue;
			Property.errorHandler = savedErrorHandler;

			if (expectError)
				assertTrue("expected error not received",errorCount == 1);
			else
				assertTrue("unexpected error received",errorCount == 0);

			if (!expectError)
				SelManager.applyParagraphFormat(pa);
		}

		private function getSpaceBefore(amount:Number = -1):Boolean
		{
			var startOfPara:int = SelManager.anchorPosition;
			var endOfPara:int = SelManager.activePosition;
			var curAmount:Object = null;
			if (amount != -1)
				curAmount = Object(amount);
			var i:int;
			var success:Boolean = true;

			for (i = startOfPara; i <= endOfPara; i++)
			{
				var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(i);
			    var paraAttr:ITextLayoutFormat = para.computedFormat;
				if (curAmount == null)
					curAmount = paraAttr.paragraphSpaceBefore;
				else if (curAmount != paraAttr.paragraphSpaceBefore)
				{
					success = false;
					break;
				}
			}
			return success;
		}

		/* ************************************************************** */
		/* Space After Tests */
		/* ************************************************************** */

		/**
		 * Set space after value to twenty-five and check that it is set correctly.
		 */
		public function setSpaceAfterPositiveTest():void
		{
			setSpaceAfter(25);
			assertTrue("space after is not 25", getSpaceAfter(25));
		}

		/**
		 * Set space after value to negative fifty and check that it is zero
		 * (i.e. no negative space after values).
		 */
		public function setSpaceAfterNegativeTest():void
		{
			setSpaceAfter(-50);
			assertTrue("space before is not 0", getSpaceAfter(0)); // set test value to 0 I don't think you can have a negative spaceAfter KJT

		}

		private function setSpaceAfter(spaceAfterValue:Number):void
		{
			var pa:TextLayoutFormat = new TextLayoutFormat();
			pa.paragraphSpaceAfter = spaceAfterValue;
			SelManager.applyParagraphFormat(pa);
		}

		private function getSpaceAfter(amount:Number = -1):Boolean
		{
			var startOfPara:int = SelManager.anchorPosition;
			var endOfPara:int = SelManager.activePosition;
			var curAmount:Object = null;
			if (amount != -1)
				curAmount = Object(amount);
			var i:int;
			var success:Boolean = true;

			for (i = startOfPara; i <= endOfPara; i++)
			{
				var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(i);
			    var paraAttr:ITextLayoutFormat = para.computedFormat;
				if (curAmount == null)
					curAmount = paraAttr.paragraphSpaceAfter;
				else if (curAmount != paraAttr.paragraphSpaceAfter)
				{
					success = false;
					break;
				}
			}
			return success;
		}

		public function joinParagraphsTest():void
		{
			var flow1:FlowElement;
			var flow2:FlowElement;
			//This is the length to the end of the first text.
			var length:int = 0;

			//Look for two back to back paragraphs.
			for(var i:int = 0; i < TestFrame.rootElement.numChildren-1; i++){
				flow1 = TestFrame.rootElement.getChildAt(i);
				flow2 = TestFrame.rootElement.getChildAt(i+1);

				length = length + flow1.textLength;

				if(flow1 is ParagraphElement && flow2 is ParagraphElement) break;
			}

			var para1:ParagraphElement = flow1 as ParagraphElement;
			var para2:ParagraphElement = flow2 as ParagraphElement;

			var attrib1:ITextLayoutFormat = para1.computedFormat;
			var attrib2:ITextLayoutFormat = para2.computedFormat;

			if(!Property.equalAllHelper(TextLayoutFormat.description,attrib1,attrib2)){
				for each (var prop:Property in TextLayoutFormat.description){
					var name:String = prop.name;

					para2[name] = attrib1[name].valueOf();
				}
			}

			attrib2 = para2.computedFormat;

			assertTrue("attributes have changed",
				Property.equalAllHelper(
					TextLayoutFormat.description,
					attrib1,
					attrib2
				)
			);

			if(attrib1.textAlign == TextAlign.JUSTIFY){
				para1.textAlign = TextAlign.CENTER;
			}else {
				para1.textAlign = TextAlign.JUSTIFY;
			}

			attrib1 = para1.computedFormat;
			attrib2 = para2.computedFormat;

			assertTrue("attributes did not change",
				!Property.equalAllHelper(
					TextLayoutFormat.description,
					attrib1,
					attrib2
				)
			);

			SelManager.selectRange(length-1,length-1);
			var origLen1:Number = para1.textLength;
			var origLen2:Number = para2.textLength;

			var event:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 127, 46);
			TestFrame.container["dispatchEvent"](event);
			TestFrame.textFlow.flowComposer.compose();

			var newLen1:Number = para1.textLength;
			var newLen2:Number = para2.textLength;

			assertTrue("paragraphs incorrectly joined",
						newLen1 == (origLen1+origLen2-1) &&
						newLen2 == 0 );

			// Make sure old attributes are preserved after undo

			SelManager.undo();

			attrib1 = para1.computedFormat;
			attrib2 = para2.computedFormat;

			assertTrue("attributes changed after an undo",
				!Property.equalAllHelper(
					TextLayoutFormat.description,
					attrib1,
					attrib2
				)
			);
		}

		/**
		 * Set the size of the text and autoleading, then change them and make sure that the
		 * leading is the correct value.
		 */
		public function autoLeadingTest():void
		{
			const acceptableErrorAmt:Number = .02;

			SelManager.selectAll();

//			var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(0);
//			var attribs:IParagraphFormat = para.computedFormat;
//			var initALP:Number = attribs.autoLeadingPercent as Number;

			var initSize:Number = 10;
			var ca:TextLayoutFormat = new TextLayoutFormat();
			ca.fontSize = initSize;
			var initALP:Number = 130;
			ca.lineHeight = initALP.toString() + '%';
			SelManager.applyLeafFormat(ca);

			SelManager.textFlow.flowComposer.compose();

			var line0:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(0) as TextFlowLine;
			var line1:TextFlowLine = SelManager.textFlow.flowComposer.getLineAt(1) as TextFlowLine;

			var initLead:Number;

			if ( SelManager.textFlow.computedFormat.blockProgression == BlockProgression.RL )
			{
				initLead = Math.abs(line1.x - line0.x);
			}
			else
			{
				initLead = Math.abs(line1.y - line0.y);
			}

			assertTrue( "Leading is not correct value", Math.abs(((initALP/100) * initSize) - initLead) <= acceptableErrorAmt);

			var finalALP:Number = initALP + 30;
			var finalSize:Number = initSize + 10;

			var ca2:TextLayoutFormat = new TextLayoutFormat();
			ca2.lineHeight = finalALP.toString() + '%';
			SelManager.applyLeafFormat(ca2);

			SelManager.textFlow.flowComposer.compose();

			line0 = SelManager.textFlow.flowComposer.getLineAt(0) as TextFlowLine;
			line1 = SelManager.textFlow.flowComposer.getLineAt(1) as TextFlowLine;

			var middleLead:Number;

			if ( SelManager.textFlow.computedFormat.blockProgression == BlockProgression.RL )
			{
				middleLead = Math.abs(line1.x - line0.x);
			}
			else
			{
				middleLead = Math.abs(line1.y - line0.y);
			}

			assertTrue( "Leading is not correct value", Math.abs(((finalALP/100) * initSize) - middleLead) <= acceptableErrorAmt);

			ca = new TextLayoutFormat();
			ca.fontSize = finalSize;
			SelManager.applyLeafFormat(ca);

			SelManager.textFlow.flowComposer.compose();

			line0 = SelManager.textFlow.flowComposer.getLineAt(0) as TextFlowLine;
			line1 = SelManager.textFlow.flowComposer.getLineAt(1) as TextFlowLine;

			var finalLead:Number;

			if ( SelManager.textFlow.computedFormat.blockProgression == BlockProgression.RL )
			{
				finalLead = Math.abs(line1.x - line0.x);
			}
			else
			{
				finalLead = Math.abs(line1.y - line0.y);
			}

			assertTrue( "Leading is not correct value", Math.abs(((finalALP/100) * finalSize) - finalLead) <= acceptableErrorAmt);
		}

		/**
		 * Create an empty paragraph and set its attributes. Then insert text and see if
		 * the paragraph still has its attributes.
		 */
		public function paragraphAttributeRetentionTest():void
		{
			SelManager.selectRange(0,0);

			var returnevent:KeyboardEvent =
				new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 13);
			TestFrame.container["dispatchEvent"](returnevent);


			SelManager.selectRange(0,0);

			var para:ParagraphElement = SelManager.textFlow.findAbsoluteParagraph(0);
			var attribs:ITextLayoutFormat = para.computedFormat;
			var initTextIndent:Number = Number(attribs.textIndent);

			var pa:TextLayoutFormat = new TextLayoutFormat();
			pa.textIndent = initTextIndent + 30;
			SelManager.applyParagraphFormat(pa);

			SelManager.insertText("I should be indented 30!");

			para = SelManager.textFlow.findAbsoluteParagraph(0);
			attribs = para.computedFormat;

			assertTrue(attribs.textIndent == initTextIndent + 30);
		}

		/**
		 * Create a paragraph attributes object, set all the number values to a limit (
		 * low limit if the attribute is at the high limit, high limit if it's anywhere
		 * else), then create a new attributes object based on it and reverse the first
		 * attribute. Then perform TextLayoutFormat.removeMatching and verify the only
		 * property left is the one you set to a different value, and ensure no other
		 * values remain.
		 */
		public function paragraphAttributeRemovalTest():void
		{
			var desc:Object = TextLayoutFormat.description;

			var pa:TextLayoutFormat = new TextLayoutFormat();
			var handler:NumberPropertyHandler;

			var good:Array = new Array();
			for each (var prop:Property in desc){
				handler = prop.findHandler(NumberPropertyHandler) as NumberPropertyHandler
				if (handler)
				{
					var name:String = prop.name;
					good.push(name);

					if(pa[name] == handler.maxValue){
						pa[name] = handler.minValue;
					}else{
						pa[name] = handler.maxValue;
					}
				}
			}

			var antiPa:TextLayoutFormat = new TextLayoutFormat(pa);

			var anti:String = "";
			for each (name in good)
			{
				handler = (desc[name].findHandler(NumberPropertyHandler) as NumberPropertyHandler);
				if(antiPa[name] == handler.minValue){
					antiPa[name] = handler.maxValue;
					anti = name;
					break;
				}else{
					antiPa[name] = handler.minValue;
					anti = name;
					break;
				}
			}

			antiPa.removeMatching(pa);
			for each (name in good){
				if(name == anti){
					assertTrue("Attribute to be retained was nulled!", antiPa[name] != null);
					assertTrue("Attribute to be retained was set to previous value!", antiPa[name] != pa[name]);
				}else{
					assertTrue("Attribute to be removed was retained!", antiPa[name] == null);
				}
			}
		}

		/**
		 * Create an empty paragraph at the end of a text flow and see if the
		 * character attributes from the previous paragraph have been applied to it.
		 */
		public function characterAttributeRetentionTest():void
		{
			var length:int = SelManager.textFlow.textLength - 1;

			var lastLeaf:FlowLeafElement = SelManager.textFlow.findLeaf(length);
			var lastCharAttr:ITextLayoutFormat = lastLeaf.computedFormat;

			SelManager.selectRange(length,length);

			var returnevent:KeyboardEvent =
				new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 13);
			TestFrame.container["dispatchEvent"](returnevent);

			SelManager.flushPendingOperations();

			length = SelManager.textFlow.textLength - 1;
			SelManager.selectRange(length,length);

			var newLeaf:FlowLeafElement = SelManager.textFlow.findLeaf(length);
			var newCharAttr:ITextLayoutFormat = newLeaf.computedFormat;
		}

		private function checkTabstopFormat (obj:Object, type:String, position:Number, alignmentToken:String):Boolean
		{
			var tabStop:TabStopFormat = obj as TabStopFormat;
			if (!tabStop)
				return false;

			return tabStop.alignment == type && tabStop.position == position && (tabStop.alignment == TabAlignment.DECIMAL ?  tabStop.decimalAlignmentToken == alignmentToken : true);
		}

		/**
		 * Validate parsing of string-based tabStops syntax
		 */
		public function tabStopsStringFormTest():void
		{
			var pa:TextLayoutFormat = new TextLayoutFormat();
			pa.tabStops = " 200 s100    C400 d350 D700|::    e800  d850|\\  d900|\\\\     ";

			var tabStopsRetval:Object = pa.tabStops;
			assertTrue("tabStops getter returned null", tabStopsRetval);

			var tabStops:Array = tabStopsRetval as Array;
			assertTrue("tabStops getter did not return an array", tabStops);

			var parseSuccess:Boolean = (tabStops.length == 8) &&
				 checkTabstopFormat (tabStops[0], TabAlignment.START, 100, null) &&
				 checkTabstopFormat (tabStops[1], TabAlignment.START, 200, null) &&
				 checkTabstopFormat (tabStops[2], TabAlignment.DECIMAL, 350, ".") &&
				 checkTabstopFormat (tabStops[3], TabAlignment.CENTER, 400, null) &&
				 checkTabstopFormat (tabStops[4], TabAlignment.DECIMAL, 700, "::") &&
				 checkTabstopFormat (tabStops[5], TabAlignment.END, 800, null) &&
				 checkTabstopFormat (tabStops[5], TabAlignment.DECIMAL, 850, " ") &&
				 checkTabstopFormat (tabStops[5], TabAlignment.DECIMAL, 900, "\\");

			assertTrue(parseSuccess, "string form of tabStops incorrectly parsed");
		}

		/* this is for testing a bug.  Bug description: Launch Flow.wsf, Select a chunk of text in the second paragraph, then
		   choose a visible background color (pink, for example), in Advanced Character, choose a Background Alpha around 20%,
		   deselect the text and note how light it is. Click in the first paragraph and start typing.  Note that with each keystroke
		   the background color appears darker.
		*/

		public function backgroundcolorchangeTest():void
		{
			var insertPoint:int = 14;
    		var tlf:TextLayoutFormat = new TextLayoutFormat();
   			tlf.backgroundColor = 0xFF00FF;
   			tlf.backgroundAlpha = .2;
   			tlf.fontSize = 40;

    		SelManager.selectRange(0,0);
   			SelManager.insertText("This is a test" +
               "            a");
   		    SelManager.selectRange(insertPoint, insertPoint);
    		SelManager.splitParagraph();
  		    var tf:TextFlow = SelManager.textFlow;
        	var p1:ParagraphElement = tf.getChildAt(0) as ParagraphElement;
        	var p2:ParagraphElement = tf.getChildAt(1) as ParagraphElement;
        	var p1start:int = p1.getAbsoluteStart();
        	var p1end:int = p1.textLength - 1;
       		var p2start:int = p2.getAbsoluteStart();
        	var p2end:int = p2start + p2.textLength - 1;

        	SelManager.selectRange(p2start, p2end);
        	SelManager.applyLeafFormat(tlf);
        	SelManager.selectRange(0,0);

       		// get the rect where the first character of the second line is  displayed
        	var testLine:TextLine =  SelManager.textFlow.flowComposer.getLineAt(1).getTextLine();
        	var characterBounds:Rectangle = testLine.getAtomBounds(0);
    		characterBounds.offset (testLine.x, testLine.y);
        	var testRect:Rectangle = new Rectangle;
        	testRect.height = characterBounds.height;
        	testRect.width = characterBounds.width;
        	var containerMatrix:Matrix = new Matrix (1,0,0,1,-characterBounds.x, -characterBounds.y);

     		//save bitmap of that rect before adding text to para 1
    		var beforeBitmapData:BitmapData = new  BitmapData(testRect.width,testRect.height);
    		beforeBitmapData.draw(TestFrame.container as IBitmapDrawable, containerMatrix, null, null, testRect);
        	var beforeBitmap:Bitmap = new Bitmap (beforeBitmapData);

    		//append some text to paragraph 1
   			SelManager.selectRange(p1end, p1end);
   			SelManager.insertText("AAA");
   			TestFrame.flowComposer.updateAllControllers();

   			//save bitmap of paragraph 2 after append text to paragraph 1
    		var afterBitmapData:BitmapData = new  BitmapData(testRect.width,testRect.height);
    		afterBitmapData.draw(TestFrame.container as IBitmapDrawable,containerMatrix, null, null, testRect);
        	var afterBitmap:Bitmap = new Bitmap(afterBitmapData);

    		// This will do the bitmap compare of the two bitmaps.
    		afterBitmap.bitmapData.draw(beforeBitmap, null, null, "difference");
    		var bounds:Rectangle = new Rectangle(0, 0, afterBitmap.width,afterBitmap.height);
    		var diffPixels:ByteArray = afterBitmap.bitmapData.getPixels(bounds);
    		diffPixels.position = 0;
    		var pixelCount:Number = diffPixels.bytesAvailable;
    		var diffCount:Number = 0;
   			while (diffPixels.bytesAvailable > 0)
    		{
     			if (diffPixels.readByte() > 0)
     			{
      				diffCount ++;
     			}
    		}

    		var diff:Number = diffCount/pixelCount*100;

   			assertTrue("Background color has been changed after appending text  to paragraph 1." + " The diff is "+
    				diff + " And the diffTolerance is " + diffTolerance, diff < diffTolerance);

		}

		/* this is for testing the bug 2371905.  Final Empty Paragraph Shows No Selection When Block Selected
		*/

		public function FinalEmptyParaTest():void
		{
			var insertPoint:int = 14;
    		var tlf:TextLayoutFormat = new TextLayoutFormat();

    		SelManager.selectRange(0,0);
   			SelManager.insertText("This is a test" +
               "            ");
   		    SelManager.selectRange(insertPoint, insertPoint);
    		SelManager.splitParagraph();
  		    var tf:TextFlow = SelManager.textFlow;
        	var p1:ParagraphElement = tf.getChildAt(0) as ParagraphElement;
        	var p2:ParagraphElement = tf.getChildAt(1) as ParagraphElement;
        	var p1start:int = p1.getAbsoluteStart();
        	var p1end:int = p1.textLength - 1;
       		var p2start:int = p2.getAbsoluteStart();
        	var p2end:int = p2start + p2.textLength - 1;

        	SelManager.selectAll();

        	var absoluteEnd:int = SelManager.absoluteEnd;

			assertTrue("Final Empty paragragh has not been selected" + " final empty paragraph end at index " + p2end +
			" and the real absolute End index is: " + absoluteEnd, p2end == absoluteEnd);
		}
	}
}
