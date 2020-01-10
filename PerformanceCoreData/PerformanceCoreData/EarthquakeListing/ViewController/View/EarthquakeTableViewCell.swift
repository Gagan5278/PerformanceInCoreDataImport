//
//  EarthquakeTableViewCell.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2020/01/01.
//  Copyright © 2020 Gagan Vishal. All rights reserved.
//

import UIKit

class EarthquakeTableViewCell: UITableViewCell {
    //IBOutlets
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var timeDetailLabel: UILabel!
    @IBOutlet weak var magnitudeLabel: UILabel!
    
    //MARK:- View Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    /******************************MVVM************************/
    //MARK:-
    var viewModel: EarthquakeProprtyProtocol! {
        didSet {
            bindData()
        }
    }

    /******************************MVVM************************/

    //MARK:- Configue Data
    var viewModelProperty: EarthquakeProprty! {
        didSet {
            bindData()
        }
    }
    
    //MARK:- Bind Data
    private func bindData(){
        self.detailDescriptionLabel.text = viewModelProperty.getName
        self.timeDetailLabel.text = viewModelProperty.humanReadableDate
        self.magnitudeLabel.text = "\(viewModelProperty.getRoundedMagnitude)"
    }
}
