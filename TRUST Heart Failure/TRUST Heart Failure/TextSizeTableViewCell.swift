//
//  TextSizeTableViewCell.swift
//  TRUST Heart Failure
//
//  Created by Nathan VelaBorja on 3/10/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class TextSizeTableViewCell: UITableViewCell {

    @IBOutlet weak var textSizeSegmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func textSizeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex + 1, forKey: "textSize")
        print("Text size changed to \(sender.selectedSegmentIndex + 1)")
    }
}
