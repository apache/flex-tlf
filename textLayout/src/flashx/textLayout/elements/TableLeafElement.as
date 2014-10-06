package flashx.textLayout.elements
{
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.BaseCompose;
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.ISWFContext;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	public class TableLeafElement extends FlowLeafElement
	{
		private var _table:TableElement;
		public function TableLeafElement(table:TableElement)
		{
			super();
			_table = table;
		}

		/** @private */
		override tlf_internal function createContentElement():void
		{
			// not sure if this makes sense...
			if (_blockElement)
				return;
			
			computedFormat;	// BEFORE creating the element
			var flowComposer:IFlowComposer = getTextFlow().flowComposer;
			var swfContext:ISWFContext = flowComposer && flowComposer.swfContext ? flowComposer.swfContext : BaseCompose.globalSWFContext;

			var format:ElementFormat = FlowLeafElement.computeElementFormatHelper (_table.computedFormat, _table.getParagraph(), swfContext) 
			_blockElement = new TextElement(_text,format);
			CONFIG::debug { Debugging.traceFTECall(_blockElement,null,"new TextElement()"); }
			CONFIG::debug { Debugging.traceFTEAssign(_blockElement, "text", _text); }
			super.createContentElement();

		}

		/** @private */
		override protected function get abstract():Boolean
		{ return false; }		
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "table"; }
		
		/** @private */
		public override function get text():String
		{
			return "\u0016";
		}
		
		/** @private */
		public override function getText(relativeStart:int=0, relativeEnd:int=-1, paragraphSeparator:String="\n"):String
		{
			return _table.getText(relativeStart, relativeEnd, paragraphSeparator);
		}
		
		/** @private */
		tlf_internal override function normalizeRange(normalizeStart:uint,normalizeEnd:uint):void
		{
			// not sure what to do here (see SpanElement)...
			super.normalizeRange(normalizeStart,normalizeEnd);
		}
		
		/** @private */
		tlf_internal override function mergeToPreviousIfPossible():Boolean
		{
			// not sure what to do here (see SpanElement)...
			return false;
		}
		
		public override function getNextLeaf(limitElement:FlowGroupElement=null):FlowLeafElement
		{
			return _table.getNextLeafHelper(limitElement,this);
		}
		
		public override function getPreviousLeaf(limitElement:FlowGroupElement=null):FlowLeafElement
		{
			return _table.getPreviousLeafHelper(limitElement,this);
		}
		/** @private */
		public override function getCharAtPosition(relativePosition:int):String
		{
			return getText(relativePosition,relativePosition);
		}
		public override function get computedFormat():ITextLayoutFormat
		{
			return _table.computedFormat;
		}
		public override function get textLength():int
		{
			return _table.textLength;
		}
		tlf_internal override function updateAdornments(tLine:TextLine, blockProgression:String):int
		{
			return 0;
		}

		override public function get parent():FlowGroupElement
		{ 
			return _table; 
		}

		override public function getTextFlow():TextFlow
		{
			return _table.getTextFlow();
		}
		
		override public function getParagraph():ParagraphElement
		{
			return _table.getParagraph();
		}

	}
}
