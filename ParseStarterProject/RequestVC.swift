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
    
    @IBOutlet weak var RvsBSwitch: UISwitch!
    
    
    
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var onePressed = false
    var twoPressed = false
    var threePressed = false
    var fourPressed = false
    
    var priceRange = "1,2,3,4"
    var confirmedKeyword = ""
    var url = ""
    var confirmedState = ""
    
    
    
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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        upgradeView.isHidden = true
        upgradeLabel.isHidden = true 
        
        print(USER_DISTANCE)
        print(USER_LAT)
        print(USER_LONG)
        
        RvsBSwitch.isOn = false
        
        switchState = "Restaurant"
        
        RvsBSwitch.addTarget(self, action: #selector(RequestVC.switchIsChanged(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "RequestVC Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
        
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(true, moveValue: 100)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(false, moveValue: 100)
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
    
    @IBAction func oneButtonPressed(_ sender: AnyObject) {
        if onePressed == false {
            onePressed = true
            oneButton.backgroundColor = UIColor(red: 1.000, green: 0.718, blue: 0.302, alpha: 1.00)
            
        } else {
            onePressed = false
            oneButton.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 0.50)
        }
    }
    
    @IBAction func twoButtonPressed(_ sender: AnyObject) {
        
        if twoPressed == false {
            twoPressed = true
            twoButton.backgroundColor = UIColor(red: 1.000, green: 0.718, blue: 0.302, alpha: 1.00)
            
        } else {
            twoPressed = false
            twoButton.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 0.50)
        }
    }
    
    @IBAction func threeButtonPressed(_ sender: AnyObject) {
        if threePressed == false {
            threePressed = true
            threeButton.backgroundColor = UIColor(red: 1.000, green: 0.718, blue: 0.302, alpha: 1.00)
            
        } else {
            threePressed = false
            threeButton.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 0.50)
        }
    }
    
    @IBAction func fourButtonPressed(_ sender: AnyObject) {
        if fourPressed == false {
            fourPressed = true
            fourButton.backgroundColor = UIColor(red: 1.000, green: 0.718, blue: 0.302, alpha: 1.00)
            
        } else {
            fourPressed = false
            fourButton.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 0.50)
        }
    }
    
    @IBAction func confirmPnK(_ sender: AnyObject) {
        
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
            
            confirmedKeyword = spaceKeyword.replacingOccurrences(of: " ", with: "")
            
        }
        
        
        
        
    }
    
    @IBAction func findRestaurant(_ sender: AnyObject) {
        
        print(confirmedState)
        
        confirmedState = switchState
        
        if confirmedState == "Restaurant" {
        
            if keyword.text != "" {
            
                url = URL_BASE + "&ll=\(USER_LAT),\(USER_LONG)" + "&radius=\(USER_DISTANCE)" + "&price=\(priceRange)" + "&query=\(confirmedKeyword)"
            } else {
                url = URL_BASE + "&ll=\(USER_LAT),\(USER_LONG)" + "&radius=\(USER_DISTANCE)" + "&price=\(priceRange)" + "&query=restaurant"
            }
        } else {
            
                url = URL_BASE + "&section=drinks" + "&ll=\(USER_LAT),\(USER_LONG)" + "&radius=\(USER_DISTANCE)" + "&price=\(priceRange)"
        }
        
        
        restaurant = Restaurant(url: url)
        
        print(restaurant.url)
        
        performSegue(withIdentifier: "foundRestSegue", sender: self)
        
        
        
    }
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func switchIsChanged(_ RvsBSwitch: UISwitch){
        if RvsBSwitch.isOn {
            switchState = "Bar"
        } else {
            switchState = "Restaurant"
        }
    }



}
