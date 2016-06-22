//
//  AfterVC.swift
//  GoEat
//
//  Created by Evan on 5/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Social
import Parse

class AfterVC: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
   
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())

        let logo = UIImage(named: "logoSmall")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        name.text = restaurant.name
        address.text = "\(restaurant.address), \(restaurant.city)"
        
        let savedRests = PFObject(className: "savedRests")
        savedRests["username"] = PFUser.currentUser()?.username
        savedRests["restName"] = restaurant.name
        savedRests["restLocation"] = "\(restaurant.address), \(restaurant.city), \(restaurant.state) \(restaurant.zip)"
        savedRests["restWebUrl"] = restaurant.websiteUrl
        savedRests["fourUrl"] = restaurant.fourUrl
        savedRests.saveInBackgroundWithBlock { (success, error) in
            
            if success {
                print("Saved restaurant successfully")
            } else {
                self.displayAlert("Could not save restaurant", message: "If you have premium, you will not be able to find this restaurant in your profile. We are sorry for the inconvience.")
            }
        }
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "AfterVC Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    @IBAction func exploreButton(sender: AnyObject) {
        
        if restaurant.websiteUrl != "" {
        
            if let url = NSURL(string: "\(restaurant.websiteUrl)") {
                UIApplication.sharedApplication().openURL(url)
            }
        } else if restaurant.websiteUrl == "" {
            
            if let fourUrl = NSURL(string: "\(restaurant.fourUrl)") {
                UIApplication.sharedApplication().openURL(fourUrl)
            }
        }
    }
    
    
    
    
    
    @IBAction func facebookPost(sender: AnyObject) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Share on Facebook")
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func twitterPost(sender: AnyObject) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Share on Twitter")
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }

    @IBAction func saveRestaurant(sender: AnyObject) {
        
        
    }
    
    @IBAction func goBackHome(sender: AnyObject) {
        
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
                
                self.displayAlert("Could not restart", message: "\(error)")
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
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
    
    
    
    
}
