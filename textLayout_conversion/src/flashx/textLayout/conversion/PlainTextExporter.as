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
package flashx.textLayout.conversion
{
	import flashx.textLayout.elements.*;

	/** 
	 * Export filter for plain text format. This class provides an alternative to
	 * the <code>TextConverter.export()</code> static method for exporting plain text,
	 * useful if you need to customize the export by changing the paragraphSeparator
	 * or stripDiscretionaryHyphens options. The PlainTextExporter class's 
	 * <code>export()</code> method results in the 
	 * same output string as the <code>TextConverter.export()</code> static method 
	 * if the two properties of the PlainTextExporter class, the <code>paragraphSeparator</code>
	 * and the <code>stripDiscretionaryHyphens</code> properties, contain their
	 * default values of <code>"\n"</code> and <code>true</code>, respectively.
	 * @includeExample examples\PlainTextExporter_example.as -noswf
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	public class PlainTextExporter implements ITextExporter	
	{
		private var _stripDiscretionaryHyphens:Boolean;
		private var _paragraphSeparator:String;
		
		static private var _discretionaryHyphen:String = String.fromCharCode(0x00AD);
		
		/**
		 * Constructor 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */

		public function PlainTextExporter()
		{
			_stripDiscretionaryHyphens = true;
			_paragraphSeparator = "\n";
		}
		 
		/** This flag indicates whether discretionary hyphens in the text should be stripped during the export process.
		 * Discretionary hyphens, also known as "soft hyphens", indicate where to break a word in case the word must be
		 * split between two lines. The Unicode character for discretionary hyphens is <code>\u00AD</code>.
		 * <p>If the <code>stripDiscretionaryHyphens</code> property is set to <code>true</code>, discretionary hyphens that are in the original text will not be in the exported text, 
		 * even if they are part of the original text. If <code>false</code>, discretionary hyphens will be in the exported text, 
		 * The default value is <code>true</code>.</p>
  		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get stripDiscretionaryHyphens():Boolean
		{
			return _stripDiscretionaryHyphens;
			
		}
		public function set stripDiscretionaryHyphens(value:Boolean):void
		{
			_stripDiscretionaryHyphens = value;
		}

		/** Specifies the character sequence used (in a text flow's plain-text equivalent) to separate paragraphs.
	    	 * The paragraph separator is not added after the last paragraph. The default value is "\n". 
  		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get paragraphSeparator():String
		{ return _paragraphSeparator; }
		public function set paragraphSeparator(value:String):void
		{
			_paragraphSeparator = value;
		}

		/** 
		 * Export the contents of a TextFlow object to plain text.
		 * The values of the <code>paragraphSeparator</code>
		 * and the <code>stripDiscretionaryHyphens</code> properties
		 * affect the output produced by this method.
		 * @param source	the text flow object to export
		 * @param conversionType 	The type to return (STRING_TYPE). This 
		 * parameter accepts only one value: <code>ConversionType.STRING_TYPE</code>,
		 * but is necessary because this class implements the ITextExporter
		 * interface. The interface method, <code>ITextExporter.export()</code>, requires 
		 * this parameter.
		 * @return Object	the exported content
		 * 
		 * @see #paragraphSeparator
		 * @see #stripDiscretionaryHyphens
		 * @see ConversionType#STRING_TYPE
  		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function export(source:TextFlow, conversionType:String):Object
		{
			if (conversionType == ConversionType.STRING_TYPE)
				return exportToString(source);
			return null;
		}
		
		/** Export text content as a string
		 * @param source	the text to export
		 * @return String	the exported content
		 * 
  		 * @private
		 */
		protected function exportToString(source:TextFlow):String
		{
			var rslt:String = "";
			var leaf:FlowLeafElement = source.getFirstLeaf(); 
			
			while (leaf)
			{
            	var p:ParagraphElement = leaf.getParagraph();
            	while (true)
            	{
            		var curString:String = leaf.text;
            		
            		//split out discretionary hyphen and put string back together
            		if (_stripDiscretionaryHyphens)
            		{
						var temparray:Array = curString.split(_discretionaryHyphen);
						curString = temparray.join("");
            		}
					
	               	rslt += curString;
					var nextLeaf:FlowLeafElement = leaf.getNextLeaf(p);
					if (!nextLeaf)
						break; // end of para
					
					leaf = nextLeaf;
            	}
            	
            	leaf = leaf.getNextLeaf();
            	if (leaf) // not the last para
                   	rslt += _paragraphSeparator; 
   			}
   			return rslt;
		}
 	}
}