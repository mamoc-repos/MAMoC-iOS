//
//  readTextFile.swift
//  iOSExamples
//
//  Created by Dawand Sulaiman on 30/06/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation

// we have small.txt, medium.txt, and large.txt files
public let TEXT_FILE_NAME = "large.txt"

public func readFile(file:String = TEXT_FILE_NAME) -> String {
    
    let start = CFAbsoluteTimeGetCurrent()

    let resourceURL:URL = URL(string: Bundle.main.resourcePath!)!
    var fileText = ""
    
    do {
        let SearchFile:URL = try (FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions()).filter{ $0.lastPathComponent == file }).first!
        
        if let aStreamReader = StreamReader(path: SearchFile.path) {
            defer {
                aStreamReader.close()
            }
            while let line = aStreamReader.nextLine() {
                fileText += line
                fileText += "\n"
            }
        }
        
//    fileText = try String(contentsOf: SearchFile)
        
    } catch let error as NSError {
        debugPrint("Error reading file: \(error.localizedDescription)")
    }
    
    let stopTime = CFAbsoluteTimeGetCurrent()
    
    debugPrint("Reading the file time: \(stopTime - start)")

    return fileText
}
