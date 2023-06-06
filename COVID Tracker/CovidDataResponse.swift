//
//  CovidDataResponse.swift
//  COVID Tracker
//
//  Created by Shivam Maheshwari on 06/06/23.
//

import Foundation

struct CovidDataResponse: Codable {
    let data: [CovidDataData]?
}

struct CovidDataData: Codable {
    let cases: CovidCases?
    let date: String?
}

struct CovidCases: Codable {
    let total: TotalCases?
}

struct TotalCases: Codable {
    let value: Int?
}

struct DayData {
    let date: Date?
    let count: Int?
}
