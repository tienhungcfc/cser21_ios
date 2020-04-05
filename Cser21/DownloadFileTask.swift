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
        
        //let path = filename.path
        
        try? data!.write(to: filename)
        //return "file://private/" + path
        return DownloadFileTask.toLocalSchemeUrl(filename.absoluteString)
    }
    
    static func replaceStartWith(str: String, startWidth: String, replace: String) -> String {
        let pref = startWidth;
        let index = str.index(str.startIndex, offsetBy: pref.count)
        let s = str[index...]
        return replace + s;
    }
    //MARK: - (static)toLocalSchemeUrl
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
    
    
    //MARK: deletePath
    func deletePath(path: String) -> String
    {
        
        let fn = path.split(separator: "/").last
        //let filename = getDocumentsDirectory().appendingPathComponent(fn);
        var fileUrl = self.getDocumentsDirectory()
        //documentsURL.appendPathComponent(fn!)
        fileUrl.appendPathComponent("" + fn!)
        let fileManager = FileManager.default

        // Delete 'hello.swift' file

        do {
            try fileManager.removeItem(at: fileUrl)
            return "";
        }
        catch let error as NSError {
            NSLog(error.localizedDescription)
            return error.localizedDescription
        }
    }
    
    let cachName: String = "downloadCache"
    
    //MARK: - getCache
    func getCache(url: String) -> String?
    {
        var dic = UserDefaults.standard.dictionary(forKey: cachName);
        if(dic == nil)
        {
            dic = [String:Any]();
        }
        return dic![url] as? String
    }
    func setCache(url: String,localPath: String)
    {
        var dic = UserDefaults.standard.dictionary(forKey: cachName);
        if(dic == nil)
        {
            dic = [String:Any]();
        }
        dic![url] = localPath;
        UserDefaults.standard.set(dic!, forKey: cachName);
    }
    
    //MARK: - clear
    func clear(param: String)  {
        //nothing
        let fileManager = FileManager.default
        let documentsURL = self.getDocumentsDirectory()
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            // process files
            for f in fileURLs
            {
                //fileinfo: name, create, last, len,abspath
                do {
                    try fileManager.removeItem(at: f)
                   
                }
                catch let error as NSError {
                    NSLog(error.localizedDescription)
                    
                }
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
    }
    
    //MARK: - load
    func load(src: String, success: @escaping (_ src: String) -> (),fail: @escaping (_ mess: String) -> ()) {
        //không dùng cache ở đây(dùng localStore ở client)
        
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
                    
                    let local = response.destinationURL!.absoluteString;
                    self.setCache(url: src, localPath: local)
                    success(local)
                   
                } else {
                    //GlobalData.sharedInstance.dismissLoader()
                    fail("LOI")
                }
            }
    }
   
    //MARK: - getlist
    func getlist() -> [[String:Any?]]
    {
        var lst = [[String:Any?]]()
        let fileManager = FileManager.default
        let documentsURL = self.getDocumentsDirectory()
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            // process files
            for f in fileURLs
            {
                //fileinfo: name, create, last, len,abspath
                var finfo = [String:Any?]();
                finfo["abspath"] = DownloadFileTask.toLocalSchemeUrl(f.absoluteString)
                finfo["name"] = f.pathComponents.last ?? "";
                
                let attr = try fileManager.attributesOfItem(atPath: f.absoluteURL.path)
                finfo["len"] = attr[FileAttributeKey.size] as! Int64
                finfo["create"] = attr[FileAttributeKey.creationDate] as? Date;
                finfo["last"] = attr[FileAttributeKey.modificationDate] as? Date;
                
                
                lst.append(finfo)
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
        return lst
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


