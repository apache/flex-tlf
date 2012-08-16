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
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.EditingMode;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.edit.SelectionFormatState;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

    [SWF(width="600", height="400")]
    public class TCMTestFocus2 extends Sprite
    {
    	private var tcm:TextContainerManager;

        public function TCMTestFocus2()
        {
            super();
        	root.loaderInfo.addEventListener(Event.INIT, initialize);
        }

        public function initialize(event:Event):void
        {

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            var b:Sprite;

            b = new Sprite();
            addChild(b);
            b.graphics.beginFill(0xffccff);
            b.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            b.graphics.endFill();

            addLabel("Test 1: Tab should go to the 'enter name here' field",10,10,200,20);
            addLabel("A focusIn event will clear the field.",10,30,200,20);
            addLabel("Type your name to ensure field has focus.",10,50,200,20);

            var obj:Object;
            obj = addTextInputManagerText(10,70,200,20,"enter name here");
            tcm = obj.tcm;
            b = obj.sprite;
            focusableObjects.push(b);
            appTextInputs[b] = obj.tcm;
            b.name = "first";
            b.addEventListener(FocusEvent.FOCUS_IN, ti_focusInHandler);
            b.addEventListener(FocusEvent.FOCUS_IN, user_ti_focusInHandler);
            b.addEventListener(MouseEvent.MOUSE_DOWN, ti_mouseDownHandler);

            addLabel("Test 2: Tab should go to the 'another text input' field",10,100,200,20);
            addLabel("Entire text should be selected.",10,120,200,20);
            addLabel("Type to ensure focus, use shift-arrow to select some text.",10,140,200,20);
            obj = addTextInputManagerText(10,160,200,20,"another text input");
            b = obj.sprite;
            focusableObjects.push(b);
            appTextInputs[b] = obj.tcm;
            b.name = "second";
            b.addEventListener(FocusEvent.FOCUS_IN, ti_focusInHandler);
            b.addEventListener(MouseEvent.MOUSE_DOWN, ti_mouseDownHandler);

            psuedoWindowParent = b = new Sprite();
            b.mouseEnabled = true;
            b.mouseChildren = true;
            addChild(b);
            b.graphics.beginFill(0xccffff);
            b.graphics.drawRect(0, 0, 300, 200);
            b.graphics.endFill();
            b.y = 40;
            b.x = 300;

            addLabel("Test 3: Click in Blue area (not in TextInput)",10,10,200,20, psuedoWindowParent);
            addLabel("Focus should got to 'pseudo-window field'.",10,30,200,20, psuedoWindowParent);
            addLabel("Type to ensure focus, use shift-arrow to select some text.",10,50,200,20, psuedoWindowParent);

            obj = addTextInputManagerText(25,80,200,20,"psuedo-window field", psuedoWindowParent);
            b = obj.sprite;
            psuedoWindow = b;
            psuedoWindowTCM = obj.tcm;
            focusableObjects.push(b);
            b.name = "psuedo";
            b.addEventListener(FocusEvent.FOCUS_IN, ti_focusInHandler);
            b.addEventListener(MouseEvent.MOUSE_DOWN, ti_mouseDownHandler);

            readSelectButton = addButton("read-select", 25,110,100,20,readSelectHandler, psuedoWindowParent);
            editableButton = addButton("editable", 125,110,100,20,editableHandler, psuedoWindowParent);

            addLabel("Test 4: Click read-select button, selection should remain",10,140,200,20, psuedoWindowParent);
            addLabel("Test 5: Click on editable button, selection should remain",10,160,200,20, psuedoWindowParent);

            addLabel("Test 6: Click in '0' field, then click on up/down buttons",10,200,200,20);
            addLabel("Focus should remain in 0 field as number changes.",10,220,200,20);
            addLabel("Use up/down arrows, make sure numbers change by 1",10,240,200,20);

            nsWrapper = b = new Sprite();
            b.mouseEnabled = true;
            b.mouseChildren = true;
            addChild(b);
            b.graphics.beginFill(0xffffcc);
            b.graphics.drawRect(0, 0, 280, 20);
            b.graphics.endFill();
            b.y = 260;
            b.x = 10;

            obj = addTextInputManagerText(0,0,200,20,"0", nsWrapper);
            ns = obj.tcm;
            nsSprite = obj.sprite;
            obj.sprite.name = "ns";
            appTextInputs[b] = ns;
            focusableObjects.push(nsSprite);
            nsSprite.addEventListener(FocusEvent.FOCUS_IN, ns_focusInHandler);
            nsSprite.addEventListener(FocusEvent.FOCUS_OUT, ns_focusOutHandler);
            nsSprite.addEventListener(MouseEvent.MOUSE_DOWN, ti_mouseDownHandler);

            addButton("up",   200,0,40,20,incrHandler, nsWrapper);
            addButton("down", 240,0,40,20,decrHandler, nsWrapper);

            addLabel("Test 7 (Proxy): Click in blue rectangle and type",10,290,100,20);
            addLabel("Yellow focus remains on rect, vowels do not show up in field",10,310,100,20);
            b = new Sprite();
            addChild(b);
            b.graphics.clear();
            b.graphics.lineStyle(1);
            b.graphics.beginFill(0xCCCCFF);
            b.graphics.drawRect(0, 0, 100, 20);
            b.graphics.endFill();
            b.x = 10;
            b.y = 330;
            focusableObjects.push(b);
            b.addEventListener(FocusEvent.FOCUS_IN, proxy_focusInHandler);
            b.addEventListener(FocusEvent.FOCUS_OUT, proxy_focusOutHandler);
            obj = addTextInputManagerText(10,350,200,20,"proxied field");
            proxy = obj.tcm;
            proxySprite = obj.sprite;
            appTextInputs[obj.sprite] = proxy;
            obj.sprite.name = "proxy";

            addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true, 1000);
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler);
            addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
            addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);

        }


        public function getFocus():DisplayObject
        {
            return stage.focus;
        }

        private function keyDownHandler(e:KeyboardEvent):void
        {
            if (!e.cancelable)
            {
                switch (e.keyCode)
                {
                    case Keyboard.UP:
                    case Keyboard.DOWN:
                    case Keyboard.PAGE_UP:
                    case Keyboard.PAGE_DOWN:
                    case Keyboard.HOME:
                    case Keyboard.END:
                    case Keyboard.LEFT:
                    case Keyboard.RIGHT:
                    case Keyboard.ENTER:
                    {
                        e.stopImmediatePropagation();
                        var cancelableEvent:KeyboardEvent =
                            new KeyboardEvent(e.type, e.bubbles, true, e.charCode, e.keyCode,
                                              e.keyLocation, e.ctrlKey, e.altKey, e.shiftKey)
                        e.target.dispatchEvent(cancelableEvent);
                    }
                }
            }
        }

        private var textInputMouseDown:Boolean;

        private function user_ti_focusInHandler(event:Event):void
        {
            trace("user_ti_focusInHandler", event.target.name);
            if (tcm.getText() == "enter name here")
            {
                tcm.setText("");
                var im:ISelectionManager = tcm.beginInteraction();
                im.selectRange(0,0);
                tcm.updateContainer();
                tcm.endInteraction();
                stateFocusEvent(tcm);
            }

        }
        private function ti_focusInHandler(event:Event):void
        {
            trace("ti_focusInHandler", event.target.name);
            if (appTextInputs[event.target])
            {
                trace("    is TextInput");
                if (!textInputMouseDown)
                {
                    var tcm:TextContainerManager = TextContainerManager(appTextInputs[event.target]);
                    var im:ISelectionManager = tcm.beginInteraction();
                    trace("    force selection");
                    im.selectAll();
                    tcm.updateContainer();
                    tcm.endInteraction();
                }
            }

        }
        private function ti_mouseDownHandler(event:Event):void
        {
            trace("ti_mouseDownHandler", event.target.name);
            if (appTextInputs[event.target])
            {
                trace("    is TextInput");
                textInputMouseDown = true;
                event.currentTarget.stage.addEventListener(MouseEvent.MOUSE_UP, ti_mouseUpHandler);
            }

        }
        private function ti_mouseUpHandler(event:Event):void
        {
            event.currentTarget.stage.removeEventListener(MouseEvent.MOUSE_UP, ti_mouseUpHandler);
            trace("ti_mouseUpHandler", event.target.name);
            if (appTextInputs[event.target])
            {
                trace("    is TextInput");
                textInputMouseDown = false;
            }

        }

        private function focusInHandler(event:Event):void
        {
            trace(event.type, event.target.name);
        }
        private function focusOutHandler(event:Event):void
        {
            trace(event.type, event.target.name);
        }

        private function mouseFocusChangeHandler(event:Event):void
        {
            trace("mouseFocusChange", event.target, event.target.name);
            event.preventDefault();
        }

        private function mouseUpHandler(event:Event):void
        {
            trace("mouseUpHandler", event.target, event.target.name);
        }
        private function mouseDownHandler(event:Event):void
        {
            trace("mouseDownHandler");
            var target:DisplayObject = DisplayObject(event.target);
            if (target == psuedoWindowParent || psuedoWindowParent.contains(target))
            {
                if (appActive)
                {
                    var tcm:TextContainerManager = TextContainerManager(appTextInputs[stage.focus]);
                    if (tcm != null)
                    {
                        if (tcm == proxy)
                            inactiveEvent(tcm);
                        else
                            stateInactiveEvent(tcm);
                    }
                    appActive = false;
                    appLastFocus = stage.focus as Sprite;
                    if (appLastFocus)
                        trace("appLastFocus", appLastFocus);
                }
                stage.focus = psuedoWindow;
                trace("setting focus to psuedoWindow");
                return;
            }
            else
            {
                var n:int = focusableObjects.length;
                for (var i:int = 0; i < n; i++)
                {
                    var s:Sprite = focusableObjects[i];
                    if (s == target || s.contains(target))
                    {
                        trace("setting focus ourselves");
                        stage.focus = appLastFocus = s;
                        appActive = true;
                    }
                }
                if (!appActive)
                {
                    trace("just activating");
                    if (appLastFocus)
                        trace("appLastFocus", appLastFocus);
                    tcm = TextContainerManager(appTextInputs[appLastFocus]);
                    if (tcm != null)
                    {
                        if (tcm == proxy)
                            focusEvent(tcm);
                        else
                            stateFocusEvent(tcm);
                    }
                    stateInactiveEvent(psuedoWindowTCM);
                    appActive = true;
                }
            }

        }

        private function readSelectHandler(event:Event):void
        {
            var im:ISelectionManager = psuedoWindowTCM.beginInteraction();
            var beginIndex:int = im.anchorPosition;
            var endIndex:int = im.activePosition;
            trace("sel:", beginIndex, endIndex);
            psuedoWindowTCM.endInteraction();
            psuedoWindowTCM.editingMode = EditingMode.READ_SELECT;
            im = psuedoWindowTCM.beginInteraction();
            im.selectRange(beginIndex, endIndex);
            psuedoWindowTCM.updateContainer();
            psuedoWindowTCM.endInteraction();
        }
        private function editableHandler(event:Event):void
        {
            psuedoWindowTCM.editingMode = EditingMode.READ_WRITE;
            var im:ISelectionManager = psuedoWindowTCM.beginInteraction();
            im.setFocus();
            psuedoWindowTCM.endInteraction();
        }

        private var focusableObjects:Array = [];
        private var readSelectButton:Sprite;
        private var editableButton:Sprite;
        private var psuedoWindowParent:Sprite;
        private var psuedoWindow:Sprite;
        private var psuedoWindowTCM:TextContainerManager;
        private var appActive:Boolean = true;
        private var appLastFocus:Sprite;
        private var appTextInputs:Dictionary = new Dictionary();

        private var proxy:TextContainerManager;
        private var proxySprite:Sprite;

        private var ns:TextContainerManager;
        private var nsSprite:Sprite;
        private var nsWrapper:Sprite;

        private var value:int = 0;
        private function incrHandler(event:Event):void
        {
            value++;
            // clears the previous textflow and changes the TCM to factory mode
            ns.setText(value.toString());

            var im:ISelectionManager = ns.beginInteraction();
            im.selectRange(0,0);               // or remember what it was previously
            ns.endInteraction();

            ns.updateContainer();
            if (stage.focus)
                trace(stage.focus.name);
            stateFocusEvent(ns);
        }
        private function decrHandler(event:Event):void
        {
            value--;
            // clears the previous textflow and changes the TCM to factory mode
            ns.setText(value.toString());

            var im:ISelectionManager = ns.beginInteraction();
            im.selectRange(0,0);               // or remember what it was previously
            ns.endInteraction();

            ns.updateContainer();
            if (stage.focus)
                trace(stage.focus.name);
            stateFocusEvent(ns);
        }
        private function ns_focusInHandler(event:FocusEvent):void
        {
            trace("ns_focusIn");
            nsWrapper.addEventListener(KeyboardEvent.KEY_DOWN, ns_keyDownHandler, true);
        }
        private function ns_focusOutHandler(event:FocusEvent):void
        {
            trace("ns_focusOut");
            nsWrapper.removeEventListener(KeyboardEvent.KEY_DOWN, ns_keyDownHandler, true);
        }
        private function ns_keyDownHandler(event:KeyboardEvent):void
        {
            trace("ns_keyDownHandler");

            if (event.isDefaultPrevented())
            {
                trace("default prevented, ignoring keystroke");
                return;
            }

            if (event.keyCode == Keyboard.UP)
            {
                value++;
                ns.setText(value.toString());
                var im:ISelectionManager = ns.beginInteraction();
                im.selectRange(0,0);               // or remember what it was previously
                ns.endInteraction();

                ns.updateContainer();
                stateFocusEvent(ns);
                event.preventDefault();
            }
            if (event.keyCode == Keyboard.DOWN)
            {
                value--;
                ns.setText(value.toString());
                im = ns.beginInteraction();
                im.selectRange(0,0);               // or remember what it was previously
                ns.endInteraction();

                ns.updateContainer();
                stateFocusEvent(ns);
                event.preventDefault();
            }
            if (event.keyCode == Keyboard.HOME)
            {
                value = 0;
                ns.setText(value.toString());
                im = ns.beginInteraction();
                im.selectRange(0,0);               // or remember what it was previously
                ns.endInteraction();

                ns.updateContainer();
                stateFocusEvent(ns);
                event.preventDefault();
            }
            if (event.keyCode == Keyboard.END)
            {
                value = 100;
                ns.setText(value.toString());
                im = ns.beginInteraction();
                im.selectRange(0,0);               // or remember what it was previously
                ns.endInteraction();

                ns.updateContainer();
                stateFocusEvent(ns);
                event.preventDefault();
            }
        }

        private var filtered:String = "aeiou";
        private function proxy_focusInHandler(event:FocusEvent):void
        {
            event.target.addEventListener(KeyboardEvent.KEY_DOWN, proxy_keyDownHandler);
            event.target.addEventListener(KeyboardEvent.KEY_UP, proxy_keyDownHandler);
            event.target.addEventListener(TextEvent.TEXT_INPUT, proxy_textInputHandler);
            focusEvent(proxy);
            proxy.setText("");
            var editManager:IEditManager = EditManager(proxy.beginInteraction());
            editManager.selectRange(0,0);
            proxy.updateContainer();
            proxy.requiredFocusInHandler(null);
            proxy.endInteraction();

        }
        private function proxy_focusOutHandler(event:FocusEvent):void
        {
            event.target.removeEventListener(KeyboardEvent.KEY_DOWN, proxy_keyDownHandler);
            event.target.removeEventListener(KeyboardEvent.KEY_UP, proxy_keyDownHandler);
            event.target.removeEventListener(TextEvent.TEXT_INPUT, proxy_textInputHandler);
            unfocusedEvent(proxy);
        }
        private function proxy_keyDownHandler(event:KeyboardEvent):void
        {
            var s:String = String.fromCharCode(event.charCode);
            trace(s);
            if (filtered.indexOf(s) == -1)
            {
                trace("fake event");
                proxySprite.dispatchEvent(event);
            }
        }
        private function proxy_textInputHandler(event:TextEvent):void
        {
            var s:String = event.text;
            trace(s);
            if (filtered.indexOf(s) == -1)
            {
                trace("fake event");
                proxySprite.dispatchEvent(event);
            }
        }

        private static var textBlock:TextBlock = new TextBlock();
        private static var textElement:TextElement = new TextElement();

        private function addLabel(text:String,x:Number,y:Number,width:Number,height:Number, parentContainer:DisplayObjectContainer = null):TextLine
        {
            var elementFormat:ElementFormat = new ElementFormat();
            //elementFormat.fontSize = 20;
            var fontDescription:FontDescription = new FontDescription();
            //fontDescription.fontName = "Arial";
            elementFormat.fontDescription = fontDescription;
            textElement.text = text;
            textElement.elementFormat = elementFormat;
            textBlock.content = textElement;
            var textLine:TextLine = textBlock.createTextLine(null, 1000);
            if (parentContainer)
                parentContainer.addChild(textLine);
            else
                addChild(textLine);
            textLine.x = x;
            textLine.y = y + textLine.height;
            return textLine;
        }

        private function addButton(text:String,x:Number,y:Number,width:Number,height:Number,handler:Function, parentContainer:DisplayObjectContainer = null):Sprite
        {
            var b:Sprite = new Sprite();
            if (parentContainer)
                parentContainer.addChild(b);
            else
                addChild(b);
            var elementFormat:ElementFormat = new ElementFormat();
            elementFormat.fontDescription = new FontDescription();
            textElement.text = text;
            textElement.elementFormat = elementFormat;
            textBlock.content = textElement;
            var textLine:TextLine = textBlock.createTextLine(null, 1000);
            b.addChild(textLine);
            textLine.y = textLine.height;
            textLine.x = (width - textLine.width) / 2
            b.x = x;
            b.y = y;
            b.graphics.clear();
            b.graphics.lineStyle(1);
            b.graphics.beginFill(0xFFCCCC);
            b.graphics.drawRect(0, 0, width, height);
            b.graphics.endFill();
            b.mouseEnabled = true;
            b.buttonMode = true;
            b.addEventListener(MouseEvent.CLICK, handler);
            b.addEventListener(MouseEvent.ROLL_OVER, button_rollOverHandler);
            b.addEventListener(MouseEvent.ROLL_OUT, button_rollOutHandler);
            return b;
        }
        private function button_rollOverHandler(event:MouseEvent):void
        {
            var b:Sprite = event.currentTarget as Sprite;
            var w:Number = b.width;
            var h:Number = b.height;
            b.graphics.clear();
            b.graphics.lineStyle(1);
            b.graphics.beginFill(0xFFDDDD);
            b.graphics.drawRect(0, 0, w - 1, h - 1);
            b.graphics.endFill();
        }

        private function button_rollOutHandler(event:MouseEvent):void
        {
            var b:Sprite = event.currentTarget as Sprite;
            var w:Number = b.width;
            var h:Number = b.height;
            b.graphics.clear();
            b.graphics.lineStyle(1);
            b.graphics.beginFill(0xFFCCCC);
            b.graphics.drawRect(0, 0, w - 1, h - 1);
            b.graphics.endFill();
        }

        // these handlers demonstrate how to transition to the different states
        // checking composeState first (its tlf_internal) is useful for finding out if we are in an optimized no selection state
        // checking interactionManager is useful for finding out if this is a read-only tcm.  Could check tcm.editingMode as well
        // its also possible to query
        private function stateFocusEvent(tcm:TextContainerManager):void
        {
         	trace("stateFocusEvent");
         	if (tcm.composeState == TextContainerManager.COMPOSE_COMPOSER)
         	{
		       	var im:ISelectionManager = tcm.beginInteraction();
		       	// this has side effects - it steals focus
		       	if (im && im.hasSelection())
		       	{
                    // AJH - can't set focus=null, runs too much other code
		       		// stage.focus = null;	// clear it somehow!!! (or could make sure it was already cleared)
		        	im.setFocus();
		       		tcm.requiredFocusInHandler(null);
		        }
	        	tcm.endInteraction();
	        }
        }
        private function stateUnfocusedEvent(tcm:TextContainerManager):void
        {
        	trace("stateUnfocusedEvent");
        	// NOTE TO FLEX:  IF the stage.focus points to the container it still gets TextInput events.  Its up to you to block them in your TCM override
         	if (tcm.composeState == TextContainerManager.COMPOSE_COMPOSER)
         	{
 		       	var im:ISelectionManager = tcm.beginInteraction();
		       	if (im)
		       	{
		       		// clear focus somehow!!! either of these next two lines works
		       		tcm.requiredFocusOutHandler(null);
		       		//if (stage.focus == tcm.container) stage.focus = null;	 // ajh - dangerous, runs lots of code, fires bindings
		       		tcm.deactivateHandler(null);
		       		tcm.activateHandler(null);
	 			}
		       	tcm.endInteraction();
        	}
        }
        private function stateInactiveEvent(tcm:TextContainerManager):void
        {
        	trace("stateInactiveEvent");
        	// NOTE TO FLEX:  IF the stage.focus points to the container it still gets TextInput events.  Its up to you to block them in your TCM override
          	if (tcm.composeState == TextContainerManager.COMPOSE_COMPOSER)
          	{
 		       	var im:ISelectionManager = tcm.beginInteraction();
		       	if (im)
		       	{
		       		// clear focus somehow!!! either of these next two lines works
		       		tcm.requiredFocusOutHandler(null);
		       		//if (stage.focus == tcm.container) stage.focus = null;	 // ajh - dangerous, runs lots of code, fires bindings
	 				tcm.deactivateHandler(null);
		       	}
		       	tcm.endInteraction();
			}
        }

        private function focusEvent(tcm:TextContainerManager):void
        {
         	trace("focusEvent");
          	if (tcm.composeState == TextContainerManager.COMPOSE_COMPOSER)
          	{
 		       	var im:ISelectionManager = tcm.beginInteraction();
		       	if (im)
		       		SelectionManager(im).setSelectionFormatState(SelectionFormatState.FOCUSED);
		       	tcm.endInteraction();
			}
        }

        private function unfocusedEvent(tcm:TextContainerManager):void
        {
         	trace("unfocusedEvent");
          	if (tcm.composeState == TextContainerManager.COMPOSE_COMPOSER)
          	{
 		       	var im:ISelectionManager = tcm.beginInteraction();
		       	if (im)
		       		SelectionManager(im).setSelectionFormatState(SelectionFormatState.UNFOCUSED);
		       	tcm.endInteraction();
			}
        }

        private function inactiveEvent(tcm:TextContainerManager):void
        {
         	trace("inactiveEvent");
          	if (tcm.composeState == TextContainerManager.COMPOSE_COMPOSER)
          	{
 		       	var im:ISelectionManager = tcm.beginInteraction();
		       	if (im)
		       		SelectionManager(im).setSelectionFormatState(SelectionFormatState.INACTIVE);
		       	tcm.endInteraction();
			}
        }

        private static var testConfiguration:IConfiguration;

        public function addTextInputManagerText(x:Number, y:Number, width:Number, height:Number, text:String, parentContainer:DisplayObjectContainer = null):Object
        {
            var b:Sprite = new Sprite();
            var tf:Sprite = new Sprite();

            if (!testConfiguration)
            {
            	// hmmm maybe clone should be on IConfiguration
	            var config:Configuration = (TextContainerManager.defaultConfiguration as Configuration).clone();

	            // different focus selection colors
	            config.focusedSelectionFormat    = new SelectionFormat(0xffffff, 1.0, BlendMode.DIFFERENCE);
				config.unfocusedSelectionFormat = new SelectionFormat(0xa8c6ee, 1.0, BlendMode.NORMAL, 0xa8c6ee, 1.0, BlendMode.NORMAL, 0);
				config.inactiveSelectionFormat  = new SelectionFormat(0xc8c8c8, 1.0, BlendMode.NORMAL, 0xc8c8c8, 1.0, BlendMode.NORMAL, 0);

				testConfiguration = config;
            }

            var tm:TextContainerManager = new CustomTextContainerManager(tf,testConfiguration);
            tm.compositionWidth = width;
            tm.compositionHeight = height;

            tm.editingMode = EditingMode.READ_WRITE;
            tm.setText(text);
            /* var editManager:IEditManager = EditManager(tm.beginInteraction());
            editManager.selectRange(0,0);
            editManager.insertText("there should not be a blinking cursor");
            tm.endInteraction(); */

            tm.updateContainer();

            tf.y = 6;
            tf.x = 2;
            b.addChild(tf);
            b.x = x;
            b.y = y;
            b.graphics.clear();
            b.graphics.lineStyle(1);
            b.graphics.beginFill(0xFFFFFF);
            b.graphics.drawRect(0, 0, width, height);
            b.graphics.endFill();
            if (parentContainer)
                parentContainer.addChild(b);
            else
                addChild(b);

            return { tcm: tm, sprite: tf };
        }

    }
}

import flash.display.Sprite;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.elements.IConfiguration;

class CustomTextContainerManager extends TextContainerManager
{
	public function CustomTextContainerManager(container:Sprite,configuration:IConfiguration =  null)
	{
		super(container,configuration);
	}

	override public function focusInHandler(event:FocusEvent):void
    {
    	trace("tcm:focusInHandler");

    	var im:ISelectionManager = beginInteraction();
    	if (!im.hasSelection())
	        im.selectRange(0,0);
        updateContainer();
        endInteraction();

        super.focusInHandler(event);
	}

    override public function mouseUpHandler(event:MouseEvent):void
    {
    	trace("tcm:mouseUpHandler");
        super.mouseUpHandler(event);
    }

    override public function mouseDownHandler(event:MouseEvent):void
    {
    	trace("tcm:mouseDownHandler");
        super.mouseDownHandler(event);
    }
}
