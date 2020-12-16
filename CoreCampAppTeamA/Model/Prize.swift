//
//  Prize.swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 14.11.2020.
//

import Foundation

protocol DocumentSerializable {
    associatedtype Model
    var dictionary: [String: Any] { get }

    static func create(_ value: [String: Any]) -> Model?
}

struct Prize: Codable {
    var id = UUID().uuidString
    var name: String
    var quantity: Int
    var picturePath: String
}

extension Prize: DocumentSerializable {
    static func create(_ value: [String: Any]) -> Prize? {
        if let id = value["id"] as? String,
           let name = value["name"] as? String,
           let quantity = value["quantity"] as? Int,
           let picturePath = value["picturePath"] as? String {
            return Prize(id: id, name: name, quantity: quantity, picturePath: picturePath)
        }
        return nil
    }

    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "quantity": quantity,
            "picturePath": picturePath,
        ]
    }
}
