//
//  LocationConfimationViewController.swift
//  OnTheMap
//
//  Created by Casey Arnold on 5/1/16.
//  Copyright © 2016 Casey Arnold. All rights reserved.
//

import UIKit
import MapKit

class LocationConfirmationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var locationStringLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSpinner: UIActivityIndicatorView!
    
    
    var editingOldLocation = false
    var locationString = ""
    let geocoder = CLGeocoder()
    var oldLocation: StudentLocation?
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set mapView delegate
        mapView.delegate = self
        
        mapView.alpha = 0.3
        mapSpinner.startAnimating()
        
        geocoder.geocodeAddressString(locationString, completionHandler: {(placemarks, error) -> Void in
            
            self.mapView.alpha = 0.3
            self.mapSpinner.startAnimating()
            
            if((error) != nil) {
                self.mapView.alpha = 1
                self.mapSpinner.stopAnimating()
                presentMessage(self, title: "Address not found", message: "Address not found, Please try again!", action: "OK")
            }
            if let placemark = placemarks?.first {
                
                self.mapView.alpha = 1
                self.mapSpinner.stopAnimating()
                
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                
                self.latitude = coordinates.latitude
                self.longitude = coordinates.longitude
                
                let region = MKCoordinateRegionMakeWithDistance(
                    coordinates, 2000, 2000)
                self.mapView.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                annotation.title = self.locationString
                self.mapView.addAnnotation(annotation)
            }
            
        })
        
        //Looks for single or multiple taps to dismiss keyboard:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    
    //MARK: submitLocationButtonTapped
    @IBAction func submitLocationButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("toShareLocationVCSegue", sender: self)
    }
    
    
    //MARK: cancelButtonTapped
    @IBAction func cancelButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toShareLocationVCSegue" {
            let shareLocationVC = segue.destinationViewController as! SharingViewController
            shareLocationVC.editingOldLocation = self.editingOldLocation
            shareLocationVC.locationString = self.locationString
            shareLocationVC.latitude = self.latitude
            shareLocationVC.longitude = self.longitude
            shareLocationVC.oldLocation = self.oldLocation
        }
    }
    
    
    //MARK: DismissKeyboard method:
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}
