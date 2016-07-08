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
        
        
        //Checking to see if Location has changed here...
        print ("Break......")
        print ("Checking Location in Sharing....")
        print (newLocation)
        print (oldLocation)
        print ("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
        
        
        urlStringTextField.delegate = self
        
        
        let emailPaddingView = UITextField(frame: CGRectMake(0, 0, 30, 0))
        urlStringTextField.leftView = emailPaddingView
        urlStringTextField.leftViewMode = UITextFieldViewMode.Always
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    
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
        
        //Checking Parameters....
        print ("Break.......")
        print ("Button Tapped on Final Submit....")
        print (newLocation)
        print ("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
        
        if Reachability.isConnectedToNetwork() {
            newLocation?.mediaURL! = urlStringTextField.text!
            
            if editingOldLocation {
                Parse.updateStudentLocation(oldLocation!, new: newLocation!, didComplete: { (success, status) -> Void in
                    
                    //Checking Data in Sharing VC
                    print("Sharing Controller Data:")
                    print (self.newLocation)
                    
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
                                "latitude"  : (self.latitude),
                                "longitude" : (self.longitude),
                                "mapString" : urlString,
                                "mediaURL"  : urlString,
                                "objectId"  : "",
                                "uniqueKey" : userID,
                                "updatedAt" : ""
                            ]
                            
                            let locations = StudentLocation.locationsFromResults([locationDict])
                            
                            Parse.addLocation(locations.first!, didComplete: { (success, status) -> Void in
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.performSegueWithIdentifier("backToListVCSegue", sender: self)
                                    
                                })
                                
                                if success {
                                    print("success")
                                    
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
    
    
    func DismissKeyboard(){
        
        view.endEditing(true)
    }
    
    
}
