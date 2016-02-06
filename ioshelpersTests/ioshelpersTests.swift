//
//  ioshelpersTests.swift
//  ioshelpersTests
//
//  Created by ilker özcan on 04/02/16.
//  Copyright © 2016 ilkerozcan. All rights reserved.
//

import Foundation
import XCTest
@testable import IO_IOS_Helpers

class ioshelpersTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
    
    // sample commit to test by aybek can kaya
	func testCommonMethods() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		
		let currentBundle = NSBundle(forClass: self.classForCoder)
		
		let errorMessage = IO_Helpers.getErrorMessageFromCode(9001, bundle: currentBundle)
		print("\n 1- Testing error messages \n\(errorMessage.0)\n\(errorMessage.1)\n\(errorMessage.2)")
		
		let cacheDirName = IO_Helpers.getSettingValue("cacheDirectoryName", bundle: currentBundle)
		print("\n 2- Testing setting value \(cacheDirName)")
		
		XCTAssert(true, "CommonMethods PASS")
	}
	
	func testStringExtensions() {
		
		var emailTest = false
		var md5Test = false
		
		let emailString = "iletisim@ilkerozcan.com.tr"
		emailTest = emailString.IO_isEmail()
		
		let md5String = emailString.IO_md5()
		if(md5String != nil) {
			md5Test = true
		}
		
		XCTAssert((emailTest && md5Test), "StringExtensions PASS")
	}
	
	func testServerSync() {
		
		var waitingBlocks = true
		
		let _ = IO_ServerSync(standartRequest: "https://graph.facebook.com/v2.5/575688417", requestBody: "", method: IO_ServerSync.RequestMethods.GET, headers: nil) { (success, data, jsonObject) -> Void in
			
			waitingBlocks = false
			let isSuccess = (success) ? "YES" : "NO"
			print("\n\nIs Success: \(isSuccess)")
			print("Response string \(data) \n\n")
			XCTAssert(true, "IO_ServerSync PASS")
		}
		
		while(waitingBlocks) {
			NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate().dateByAddingTimeInterval(-0.1))
		}
	}
	
	func testTimer() {
		
		var waitingBlocks = true
		var timerExecuteCount = 0
		print("Testing timer ...\n\n")
		
		let timer = IO_Timer(withTimeInterval: NSTimeInterval(3)) { () -> Void in
			
			timerExecuteCount += 1
			print("\(timerExecuteCount)- Hallo!\n")
		}
		
		while(waitingBlocks) {
			NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate().dateByAddingTimeInterval(-0.1))
			
			if(timerExecuteCount > 3) {
				timer.StopTimer()
				waitingBlocks = false
				XCTAssert(true, "IO_Timer PASS")
			}
		}
	}
	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
