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
package
{
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.compose.*;
	import flashx.textLayout.container.*;
	import flashx.textLayout.conversion.*;
	import flashx.textLayout.edit.*;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.formats.*;
	
	[SWF(width="1000", height="800")]
	public class StructureWalk extends Sprite
	{
		public var allGroupElements:Array = [DivElement, ParagraphElement, ListElement, ListItemElement, LinkElement, 
			TCYElement]//, SubParagraphGroupElement];
		//public var flowGroupElementArray:Array = [DivElement, ParagraphElement, ListElement, ListItemElement];
		//public var subParagraphGroupElementArray:Array = [LinkElement, TCYElement, SubParagraphGroupElement];
		//public var leafElementArray:Array = [SpanElement, InlineGraphicElement];
		public var textFlow:TextFlow;
		public var parentChildCount:int = 0;
		public var pairsDone:Array = [];
		public var errors:String;
		public var verbose:Boolean = true;
		
		public function StructureWalk()
		{
			createFlow();
			var sprite1:Sprite = new Sprite();
			var cc1:ContainerController = new ContainerController(sprite1,1000,800);
			addChild(sprite1);
			textFlow.interactionManager = new EditManager();
			textFlow.flowComposer.addController(cc1);
			textFlow.flowComposer.updateAllControllers();
			//trace (pairsDone);
		}
		
		public function createFlow():void
		{
			textFlow = new TextFlow();
			textFlow.id = "TextFlow";
			addChildren (textFlow);
		}
		
		public function addChildren(parent:FlowGroupElement):void
		{
			for (var i:int = 0; i < allGroupElements.length; i++)
			{
				var child:FlowGroupElement = new allGroupElements[i]();
				//if (recursiveNestingIsOK(parent,child))
				if (pairIsNew(parent,child))
				{
					try
					{
						parent.addChild(child);
						child.id = ++parentChildCount + ":" + getElementName(child) + " in a " + parent.id;
						addText(parent, child);
						addChildren(FlowGroupElement(child));
					}
					catch (err:Error)
					{
						//trace (err.message);
						//trace ("   parent:" + getElementName(parent) + "   child:" + getElementName(child));
						errors = errors + err.message + "\r"
					}
				}
			}
			var s:SpanElement = new SpanElement();
			try
			{
				parent.addChild(s);
				s.id = ++parentChildCount + ":" + getElementName(s) + " in a " + parent.id;
				if (verbose)
				{
					s.text = "[" + s.id + "]";
				}
				else
				{
					s.text = "[" + parentChildCount + "]";
				}
			}
			catch (err:Error)
			{
				//trace (err.message);
				//trace ("   parent:" + getElementName(parent) + "   child:" + getElementName(s));
				errors = errors + err.message + "\r"
				
			}
		}
		
		// returns true if the recursive nesting is less than 2 (div in div is OK, div in div in div is not)
		public function recursiveNestingIsOK(parent:FlowGroupElement, child:FlowGroupElement):Boolean
		{
			var instancesOfChildInStack:Array = parent.id.match(new RegExp(getElementName(child), 'g'));
			return (!instancesOfChildInStack || instancesOfChildInStack.length < 2);
		}
		
		// returns true if this parent/child pair hasn't yet been added.
		public function pairIsNew(parent:FlowGroupElement, child:FlowElement):Boolean
		{
			var pairString:String = getElementName(child) + " in a " + getElementName(parent);
			if (pairsDone.indexOf(pairString) != -1) return false
			pairsDone.push(pairString);
			return true;
		}
		
		CONFIG::debug public function getElementName(element:FlowElement):String
		{
			var longString:String = element.toString();
			return (longString.split(" ")[0].substr(longString.indexOf("::")+2));
		}
		
		CONFIG::release public function getElementName(element:FlowElement):String
		{
			return flash.utils.getQualifiedClassName(element);

		}
		
		public function addText(parent:FlowGroupElement, child:FlowGroupElement):void
		{
			var labelSpanHolder:FlowGroupElement;
			if (child is ParagraphElement || child is SubParagraphGroupElementBase)
			{
				labelSpanHolder = FlowGroupElement(child);
			}
			else
			{
				labelSpanHolder = new ParagraphElement();
				child.addChild(labelSpanHolder);
			}
			var s:SpanElement = new SpanElement();
			if (verbose)
			{
				s.text = "[" + child.id + "]";
			}
			else
			{
				s.text = "[" + parentChildCount + "]";
			}
			labelSpanHolder.addChild(s);			
		}
	}
}