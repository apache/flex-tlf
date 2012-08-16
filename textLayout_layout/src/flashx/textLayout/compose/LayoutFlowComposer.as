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
	import __AS3__.vec.Vector;
	
	import flash.display.Sprite;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.LayoutContainerController;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	public class LayoutFlowComposer extends StandardFlowComposer
	{
		public function LayoutFlowComposer():void
		{
			super();
		}
		
		/** @private */
		tlf_internal override function getComposeState():ComposeState
		{ return LayoutComposeState.getLayoutComposeState(); }
		
		/** @private */
		tlf_internal override function releaseComposeState(state:ComposeState):void
		{ LayoutComposeState.releaseLayoutComposeState(state); }
		
		// This override makes the LayoutComposer less efficient but is necessary or floats dissapear if updateAllControllers is called when scrolling
		// is enabled on the last container.  The base class skips the compose but marks the controllers as needing update.  Since compose was skipped
		// the inlineChildren arrays are empty and no inlines get composed.  This works around that problem.  A better solution is needed when inlines
		// become first class and well supported.
		tlf_internal override function callTheComposer(composeToPosition:int, controllerEndIndex:int):ContainerController
		{				
			var state:ComposeState = getComposeState();
			
			var lastComposedPosition:int = state.composeTextFlow(textFlow, composeToPosition, controllerEndIndex);
			if (_damageAbsoluteStart < lastComposedPosition)
				_damageAbsoluteStart = lastComposedPosition;
			CONFIG::debug { checkFirstDamaged(); }
			
			// make sure there is an empty TextFlowLine covering any trailing content
			finalizeLinesAfterCompose();
			
			releaseComposeState(state);
							
			textFlow.dispatchEvent(new CompositionCompleteEvent(CompositionCompleteEvent.COMPOSITION_COMPLETE,false,false,textFlow, 0,lastComposedPosition));

			CONFIG::debug { textFlow.debugCheckTextFlow(); }
			// TODO: optimize to the first damaged controller
			return getControllerAt(0);
		}
	}
}

