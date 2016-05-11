//
//  BackTableVC.swift
//  GoEat
//
//  Created by Evan on 5/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class BackTableVC: UITableViewController {
    
    var tableArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
      tableArray = ["GoEat","Home","Profile","Upgrade to Premium","Share with Friends", "Privacy and Terms of Use", "Support", "Log Out"]
        
        tableView.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 1.00)

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

        cell.textLabel?.text = tableArray[indexPath.row]
        
        if tableArray[indexPath.row] == "GoEat" {
            cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 25.0)
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.textColor = UIColor(red: 0.149, green: 0.776, blue: 0.855, alpha: 1.00)
            cell.backgroundColor = UIColor(red: 1.00, green: 0.718, blue: 0.302, alpha: 1.00)
            
        } else {
            cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 17.0)
            cell.backgroundColor = UIColor(red: 1.00, green: 0.800, blue: 0.502, alpha: 1.00)
            cell.textLabel?.textColor = UIColor(red: 0.329, green: 0.431, blue: 0.478, alpha: 1.00)
        }
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
