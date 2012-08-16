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
package flashx.textLayout.elements
{
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormatValueHolder;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	[ExcludeClass]
	/** This class extends TextLayoutFormatValueHolder and add capabilities to hold privateData and userStyles.  @private */
	public class FlowValueHolder extends TextLayoutFormatValueHolder
	{
		private var _userStyles:Object;
		private var _privateData:Object;
		
		public function FlowValueHolder(initialValues:FlowValueHolder = null)
		{
			super(initialValues);
			initialize(initialValues);
		}
		
		private function initialize(initialValues:FlowValueHolder):void
		{
			if (initialValues)
			{
				for (var s:String in initialValues.userStyles)
					writableUserStyles()[s] = initialValues.userStyles[s];
				for (s in initialValues.privateData)
					writablePrivateData()[s] = initialValues.privateData[s];
			}
		}

		private function writableUserStyles():Object
		{ 
			if (_userStyles == null)
				_userStyles = new Object();
			return _userStyles;
		}
			
		public function get userStyles():Object
		{ return _userStyles; }
		public function set userStyles(val:Object):void
		{ _userStyles = val; }

		public function getUserStyle(styleProp:String):*
		{ return _userStyles ? _userStyles[styleProp] : undefined; }
		public function setUserStyle(styleProp:String,newValue:*):void
		{
			CONFIG::debug { assert(TextLayoutFormat.description[styleProp] === undefined,"bad call to setUserStyle"); }
			if (newValue === undefined)
			{
				if (_userStyles)
					delete _userStyles[styleProp];
			}
			else
				writableUserStyles()[styleProp] = newValue;
		}

		private function writablePrivateData():Object
		{
			if (_privateData == null)
				_privateData = new Object();
			return _privateData;
		}

		public function get privateData():Object
		{ return _privateData; }
		public function set privateData(val:Object):void
		{ _privateData = val; }

		public function getPrivateData(styleProp:String):*
		{ return _privateData ? _privateData[styleProp] : undefined; }

		public function setPrivateData(styleProp:String,newValue:*):void
		{
			if (newValue === undefined)
			{
				if (_privateData)
					delete _privateData[styleProp];
			}
			else
				writablePrivateData()[styleProp] = newValue;
		}
	}
}
