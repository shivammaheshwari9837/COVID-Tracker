//
//  APICaller.swift
//  COVID Tracker
//
//  Created by Shivam Maheshwari on 03/06/23.
//

import Foundation

extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter
    }()
    
    static let prettyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter
    }()
    
}

class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    private struct Constants {
        static let allStatesUrl = URL(string: "https://api.covidtracking.com/v2/states.json")
    }
    
    enum DataScope {
        case national
        case state(State)
    }
    
    public func getCovidData(
        for scope: DataScope,
        completion: @escaping (Result<[DayData], Error>) -> Void) {
            
            let urlString: String
            switch scope {
            case .national:
                urlString = "https://api.covidtracking.com/v2/us/daily.json"
            case .state(let state):
                urlString = "https://api.covidtracking.com/v2/states/\(state.stateCode?.lowercased() ?? "")/daily.json"
            }
            
            guard let url = URL(string: urlString) else { return }
            
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(CovidDataResponse.self, from: data)
                    
                    let models = result.data?.compactMap({ model -> DayData? in
                        guard let date = DateFormatter.dayFormatter.date(from: model.date ?? ""),
                              let count = model.cases?.total?.value else {
                            return nil
                        }
                        return DayData.init(date: date,
                                            count: count)
                    })
                    
                    completion(.success(models ?? []))
                    
                }
                catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
            
            
            
        }
    
    public func getStateList(
        completion: @escaping (Result<[State], Error>) -> Void) {
            guard let url = Constants.allStatesUrl else { return }
            
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(StateListResponse.self, from: data)
                    let states = result.data
                    completion(.success(states ?? []))
                }
                catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
}
