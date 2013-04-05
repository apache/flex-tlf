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
package bxf.ui.controls
{
	import bxf.ui.inspectors.HotTextInput;
	import bxf.ui.utils.EffectiveStage;
	
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextLineMetrics;
	
	import mx.controls.TextInput;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	
	[Event(name="change", type="bx.controls.HotTextEvent")]
	[Event(name="finishChange", type="bx.controls.HotTextEvent")]
	[Event(name="active", type="bx.controls.HotTextEvent")]
	[Event(name="inactive", type="bx.controls.HotTextEvent")]
	
	public class HotText extends UIComponent
	{
		[Embed(source="../assets/finger_scrub_cur.png")]
		private static var sHorizResizeCursor:Class;

	    //----------------------------------
	    //  textField
	    //----------------------------------
	
	    /**
	     *  The internal UITextField object that renders the value of the hotext control.
	     * 
	     *  @default null 
	     */
	    protected var textField:HotTextInput;

	    //----------------------------------
	    //  labelField
	    //----------------------------------
	
	    /**
	     *  The internal UITextField object that renders the label of the hotext control.
	     * 
	     *  @default null 
	     */
		protected var labelField:UITextField;
		
		protected var inPlaceEdit:TextInput;
		
		private var currCapture:IMouseCapture = null;
		private var _fontSize:uint;
		private var _textLabel:String;
		private var _valueString:String;
		private var _valueConflict:Boolean = true;
		
		private var _labelColor:Number = 0x000000;
				
		private var _displayUnderline:Boolean = false;
		
		private var _suffix:String="";
		
		private var _maxChars:int = 0;	// for inPlaceEdit
		
		private var _stage:DisplayObject;	// if we get unexpectedly removed from the stage, we still need to find it to 
									// remove stageBubbleClickHandler
		private var labelStyle:String = "ActionLabels";
		private var detailStyle:String = "hotTextStyle";
		
		// for activity event debouncing
		private var _hovering:Boolean = false;	// basically, "mouse over" regardless of focus
		private var _editing:Boolean = false;	// inPlaceEdit active
		private var _suspended:Boolean = false;	// inPlaceEdit suspended
		private var _genericallyFocused:Boolean = false;	// focused by keyboard or after drag; e.g. "blue box showing"
		
		public function HotText()
		{
			super();
		}

		private function mouseUpHandler(e:MouseEvent):void{
			if (currCapture) {
				currCapture.EndTracking(e);
				currCapture = null;
				if (null != EffectiveStage(this)) {
		        	EffectiveStage(this).removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
		       		EffectiveStage(this).removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
		  		}
				if (e.target == textField.internalTextField) { //bug 217661
					CursorManager.setCursor(sHorizResizeCursor);
				}
				else {
					CursorManager.removeAllCursors();
				}
				e.stopPropagation();
			}
		}

		private function mouseDownHandler(e:MouseEvent):void{
			currCapture = ServeMouseCapture();
			if (null == currCapture)
				return;
	
	        EffectiveStage(this).addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
	        EffectiveStage(this).addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
				
			currCapture.BeginTracking(e, true);
		}

		private function mouseMoveHandler(e:MouseEvent):void {
			if (currCapture) {
				currCapture.ContinueTracking(e);
				e.stopPropagation();
			}
		}

		private function clickHandler(e:MouseEvent):void {
			
		}
		
		private function set hovering(value:Boolean) : void {
			_hovering = value;
//			if (value) {
//				addActivity();
//			} else {
//				subtractActivity();
//			}
		}
		
		private function set editing(value:Boolean) : void {
			_editing = value;
			if (value) {
				addActivity();
			} else {
				subtractActivity();
			}
		}
		
		private function set focused(value:Boolean) : void {
			_genericallyFocused = value;
			if (value) {
				addActivity();
			} else {
				subtractActivity();
			}
		}
		
		public function setValueConflict():void
		{
			_valueConflict = true;
			if (textField) {
				textField.text = "---";
	            invalidateSize();
    	        invalidateDisplayList();
			}
		}
		
		public function get valueConflict() : Boolean {
			return _valueConflict;
		}

		private function addActivity() : void
		{
			const degreeOfActivity:int = int(_editing) + /* int(_hovering) + */ int(_genericallyFocused);
			
//			trace(bx.utils.StackTrace("addFocus: degree " + degreeOfActivity + "; editing " + _editing + "; hovering " + _hovering + "; focused " + _genericallyFocused));

			if (degreeOfActivity == 1)	// e.g. we're going 0->1
			{
				dispatchEvent(new HotTextEvent(HotTextEvent.ACTIVE, this));
			}
		}

		private function subtractActivity() : void
		{
			const degreeOfActivity:int = int(_editing) + /* int(_hovering) + */ int(_genericallyFocused);

//			trace(bx.utils.StackTrace("subtractFocus: degree " + degreeOfActivity + "; editing " + _editing + "; hovering " + _hovering + "; focused " + _genericallyFocused));

			if (degreeOfActivity == 0)	// totally done
			{	
				dispatchEvent(new HotTextEvent(HotTextEvent.INACTIVE, this));
			}
		}

		private function rollOverHandler(e:MouseEvent):void {
			if (!e.buttonDown) {
				if (e.target == e.currentTarget) {
					CursorManager.setCursor(sHorizResizeCursor);
					hovering = true;
				}
			}
		}

		private function rollOutHandler(e:MouseEvent):void {
			
			if (null == currCapture && !e.buttonDown && e.target == e.currentTarget) {
				CursorManager.removeAllCursors();
				hovering = false;
			}
		}

		private function focusGainHandler(e:FocusEvent):void {
			focused = true;
		}

		private function focusLossHandler(e:FocusEvent):void {
			focused = false;
		}

		public function set suffix(inSuffix:String):void {
			_suffix = inSuffix;
		}
		
		public function set textLabel(inLabel:String):void {
			_textLabel = inLabel;
			if (labelField) {
			
				labelField.text = inLabel;
	            invalidateSize();
    	        invalidateDisplayList();
			}
		}
	
		public function set displayUnderline(inDisplay:Boolean):void {
			_displayUnderline = inDisplay;
    	    invalidateDisplayList();    			
		}

		public function get textLabel():String {
			return _textLabel;
		}
	
		protected function set valueString(inValStr:String):void {
			_valueConflict = false;
			_valueString = inValStr;
			if (textField) {
				textField.text = _valueString + _suffix;
	            invalidateSize();
    	        invalidateDisplayList();
			}
		}
		
		public function set labelColor(color:Number):void {
			_labelColor = color;
			if (labelField)
				labelField.setColor(_labelColor);
		}
		
		/// Max chars for in-place edit
		public function set maxChars(chars:int):void {
			_maxChars = chars;
		}
		
		public function get maxChars():int {
			return _maxChars;
		}
		
		/** 
		 * Internal functions used for subclass extension
		 * */
		 
		protected function UpdateStringFromValue():void {
			
		}

		protected function SetValueFromText(inString:String):void {
			
		}

		protected function ServeMouseCapture():IMouseCapture {
			return null;
		}

		/**
		 * Flex Overrides
		 * */
	    override protected function createChildren():void
	    {
	        super.createChildren();
	
	        // Create a UITextField to display the label.
	 		if (!labelField) {
	 			labelField = new UITextField;//(createInFontContext(UITextField));
				labelField.styleName = labelStyle;

	 			addChild(labelField);
	 			//labelField.setColor(_labelColor);
	 		}
	 		
	        if (!textField)
	        {
	            textField = new HotTextInput;//UITextField(createInFontContext(UITextField));
	            textField.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
	            textField.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
	            //textField.addEventListener(MouseEvent.CLICK, clickHandler);
	            textField.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	            textField.addEventListener(flash.events.FocusEvent.FOCUS_IN, focusGainHandler);
	            textField.addEventListener(flash.events.FocusEvent.FOCUS_OUT, focusLossHandler);
	            this.styleName = detailStyle;
	            addChild(textField);
	        }
	        
	        if (!inPlaceEdit) 
	        {
	        	inPlaceEdit = new TextInput;//TextInput(createInFontContext(TextInput));
	        	inPlaceEdit.setStyle("color", "#000000");
	        	addChild(inPlaceEdit);
	        	inPlaceEdit.visible = false;
	        }
	    }
	
	    override public function get baselinePosition():Number
	    {
	        if (!myValidateBaselinePosition())
	            return NaN;
	
	        return textField.y + textField.baselinePosition;
	    }
	    
		private function myValidateBaselinePosition():Boolean
	    {
	        // If this component isn't parented,
	        // then it doesn't know its text styles
	        // and we can't compute a baselinePosition.
	        if (!parent)
	            return false;
	            
	        // If this component hasn't been sized yet, assign it
	        // an actual size that's based on its explicit or measured size.
	        if (width == 0 && height == 0)
	        {
	            validateNow();
	            
	            var w:Number = getExplicitOrMeasuredWidth();
	            var h:Number = getExplicitOrMeasuredHeight();
	            
	            setActualSize(w, h);
	        }
	        
	        // Ensure that this component's internal TextFields
	        // are properly laid out, so that we can use
	        // their locations to compute a baselinePosition.
	        validateNow();
	        
	        return true;
	    }	    

		private static const TEXT_HEIGHT_PADDING:int = 4;
		private static const TEXT_WIDTH_PADDING:int = 6;
	    
	    override protected function measure():void
    	{
	   		super.measure();

	        var textWidth:Number = 0;
    	    var textHeight:Number = 0;
			var paddingLeft:Number = getStyle("paddingLeft");
			var paddingRight:Number = getStyle("paddingRight");
			var paddingTop:Number = 4;//getStyle("paddingTop");
			var paddingBottom:Number = getStyle("paddingBottom");
			var horizontalGap:Number = 2;
			//horizontalGap = getStyle("horizontalGap");

			if (textLabel)
		    {
				var lineMetrics:TextLineMetrics = measureText(textLabel);
				textWidth = lineMetrics.width + TEXT_WIDTH_PADDING;
				textHeight = lineMetrics.height + TEXT_HEIGHT_PADDING;
		        
				textWidth += paddingLeft + paddingRight + getStyle("textIndent"); 
				textHeight += paddingTop + paddingBottom;         
				textWidth += (horizontalGap-2);
			}
		    
		    if (_valueString) 
		   	{
				lineMetrics = measureText(_valueString + _suffix);
				textWidth += lineMetrics.width + TEXT_WIDTH_PADDING;
				textHeight += lineMetrics.height + TEXT_HEIGHT_PADDING;
		        
				textWidth += paddingLeft + paddingRight + getStyle("textIndent"); 
				textHeight += paddingTop + paddingBottom;         		   		
		   	}

			measuredMinWidth = measuredWidth = textWidth;
        	measuredMinHeight = measuredHeight = textHeight;
	   	}
	   	 
	    override protected function updateDisplayList(unscaledWidth:Number,
    	                                              unscaledHeight:Number):void
    	{
    		var dispStr:String = _valueConflict ? "---" : _valueString + _suffix;
    		if (textField.text != dispStr) {
 	            textField.text = dispStr;
    		}
    		
    		if (labelField.text != _textLabel) {
 	            labelField.text = _textLabel;
    		}
   
	         layoutContents(unscaledWidth, unscaledHeight,
    	                   /*phase == ButtonPhase.DOWN*/false);
    	     
			if (_displayUnderline) {
	    	    // Draw a dashed underline
	    	    var beginOfLineX:int = textField.x + (0.25 * TEXT_WIDTH_PADDING);
	    	    var endOfLineX:int = textField.x + textField.width - (0.5 * TEXT_WIDTH_PADDING);
	    	    if (beginOfLineX < endOfLineX)
	    	    {
		    	    var lineY:int = textField.y + textField.height - TEXT_HEIGHT_PADDING - 2;
		    	     
					this.graphics.clear();
		    	    
					this.graphics.lineStyle(1, getStyle("color"), 1, true, LineScaleMode.NONE, CapsStyle.NONE);
					for (var currentPoint:int = beginOfLineX; currentPoint <= endOfLineX; currentPoint += 2) {
						this.graphics.moveTo(currentPoint, lineY);
						this.graphics.lineTo(currentPoint, lineY+1);
					}
					this.graphics.lineStyle(1, getStyle("backColor"), 1, true, LineScaleMode.NONE, CapsStyle.NONE);
					this.graphics.moveTo(beginOfLineX-1, lineY+1);
					this.graphics.lineTo(endOfLineX+1, lineY+1);
	    	    }
			}
    	}
    	
    	protected function layoutContents(unscaledWidth:Number,
                                        unscaledHeight:Number,
                                        offset:Boolean):void
        {
			var labelWidth:Number = 0;
			var labelHeight:Number = 0;

			var labelX:Number = 0;
			var labelY:Number = 0;
       
			var textWidth:Number = 0;
			var textHeight:Number = 0;

			var textX:Number = 0;
			var textY:Number = 0;

			var horizontalGap:Number = 0;
			var verticalGap:Number = 2;

			var paddingLeft:Number = getStyle("paddingLeft");
			var paddingRight:Number = getStyle("paddingRight");
			var paddingTop:Number = getStyle("paddingTop");
			var paddingBottom:Number = getStyle("paddingBottom");

        	var lineMetrics:TextLineMetrics;

			if (_textLabel) {
    	        lineMetrics = measureText(_textLabel);
        	    labelWidth = lineMetrics.width + TEXT_WIDTH_PADDING;
            	labelHeight = lineMetrics.height + TEXT_HEIGHT_PADDING;
        	} else {
            	lineMetrics = measureText("Wj");
            	textHeight = lineMetrics.height + TEXT_HEIGHT_PADDING;
        	}

			if (_valueString) {
	   	        lineMetrics = measureText(_valueString + _suffix);
        	    textWidth = lineMetrics.width + TEXT_WIDTH_PADDING;
            	textHeight = lineMetrics.height + TEXT_HEIGHT_PADDING;
			} else {
            	lineMetrics = measureText("Wj");
            	textHeight = lineMetrics.height + TEXT_HEIGHT_PADDING;
        	}

			var viewWidth:Number = unscaledWidth;
			var viewHeight:Number = unscaledHeight;

           // horizontalGap = getStyle("horizontalGap");
			if (textWidth == 0 || labelWidth == 0)
				horizontalGap = 0;
			
           
           	labelField.width = labelWidth;
            labelField.height = labelHeight = Math.min(viewHeight, labelHeight);
            
            if (textWidth > 0)
            {
            	if (unscaledWidth > 0) 
                	textField.width = textWidth = 
                    	Math.max(Math.min(viewWidth - labelWidth - horizontalGap -
                        	              paddingLeft - paddingRight, textWidth), 0);
                else
                	textField.width = textWidth;
            }
            else
            {
                textField.width = labelWidth = 0;
            }
            
			textField.height = labelHeight = Math.min(viewHeight, textHeight);
			labelX += paddingLeft;
			textX = labelX + labelWidth + horizontalGap;
            labelY  = ((viewHeight - labelHeight - paddingTop - paddingBottom) / 2) + paddingTop;
            textY = ((viewHeight - textHeight - paddingTop - paddingBottom) / 2) + paddingTop;

	        textField.x = Math.round(textX);
    	    textField.y = Math.round(textY);

	        labelField.x = Math.round(labelX);
    	    labelField.y = Math.round(labelY);
        }
		
		private function handleInPlaceEditEnd():void {
			if (_editing || _suspended)
			{
				inPlaceEdit.visible = false;
				inPlaceEdit.removeEventListener(mx.events.FlexEvent.ENTER, onNumberChanged);
				inPlaceEdit.removeEventListener(flash.events.FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusOut);
				inPlaceEdit.removeEventListener(flash.events.FocusEvent.FOCUS_OUT, inPlaceFocusLossHandler);
				
				_stage.removeEventListener(MouseEvent.CLICK, stageBubbleClickHandler, true);		
				
				if (!valueConflict || inPlaceEdit.text.length > 0)
					SetValueFromText(inPlaceEdit.text);
				inPlaceEdit.horizontalScrollPosition = 0.0;
				editing = false;
				_suspended = false;
			}
		}
		
		/**
		 * Turns off editing (call from loss of focus), but puts control into a suspended state so that a subsequent
		 * event (from tab or enter key) can still cause it to set the value of the property.
		 */
		private function handleInPlaceEditSuspend():void {
			if (_editing)
			{
				inPlaceEdit.visible = false;
				inPlaceEdit.removeEventListener(mx.events.FlexEvent.ENTER, onNumberChanged);
				inPlaceEdit.removeEventListener(flash.events.FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusOut);
				inPlaceEdit.removeEventListener(flash.events.FocusEvent.FOCUS_OUT, inPlaceFocusLossHandler);
				
				_stage.removeEventListener(MouseEvent.CLICK, stageBubbleClickHandler, true);		
				inPlaceEdit.horizontalScrollPosition = 0.0;
				editing = false;
				_suspended = true;
			}
		}
		
		private function onNumberChanged(evt:mx.events.FlexEvent):void {
			textField.setFocus(); // Return focus to the Mouse Control
			handleInPlaceEditEnd();
		}
		
		private function onKeyFocusOut(evt:flash.events.FocusEvent):void {
			textField.setFocus(); // Return focus to the Mouse Control
			handleInPlaceEditEnd();
		}
		
		
		private function stageBubbleClickHandler(evt:MouseEvent):void {
			if (evt.target == textField.internalTextField)
				return;
			var targetAsUITextField:UITextField = evt.target as UITextField;
			if (targetAsUITextField != null) {
				if (targetAsUITextField.parent == inPlaceEdit)
					return;
			}
			handleInPlaceEditEnd();
		}
		
		private function inPlaceFocusLossHandler(e:FocusEvent):void {
			handleInPlaceEditSuspend();
		}

		public function beginInPlaceEdit():void {
			inPlaceEdit.addEventListener(mx.events.FlexEvent.ENTER, onNumberChanged);
			inPlaceEdit.addEventListener(flash.events.FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusOut);
			inPlaceEdit.addEventListener(flash.events.FocusEvent.FOCUS_OUT, inPlaceFocusLossHandler);
			
			// remember the stage because e.g. due to deselection we can get removed from the stage before we get 
			// notified of it - but we will still need to unhook stageBubbleClickHandler. See bug 214627/215494
			_stage = EffectiveStage(this);
			
			_stage.addEventListener(MouseEvent.CLICK, stageBubbleClickHandler, true);
			
	
			inPlaceEdit.horizontalScrollPosition = 0;
			inPlaceEdit.setSelection(0,0);
			inPlaceEdit.visible = true;
					
			inPlaceEdit.x = textField.x-2;
			inPlaceEdit.y = textField.y-2;
			inPlaceEdit.width = Math.max(textField.width+4, 40);
			inPlaceEdit.height = textField.height+4;
			inPlaceEdit.text = _valueConflict ? "" : _valueString;
			inPlaceEdit.maxChars = _maxChars;
			inPlaceEdit.setFocus();
			inPlaceEdit.setSelection(0, textField.text.length);	
			inPlaceEdit.horizontalScrollPosition = 0;	
			inPlaceEdit.setFocus();
			editing = true;
		}
	}
}

