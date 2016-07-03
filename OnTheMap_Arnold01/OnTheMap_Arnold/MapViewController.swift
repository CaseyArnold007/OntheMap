//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Casey Arnold on 5/1/16.
//  Copyright © 2016 Casey Arnold. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var editingOldLocation = false
    var oldLocation: StudentLocation?
    
    @IBOutlet weak var logOutSpinner: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addAnnotations()
    }
    
    func addAnnotations() {
        
        self.mapView.alpha = 0.3
        self.logOutSpinner.startAnimating()
        
        Parse.getLocations { (success, status, locationsArray) -> Void in
            if success {
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    
                    StudentLocation.locations = locationsArray!
                    
                    for location in StudentLocation.locations {
                        
                        
                        let lat = CLLocationDegrees(location.latitude!)
                        let long = CLLocationDegrees(location.longitude!)
                        
                        
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        
                        let first = location.firstName!
                        let last = location.lastName!
                        let mediaURL = location.mediaURL!
                        
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = mediaURL
                        
                        
                        self.annotations.append(annotation)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.mapView.alpha = 1
                        self.logOutSpinner.stopAnimating()
                        self.mapView.addAnnotations(self.annotations)
                        
                        
                    }
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    presentMessage(self, title: "Error", message: status!, action: "OK")
                    self.mapView.alpha = 1
                    self.logOutSpinner.stopAnimating()
                })
            }
        }
        
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.orangeColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
        func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            performSegueWithIdentifier("fromMapToURLVCSegue", sender: self)
        }
    }
    
    
    @IBAction func logOutButtonTapped(sender: UIBarButtonItem) {
        mapView.alpha = 0.3
        logOutButton.enabled = false
        logOutSpinner.startAnimating()
        Udacity.logout { (success, status) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.alpha = 1.0
                    self.logOutButton.enabled = true
                    self.logOutSpinner.stopAnimating()
                })
            }
        }
    }
    
    
    @IBAction func addLocationButtonTapped(sender: UIBarButtonItem) {
        
        if let userLastName = userDefaults.valueForKey("userLastName") as? String {
            Parse.checkIfLocationAlreadyAdded(userLastName, didComplete: { (found, studentLocation) -> Void in
                
                if found {
                    if let student = studentLocation {
                        self.oldLocation = student
                        self.editingOldLocation = true
                        
                        let alert = UIAlertController(title: "Location & URL Already shared", message: "You shared \(student.mediaURL!) from \(student.mapString!) before, Do you want to Edit your location & URL ?", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "Edit Location", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                            dispatch_async(dispatch_get_main_queue(), {
                                self.performSegueWithIdentifier("addFromMapSegue", sender: self)
                                
                                //Checking Optionals....
                                print ("Checking Optionals...")
                                print (student.mediaURL)
                                print (student.mapString)
                                print (student.firstName)
                                print (student.lastName)
                            })
                        }))
                        dispatch_async(dispatch_get_main_queue(), {
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    }
                    
                } else {
                    
                    self.editingOldLocation = false
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("addFromMapSegue", sender: self)
                    })
                }
                
            })
        }
    }
    
    
    @IBAction func refreshButtonTapped(sender: UIBarButtonItem) {
        if Reachability.isConnectedToNetwork() {
            annotations = []
            let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
            mapView.removeAnnotations( annotationsToRemove )
            addAnnotations()
        } else {
            presentMessage(self, title: "No Internet", message: "You are not connected to the internet! Connect your device and try again", action: "OK")
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromMapToURLVCSegue" {
            let urlVC = segue.destinationViewController as! URLViewController
            urlVC.urlString = (mapView.selectedAnnotations.first?.subtitle!)!
        }
        if segue.identifier == "addFromMapSegue" {
         let locationViewController = segue.destinationViewController as? LocationViewController
            locationViewController?.editingOldLocation = self.editingOldLocation
            locationViewController?.oldLocation = self.oldLocation
        }
    }
}