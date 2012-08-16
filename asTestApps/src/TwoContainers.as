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
	
	import flash.utils.ByteArray;
	import flash.display.Sprite;
	import flashx.textLayout.container.*;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.conversion.*;
	
	[SWF(width="1000", height="500")]
	public class TwoContainers extends Sprite
	{
		[Embed(source="../../test/testFiles/markup/tlf/aliceID.xml",mimeType="application/octet-stream")]
		private var AliceIDClass : Class;
		
		public function TwoContainers()
		{
			var alice:ByteArray = new AliceIDClass();
			var aliceData:String = alice.readMultiByte(alice.length,"utf-8");
			var textImporter:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
			var newFlow:TextFlow = textImporter.importToFlow(aliceData);
			var s:Sprite = new Sprite();
			s.x = 10;
			s.y = 100;
			addChild(s);
			
			var sprite1:Sprite = new Sprite();
			var _cc1:ContainerController = new ContainerController(sprite1, 480, 390);
			var sprite2:Sprite = new Sprite();
			var _cc2:ContainerController = new ContainerController(sprite2, 480, 390);
			sprite2.x = (500);
			s.addChild(sprite1);
			s.addChild(sprite2);
			newFlow.flowComposer.addController(_cc1);
			newFlow.flowComposer.addController(_cc2);
			newFlow.flowComposer.updateAllControllers();
			resizeContainer (_cc1, 639.245850162115, 373.9300443092361);
			resizeContainer (_cc1, 365.48377386061475, 90.32808240735903);
			resizeContainer (_cc1, 538.2365170982666, 117.52467934275046);
			resizeContainer (_cc1, 654.2603318928741, 358.720060007181);
		}
		
		private function resizeContainer(cc:ContainerController, x:Number, y:Number):void
		{
			cc.setCompositionSize(x,y);
			cc.textFlow.flowComposer.updateAllControllers();
		}
	}
}