//
//  MaterialView.swift
//  devslopesShowcase
//
//  Created by Evan on 3/15/16.
//  Copyright © 2016 Evan. All rights reserved.
//

import UIKit

let SHADOW_COLOR: CGFloat = 157.0 / 255.0

class MaterialView: UIView {

    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }

}
