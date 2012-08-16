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
package flashx.textLayout.utils
{
	[ExcludeClass]
	/** @private
	 * Internally, we work with Twips, which we consider to be 1/20 of
	 * a pixel. This is the same measurement as used within FTE (see the
	 * kTwipsPerPixel constant in flash/core/edittext.h).
	 * 
	 * Note that conversion between Pixels and Twips does not round-trip
	 * due to the loss of precision in the conversion to Twips.
	 */
	public final class Twips
	{
		public static const ONE_TWIP:Number = .05;
		public static const TWIPS_PER_PIXEL:int = 20;
		
		/// Convert Pixels to Twips (truncated)
		public static function to(n:Number):int
		{
			return int(n * 20);
		}
		
		/// Convert Twips to pixels
		public static function from(t:int):Number
		{
			return Number(t) / 20;
		}
		
		/// Convert Pixels to Twips (rounded)
		public static function round(n:Number):int
		{
			return int(Math.round(n) * 20);
		}
		
		/** ceil a number to the nearest twip */
		public static function ceil(n:Number):Number
		{
			return Math.ceil(n*20.0)/20.0;
		}
		/** floor a number to the nearest twip */
		public static function floor(n:Number):Number
		{
			return Math.floor(n*20.0)/20.0;
		}
	}
}
