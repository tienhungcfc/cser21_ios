//
//  ViewController.swift
//  Cser21 - ezs.vn
//
//  Created by High Sierra on 1/7/20.
//  Copyright © 2020 High Sierra. All rights reserved.
//

import UIKit
import WebKit
import Firebase

class ViewController: UIViewController,WKScriptMessageHandler,UIGestureRecognizerDelegate  {
    //@IBOutlet weak var wv: WKWebView!
    
    
    //@IBOutlet weak var wv: WKWebView!
    
    
    @IBOutlet weak var uv: UIWebView!
    
    //@IBOutlet weak var wv: WKWebView!
    var wv: WKWebView!
    
    var os10:Bool = false;
    
    let domain = "https://cser.vn/";
    let colorBrand = 0xff4e40;
    let mtop = CGFloat(20);
    /*
     for event: onTap,onPinch,onRotation,onSwipe,onPan,onEPan,onLongpress
     */
    func StrPoint(Point: CGPoint) -> String
    {
        
        do
        {
            return "{\"x\":" + String(describing: Point.x) + ",\"y\":" + String(describing: Point.y) + "}"
        }
        catch
        {
            return "{}"
        }
        
    }
    func StrSize() -> String
    {
        do
        {
            let s = os10 ? uv.bounds.size : wv.bounds.size
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            return "{\"width\":" + String(describing: s.width) + ",\"height\":" + String(describing: s.height - statusBarHeight ) + "}"
        }
        catch
        {
            return "{}"
        }
    }
    func StrGestureState(state: UIGestureRecognizer.State) -> String
    {
        var s:String = ""
        switch state {
        case UIGestureRecognizer.State.ended:
            s = "ended"
        case UIGestureRecognizer.State.cancelled:
            s = "cancelled"
        case UIGestureRecognizer.State.changed:
            s = "changed"
        case UIGestureRecognizer.State.began:
            s = "began"
        case UIGestureRecognizer.State.failed:
            s = "failed"
        case UIGestureRecognizer.State.possible:
            s = "possible"
        case UIGestureRecognizer.State.recognized:
            s = "recognized"
        default:
            s = ""
        }
        return "\"" + s + "\""
    }
    @objc func onTap(g: UITapGestureRecognizer) {
        
        var value:String = "";
        value += "{\"point\":" + StrPoint(Point: g.location(in: os10 ? uv : wv)) ;
        value += ",\"size\":" + StrSize();
        value += ",\"state\":" + StrGestureState(state: g.state);
        value += "}";
        JS(cmd: "onTap", value: value )
    }
    @objc func onPinch(g: UIPinchGestureRecognizer) {
        //        var value:String = "";
        //        value += "{\"point\":" + StrPoint(Point: g.location(in: wv)) ;
        //        value += ",\"scale\":" + String(describing: g.scale);
        //        value += ",\"velocity\":" + String(describing: g.velocity);
        //        value += ",\"size\":" + StrSize();
        //        value += ",\"state\":" + StrGestureState(state: g.state);
        //        value += "}";
        //        JS(cmd: "onPinch", value: value)
    }
    @objc func onRotation(g: UIRotationGestureRecognizer) {
        var value:String = "";
        value += "{\"point\":" + StrPoint(Point: g.location(in: os10 ? uv : wv)) ;
        value += ",\"rotation\":" + String(describing: g.rotation);
        value += ",\"velocity\":" + String(describing: g.velocity);
        value += ",\"size\":" + StrSize();
        value += ",\"state\":" + StrGestureState(state: g.state);
        value += "}";
        JS(cmd: "onRotation", value: value)
    }
    @objc func onPan(g: UIPanGestureRecognizer) {
        var value:String = "";
        value += "{\"point\":" + StrPoint(Point: g.location(in: os10 ? uv : wv)) ;
        value += ",\"translation\":" + StrPoint(Point: g.translation(in: os10 ? uv : wv));
        value += ",\"velocity\":" + StrPoint(Point: g.velocity(in: os10 ? uv : wv));
        value += ",\"size\":" + StrSize();
        value += ",\"state\":" + StrGestureState(state: g.state);
        value += "}";
        JS(cmd: "onPan", value: value)
    }
    @objc func onEPan(g: UIScreenEdgePanGestureRecognizer) {
        var value:String = "";
        value += "{\"point\":" + StrPoint(Point: g.location(in: os10 ? uv : wv)) ;
        value += ",\"translation\":" + StrPoint(Point: g.translation(in: os10 ? uv : wv));
        value += ",\"velocity\":" + StrPoint(Point: g.velocity(in: os10 ? uv : wv));
        value += ",\"size\":" + StrSize();
        value += ",\"state\":" + StrGestureState(state: g.state);
        value += "}";
        JS(cmd: "onEPan", value: value)
    }
    @objc func onSwipe(g: UISwipeGestureRecognizer) {
        var value:String = "";
        value += "{\"point\":" + StrPoint(Point: g.location(in: os10 ? uv : wv)) ;
        value += ",\"direction\":" + String(describing: g.direction.rawValue);
        value += ",\"size\":" + StrSize();
        value += ",\"state\":" + StrGestureState(state: g.state);
        value += "}";
        JS(cmd: "onSwipe", value: value)
    }
    @objc func onLongpress(g: UILongPressGestureRecognizer) {
        var value:String = "";
        value += "{\"point\":" + StrPoint(Point: g.location(in: os10 ? uv : wv)) ;
        value += ",\"size\":" + StrSize();
        value += ",\"state\":" + StrGestureState(state: g.state);
        value += "}";
        JS(cmd: "onLongpress", value: value)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func getKey(keyName: String,value: String) -> String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: keyName)!
    }
    func setKey(keyName: String,value: String) -> Void {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: keyName)
    }
    
    func Subscribe(topics: String) -> Void {
        if(topics.isEmpty)
        {
            return;
        }
        setKey(keyName: "subscribe", value: topics);
        let a1 = topics.components(separatedBy:  ",");
        
        for a in a1 {
            // print("Hello, \(name)!")
            //android: FirebaseMessaging.getInstance().subscribeToTopic(a);
            Messaging.messaging().subscribe(toTopic: a);
        }
    }
    
    func UnSubscribe() -> Void {
        let topics = getKey(keyName: "subscribe", value: "")
        if(topics.isEmpty)
        {
            return;
        }
        let a1 = topics.components(separatedBy:  ",");
        for a in a1 {
            // print("Hello, \(name)!")
            //android: FirebaseMessaging.getInstance().subscribeToTopic(a);
            Messaging.messaging().unsubscribe(fromTopic: a);
        }
        
    }
    func IconBadgeNumber(strNum : String) -> Void {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    //MARK: - reloadStoryboard
    func reloadStoryboard()  {
        loadView();
    }
    
    //MARK: - evalJs
    func evalJs(str: String)
    {
        if(os10){
            //uv.loadRequest(<#T##request: URLRequest##URLRequest#>)("app_response('\(cmd)','\(value)',true)",completionHandler: nil)
            //let str:String = "javascript:app_response('\(cmd)','\(value)',true);";
            uv.stringByEvaluatingJavaScript(from: str)
        }else{
            wv.evaluateJavaScript(str,completionHandler: nil)
        }
        
    }
    
    //MARK: - Do
    
    func Do(cmd: String,value: Any?)  {
        if(value == nil) { return;}
        let str: String = value as! String
        
        let segs = str.components(separatedBy:  ":")
        
        var key = "" as String
        var va = "" as String
        if(segs.count > 0)
        {
            key = segs[0] as String
        }
        if(segs.count > 1)
        {
            va = segs[1] as String
        }
        
        
        switch cmd {
        case "setkey":
            setKey(keyName: key, value: va)
            break
        case "getkey":
            JS(cmd: cmd, value: getKey(keyName: key, value: va))
            break
        case "subscribe":
            // JS(cmd: cmd, value: getKey(keyName: key, value: va))
            Subscribe(topics: str)
            break
        case "unsubscribe":
            UnSubscribe();
            break
        case "iconbadgenumber":
            IconBadgeNumber(strNum: str);
            break
        case "open_link":
            open_link(url: str);
            break
        //MARK: - case:call
        case "call":
            App21(viewController: self).call(jsonStr: value as! String)
            break
        default:
            break
        }
    }
    
    func open_link(url : String) ->  Void {
        //NSLog(url)
        if #available(iOS 11.0, *) {
            // or use some work around
            guard let _url = URL(string: url) else { return }
            UIApplication.shared.open(_url)
        }else
            {
            // for ex. UIStackView
                guard let _url = URL(string: url) else { return }
                UIApplication.shared.openURL(_url);
        }
    }
    /*
     Nhan thong bao tu web
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //<#code#>
        let data = message.body as! NSDictionary
        let cmd: String = (data["cmd"] as? String)!
        let value = data["value"]
        Do(cmd: cmd,value: value)
    }
    
    
    func ios10() {
        //always set 0
        //IconBadgeNumber(strNum: "0");
        //Javascript
        //uv.configuration.userContentController.add(self, name: "IOS")
        
        
        uv.scrollView.decelerationRate = UIScrollView.DecelerationRate.normal;
        //CGSize viewSize = self.view.frame.size
        uv.window?.sizeToFit()
        //Event
        //#
        let evt_tap = UITapGestureRecognizer(target: self , action: #selector(onTap))
        evt_tap.delegate = self
        evt_tap.numberOfTapsRequired = 1
        uv.addGestureRecognizer(evt_tap)
        //#
        let evt_pinch = UIPinchGestureRecognizer(target: self , action: #selector(onPinch))
        evt_pinch.delegate = self
        uv.addGestureRecognizer(evt_pinch)
        //#
        let evt_Rotation = UIRotationGestureRecognizer(target: self , action: #selector(onRotation))
        evt_Rotation.delegate = self
        uv.addGestureRecognizer(evt_Rotation)
        //#
        let evt_Pan = UIPanGestureRecognizer(target: self , action: #selector(onPan))
        evt_Pan.delegate = self
        uv.addGestureRecognizer(evt_Pan)
        //#
        let evt_Epan = UIScreenEdgePanGestureRecognizer(target: self , action: #selector(onEPan))
        evt_Epan.delegate = self
        uv.addGestureRecognizer(evt_Epan)
        //#
        let evt_Swipe = UISwipeGestureRecognizer(target: self , action: #selector(onSwipe))
        evt_Swipe.delegate = self
        uv.addGestureRecognizer(evt_Swipe)
        //#
        let evt_Longpress = UILongPressGestureRecognizer(target: self , action: #selector(onLongpress))
        evt_Longpress.delegate = self
        uv.addGestureRecognizer(evt_Longpress)
        
        
        //UI
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // load embed.html
        if let path = Bundle.main.path(forResource: "embed", ofType: "html"){
            let fm = FileManager()
            let exists = fm.fileExists(atPath: path)
            if(exists){
                let c = fm.contents(atPath: path)
                let cString = NSString(data: c!, encoding: String.Encoding.utf8.rawValue)
                
                let url = URL(string: domain)
                
                var html:String = "";
                html +=  cString! as String
                uv.loadHTMLString(html, baseURL: url)
            }
            //test
            
        }
    }
    
    func ios11()  {
        //Javascript
        wv.configuration.userContentController.add(self, name: "IOS")
        wv.scrollView.decelerationRate = UIScrollView.DecelerationRate.normal;
        //CGSize viewSize = self.view.frame.size
        
        //Event
        //#
        let evt_tap = UITapGestureRecognizer(target: self , action: #selector(onTap))
        evt_tap.delegate = self
        evt_tap.numberOfTapsRequired = 1
        wv.addGestureRecognizer(evt_tap)
        //#
        let evt_pinch = UIPinchGestureRecognizer(target: self , action: #selector(onPinch))
        evt_pinch.delegate = self
        wv.addGestureRecognizer(evt_pinch)
        //#
        let evt_Rotation = UIRotationGestureRecognizer(target: self , action: #selector(onRotation))
        evt_Rotation.delegate = self
        wv.addGestureRecognizer(evt_Rotation)
        //#
        let evt_Pan = UIPanGestureRecognizer(target: self , action: #selector(onPan))
        evt_Pan.delegate = self
        wv.addGestureRecognizer(evt_Pan)
        //#
        let evt_Epan = UIScreenEdgePanGestureRecognizer(target: self , action: #selector(onEPan))
        evt_Epan.delegate = self
        wv.addGestureRecognizer(evt_Epan)
        //#
        let evt_Swipe = UISwipeGestureRecognizer(target: self , action: #selector(onSwipe))
        evt_Swipe.delegate = self
        wv.addGestureRecognizer(evt_Swipe)
        //#
        let evt_Longpress = UILongPressGestureRecognizer(target: self , action: #selector(onLongpress))
        evt_Longpress.delegate = self
        wv.addGestureRecognizer(evt_Longpress)
        
        
        //UI
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // load embed.html
        if let path = Bundle.main.path(forResource: "embed", ofType: "html"){
            let fm = FileManager()
            let exists = fm.fileExists(atPath: path)
            if(exists){
                let c = fm.contents(atPath: path)
                let cString = NSString(data: c!, encoding: String.Encoding.utf8.rawValue)
                
                let url = URL(string: domain)
                
                var html:String = "";
                html +=  cString! as String
                wv.loadHTMLString(html, baseURL: url)
                wv.alpha = 1
            }
            //test
            
        }
    }
    //MARK: - loadView
    override func loadView() {
        super.loadView()
        if #available(iOS 11.0, *) {
            // or use some work around
            let webConfiguration = WKWebViewConfiguration();
            // let bg = UIColor(colorWithHaxValue: colorBrand);
            let h = view.bounds.height ;//- mtop
            let frm = CGRect(x:0 , y:0, width: view.bounds.width, height: h)
            
            //app21: handler file local
            //webConfiguration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
            webConfiguration.setURLSchemeHandler(LocalSchemeHandler(), forURLScheme: "local")
            //
            
            wv = WKWebView(frame: frm, configuration: webConfiguration);
            //view.backgroundColor = bg;
            view.addSubview(wv);
            wv.isOpaque = false;
            //wv.backgroundColor = bg;
            os10 = false;
            
            
        } else {
            os10 = true;
            uv.delegate = self
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if #available(iOS 11.0, *) {
            // or use some work around
            ios11()
        }else{
            // for ex. UIStackView
            ios10()
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func printReceivedParmas(_ data: AnyObject) {
        //print("Swift recieved data passed from JS: \(data)")
    }
    
    func JS(cmd: String, value: String){
        if(os10){
            //uv.loadRequest(<#T##request: URLRequest##URLRequest#>)("app_response('\(cmd)','\(value)',true)",completionHandler: nil)
            let str:String = "javascript:app_response('\(cmd)','\(value)',true);";
            uv.stringByEvaluatingJavaScript(from: str)
        }else{
            wv.evaluateJavaScript("app_response('\(cmd)','\(value)',true)",completionHandler: nil)
        }
        
    }
    
    
    
    
}
extension ViewController: UIWebViewDelegate
{
    //for os10
    internal func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        //webView.stringByEvaluatingJavaScriptFromString("something = 42")
        if(!os10) {
            return true;
        }
        let str = String(describing: request)
        let arr = str.components(separatedBy:"?")
        if(arr.count == 2)
        {
            if(arr[0].starts(with: "js://"))
            {
                let a = arr[1].components(separatedBy: "&")
                
                var cmd:String = ""
                var value:String = ""
                for row in a {
                    let pairs = row.components(separatedBy:"=")
                    if(pairs.count == 2)
                    {
                        if(pairs[0] == "cmd") {
                            cmd = pairs[1]
                        }
                        if(pairs[0] == "value") {
                            value = pairs[1]
                        }
                    }
                }
                if(cmd != "")
                {
                    Do(cmd: cmd, value: value)
                }
                return false
            }
        }
        return true
    }
    
    
    
}

extension UIColor{
    convenience  init(colorWithHaxValue value: Int, alpha:CGFloat = 1.0) {
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat((value & 0x0000FF)) / 255.0,
            alpha: alpha
        )
    }
}

