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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        open.target = self.revealViewController()
        open.action = Selector("revealToggle:")
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        
        self.navigationItem.title = PFUser.currentUser()?.username
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.149, green: 0.776, blue: 0.855, alpha: 1.00)
        
        tableView.estimatedRowHeight = 90
        
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        webUrls.removeAll()
        
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
            
            webUrls.append((cell?.restWebUrl)!)
            
            
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            let createdAt: NSDate = object.createdAt!
            cell?.restTime.text = dateFormatter.stringFromDate(createdAt)
            
            
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let url = webUrls[indexPath.row]
        
        if url != "" {
            
            if let NSUrl = NSURL(string: url) {
                UIApplication.sharedApplication().openURL(NSUrl)
            }
            
        }
        
        
    }
    
    

    

}
