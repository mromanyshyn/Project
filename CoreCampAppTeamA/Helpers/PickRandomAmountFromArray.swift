//
//  PIckRandomAmountFromArray.swift
//  CoreCampAppTeamA
//
//  Created by AntonMelnychuk on 27.10.2020.
//
import Foundation

// MARK: - Functions

func pickRandom<T: Equatable>(_ amount: Int, from array: Array<T>) -> Array<T> {
    var randomElementsInReturnArray = 0
    var arrayToReturn: Array<T> = []

    while randomElementsInReturnArray != amount {
        let elementToReturn = pickOneFromArray(array)
        if arrayToReturn.contains(elementToReturn) {
            continue
        } else {
            arrayToReturn.append(elementToReturn)
            randomElementsInReturnArray += 1
        }
    }

    return arrayToReturn
}

func pickOneFromArray<T>(_ array: Array<T>) -> T {
    let r = Int.random(in: 0 ..< array.count)

    return array[r]
}
