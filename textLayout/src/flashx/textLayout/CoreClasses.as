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
		
		import flashx.textLayout.TextLayoutVersion; TextLayoutVersion;

		import flashx.textLayout.compose.BaseCompose; BaseCompose;
		import flashx.textLayout.compose.ComposeState; ComposeState;
		import flashx.textLayout.compose.FlowComposerBase; FlowComposerBase;
		import flashx.textLayout.compose.FloatCompositionData; FloatCompositionData;
		import flashx.textLayout.compose.FlowDamageType; FlowDamageType;
		import flashx.textLayout.compose.IFlowComposer; IFlowComposer;
		import flashx.textLayout.compose.ISWFContext; ISWFContext;
		import flashx.textLayout.compose.IVerticalJustificationLine; IVerticalJustificationLine;
		import flashx.textLayout.compose.Parcel; Parcel;
		import flashx.textLayout.compose.ParcelList; ParcelList;
		import flashx.textLayout.compose.SimpleCompose; SimpleCompose;
		import flashx.textLayout.compose.Slug; Slug;
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
		import flashx.textLayout.edit.SelectionType; SelectionType;
		
		import flashx.textLayout.elements.SubParagraphGroupElementBase; SubParagraphGroupElementBase;
		import flashx.textLayout.elements.BreakElement; BreakElement;
		import flashx.textLayout.elements.Configuration; Configuration;
		import flashx.textLayout.elements.ContainerFormattedElement; ContainerFormattedElement;
		import flashx.textLayout.elements.DivElement; DivElement;
		import flashx.textLayout.elements.FlowElement; FlowElement;
		import flashx.textLayout.elements.FlowGroupElement; FlowGroupElement;
		import flashx.textLayout.elements.FlowLeafElement; FlowLeafElement;
		import flashx.textLayout.elements.GlobalSettings; GlobalSettings;
		import flashx.textLayout.elements.IConfiguration; IConfiguration;
		import flashx.textLayout.elements.IExplicitFormatResolver; IExplicitFormatResolver;
		import flashx.textLayout.elements.IFormatResolver; IFormatResolver;
		import flashx.textLayout.elements.InlineGraphicElement; InlineGraphicElement;
		import flashx.textLayout.elements.InlineGraphicElementStatus; InlineGraphicElementStatus;
		import flashx.textLayout.elements.ListElement; ListElement;
		import flashx.textLayout.elements.ListItemElement; ListItemElement;
		import flashx.textLayout.elements.LinkElement; LinkElement;
		import flashx.textLayout.elements.LinkState; LinkState;
		import flashx.textLayout.elements.OverflowPolicy; OverflowPolicy;
		import flashx.textLayout.elements.ParagraphElement; ParagraphElement;
		import flashx.textLayout.elements.ParagraphFormattedElement; ParagraphFormattedElement;
		import flashx.textLayout.elements.SpanElement; SpanElement;
		import flashx.textLayout.elements.SpecialCharacterElement; SpecialCharacterElement;
		import flashx.textLayout.elements.SubParagraphGroupElement; SubParagraphGroupElement;
		import flashx.textLayout.elements.TabElement; TabElement;
		import flashx.textLayout.elements.TableElement; TableElement;
		import flashx.textLayout.elements.TableBodyElement; TableBodyElement;
		import flashx.textLayout.elements.TableColElement; TableColElement;
		import flashx.textLayout.elements.TableColGroupElement; TableColGroupElement;
		import flashx.textLayout.elements.TableCellElement; TableCellElement;
		import flashx.textLayout.elements.TableRowElement; TableRowElement;
		import flashx.textLayout.elements.TCYElement; TCYElement;
		import flashx.textLayout.elements.TextFlow; TextFlow;
		import flashx.textLayout.elements.TextRange; TextRange;

		
		import flashx.textLayout.events.CompositionCompleteEvent; CompositionCompleteEvent;
		import flashx.textLayout.events.DamageEvent; DamageEvent;
		import flashx.textLayout.events.FlowElementMouseEvent; FlowElementMouseEvent;
		import flashx.textLayout.events.FlowElementMouseEventManager; FlowElementMouseEventManager;
		import flashx.textLayout.events.FlowElementEventDispatcher; FlowElementEventDispatcher;
		import flashx.textLayout.events.ModelChange; ModelChange;
		import flashx.textLayout.events.ScrollEvent; ScrollEvent;
		import flashx.textLayout.events.ScrollEventDirection; ScrollEventDirection;
		import flashx.textLayout.events.StatusChangeEvent; StatusChangeEvent;
		import flashx.textLayout.events.TextLayoutEvent; TextLayoutEvent;
		
		import flashx.textLayout.factory.FactoryDisplayComposer; FactoryDisplayComposer;
		import flashx.textLayout.factory.TextLineFactoryBase; TextLineFactoryBase;
		import flashx.textLayout.factory.StringTextLineFactory; StringTextLineFactory;
		import flashx.textLayout.factory.TextFlowTextLineFactory; TextFlowTextLineFactory;
		import flashx.textLayout.factory.TruncationOptions; TruncationOptions;		

		import flashx.textLayout.formats.BaselineOffset; BaselineOffset;
		import flashx.textLayout.formats.BaselineShift; BaselineShift;
		import flashx.textLayout.formats.BlockProgression; BlockProgression;
		import flashx.textLayout.formats.BreakStyle; BreakStyle;

		import flashx.textLayout.formats.Category; Category;
		import flashx.textLayout.formats.ClearFloats; ClearFloats;
		import flashx.textLayout.formats.Direction; Direction;
		import flashx.textLayout.formats.Float; Float;
		import flashx.textLayout.formats.FormatValue; FormatValue;
		import flashx.textLayout.formats.IMEStatus; IMEStatus;
		import flashx.textLayout.formats.IListMarkerFormat; IListMarkerFormat;
		import flashx.textLayout.formats.ITabStopFormat; ITabStopFormat;
		import flashx.textLayout.formats.ITextLayoutFormat; ITextLayoutFormat;
		import flashx.textLayout.formats.JustificationRule; JustificationRule;
		import flashx.textLayout.formats.LeadingModel; LeadingModel;
		import flashx.textLayout.formats.LineBreak; LineBreak;
		import flashx.textLayout.formats.ListMarkerFormat; ListMarkerFormat;
		import flashx.textLayout.formats.ListMarkerFormat; ListMarkerFormat;
		import flashx.textLayout.formats.Suffix; Suffix;
		import flashx.textLayout.formats.TabStopFormat; TabStopFormat;
		import flashx.textLayout.formats.TextAlign; TextAlign;
		import flashx.textLayout.formats.TextDecoration; TextDecoration;
		import flashx.textLayout.formats.TextJustify; TextJustify;
		import flashx.textLayout.formats.TextLayoutFormat; TextLayoutFormat;		
		import flashx.textLayout.formats.VerticalAlign; VerticalAlign;
		import flashx.textLayout.formats.WhiteSpaceCollapse; WhiteSpaceCollapse;

		import flashx.textLayout.property.ArrayProperty; ArrayProperty;
		import flashx.textLayout.property.Property; Property;
		
		// new property classes
		import flashx.textLayout.property.PropertyHandler; PropertyHandler;
		import flashx.textLayout.property.BooleanPropertyHandler; BooleanPropertyHandler;
		import flashx.textLayout.property.EnumPropertyHandler; EnumPropertyHandler;
		import flashx.textLayout.property.FormatPropertyHandler; FormatPropertyHandler;
		import flashx.textLayout.property.StringPropertyHandler; StringPropertyHandler;
		import flashx.textLayout.property.IntPropertyHandler; IntPropertyHandler;
		import flashx.textLayout.property.UintPropertyHandler; UintPropertyHandler;
		import flashx.textLayout.property.NumberPropertyHandler; NumberPropertyHandler;
		import flashx.textLayout.property.UndefinedPropertyHandler; UndefinedPropertyHandler;
		import flashx.textLayout.property.PercentPropertyHandler; PercentPropertyHandler;
		import flashx.textLayout.property.CounterContentHandler; CounterContentHandler;
		import flashx.textLayout.property.CounterPropHandler; CounterPropHandler;
		
		import flashx.textLayout.utils.CharacterUtil; CharacterUtil;
		import flashx.textLayout.utils.GeometryUtil; GeometryUtil;
		import flashx.textLayout.utils.HitTestArea; HitTestArea;
		import flashx.textLayout.utils.Twips; Twips;
				
		CONFIG::release public function exportAssert():void
		{
			assert();
		}
	}
}

