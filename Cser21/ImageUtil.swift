//
//  ImageUtil.swift
//  Cser21
//
//  Created by Hung-Catalina on 4/8/20.
//  Copyright © 2020 High Sierra. All rights reserved.
//
import UIKit
import Foundation
class ImageUtil{
    var app21: App21? = nil
    func execute(result: Result) -> Void {
        DispatchQueue.main.async(execute: {
            
            do{
                let d = DownloadFileTask();
                let decoder = JSONDecoder()
                
                let info = try decoder.decode(ImageUtilInfo.self, from: result.params!.data(using: .utf8)!)
                let data = d.localToData(filePath: info.path)
                
                let image = UIImage(data: data)
                let _image = image?.rotate(radians: CGFloat(info.degrees))
               
                let ext = String( d.getName(path: info.path).split(separator: ".").last!).lowercased()
               
                let _data = ext == "png" ? _image!.pngData() : _image!.jpegData(compressionQuality: 1);
                let name = d.getName(path: info.path)
                let filename = d.getDocumentsDirectory().appendingPathComponent(name)
                
                //let path = filename.path
                
                try? _data!.write(to: filename)
                
                result.success = true;
               
                self.app21?.App21Result(result: result)
            }
            catch{
                result.success = false;
                result.error = error.localizedDescription;
                self.app21?.App21Result(result: result)
            }
        })
        
    }
}

class ImageUtilInfo : Codable{
    var degrees: Float = 0
    var path: String = ""
}
extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}
