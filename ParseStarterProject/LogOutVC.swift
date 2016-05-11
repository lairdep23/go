//
//  LogOutVC.swift
//  GoEat
//
//  Created by Evan on 5/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class LogOutVC: UIViewController {

    @IBOutlet weak var open: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        open.target = self.revealViewController()
        open.action = Selector("revealToggle:")
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backHomeButton(sender: AnyObject) {
        
        self.performSegueWithIdentifier("backHomeSegue", sender: self)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logOutSegue" {
            
            let query = PFQuery(className: "restRequest")
            query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
            query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) in
                
                if error == nil {
                    
                    if let objects = objects as? [PFObject]! {
                        for object in objects {
                            object.deleteInBackground()
                            PFUser.logOut()
                        }
                    }
                    
                } else {
                    
                    self.displayAlert("Could not log out", message: "\(error)")
                }
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
