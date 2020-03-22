//
//  DownloadFileTask.swift
//  Cser21
//
//  Created by Hung-Catalina on 3/21/20.
//  Copyright © 2020 High Sierra. All rights reserved.
//
import UIKit
import Foundation
class DownloadFileTask {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func ddMMyyyyHHmmss(date: Date?) -> String {
        let d = date ?? Date();
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyyHHmmss"
        return formatter.string(from: d);
    }
    
    func save(image: UIImage, opt: [String:String]) -> String {
        
        var ext = ".png";
        var pref = "IMG-";
        
        ext = opt["ext"] == ".jpg" ? ".jpg" : ".png"
        pref = opt["pref"]  ?? pref
        
        let data = ext == ".jpg" ? image.jpegData(compressionQuality: 1) : image.pngData();
        
        let name = pref + ddMMyyyyHHmmss(date: Date()) + ext;
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        try? data!.write(to: filename)
        return DownloadFileTask.toLocalSchemeUrl(filename.absoluteString)
    }
    
    static func replaceStartWith(str: String, startWidth: String, replace: String) -> String {
        let pref = startWidth;
        let index = str.index(str.startIndex, offsetBy: pref.count)
        let s = str[index...]
        return replace + s;
    }
    
    static func toLocalSchemeUrl(_ filename: String) -> String {
       return replaceStartWith(str: filename, startWidth: "file://", replace: "local://")
    }
    static func urlToLocalFileName(_ localUrl: String) -> String {
         return replaceStartWith(str: localUrl, startWidth: "local://", replace: "file://")
    }
    
    static func readData(filePath: String)  -> Data
    {
       // let inp = InputStream(fileAtPath: filePath);
        let path = filePath // or whatever...
        //let currentDirectory = getDocumentsDirectory(DownloadFileTask())
        let absouteURL = URL(fileURLWithPath: path);
        let inp = InputStream(url: absouteURL)
        do{
            return  try Data(reading: inp!)
        }catch{
            //throw  Error21.runtimeError(error.localizedDescription)
            NSLog(error.localizedDescription);
            return Data.init(); //empty
        }
    }
   
}
extension Data {
    init(reading input: InputStream) throws {
        self.init()
        input.open()
        defer {
            input.close()
        }

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                //Stream error occured
                throw input.streamError!
            } else if read == 0 {
                //EOF
                break
            }
            self.append(buffer, count: read)
        }
    }
}
