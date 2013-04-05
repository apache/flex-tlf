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
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import flash.text.StyleSheet;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	[SWF(width="500", height="500")]
	public class AS3CSSSample extends Sprite
	{
		
		public function AS3CSSSample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			
			var textFlow:TextFlow = TextConverter.importToFlow(Data.simpleText, TextConverter.TEXT_LAYOUT_FORMAT);
			// wipe out the default inherits - format take precendence over CSS - this simplifies the example
			textFlow.format = null;
			
			// create a styleSheet - use the subclass with the transform override
			var styleSheet:StyleSheet = new TLFStyleSheet;
			
			// parse a styleSheet
			styleSheet.parseCSS(Data.CSSText);
			
			// attach a format resolver
			textFlow.formatResolver = new CSSFormatResolver(styleSheet);
			
			// set it into the editor
			textFlow.flowComposer.addController(new ContainerController(this,500,500));
			textFlow.flowComposer.updateAllControllers();

		}
	}
}
import flash.text.StyleSheet;
import flash.text.TextFormat;

class TLFStyleSheet extends StyleSheet
{
	// override transform - skip making a TextFormat
	public override function transform(formatObject:Object):TextFormat
	{
		return null;
	}
}

class Data
{
	
static public const simpleText:String = "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>"
		+ "<p styleName='center'><span>There are many </span><span styleName='italic'>such</span><span> lime-kilns in that tract of country, for the purpose of burning the white marble which composes a large part of the substance of the hills. Some of them, built years ago, and long deserted, with weeds growing in the vacant round of the interior, which is open to the sky, and grass and wild-flowers rooting themselves into the chinks of the stones, look already like relics of antiquity, and may yet be overspread with the lichens of centuries to come. Others, where the lime-burner still feeds his daily and nightlong fire, afford points of interest to the wanderer among the hills, who seats himself on a log of wood or a fragment of marble, to hold a chat with the solitary man. It is a lonesome, and, when the character is inclined to thought, may be an intensely thoughtful occupation; as it proved in the case of Ethan Brand, who had mused to such strange purpose, in days gone by, while the fire in this very kiln was burning.</span></p>"
		+ "<p><span>The man who now watched the </span><span id='bold'>fire</span><span> was of a </span><span typeName='foo'>different</span><span> order, and troubled himself with no thoughts save the very few that were requisite to his business. At frequent intervals, he flung back the clashing weight of the iron door, and, turning his face from the insufferable glare, thrust in huge logs of oak, or stirred the immense brands with a long pole. Within the furnace were seen the curling and riotous flames, and the burning marble, almost molten with the intensity of heat; while without, the reflection of the fire quivered on the dark intricacy of the surrounding forest, and showed in the foreground a bright and ruddy little picture of the hut, the spring beside its door, the athletic and coal-begrimed figure of the lime-burner, and the half-frightened child, shrinking into the protection of his father's shadow. And when again the iron door was closed, then reappeared the tender light of the half-full moon, which vainly strove to trace out the indistinct shapes of the neighboring mountains; and, in the upper sky, there was a flitting congregation of clouds, still faintly tinged with the rosy sunset, though thus far down into the valley the sunshine had vanished long and long ago.</span></p>"
		+ "</TextFlow>";


static public const CSSText:String = "\
\
span \
{\
	fontSize:		18;\
}\
\
TextFlow\
{\
	columnCount:            2;\
	textIndent:             15;\
	paragraphSpaceAfter:	15;\
	paddingTop:             4;\
	paddingLeft:            4;\
}\
\
foo\
{\
	fontSize:		18;\
	color:			0xff00;\
}\
\
.italic\
{\
	#fontStyle:		italic;\
	#color:			0xff;\
	#fontFamily:	Helvetica;\
}\
\
.center\
{\
	textAlign:		center;\
}\
\
#bold\
{\
	fontWeight:		bold;\
}\
";
}


import flash.text.StyleSheet;
import flash.utils.Dictionary;

import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.FlowGroupElement;
import flashx.textLayout.elements.IFormatResolver;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.formats.TextLayoutFormat;
import flashx.textLayout.property.Property;
import flashx.textLayout.tlf_internal;
use namespace tlf_internal;

/** This version hands back a style on demand from the dictionary.
 * Another way to do it would be to "redo" the cascade top down.
 */
