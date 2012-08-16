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
	import flashx.textLayout.elements.TextFlow;
	
	/** 
	 * Interface for exporting text content from a 
	 * TextFlow instance to either String or XML format. 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
	 */
	public interface ITextExporter
	{	
		/** 
		 * Export text content from a TextFlow instance in String or XML format.
		 * <p>Set the <code>conversionType</code> parameter to either of the following values:
		 * <ul>
		 *   <li><code>flashx.textLayout.conversion.ConversionType.STRING_TYPE</code>;</li>
		 *   <li><code>flashx.textLayout.conversion.ConversionType.XML_TYPE</code>.</li>
		 * </ul>
		 * </p>
		 * @param source	The TextFlow to export
		 * @param conversionType 	Return a String (STRING_TYPE) or XML (XML_TYPE).
		 * @return Object	The exported content
		 * @includeExample examples\ITextExporterExample.as -noswf
		 * @see flashx.textLayout.conversion.ConversionType
	 	 * @playerversion Flash 10
	 	 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		function export(source:TextFlow, conversionType:String):Object;
	}
}
