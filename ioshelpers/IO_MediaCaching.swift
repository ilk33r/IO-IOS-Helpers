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
public typealias IO_MediaCachingResponseHandler = (_ success : Bool, _ image : UIImage?) -> Void

private class IO_MediaCachingRequestUrls {
	
	class var sharedInstance : IO_MediaCachingRequestUrls {
		
		struct Singleton {
			static let instance		= IO_MediaCachingRequestUrls()
		}
		
		return Singleton.instance
	}
	
	fileprivate var wishList : [String]!
	
	init() {
		self.wishList		= [String]()
	}
	
	func addImage(_ imageName : String) -> Bool {
		
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
	
	func removeImage(_ imageName : String) {
		
		for (index, value) in wishList.enumerated()
		{
			if(value == imageName)
			{
				wishList.remove(at: index)
				break
			}
		}
	}
	
	func resetWhishList() {
		wishList = [String]()
	}
}

/// Media Caching
open class IO_MediaCaching: NSObject {
	
	fileprivate var tryCount = 0
	fileprivate var cachingCompletitionHandler : IO_MediaCachingResponseHandler!
	fileprivate var requestFile : String!
	fileprivate var urlData : NSMutableData!
	fileprivate var syncConnection: NSURLConnection!

	fileprivate var md5FileName = ""
	
	/// Media Caching
	public init(getMediaImage fileUrl : String!, completionHandler : @escaping IO_MediaCachingResponseHandler) {
		super.init()
		
		if(fileUrl != nil) {
			
			if(!fileUrl.isEmpty) {
				self.getMediaImage(fileUrl, completionHandler: completionHandler)
			}else{
				completionHandler(false, nil)
			}
		}else{
			completionHandler(false, nil)
		}
		
	}
	
	// get image if exists in cache
	fileprivate func getMediaImage(_ fileUrl : String, completionHandler : @escaping IO_MediaCachingResponseHandler) {
		
		md5FileName = fileUrl.IO_md5() + "-cached.img"

		if(IO_MediaCaching.mediaExists(md5FileName)) {

			let cachefile = NSString(string: IO_Helpers.getMediaCacheDirectory!).appendingPathComponent(md5FileName)
			let fileUrl = URL(fileURLWithPath: cachefile)
			let fileData = try? Data(contentsOf: fileUrl)
			completionHandler(true, UIImage(data: fileData!))
		}else{
			if(IO_MediaCachingRequestUrls.sharedInstance.addImage(fileUrl)) {
				cachingCompletitionHandler	= completionHandler
				tryCount = 0
				requestFile = fileUrl
				startRequest()
			}else{
				completionHandler(false, nil)
			}
		}
	}
	
