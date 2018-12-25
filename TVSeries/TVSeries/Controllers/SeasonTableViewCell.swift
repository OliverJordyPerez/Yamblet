//
//  SeasonTableViewCell.swift
//  TVSeries
//
//  Created by OliverPérez on 12/24/18.
//  Copyright © 2018 OliverPérez. All rights reserved.
//

import UIKit

class SeasonTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var descritionSeason: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
