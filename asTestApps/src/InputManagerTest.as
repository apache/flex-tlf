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
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.FlowOperationEvent;
	import flashx.textLayout.events.TextLayoutEvent;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.operations.SplitParagraphOperation;
	
	
	/** Simple example of two form fields with editable text.  The text only breaks lines on paragraph ends or hard line breaks.  */
	public class InputManagerTest extends Sprite
	{
		private static const markup:String = "<flow:TextFlow xmlns:flow='http://ns.adobe.com/textLayout/2008' >" + 
			"<flow:p><flow:span fontSize='40' breakOpportunity='any'>A</flow:span><flow:span fontSize='20' breakOpportunity='all'>B</flow:span></flow:p>" + 
			"</flow:TextFlow>";
		
		
		public function InputManagerTest()
		{
			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			var s:Sprite = new Sprite();
			addChild(s);
			textFlow.flowComposer.addController(new ContainerController(s));
			textFlow.flowComposer.updateAllControllers();
			textFlow.interactionManager = new SelectionManager();
			textFlow.interactionManager.selectRange(1, 1);
			var format:ITextLayoutFormat = textFlow.interactionManager.getCommonCharacterFormat();
		}
	}
}