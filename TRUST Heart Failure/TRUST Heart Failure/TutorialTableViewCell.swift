//
//  TutorialTableViewCell.swift
//  TRUST Heart Failure
//
//  Created by Nathan VelaBorja on 3/25/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class TutorialTableViewCell: UITableViewCell {

    @IBOutlet weak var tutorialImage: UIImageView!
    @IBOutlet weak var tutorialLabel: UILabel!
    var youtubeURL = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
