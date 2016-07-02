//
//  ListingViewController.swift
//  OnTheMap
//
//  Created by Casey Arnold on 5/1/16.
//  Copyright © 2016 Casey Arnold. All rights reserved.
//

import UIKit

class ListingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    var editingOldLocation = false
    var oldLocation: StudentLocation?
    
    override func viewDidAppear(animated: Bool) {
        if let selectedCellIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selectedCellIndexPath, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegates
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocation.locations.count
    }
    
    //MARK: TableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // sorting the array based on date locations updated:
        let sortedLocationsArray = StudentLocation.locations.sort({$1.updatedAt > $0.updatedAt })
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath)
        let name = sortedLocationsArray[indexPath.row].firstName! + " " + sortedLocationsArray[indexPath.row].lastName!
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = sortedLocationsArray[indexPath.row].mapString!
        
        return cell
    }
    
    
    //MARK: logOutButtonTapped
    @IBAction func logOutButtonTapped(sender: UIBarButtonItem) {
        tableView.alpha = 0.3
        logOutButton.enabled = false
        Udacity.logout { (success, status) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.alpha = 1.0
                    self.logOutButton.enabled = true
                })
            }
        }
    }
    
    
    //MARK: addLocationButtonTapped
    @IBAction func addLocationButtonTapped(sender: UIBarButtonItem) {
        
        if let userLastName = NSUserDefaults.standardUserDefaults().valueForKey("userLastName") as? String {
            Parse.checkIfLocationAlreadyAdded(userLastName, didComplete: { (found, studentLocation) -> Void in
                
                if found {
                    if let student = studentLocation {
                        self.oldLocation = student
                        self.editingOldLocation = true
                        let alert = UIAlertController(title: "Location & URL Already shared", message: "You shared (\(student.mediaURL!)) from (\(student.mapString!)) before, Do you want to Edit your location & URL ?", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "Override", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                            dispatch_async(dispatch_get_main_queue(), {
                                self.performSegueWithIdentifier("addFromListSegue", sender: self)
                            })
                        }))
                        dispatch_async(dispatch_get_main_queue(), {
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    }
                    
                } else {
                    // User didn't share a location before
                    self.editingOldLocation = false
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("addFromListSegue", sender: self)
                    })
                }
                
            })
        }
    }
    
    
    //MARK: refreshButtonTapped
    @IBAction func refreshButtonTapped(sender: UIBarButtonItem) {
        
        if Reachability.isConnectedToNetwork() {
            updateLocations()
        } else {
            presentMessage(self, title: "No Internet", message: "Your Device is not connected to the internet! Connect and try again", action: "OK")
        }
    }
    
    
    //MARK: helper methode to update table
    func updateLocations() {
        
        self.tableView.alpha = 0.3
        
        Parse.getLocations { (success, status, locationsArray) -> Void in
            if success {
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    
                    StudentLocation.locations = locationsArray!
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.alpha = 1
                    self.tableView.reloadData()
                }
            }  else {
                dispatch_async(dispatch_get_main_queue(), {
                    presentMessage(self, title: "Error", message: status!, action: "OK")
                    self.tableView.alpha = 1
                })
            }
        }
    }
    
    
    //MARK: prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromListToURLVCSegue" {
            let urlVC = segue.destinationViewController as! URLViewController
            urlVC.urlString = StudentLocation.locations[(tableView.indexPathForSelectedRow?.row)!].mediaURL!
        }
        if segue.identifier == "addFromListSegue" {
            let locationViewController = segue.destinationViewController as? LocationViewController
            locationViewController?.editingOldLocation = self.editingOldLocation
            locationViewController?.oldLocation = self.oldLocation
        }
    }
    
    
}

