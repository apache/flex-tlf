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
	 * Interface for importing text content into a TextFlow from an external source. 
	 * @includeExample examples\ITextImporterExample.as -noswf
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	public interface ITextImporter
	{	
		/** 
		 * Import text content from an external source and convert it into a TextFlow.
		 * @param source		Data to convert
		 * @return TextFlow created from the source.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		function importToFlow(source:Object):TextFlow;

		/** 
		 * Errors encountered while parsing. This will be empty if there were no errors.
		 * Value is a vector of Strings.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		function get errors():Vector.<String>;
		
		/** 
		 * Parsing errors during import will cause exceptions if throwOnError is <code>true</code>. 
	 	 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		function get throwOnError():Boolean;
		function set throwOnError(value:Boolean):void;
	}
}