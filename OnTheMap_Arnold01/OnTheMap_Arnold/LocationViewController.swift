//
//  LocationViewController.swift
//  OnTheMap
//
//  Created by Casey Arnold on 5/1/16.
//  Copyright © 2016 Casey Arnold. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var submitLocationButton: UIButton!
    @IBOutlet weak var locationStringTextField: UITextField!
    
    @IBOutlet weak var geoLoactionSpinner: UIActivityIndicatorView!
    
    
    var editingOldLocation = false
    var oldLocation: StudentLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        locationStringTextField.delegate = self
        
     
        let emailPaddingView = UITextField(frame: CGRectMake(0, 0, 30, 0))
        locationStringTextField.leftView = emailPaddingView
        locationStringTextField.leftViewMode = UITextFieldViewMode.Always
        
       
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        DismissKeyboard()
        findLocationButtonTapped(submitLocationButton)
        return true
    }
    
  
    @IBAction func findLocationButtonTapped(sender: UIButton) {
        
        geoLoactionSpinner.startAnimating()
        
        if locationStringTextField.text?.isEmpty == true {
            presentMessage(self, title: "No Location", message: "No location, Please enter your location and try again!", action: "OK")
            geoLoactionSpinner.stopAnimating()
        } else {
            performSegueWithIdentifier("toConfirmMapVCSegue", sender: self)
            geoLoactionSpinner.stopAnimating()
        }
    }
    
  
    @IBAction func cancelButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toConfirmMapVCSegue" {
            let confirmLocationVC = segue.destinationViewController as! LocationConfirmationViewController
            
            if locationStringTextField.text?.isEmpty == false {
                confirmLocationVC.editingOldLocation = self.editingOldLocation
                confirmLocationVC.locationString = locationStringTextField.text!
                confirmLocationVC.oldLocation = self.oldLocation
                
                
                //Checking Old Location....
                print ("Break....")
                print ("Checking Old Location....")
                print (self.oldLocation)
                
            } else {
                presentMessage(self, title: "No Location", message: "No location typed, Please enter your location and try again", action: "OK")
            }
        }
    }
    
    
    
    func DismissKeyboard(){
     
        view.endEditing(true)
    }
    
}
