//
//  SettingsTableViewCell.swift
//  CoreCampAppTeamA
//
//  Created by MacBook on 30.11.2020.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    //  MARK: - IBOutlets and varibiables

    @IBOutlet var prizesImage: UIImageView!
    @IBOutlet var prizeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - Functions

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
