//
//  HomeVC.swift
//  GoEat
//
//  Created by Evan on 5/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

var hasMadeRestRequest = false

class HomeVC: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var open: UIBarButtonItem!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var confirmLoc: UIButton!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var distanceTextField: UITextField!
    
    @IBOutlet weak var distanceButton: UIButton!
    
    var confirmedLocation = false
    
    let locationManager = CLLocationManager()
    
    var lat: CLLocationDegrees = 0.0
    var long: CLLocationDegrees = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        open.target = self.revealViewController()
        open.action = Selector("revealToggle:")
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
       /* distanceLabel.hidden = true
        distanceTextField.hidden = true
        distanceButton.hidden = true*/
        
        distanceTextField.delegate = self
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let aSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
        let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
        let numberFiltered = compSepByCharInSet.joinWithSeparator("")
        return string == numberFiltered
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        
        lat = location.latitude
        long = location.longitude
        
        map.showsUserLocation = true
        let center = CLLocationCoordinate2D(latitude: location.latitude , longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01))
        
        map.setRegion(region, animated: true)
        
        
    }


    @IBAction func confirmLocation(sender: AnyObject) {
        print("\(lat)\(long)")
        print(PFUser.currentUser()?.username)
        
        let restRequest = PFObject(className: "restRequest")
        restRequest["username"] = PFUser.currentUser()?.username
        restRequest["userLocation"] = PFGeoPoint(latitude: lat, longitude: long)
        restRequest.saveInBackgroundWithBlock { (success, error) in
            
            if success {
                
                self.confirmedLocation = true
                hasMadeRestRequest = true
                
            } else {
                
                self.displayAlert("Could not confirm location", message: "Please check and make sure location services for this app are turned on, thank you!")
                
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func restartButton(sender: AnyObject) {
        
        let query = PFQuery(className: "restRequest")
        query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) in
            
            if error == nil {
                
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        object.deleteInBackground()
                        self.confirmedLocation = false
                        hasMadeRestRequest = false
                    }
                }
                
            } else {
                
                self.displayAlert("Could not restart", message: "\(error)")
            }
        }
    }
    
    @IBAction func confirmDistance(sender: AnyObject) {
        
        
        let query = PFQuery(className: "restRequest")
        query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) in
            
            if error == nil {
                
                if let objects = objects as [PFObject]! {
                    
                    for object in objects {
                
                    if self.confirmedLocation == true {
                    
                        if self.distanceTextField != "" {
                            
                            let query = PFQuery(className: "restRequest")
                            query.getObjectInBackgroundWithId(object.objectId!, block: { (object: PFObject?, error: NSError?) in
                                
                                if error != nil {
                                    print(error)
                                } else if let object = object {
                                    
                                    object["userDistance"] = self.distanceTextField.text
                                    
                                    object.saveInBackground()
                                }
                            })
                
                        } else {
                            
                        self.displayAlert("Could not confirm distance", message: "Please type in a distance willing to travel between 1-100, thank you!")
                        }
                    } else {
                    
                        self.displayAlert("Could not confirm distance", message: "Please confirm your location first, thank you!")
                    
                    }
                }
                
            } else {
                
                self.displayAlert("Could not confirm distance", message: "\(error)")
            }
        }
    }
    }
    
}



