//
//  GoogleSheetManager.swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 04.11.2020.
//

import Foundation
import GoogleAPIClientForREST

class GoogleSheetManager: NSObject {
    static let shared = GoogleSheetManager()
    override private init() {}

    var sheetID = ""
    var sheetName = "Аркуш1"

    private var importCompletion: ((Result<[Participant], GoogleSheetError>) -> Void)?

    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    let service = GTLRSheetsService()

    // Get the full names of participants in a sample spreadsheet:
    // https://docs.google.com/spreadsheets/d/116OXZSJL6Q53VWh8tJ3FM_nZOZPt2Azw3XKKdRtLNic/edit#gid=0

    func importParticipants(url: String, completion: @escaping (Result<[Participant], GoogleSheetError>) -> Void) {
        importCompletion = completion

        do {
            let input = url
            let regex = try NSRegularExpression(pattern: ".*/(.*)/", options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))

            if let match = matches.first {
                let range = match.range(at: 1)
                if let swiftRange = Range(range, in: input) {
                    let name = input[swiftRange]
                    GoogleSheetManager.shared.sheetID = String(name)
                    print(GoogleSheetManager.shared.sheetID)
                }
            }
        } catch {
            print(error, "Regex was bad!")
        }

        let spreadsheetId = sheetID
        let range = "\(sheetName)!B2:E"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range: range)
        service.executeQuery(query, delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }

    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result: GTLRSheets_ValueRange,
                                       error: NSError?) {
        var participants: [Participant] = []
        if let _ = error {
            print("Bad Sheet Name")
            importCompletion?(.failure(.invalidName))
            return
        }

        let rows = result.values!

        if rows.isEmpty {
            importCompletion?(.failure(.invalidData))
            print("No data found.")
            return
        }

        for row in rows {
            let name = row[0]
            let email = row[1]
            let language = row[2]
            let familiar = row[3]

            let participant = Participant(name: "\(name)", email: "\(email)",
                                          language: "\(language)",
                                          familiar: "\(familiar)")
            participants.append(participant)
        }
        importCompletion?(.success(participants))
        importCompletion = nil
    }
}
