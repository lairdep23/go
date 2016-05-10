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

class ViewController: UIViewController {
    
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
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
        
        if PFUser.currentUser() != nil {
            
            self.performSegueWithIdentifier("loginSegue", sender: self)
            
            print("already logged in")
        }
    }



    @IBAction func howItWorksButton(sender: AnyObject) {
    }










    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

   
}
