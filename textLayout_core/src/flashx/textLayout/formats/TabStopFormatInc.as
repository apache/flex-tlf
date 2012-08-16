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
			return _tabStopFormatValueHolder ? _tabStopFormatValueHolder.position : undefined;
		}
		public function set position(positionValue:*):void
		{
			writableTabStopFormatValueHolder().position = positionValue;
			tabStopFormatChanged();
		}

		/**
		 * TabStopFormat:
		 * The tab alignment for this tab stop. 
		 * <p>Legal values are flash.text.engine.TabAlignment.START, flash.text.engine.TabAlignment.CENTER, flash.text.engine.TabAlignment.END, flash.text.engine.TabAlignment.DECIMAL, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of START.</p>
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
			return _tabStopFormatValueHolder ? _tabStopFormatValueHolder.alignment : undefined;
		}
		public function set alignment(alignmentValue:*):void
		{
			writableTabStopFormatValueHolder().alignment = alignmentValue;
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
			return _tabStopFormatValueHolder ? _tabStopFormatValueHolder.decimalAlignmentToken : undefined;
		}
		public function set decimalAlignmentToken(decimalAlignmentTokenValue:*):void
		{
			writableTabStopFormatValueHolder().decimalAlignmentToken = decimalAlignmentTokenValue;
			tabStopFormatChanged();
		}
