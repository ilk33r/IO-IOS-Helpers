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

typealias IO_NetworkResponseHandler = (_ success: Bool, _ data: AnyObject?, _ errorStr: String?) -> Void

class IO_NetworkHelper {
	
	private var completitionHandler: IO_NetworkResponseHandler
	
	init(withGetRequest requestURL: String, completitionHandler: @escaping IO_NetworkResponseHandler) {
		
		self.completitionHandler = completitionHandler
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
					
					self.completitionHandler(false, nil, error?.localizedDescription)
					let alertview = UIAlertView(title: "OOPS!", message: "Bir hata olustu. Lütfen daha sonra tekrar deneyin.", delegate: nil, cancelButtonTitle: "Tamam")
					alertview.show()
				})
				
			}else{
				#if NETWORK_DEBUG
					print("Connection receive response! \(responseCode)\n \(data)")
				#endif
				
				DispatchQueue.main.async(execute: { () -> Void in
					
					if(error != nil) {
						
						self.completitionHandler(false, data as AnyObject?, error?.localizedDescription)
					}else{
						
						self.completitionHandler(true, data as AnyObject?, nil)
					}
				})
			}
			
		}
		#if NETWORK_DEBUG
			print("Request will start! \(requestURL)\n")
		#endif
		
		dataTask.resume()
	}
}
