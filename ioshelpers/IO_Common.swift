//
//  IO_Common.swift
//  IO Helpers
//
//  Created by ilker özcan on 28/08/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//
//

import Foundation
import UIKit

private let Device = UIDevice.current
private let iosVersion = NSString(string: Device.systemVersion).doubleValue
private let AppBundle = Bundle.main

/// Helpers class
open class IO_Helpers: NSObject {
	
	/// Return bundle id
	open static let bundleID = AppBundle.bundleIdentifier!
	
	/// Is iOS 10
	open static let iOS10 = iosVersion >= 10
	/// Is iOS 9
	open static let iOS9 = iosVersion >= 9 && iosVersion < 10
	/// Is iOS 8
	open static let iOS8 = iosVersion >= 8 && iosVersion < 9
	/// Is iOS 7
	open static let iOS7 = iosVersion >= 7 && iosVersion < 8
	
	/// Returns device uuid
	open static let deviceUUID = Device.identifierForVendor!.uuidString
	
	/// Returns application name
	open static let applicationName = AppBundle.infoDictionary!["CFBundleName"] as! String
	
	/// Returns application version
	open static let applicationVersion = (AppBundle.infoDictionary!["CFBundleShortVersionString"] as! String) + " (" + (AppBundle.infoDictionary!["CFBundleVersion"] as! String) + ")"
	
	/// Returns device name
	open static let deviceName = Device.name
	/// Returns device model
	open static let devicModel = Device.model
	/// Returns device version
	open static let deviceVersion = "\(iosVersion)"
	
	/// Get error message (title, message, cancel button title)
	open static func getErrorMessageFromCode(_ errorCode : Int, bundle: Bundle? = nil) -> (String?, String?, String?) {
		
		let selectedBundle = (bundle != nil) ? bundle! : AppBundle
		
		if let helpersBundle = selectedBundle.path(forResource: "IO_IOS_Helpers", ofType: "bundle") {
			if let helperResourcesBundle = Bundle(path: helpersBundle) {
			
				if let errorCodesPath = helperResourcesBundle.path(forResource: "ErrorMessages", ofType: "plist") {
				
					let dictionary = NSDictionary(contentsOfFile: errorCodesPath)
					let errorData: NSDictionary	= dictionary?.object(forKey: String(errorCode)) as! NSDictionary
					return (errorData.object(forKey: "title") as? String, errorData.object(forKey: "message") as? String, errorData.object(forKey: "cancelButtonTitle") as? String);
				}else{
					NSLog("\n-------------\nWarning!\n-------------\nPlist ErrorMessages could not exists in the IO_IOS_Helpers bundle!\n")
					abort()
				}
			}else{
				NSLog("\n-------------\nWarning!\n-------------\nBundle IO_IOS_Helpers could not exists!\n")
				abort()
			}
		}else{
			NSLog("\n-------------\nWarning!\n-------------\nBundle IO_IOS_Helpers could not exists!\n")
			abort()
		}
	}
	
	/// Return media cache directory
	open static var getMediaCacheDirectory : String? {
		
		get {
			
			let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
			
			if paths.count > 0 {
				
				let cacheDirectory = paths[0]
				
				let CacheDirectoryName = IO_Helpers.getSettingValue("cacheDirectoryName")
				let mediaCachePath = NSString(string: cacheDirectory).appendingPathComponent(CacheDirectoryName)
				
				if(!FileManager.default.fileExists(atPath: mediaCachePath)) {
					
					do {
						try FileManager.default.createDirectory(atPath: mediaCachePath, withIntermediateDirectories: true, attributes: nil)
					} catch _ {
					}
				}
				
				return mediaCachePath as String
			}else{
				return nil
			}
		}
	}
	
	/// Return media cache directory
	open static var getDownloadsDirectory : String? {
		
		get {
			
			let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
			
			if paths.count > 0 {
				
				let downloadDirectory = paths[0]
				
				let DownloadDirectoryName = IO_Helpers.getSettingValue("downloadDirectoryName")
				let downloadDirPath = NSString(string: downloadDirectory).appendingPathComponent(DownloadDirectoryName)
				
				if(!FileManager.default.fileExists(atPath: downloadDirPath)) {
					
					do {
						try FileManager.default.createDirectory(atPath: downloadDirPath, withIntermediateDirectories: true, attributes: nil)
					} catch _ {
					}
				}
				
				return downloadDirPath as String
			}else{
				return nil
			}
		}
	}
	
