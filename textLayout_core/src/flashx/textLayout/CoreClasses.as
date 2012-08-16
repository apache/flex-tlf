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
package flashx.textLayout
{
 	internal class CoreClasses
	{
		import flashx.textLayout.tlf_internal; tlf_internal;
		
		import flashx.textLayout.accessibility.TextAccImpl; TextAccImpl;
		
		import flashx.textLayout.BuildInfo; BuildInfo;

		import flashx.textLayout.compose.BaseCompose; BaseCompose;
		import flashx.textLayout.compose.ComposeState; ComposeState;
		import flashx.textLayout.compose.FlowComposerBase; FlowComposerBase;
		import flashx.textLayout.compose.FlowDamageType; FlowDamageType;
		import flashx.textLayout.compose.IFlowComposer; IFlowComposer;
		import flashx.textLayout.compose.ITextLineCreator; ITextLineCreator;
		import flashx.textLayout.compose.ISWFContext; ISWFContext;
		import flashx.textLayout.compose.IVerticalJustificationLine; IVerticalJustificationLine;
		import flashx.textLayout.compose.Parcel; Parcel;
		import flashx.textLayout.compose.ParcelList; ParcelList;
		import flashx.textLayout.compose.SimpleCompose; SimpleCompose;
		import flashx.textLayout.compose.TextFlowLine; TextFlowLine;
		import flashx.textLayout.compose.TextFlowLineLocation; TextFlowLineLocation;
		import flashx.textLayout.compose.TextLineRecycler; TextLineRecycler;
		import flashx.textLayout.compose.StandardFlowComposer; StandardFlowComposer;
		import flashx.textLayout.compose.VerticalJustifier; VerticalJustifier;
		
		import flashx.textLayout.container.ColumnState; ColumnState;		
		import flashx.textLayout.container.ContainerController; ContainerController;
		import flashx.textLayout.container.ISandboxSupport; ISandboxSupport;
		import flashx.textLayout.container.ScrollPolicy; ScrollPolicy;
				
		import flashx.textLayout.debug.assert;
		import flashx.textLayout.debug.Debugging; Debugging;
		
		import flashx.textLayout.edit.EditingMode; EditingMode;
		import flashx.textLayout.edit.IInteractionEventHandler; IInteractionEventHandler;
		import flashx.textLayout.edit.ISelectionManager; ISelectionManager;
		import flashx.textLayout.edit.SelectionFormat; SelectionFormat;
		import flashx.textLayout.edit.SelectionState; SelectionState;
		import flashx.textLayout.elements.TextRange; TextRange;
		
		import flashx.textLayout.elements.BreakElement; BreakElement;
		import flashx.textLayout.elements.Configuration; Configuration;
		import flashx.textLayout.elements.ContainerFormattedElement; ContainerFormattedElement;
		import flashx.textLayout.elements.DivElement; DivElement;
		import flashx.textLayout.elements.FlowElement; FlowElement;
		import flashx.textLayout.elements.FlowGroupElement; FlowGroupElement;
		import flashx.textLayout.elements.FlowLeafElement; FlowLeafElement;
		import flashx.textLayout.elements.GlobalSettings; GlobalSettings;
		import flashx.textLayout.elements.IConfiguration; IConfiguration;
		import flashx.textLayout.elements.IFormatResolver; IFormatResolver;
		import flashx.textLayout.elements.InlineGraphicElement; InlineGraphicElement;
		import flashx.textLayout.elements.InlineGraphicElementStatus; InlineGraphicElementStatus;
		import flashx.textLayout.elements.LinkElement; LinkElement;
		import flashx.textLayout.elements.LinkState; LinkState;
		import flashx.textLayout.elements.OverflowPolicy; OverflowPolicy;
		import flashx.textLayout.elements.ParagraphElement; ParagraphElement;
		import flashx.textLayout.elements.ParagraphFormattedElement; ParagraphFormattedElement;
		import flashx.textLayout.elements.SpanElement; SpanElement;
		import flashx.textLayout.elements.SpecialCharacterElement; SpecialCharacterElement;
		import flashx.textLayout.elements.SubParagraphGroupElement; SubParagraphGroupElement;
		import flashx.textLayout.elements.TabElement; TabElement;
		import flashx.textLayout.elements.TCYElement; TCYElement;
		import flashx.textLayout.elements.TextFlow; TextFlow;
		import flashx.textLayout.elements.TextRange; TextRange;
		
		import flashx.textLayout.events.CompositionCompleteEvent; CompositionCompleteEvent;
		import flashx.textLayout.events.DamageEvent; DamageEvent;
		import flashx.textLayout.events.FlowElementMouseEvent; FlowElementMouseEvent;
		import flashx.textLayout.events.ModelChange; ModelChange;
		import flashx.textLayout.events.StatusChangeEvent; StatusChangeEvent;
		import flashx.textLayout.events.TextLayoutEvent; TextLayoutEvent;
		
		import flashx.textLayout.factory.TextLineFactoryBase; TextLineFactoryBase;
		import flashx.textLayout.factory.StringTextLineFactory; StringTextLineFactory;
		import flashx.textLayout.factory.TextFlowTextLineFactory; TextFlowTextLineFactory;
		import flashx.textLayout.factory.TruncationOptions; TruncationOptions;		

		import flashx.textLayout.formats.BaselineOffset; BaselineOffset;
		import flashx.textLayout.formats.BaselineShift; BaselineShift;
		import flashx.textLayout.formats.BlockProgression; BlockProgression;

		import flashx.textLayout.formats.Category; Category;
		import flashx.textLayout.formats.Direction; Direction;
		import flashx.textLayout.formats.Float; Float;
		import flashx.textLayout.formats.FlowElementDisplayType; FlowElementDisplayType;
		import flashx.textLayout.formats.FormatValue; FormatValue;
		import flashx.textLayout.formats.IMEStatus; IMEStatus;
		import flashx.textLayout.formats.ITextLayoutFormat; ITextLayoutFormat;
		import flashx.textLayout.formats.ITabStopFormat; ITabStopFormat;
		import flashx.textLayout.formats.JustificationRule; JustificationRule;
		import flashx.textLayout.formats.LeadingModel; LeadingModel;
		import flashx.textLayout.formats.LineBreak; LineBreak;
		import flashx.textLayout.formats.TabStopFormat; TabStopFormat;
		import flashx.textLayout.formats.TextAlign; TextAlign;
		import flashx.textLayout.formats.TextDecoration; TextDecoration;
		import flashx.textLayout.formats.TextJustify; TextJustify;
		import flashx.textLayout.formats.TextLayoutFormat; TextLayoutFormat;		
		import flashx.textLayout.formats.TextLayoutFormatValueHolder; TextLayoutFormatValueHolder;		
		import flashx.textLayout.formats.VerticalAlign; VerticalAlign;
		import flashx.textLayout.formats.WhiteSpaceCollapse; WhiteSpaceCollapse;

		import flashx.textLayout.property.ArrayProperty; ArrayProperty;
		import flashx.textLayout.property.BooleanProperty; BooleanProperty;
		import flashx.textLayout.property.EnumStringProperty; EnumStringProperty;
		import flashx.textLayout.property.IntProperty; IntProperty;
		import flashx.textLayout.property.IntWithEnumProperty; IntWithEnumProperty;
		import flashx.textLayout.property.NumberOrPercentOrEnumProperty; NumberOrPercentOrEnumProperty;
		import flashx.textLayout.property.NumberOrPercentProperty; NumberOrPercentProperty;
		import flashx.textLayout.property.NumberProperty; NumberProperty;
		import flashx.textLayout.property.NumberWithEnumProperty; NumberWithEnumProperty;
		import flashx.textLayout.property.Property; Property;
		import flashx.textLayout.property.StringProperty; StringProperty;
		import flashx.textLayout.property.UintProperty; UintProperty;
		
		import flashx.textLayout.utils.CharacterUtil; CharacterUtil;
		import flashx.textLayout.utils.GeometryUtil; GeometryUtil;
		
		// Alphabetical list of classes to be included as part of text_model.swc.
		// This should mirror what's in the .flexLibProperties
		
		CONFIG::release public function exportAssert():void
		{
			assert();
		}
	}
}

