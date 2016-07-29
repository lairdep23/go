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
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timesLoaded = 1
        
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
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
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let logo = UIImage(named: "logoSmall")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
        
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
        if launchedBefore {
            print("Not First Launch")
        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
            displayEmailAlert("Thank you for downloading GoEat!", message: "Enter your email to recieve a personal thank you letter from the founder, Evan!")
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "HomeVC Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 130)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 130)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
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
                
                USER_LAT = "\(self.lat)"
                USER_LONG = "\(self.long)"
                
                self.confirmedLocation = true
                hasMadeRestRequest = true
                
            } else {
                
                self.displayAlert("Could not confirm location", message: "Please check and make sure location services for this app are turned on, thank you!")
                
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { (action) in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func restartButton(sender: AnyObject) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    
        
        let query = PFQuery(className: "restRequest")
        query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) in
            
            if error == nil {
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        object.deleteInBackgroundWithBlock({ (success, error) in
                          
                            if success {
                                
                                self.activityIndicator.stopAnimating()
                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                
                                self.confirmedLocation = false
                                hasMadeRestRequest = false
                                
                                USER_LAT = ""
                                USER_LONG = ""
                                USER_DISTANCE = ""
                                
                            } else {
                                self.activityIndicator.stopAnimating()
                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            }
                            
                        })
                        
                    }
                }
                
            } else {
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                self.displayAlert("Could not restart", message: "\(error)")
            }
        }
    }
    
    @IBAction func confirmDistance(sender: AnyObject) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        
        let query = PFQuery(className: "restRequest")
        query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) in
            
            if error == nil {
                
                if let objects = objects as [PFObject]! {
                    
                    for object in objects {
                
                    if self.confirmedLocation == true {
                    
                        if self.distanceTextField.text != "" {
                            
                            let confirmedDistanceMeters = Double(self.distanceTextField.text!)! * 1609
                            
                            let query = PFQuery(className: "restRequest")
                            query.getObjectInBackgroundWithId(object.objectId!, block: { (object: PFObject?, error: NSError?) in
                                
                                if error != nil {
                                    print(error)
                                } else if let object = object {
                                    
                                    object["userDistance"] = "\(confirmedDistanceMeters)"
                                    object.saveInBackgroundWithBlock({ (success, error) in
                                        
                                        self.activityIndicator.stopAnimating()
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                        
                                        if error == nil {
                                            self.performSegueWithIdentifier("homeToRequestSegue", sender: nil)
                                            USER_DISTANCE = "\(confirmedDistanceMeters)"
                                        } else {
                                           
                                            self.displayAlert("Could not confirm distance", message: "Please try again in a little bit, thank you!")
                                        }
                                    })
                                    
                                    
                                }
                            })
                
                        } else {
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            
                        self.displayAlert("Could not confirm distance", message: "Please type in a distance willing to travel between 1-100, thank you!")
                        }
                    } else {
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                        self.displayAlert("Could not confirm distance", message: "Please confirm your location first, thank you!")
                    
                    }
                }
                
            } else {
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                self.displayAlert("Could not confirm distance", message: "\(error)")
            }
        }
    }
    }
    
    func displayEmailAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Enter Email"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let emailRequest = PFObject(className: "UserEmailStart")
            emailRequest["username"] = PFUser.currentUser()?.username
            emailRequest["email"] = textField.text
            emailRequest.saveInBackgroundWithBlock { (success, error) in
                
                if success {
                    
                    gotEmail = true
                    
                } else {
                    
                    gotEmail = false
                    
                }
            }
            
            
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
}



