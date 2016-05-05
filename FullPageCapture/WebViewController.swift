//
//  WebViewController.swift
//  FullPageCapture
//
//  Created by Imairi, Yosuke on 3/14/16.
//  Copyright © 2016 imairi. All rights reserved.
//

import UIKit
import WebKit
import AHKBendableView

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, UISearchBarDelegate, CaptureMenuViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var pageTitleView: ProgressView!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    @IBOutlet weak var menuBar: UIView!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    
    var webView = WKWebView()
    var captures = [UIImage]()
    var previousY : CGFloat = 0.0
    var canHideMenuBar = false
    var captureMenuBaseView = BendableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // set up search bar
        searchBar.delegate = self
        
        // set up webview
        webView.frame = CGRectMake(0, pageTitleView.frame.size.height + 20, view.frame.width, UIScreen.mainScreen().bounds.size.height - menuBar.frame.size.height)
        webView.scrollView.contentInset = UIEdgeInsetsMake(menuBar.frame.size.height, 0, 0, 0)
        view.addSubview(webView)
        view.sendSubviewToBack(webView)
        
        webView.navigationDelegate = self
        webView.UIDelegate = self
        webView.scrollView.delegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath:"estimatedProgress", options:.New, context:nil)
        webView.addObserver(self, forKeyPath:"canGoBack", options:.New, context:nil)
        webView.addObserver(self, forKeyPath:"canGoForward", options:.New, context:nil)
        
        goBackButton.userInteractionEnabled = false
        goForwardButton.userInteractionEnabled = false
        reloadButton.userInteractionEnabled = false
        
        
        // create capture menu base view
        captureMenuBaseView = BendableView(frame: CGRectMake(0,UIScreen.mainScreen().bounds.size.height,UIScreen.mainScreen().bounds.size.width,100))
        captureMenuBaseView.backgroundColor = UIColor.redColor()
        view.addSubview(captureMenuBaseView)
        
        
        // create capture menu view
        let captureMenuView: CaptureMenuView = UINib.instantiateView()
        captureMenuView.frame = CGRectMake(0, 0, captureMenuBaseView.bounds.size.width, captureMenuBaseView.bounds.size.height)
        captureMenuView.delegate = self
        captureMenuBaseView.addSubview(captureMenuView)        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "canGoBack")
        webView.removeObserver(self, forKeyPath: "canGoForward")
    }
    
    
    // MARK: - IBActions
    @IBAction func tapGoBackButton(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func tapGoForwardButton(sender: AnyObject) {
        webView.goForward()
    }
    
    @IBAction func tapReloadButton(sender: AnyObject) {
        webView.reload()
    }
    
    @IBAction func tapBookmarkButton(sender: AnyObject) {
        print(#function)

        captureMenuBaseView.fillColor = UIColor.redColor()
        captureMenuBaseView.damping = 0.5
        captureMenuBaseView.initialSpringVelocity = 0.8
        
        var afterY = CGFloat(0.0)
        if captureMenuBaseView.frame.origin.y < UIScreen.mainScreen().bounds.size.height {
            afterY = UIScreen.mainScreen().bounds.size.height
        } else {
            afterY = UIScreen.mainScreen().bounds.size.height - 100
        }
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: .CurveEaseInOut, animations: {
            self.captureMenuBaseView.frame.origin = CGPoint(x: 0, y: afterY)
            }, completion: nil)
    }
    
    
    // MARK - Private Methods
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error != nil {
            print(error.code)
        }
    }
    
    func takeScreenshot(id:AnyObject) {
        let webViewContentSize = webView.scrollView.contentSize
        let currentOffset = webView.scrollView.contentOffset
        let capture = webView.screenshot()
        
        captures.append(capture)
        
        webView.scrollView.contentOffset = CGPointMake(currentOffset.x, currentOffset.y + webView.frame.size.height)
        
        if (webViewContentSize.height < currentOffset.y) {
            
            // concat captures
            var targetPoint = CGPointZero
            UIGraphicsBeginImageContext(CGSizeMake(webViewContentSize.width * UIScreen.mainScreen().scale, webViewContentSize.height * UIScreen.mainScreen().scale));
            
            for image in captures {
                let imageWidth = CGFloat(CGImageGetWidth(image.CGImage))
                let imageHeight = CGFloat(CGImageGetHeight(image.CGImage))
                let imageRect = CGRectMake(targetPoint.x, targetPoint.y, imageWidth, imageHeight)
                
                image.drawInRect(imageRect)
                
                targetPoint = CGPointMake(imageRect.origin.x, imageRect.origin.y + imageRect.size.height)
            }
            let compositeImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            
            // save whole capture to Photo app
            UIImageWriteToSavedPhotosAlbum(compositeImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            // reset stored captures
            captures = [UIImage]()
            webView.userInteractionEnabled = true
            moveToScrollViewTop()
            
            if id is NSTimer {
                id.invalidate()
            }
        }
    }
    
    func moveToScrollViewTop() {
        webView.scrollView.contentOffset = CGPointZero
    }
    
    // MARK: - KVO for WKWebView
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let keyPath = keyPath, change = change else {
            return
        }
        
        switch keyPath {
        case "estimatedProgress":
            if let progress = change[NSKeyValueChangeNewKey] as? Double {
                pageTitleView.progress = progress
                pageTitleView.setNeedsDisplay()
            }
            break
            case "canGoBack":
                goBackButton.userInteractionEnabled = true
            break
            case "canGoForward":
                goForwardButton.userInteractionEnabled = true
            break
        default:
            break
        }
    }
}


