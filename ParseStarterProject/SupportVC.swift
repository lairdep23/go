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

    @IBAction func emailButton(_ sender: AnyObject) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["GoEatiOSApp@gmail.com"])
            
            present(mail, animated: true, completion: nil)
            
        } else {
            
            displayAlert("Could not send email", message: "We are sorry, but we were unable to connect with email client")
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "SupportVC Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
    }
    

}
