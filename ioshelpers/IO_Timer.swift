//
//  IO_Timer.swift
//  IO Helpers
//
//  Created by ilker özcan on 02/09/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//
//

import Foundation
import Dispatch

public typealias IO_TimerResponseHandler = () -> Void

/// Timer class
public class IO_Timer: NSObject {
	
	private let timerInterval: NSTimeInterval
	
	private var completitionHandler: IO_TimerResponseHandler!
	private var timer: NSTimer!
	private var isUpdating = false
	
	/// Timer class
	public init(withTimeInterval timerInterval: NSTimeInterval, completitionHandler: IO_TimerResponseHandler!) {
		
		self.timerInterval = timerInterval
		self.completitionHandler = completitionHandler
		
		super.init()
		self.Start()
	}
	
	private func Start() {
		self.timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "Update", userInfo: nil, repeats: true)
	}
	
	/// Stop timer
	public func StopTimer() {
		
		if(timer != nil) {
			timer.invalidate()
			timer = nil
			self.completitionHandler = nil
		}
	}
	
	// call update
	public func Update() {
		
		if(isUpdating) {
			return
		}
		
		isUpdating = true
		
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			
			if(self.completitionHandler != nil) {
				self.completitionHandler()
				self.isUpdating = false
			}
		})
	}

}
