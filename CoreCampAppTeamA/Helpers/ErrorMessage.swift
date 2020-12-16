//
//  ErrorMessage.swift..swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 05.11.2020.
//

import Foundation

enum GoogleSheetError: String, Error {
    case invalidName = "Please enter a valid Sheet Name or Link."
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
}
