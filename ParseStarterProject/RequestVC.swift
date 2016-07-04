//
//  RequestVC.swift
//  GoEat
//
//  Created by Evan on 5/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse



class RequestVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var oneButton: UIButton!
    
    @IBOutlet weak var twoButton: UIButton!
    
    @IBOutlet weak var threeButton: UIButton!
    
    @IBOutlet weak var fourButton: UIButton!
    
    @IBOutlet weak var keyword: UITextField!
    
    @IBOutlet weak var upgradeLabel: UILabel!
    
    @IBOutlet weak var upgradeView: MaterialView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var onePressed = false
    var twoPressed = false
    var threePressed = false
    var fourPressed = false
    
    var priceRange = "1,2,3,4"
    var confirmedKeyword = ""
    var url = ""
    
    
    
    var nonSelectedColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 0.50)
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let logo = UIImage(named: "logoSmall")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
        
        keyword.delegate = self
        
        oneButton.backgroundColor = nonSelectedColor
        twoButton.backgroundColor = nonSelectedColor
        threeButton.backgroundColor = nonSelectedColor
        fourButton.backgroundColor = nonSelectedColor
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 1.000, green: 0.718, blue: 0.302, alpha: 1.00)
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        upgradeView.hidden = true
        upgradeLabel.hidden = true 
        
        print(USER_DISTANCE)
        print(USER_LAT)
        print(USER_LONG)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "RequestVC Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
        //let userDefaults = NSUserDefaults.standardUserDefaults()
        
       /* if userDefaults.boolForKey("premiumUser") {
            
            upgradeView.hidden = true
            upgradeLabel.hidden = true 
            
        } else {
            upgradeView.hidden = false
            upgradeLabel.hidden = false 
        }*/
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
    
    @IBAction func oneButtonPressed(sender: AnyObject) {
        if onePressed == false {
            onePressed = true
            oneButton.backgroundColor = UIColor(red: 1.000, green: 0.718, blue: 0.302, alpha: 1.00)
            
        } else {
            onePressed = false
            oneButton.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 0.50)
        }
    }
    
    @IBAction func twoButtonPressed(sender: AnyObject) {
        
        if twoPressed == false {
            twoPressed = true
            twoButton.backgroundColor = UIColor(red: 1.000, green: 0.718, blue: 0.302, alpha: 1.00)
            
        } else {
            twoPressed = false
            twoButton.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 0.50)
        }
    }
    
    @IBAction func threeButtonPressed(sender: AnyObject) {
        if threePressed == false {
            threePressed = true
            threeButton.backgroundColor = UIColor(red: 1.000, green: 0.718, blue: 0.302, alpha: 1.00)
            
        } else {
            threePressed = false
            threeButton.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 0.50)
        }
    }
    
    @IBAction func fourButtonPressed(sender: AnyObject) {
        if fourPressed == false {
            fourPressed = true
            fourButton.backgroundColor = UIColor(red: 1.000, green: 0.718, blue: 0.302, alpha: 1.00)
            
        } else {
            fourPressed = false
            fourButton.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 0.50)
        }
    }
    
    @IBAction func confirmPnK(sender: AnyObject) {
        
        //ConfirmPrice
        
        if onePressed == true {
            
            if twoPressed == true && threePressed == false && fourPressed == false {
                priceRange = "1,2"
            } else if twoPressed == false && threePressed == true && fourPressed == false {
                priceRange = "1,3"
            } else if twoPressed == false && threePressed == false && fourPressed == true {
                priceRange = "1,4"
            } else if twoPressed == true && threePressed == true && fourPressed == false {
                priceRange = "1,2,3"
            } else if twoPressed == true && threePressed == false && fourPressed == true {
                priceRange = "1,2,4"
            } else if twoPressed == false && threePressed == true && fourPressed == true {
                priceRange = "1,3,4"
            } else if twoPressed == true && threePressed == true && fourPressed == true {
                priceRange = "1,2,3,4"
            } else {
                priceRange = "1"
            }
            
        } else if twoPressed == true {
            
            if threePressed == true && fourPressed == false {
                priceRange = "2,3"
                } else if threePressed == false && fourPressed == true {
                priceRange = "2,4"
                } else if threePressed == true && fourPressed == true {
                priceRange = "2,3,4"
                } else {
                priceRange = "2"
                }
            
        } else if threePressed == true {
            
            if fourPressed == true {
                priceRange = "3,4"
                } else {
                priceRange = "3"
                }
            
        } else if fourPressed == true {
            
            priceRange = "4"
            
        } else {
            
            priceRange = "1,2,3,4"
        }
        
        print(priceRange)
        
        //confirm Keyword
        
        if keyword.text != "" {
            
            let spaceKeyword = keyword.text!
            
            confirmedKeyword = spaceKeyword.stringByReplacingOccurrencesOfString(" ", withString: "")
            
        }
        
        
    }
    
    @IBAction func findRestaurant(sender: AnyObject) {
        
        if keyword.text != "" {
            
            url = URL_BASE + "&ll=\(USER_LAT),\(USER_LONG)" + "&radius=\(USER_DISTANCE)" + "&price=\(priceRange)" + "&query=\(confirmedKeyword)"
        } else {
            url = URL_BASE + "&section=food" + "&ll=\(USER_LAT),\(USER_LONG)" + "&radius=\(USER_DISTANCE)" + "&price=\(priceRange)" + "&query=restaurant"
        }
        
        restaurant = Restaurant(url: url)
        
        print(restaurant.url)
        
        performSegueWithIdentifier("foundRestSegue", sender: self)
        
        
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }


}
