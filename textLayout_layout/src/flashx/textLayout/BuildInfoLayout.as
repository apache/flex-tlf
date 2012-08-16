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
package flashx.textLayout
{
	/**
	 * Contains identifying information for the current build. 
	 * This may not be the form that this information is presented in the final API.
	 */
	public class BuildInfoLayout
	{		
		[ExcludeClass]
		/**
		 * Contains the current version number. 
		 */
		public static const VERSION:String = "1.0";
		
		/**
		 * Contains the current build number. 
		 * It is static and can be called with <code>BuildInfo.kBuildNumber</code>
		 * <p>String Format: "BuildNumber (Changelist)"</p>
		 */
		public static const kBuildNumber:String = "595 (738907)";
		
		/**
		 * Contains the branch name. 
		 */
		public static const kBranch:String = "1.0";

		/**
		 * @private 
		 */
		public static const AUDIT_ID:String = "";
		
		/**
		 * @private 
		 */
		public function dontStripAuditID():String
		{
			return AUDIT_ID;
		}
	}
}

