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
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

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

    public class TCMTestFocus extends Sprite
    {
    	private var tcm:TextContainerManager;

        public function TCMTestFocus()
        {
            super();

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            tcm = addTextInputManagerText(10,60,200,20,"enter name here");

            addTextInputManagerText(10,110,200,20,"another TCM field");

            // put some TextFields up for hitting - psuedo buttons
            addButton("ChgState:",20,10,60,20,null);
            addButton("Focus",   110,10,60,20,stateFocusEvent);
            addButton("Unfocus", 200,10,60,20,stateUnfocusedEvent);
            addButton("Inactive",290,10,60,20,stateInactiveEvent);

            addButton("ChgFormat:",20,30,60,20,null);
            addButton("Focus",   110,30,60,20,focusEvent);
            addButton("Unfocus", 200,30,60,20,unfocusedEvent);
            addButton("Inactive",290,30,60,20,inactiveEvent);
        }

        private function addButton(text:String,x:Number,y:Number,width:Number,height:Number,handler:Function):TextField
        {
            var f1:TextField = new TextField();
            f1.text = text;
            f1.x = x; f1.y = y; f1.height = height; f1.width = width;
            addChild(f1);
            if (handler != null)
	        {
	            f1.border = true;
	            f1.borderColor = 0xff;
	            f1.addEventListener(MouseEvent.MOUSE_OVER,handler);
	        }
            f1.selectable = false;

            return f1;
        }

        // these handlers demonstrate how to transition to the different states
        // checking composeState first (its tlf_internal) is useful for finding out if we are in an optimized no selection state
        // checking interactionManager is useful for finding out if this is a read-only tcm.  Could check tcm.editingMode as well
        // its also possible to query
        private function stateFocusEvent(e:Event):void
        {
         	trace("stateFocusEvent");
         	if (tcm.composeState == TextContainerManager.COMPOSE_COMPOSER)
         	{
		       	var im:ISelectionManager = tcm.beginInteraction();
		       	// this has side effects - it steals focus
		       	if (im && im.hasSelection())
		       	{
		       		stage.focus = null;	// clear it somehow!!! (or could make sure it was already cleared)
		        	im.setFocus();
		        }
	        	tcm.endInteraction();
	        }
        }
        private function stateUnfocusedEvent(e:Event):void
        {
        	trace("stateUnfocusedEvent");
        	// NOTE TO FLEX:  IF the stage.focus points to the container it still gets TextInput events.  Its up to you to block them in your TCM override
         	if (tcm.composeState == TextContainerManager.COMPOSE_COMPOSER)
         	{
 		       	var im:ISelectionManager = tcm.beginInteraction();
		       	if (im)
		       	{
		       		// clear focus somehow!!! either of these next two lines works
		       		//tcm.requiredFocusOutHandler(null);
		       		if (stage.focus == tcm.container) stage.focus = null;
		       		tcm.deactivateHandler(null);
		       		tcm.activateHandler(null);
	 			}
		       	tcm.endInteraction();
        	}
        }
        private function stateInactiveEvent(e:Event):void
        {
        	trace("stateInactiveEvent");
        	// NOTE TO FLEX:  IF the stage.focus points to the container it still gets TextInput events.  Its up to you to block them in your TCM override
          	if (tcm.composeState == TextContainerManager.COMPOSE_COMPOSER)
          	{
 		       	var im:ISelectionManager = tcm.beginInteraction();
		       	if (im)
		       	{
		       		// clear focus somehow!!! either of these next two lines works
		       		// tcm.requiredFocusOutHandler(null);
		       		if (stage.focus == tcm.container) stage.focus = null;
	 				tcm.deactivateHandler(null);
		       	}
		       	tcm.endInteraction();
			}
        }

        private function focusEvent(e:Event):void
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

        private function unfocusedEvent(e:Event):void
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

        private function inactiveEvent(e:Event):void
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

        public function addTextInputManagerText(x:Number, y:Number, width:Number, height:Number, text:String):TextContainerManager
        {
            var bg:Sprite = new Sprite();

            if (!testConfiguration)
            {
            	// hmmm maybe clone should be on IConfiguration
	            var config:Configuration = (TextContainerManager.defaultConfiguration as Configuration).clone();

	            // different focus selection colors
	            config.focusedSelectionFormat    = new SelectionFormat(0xffffff, 1.0, BlendMode.DIFFERENCE);
				config.unfocusedSelectionFormat = new SelectionFormat(0xa8c6ee, 1.0, BlendMode.NORMAL, 0xa8c6ee, 1.0, BlendMode.NORMAL, 0);
				config.inactiveSelectionFormat  = new SelectionFormat(0xe8e8e8, 1.0, BlendMode.NORMAL, 0xe8e8e8, 1.0, BlendMode.NORMAL, 0);

				testConfiguration = config;
            }

            var tm:TextContainerManager = new TextContainerManager(bg,testConfiguration);
            tm.compositionWidth = NaN;
            tm.compositionHeight = NaN;

            tm.editingMode = EditingMode.READ_WRITE;
            tm.setText(text);
            /* var editManager:IEditManager = EditManager(tm.beginInteraction());
            editManager.setSelection(0,0);
            editManager.insertText("there should not be a blinking cursor");
            tm.endInteraction(); */

            tm.updateContainer();

            bg.x = x;
            bg.y = y;
            addChild(bg);

            return tm;
        }

    }
}

