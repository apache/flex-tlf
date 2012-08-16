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
package flashx.textLayout.container
{
	import flash.display.Sprite;

[ExcludeClass]
	/** @private */
	public class TextLayoutBaseContainer extends Sprite
	{
		/////////////////////////////////////////////////////////////////////////
		//  Width and Height
		/////////////////////////////////////////////////////////////////////////

		private var _width:Number;
		private var _height:Number;

		// This constructor function is here just to silence a compile warning in Eclipse. There
		// appears to be no way to turn the warning off selectively.
		CONFIG::debug public function TextLayoutBaseContainer()
		{
			super();
		}
		
		/** @private */
		override public function get width():Number
		{
			return _width;
		}

		/** @private */
		override public function set width(value:Number):void
		{
			_width = value;
		}

		/** @private */
		override public function get height():Number
		{
			return _height;
		}

		/** @private */
		override public function set height(value:Number):void
		{
			_height = value;
		}

		public function validateSize(recursive:Boolean = false):void
		{
			// override		
		}
		
		public function validateNow():void
		{
			
		}
	}
}