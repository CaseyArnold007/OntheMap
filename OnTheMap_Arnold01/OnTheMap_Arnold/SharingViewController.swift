//
//  SharingViewController.swift
//  OnTheMap
//
//  Created by Casey Arnold on 5/1/16.
//  Copyright © 2016 Casey Arnold. All rights reserved.
//

import UIKit

class SharingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var urlStringTextField: UITextField!
    @IBOutlet weak var submitUrlButton: UIButton!
    
    var editingOldLocation = false
    var locationString = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var urlString = ""
    var oldLocation: StudentLocation?
    var newLocation: StudentLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newLocation = oldLocation
        
        newLocation?.mapString = self.locationString
        newLocation?.latitude = self.latitude
        newLocation?.longitude = self.longitude
        
        // set textfield delegate
        urlStringTextField.delegate = self
        
        // set text fields style
        let emailPaddingView = UITextField(frame: CGRectMake(0, 0, 30, 0))
        urlStringTextField.leftView = emailPaddingView
        urlStringTextField.leftViewMode = UITextFieldViewMode.Always
        
        //Looks for single or multiple taps to dismiss keyboard:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    // move from textfield to another when tapping return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if urlStringTextField.text!.rangeOfString(".") == nil {
            presentMessage(self, title: "Invalid URL", message: "\(urlStringTextField.text!) is Not A Valid URL", action: "Try Again")
        } else {
            self.urlString = urlStringTextField.text!
            DismissKeyboard()
            submitButtonTapped(submitUrlButton)
        }
        return true
    }
    
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButtonTapped(sender: UIButton) {
        
        if Reachability.isConnectedToNetwork() {
            newLocation?.mediaURL! = urlStringTextField.text!
            
            if editingOldLocation {
                Parse.updateStudentLocation(oldLocation!, new: newLocation!, didComplete: { (success, status) -> Void in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.performSegueWithIdentifier("backToListVCSegue", sender: self)
                            
                        })
                        
                    }
                })
            } else {
                
                if let firstName = userDefaults.valueForKey("userFirstName") as? String {
                    if let lastName = userDefaults.valueForKey("userLastName") as? String {
                        if let userID = userDefaults.valueForKey("userID") as? String {
                            
                            let locationDict: [String : AnyObject] = [
                                "createdAt" : "",
                                "firstName" : firstName,
                                "lastName"  : lastName,
                                "latitude"  : 1.0,
                                "longitude" : 1.0,
                                "mapString" : urlString,
                                "mediaURL"  : urlString,
                                "objectId"  : "",
                                "uniqueKey" : userID,
                                "updatedAt" : ""
                            ]
                            
                            let locations = StudentLocation.locationsFromResults([locationDict])
                            
                            Parse.addLocation(locations.first!, didComplete: { (success, status) -> Void in
                                if success {
                                    print("success")
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                            self.dismissViewControllerAnimated(true, completion: nil)
                                        })
                                    })
                                    
                                }
                            })
                        }
                    }
                }
            }
        } else {
            presentMessage(self, title: "No Internet", message: "Your Device is not connected to the internet! Connect and try again", action: "OK")
        }
        
    }
    
    //MARK: DismissKeyboard method:
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
}
