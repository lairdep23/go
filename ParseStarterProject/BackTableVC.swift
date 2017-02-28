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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "SideMenu Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableArray[indexPath.row], for: indexPath)

        
        
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableArray[indexPath.row] == "Log Out" {
            
            self.displayLogOutAlert("Are You Sure?", message: "All requests will be canceled if you log out.")
            
        } else if tableArray[indexPath.row] == "Upgrade to Premium" {
            //self.displayUpgradeAlert("Upgrade to Premium!", message: "Enjoy awesome benefits such as keywords, your profile, and much more!")
            self.displayAlert("No Need to Upgrade!", message: "For a limited time GoEat and all it's features are absolutely FREE! Enjoy:)")
        }
    }
    
    func displayLogOutAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Log Out :(", style: .default, handler: { (action) in
            
            print(PFUser.current()?.username!)
            
            if action.isEnabled {
                
                do {
            
            let query = PFQuery(className: "restRequest")
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            query.findObjectsInBackground { (objects:[PFObject]?, error: NSError?) in
                
                if error == nil {
                    
                    if objects!.count > 0 {
                        
                        if let objects = objects as [PFObject]! {
                            for object in objects {
                                  object.deleteInBackground(block: { (success, error) in
                                    
                                    if success {
                                        
                                        PFUser.logOut()
                                        self.performSegue(withIdentifier: "logOutSegue", sender: self)
                                    }
                                    
                                  })
                                
            
                                }
                            }
                    } else {
                        PFUser.logOut()
                        self.performSegue(withIdentifier: "logOutSegue", sender: self)
                        
                    }
                    }
                    }
                } 
                
                
            
            }
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            self.willDeleteRequests = false
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func displayBuyAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Buy!", style: .default, handler: { (action) in
            
            DispatchQueue.main.asyncAfter(deadline: UInt64(0.2), execute: {
                
                PFPurchase.buyProduct("GoEatPremium248915248915", block: { (error: NSError?) in
                    if error == nil {
                        print("purchase worked")
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        print(error.debugDescription)
                        print(error)
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                
            })
            
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action:UIAlertAction) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayUpgradeAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Upgrade!", style: .default, handler: { (action) in
            
            self.displayBuyAlert("Confirm your In-App Purchase", message: "Do you want to buy one year of awesome GoEat Premium for $2.99?")
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
 

}
