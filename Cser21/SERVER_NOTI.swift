//
//  SERVER_NOTI.swift
//  Cser21
//
//  Created by Hung-Catalina on 4/8/20.
//  Copyright © 2020 High Sierra. All rights reserved.
//

import Foundation
import UserNotifications

class SERVER_NOTI{
    var app21: App21?
    func noti(noti21: Noti21) -> Void {
        //
        
        
        //
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert,.sound]) { (granted, error) in
            //
        }
        //
        let content = UNMutableNotificationContent()
        content.title = (noti21.notification?.title!)!
        content.body = (noti21.notification?.body!)! as String
        
        content.userInfo = [String:String]()
        if((noti21.data) != nil){
            for item in noti21.data! {
                content.userInfo[item.key] = item.value
            }
        }
        
        
        content.categoryIdentifier = "App21CustomPush"
        content.sound = UNNotificationSound.default
        
        //largeImage
        let largeIcon = content.userInfo["largeIcon"]
        if largeIcon != nil, let fileUrl = URL(string: largeIcon! as! String) {
            
            guard let imageData = NSData(contentsOf: fileUrl) else {
                return
            }
            
            let fileIdentifier = DownloadFileTask().getName(path: fileUrl.absoluteString)
            guard let attachment = saveImageToDisk(fileIdentifier: fileIdentifier, data: imageData, options: nil) else {
                return
            }
            
            content.attachments = [ attachment ]
        }
        
        //
        let delay = Int().parseDicKey(data: noti21.data, key: "delay", df: 0)
        
        //
        var trigger : UNCalendarNotificationTrigger? = nil
        if(delay  > 0){
            let date = Date().addingTimeInterval(Double(delay))
            let dateComponent = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent , repeats: false)
            
        }
       
        //
        let uuid = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        //
        center.add(request) { (error) in
            //
        }
    }
    func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
    
    func run(result: Result, callback: @escaping () -> ()) -> Void{
        
    }
}
class SERVER_NOTI_Config : Codable{
    var  enable: Bool = false;
    var  intervalMillis: Int = 1000 * 60 * 15;
    var  server: String = "";
    var  serverParams: [String:String]? = nil;
}
