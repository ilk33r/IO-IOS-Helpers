//
//  IO_ServerSync.swift
//  IO Helpers
//
//  Created by ilker özcan on 01/03/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//

import UIKit
import SystemConfiguration

public typealias IO_ServerSyncResponseHandler = (success: Bool, data: String!, jsonObject: AnyObject!) -> Void

public struct IO_HttpHeader {
	
	let headerName: String
	let headerValue: String
	
	init(headerName: String, headerValue: String) {
		
		self.headerName = headerName
		self.headerValue = headerValue
	}
}

public class IO_Reachability {
	
	class func isConnectedToNetwork() -> Bool {
		var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
		zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
		zeroAddress.sin_family = sa_family_t(AF_INET)
		
		let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
			
			SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
		}
		
		var flags = SCNetworkReachabilityFlags(rawValue: 0)
		
		SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags)
		
		let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
		let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
		
		return (isReachable && !needsConnection) ? true : false
	}
}

/// Api connection class
public class IO_ServerSync: NSObject {
	
	public enum RequestMethods: String {
		case POST = "POST"
		case GET = "GET"
	}
	
	private var requestUrl: NSURL!
	private var completitionHandler: IO_ServerSyncResponseHandler!
	private var parameters: Dictionary<String, AnyObject>!
	private var formData: String!
	private var customHeaders: [IO_HttpHeader]!
	private var urlData: NSMutableData!
	private var syncConnection: NSURLConnection!
	
	private var connectionFinished = false
	private var internalServerError = false
	private var isJsonRequest = false
	private var requestMethodString = ""
		
	/// Api connection class
	public init(jsonRequest requestUrl : String, parameters : Dictionary<String, AnyObject>, method: RequestMethods, completitionHandler : IO_ServerSyncResponseHandler) {

		self.requestUrl = NSURL(string: requestUrl)
		self.parameters = parameters
		self.requestMethodString = method.rawValue
		self.completitionHandler = completitionHandler
		self.isJsonRequest = true
		super.init()

		#if NETWORK_DEBUG
			print("Request start \(requestUrl)\n")
		#endif
		
		startRequest()
	}
	
	/// Api connection class
	public init(jsonRequestWithHeaders requestUrl : String, parameters : Dictionary<String, AnyObject>, method: RequestMethods, headers: [IO_HttpHeader], completitionHandler : IO_ServerSyncResponseHandler) {
		
		self.requestUrl = NSURL(string: requestUrl)
		self.parameters = parameters
		self.requestMethodString = method.rawValue
		self.completitionHandler = completitionHandler
		self.customHeaders = headers
		self.isJsonRequest = true
		super.init()
		
		#if NETWORK_DEBUG
			print("Request start \(requestUrl)\n")
		#endif
		
		startRequest()
	}

	/// Api connection class
	public init (multipartFormDataRequest requestUrl : String, parameters : Dictionary<String, AnyObject>, completitionHandler : IO_ServerSyncResponseHandler) {
		
		self.requestUrl = NSURL(string: requestUrl)
		self.completitionHandler = completitionHandler
		self.parameters = parameters
		self.requestMethodString = "POST"
		super.init()
		
		#if NETWORK_DEBUG
			print("Request start \(requestUrl)")
		#endif
		
		startMultipartFormDataRequest()
	}
	
	/// Api connection class
	public init (multipartFormDataRequestWithHeaders requestUrl : String, parameters : Dictionary<String, AnyObject>, headers: [IO_HttpHeader], completitionHandler : IO_ServerSyncResponseHandler) {
		
		self.requestUrl = NSURL(string: requestUrl)
		self.completitionHandler = completitionHandler
		self.parameters = parameters
		self.requestMethodString = "POST"
		self.customHeaders = headers
		super.init()
		
		#if NETWORK_DEBUG
			print("Request start \(requestUrl)")
		#endif
		
		startMultipartFormDataRequest()
	}
	
