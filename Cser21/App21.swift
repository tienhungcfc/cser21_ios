//
//  App21.swift
//  Cser21
//
//  Created by Hung-Catalina on 3/21/20.
//  Copyright © 2020 High Sierra. All rights reserved.
//
import Foundation
import UIKit
import MobileCoreServices
import AVFoundation
import Photos

class App21 : NSObject
{
    var caller:  ViewController
    init(viewController: ViewController)
    {
        caller = viewController;
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    //MARK: - App21Result
    func App21Result(result: Result) -> Void {
        do {
           let jsonEncoder = JSONEncoder()
           let jsonData = try jsonEncoder.encode(result)
           let json = String(data: jsonData, encoding: String.Encoding.utf8)
           //chuyen ve base64 -> khong bi loi ky tu dac biet
           let base64 = json?.base64Encoded();
           DispatchQueue.main.async(execute: {
               self.caller.evalJs(str: "App21Result('BASE64:" + base64! + "')");
           })
        } catch  {
            //
            NSLog("App21Result -> " + error.localizedDescription);
        }
        
    }
    
    //MARK: - call
    func call(jsonStr: String) -> Void {
        //
        
        let result = Result();
       
        
        do {
            let data = jsonStr.data(using: .utf8);
            let json = try JSONSerialization.jsonObject(with: data! , options: []) as? [String: Any];
            result.sub_cmd = json!["sub_cmd"] as? String;
            result.sub_cmd_id = json!["sub_cmd_id"] as! Int;
            result.params = json!["params"] as? String;
            
            
            //var selector = Selector(result.sub_cmd! + ":");
            
            //var selector = #selector(App21.REBOOT(result:)) => run ok
            
            //see: https://forums.developer.apple.com/thread/86081
            let selector = Selector(result.sub_cmd! + "WithResult:")
            if(selector.hashValue==0){
                result.success = false;
                result.error = (result.sub_cmd ?? "") +  " NOT FOUND";
                App21Result(result: result)
                return;
            }
            performSelector(inBackground: selector, with: result)
           
           // App21Result(result: result);
            return;
        }
        catch let e as NSException{
            NSLog(e.reason!)
        }
        catch  {
            print(error.localizedDescription);
            result.success = false;
            result.error = error.localizedDescription;
            App21Result(result: result);
        }
    }
    
    //MARK: - BACKGROUND
    @objc func BACKGROUND(result: Result) -> Void {
        //
        result.success = true;
        App21Result(result: result);
        DispatchQueue.main.async { // Correct
            self.caller.setBackground(params: result.params)
        }
    }
    
    //MARK: - REBOOT
    @objc func REBOOT(result: Result) -> Void {
        //
        result.success = true;
        App21Result(result: result);
        
        let miliSecond = Int(result.params ?? "0") ?? 0;
        let s = miliSecond/1000;
        DispatchQueue.main.asyncAfter(deadline:.now() + Double(s)) {
            self.caller.reloadStoryboard();
        }
    }
    
    
    
    
    //MARK: - CAMERA
    @objc func CAMERA(result: Result) -> Void {
        //
        DispatchQueue.main.async(execute: {
            // self.caller.openCamera(result: result);
            self._PERMISSION(permission: PermissionName.camera,result: result, ok:{(mess: String) -> Void in
                //go
                NSLog("ok->openCamera");
                
                AttachmentHandler.shared.showCamera(vc: self.caller);
                
                AttachmentHandler.shared.imagePickedBlock = { (image) in
                    /* get your image here */
                    //Use image name from bundle to create NSData
                    // let image : UIImage = UIImage(named:"imageNameHere")!
                    //Now use image to create into NSData format
                    //let imageData:NSData = image.pngData()! as NSData
                    
                    //let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                    result.success = true
                    let src = DownloadFileTask().save(image: image,
                                                      opt: self.paramsToDic(params: result.params));
                    result.data = JSON(src);
                    self.App21Result(result: result);
                }
                
            })
        })
 
    }
    
    
    //MARK: - LOCATION
    @objc func LOCATION(result: Result) -> Void {
        /*
        result.success = true;
        let loc21 = Loction21()
        loc21.app21 = self
        loc21.run(result: result)
        */
        caller.locationCallback = {(loc: CLLocationCoordinate2D?) in
            result.success = loc != nil
            if(loc != nil)
            {
                let d: [String: Double] = [
                    "lat": loc!.latitude,
                    "lng": loc!.longitude
                ]
                
                result.data = JSON(d)
            }
            self.App21Result(result: result);
        }
        caller.requestLoction()
    }
    
    //MARK: - DOWNLOAD
    @objc func DOWNLOAD(result: Result) -> Void
    {
        DownloadFileTask().load(src: result.params!, success: { (absPath: String) -> Void in
//
            result.success = true;
            result.data = JSON(DownloadFileTask.toLocalSchemeUrl(absPath));
            self.App21Result(result: result)
            
        }) { (mess: String)  -> Void in
            //
            result.success = false;
            result.error = mess;
            self.App21Result(result: result)
        }
    }
    
    //MARK: - BASE64
    @objc func BASE64(result: Result) -> Void
    {
        
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            do
            {
                let decoder = JSONDecoder()
                
                let rq = try decoder.decode(Base64Require.self, from: result.params!.data(using: .utf8)!)
                
                
                let b64 = DownloadFileTask().toBase64(src: rq.path)
                result.success = b64 != nil
                // Bounce back to the main thread to update the UI
                DispatchQueue.main.async {
                    self.App21Result(result: result)
                    self.caller.evalJs(str: rq.callback! + "('" + b64! + "')")
                }
                
                
            }catch{
                result.success = false
                result.error = error.localizedDescription
                // Bounce back to the main thread to update the UI
                DispatchQueue.main.async {
                     self.App21Result(result: result)
                }
            }
           
            
        }
        
       
        
    }
        
    
    
    
    //MARK: - CLEAR_DOWNLOAD
    @objc func CLEAR_DOWNLOAD(result: Result) -> Void
    {
        DownloadFileTask().clear(param: result.params ?? "",callback: {(ok: String,error: String?) -> Void in
            if(error != nil)
            {
                result.success = false;
                result.error = error;
            }else{
                result.success = true;
            }
            
            self.App21Result(result: result);
        })
       
    }
    
    

