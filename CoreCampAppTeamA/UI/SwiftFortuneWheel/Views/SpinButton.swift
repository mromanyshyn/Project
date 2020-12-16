//
//  SpinButton.swift
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

/// Spin button located at the center of the fotune wheel view.
/// Optional and can be hidden.
class SpinButton: UIButton {
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

    private var heightLC: NSLayoutConstraint?
    private var widthLC: NSLayoutConstraint?
    private var centerXLC: NSLayoutConstraint?
    private var centerYLC: NSLayoutConstraint?

    #if os(macOS)
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            isBordered = false
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            wantsLayer = true
            isBordered = false
        }
    #endif
}

extension SpinButton {
    /// Setups auto layouts with preferences
    /// - Parameter preferences: Spin button preferences, that contains layouts preference variables.
    func setupAutoLayout(with preferences: SFWConfiguration.SpinButtonPreferences?) {
        guard let superView = superview else { return }
        guard let preferences = preferences else { return }
        removeConstraints(constraints)
        translatesAutoresizingMaskIntoConstraints = false

        heightLC = heightAnchor.constraint(equalToConstant: preferences.size.height)
        heightLC?.isActive = true

        widthLC = widthAnchor.constraint(equalToConstant: preferences.size.width)
        widthLC?.isActive = true

        centerXLC = centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: preferences.horizontalOffset)
        centerXLC?.isActive = true

        centerYLC = centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: preferences.verticalOffset)
        centerYLC?.isActive = true

        layoutIfNeeded()
    }

    private func diactivateConstrains() {
        heightLC?.isActive = false
        widthLC?.isActive = false
        centerXLC?.isActive = false
        centerYLC?.isActive = false
    }

    /// Updates spin button image
    /// - Parameter name: Image name from assets catalog
    func image(name: String?) {
        guard let imageName = name, imageName != "" else {
            #if os(macOS)
                setImage(nil)
            #else
                setImage(nil, for: .normal)
            #endif
            return
        }
        let image = SFWImage(named: imageName)
        #if os(macOS)
            setImage(image)
        #else
            setImage(image, for: .normal)
        #endif
    }

    /// Updates spin button background image
    /// - Parameter name: Image name from assets catalog
    func backgroundImage(name: String?) {
        #if !os(macOS)
            guard let imageName = name, imageName != "" else {
                setBackgroundImage(nil, for: .normal)
                return
            }
            let image = UIImage(named: imageName)
            setBackgroundImage(image, for: .normal)
        #endif
    }

    /// Updates spin button background color and layer
    /// - Parameter preferences: Preferences that contains appearance preference variables.
    func configure(with preferences: SFWConfiguration.SpinButtonPreferences?) {
        backgroundColor = preferences?.backgroundColor
        #if os(macOS)
            layer?.cornerRadius = preferences?.cornerRadius ?? 0
            layer?.borderWidth = preferences?.cornerWidth ?? 0
            layer?.borderColor = preferences?.cornerColor.cgColor
            font = preferences?.font
            setTitle(attributedTitle.string, attributes: preferences?.textAttributes)
        #else
            layer.cornerRadius = preferences?.cornerRadius ?? 0
            layer.borderWidth = preferences?.cornerWidth ?? 0
            layer.borderColor = preferences?.cornerColor.cgColor
            setTitleColor(preferences?.textColor, for: .normal)
            setTitleColor(preferences?.disabledTextColor, for: .disabled)
            titleLabel?.font = preferences?.font
        #endif
    }
}
