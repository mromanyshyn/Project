//
//  PinImageView.swift
//  SwiftFortuneWheel
//
//  Created by Sherzod Khashimov on 6/3/20.
//
//

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// Pin or anchor image view, that usually represents an arrow to point in selected slice.
class PinImageView: UIImageView {
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

    private var heightLC: NSLayoutConstraint?
    private var widthLC: NSLayoutConstraint?
    private var topLC: NSLayoutConstraint?
    private var bottomLC: NSLayoutConstraint?
    private var leadingLC: NSLayoutConstraint?
    private var trailingLC: NSLayoutConstraint?
    private var centerXLC: NSLayoutConstraint?
    private var centerYLC: NSLayoutConstraint?
}

extension PinImageView {
    /// Setups auto layouts with preferences
    /// - Parameter preferences: Spin button preferences, that contains layouts preference variables.
    func setupAutoLayout(with preferences: SFWConfiguration.PinImageViewPreferences?) {
        guard let superView = superview else { return }
        guard let preferences = preferences else { return }
        removeConstraints(constraints)
        translatesAutoresizingMaskIntoConstraints = false

        diactivateConstrains()

        heightLC = heightAnchor.constraint(equalToConstant: preferences.size.height)
        heightLC?.isActive = true

        widthLC = widthAnchor.constraint(equalToConstant: preferences.size.width)
        widthLC?.isActive = true

        switch preferences.position {
        case .top:
            topLC = topAnchor.constraint(equalTo: superView.topAnchor, constant: preferences.verticalOffset)
            topLC?.isActive = true
        case .bottom:
            bottomLC = bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: preferences.verticalOffset)
            bottomLC?.isActive = true
        case .left:
            leadingLC = leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: preferences.horizontalOffset)
            leadingLC?.isActive = true
        case .right:
            trailingLC = trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: preferences.horizontalOffset)
            trailingLC?.isActive = true
        }

        switch preferences.position {
        case .top, .bottom:
            centerXLC = centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: preferences.horizontalOffset)
            centerXLC?.isActive = true
        case .left, .right:
            centerYLC = centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: preferences.verticalOffset)
            centerYLC?.isActive = true
        }

        layoutIfNeeded()
    }

    private func diactivateConstrains() {
        heightLC?.isActive = false
        widthLC?.isActive = false
        topLC?.isActive = false
        bottomLC?.isActive = false
        leadingLC?.isActive = false
        trailingLC?.isActive = false
        centerXLC?.isActive = false
        centerYLC?.isActive = false
    }

    /// Updates pin image
    /// - Parameter name: Image name from assets catalog
    func image(name: String?) {
        guard let imageName = name, imageName != "" else {
            image = nil
            return
        }
        image = SFWImage(named: imageName)
    }

    /// Updates pin image view background color and layer
    /// - Parameter preferences: Preferences that contains appearance preference variables.
    func configure(with preferences: SFWConfiguration.PinImageViewPreferences?) {
        backgroundColor = preferences?.backgroundColor
        tintColor = preferences?.tintColor
    }
}
