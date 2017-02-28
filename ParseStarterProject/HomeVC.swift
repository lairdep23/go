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
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore {
            print("Not First Launch")
        } else {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            displayEmailAlert("Thank you for downloading GoEat!", message: "Enter your email to recieve a personal thank you letter from the founder, Evan!")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "HomeVC Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(true, moveValue: 130)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(false, moveValue: 130)
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let aSet = CharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        
        lat = location.latitude
        long = location.longitude
        
        map.showsUserLocation = true
        let center = CLLocationCoordinate2D(latitude: location.latitude , longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01))
        
        map.setRegion(region, animated: true)
        
        
    }


    @IBAction func confirmLocation(_ sender: AnyObject) {
        print("\(lat)\(long)")
        print(PFUser.current()?.username)
        
        let restRequest = PFObject(className: "restRequest")
        restRequest["username"] = PFUser.current()?.username
        restRequest["userLocation"] = PFGeoPoint(latitude: lat, longitude: long)
        restRequest.saveInBackground { (success, error) in
            
            if success {
                
                USER_LAT = "\(self.lat)"
                USER_LONG = "\(self.long)"
                
                self.confirmedLocation = true
                hasMadeRestRequest = true
                
                self.confirmLocAlert("Location Confirmed!", message: "")
                
            } else {
                
                self.displayAlert("Could not confirm location", message: "Please check and make sure location services for this app are turned on, thank you!")
                
            }
        }
    }
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func restartButton(_ sender: AnyObject) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    
        
        let query = PFQuery(className: "restRequest")
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        query.findObjectsInBackground { (objects:[PFObject]?, error: NSError?) in
            
            if error == nil {
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        object.deleteInBackground(block: { (success, error) in
                          
                            if success {
                                
                                self.activityIndicator.stopAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                                
                                self.confirmedLocation = false
                                hasMadeRestRequest = false
                                
                                USER_LAT = ""
                                USER_LONG = ""
                                USER_DISTANCE = ""
                                
                            } else {
                                self.activityIndicator.stopAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                            
                        })
                        
                    }
                }
                
            } else {
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                self.displayAlert("Could not restart", message: "\(error)")
            }
        }
    }
    
    @IBAction func confirmDistance(_ sender: AnyObject) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        let query = PFQuery(className: "restRequest")
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        query.findObjectsInBackground { (objects:[PFObject]?, error: NSError?) in
            
            if error == nil {
                
                if let objects = objects as [PFObject]! {
                    
                    for object in objects {
                
                    if self.confirmedLocation == true {
                    
                        if self.distanceTextField.text != "" {
                            
                            let confirmedDistanceMeters = Double(self.distanceTextField.text!)! * 1609
                            
                            let query = PFQuery(className: "restRequest")
                            query.getObjectInBackground(withId: object.objectId!, block: { (object: PFObject?, error: NSError?) in
                                
                                if error != nil {
                                    print(error)
                                } else if let object = object {
                                    
                                    object["userDistance"] = "\(confirmedDistanceMeters)"
                                    object.saveInBackground(block: { (success, error) in
                                        
                                        self.activityIndicator.stopAnimating()
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                        
                                        if error == nil {
                                            self.performSegue(withIdentifier: "homeToRequestSegue", sender: nil)
                                            USER_DISTANCE = "\(confirmedDistanceMeters)"
                                        } else {
                                           
                                            self.displayAlert("Could not confirm distance", message: "Please try again in a little bit, thank you!")
                                        }
                                    })
                                    
                                    
                                }
                            })
                
                        } else {
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                        self.displayAlert("Could not confirm distance", message: "Please type in a distance willing to travel between 1-100, thank you!")
                        }
                    } else {
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    
                        self.displayAlert("Could not confirm distance", message: "Please confirm your location first, thank you!")
                    
                    }
                }
                
            } else {
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                
                self.displayAlert("Could not confirm distance", message: "\(error)")
            }
        }
    }
    }
    
    func displayEmailAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Enter Email"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let emailRequest = PFObject(className: "UserEmailStart")
            emailRequest["username"] = PFUser.current()?.username
            emailRequest["email"] = textField.text
            emailRequest.saveInBackground { (success, error) in
                
                if success {
                    
                    gotEmail = true
                    
                } else {
                    
                    gotEmail = false
                    
                }
            }
            
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func confirmLocAlert(_ title: String, message: String) -> Void{
        
        let alertController = UIAlertController(title: title , message: message, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        
        
        
    }
    
}



