//
//  IO_DateTime.swift
//  IO Helpers
//
//  Created by ilker özcan on 02/09/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//
//

import Foundation

/// Date Time Class
public class IO_DateTime {
	
	private let currentDate	= NSDate()
	private let dateFormat = "yyyy-LL-dd HH:mm:ss.S"
	
	private var inputDate : NSDate!
	private var inputString: String!
	
	/// NSDate To string (2015-09-01 14:03:00.000000)
	public init(initWithNsDate date : NSDate!) {
		
		if(date == nil) {
			
			inputDate = currentDate
		}else{
			inputDate = date
		}
		
		let formatter = NSDateFormatter()
		//2015-09-01 14:03:00.000000
		formatter.dateFormat = self.dateFormat
		formatter.timeZone = NSTimeZone(abbreviation: "GMT")
		inputString = formatter.stringFromDate(date)
	}
	
	/// String (2015-09-01 14:03:00.000000) to NSDate
	public init(initWithString date: String!) {
		inputString	= date
		
		let formatter = NSDateFormatter()
		//2015-09-01 14:03:00.000000
		formatter.dateFormat = self.dateFormat
		formatter.timeZone = NSTimeZone(abbreviation: "GMT")
		let formattedNsDate = formatter.dateFromString(date)
		
		if(formattedNsDate == nil) {
			
			inputDate = currentDate
		}else{
			inputDate = formattedNsDate
		}
		
	}
	
	/// Return NSDate
	public func getDate() -> NSDate! {
		return inputDate
	}
	
	/// Return String
	public func getDateString() -> String! {
		return inputString
	}
	
	/// Return GMT NSDate
	class func getCurrentGMTDate() -> NSDate {
		let currentTime				= NSDate()
		let timezone				= NSTimeZone(abbreviation: "GMT")
		let formatter				= NSDateFormatter()
		formatter.dateFormat		= "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		formatter.timeZone			= timezone
		let dateString				= formatter.stringFromDate(currentTime)
		
		return formatter.dateFromString(dateString)!
	}
	
	/// Return X Ago string from NSDate
	public func getTimeAgoString() -> String!
	{
		let currentEpochTime		= currentDate.timeIntervalSince1970
		let inputDateEpochTime		= inputDate.timeIntervalSince1970
		let elapsedSeconds			= Int(currentEpochTime ) - Int(inputDateEpochTime)
		var result : String			= ""
		
		if(elapsedSeconds > 59)
		{
			let elapsedMinutes		= Int(elapsedSeconds) / 60
			
			if(elapsedMinutes > 59)
			{
				let elapsedHours	= Int(elapsedMinutes) / 60
				
				if(elapsedHours > 24)
				{
					let elapsedDays		= Int(elapsedHours) / 24
					
					if(elapsedDays > 7)
					{
						let elapsedWeeks		= Int(elapsedDays) / 7
						result					= "\(elapsedWeeks) w"
					}else{
						result				= "\(elapsedDays) d"
					}
					
				}else{
					result				= "\(elapsedHours) h"
				}
			}else{
				result				= "\(elapsedMinutes) min"
			}
			
		}else{
			result					= "\(elapsedSeconds) sec"
		}
		
		return result
	}
	
	/// Return Unix time
	public func getUnixTimeStamp() -> Int {
		return Int(inputDate.timeIntervalSince1970)
	}
}