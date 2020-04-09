//
//  extension.swift
//  Cser21
//
//  Created by Hung-Catalina on 4/8/20.
//  Copyright © 2020 High Sierra. All rights reserved.
//

import Foundation

extension Int{
    func parseDicKey(data: [String:String]?, key: String, df: Int) ->  Int {
        do{
            if data == nil {
                return df
            }
            let v = data![key]
            if v == nil {
                return df
            }
            return  Int(String(v!))!
        }catch{
            return df
        }
    }
}
