//
//  SupportVC.swift
//  GoEat
//
//  Created by Evan on 5/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MessageUI

class SupportVC: UIViewController, MFMailComposeViewControllerDelegate {

    
    @IBOutlet weak var open: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        let logo = UIImage(named: "logoSmall")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
    }

    @IBAction func emailButton(sender: AnyObject) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["GoEatiOSApp@gmail.com"])
            
            presentViewController(mail, animated: true, completion: nil)
            
        } else {
            
            displayAlert("Could not send email", message: "We are sorry, but we were unable to connect with email client")
            
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "SupportVC Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    

}
