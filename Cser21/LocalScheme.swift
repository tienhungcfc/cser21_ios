//
//  LocalScheme.swift
//  Cser21
//
//  Created by Hung-Catalina on 3/22/20.
//  Copyright © 2020 High Sierra. All rights reserved.
//

import Foundation
import WebKit


@available(iOS 11.0, *)
class LocalSchemeHandler: NSObject, WKURLSchemeHandler {
   
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        
        var url = urlSchemeTask.request.url?.absoluteString
        var file = DownloadFileTask.urlToLocalFileName(url!);
        
        ///
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        //
    }
    
    
}

