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
package flashx.textLayout.edit
{

/**
 * The ElementRange class represents the range of objects selected within a text flow.
 * 
 * <p>The beginning elements 
 * (such as <code>firstLeaf</code>) are always less than or equal to the end elements (in this case, <code>lastLeaf</code>)
 * for each pair of values in an element range.</p>
 * 
 * @see flashx.textLayout.elements.TextFlow
 * 
 * @playerversion Flash 10
 * @playerversion AIR 1.5
 * @langversion 3.0
 */	
public class ElementRange
{
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.ContainerFormattedElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	private var _absoluteStart:int;
	private var _absoluteEnd:int;
	private var _firstLeaf:FlowLeafElement;
	private var _lastLeaf:FlowLeafElement;
	private var _firstParagraph:ParagraphElement;
	private var _lastParagraph:ParagraphElement;
	private var _textFlow:TextFlow;	
	
	/** 
	 * The absolute text position of the FlowLeafElement object that contains the start of the range.
	 *  
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	 */
	public function get absoluteStart():int
	{
		return _absoluteStart;
	}
	public function set absoluteStart(value:int):void
	{
		_absoluteStart = value;
	}
	
	/** 
	 * The absolute text position of the FlowLeafElement object that contains the end of the range. 
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
 	 */
	public function get absoluteEnd():int
	{
		return _absoluteEnd;
	}
	public function set absoluteEnd(value:int):void
	{
		_absoluteEnd = value;
	}

	/** 
	 * The FlowLeafElement object that contains the start of the range. 
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	 */
	public function get firstLeaf():FlowLeafElement
	{
		return _firstLeaf;
	}
	public function set firstLeaf(value:FlowLeafElement):void
	{
		_firstLeaf = value;
	}

	/** 
	 * The FlowLeafElement object that contains the end of the range. 
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	*/
	public function get lastLeaf():FlowLeafElement
	{
		return _lastLeaf;
	}
	public function set lastLeaf(value:FlowLeafElement):void
	{
		_lastLeaf = value;
	}

	/** 
	 * The ParagraphElement object that contains the start of the range. 
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	 */
	public function get firstParagraph():ParagraphElement
	{
		return _firstParagraph;
	}
	public function set firstParagraph(value:ParagraphElement):void
	{
		_firstParagraph = value;
	}
	
	/** 
	 * The ParagraphElement object that contains the end of the range. 
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	*/
	public function get lastParagraph():ParagraphElement
	{
		return _lastParagraph;
	}
	public function set lastParagraph(value:ParagraphElement):void
	{
		_lastParagraph = value;
	}
	
	/** 
	 * The TextFlow object that contains the range. 
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	 */
	public function get textFlow():TextFlow
	{
		return _textFlow;
	}	
	public function set textFlow(value:TextFlow):void
	{
		_textFlow = value;
	}	
	
	// This constructor function is here just to silence a compile warning in Eclipse. There
	// appears to be no way to turn the warning off selectively.
	/** @private */
	CONFIG::debug public function ElementRange()
	{
		super();
	}
	
 	// NOTE: We've been back and forth on this - should a range selection show null attributes or beginning of range attributes?
	// After looking at this for a while I want it to show beginning of range attributes.  Two main reasons
	// 1. If the range contains different objects but homogoneous settings we should show the attributes.
	// 2. If we show null attributes on a range selection there's no way to, for example, turn BOLD off.
	// Try this at home - restore the old code. Select the entire text.  Turn Bold on.  Can't turn bold off.
	// Please don't revert this without further discussion.
	// Ideally we would have a way of figuring out which attributes are homogoneous over the selection range
	// and which were not and showing, for example, a "half-checked" bold item.  We'd have to work this out for all the properties.
	
	// OLD CODE that shows null attribute settings on a range selection
	// var charAttr:ICharacterFormat = selRange.begElem == selRange.endElem ? selRange.begElem.computedCharacterFormat : new CharacterFormat();
	// var paraAttr:IParagraphFormat = selRange.begPara == selRange.endPara ? selRange.begPara.computedParagraphFormat : new ParagraphFormat();


	/** 
	 * The format attributes of the container displaying the range. 
	 * 
	 * <p>If the range spans more than one container, the format of the first container is returned.</p>
	 *  
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	 */
	public function get containerFormat():ITextLayoutFormat
	{
		// see NOTE above before changing!!
		// This is just wrong - only shows the first container
		var container:ContainerController;
		var flowComposer:IFlowComposer = firstParagraph.getTextFlow().flowComposer;
		if (flowComposer && flowComposer.numControllers > 0)
			container = flowComposer.getControllerAt(0);
		if (!container)
			return ContainerFormattedElement(firstParagraph.getParentByType(ContainerFormattedElement)).computedFormat;
 		return container.computedFormat;		
	}
		
	/** 
	 * The format attributes of the paragraph containing the range. 
	 * 
	 * <p>If the range spans more than one paragraph, the format of the first paragraph is returned.</p>
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	 */
	public function get paragraphFormat():ITextLayoutFormat
	{
		// see NOTE above before changing!!
  		return firstParagraph.computedFormat;
 	}
		
	/** 
	 * The format attributes of the characters in the range. 
	 * 
	 * <p>If the range spans more than one FlowElement object, which means that more than one
	 * character format may exist within the range, the format of the first FlowElement object is returned.</p>
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	 */
	public function get characterFormat():ITextLayoutFormat
	{
		// see NOTE above before changing!!
 		return firstLeaf.computedFormat;
	}
	
	/** 
	 * Creates an ElementRange object.
	 * 
	 * @param textFlow	the text flow
	 * @param beginIndex absolute text position of the first character in the text range
	 * @param endIndex one beyond the absolute text position of the last character in the text range
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
 	 * @langversion 3.0
	 */
	static public function createElementRange(textFlow:TextFlow, absoluteStart:int, absoluteEnd:int):ElementRange
	{
		var rslt:ElementRange = new ElementRange();
		if (absoluteStart == absoluteEnd)
		{
			rslt.absoluteStart = rslt.absoluteEnd = absoluteStart;
			rslt.firstLeaf = rslt.lastLeaf = textFlow.findLeaf(rslt.absoluteStart);
			rslt.firstParagraph = rslt.lastParagraph = rslt.firstLeaf.getParagraph();
	//		rslt.begContainer = rslt.endContainer = selState.textFlow.findAbsoluteContainer(rslt.begElemIdx);
			adjustForLeanLeft(rslt);
		}
		else
		{
			// order the selection points
			if (absoluteStart < absoluteEnd)
			{
				rslt.absoluteStart  = absoluteStart;
				rslt.absoluteEnd = absoluteEnd;
			}
			else
			{
				rslt.absoluteStart  = absoluteEnd;
				rslt.absoluteEnd = absoluteStart;
			}
			rslt.firstLeaf = textFlow.findLeaf(rslt.absoluteStart);
			rslt.lastLeaf = textFlow.findLeaf(rslt.absoluteEnd);
			// back up one element if the end of the selection is the start of an element
			// otherwise a block selection of a span looks like it includes discreet selection ranges
			if (((rslt.lastLeaf == null) && (rslt.absoluteEnd == textFlow.textLength)) || (rslt.absoluteEnd == rslt.lastLeaf.getAbsoluteStart()))
				rslt.lastLeaf = textFlow.findLeaf(rslt.absoluteEnd-1);
				
			rslt.firstParagraph = rslt.firstLeaf.getParagraph();
			rslt.lastParagraph = rslt.lastLeaf.getParagraph();
			
	//		rslt.begContainer = selState.textFlow.findAbsoluteContainer(rslt.begElemIdx);
	//		rslt.endContainer = selState.textFlow.findAbsoluteContainer(rslt.endElemIdx);
	//		if (rslt.endElemIdx == rslt.endContainer.relativeStart)
	//			rslt.endContainer = rslt.endContainer.preventextContainer;
				
			// if the end of the range includes the next to last character in a paragraph 
			// expand it to include the paragraph teriminate character
			if (rslt.absoluteEnd == rslt.lastParagraph.getAbsoluteStart() + rslt.lastParagraph.textLength - 1)
			{
				rslt.absoluteEnd++
				rslt.lastLeaf = rslt.lastParagraph.getLastLeaf();
			}

		}
		rslt.textFlow = textFlow;
			
		return rslt;
	}
	
	static private function adjustForLeanLeft(rslt:ElementRange):void
	{		
		// If we're at the start of a leaf element, look to the previous leaf element and see if it shares the same
		// parent. If so, we're going to move the selection to the end of the previous element so it takes on
		// the formatting of the character to the left. We don't want to do this if the previous element is in
		// a different character, across link or tcy boundaries, etc.
		if (rslt.firstLeaf.getAbsoluteStart() == rslt.absoluteStart)
		{
			var previousNode:FlowLeafElement = rslt.firstLeaf.getPreviousLeaf(rslt.firstParagraph);
			if (previousNode && previousNode.getParagraph() == rslt.firstLeaf.getParagraph())
			{
				if((!(previousNode.parent is SubParagraphGroupElement) || (previousNode.parent as SubParagraphGroupElement).acceptTextAfter())
					&& (!(rslt.firstLeaf.parent is SubParagraphGroupElement) || previousNode.parent === rslt.firstLeaf.parent))
					rslt.firstLeaf = previousNode;
			}
				
		}
	}
}
}