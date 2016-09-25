//
//  IO_UIIMage.swift
//  bahisadam
//
//  Created by ilker özcan on 24/09/16.
//  Copyright © 2016 ilkerozcan. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

	func tintedWithLinearGradientColors(colorsArr: [CGColor?]) -> UIImage {
		
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		let context = UIGraphicsGetCurrentContext()
		context!.translateBy(x: 0, y: self.size.height)
		context!.scaleBy(x: 1.0, y: -1.0)
		
		context!.setBlendMode(CGBlendMode.normal)
		let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		
		// Create gradient
		
		let colors = colorsArr as CFArray
		let space = CGColorSpaceCreateDeviceRGB()
		let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil)
		
		// Apply gradient
		
		context!.clip(to: rect, mask: self.cgImage!)
		context!.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: self.size.height), options: CGGradientDrawingOptions(rawValue: UInt32(0)))
		let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return gradientImage!
	}
	
}
