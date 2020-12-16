//
//  SpeakersCell.swift
//  CoreCampAppTeamA
//
//  Created by Max on 13.12.2020.
//

import UIKit

class SpeakersCell: UITableViewCell {
    //  MARK: - IBOutlets and varibiables

    @IBOutlet var speakerImage: UIImageView!
    @IBOutlet var speakerName: UILabel!
    @IBOutlet var speakerDepartment: UILabel!
    @IBOutlet var speakerPosition: UILabel!
    @IBOutlet var speakerCard: UIView!

    @IBOutlet var speakerSettingsButton: UIButton!

    // MARK: - Functions

    override func awakeFromNib() {
        super.awakeFromNib()
        speakerSettingsButton.tintColor = UIColor(named: "speakers_hue")
        backgroundColor = UIColor(red: 0.95, green: 0.99, blue: 1, alpha: 1)
        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        speakerCard.layer.cornerRadius = 10
        speakerCard.layer.shadowPath = UIBezierPath(rect: speakerCard.bounds).cgPath
        speakerCard.layer.shadowColor = UIColor.lightGray.cgColor
        speakerCard.layer.shadowRadius = 3
        speakerCard.layer.shadowOffset = .zero
        speakerCard.layer.shadowOpacity = 0.2
        speakerImage.layer.cornerRadius = speakerImage.bounds.width / 2
    }

    func update(name: String, image: UIImage, speakerDepartment: String, speakerPosition: String) {
        speakerName.text = name
        speakerImage.image = image
        self.speakerDepartment.text = speakerDepartment
        self.speakerPosition.text = speakerPosition
    }
}
