//
//  ShareVC.swift
//  GoEat
//
//  Created by Evan on 5/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Social

class ShareVC: UIViewController {

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "ShareVC Screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
    }

    @IBAction func facebookPost(_ sender: AnyObject) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("@GoEatiOSApp is awesome! Everyone check it out! www.GoEatiOSApp.com")
            self.present(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func twitterPost(_ sender: AnyObject) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("@GoEatiOSApp is awesome! Everyone check it out! www.GoEatiOSApp.com")
            self.present(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
