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
	import flash.system.Capabilities;

	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.elements.Configuration;

	public class AccessibleTCM extends Sprite
	{
		public function AccessibleTCM()
		{
			super();

			// TLF only attaches the accesibility object if its available in the Capabilities
			if (Capabilities.hasAccessibility)
				trace("System accessibility available");
			else
				trace("System accessibility NOT available");

			var sprite:Sprite = new Sprite();
			sprite.x = 50; sprite.y = 50;
			addChild(sprite);

			var lorem:String = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

			// create a config that enables accessibility
			var config:Configuration = Configuration(TextContainerManager.defaultConfiguration).clone();
			config.enableAccessibility = true;

			var tcm:TextContainerManager = new TextContainerManager(sprite,config);
			tcm.updateContainer();
			tcm.setText(lorem);
			tcm.updateContainer();

			// no accessibility attached to TCM until its converted to a textflow with a containercontroller.
			// flex team: is this a problem?
			tcm.beginInteraction();
			tcm.endInteraction();

			// only non-null if Capabilities.hasAccessibility is true
			trace(sprite.accessibilityImplementation);

		}
	}

}
