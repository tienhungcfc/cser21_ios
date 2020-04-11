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
        if data == nil {
            return df
        }
        let v = data![key]
        if v == nil {
            return df
        }
        return  Int(String(v!))!
    }
    func parseAny(any: Any?) -> Int
    {
        let a = any as? Int
        if(a != nil){
            return a!
        }
        let s = any as! String?
        if(s != nil)
        {
            let b = Int(s!)
            if(b != nil){
                return b!
            }
        }
        return 0;
    }
}
