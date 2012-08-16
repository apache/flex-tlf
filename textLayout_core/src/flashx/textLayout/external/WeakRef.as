/**
 * Weak reference to an object
 * 
 * To create:
 * var weak:Weakref = new WeakRef( obj );
 *
 * To use:
 * var strong = weak.get();
 * if( strong != null )
 * {
 *     // use strong here
 * }
 * else
 * {
 *     // garbage collector has disposed of the object
 * }
 * 
 * Author: Richard Lord
 * Copyright (c) Big Room Ventures Ltd. 2007
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package flashx.textLayout.external
{
	import flash.utils.Dictionary;
	
[ExcludeClass]
	/** @private */
	public class WeakRef
	{
		private var dic:Dictionary;
		
		public function WeakRef( obj:* )
		{
			dic = new Dictionary( true );
			if (obj != null)
				dic[obj] = 1;
		}
		
		public function get():*
		{
			for( var item:* in dic )
			{
				return item;
			}
			return null;
		}
	}
}
