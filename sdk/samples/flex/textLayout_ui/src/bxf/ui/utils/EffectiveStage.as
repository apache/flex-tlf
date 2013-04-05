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
package bxf.ui.utils
{
	import flash.display.DisplayObject;
	
	/**
	 * Finds the effective stage to be used.  Assumes all DisplayObjects share the same stage so once calculated keep using it.
	 */
	
	public function EffectiveStage(obj:DisplayObject):DisplayObject
	{
		// safe to test for stage existence
		if (_effectiveStage == null && obj && obj.stage)
		{
			// if the stage is accessible lets use it.
			try
			{
				var x:int = obj.stage.numChildren;
				_effectiveStage = obj.stage;
			}
			catch(e:Error)
			{
				// TODO: some way to find the highest level accessible root???
				_effectiveStage = obj.root;
			}
		}
		return _effectiveStage;
	}

}

import flash.display.DisplayObject;
var _effectiveStage:DisplayObject = null;
