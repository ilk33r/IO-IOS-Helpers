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
	private func encryptText(contentString : String!) -> String {
		
		var contentText		= ""
		
		if(contentString != nil) {
			
			contentText		= contentString!
		}
		
		let plainData		= contentText.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
		let base64String	= plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
		let encryptedText	= self.xorEncription(getEncryptionKey(), content: base64String!)
		let encryptedData	= encryptedText.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
		
		return (encryptedData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))!
	}
	
	// decrypt
	private func decryptText(contentString : String!) -> String {
		var contentText		= ""
		
		if(contentString != nil) {
			
			contentText		= contentString!
		}
		
		let encryptedData	= NSData(base64EncodedString: contentText, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
		
		if(encryptedData == nil) {
			
			return ""
		}
		
		if let encryptedText = NSString(data: encryptedData!, encoding: NSUTF8StringEncoding) as? String {
			
			let decryptedText	= self.xorEncription(getEncryptionKey(), content: encryptedText)
			let decodedData		= NSData(base64EncodedString: decryptedText, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
			
			if(decodedData == nil) {
				
				return ""
			}

			let decodedString	= NSString(data: decodedData!, encoding: NSUTF8StringEncoding) as! String
			return decodedString
			
		}else{
			return ""
		}
	}
	
	// Todo implement bundle read
	private func getEncryptionKey() -> String {
		
		return IO_Helpers.getSettingValue("encryptionkey")
	}
	
	// Exclusive or (xor) encription method
	private func xorEncription(key: String, content: String) -> String {
		let uintText		= [UInt8](content.utf8)
		let cipher			= [UInt8](key.utf8)
		var encrypted		= [UInt8]()
		let characterLength	= cipher.count
		
		for character in uintText.enumerate() {
			
			let keyIdx		= character.index % characterLength
			encrypted.append(character.element ^ cipher[keyIdx])
		}
		
		return String(bytes: encrypted, encoding: NSUTF8StringEncoding)!
	}
}