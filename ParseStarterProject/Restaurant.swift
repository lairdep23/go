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

    
    var name: String {
        return _name
    }
    
    var url: String {
        return _url
    }
    
    var address: String {
        return _address
    }
    
    var city: String {
        return _city
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
                                        
                                        if let locationDict = venueDict["location"] as? Dictionary<String, AnyObject> {
                                            
                                            if let address = locationDict["address"] as? String {
                                                self._address = address
                                            }
                                            
                                            if let city = locationDict["city"] as? String {
                                                self._city = city
                                            }
                                            
                                            print("\(self._address), \(self._city)")
                                        
                                        }
                                    
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                }
                
            }
        }
        
    }
}


