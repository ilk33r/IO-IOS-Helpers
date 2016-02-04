//
//  IO_Json.swift
//  IO Helpers
//
//  Created by ilker özcan on 01/03/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//

import Foundation

/// Json encoder/decoder
public struct IO_Json
{
	/// Object to JSON string
	public static func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
		
		//var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
		let options: NSJSONWritingOptions?  = (prettyPrinted) ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions(rawValue: 0)
		
		if NSJSONSerialization.isValidJSONObject(value) {
			if let data = try? NSJSONSerialization.dataWithJSONObject(value, options: options!) {
				return NSString(data: data, encoding: NSUTF8StringEncoding)! as String
			}
		}
		
		return ""
	}
	
	/// JSON to array
	public static func JSONParseArray(jsonString: String) -> [AnyObject] {
		if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
		{
			if let array = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)))  as? [AnyObject] {
				return array
			}
		}
		return [AnyObject]()
	}
	
	/// JSON to object
	public static func JSONParseDictionary(jsonString: String) -> [String: AnyObject] {
		if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
			if let dictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)))  as? [String: AnyObject] {
				return dictionary
			}
		}
		return [String: AnyObject]()
	}
}