//
//  IO_NetworkHelper.swift
//
//
//  Created by ilker özcan on 21/09/16.
//  Copyright © 2016 ilkerozcan. All rights reserved.
//

import Foundation
import Dispatch
import AFNetworking

public typealias IO_NetworkResponseHandler = (_ success: Bool, _ data: AnyObject?, _ errorStr: String?, _ statusCode: Int) -> Void
public typealias IO_NetworkFileHandler = (_ success: Bool, _ filePath: URL?, _ errorStr: String?, _ statusCode: Int) -> Void
public typealias IO_NetworkReachability = (_ status: Bool) -> Void

public class IO_NetworkHelper {
	
	private let maximumActiveDownloads = 7
	
#if os(iOS)
	public class func deviceIsConnectedToInternet(callback: @escaping IO_NetworkReachability) {
		
		AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) in
			
			if(status == AFNetworkReachabilityStatus.notReachable) {
				
				callback(false)
			}else{
				callback(true)
			}
		}
		AFNetworkReachabilityManager.shared().startMonitoring()
	}
#endif
	
	@discardableResult
	public init(getJSONRequest requestURL: String, completitionHandler: IO_NetworkResponseHandler?) {
		
		let networkManager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default)
		var request = URLRequest(url: URL(string: requestURL)!)
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
		let dataTask = networkManager.dataTask(with: request) { (response, data, error) in
			
			let httpResponse = response as! HTTPURLResponse
			let responseCode = httpResponse.statusCode
			
			if(responseCode < 200 || responseCode >= 300) {
				
				#if NETWORK_DEBUG
					print("Internal server error! \(responseCode)\n")
				#endif
				
				DispatchQueue.main.async(execute: { () -> Void in
					
					if(completitionHandler != nil) {
						
						completitionHandler!(false, nil, error?.localizedDescription, responseCode)
					}
					
				#if os(iOS)
					let alertMessage = IO_Helpers.getErrorMessageFromCode(9001)
					let alertview = UIAlertView(title: alertMessage.0, message: alertMessage.1, delegate: nil, cancelButtonTitle: alertMessage.2)
					alertview.show()
				#endif
				})
				
			}else{
				#if NETWORK_DEBUG
					print("Connection receive response! \(responseCode)\n \(data)")
				#endif
				
				DispatchQueue.main.async(execute: { () -> Void in
					
					if(error != nil) {
						
						if(completitionHandler != nil) {
							completitionHandler!(false, data as AnyObject?, error?.localizedDescription, responseCode)
						}
					}else{
						
						if(completitionHandler != nil) {
							completitionHandler!(true, data as AnyObject?, nil, responseCode)
						}
					}
				})
			}
			
		}
		#if NETWORK_DEBUG
			print("Request will start! \(requestURL)\n")
		#endif
		
		dataTask.resume()
	}
	
	@discardableResult
	public init(postJSONRequest requestURL: String, postData: Dictionary<String, AnyObject>, completitionHandler: IO_NetworkResponseHandler?) {
		
		let postDataString = IO_Json.JSONStringify(value: postData as AnyObject)
		let networkManager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default)
		var request = URLRequest(url: URL(string: requestURL)!)
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
		request.httpMethod = "POST"
		request.httpBody = postDataString.data(using: String.Encoding.utf8)
		
		let dataTask = networkManager.dataTask(with: request) { (response, data, error) in
			
			let httpResponse = response as! HTTPURLResponse
			let responseCode = httpResponse.statusCode
			
			if(responseCode < 200 || responseCode >= 300) {
				
				#if NETWORK_DEBUG
					print("Internal server error! \(responseCode)\n")
				#endif
				
				DispatchQueue.main.async(execute: { () -> Void in
					
					if(completitionHandler != nil) {
						
						completitionHandler!(false, nil, error?.localizedDescription, responseCode)
					}
					
					#if os(iOS)
						let alertMessage = IO_Helpers.getErrorMessageFromCode(9001)
						let alertview = UIAlertView(title: alertMessage.0, message: alertMessage.1, delegate: nil, cancelButtonTitle: alertMessage.2)
						alertview.show()
					#endif
				})
				
			}else{
				#if NETWORK_DEBUG
					print("Connection receive response! \(responseCode)\n \(data)")
				#endif
				
				DispatchQueue.main.async(execute: { () -> Void in
					
					if(error != nil) {
						
						if(completitionHandler != nil) {
							completitionHandler!(false, data as AnyObject?, error?.localizedDescription, responseCode)
						}
					}else{
						
						if(completitionHandler != nil) {
							completitionHandler!(true, data as AnyObject?, nil, responseCode)
						}
					}
				})
			}
			
		}
		#if NETWORK_DEBUG
			print("Request will start! \(requestURL)\n Post data: \n\(postDataString)\n\n")
		#endif
		
		dataTask.resume()
	}
	
	@discardableResult
	public init(downloadFile requestURL: String, displayError: Bool, completitionHandler: IO_NetworkFileHandler?) {
		
		let networkManager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default)
		var request = URLRequest(url: URL(string: requestURL)!, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 90)
		request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
		
		let fileDownloadTask = networkManager.downloadTask(with: request, progress: { (taskProgress) in
			// pass
		}, destination: { (fileUrl, urlResponse) -> URL in
			
			if let downloadsDirectory = IO_Helpers.getDownloadsDirectory {
				
				let filePath = downloadsDirectory + "/\(urlResponse.suggestedFilename!)"
				return URL(fileURLWithPath: filePath)
			}else{
				return URL(fileURLWithPath: urlResponse.suggestedFilename!)
			}
			
		}) { (urlResponse, fileUrl, error) in
			
			let httpResponse = urlResponse as! HTTPURLResponse
			let responseCode = httpResponse.statusCode
				
			if(responseCode < 200 || responseCode >= 300) {
				#if NETWORK_DEBUG
					print("Internal server error! \(responseCode)\n")
				#endif
					
				DispatchQueue.main.async(execute: { () -> Void in
					
					if(completitionHandler != nil) {
						
						completitionHandler!(false, nil, error?.localizedDescription, responseCode)
					}
					
				#if os(iOS)
					if(displayError) {
							
						let alertview = UIAlertView(title: "OOPS!", message: "Bir hata olustu. Lütfen daha sonra tekrar deneyin.", delegate: nil, cancelButtonTitle: "Tamam")
						alertview.show()
					}
				#endif
				})
			}else{
				
				/*var resourceValues = URLResourceValues()
				resourceValues.isExcludedFromBackup = true
				try? fileUrl?.setResourceValues(resourceValues.allValues)*/
				DispatchQueue.main.async(execute: { () -> Void in
					
					if(completitionHandler != nil) {
						completitionHandler!(true, fileUrl, error?.localizedDescription, 200)
					}
				})
			}
			
		}
		fileDownloadTask.resume()
	}
}
