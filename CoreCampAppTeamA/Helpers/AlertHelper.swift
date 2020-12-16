//
//  AlertHelper.swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 04.11.2020.
//

import Kingfisher
import SwiftMessages
import UIKit

class AlertHelper {
    // MARK: - Functions

    static func showAlert(title: String, message: String, over viewController: UIViewController) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK",
                               style: UIAlertAction.Style.default,
                               handler: nil)
        alert.addAction(ok)
        viewController.present(alert, animated: true, completion: nil)
    }

    static func showMessage(title: String, body: String, iconImage: UIImage?, iconText: String) {
        let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
        messageView.configureBackgroundView(width: 250)

        messageView.iconImageView?.contentMode = .scaleAspectFit
        messageView.iconImageView?.kf.indicatorType = .activity
        messageView.iconImageView?.translatesAutoresizingMaskIntoConstraints = false
        messageView.iconImageView?.heightAnchor.constraint(equalToConstant: 200).isActive = true

        messageView.configureContent(title: title, body: body, iconImage: iconImage, iconText: iconText, buttonImage: nil, buttonTitle: "Got it") { _ in
            SwiftMessages.hide()
        }
        messageView.backgroundView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        messageView.backgroundView.layer.cornerRadius = 10
        messageView.configureDropShadow()

        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.duration = .forever
        config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        SwiftMessages.show(config: config, view: messageView)
    }
}
