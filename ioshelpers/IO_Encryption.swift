//
//  IO_Encryption.swift
//  IO Helpers
//
//  Created by ilker özcan on 04/09/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//
//

import Foundation

/// XoR Encryption
public struct IO_Encryption {
	
	public var plainText: String!
	public var encryptedText: String!
	
	/// Encrypt plain text
	public init(plainText: String!) {
		
		self.plainText = plainText
		self.encryptedText = self.encryptText(plainText)
	}
	
	/// Decrypt string
	public init(encryptedText: String!) {
		
		self.encryptedText = encryptedText
		self.plainText = self.decryptText(encryptedText)
	}
	
	// encrypt
	fileprivate func encryptText(_ contentString : String!) -> String {
		
		var contentText		= ""
		
		if(contentString != nil) {
			
			contentText		= contentString!
		}
		
		let plainData		= contentText.data(using: String.Encoding.utf8, allowLossyConversion: true)
		let base64String	= plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
		let encryptedText	= self.xorEncription(getEncryptionKey(), content: base64String!)
		let encryptedData	= encryptedText.data(using: String.Encoding.utf8, allowLossyConversion: true)
		
		return (encryptedData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters))!
	}
	
	// decrypt
	fileprivate func decryptText(_ contentString : String!) -> String {
		var contentText		= ""
		
		if(contentString != nil) {
			
			contentText		= contentString!
		}
		
		let encryptedData	= Data(base64Encoded: contentText, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
		
		if(encryptedData == nil) {
			
			return ""
		}
		
		if let encryptedText = NSString(data: encryptedData!, encoding: String.Encoding.utf8.rawValue) as? String {
			
			let decryptedText	= self.xorEncription(getEncryptionKey(), content: encryptedText)
			let decodedData		= Data(base64Encoded: decryptedText, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
			
			if(decodedData == nil) {
				
				return ""
			}

			let decodedString	= NSString(data: decodedData!, encoding: String.Encoding.utf8.rawValue) as! String
			return decodedString
			
		}else{
			return ""
		}
	}
	
	// Todo implement bundle read
	fileprivate func getEncryptionKey() -> String {
		
		return IO_Helpers.getSettingValue("encryptionkey")
	}
	
	// Exclusive or (xor) encription method
	fileprivate func xorEncription(_ key: String, content: String) -> String {
		let uintText		= [UInt8](content.utf8)
		let cipher			= [UInt8](key.utf8)
		var encrypted		= [UInt8]()
		let characterLength	= cipher.count
		
		for character in uintText.enumerated() {
			
			let keyIdx = character.offset % characterLength
			encrypted.append(character.element ^ cipher[keyIdx])
		}
		
		return String(bytes: encrypted, encoding: String.Encoding.utf8)!
	}
}
