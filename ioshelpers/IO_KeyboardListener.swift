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
open class IO_KeyboardListener {

	var delegate: IO_KeyboardListenerDelegate!
	
	/// Listen keyboard events
	public init(withDelegate delegate: IO_KeyboardListenerDelegate!) {
		
		self.delegate = delegate
		NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillShow:")), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillDismiss:")), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	deinit {
		self.delegate = nil
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	internal func keyboardWillShow(_ notification : Notification) {
		let keyboardInfo					= (notification as NSNotification).userInfo!
		let endFrameValue :NSValue			= keyboardInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
		let endFrame						= endFrameValue.cgRectValue
		let distance						= endFrame.height

		if(self.delegate != nil) {
			self.delegate.IO_KeyboardListener(keyboardDidOpen: distance)
		}
	}
	
	internal func keyboardWillDismiss(_ notification : Notification) {
		
		if(self.delegate != nil) {
			self.delegate.IO_KeyboardListenerKeyboardWillDismiss()
		}
	}
	
}
