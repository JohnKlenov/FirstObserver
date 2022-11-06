//
//  SegmentedControlMW.swift
//  FirstObserver
//
//  Created by Evgenyi on 13.08.22.
//

import UIKit

class SegmentedControlMW: UISegmentedControl {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // делаем острые угля для UISegmentedControl
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0
    }
    

}
