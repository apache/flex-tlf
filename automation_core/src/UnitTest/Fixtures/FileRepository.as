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
package UnitTest.Fixtures
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

    import mx.utils.LoaderUtil;

	/** Gateway class for reading and caching files used by the test harness code.
	 */
	public class FileRepository
	{
		/** Get the named file.
		 * @param	fileName name of the file we're looking for
		 * @return String that contains the content of the file
		 */
		static public function getFile(baseURL:String, fileName:String):String
		{
			return CustomURLLoader.getFile(LoaderUtil.createAbsoluteURL(baseURL,fileName));
		}

		/** Get the named file as an XML object.
		 * File will be converted assuming whitespace is significant.
		 * @param	fileName of the file we're looking for
		 * @return String that contains the content of the file
		 */
		static public function getFileAsXML(baseURL:String, fileName:String):XML
		{
			var xmlData:XML = null;
		 	var sourceString:String = getFile(baseURL,fileName);
		 	return sourceString ? convertToXML(sourceString) : null;
		}

		/** Convert from string to XML */
		static private function convertToXML(sourceString:String):XML
		{
			var xmlData:XML = null;

			// Convert string data to XML
			var originalSettings:Object = XML.settings();
			try
			{
				XML.ignoreProcessingInstructions = false;
				XML.ignoreWhitespace = false;
				xmlData = new XML(sourceString);
			}
			finally
			{
				XML.setSettings(originalSettings);
			}
			return xmlData;
		}

		/**
		* Reads in a file and set up a handler for when the file read is complete
		*/
		static public function readFile(baseURL:String, fileName:String, handler:Function = null, errorHandler:Function = null, securityHandler:Function = null, ignoreWhitespace:Boolean = false): void
		{
			if (fileName == null || fileName.length <= 0)
				return;

			var tcURL:URLRequest = new URLRequest(LoaderUtil.createAbsoluteURL(baseURL,fileName));
			tcURL.method = URLRequestMethod.GET;
			var tcLoader:URLLoader = new CustomURLLoader(handler, errorHandler, securityHandler);
			tcLoader.load(tcURL);
		}

       /**
        * Returns true if there are pending requests, false if not
        */
        static public function pendingRequests(): Boolean
        {
            return (CustomURLLoader.requestsPending != 0);
        }
	}
}
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flashx.textLayout.debug.assert;

	/** Serves as a single bottleneck for all requests that go through
	 * FileRepository. Requests come in as URLLoader.load calls, and we
	 * always listen for completion, error, and security error. If a handler
	 * for any of these is passed in when the CustomURLLoader is constructed,
	 * we will in addition call the handler.
	 *
	 * Override URLLoader so we can get the request back when we're
	 * in a completion function. Also tracks outstanding requests so we
	 * can block until results are complete.
	 */
	class CustomURLLoader extends URLLoader
	{
		public var request: URLRequest;			// original request for file load
		public var completeHandler:Function;	// custom completion handler
		public var ioErrorHandler:Function;		// custom i/o error handler
		public var securityErrorHandler:Function;	// custom security error handler

		/** Cache containing all files that have been requested.
		 * The key is the name of the file as given in the original request, and the
		 * value is the contents of the file as a string. */
		static private var _fileCache:Object;

		/** Number of file read requests that are pending -- i.e., that have neither
		 * completed successfully nor returned errors.
		 */
		static private var _requestsPending:int = 0;

		static private var FILE_ERROR:String = "$$$NOT_FOUNDXXX" // unique string to signal file read error

		/** Constructor
		 * Note that if you specify all three handlers, one will be called depending on the outcome of the
		 * read.
		 *
		 * @param completeHandler - custom handler called on successful completion of file read
		 * @param ioErrorHandler - custom handler called on i/o error of file read
		 * @param securityErrorHandler - custom handler called on security error of file read
		 */
		public function CustomURLLoader(completeHandler:Function, ioErrorHandler:Function = null, securityErrorHandler:Function = null)
		{
			this.completeHandler = completeHandler;
			this.ioErrorHandler = ioErrorHandler;
			this.securityErrorHandler = securityErrorHandler;

			if (!_fileCache)
				_fileCache = new Object();
		}

		/** Returns number of file read requests that are pending -- i.e., that have neither
		 * completed successfully nor returned errors.
		 */
		static public function get requestsPending():int
		{
			return _requestsPending;
		}

		/** Given the name of a file, look it up in the cache and return the contents as a string. */
		static public function getFile(fileName:String):String
		{
			// If it's in the cache, just return it
			if (_fileCache[fileName] != null)
				return _fileCache[fileName];

			// We have a request out, and we're waiting for the result. Unfortunately, there's no
			// way we know to wait and still handle the events that would cause the pending status
			// to complete. So we return failure here as well.
			if (_fileCache.hasOwnProperty(fileName))
				return null;

			// We've never seen this file
			return null;
		}

		/** Add a new file to the cache. Takes the name of the file, as given in the URLRequest,
		 * and the file contents as a string. */
		static private function addToCache(urlLoader:CustomURLLoader, data:String):void
		{
			CONFIG::debug { assert(_fileCache[getFileKey(urlLoader)] == null, "Adding over existing cache entry!"); }
			_fileCache[getFileKey(urlLoader)] = data;
		}

		/** Default handler. This will get called on every successful completion of a read that goes
		 * through CustomURLLoader. It's job is to add the file to the file cache, and call the
		 * custom completion handler, if one was specified.
		 */
		static private function defaultCompleteHandler(event:Event):void
		{
			// Remove the event listener that was attached so this function could get called.
			if (event)
				event.target.removeEventListener(Event.COMPLETE, defaultCompleteHandler);

			// This request handled; is no longer pending
			--_requestsPending;

 			// Add the new file to the cache
 			var urlLoader:CustomURLLoader = CustomURLLoader(event.target);
 			addToCache(urlLoader, urlLoader.data);

 			// Call the custom completion handler
			if (urlLoader.completeHandler != null)
				urlLoader.completeHandler(event);
			urlLoader.close();
		}

		/** Default handler. This will get called on every security error of a read that goes
		 * through CustomURLLoader. It's job is to update the file cache, and call the
		 * custom security error handler, if one was specified.
		 */
		static private function defaultSecurityErrorHandler(event:SecurityErrorEvent):void
		{
 			if (event)
				event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, defaultSecurityErrorHandler);

			--_requestsPending;
			var urlLoader:CustomURLLoader = CustomURLLoader(event.target);
			addToCache(urlLoader, FILE_ERROR);
			if (urlLoader.securityErrorHandler != null)
				urlLoader.securityErrorHandler(event);
        }

		/** Default handler. This will get called on every i/o error of a read that goes
		 * through CustomURLLoader. It's job is to update the file cache, and call the
		 * custom i/o error handler, if one was specified.
		 */
        static private function defaultIOErrorHandler(event:IOErrorEvent):void
        {
			if (event)
				event.target.removeEventListener(IOErrorEvent.IO_ERROR, defaultIOErrorHandler);

        	--_requestsPending;
 			var urlLoader:CustomURLLoader = CustomURLLoader(event.target);
			addToCache(urlLoader, FILE_ERROR);
			if (urlLoader.ioErrorHandler != null)
				urlLoader.ioErrorHandler(event);
         }

        /* Start a file read.
         * @param request - URL request for the read
         */
		override public function load(request:URLRequest):void
		{
			this.request = request;

			// If we have already read this file in, or we are already in the middle of reading it in, don't make another request
			if (_fileCache.hasOwnProperty(getFileKey(this)))
			{
				CONFIG::debug { assert (completeHandler == null, "Load has file cached, won't be calling completeHandler! You should call get() before calling readFile()"); }
				return;
			}

			// Add it to the cache as a null entry, to signal there's a request pending on it
			_fileCache[getFileKey(this)] = null;

			// Attach listeners so the default handlers get called.
			addEventListener(Event.COMPLETE,defaultCompleteHandler, false, 0, true);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR,defaultSecurityErrorHandler, false, 0, true);
			addEventListener(IOErrorEvent.IO_ERROR, defaultIOErrorHandler, false, 0, true);

			++_requestsPending;
			super.load(request);
		}

		/** Given a URLLoader, return the key for access the file cache. Right now, we
		 * just use the file name for this.
		 */
		static private function getFileKey(urlLoader:CustomURLLoader):String
		{
			return urlLoader.request.url;
		}
	}
