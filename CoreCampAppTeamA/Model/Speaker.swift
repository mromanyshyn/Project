//
//  Speaker.swift
//  CoreCampAppTeamA
//
//  Created by MacBook on 13.12.2020.
//

import Foundation

struct Speaker: Equatable {
    var id = UUID().uuidString
    var name: String
    var picturePath: String
    var pictureID: String

    var departmentName: String
    var positionName: String
}

extension Speaker: DocumentSerializable {
    static func create(_ value: [String: Any]) -> Speaker? {
        if let id = value["id"] as? String,
           let name = value["name"] as? String,
           let picturePath = value["picturePath"] as? String,
           let pictureID = value["pictureID"] as? String,

           let departmentName = value["departmentName"] as? String,
           let positionName = value["positionName"] as? String {
            return Speaker(id: id, name: name, picturePath: picturePath, pictureID: pictureID, departmentName: departmentName, positionName: positionName)
        }
        return nil
    }

    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "picturePath": picturePath,
            "pictureID": pictureID,
            "departmentName": departmentName,
            "positionName": positionName,
        ]
    }
}