	/// Api connection class
	public init(standartRequest requestUrl: String, requestBody: String!, method: RequestMethods, headers: [IO_HttpHeader]!, completitionHandler : IO_ServerSyncResponseHandler) {
		
		self.requestUrl = NSURL(string: requestUrl)
		self.formData = requestBody
		self.requestMethodString = method.rawValue
		self.completitionHandler = completitionHandler
		self.customHeaders = headers
		self.isJsonRequest = false
		super.init()
		
		#if NETWORK_DEBUG
			print("Request start \(requestUrl)\n")
		#endif
		
		startRequest()
	}
	
	// start json request
	private func startRequest() {
		
		if(IO_Reachability.isConnectedToNetwork()) {
			
			let urlRequest = NSMutableURLRequest(URL: self.requestUrl, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 90)
			urlRequest.HTTPMethod = self.requestMethodString
			
			if(self.isJsonRequest) {
				urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
				urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
			}else{
				urlRequest.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
			}
			urlRequest.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
			
			if(self.customHeaders != nil) {
				
				for(var i = 0, hl = self.customHeaders.count; i < hl; i++) {
					
					urlRequest.addValue(customHeaders[i].headerValue, forHTTPHeaderField: customHeaders[i].headerName)
				}
			}
			
			if(self.requestMethodString == "POST") {

				let requestBody: String
				if(self.isJsonRequest) {
					requestBody = IO_Json.JSONStringify(self.parameters, prettyPrinted: false)
				}else{
					requestBody = self.formData
				}
				
				urlRequest.addValue("\(requestBody.characters.count)", forHTTPHeaderField: "Content-Length")
				urlRequest.HTTPBody = requestBody.dataUsingEncoding(NSUTF8StringEncoding)
			}
			
			urlData = NSMutableData()
			UIApplication.sharedApplication().networkActivityIndicatorVisible		= true
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				
				self.syncConnection = NSURLConnection(request: urlRequest, delegate: self, startImmediately: false)
				self.syncConnection?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
				self.syncConnection?.start()
			})

