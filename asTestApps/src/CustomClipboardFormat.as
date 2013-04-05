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
	import flash.desktop.ClipboardFormats;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.*;
	import flashx.undo.UndoManager;
	
	
	// Example code to install a custom clipboard format. This one installs at the front of the list (overriding all later formats)
	// and adds a handler for plain text that strips out all consonants (everything except aeiou).
	public class CustomClipboardFormat extends Sprite 
	{ 
		public function CustomClipboardFormat() 
		{ 
			var textFlow:TextFlow = setup();
			TextConverter.addFormatAt(0, "vowelsOnly", VowelsOnlyImporter, null, "air:text" /* it's a converter for cliboard */);
		} 
		
		private const markup:String = '<TextFlow whiteSpaceCollapse="preserve" version="2.0.0" xmlns="http://ns.adobe.com/textLayout/2008"><p><span>Anything you paste will have all consonants removed.</span></p></TextFlow>';
		private function setup():TextFlow
		{
			var importer:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
			var textFlow:TextFlow = importer.importToFlow(markup);
			textFlow.flowComposer.addController(new ContainerController(this,500,200));
			textFlow.interactionManager = new EditManager(new UndoManager());
			textFlow.flowComposer.updateAllControllers();
			return textFlow;
		}
	} 
	
}

import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.ConverterBase;
import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.elements.IConfiguration;
import flashx.textLayout.elements.TextFlow;

class VowelsOnlyImporter extends ConverterBase implements ITextImporter
{
	protected var _config:IConfiguration = null;
	
	/** Constructor */
	public function VowelsOnlyImporter()
	{
		super();
	}
	
	public function importToFlow(source:Object):TextFlow
	{
		if (source is String)
		{
			var firstChar:String = (source as String).charAt(0);
			firstChar = firstChar.toLowerCase();
			// This filter only applies if the first character is a vowel
			if (firstChar == 'a' || firstChar == 'i' || firstChar == 'e' || firstChar == 'o' || firstChar == 'u')
			{
				var pattern:RegExp = /([b-df-hj-np-tv-z])*/g;
				source = source.replace(pattern, "");
				var importer:ITextImporter = TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT);
				importer.useClipboardAnnotations = this.useClipboardAnnotations;
				importer.configuration = _config;
				return importer.importToFlow(source);
			}
		}
		return null;
	}
	
	/**
	 * The <code>configuration</code> property contains the IConfiguration instance that
	 * the importerd needs when creating new TextFlow instances. This property
	 * is initially set to <code>null</code>.
	 * @see TextFlow constructor
	 * @playerversion Flash 10.2
	 * @playerversion AIR 2.0
	 * @langversion 3.0
	 */
	public function get configuration():IConfiguration
	{
		return _config;
	}
	
	public function set configuration(value:IConfiguration):void
	{
		_config = value;
	}
}
