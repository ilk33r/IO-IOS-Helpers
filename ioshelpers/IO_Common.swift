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

private let Device = UIDevice.currentDevice()
private let iosVersion = NSString(string: Device.systemVersion).doubleValue
private let AppBundle = NSBundle.mainBundle()

/// Helpers class
public class IO_Helpers: NSObject {
	
	/// Return bundle id
	public static let bundleID = AppBundle.bundleIdentifier!
	
	/// Is iOS 10
	public static let iOS10 = iosVersion >= 10
	/// Is iOS 9
	public static let iOS9 = iosVersion >= 9 && iosVersion < 10
	/// Is iOS 8
	public static let iOS8 = iosVersion >= 8 && iosVersion < 9
	/// Is iOS 7
	public static let iOS7 = iosVersion >= 7 && iosVersion < 8
	
	/// Returns device uuid
	public static let deviceUUID = Device.identifierForVendor!.UUIDString
	
	/// Returns application name
	public static let applicationName = AppBundle.infoDictionary!["CFBundleName"] as! String
	
	/// Returns application version
	public static let applicationVersion = (AppBundle.infoDictionary!["CFBundleShortVersionString"] as! String) + " (" + (AppBundle.infoDictionary!["CFBundleVersion"] as! String) + ")"
	
	/// Returns device name
	public static let deviceName = Device.name
	/// Returns device model
	public static let devicModel = Device.model
	/// Returns device version
	public static let deviceVersion = "\(iosVersion)"
	
