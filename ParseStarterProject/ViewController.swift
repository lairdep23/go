/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

//parse-dashboard --appId goeatapp15 --masterKey 152489152489 --serverURL "http://goeatapp15.herokuapp.com/parse" --appName goeatapp15

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var howItWorksView: MaterialView!
    
    @IBOutlet weak var howItWorksLabel: UILabel!
    
    @IBOutlet weak var nextBut: UIBarButtonItem!
    
    @IBOutlet weak var backBut: UIBarButtonItem!
    
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.delegate = self
        password.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        howItWorksView.hidden = true
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func signUpButton(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            displayAlert("Sign Up Failed", message: "Please enter a username and password")
            
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again later."
                
                let user = PFUser()
                user.username = username.text
                user.password = password.text
                
                
                
                user.signUpInBackgroundWithBlock({ (success, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil {
                        
                        self.performSegueWithIdentifier("loginSegue", sender: self)
                        print("signed up")
                        
                    } else {
                        
                        if let errorString = error!.userInfo["error"] as? String {
                            
                            errorMessage = errorString
                            
                        }
                        self.displayAlert("Failed Sign Up", message: errorMessage)
                    }
                })
            }

    }
    
    @IBAction func logInButton(sender: AnyObject) {
        
        var errorMessage = "Please try again later."
        
        PFUser.logInWithUsernameInBackground(username.text!, password: password.text! , block: { (user, error) in
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if user != nil {
                
               self.performSegueWithIdentifier("loginSegue", sender: self)
                print("logged in")
                
            } else {
                
                if let errorString = error!.userInfo["error"] as? String {
                    
                    errorMessage = errorString
                    
                }
                self.displayAlert("Failed Login", message: errorMessage)
            }
        })


    }
    
    override func viewDidAppear(animated: Bool) {
        
        howItWorksView.hidden = true
        
        if PFUser.currentUser()?.username != nil {
            
            self.performSegueWithIdentifier("loginSegue", sender: self)
            
           // print("already logged in")
        }
    }



    @IBAction func howItWorksButton(sender: AnyObject) {
        
        howItWorksView.hidden = false
        
        howItWorksLabel.text = "Sign up with a username and password, no email required!"
        nextBut.title = "Next"
        backBut.title = ""
        
    }
    
    
    @IBAction func nextButton(sender: AnyObject) {
        
        if howItWorksLabel.text == "Sign up with a username and password, no email required!" {
            backBut.title = "Back"
            howItWorksLabel.text = "Confirm your location and set your distance willing to travel to the restaurant."
        } else if howItWorksLabel.text == "Confirm your location and set your distance willing to travel to the restaurant." {
            howItWorksLabel.text = "Set your price range and keyword and we'll find you a top rated restaurant using Foursquare."
        } else if howItWorksLabel.text == "Set your price range and keyword and we'll find you a top rated restaurant using Foursquare." {
            howItWorksLabel.text = "We'll then give you directions so you can be on your way to possibly your new favorite restaurant!"
        } else if howItWorksLabel.text == "We'll then give you directions so you can be on your way to possibly your new favorite restaurant!" {
            nextBut.title = ""
            howItWorksLabel.text = "The catch? \n \n The restaurant isn't revealed until you arrive!"
        }
        
    }
    
    
    @IBAction func backButton(sender: AnyObject) {
        
        if howItWorksLabel.text == "Confirm your location and set your distance willing to travel to the restaurant." {
            
            howItWorksLabel.text = "Sign up with a username and password, no email required!"
            backBut.title = ""
            nextBut.title = "Next"
            
        } else if howItWorksLabel.text == "Set your price range and keyword and we'll find you a top rated restaurant using Foursquare." {
            
            howItWorksLabel.text = "Confirm your location and set your distance willing to travel to the restaurant."
            
        } else if howItWorksLabel.text == "We'll then give you directions so you can be on your way to possibly your new favorite restaurant!" {
            
            howItWorksLabel.text = "Set your price range and keyword and we'll find you a top rated restaurant using Foursquare."
            
        } else if howItWorksLabel.text == "The catch? \n \n The restaurant isn't revealed until you arrive!" {
            
            howItWorksLabel.text = "We'll then give you directions so you can be on your way to possibly your new favorite restaurant!"
        }
        
        
    }
    
    
    @IBAction func exitButton(sender: AnyObject) {
        howItWorksView.hidden = true
    }
    


    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }




   
}
