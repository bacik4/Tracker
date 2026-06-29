//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Игорь Глебов on 29.06.2026.
//
import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "1983fc90-7ce9-42e9-9183-6b33171e12e1") else { return }

        AppMetrica.activate(with: configuration)
    }
    
    static func report(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": screen
        ]
        
        if let item {
            params["item"] = item
        }
        
        print("Analytics event:", params)
        
        AppMetrica.reportEvent(name: event, parameters: params) { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        }
    }
}
