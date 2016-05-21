//
//  Restaurant.swift
//  GoEat
//
//  Created by Evan on 5/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import Alamofire

class Restaurant {
    
    private var _name: String!
    private var _url: String!
    private var _address: String!
    private var _city: String!
    private var _zip: String!
    private var _state: String!
    private var _distance: Int!
    private var _websiteUrl: String!
    private var _phoneNumber: String!
    var couldntFind = false

    
    var name: String {
        
        if _name == nil {
            _name = ""
        }
        
        return _name
    }
    
    var url: String {
        if _url == nil {
                _url = ""
            }
        
        return _url
        
    }
    
    var address: String {
        if _address == nil {
            _address = ""
        }
            
        return _address
        
    }
    
    var city: String {
        if _city == nil {
            _city = ""
        }
            
        return _city
    }
    
    var zip: String {
        
        if _zip == nil {
            _zip = ""
        }
        return _zip
    }
    
    var state: String {
        if _state == nil {
            _state = ""
        }
        return _state
    }
    
    var distance: Int {
        if _distance == nil {
            _distance = 0
        }
        return _distance
    }
    
    var websiteUrl: String {
        if _websiteUrl == nil {
            _websiteUrl = ""
        }
        return _websiteUrl
    }
    
    var phoneNumber: String {
        if _phoneNumber == nil {
            _phoneNumber = ""
        }
        return _phoneNumber
    }
    
    init(url: String) {
        self._url = url 
    }
    
    func downloadFoursquareRest(completed: DownloadComplete) {
        
        let alamoUrl = NSURL(string: _url)!
        
        Alamofire.request(.GET, alamoUrl).responseJSON { response in
            let result = response.result
            
                print(result.value.debugDescription)
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                
                if let responseDict = dict["response"] as? Dictionary<String, AnyObject> {
                    
                    if let groupsDict = responseDict["groups"] as? [Dictionary<String, AnyObject>] {
                        
                        if let arrayDict = groupsDict[0] as? Dictionary<String, AnyObject> {
                            
                            if let itemsArrayDict = arrayDict["items"] as? [Dictionary<String, AnyObject>] {
                                
                                if let itemsDict = itemsArrayDict[0] as? Dictionary<String, AnyObject> {
                                    
                                    if let venueDict = itemsDict["venue"] as? Dictionary<String, AnyObject> {
                                        
                                        if let name = venueDict["name"] as? String {
                                            self._name = name
                                        }
                                        print(self._name)
                                        
                                        if let contactDict = venueDict["contact"] as? Dictionary<String, AnyObject> {
                                            
                                            if let phone = contactDict["phone"] as? String {
                                                self._phoneNumber = phone
                                            }
                                            
                                            print(self._phoneNumber)
                                        }
                                        
                                        if let locationDict = venueDict["location"] as? Dictionary<String, AnyObject> {
                                            
                                            if let address = locationDict["address"] as? String {
                                                self._address = address
                                            }
                                            
                                            if let city = locationDict["city"] as? String {
                                                self._city = city
                                            }
                                            
                                            if let state = locationDict["state"] as? String {
                                                self._state = state
                                            }
                                            
                                            if let zipcode = locationDict["postalCode"] as? String {
                                                self._zip = zipcode
                                            }
                                            
                                            if let distance = locationDict["distance"] as? Int {
                                                self._distance = distance
                                            }
                                            
                                            print("\(self._address), \(self._city), \(self._state) \(self._zip) which is \(Double(self._distance) * 0.000621371) miles away")
                                        
                                        }
                                        
                                        if let webUrl = venueDict["url"] as? String {
                                            self._websiteUrl = webUrl
                                        }
                                        
                                        print(self._websiteUrl)
                                    
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    }
                
                }
            
            completed()
        }
    }
        
}



