//
//  ClearStackView.swift
//  CoreCampAppTeamA
//
//  Created by Anton Melnychuk on 03.11.2020.
//

import UIKit

extension UIStackView {
    func clearStackView() {
        arrangedSubviews.forEach { view in
            view.removeFromSuperview()
            removeArrangedSubview(view)
        }
    }
}
