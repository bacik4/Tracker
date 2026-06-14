//
//  Tracker.swift
//  Tracker
//
//  Created by Игорь Глебов on 26.05.2026.
//
import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>
}
