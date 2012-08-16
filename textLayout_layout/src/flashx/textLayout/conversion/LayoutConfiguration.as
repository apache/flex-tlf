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
	import flashx.textLayout.compose.LayoutComposeState;
	import flashx.textLayout.compose.LayoutFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.TextFlow;
	
	
	public class LayoutConfiguration 
	{

		static public function isLayoutComposer(controllerClass:Class) : Boolean
		{
			return controllerClass == LayoutFlowComposer;
		}		
		
		/** Set LayoutConfiguration as the default. This updates both the default TextFlow Configuration and the ImportExport configuration for layout support */
		static public function SetLayoutConfigurationAsDefault():void
		{
			TextLayoutImporter.restoreDefaults();
			var config:ImportExportConfiguration = TextLayoutImporter.defaultConfiguration;

			TextFlow.defaultConfiguration.flowComposerClass = LayoutFlowComposer;
		}
	}
}