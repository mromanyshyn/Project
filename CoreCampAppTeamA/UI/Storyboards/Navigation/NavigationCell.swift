//
//  NavigationCell.swift
//  CoreCampAppTeamB
//
//  Created by Max on 11/11/2020.
//

import UIKit

class NavigationCell: UICollectionViewCell {
    
    //  MARK: -IBOutlets and varibiables
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    var selectedColor: UIColor?
    
    // MARK: -Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if self.isHighlighted{
            self.screenNameLabel.font = UIFont(name: "TTHoves-Bold", size: 20)
        }
    }
    
    override var isSelected: Bool{
        didSet{
            screenNameLabel.font = isSelected ? UIFont(name: "TTHoves-Bold", size: 18) : UIFont(name: "TTHoves-Regular", size: 18)
            screenNameLabel.textColor = isSelected ? selectedColor : .black
        }
    }
}
