//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Owi Lover on 6/22/25.
//

//import YandexMobileMetrica
//
//struct AnalyticsService {
//    static func activate() {
//        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "1398be6d-95c3-4b8d-850b-6a111e8a1381") else { return }
//        
//        YMMYandexMetrica.activate(with: configuration)
//    }
//    
//    func report(event: String, params : [AnyHashable : Any]) {
//        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
//            print("REPORT ERROR: %@", error.localizedDescription)
//        })
//    }
//}

import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "1398be6d-95c3-4b8d-850b-6a111e8a1381") else { return }
        AppMetrica.activate(with: configuration)
    }
    
    enum Events: String {
        case open
        case close
        case click
    }
    
    enum Items: String {
        case add_track
        case track
        case filter
        case edit
        case delete
    }
    
    func report(name: String, event: Events, screen: String, item: Items? = nil) {
        
        let parameters: [String: Any] = {
            var dictionary = [
                "event": event.rawValue,
                "screen": screen,
            ]
            if let item {
                dictionary["item"] = item.rawValue
            }
            return dictionary
        }()

        AppMetrica.reportEvent(name: name, parameters: parameters, onFailure: ({ error in
            print("Can't report AppMetrica! error: \(error.localizedDescription)") })
        )
        print("Reported to AppMetrica! info: \(name): \(parameters)")
    }
}
