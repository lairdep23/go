//
//  FoundRestVC.swift
//  GoEat
//
//  Created by Evan on 5/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit
import UberRides

class FoundRestVC: UIViewController {

    @IBOutlet weak var favRestLabel: UILabel!
    
    @IBOutlet weak var restaurantFoundLabel: UILabel!
    
    @IBOutlet weak var suggestionLabel: UILabel!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var dropOff_Lat = CLLocationCoordinate2D().latitude
    var dropOff_Long = CLLocationCoordinate2D().longitude
    
    var uiUpdated = false
    
    lazy var rideRequestButton = RideRequestButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()

        restaurant.downloadFoursquareRest { () -> () in
            
            if restaurant.couldntFind == false {
                
                if switchState == "Restaurant"{
                
                    self.restaurantFoundLabel.text = "Restaurant Found!"
                    self.suggestionLabel.text = "Your restaurant suggestion is..."
                
                } else {
                    self.restaurantFoundLabel.text = "Bar Found!"
                    self.suggestionLabel.text = "Your bar suggestion is..."
                }
                
                self.updateUI()
                
                let address = "\(restaurant.address), \(restaurant.city), \(restaurant.state) \(restaurant.zip)"
                
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address){(placemarks, error) in
                    if let placemark = placemarks![0] as? CLPlacemark {
                        
                        let location = placemark.location
                        self.dropOff_Lat = (location?.coordinate.latitude)!
                        self.dropOff_Long = (location?.coordinate.longitude)!
                        
                        self.uiUpdated = true
                        
                        self.rideRequestButton.rideParameters = self.buildRideParameters()
                        self.rideRequestButton.requestBehavior = self.buildRequestBehavior()
                        
                        self.view.addSubview(self.rideRequestButton)
                        timesLoaded += 1
                        self.addRequestButtonConstraint()
                        self.rideRequestButton.colorStyle = .white
                        
                        
                    } else {
                        print("Couldn't convert to CLLocation")
                        
                        self.uiUpdated = false
                    }
                    
                }
                
                
                
            } else {
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if switchState == "Restaurant" {
                    self.displayRestartAlert("Sorry, we could not find a restaurant:(", message: "Please restart and broaden your distance, price range, or keyword. Thank you!")
                    self.restaurantFoundLabel.text = "Restaurant Not Found:("
                    
                } else {
                    
                    self.displayRestartAlert("Sorry, we could not find a bar:(", message: "Please restart and broaden your distance, price range, or keyword. Thank you!")
                    self.restaurantFoundLabel.text = "Bar Not Found:("
                    
                }
            }
            
            
        }
        
        
        
        let logo = UIImage(named: "logoSmall")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "FoundRestVC Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
        
        if timesLoaded >= 2 {
            displayArrivedAlert("Would you like to reveal your destination?", message: "If you have arrived or are close to arriving, press Yes to reveal.")
        }
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "premiumUser") {
           // upgradeLabel.hidden = true
           // upgradeView.hidden = true
            
        } else {
           // upgradeLabel.hidden = false
           // upgradeLabel.hidden = false
        }
        
        
    }
    
    func updateUI() {
        
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        if restaurant.couldntFind == false {
            
            let distanceDouble = Double(restaurant.distance) * 0.000621371
            let roundedDistance = Double(round(distanceDouble*10)/10)
            
            if switchState == "Restaurant" {
            
                favRestLabel.text = "Your new favorite restaurant is only \(roundedDistance) miles away, so what are you waiting for and..."
            } else {
                
                favRestLabel.text = "Your new favorite bar is only \(roundedDistance) miles away, so what are you waiting for and..."
            }
            
        } else {
            
            self.uiUpdated = false
            
            restaurant.couldntFind = false
            
            if switchState == "Restaurant" {
            
                displayRestartAlert("Sorry, we could not find a restaurant :(", message: "Please restart and broaden your distance, price range, or keyword. Thank you!")
            } else {
                
                displayRestartAlert("Sorry, we could not find a bar :(", message: "Please restart and broaden your distance, price range, or keyword. Thank you!")
                
            }
        }
        
    }
    
    func buildRideParameters() -> RideParameters {
        
        let address = "\(restaurant.address), \(restaurant.city), \(restaurant.state) \(restaurant.zip)"
        
        let builder = RideParametersBuilder()
        
        let pickupLocation = CLLocation(latitude: Double(USER_LAT)!, longitude: Double(USER_LONG)!)
        builder.setPickupLocation(pickupLocation)
        let dropoffLocation = CLLocation(latitude: self.dropOff_Lat, longitude: self.dropOff_Long)
        print(self.dropOff_Lat)
        print(self.dropOff_Long)
        builder.setDropoffLocation(dropoffLocation, nickname: "New Favorite Restaurant", address: address)
        
        return builder.build()
        
    }
    
    func buildRequestBehavior() -> RideRequesting {
        let requestBehavior = RideRequestViewRequestingBehavior(presentingViewController: self)
        
        return requestBehavior
    }
    
    func addRequestButtonConstraint() {
        
        rideRequestButton.translatesAutoresizingMaskIntoConstraints = false
        
        let CenterX = NSLayoutConstraint(item: rideRequestButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: rideRequestButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -20.0)
        let width = NSLayoutConstraint(item: rideRequestButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: -30.0)
        view.addConstraints([CenterX, bottom, width])
    
    }
    
  /*  func addUberButton() {
        
        if  restaurant.couldntFind == false {
        
        let address = "\(restaurant.address), \(restaurant.city), \(restaurant.state) \(restaurant.zip)"
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address){(placemarks, error) in
            if let placemark = placemarks![0] as? CLPlacemark {
                
                let location = placemark.location
                self.dropOff_Lat = (location?.coordinate.latitude)!
                self.dropOff_Long = (location?.coordinate.longitude)!
                
                self.uiUpdated = true
                
            } else {
                print("Couldn't convert to CLLocation")
                
                self.uiUpdated = false
            }
            
        }
            
            let behavior = RideRequestViewRequestingBehavior(presentingViewController: self)
            let builder = RideParametersBuilder()
            let pickupLocation = CLLocation(latitude: Double(USER_LAT)!, longitude: Double(USER_LONG)!)
            let dropoffLocation = CLLocation(latitude: self.dropOff_Lat, longitude: self.dropOff_Long)
            builder.setPickupLocation(pickupLocation).setDropoffLocation(dropoffLocation, nickname: "New Favorite Restaurant", address: address)
            let rideParameters = builder.build()
            let button = RideRequestButton(rideParameters: rideParameters, requestingBehavior: behavior)
            button.colorStyle = .White
            
            self.uberView.addSubview(button)
            self.uberView.bringSubviewToFront(button)
            
            
            button.center.x = uberView.center.x
            
        }
    }*/

    @IBAction func getDirections(_ sender: AnyObject) {
        
        let address = "\(restaurant.address), \(restaurant.city), \(restaurant.state) \(restaurant.zip)"
        
        let geoCoder = CLGeocoder()
        
        if switchState == "Bar" {
            
            let alertController = UIAlertController(title: "Please don't drink and drive!" , message: "", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                
                geoCoder.geocodeAddressString(address) { (placemark, error) in
                    
                    if (placemark?[0]) != nil {
                        
                        let mkPlace = MKPlacemark(placemark: placemark![0])
                        
                        let mapItem = MKMapItem(placemark: mkPlace)
                        
                        if switchState == "Restaurant" {
                            
                            mapItem.name = "Your New Fav Restaurant"
                            
                            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                            
                            mapItem.openInMaps(launchOptions: launchOptions)
                            
                            if mapItem.openInMaps(launchOptions: launchOptions) == false {
                                
                                self.displayArrivedAlert("Would you like to reveal your destination?", message: "If you have arrived or are close to arriving, press Yes to reveal the restaurant.")
                            }
                            
                        } else {
                            
                            mapItem.name = "Your New Fav Bar"
                            
                            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                            
                            mapItem.openInMaps(launchOptions: launchOptions)
                            
                            if mapItem.openInMaps(launchOptions: launchOptions) == false {
                                
                                self.displayArrivedAlert("Would you like to reveal your destination?", message: "If you have arrived or are close to arriving, press Yes to reveal the bar.")
                            }
                            /*let push = PFPush()
                             push.setChannel("GoEat")
                             push.setMessage("Once you've arrived just hop back on to GoEat using the top left corner to reveal your surprise restaurant!")
                             push.sendPushInBackground()*/
                            
                            
                        }
                        
                        
                    } else {
                        self.displayRestartAlert("We are very sorry :(", message: "We could not find the address of this venue, please restart and try again!")
                    }
                }
                
                
            }))
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
        
        geoCoder.geocodeAddressString(address) { (placemark, error) in
            
            if (placemark?[0]) != nil {
                
                let mkPlace = MKPlacemark(placemark: placemark![0])
                
                let mapItem = MKMapItem(placemark: mkPlace)
                
                if switchState == "Restaurant" {
                
                    mapItem.name = "Your New Fav Restaurant"
                
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                
                    mapItem.openInMaps(launchOptions: launchOptions)
                    
                    if mapItem.openInMaps(launchOptions: launchOptions) == false {
                        
                        self.displayArrivedAlert("Would you like to reveal your destination?", message: "If you have arrived or are close to arriving, press Yes to reveal the restaurant.")
                    }
                
                } else {
                    
                    mapItem.name = "Your New Fav Bar"
                    
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    
                    mapItem.openInMaps(launchOptions: launchOptions)
                    
                    if mapItem.openInMaps(launchOptions: launchOptions) == false {
                        
                        self.displayArrivedAlert("Would you like to reveal your destination?", message: "If you have arrived or are close to arriving, press Yes to reveal the bar.")
                    }
                /*let push = PFPush()
                push.setChannel("GoEat")
                push.setMessage("Once you've arrived just hop back on to GoEat using the top left corner to reveal your surprise restaurant!")
                push.sendPushInBackground()*/
                
                
                }
                
                
            } else {
                self.displayRestartAlert("We are very sorry :(", message: "We could not find the address of this venue, please restart and try again!")
            }
        }
        }
        
        
        
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
                
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        object.deleteInBackground(block: { (success, error) in
                            
                            if success {
                                
                                hasMadeRestRequest = false
                                
                                USER_LAT = ""
                                USER_LONG = ""
                                USER_DISTANCE = ""
                                
                                self.activityIndicator.stopAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                                
                                self.navigationController?.popToRootViewController(animated: true)
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
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func displayRestartAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { (action) in
            
            let query = PFQuery(className: "restRequest")
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            query.findObjectsInBackground { (objects:[PFObject]?, error: NSError?) in
                
                if error == nil {
                    
                    if let objects = objects as [PFObject]! {
                        for object in objects {
                            object.deleteInBackground(block: { (success, error) in
                                
                                if success {
                                    
                                    hasMadeRestRequest = false
                                    
                                    USER_LAT = ""
                                    USER_LONG = ""
                                    USER_DISTANCE = ""
                                    
                                    self.navigationController?.popToRootViewController(animated: true)
                                }
                            })
                        }
                    }
                    
                } else {
                    
                    self.displayAlert("Could not restart", message: "\(error)")
                }
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func callRest(_ sender: AnyObject) {
        
        displayCallAlert("We hope to have this feature soon!", message: "Until then here is their number. But remember, this ruins the suprise!")
        
        
    }
    
    func displayCallAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
            
            if restaurant.phoneNumber != "" {
            
            let phone = "tel://\(restaurant.phoneNumber)"
            let url: URL = URL(string: phone)!
            print(url)
            UIApplication.shared.openURL(url)
                
            } else {
                self.dismiss(animated: true, completion: nil)
                self.displayAlert("Could not find number", message: "We are sorry but we could not find this destination's number :(")
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: { (action) in
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func displayArrivedAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes!", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "arrivedSegue", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    

}
