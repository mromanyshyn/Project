//
//  DataManager.swift
//  CoreCampAppTeamA
//
//  Created by Anton Melnychuk on 13.12.2020.
//

import Foundation

class TableViewDataManager {
    //  MARK: - IBOutlets and varibiables

    static let instance = TableViewDataManager()
    private init() {}

    var recruiters: [Recruiter] = []

    var speakers: [Speaker] = []

    // MARK: - Functions

    func addRecruiter(_ addRecruiter: Recruiter) {
        recruiters.append(addRecruiter)
    }

    func editRecruiter(_ editRecruiter: Recruiter) {
        if let index = recruiters.firstIndex(where: { $0.id == editRecruiter.id }) {
            recruiters[index] = editRecruiter
        }
    }

    func addSpeaker(_ speaker: Speaker) {
        speakers.append(speaker)
    }

    func editSpeaker(_ speaker: Speaker) {
        if let index = speakers.firstIndex(where: { $0.id == speaker.id }) {
            speakers[index] = speaker
        }
    }
}
