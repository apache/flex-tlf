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
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.*;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.*;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.utils.GeometryUtil;
	
	import mx.containers.Canvas;

	use namespace tlf_internal;
	

 	public class LinkTest extends VellumTestCase	
	{	
		private var direction:String="";
		public function LinkTest(methodName:String, testID:String, testConfig:TestConfig, testXML:XML = null)
		{
			super(methodName, testID, testConfig);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Links";
			
			var customConfig:TestConfig = testConfig.copyTestConfig();
			
			if ( customConfig.writingDirection[0] == "rl")
				direction = "vertical";
			else direction = "honrizontal";
		}

		
		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "performLinkTest", testConfig ) ); //HBS
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "changeLinkColor", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "changeHoverColor", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "changeActiveColor", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "splitRejoinLinkTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "splitRejoinTargetTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "extendToOverlappingLinksTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "removeLinkTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "adjacentLinkAttributesTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "nestedLinkAttributesTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "splitLinkAttributesTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "defaultConfigAttributesTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "textAdditionTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "nestedLinkTargetTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "nestedLinkMergeTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "linkCrossingParagraphTest", testConfig ) );
   			ts.addTestDescriptor (new TestDescriptor (LinkTest, "linkWithCustomListenerTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "applyLinkAndRemoveAllTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "applyLinkAndRemoveFormerTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "applyLinkAndRemoveLatterTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "applyLinkAndRemoveMiddleTest", testConfig ) );
			// the descriptors added above should have a testConfig with a containerType of "sprite"
			// When the TestDescriptor is created it makes a new testConfig and copies over the
			// properties, so changing the containerType here should not affect the TestDescriptors
			// already created. But it does - when the tests above run it goes through the "custom" code.
			var customTestConfig:TestConfig = testConfig.copyTestConfig();
			customTestConfig.containerType = "custom";
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "linkWithInlineTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "linkWithNullInlineTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "linkWithDisplayObjectTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "launchLinkTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "linkEventMirrorTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "spanMouseDownEventMirrorTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "spanMouseClickEventMirrorTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "spanMouseMoveEventMirrorTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "spanMouseUpEventMirrorTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "spanRollOverEventMirrorTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "spanRollOutEventMirrorTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (LinkTest, "spanMouseEventMirrorTest", customTestConfig ) );
			ts.addTestDescriptor(new TestDescriptor (LinkTest, "interactiveObjectCount", customTestConfig ) );
			ts.addTestDescriptor(new TestDescriptor (LinkTest, "partlyComposingTest", customTestConfig ) );
  		}

   		override public function setUp() : void
		{
			if (containerType == "custom")
			{
				cleanUpTestApp();
			}
			else
			{
				super.setUp();
			}
		}

		/**
		 * Selects the characters between the 30th and 50th characters and turns the selected area into a link.
		 * Verifies that the 40th character is underneath a link.
		 * Selects the 40th character and splits at that location.
		 * Verifies that the first character in the new paragraph is underneath a link with the proper uri.
		 * Undo the split operation.
		 * Verfifies that the link is recreated in the first paragraph and is of length 20 with the proper uri.
		 * Undo the "make link" operation.
		 * Verifies that the 40th character is no longer underneath a link.
		 */
		public function performLinkTest():void // HBS
		{
			var startIndx:int = 30;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			var fl:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;
			assertTrue("link element is null", (linkEl != null));
			assertTrue("expected link length of " + (endIndx - startIndx) + " but found " +
						linkEl.textLength, (linkEl.textLength == (endIndx - startIndx)));
			assertTrue("expected http://www.google.com, but found " +
						linkEl.href, (linkEl.href == "http://www.google.com"));

			//if down here, the link element was created correctly.
			//Now, split the linkElement in the middle, which should be
			//at position 40

			SelManager.selectRange((startIndx + endIndx)/2, (startIndx + endIndx)/2);
			SelManager.splitParagraph();

			//get the next paragraph and then get the first FlowElement of that paragraph. It
			//should be a link element

			var curPar:ParagraphElement = fl.getParagraph();
			var curParIndex:int = curPar.parent.getChildIndex(curPar);
			assertTrue(true, ((curParIndex + 1) < curPar.parent.numChildren));

			//if here, the split occurred fine.
			var newPar:ParagraphElement = curPar.parent.getChildAt(curParIndex + 1) as ParagraphElement;
			assertTrue(true, newPar != null);
			var firstFlEl:FlowElement = newPar.getChildAt(0);
			assertTrue(true, firstFlEl is LinkElement);
			var newLinkEl:LinkElement = firstFlEl as LinkElement;
			var expectedLength:int = (endIndx - startIndx) / 2;

			//check to see if new link element is expected length or expected length + 1 (since
			//a newline could have been appended to it.
			assertTrue(true, ((expectedLength == newLinkEl.textLength) || (expectedLength == newLinkEl.textLength - 1)));
			assertTrue(true, (newLinkEl.href == "http://www.google.com"));

			//undoing the split operation.
			SelManager.undo();

			assertTrue(true, (linkEl != null));
			assertTrue(true, (linkEl.textLength == (endIndx - startIndx)));
			assertTrue(true, (linkEl.href == "http://www.google.com"));

			//undo the make link operation.
			SelManager.undo();

			fl = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;
			assertTrue(true, (linkEl == null));
		}

		/**
		 * Selects the text between 30 and 50 and makes it a link to google.
		 * Then inverts the link's color.
		 */
		public function changeLinkColor():void
		{
			var startIndx:int = 30;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			var fl:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;

			var newColor:uint = ~(linkEl.effectiveLinkElementTextLayoutFormat.color as uint) as uint;
			var d:Dictionary = new Dictionary();
			d[TextLayoutFormat.colorProperty.name] = newColor;
			linkEl.linkNormalFormat = d;

			assertTrue(linkEl.linkNormalFormat != null && linkEl.linkNormalFormat[TextLayoutFormat.colorProperty.name] == newColor);
		}

		/**
		 * Selects the text between 30 and 50 and makes it a link to google.
		 * Then inverts the link's hover color.
		 */
		public function changeHoverColor():void
		{
			var startIndx:int = 30;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			var fl:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;

			var newColor:uint = ~(linkEl.effectiveLinkElementTextLayoutFormat.color as uint) as uint;
			var d:Dictionary = new Dictionary();
			d[TextLayoutFormat.colorProperty.name] = newColor;
			linkEl.linkHoverFormat = d;

			assertTrue(linkEl.linkHoverFormat != null && linkEl.linkHoverFormat[TextLayoutFormat.colorProperty.name] == newColor);
		}

		/**
		 * Selects the text between 30 and 50 and makes it a link to google.
		 * Then inverts the link's active color.
		 */
		public function changeActiveColor():void
		{
			var startIndx:int = 30;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			var fl:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;

			var newColor:uint = ~(linkEl.effectiveLinkElementTextLayoutFormat.color as uint) as uint;
			var d:Dictionary = new Dictionary();
			d[TextLayoutFormat.colorProperty.name] = newColor;
			linkEl.linkActiveFormat = d;

			assertTrue(linkEl.linkActiveFormat != null && linkEl.linkActiveFormat[TextLayoutFormat.colorProperty.name] == newColor);
		}

		/**
		 * Creates a link in the first line, then turns a portion of that link
		 * into a different link. Then splits the two links on the border between them
		 * and undoes the opperation. Subsequently checks to see that both link
		 * exist and point to their respective destinations.
		 */
		public function splitRejoinLinkTest():void
		{
			var startIndx:int = 10;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			SelManager.selectRange(startIndx + 15, endIndx - 15);
			SelManager.applyLink("http://maps.google.com", "_self", false);

			SelManager.selectRange(startIndx + 16, startIndx + 16);
			SelManager.splitParagraph();

			//undoing the split operation.
			SelManager.undo();

			var first:FlowElement = SelManager.textFlow.findLeaf(startIndx);
			var second:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2);

			var linkOne:LinkElement = first.getParentByType(LinkElement) as LinkElement;
			var linkTwo:LinkElement = second.getParentByType(LinkElement) as LinkElement;

			assertTrue(linkOne != linkTwo);
			assertTrue(linkOne.href != linkTwo.href);
		}

		/**
		 * Creates a link in the first line, then changes a portion of the link to
		 * have a different target. Then splits the two links on the border between
		 * them and undoes the opperation. Subsequently checks to see that both link
		 * exist and point to their respective destinations.
		 */
		public function splitRejoinTargetTest():void
		{
			var startIndx:int = 10;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			SelManager.selectRange(startIndx + 15, endIndx - 15);
			SelManager.applyLink("http://www.google.com", "_top", false);

			SelManager.selectRange(startIndx + 16, startIndx + 16);
			SelManager.splitParagraph();

			//undoing the split operation.
			SelManager.undo();

			var first:FlowElement = SelManager.textFlow.findLeaf(startIndx);
			var second:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2);

			var linkOne:LinkElement = first.getParentByType(LinkElement) as LinkElement;
			var linkTwo:LinkElement = second.getParentByType(LinkElement) as LinkElement;

			assertTrue(linkOne != linkTwo);
			assertTrue(linkOne.target != linkTwo.target);
		}

		/**
		 * Selects the characters between the 30th and 50th characters and turns the selected area into a link.
		 * Selects the characters between the 35th and 45th charactets and applies a new link with extendToOverlappingLinks set to true
		 * Verifies that the 30th character is underneath a link with the second URL
		 * Undo the "make link" operations.
		 * Turns the selected area into a link.
		 * Selects the characters between the 35th and 45th charactets and applies a new link (blank target, extendToOverlappingLinks set to true)
		 * Verifies that the 30th character is no longer underneath a link.
		 */
		public function extendToOverlappingLinksTest():void // HBS
		{
			var startIndx:int = 30;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			SelManager.selectRange(startIndx+5, endIndx-5);
			SelManager.applyLink("http://www.live.com", "_self", true);

			var fl:FlowElement = SelManager.textFlow.findLeaf(startIndx) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;
			assertTrue("link element is null", (linkEl != null));
			assertTrue("expected link length of " + (endIndx - startIndx) + " but found " +
						linkEl.textLength, (linkEl.textLength == (endIndx - startIndx)));
			assertTrue("expected http://www.live.com, but found " +
						linkEl.href, (linkEl.href == "http://www.live.com"));

			//undo the make link operations.
			SelManager.undo();
			SelManager.undo();

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			SelManager.selectRange(startIndx+5, endIndx-5);
			SelManager.applyLink("", "_self", true);

			fl = SelManager.textFlow.findLeaf(startIndx) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;
			assertTrue(true, (linkEl == null));
		}

		/**
		 * Determines where there is a paragraph break and tries to create a link
		 * across it. Since links are sub paragraph blocks, this shouldn't happen.
		 * Instead there should be two different links with the same attributes.
		 */
		public function linkCrossingParagraphTest():void
		{
			var startIndx:int = 30;
			var endIndx:int = 50;
			var splitIndx:int = 40;

			SelManager.selectRange(splitIndx, splitIndx);
			SelManager.splitParagraph();
			SelManager.flushPendingOperations()

			SelManager.selectRange(startIndx, endIndx);
			var firstLinkCreated:LinkElement = SelManager.applyLink("http://www.google.com", "_self", false);

			var start:FlowElement = SelManager.textFlow.findLeaf(splitIndx-2) as FlowElement;
			var linkStart:LinkElement = start.getParentByType(LinkElement) as LinkElement;
			assertTrue("EditManager.applyLink not returning firstLinkCreated", firstLinkCreated == linkStart);

			var end:FlowElement = SelManager.textFlow.findLeaf(splitIndx+2) as FlowElement;
			var linkEnd:LinkElement = end.getParentByType(LinkElement) as LinkElement;

			assertTrue("Link not created correctly!",linkStart != null && linkEnd != null);
			assertTrue("Link spans paragraph!",linkStart != linkEnd);
			assertTrue("Link hrefs not identical!",linkStart.href == linkEnd.href);
			assertTrue("Link targets not identical!",linkStart.target == linkEnd.target);
		}

		/**
		 * First make a link, then shift the select and set the link to null. Verify
		 * that the link is removed in the new selection.
		 */
		public function removeLinkTest():void
		{
			var startIndx:int = 30;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			var fl:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;

			assertTrue("Link not set! Value is " + linkEl.href, linkEl.href == "http://www.google.com");
			assertTrue("Target not set! Value is " + linkEl.target, linkEl.target == "_self");

			startIndx = 40;
			endIndx = 60;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink(null, null, false);		// remove by passing null

			// Check that it was removed
			fl = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;

			assertTrue("Link not removed!", !linkEl);

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);
			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("", null, false);		// remove by passing empty string

			// Check that it was removed
			fl = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;
			
			assertTrue("Link not removed!", !linkEl);
		}

		/**
		 * Create two adjacent links with the same target then change their active color
		 * attributes to be different. Ensure that they don't get merged.
		 */
		public function adjacentLinkAttributesTest():void
		{
			var startIndx:int = 30;
			var midIndx:int = 40;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, midIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			var fl:FlowElement = SelManager.textFlow.findLeaf((startIndx + midIndx) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;

			var d:Dictionary = new Dictionary();
			d[TextLayoutFormat.colorProperty.name] = 0x0000FF;
			linkEl.linkActiveFormat = d;

			SelManager.selectRange(midIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_parent", false);

			var fl2:FlowElement = SelManager.textFlow.findLeaf((midIndx + endIndx) / 2) as FlowElement;
			var linkEl2:LinkElement = fl2.getParentByType(LinkElement) as LinkElement;

			d = new Dictionary();
			d[TextLayoutFormat.colorProperty.name] = 0xFFFF00;
			linkEl2.linkActiveFormat = d;

			SelManager.flushPendingOperations();

			fl = SelManager.textFlow.findLeaf((startIndx + midIndx) / 2) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;

			fl2 = SelManager.textFlow.findLeaf((midIndx + endIndx) / 2) as FlowElement;
			linkEl2 = fl2.getParentByType(LinkElement) as LinkElement;

			assertTrue("Link elements with different active link formats were merged",
					linkEl != linkEl2
			);

			var linkElColor:*  = linkEl.linkActiveFormat == null ? undefined : linkEl.linkActiveFormat[TextLayoutFormat.colorProperty.name];
			var linkEl2Color:* = linkEl2.linkActiveFormat == null ? undefined : linkEl2.linkActiveFormat[TextLayoutFormat.colorProperty.name];

			assertTrue("Link elements with different active link colors did not preserve their colors",linkEl2Color === 0xFFFF00 && linkElColor === 0xff);
		}

		/**
		 * Create two nested links with the same target then change their active color
		 * attributes to be different. Ensure that they don't get merged.
		 */
		public function nestedLinkAttributesTest():void
		{
			var startIndx:int = 30;
			var startIndx2:int = 35;
			var endIndx2:int = 45;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			var fl:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;

			var firstCharForm:Dictionary = new Dictionary();
			firstCharForm[TextLayoutFormat.colorProperty.name] = 0x0000FF;
			linkEl.linkActiveFormat = firstCharForm;

			SelManager.selectRange(startIndx2, endIndx2);
			SelManager.applyLink("http://www.google.com", "_top", false);

			var fl2:FlowElement = SelManager.textFlow.findLeaf((startIndx2 + endIndx2) / 2) as FlowElement;
			var linkEl2:LinkElement = fl2.getParentByType(LinkElement) as LinkElement;

			var secondCharForm:Dictionary = new Dictionary();
			secondCharForm[TextLayoutFormat.colorProperty.name] = 0xFFFF00;
			linkEl2.linkActiveFormat = secondCharForm;

			SelManager.flushPendingOperations();

			fl = SelManager.textFlow.findLeaf((startIndx + startIndx2) / 2) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;

			fl2 = SelManager.textFlow.findLeaf((startIndx2 + endIndx2) / 2) as FlowElement;
			linkEl2 = fl2.getParentByType(LinkElement) as LinkElement;

			var fl3:FlowElement = SelManager.textFlow.findLeaf((endIndx2 + endIndx) / 2) as FlowElement;
			var linkEl3:LinkElement = fl3.getParentByType(LinkElement) as LinkElement;

			assertTrue("Link elements with different active link formats were merged",
					(linkEl != linkEl2) && (linkEl2 != linkEl3)
			);

			var linkElColor:*  = linkEl.linkActiveFormat == null ? undefined : linkEl.linkActiveFormat[TextLayoutFormat.colorProperty.name];
			var linkEl2Color:* = linkEl2.linkActiveFormat == null ? undefined : linkEl2.linkActiveFormat[TextLayoutFormat.colorProperty.name];

			assertTrue("Link elements with different active link colors did not preserve their colors",linkEl2Color === 0xFFFF00 && linkElColor === 0xff);
		}

		/**
		 * Create a link, then set the color attributes.
		 * Split the link and change the color attributes of the first half.
		 * Ensure that the second half doesn't get the new attributes.
		 */
		public function splitLinkAttributesTest():void
		{
			var startIndx:int = 30;
			var midIndx:int = 40;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			var fl:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;

			var firstCharForm:Dictionary = new Dictionary();
			firstCharForm[TextLayoutFormat.colorProperty.name] = 0x0000FF;
			linkEl.linkActiveFormat = firstCharForm;

			SelManager.selectRange(midIndx, midIndx);
			SelManager.splitParagraph();
			SelManager.flushPendingOperations();

			fl = SelManager.textFlow.findLeaf((startIndx + midIndx) / 2) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;

			var fl2:FlowElement = SelManager.textFlow.findLeaf((midIndx + endIndx) / 2) as FlowElement;
			var linkEl2:LinkElement = fl2.getParentByType(LinkElement) as LinkElement;

			var secondCharForm:Dictionary = new Dictionary();
			secondCharForm[TextLayoutFormat.colorProperty.name] = 0xFFFF00;
			linkEl2.linkActiveFormat = secondCharForm;

			SelManager.flushPendingOperations();

			assertTrue("Link elements with different active link formats were merged",
					linkEl != linkEl2
			);

			var linkElColor:*  = linkEl.linkActiveFormat == null ? undefined : linkEl.linkActiveFormat[TextLayoutFormat.colorProperty.name];
			var linkEl2Color:* = linkEl2.linkActiveFormat == null ? undefined : linkEl2.linkActiveFormat[TextLayoutFormat.colorProperty.name];

			assertTrue("Link elements with different active link colors did not preserve their colors",linkEl2Color === 0xFFFF00 && linkElColor === 0xff);
		}

		/**
		 * Change the DefaultConfiguration in TextFlow.
		 * Create a new TextFlow.
		 * Verify that the new flow has the new default configuration.
		 */
		public function defaultConfigAttributesTest():void
		{
			var actColor:uint = 0x0000FF;
			var hovColor:uint = 0x00FF00;
			var linkColor:uint = 0xFF0000;

			/* var actFormat:Dictionary = new Dictionary();
			actFormat[TextLayoutFormat.colorProperty.name] = actColor;

			var hovFormat:Dictionary = new Dictionary();
			hovFormat[TextLayoutFormat.colorProperty.name] = hovColor;

			var linkFormat:Dictionary = new Dictionary();
			linkFormat[TextLayoutFormat.colorProperty.name] = linkColor; */

			var actFormat:TextLayoutFormat = new TextLayoutFormat();
			actFormat.color = actColor;

			var hovFormat:TextLayoutFormat = new TextLayoutFormat();
			hovFormat.color = hovColor;

			var linkFormat:TextLayoutFormat = new TextLayoutFormat();
			linkFormat.color = linkColor;

			var testConfig:Configuration = new Configuration();

			testConfig.defaultLinkActiveFormat = actFormat;
			testConfig.defaultLinkNormalFormat = linkFormat;
			testConfig.defaultLinkHoverFormat = hovFormat;

			var newFlow:TextFlow = new TextFlow(testConfig);

			assertTrue("Active format was not applied.",TextLayoutFormat.isEqual(newFlow.configuration.defaultLinkActiveFormat,actFormat));
			assertTrue("Hover format was not applied.",TextLayoutFormat.isEqual(newFlow.configuration.defaultLinkHoverFormat,hovFormat));
			assertTrue("Link format was not applied.",TextLayoutFormat.isEqual(newFlow.configuration.defaultLinkNormalFormat,linkFormat));
		}

		/**
		 * Insert text at the end of a link.
		 * Verify that the new text is not a link.
		 */
		public function textAdditionTest():void
		{
			var startIndx:int = 30;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			SelManager.flushPendingOperations();

			SelManager.selectRange(endIndx, endIndx);
			SelManager.insertText("I should not be a link.");

			var fl:FlowElement = SelManager.textFlow.findLeaf(endIndx + 2) as FlowElement;

			assertTrue("Inserted text became a link!",!(fl is LinkElement));


			SelManager.selectRange(startIndx, startIndx);
			SelManager.insertText("I should not be a link.");

			fl = SelManager.textFlow.findLeaf(startIndx + 2) as FlowElement;

			assertTrue("Inserted text became a link!",!(fl is LinkElement));
		}

		/**
		 * Create two nested links with the same target.
		 * Change the outer link's target.
		 * Verify that the inner link doesn't change it's target.
		 * Verify that both sides of the outer link change.
		 */
		public function nestedLinkTargetTest():void
		{
			var startIndx:int = 30;
			var startIndx2:int = 35;
			var endIndx2:int = 45;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			var fl:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;

			SelManager.selectRange(startIndx2, endIndx2);
			SelManager.applyLink("http://www.google.com", "_none", false);

			var fl2:FlowElement = SelManager.textFlow.findLeaf((startIndx2 + endIndx2) / 2) as FlowElement;
			var linkEl2:LinkElement = fl2.getParentByType(LinkElement) as LinkElement;

			linkEl2.target = "http://slashdot.org";

			SelManager.flushPendingOperations();

			fl = SelManager.textFlow.findLeaf((startIndx + startIndx2) / 2) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;

			fl2 = SelManager.textFlow.findLeaf((startIndx2 + endIndx2) / 2) as FlowElement;
			linkEl2 = fl2.getParentByType(LinkElement) as LinkElement;

			var fl3:FlowElement = SelManager.textFlow.findLeaf((endIndx2 + endIndx) / 2) as FlowElement;
			var linkEl3:LinkElement = fl3.getParentByType(LinkElement) as LinkElement;

			assertTrue("Link elements with different targets were merged.",
					(linkEl != linkEl2) && (linkEl2 != linkEl3)
			);
			assertTrue("Link elements with different targets didn't preserve their targets",
					(linkEl.target != linkEl2.target) &&
					(linkEl2.target != linkEl.target) &&
					(linkEl3.target == linkEl.target)
			);
		}

		/**
		 * Create two nested links with the same target.
		 * Change the outer link's target.
		 * Verify that the inner link doesn't change it's target.
		 * Verify that both sides of the outer link change.
		 */
		public function nestedLinkMergeTest():void
		{
			var startIndx:int = 30;
			var startIndx2:int = 35;
			var endIndx2:int = 45;
			var endIndx:int = 50;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);

			var fl:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;

			SelManager.selectRange(startIndx2, endIndx2);
			SelManager.applyLink("http://www.google.com", "_self", false);

			var fl2:FlowElement = SelManager.textFlow.findLeaf((startIndx2 + endIndx2) / 2) as FlowElement;
			var linkEl2:LinkElement = fl2.getParentByType(LinkElement) as LinkElement;

			linkEl2.target = "http://slashdot.org";

			SelManager.flushPendingOperations();

			fl = SelManager.textFlow.findLeaf((startIndx + startIndx2) / 2) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;

			fl2 = SelManager.textFlow.findLeaf((startIndx2 + endIndx2) / 2) as FlowElement;
			linkEl2 = fl2.getParentByType(LinkElement) as LinkElement;

			var fl3:FlowElement = SelManager.textFlow.findLeaf((endIndx2 + endIndx) / 2) as FlowElement;
			var linkEl3:LinkElement = fl3.getParentByType(LinkElement) as LinkElement;

			assertTrue("Link elements were not merged.",
					(linkEl === linkEl2)
			);
		}

		private static function listener(e:Event):void
		{ }

		public function linkWithCustomListenerTest():void
		{
			var tf:TextFlow = new TextFlow();
			tf.flowComposer.addController(new ContainerController(new Sprite()));
			var p:ParagraphElement = new ParagraphElement();
			tf.addChild(p);

			// first link
			var span1:SpanElement = new SpanElement();
			span1.text = "span1";
			var link1:LinkElement = new LinkElement();
			link1.addChild(span1);
			p.addChild(link1);

			// second link
			var span2:SpanElement = new SpanElement();
			span2.text = "span2";
			var link2:LinkElement = new LinkElement();
			link2.addChild(span2);
			p.addChild(link2);

			link2.getEventMirror().addEventListener("test",listener);
			tf.flowComposer.updateAllControllers();

			assertTrue("Links with custom mirror events should not merge", link1.parent == p && link2.parent == p);
		}

		public function linkWithInlineTest():void
		{
			doLinkWithInlineTest("http://www.adobe.com/shockwave/download/images/flashplayer_100x100.jpg");
		}
		public function linkWithNullInlineTest():void
		{
			doLinkWithInlineTest(null);
		}
		public function linkWithDisplayObjectTest():void
		{
			// Create a simple rectangular display object for the float
			var displayObject:Sprite = new Sprite();
			var g:Graphics = displayObject.graphics;
			g.beginFill(0xFF00FF);
			g.drawRect(0, 0, 100, 100);
			g.endFill();

			doLinkWithInlineTest(displayObject);
		}
		private function doLinkWithInlineTest(source:Object):void
		{
			var s:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();

			TestCanvas.rawChildren.addChild(s);

			var _textFlow:TextFlow = new TextFlow();
			_textFlow.fontSize = 48;
			var p:ParagraphElement = new ParagraphElement();
			_textFlow.addChild(p);

			var span:SpanElement = new SpanElement();
			span.text = "Hello ";
			p.addChild(span);

			var link:LinkElement = new LinkElement();  link.href = "http://www.adobe.com";

			// graphic doesn't load
			var inlineGraphic:InlineGraphicElement = new InlineGraphicElement();
			if (source)
				inlineGraphic.source = source;
			inlineGraphic.width = 100;
			inlineGraphic.height = 100;
			link.addChild(inlineGraphic);

			p.addChild(link);

			var span2:SpanElement = new SpanElement();
			span2.text = " World";
			p.addChild(span2);

			_textFlow.flowComposer.addController(new ContainerController(s,400,200));

			// this call compose but the graphic hasn't been loaded from the source URL yet.
			_textFlow.flowComposer.updateAllControllers();
			
			var inline:DisplayObject = inlineGraphic.graphic;
			if (inline.width > 0 && inline.height > 0)		// try simulating a click
			{
				var eventCount:int = 0;
				link.href = "event:customEvent";
				link.getEventMirror().addEventListener(FlowElementMouseEvent.CLICK,listener);
				_textFlow.flowComposer.updateAllControllers();
				var controller:ContainerController = _textFlow.flowComposer.getControllerAt(0);
				var x:Number = inline.x + inline.width / 2;
				var y:Number = inline.y + inline.height / 2;
				var pt:Point = new Point(x, y);
				pt = inline.localToGlobal(pt);
				pt = controller.container.globalToLocal(pt);
				controller.container.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, pt.x, pt.y));
				controller.container.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, pt.x, pt.y));
				assertTrue("Custom listener should have received click", eventCount == 1);
			}
			
			function listener(e:Event):void
			{  eventCount++;  }
			
		}
		private function applyLink(startIndx:int,endIndx:int):void
		{			
			/*
			apply the link from startIndx to endIndx 
			then calling applyLink(null) to remove the selection
			*/			
			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink("http://www.google.com", "_self", false);
			
			var fl:FlowElement = SelManager.textFlow.findLeaf((startIndx + endIndx) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;
			
			//check that the link and target are set
			assertTrue("Link not set! Value is " + linkEl.href, linkEl.href == "http://www.google.com");
			assertTrue("Target not set! Value is " + linkEl.target, linkEl.target == "_self");			
		}
		private function removeLink(startIndx:int,endIndx:int):void
		{
			//remove the link from startIndx to endIndx
			SelManager.selectRange(startIndx, endIndx);
			SelManager.applyLink(null, null, false);		// remove by passing null	
			
		}
		public function applyLinkAndRemoveAllTest():void
		{
			//apply the link from 30 to 50			
			applyLink(30,50);		
			//remove the link from 30 to 50
			removeLink(30,50);			
			// Check that it was removed
			var fl:FlowElement = SelManager.textFlow.findLeaf((30 + 50) / 2) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;			
			assertTrue("Link not removed when applyLink(null) called!", !linkEl);
			
		}
		/**
		 apply the link from 30 to 50 
		 then remove the selection of 25, 40
		 check no link element parent for index 35, but the link remains at index 45
		 */
		public function applyLinkAndRemoveFormerTest():void
		{
			
			applyLink(30,50);
			//remove a selection of 25, 40
			removeLink(25,40);			
			//Check that no link element parent for index 35, but the link remains at index 45
			var fl:FlowElement = SelManager.textFlow.findLeaf(35) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;
			assertTrue("Link element parent for index 35 not removed when applyLink(null) called",!linkEl );
			fl = SelManager.textFlow.findLeaf(45) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;
			assertTrue("Link element parent for index 45 not remain when applyLink(null) called",linkEl );			
		}
		/**
		 apply the link from 30 to 50 
		 then remove the selection of 40, 55
		 check the link remains at index 35, but is not present at index 45
		 */
		public function applyLinkAndRemoveLatterTest():void
		{
			
			applyLink(30,50);
			//remove a selection of 40, 55
			removeLink(40,55);
			//Check that the link remains at index 35, but is not present at index 45
			var fl:FlowElement = SelManager.textFlow.findLeaf(35) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;
			assertTrue("Link element parent for index 35 not ramain when applyLink(null) called",linkEl );
			fl = SelManager.textFlow.findLeaf(45) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;
			assertTrue("Link element parent for index 45 not removed when applyLink(null) called",!linkEl );	
		}
		/**
		 apply the link from 30 to 50 
		 then remove the selection of 35, 45
		 check no link at index 40, but there should be two separate link elements now
		 */
		public function applyLinkAndRemoveMiddleTest():void
		{			
			applyLink(30,50);
			//remove a selection of 35, 45
			removeLink(35,45);
			//Check that no link at index 40, but there should be two separate link elements now
			var fl:FlowElement = SelManager.textFlow.findLeaf(40) as FlowElement;
			var linkEl:LinkElement = fl.getParentByType(LinkElement) as LinkElement;
			assertTrue("Link element parent for index 40 not removed when applyLink(null) called",!linkEl );
			fl = SelManager.textFlow.findLeaf(30) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;
			assertTrue("Link element parent for index 30 not remain when applyLink(null) called",linkEl );
			fl = SelManager.textFlow.findLeaf(49) as FlowElement;
			linkEl = fl.getParentByType(LinkElement) as LinkElement;
			assertTrue("Link element parent for index 49 not remain when applyLink(null) called",linkEl );
			
		} 
		
		private var tf:TextFlow = new TextFlow();
		public function launchLinkTest():void	
		{	
			if (direction == "vertical")
			{
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.fontFamily = "Arial";
				format.fontSize = 16;
				format.direction = "ltr";
				format.blockProgression = "rl";
				tf.hostFormat = format;
			}
			
			var p:ParagraphElement = new ParagraphElement();
			tf.addChild(p);
			
			var link:LinkElement = new LinkElement();
			link.href = "event:customEvent";
			var span:SpanElement = new SpanElement();
			span.text = "Hello world";
			span.fontSize = 16;
			link.addChild(span);
			p.addChild(link);
			
			var container:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();
			
			TestCanvas.rawChildren.addChild(container);
			var cc:ContainerController = new ContainerController(container,100,50);
			
			tf.flowComposer.addController(cc);
			tf.flowComposer.updateAllControllers();
			
			var editmanager:EditManager = new EditManager();
			tf.interactionManager = editmanager;
			editmanager.selectRange(2, 6);
			// Get the bounds of the link in TextLine coordinates
			var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
			var bounds:Rectangle = boundsInfo.rect as Rectangle;
			var textLine:TextLine = boundsInfo.textLine;
			
			tf.addEventListener("customEvent", addAsync(checkEvent,2500,null),false,0,true);
			tf.flowComposer.updateAllControllers();
		
			tf.interactionManager = null;
			
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
		
			tf.interactionManager = editmanager;
			editmanager.selectRange(0, 0);
		}
		
		public function linkEventMirrorTest():void	
		{	
			if (direction == "vertical")
			{
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.fontFamily = "Arial";
				format.fontSize = 16;
				format.direction = "ltr";
				format.blockProgression = "rl";
				tf.hostFormat = format;
			}
			
			var p:ParagraphElement = new ParagraphElement();
			tf.addChild(p);
			
			var link:LinkElement = new LinkElement();
			link.href = "event:customEvent";
			var span:SpanElement = new SpanElement();
			span.text = "Hello world";
			span.fontSize = 16;
			link.addChild(span);
			p.addChild(link);
			
			var container:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();
			
			TestCanvas.rawChildren.addChild(container);
			var cc:ContainerController = new ContainerController(container,100,50);
			
			tf.flowComposer.addController(cc);
			tf.flowComposer.updateAllControllers();
			
			link.getEventMirror().addEventListener("customEvent", addAsync(checkEvent,2500,null),false,0,true);
			tf.flowComposer.updateAllControllers();
			
			var editmanager:EditManager = new EditManager();
			tf.interactionManager = editmanager;
			editmanager.selectRange(2, 6);
			// Get the bounds of the link in TextLine coordinates
			var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
			var bounds:Rectangle = boundsInfo.rect as Rectangle;
			var textLine:TextLine = boundsInfo.textLine;
			
			tf.interactionManager = null;
			
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			
			tf.interactionManager = editmanager;
			editmanager.selectRange(0, 0);
		}
		
		public function spanMouseDownEventMirrorTest():void	
		{	
			if (direction == "vertical")
			{
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.fontFamily = "Arial";
				format.fontSize = 16;
				format.direction = "ltr";
				format.blockProgression = "rl";
				tf.hostFormat = format;
			}
			var p:ParagraphElement = new ParagraphElement();
			tf.addChild(p);
			var span:SpanElement = new SpanElement();
			span.text = "Hello world";
			span.fontSize = 16;
			span.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_DOWN, addAsync(checkMouseDownEvent,2500,null),false,0,true);
			p.addChild(span);
			var container:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();
			TestCanvas.rawChildren.addChild(container);
			var cc:ContainerController = new ContainerController(container,100,50);
			tf.flowComposer.addController(cc);
			tf.flowComposer.updateAllControllers();
			var editmanager:EditManager = new EditManager();
			tf.interactionManager = editmanager;
			editmanager.selectRange(2, 4);
			tf.flowComposer.addController(new ContainerController(container,200,100));
			tf.flowComposer.updateAllControllers();
			
			// Get the bounds of the link in TextLine coordinates
			var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
			var bounds:Rectangle = boundsInfo.rect as Rectangle;
			var textLine:TextLine = boundsInfo.textLine;
			tf.interactionManager = null;
			
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			tf.interactionManager = editmanager;
			editmanager.selectRange(0, 0);
		}
		
		public function spanMouseClickEventMirrorTest():void	
		{	
			if (direction == "vertical")
			{
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.fontFamily = "Arial";
				format.fontSize = 16;
				format.direction = "ltr";
				format.blockProgression = "rl";
				tf.hostFormat = format;
			}
			var p:ParagraphElement = new ParagraphElement();
			tf.addChild(p);
			var span:SpanElement = new SpanElement();
			span.text = "Hello world";
			span.fontSize = 16;
			span.getEventMirror().addEventListener(FlowElementMouseEvent.CLICK, addAsync(checkMouseClickEvent,2500,null),false,0,true);
			p.addChild(span);
			var container:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();
			TestCanvas.rawChildren.addChild(container);
			var cc:ContainerController = new ContainerController(container,100,50);
			tf.flowComposer.addController(cc);
			tf.flowComposer.updateAllControllers();
			var editmanager:EditManager = new EditManager();
			tf.interactionManager = editmanager;
			editmanager.selectRange(2, 4);
			tf.flowComposer.addController(new ContainerController(container,200,100));
			tf.flowComposer.updateAllControllers();
			
			// Get the bounds of the link in TextLine coordinates
			var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
			var bounds:Rectangle = boundsInfo.rect as Rectangle;
			var textLine:TextLine = boundsInfo.textLine;
			
			tf.interactionManager = null;
			//dispatch mouse events
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			
			tf.interactionManager = editmanager;
			editmanager.selectRange(0, 0);
		}
		
		public function spanMouseMoveEventMirrorTest():void	
		{	
			if (direction == "vertical")
			{
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.fontFamily = "Arial";
				format.fontSize = 16;
				format.direction = "ltr";
				format.blockProgression = "rl";
				tf.hostFormat = format;
			}
			var p:ParagraphElement = new ParagraphElement();
			tf.addChild(p);
			var span:SpanElement = new SpanElement();
			span.text = "Hello world";
			span.fontSize = 16;
			span.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_MOVE, addAsync(checkMouseMoveEvent,2500,null),false,0,true);
			p.addChild(span);
			var container:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();
			TestCanvas.rawChildren.addChild(container);
			var cc:ContainerController = new ContainerController(container,100,50);
			tf.flowComposer.addController(cc);
			tf.flowComposer.updateAllControllers();
			var editmanager:EditManager = new EditManager();
			tf.interactionManager = editmanager;
			editmanager.selectRange(2, 4);
			tf.flowComposer.addController(new ContainerController(container,200,100));
			tf.flowComposer.updateAllControllers();
			
			// Get the bounds of the link in TextLine coordinates
			var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
			var bounds:Rectangle = boundsInfo.rect as Rectangle;
			var textLine:TextLine = boundsInfo.textLine;
			
			tf.interactionManager = null;
			
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			tf.interactionManager = editmanager;
			editmanager.selectRange(0, 0);
		}
		
		public function spanMouseUpEventMirrorTest():void	
		{	
			if (direction == "vertical")
			{
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.fontFamily = "Arial";
				format.fontSize = 16;
				format.direction = "ltr";
				format.blockProgression = "rl";
				tf.hostFormat = format;
			}
			var p:ParagraphElement = new ParagraphElement();
			tf.addChild(p);
			var span:SpanElement = new SpanElement();
			span.text = "Hello world";
			span.fontSize = 16;
			span.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_UP, addAsync(checkMouseUpEvent,2500,null),false,0,true);
			p.addChild(span);
			var container:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();
			TestCanvas.rawChildren.addChild(container);
			var cc:ContainerController = new ContainerController(container,100,50);
			tf.flowComposer.addController(cc);
			tf.flowComposer.updateAllControllers();
			var editmanager:EditManager = new EditManager();
			tf.interactionManager = editmanager;
			editmanager.selectRange(2, 4);
			
			var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
			var bounds:Rectangle = boundsInfo.rect as Rectangle;
			var textLine:TextLine = boundsInfo.textLine;
			tf.interactionManager = null;
			
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			
			tf.interactionManager = editmanager;
			editmanager.selectRange(0, 0);
		}
		
		public function spanRollOverEventMirrorTest():void	
		{	
			if (direction == "vertical")
			{
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.fontFamily = "Arial";
				format.fontSize = 16;
				format.direction = "ltr";
				format.blockProgression = "rl";
				tf.hostFormat = format;
			}
			var p:ParagraphElement = new ParagraphElement();
			tf.addChild(p);
			var span:SpanElement = new SpanElement();
			span.text = "Hello world";
			span.fontSize = 16;
			span.getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OVER, addAsync(checkMouseRollOverEvent,2500,null),false,0,true);
			p.addChild(span);
			var container:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();
			TestCanvas.rawChildren.addChild(container);
			var cc:ContainerController = new ContainerController(container,100,50);
			tf.flowComposer.addController(cc);
			tf.flowComposer.updateAllControllers();
			var editmanager:EditManager = new EditManager();
			tf.interactionManager = editmanager;
			editmanager.selectRange(2, 4);
			
			var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
			var bounds:Rectangle = boundsInfo.rect as Rectangle;
			var textLine:TextLine = boundsInfo.textLine;
			
			tf.interactionManager = null;
			
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			
			tf.interactionManager = editmanager;
			editmanager.selectRange(0, 0);
		}
		
		public function spanRollOutEventMirrorTest():void	
		{	
			if (direction == "vertical")
			{
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.fontFamily = "Arial";
				format.fontSize = 16;
				format.direction = "ltr";
				format.blockProgression = "rl";
				tf.hostFormat = format;
			}
			var p:ParagraphElement = new ParagraphElement();
			tf.addChild(p);
			var span:SpanElement = new SpanElement();
			span.text = "Hello world";
			span.fontSize = 16;
			span.getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OUT, addAsync(checkMouseRollOutEvent,2500,null),false,0,true);
			p.addChild(span);
			var container:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();
			TestCanvas.rawChildren.addChild(container);
			var cc:ContainerController = new ContainerController(container,100,50);
			tf.flowComposer.addController(cc);
			tf.flowComposer.updateAllControllers();
			var editmanager:EditManager = new EditManager();
			tf.interactionManager = editmanager;
			editmanager.selectRange(2, 4);
			var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
			var bounds:Rectangle = boundsInfo.rect as Rectangle;
			var textLine:TextLine = boundsInfo.textLine;
			tf.interactionManager = null;
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true, false, bounds.right + 1, bounds.bottom + 1, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			tf.interactionManager = editmanager;
			editmanager.selectRange(0, 0);
		}
		
		public function spanMouseEventMirrorTest():void	
		{	
			if (direction == "vertical")
			{
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.fontFamily = "Arial";
				format.fontSize = 16;
				format.direction = "ltr";
				format.blockProgression = "rl";
				tf.hostFormat = format;
			}
			var textFlow:TextFlow = new TextFlow();
			textFlow.fontSize = 24;
			var p:ParagraphElement = new ParagraphElement();
			textFlow.addChild(p);
			var span:SpanElement = new SpanElement();
			span.text = "Hello world";
			span.fontSize = 16;
			p.addChild(span);
			var editmanager:EditManager = new EditManager();
			textFlow.interactionManager = editmanager;
			var container:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();
			TestCanvas.rawChildren.addChild(container);
			textFlow.flowComposer.addController(new ContainerController(container,200,100));
			textFlow.flowComposer.updateAllControllers();
			
			//listen for all FlowElementMouseEvents
			span.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_DOWN,traceEvent);
			span.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_UP,traceEvent);
			span.getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_MOVE,traceEvent);
			span.getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OVER,traceEvent);
			span.getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OUT,traceEvent);
			span.getEventMirror().addEventListener(FlowElementMouseEvent.CLICK,traceEvent);
			
			editmanager.selectRange(2, 4);
			// Get the bounds of the link in TextLine coordinates
			var boundsInfo:Object = GeometryUtil.getHighlightBounds(editmanager.getSelectionState())[0];
			var bounds:Rectangle = boundsInfo.rect as Rectangle;
			var textLine:TextLine = boundsInfo.textLine;
			textFlow.interactionManager = null;
		    //dispatch all mouse events
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true, false, bounds.right + 1, bounds.bottom + 1, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine)); 
			textLine.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
			textLine.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2, textLine));
	
			textFlow.interactionManager = editmanager;
			editmanager.selectRange(0, 0);
		}
		
		private function checkEvent(e:Event):void
		{
			assertTrue("mouseClickEvent is not fired when launch a link.", !(e is ErrorEvent));
			tf.removeEventListener("customEvent", checkEvent);
		}
		
		public function traceEvent(e:FlowElementMouseEvent):void
		{ 
			assertTrue("mouseEvent not fired correctly", !(e is ErrorEvent));
			tf.removeEventListener(FlowElementMouseEvent.MOUSE_DOWN, checkMouseDownEvent);
			tf.removeEventListener(FlowElementMouseEvent.MOUSE_UP, checkMouseUpEvent);
			tf.removeEventListener(FlowElementMouseEvent.CLICK, checkMouseClickEvent);
			tf.removeEventListener(FlowElementMouseEvent.MOUSE_MOVE, checkMouseMoveEvent);
			tf.removeEventListener(FlowElementMouseEvent.ROLL_OVER, checkMouseRollOverEvent);
			tf.removeEventListener(FlowElementMouseEvent.ROLL_OUT, checkMouseRollOutEvent);
			
		}
		private function checkMouseDownEvent(e:Event):void
		{
			assertTrue("mouseDown event is not fired", !(e is ErrorEvent));
			tf.removeEventListener(FlowElementMouseEvent.MOUSE_DOWN, checkMouseDownEvent);
		}
		private function checkMouseUpEvent(e:Event):void
		{
			assertTrue("mouseUp event is not fired", !(e is ErrorEvent));
			tf.removeEventListener(FlowElementMouseEvent.MOUSE_UP, checkMouseUpEvent);
		}
		private function checkMouseClickEvent(e:Event):void
		{
			assertTrue("mouseClick event is not fired", !(e is ErrorEvent));
			tf.removeEventListener(FlowElementMouseEvent.CLICK, checkMouseClickEvent);
		}
		private function checkMouseMoveEvent(e:Event):void
		{
			assertTrue("mouseMove event is not fired", !(e is ErrorEvent));
			tf.removeEventListener(FlowElementMouseEvent.MOUSE_MOVE, checkMouseMoveEvent);
		}
		private function checkMouseRollOverEvent(e:Event):void
		{
			assertTrue("mouseRollOver event is not fired", !(e is ErrorEvent));
			tf.removeEventListener(FlowElementMouseEvent.ROLL_OVER, checkMouseRollOverEvent);
		}
		private function checkMouseRollOutEvent(e:Event):void
		{
			assertTrue("mouseRollOut event is not fired", !(e is ErrorEvent));
			tf.removeEventListener(FlowElementMouseEvent.ROLL_OUT, checkMouseRollOutEvent);
		}
		
		public function interactiveObjectCount():void	
		{
			var markup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
				+"<list><li><div>" +
					"<p>" +
						"<span>before link</span>" +
						"<tcy><a url=\"www.adobe.com\"><span>the first link</span></a></tcy>" +
						"<a url=\"www.adobe.com\"><span>the second</span><span color=\"0xff0000\"> link</span></a>"+
						"<tcy><span>after link</span></tcy>"+
					"</p>" +
					"<p><span>no link</span></p>" +
				"</div></li></list>"+
				"<p><span>no link</span></p>"
				+"</TextFlow>";
			var textFlow:TextFlow = TextConverter.importToFlow(markup,TextConverter.TEXT_LAYOUT_FORMAT);
			var editmanager:EditManager = new EditManager();
			textFlow.interactionManager = editmanager;
			var container:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();
			TestCanvas.rawChildren.addChild(container);
			textFlow.flowComposer.addController(new ContainerController(container,300,200));
			textFlow.flowComposer.updateAllControllers();
			
			//get the first paragraph
			var span1:SpanElement = textFlow.getFirstLeaf() as SpanElement;
			var para1:ParagraphElement = span1.parent as ParagraphElement;
			assertTrue("The number of interactive children does not equal 2", para1._interactiveChildrenCount == 2);
			//get the second paragraph
			var para2:ParagraphElement = para1.getNextSibling() as ParagraphElement;
			assertTrue("The number of interactive children does not equal 0", para2._interactiveChildrenCount == 0);
			//get the third paragraph
			var para3:ParagraphElement = textFlow.getChildAt(1) as ParagraphElement;
			assertTrue("The number of interactive children does not equal 0", para3._interactiveChildrenCount == 0);
			//
			editmanager.applyLink("www.adobe.com", "_self", false, new SelectionState(textFlow, 0, 6));
			assertTrue("The number of interactive children is incorrect after apply link", para1._interactiveChildrenCount == 3);
			//
			editmanager.applyLink(null, null, false, new SelectionState(textFlow, 0, 6)); 
			assertTrue("The number of interactive children is incorrect after cancel the link", para1._interactiveChildrenCount == 2);
		}
		
		public function partlyComposingTest():void	
		{
			var textFlow:TextFlow = new TextFlow();
			var editmanager:EditManager = new EditManager();
			textFlow.interactionManager = editmanager;
			editmanager.selectAll();
			editmanager.deleteText();
			
			createLinkLine(textFlow, 7);
			var container:Sprite = new Sprite();
			var TestCanvas:Canvas = testApp.getDisplayObject();
			TestCanvas.rawChildren.addChild(container);
			var cc:ContainerController = new ContainerController(container,300,100);
			textFlow.flowComposer.addController(cc);
			var container1:Sprite = new Sprite();
			container1.x = 310;
			container1.y = 0;
			TestCanvas.rawChildren.addChild(container1);
			var cc1:ContainerController = new ContainerController(container1,300,150);
			textFlow.flowComposer.addController(cc1);
			cc.columnCount = 2;
			cc1.columnCount = 2;
			textFlow.flowComposer.updateAllControllers();
			assertTrue("All interactive objects should be cleard", getLength(cc.interactiveObjects) == 7 && getLength(cc1.interactiveObjects) == 0);
			createLinkLine(textFlow, 7);
			textFlow.flowComposer.updateAllControllers();
			assertTrue("The number of interactive objects is incorrect", getLength(cc.interactiveObjects) == 13 && getLength(cc1.interactiveObjects) == 1);
			createLinkLine(textFlow, 7);
			textFlow.flowComposer.updateAllControllers();
			assertTrue("The number of interactive objects is incorrect", getLength(cc.interactiveObjects) == 13 && getLength(cc1.interactiveObjects) == 8);
			var inserted:String = " Inserted Text Inserted Text Inserted Text Inserted Text Inserted Text Inserted Text" +
				" Inserted Text Inserted Text Inserted Text Inserted Text Inserted Text Inserted Text" +
				" Inserted Text Inserted Text Inserted Text Inserted Text Inserted Text Inserted Text" +
				" Inserted Text Inserted Text Inserted Text Inserted Text Inserted Text Inserted Text";
			editmanager.insertText(inserted, new SelectionState(textFlow, 55, 55));
			assertTrue("The number of interactive objects is incorrect", getLength(cc.interactiveObjects) == 3);
		}
		
		private function getLength(dic:Dictionary):int
		{
			var length:int = 0;
			for each(var o:Object in dic)
				length ++;
			return length;
		}
		
		private function createLinkLine(textFlow:TextFlow, times:int):void
		{
			for(var idx:int = 0; idx < times; idx++)
			{
				var p:ParagraphElement = new ParagraphElement();
				var span:SpanElement = new SpanElement();
				span.color = 0xCCCCCC;
				span.text = '15:38 '
				p.addChild(span);
				
				var a:LinkElement = new LinkElement();
				a.href = 'www.adobe.com';
				span = new SpanElement();
				span.text = "KnuX";
				a.addChild(span);
				p.addChild(a);
				
				span = new SpanElement();
				span.text = " : ";
				p.addChild(span);
				
				span = new SpanElement();
				span.text = "Test test";
				p.addChild(span);
				
				textFlow.addChild(p);
			}
		}
	}
}
