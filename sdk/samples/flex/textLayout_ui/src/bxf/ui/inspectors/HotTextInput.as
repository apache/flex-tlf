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
package bxf.ui.inspectors
{

import flash.accessibility.AccessibilityProperties;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.system.IME;
import flash.system.IMEConversionMode;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextLineMetrics;

import mx.core.EdgeMetrics;
import mx.core.FlexVersion;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.IIMESupport;
import mx.core.IRectangularBorder;
import mx.core.IUITextField;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerComponent;
import mx.styles.ISimpleStyleClient;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when text in the TextInput control changes
 *  through user input.
 *  This event does not occur if you use data binding or 
 *  ActionScript code to change the text.
 *
 *  <p>Even though the default value of the <code>Event.bubbles</code> property 
 *  is <code>true</code>, this control dispatches the event with 
 *  the <code>Event.bubbles</code> property set to <code>false</code>.</p>
 *
 *  @eventType flash.events.Event.CHANGE
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  Dispatched when the <code>data</code> property changes.
 *
 *  <p>When you use a component as an item renderer,
 *  the <code>data</code> property contains the data to display.
 *  You can listen for this event and update the component
 *  when the <code>data</code> property changes.</p>
 *
 *  @eventType mx.events.FlexEvent.DATA_CHANGE
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]


//--------------------------------------
//  Other metadata
//--------------------------------------

[DataBindingInfo("editEvents", "&quot;focusIn;focusOut&quot;")]

[DefaultBindingProperty(source="text", destination="text")]

[DefaultTriggerEvent("change")]


public class HotTextInput extends UIComponent
                       implements IDataRenderer,
                       IFocusManagerComponent, IIMESupport

