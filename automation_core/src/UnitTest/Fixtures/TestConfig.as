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
package UnitTest.Fixtures
{
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flash.system.Capabilities;

	public class TestConfig
	{
		public var writingDirection:Array = [ BlockProgression.TB, Direction.LTR ] ;
		public var containerType:String = "flex";
		public var doBeforeAfterCompare:Boolean = false;
		public var useEmbeddedFonts:Boolean = false;
		public var baseURL:String = "";
		public var flashVersion:String = Capabilities.version.substr(4,4);

		public function TestConfig()
		{
		}

		public function copyTestConfig():TestConfig
		{
			var newConfig:TestConfig = new TestConfig();
			newConfig.writingDirection = writingDirection;
			newConfig.containerType = containerType;
			newConfig.doBeforeAfterCompare = doBeforeAfterCompare;
			newConfig.useEmbeddedFonts = useEmbeddedFonts;
			newConfig.baseURL = baseURL;
			newConfig.flashVersion = flashVersion;
			return newConfig;
		}

	}
}
