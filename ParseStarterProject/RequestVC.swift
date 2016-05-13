//
//  RequestVC.swift
//  GoEat
//
//  Created by Evan on 5/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class RequestVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let logo = UIImage(named: "logoSmall")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 1.000, green: 0.718, blue: 0.302, alpha: 1.00)
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
