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
		public function get position():*
		{
			return _tabStopFormat ? _tabStopFormat.position : undefined;
		}
		public function set position(positionValue:*):void
		{
			writableTabStopFormat().position = positionValue;
			tabStopFormatChanged();
		}

		[Inspectable(enumeration="start,center,end,decimal,inherit")]
		/**
		 * TabStopFormat:
		 * The tab alignment for this tab stop. 
		 * <p>Legal values are TabAlignment.START, TabAlignment.CENTER, TabAlignment.END, TabAlignment.DECIMAL, FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of TabAlignment.START.</p>
		 * @see FormatValue#INHERIT
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.TabAlignment
		 */
		public function get alignment():*
		{
			return _tabStopFormat ? _tabStopFormat.alignment : undefined;
		}
		public function set alignment(alignmentValue:*):void
		{
			writableTabStopFormat().alignment = alignmentValue;
			tabStopFormatChanged();
		}

		/**
		 * TabStopFormat:
		 * The alignment token to be used if the alignment is DECIMAL.
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of null.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get decimalAlignmentToken():*
		{
			return _tabStopFormat ? _tabStopFormat.decimalAlignmentToken : undefined;
		}
		public function set decimalAlignmentToken(decimalAlignmentTokenValue:*):void
		{
			writableTabStopFormat().decimalAlignmentToken = decimalAlignmentTokenValue;
			tabStopFormatChanged();
		}