	// start image download process
	fileprivate func startRequest() {

		let requestUrl = URL(string: self.requestFile)
		let urlRequest = NSMutableURLRequest(url: requestUrl!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 90)
		
		urlRequest.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
		self.urlData = NSMutableData()
		
		DispatchQueue.main.async(execute: { () -> Void in

			self.syncConnection	= NSURLConnection(request: urlRequest as URLRequest, delegate: self, startImmediately: false)
			self.syncConnection?.schedule(in: RunLoop.current, forMode: RunLoopMode.commonModes)
			self.syncConnection?.start()
		})
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	// request complete
	func connection(_ connection: NSURLConnection, didReceiveResponse response: URLResponse) {
		
		let httpResponse = response as! HTTPURLResponse
		let code = httpResponse.statusCode
		
		if(code < 200 || code >= 300) {

			RunLoop.current.cancelPerformSelectors(withTarget: self)
			connection.cancel()
			
			self.tryCount += 1
			
			if(self.tryCount < 3) {
				
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				IO_MediaCachingRequestUrls.sharedInstance.removeImage(requestFile)
				
				let dispatchDelay		= DispatchTime.now() + Double(Int64(1)) / Double(NSEC_PER_SEC)
				
				DispatchQueue.main.asyncAfter(deadline: dispatchDelay, execute: { () -> Void in
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
	func connection(_ connection: NSURLConnection, didReceiveData data: Data) {
		if (data.count == 0) {
			return;
		}
		
		urlData.append(data)
	}
	
	// download complete
	func connectionDidFinishLoading(_ connection: NSURLConnection) {
		
		RunLoop.current.cancelPerformSelectors(withTarget: self)
		UIApplication.shared.isNetworkActivityIndicatorVisible = false

		let cachefile = NSString(string: IO_Helpers.getMediaCacheDirectory!).appendingPathComponent(md5FileName)
		
		urlData.write(toFile: cachefile as String, atomically: false)
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
	func connection(_ connection: NSURLConnection, didFailWithError error: NSError) {
		
		RunLoop.current.cancelPerformSelectors(withTarget: self)
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
		connection.cancel()
		
		self.tryCount += 1
		
		if(self.tryCount < 3) {
			
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			IO_MediaCachingRequestUrls.sharedInstance.removeImage(requestFile)

			let dispatchDelay = DispatchTime.now() + Double(Int64(1)) / Double(NSEC_PER_SEC)
			DispatchQueue.main.asyncAfter(deadline: dispatchDelay, execute: { () -> Void in
				self.startRequest()
			})
		}else{
			
			if(self.cachingCompletitionHandler != nil) {
				
				self.cachingCompletitionHandler(success : false, image : nil)
			}
		}
	}
	
	/// Convert url to cache file name
	static func convertUrlToFileName(_ fileUrl: String) -> String {
		
		let md5FileName = fileUrl.IO_md5() + "-cached.img"
		return md5FileName;
	}
	
	/// Check media exists in the cache
	static func mediaExists(_ fileName : String) -> Bool {
		
		var cachefile = IO_Helpers.getMediaCacheDirectory

		if(cachefile != nil) {
			
			cachefile = NSString(string: cachefile!).appendingPathComponent(fileName)
			
			if(FileManager.default.fileExists(atPath: cachefile!))
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
	static func getMediaImageForBase64Encoded(_ fileName : String) -> String! {

		if(IO_MediaCaching.mediaExists(fileName)) {
			let cachefile = NSString(string: IO_Helpers.getMediaCacheDirectory!).appendingPathComponent(fileName)
			let fileUrl = URL(fileURLWithPath: cachefile)
			let fileData = try? Data(contentsOf: fileUrl)
			return (fileData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters))!
		}else{
			return nil
		}
	}

	/// Save file to cache directory
	static func saveFileToCache(_ fileName: String!, fileContent: Data!) {
		
		let cachefile = NSString(string: IO_Helpers.getMediaCacheDirectory!).appendingPathComponent(fileName)
		fileContent.write(to: cachefile, options: false)
	}
	
	/// Remove file from cache directory
	static func removeFileFromCache(_ fileName: String!) {
		
		let cachefile = NSString(string: IO_Helpers.getMediaCacheDirectory!).appendingPathComponent(fileName)
		do {
			try FileManager.default.removeItem(atPath: cachefile)
		} catch _ {
		}
	}
	
	// delete old images and clear whishlist
	class func clearCache(_ timeInterval: TimeInterval = -604800) {
		
		let cacheDirectory = IO_Helpers.getMediaCacheDirectory
		
		if(cacheDirectory != nil) {
			let files = FileManager.default.enumerator(atPath: cacheDirectory!)
			var fileCount = 0
			
			while let file: String = files?.nextObject() as? String {
				
				let filePath = NSString(string: cacheDirectory!).appendingPathComponent(file)
				let fileAttributes = try? FileManager.default.attributesOfItem(atPath: filePath)
			
				if(fileAttributes != nil) {
					
					if let fileCreateDate = fileAttributes?[FileAttributeKey.creationDate] as? Date {
						
						let fileCreateEpoch = fileCreateDate.timeIntervalSince1970
						let timeInterval = Date().addingTimeInterval(timeInterval).timeIntervalSince1970
						
						if(fileCreateEpoch < timeInterval) {
							
							do {
								try FileManager.default.removeItem(atPath: filePath)
							} catch _ {
							}
						}
					}
				}
				
				fileCount += 1
			}
		}
		
		IO_MediaCachingRequestUrls.sharedInstance.resetWhishList()
	}
}
