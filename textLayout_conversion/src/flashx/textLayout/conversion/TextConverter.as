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
package flashx.textLayout.conversion
{
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.elements.IConfiguration;
	
	/** 
	 * This is the gateway class for handling import and export. It serves as a unified access point to the 
	 * conversion functionality in the Text Layout Framework.
	 * @includeExample examples\TextConverter_example.as -noswf
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	public class TextConverter
	{
		/** 
		 * HTML format.
		 * Use this for importing from, or exporting to, a TextFlow using the HTML fomat.
		 * The Text Layout Framework HTML supports a subset of the tags and attributes supported by
		 * the TextField class in the <code>flash.text</code> package.
		 * <p>The following table lists the HTML tags and attributes supported for the import
		 * and export process (tags and attributes supported by TextField, but not supported by 
		 * the Text Layout Framework are specifically described as not supported):</p>
		 * 
		 * 
		 * <table class="innertable" width="640">
		 * 
		 * <tr>
		 * 
		 * <th>
		 * Tag
		 * </th>
		 * 
		 * <th>
		 * Description
		 * </th>
		 * 
		 * </tr>
		 * 
		 * <tr>
		 * 
		 * <td>
		 * Anchor tag
		 * </td>
		 * 
		 * <td>
		 * The <code>&lt;a&gt;</code> tag creates a hypertext link and supports the following attributes:
		 * <ul>
		 * 
		 * <li>
		 * <code>target</code>: Specifies the name of the target window where you load the page. 
		 * Options include <code>_self</code>, <code>_blank</code>, <code>_parent</code>, and 
		 * <code>_top</code>. The <code>_self</code> option specifies the current frame in the current window, 
		 * <code>_blank</code> specifies a new window, <code>_parent</code> specifies the parent of the 
		 * current frame, and <code>_top</code> specifies the top-level frame in the current window. 
		 * </li>
		 *
		 * <li>
		 * <code>href</code>: Specifies a URL. The URL can 
		 * be either absolute or relative to the location of the SWF file that 
		 * is loading the page. An example of an absolute reference to a URL is 
		 * <code>http://www.adobe.com</code>; an example of a relative reference is 
		 * <code>/index.html</code>. Absolute URLs must be prefixed with 
		 * http://; otherwise, Flash treats them as relative URLs. 
		 * <strong>Note: Unlike the TextField class, </strong>ActionScript <code>link</code> events 
		 * are not supported. Neither are
		 * <code>a:link</code>, <code>a:hover</code>, and <code>a:active</code> styles.
		 * </li>
		 * 
		 * </ul>
		 * 
		 * </td>
		 * </tr>
		 * 
		 * <tr>
		 * 
		 * <td>
		 * Bold tag
		 * </td>
		 * 
		 * <td>
		 * The <code>&lt;b&gt;</code> tag renders text as bold. A bold typeface must be available for the font used.
		 * </td>
		 * </tr>
		 * 
		 * <tr>
		 * 
		 * <td>
		 * Break tag
		 * </td>
		 * <td>
		 * The <code>&lt;br&gt;</code> tag creates a line break in the text.
		 * </td>
		 * </tr>
		 * 
		 * <tr>
		 * 
		 * <td>
		 * Font tag
		 * </td>
		 * 
		 * <td>
		 * The <code>&lt;font&gt;</code> tag specifies a font or list of fonts to display the text.The font tag 
		 * supports the following attributes:
		 * <ul>
		 * 
		 * <li>
		 * <code>color</code>: Only hexadecimal color (<code>#FFFFFF</code>) values are supported. 
		 * </li>
		 * 
		 * <li>
		 * <code>face</code>: Specifies the name of the font to use. As shown in the following example, 
		 * you can specify a list of comma-delimited font names, in which case Flash Player selects the first available 
		 * font. If the specified font is not installed on the local computer system or isn't embedded in the SWF file, 
		 * Flash Player selects a substitute font. 
		 * </li>
		 * 
		 * <li>
		 * <code>size</code>: Specifies the size of the font. You can use absolute pixel sizes, such as 16 or 18 
		 * or relative point sizes, such as +2 or -4. 
		 * </li>
		 * 
		 * <li>
		 * <code>letterspacing</code>: Specifies the tracking (manual kerning) in pixels to be applied to the right of each character. 
		 * </li>
		 * 
		 * <li>
		 * <code>kerning</code>: Specifies whether kerning is enabled or disabled. A non-zero value enables kerning, while zero disables it.  
		 * </li>
		 * 
		 * </ul>
		 * 
		 * </td>
		 * </tr>
		 * 
		 * <tr>
		 * 
		 * <td>
		 * Image tag
		 * </td>
		 * 
		 * <td>
		 * The <code>&lt;img&gt;</code> tag lets you embed external image files (JPEG, GIF, PNG), SWF files, and 
		 * movie clips inside text.  
		 * 
		 *  <p>The <code>&lt;img&gt;</code> tag supports the following attributes: </p>
		 * 
		 * <ul >
		 * 
		 * <li>
		 * <code>src</code>: Specifies the URL to an image or SWF file, or the linkage identifier for a movie clip 
		 * symbol in the library. This attribute is required; all other attributes are optional. External files (JPEG, GIF, PNG, 
		 * and SWF files) do not show until they are downloaded completely. 
		 * </li>
		 * 
		 * <li>
		 * <code>width</code>: The width of the image, SWF file, or movie clip being inserted, in pixels. 
		 * </li>
		 * 
		 * <li>
		 * <code>height</code>: The height of the image, SWF file, or movie clip being inserted, in pixels. 
		 * </li>
		 * </ul>
		 * <p><strong>Note: </strong> Unlike the TextField class, the following attributes are not supported:
		 * <code>align</code>, <code>hspace</code>, <code>vspace</code>,  <code>id</code>, and <code>checkPolicyFile</code>.</p>
		 *
		 * </td>
		 * </tr>
		 * 
		 * <tr>
		 * 
		 * <td>
		 * Italic tag
		 * </td>
		 * 
		 * <td>
		 * The <code>&lt;i&gt;</code> tag displays the tagged text in italics. An italic typeface must be available 
		 * for the font used.
		 * </td>
		 * </tr>
		 * 
		 * <tr>
		 * 
		 * <td>
		 * <em>List item tag</em>
		 * </td>
		 * 
		 * <td>
		 * <strong>Note: </strong> Unlike the TextField class, the List item tag is not supported.
		 * </td>
		 * </tr>
		 * 
		 * <tr>
		 * 
		 * <td>
		 * Paragraph tag
		 * </td>
		 * 
		 * <td>
		 * The <code>&lt;p&gt;</code> tag creates a new paragraph. 
		 * 
		 * The <code>&lt;p&gt;</code> tag supports the following attributes:
		 * <ul >
		 * 
		 * <li>
		 * align: Specifies alignment of text within the paragraph; valid values are <code>left</code>, <code>right</code>, <code>justify</code>, and <code>center</code>. 
		 * </li>
		 * 
		 * <li>
		 * class: Specifies a class name that can be used for styling 
		 * </li>
		 * 
		 * </ul>
		 * 
		 * </td>
		 * </tr>
		 * 
		 * <tr>
		 * 
		 * <td>
		 * Span tag
		 * </td>
		 * 
		 * <td>
		 * 
		 * The <code>&lt;span&gt;</code> tag supports the following attributes:
		 * 
		 * <ul>
		 * 
		 * <li>
		 * class: Specifies a class name that can be used for styling. While span tags are often used to set a style defined in a style sheet,
		 * TLFTextField instances do not support style sheets. The span tag is available for TLFTextField instances to refer to a class with 
		 * style properties.</li>
		 * <li> You can also put properties directly in the span tag: 
		 * <code>&lt;span fontFamily="Arial"&gt;Hi there&lt;/span&gt;</code>. However, nested span tags are not supported.
		 * </li>
		 * 
		 * </ul>
		 * 
		 * </td>
		 * </tr>
		 * 
		 * <tr>
		 * 
		 * <td>
		 * Text format tag
		 * </td>
		 * 
		 * <td>
		 *  <p>The <code>&lt;textformat&gt;</code> tag lets you use a subset of paragraph formatting 
		 * properties of the TextFormat class within text fields, including line leading, indentation, 
		 * margins, and tab stops. You can combine <code>&lt;textformat&gt;</code> tags with the 
		 * built-in HTML tags. </p>
		 * 
		 *  <p>The <code>&lt;textformat&gt;</code> tag has the following attributes: </p>
		 * <ul >
		 * 
		 * 
		 * <li>
		 * <code>indent</code>: Specifies the indentation from the left margin to the first character 
		 * in the paragraph; corresponds to <code>TextFormat.indent</code>. Both positive and negative 
		 * numbers are acceptable. 
		 * </li>
		 * 
		 * <li>
		 * <code>blockindent</code>: Specifies the indentation applied to all lines of the paragraph.
		 * </li>
		 * 
		 * <li>
		 * <code>leftmargin</code>: Specifies the left margin of the paragraph, in points; corresponds 
		 * to <code>TextFormat.leftMargin</code>. 
		 * </li>
		 * 
		 * <li>
		 * <code>rightmargin</code>: Specifies the right margin of the paragraph, in points; corresponds 
		 * to <code>TextFormat.rightMargin</code>. 
		 * </li>
		 * 
		 * 	<li>
		 * <code>leading</code>: Specifies the leading (line height) measured in pixels between a line's ascent and the previous line's descent
		 * </li>
		 * 
		 * 	<li>
		 * <code>tabstops</code>: Specifies a comma-separated list of tab stop positions for the paragraph. 
		 * </li>
		 * </ul>
		 * 
		 * </td>
		 * </tr>
		 * 
		 * <tr>
		 * 
		 * <td>
		 * Underline tag
		 * </td>
		 * 
		 * <td>
		 * The <code>&lt;u&gt;</code> tag underlines the tagged text.
		 * </td>
		 * </tr>
		 * 
		 * </table>

		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 */
		public static const TEXT_FIELD_HTML_FORMAT:String = "textFieldHTMLFormat";

		/** 
		 * Plain text format.
		 * Use this for creating a TextFlow from a simple, unformatted String, 
		 * or for creating a simple, unformatted String from a TextFlow.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 */
		public static const PLAIN_TEXT_FORMAT:String = "plainTextFormat";

		/** 
		 * TextLayout Format.
		 * Use this for importing from, or exporting to, a TextFlow using the TextLayout markup format.
		 * Text Layout format will detect the following errors:
		 * <ul>
		 * <li>Unexpected namespace</li>
		 * <li>Unknown element</li>
		 * <li>Unknown attribute</li>
		 * </ul>
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 */
		public static const TEXT_LAYOUT_FORMAT:String = "textLayoutFormat";
	
		/** 
		 * Creates a TextFlow from source content in a specified format.
		 * Supported formats include HTML, plain text, and TextLayout Markup.
		 * <p>Use one of the four static constants supplied with this class
		 * to specify the <code>format</code> parameter:
		 * <ul>
		 * <li>TextConverter.TEXT_FIELD_HTML_FORMAT</li>
		 * <li>TextConverter.PLAIN_TEXT_FORMAT</li>
		 * <li>TextConverter.TEXT_LAYOUT_FORMAT</li>
		 * </ul>
		 * </p>
		 * @param source	Source content
		 * @param format	Format of source content
		 * @param config    IConfiguration to use when creating new TextFlows
		 * @return TextFlow that was created from the source.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 * @see #TEXT_FIELD_HTML_FORMAT
		 * @see #PLAIN_TEXT_FORMAT
		 * @see #TEXT_LAYOUT_FORMAT
		 */
		public static function importToFlow(source:Object, format:String, config:IConfiguration = null) : TextFlow
		{
			var parser:ITextImporter = getImporter(format, config);
			return parser.importToFlow(source);
		}
		
		/** 
		 * Exports a TextFlow to a specified format. Supported formats
		 * include FXG, HTML, plain text, and TextLayout Markup.
		 * <p>Use one of the four static constants supplied with this class
		 * to specify the <code>format</code> parameter:
		 * <ul>
		 * <li>TextConverter.TEXT_FIELD_HTML_FORMAT</li>
		 * <li>TextConverter.PLAIN_TEXT_FORMAT</li>
		 * <li>TextConverter.TEXT_LAYOUT_FORMAT</li>
		 * </ul>
		 * </p>
		 * <p>Specify the type of the exported data in the <code>conversionType</code> parameter 
		 * with one of the two static constants supplied by the ConversionType class:
		 * <ul>
		 * <li>ConversionType.STRING_TYPE</li>
		 * <li>ConversionType.XML_TYPE</li>
		 * </ul>
		 * </p>
		 * 
		 * Returns a representation of the TextFlow in the specified format.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 * @param source	Source content
		 * @param format	Output format
		 * @param conversionType	Type of exported data
		 * @return Object	Exported form of the TextFlow
		 * @see #TEXT_FIELD_HTML_FORMAT
		 * @see #PLAIN_TEXT_FORMAT
		 * @see #TEXT_LAYOUT_FORMAT
		 * @see flashx.textLayout.conversion.ConversionType
		 */
		public static function export(source:TextFlow, format:String, conversionType:String) : Object
		{
			var exporter:ITextExporter = getExporter(format);
			return exporter.export(source, conversionType);
		}
		
		/** 
		 * Creates an import filter. 
		 * Returns an import filter, which you can then use to import from a 
		 * source string or XML object to a TextFlow. Use this function
		 * if you have many separate imports to perform, or if you want to 
		 * handle errors during import. It is equivalent to calling 
		 * <code>flashx.textLayout.conversion.TextConverter.importToFlow()</code>.
		 * <p>Use one of the four static constants supplied with this class
		 * to specify the <code>format</code> parameter:
		 * <ul>
		 * <li>TextConverter.TEXT_FIELD_HTML_FORMAT</li>
		 * <li>TextConverter.PLAIN_TEXT_FORMAT</li>
		 * <li>TextConverter.TEXT_LAYOUT_FORMAT</li>
		 * </ul>
		 * </p>
		 * @includeExample examples\getImporter_example.as -noswf
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 * @param format	Format of source content.  Use constants from flashx.textLayout.conversion.TextConverter.TEXT_LAYOUT_FORMAT, PLAIN_TEXT_FORMAT, TEXT_FIELD_HTML_FORMAT etc.
		 * @param config    configuration to use during this import.  null means take the current default.
		 * @return ITextImporter	Text filter that can import the source data
		 * @see #TEXT_FIELD_HTML_FORMAT
		 * @see #PLAIN_TEXT_FORMAT
		 * @see #TEXT_LAYOUT_FORMAT
		 */
		public static function getImporter(format:String,config:IConfiguration =  null): ITextImporter
		{
			switch (format)
			{
				case TEXT_LAYOUT_FORMAT:
					return new TextLayoutImporter(config);
				case PLAIN_TEXT_FORMAT:
					return new PlainTextImporter(config);
				case TEXT_FIELD_HTML_FORMAT:
					return new HtmlImporter(config);
			}
			return null;
		}

		/** 
		 * Creates an export filter.
		 * Returns an export filter, which you can then use to export from 
		 * a TextFlow to a source string or XML object. Use this function if 
		 * you have many separate exports to perform. It is equivalent to calling 
		 * <code>flashx.textLayout.conversion.TextConverter.export()</code>.
		 * <p>Use one of the four static constants supplied with this class
		 * to specify the <code>format</code> parameter:
		 * <ul>
		 * <li>TextConverter.TEXT_FIELD_HTML_FORMAT</li>
		 * <li>TextConverter.PLAIN_TEXT_FORMAT</li>
		 * <li>TextConverter.TEXT_LAYOUT_FORMAT</li>
		 * </ul>
		 * </p>
		 * @includeExample examples\getExporter_example.as -noswf
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0 
		 * @param format	Target format for exported data
		 * @return ITextExporter	Text filter that can export in the specified format
		 * @see #TEXT_FIELD_HTML_FORMAT
		 * @see #PLAIN_TEXT_FORMAT
		 * @see #TEXT_LAYOUT_FORMAT
		 */
		public static function getExporter(format:String) : ITextExporter
		{
			switch (format)
			{
				case TEXT_LAYOUT_FORMAT:
					return new TextLayoutExporter();
				case PLAIN_TEXT_FORMAT:
					return new PlainTextExporter();
				case TEXT_FIELD_HTML_FORMAT:
					return new HtmlExporter();
			}
			
			return null;
		}
	}
}
