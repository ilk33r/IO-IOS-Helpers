//
//  IO_MediaCaching.swift
//  IO Helpers
//
//  Created by ilker özcan on 15/03/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//

import UIKit
import Foundation

/// Media caching handler
public typealias IO_MediaCachingResponseHandler = (success : Bool, image : UIImage!) -> Void

private class IO_MediaCachingRequestUrls {
	
	class var sharedInstance : IO_MediaCachingRequestUrls {
		
		struct Singleton {
			static let instance		= IO_MediaCachingRequestUrls()
		}
		
		return Singleton.instance
	}
	
	private var wishList : [String]!
	
	init() {
		self.wishList		= [String]()
	}
	
	func addImage(imageName : String) -> Bool {
		
		var imageIsNotRequesting		= true
		
		for wishListImageName in wishList
		{
			if(wishListImageName == imageName)
			{
				imageIsNotRequesting	= false
				break
			}
		}
		
		if(imageIsNotRequesting)
		{
			wishList.append(imageName)
		}
		
		return imageIsNotRequesting
	}
	
	func removeImage(imageName : String) {
		
		for (index, value) in wishList.enumerate()
		{
			if(value == imageName)
			{
				wishList.removeAtIndex(index)
				break
			}
		}
	}
	
	func resetWhishList() {
		wishList = [String]()
	}
}

/// Media Caching
public class IO_MediaCaching: NSObject {
	
	private var tryCount = 0
	private var cachingCompletitionHandler : IO_MediaCachingResponseHandler!
	private var requestFile : String!
	private var urlData : NSMutableData!
	private var syncConnection: NSURLConnection!

	private var md5FileName = ""
	
	/// Media Caching
	public init(getMediaImage fileUrl : String!, completionHandler : IO_MediaCachingResponseHandler) {
		super.init()
		
		if(fileUrl != nil) {
			
			if(!fileUrl.isEmpty) {
				self.getMediaImage(fileUrl, completionHandler: completionHandler)
			}else{
				completionHandler(success: false, image: nil)
			}
		}else{
			completionHandler(success: false, image: nil)
		}
		
	}
	
	// get image if exists in cache
	private func getMediaImage(fileUrl : String, completionHandler : IO_MediaCachingResponseHandler) {
		
		md5FileName = fileUrl.IO_md5() + "-cached.img"

		if(IO_MediaCaching.mediaExists(md5FileName)) {

			let cachefile = NSString(string: IO_Helpers.getMediaCacheDirectory!).stringByAppendingPathComponent(md5FileName)
			let fileUrl = NSURL(fileURLWithPath: cachefile)
			let fileData = NSData(contentsOfURL: fileUrl)
			completionHandler(success: true, image: UIImage(data: fileData!))
		}else{
			if(IO_MediaCachingRequestUrls.sharedInstance.addImage(fileUrl)) {
				cachingCompletitionHandler	= completionHandler
				tryCount = 0
				requestFile = fileUrl
				startRequest()
			}else{
				completionHandler(success: false, image: nil)
			}
		}
	}
	
	// start image download process
	private func startRequest() {

		let requestUrl = NSURL(string: self.requestFile)
		let urlRequest = NSMutableURLRequest(URL: requestUrl!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 90)
		
		urlRequest.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
		self.urlData = NSMutableData()
		
		dispatch_async(dispatch_get_main_queue(), { () -> Void in

			self.syncConnection	= NSURLConnection(request: urlRequest, delegate: self, startImmediately: false)
			self.syncConnection?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
			self.syncConnection?.start()
		})
		
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
	}
	
	// request complete
	func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
		
		let httpResponse = response as! NSHTTPURLResponse
		let code = httpResponse.statusCode
		
