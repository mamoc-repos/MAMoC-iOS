//
//  readTextFile.swift
//  iOSExamples
//
//  Created by Dawand Sulaiman on 30/06/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation

public let TEXT_FILE_NAME = "bigText.txt"

public func readFile() -> String{
    
    var resourceURL:URL = URL(string: Bundle.main.resourcePath!)!
    var textToSearch = ""
    
    do {
        let textToSearchFile:URL = try (FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions()).filter{ $0.lastPathComponent == TEXT_FILE_NAME }).first!
        
        if let aStreamReader = StreamReader(path: textToSearchFile.path) {
            defer {
                aStreamReader.close()
            }
            while let line = aStreamReader.nextLine() {
                textToSearch += line
                textToSearch += "\n"
            }
        }
    } catch let error as NSError {
        debugPrint("Error reading file: \(error.localizedDescription)")
    }
    
    return textToSearch
}
