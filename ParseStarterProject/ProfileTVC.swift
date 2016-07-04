//
//  ProfileTVC.swift
//  GoEat
//
//  Created by Evan on 5/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProfileTVC: PFQueryTableViewController {
    
    @IBOutlet weak var open: UIBarButtonItem!
    
    var webUrls = [String]()
    var fourUrls = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        
        self.navigationItem.title = PFUser.currentUser()?.username
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.149, green: 0.776, blue: 0.855, alpha: 1.00)
        
        tableView.estimatedRowHeight = 90
        
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        webUrls.removeAll()
        fourUrls.removeAll()
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "ProfileVC Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        /*let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.boolForKey("premiumUser") == false {
            
            self.displayUpgradeAlert("Must upgrade to premium to view your history!", message: "Enjoy awesome benefits such as keywords, your profile, UberRides coming soon, and much more!")
            
            self.tableView.hidden = true
        } else {
            
            self.tableView.hidden = false
        }*/
        
        
        
        
    }
    
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        
        parseClassName = "savedRests"
        pullToRefreshEnabled = true
        paginationEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        parseClassName = "savedRests"
        pullToRefreshEnabled = true
        paginationEnabled = true
    
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        
        if self.objects!.count == 0 {
            query.cachePolicy = .CacheThenNetwork
        }
        
        query.orderByDescending("createdAt")
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> ProfileCell? {
        
        
        let cellIdentifier = "cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ProfileCell
        
        if cell == nil {
            cell = ProfileCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if let object = object {
            
            cell?.restName.text = object["restName"] as? String
            cell?.restLocation.text = object["restLocation"] as? String
            cell?.restWebUrl = (object["restWebUrl"] as? String)!
            cell?.restFourUrl = object["fourUrl"] as! String
            
            
            webUrls.append((cell?.restWebUrl)!)
            fourUrls.append((cell?.restFourUrl)!)
            
            
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            let createdAt: NSDate = object.createdAt!
            cell?.restTime.text = dateFormatter.stringFromDate(createdAt)
            
            
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let url = webUrls[indexPath.row]
        let fourUrl = fourUrls[indexPath.row]
        
        if url != "" {
            
            if let NSUrl = NSURL(string: url) {
                UIApplication.sharedApplication().openURL(NSUrl)
            }
            
        } else if url == "" {
            if let NSurl = NSURL(string: fourUrl) {
                UIApplication.sharedApplication().openURL(NSurl)
            }
        }
        
        
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
    
    func displayBuyAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Buy!", style: .Default, handler: { (action) in
            
            PFPurchase.buyProduct("GoEatPremium248915248915", block: { (error) in
                if error != nil {
                    self.displayAlert("Could not process purchase:(", message: error.debugDescription)
                }
            })
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    

}
