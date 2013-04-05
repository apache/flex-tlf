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
	import bxf.ui.inspectors.IPropertyEditor;
	
	import mx.containers.HBox;
	import mx.controls.Spacer;
	import mx.controls.Text;
	import mx.core.ScrollPolicy;
	import flash.events.MouseEvent;
	import flash.ui.MouseCursor;
	import flash.events.Event;
	import mx.events.FlexEvent;
	import bxf.ui.controls.HotTextEvent;
		
	public class PropertyEditorBase extends HBox implements IHUDLayoutElement {
		private var mLabel:Text;
		private var mLabelText:String;
		private var mSpacer:Spacer;
		protected var mUseSectionSpacer:Boolean = false;
		private var mSectionSpacer:Spacer;
		
		public function PropertyEditorBase(inLabel:String) {
			if (null == (this as IPropertyEditor)) {
				throw new Error("ERROR: Class must be an IPropertyEditor");
			}
			
			setStyle("horizontalGap", 2);
			mLabelText = inLabel;	
			this.horizontalScrollPolicy = this.verticalScrollPolicy = ScrollPolicy.OFF;
			
		//	addEventListener(HotTextEvent.FINISH_CHANGE, onCommit);
			addEventListener(PropertyEditEvent.VALUE_CHANGED, onValueCommit);
		}
		
		public function set sectionSpacer(inSectionSpacer:Boolean):void {
			mUseSectionSpacer = inSectionSpacer;
		}
		
		protected function get labelText():String {
			return mLabelText;
		}
		
		override protected function createChildren():void
		{
	        super.createChildren();
	        if (null == mSpacer) {
	        	mSpacer = new Spacer();
	        	addChild(mSpacer);
	        }

	        if (mUseSectionSpacer == true && null == mSectionSpacer)
	        {
	        	mSectionSpacer = new Spacer();
	        	addChild(mSectionSpacer);
	        }
	        
	        if (null == mLabel) {
	        	mLabel = new Text();
	        	mLabel.text = mLabelText;
	        	mLabel.selectable = false;
				mLabel.styleName = "ActionLabels";
				mLabel.setStyle("textAlign", "right"); 
				mLabel.setStyle("paddingTop", 2);	
	        	addChild(mLabel);
	        }
	        
	    }
				
		public function getLabelWidth():int {
			var ret:int = 0;
			
			if (mUseSectionSpacer == false)
				ret = mLabel.measuredWidth;
			return ret;
		}
		
		public function set maxSiblingLabelWid(inMaxLblWid:int):void {
			var val:int = inMaxLblWid - getLabelWidth();
			if (val < 0)
				val = 0;
				
			if (mUseSectionSpacer)
				mSectionSpacer.width = val;
			else
				mSpacer.width = val;
		}	
		
		protected function onValueCommit(event:Event):void
		{
			this.parentApplication.dispatchEvent(new Event(Event.ACTIVATE));
		}	
	}
}
