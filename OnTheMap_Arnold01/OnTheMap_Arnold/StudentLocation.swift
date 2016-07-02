//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by Casey Arnold on 5/1/16.
//  Copyright © 2016 Casey Arnold. All rights reserved.
//

import Foundation

//TODO: import NSDate from String using NSDateFormatter

struct StudentLocation {
    
    // shared locations singleton
    static var locations: [StudentLocation] = []
    
    var createdAt: String?
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mapString: String?
    var mediaURL: String?
    var objectId: String?
    var uniqueKey: String?
    var updatedAt: String?
    
    init (dictionary: [String : AnyObject]) {
        createdAt = dictionary["createdAt"] as? String
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
        mapString = dictionary["mapString"] as? String
        mediaURL = dictionary["mediaURL"] as? String
        objectId = dictionary["objectId"] as? String
        uniqueKey = dictionary["uniqueKey"] as? String
        updatedAt = dictionary["updatedAt"] as? String
    }
    
    
    // Helper: Given an array of dictionaries, convert them to an array of StudentLocation objects
    static func locationsFromResults(results: [[String : AnyObject]]) -> [StudentLocation] {
        var locations = [StudentLocation]()
        
        for result in results {
            locations .append(StudentLocation(dictionary: result))
        }
        return locations
    }
    
}