//
//  TableViewCell.swift
//  CoreCampAppTeamA
//
//  Created by Mykhailo Romanyshyn on 28.10.2020.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
    //  MARK: - IBOutlets and varibiables

    @IBOutlet var recruitersCellImage: UIImageView!
    @IBOutlet private var recruitersCellName: UILabel!
    @IBOutlet var recruiterCellSubtitle: UILabel!
    @IBOutlet var recruiterCellContakt: UILabel!
    @IBOutlet var recruiterCellEmail: UILabel!
    @IBOutlet var recruiterCellskype: UILabel!
    @IBOutlet var recruiterCellQR: UIImageView!
    @IBOutlet var recruiterViewCard: UIView!
    @IBOutlet var recruiterLinkView: UITextView!

    // MARK: - Functions

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(red: 0.95, green: 0.99, blue: 1, alpha: 1)
        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        recruiterViewCard.layer.cornerRadius = 10
        recruiterViewCard.layer.shadowPath = UIBezierPath(rect: recruiterViewCard.bounds).cgPath
        recruiterViewCard.layer.shadowColor = UIColor.lightGray.cgColor
        recruiterViewCard.layer.shadowRadius = 3
        recruiterViewCard.layer.shadowOffset = .zero
        recruiterViewCard.layer.shadowOpacity = 0.2
        recruitersCellImage.layer.cornerRadius = recruitersCellImage.bounds.width / 2
    }

    func showQrCode() {
        if recruiterLinkView?.text != nil {
            recruiterCellQR?.image = generateQrCode(from: recruiterLinkView.text!)
        } else {
            recruiterCellQR?.image = generateQrCode(from: "")
        }
    }

    func generateQrCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")

            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }

    func update(name: String, image: UIImage, subtitle: String, contact: String, qr: UIImage, link: String, email: String, skype: String) {
        recruitersCellName.text = name
        recruitersCellImage.image = image
        recruiterCellSubtitle.text = subtitle
        recruiterCellContakt.text = contact
        recruiterLinkView.text = link
        recruiterCellQR.image = qr
        recruiterCellEmail.text = email
        recruiterCellskype.text = skype
    }

    // MARK: - IBAction methods

    @IBAction func linkBtnPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: recruiterLinkView.text!)! as URL, options: [:], completionHandler: nil)
    }
}