    //MARK: - GET_DOWNLOADED
    @objc func GET_DOWNLOADED(result: Result) -> Void
    {
        result.data = JSON(DownloadFileTask().getlist());
        result.success = true;
        App21Result(result: result);
    }
    
    
    //MARK: - DELETE_FILE (result.result = 1 file)
    @objc func DELETE_FILE(result: Result) -> Void
    {
        let mess = DownloadFileTask().deletePath(path: result.params!)
        result.success = mess == "" ?  true : false;
        if(mess != "")
        {
            result.error = mess;
        }
        App21Result(result: result);
        
    }
    
    
    
    func paramsToDic(params: String?) -> [String:String]
    {
        var d = [String:String]();
        if(params != nil)
        {
            for seg in (params?.split(separator: ","))!
            {
                let arr = seg.split(separator: ":")
                d[String(describing: arr[0])] = arr.count > 1 ? String(describing: arr[1]) : "";
            }
        }
        return d;
    }
    
    func reject(result: Result, resson: String)
    {
        NSLog(resson)
        result.success = false;
        result.error = resson
        App21Result(result: result)
    }
    //MARK: - _PERMISSION
    //permission:camera, video, photoLibrary
    func _PERMISSION(permission: PermissionName,result: Result, ok:  @escaping(_ mess: String)->Void )
    {
        switch(permission){
        case .camera,.photoLibrary,.video:
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                //ok
                NSLog("authorized")
                ok("authorized");
                break;
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == PHAuthorizationStatus.authorized{
                        // photo library access given
                        
                        ok("access_given");
                    }else{
                        self.reject(result: result, resson: "restriced_manually")
                    }
                })
            case .denied:
                
                self.reject(result: result, resson: "permission_denied")
                
                break
            case .restricted:
               
                self.reject(result: result, resson: "permission_restricted")
                
                break
            default:
                break
            }
        }
    }
    
    
    
    enum PermissionName: String{
        case camera, video, photoLibrary
    }
    
}

//MARK: - Result
class Result : NSObject {
    var success = true
    var data: JSON? = nil
    var error: String? = ""
    
    var sub_cmd: String? = ""
    var sub_cmd_id: Int = 0
    var params: String? = ""
    
    enum CodingKeys:String, CodingKey {
        case success
        case data
        case error
        case sub_cmd
        case sub_cmd_id
        case params
    }
}
extension Result: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(error, forKey: .error)
        if(data != nil)
        {
           
           try container.encode(data, forKey: .data)
           
        }
        try container.encode(sub_cmd, forKey: .sub_cmd)
        try container.encode(params, forKey: .params)
        try container.encode(sub_cmd_id, forKey: .sub_cmd_id)
    }
}


extension String {
//: ### Base64 encoding a string
    func base64Encoded() -> String? {
    
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }

//: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
enum Error21 : Error {
   case runtimeError(String)
}

class Base64Require : Codable{
    var path: String?;
    var callback: String?;
}



