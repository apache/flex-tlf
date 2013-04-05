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
package UnitTest.Validation
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	import flash.system.*;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextRotation;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.factory.StringTextLineFactory;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.Float;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.VerticalAlign;
	import flashx.textLayout.tlf_internal;
	
	import flexunit.framework.Assert;
	
	import mx.core.UIComponent;

	use namespace tlf_internal;

	/** Check a sample text composition result to make sure:
	 * (1) The text falls in the correct area of the container, given the vertical and horizontal alignment values applied to the TextFlow;
	 * (2) That the content bounds is no smaller than the inked bounds
	 * (3) That the full compose content bounds matches the factory content bounds (or has only fractional differences). Note that the inked bounds may be smaller
	 * 	   than the content bounds because (for example) padding or indents have been applied.
	 */
	public class BoundsChecker
	{
		
		private static var textFlowFactory:TextFlowTextLineFactory = null;
		
		public static function validateAll(textFlow:TextFlow, parent:Sprite, marginOfError:Number=5, checkFactory:Boolean=true):void
		{
			// is this for validateContentBounds use only, or
			// are there invalid flows for validateAlignment?
			if (!flowIsWithinTestableBounds(textFlow))
				return;

			var controller:ContainerController = textFlow.flowComposer.getControllerAt(0);
			if (!controller || !controller.container && controller.container.parent != parent)
				return;
			
			var compositionBounds:Rectangle = new Rectangle(0, 0, controller.compositionWidth, controller.compositionHeight);
			var blockProgression:String = textFlow.computedFormat.blockProgression;
			
			var contentBounds:Rectangle = controller.getContentBounds();
			validateContentBounds(controller.container, contentBounds, "composer", marginOfError);
			if (blockProgression == BlockProgression.RL && controller.horizontalScrollPolicy != ScrollPolicy.OFF && controller.verticalScrollPolicy != ScrollPolicy.OFF)
			{
				// content bounds will have origin on the right at zero, factory content bounds will not, and compositionBounds will not. we adjust for this here.
				contentBounds.offset(compositionBounds.width, 0);
			}
			validateAlignment(textFlow.computedFormat.verticalAlign, textFlow.computedFormat.textAlign, textFlow, compositionBounds, contentBounds, false /*contentExpectedToFit*/, 5);
			
			if (checkFactory)
			{
				if (!textFlowFactory)
					textFlowFactory = new TextFlowTextLineFactory();
				var factorySprite:Sprite = addTextFactoryFromFlowSprite(textFlowFactory, compositionBounds.width, compositionBounds.height,textFlow);
				parent.addChild(factorySprite);		// so that bounds calculations work
				var factoryContentBounds:Rectangle = textFlowFactory.getContentBounds();
				validateContentBounds(factorySprite, factoryContentBounds, "factory", marginOfError);
				// Factory content bounds should only be fractionally different than full compose content bounds
				Assert.assertTrue("Factory compose got different content bounds than full compose", Math.abs(contentBounds.left - factoryContentBounds.left) < 1,
					Math.abs(contentBounds.top - factoryContentBounds.top) < 1,Math.abs(contentBounds.right - factoryContentBounds.right) < 1,Math.abs(contentBounds.bottom - factoryContentBounds.bottom) < 1);
				parent.removeChild(factorySprite);	
				// Clean up
				textFlow.flowComposer = new StandardFlowComposer();		
			}
		}
		
		private static function flowIsWithinTestableBounds(textFlow:TextFlow):Boolean
			// Return whether the bounds check will work (no false positives) on this flow.
			// A smarter version of this might adjust the marginForError instead of disallowing the test.
		{
			var writingDirection:String = textFlow.direction;
			for (var leaf:FlowLeafElement = textFlow.getFirstLeaf(); leaf; leaf = leaf.getNextLeaf())
			{
				var format:ITextLayoutFormat = leaf.computedFormat;
				if (format.fontSize > 100)
					return false;
				var leading:Number = leaf.getEffectiveLineHeight(leaf.computedFormat.blockProgression);
				if (leading > 100)
					return false;
				if ((format.textRotation != TextRotation.ROTATE_0) && (format.textRotation != TextRotation.AUTO))
					return false;
				var trackingLeft:Number = TextLayoutFormat.trackingLeftProperty.computeActualPropertyValue(leaf.computedFormat.trackingLeft,format.fontSize);
				if (trackingLeft > 100)
					return false;
				var trackingRight:Number = TextLayoutFormat.trackingRightProperty.computeActualPropertyValue(leaf.computedFormat.trackingRight,format.fontSize);
				if (trackingRight > 100)
					return false;
				var inline:InlineGraphicElement = leaf as InlineGraphicElement;
				if (inline)
				{
				//	trace("checking float direction");
					if (writingDirection == Direction.LTR)
					{
						if ((inline.computedFloat == Float.END) || (inline.computedFloat == Float.RIGHT)) 
						{
					//		trace ("ltr w/ right float");
							return false;
						}
					}
					if (writingDirection == Direction.RTL)
					{
						if ((inline.computedFloat == Float.END) || (inline.computedFloat == Float.LEFT))
						{
					//		trace ("rtl w/ left float");
							return false;
						}
					}
				}
			}
			return true;
		}

		private static function validateContentBounds(s:Sprite, contentBounds:Rectangle, type:String, marginOfError:Number):void
		{
			// Check that the content bounds includes all the places within the container that have text	
			s.graphics.clear();
			var bbox:Rectangle = s.getBounds(s);
			
			// The content bounds should always include the inked bounds, or be very close to it. In practice, how far it may be off by is proportional to the text size.
			Assert.assertTrue(type + " contentBounds left doesn't match sprite inked bounds. Bounds left=" + contentBounds.left + " ink left=" + bbox.left,
				contentBounds.left <= bbox.left || Math.abs(contentBounds.left - bbox.left) < marginOfError);
			Assert.assertTrue(type + " contentBounds top doesn't match sprite inked bounds. Bounds top=" + contentBounds.top + " ink top=" + bbox.top, 
				contentBounds.top <= bbox.top || Math.abs(contentBounds.top - bbox.top) < marginOfError);
			Assert.assertTrue(type + " contentBounds right doesn't match sprite inked bounds. Bounds right=" + contentBounds.right + " ink right=" + bbox.right, 
				contentBounds.right >= bbox.right || Math.abs(contentBounds.right - bbox.right) < marginOfError);
			Assert.assertTrue(type + " contentBounds bottom doesn't match sprite inked bounds. Bounds bottom=" + contentBounds.bottom + " ink bottom=" + bbox.bottom, 
				contentBounds.bottom >= bbox.bottom || Math.abs(contentBounds.bottom - bbox.bottom) < marginOfError);
		}
		
		private static function validateAlignment(verticalAlign:String, textAlign:String, textFlow:TextFlow, compositionBounds:Rectangle, contentBounds:Rectangle, expectContentsToFit:Boolean, marginOfError:Number):void
		{
			// Check that the text was put in the appropriate area of the container, given the vertical & horizontal alignment values
			if (expectContentsToFit)
			{
				Assert.assertTrue("contents expected to fit, but overflow in height", contentBounds.height <= compositionBounds.height || contentBounds.height - compositionBounds.height < 1);
				Assert.assertTrue("contents expected to fit, but overflow in width", contentBounds.width <= compositionBounds.width || contentBounds.width - compositionBounds.width < 1);
			}
			
			var blockProgression:String = textFlow.computedFormat.blockProgression;
			
			// If the content bounds exceeds the composition bounds, we don't do any vertical alignment adjustment, and it will be set to top.
			if (blockProgression == BlockProgression.TB)
			{
				if (contentBounds.height > compositionBounds.height)
					verticalAlign = VerticalAlign.TOP;
			}
			else if (contentBounds.width > compositionBounds.width)
				verticalAlign = null;		// don't check this case; I think content bounds may not be right
			
			// Resolve direction dependent alignment
			if (textAlign == TextAlign.START)
				textAlign = textFlow.computedFormat.direction == Direction.LTR ? TextAlign.LEFT : TextAlign.RIGHT;
			if (textAlign == TextAlign.END)
				textAlign = textFlow.computedFormat.direction == Direction.RTL ? TextAlign.LEFT : TextAlign.RIGHT;
			
			// Swap alignment values for validate call if text is rotated (vertical text)
			if (blockProgression == BlockProgression.RL)
			{
				var originalTextAlign:String = textAlign;
				switch (verticalAlign)
				{
					case VerticalAlign.TOP:
						textAlign = TextAlign.RIGHT;
						break;
					case VerticalAlign.MIDDLE:
						textAlign = TextAlign.CENTER;
						break;
					case VerticalAlign.BOTTOM:
						textAlign = TextAlign.LEFT;
						break;
					default:
						textAlign = null;
						break;
				}
				switch (originalTextAlign)
				{
					case TextAlign.LEFT:
						verticalAlign = VerticalAlign.TOP;
						break;
					case TextAlign.CENTER:
						verticalAlign = VerticalAlign.MIDDLE;
						break;
					case TextAlign.RIGHT:
						verticalAlign = VerticalAlign.BOTTOM;
						break;
					default:
						break;
				}
			}
			
			switch (verticalAlign)
			{
				case VerticalAlign.TOP:
					Assert.assertTrue("Vertical alignment top - content not at top", Math.abs(contentBounds.top - compositionBounds.top) < marginOfError);
					break;
				case VerticalAlign.MIDDLE:
					Assert.assertTrue("Vertical alignment middle - content not at middle", Math.abs(Math.abs(contentBounds.top - compositionBounds.top) - Math.abs(contentBounds.bottom - compositionBounds.bottom)) < marginOfError);
					break;
				case VerticalAlign.BOTTOM:
					Assert.assertTrue("Vertical alignment bottom - content not at bottom", Math.abs(contentBounds.bottom - compositionBounds.bottom) < marginOfError);
					break;
				default:
					break;
			}
			switch (textAlign)
			{
				case TextAlign.LEFT:
					Assert.assertTrue("Horizontal alignment left - content not at left", Math.abs(contentBounds.left - compositionBounds.left) < marginOfError);
					break;
				case TextAlign.CENTER:
					Assert.assertTrue("Horizontal alignment center - content not at center", Math.abs(Math.abs(contentBounds.left - compositionBounds.left) - Math.abs(contentBounds.right - compositionBounds.right)) < marginOfError);
					break;
				case TextAlign.RIGHT:
					Assert.assertTrue("Horizontal alignment right - content not at right", Math.abs(contentBounds.right - compositionBounds.right) < marginOfError);
					break;
				default:
					break;
			}
		}
		
		
		private static function addTextFactoryFromFlowSprite(textFlowFactory:TextFlowTextLineFactory, width:Number, height:Number, textFlow:TextFlow):Sprite
		{
			// trace("addTextFactoryFromFlowSprite",x,y,width,height,textAlign,verticalAlign,lineBreak);
			
			var factorySprite:Sprite = new Sprite();			
			
			textFlowFactory.compositionBounds = new Rectangle(0,0,width?width:NaN,height?height:NaN);
			
			textFlowFactory.createTextLines(callback,textFlow);
			
			function callback(tl:DisplayObject):void
			{
				factorySprite.addChild(tl);
			}
			
			return factorySprite;
		}

	}
}