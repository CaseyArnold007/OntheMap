//
//  Constant.swift
//  OnTheMap
//
//  Created by Casey Arnold on 5/1/16.
//  Copyright © 2016 Casey Arnold. All rights reserved.
//

import Foundation

struct Constants {
    
    
        
    static let UdacityBaseLink = "https://www.udacity.com/api/"
    static let ParseBaseLink = "https://api.parse.com/1/classes/"
    
    
    static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    static let ParseResultsLimit = 100
}

struct ParseHTTPHeaders {
    static let ParseApplicationID = "X-Parse-Application-Id"
    static let RESTAPIKey = "X-Parse-REST-API-Key"
}

struct ParseMethodNames {
    static let StudentLocation = "StudentLocation"
}

struct UdacityMethodNames {
    static let Session = "session"
    static let Users = "users/"
}



struct ParseJSONBodyKeys {
    static let UniqueKey = "uniqueKey"
    static let FirstName = "firstName"
    static let LastName = "lastName"
    static let MapString = "mapString"
    static let MediaURL = "mediaURL"
    static let Latitude = "latitude"
    static let Longitude = "longitude"
}