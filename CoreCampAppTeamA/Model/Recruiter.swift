//
//  Recruiter.swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 01.12.2020.
//

import UIKit

struct Recruiter: Equatable {
    var id = UUID().uuidString
    var name: String
    var picturePath: String
    var pictureID: String

    var subtitle: String

    var contact: String
    var link: String
    var email: String
    var skype: String

    static func == (lhs: Recruiter, rhs: Recruiter) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Recruiter: DocumentSerializable {
    static func create(_ value: [String: Any]) -> Recruiter? {
        if let id = value["id"] as? String,
           let name = value["name"] as? String,
           let picturePath = value["picturePath"] as? String,
           let pictureID = value["pictureID"] as? String,
           let subtitle = value["subtitle"] as? String,

           let contact = value["contact"] as? String,
           let link = value["linkedin"] as? String,
           let email = value["email"] as? String,
           let skype = value["skype"] as? String {
            return Recruiter(id: id, name: name, picturePath: picturePath, pictureID: pictureID, subtitle: subtitle, contact: contact, link: link, email: email, skype: skype)
        }
        return nil
    }

    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "picturePath": picturePath,
            "pictureID": pictureID,

            "subtitle": subtitle,
            "contact": contact,

            "linkedin": link,
            "email": email,
            "skype": skype,
        ]
    }
}
