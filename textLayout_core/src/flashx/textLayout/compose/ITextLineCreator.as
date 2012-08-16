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
package flashx.textLayout.compose
{
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	/** 
	 * ITextLineCreator defines an interface for creating TextLine objects for an IFlowComposer instance.
	 * 
	 * <p>The ITextLineCreator interface wraps the FTE line creation methods.
	 * There are basically two reasons why an application might want to use 
	 * this interface to control the line creation. First,
	 * if the application has a SWF that contains a font, and you want to 
	 * use that font from a different SWF, you can reuse the
	 * font if the TextLine was created from the same SWF that has the font. 
	 * Second, you can get a faster recompose time by reusing 
	 * existing TextLines. TLF does that internally, and when it is reusing 
	 * it will call recreateTextLine instead of createTextLine.
	 * Your application may have additional TextLines that it knows can be reused. 
	 * If so, in your implementation of createTextLine,
	 * you may call TextBlock.recreateTextLine with the line to be reused instead 
	 * of TextBlock.createTextLine.</p>
	 *
	 * @see flast.text.engine.TextLine
	 * @see flashx.textLayout.compose.IFlowComposer
	 * @see flashx.textLayout.elements.TextFlow TextFlow
	 * 
	 * @includeExample examples\ITextLineCreator_ClassExample.as -noswf
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	public interface ITextLineCreator
	{
		/** 
		 * Creates a TextLine object for a flow composer.
		 * 
		 * <p>Called by a flow composer when a text line must be created.</p>
		 * 
		 * @param textBlock The TextBlock object for which the line is to be created.
		 * @param previousLine The previous line created for the TextBlock, if any.
		 * @param width The maximum width of the line.
		 * @param lineOffset An optional offset value.
		 * @param fitSomething If <code>true</code>, at least one character or inline graphic must be fit on the line
		 * even if that element causes the line to exceed the value in the <code>width</code> parameter.
		 * 
		 * @return TextLine the created TextLine object
		 *  
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		function createTextLine(textBlock:TextBlock, previousLine:TextLine = null, width:Number = 1000000, lineOffset:Number = 0.0, fitSomething:Boolean = false):TextLine

		/** 
		 * Recreates a TextLine object for a flow composer.
		 * 
		 * <p>Called by a flow composer when a text line must be recreated.</p>
		 * 
		 * <p><b>Note:</b> The TextBlock <code>recreateTextLine()</code> method is available starting in
		 * Flash Player 10.1 and AIR 2.0. To implement this method so that it is compatible with
		 * earlier runtimes, test for the existence of the <code>recreateTextLine()</code> method 
		 * on the TextBlock object before calling it.</p>
		 *  
		 * @param textBlock The TextBlock object for which the line is to be created.
		 * @param previousLine The previous line created for the TextBlock, if any.
		 * @param width The maximum width of the line.
		 * @param lineOffset An optional offset value.
		 * @param fitSomething If <code>true</code>, at least one character or inline graphic must be fit on the line
		 * even if that element causes the line to exceed the value in the <code>width</code> parameter.
		 * 
		 * @return TextLine the recreated TextLine object
		 * 
		 * @includeExample examples\ITextLineCreator_recreateTextLine.as -noswf
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
	 	 * @langversion 3.0
	 	 */
		function recreateTextLine(textBlock:TextBlock, textLine:TextLine, previousLine:TextLine = null, width:Number = 1000000, lineOffset:Number = 0.0, fitSomething:Boolean = false):TextLine

	}
}