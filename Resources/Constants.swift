//
//  Constants.swift
//  GoEat
//
//  Created by Evan on 5/18/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import Parse

let URL_BASE = "https://api.foursquare.com/v2/venues/explore?&client_id=B0YPNYWYTTKKQ0UU1WQP0WRYCVQW4HAEZJ3RZICUTT0BWIWC&client_secret=IXQJXYVKQ5A0FXYCPNBINBA0URYZEJXWMOLIHEPMN1YN2PXP&limit=1&v=20160518&openNow=1"

var USER_LAT = ""
var USER_LONG = ""
var USER_DISTANCE = ""


typealias DownloadComplete = () -> ()