{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function HotTextInput()
    {
        super();

        // InteractiveObject variables.
        tabChildren = true;
        height = 10;
    }
    
    public function get enableIME():Boolean
    { return false; }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  The internal subcontrol that draws the border and background.
     */
    mx_internal var border:IFlexDisplayObject;

    /**
     *  @private
     *  Flag that will block default data/listData behavior.
     */
    private var textSet:Boolean;

    /**
     *  @private
     *  If true, pass calls to drawFocus() up to the parent.
     *  This is used when a TextInput is part of a composite control
     *  like NumericStepper or ComboBox;
     */
    mx_internal var parentDrawsFocus:Boolean = false;

    /**
     *  @private
     *  Previous imeMode.
     */
    private var prevMode:String = null;

    /**
     *  @private
     */    
    private var errorCaught:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  accessibilityProperties
    //----------------------------------

    /**
     *  @private
     *  Storage for the accessibilityProperties property.
     */
    private var _accessibilityProperties:AccessibilityProperties;

    /**
     *  @private
     */
    private var accessibilityPropertiesChanged:Boolean = false;

    /**
     *  @private
     *  Storage for the accessibilityProperties property.
     */
    override public function get accessibilityProperties():
                                            AccessibilityProperties
    {
        return _accessibilityProperties;
    }

    /**
     *  @private
     *  Accessibility data.
     *
     *  @tiptext
     *  @helpid 3199
     */
    override public function set accessibilityProperties(
                                        value:AccessibilityProperties):void
    {
        if (value == _accessibilityProperties)
            return;

        _accessibilityProperties = value;
        accessibilityPropertiesChanged = true;

        invalidateProperties();
    }

    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  @private
     *  The baselinePosition of a TextInput is calculated for its textField.
     */
    override public function get baselinePosition():Number
    {
        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0)
        {
            var t:String = text;
            if (t == "")
                t = " ";
    
            return (border && border is IRectangularBorder ?
                    IRectangularBorder(border).borderMetrics.top :
         			0)  + measureText(t).ascent;
        }
        
        if (!validateBaselinePosition())
            return NaN;
        
        return textField.y + textField.baselinePosition;
    }

    //----------------------------------
    //  tabIndex
    //----------------------------------

    /**
     *  @private
     *  Storage for the tabIndex property.
     */
    private var _tabIndex:int = -1;

    /**
     *  @private
     */
    private var tabIndexChanged:Boolean = false;

    /**
     *  @private
     *  Tab order in which the control receives the focus when navigating
     *  with the Tab key.
     *
     *  @default -1
     *  @tiptext tabIndex of the component
     *  @helpid 3198
     */
    override public function get tabIndex():int
    {
        return _tabIndex;
    }

    /**
     *  @private
     */
    override public function set tabIndex(value:int):void
    {
        if (value == _tabIndex)
            return;

        _tabIndex = value;
        tabIndexChanged = true;

        invalidateProperties();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  data
    //----------------------------------

    /**
     *  @private
     *  Storage for the data property.
     */
    private var _data:Object;

    [Bindable("dataChange")]

    /**
     *  Lets you pass a value to the component
     *  when you use it in an item renderer or item editor.
     *  You typically use data binding to bind a field of the <code>data</code>
     *  property to a property of this component.
     *
     *  <p>When you use the control as a drop-in item renderer or drop-in
     *  item editor, Flex automatically writes the current value of the item
     *  to the <code>text</code> property of this control.</p>
     *
     *  <p>You do not set this property in MXML.</p>
     *
     *  @default null
     *  @see mx.core.IDataRenderer
     */
    public function get data():Object
    {
        return _data;
    }

    /**
     *  @private
     */
    public function set data(value:Object):void
    {
        var newText:*;

        _data = value;

        if (_data != null)
        {
            if (_data is String)
                newText = String(_data);
            else
                newText = _data.toString();
        }

        if (newText !== undefined && !textSet)
        {
            text = newText;
            textSet = false;
        }

        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
    }

    //----------------------------------
    //  editable
    //----------------------------------

    /**
     *  @private
     *  Storage for the editable property.
     */
    private var _editable:Boolean = false;

    /**
     *  Indicates whether the user is allowed to edit the text in this control.
     *  If <code>true</code>, the user can edit the text.
     *
     *  @default true
     * 
     *  @tiptext Specifies whether the component is editable or not
     *  @helpid 3196
     */
    public function get editable():Boolean
    {
        return _editable;
    }

    //----------------------------------
    //  imeMode
    //----------------------------------

    /**
     *  @private
     */
    private var _imeMode:String = null;

    /**
     *  Specifies the IME (input method editor) mode.
     *  The IME enables users to enter text in Chinese, Japanese, and Korean.
     *  Flex sets the specified IME mode when the control gets the focus,
     *  and sets it back to the previous value when the control loses the focus.
     *
     *  <p>The flash.system.IMEConversionMode class defines constants for the
     *  valid values for this property.
     *  You can also specify <code>null</code> to specify no IME.</p>
     *
     *  @default null
     * 
     *  @see flash.system.IMEConversionMode
     */
    public function get imeMode():String
    {
        return _imeMode;
    }

    /**
     *  @private
     */
    public function set imeMode(value:String):void
    {
        _imeMode = value;
        // We don't call IME.conversionMode here. We call it
        // only on focusIn. Thus fringe cases like setting
        // imeMode dynamically without moving focus, through
        // keyboard events, wouldn't change the mode. Also
        // getting imeMode asynch. from the server which gets
        // delayed and set later after focusIn is not handled
        // as having the text partly in one script and partly
        // in another is not desirable.
    }

    //----------------------------------
    //  length
    //----------------------------------

    /**
     *  The number of characters of text displayed in the TextArea.
     *
     *  @default 0
     *  @tiptext The number of characters in the TextInput.
     *  @helpid 3192
     */
    public function get length():int
    {
        return text != null ? text.length : -1;
    }

    //----------------------------------
    //  maxChars
    //----------------------------------

    /**
     *  @private
     *  Storage for the maxChars property.
     */
    private var _maxChars:int = 0;

    /**
     *  @private
     */
    private var maxCharsChanged:Boolean = false;

    [Bindable("maxCharsChanged")]

    /**
     *  Maximum number of characters that users can enter in the text field.
     *  This property does not limit the length of text specified by the
     *  setting the control's <code>text</code> or <code>htmlText</code> property.
     * 
     *  <p>The default value is 0, which is a special case
     *  meaning an unlimited number.</p>
     *
     *  @tiptext The maximum number of characters
     *  that the TextInput can contain
     *  @helpid 3191
     */
    public function get maxChars():int
    {
        return _maxChars;
    }

    /**
     *  @private
     */
    public function set maxChars(value:int):void
    {
        if (value == _maxChars)
            return;

        _maxChars = value;
        maxCharsChanged = true;

        invalidateProperties();

        dispatchEvent(new Event("maxCharsChanged"));
    }

    //----------------------------------
    //  maxHorizontalScrollPosition
    //----------------------------------

    /**
     *  @private 
     *  Maximum value of <code>horizontalScrollPosition</code>.
     * 
     *  <p>The default value is 0, which means that horizontal scrolling is not 
     *  required.</p>
     *
     *  <p>The value of the <code>maxHorizontalScrollPosition</code> property is
     *  computed from the data and size of component, and must not be set by
     *  the application code.</p>
     */
    public function get maxHorizontalScrollPosition():Number
    {
        return textField ? textField.maxScrollH : 0;
    }

    //----------------------------------
    //  restrict
    //----------------------------------

    /**
     *  @private
     *  Storage for the restrict property.
     */
    private var _restrict:String;

    /**
     *  @private
     */
    private var restrictChanged:Boolean = false;

    [Bindable("restrictChanged")]

    /**
     *  Indicates the set of characters that a user can enter into the control. 
     *  If the value of the <code>restrict</code> property is <code>null</code>, 
     *  you can enter any character. If the value of the <code>restrict</code> 
     *  property is an empty string, you cannot enter any character.
     *  This property only restricts user interaction; a script
     *  can put any text into the text field. If the value of
     *  the <code>restrict</code> property is a string of characters,
     *  you may enter only characters in that string into the
     *  text field.
     *
     *  <p>Flex scans the string from left to right. You can specify a range by 
     *  using the hyphen (-) character.
     *  If the string begins with a caret (^) character, all characters are 
     *  initially accepted and succeeding characters in the string are excluded 
     *  from the set of accepted characters. If the string does not begin with a 
     *  caret (^) character, no characters are initially accepted and succeeding 
     *  characters in the string are included in the set of accepted characters.</p>
     * 
     *  <p>Because some characters have a special meaning when used
     *  in the <code>restrict</code> property, you must use
     *  backslash characters to specify the literal characters -, &#094;, and \.
     *  When you use the <code>restrict</code> property as an attribute
     *  in an MXML tag, use single backslashes, as in the following 
     *  example: \&#094;\-\\.
     *  When you set the <code>restrict</code> In and ActionScript expression,
     *  use double backslashes, as in the following example: \\&#094;\\-\\\.</p>
     *
     *  @default null
     *  @see flash.text.TextField#restrict
     *  @tiptext The set of characters that may be entered
     *  into the TextInput.
     *  @helpid 3193
     */
    public function get restrict():String
    {
        return _restrict;
    }

    /**
     *  @private
     */
    public function set restrict(value:String):void
    {
        if (value == _restrict)
            return;
        
        _restrict = value;
        restrictChanged = true;

        invalidateProperties();

        dispatchEvent(new Event("restrictChanged"));
    }

    //----------------------------------
    //  selectable
    //----------------------------------    

    /**
     *  @private
     *  Used to make TextInput function correctly in the components that use it
     *  as a subcomponent. ComboBox, at this point. 
     */
    private var _selectable:Boolean = true;
    
    /**
     *  @private
     */
    private var selectableChanged:Boolean = false;
    
    /**
     *  @private
     */ 
    mx_internal function get selectable():Boolean
    {
        return _selectable;
    }
    
    /**
     *  @private
     */
    mx_internal function set selectable(value:Boolean):void
    {
        if (_selectable == value)
            return;
        _selectable = value;
        selectableChanged = true;
        invalidateProperties();
    }

    //----------------------------------
    //  text
    //----------------------------------

    /**
     *  @private
     *  Storage for the text property.
     *  In addition to being set in the 'text' setter,
     *  it is automatically updated at another time:
     *  When the 'text' or 'htmlText' is pushed down into
     *  the textField in commitProperties(), this causes
     *  the textField to update its own 'text'.
     *  Therefore in commitProperties() we reset this storage var
     *  to be in sync with the textField.
     */
    private var _text:String = "";

    /**
     *  @private
     */
    private var textChanged:Boolean = false;

    [Bindable("textChanged")]
    [NonCommittingChangeEvent("change")]

    /**
     *  Plain text that appears in the control.
     *  Its appearance is determined by the CSS styles of this Label control.
     *  
     *  <p>Any HTML tags in the text string are ignored,
     *  and appear as entered in the string. 
     *  To display text formatted using HTML tags,
     *  use the <code>htmlText</code> property instead.
     *  If you set the <code>htmlText</code> property,
     *  the HTML replaces any text you had set using this propety, and the
     *  <code>text</code> property returns a plain-text version of the
     *  HTML text, with all HTML tags stripped out. For more information
     *  see the <code>htmlText</code> property.</p>
     *
     *  <p>To include the special characters left angle  bracket (&lt;),
     *  right angle bracket (&gt;), or ampersand (&amp;) in the text,
     *  wrap the text string in the CDATA tag.
     *  Alternatively, you can use HTML character entities for the
     *  special characters, for example, <code>&amp;lt;</code>.</p>
     *
     *  <p>If you try to set this property to <code>null</code>,
     *  it is set, instead, to the empty string.
     *  The <code>text</code> property can temporarily have the value <code>null</code>,
     *  which indicates that the <code>htmlText</code> has been recently set
     *  and the corresponding <code>text</code> value
     *  has not yet been determined.</p>
     *
     *  @default ""
     *  @tiptext Gets or sets the TextInput content
     *  @helpid 3190
     */
    public function get text():String
    {
        return _text;
    }

    /**
     *  @private
     */
    public function set text(value:String):void
    {
        textSet = true;

        // The text property can't be set to null, only to the empty string.
        // If the getter returns null, it means that 'htmlText' was just set
        // and the value of 'text' isn't yet known, because the 'htmlText'
        // hasn't been committed into the textField and the 'text'
        // hasn't yet been read back out of the textField.
        if (!value)
            value = "";

        if (value == _text)
            return;
        
        _text = value;
        textChanged = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();

        // Trigger bindings to 'text'.
        dispatchEvent(new Event("textChanged"));

        // commitProperties() will dispatch an "htmlTextChanged" event
        // after the TextField determines the 'htmlText' based on the
        // 'text'; this event will trigger any bindings to 'htmlText'.

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }

    //----------------------------------
    //  textField
    //----------------------------------

    /**
     *  The internal UITextField that renders the text of this TextInput.
     */
    protected var textField:IUITextField;

	public function get internalTextField():UITextField {
		return textField as UITextField;
	}
    //----------------------------------
    //  textHeight
    //----------------------------------

    /**
     *  @private
     */
    private var _textHeight:Number;
    
    /**
     *  The height of the text.
     *
     *  <p>The value of the <code>textHeight</code> property is correct only
     *  after the component has been validated.
     *  If you set <code>text</code> and then immediately ask for the
     *  <code>textHeight</code>, you might receive an incorrect value.
     *  You should wait for the component to validate
     *  or call the <code>validateNow()</code> method before you get the value.
     *  This behavior differs from that of the flash.text.TextField control,
     *  which updates the value immediately.</p>
     *
     *  @see flash.text.TextField
     */
    public function get textHeight():Number
    {
        return _textHeight;
    }

    //----------------------------------
    //  textWidth
    //----------------------------------

    /**
     *  @private
     */
    private var _textWidth:Number;
    
    /**
     *  The width of the text.
     *
     *  <p>The value of the <code>textWidth</code> property is correct only
     *  after the component has been validated.
     *  If you set <code>text</code> and then immediately ask for the
     *  <code>textWidth</code>, you might receive an incorrect value.
     *  You should wait for the component to validate
     *  or call the <code>validateNow()</code> method before you get the value.
     *  This behavior differs from that of the flash.text.TextField control,
     *  which updates the value immediately.</p>
     *
     *  @see flash.text.TextField
     */
    public function get textWidth():Number
    {
        return _textWidth;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Create child objects.
     */
    override protected function createChildren():void
    {
        super.createChildren();

        //createBorder();

        createTextField(-1);
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();


        if (hasFontContextChanged() && textField != null)
        {
            var childIndex:int = getChildIndex(DisplayObject(textField));
            removeTextField();
            createTextField(childIndex);
            
            accessibilityPropertiesChanged = true;
            maxCharsChanged = true;
            restrictChanged = true;
            tabIndexChanged = true;
            textChanged = true;
        }
        
        if (accessibilityPropertiesChanged)
        {
            textField.accessibilityProperties = _accessibilityProperties;

            accessibilityPropertiesChanged = false;
        }
        
        if (maxCharsChanged)
        {
            textField.maxChars = _maxChars;

            maxCharsChanged = false;
        }

        if (restrictChanged)
        {
            textField.restrict = _restrict;

            restrictChanged = false;
        }

        if (tabIndexChanged)
        {
            textField.tabIndex = _tabIndex;

            tabIndexChanged = false;
        }

        if (textChanged)
        {
            // If the 'text' and 'htmlText' properties have both changed,
            // the last one set wins.
            textField.text = _text;
            
            textFieldChanged(false, true);
            
            textChanged = false;
        }

    }

    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();

  		var bm:EdgeMetrics = border && border is IRectangularBorder ?
                             IRectangularBorder(border).borderMetrics :
                             EdgeMetrics.EMPTY;

        var w:Number;
        var h:Number;

        // Start with a width of 160. This may change.
        measuredWidth = DEFAULT_MEASURED_WIDTH;
        
        if (maxChars)
        {
            // Use the width of "W" and multiply by the maxChars
            measuredWidth = Math.min(measuredWidth,
                measureText("W").width * maxChars + bm.left + bm.right + 8);
        }
        
        if (!text || text == "")
        {
            w = DEFAULT_MEASURED_MIN_WIDTH;
            h = measureText(" ").height +
                bm.top + bm.bottom + UITextField.TEXT_HEIGHT_PADDING;
            if (FlexVersion.compatibilityVersion >= FlexVersion.VERSION_3_0)  
                h += getStyle("paddingTop") + getStyle("paddingBottom");
        }
        else
        {
            var lineMetrics:TextLineMetrics;
            lineMetrics = measureText(text);

            w = lineMetrics.width + bm.left + bm.right + 8; 
            h = lineMetrics.height + bm.top + bm.bottom + UITextField.TEXT_HEIGHT_PADDING; 
                            
            if (FlexVersion.compatibilityVersion >= FlexVersion.VERSION_3_0)
            {
                w += getStyle("paddingLeft") + getStyle("paddingRight");
                h += getStyle("paddingTop") + getStyle("paddingBottom");
            }
        }

        measuredWidth = Math.max(w, measuredWidth);
        measuredHeight = Math.max(h, DEFAULT_MEASURED_HEIGHT);
        
        measuredMinWidth = DEFAULT_MEASURED_MIN_WIDTH;
        measuredMinHeight = DEFAULT_MEASURED_MIN_HEIGHT;
    }

    /**
     *  @private
     *  Stretch the border and fit the TextField inside it.
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        var bm:EdgeMetrics;

        if (border)
        {
            border.setActualSize(unscaledWidth, unscaledHeight);
            bm = border is IRectangularBorder ?
                    IRectangularBorder(border).borderMetrics : EdgeMetrics.EMPTY;
        }
        else
        {
            bm = EdgeMetrics.EMPTY;
        }
        
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        var widthPad:Number = bm.left + bm.right;
        var heightPad:Number = bm.top + bm.bottom + 1;
        
        textField.x = bm.left;
        textField.y = bm.top;

        if (FlexVersion.compatibilityVersion >= FlexVersion.VERSION_3_0)
        {
            textField.x += paddingLeft;
            textField.y += paddingTop;
            widthPad += paddingLeft + paddingRight; 
            heightPad += paddingTop + paddingBottom;
        }
        
        textField.width = Math.max(0, unscaledWidth - widthPad);
        textField.height = Math.max(0, unscaledHeight - heightPad);
    }


    /**
     *  @private
     *  Focus should always be on the internal TextField.
     */
    override public function setFocus():void
    {
        textField.setFocus();
    }

    /**
     *  @private
     */
    override protected function isOurFocus(target:DisplayObject):Boolean
    {
        return target == textField || super.isOurFocus(target);
    }

    /**
     *  @private
     *  Forward the drawFocus to the parent, if requested
     */
    override public function drawFocus(isFocused:Boolean):void
    {
        if (parentDrawsFocus)
        {
            IFocusManagerComponent(parent).drawFocus(isFocused);
            return;
        }

        super.drawFocus(isFocused);
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        var allStyles:Boolean = (styleProp == null || styleProp == "styleName");

        super.styleChanged(styleProp);
        
        // Replace the borderSkin
        if (allStyles || styleProp == "borderSkin")
        {
            if (border)
            {
                removeChild(DisplayObject(border));
                border = null;
                createBorder();
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Creates the text field child and adds it as a child of this component.
     * 
     *  @param childIndex The index of where to add the child.
     *  If -1, the text field is appended to the end of the list.
     */
    mx_internal function createTextField(childIndex:int):void
    {
        if (!textField)
        {
            textField = IUITextField(createInFontContext(UITextField));

            textField.autoSize = TextFieldAutoSize.NONE;
            textField.enabled = enabled;
            textField.ignorePadding = false;
            textField.multiline = false;
            textField.tabEnabled = true;
            textField.wordWrap = false;
            if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0)
                textField.styleName = this;

            textField.addEventListener(Event.CHANGE, textField_changeHandler);
            textField.addEventListener("textFieldStyleChange",
                                       textField_textFieldStyleChangeHandler);
            textField.addEventListener("textFormatChange",
                                       textField_textFormatChangeHandler);
            textField.addEventListener("textInsert",
                                       textField_textModifiedHandler);                                       
            textField.addEventListener("textReplace",
                                       textField_textModifiedHandler);                                       

            if (childIndex == -1)
                addChild(DisplayObject(textField));
            else
                addChildAt(DisplayObject(textField), childIndex);
        }
    }

    /**
     *  @private
     *  Removes the text field from this component.
     */
    mx_internal function removeTextField():void
    {
        if (textField)
        {
            textField.removeEventListener(Event.CHANGE, textField_changeHandler);
            textField.removeEventListener("textFieldStyleChange",
                                          textField_textFieldStyleChangeHandler);
            textField.removeEventListener("textFormatChange",
                                          textField_textFormatChangeHandler);
            textField.removeEventListener("textInsert",
                                          textField_textModifiedHandler);                                       
            textField.removeEventListener("textReplace",
                                          textField_textModifiedHandler);                                       

            removeChild(DisplayObject(textField));
            textField = null;
        }
    }
    
    /**
     *  Creates the border for this component.
     *  Normally the border is determined by the
     *  <code>borderStyle</code> and <code>borderSkin</code> styles.  
     *  It must set the border property to the instance
     *  of the border.
     */
    protected function createBorder():void
    {
        if (!border)
        {
            var borderClass:Class = getStyle("borderSkin");

            if (borderClass != null)
            {
                border = new borderClass();
    
                if (border is ISimpleStyleClient)
                    ISimpleStyleClient(border).styleName = this;
    
                // Add the border behind all the children.
                addChildAt(DisplayObject(border), 0);
    
                invalidateDisplayList();
            }
        }
    }

    /**
     *  Returns a TextLineMetrics object with information about the text 
     *  position and measurements for a line of text in the control.
     *  The component must be validated to get a correct number.
     *  If you set the <code>text</code> or <code>htmlText</code> property
     *  and then immediately call
     *  <code>getLineMetrics()</code> you may receive an incorrect value.
     *  You should either wait for the component to validate
     *  or call <code>validateNow()</code>.
     *  This is behavior differs from that of the flash.text.TextField class,
     *  which updates the value immediately.
     * 
     *  @param lineIndex The zero-based index of the line for which to get the metrics. 
     *
     *  @see flash.text.TextField
     *  @see flash.text.TextLineMetrics
     */
    public function getLineMetrics(lineIndex:int):TextLineMetrics
    {
        return textField ? textField.getLineMetrics(lineIndex) : null;
    }

    /**
     *  @private
     *  Setting the 'htmlText' of textField changes its 'text',
     *  and vice versa, so afterwards doing so we call this method
     *  to update the storage vars for various properties.
     *  Afterwards, the TextInput's 'text', 'htmlText', 'textWidth',
     *  and 'textHeight' are all in sync with each other
     *  and are identical to the TextField's.
     */
    private function textFieldChanged(styleChangeOnly:Boolean,
                                      dispatchValueCommitEvent:Boolean):void
    {
        var changed1:Boolean;

        if (!styleChangeOnly)
        {
            changed1 = _text != textField.text;
            _text = textField.text;
        }
        
        // If the 'text' property changes, trigger bindings to it
        // and conditionally dispatch a 'valueCommit' event.
        if (changed1)
        {
            dispatchEvent(new Event("textChanged"));
            
            if (dispatchValueCommitEvent)
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        }

        _textWidth = textField.textWidth;
        _textHeight = textField.textHeight;
    }

    /**
     *  @private
     *  Some other components which use a TextInput as an internal
     *  subcomponent need access to its UITextField, but can't access the
     *  textField var because it is protected and therefore available
     *  only to subclasses.
     */
    mx_internal function getTextField():IUITextField
    {
        return textField;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Gets called by internal field so we draw a focus rect around us.
     */
    override protected function focusInHandler(event:FocusEvent):void
    {
        if (event.target == this)
            systemManager.stage.focus = TextField(textField);

        var fm:IFocusManager = focusManager;

        if (fm)
        {
            fm.showFocusIndicator = true;
        }

        super.focusInHandler(event);
            
        if (_imeMode != null)
        {
            IME.enabled = true;
            prevMode = IME.conversionMode;
            // When IME.conversionMode is unknown it cannot be
            // set to anything other than unknown(English)
            try
            {
                if (!errorCaught &&
                    IME.conversionMode != IMEConversionMode.UNKNOWN)
                {
                    IME.conversionMode = _imeMode;
                }
                errorCaught = false;
            }
            catch(e:Error)
            {
                // Once an error is thrown, focusIn is called 
                // again after the Alert is closed, throw error 
                // only the first time.
                errorCaught = true;
                var message:String = resourceManager.getString(
                    "controls", "unsupportedMode", [ _imeMode ]);
                throw new Error(message);
            }
        }
    }

    /**
     *  @private
     *  Gets called by internal field so we remove focus rect.
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
        super.focusOutHandler(event);

        if (_imeMode != null)
        {
            // When IME.conversionMode is unknown it cannot be
            // set to anything other than unknown(English)
            // and when known it cannot be set to unknown
            if (IME.conversionMode != IMEConversionMode.UNKNOWN 
                && prevMode != IMEConversionMode.UNKNOWN)
                IME.conversionMode = prevMode;
            IME.enabled = false;
        }

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function textField_changeHandler(event:Event):void
    {
        textFieldChanged(false, false);

        // Kill any programmatic change we might be looking at.
        textChanged = false;

        // Stop propagation of the original event
        // and dispatch a new one that doesn't bubble.
        event.stopImmediatePropagation();
        dispatchEvent(new Event(Event.CHANGE));
    }

    /**
     *  @private
     */
    private function textField_textFieldStyleChangeHandler(event:Event):void
    {
        textFieldChanged(true, false);
    }

    /**
     *  @private
     */
    private function textField_textFormatChangeHandler(event:Event):void
    {
        textFieldChanged(true, false);
    }
    
    /**
     *  @private
     */
    private function textField_textModifiedHandler(event:Event):void
    {
        textFieldChanged(false, true);
    }
}

}
