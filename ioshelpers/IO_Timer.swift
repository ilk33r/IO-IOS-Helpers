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

public typealias IO_TimerResponseHandler = (_ elapsedSteps: Int) -> Void


/// Timer class
open class IO_Timer: NSObject {
	
	fileprivate let timerInterval: TimeInterval
	
	fileprivate var completitionHandler: IO_TimerResponseHandler!
	fileprivate var timer: Timer!
	fileprivate var isUpdating = false
    
    fileprivate var stepsElapsed:Int = 0
    
    
	
	/// Timer class
	public init(withTimeInterval timerInterval: TimeInterval, completitionHandler: IO_TimerResponseHandler!) {
		
		self.timerInterval = timerInterval
		self.completitionHandler = completitionHandler
		
		super.init()
		self.Start()
	}

	fileprivate func Start() {
        
         stepsElapsed = 0
        self.timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(IO_Timer.Update), userInfo: nil, repeats: true)
        
	}
	
	/// Stop timer
	open func StopTimer() {
		
		if(timer != nil) {
			timer.invalidate()
			timer = nil
			self.completitionHandler = nil
            
            stepsElapsed = 0
		}
	}
	
	// call update
	open func Update() {
		
		if(isUpdating) {
			return
		}
		
		isUpdating = true
		
        stepsElapsed += 1
		DispatchQueue.main.async(execute: { () -> Void in
			
			if(self.completitionHandler != nil) {
				self.completitionHandler(elapsedSteps: self.stepsElapsed)
				self.isUpdating = false
			}
		})
	}

}