extension WebViewController {
    // MARK: - CaptureMenuViewDelegate
    func tapCaptureButton(type: CaptureType) {
        webView.userInteractionEnabled = false
        moveToScrollViewTop()
        
        let timer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(takeScreenshot(_:)), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !canHideMenuBar {
            return
        }
        
        if scrollView.contentOffset.y < previousY || scrollView.contentOffset.y < 0 {
            print("出す")
            menuBarHeight.constant = 44.0
            menuBar.alpha = 1.0
        } else {
            print("隠す")
            let diff = scrollView.contentOffset.y - previousY
            let afterViewHeight = menuBarHeight.constant - diff
            print(afterViewHeight)
            if afterViewHeight < 0 {
                menuBarHeight.constant = 0
                menuBar.alpha = 0.0
            } else {
                menuBarHeight.constant = afterViewHeight
                menuBar.alpha -= 0.05
            }
        }
        
        previousY = scrollView.contentOffset.y
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        guard let query = searchBar.text else {
            print("urlがおかしい")
            return
        }
        
        var urlString = ""
        
        if query.lowercaseString.hasPrefix("http") {
            urlString = query
        } else {
            let encordedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            if let encordedQuery = encordedQuery {
                urlString = "http://google.com/#q=\(encordedQuery)"
            }
        }

        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
    
    // MARK - WKNavigationDelegate
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        canHideMenuBar = false
        reloadButton.userInteractionEnabled = false
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        pageTitleLabel.text = webView.title
        canHideMenuBar = true
        reloadButton.userInteractionEnabled = true
    }
    
    // MARK - WKUIDelegate
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        // enable to open target="_blank"
        if navigationAction.targetFrame == nil {
            webView.loadRequest(navigationAction.request)
        }
        return nil
    }
    
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        
        // display javascript default alert function by UIAlertViewController
        let alertController = javaScriptAlertViewController(webView.URL, message: message, preferredStyle: .Alert)
        
        let doneAction = UIAlertAction(title: "OK", style: .Default) { action in completionHandler() }
        alertController.addAction(doneAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        
        // display javascript confirm alert function by UIAlertViewController
        let alertController = javaScriptAlertViewController(webView.URL, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel) { action in completionHandler(false) }
        let doneAction = UIAlertAction(title: "OK", style: .Default) { action in completionHandler(true) }
        
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        
        // display javascript prompt alert function by UIAlertViewController
        let alertController = javaScriptAlertViewController(webView.URL, message: prompt, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel) { action in completionHandler("") }
        let doneAction = UIAlertAction(title: "OK", style: .Default) { action in completionHandler(alertController.textFields?.first?.text)}
        
        alertController.addTextFieldWithConfigurationHandler() { $0.text = defaultText }
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
        // display basic authentication dialog
        let authenticationMethod = challenge.protectionSpace.authenticationMethod
        
        switch authenticationMethod {
        case NSURLAuthenticationMethodDefault, NSURLAuthenticationMethodHTTPBasic, NSURLAuthenticationMethodHTTPDigest:
            
            let alertController = UIAlertController(title: "Authentication Required", message: "認証が必要です", preferredStyle: .Alert)
            weak var usernameTextField: UITextField!
            alertController.addTextFieldWithConfigurationHandler { textField in
                textField.placeholder = "Username"
                usernameTextField = textField
            }
            weak var passwordTextField: UITextField!
            alertController.addTextFieldWithConfigurationHandler { textField in
                textField.placeholder = "Password"
                textField.secureTextEntry = true
                passwordTextField = textField
            }
            
            let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: { action in completionHandler(.CancelAuthenticationChallenge, nil) })
            let doneAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
                if let userName = usernameTextField.text, password = passwordTextField.text {
                    let credential = NSURLCredential(user: userName, password: password, persistence: .ForSession)
                    completionHandler(.UseCredential, credential)
                }
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(doneAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        case NSURLAuthenticationMethodServerTrust: completionHandler(.PerformDefaultHandling, nil)
        default: completionHandler(.CancelAuthenticationChallenge, nil)
        }
    }

    func javaScriptAlertViewController(webViewUrl: NSURL?, message: String?, preferredStyle: UIAlertControllerStyle) -> UIAlertController {
        var alertTitle = ""
        if let url = webViewUrl, host = url.host {
            alertTitle = "\(url.scheme)://\(host)"
        }
        return UIAlertController(title: alertTitle, message: message, preferredStyle: preferredStyle)
    }
}


