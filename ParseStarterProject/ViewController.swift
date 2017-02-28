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
import UberRides

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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        howItWorksView.isHidden = true
        
    }

    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func signUpButton(_ sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            displayAlert("Sign Up Failed", message: "Please enter a username and password")
            
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again later."
                
                let user = PFUser()
                user.username = username.text
                user.password = password.text
                
                
                
                user.signUpInBackground(block: { (success, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if error == nil {
                        
                        self.performSegue(withIdentifier: "loginSegue", sender: self)
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
    
    @IBAction func logInButton(_ sender: AnyObject) {
        
        var errorMessage = "Please try again later."
        
        PFUser.logInWithUsername(inBackground: username.text!, password: password.text! , block: { (user, error) in
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if user != nil {
                
               self.performSegue(withIdentifier: "loginSegue", sender: self)
                print("logged in")
                
            } else {
                
                if let errorString = error!.userInfo["error"] as? String {
                    
                    errorMessage = errorString
                    
                }
                self.displayAlert("Failed Login", message: errorMessage)
            }
        })


    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        howItWorksView.isHidden = true
        
        if PFUser.current()?.username != nil {
            
            self.performSegue(withIdentifier: "loginSegue", sender: self)
            
           // print("already logged in")
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Login Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
    }



    @IBAction func howItWorksButton(_ sender: AnyObject) {
        
        howItWorksView.isHidden = false
        
        howItWorksLabel.text = "Sign up with a username and password, no email required!"
        nextBut.title = "Next"
        backBut.title = ""
        
    }
    
    
    @IBAction func nextButton(_ sender: AnyObject) {
        
        if howItWorksLabel.text == "Sign up with a username and password, no email required!" {
            backBut.title = "Back"
            howItWorksLabel.text = "Confirm your location and set your distance willing to travel to the restaurant."
        } else if howItWorksLabel.text == "Confirm your location and set your distance willing to travel to the restaurant." {
            howItWorksLabel.text = "Set your price range and keyword and we'll find you a top rated restaurant using Foursquare."
        } else if howItWorksLabel.text == "Set your price range and keyword and we'll find you a top rated restaurant using Foursquare." {
            howItWorksLabel.text = "We'll then give you directions or call you an Uber so you can be on your way to possibly your new favorite restaurant!"
        } else if howItWorksLabel.text == "We'll then give you directions or call you an Uber so you can be on your way to possibly your new favorite restaurant!" {
            nextBut.title = ""
            howItWorksLabel.text = "The catch? \n \n The restaurant isn't revealed until you arrive!"
        }
        
    }
    
    
    @IBAction func backButton(_ sender: AnyObject) {
        
        if howItWorksLabel.text == "Confirm your location and set your distance willing to travel to the restaurant." {
            
            howItWorksLabel.text = "Sign up with a username and password, no email required!"
            backBut.title = ""
            nextBut.title = "Next"
            
        } else if howItWorksLabel.text == "Set your price range and keyword and we'll find you a top rated restaurant using Foursquare." {
            
            howItWorksLabel.text = "Confirm your location and set your distance willing to travel to the restaurant."
            
        } else if howItWorksLabel.text == "We'll then give you directions or call you an Uber so you can be on your way to possibly your new favorite restaurant!" {
            
            howItWorksLabel.text = "Set your price range and keyword and we'll find you a top rated restaurant using Foursquare."
            
        } else if howItWorksLabel.text == "The catch? \n \n The restaurant isn't revealed until you arrive!" {
            
            howItWorksLabel.text = "We'll then give you directions or call you an Uber so you can be on your way to possibly your new favorite restaurant!"
        }
        
        
    }
    
    
    @IBAction func exitButton(_ sender: AnyObject) {
        howItWorksView.isHidden = true
    }
    


    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }




   
}
