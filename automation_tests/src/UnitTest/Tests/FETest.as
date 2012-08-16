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
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.text.engine.FontWeight;
	import flash.text.engine.Kerning;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.*;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.DamageEvent;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.operations.FlowOperation;
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;
	
	import mx.utils.LoaderUtil;
	import flashx.textLayout.conversion.ITextLayoutImporter;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.container.TextContainerManager;
	import flash.text.engine.TextLineValidity;
	import mx.core.Container;
	import mx.containers.Canvas;
	import flashx.textLayout.compose.FlowComposerBase;
	import flashx.textLayout.events.CompositionCompleteEvent;

 	public class FETest extends VellumTestCase
	{
		private var data:Array;
		private var callback:Boolean = false;
//		private var inlineGraphicSWFEnabled:Boolean = false;
		private var src:String;
		private var baseImageURL:String;
		private var indx1:int;
		private var indx2:int;
		private var indx3:int;
		private var img1:InlineGraphicElement;
		private var img2:InlineGraphicElement;
		private var img3:InlineGraphicElement;

		public function FETest(methodName:String, testID:String, data:Array, testConfig:TestConfig, testXML:XML=null)
		{
			super(methodName, testID, testConfig, testXML);
			this.data = data;

			this.TestID = this.TestID + ":";
			for each (var url:String in data)
			{
				this.TestID = this.TestID + ":" + url;

				if(url.search(".swf") != -1){
					TestData["bitmapSnapshot"] = "false";
				}
			}
			baseImageURL = LoaderUtil.createAbsoluteURL(baseURL, "../../test/testFiles/assets/");

			// Note: These must correspond to a Watson product area (case-sensitive)
			metaData.productArea = "Graphics";
		}

		public static function suiteFromXML(testListXML:XML, testConfig:TestConfig, ts:TestSuiteExtended):void
 		{
			var writingDirection:String = testConfig.writingDirection[0] + "_" + testConfig.writingDirection[1];
			for each (var testCaseXML:XML in testListXML.*)
			{
				if (testCaseXML.localName() == "TestCase" &&
					testCaseXML.TestData.(@name == writingDirection).toString() != "false")
				{
					var fe:XMLList = testCaseXML.TestData.(@name == "foreignElement");

					for each (var battery:String in fe.toString().split(","))
					{
						var array:Array = new Array();

						if(battery.indexOf("+") != -1){
							for each (var element:String in battery.split("+"))
							{
								for each (var group:* in fe.@dataGroup.toString().split(","))
								{
									var dg:XMLList =
										testListXML.DataGroup.(@group == group.toString());
									for each (var url:XML in dg.*)
									{
										if(battery.indexOf(url.@name.toString()) != -1)
										{
											array.push(url.@url.toString());
										}
									}
								}
							}
						}else{
							for each (var group2:* in fe.@dataGroup.toString().split(","))
							{
								var dg2:XMLList =
									testListXML.DataGroup.(@group == group2.toString());
								for each (var url2:XML in dg2.*)
								{
									if(battery.indexOf(url2.@name.toString()) != -1)
									{
										array.push(url2.@url.toString());
										break;
									}
								}
							}
						}
						var testID:String = testCaseXML.@functionName.toString();
						for each (var urlStr:String in array)
						{
							testID = testID + "-" + urlStr;
						}
						var tempXML:XML = testCaseXML.copy();
						tempXML.appendChild (<TestData name="id">{testID}</TestData>);
						ts.addTestDescriptor(new TestDescriptor (FETest, tempXML.@functionName, testConfig, tempXML, null, array));
					}
				}
			}
 		}
		/*
		*	Load a TextFlow using StandardFlowComposer and wait for its graphics to load
		*	Call removeAllcontrollers 
		*	Verify graphics are still loaded
		*	call textFlow.unloadGraphics
		*	verify graphics are unloaded
		*	add controllers; compose
		*	verify graphics are still unloaded
		*	call prepareGraphicsForLoad then damage & compose
		*	verify graphics are loaded
		*/
		public function loadUnloadGraphicsTest(callBack:Object = null):void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var selectIndx:int = textFlow.textLength/2;
			if(!callback)
			{
				callback = true;
				TestFrame.container.addEventListener(Event.ENTER_FRAME,addAsync(loadUnloadGraphicsTest,2500,null),false,0,true);
				
				var src:String = data[data.length-1].toString();
				var width:int = 20;
				var height:int = 20;
				
				SelManager.selectRange(selectIndx, selectIndx);
				SelManager.insertInlineGraphic("../../test/testFiles/assets/smiling.png",width,height);
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				var img:InlineGraphicElement = textFlow.findLeaf(selectIndx) as InlineGraphicElement;
				assertTrue("Inline Graphic is not found", img != null);

				if(img.status != InlineGraphicElementStatus.READY)
				{
					textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(loadUnloadGraphicsTest,2500,null),false,0,true);
				}
				else
				{
					//remove controller
					var oldController:ContainerController = textFlow.flowComposer.getControllerAt(0);
					textFlow.flowComposer.removeAllControllers();
					assertTrue("Inline Graphic is unloaded by removing controller", img.status == "ready");
					textFlow.flowComposer.addController(new ContainerController(oldController.container,500,500));
					textFlow.flowComposer.updateAllControllers();
					//unloadGraphics
					textFlow.unloadGraphics();
					assertTrue("Inline Graphic is not unloaded by unloadGraphics", img.status == "loadPending");
					//add controllers
					textFlow.flowComposer.addController(new ContainerController(new Container(),500,500));
					textFlow.flowComposer.updateAllControllers();
					assertTrue("Inline Graphic is loaded by add controllers", img.status == "loadPending");
					//prepareGraphicsForLoad
					textFlow.prepareGraphicsForLoad();
					textFlow.applyFunctionToElements(function (elem:FlowElement):Boolean{ if (elem is InlineGraphicElement) textFlow.damage(elem.getAbsoluteStart(),1,TextLineValidity.INVALID); return false; });
					textFlow.flowComposer.updateAllControllers();
					textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, addAsync(waitInlineGraphic,2500,null),false,0,true);
					
					function waitInlineGraphic(callback:Object = null):void
					{
						//wait for another ENTER_FRAME if the status is not ready
						//if it doesn't become ready within the test timeout, the test will error.
						if (img.status != "ready")
						{
							textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, addAsync(waitInlineGraphic,2500,null),false,0,true);
						}else{
							assertTrue("Inline Graphic is not loaded by prepareGraphicsForLoad", img.status == "ready");
						}
					}
				}
			}
		}
		
		/*
		*	load a TextFlow in TCM and wait for its graphics to load
		*	call textFlow.unloadGraphics
		*	verify graphics are unloaded
		*	call prepareGraphicsForLoad then damage & compose
		*	verify graphics are loaded
		*/
		public function loadUnloadGraphicsInTCM(callBack:Object = null):void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			var markup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
				+"<p>"
				+"<span>A inline graphic</span>"
				+"<img width=\"30\" height=\"30\" source=\"../../test/testFiles/assets/smiling.png\"/>"
				+"<span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole.</span>"
				+"</p>"
				+"</TextFlow>";
			var newTF:TextFlow = TextConverter.importToFlow(markup,TextConverter.TEXT_LAYOUT_FORMAT);
			var testTCM:TextContainerManager = addTCM(true);
			testTCM.setTextFlow(newTF);
			testTCM.updateContainer();				
			
			var para:ParagraphElement = newTF.getChildAt(0) as ParagraphElement;
			assertTrue("The second element in the paragraph is not an inline graphic element, after converting markup to textflow", para.getChildAt(1) is InlineGraphicElement);
			var img:InlineGraphicElement = para.getChildAt(1) as InlineGraphicElement;
			TestFrame.container.addEventListener(Event.ENTER_FRAME,addAsync(assertFirstly,2500,null),false,0,true);
			
			function assertFirstly(callback:Object = null):void
			{
				if(img.status != InlineGraphicElementStatus.READY)
				{
					newTF.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(assertFirstly,2500,null),false,0,true);
				}
				else
				{
					//unloadGraphics
					newTF.unloadGraphics();
					assertTrue("Inline Graphic is not unloaded by unloadGraphics", img.status == "loadPending");
					//prepareGraphicsForload
					newTF.prepareGraphicsForLoad();
					newTF.applyFunctionToElements(function (elem:FlowElement):Boolean{ if (elem is InlineGraphicElement) newTF.damage(elem.getAbsoluteStart(),1,TextLineValidity.INVALID); return false; });
					newTF.flowComposer.updateAllControllers();
					newTF.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, addAsync(assertSecondly,2500,null),false,0,true);
				}
			}
			
			function assertSecondly(callback:Object = null):void
			{
				if(img.status != InlineGraphicElementStatus.READY)
				{
					newTF.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(assertSecondly,2500,null),false,0,true);
				}
				else
				{
					assertTrue("Inline Graphic is not loaded by prepareGraphicsForLoad", img.status == "ready");
				}
			}
			
		}
		
		private function addTCM( testSettings:Boolean = true, configuration:IConfiguration = null ):TextContainerManager
		{
			var newSprite:Sprite = new Sprite();
			newSprite.x = 10;
			newSprite.y = 10;
			var newTCM:TextContainerManager = new TextContainerManager(newSprite, configuration);
			testApp.getDisplayObject().rawChildren.addChild(newSprite);
			
			if ( testSettings == true )
			{
				var format:TextLayoutFormat = new TextLayoutFormat();
				format.blockProgression = writingDirection[0];
				format.direction = writingDirection[1];
				newTCM.hostFormat = format;
			}
			
			return newTCM;
		}
		/*
		 * This method is included, commented out, as an example of how to
		 * set up a FE test in such a way that the images are recorded
		 * in the snapshotting process.
		public function insertImageTest(callBack:Object = null):void
		{
			if(!callback){
		 		callback = true;
		 		TestFrame.container.addEventListener(Event.ENTER_FRAME,addAsync(insertImageTest,2500,null),false,0,true);

				var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;

				src = data[data.length-1].toString();
				var width:int = 20;
				var height:int = 20;

				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertImage(src,width,height,false,"insert image");
			}else{
				// examine the results
				var index:int = SelManager.textFlow.textLength/2;
				var elem:LeafElement = SelManager.textFlow.findLeaf(index);
				var img:InlineGraphic;

				assertTrue("inserted image element not found",elem is InlineGraphic);
				if (elem is InlineGraphic)
				{
					img = InlineGraphic(elem);

					if(img.loadStatus != InlineGraphic.LOAD_COMPLETE){
						SelManager.textFlow.addEventListener(Event.ENTER_FRAME,addAsync(insertImageTest,2500,null),false,0,true);
					}else{
						assertTrue("inserted image is the wrong width",img.width == 20);
						assertTrue("inserted image is the wrong height",img.height == 20);
						assertTrue("inserted image has the wrong uri",img.src == src);
						assertTrue("inserted image has the wrong length",img.textLength == 1);
					}
				}
			}
		} */

		/**
		 * Select halfway through the flow and insert an image using a string source
		 */
		public function insertImageAsString(callBack:Object = null):void
		{
  			if(!callback)
  			{
		 		callback = true;
		 		TestFrame.container.addEventListener(Event.ENTER_FRAME,addAsync(insertImageAsString,2500,null),false,0,true);

	  			var startIndx:int = SelManager.textFlow.textLength/2;
	  			var endIndx:int = startIndx;
	  			var flowLength:int = SelManager.textFlow.textLength;

	  			var src:String = data[data.length-1].toString();
	  			var width:int = 20;
	  			var height:int = 20;

	  			SelManager.selectRange(startIndx, endIndx);
	  			var inlineGraphicElement:InlineGraphicElement = SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);

	  			// examine the results
	  			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(startIndx);
				assertTrue("Return value of insertInlineGraphic doesn't match what is found", inlineGraphicElement == elem);
	  			assertTrue("inserted InlineGraphicElement element not found",elem is InlineGraphicElement);
	  			assertTrue("unexpected flow textLength after replacing text with graphic", (flowLength + 1) - (endIndx - startIndx));
	   			assertTrue("unexpected range selection after replacing text with graphic", SelManager.anchorPosition == SelManager.activePosition);
	  			assertTrue("unexpected selection position after replacing text with graphic", SelManager.anchorPosition == startIndx + 1);
	  			if (elem is InlineGraphicElement)
	  			{
	  				var img:InlineGraphicElement = InlineGraphicElement(elem);
	  				assertTrue("inserted image is the wrong width",img.width == width);
	  				assertTrue("inserted image is the wrong height",img.height == height);
	  				assertTrue("inserted image has the wrong source",img.source == LoaderUtil.createAbsoluteURL(baseImageURL,src));
	  				assertTrue("inserted image has the wrong length",img.textLength == 1);
				}
  			}
  			else // Make sure the image is ready before we let the snapshot go
  			{
  				elem = SelManager.textFlow.findLeaf(SelManager.textFlow.textLength/2);
  				img = InlineGraphicElement(elem);
  				if(img.status != InlineGraphicElementStatus.READY)
  				{
					SelManager.textFlow.addEventListener(Event.ENTER_FRAME,addAsync(insertImageAsString,2500,null),false,0,true);
  				}
  			}
		}

		private function createFilledSprite(width:Number, height:Number, color:int):Sprite
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(color);	// red
			sprite.graphics.drawRect(0,0,width,height);
			sprite.graphics.endFill();
			return sprite;
		}
		
		/**
		 * Select a quarter of the way through the flow and insert an image using a DisplayObject source
		 */
		public function insertImageAsDisplayObject(callBack:Object = null):void
		{
  			if(!callback)
  			{
		 		callback = true;
		 		TestFrame.container.addEventListener(Event.ENTER_FRAME,addAsync(insertImageAsDisplayObject,2500,null),false,0,true);

	  			var startIndx:int = SelManager.textFlow.textLength/4;
	  			var endIndx:int = startIndx + 5;		// replace existing text
	  			var flowLength:int = SelManager.textFlow.textLength;

				var sprite:Sprite = createFilledSprite(100, 100, 0xff0000);

	  			var src:Object = sprite;
	  			var width:int = 100;
	  			var height:int = 100;

	  			SelManager.selectRange(startIndx, endIndx);
	  			SelManager.insertInlineGraphic(src,width,height);

	  			// examine the results
	  			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(startIndx);
	  			assertTrue("inserted InlineGraphicElement element not found",elem is InlineGraphicElement);
	  			assertTrue("unexpected flow textLength after replacing text with graphic", (flowLength + 1) - (endIndx - startIndx));
	   			assertTrue("unexpected range selection after replacing text with graphic", SelManager.anchorPosition == SelManager.activePosition);
	  			assertTrue("unexpected selection position after replacing text with graphic", SelManager.anchorPosition == startIndx + 1);
	  			if (elem is InlineGraphicElement)
	  			{
	  				var img:InlineGraphicElement = InlineGraphicElement(elem);
	  				assertTrue("inserted image is the wrong width",img.width == width);
	  				assertTrue("inserted image is the wrong height",img.height == height);
	  				assertTrue("inserted image has the wrong source",img.source == src);
	  				assertTrue("inserted image has the wrong length",img.textLength == 1);
				}
			}
  			else // Make sure the image is ready before we let the snapshot go
  			{
  				elem = SelManager.textFlow.findLeaf((SelManager.textFlow.textLength+5)/4);
  				img = InlineGraphicElement(elem);
  				if(img.status != InlineGraphicElementStatus.READY)
  				{
					SelManager.textFlow.addEventListener(Event.ENTER_FRAME,addAsync(insertImageAsDisplayObject,2500,null),false,0,true);
  				}
  			}
		}

		/**
		 * Select a third of the way through the flow and insert an image using a URLRequest Source
		 */
		public function insertImageAsURLRequest(callBack:Object = null):void
		{
	  		try
	  		{
	  		if(!callback)
  			{
		 		callback = true;
		 		TestFrame.container.addEventListener(Event.ENTER_FRAME,addAsync(insertImageAsURLRequest,2500,null),false,0,true);

	  			var startIndx:int = SelManager.textFlow.textLength/3;
	  			var endIndx:int = startIndx + 5;		// replace existing text
	  			var flowLength:int = SelManager.textFlow.textLength;

	  			var url:URLRequest = new URLRequest("http://www.adobe.com/images/shared/download_buttons/get_adobe_flash_player.png");

	  			var src:Object = url;
	  			var width:int = 106;
	  			var height:int = 32;

	  			SelManager.selectRange(startIndx, endIndx);
	  			SelManager.insertInlineGraphic(src,width,height);

	  			// examine the results
	  			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(startIndx);
	  			assertTrue("inserted InlineGraphicElement element not found", elem is InlineGraphicElement);
	  			assertTrue("unexpected flow textLength after replacing text with graphic", (flowLength + 1) - (endIndx - startIndx));
	   			assertTrue("unexpected range selection after replacing text with graphic", SelManager.anchorPosition == SelManager.activePosition);
	  			assertTrue("unexpected selection position after replacing text with graphic", SelManager.anchorPosition == startIndx + 1);
	  			if (elem is InlineGraphicElement)
	  			{
	  				var img:InlineGraphicElement = InlineGraphicElement(elem);
	  				assertTrue("inserted image is the wrong width",img.width == width);
	  				assertTrue("inserted image is the wrong height",img.height == height);
	  				assertTrue("inserted image has the wrong source",img.source == src);
	  				assertTrue("inserted image has the wrong length",img.textLength == 1);
				}
			}
  			else // Make sure the image is ready before we let the snapshot go
  			{
  				elem = SelManager.textFlow.findLeaf((SelManager.textFlow.textLength+2)/3);
  				img = InlineGraphicElement(elem);
  				if(img.status != InlineGraphicElementStatus.READY)
  				{
					SelManager.textFlow.addEventListener(Event.ENTER_FRAME,addAsync(insertImageAsURLRequest,2500,null),false,0,true);
  				}
  			}
  			}
  			catch ( err:IOError )
  			{
  				fail( "Test error while loading image from URL: " + err.message );
  			}
		}

		/**
		 * Test for Watson 2609303
		 */
		public function insertAtEndAndUndo(callBack:Object = null):void
		{
			var elem:FlowLeafElement;
			var startIndx:int;
			if(!callback)
			{
				callback = true;
				TestFrame.container.addEventListener(Event.ENTER_FRAME,addAsync(insertAtEndAndUndo,2500,null),false,0,true);

				var textFlow:TextFlow = SelManager.textFlow;
				
				startIndx = SelManager.textFlow.textLength - 1;
				
				var width:int = 100;
				var height:int = 100;
				var src:String = data[data.length-1].toString();
				
				SelManager.selectRange(startIndx, startIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),FormatValue.AUTO,FormatValue.AUTO);
				
				// examine the results
				elem = SelManager.textFlow.findLeaf(startIndx);
				assertTrue("inserted InlineGraphicElement element not found",elem is InlineGraphicElement);
	
			}
			else // Make sure the image is ready before we try the undo
			{
				elem = SelManager.textFlow.findLeaf(SelManager.textFlow.textLength - 2);
				var img:InlineGraphicElement = InlineGraphicElement(elem);
				if(img.status != InlineGraphicElementStatus.READY)
				{
					SelManager.textFlow.addEventListener(Event.ENTER_FRAME,addAsync(insertAtEndAndUndo,2500,null),false,0,true);
					return;
				}
			//	SelManager.textFlow.flowComposer.updateAllControllers();
				SelManager.undo();
				
				assertTrue("expected inline to be removed by undo",elem.parent == null);
			}
		}
		
		public function modifyImageSourceTest():void
		{
			try
			{
			var startIndx:int = SelManager.textFlow.textLength/2;
  			var endIndx:int = startIndx;
  			var flowLength:int = SelManager.textFlow.textLength;

  			var src:Object = data[data.length-1].toString();
  			var width:int = 20;
  			var height:int = 20;

  			SelManager.selectRange(startIndx, endIndx);
  			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,String(src)),width,height);

  			// examine the results
  			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(startIndx);
  			assertTrue("inserted InlineGraphicElement element not found",elem is InlineGraphicElement);
  			assertTrue("unexpected flow textLength after replacing text with graphic", (flowLength + 1) - (endIndx - startIndx));
   			assertTrue("unexpected range selection after replacing text with graphic", SelManager.anchorPosition == SelManager.activePosition);
  			assertTrue("unexpected selection position after replacing text with graphic", SelManager.anchorPosition == startIndx + 1);
  			if (elem is InlineGraphicElement)
  			{
  				var img:InlineGraphicElement = InlineGraphicElement(elem);
  				assertTrue("inserted image is the wrong width",img.width == width);
  				assertTrue("inserted image is the wrong height",img.height == height);
  				assertTrue("inserted image has the wrong source",img.source == LoaderUtil.createAbsoluteURL(baseImageURL,String(src)));
  				assertTrue("inserted image has the wrong length",img.textLength == 1);
			}

		// Modify from string to GraphicsObject

			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0xff0000);	// red
			sprite.graphics.drawRect(0,0,100,100);
			sprite.graphics.endFill();

  			src = sprite;
  			width = 100;
  			height = 100;

  			SelManager.selectRange(startIndx, endIndx);
  			SelManager.modifyInlineGraphic(src,width,height);

  			// examine the results
  			elem = SelManager.textFlow.findLeaf(startIndx);
  			assertTrue("inserted InlineGraphicElement element not found",elem is InlineGraphicElement);
  			if (elem is InlineGraphicElement)
  			{
  				img = InlineGraphicElement(elem);
  				assertTrue("inserted image is the wrong width",img.width == width);
  				assertTrue("inserted image is the wrong height",img.height == height);
  				assertTrue("inserted image has the wrong source",img.source == src);
  				assertTrue("inserted image has the wrong length",img.textLength == 1);
			}

		// Modify from DisplayObject to URLRequest

  			var url:URLRequest = new URLRequest("https://bugs.corp.adobe.com/WTSNPROD/images/Watson_Adobe_Logo.gif");

  			src = url;
  			width = 106;
  			height = 32;

  			SelManager.selectRange(startIndx, endIndx);
  			SelManager.modifyInlineGraphic(src,width,height);

  			// examine the results
  			elem = SelManager.textFlow.findLeaf(startIndx);
  			assertTrue("inserted InlineGraphicElement element not found", elem is InlineGraphicElement);
  			if (elem is InlineGraphicElement)
  			{
  				img = InlineGraphicElement(elem);
  				assertTrue("inserted image is the wrong width",img.width == width);
  				assertTrue("inserted image is the wrong height",img.height == height);
  				assertTrue("inserted image has the wrong source",img.source == src);
  				assertTrue("inserted image has the wrong length",img.textLength == 1);
			}
			}
			catch ( err:IOError )
  			{
  				fail( "Test error while loading image from URL: " + err.message );
  			}
		}

		public function copyMultipleImageTest(callBack:Object = null):void
		{
	  		if (!callBack)
			{
				// Insert 3 images
				callBack = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(copyMultipleImageTest,2500,null),false,0,true);
	  			var indx:int = SelManager.textFlow.textLength/2;
	  			var origFlowLength:int = SelManager.textFlow.textLength;
	
	  			var width:int = 20;
	  			var height:int = 20;
	  			SelManager.selectRange(indx, indx);
	  			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,"smiling.png"),width,height);
	  			var firstIndx:int = indx;
	
	  			width = 30;
	  			height = 30;
	  			SelManager.selectRange(indx, indx);
	  			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,"gremlin.jpg"),width,height);
	  			var secondIndx:int = indx;
	
	  			indx = SelManager.textFlow.textLength/3;
	  			width = 40;
	  			height = 40;
	  			SelManager.selectRange(indx, indx);
	  			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,"smiley.gif"),width,height);
	  			var thirdIndx:int = indx;
	
	  			SelManager.selectRange(thirdIndx,
	  									firstIndx+3 );
	
	  			var copy:TextScrap = TextScrap.createTextScrap(SelManager.getSelectionState());
	  			SelManager.deleteNextCharacter();
	  			SelManager.selectRange(thirdIndx,
	  									thirdIndx );
	  			SelManager.pasteTextScrap(copy);
	
	  			// examine the results
	  			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(firstIndx+1);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	  			assertTrue("unexpected flow textLength after replacing text with graphic",
	  						SelManager.textFlow.textLength == origFlowLength + 3);
	   			assertTrue("unexpected range selection after replacing text with graphic",
	   						SelManager.anchorPosition == SelManager.activePosition);
	  			assertTrue("unexpected selection position after replacing text with graphic",
	  						SelManager.activePosition == firstIndx+3);
				elem = SelManager.textFlow.findLeaf(secondIndx+2);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	  			elem = SelManager.textFlow.findLeaf(thirdIndx);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	
				SelManager.undo(); // Undo the paste
				SelManager.undo(); // Undo the delete
	
				elem = SelManager.textFlow.findLeaf(firstIndx+1);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	  			assertTrue("unexpected flow textLength after replacing text with graphic",
	  						SelManager.textFlow.textLength == origFlowLength + 3);
				elem = SelManager.textFlow.findLeaf(secondIndx+2);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	  			elem = SelManager.textFlow.findLeaf(thirdIndx);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	
				SelManager.redo(); // Redo the delete
				SelManager.redo(); // Redo the paste
	
				indx1 = firstIndx+1;
				elem = SelManager.textFlow.findLeaf(firstIndx+1);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	  			assertTrue("unexpected flow textLength after replacing text with graphic",
	  						SelManager.textFlow.textLength == origFlowLength + 3);
	   			assertTrue("unexpected range selection after replacing text with graphic",
	   						SelManager.anchorPosition == SelManager.activePosition);
	  			assertTrue("unexpected selection position after replacing text with graphic",
	  						SelManager.activePosition == firstIndx+3);
				indx2 = secondIndx+2;
				elem = SelManager.textFlow.findLeaf(secondIndx+2);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
				indx3 = thirdIndx;
	  			elem = SelManager.textFlow.findLeaf(thirdIndx);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				img1 = SelManager.textFlow.findLeaf(indx1) as InlineGraphicElement;
				img2 = SelManager.textFlow.findLeaf(indx2) as InlineGraphicElement;
				img3 = SelManager.textFlow.findLeaf(indx3) as InlineGraphicElement;
				
				if(img1.status != InlineGraphicElementStatus.READY || img2.status != InlineGraphicElementStatus.READY || img3.status != InlineGraphicElementStatus.READY)
				{
					SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(copyMultipleImageTest,2500,null),false,0,true);
				}
			}
		}

		public function cutMultipleImageTest(callBack:Object = null):void
		{
			if (!callBack)
			{
				callBack = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(cutMultipleImageTest,2500,null),false,0,true);
				// Insert 3 images
	  			var indx:int = SelManager.textFlow.textLength/2;
	  			var origFlowLength:int = SelManager.textFlow.textLength;
	
	  			var width:int = 20;
	  			var height:int = 20;
	  			SelManager.selectRange(indx, indx);
	  			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,"smiling.png"),width,height);
	  			var firstIndx:int = indx;
	
	  			width = 30;
	  			height = 30;
	  			SelManager.selectRange(indx, indx);
	  			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,"gremlin.jpg"),width,height);
	  			var secondIndx:int = indx;
	
	  			indx = SelManager.textFlow.textLength/3;
	  			width = 40;
	  			height = 40;
	  			SelManager.selectRange(indx, indx);
	  			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,"smiley.gif"),width,height);
	  			var thirdIndx:int = indx;
	
	  			SelManager.selectRange(thirdIndx,
	  									firstIndx+3 );
	
	  			var copy:TextScrap = SelManager.cutTextScrap();
	  			SelManager.selectRange(thirdIndx,
	  									thirdIndx );
	  			SelManager.pasteTextScrap(copy);
	
	  			// examine the results
	  			var elem:FlowLeafElement = SelManager.textFlow.findLeaf(firstIndx+1);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	  			assertTrue("unexpected flow textLength after replacing text with graphic",
	  						SelManager.textFlow.textLength == origFlowLength + 3);
	   			assertTrue("unexpected range selection after replacing text with graphic",
	   						SelManager.anchorPosition == SelManager.activePosition);
	  			assertTrue("unexpected selection position after replacing text with graphic",
	  						SelManager.activePosition == firstIndx+3);
				elem = SelManager.textFlow.findLeaf(secondIndx+2);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	  			elem = SelManager.textFlow.findLeaf(thirdIndx);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	
				SelManager.undo(); // Undo the paste
	
				elem = SelManager.textFlow.findLeaf(firstIndx+1);
	  			assertTrue("inserted InlineGraphicElement element should not be found",
	  						!(elem is InlineGraphicElement));
	  			assertTrue("unexpected flow textLength after undo multi-image cut",
	  						SelManager.textFlow.textLength == (origFlowLength - (firstIndx-thirdIndx)) );
				elem = SelManager.textFlow.findLeaf(secondIndx+2);
	  			assertTrue("inserted InlineGraphicElement element should not be found",
	  						!(elem is InlineGraphicElement));
	  			elem = SelManager.textFlow.findLeaf(thirdIndx);
	  			assertTrue("inserted InlineGraphicElement element should not be found",
	  						!(elem is InlineGraphicElement));
	
				SelManager.undo(); // Undo the cut
				elem = SelManager.textFlow.findLeaf(firstIndx+1);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	  			assertTrue("unexpected flow textLength after replacing text with graphic",
	  						SelManager.textFlow.textLength == origFlowLength + 3);
	   			assertTrue("unexpected range selection after replacing text with graphic",
	   						SelManager.anchorPosition != SelManager.activePosition);
	  			assertTrue("unexpected selection position after replacing text with graphic",
	  						SelManager.anchorPosition == thirdIndx &&
	  						SelManager.activePosition == firstIndx+3);
				elem = SelManager.textFlow.findLeaf(secondIndx+2);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	  			elem = SelManager.textFlow.findLeaf(thirdIndx);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	
				SelManager.redo(); // Redo the cut
	
				elem = SelManager.textFlow.findLeaf(firstIndx+1);
	  			assertTrue("inserted InlineGraphicElement element should not be found",
	  						!(elem is InlineGraphicElement));
	  			assertTrue("unexpected flow textLength after undo multi-image cut",
	  						SelManager.textFlow.textLength == (origFlowLength - (firstIndx-thirdIndx)) );
				elem = SelManager.textFlow.findLeaf(secondIndx+2);
	  			assertTrue("inserted InlineGraphicElement element should not be found",
	  						!(elem is InlineGraphicElement));
	  			elem = SelManager.textFlow.findLeaf(thirdIndx);
	  			assertTrue("inserted InlineGraphicElement element should not be found",
	  						!(elem is InlineGraphicElement));
	
				SelManager.redo(); // Redo the paste
	
				indx1 = firstIndx+1;
				elem = SelManager.textFlow.findLeaf(firstIndx+1);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
	  			assertTrue("unexpected flow textLength after replacing text with graphic",
	  						SelManager.textFlow.textLength == origFlowLength + 3);
	   			assertTrue("unexpected range selection after replacing text with graphic",
	   						SelManager.anchorPosition == SelManager.activePosition);
	  			assertTrue("unexpected selection position after replacing text with graphic",
	  						SelManager.activePosition == firstIndx+3);
				indx2 = secondIndx+2;
				elem = SelManager.textFlow.findLeaf(secondIndx+2);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
				indx3 = thirdIndx;
	  			elem = SelManager.textFlow.findLeaf(thirdIndx);
	  			assertTrue("inserted InlineGraphicElement element not found",
	  						elem is InlineGraphicElement);
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				img1 = SelManager.textFlow.findLeaf(indx1) as InlineGraphicElement;
				img2 = SelManager.textFlow.findLeaf(indx2) as InlineGraphicElement;
				img3 = SelManager.textFlow.findLeaf(indx3) as InlineGraphicElement;
				
				if(img1.status != InlineGraphicElementStatus.READY || img2.status != InlineGraphicElementStatus.READY || img3.status != InlineGraphicElementStatus.READY)
				{
					SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(cutMultipleImageTest,2500,null),false,0,true);
				}
			}
		}

		/**
		 * Testing undo/redo of image insertion
		 */
		public function undoRedoInsertImageTest(callBack:Object = null):void
		{
			if (!callback)
			{
				callback = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(undoRedoInsertImageTest,2500,null),false,0,true);
				var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;
				indx1 = startIndx;
	
				var src:String = data[data.length-1].toString();
				var width:int = 20;
				var height:int = 20;
	
				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
				var elem:FlowLeafElement = SelManager.textFlow.findLeaf(startIndx);
				assertTrue("inserted image element not found",elem is InlineGraphicElement);
	
				SelManager.undo();
	
				elem = SelManager.textFlow.findLeaf(startIndx);
				assertTrue("inserted image element not deleted by undo",!(elem is InlineGraphicElement));
	
				SelManager.redo();
				elem = SelManager.textFlow.findLeaf(startIndx);
				assertTrue("inserted image element not recreated by redo",elem is InlineGraphicElement);
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				img1 = SelManager.textFlow.findLeaf(indx1) as InlineGraphicElement;
				
				if(img1.status != InlineGraphicElementStatus.READY)
				{
					SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(undoRedoInsertImageTest,2500,null),false,0,true);
				}
			}
		}

		/**
		 * Test for Watson 2512062
		 */
		public function insertStyleNameTest(callBack:Object = null):void
		{
			SelManager.selectRange(0, 5);
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.fontWeight = FontWeight.BOLD;
			SelManager.applyFormat(format, null, null);
			var leaf:FlowLeafElement = SelManager.textFlow.getFirstLeaf();
			leaf.styleName = "foo";

			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0xff0000);	// red
			sprite.graphics.drawRect(0,0,100,100);
			sprite.graphics.endFill();
			SelManager.selectRange(5, 5);
			SelManager.insertInlineGraphic(sprite, 100, 100);
			
			var inlineGraphic:FlowLeafElement = leaf.getNextLeaf();
			assertTrue("Expected styleName to be propagated to inline graphic", inlineGraphic.styleName == "foo");
			
			SelManager.undo();		// undo inline graphic insert
			
			var pointFormat:PointFormat = new PointFormat();
			pointFormat.setStyle("styleName", "bar");
			SelManager.setSelectionState(new SelectionState(SelManager.textFlow, 25, 25, pointFormat));
			inlineGraphic = SelManager.insertInlineGraphic(sprite, 100, 100);
			
			assertTrue("Expected styleName from pointFormat to be propagated to inserted inline graphic", inlineGraphic.styleName == "bar");
		}
		
		/**
		 * Select halfway through the flow and insert an image .. and then change it
		 */
		public function changeImageTest(callback:Object = null):void
		{
			if (!callback)
			{
				callback = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(changeImageTest,2500,null),false,0,true);
				var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;
				indx1 = startIndx;
	
				var src:String = data[data.length-1].toString();
				var width:int = 20;
				var height:int = 20;
	
				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
	
				// examine the results
				var elem:FlowLeafElement = SelManager.textFlow.findLeaf(startIndx);
				var img:InlineGraphicElement;
	
				assertTrue("inserted image element not found",elem is InlineGraphicElement);
				if (elem is InlineGraphicElement)
				{
					img = InlineGraphicElement(elem);
					assertTrue("inserted image is the wrong width",img.width == width);
					assertTrue("inserted image is the wrong height",img.height == height);
					assertTrue("inserted image has the wrong uri",img.source == LoaderUtil.createAbsoluteURL(baseImageURL,src));
					assertTrue("inserted image has the wrong length",img.textLength == 1);
				}
	
				// block select the image and change it
				var chgSrc:String = data[data.length-1].toString();
				var chgWidth:int = 40;
				var chgHeight:int = 40;
	
				SelManager.selectRange(startIndx, endIndx+1);
				SelManager.modifyInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,chgSrc),chgWidth,chgHeight);
	
				// examine the results
				elem = SelManager.textFlow.findLeaf(startIndx);
				assertTrue("inserted image element not found",elem is InlineGraphicElement);
				if (elem is InlineGraphicElement)
				{
					img = InlineGraphicElement(elem);
					assertTrue("inserted image is the wrong width",img.width == chgWidth);
					assertTrue("inserted image is the wrong height",img.height == chgHeight);
					assertTrue("inserted image has the wrong uri",img.source == LoaderUtil.createAbsoluteURL(baseImageURL,chgSrc));
					assertTrue("inserted image has the wrong length",img.textLength == 1);
				}
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				img1 = SelManager.textFlow.findLeaf(indx1) as InlineGraphicElement;
				
				if(img1.status != InlineGraphicElementStatus.READY)
				{
					SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(changeImageTest,2500,null),false,0,true);
				}
			}
		}

		/**
		 * Select halfway through the flow and insert an image .. and then change it .. and then undo and redo the change
		 */
		public function undoRedoChangeImageTest(callback:Object = null):void
		{
			if (!callback)	
			{
				callback = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(undoRedoChangeImageTest,2500,null),false,0,true);
				var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;
				indx1 = startIndx;
	
				var src:String = data[data.length-1].toString();
				var width:int = 20;
				var height:int = 20;
	
				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
	
				// examine the results
				var elem:FlowLeafElement;
				var img:InlineGraphicElement;
	
				elem = SelManager.textFlow.findLeaf(startIndx);
				assertTrue("inserted image element not found",elem is InlineGraphicElement);
				if (elem is InlineGraphicElement)
				{
					img = InlineGraphicElement(elem);
					assertTrue("inserted image is the wrong width",img.width == width);
					assertTrue("inserted image is the wrong height",img.height == height);
					assertTrue("inserted image has the wrong uri",img.source == LoaderUtil.createAbsoluteURL(baseImageURL,src));
					assertTrue("inserted image has the wrong length",img.textLength == 1);
				}
	
				// block select the image and change it
				var chgSrc:String = data[data.length-1].toString();
				var chgWidth:int = 40;
				var chgHeight:int = 40;
	
				SelManager.selectRange(startIndx, endIndx+1);
				SelManager.modifyInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,chgSrc),chgWidth,chgHeight);
	
				// examine the results
				elem = SelManager.textFlow.findLeaf(startIndx);
				assertTrue("inserted image element not found",elem is InlineGraphicElement);
				if (elem is InlineGraphicElement)
				{
					img = InlineGraphicElement(elem);
					assertTrue("inserted image is the wrong width",img.width == chgWidth);
					assertTrue("inserted image is the wrong height",img.height == chgHeight);
					assertTrue("inserted image has the wrong uri",img.source == LoaderUtil.createAbsoluteURL(baseImageURL,chgSrc));
					assertTrue("inserted image has the wrong length",img.textLength == 1);
				}
	
				// undo the change image operation
				SelManager.undo();
	
				// examine the results
				elem = SelManager.textFlow.findLeaf(startIndx);
				assertTrue("inserted image element not found",elem is InlineGraphicElement);
				if (elem is InlineGraphicElement)
				{
					img = InlineGraphicElement(elem);
					assertTrue("inserted image is the wrong width",img.width == width);
					assertTrue("inserted image is the wrong height",img.height == height);
					assertTrue("inserted image has the wrong uri",img.source == LoaderUtil.createAbsoluteURL(baseImageURL,src));
					assertTrue("inserted image has the wrong length",img.textLength == 1);
				}
	
				// redo the change image operation
				SelManager.redo();
	
				// examine the results
				elem = SelManager.textFlow.findLeaf(startIndx);
				assertTrue("inserted image element not found",elem is InlineGraphicElement);
				if (elem is InlineGraphicElement)
				{
					img = InlineGraphicElement(elem);
					assertTrue("inserted image is the wrong width",img.width == chgWidth);
					assertTrue("inserted image is the wrong height",img.height == chgHeight);
					assertTrue("inserted image has the wrong uri",img.source == LoaderUtil.createAbsoluteURL(baseImageURL,chgSrc));
					assertTrue("inserted image has the wrong length",img.textLength == 1);
				}
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				img1 = SelManager.textFlow.findLeaf(indx1) as InlineGraphicElement;
				
				if(img1.status != InlineGraphicElementStatus.READY)
				{
					SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(undoRedoChangeImageTest,2500,null),false,0,true);
				}
			}
		
		}

		/**
		 * Ensure that you can't make the image wider than the TestFrame.
		 */
		public function nestedForeignElementsTest():void
		{
			/*var subTC:LayoutScrollableFlashTextContainer = new LayoutScrollableFlashTextContainer();
			subTC.verticalScrollPolicy = ScrollPolicy.OFF
			subTC.horizontalScrollPolicy = ScrollPolicy.OFF*/
			var subTC:Sprite = new Sprite();
			var subController:ContainerController = new ContainerController(subTC);
			var subTF:TextFlow = SelManager.textFlow.deepCopy() as TextFlow;
			subTF.flowComposer = new StandardFlowComposer();
			var controller:ContainerController = new ContainerController(subTC);
			subTF.flowComposer.addController(controller);
			subTF.interactionManager = new EditManager(null);

			var src:String = data[data.length-1].toString();
			var startIndx:int = SelManager.textFlow.textLength/2;
			var endIndx:int = startIndx;

			var width:int = 20;
			var height:int = 20;

			subTF.interactionManager.selectRange(startIndx, endIndx);
			IEditManager(subTF.interactionManager).insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);

			SelManager.selectRange(startIndx, endIndx);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);

			var image:InlineGraphicElement = SelManager.textFlow.findLeaf(startIndx) as InlineGraphicElement;
			image.source = subTC;
		}

		/**
		 * Make sure that changing the baseline changes the image position.
		 */
		public function changeBaselineTest(callback:Object = null):void
		{
			if (!callback)
			{	
				callback = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(changeBaselineTest,2500,null),false,0,true);
				var tb:Boolean = TestFrame.rootElement.computedFormat.blockProgression ==
						BlockProgression.RL;
				var src:String = data[data.length-1].toString();
				var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;
				indx1 = startIndx;
	
				var width:int = 20;
				var height:int = 20;
	
				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
	
				var image:InlineGraphicElement = SelManager.textFlow.findLeaf(startIndx) as InlineGraphicElement;
				TestFrame.textFlow.flowComposer.updateAllControllers();
	
				var init:int = tb ?
					image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y)).x:
					image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y)).y;
	
				SelManager.selectRange(startIndx, endIndx+1);
				image.alignmentBaseline = flash.text.engine.TextBaseline.IDEOGRAPHIC_CENTER;
				SelManager.flushPendingOperations();
				TestFrame.textFlow.flowComposer.updateAllControllers();
	
				var end:int = tb ?
					image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y)).x:
					image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y)).y;
	
	
				if(tb){
					assertTrue("Changing the baseline of the graphic did not " +
							"accurately change the image's position. " +
							end + " !> " + init + ".",
							end > init
					);
				}else{
					assertTrue("Changing the baseline of the graphic did not " +
							"accurately change the image's position. " +
							end + " !< " + init + ".",
							end < init
					);
				}
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				img1 = SelManager.textFlow.findLeaf(indx1) as InlineGraphicElement;
				
				if(img1.status != InlineGraphicElementStatus.READY)
				{
					SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(changeBaselineTest,2500,null),false,0,true);
				}
			}
		}

		/**
		 * Make sure that shifting the baseline changes the image position.
		 */
		public function baselineShiftTest(callback:Object = null):void
		{
			if (!callback)
			{
				callback = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(baselineShiftTest,2500,null),false,0,true);
				var tb:Boolean = TestFrame.rootElement.computedFormat.blockProgression ==
						BlockProgression.RL;
	
				var src:String = data[data.length-1].toString();
				var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;
				indx1 = startIndx;
	
				var width:int = 20;
				var height:int = 20;
	
				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
	
				var image:InlineGraphicElement = SelManager.textFlow.findLeaf(startIndx) as InlineGraphicElement;
				TestFrame.textFlow.flowComposer.updateAllControllers();
	
				var init:int = tb ?
					image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y)).x:
					image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y)).y;
	
				SelManager.selectRange(startIndx, endIndx+1);
				image.baselineShift = 20;
				SelManager.flushPendingOperations();
				TestFrame.textFlow.flowComposer.updateAllControllers();
	
				var end:int = tb ?
					image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y)).x:
					image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y)).y;
	
				if(tb){
					assertTrue("Changing the baseline of the graphic did not " +
							"accurately change the image's position. " +
							end + " != " + (init+20) + ".",
							end == init + 20
					);
				}else{
					assertTrue("Changing the baseline of the graphic did not " +
							"accurately change the image's position. " +
							end + " != " + (init-20) + ".",
							end == init - 20
					);
				}
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				img1 = SelManager.textFlow.findLeaf(indx1) as InlineGraphicElement;
				
				if(img1.status != InlineGraphicElementStatus.READY)
				{
					SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(baselineShiftTest,2500,null),false,0,true);
				}
			}
		}

		/**
		 * Make sure that shifting the baseline changes the image position.
		 */
		public function breakOpportunityTest(callback:Object = null):void
		{
			// TODO: Matt this is a better way to figure out if we are TB
			// The way you are doing it is not reliable
			if (!callback)
			{	
				callback = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(breakOpportunityTest,2500,null),false,0,true);
				SelManager.selectAll();
				var ca:TextLayoutFormat = new TextLayoutFormat();
				ca.fontFamily = "Times New Roman";
				SelManager.applyLeafFormat(ca);
				SelManager.flushPendingOperations();
	
				var tb:Boolean = TestFrame.rootElement.computedFormat.blockProgression == BlockProgression.RL;
	
				var src:String = data[data.length-1].toString();
	
				var startIndx:int = SelManager.textFlow.flowComposer.getLineAt(1).absoluteStart;
				var endIndx:int = startIndx + SelManager.textFlow.flowComposer.getLineAt(1).textLength;
				SelManager.selectRange(endIndx, endIndx);
				indx1 = endIndx;
	
				var width:int = 20;
				var height:int = 20;
	
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
	
				var image:InlineGraphicElement = SelManager.textFlow.findLeaf(endIndx) as InlineGraphicElement;
				TestFrame.textFlow.flowComposer.updateAllControllers();
	
				var init:Point =
					image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y));
	
				SelManager.selectRange(endIndx, endIndx+1);
				image.breakOpportunity = flash.text.engine.BreakOpportunity.NONE;
				SelManager.flushPendingOperations();
				TestFrame.textFlow.flowComposer.updateAllControllers();
	
				var mid:Point =
					image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y));
	
				// TODO: top to bottom test
				if (!tb)
				{
					assertTrue("The x position of the image is less than or equal to" +
							" the initial position of the image: The image has not obeyed the" +
							" BreakOpportunity.NONE designation. " + init.x + " !<= " + mid.x
							, init.x <= mid.x);
					assertTrue("The y position of the image is greater than or equal to" +
							" the initial position of the image: The image has not obeyed the" +
							" BreakOpportunity.NONE designation. " + init.y + " !>= " + mid.y
							, init.y >= mid.y);
				}
	
				SelManager.selectRange(endIndx, endIndx+1);
				image.breakOpportunity = flash.text.engine.BreakOpportunity.AUTO;
				SelManager.flushPendingOperations();
				TestFrame.textFlow.flowComposer.updateAllControllers();
	
				var end:Point =
					image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y));
	
				/*assertTrue("The x position of the image is greater than or equal to" +
						" the midpoint position of the image: The image has not obeyed the" +
						" BreakOpportunity.ALL designation.", mid.x >= end.x);
				assertTrue("The y position of the image is less than or equal to" +
						" the midpoint position of the image: The image has not obeyed the" +
						" BreakOpportunity.ALL designation.", mid.y <= end.y);*/
	
				// TODO: top to bottom test
				if (!tb)
				{
					assertTrue("The x position of the image is not equal to" +
							" the initial position of the image: The image's x position has not been" +
							" restored by setting BreakOpportunity.AUTOMATIC.", init.x == end.x);
					assertTrue("The y position of the image is not equal to" +
							" the initial position of the image: The image's y position has not been" +
							" restored by setting BreakOpportunity.AUTOMATIC.", init.y == end.y);
				}
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				img1 = SelManager.textFlow.findLeaf(indx1) as InlineGraphicElement;
				
				if(img1.status != InlineGraphicElementStatus.READY)
				{
					SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(breakOpportunityTest,2500,null),false,0,true);
				}
			}
		}

		/**
		 * Make sure that kerning doesn't change the image position.
		 */
		public function kerningTest():void
		{
			var src:String = data[data.length-1].toString();
			var startIndx:int = SelManager.textFlow.textLength/2;
			var endIndx:int = startIndx;

			var width:int = 20;
			var height:int = 20;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);

			var image:InlineGraphicElement = SelManager.textFlow.findLeaf(endIndx) as InlineGraphicElement;
			TestFrame.textFlow.flowComposer.updateAllControllers();

			var init:Point =
				image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y));

			SelManager.selectRange(endIndx, endIndx+1);
			image.kerning = image.computedFormat.kerning != Kerning.OFF ? Kerning.OFF : Kerning.ON;
			SelManager.flushPendingOperations();
			TestFrame.textFlow.flowComposer.updateAllControllers();

			var end:Point =
				image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y));

			assertTrue("Changing the kerning value effected the placement of the image.",
					Point.distance(init,end) == 0);
		}
		/**
		 * Make sure that changing the tracking changes the image position.
		 */
		public function trackingTest():void
		{
			var src:String = data[data.length-1].toString();
			var startIndx:int = SelManager.textFlow.textLength/2;
			var endIndx:int = startIndx;

			var width:int = 20;
			var height:int = 20;

			SelManager.selectRange(startIndx, endIndx);
			SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);

			var image:InlineGraphicElement = SelManager.textFlow.findLeaf(endIndx) as InlineGraphicElement;
			TestFrame.textFlow.flowComposer.updateAllControllers();

			var init:Point =
				image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y));

			SelManager.selectRange(endIndx-1, endIndx);
			image.trackingRight = image.computedFormat.trackingRight + 20;
			SelManager.flushPendingOperations();
			TestFrame.textFlow.flowComposer.updateAllControllers();

			var end:Point =
				image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y));

	//		assertTrue("Changing the trackingRight value by twenty did not effect the " +
	//				"placement of the image.", Point.distance(init,end) != 0);

			SelManager.selectRange(endIndx-1, endIndx);
			image.trackingLeft = image.computedFormat.trackingLeft + 20;
			SelManager.flushPendingOperations();
			TestFrame.textFlow.flowComposer.updateAllControllers();


			// this test is not right for RTL - the image is treated as a RTL character and end is now the character before
			// removed this test as a workaround for bug 2467357 - QE can revisit for the RTL case
			if (this.writingDirection[1] == Direction.LTR)
			{
				end = image.graphic.localToGlobal(new Point(image.graphic.x,image.graphic.y));
				assertTrue("Changing the trackingLeft value by twenty did not effect the " +
					"placement of the image.", Point.distance(init,end) != 0);
			}
		}

		/**
		 * Make sure that inserting a FE in a link applies the link properties to the FE.
		 */
		public function insertFEInLink(callBack:Object = null):void
		{
			if (!callBack)
			{
				callBack = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(insertFEInLink,2500,null),false,0,true);
				var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;
				indx1 = startIndx;
	
				var site:String = "http://www.google.com";
				var ref:String = "_self";
	
				SelManager.selectRange(startIndx-5,endIndx+5);
				SelManager.applyLink(site,ref ,false);
	
				var src:String = data[data.length-1].toString();
	
				var width:int = 20;
				var height:int = 20;
	
				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
	
				var image:InlineGraphicElement = SelManager.textFlow.findLeaf(endIndx) as InlineGraphicElement;
				SelManager.flushPendingOperations();
				TestFrame.textFlow.flowComposer.updateAllControllers();
	
				var link:LinkElement = image.getParentByType(LinkElement) as LinkElement;
	
				assertTrue("Foreign Element does not point to the correct" +
						"site.", link.href == site);
	
				assertTrue("Foreign Element does not have the correct " +
						"href.", link.target == ref);
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				img1 = SelManager.textFlow.findLeaf(indx1) as InlineGraphicElement;
				
				if(img1.status != InlineGraphicElementStatus.READY)
				{
					SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(insertFEInLink,2500,null),false,0,true);
				}
			}
		}

		/**
		 * Make sure that adding a link to a FE works.
		 */
		public function foreignElementToLink(callBack:Object = null):void
		{
			if (!callBack)
			{
				callBack = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(foreignElementToLink,2500,null),false,0,true);
				var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;
				indx1 = startIndx;
	
				var src:String = data[data.length-1].toString();
	
				var width:int = 20;
				var height:int = 20;
	
	
				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
	
				var site:String = "http://www.google.com";
				var ref:String = "_self";
	
				SelManager.selectRange(startIndx, endIndx+1);
				SelManager.applyLink(site,ref ,false);
	
				var image:InlineGraphicElement = SelManager.textFlow.findLeaf(endIndx) as InlineGraphicElement;
				SelManager.flushPendingOperations();
				TestFrame.textFlow.flowComposer.updateAllControllers();
	
				var link:LinkElement = image.getParentByType(LinkElement) as LinkElement;
	
				assertTrue("Foreign Element does not point to the correct" +
						"site.", link.href == site);
	
				assertTrue("Foreign Element does not have the correct " +
						"href.", link.target == ref);
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				img1 = SelManager.textFlow.findLeaf(indx1) as InlineGraphicElement;
				
				if(img1.status != InlineGraphicElementStatus.READY)
				{
					SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(foreignElementToLink,2500,null),false,0,true);
				}
			}
		}

		/**
		 * Resize the foreign element proportionally and see that it has the right
		 * dimensions.
		 */
		 
		 public function proportionalSize(callBack:Object = null):void
		 {
			 if(!callback)
			 {
				 callback = true;
				 TestFrame.container.addEventListener(Event.ENTER_FRAME,addAsync(proportionalSize,2500,null),false,0,true);
				 
				 var startIndx:int = SelManager.textFlow.textLength/2;
				 var endIndx:int = startIndx;
				 indx1 = endIndx;
				 
				 var src:String = data[data.length-1].toString();
				 
				 var width:String = "100%";
				 var height:String = "100%";
				 
				 SelManager.selectRange(startIndx, endIndx);
				 SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
				 
				 var image:InlineGraphicElement = SelManager.textFlow.findLeaf(SelManager.textFlow.textLength/2) as InlineGraphicElement;
				 
				 var initWidth:int = image.width as int;
				 var initHeight:int = image.height as int;
				 
				 startIndx = startIndx + 5;
				 endIndx = startIndx;
				 indx2 = endIndx;
				 
				 width = "50%";
				 height = "50%";
				 
				 SelManager.selectRange(startIndx, endIndx);
				 SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
				 
				 image = SelManager.textFlow.findLeaf(indx2) as InlineGraphicElement;
				 
				 var midWidth:int = image.actualWidth as int;
				 var midHeight:int = image.actualHeight as int;
				 
				 assertTrue("Final width is not half of initial width!", initWidth/2 == midWidth);
				 assertTrue("Final height is not half of initial height!", initHeight/2 == midHeight);
				 
				 startIndx = startIndx + 5;
				 endIndx = startIndx;
				 indx3 = endIndx;
				 
				 width = "200%";
				 height = "200%";
				 
				
				 SelManager.selectRange(startIndx, endIndx);
				 SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
				 
				 image = SelManager.textFlow.findLeaf(indx3) as InlineGraphicElement;
				 
				 var endWidth:int = image.actualWidth as int;
				 var endHeight:int = image.actualHeight as int;
				 
				 assertTrue("Final width is not half of initial width!", initWidth*2 == endWidth);
				 assertTrue("Final height is not half of initial height!", initHeight*2 == endHeight);
			
			 }
			 else // Make sure the image is ready before we let the snapshot go
			 {
				 img1 = SelManager.textFlow.findLeaf(indx1) as InlineGraphicElement;
				 img2 = SelManager.textFlow.findLeaf(indx2) as InlineGraphicElement;
				 img3 = SelManager.textFlow.findLeaf(indx3) as InlineGraphicElement;
				 
				 if(img1.status != InlineGraphicElementStatus.READY || img2.status != InlineGraphicElementStatus.READY || img3.status != InlineGraphicElementStatus.READY)
				 {
					 SelManager.textFlow.addEventListener(Event.ENTER_FRAME,addAsync(proportionalSize,2500,null),false,0,true);
				 }
			 }
		}

		 private function updateCompletionHandler(event:Event):void
		 {
		 	assertTrue("Operation must be on stack",SelManager.undoManager.canUndo());
		 	var op:FlowOperation = SelManager.undoManager.peekUndo() as FlowOperation;
		 	assertTrue("FlowOperation not found",op != null);
		 	assertTrue("FlowManager generation mismatch",op.endGeneration == SelManager.textFlow.generation);
			this.callback = false;
		 }

