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
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.net.*;

private function MakeMySQLDate(tmpDate:Date):String
{
// *******************************************************************
// Parameter:
//	   tmpDate - Date object that will be parsed to creat the MySQL Date.
// Return:
//     tmpDate converted into the MySQL friendly format of yyyymmdd.
// *******************************************************************
	var iYear:Number = tmpDate.getFullYear();
	var iMonth:Number = tmpDate.getMonth()+1;
	var iDay:Number = tmpDate.getDate();
	var tmpStrMonth:String = iMonth.toString();
	if (iMonth <= 9) {
		tmpStrMonth = "0" + tmpStrMonth;
	}
	var tmpStrDay:String = iDay.toString();
	if (iDay <= 9) {
		tmpStrDay = "0" + tmpStrDay;
	}
	var tmpStrHour:String = tmpDate.getHours().toString();
	if (tmpDate.getHours() <= 9) {
		tmpStrHour = "0" + tmpStrHour;
	}
	var tmpStrMinute:String = tmpDate.getMinutes().toString();
	if (tmpDate.getMinutes() <= 9) {
		tmpStrMinute = "0" + tmpStrMinute;
	}
	var tmpStrSecond:String = tmpDate.getSeconds().toString();
	if (tmpDate.getSeconds() <= 9) {
		tmpStrSecond = "0" + tmpStrSecond;
	}

	return iYear.toString() + tmpStrMonth + tmpStrDay + tmpStrHour + tmpStrMinute + tmpStrSecond;
}

private function createMySQLDateFromString(strDate:String):String
{
	var arTemp:Array;
	var arDate:Array;
	var arTime:Array;
	var strMonth:String;
	var strDay:String;
	var strHour:String;

	arTemp = strDate.split(" ");
	arDate = String(arTemp[0]).split("/");
	arTime = String(arTemp[1]).split(":");

	var iMonth:Number = Number(arDate[0]);
	var iDay:Number = Number(arDate[1]);
	var strYear:String = String(arDate[2]);
	var iHour:Number = Number(arTime[0]);
	var strMinute:String = String(arTime[1]);
	var strSecond:String = String(arTime[2]);

	strMonth = String(arDate[0]);
	if (iMonth <= 9)
	{
		strMonth = "0" + strMonth;
	}

	strDay = String(arDate[1]);
	if (iDay <= 9)
	{
		strDay = "0" + strDay;
	}

	strHour = String(arTime[0]);
	if (arTemp[2] == "PM")
	{
		iHour += 12;
	}
	else if (iHour <= 9)
	{
		strHour = "0" + strHour;
	}

	return strYear + strMonth + strDay + strHour + strMinute + strSecond;
}


private function fixStringDataForMySQL(strTemp:String):String
{
	var i:Number = 0;
	var iOld:Number = 0;
	var firstQuote:Boolean = false;
	var strNew:String = "";

	strTemp = trim(strTemp);

	while (i != -1){
		i = strTemp.indexOf("'", i);
		if (i != -1){
			if ((strNew != "") || (firstQuote)){
				strNew += "\\" + strTemp.substring(iOld, i);
			}
			else if (i != 0) {
				strNew = strTemp.substring(iOld, i);
			}
			else {
				firstQuote = true;
			}
			iOld = i;
			i++;
		}
	}
	if (iOld <= strTemp.length){
		if (strNew != ""){
			strNew += "\\" + strTemp.substring(iOld, strTemp.length);
		}
		else {
			strNew = strTemp.substring(iOld, strTemp.length);
		}
	}
	return (strNew);
}

// General Date and String Functions //

private function DateAdd(tmpDate:Date, strType:String, iVal:Number):void {
// *******************************************************************
// Parameters:
//	   tmpDate - Date object to which will be added the time.
//	   strType - String value that represents what the iVal value is.
//               s - Seconds
//               m - Minutes
//               h - hours
//               d - days
//               w - weeks
//	   iVal - Number value the represents the number of strType to add to the date.
//            If you want to go subtract, just use a negative number.
// Return:
//     tmpDate with time addded.
// *******************************************************************
	var timeVal:Number = 0;
	switch(strType){
		case "s":
			timeVal = (1000*iVal);
			break;
		case "m":
			timeVal = (1000*60*iVal);
			break;
		case "h":
			timeVal = (1000*60*60*iVal);
			break;
		case "d":
			timeVal = (1000*60*60*24*iVal);
			break;
		case "w":
			timeVal = (1000*60*60*24*7*iVal);
			break;
	}
	tmpDate.setTime(tmpDate.getTime() + timeVal);
}

private function ltrim(matter:String):String
{
    if ((matter.length>1) || (matter.length == 1 && matter.charCodeAt(0)>32 && matter.charCodeAt(0)<255)) {
        var i:int = 0;
        while (i<matter.length && (matter.charCodeAt(i)<=32 || matter.charCodeAt(i)>=255)) {
            i++;
        }
        matter = matter.substring(i);
    } else {
        matter = "";
    }
    return matter;
}

private function rtrim(matter:String):String
{
    if ((matter.length>1) || (matter.length == 1 && matter.charCodeAt(0)>32 && matter.charCodeAt(0)<255)) {
       var i:int = matter.length-1;
       while (i>=0 && (matter.charCodeAt(i)<=32 || matter.charCodeAt(i)>=255)) {
            i--;
        }
        matter = matter.substring(0, i+1);
    } else {
        matter = "";
    }
    return matter;
}

private function trim(matter:String):String
{
    return ltrim(rtrim(matter));
}

//**************************************************************
// SQL XML functions.
//**************************************************************
private function fixSingleQuotes(strTemp:String):String
{
	var pattern:RegExp = /\x27/gi;
	return (strTemp.replace(pattern, "&apos;"));
}

private function createSQLXML(SQL:String, DataLabel:String):String
{
	return ("<SQL SQL='" + fixSingleQuotes(SQL) + "' Name='" + DataLabel + "'></SQL>");
	//return ("<SQL SQL='" + SQL + "' Name='" + DataLabel + "'></SQL>");
}

private function sendSQLXML(aspURL:String,
							SQLXML:String,
							returnSQLXMLCallback:Function,
							errorSQLXMLCallback:Function):void
{
	var myXMLURL:URLRequest = new URLRequest(aspURL);
	var variables:URLVariables = new URLVariables();
	variables.xmlSQL = "<MTBFRequest>" + SQLXML + "</MTBFRequest>";
	myXMLURL.data = variables;
	myXMLURL.method = URLRequestMethod.POST;
	var myLoader:URLLoader = new URLLoader();
	myLoader.addEventListener("complete", returnSQLXMLCallback, false, 0, true);
	myLoader.addEventListener(IOErrorEvent.IO_ERROR, errorSQLXMLCallback);
	myLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
	myLoader.load(myXMLURL);
}

private function httpStatus(eventObj:HTTPStatusEvent):void
{
	var header:URLRequestHeader;
    //trace("httpStatusHandler: " + eventObj);
    //trace("status: " + eventObj.status);

}
/*
private function ioErrorListener(eventObj:IOErrorEvent):void
{
	//trace(eventObj.text);
}
*/
private function makeDateObject(strDate:String):Date
{
	var my_str:String = strDate;
	var my_array:Array = my_str.split("/");
	var tmpDate:Date = new Date(my_array[2],Number(my_array[0])-1, my_array[1],0,0,0,0);
	return tmpDate;
}