		if(code < 200 || code >= 300) {

			NSRunLoop.currentRunLoop().cancelPerformSelectorsWithTarget(self)
			connection.cancel()
			
			self.tryCount++
			
			if(self.tryCount < 3) {
				
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				IO_MediaCachingRequestUrls.sharedInstance.removeImage(requestFile)
				
				let dispatchDelay		= dispatch_time(DISPATCH_TIME_NOW, Int64(1))
				
				dispatch_after(dispatchDelay, dispatch_get_main_queue(), { () -> Void in
					self.startRequest()
				})
				
			}else{
				if(self.cachingCompletitionHandler != nil) {
					
					self.cachingCompletitionHandler(success : false, image : nil)
				}
			}
		}
	}
	
	// image downloading
	func connection(connection: NSURLConnection, didReceiveData data: NSData) {
		if (data.length == 0) {
			return;
		}
		
		urlData.appendData(data)
	}
	
	// download complete
	func connectionDidFinishLoading(connection: NSURLConnection) {
		
		NSRunLoop.currentRunLoop().cancelPerformSelectorsWithTarget(self)
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false

		let cachefile = NSString(string: IO_Helpers.getMediaCacheDirectory!).stringByAppendingPathComponent(md5FileName)
		
		urlData.writeToFile(cachefile as String, atomically: false)
		IO_MediaCachingRequestUrls.sharedInstance.removeImage(requestFile)
		
		connection.cancel()
		self.requestFile = nil
		self.urlData = nil
		self.syncConnection = nil
		self.md5FileName = ""
		
		if(cachingCompletitionHandler != nil) {
			
			cachingCompletitionHandler(success: true, image: UIImage(data: urlData!))
		}
	}
	
	// download failed
	func connection(connection: NSURLConnection, didFailWithError error: NSError) {
		
		NSRunLoop.currentRunLoop().cancelPerformSelectorsWithTarget(self)
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		connection.cancel()
		
		self.tryCount++
		
		if(self.tryCount < 3) {
			
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			IO_MediaCachingRequestUrls.sharedInstance.removeImage(requestFile)

			let dispatchDelay = dispatch_time(DISPATCH_TIME_NOW, Int64(1))
			dispatch_after(dispatchDelay, dispatch_get_main_queue(), { () -> Void in
				self.startRequest()
			})
		}else{
			
			if(self.cachingCompletitionHandler != nil) {
				
				self.cachingCompletitionHandler(success : false, image : nil)
			}
		}
	}
	
	/// Convert url to cache file name
	static func convertUrlToFileName(fileUrl: String) -> String {
		
		let md5FileName = fileUrl.IO_md5() + "-cached.img"
		return md5FileName;
	}
	
	/// Check media exists in the cache
	static func mediaExists(fileName : String) -> Bool {
		
		var cachefile = IO_Helpers.getMediaCacheDirectory

		if(cachefile != nil) {
			
			cachefile = NSString(string: cachefile!).stringByAppendingPathComponent(fileName)
			
			if(NSFileManager.defaultManager().fileExistsAtPath(cachefile!))
			{
				return true
			}else{
				return false
			}
		}else{
			return false
		}
	}
	
	/// Get base64 encoded image
	static func getMediaImageForBase64Encoded(fileName : String) -> String! {

		if(IO_MediaCaching.mediaExists(fileName)) {
			let cachefile = NSString(string: IO_Helpers.getMediaCacheDirectory!).stringByAppendingPathComponent(fileName)
			let fileUrl = NSURL(fileURLWithPath: cachefile)
			let fileData = NSData(contentsOfURL: fileUrl)
			return (fileData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))!
		}else{
			return nil
		}
	}

	/// Save file to cache directory
	static func saveFileToCache(fileName: String!, fileContent: NSData!) {
		
		let cachefile = NSString(string: IO_Helpers.getMediaCacheDirectory!).stringByAppendingPathComponent(fileName)
		fileContent.writeToFile(cachefile, atomically: false)
	}
	
	/// Remove file from cache directory
	static func removeFileFromCache(fileName: String!) {
		
		let cachefile = NSString(string: IO_Helpers.getMediaCacheDirectory!).stringByAppendingPathComponent(fileName)
		do {
			try NSFileManager.defaultManager().removeItemAtPath(cachefile)
		} catch _ {
		}
	}
	
	// delete old images and clear whishlist
	class func clearCache(timeInterval: NSTimeInterval = -604800) {
		
		let cacheDirectory = IO_Helpers.getMediaCacheDirectory
		
		if(cacheDirectory != nil) {
			let files = NSFileManager.defaultManager().enumeratorAtPath(cacheDirectory!)
			var fileCount = 0
			
			while let file: String = files?.nextObject() as? String {
				
				let filePath = NSString(string: cacheDirectory!).stringByAppendingPathComponent(file)
				let fileAttributes = try? NSFileManager.defaultManager().attributesOfItemAtPath(filePath)
			
				if(fileAttributes != nil) {
					
					if let fileCreateDate = fileAttributes?[NSFileCreationDate] as? NSDate {
						
						let fileCreateEpoch = fileCreateDate.timeIntervalSince1970
						let timeInterval = NSDate().dateByAddingTimeInterval(timeInterval).timeIntervalSince1970
						
						if(fileCreateEpoch < timeInterval) {
							
							do {
								try NSFileManager.defaultManager().removeItemAtPath(filePath)
							} catch _ {
							}
						}
					}
				}
				
				fileCount++
			}
		}
		
		IO_MediaCachingRequestUrls.sharedInstance.resetWhishList()
	}
}
