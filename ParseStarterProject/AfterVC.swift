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

class AfterVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var enterEmail: UITextField!
   
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())

        let logo = UIImage(named: "logoSmall")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
        
        enterEmail.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        name.text = restaurant.name
        address.text = "\(restaurant.address), \(restaurant.city)"
        
        let savedRests = PFObject(className: "savedRests")
        savedRests["username"] = PFUser.current()?.username
        savedRests["restName"] = restaurant.name
        savedRests["restLocation"] = "\(restaurant.address), \(restaurant.city), \(restaurant.state) \(restaurant.zip)"
        savedRests["restWebUrl"] = restaurant.websiteUrl
        savedRests["fourUrl"] = restaurant.fourUrl
        savedRests.saveInBackground { (success, error) in
            
            if success {
                print("Saved restaurant successfully")
            } else {
                self.displayAlert("Could not save restaurant", message: "If you have premium, you will not be able to find this restaurant in your profile. We are sorry for the inconvience.")
            }
        }
        
        
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(true, moveValue: 195)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(false, moveValue: 195)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "AfterVC Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
    }
    
    
    @IBAction func exploreButton(_ sender: AnyObject) {
        
        if restaurant.websiteUrl != "" {
        
            if let url = URL(string: "\(restaurant.websiteUrl)") {
                UIApplication.shared.openURL(url)
                URLResourceKey.isExcludedFromBackupKey
            }
        } else if restaurant.websiteUrl == "" {
            
            if let fourUrl = URL(string: "\(restaurant.fourUrl)") {
                UIApplication.shared.openURL(fourUrl)
                URLResourceKey.isExcludedFromBackupKey
            }
        }
    }
    
    
    
    
    
    @IBAction func facebookPost(_ sender: AnyObject) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Share on Facebook")
            self.present(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func twitterPost(_ sender: AnyObject) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Had an awesome meal with @GoEatiOSApp Eveyone check it out! GoEatiOSApp.com #GoEat")
            self.present(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }

    @IBAction func saveRestaurant(_ sender: AnyObject) {
        
        
    }
    
    @IBAction func goBackHome(_ sender: AnyObject) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        if enterEmail.text != "" {
            
            let emailRequest = PFObject(className: "UserEmail")
            emailRequest["username"] = PFUser.current()?.username
            emailRequest["email"] = self.enterEmail.text
            emailRequest.saveInBackground { (success, error) in
                
                if success {
                    
                    gotEmail = true
                    
                } else {
                    
                    gotEmail = false
                    
                }
            }
            
            
            
        }
        
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
                                timesLoaded = 1
                                
                                self.activityIndicator.stopAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                                
                                self.displayRateAlert("Did you have a good time??", message: "If so, please rate our app! We would really appreciate it!")
                                
                                self.navigationController?.popToRootViewController(animated: true)
                            } else {
                                self.activityIndicator.stopAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                        })
                    }
                }
                
            } else {
                
                self.displayAlert("Could not restart", message: "\(error)")
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
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
    
    func displayRateAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Not Now:(", style: .cancel, handler: { (action) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Rate GoEat", style: .default, handler: { (action) in
            
            UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/app/id1129022364")!)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
}
