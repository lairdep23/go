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
    
    fileprivate var _name: String!
    fileprivate var _url: String!
    fileprivate var _address: String!
    fileprivate var _city: String!
    fileprivate var _zip: String!
    fileprivate var _state: String!
    fileprivate var _distance: Int!
    fileprivate var _websiteUrl: String!
    fileprivate var _fourUrl: String!
    fileprivate var _phoneNumber: String!
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
    
    var fourUrl: String {
        if _fourUrl == nil {
            _fourUrl = ""
        }
        return _fourUrl
    }
    
    init(url: String) {
        self._url = url 
    }
    
    func downloadFoursquareRest(_ completed: @escaping DownloadComplete) {
        
        let alamoUrl = URL(string: _url)!
        
        Alamofire.request(.GET, alamoUrl).responseJSON { response in
            let result = response.result
            
                print(result.value.debugDescription)
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                
                if let responseDict = dict["response"] as? Dictionary<String, AnyObject> {
                    
                    if let resultsNumber = responseDict["totalResults"] as? Int {
                        if resultsNumber == 0 {
                            print("No results")
                            self.couldntFind = true
                            completed()
                        } else {
                            print("We got results")
                            self.couldntFind = false
                            
                            if let groupsDict = responseDict["groups"] as? [Dictionary<String, AnyObject>] {
                                
                                if let arrayDict = groupsDict[0] as? Dictionary<String, AnyObject> {
                                    
                                    if let itemsArrayDict = arrayDict["items"] as? [Dictionary<String, AnyObject>] {
                                        
                                        if let itemsDict = itemsArrayDict[0] as? Dictionary<String, AnyObject> {
                                            
                                            if let tipsArray = itemsDict["tips"] as? [Dictionary<String, AnyObject>] {
                                                
                                                if let tipsDict = tipsArray[0] as? Dictionary<String, AnyObject> {
                                                    
                                                    if let squareUrl = tipsDict["canonicalUrl"] as? String {
                                                        
                                                        self._fourUrl = squareUrl
                                                        print(self._fourUrl)
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                            if let venueDict = itemsDict["venue"] as? Dictionary<String, AnyObject> {
                                                
                                                if let name = venueDict["name"] as? String {
                                                    self._name = name
                                                    print(self._name)
                                                }
                                                
                                                
                                                if let contactDict = venueDict["contact"] as? Dictionary<String, AnyObject> {
                                                    
                                                    if let phone = contactDict["phone"] as? String {
                                                        self._phoneNumber = phone
                                                        print(self._phoneNumber)
                                                    }
                                                    
                                                    
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
                    
                    
    }
        
}



