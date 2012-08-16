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
	import flash.text.StyleSheet;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.conversion.ImportExportConfiguration;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.IExplicitFormatResolver;
	import flashx.textLayout.elements.IFormatResolver;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;
	
	public class CustomFormatResolver extends CSSFormatResolver implements IExplicitFormatResolver
	{
		public function CustomFormatResolver(styleSheet:StyleSheet)
		{
			super(styleSheet);
		}
		
		public function resolveExplicitFormat(elem:Object):ITextLayoutFormat
		{
			var attr:TextLayoutFormat = _textLayoutFormatCache[elem];			
			if (elem is FlowElement)
			{
				if (elem.styleName != null)
					attr = addStyleAttributes(attr, "." + elem.styleName);
				
				if (elem.id != null)
					attr = addStyleAttributes(attr, "#" + elem.id);
				
				_textLayoutFormatCache[elem] = attr;
				return attr;
			}
			return null;
		}
	}
}