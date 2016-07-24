//
//  BackTableVC.swift
//  GoEat
//
//  Created by Evan on 5/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class BackTableVC: UITableViewController {
    
    var tableArray = [String]()
    var willDeleteRequests = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
      tableArray = ["GoEat","Home","Profile","Upgrade to Premium","Share with Friends", "Privacy and Terms of Use", "Support", "Log Out"]
        
        tableView.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 1.00)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "SideMenu Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableArray[indexPath.row], forIndexPath: indexPath)

        
        
        if tableArray[indexPath.row] == "GoEat" {
            
            cell.imageView?.image = UIImage(named: "logoSmall")
            cell.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 1.00)
            
        } else {
            cell.textLabel?.text = tableArray[indexPath.row]
            cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 17.0)
            cell.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 1.00)
            cell.textLabel?.textColor = UIColor(red: 0.329, green: 0.431, blue: 0.478, alpha: 1.00)
        }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableArray[indexPath.row] == "Log Out" {
            
            self.displayLogOutAlert("Are You Sure?", message: "All requests will be canceled if you log out.")
            
        } else if tableArray[indexPath.row] == "Upgrade to Premium" {
            //self.displayUpgradeAlert("Upgrade to Premium!", message: "Enjoy awesome benefits such as keywords, your profile, and much more!")
            self.displayAlert("No Need to Upgrade!", message: "For a limited time GoEat and all it's features are absolutely FREE! Enjoy:)")
        }
    }
    
    func displayLogOutAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Log Out :(", style: .Default, handler: { (action) in
            
            print(PFUser.currentUser()?.username!)
            
            if action.enabled {
                
                do {
            
            let query = PFQuery(className: "restRequest")
            query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
            query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) in
                
                if error == nil {
                    
                    if objects!.count > 0 {
                        
                        if let objects = objects as [PFObject]! {
                            for object in objects {
                                  object.deleteInBackgroundWithBlock({ (success, error) in
                                    
                                    if success {
                                        
                                        PFUser.logOut()
                                        self.performSegueWithIdentifier("logOutSegue", sender: self)
                                    }
                                    
                                  })
                                
            
                                }
                            }
                    } else {
                        PFUser.logOut()
                        self.performSegueWithIdentifier("logOutSegue", sender: self)
                        
                    }
                    }
                    }
                } 
                
                
            
            }
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
            self.willDeleteRequests = false
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { (action) in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func displayBuyAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Buy!", style: .Default, handler: { (action) in
            
            dispatch_after(UInt64(0.2), dispatch_get_main_queue(), {
                
                PFPurchase.buyProduct("GoEatPremium248915248915", block: { (error: NSError?) in
                    if error == nil {
                        print("purchase worked")
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        print(error.debugDescription)
                        print(error)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
                
            })
            
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action:UIAlertAction) in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayUpgradeAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Upgrade!", style: .Default, handler: { (action) in
            
            self.displayBuyAlert("Confirm your In-App Purchase", message: "Do you want to buy one year of awesome GoEat Premium for $2.99?")
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
 

}
