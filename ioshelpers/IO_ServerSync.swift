//
//  IO_ServerSync.swift
//  IO Helpers
//
//  Created by ilker özcan on 01/03/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//

import UIKit
import SystemConfiguration

public typealias IO_ServerSyncResponseHandler = (_ success: Bool, _ data: String?, _ jsonObject: AnyObject?) -> Void

public struct IO_HttpHeader {
	
	let headerName: String
	let headerValue: String
	
	init(headerName: String, headerValue: String) {
		
		self.headerName = headerName
		self.headerValue = headerValue
	}
}

open class IO_Reachability {
	
	class func isConnectedToNetwork() -> Bool {
		var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
		zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
		zeroAddress.sin_family = sa_family_t(AF_INET)
		
		let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
			
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
open class IO_ServerSync: NSObject, NSURLConnectionDelegate {
	
	public enum RequestMethods: String {
		case POST = "POST"
		case GET = "GET"
	}
	
	fileprivate var requestUrl: URL!
	fileprivate var completitionHandler: IO_ServerSyncResponseHandler!
	fileprivate var parameters: Dictionary<String, AnyObject>!
	fileprivate var formData: String!
	fileprivate var customHeaders: [IO_HttpHeader]!
	fileprivate var urlData: NSMutableData!
	fileprivate var syncConnection: NSURLConnection!
	
	fileprivate var connectionFinished = false
	fileprivate var internalServerError = false
	fileprivate var isJsonRequest = false
	fileprivate var requestMethodString = ""
		
	/// Api connection class
	public init(jsonRequest requestUrl : String, parameters : Dictionary<String, AnyObject>, method: RequestMethods, completitionHandler : @escaping IO_ServerSyncResponseHandler) {

		self.requestUrl = URL(string: requestUrl)
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
	public init(jsonRequestWithHeaders requestUrl : String, parameters : Dictionary<String, AnyObject>, method: RequestMethods, headers: [IO_HttpHeader], completitionHandler : @escaping IO_ServerSyncResponseHandler) {
		
		self.requestUrl = URL(string: requestUrl)
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
	public init (multipartFormDataRequest requestUrl : String, parameters : Dictionary<String, AnyObject>, completitionHandler : @escaping IO_ServerSyncResponseHandler) {
		
		self.requestUrl = URL(string: requestUrl)
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
	public init (multipartFormDataRequestWithHeaders requestUrl : String, parameters : Dictionary<String, AnyObject>, headers: [IO_HttpHeader], completitionHandler : @escaping IO_ServerSyncResponseHandler) {
		
		self.requestUrl = URL(string: requestUrl)
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
	public init(standartRequest requestUrl: String, requestBody: String!, method: RequestMethods, headers: [IO_HttpHeader]!, completitionHandler : @escaping IO_ServerSyncResponseHandler) {
		
		self.requestUrl = URL(string: requestUrl)
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
	fileprivate func startRequest() {
		
		if(IO_Reachability.isConnectedToNetwork()) {
			
			let urlRequest = NSMutableURLRequest(url: self.requestUrl, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 90)
			urlRequest.httpMethod = self.requestMethodString
			
			if(self.isJsonRequest) {
				urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
				urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
			}else{
				urlRequest.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8", forHTTPHeaderField: "Accept")
			}
			urlRequest.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
			
			if(self.customHeaders != nil) {
				
				for(var i = 0, hl = self.customHeaders.count; i < hl; i += 1) {
					
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
				urlRequest.httpBody = requestBody.data(using: String.Encoding.utf8)
			}
			
			urlData = NSMutableData()
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			DispatchQueue.main.async(execute: { () -> Void in
				
				self.syncConnection = NSURLConnection(request: urlRequest as URLRequest, delegate: self, startImmediately: false)
				self.syncConnection?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
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
	fileprivate func startMultipartFormDataRequest() {
		
		if(IO_Reachability.isConnectedToNetwork()) {
			
			let urlRequest = NSMutableURLRequest(url: self.requestUrl, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 90)
			urlRequest.httpMethod = self.requestMethodString
			
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
				
			postBodyData.append(boundaryStartString.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
			postBodyData.append(contentDispositionString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: true)!)
			postBodyData.append(contentTypeString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: true)!)
			let imageData = try? Data(contentsOf: self.parameters["Image"] as! URL)
			postBodyData.append(imageData!)
			postBodyData.append(boundaryEndString.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
				
			urlRequest.addValue("\(postBodyData.length)", forHTTPHeaderField: "Content-Length")
			urlRequest.httpBody = postBodyData as Data
			
			urlData							= NSMutableData()
			
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			DispatchQueue.main.async(execute: { () -> Void in
				self.syncConnection				= NSURLConnection(request: urlRequest as URLRequest, delegate: self, startImmediately: false)
				self.syncConnection?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
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
	open func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
		
		connection.cancel()
		UIApplication.shared.isNetworkActivityIndicatorVisible		= false
		connectionFinished = true
		RunLoop.current.cancelPerformSelectors(withTarget: self)
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
	open func connection(_ connection: NSURLConnection, didReceiveResponse response: URLResponse) {
		
		let httpResponse = response as! HTTPURLResponse
		let code = httpResponse.statusCode
			
		if(code < 200 || code >= 300) {
			
			internalServerError				= true
			#if NETWORK_DEBUG
				print("Internal server error! \(code)\n")
			#endif
		}else{
			#if NETWORK_DEBUG
			print("Connection receive response! \(code)\n")
			#endif
		}
	}
		
	// synchronization data
	open func connection(_ connection: NSURLConnection, didReceiveData data: Data) {
		
		if (data.count == 0) {
			return;
		}
			
		urlData.append(data)
	}
		
	// synchronization finished
	open func connectionDidFinishLoading(_ connection: NSURLConnection) {
		
		UIApplication.shared.isNetworkActivityIndicatorVisible		= false
		connectionFinished		= true
		RunLoop.current.cancelPerformSelectors(withTarget: self)
		self.parameters = nil
		self.customHeaders = nil
		self.syncConnection = nil
		
		var dataString : String!
			
		if(self.urlData == nil) {
			dataString = ""
		}else if (self.urlData.length == 0) {
			dataString = ""
		}else{
			dataString = NSString(data: self.urlData as Data, encoding: String.Encoding.utf8.rawValue) as! String
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
		
		self.requestUrl = nil
		if(self.isJsonRequest) {
			
			let responseData = IO_Json.JSONParseDictionary(dataString)
			self.completitionHandler(success: true, data: dataString, jsonObject: responseData)
		}else{
			self.completitionHandler(success: true, data: dataString, jsonObject: nil)
		}
	}
	
	// set connection protection rules for secure urls
	open func connection(_ connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: URLProtectionSpace) -> Bool {
		
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
