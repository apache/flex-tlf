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
package flashx.textLayout.ui.inspectors
{
	import flashx.textLayout.formats.ListStyleType;
	import flashx.textLayout.formats.Suffix;

	public class ListPropertyEditor extends DynamicTextPropertyEditor
	{
		[Embed(source="./assets/removeList.png")]
		private var removeListIcon:Class;

		[Embed(source="./assets/numberedList.png")]
		private var numberedListIcon:Class;

		[Embed(source="./assets/unnumberedList.png")]
		private var unnumberedListIcon:Class;

		public function ListPropertyEditor()
		{
			var recipe:XML =
				<recipe>
					<row>
						<editor type="multiIconButton" style="iconButtonGroup" label="$$$/stage/TextEditing/Label/List Type=">
							<property name={TextInspectorController.LIST_UIPROP}/>
							<button icon="removeListIcon" value="removeList"/>
							<button icon="unnumberedListIcon" value="unnumberedList"/>
							<button icon="numberedListIcon" value="numberedList"/>
						</editor>
						<editor type="combo" label="$$$/stage/TextEditing/Label/listStylePosition=Position:">
							<property name={TextInspectorController.LIST_STYLE_POSITION_UIPROP}/>
							<choice display="inside" value={flashx.textLayout.formats.ListStylePosition.INSIDE}/>
							<choice display="outside" value={flashx.textLayout.formats.ListStylePosition.OUTSIDE}/>
						</editor>
					</row>
					<row>
						<editor type="combo" label="$$$/stage/TextEditing/Label/listStyleType=Type:">
							<property name={TextInspectorController.LIST_STYLE_TYPE_UIPROP}/>
							<choice display="upperAlpha" value={flashx.textLayout.formats.ListStyleType.UPPER_ALPHA}/>
							<choice display="lowerAlpha" value={flashx.textLayout.formats.ListStyleType.LOWER_ALPHA}/>
							<choice display="upperRoman" value={flashx.textLayout.formats.ListStyleType.UPPER_ROMAN}/>
							<choice display="lowerRoman" value={flashx.textLayout.formats.ListStyleType.LOWER_ROMAN}/>
							<choice display="none" value={flashx.textLayout.formats.ListStyleType.NONE}/>
							<choice display="disc" value={flashx.textLayout.formats.ListStyleType.DISC}/>
							<choice display="circle" value={flashx.textLayout.formats.ListStyleType.CIRCLE}/>
							<choice display="square" value={flashx.textLayout.formats.ListStyleType.SQUARE}/>
							<choice display="box" value={flashx.textLayout.formats.ListStyleType.BOX}/>
							<choice display="check" value={flashx.textLayout.formats.ListStyleType.CHECK}/>
							<choice display="diamond" value={flashx.textLayout.formats.ListStyleType.DIAMOND}/>
							<choice display="hyphen" value={flashx.textLayout.formats.ListStyleType.HYPHEN}/>
							<choice display="arabicIndic" value={flashx.textLayout.formats.ListStyleType.ARABIC_INDIC}/>
							<choice display="bengali" value={flashx.textLayout.formats.ListStyleType.BENGALI}/>
							<choice display="decimal" value={flashx.textLayout.formats.ListStyleType.DECIMAL}/>
							<choice display="decimalLeadingZero" value={flashx.textLayout.formats.ListStyleType.DECIMAL_LEADING_ZERO}/>
							<choice display="devanagari" value={flashx.textLayout.formats.ListStyleType.DEVANAGARI}/>
							<choice display="gujarati" value={flashx.textLayout.formats.ListStyleType.GUJARATI}/>
							<choice display="gurmukhi" value={flashx.textLayout.formats.ListStyleType.GURMUKHI}/>
							<choice display="kannada" value={flashx.textLayout.formats.ListStyleType.KANNADA}/>
							<choice display="persian" value={flashx.textLayout.formats.ListStyleType.PERSIAN}/>
							<choice display="thai" value={flashx.textLayout.formats.ListStyleType.THAI}/>
							<choice display="urdu" value={flashx.textLayout.formats.ListStyleType.URDU}/>
							<choice display="cjkEarthlyBranch" value={flashx.textLayout.formats.ListStyleType.CJK_EARTHLY_BRANCH}/>
							<choice display="cjkHeavenlyStem" value={flashx.textLayout.formats.ListStyleType.CJK_HEAVENLY_STEM}/>
							<choice display="hangul" value={flashx.textLayout.formats.ListStyleType.HANGUL}/>
							<choice display="hangulConstant" value={flashx.textLayout.formats.ListStyleType.HANGUL_CONSTANT}/>
							<choice display="hiragana" value={flashx.textLayout.formats.ListStyleType.HIRAGANA}/>
							<choice display="hiraganaIroha" value={flashx.textLayout.formats.ListStyleType.HIRAGANA_IROHA}/>
							<choice display="katakana" value={flashx.textLayout.formats.ListStyleType.KATAKANA}/>
							<choice display="katakanaIroha" value={flashx.textLayout.formats.ListStyleType.KATAKANA_IROHA}/>
							<choice display="lowerGreek" value={flashx.textLayout.formats.ListStyleType.LOWER_GREEK}/>
							<choice display="lowerLatin" value={flashx.textLayout.formats.ListStyleType.LOWER_LATIN}/>
							<choice display="upperGreek" value={flashx.textLayout.formats.ListStyleType.UPPER_GREEK}/>
							<choice display="upperLatin" value={flashx.textLayout.formats.ListStyleType.UPPER_LATIN}/>
						</editor>
						<editor type="combo" label="$$$/stage/TextEditing/Label/suffix=Suffix:">
							<property name={TextInspectorController.LIST_SUFFIX_UIPROP}/>
							<choice display="none" value={flashx.textLayout.formats.Suffix.NONE}/>
							<choice display="auto" value={flashx.textLayout.formats.Suffix.AUTO}/>
						</editor>
					</row> 
					<row>
						<editor type="string" label="$$$/stage/TextEditing/Label/beforeContent=Before:" width="150">
							<property name={TextInspectorController.LIST_BEFORE_CONTENT_UIPROP}/>
						</editor>
					</row> 
					<row>
						<editor type="string" label="$$$/stage/TextEditing/Label/afterContent=After:" width="150">
							<property name={TextInspectorController.LIST_AFTER_CONTENT_UIPROP}/>
						</editor>
					</row> 
				</recipe>;
			super(recipe);
			
			SetIcon("removeListIcon", removeListIcon);
			SetIcon("unnumberedListIcon", unnumberedListIcon);
			SetIcon("numberedListIcon", numberedListIcon);
		}
		
	}
}
