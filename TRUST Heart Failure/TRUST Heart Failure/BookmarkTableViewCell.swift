//
//  BookmarkTableViewCell.swift
//  TRUST Heart Failure
//
//  Created by Kameron Haramoto on 3/1/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class BookmarkTableViewCell: UITableViewCell {

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var pageNumberLabel: UILabel!
    var mid : String = ""
    var pid : String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    

}