			connectionFinished = false
		}else{
			
			if(self.completitionHandler != nil) {
				
				self.completitionHandler(success: false, data: nil, jsonObject: nil)
			}
		}
	}
	
	// start multipart request
	private func startMultipartFormDataRequest() {
		
		if(IO_Reachability.isConnectedToNetwork()) {
			
			let urlRequest = NSMutableURLRequest(URL: self.requestUrl, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 90)
			urlRequest.HTTPMethod = self.requestMethodString
			
			let boundaryString = "----IOFormBoundary" + IO_Helpers.generateRandomAlphanumeric(12)
			if(self.isJsonRequest) {
				urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
			}else{
				urlRequest.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
			}

			urlRequest.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
			urlRequest.addValue("multipart/form-data; boundary=\(boundaryString)", forHTTPHeaderField: "Content-Type")
				
			let postBodyData = NSMutableData()
			let boundaryStartString = "--\(boundaryString)\r\n" as NSString
			let contentDispositionString = "Content-Disposition: form-data; name=\"UploadedImage\"; filename=\"userProfilePicture.jpg\"\r\n" as NSString
			let contentTypeString = "Content-Type: image/jpeg\r\n\r\n" as NSString
			let boundaryEndString = "\r\n--\(boundaryString)--\r\n" as NSString
				
			postBodyData.appendData(boundaryStartString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
			postBodyData.appendData(contentDispositionString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
			postBodyData.appendData(contentTypeString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
			let imageData = NSData(contentsOfURL: self.parameters["Image"] as! NSURL)
			postBodyData.appendData(imageData!)
			postBodyData.appendData(boundaryEndString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
				
			urlRequest.addValue("\(postBodyData.length)", forHTTPHeaderField: "Content-Length")
			urlRequest.HTTPBody = postBodyData
			
			urlData							= NSMutableData()
			
			UIApplication.sharedApplication().networkActivityIndicatorVisible = true
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.syncConnection				= NSURLConnection(request: urlRequest, delegate: self, startImmediately: false)
				self.syncConnection?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
				self.syncConnection?.start()
			})
			
			connectionFinished				= false
			
		}else{
			if(self.completitionHandler != nil) {
				
				self.completitionHandler(success: false, data: nil, jsonObject: nil)
			}
		}
	}

	// connection failed
	func connection(connection: NSURLConnection, didFailWithError error: NSError) {
		
		connection.cancel()
		UIApplication.sharedApplication().networkActivityIndicatorVisible		= false
		connectionFinished = true
		NSRunLoop.currentRunLoop().cancelPerformSelectorsWithTarget(self)
		self.requestUrl = nil
		self.parameters = nil
		self.customHeaders = nil
		self.urlData = nil
		self.syncConnection = nil
		
		if(self.completitionHandler != nil) {
			
			#if NETWORK_DEBUG
			print("Connection failed! \(error.description)\n")
			#endif
			self.completitionHandler(success: false, data: nil, jsonObject: nil)
		}
	}
		
	// request complete
	func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
		
		let httpResponse = response as! NSHTTPURLResponse
		let code = httpResponse.statusCode
			
		if(code < 200 || code >= 300) {
			
			internalServerError				= true
		}else{
			#if NETWORK_DEBUG
			print("Connection receive response! \(code)\n")
			#endif
		}
	}
		
	// synchronization data
	func connection(connection: NSURLConnection, didReceiveData data: NSData) {
		
		if (data.length == 0) {
			return;
		}
			
		urlData.appendData(data)
	}
		
	// synchronization finished
	func connectionDidFinishLoading(connection: NSURLConnection) {
		
		UIApplication.sharedApplication().networkActivityIndicatorVisible		= false
		connectionFinished		= true
		NSRunLoop.currentRunLoop().cancelPerformSelectorsWithTarget(self)
		self.requestUrl = nil
		self.parameters = nil
		self.customHeaders = nil
		self.syncConnection = nil
		
		var dataString : String!
			
		if(self.urlData == nil) {
			dataString = ""
		}else if (self.urlData.length == 0) {
			dataString = ""
		}else{
			dataString = NSString(data: self.urlData, encoding: NSUTF8StringEncoding) as! String
		}
		
		self.urlData = nil
		
		if internalServerError {
			#if NETWORK_DEBUG
				print("Failed request \(requestUrl) \(dataString)")
			#endif
			self.completitionHandler(success: false, data: dataString, jsonObject: nil)
			return
		}else{
			#if NETWORK_DEBUG
				print("Success request \(requestUrl) \(dataString)")
			#endif
		}
		
		if(self.isJsonRequest) {
			
			let responseData = IO_Json.JSONParseDictionary(dataString)
			self.completitionHandler(success: true, data: dataString, jsonObject: responseData)
		}else{
			self.completitionHandler(success: true, data: dataString, jsonObject: nil)
		}
	}
	
	// set connection protection rules for secure urls
	func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool {
		
		let protectionMethod = protectionSpace.authenticationMethod
		
		if(protectionMethod == NSURLAuthenticationMethodServerTrust) {
			return true
		}
		
		return false;
	}
	
	// trust only selected server ssl certificate
	/*
	func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
		
		if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
			
			let trustRef = challenge.protectionSpace.serverTrust
			SecTrustEvaluate(trustRef!, nil)
			let certificateCount = SecTrustGetCertificateCount(trustRef!)
			var trustStatus = false
			
			if(certificateCount > 0) {
				
				let certificate0 = SecTrustGetCertificateAtIndex(trustRef!, 0)
				let certSummary = SecCertificateCopySubjectSummary(certificate0!)
				let certificate1 = SecTrustGetCertificateAtIndex(trustRef!, 1)
				let caCertSummary = SecCertificateCopySubjectSummary(certificate1!)
				
				let summaryString = certSummary as NSString
				let caSummaryString = caCertSummary as NSString
				
				
				if(summaryString == "CN 1" && caSummaryString == "CN 2") {
					trustStatus = true
				}
			}
			
			if(trustStatus) {
				challenge.sender!.useCredential(NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!), forAuthenticationChallenge: challenge)
				return
			}
		}
		
		challenge.sender!.continueWithoutCredentialForAuthenticationChallenge(challenge)
	}
	*/
}
