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
        
        //Hiding Spinner and Password Text Entry
        loginSpinner.hidden = true
        passwordTextField.secureTextEntry = true
        
        // set text fields delegates
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // set text fields style
        let emailPaddingView = UITextField(frame: CGRectMake(0, 0, 10, 0))
        usernameTextField.leftView = emailPaddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.Always
        let passwordPaddingView = UITextField(frame: CGRectMake(0, 0, 10, 0))
        passwordTextField.leftView = passwordPaddingView
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        usernameTextField.tintColor = UIColor.orangeColor()
        passwordTextField.tintColor = UIColor.orangeColor()
        
        //Looks for single or multiple taps to dismiss keyboard:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    // move from textfield to another when tapping return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if usernameTextField.isFirstResponder() {
            // check if email contains '@' and '.' chracters:
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
    
    //MARK: DismissKeyboard method:
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: Login
    @IBAction func loginButtonTapped(sender: UIButton) {
        
        view.endEditing(true)
        
        // check if username and password text fields are empty
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
                    
                    // fetching user's last name for later use
                    Udacity.getUserName({ (success, status, userFirstName, userLastName) -> Void in
                        if success {
                            // save user's last name offline for later use
                            userDefaults.setObject(userLastName!, forKey: "userLastName")
                            userDefaults.setObject(userFirstName!, forKey: "userFirstName")
                        }
                    })
                    // removing password from password text field, so when user signs out, he has to enter the password again (for security reasons)
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
    
    // prevent segue to map if no network
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if identifier == "toSignUpVCSegue" {
            
            if !Reachability.isConnectedToNetwork() {
                presentMessage(self, title: "No Internet", message: "Your Device is not connected to the internet! Connect and try again", action: "OK")
                return false
            }
        }
        // by default, transition
        return true
    }
}
