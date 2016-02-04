//
//  IO_StreamReader.swift
//  IO Helpers
//
//  Created by ilker özcan on 19/10/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//
//

import Foundation

/// Stream file reader class
public class IO_StreamReader  {
	
	private let chunkSize: UInt64
	
	private var fileHandle: NSFileHandle!
	
	private var atEof = false
	private var currentSeek: UInt64 = 0
	
	/// File path, chink size
	public init? (pathUrl: NSURL!, chunkSize: UInt64 = 4096) {
		
		self.chunkSize = chunkSize
		
		do {
			self.fileHandle = try NSFileHandle(forReadingFromURL: pathUrl)
			
		} catch let error as NSError {
			print("Could not open file. \(error.description)")
			self.fileHandle = nil
			return nil
		}
	}
	
	deinit {
		self.close()
	}
	
	/// Read part of file
	public func getChunkData() -> NSData? {
		
		precondition(fileHandle != nil, "Attempt to read from closed file")
		
		if atEof {
			return nil
		}
		
		// Read data chunks from file until a line delimiter is found:
		//let range = NSRange(location: Int(currentSeek), length: Int(chunkSize))
		let tmpData = fileHandle.readDataOfLength(Int(chunkSize))
		
		if tmpData.length == 0 {
			// EOF or read error.
			atEof = true
			return nil
			
		}else{
			currentSeek += chunkSize
			return tmpData
		}
	}
	
	/// Start reading from the beginning of file.
	public func rewind() -> Void {
		
		fileHandle.seekToFileOffset(0)
		atEof = false
	}
	
	/// Close the underlying file. No reading must be done after calling this method.
	public func close() {
		
		fileHandle?.closeFile()
		fileHandle = nil
	}
}