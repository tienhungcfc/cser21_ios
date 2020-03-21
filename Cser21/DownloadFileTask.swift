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
        var d = date ?? Date();
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyyHHmmss"
        return formatter.string(from: d);
    }
    
    func save(image: UIImage, opt: [String:String]) -> String {
        
        var ext = ".png";
        var pref = "IMG-";
        if(opt != nil )
        {
            ext = opt["ext"] == ".jpg" ? ".jpg" : ".png"
            ext = opt["pref"]  ?? pref
        }
        var data = ext == ".jpg" ? image.jpegData(compressionQuality: 1) : image.pngData();
        
        var name = pref + ddMMyyyyHHmmss(date: Date()) + ext;
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        try? data!.write(to: filename)
        return filename.absoluteString
    }
}
