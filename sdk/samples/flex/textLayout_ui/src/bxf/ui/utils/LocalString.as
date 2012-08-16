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
	
	/**
	 * Hides the messiness of going and finding the app controller and asking it to localize for us.
	 */
	public function LocalString(val:String):String
	{
		// Just assume it's a zString and return the last bit, for now. 
		if (val != null) {
			var equalSign:Number = val.indexOf("=");
			if (equalSign >= 0 && val.length > 1) {
				return val.substr(equalSign + 1);
			}
		}
		
		return val;
	}

}
