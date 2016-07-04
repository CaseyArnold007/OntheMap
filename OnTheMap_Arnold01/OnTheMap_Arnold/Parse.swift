//
//  Parsing.swift
//  OnTheMap
//
//  Created by Casey Arnold on 5/1/16.
//  Copyright © 2016 Casey Arnold. All rights reserved.
//

import Foundation


class Parse {
    
    //Getting Locations
    class func getLocations(didComplete: (success: Bool, status: String?, locationsArray: [StudentLocation]?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.ParseBaseLink + ParseMethodNames.StudentLocation + "?limit=\(Constants.ParseResultsLimit)")!)
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: ParseHTTPHeaders.ParseApplicationID)
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: ParseHTTPHeaders.RESTAPIKey)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil) else {
                print(error!.localizedDescription)
                didComplete(success: false, status: error!.localizedDescription, locationsArray: nil)
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                guard let results = parsedResult["results"] as? [[String : AnyObject]] else {
                    print("Can't find results in \(parsedResult!)")
                    didComplete(success: false, status: "Couldn't find Results", locationsArray: nil)
                    return
                }
                let locations = StudentLocation.locationsFromResults(results)
                didComplete(success: true, status: nil, locationsArray: locations)
                
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                didComplete(success: false, status: "Couldn't find Results", locationsArray: nil)
                return
            }
        }
        task.resume()
    }
    
    
    //Adding A Location
    class func addLocation(user: StudentLocation, didComplete: (success: Bool, status: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.ParseBaseLink + ParseMethodNames.StudentLocation)!)
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: ParseHTTPHeaders.ParseApplicationID)
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: ParseHTTPHeaders.RESTAPIKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(user.uniqueKey!)\", \"firstName\": \"\(user.firstName!)\", \"lastName\": \"\(user.lastName!)\",\"mapString\": \"\(user.mapString!)\", \"mediaURL\": \"\(user.mediaURL!)\",\"latitude\": \(user.latitude!), \"longitude\": \(user.longitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard (error == nil) else {
                print(error!.localizedDescription)
                didComplete(success: false, status: error!.localizedDescription)
                return
            }
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                guard let _ = parsedResult["objectId"] as? [[String : AnyObject]] else {
                    print("Can't find objectId in \(parsedResult!)")
                    didComplete(success: false, status: "Couldn't find Results")
                    return
                }
                
                didComplete(success: true, status: nil)
                
            }  catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                didComplete(success: false, status: "Could not parse the data")
                return
            }
        }
        task.resume()
    }
    
    //Query A Location
    class func queryLocation(uniqueKey: String, didComplete: (success: Bool, status: String?, location: StudentLocation?) -> Void) {
        
        let urlString = Constants.ParseBaseLink + ParseMethodNames.StudentLocation + "?where=%7B%22uniqueKey%22%3A%22" + uniqueKey + "%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: ParseHTTPHeaders.ParseApplicationID)
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: ParseHTTPHeaders.RESTAPIKey)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil) else {
                print(error!.localizedDescription)
                didComplete(success: false, status: error!.localizedDescription, location: nil)
                return
            }
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
                guard let results = parsedResult["results"] as? [[String : AnyObject]] else {
                    print("Can't find results in \(parsedResult!)")
                    didComplete(success: false, status: "Couldn't find Results", location: nil)
                    return
                }
                let studentLocation = StudentLocation.locationsFromResults(results).first
                didComplete(success: true, status: nil, location: studentLocation)
                
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                didComplete(success: false, status: "Could not parse the data", location: nil)
                return
            }
        }
        task.resume()
    }
    
    
    //Updating A Location
    
    
    class func updateStudentLocation (old: StudentLocation, new: StudentLocation, didComplete:(success: Bool, status: String?) -> Void) {
        
        let urlString = Constants.ParseBaseLink + ParseMethodNames.StudentLocation
            
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: ParseHTTPHeaders.ParseApplicationID)
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: ParseHTTPHeaders.RESTAPIKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"\(old.uniqueKey!)\", \"firstName\": \"\(new.firstName!)\", \"lastName\": \"\(new.lastName!)\",\"mapString\": \"\(new.mapString!)\", \"mediaURL\": \"\(new.mediaURL!)\",\"latitude\": \(new.latitude!), \"longitude\": \(new.longitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        
        //Print Body
        print ("Break.................")
        print ("HTTP Body Print.......")
        print (request.HTTPBody)
        print ("XXXXXXXXXXXXXXXXXXXXXX")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil) else {
                print(error!.localizedDescription)
                didComplete(success: false, status: error!.localizedDescription)
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
                
                //Printing Parsed result....
                print ("Break.........")
                print ("Parsed Result.")
                print (parsedResult)
                print ("XXXXXXXXXXXXXX")
                
                guard let _ = parsedResult["updatedAt"] as? String else {
                    print("Can't find updatedAt in \(parsedResult!)")
                    didComplete(success: false, status: "Couldn't find Results")
                    return
                }
                
                didComplete(success: true, status: nil)
                
            }  catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                didComplete(success: false, status: "Could not parse the data")
                return
            }
        }
        task.resume()
        
    }
    
    
    //Has A Location Been Added???
    class func checkIfLocationAlreadyAdded(lastName: String, didComplete: (found: Bool, studentLocation: StudentLocation?) -> Void) {
        
        getLocations { (success, status, locationsArray) -> Void in
            if success {
                if let locations = locationsArray {
                    
                    var found = false
                    
                    for location in locations {
                        if location.lastName! == lastName {
                            didComplete(found: true, studentLocation: location)
                            found = true
                        }
                    }
                    if !found {
                        didComplete(found: false, studentLocation: nil)
                    }
                }
            }
        }
    }
    
    
}
