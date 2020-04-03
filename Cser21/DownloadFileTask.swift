//
//  DownloadFileTask.swift
//  Cser21
//
//  Created by Hung-Catalina on 3/21/20.
//  Copyright © 2020 High Sierra. All rights reserved.
//
import UIKit
import Foundation
import Alamofire
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
    
    
    
    func deletePath(path: String)
    {
        let fn = path.split(separator: "/").last
        //let filename = getDocumentsDirectory().appendingPathComponent(fn);
        var fileUrl = self.getDocumentsDirectory()
        //documentsURL.appendPathComponent(fn!)
        fileUrl.appendPathComponent("" + fn!)
        let fileManager = FileManager.default

        // Delete 'hello.swift' file

        do {
            try fileManager.removeItem(atPath: fileUrl.absoluteString)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    //MARK: - getCache
    func getCache(url: String) -> String
    {
        
        return ""
    }
    
    func clear(param: String)  {
        
    }
    
    
    func load(src: String, success: @escaping (_ src: String) -> (),fail: @escaping (_ mess: String) -> ()) {
        let manager = Alamofire.SessionManager.default
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            
            var fn = src.split(separator: "?").first
            fn = fn?.split(separator: "/").last
            
            
            var documentsURL = self.getDocumentsDirectory()
            documentsURL.appendPathComponent(self.ddMMyyyyHHmmss(date: Date()) + "-" + fn!)
           
            return (documentsURL, [.removePreviousFile])
        }
        
        manager.download(URL(string: src)!, to: destination)
            
            .downloadProgress(queue: .main, closure: { (progress) in
                //progress closure
                print(progress.fractionCompleted)
            })
            .validate { request, response, temporaryURL, destinationURL in
                // Custom evaluation closure now includes file URLs (allows you to parse out error messages if necessary)
                //GlobalData.sharedInstance.dismissLoader()
                return .success
            }
            
            .responseData { response in
                if let destinationUrl = response.destinationURL {
                    print(destinationUrl)
                    
                    
                    success(response.destinationURL!.absoluteString)
                   
                } else {
                    //GlobalData.sharedInstance.dismissLoader()
                    fail("LOI")
                }
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
