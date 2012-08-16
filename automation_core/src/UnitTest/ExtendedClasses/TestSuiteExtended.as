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
package UnitTest.ExtendedClasses
{
	import flash.events.Event;
	import flash.system.System;
	import flash.utils.*;

	import flexunit.flexui.*;
	import flexunit.framework.*;
	import flexunit.runner.*;
	import flexunit.textui.*;
	import flexunit.utils.*;

	public class TestSuiteExtended extends TestSuite
	{
		public var _parent:Object;
		public var currentTest:Test;
		public var testDescArrayList : Collection;
		private var runDescIter:Iterator;
		private var listener : TestSuiteTestListener;

		public function TestSuiteExtended(parent:Object=null)
		{
	        super(null);
			testDescArrayList = Collection( new ArrayList());
			_parent = parent;
		}

    override public function runWithResult( result:TestResult ):void
    {
        runDescIter = testDescArrayList.iterator();
        listener = new TestSuiteTestListener(this, result);
        runNext(result);
    }

	private static const _a:uint = 1664525;
	private static const _c:uint = 1013904223;
	private static var _rand:uint = 47;

	// random from 0 to 1 inclusive I think
	private static function getRandom():Number
	{
		_rand = _a*_rand+_c;
		return Number(_rand)/uint.MAX_VALUE;
	}

	private function chooseRandomTest():Object
	{
		_rand = _a*_rand+_c;
		var index:int = getRandom() * (testDescArrayList.length()+1)
		if (index >= testDescArrayList.length())
			index = testDescArrayList.length()-1;
		return testDescArrayList.getItemAt(index);
	}

	private var __testCount:int = 0;
	private var _maxDeltaMemory:int = -1;
	private var _maxDeltaTest:int = -1;

	private var repeatForever:Boolean = false;
	private var useRandomTest:Boolean = false;

    override public function runNext( result : TestResult) : void
    {
		currentTest = null;
		if (!runDescIter.hasNext() && repeatForever)
			runDescIter = testDescArrayList.iterator();
        if ( runDescIter.hasNext() )
        {
            if ( result.shouldStop() )
            {
                listener.pop();
                return;
            }

			currentTest = useRandomTest ? chooseRandomTest().makeTest() : runDescIter.next().makeTest();

			/*var curMemory:int = System.totalMemory;
			__testCount++;
			trace(__testCount,_maxDeltaTest,_maxDeltaMemory,currentTest.toString());*/

            runTest( currentTest, result );

			/*System.gc();System.gc();
			var aftMemory:int = System.totalMemory;
			var deltaMemory:int = aftMemory-curMemory;
			if (deltaMemory > _maxDeltaMemory)
			{
				_maxDeltaMemory = deltaMemory;
				_maxDeltaTest = __testCount;
			}*/
        }
        else
        {
			if (_parent != null)
				_parent.dispatchEvent(new Event("TestComplete"));
            listener.pop();
        }
    }

	private function runTest( test:Test, result:TestResult ):void
	{
		test.runWithResult( result );
	}

	override public function testCount() : Number
	{
		return testDescArrayList.length();
	}

	override public function getTests() : Array
	{
		var tempArray:Array = testDescArrayList.toArray();
		return testDescArrayList.toArray();
	}

	public function addTestDescriptor ( descriptor:TestDescriptor ) : void
	{
		testDescArrayList.addItem (descriptor);
	}

	override public function countTestCases() : Number
	{
		return testCount(); // currently it's a flat list.
	}

	}

}
