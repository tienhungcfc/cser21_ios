//
//  Noti21.swift
//  Cser21
//
//  Created by Hung-Catalina on 4/8/20.
//  Copyright © 2020 High Sierra. All rights reserved.
//

import Foundation
class Noti21: Codable {
    var notification: Notification21?
    var data: [String:String]?
}
class Notification21: Codable
{
    var title: String?
    var body: String?
    var sound: String?
}