//		 private function enableInlineGraphicSWF():void
//		 {
//			 var config:Configuration = new Configuration();
//			 config.inlineGraphicProtocolVerifierFunction = myProtocalVerifierFunction;
//			 var newTF:TextFlow = new TextFlow(config);
//			 
//			 newTF.replaceChildren(0, newTF.numChildren, SelManager.textFlow.mxmlChildren);
//			 
//			 // Copy the styles from old textflow to new textflow
//			 newTF.blockProgression = SelManager.textFlow.blockProgression;
//			 newTF.fontSize   = SelManager.textFlow.fontSize;
//			 newTF.fontFamily = SelManager.textFlow.fontFamily;
//			 newTF.fontStyle  = SelManager.textFlow.fontStyle;
//			 newTF.fontWeight = SelManager.textFlow.fontWeight;
//			 
//			 var sprite:Sprite = new Sprite();
//			 
//			 var TestCanvas:Canvas = this.myEmptyChilds();
//			 TestCanvas.rawChildren.addChild(sprite);
//			 
//			 newTF.flowComposer.removeAllControllers();
//			 newTF.flowComposer.addController(new ContainerController(sprite, 800, 800) );
//			 newTF.flowComposer.compose();
//			 
//			 newTF.unloadGraphics();
//			 //prepareGraphicsForload
//			 newTF.prepareGraphicsForLoad();
//			 newTF.applyFunctionToElements(function (elem:FlowElement):Boolean{ if (elem is InlineGraphicElement) newTF.damage(elem.getAbsoluteStart(),1,TextLineValidity.INVALID); return false; });
//			 newTF.flowComposer.updateAllControllers();
//			 
//			 SelManager.textFlow = newTF;
//			 
//			 SelManager.updateAllControllers();
//			 inlineGraphicSWFEnabled = true;
//		 }
		 
		/**
		 * Size the FE at 50% height, then verify that the width is set proportionally.
		 */
		 public function proportionalAutoWidth(callBack:Object = null):void
		 {
		 	if(!callback){
		 		callback = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(proportionalAutoWidth,2500,null),false,0,true);

			 	var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;

				var src:String = data[data.length-1].toString();
				
				var width:String = "auto";
				var height:String = "50%";

				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
		 	}
		 	else
		 	{
		 		assertTrue("unexected event",callBack is StatusChangeEvent);
		 		var event:StatusChangeEvent = StatusChangeEvent(callBack);
				assertTrue("unexpected StatusChangeEvent received",event.element is InlineGraphicElement);
				var image:InlineGraphicElement = InlineGraphicElement(event.element);
				switch (event.status)
				{
					case InlineGraphicElementStatus.LOADING:
					case InlineGraphicElementStatus.SIZE_PENDING:
						SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(proportionalAutoWidth,2500,null),false,0,true);
						break;
					case InlineGraphicElementStatus.READY:
						var effWidth:Number = image.actualWidth as Number;
						var effHeight:Number = image.actualHeight as Number;
						
						var nomWidth:Number = image.measuredWidth as Number;
						var nomHeight:Number = image.measuredHeight as Number;
						
						assertTrue("Final width is not half of initial width!", nomWidth/2 == effWidth);
						assertTrue("Final height is not half of initial height!", nomHeight/2 == effHeight);
						SelManager.textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE,addAsync(updateCompletionHandler,2500,null),false,0,true);
						break;
					default:
						assertTrue("unexpected StatusChangeEvent status: "+event.status,false);
						break;
				}
		 	}
		 }
		 
		/**
		 * Size the FE at 50% height, then verify that the width is set proportionally.
		 */
		 public function proportionalAutoHeight(callBack:Object = null):void
		 {
		 	if(!callback)
		 	{
		 		callback = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(proportionalAutoHeight,2500,null),false,0,true);

			 	var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;

				var src:String = data[data.length-1].toString();
				
				var width:String = "50%";
				var height:String = "auto"; 

				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
		 	}
		 	else
		 	{
		 		assertTrue("unexected event",callBack is StatusChangeEvent);
				var event:StatusChangeEvent = StatusChangeEvent(callBack);
				assertTrue("unexpected StatusChangeEvent received",event.element is InlineGraphicElement);
				var image:InlineGraphicElement = InlineGraphicElement(event.element);
				switch (event.status)
				{
					case InlineGraphicElementStatus.LOADING:
					case InlineGraphicElementStatus.SIZE_PENDING:
						SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(proportionalAutoHeight,2500,null),false,0,true);
						break;
					case InlineGraphicElementStatus.READY:
						var effWidth:Number = image.actualWidth as Number;
						var effHeight:Number = image.actualHeight as Number;
						
						var nomWidth:Number = image.measuredWidth as Number;
						var nomHeight:Number = image.measuredHeight as Number;
						
						assertTrue("Final width is not half of initial width!", nomWidth/2 == effWidth);
						assertTrue("Final height is not half of initial height!", nomHeight/2 == effHeight);
						SelManager.textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE,addAsync(updateCompletionHandler,2500,null),false,0,true);
						break;
					default:
						assertTrue("unexpected StatusChangeEvent status: "+event.status,false);
						break;
				}
		 	}
		 }

		/**
		 * Size the FE at 50 width, then verify that the height is set proportionally.
		 */
		 public function proportionalFixedWidth(callBack:Object = null):void
		 {
		 	if(!callback)
		 	{
		 		callback = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(proportionalFixedWidth,2500,null),false,0,true);
			 	var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;

				var src:String = data[data.length-1].toString();
				
				var width:String = "50";
				var height:String = "auto";

				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
		 	}
		 	else
		 	{
				assertTrue("unexected event",callBack is StatusChangeEvent);
				var event:StatusChangeEvent = StatusChangeEvent(callBack);
				assertTrue("unexpected StatusChangeEvent received",event.element is InlineGraphicElement);
				var image:InlineGraphicElement = InlineGraphicElement(event.element);

				switch (event.status)
				{
					case InlineGraphicElementStatus.LOADING:
					case InlineGraphicElementStatus.SIZE_PENDING:
						SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(proportionalFixedWidth,2500,null),false,0,true);
						break;
					case InlineGraphicElementStatus.READY:
						var effWidth:Number = image.actualWidth as Number;
						var effHeight:Number = image.actualHeight as Number;
						
						var nomWidth:Number = image.measuredWidth as Number;
						var nomHeight:Number = image.measuredHeight as Number;
						
						assertTrue(
							"Ratio of width to height is not correct!",
							nomWidth/effWidth == nomHeight/effHeight
						);
						SelManager.textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE,addAsync(updateCompletionHandler,2500,null),false,0,true);
						break;
					default:
						assertTrue("unexpected StatusChangeEvent status: "+event.status,false);
						break;
				}
		 	}
		 }

		/**
		 * Size the FE at 50 height, then verify that the width is set proportionally.
		 */
		 public function proportionalFixedHeight(callBack:Object = null):void
		 {
			if(!callback)
			{
		 		callback = true;
				SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(proportionalFixedHeight,2500,null),false,0,true);

			 	var startIndx:int = SelManager.textFlow.textLength/2;
				var endIndx:int = startIndx;

				var src:String = data[data.length-1].toString();
				
				var width:String = "auto";
				var height:String = "50";

				SelManager.selectRange(startIndx, endIndx);
				SelManager.insertInlineGraphic(LoaderUtil.createAbsoluteURL(baseImageURL,src),width,height);
			}
			else
			{
				assertTrue("unexected event",callBack is StatusChangeEvent);
				var event:StatusChangeEvent = StatusChangeEvent(callBack);
				assertTrue("unexpected StatusChangeEvent received",event.element is InlineGraphicElement);
				var image:InlineGraphicElement = InlineGraphicElement(event.element);
				switch (event.status)
				{
					case InlineGraphicElementStatus.LOADING:
					case InlineGraphicElementStatus.SIZE_PENDING:
						SelManager.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(proportionalFixedHeight,2500,null),false,0,true);
						break;
					case InlineGraphicElementStatus.READY:
						var effWidth:Number = image.actualWidth as Number;
						var effHeight:Number = image.actualHeight as Number;
						
						var nomWidth:Number = image.measuredWidth as Number;
						var nomHeight:Number = image.measuredHeight as Number;
						
						assertTrue(
							"Ratio of width to height is not correct!",
							nomWidth/effWidth == nomHeight/effHeight
						);
						SelManager.textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE,addAsync(updateCompletionHandler,2500,null),false,0,true);
						break;
					default:
						assertTrue("unexpected StatusChangeEvent status: "+event.status,false);
						break;
				}
			}
		 }

		private function graphicStatusChangeEvent(e:StatusChangeEvent):void
		{
			try
	        {
		        if (e.status == InlineGraphicElementStatus.READY)
				{
		        	e.element.getTextFlow().flowComposer.updateAllControllers();
		  		}
	        }
	        catch ( re:RangeError )
	        {
	        	TestFrame.textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,graphicStatusChangeEvent);
	        	TestFrame.textFlow.dispatchEvent(new Event(Event.SOUND_COMPLETE));
	        	return;
	        }
		}

		private function nullFunction( param:Object = null ):void { return; }
		private function failEvent(e:Event):void { fail( "InlineGraphics not correcty updating - See Watson #2298043" ); }

		private function rect(color:int):Sprite
        {
            var sp:Sprite = new Sprite();
            sp.graphics.beginFill(color);
            sp.graphics.drawRect(0,0,200, 5);
            sp.graphics.endFill();
            sp.width  = 200;
            sp.height = 5;
            return sp;
		}

		// Test for Watson #2298043
		public function statusChangedEventTest():void
		{
			TestFrame.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, graphicStatusChangeEvent);

			TestFrame.textFlow.addEventListener(Event.SOUND_COMPLETE, addAsync(failEvent,2500, null, nullFunction));

		 	SelManager.selectAll();
		 	SelManager.deleteText();

		 	var p:ParagraphElement = new ParagraphElement();
		 	TestFrame.textFlow.addChild(p);

		 	var inlineGraphic:InlineGraphicElement = new InlineGraphicElement();
            inlineGraphic.source = "http://www.adobe.com/shockwave/download/images/flashplayer_100x100.jpg";
            p.addChild(inlineGraphic);

			var inlineGraphicElement:InlineGraphicElement = new InlineGraphicElement();
	        var sprite:Sprite = rect(0xff0000);
	        inlineGraphicElement.width  = sprite.width+10;
	        inlineGraphicElement.height = sprite.height+10;
	        inlineGraphicElement.source = sprite;
	        p.addChild(inlineGraphicElement);

	        var p2:ParagraphElement = new ParagraphElement();
	        var sp:SpanElement   = new SpanElement();
	        sp.text = "xyz";
	        inlineGraphicElement = new InlineGraphicElement();
	        sprite = rect(0x0000ff);
	        inlineGraphicElement.width  = sprite.width+9;
	        inlineGraphicElement.height = sprite.height+9;
	        inlineGraphicElement.source = sprite;
	        p2.addChild(inlineGraphicElement);
	        p2.addChild(sp);
	        TestFrame.textFlow.addChild(p2);

	        SelManager.selectAll();

	        TestFrame.textFlow.flowComposer.updateAllControllers();
		}

		// Test for Watson #2374243
		public function nullSourceExplicitWHTest():void
		{
			var p:ParagraphElement = new ParagraphElement();
		 	TestFrame.textFlow.addChild(p);

		 	var span:SpanElement = new SpanElement();
		 	span.text = "BEFORE";
		 	p.addChild(span);

		 	var inlineGraphic:InlineGraphicElement = new InlineGraphicElement();
		 	inlineGraphic.height = 48;
		 	inlineGraphic.width  = 48;
            p.addChild(inlineGraphic);

		 	span = new SpanElement();
		 	span.text = "AFTER";
		 	p.addChild(span);

	        TestFrame.textFlow.flowComposer.updateAllControllers();
		}
		
		// Watson # 2695825, Copying and pasting the first character in a text block results in a carriage return at the beginning.
		public function copyFirstCharacterTest():void
		{
			// create a paragraph
			SelManager.selectAll();
			SelManager.deleteText();
			SelManager.insertText("AAAAAAAA");
			TestFrame.textFlow.flowComposer.updateAllControllers();
							
			//select first character
			SelManager.selectRange(0, 1);
			var copy:TextScrap = TextScrap.createTextScrap(SelManager.getSelectionState());
			//paste to 3rd position
			SelManager.selectRange(3, 3 );
			SelManager.pasteTextScrap(copy);
			TestFrame.textFlow.flowComposer.updateAllControllers();
			
			//check if there is second paragraph after paste
			var elem:FlowLeafElement = SelManager.textFlow.getFirstLeaf();
			var para:ParagraphElement = elem.getParagraph();
			para = para.getNextParagraph();
			assertTrue ("there should be only one paragraph after paste.", para ==null);
		}
		
		// Watson 2724144, inline graphic is visible only if the TextLine it is on is visible
		public function inlineIsVisible():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			controller.columnCount = 1;
			controller.verticalScrollPolicy = ScrollPolicy.ON;
			controller.horizontalScrollPolicy = ScrollPolicy.ON;
			
			SelManager.selectAll();
			var scrap:TextScrap = TextScrap.createTextScrap(SelManager.getSelectionState());
			SelManager.selectRange(textFlow.textLength - 1, textFlow.textLength - 1);
			SelManager.pasteTextScrap(scrap);
			SelManager.selectRange(textFlow.textLength - 1, textFlow.textLength - 1);
			SelManager.pasteTextScrap(scrap);
			var thirdPara:FlowElement = SelManager.textFlow.getChildAt(2) as FlowElement;
			var pos:int = thirdPara.getAbsoluteStart();
			SelManager.selectRange(pos, pos);
			SelManager.insertInlineGraphic(createFilledSprite(15, 15, 0x00ff00), 15, 15, Float.NONE);
			var s:Sprite = createFilledSprite(50, 400, 0xff0000);
			SelManager.insertInlineGraphic(s, 50, 400);
			SelManager.selectRange(0, 0);
			SelManager.updateAllControllers();
			assertTrue("Expected inline to be visible even if its line is scrolled down", s.stage == TestFrame.container.stage);
			
		}
		
		// Test that the controller's protected methods for adding and removing graphic elements are being called.
		public function addRemoveInlineGraphicElement():void
		{
			var textFlow:TextFlow = SelManager.textFlow;
			var flowComposer:IFlowComposer = textFlow.flowComposer;
			var oldController:ContainerController = flowComposer.getControllerAt(0);
			flowComposer.removeAllControllers();
			var controller:TestContainerController = new TestContainerController(oldController.container);
			flowComposer.addController(controller);
			flowComposer.updateAllControllers();
			assertTrue("No inlines yet", controller.inlineCount == 0);
			var s:Sprite = createFilledSprite(50, 400, 0xff0000);
			SelManager.selectRange(0, 0);
			SelManager.allowDelayedOperations = false;
			SelManager.insertInlineGraphic(createFilledSprite(15, 15, 0x00ff00), 15, 15, Float.NONE);
			assertTrue("Inline added", controller.inlineCount == 1);
			SelManager.selectRange(0, 1);
			SelManager.deleteText();
			assertTrue("Inline removed", controller.inlineCount == 0);
		}
		
		//test for Bug # 2563434 - Importers resolve relative image paths from the swf, not the HTML file
		public function imgSourceFilterFunctionTest(callback:Object = null):void
		{
			var tf:TextFlow;
			
			if(!callback)
			{
				callback = true;
				tf = SelManager.textFlow;
				tf.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(imgSourceFilterFunctionTest,2500,null),false,0,true);	
				var textImporter:ITextImporter;
							
				SelManager.selectAll();
				SelManager.deleteText();
				SelManager.insertText("AAAAAAA");
				SelManager.textFlow.flowComposer.updateAllControllers();
				
				//get relative path for img
				var replacedSource:String = LoaderUtil.createAbsoluteURL(baseURL, "../../test/testFiles/assets/");
				
				textImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
				(textImporter as ITextLayoutImporter).imageSourceResolveFunction = function (source:String):String { replacedSource += source; return replacedSource; };
				textImporter.importToFlow("<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'><img source='smiley.gif'/></TextFlow>");
			
				SelManager.selectRange(2,2);
				//insert inline graphic
				SelManager.insertInlineGraphic( replacedSource, 100, 100 );
				SelManager.textFlow.flowComposer.updateAllControllers();
			}
			else // Make sure the image is ready before we let the snapshot go
			{
				var img:InlineGraphicElement = callback.element;
				tf = img.getTextFlow();
				if(img.status != InlineGraphicElementStatus.READY)
				{
					tf.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE,addAsync(imgSourceFilterFunctionTest,2500,null),false,0,true);
				}
			}
		}
		
		public function imgSourceSecurityError():void
		{
			var tf:TextFlow = SelManager.textFlow;
			SelManager.selectRange(0,0);
			// don't need all the data after base64, - this throws in player and TLF needs to catchit
			SelManager.insertInlineGraphic("data:image/jpg;base64,/9j",100,100);
		}
		
		public function myEmptyChilds():Canvas
		{
			var TestCanvas:Canvas = null;
			TestDisplayObject = testApp.getDisplayObject();
			if (TestDisplayObject)
			{
				TestCanvas = Canvas(TestDisplayObject);
				TestCanvas.removeAllChildren();
				var cnt:Number = TestCanvas.rawChildren.numChildren;
				for ( var a:int = 0; a < cnt; a ++ )
				{
					TestCanvas.rawChildren.removeChildAt(0);
				}
			}
			
			return TestCanvas;
		}
		