	/// Get error message (title, message, cancel button title)
	public static func getErrorMessageFromCode(errorCode : Int, bundle: NSBundle? = nil) -> (String?, String?, String?) {
		
		let selectedBundle = (bundle != nil) ? bundle! : AppBundle
		
		if let helpersBundle = selectedBundle.pathForResource("IO_IOS_Helpers", ofType: "bundle") {
			if let helperResourcesBundle = NSBundle(path: helpersBundle) {
			
				if let errorCodesPath = helperResourcesBundle.pathForResource("ErrorMessages", ofType: "plist") {
				
					let dictionary = NSDictionary(contentsOfFile: errorCodesPath)
					let errorData: NSDictionary	= dictionary?.objectForKey(String(errorCode)) as! NSDictionary
					return (errorData.objectForKey("title") as? String, errorData.objectForKey("message") as? String, errorData.objectForKey("cancelButtonTitle") as? String);
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
	public static var getMediaCacheDirectory : String? {
		
		get {
			
			let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
			
			if paths.count > 0 {
				
				let cacheDirectory = paths[0]
				
				let CacheDirectoryName = IO_Helpers.getSettingValue("cacheDirectoryName")
				let mediaCachePath = NSString(string: cacheDirectory).stringByAppendingPathComponent(CacheDirectoryName)
				
				if(!NSFileManager.defaultManager().fileExistsAtPath(mediaCachePath)) {
					
					do {
						try NSFileManager.defaultManager().createDirectoryAtPath(mediaCachePath, withIntermediateDirectories: true, attributes: nil)
					} catch _ {
					}
				}
				
				return mediaCachePath as String
			}else{
				return nil
			}
		}
	}
	
	/// Get screen resolution (CGFloat, CGFloat)
	public static func getResolution() -> (CGFloat, CGFloat) {
		
		return (UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
	}
	
	/// gerate random alphanumeric string
	public static func generateRandomAlphanumeric(characterCount: Int) -> String
	{
		let characterSet	= "123456789abcdefghijkmnpqrstuvyz"
		var randomString	= ""
		
		for(var i = 0; i < characterCount; i++)
		{
			let randomNumber		= IO_Helpers.randomInt(0, max: characterSet.characters.count - 1)
			let endIdx				= randomNumber + 1
			let selectedCharacter	= characterSet.substringWithRange(Range<String.Index>(start: characterSet.startIndex.advancedBy(randomNumber), end: characterSet.startIndex.advancedBy(endIdx)))
			
			//characterSet.substringWithRange(Range<String.Index>(start: advance(randomNumber, 1), end: advance(randomNumber + 1, 0)))
			randomString	+= selectedCharacter
		}
		
		return randomString
	}
	
	/// Generate random integer
	public static func randomInt(var min: Int, var max:Int) -> Int {
        
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
    
    /*
    public static func randomDouble(var min:Double , var max:Double)->Double {
        
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

        let diff:Double = Double(abs(max - min))
      
        let
        
        var randDouble = min + Double(arc4random())%diff
        
        randDouble = drand48()
        
        return randDouble
    
    }
    */
	
	/// Convert radians to degrees for location
	public static func mathDegrees(radians : Double) -> Double {
		return (radians * (180.0 / Double(M_PI)))
	}
	
	/// Convert degrees to radians for location
	public func mathRadians(degrees : Double) ->Double {
		return (degrees / (180.0 * Double(M_PI)))
	}
	
	/// Convert miles to kilometers
	public func convertMilesToKilemoters(miles: Double) -> Double {
		return miles * 1.60934
	}
	
	/// Get setting value from Settings.plist
	public static func getSettingValue(settingKey: String, bundle: NSBundle? = nil) -> String {
		
		let selectedBundle = (bundle != nil) ? bundle! : AppBundle
		
		if let helpersBundle = selectedBundle.pathForResource("IO_IOS_Helpers", ofType: "bundle") {
			
			if let helperResourcesBundle = NSBundle(path: helpersBundle) {
			
				if let plistPath = helperResourcesBundle.pathForResource("Settings", ofType: "plist") {
				
					let dictionary = NSDictionary(contentsOfFile: plistPath)
					let settingValue: String = dictionary?.objectForKey(settingKey) as! String
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

/// String extension
extension String {
	
	/// Check string is e-mail
	public func IO_isEmail() -> Bool {
		let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
		return regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
	}
	
	/// md5 and trim extension for string
	public func IO_md5() -> String! {
		let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
		let strLen = CUnsignedInt(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
		let digestLen = Int(CC_MD5_DIGEST_LENGTH)
		let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
		
		CC_MD5(str!, strLen, result)
		
		let hash = NSMutableString()
		for i in 0..<digestLen {
			hash.appendFormat("%02x", result[i])
		}
		
		result.destroy()
		
		return String(format: hash as String)
	}
	
	/// Trim whitespace from string
	public func IO_condenseWhitespace() -> String {
		let components = self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!$0.characters.isEmpty})
		
		return components.joinWithSeparator("")
	}
}

/// uiview cntroller extensions
extension UIViewController {
	
	/// Present modal view right to left animation
	public func IO_presentViewControllerWithCustomAnimation(viewControllerToPresent: UIViewController!) {
		let screenSizeWidth							= UIScreen.mainScreen().bounds.size.width
		let startTransition							= CGAffineTransformMakeTranslation(screenSizeWidth, 0)
		viewControllerToPresent.view.hidden			= true
		self.presentViewController(viewControllerToPresent, animated: false, completion: { () -> Void in
			
			viewControllerToPresent.view.hidden			= false
			viewControllerToPresent.view.transform		= startTransition
			let destinationTransform					= CGAffineTransformMakeTranslation(0, 0)
			UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.05, options: [], animations: { () -> Void in
				
				viewControllerToPresent.view.transform	= destinationTransform
			}, completion: { finished in
					
				viewControllerToPresent.view.transform	= destinationTransform
			})
			
		})
	}
	
	/// Dismiss modal view right to left animation
	public func IO_dismissViewControllerWithCustomAnimation() {
		
		let screenSizeWidth							= UIScreen.mainScreen().bounds.size.width
		let destinationTransform					= CGAffineTransformMakeTranslation(screenSizeWidth, 0)
		
		UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.05, options: [], animations: { () -> Void in
			
			self.view.transform					= destinationTransform
		}, completion: { finished in
				
			self.view.transform					= destinationTransform
			self.dismissViewControllerAnimated(false, completion: nil)
		})
		
	}
}

