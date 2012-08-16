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
	import flash.events.KeyboardEvent;
	import flash.text.engine.TextLine;
	import flash.ui.KeyLocation;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.ListElement;
	import flashx.textLayout.elements.ListItemElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.ListMarkerFormat;
	import flashx.textLayout.formats.ListStyleType;
	import flashx.textLayout.formats.TabStopFormat;
	import flashx.textLayout.tlf_internal;
	
	import mx.containers.Canvas;
	
	use namespace tlf_internal;

	public class ListTest extends VellumTestCase
	{
		public function ListTest(methodName:String, testID:String, testConfig:TestConfig, testCaseXML:XML=null)
		{
			super(methodName, testID, testConfig, testCaseXML);

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Lists";
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
		public static function suite(testConfig:TestConfig, ts:TestSuiteExtended):void
		{
			ts.addTestDescriptor (new TestDescriptor (ListTest, "addList", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "addNestedLists", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "removeNestedLists", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "addMultiListItem", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "checkMarkerRegeneration", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "removeListItem", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "tabsInMarkerFormat", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "addDivInList", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "SplitAndMergeCauseMarkerRegeneration", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "listItemGoOutOfList", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "splitElementOperationTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "enterSplitListItem", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "backspaceMergeListItem", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "listMarkerFormatTest", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "ListListMarkerFormatparagraphStartIndent", testConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "ListMarkerFormatTabStopTest", testConfig ) );
			
			var customTestConfig:TestConfig = testConfig.copyTestConfig();
			customTestConfig.containerType = "custom";
			ts.addTestDescriptor (new TestDescriptor (ListTest, "scrollByLinesTest", customTestConfig ) );
			ts.addTestDescriptor (new TestDescriptor (ListTest, "crossContainers", customTestConfig ) );

		}
		public function addList():void
		{
			// See VellumTextCase.setup() for where SelManager comes from.
			// This creates a list with the default selection from setup()
			var listElementCreated:ListElement = SelManager.createList();
			
		//Check model
			var tf:TextFlow = SelManager.textFlow;
			// Iterate through the FlowElements, looking for a ListElement.
			// This works only because we know the list isn't inside a div.
			// More complex flows might require iterating through FlowLeafElements
			var listsFound:int = 0;
			var elem:FlowElement = tf.getChildAt(0);
			while (elem)
			{
				if (elem as ListElement)
				{
					// save this for display check below
					var listElement:ListElement = elem as ListElement;
					assertTrue("List element found doesn't match what was returned by createList()", listElement == listElementCreated);
					listsFound++;
				}
				elem = elem.getNextSibling();
			}
			assertTrue("Expected one list element in the model and found: " + listsFound, listsFound == 1);
			// here you could look at the ListElement to perform more validation steps
			
		//Check export
			var exportedXML:XML = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.XML_TYPE) as XML;
			// set the default namespace to what the exported XML uses
			var xmlns:Namespace = new Namespace("http://ns.adobe.com/textLayout/2008");
			default xml namespace = xmlns;
			// find all the nodes named "list"
			var listNodes:XMLList = exportedXML.child("list");
			// check that we have one list node. Other checks could be added based on the XML data.
			assertTrue("Expected one list element and found: " + listNodes.length(), listNodes.length() == 1);
			// here you could look at the rest of the XML data to perform more validation steps
			
		//Check display.
			// determine what the bullet text should be
			var listItem:ListItemElement = listElement.getChildAt(0) as ListItemElement;
			var bulletText:String = listElement.computeListItemText(listItem, listItem.computedListMarkerFormat());
			// here you could use this tlf_internal function to check more complex markers 
			// add one for the TextBlock terminator
			var markerLength:int = bulletText.length + 1;
			// find the TextFlowLine for the list start
			var listStartIndex:int = listElement.getElementRelativeStart(tf);
			var listFlowLine:TextFlowLine = tf.flowComposer.findLineAtPosition(listStartIndex);
			// this line should have a TextLine with a child TextLine that contains the bullet
			// the bulletLine is static, so there's not much information we can get from it.
			var listLine:TextLine = listFlowLine.getTextLine();
			var bulletLine:TextLine = listLine.getChildAt(0) as TextLine;
			assertTrue("Did not find a TextLine for the bullet", bulletLine !=null);
			assertTrue("text length for the bullet line should be " + markerLength + ", but was " + bulletLine.rawTextLength, bulletLine.rawTextLength == markerLength);
		}
		
		public function addNestedLists():void
		{
			//this test case will check up to three level nested lists
			//create three lists
			SelManager.createList();
			SelManager.createList();
			SelManager.createList();
			var tf:TextFlow = SelManager.textFlow;
			var listsFound:int = 0;
			var elem:FlowElement = tf.getChildAt(0);
			while (elem)
			{
				if (elem as ListElement)
				{	
					var listElement:ListElement = elem as ListElement;
					var allListElement:Array = [];
					var a:int = 0;
					allListElement[a] = listElement;
					var elem2:FlowElement = listElement.getChildAt(0);
					var e:FlowGroupElement = FlowGroupElement (elem2);
					var i:int=0;
					while (i < e.mxmlChildren.length)
					{
						if (e.mxmlChildren[i] as ListElement)
						{	
							var listElement1:ListElement = e.mxmlChildren[i] as ListElement;
							var elem3:FlowElement = listElement1.getChildAt(0);
							var e1:FlowGroupElement = FlowGroupElement (elem3);
							var j:int=0;
							while (j < e1.mxmlChildren.length)
							{
								if (e1.mxmlChildren[j] as ListElement)
								{	
									listsFound++;
									a++;
									allListElement[a] = e1.mxmlChildren[j] as ListElement;
								}
								j++;
							}
							listsFound++;
							a++;
							allListElement[a] = e.mxmlChildren[i] as ListElement;
						}
						i++;
					}
					listsFound++;
				}
				elem = elem.getNextSibling();
			}
			
			//check if there are three lists found
			assertTrue("Expected four list element in the model and found: " + listsFound, listsFound == 3);
			
			//Check export
			var exportedXML:XML = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.XML_TYPE) as XML;
			// set the default namespace to what the exported XML uses
			var xmlns:Namespace = new Namespace("http://ns.adobe.com/textLayout/2008");
			default xml namespace = xmlns;
			var listNodes:XMLList = exportedXML.child("list");
			// check that we have one list node. Other checks could be added based on the XML data.
			assertTrue("Expected one list element and found: " + listNodes.length(), listNodes.length() == 1);
	
			// determine what the bullet text should be
			var listItem:ListItemElement = new ListItemElement();
			var bulletText:String = "";
			var markerLength:int = 0;
			var listStartIndex:int = 0;
			var listFlowLine:TextFlowLine;
			var listLine:TextLine;
			var bulletLine:TextLine;
			for (i=0; i<listsFound; i++)
			{
				listElement = allListElement[i] as ListElement;
				listItem = listElement.getChildAt(0) as ListItemElement;
				bulletText = listElement.computeListItemText(listItem, listItem.computedListMarkerFormat());
				markerLength = bulletText.length + 1;
				// find the TextFlowLine for the list start
				listStartIndex = listElement.getElementRelativeStart(tf);
				listFlowLine = tf.flowComposer.findLineAtPosition(listStartIndex);
				listLine = listFlowLine.getTextLine();
				bulletLine = listLine.getChildAt(0) as TextLine;
				assertTrue("Did not find a TextLine for the bullet", bulletLine !=null);
				assertTrue("text length for the bullet line should be " + markerLength + ", but was " + bulletLine.rawTextLength, bulletLine.rawTextLength == markerLength);
			}

		}
		
		public function removeNestedLists():void
		{
			//create three lists
			SelManager.createList();
			SelManager.createList();
			SelManager.createList();
			var tf:TextFlow = SelManager.textFlow;
			var elem:FlowElement = tf.getChildAt(0);
			
			//save first list to remove it later
			while (elem)
			{
				if (elem as ListElement)
				{	
					var firstListElement:ListElement = elem as ListElement;
				}
				elem = elem.getNextSibling();
			}
			
			//remove the first ListElement, since it's nested list, remove first one will remove all
			firstListElement.parent.removeChild(firstListElement);
			tf.flowComposer.updateAllControllers();
			elem = tf.getChildAt(0);
			var listsFound:int = 0;
			while (elem)
			{
				if (elem as ListElement)
				{	
					var listElement:ListElement = elem as ListElement;
					var elem2:FlowElement = listElement.getChildAt(0);
					var e:FlowGroupElement = FlowGroupElement (elem2);
					var i:int = 0;
					while (i < e.mxmlChildren.length)
					{
						if (e.mxmlChildren[i] as ListElement)
						{	
							var listElement1:ListElement = e.mxmlChildren[i] as ListElement;
							var elem3:FlowElement = listElement1.getChildAt(0);
							var e1:FlowGroupElement = FlowGroupElement (elem3);
							var j:int=0;
							while (j < e1.mxmlChildren.length)
							{
								if (e1.mxmlChildren[j] as ListElement)
								{	
									listsFound++;
								}
								j++;
							}
							listsFound++;
						}
						i++;
					}
					listsFound++;
				}
				elem = elem.getNextSibling();
			}
			
			//check 0 list found after removal
			assertTrue("Expected 0 list element found: " + listsFound, listsFound == 0);
		}
		
		public function addDivInList():void
		{
			var tf:TextFlow = SelManager.textFlow;
			SelManager.selectAll();
			SelManager.deleteText();
			
			var list:ListElement = new ListElement();
			list.listStyleType = ListStyleType.DECIMAL;
			var item:ListItemElement = new ListItemElement();
			var paragraphElement:ParagraphElement = new ParagraphElement();
			var spanElement:SpanElement = new SpanElement();
			spanElement.text = "Decimal list";
			paragraphElement.addChild(spanElement);
			var divElementCreated:DivElement = SelManager.createDiv();
			divElementCreated.addChild(paragraphElement);
			item.addChild(divElementCreated);
			list.addChild(item);
			tf.addChild(list);

			tf.flowComposer.updateAllControllers();
			
			//to check if div element has been created successfully
			var elem:FlowLeafElement = tf.findLeaf(0);
			var divElement:DivElement =new DivElement();
			while (elem)
			{
				divElement = elem.getParentByType(DivElement) as DivElement;
				if (divElement as DivElement)
				{
					assertTrue("div element found doesn't match what was returned by createDiv()", divElement == divElementCreated);
				}
				elem = elem.getNextLeaf();
			}
		}
		
		public function addMultiListItem():void
		{
			SelManager.selectRange(0,0);
			var tf:TextFlow = SelManager.textFlow;
			
			//Add three DECIMAL list items
			var list:ListElement = new ListElement();
			list.listStyleType = ListStyleType.DECIMAL;
			tf.addChild(list);
			var item:ListItemElement = new ListItemElement();
			list.addChild(item);
			list.addChild(new ListItemElement());
			list.addChild(new ListItemElement());
			tf.flowComposer.updateAllControllers();
			
			// Iterate through the FlowElements, looking for a ListElement.
			var listItemsFound:int = 0;
			var elem:FlowElement = tf.getChildAt(0);
		
			while (elem)
			{
				if (elem as ListElement)
				{
					// save this for display check below
					var listElement:ListElement = elem as ListElement;
					var elem2:FlowElement = listElement.getChildAt(0)
					// look for ListItemElement
					while (elem2)
					{
						if (elem2 as ListItemElement)
						{
							listItemsFound++;
						}
						elem2 = elem2.getNextSibling();
					}
				}
				elem = elem.getNextSibling();
			}
			//check three listItems have been added
			assertTrue("Expected one list element in the model and found: " + listItemsFound, listItemsFound == 3);
	
			//Check export
			var exportedXML:XML = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.XML_TYPE) as XML;
			// set the default namespace to what the exported XML uses
			var xmlns:Namespace = new Namespace("http://ns.adobe.com/textLayout/2008");
			default xml namespace = xmlns;
			
			// find all the nodes named "list"
			var listNodes:XMLList = exportedXML.child("list");
			assertTrue("Expected one list element and found: " + listNodes.length(), listNodes.length() == 1);
			
			//Check display.
			// determine what the bullet text should be
			var listItem:ListItemElement = new ListItemElement();
			var bulletText:String = "";
			var markerLength:int = 0;
			var listStartIndex:int = 0;
			var listFlowLine:TextFlowLine;
			var listLine:TextLine;
			var bulletLine:TextLine;
			for (var i:int=0; i<listItemsFound; i++)
			{
				listItem = listElement.getChildAt(i) as ListItemElement;
				bulletText = listElement.computeListItemText(listItem, listItem.computedListMarkerFormat());
				markerLength = bulletText.length + 1;
				// find the TextFlowLine for the list start
				listStartIndex = listElement.getElementRelativeStart(tf);
				listFlowLine = tf.flowComposer.findLineAtPosition(listStartIndex);
				listLine = listFlowLine.getTextLine();
				bulletLine = listLine.getChildAt(0) as TextLine;
				assertTrue("Did not find a TextLine for the bullet", bulletLine !=null);
				assertTrue("text length for the bullet line should be " + markerLength + ", but was " + bulletLine.rawTextLength, bulletLine.rawTextLength == markerLength);
			}
		}
		
		public function checkMarkerRegeneration():void
		{
			SelManager.selectRange(0,0);
			var tf:TextFlow = SelManager.textFlow;
			
			//Add four CJK_HEAVENLY_STEM list items
			var list:ListElement = new ListElement();
			list.listStyleType = ListStyleType.CJK_HEAVENLY_STEM;
			tf.addChild(list);
			var item:ListItemElement = new ListItemElement();
			list.addChild(item);
			list.addChild(new ListItemElement());
			list.addChild(new ListItemElement());
			list.addChild(new ListItemElement());
			tf.flowComposer.updateAllControllers();			
			
			var elem:FlowElement = tf.getChildAt(0);
			while (elem)
			{
				if (elem as ListElement)
				{
					// save this for list Marker check below
					var listElement:ListElement = elem as ListElement;
				}
				elem = elem.getNextSibling();
			}
			
			//check the Marker regeneration after adding list items, Check 3rd Marker
			var	listItem:ListItemElement = listElement.getChildAt(2) as ListItemElement;
			var	bulletText:String = listElement.computeListItemText(listItem, listItem.computedListMarkerFormat());
			assertTrue("Marker regeneration is incorrect after adding a new list item", bulletText == "丙.");
		
			//check the Marker regeneration after removing list items, Recheck 3rd Marker after remove 2nd Marker
			list.removeChildAt(1);
			tf.flowComposer.updateAllControllers();	
			elem = tf.getChildAt(0);
			while (elem)
			{
				if (elem as ListElement)
				{
					// save this for Marker check
					listElement = elem as ListElement;
				}
				elem = elem.getNextSibling();
			}
			listItem = listElement.getChildAt(2) as ListItemElement;
			bulletText = listElement.computeListItemText(listItem, listItem.computedListMarkerFormat());
			assertTrue("Marker regeneration is incorrect after removing a list item ", bulletText == "丙.");
		
			//check the Marker regeneration after changing the listStyeType
			list.listStyleType = ListStyleType.DIAMOND;
			listItem = listElement.getChildAt(2) as ListItemElement;
			bulletText = listElement.computeListItemText(listItem, listItem.computedListMarkerFormat());
			assertTrue("Marker regeneration is incorrect after changing listStyleType ", bulletText == "◆");
			
			list.listStyleType = ListStyleType.LOWER_GREEK;
			listItem = listElement.getChildAt(2) as ListItemElement;
			bulletText = listElement.computeListItemText(listItem, listItem.computedListMarkerFormat());
			assertTrue("Marker regeneration is incorrect after changing listStyleType ", bulletText == "γ.");
		}
		
		public function removeListItem():void
		{
			SelManager.selectRange(0,0);
			var tf:TextFlow = SelManager.textFlow;
			
			//Add four ARABIC_INDIC list items
			var list:ListElement = new ListElement();
			list.listStyleType = ListStyleType.ARABIC_INDIC;
			tf.addChild(list);
			var item:ListItemElement = new ListItemElement();
			list.addChild(item);
			list.addChild(new ListItemElement());
			list.addChild(new ListItemElement());
			list.addChild(new ListItemElement());
			//Remove one list item
			list.removeChildAt(1);
			tf.flowComposer.updateAllControllers();
			
			// Iterate through the FlowElements, looking for a ListElement.
			var listItemsFound:int = 0;
			var elem:FlowElement = tf.getChildAt(0);
			
			while (elem)
			{
				if (elem as ListElement)
				{
					// save this for display check below
					var listElement:ListElement = elem as ListElement;
					var elem2:FlowElement = listElement.getChildAt(0)
					while (elem2)
					{
						if (elem2 as ListItemElement)
						{
							listItemsFound++;
						}
						elem2 = elem2.getNextSibling();
					}
				}
				elem = elem.getNextSibling();
			}
			
			//check three listItems are still existing
			assertTrue("Expected one list element in the model and found: " + listItemsFound, listItemsFound == 3);
			
			//Check export
			var exportedXML:XML = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT,ConversionType.XML_TYPE) as XML;
			// set the default namespace to what the exported XML uses
			var xmlns:Namespace = new Namespace("http://ns.adobe.com/textLayout/2008");
			default xml namespace = xmlns;
			
			// find all the nodes named "list"
			var listNodes:XMLList = exportedXML.child("list");
			assertTrue("Expected one list element and found: " + listNodes.length(), listNodes.length() == 1);
			
			//Check display.
			var listItem:ListItemElement = new ListItemElement();
			var bulletText:String = "";
			var markerLength:int = 0;
			var listStartIndex:int = 0;
			var listFlowLine:TextFlowLine;
			var listLine:TextLine;
			var bulletLine:TextLine;
			for (var i:int=0; i<listItemsFound; i++)
			{
				listItem = listElement.getChildAt(i) as ListItemElement;
				bulletText = listElement.computeListItemText(listItem, listItem.computedListMarkerFormat());
				markerLength = bulletText.length + 1;
				// find the TextFlowLine for the list start
				listStartIndex = listElement.getElementRelativeStart(tf);
				listFlowLine = tf.flowComposer.findLineAtPosition(listStartIndex);
				listLine = listFlowLine.getTextLine();
				bulletLine = listLine.getChildAt(0) as TextLine;
				assertTrue("Did not find a TextLine for the bullet", bulletLine !=null);
				assertTrue("text length for the bullet line should be " + markerLength + ", but was " + bulletLine.rawTextLength, bulletLine.rawTextLength == markerLength);
			}
		}
		public function crossContainers():void
		{	
			var TestCanvas:Canvas;
			TestDisplayObject = testApp.getDisplayObject();
			if (TestDisplayObject)
			{
				TestCanvas = Canvas(TestDisplayObject);
			}
			var tf:TextFlow = new TextFlow();
			
			tf.flowComposer = new StandardFlowComposer();
			//create three linked containers
			
			var container1:Sprite = new Sprite();
			var container2:Sprite = new Sprite();
			var container3:Sprite = new Sprite();
			var controllerOne:ContainerController = new ContainerController(container1,100,100);
			var controllerTwo:ContainerController = new ContainerController(container2,100,100);
			var controllerThree:ContainerController = new ContainerController(container3,100,100);
			
			TestCanvas.rawChildren.addChild(container1);
			TestCanvas.rawChildren.addChild(container2);
			TestCanvas.rawChildren.addChild(container3);
			
			container1.x = 50;
			container1.y = 100;
			container2.x = 150;
			container2.y = 100;
			container3.x = 250;
			container3.y = 100;
			
			// add the controllers to the text flow and update them
			tf.flowComposer.addController(controllerOne);
			tf.flowComposer.addController(controllerTwo);
			tf.flowComposer.addController(controllerThree);
			controllerOne.verticalScrollPolicy = ScrollPolicy.AUTO;
			controllerTwo.verticalScrollPolicy = ScrollPolicy.AUTO;
			controllerThree.verticalScrollPolicy = ScrollPolicy.AUTO;
			tf.interactionManager = new EditManager();
			tf.flowComposer.updateAllControllers();
			
			//create List			
			var listElement:ListElement = new ListElement();
			listElement.listStyleType = ListStyleType.DECIMAL;
			tf.addChild(listElement);
			for(var i:int = 0; i<21; i++){
				listElement.addChild(new ListItemElement());				
			}			
			tf.flowComposer.updateAllControllers();			
			
			//Get the ListElment.
			var elem:FlowElement = tf.getChildAt(0);
			var listElem:ListElement;
			while (elem)
			{
				if (elem as ListElement)
				{
					// save this for list Marker check below
					listElem = elem as ListElement;
				}
				elem = elem.getNextSibling();
			}
			
			//check the Marker generation
			var listItem:ListItemElement;
			var bulletText:String;
			for(var j:int = 0; j <listElem.numChildren; j++ ){
				listItem = listElem.getChildAt(j) as ListItemElement;
				
				bulletText = listElem.computeListItemText(listItem, listItem.computedListMarkerFormat());
				assertTrue("Marker generation is incorrect after crossing the containers ",bulletText == ((j+1)+"."));
			}			
		}
		public function scrollByLinesTest():void
		{
			var TestCanvas:Canvas;
			TestDisplayObject = testApp.getDisplayObject();
			if (TestDisplayObject)
			{
				TestCanvas = Canvas(TestDisplayObject);
			}
			
			var Markup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008'> " +
				"<flow:p>before</flow:p>" +
				"<flow:list listStyleType='decimal'>" +
				"<flow:li>one</flow:li>" +
				"<flow:li>two</flow:li>" +
				"<flow:li>three</flow:li>" +
				"<flow:li>four</flow:li>" +
				"<flow:li>five</flow:li>" +
				"<flow:li>six</flow:li>" +
				"<flow:li>seven</flow:li>" +
				"<flow:li>eight</flow:li>" +
				"<flow:li>nine</flow:li>" +
				"<flow:li>ten</flow:li>" +				
				"</flow:list>" +
				"<flow:p>after</flow:p>" +
				"<flow:p></flow:p>" +
				"<flow:list listStyleType='upperAlpha' listStylePosition='inside'>" +
				"<flow:listMarkerFormat>" +
				"<flow:ListMarkerFormat beforeContent='Chapter ' content='counters(ordered,&quot;.&quot;,upperRoman)' afterContent='&#x9;'/>" +
				"</flow:listMarkerFormat>" +
				"<flow:li>" +
				"<p><span>First</span></p>" +
				"<flow:list>" +
				"<flow:listMarkerFormat>" +
				"<flow:ListMarkerFormat beforeContent='Section ' content='counters(ordered,&quot;.&quot;,upperRoman)' afterContent='&#x9;'/>" +
				"</flow:listMarkerFormat>" +
				"<flow:li>one</flow:li>" +
				"<flow:li>two</flow:li>" +
				"<flow:li>three</flow:li>" +
				"<flow:li>four</flow:li>" +
				"<flow:li>five</flow:li>" +
				"<flow:li>six</flow:li>" +
				"<flow:li>seven</flow:li>" +
				"<flow:li>eight</flow:li>" +
				"<flow:li>nine</flow:li>" +
				"<flow:li>ten</flow:li>" +	
				"</flow:list>" +
				"</flow:li>" +
				"</flow:list>" +
				"</flow:TextFlow>";
			var tf:TextFlow = TextConverter.importToFlow(Markup, TextConverter.TEXT_LAYOUT_FORMAT);			
			tf.flowComposer = new StandardFlowComposer();
			var blockProgression:String = tf.computedFormat.blockProgression;			
			
			var container:Sprite = new Sprite();			
			var controller:ContainerController = new ContainerController(container,200,100);
			
			TestCanvas.rawChildren.addChild(container);	
			container.x = 50;
			container.y = 50;			
			
			// add the controller to the text flow and update them
			tf.flowComposer.addController(controller);	
			controller.verticalScrollPolicy = ScrollPolicy.AUTO;
			tf.interactionManager = new EditManager();
			tf.flowComposer.updateAllControllers();
			
			var beforePosition:Array;
			var beforeFirstVisibleLine:int;
			var beforeLastVisibleLine:int;
			var afterPosition:Array;
			var afterFirstVisibleLine:int;
			var afterLastVisibleLine:int;
		
			var amount:Number;			
			var numberOfLines:int = 1;

			for (var i:int = 0; i< 17; i++){
				
				beforePosition = findFirstAndLastVisibleLine(tf.flowComposer, controller);
				
				amount = controller.getScrollDelta(numberOfLines);
				if (blockProgression == BlockProgression.TB)
					controller.verticalScrollPosition += amount;
				else
					controller.horizontalScrollPosition -= amount;
				
				tf.flowComposer.updateAllControllers();
				beforeFirstVisibleLine = beforePosition[0];
				beforeLastVisibleLine = beforePosition[1];
				
				afterPosition = findFirstAndLastVisibleLine(tf.flowComposer, controller);
				afterFirstVisibleLine = afterPosition[0];
				afterLastVisibleLine = afterPosition[1];
				
				// Check that we did scroll forward, and check that some text that was visible before is still visible.				
				assertTrue("scrollMultipleLines didn't advance scroll correctly at line "+ (i+1), afterFirstVisibleLine == beforeFirstVisibleLine + numberOfLines);
			}
			
			
		}
		// Copy of function in ContainerControllerBase -- if you change that one, change this one too!
		private function findFirstAndLastVisibleLine(flowComposer:IFlowComposer, controller:ContainerController):Array
		{
			var firstLine:int = flowComposer.findLineIndexAtPosition(controller.absoluteStart);
			var lastLine:int = flowComposer.findLineIndexAtPosition(controller.absoluteStart + controller.textLength - 1);
			var lastColumn:int = 0;
			var firstVisibleLine:int = -1;
			var lastVisibleLine:int = -1;
			for (var lineIndex:int = firstLine; lineIndex <= lastLine; lineIndex++)
			{
				var curLine:TextFlowLine = flowComposer.getLineAt(lineIndex);
				if (curLine.controller != controller)
					continue;
				
				// skip until we find the lines in the last column
				if (curLine.columnIndex != lastColumn)
					continue;
				
				if (curLine.textLineExists && curLine.getTextLine().parent)
				{
					if (firstVisibleLine < 0)
						firstVisibleLine = lineIndex;
					
					lastVisibleLine = lineIndex;
				}
			}
			
			return [firstVisibleLine, lastVisibleLine];
		}

		public function SplitAndMergeCauseMarkerRegeneration():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.selectRange(0,0);
			var tf:TextFlow = SelManager.textFlow;
			tf.removeChildAt(0);
			var list:ListElement = new ListElement();
			list.listStyleType = ListStyleType.DECIMAL;
			
			tf.addChild(list);
			var item:ListItemElement = new ListItemElement();
			list.addChild(item);
			list.addChild(new ListItemElement());
			list.addChild(new ListItemElement());
			tf.flowComposer.updateAllControllers();				
			
			//check the Marker regeneration after merging list items
			SelManager.selectRange(2,2);
			var kBackSpace:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, Keyboard.BACKSPACE);
			TestFrame.container["dispatchEvent"](kBackSpace);
			SelManager.flushPendingOperations();			
			tf.flowComposer.updateAllControllers();
			
			var	listItem1:ListItemElement = list.getChildAt(0) as ListItemElement;
			var	bulletText1:String = list.computeListItemText(listItem1, listItem1.computedListMarkerFormat());			
			var	listItem2:ListItemElement = list.getChildAt(1) as ListItemElement;
			var	bulletText2:String = list.computeListItemText(listItem2, listItem2.computedListMarkerFormat());
			assertTrue("Marker regeneration is incorrect after merging a new list item", 
				bulletText1 == "1." && bulletText2 == "2.");
			
			//check the Marker regeneration after spliting list items
			SelManager.selectRange(0,0);
			var kEnter:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, Keyboard.ENTER);
			TestFrame.container["dispatchEvent"](kEnter);
			SelManager.flushPendingOperations();			
			tf.flowComposer.updateAllControllers();
			
			listItem1 = list.getChildAt(0) as ListItemElement;
			bulletText1 = list.computeListItemText(listItem1, listItem1.computedListMarkerFormat());			
			listItem2 = list.getChildAt(1) as ListItemElement;
			bulletText2 = list.computeListItemText(listItem2, listItem2.computedListMarkerFormat());
			var	listItem3:ListItemElement = list.getChildAt(2) as ListItemElement;	
			var	bulletText3:String = list.computeListItemText(listItem3, listItem3.computedListMarkerFormat());
			assertTrue("Marker regeneration is incorrect after spliting a new list item",
				bulletText1 == "1." && bulletText2 == "2." &&  bulletText3 == "3.");
		}
		
		public function listItemGoOutOfList():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.selectRange(0,0);
			var tf:TextFlow = SelManager.textFlow;
			tf.removeChildAt(0);
			var list:ListElement = new ListElement();
			list.listStyleType = ListStyleType.DECIMAL;
			
			tf.addChild(list);
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
			list.addChild(new ListItemElement());

			tf.flowComposer.updateAllControllers();	

			var kEnter:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, Keyboard.ENTER);
			var kBackSpace:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, Keyboard.BACKSPACE);
			
			//Enter on an empty list item at the end of the list should remove the empty item and put the cursor after the list
			SelManager.selectRange(6,6);
			TestFrame.container["dispatchEvent"](kEnter);
			SelManager.flushPendingOperations();			
			tf.flowComposer.updateAllControllers();
			
			assertTrue("Number of Items in List is incorrect after ente on an empty list item at the end of the list", 
				list.numChildren == 2);
			assertTrue("Item out of List is incorrect after enter on an empty list item at the end of the list", 
				tf.getChildAt(0) is ListElement && tf.getChildAt(1) is ParagraphElement);
			
			//Backspace from the beginning of first item should pull item out of the list and regenerate markers.
			SelManager.selectRange(0,0);
			TestFrame.container["dispatchEvent"](kBackSpace);
			SelManager.flushPendingOperations();			
			tf.flowComposer.updateAllControllers();
						
			var listItem1:ListItemElement = list.getChildAt(0) as ListItemElement;
			var	marker:String = list.computeListItemText(listItem1, listItem1.computedListMarkerFormat());	
			assertTrue("Marker is incorrect after backspace from the beginning of first item", marker == "1.");
			var elem1:ParagraphElement = tf.getChildAt(0) as ParagraphElement;
			var elem2:ListElement = tf.getChildAt(1) as ListElement;
			span1 = elem1.getChildAt(0) as SpanElement;
			item2 = elem2.getChildAt(0) as ListItemElement;
			para2 = item2.getChildAt(0) as ParagraphElement;
			span2 = para2.getChildAt(0) as SpanElement;
			assertTrue("Item out of List is incorrect after backspace from the beginning of first item", 
				tf.getChildAt(0) is ParagraphElement && tf.getChildAt(1) is ListElement && span1.text == "ab" );
			assertTrue("The first item is incorrect backspace from the beginning of first item", span2.text == "cd");
			assertTrue("Number of Items is incorrect after backspace from the beginning of first item", list.numChildren == 1);
		}
		public function splitElementOperationTest():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var listItemMarkup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
				+"<list><li><div><p><span>が全然分からへん。</span><tcy>12</tcy></p></div></li></list>"
				+"</TextFlow>";
			var listFlow:TextFlow = TextConverter.importToFlow(listItemMarkup,TextConverter.TEXT_LAYOUT_FORMAT);
			var list:ListElement = listFlow.getChildAt(0) as ListElement;
			var listCopy:ListElement;

			// splitElementOperation on List at the beginnning
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			var xmlOut:XML = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			SelManager.selectRange(0,0);
			EditManager(SelManager).splitElement(listCopy as ListElement);
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of Lists is incorrect after splitElementOperation on List at the beginnning",tf.numChildren == 2 );
			
			// splitElementOperation on List in the middle
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			SelManager.selectRange(3,3);
			EditManager(SelManager).splitElement(listCopy as ListElement);
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of Lists is incorrect after splitElementOperation on List in the middle",tf.numChildren == 2 );
			
			// splitElementOperation on List at the end
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			SelManager.selectRange(13,13);
			EditManager(SelManager).splitElement(listCopy as ListElement);
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of Lists is incorrect after splitElementOperation on List at the end",tf.numChildren == 2 );
			
			// splitElementOperation on ListItem at the beginnning
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			SelManager.selectRange(0,0);
			list = tf.getChildAt(0) as ListElement;
			EditManager(SelManager).splitElement(list.getChildAt(0)as ListItemElement);
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of ListItems is incorrect after splitElementOperation on ListItem at the beginnning", listCopy.numChildren == 2 );
			
			// splitElementOperation on ListItem in the middle
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			SelManager.selectRange(3,3);
			list = tf.getChildAt(0) as ListElement;
			EditManager(SelManager).splitElement(list.getChildAt(0)as ListItemElement);
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of ListItems is incorrect after splitElementOperation on ListItem in the middle", listCopy.numChildren == 2 );
			
			// splitElementOperation on ListItem at the end
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			SelManager.selectRange(13,13);
			list = tf.getChildAt(0) as ListElement;
			EditManager(SelManager).splitElement(list.getChildAt(0)as ListItemElement);
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of ListItems is incorrect after splitElementOperation on ListItem at the end", listCopy.numChildren == 2 );
			
			// splitElementOperation on div at the beginnning
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			SelManager.selectRange(0,0);
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			list = tf.getChildAt(0) as ListElement;
			var listItem: ListItemElement = list.getChildAt(0) as ListItemElement;
			EditManager(SelManager).splitElement(listItem.getChildAt(0) as DivElement);
			listCopy = tf.getChildAt(0) as ListElement;
			listItem = listCopy.getChildAt(0) as ListItemElement;
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of Divs is incorrect after splitElementOperation on Div at the beginnning", listItem.numChildren == 2 );
			
			// splitElementOperation on div in the middle
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			SelManager.selectRange(3,3);
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			list = tf.getChildAt(0) as ListElement;
			listItem = list.getChildAt(0) as ListItemElement;
			EditManager(SelManager).splitElement(listItem.getChildAt(0) as DivElement);
			listCopy = tf.getChildAt(0) as ListElement;
			listItem = listCopy.getChildAt(0) as ListItemElement;
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of Divs is incorrect after splitElementOperation on Div in the middle", listItem.numChildren == 2 );
			
			// splitElementOperation on div at the end
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			SelManager.selectRange(13,13);
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			list = tf.getChildAt(0) as ListElement;
			listItem = list.getChildAt(0) as ListItemElement;
			EditManager(SelManager).splitElement(listItem.getChildAt(0) as DivElement);
			listCopy = tf.getChildAt(0) as ListElement;
			listItem = listCopy.getChildAt(0) as ListItemElement;
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of Divs is incorrect after splitElementOperation on Div at the end", listItem.numChildren == 2 );
			
			
			// splitElementOperation on paragraph at the beginnning
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			
			SelManager.selectRange(0,0);
			list = tf.getChildAt(0) as ListElement;
			listItem = list.getChildAt(0) as ListItemElement;
			var div: DivElement = listItem.getChildAt(0) as DivElement;
			EditManager(SelManager).splitElement(div.getChildAt(0) as ParagraphElement);
			list = tf.getChildAt(0) as ListElement;
			listItem = list.getChildAt(0) as ListItemElement;
			div = listItem.getChildAt(0) as DivElement;
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of para is incorrect after splitElementOperation on para at the beginnning", div.numChildren == 2 );	
			
			// splitElementOperation on paragraph in the middle
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			
			SelManager.selectRange(3,3);
			list = tf.getChildAt(0) as ListElement;
			listItem = list.getChildAt(0) as ListItemElement;
			div = listItem.getChildAt(0) as DivElement;
			EditManager(SelManager).splitElement(div.getChildAt(0) as ParagraphElement);
			list = tf.getChildAt(0) as ListElement;
			listItem = list.getChildAt(0) as ListItemElement;
			div = listItem.getChildAt(0) as DivElement;
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of para is incorrect after splitElementOperation on para in the middle", div.numChildren == 2 );	
			
			// splitElementOperation on paragraph at the end
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			
			SelManager.selectRange(13,13);
			list = tf.getChildAt(0) as ListElement;
			listItem = list.getChildAt(0) as ListItemElement;
			div = listItem.getChildAt(0) as DivElement;
			EditManager(SelManager).splitElement(div.getChildAt(0) as ParagraphElement);
			list = tf.getChildAt(0) as ListElement;
			listItem = list.getChildAt(0) as ListItemElement;
			div = listItem.getChildAt(0) as DivElement;
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of para is incorrect after splitElementOperation on para at the end", div.numChildren == 2 );	
			
			// splitElementOperation on tcy
			/*list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			
			SelManager.selectRange(10,10);
			list = tf.getChildAt(0) as ListElement;
			listItem = list.getChildAt(0) as ListItemElement;
			div = listItem.getChildAt(0) as DivElement;
			var para: ParagraphElement = div.getChildAt(0) as ParagraphElement;

			EditManager(SelManager).splitElement(para.getChildAt(1) as TCYElement);
			list = tf.getChildAt(0) as ListElement;
			listItem = list.getChildAt(0) as ListItemElement;
			div = listItem.getChildAt(0) as DivElement;
			para = div.getChildAt(0) as ParagraphElement;
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			trace(xmlOut);
			assertTrue("The number of TCY is incorrect after splitElementOperation on TCY", para.numChildren == 3 ); 
			*/
		}
		
		public function enterSplitListItem():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var listItemMarkup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
				+"<list><li><div><p><span>abc</span></p></div></li></list>"
				+"</TextFlow>";
			var listFlow:TextFlow = TextConverter.importToFlow(listItemMarkup,TextConverter.TEXT_LAYOUT_FORMAT);
			var list:ListElement = listFlow.getChildAt(0) as ListElement;
			var listCopy:ListElement;
			
			// setup
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			// enter at the beginning of a list item
			var kEnter:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, Keyboard.ENTER);
			SelManager.selectRange(0,0);
			TestFrame.container["dispatchEvent"](kEnter);
			SelManager.flushPendingOperations();			
			tf.flowComposer.updateAllControllers();
			var xmlOut:XML = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			list = tf.getChildAt(0) as ListElement;
			assertTrue("The number of list items is incorrect after enter at the beginning", list.numChildren == 2 );
			var item1:ListItemElement = list.getChildAt(0) as ListItemElement;
			assertTrue("The structure of the first item created after enter at the beginning is incorrect", 
				item1.getChildAt(0) is DivElement );
			var div1:DivElement = item1.getChildAt(0) as DivElement; 
			var para1:ParagraphElement = div1.getChildAt(0) as ParagraphElement;
			var span1:SpanElement = para1.getChildAt(0) as SpanElement;
			assertTrue("The text of the first item created after enter at the beginning is incorrect", span1.text == "");
			var item2:ListItemElement = list.getChildAt(1) as ListItemElement;
			assertTrue("The structure of the second item created after enter at the beginning is incorrect", 
				item2.getChildAt(0) is DivElement);
			var div2:DivElement = item2.getChildAt(0) as DivElement;
			var para2:ParagraphElement = div2.getChildAt(0) as ParagraphElement;
			var span2:SpanElement = para2.getChildAt(0) as SpanElement;
			assertTrue("The text of the second item created after enter at the beginning is incorrect", span2.text == "abc");
			
			// setup
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			// enter in the middle of a list item
			SelManager.selectRange(2,2);
			TestFrame.container["dispatchEvent"](kEnter);
			SelManager.flushPendingOperations();			
			tf.flowComposer.updateAllControllers();
			list = tf.getChildAt(0) as ListElement;
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			assertTrue("The number of list items is incorrect after enter in the middle", list.numChildren == 2 );
			item1 = list.getChildAt(0) as ListItemElement;
			assertTrue("The structure of the first item created after enter in the middle is incorrect", 
				item1.getChildAt(0) is DivElement);
			div1 = item1.getChildAt(0) as DivElement;
			para1 = div1.getChildAt(0) as ParagraphElement;
			span1 = para1.getChildAt(0) as SpanElement;
			assertTrue("The text of the  first item created after enter in the middle is incorrect", span1.text == "ab");
			item2 = list.getChildAt(1) as ListItemElement;
			assertTrue("The structure of the second item created after enter in the middle is incorrect", 
				item2.getChildAt(0) is DivElement);
			div2 = item2.getChildAt(0) as DivElement;
			para2 = div2.getChildAt(0) as ParagraphElement;
			span2 = para2.getChildAt(0) as SpanElement;
			assertTrue("The text of the second item created after enter in the middle is incorrect", span2.text == "c");
			
			// setup
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			// enter at the end of a list item
			SelManager.selectRange(3,3);
			TestFrame.container["dispatchEvent"](kEnter);
			SelManager.flushPendingOperations();			
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			list = tf.getChildAt(0) as ListElement;
			assertTrue("The number of list items is incorrect after enter at the end", list.numChildren == 2 );
			item1 = list.getChildAt(0) as ListItemElement;
			assertTrue("The structure of the first item created after enter at the end is incorrect", 
				item1.getChildAt(0) is DivElement);
			div1 = item1.getChildAt(0) as DivElement;
			para1 = div1.getChildAt(0) as ParagraphElement;
			span1 = para1.getChildAt(0) as SpanElement;
			assertTrue("The text of the first item created after enter at the end is incorrect", span1.text == "abc");
			item2 = list.getChildAt(1) as ListItemElement;
			assertTrue("The structure of the second item created after enter at the end is incorrect", 
				item2.getChildAt(0) is DivElement);
			div2 = item2.getChildAt(0) as DivElement;
			para2 = div2.getChildAt(0) as ParagraphElement;
			span2 = para2.getChildAt(0) as SpanElement;
			assertTrue("The text of the second item created after enter at the end is incorrect", span2.text == "");
		}
		
		public function backspaceMergeListItem():void
		{
			var tf:TextFlow = SelManager.textFlow;
			var listItemMarkup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
				+"<list>"
				+"<li><p><span>ab</span></p></li>"
				+"<li><p><span>cd</span></p></li>"
				+"<li><div><p><span>ef</span></p></div></li>"
				+"<li><p><tcy><span>ab</span></tcy></p></li>"
				+"<li><p><tcy><span>cd</span></tcy></p></li>"
				+"<li><div><p><span>ef</span></p></div></li>"
				+"<li><div><p><span>gh</span></p></div></li>"
				+"</list>"
				+"</TextFlow>";
			var listFlow:TextFlow = TextConverter.importToFlow(listItemMarkup,TextConverter.TEXT_LAYOUT_FORMAT);
			var list:ListElement = listFlow.getChildAt(0) as ListElement;
			var listCopy:ListElement;

			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			//merge two list items that have only paragraph element
			var kBackspace:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, Keyboard.BACKSPACE);
			SelManager.selectRange(3,3);
			TestFrame.container["dispatchEvent"](kBackspace);
			SelManager.flushPendingOperations();			
			tf.flowComposer.updateAllControllers();
			var xmlOut:XML = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			list = tf.getChildAt(0) as ListElement;
			assertTrue("The number of list items is incorrect after merging two list items that have only paragraph element", 
				list.numChildren == 6 );
			var item1:ListItemElement = list.getChildAt(0) as ListItemElement;
			assertTrue("The structure of the item created after merging two list items that have only paragraph element", 
				item1.numChildren == 1 && item1.getChildAt(0) is ParagraphElement);
			var para:ParagraphElement = item1.getChildAt(0) as ParagraphElement;
			var span:SpanElement = para.getChildAt(0) as SpanElement;
			assertTrue("The text of the item created after merging two list items that have only paragraph element", span.text == "abcd");

			//merge two list items that both have paragraph nested in Div
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			
			SelManager.selectRange(18,18);
			TestFrame.container["dispatchEvent"](kBackspace);
			SelManager.flushPendingOperations();
			SelManager.selectRange(18,18);
			TestFrame.container["dispatchEvent"](kBackspace);
			SelManager.flushPendingOperations();
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			list = tf.getChildAt(0) as ListElement;
			assertTrue("The number of list items is incorrect after merging two list items that both have paragraph nested in Div", 
				list.numChildren == 6 );
			item1 = list.getChildAt(5) as ListItemElement;
			var div:DivElement = item1.getChildAt(0) as DivElement; 
			assertTrue("The structure of the item created after merging two list items that both have paragraph nested in Div", 
				item1.numChildren == 1 && item1.getChildAt(0) is DivElement);
			para = div.getChildAt(0) as ParagraphElement;
			span = para.getChildAt(0) as SpanElement;
			assertTrue("The text of the item created after merging two list items that both have paragraph nested in Div", span.text == "efgh");
			
			//merge two list items that have different elements
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			
			SelManager.selectRange(9,9);
			TestFrame.container["dispatchEvent"](kBackspace);
			SelManager.flushPendingOperations();		
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			list = tf.getChildAt(0) as ListElement;
			assertTrue("The number of list items is incorrect after merging two list items that have different elements", 
				list.numChildren == 6 );
			var item2:ListItemElement = list.getChildAt(2) as ListItemElement;
			div = item2.getChildAt(0) as DivElement;
			para = div.getChildAt(0) as ParagraphElement;
			assertTrue("The structure of the item created after merging two list items that have different elements is incorrect", 
				para.numChildren == 2 && para.getChildAt(0) is SpanElement && para.getChildAt(1) is TCYElement);			
			var span1:SpanElement = para.getChildAt(0) as SpanElement;
			var tcy:TCYElement = para.getChildAt(1) as TCYElement;
			var span2:SpanElement = tcy.getChildAt(0) as SpanElement;
			assertTrue("The text of the item created after merging two list items that have different elements is incorrect", 
				span1.text == "ef" && span2.text == "ab" );
			
			//merge two list items that have only tcy nested in paragraph
			list = listFlow.getChildAt(0) as ListElement;
			listCopy = list.deepCopy(0,list.textLength) as ListElement;
			tf.replaceChildren(0,tf.numChildren,listCopy);
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			
			SelManager.selectRange(12,12);
			TestFrame.container["dispatchEvent"](kBackspace);
			SelManager.flushPendingOperations();			
			tf.flowComposer.updateAllControllers();
			xmlOut = TextConverter.export(tf,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut);
			list = tf.getChildAt(0) as ListElement;
			assertTrue("The number of list items is incorrect after merging two list items that have tcy nested in paragraph", 
				list.numChildren == 6 );
			var item3:ListItemElement = list.getChildAt(3) as ListItemElement;
			assertTrue("The structure of the item created after merging two list items that have tcy nested in paragraph is incorrect", 
				item3.numChildren == 1 && item3.getChildAt(0) is ParagraphElement);
			para = item3.getChildAt(0) as ParagraphElement;
			tcy = para.getChildAt(0) as TCYElement;			
			span = tcy.getChildAt(0) as SpanElement;
			assertTrue("The text of the item created after merging two list items that have tcy nested in paragraph is incorrect", 
				span.text == "abcd");
		}
		
		public function tabsInMarkerFormat():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			SelManager.selectRange(0,0);
			textFlow.replaceChildren(0,textFlow.numChildren);
			
			var list:ListElement = new ListElement()
			list.listStyleType = "decimal"; 
			list.listStylePosition = "inside";
			list.paddingLeft = "0";
			
			var listMarkerFormat:ListMarkerFormat = new ListMarkerFormat();
			var tabStops:Array = new Array();
			var tabstop:TabStopFormat = new TabStopFormat();
			tabstop.position = 50;
			var tabstop2:TabStopFormat = new TabStopFormat();
			tabstop2.position = 80;
			tabStops.push(tabstop);
			tabStops.push(tabstop2);
			listMarkerFormat.tabStops = tabStops;
			listMarkerFormat.beforeContent = "- ";
			listMarkerFormat.afterContent = String.fromCharCode(0x9);
			
			var item:ListItemElement;
			item = new ListItemElement();
			item.listMarkerFormat = listMarkerFormat;
			var paragraphElement:ParagraphElement = new ParagraphElement();
			var spanElement:SpanElement = new SpanElement();
			spanElement.text = "Text starts here";
			paragraphElement.addChild(spanElement);
			item.addChild(paragraphElement);
			list.addChild(item);
			textFlow.addChild(list);
			
			textFlow.flowComposer.updateAllControllers();
		}
		
		public function listMarkerFormatTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			SelManager.selectRange(0,0);
			//textFlow.format = null;
			textFlow.replaceChildren(0,textFlow.numChildren);
			
			var p:ParagraphElement = new ParagraphElement();
			var span:SpanElement = new SpanElement();
			var listElement:ListElement = new ListElement()
			listElement.listStyleType = "decimal"; 
			listElement.listStylePosition = "inside";
			listElement.paddingLeft = "0";
			var listItemElement:ListItemElement = new ListItemElement();
			
			var listMarkerFormat:ListMarkerFormat = new ListMarkerFormat();
			var listMarkerFormat2:ListMarkerFormat = new ListMarkerFormat();
			
			//concat test
			// set format attributes in the first one
			listMarkerFormat.afterContent = "*";
			listMarkerFormat.color = 0x336633;
			listMarkerFormat.fontSize = 18;
			// set some of the same attributes on the second one listMarkerFormat2
			listMarkerFormat2.color = 0x0000CC;
			listMarkerFormat2.fontSize = 12;
			listMarkerFormat2.fontFamily = "Arial, Helvetica, _sans";
			
			// concat listMarkerFormat2 settings;		
			listMarkerFormat.concat(listMarkerFormat2);	
			//assign format to the listElement
			listItemElement.listMarkerFormat = listMarkerFormat;
			
			assertTrue("concat doesn't work properly. ",listMarkerFormat.afterContent == "*" &&
				listMarkerFormat.color == 0x336633 &&
				listMarkerFormat.fontSize == 18 &&
				listMarkerFormat.fontFamily == "Arial, Helvetica, _sans");
			
			span.text = "concat() test successful. ";
			
			//concatInheritOnly test
			listMarkerFormat = new ListMarkerFormat();
			listMarkerFormat2 = new ListMarkerFormat();
			// set format attributes in the first one
			listMarkerFormat.color = 0xFF0000;
			listMarkerFormat.fontSize = undefined;	
			// set some of the same attributes on the second one listMarkerFormat2
			listMarkerFormat2.color = 0x00FF00;
			listMarkerFormat2.backgroundColor = 0x00CCCC;
			listMarkerFormat2.fontSize = 16;
			listMarkerFormat2.fontFamily = "Times Roman";
			
			// concatInheritOnly listMarkerFormat2 settings;		
			listMarkerFormat.concatInheritOnly(listMarkerFormat2);	
			//assign format to the listElement
			listItemElement.listMarkerFormat = listMarkerFormat;
			
			assertTrue("concatInheritOnly doesn't work properly. ",
				listMarkerFormat.backgroundColor == undefined &&
				listMarkerFormat.color == 0xFF0000 &&
				listMarkerFormat.fontSize == 16 &&
				listMarkerFormat.fontFamily == "Times Roman");
			
			span.text += "concatInheritOnly() test successful. "
				
			//apply() test
			listMarkerFormat = new ListMarkerFormat();
			listMarkerFormat2 = new ListMarkerFormat();
			// set format attributes in the first one
			listMarkerFormat.textIndent = 8;
			listMarkerFormat.color = 0x336633;
			listMarkerFormat.fontFamily = "Arial, Helvetica, _sans";
			listMarkerFormat.fontSize = 24;
			// set some of the same attributes on the second one
			listMarkerFormat2.color = 0x0000CC;
			listMarkerFormat2.fontSize = 12;
			listMarkerFormat2.textIndent = 24;
			
			// apply listMarkerFormat2 settings;		
			listMarkerFormat.apply(listMarkerFormat2);	
			//assign format to the listElement
			listItemElement.listMarkerFormat = listMarkerFormat;
			
			assertTrue("apply() doesn't work properly. ",
				listMarkerFormat.textIndent == 24 &&
				listMarkerFormat.color == 0x0000CC &&
				listMarkerFormat.fontSize == 12 &&
				listMarkerFormat.fontFamily == "Arial, Helvetica, _sans");
			
			// add text to the span, the span to the paragraph, and the paragraph to the text flow.
			span.text += "apply() test successful. ";
			
			//removeMatching() test
			listMarkerFormat = new ListMarkerFormat();
			listMarkerFormat2 = new ListMarkerFormat();
			// set format attributes in the first one
			listMarkerFormat.textIndent = 8;
			listMarkerFormat.color = 0x336633;
			listMarkerFormat.fontFamily = "Arial, Helvetica, _sans";
			listMarkerFormat.fontSize = 24;
			
			// set fontFamily to same value for listMarkerFormat2			
			listMarkerFormat2.fontFamily = "Arial, Helvetica, _sans";
			
			// call removeMatching() to remove any values that match textLayoutFormat2; 
			listMarkerFormat.removeMatching(listMarkerFormat2);	
			//assign format to the listElement
			listItemElement.listMarkerFormat = listMarkerFormat;
			
			assertTrue("removeMatching() doesn't work properly. ",
				listMarkerFormat.textIndent == 8 &&
				listMarkerFormat.color == 0x336633 &&
				listMarkerFormat.fontSize == 24 &&
				listMarkerFormat.fontFamily == undefined);
			
			// add text to the span, the span to the paragraph, and the paragraph to the text flow.
			span.text += "removeMatching() test successful. " 
				
			//removeClashing() test
			listMarkerFormat = new ListMarkerFormat();
			listMarkerFormat2 = new ListMarkerFormat();
			// set format attributes in the first one
			listMarkerFormat.textIndent = 8;
			listMarkerFormat.color = 0x336633;
			listMarkerFormat.fontFamily = "Arial, Helvetica, _sans";
			listMarkerFormat.fontSize = 24;
			
			// set fontFamily to same value for listMarkerFormat2			
			listMarkerFormat2.fontFamily = "Arial, Helvetica, _sans";
			
			// call removeClashing() to remove any values that clash listMarkerFormat; 
			listMarkerFormat.removeClashing(listMarkerFormat2);	
			//assign format to the listElement
			listItemElement.listMarkerFormat = listMarkerFormat;
			
			assertTrue("removeClashing() doesn't work properly. ",
				listMarkerFormat.textIndent == 8 &&
				listMarkerFormat.color == 0x336633 &&
				listMarkerFormat.fontSize == 24 &&
				listMarkerFormat.fontFamily == "Arial, Helvetica, _sans");
			
			// add text to the span, the span to the paragraph, and the paragraph to the text flow.
			span.text += "removeClashing() test successful. " 
			
			p.addChild(span);
			listItemElement.addChild(p);
			listElement.addChild(listItemElement);
			textFlow.addChild(listElement);
			textFlow.flowComposer.updateAllControllers(); 
		}
		
		//yongtian : Watson Bug#2800975 ListMarkerFormat.paragraphStartIndent not applied properly in Inside lists.
		/**
		 * The attribute listMarkerFormat.paragraphStartIndent should push all of the list content to the right. 
		 */
		public function ListListMarkerFormatparagraphStartIndent():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			SelManager.selectRange(0,0);
		
			textFlow.replaceChildren(0,textFlow.numChildren);
			
			var list:ListElement = new ListElement()
			list.listStyleType = "decimal"; 
			list.listStylePosition = "inside";
			list.paddingLeft = "50";
			list.paddingTop = "50";
			list.paddingRight = "50";
			
			var listMarkerFormat:ListMarkerFormat = new ListMarkerFormat();
			listMarkerFormat.beforeContent = "- ";
			listMarkerFormat.afterContent = String.fromCharCode(0x9);
			listMarkerFormat.paragraphStartIndent = "25";
			
			var item:ListItemElement;
			item = new ListItemElement();
			item.listMarkerFormat = listMarkerFormat;
			var paragraphElement:ParagraphElement = new ParagraphElement();
			var spanElement:SpanElement = new SpanElement();
			spanElement.text = "Text starts here";
			paragraphElement.addChild(spanElement);
			item.addChild(paragraphElement);
			list.addChild(item);
			textFlow.addChild(list);	
			
			textFlow.flowComposer.updateAllControllers();
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var line:TextFlowLine = textFlow.flowComposer.getLineAt(0);
			assertTrue("Expected list to indent to paragraphStartIndent and Padding",line.lineOffset== 90);
		}
		
		//yongtian : Fix bug related Bug#2800975, the custom tabStop of ListMarkerFormat are not correct displayed   
		public function ListMarkerFormatTabStopTest():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			SelManager.selectRange(0,0);
			textFlow.replaceChildren(0,textFlow.numChildren);
	
			var list:ListElement = new ListElement()
			list.listStyleType = "decimal";
			list.listStylePosition = "inside";
			list.paddingLeft = 0;
			
			var listMarkerFormat:ListMarkerFormat = new ListMarkerFormat();
			
			var tabStops:Array = new Array();
			var tabstop:TabStopFormat = new TabStopFormat();
			tabstop.position = 70;
			tabStops.push(tabstop);
			listMarkerFormat.tabStops = tabStops;
			listMarkerFormat.beforeContent = "- ";
			listMarkerFormat.afterContent = String.fromCharCode(0x9);
			var item:ListItemElement;
			item = new ListItemElement();
			item.listMarkerFormat = listMarkerFormat;
			var paragraphElement:ParagraphElement = new ParagraphElement();
			paragraphElement.paragraphStartIndent = 0;
			var spanElement:SpanElement = new SpanElement();
			spanElement.text = "Text starts at 100";
			paragraphElement.addChild(spanElement);
			item.addChild(paragraphElement);
			list.addChild(item);
			textFlow.addChild(list);
			textFlow.flowComposer.updateAllControllers();		
			assertTrue("The custome TabStop is not correct!",(((textFlow.getChildAt(0) as ListElement).mxmlChildren[0] as ListItemElement).computedFormat.listMarkerFormat.afterContent) == "\t" && ((((textFlow.getChildAt(0) as ListElement).mxmlChildren[0] as ListItemElement).computedFormat.listMarkerFormat.tabStops as Array)[0] as TabStopFormat).position == 70);	
		}
	}
}