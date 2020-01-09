//
//  CustomTableViewCell.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/31.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var decriptionLabel: UILabel!
    @IBOutlet weak var atTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
