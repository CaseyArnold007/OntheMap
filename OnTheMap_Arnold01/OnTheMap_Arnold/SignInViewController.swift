//
//  SignInViewController.swift
//  OnTheMap
//
//  Created by Casey Arnold on 5/1/16.
//  Copyright © 2016 Casey Arnold. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var webspinner: UIActivityIndicatorView!
    
    let url = NSURL (string: "https://www.udacity.com/account/auth#!/signup")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        
        webspinner.startAnimating()
        webView.bounds.size = self.view.bounds.size
        webView.loadRequest(NSURLRequest(URL: url!))
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        webspinner.stopAnimating()
        presentMessage(self, title: "Error", message: "\(error!.localizedDescription)", action: "OK")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webspinner.stopAnimating()
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func openInSafariButtonTapped(sender: UIBarButtonItem) {
        UIApplication.sharedApplication().openURL(self.url!)
    }
    
}

