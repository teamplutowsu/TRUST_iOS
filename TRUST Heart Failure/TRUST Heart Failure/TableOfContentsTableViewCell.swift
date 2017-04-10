//
//  TableOfContentsTableViewCell.swift
//  TRUST Heart Failure
//
//  Created by Nathan VelaBorja on 3/17/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class TableOfContentsTableViewCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
