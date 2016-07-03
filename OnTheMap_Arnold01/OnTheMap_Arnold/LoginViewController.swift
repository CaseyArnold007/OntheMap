//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Casey Arnold on 5/1/16.
//  Copyright © 2016 Casey Arnold. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    
    var currentKeyboardHeight: CGFloat = 0.0
    var viewMovedUp = false
    var viewMovedDown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        loginSpinner.hidden = true
        passwordTextField.secureTextEntry = true
        
      
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
      
        let emailPaddingView = UITextField(frame: CGRectMake(0, 0, 10, 0))
        usernameTextField.leftView = emailPaddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.Always
        let passwordPaddingView = UITextField(frame: CGRectMake(0, 0, 10, 0))
        passwordTextField.leftView = passwordPaddingView
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        usernameTextField.tintColor = UIColor.orangeColor()
        passwordTextField.tintColor = UIColor.orangeColor()
        
    
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
  
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if usernameTextField.isFirstResponder() {
           
            if (usernameTextField.text!.rangeOfString("@") == nil || usernameTextField.text!.rangeOfString(".") == nil) {
                presentMessage(self, title: "Invalid Email Address", message: "\(usernameTextField.text!) is Not A Valid Email Address", action: "Try Again")
            } else {
                passwordTextField.becomeFirstResponder()
            }
        } else {
            DismissKeyboard()
            loginButtonTapped(loginButton)
        }
        return true
    }
    
   
    func DismissKeyboard(){
      
        view.endEditing(true)
    }
    
   
    @IBAction func loginButtonTapped(sender: UIButton) {
        
        view.endEditing(true)
        
       
        if usernameTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true {
            presentMessage(self, title: "No Email and/or Password", message: "Please Enter Your Email and Password", action: "OK")
        }
        else {
            
            if Reachability.isConnectedToNetwork() {
                
                loginButton.hidden = true
                loginSpinner.hidden = false
                loginSpinner.startAnimating()
                
                Udacity.login(usernameTextField.text!, password: passwordTextField.text!) { (success, status, userID) -> Void in
                    
                    if !success {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.loginSpinner.stopAnimating()
                            self.loginButton.hidden = false
                            presentMessage(self, title: "Error", message: status!, action: "OK")
                        })
                        return
                    }
                    
                  
                    Udacity.getUserName({ (success, status, userFirstName, userLastName) -> Void in
                        if success {
                         
                            userDefaults.setObject(userLastName!, forKey: "userLastName")
                            userDefaults.setObject(userFirstName!, forKey: "userFirstName")
                        }
                    })
                   
                    self.passwordTextField.text = ""
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.DismissKeyboard()
                        self.loginSpinner.stopAnimating()
                        self.loginButton.hidden = false
                        
                        self.performSegueWithIdentifier("toTabVCSegue", sender: self)
                    })
                }
                
            } else {
                presentMessage(self, title: "No Internet", message: "Your Device is not connected to the internet! Connect and try again", action: "OK")
            }
            
            
            
        }
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if identifier == "toSignUpVCSegue" {
            
            if !Reachability.isConnectedToNetwork() {
                presentMessage(self, title: "No Internet", message: "Your Device is not connected to the internet! Connect and try again", action: "OK")
                return false
            }
        }
        
        return true
    }
}