class CSSFormatResolver implements IFormatResolver
{
	/** cache of already calculated styles. */
	private var _textLayoutFormatCache:Dictionary;
	/** Hangs on to the parsed styleSheet */
	private var _styleSheet:StyleSheet;
	
	/** Create a flex style resolver.  */
	public function CSSFormatResolver(styleSheet:StyleSheet):void
	{
		_textLayoutFormatCache = new Dictionary(true);
		_styleSheet = styleSheet;
	}
	
	/** Use styleSelector to look up a style declaration from the parsed style.  Add each set attribute to a TextLayoutFormat creating one if necessary. */
	private function addStyleAttributes(attr:TextLayoutFormat, styleSelector:String):TextLayoutFormat
	{
		var foundStyle:Object = _styleSheet.getStyle(styleSelector);
		if (foundStyle)
		{ 				
			// description is a list of all the TLF defined attributes
			// Property is an internal, but very useful, class that defines a TLF attribute.  We're just looking at its name.
			for each (var prop:Property in TextLayoutFormat.description)
			{
				var propStyle:Object = foundStyle[prop.name];
				if (propStyle)
				{
					if (attr == null)
						attr = new TextLayoutFormat();
					attr[prop.name] = propStyle;
				}
			}
		}
		return attr;
	}
	
	/** Calculate the TextLayoutFormat style for a particular element. Implements three style selectors for each element
	 * - type selector (this is new for 2.0 - each element has a typeName property that is normally the TLF typeName. 
	 * 	The HTML importer converts <foo> to a TLF element with typeName="foo"
	 * - class selector 
	 * - id selector
	 */
	public function resolveFormat(elem:Object):ITextLayoutFormat
	{
		var attr:TextLayoutFormat = _textLayoutFormatCache[elem];
		if (attr !== null)
			return attr;
		
		if (elem is FlowElement)
		{
			attr = addStyleAttributes(attr, elem.typeName);
			
			if (elem.styleName != null)
				attr = addStyleAttributes(attr, "." + elem.styleName);
			
			if (elem.id != null)
				attr = addStyleAttributes(attr, "#" + elem.id);
			
			_textLayoutFormatCache[elem] = attr;
		}
		return attr;
	}
	
	/** Calculate the user style for a particular element. The parsed styleSheet is held in _styleSheet.  Apply the CSS selectors here. 
	 * Generally this is only called when the already calculated result isn't in the cache.  */
	public function resolveUserFormat(elem:Object,userStyle:String):*
	{
		var flowElem:FlowElement = elem as FlowElement;
		var foundStyle:Object;
		var propStyle:*;
		
		// support non-tlf styles
		if (flowElem)
		{
			if (flowElem.id)
			{
				foundStyle = _styleSheet.getStyle("#"+flowElem.id);
				if (foundStyle)
				{
					propStyle = foundStyle[userStyle];
					if (propStyle !== undefined)
						return propStyle;
				}
			}
			if (flowElem.styleName)
			{
				foundStyle = _styleSheet.getStyle("."+flowElem.styleName);
				if (foundStyle)
				{
					foundStyle = foundStyle[userStyle];
					if (propStyle !== undefined)
						return propStyle;
				}
			}
			
			foundStyle = _styleSheet.getStyle(flowElem.typeName);
			if (foundStyle)
			{
				propStyle = foundStyle[userStyle];
				if (propStyle !== undefined)
					return propStyle;
			}
		}
		return undefined;
	}
	
	/** Completely clear the cache.  None of the results are valid. */
	public function invalidateAll(tf:TextFlow):void
	{
		_textLayoutFormatCache = new Dictionary(true);	// clears the cache
	}
	
	/** The style of one element is invalidated.  */
	public function invalidate(target:Object):void
	{
		delete _textLayoutFormatCache[target];
		
		// recursively descend if this element is a FlowGroupElement.  Is this needed?
		var blockElem:FlowGroupElement = target as FlowGroupElement;
		if (blockElem)
		{
			for (var idx:int = 0; idx < blockElem.numChildren; idx++)
				invalidate(blockElem.getChildAt(idx));
		}
	}
	
	/** Called when a TextFlow is copied.  In this case these are sharable between TextFlows.  If the flows have different styleSheets you may want to clone this. */
	public function getResolverForNewFlow(oldFlow:TextFlow,newFlow:TextFlow):IFormatResolver
	{ return this; }
}
