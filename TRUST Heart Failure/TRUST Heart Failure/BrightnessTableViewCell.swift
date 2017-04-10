//
//  BrightnessTableViewCell.swift
//  TRUST Heart Failure
//
//  Created by Nathan VelaBorja on 3/10/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class BrightnessTableViewCell: UITableViewCell {

    @IBOutlet weak var brightnessSlider: UISlider!
    
    @IBAction func brightnessSliderValueChanged(_ sender: UISlider) {
        UIScreen.main.brightness = CGFloat(sender.value)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
