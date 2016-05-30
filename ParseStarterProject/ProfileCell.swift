//
//  ProfileCell.swift
//  GoEat
//
//  Created by Evan on 5/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MapKit


var numberOfRests: Int = 0

class ProfileCell: PFTableViewCell {

    @IBOutlet weak var restName: UILabel!
    
    @IBOutlet weak var restLocation: UILabel!
    
    @IBOutlet weak var restTime: UILabel!
    
    var restWebUrl = ""
    
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func goAgain(sender: AnyObject) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(restLocation.text!) { (placemark, error) in
            
            if (placemark?[0]) != nil {
                
                let mkPlace = MKPlacemark(placemark: placemark![0])
                
                let mapItem = MKMapItem(placemark: mkPlace)
                
                mapItem.name = self.restName.text!
                
                let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                
                mapItem.openInMapsWithLaunchOptions(launchOptions)
                
    
            }
        }
    }
    
   

   
    

}
