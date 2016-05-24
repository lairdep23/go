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

class FoundRestVC: UIViewController {

    @IBOutlet weak var favRestLabel: UILabel!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        restaurant.downloadFoursquareRest { () -> () in
            
            if restaurant.couldntFind == false {
                
                self.updateUI()
                
            } else {
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                self.displayRestartAlert("Sorry, we could not find a restaurant:(", message: "Please restart and broaden your distance, price range, or keyword. Thank you!")
            }
            
            
        }
        
        
        
        let logo = UIImage(named: "logoSmall")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
    }
    
    func updateUI() {
        
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        if restaurant.couldntFind == false {
            
            let distanceDouble = Double(restaurant.distance) * 0.000621371
            let roundedDistance = Double(round(distanceDouble*10)/10)
            
            favRestLabel.text = "Your new favorite restaurant is only \(roundedDistance) miles away, so what are you waiting for and..."
            
        } else {
            
            restaurant.couldntFind = false 
            
            displayRestartAlert("Sorry, we could not find a restaurant:(", message: "Please restart and broaden your distance, price range, or keyword. Thank you!")
        }
        
    }

    @IBAction func getDirections(sender: AnyObject) {
        
        let address = "\(restaurant.address), \(restaurant.city), \(restaurant.state) \(restaurant.zip)"
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemark, error) in
            
            if (placemark?[0]) != nil {
                
                let mkPlace = MKPlacemark(placemark: placemark![0])
                
                let mapItem = MKMapItem(placemark: mkPlace)
                
                mapItem.name = "Your New Fav Restaurant"
                
                let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                
                mapItem.openInMapsWithLaunchOptions(launchOptions)
                
                self.performSegueWithIdentifier("arrivedSegue", sender: self)
                
            } else {
                self.displayRestartAlert("We are very sorry :(", message: "We could not find the address of this restaurant, please restart and try again!")
            }
        }
        
        
        
        
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
                
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        object.deleteInBackgroundWithBlock({ (success, error) in
                            
                            if success {
                                
                                hasMadeRestRequest = false
                                
                                USER_LAT = ""
                                USER_LONG = ""
                                USER_DISTANCE = ""
                                
                                self.activityIndicator.stopAnimating()
                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                
                                self.navigationController?.popToRootViewControllerAnimated(true)
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
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func displayRestartAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .Default, handler: { (action) in
            
            let query = PFQuery(className: "restRequest")
            query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
            query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) in
                
                if error == nil {
                    
                    if let objects = objects as [PFObject]! {
                        for object in objects {
                            object.deleteInBackgroundWithBlock({ (success, error) in
                                
                                if success {
                                    
                                    hasMadeRestRequest = false
                                    
                                    USER_LAT = ""
                                    USER_LONG = ""
                                    USER_DISTANCE = ""
                                    
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                }
                            })
                        }
                    }
                    
                } else {
                    
                    self.displayAlert("Could not restart", message: "\(error)")
                }
            }
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func callRest(sender: AnyObject) {
        
        displayCallAlert("We hope to have this feature soon!", message: "Until then here is their number. But remember, this ruins the suprise!")
        
        
    }
    
    func displayCallAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Call", style: .Default, handler: { (action) in
            
            if restaurant.phoneNumber != "" {
            
            let phone = "tel://\(restaurant.phoneNumber)"
            let url: NSURL = NSURL(string: phone)!
            print(url)
            UIApplication.sharedApplication().openURL(url)
                
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
                self.displayAlert("Could not find number", message: "We are sorry but we could not find this restaurants number :(")
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel , handler: { (action) in
            
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    

}
