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
package {
	import flash.display.Sprite;
	
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flash.text.engine.TextLine;
	import flash.geom.Rectangle;

	/** "Hello, World" text example for a single paragraph of static text */
	public class StaticHelloWorld extends Sprite
	{
		public function StaticHelloWorld()
		{
			var characterFormat:TextLayoutFormat = new TextLayoutFormat();
			characterFormat.fontSize = 48;
			var factory:StringTextLineFactory = new StringTextLineFactory();
			factory.text = "Hello, world";
			factory.compositionBounds = new Rectangle(0,0,300,100);
			factory.spanFormat = characterFormat;
			factory.createTextLines(callback);

			function callback(tl:TextLine):void
			{ 
				addChild(tl); 
			}
		}

		
	}		
}