	/// Get screen resolution (CGFloat, CGFloat)
	open static func getResolution() -> (CGFloat, CGFloat) {
		
		return (UIScreen.main.bounds.width, UIScreen.main.bounds.height);
	}
	
	/// gerate random alphanumeric string
	open static func generateRandomAlphanumeric(_ characterCount: Int) -> String {
		
		let characterSet	= "123456789abcdefghijkmnpqrstuvyz"
		var randomString	= ""
		
		for _ in 0..<characterCount {
			
			let randomNumber = IO_Helpers.randomInt(0, max: characterSet.characters.count - 1)
			let endIdx = randomNumber + 1
			let _startIdx = characterSet.characters.index(characterSet.startIndex, offsetBy: randomNumber)
			let _endIdx = characterSet.characters.index(characterSet.startIndex, offsetBy: endIdx)
			let rangeString = Range<String.Index>(_startIdx..<_endIdx)
			let selectedCharacter = characterSet.substring(with: rangeString)
			randomString	+= selectedCharacter
		}
		
		return randomString
	}
	
	/// Generate random integer
	public static func randomInt(_ min: Int, max:Int) -> Int {
		var min = min, max = max
        
        if(max < min)
        {
            // swap
            let temp = min
            min = max
            max = temp
        }
        else if(max == min)
        {
            return min 
        }
        
        let diff = abs(max - min)
        
		return min + Int(arc4random_uniform(UInt32(diff)))
	}
	
	/// Convert radians to degrees for location
	open static func mathDegrees(_ radians : Double) -> Double {
		return (radians * (180.0 / Double(M_PI)))
	}
	
	/// Convert degrees to radians for location
	open func mathRadians(_ degrees : Double) ->Double {
		return (degrees / (180.0 * Double(M_PI)))
	}
	
	/// Convert miles to kilometers
	open func convertMilesToKilemoters(_ miles: Double) -> Double {
		return miles * 1.60934
	}
	
	/// Get setting value from Settings.plist
	open static func getSettingValue(_ settingKey: String, bundle: Bundle? = nil) -> String {
		
		let selectedBundle = (bundle != nil) ? bundle! : AppBundle
		
		if let helpersBundle = selectedBundle.path(forResource: "IO_IOS_Helpers", ofType: "bundle") {
			
			if let helperResourcesBundle = Bundle(path: helpersBundle) {
			
				if let plistPath = helperResourcesBundle.path(forResource: "Settings", ofType: "plist") {
				
					let dictionary = NSDictionary(contentsOfFile: plistPath)
					let settingValue: String = dictionary?.object(forKey: settingKey) as! String
					return settingValue
				}else{
					NSLog("\n-------------\nWarning!\n-------------\nPlist ErrorMessages could not exists in the IO_IOS_Helpers bundle!\n")
					abort()
				}
			}else{
				NSLog("\n-------------\nWarning!\n-------------\nBundle IO_IOS_Helpers could not exists!\n")
				abort()
			}
		}else{
			NSLog("\n-------------\nWarning!\n-------------\nBundle IO_IOS_Helpers could not exists!\n")
			abort()
		}
	}
}

/// uiview cntroller extensions
extension UIViewController {
	
	/// Present modal view right to left animation
	public func IO_presentViewControllerWithCustomAnimation(_ viewControllerToPresent: UIViewController!) {
		let screenSizeWidth							= UIScreen.main.bounds.size.width
		let startTransition							= CGAffineTransform(translationX: screenSizeWidth, y: 0)
		viewControllerToPresent.view.isHidden			= true
		self.present(viewControllerToPresent, animated: false, completion: { () -> Void in
			
			viewControllerToPresent.view.isHidden			= false
			viewControllerToPresent.view.transform		= startTransition
			let destinationTransform					= CGAffineTransform(translationX: 0, y: 0)
			UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.05, options: [], animations: { () -> Void in
				
				viewControllerToPresent.view.transform	= destinationTransform
			}, completion: { finished in
					
				viewControllerToPresent.view.transform	= destinationTransform
			})
			
		})
	}
	
	/// Dismiss modal view right to left animation
	public func IO_dismissViewControllerWithCustomAnimation() {
		
		let screenSizeWidth							= UIScreen.main.bounds.size.width
		let destinationTransform					= CGAffineTransform(translationX: screenSizeWidth, y: 0)
		
		UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.05, options: [], animations: { () -> Void in
			
			self.view.transform					= destinationTransform
		}, completion: { finished in
				
			self.view.transform					= destinationTransform
			self.dismiss(animated: false, completion: nil)
		})
		
	}
}

