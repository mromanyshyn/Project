//
//  WheelView.swift
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

/// Wheel view with slices.
class WheelView: UIView {
    /// Wheel layer
    private(set) var wheelLayer: WheelLayer?

    /// Customizable preferences.
    /// Required in order to draw properly.
    var preferences: SFWConfiguration.WheelPreferences? {
        didSet {
            wheelLayer = nil
            addWheelLayer()
        }
    }

    /// List of Slice objects.
    /// Used to draw content.
    var slices: [Slice] = [] {
        didSet {
            wheelLayer?.slices = slices
            #if os(macOS)
                setNeedsDisplay(frame)
            #else
                setNeedsDisplay()
            #endif
        }
    }

    /// Initiates without IB.
    /// - Parameters:
    ///   - frame: Frame
    ///   - slices: List of Slices
    ///   - configuration: Customizable configuration
    init(frame: CGRect, slices: [Slice], preferences: SFWConfiguration.WheelPreferences?) {
        self.preferences = preferences
        self.slices = slices
        super.init(frame: frame)
        #if os(macOS)
            wantsLayer = true
        #endif
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        #if os(macOS)
            wantsLayer = true
        #endif
    }

    #if os(macOS)
        override public func layout() {
            super.layout()
            wheelLayer?.needsDisplayOnBoundsChange = true
        }
    #else
        override public func layoutSubviews() {
            super.layoutSubviews()
            layer.needsDisplayOnBoundsChange = true
        }
    #endif

    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        addWheelLayer()
    }

    #if os(macOS)
        override public var wantsDefaultClipping: Bool {
            return false
        }
    #endif

    /// Updates wheel layer and adds to view layer.
    private func addWheelLayer() {
        #if os(macOS)
            for layer in layer?.sublayers ?? [] {
                layer.removeFromSuperlayer()
            }
            // -MARK: I don't know how to fix clipping problem on macOS, if you have a better solution, I will be happy to know
            let circleWidth = preferences?.circlePreferences.strokeWidth ?? 0
            let frame = NSRect(x: bounds.origin.x + circleWidth / 2, y: bounds.origin.y + circleWidth / 2, width: bounds.width - circleWidth, height: bounds.height - circleWidth)
            wheelLayer = WheelLayer(frame: frame, slices: slices, preferences: preferences)
            layer?.addSublayer(wheelLayer!)
        #else
            for layer in layer.sublayers ?? [] {
                layer.removeFromSuperlayer()
            }
            let frame = bounds
            wheelLayer = WheelLayer(frame: frame, slices: slices, preferences: preferences)
            layer.addSublayer(wheelLayer!)
        #endif
        wheelLayer!.setNeedsDisplay()
    }
}

extension WheelView {
    /// Setups auto layouts
    func setupAutoLayout() {
        guard let superView = superview else { return }
        removeConstraints(constraints)
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
    }
}
