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
    
    func setUpWebForLocalFile()
    {
        
    }
}
