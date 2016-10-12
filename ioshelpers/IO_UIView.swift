//
//  IO_UIView.swift
//  bahisadam
//
//  Created by ilker özcan on 24/09/16.
//  Copyright © 2016 ilkerozcan. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable extension UIView {

	@IBInspectable var borderColor:UIColor? {
		set {
			layer.borderColor = newValue!.cgColor
		}
		get {
			if let color = layer.borderColor {
				return UIColor(cgColor:color)
			}
			else {
				return nil
			}
		}
	}
	@IBInspectable var borderWidth:CGFloat {
		set {
			layer.borderWidth = newValue
		}
		get {
			return layer.borderWidth
		}
	}
	@IBInspectable var cornerRadius:CGFloat {
		set {
			layer.cornerRadius = newValue
			clipsToBounds = newValue > 0
		}
		get {
			return layer.cornerRadius
		}
	}
}
