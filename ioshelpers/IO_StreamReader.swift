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
open class IO_StreamReader  {
	
	fileprivate let chunkSize: UInt64
	
	fileprivate var fileHandle: FileHandle!
	
	fileprivate var atEof = false
	fileprivate var currentSeek: UInt64 = 0
	
	/// File path, chink size
	public init? (pathUrl: URL!, chunkSize: UInt64 = 4096) {
		
		self.chunkSize = chunkSize
		
		do {
			self.fileHandle = try FileHandle(forReadingFrom: pathUrl)
			
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
	open func getChunkData() -> Data? {
		
		precondition(fileHandle != nil, "Attempt to read from closed file")
		
		if atEof {
			return nil
		}
		
		// Read data chunks from file until a line delimiter is found:
		//let range = NSRange(location: Int(currentSeek), length: Int(chunkSize))
		let tmpData = fileHandle.readData(ofLength: Int(chunkSize))
		
		if tmpData.count == 0 {
			// EOF or read error.
			atEof = true
			return nil
			
		}else{
			currentSeek += chunkSize
			return tmpData
		}
	}
	
	/// Start reading from the beginning of file.
	open func rewind() -> Void {
		
		fileHandle.seek(toFileOffset: 0)
		atEof = false
	}
	
	/// Close the underlying file. No reading must be done after calling this method.
	open func close() {
		
		fileHandle?.closeFile()
		fileHandle = nil
	}
}
