//
//  FPCWebViewController.swift
//  FullPageCapture
//
//  Created by Imairi, Yosuke a | Kametan | TRVDD on 3/14/16.
//  Copyright © 2016 imairi. All rights reserved.
//

import UIKit
import WebKit

class FPCWebViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        webView.frame = CGRectMake(0, searchBar.frame.size.height + 20, view.frame.width, UIScreen.mainScreen().bounds.size.height - searchBar.frame.size.height - 49 - 20)
        view.addSubview(webView)
        
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        if let url = NSURL(string: "http://google.com/") {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - WKNavigationDelegate
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(__FUNCTION__)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print(__FUNCTION__)
    }
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        print(__FUNCTION__)
    }
    
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print(__FUNCTION__)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print(__FUNCTION__)
    }

    @IBAction func tapAButton(sender: AnyObject) {
        print(__FUNCTION__)
        let webViewContentSize = webView.scrollView.contentSize
        print(webViewContentSize)
        let currentOffset = webView.scrollView.contentOffset
        
        
        let capture = screenCapture(view: webView, rect: webView.frame)
        let imageView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
        imageView.image = capture
        view.addSubview(imageView)
        
        UIImageWriteToSavedPhotosAlbum(capture, self, "image:didFinishSavingWithError:contextInfo:", nil)
        
        webView.scrollView.contentOffset = CGPointMake(currentOffset.x, currentOffset.y + webView.frame.size.height)
    }
    
    
    
    
    func screenCapture(view view:UIView, rect:CGRect) -> UIImage {
        var capture : UIImage
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y)
        
        if view.respondsToSelector("drawViewHierarchyInRect:afterScreenUpdates:") {
            view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        } else {
            view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        }
        
        capture = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return capture
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        print(__FUNCTION__)
        if error != nil {
            print(error.code)
        }
    }
}
