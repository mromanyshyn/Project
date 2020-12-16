//
//  ButtonCornerRadius.swift
//  CoreCampAppTeamA
//
//  Created by AntonMelnychuk on 27.10.2020.
//
import UIKit

extension UIButton {
    func roundCorners(corners: UIRectCorner, radius: Int = 15) {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: corners,
                                     cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}
