//
//  FoundRestVC.swift
//  GoEat
//
//  Created by Evan on 5/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class FoundRestVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        restaurant.downloadFoursquareRest { () -> () in
        }
        
        let logo = UIImage(named: "logoSmall")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