//		private function myProtocalVerifierFunction(uri:String):Boolean
//		{
//			return true;
//		}
//		
//		// mjzhang: Bug#2819930 RSL signing security fixes
//		public function inlineGraphicSWFTest_default():void
//		{
//			SelManager.selectAll();
//			SelManager.deleteText();
//			
//			var markup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
//				+"<p>"
//				+"<span>A inline graphic</span>"
//				+"<img width=\"20\" height=\"20\" source=\"../../test/testFiles/assets/SwfAttack.swf\"/>"
//				+"<span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole.</span>"
//				+"</p>"
//				+"</TextFlow>";
//			
//			var config:Configuration = new Configuration();
//			var newTF:TextFlow = TextConverter.importToFlow(markup,TextConverter.TEXT_LAYOUT_FORMAT, config);
//			var testTCM:TextContainerManager = addTCM(true);
//			testTCM.setTextFlow(newTF);
//			testTCM.updateContainer();
//						
//			newTF.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, addAsync(assertGraphic,2500,null, failFunction));
//			
//			function failFunction():void
//			{
//				assertTrue("Inline Graphic not support swf by default, so will go here", true);
//			}
//			
//			function assertGraphic(obj:Object = null):void
//			{
//				assertTrue("Inline Graphic not support swf by default, so will not go here", false);
//			}
//		}
//		
//		// mjzhang: Bug#2819930 RSL signing security fixes
//		public function inlineGraphicPNGTest_default():void
//		{
//			SelManager.selectAll();
//			SelManager.deleteText();
//			
//			var markup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
//				+"<p>"
//				+"<span>A inline graphic</span>"
//				+"<img width=\"20\" height=\"20\" source=\"../../test/testFiles/assets/smiling.swf.png\"/>"
//				+"<span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole.</span>"
//				+"</p>"
//				+"</TextFlow>";
//			
//			var config:Configuration = new Configuration();
//			var newTF:TextFlow = TextConverter.importToFlow(markup,TextConverter.TEXT_LAYOUT_FORMAT, config);
//			var testTCM:TextContainerManager = addTCM(true);
//			testTCM.setTextFlow(newTF);
//			testTCM.updateContainer();
//			
//			newTF.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, addAsync(assertGraphic,2500,null, failFunction));
//			
//			function failFunction():void
//			{
//				assertTrue("Inline Graphic support png by default, so will not go here", false);
//			}
//			
//			function assertGraphic(obj:Object = null):void
//			{
//				assertTrue("Inline Graphic support png by default, so will go here", true);
//			}
//		}
//		
//		// mjzhang: Bug#2819930 RSL signing security fixes
//		public function inlineGraphicSWFTest_SWFenabled():void
//		{
//			SelManager.selectAll();
//			SelManager.deleteText();
//			
//			var markup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
//				+"<p>"
//				+"<span>A inline graphic</span>"
//				+"<img width=\"20\" height=\"20\" source=\"../../test/testFiles/assets/SwfAttack.swf\"/>"
//				+"<span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole.</span>"
//				+"</p>"
//				+"</TextFlow>";
//			
//			var config:Configuration = new Configuration();
//			config.inlineGraphicProtocolVerifierFunction = myProtocalVerifierFunction;
//			var newTF:TextFlow = TextConverter.importToFlow(markup,TextConverter.TEXT_LAYOUT_FORMAT, config);
//			var testTCM:TextContainerManager = addTCM(true);
//			testTCM.setTextFlow(newTF);
//			testTCM.updateContainer();
//			
//			newTF.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, addAsync(assertGraphic,2500,null, failFunction));
//			
//			function failFunction():void
//			{
//				assertTrue("Inline Graphic not support swf by default, but we override Config.inlineGraphicProtocolVerifierFunction, so will not go here", false);
//			}
//			
//			function assertGraphic(obj:Object = null):void
//			{
//				assertTrue("Inline Graphic not support swf by default, but we override Config.inlineGraphicProtocolVerifierFunction, so will go here", true);
//			}
//		}
//		
//		// mjzhang: Bug#2819930 RSL signing security fixes
//		// the test file smillingswf.png is actually a SWF file, uses '.png' as file extention
//		public function inlineGraphicFakePNGTest_default():void
//		{
//			SelManager.selectAll();
//			SelManager.deleteText();
//			//+"<img width=\"20\" height=\"20\" source=\"../../test/testFiles/assets/fakepng.png\"/>"
//			var markup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
//				+"<p>"
//				+"<span>A inline graphic</span>"
//				+"<img width=\"20\" height=\"20\" source=\"../../test/testFiles/assets/SwfAttack.swf.png\"/>"
//				+"<span>The man who now watched the fire was of a different order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole.</span>"
//				+"</p>"
//				+"</TextFlow>";
//			
//			var config:Configuration = new Configuration();
//			var newTF:TextFlow = TextConverter.importToFlow(markup,TextConverter.TEXT_LAYOUT_FORMAT, config);
//			var testTCM:TextContainerManager = addTCM(true);
//			testTCM.setTextFlow(newTF);
//			testTCM.updateContainer();
//			
//			newTF.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, addAsync(assertGraphic,2500,null, failFunction));
//			
//			function failFunction():void
//			{
//				assertTrue("Inline Graphic support png by default, but this file is actually a SWF, so will go here", true);
//			}
//			
//			function assertGraphic(obj:Object = null):void
//			{
//				assertTrue("Inline Graphic support png by default, but this file is actually a SWF, so will not go here", false);
//			}
//		}
		
		// mjzhang: Bug#2930383 [Null Pointer Exception] Clicking enter at the beginning of a sentence after adding an ILG causes NPE
		public function inlineGraphicEnterNPETest():void
		{
			SelManager.selectAll();
			SelManager.deleteText();
			var textFlow:TextFlow = SelManager.textFlow;
			
			var markup:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
				+"<p>"
				+"<span>Hello, world</span>"
				+"<img width=\"30\" height=\"30\" source=\"../../test/testFiles/assets/smiling.png\"/>"
				+"</p>"
				+"</TextFlow>";
			
			var newTF:TextFlow = TextConverter.importToFlow(markup,TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.replaceChildren(0, textFlow.numChildren, newTF.mxmlChildren);
			textFlow.addEventListener(DamageEvent.DAMAGE, onDamageEvent);
			textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, onCompositionComplete);
			SelManager.updateAllControllers();
			
			function onCompositionComplete(event:CompositionCompleteEvent):void
			{
				textFlow.removeEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, onCompositionComplete);
				
				SelManager.selectRange(0, 0);
				var kEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 13, Keyboard.ENTER);
				TestFrame.container.dispatchEvent(kEvent);
			}
			
			function onDamageEvent(event:DamageEvent):void
			{
				try
				{
					var start:int = (event.damageAbsoluteStart > 0) ? event.damageAbsoluteStart-1: 0;
					event.textFlow.getText(start, start + 2);
				}
				catch(e:Error)
				{
					assertTrue("getText shouldn't got null pointer exception.", false);
					return;
				}
				
				assertTrue("We got correct code path, no exception", true);
			}
		}
	
	}
}

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import flashx.textLayout.container.ContainerController;

class TestContainerController extends ContainerController
{
	public var inlineCount:int;
	
	public function TestContainerController(container:Sprite,compositionWidth:Number=100,compositionHeight:Number=100)
	{
		super(container, compositionWidth, compositionHeight);
		inlineCount = 0;
	}
	
	override protected function addInlineGraphicElement(parent:DisplayObjectContainer, inlineGraphicElement:DisplayObject, index:int):void
	{
		super.addInlineGraphicElement(parent, inlineGraphicElement, index);
		++inlineCount;
	}
	
	override protected function removeInlineGraphicElement(parent:DisplayObjectContainer, inlineGraphicElement:DisplayObject):void
	{
		super.removeInlineGraphicElement(parent, inlineGraphicElement);
		--inlineCount;
	}
}
