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

typealias IO_NetworkResponseHandler = (_ success: Bool, _ data: AnyObject?, _ errorStr: String?, _ statusCode: Int) -> Void
typealias IO_NetworkImageHandler = (_ success: Bool, _ image: UIImage?, _ errorStr: String?, _ statusCode: Int) -> Void

class IO_NetworkHelper {
	
	private let maximumActiveDownloads = 7
	
	@discardableResult
	init(getJSONRequest requestURL: String, completitionHandler: @escaping IO_NetworkResponseHandler) {
		
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
					
					completitionHandler(false, nil, error?.localizedDescription, responseCode)
					let alertMessage = IO_Helpers.getErrorMessageFromCode(9001)
					let alertview = UIAlertView(title: alertMessage.0, message: alertMessage.1, delegate: nil, cancelButtonTitle: alertMessage.2)
					alertview.show()
				})
				
			}else{
				#if NETWORK_DEBUG
					print("Connection receive response! \(responseCode)\n \(data)")
				#endif
				
				DispatchQueue.main.async(execute: { () -> Void in
					
					if(error != nil) {
						
						completitionHandler(false, data as AnyObject?, error?.localizedDescription, responseCode)
					}else{
						
						completitionHandler(true, data as AnyObject?, nil, responseCode)
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
	init(downloadImage requestURL: String, completitionHandler: @escaping IO_NetworkImageHandler) {
		
		var request = URLRequest(url: URL(string: requestURL)!, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 90)
		request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
		
		if let cachedImage = AFImageDownloader.defaultURLCache().cachedResponse(for: request) {
			
			let image = UIImage(data: cachedImage.data)
			DispatchQueue.main.async(execute: { () -> Void in
				
				completitionHandler(true, image, nil, 200)
			})
		}else{
			AFImageDownloader.defaultInstance().downloadImage(for: request, success: { (request, response, image) in
				
				DispatchQueue.main.async(execute: { () -> Void in
					completitionHandler(true, image, nil, 200)
				})
				
			}, failure: { (request, response, error) in
				if let responseCode = response?.statusCode {
					
					if(responseCode < 200 || responseCode >= 300) {
						
						#if NETWORK_DEBUG
							print("Internal server error! \(responseCode)\n")
						#endif
						
						DispatchQueue.main.async(execute: { () -> Void in
							
							completitionHandler(false, nil, error.localizedDescription, responseCode)
							let alertview = UIAlertView(title: "OOPS!", message: "Bir hata olustu. Lütfen daha sonra tekrar deneyin.", delegate: nil, cancelButtonTitle: "Tamam")
							alertview.show()
						})
						
					}
				}else{
					DispatchQueue.main.async(execute: { () -> Void in
						completitionHandler(false, nil, error.localizedDescription, 0)
					})
				}
			})
		}
	}
}
