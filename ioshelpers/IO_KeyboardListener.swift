//
//  IO_KeyboardListener.swift
//  ioshelpers
//
//  Created by ilker özcan on 07/02/16.
//  Copyright © 2016 ilkerozcan. All rights reserved.
//

import UIKit
import Foundation

public protocol IO_KeyboardListenerDelegate {
	
	func IO_KeyboardListener(keyboardDidOpen keyboardHeight: CGFloat)
	func IO_KeyboardListenerKeyboardWillDismiss()
}

// TODO: Create test case
/// Listen keyboard events
public class IO_KeyboardListener {

	var delegate: IO_KeyboardListenerDelegate!
	
	/// Listen keyboard events
	public init(withDelegate delegate: IO_KeyboardListenerDelegate!) {
		
		self.delegate = delegate
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDismiss:", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	deinit {
		self.delegate = nil
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}
	
	internal func keyboardWillShow(notification : NSNotification) {
		let keyboardInfo					= notification.userInfo!
		let endFrameValue :NSValue			= keyboardInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
		let endFrame						= endFrameValue.CGRectValue()
		let distance						= CGRectGetHeight(endFrame)

		if(self.delegate != nil) {
			self.delegate.IO_KeyboardListener(keyboardDidOpen: distance)
		}
	}
	
	internal func keyboardWillDismiss(notification : NSNotification) {
		
		if(self.delegate != nil) {
			self.delegate.IO_KeyboardListenerKeyboardWillDismiss()
		}
	}
	
}
