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
package bxf.ui.inspectors {
	import bxf.ui.utils.LocalString;
	
	import flash.events.Event;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.controls.Spacer;
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;
	import mx.utils.ObjectProxy;
	

	public class DynamicPropertyEditorBase extends VBox implements IPropertiesEditor{
		
		public static const pxSuffix:String = LocalString("$$$/stage/PropertyEditor/PxSuffix/=px");
		public static const percentSuffix:String = LocalString("$$$/stage/PropertyEditor/percentSuffix/=%");
		public static const secondsSuffix:String = LocalString("$$$/stage/PropertyEditor/secondsSuffix/=s");
		
		private var mProps:ObjectProxy = new ObjectProxy(new Object());
				
		private const tmpWid:int = 190;		
		private var mNeedToUpdateWidths:Boolean = false;

		private var mEditorLayout:XML;
		protected var mIcons:Object = new Object();

		private var mPropertyEditors:Object = null;	// associative array;  created once and held onto

		public static const MODELEDITED_EVENT:String = "modelEdited";
		public static const MODELCHANGED_EVENT:String = "modelChanged";
		public static const PROPERTY_ACTIVE_EVENT:String = "propActive";
		public static const PROPERTY_INACTIVE_EVENT:String = "propInactive";

		private var mLayoutItems:Array = [];
		
		[Bindable]
		private var mMaxLabelWidth:int = 0;
		
		public function DynamicPropertyEditorBase(inLayout:XML):void {
			mEditorLayout = inLayout;
			properties.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
			setStyle("verticalGap", 3);
			setStyle("top", 6);
			setStyle("left", 10);
		}
		
		public function reset():void
		{
			mProps.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
			mProps = new ObjectProxy(new Object());
			mProps.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
		}
		
		public function get properties():Object {
			return mProps;	
		}
		
		public function SetIcon(inKey:String, inIcon:Class):void
		{
			mIcons[inKey] = inIcon;
		}
		
		public function hasEditorForProperty(inPropertyName:String):Boolean
		{
			if (mPropertyEditors)
			{
				return mPropertyEditors[inPropertyName] != null;
			}
			return false;
		}
		
		// These props are common to both regular and flash components. Each also overrides this to add more	
		protected function doGetPropertyEditor(editorEntry:XML):IPropertyEditor {
			var editor:IPropertyEditor = null;

			if (editorEntry != null){
				var editorType:String = editorEntry.@type;

				var labelZString:String = editorEntry.@label;
				var localizedLabel:String = (labelZString != null) ? LocalString(labelZString) : "";

				var primaryPropName:String = editorEntry.property[0].@name;
				var tipZString:String = editorEntry.@tooltip;
				var tipString:String = (tipZString != null) ? LocalString(tipZString) : "";
				
				var sectionSpacerStr:String = editorEntry.@sectionSpacer;
				var sectionSpacer:Boolean = sectionSpacerStr != null && sectionSpacerStr == "yes"; 

				var editorStyle:String = (editorEntry.@style != null) ? editorEntry.@style : "";

				switch (editorType) {
					
				case "hotnumber":
					var minStr:String = editorEntry.property[0].@minValue;
					var minValue:Number = (minStr != null && minStr.length > 0) ? Number(minStr) : Number.NaN;
					var maxStr:String = editorEntry.property[0].@maxValue;
					var maxValue:Number = (maxStr != null && maxStr.length > 0) ? Number(maxStr) : Number.NaN;

					var decStr:String = editorEntry.@decimals;
					var decimals:uint = (decStr != null && decStr.length > 0) ? uint(decStr) : 0;
					var maxCharStr:String = editorEntry.@maxChars;
					var maxChars:int = (maxCharStr != null && maxCharStr.length > 0) ? int(maxCharStr) : 0;
					var enforceStr:String = editorEntry.@enforcePrecision;
					var enforcePrecision:Boolean = enforceStr != null && enforceStr == "yes";
					var incrStr:String = editorEntry.@increment;
					var increment:Number = (incrStr != null && incrStr.length > 0) ? Number(incrStr) : 1;
					var suffix:String = (editorEntry.@suffix != null) ? editorEntry.@suffix : "";
					var convertToPercentStr:String = editorEntry.property[0].@convertToPercent;
					var convertToPercent:Boolean = convertToPercentStr != null && convertToPercentStr == "yes"; 

					editor = new HotNumericPropertyEditor(localizedLabel, primaryPropName, suffix, minValue, maxValue, convertToPercent, decimals, increment, enforcePrecision, maxChars);
					break;
				
				case "hotnumberunit":
					editor = new HotNumericWithUnitsEditor(localizedLabel, primaryPropName, editorEntry);
					break;
					
				case "color":
					editor = new ColorPropertyEditor(localizedLabel, primaryPropName);
					break;
					
				case "checkbox":
					if (editorEntry.@labelSide == "left" || editorEntry.@trickMode == "hangingIndent") {
						var sectionLabelZStr:String = editorEntry.@sectionLabel;
						var sectionLabel:String = (sectionLabelZStr != null)? LocalString(sectionLabelZStr) : ""; 
						editor = new CheckboxPropertyEditor(localizedLabel, primaryPropName, editorEntry.@trickMode == "hangingIndent", sectionLabel);
					} else {
						editor = new SimpleCheckboxPropertyEditor(localizedLabel, primaryPropName);
					}
					break;
					
				case "string":
					var stringWidth:String = editorEntry.@width;
					if (stringWidth != null)
						editor = new StringPropertyEditor(localizedLabel, primaryPropName, Number(stringWidth));
					else
						editor = new StringPropertyEditor(localizedLabel, primaryPropName);
					break;

				case "stringButton":
					var cmdString:String = editorEntry.@cmd;
					var cmdVal:Number = (cmdString != null && cmdString.length > 0) ? Number(cmdString) : 0;
					editor = new StringButtonPropertyEditor(localizedLabel, primaryPropName, cmdVal, tipString);
					break;
				case "pictureButton":
					var pixCmdString:String = editorEntry.@cmd;
					var pixCmdVal:Number = (pixCmdString != null && pixCmdString.length > 0) ? Number(pixCmdString) : 0;
					editor = new PictureButtonPropertyEditor(pixCmdVal, editorStyle, tipString);
					break;

				case "combo":
					var displayValues:Array = new Array();
					var map:Object = new Object();
					for each (var choice:XML in editorEntry.choice) {
						var userString:String = choice.@display;
						var valueString:String = choice.@value;
						displayValues.push(userString);
						if (valueString.length > 0)
							map[userString] = valueString;
					}

					editor = new ComboBoxPropertyEditor(localizedLabel, primaryPropName, displayValues, map);
					break;

				case "toggleButton":
					var iconClassStr:String = editorEntry.@iconClass;
					var iconClass:Class = iconClassStr ? mIcons[iconClassStr] : null;
					var falseStr:String = editorEntry.property[0].@falseValue;
					var trueStr:String = editorEntry.property[0].@trueValue;
					var buttonWidth:Number = editorEntry.@width;
					var commitStr:String = editorEntry.property[0].@commit;
					var commit:Boolean = commitStr != null && commitStr == "yes"; 
					editor = new ToggleButtonPropertyEditor(localizedLabel, iconClass, primaryPropName, falseStr, trueStr, commit, editorStyle, buttonWidth);
					break;
				
				case "multiIconButton":
					var icons:Array = [];
					var values:Array = [];
					for each (var button:XML in editorEntry.button) {
						icons.push(mIcons[button.@icon]);
						values.push(button.@value);
					}
					editor = new MultiIconButtonSelector(localizedLabel, primaryPropName, icons, values, editorStyle);
					break;
					
				case "fontPicker":
					editor = new FontPropertyEditor(localizedLabel, primaryPropName);
					break;
				}
				
				if (editor && sectionSpacer == true && (editor is IHUDLayoutElement)) {
					(editor as IHUDLayoutElement).sectionSpacer = sectionSpacer;
				}
			}
			
			return editor;	
		}
		
		private function updateAvailablePropertyEditors():void {
			// really, it's "init", but maybe one day it will be "update"
			if (mPropertyEditors == null) {
				mPropertyEditors = new Object();
				
				for each (var editorEntry:XML in mEditorLayout.row.editor) {

					var editor:IPropertyEditor = doGetPropertyEditor(editorEntry);
					for each (var propEntry:XML in editorEntry.property) {
						var propName:String = propEntry.@name;
						mPropertyEditors[propName] = editor;
					}
				
					if (editor != null) {
						editor.addEventListener(PropertyEditEvent.VALUE_EDITED, handleEditingChange, false, 0.0, true);
						editor.addEventListener(PropertyEditEvent.VALUE_CHANGED, handlePropChanged, false, 0.0, true);	
						editor.addEventListener(PropertyEditEvent.VALUE_ACTIVE, handlePropActive, false, 0.0, true);	
						editor.addEventListener(PropertyEditEvent.VALUE_INACTIVE, handlePropInactive, false, 0.0, true);	
					}
				}
			}
		}
				
		private function onPropertyChange(evt:PropertyChangeEvent):void {
			updateAvailablePropertyEditors();

			var asIPE:IPropertyEditor = mPropertyEditors[evt.property];
			if (null != asIPE) {
				if (evt.newValue is Array)
				{
					var strArray:Array = [];
					for each (var i:* in evt.newValue)
						strArray.push(String(i));
					asIPE.setMultiValue(strArray, String(evt.property));
				}
				else
					asIPE.setValueAsString(String(evt.newValue), String(evt.property));
			}

		}
		
		// enables live update
		protected function handleEditingChange(editEvt:PropertyEditEvent):void {
			var propId:String = String(editEvt.property);
			var propVal:String = String(editEvt.newValue);
			
			// is reusing mx.events.PropertyChangeEvent clever or dumb? Don't know yet.
			var evt:PropertyChangeEvent = new PropertyChangeEvent(MODELEDITED_EVENT, false, false, null, propId, properties[propId], propVal);
			properties[propId] = propVal;
			dispatchEvent(evt); 
		}
		
		protected function handlePropChanged(editEvt:PropertyEditEvent):void {
			var propId:String = String(editEvt.property);
			var propVal:String = String(editEvt.newValue);
			
			// is reusing mx.events.PropertyChangeEvent clever or dumb? Don't know yet.
			var evt:PropertyChangeEvent = new PropertyChangeEvent(MODELCHANGED_EVENT, false, false, null, propId, properties[propId], propVal);
			properties[propId] = propVal;
			dispatchEvent(evt); 
		}

		protected function handlePropActive(editEvt:PropertyEditEvent):void {
			var propId:String = String(editEvt.property);
			
			// is reusing mx.events.PropertyChangeEvent clever or dumb? Probably dumb here. FIXME
			var evt:PropertyChangeEvent = new PropertyChangeEvent(PROPERTY_ACTIVE_EVENT, false, false, null, propId, null,null);
			dispatchEvent(evt); 
		}

		protected function handlePropInactive(editEvt:PropertyEditEvent):void {
			var propId:String = String(editEvt.property);
			
			// is reusing mx.events.PropertyChangeEvent clever or dumb? Probably dumb here. FIXME
			var evt:PropertyChangeEvent = new PropertyChangeEvent(PROPERTY_INACTIVE_EVENT, false, false, null, propId, null,null);
			dispatchEvent(evt); 
		}

		public function rebuildUI():void {
			/*
			 * re-layout properties based on what we have now
			 */

			// Remove any existing children
			for (var i:uint = numChildren; --i >= 0; ) {
				removeChildAt(i);
			}
			updateAvailablePropertyEditors();

			mLayoutItems=[];
			/*
			 * For now, we go with the known properties only, keep track of what we've handled and then (do what with?) properties
	 		 * the object has that we don't know how to handle. [note: at this instant the "keep track..."
	 		 * part is untrue. But it was my intent....
	 		 */
			for each (var row:XML in mEditorLayout.row) {
				var currRowBox:HBox = null;
				var rowLabel:Label = null;
		 		var colNum:int = 0;
		 		var styleStr:String = row.@style;
		 		var labelStr:String = row.@label;
		 		if (labelStr.length)
		 			labelStr = LocalString(labelStr);
		 		var test:XMLList = row.editor;
		 		if (labelStr.length && row.editor[0] == null)
		 		{
		 			rowLabel = new Label();
		 			rowLabel.text = labelStr;
		 			addChild(rowLabel);
		 		}
				
				for each (var editorEntry:XML in row.editor) {
					var usesEditor:Boolean = false;
//					usesEditor = mProps[editorEntry.property[0].@name != null;
					for each (var affectedProperty:String in editorEntry.property.@name) {
						if (mProps[affectedProperty] != null) {
							usesEditor = true;
							break;
						}
					}
					
					if (usesEditor) {
						// The selected object has this property.	
						var propName:String = editorEntry.property[0].@name;	// HACK
						var propEditor:UIComponent = mPropertyEditors[propName];
						if (propEditor != null) {
							
							if (null == currRowBox) {
						 		if (labelStr.length)
						 		{
						 			rowLabel = new Label();
						 			rowLabel.text = labelStr;
						 			addChild(rowLabel);
						 		}
								currRowBox = new HBox;
								addChild(currRowBox);	
								if (styleStr.length)
									currRowBox.styleName = styleStr;		
								currRowBox.setStyle("verticalAlign", "middle");
							}
							
							currRowBox.addChild(propEditor);
							
							var asHUDLayoutElem:IHUDLayoutElement = propEditor as IHUDLayoutElement;
							if (asHUDLayoutElem && colNum == 0) {
								mLayoutItems.push(asHUDLayoutElem);
							}
						colNum++;
						} else {
							// This is a known property. We should have had an editor
							trace("Internal error: unknown \"known\" property");
						}
					}
				}
				
				for each (var spacer:XML in row.spacer) {	
					var s:Spacer = new Spacer();
					s.height = spacer.@height;
					addChild(new HBox().addChild(s));
				}
			}
			
			// The property editor changed, we need to alert parties that care.
			validateNow();
			var propEditEvent:Event = new Event("PropertyEditorChanged", true, false);
			this.dispatchEvent(propEditEvent);
			
			mNeedToUpdateWidths = true;
			callLater(updateWidths);	
		}		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (mNeedToUpdateWidths)
				updateWidths();
		}
		
		private function updateWidths():void {
			if (this.parent == null || this.parent.parent == null)
				return;
				
			mNeedToUpdateWidths = false;
			var maxLblWid:int = 0;
			var hudElem:IHUDLayoutElement;
			
			for each (hudElem in mLayoutItems) {
				var lblWid:int = hudElem.getLabelWidth();
				if (lblWid > maxLblWid)
					maxLblWid = lblWid;
			}
			
			if (maxLblWid != mMaxLabelWidth)
				mMaxLabelWidth = maxLblWid;

			//**teb - TODO; use data binding for this!
			for each (hudElem in mLayoutItems) {
				hudElem.maxSiblingLabelWid = mMaxLabelWidth;
			}
				
		}		
		
	}	
		
}
