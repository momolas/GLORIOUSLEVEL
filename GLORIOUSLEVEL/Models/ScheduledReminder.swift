//
//  ScheduledReminder.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 11/01/2026.
//

import Foundation

struct ScheduledReminder: Identifiable, Equatable {
    let id: String // Correspond à l'identifiant de la notification
    let date: Date // Représente la combinaison de jour et d'heure
}

enum WeekDay: Int, CaseIterable {
    case lundi = 2
    case mardi = 3
    case mercredi = 4
    case jeudi = 5
    case vendredi = 6
    case samedi = 7
    case dimanche = 1

    var abbreviation: String {
        switch self {
            case .lundi: return "L"
            case .mardi: return "M"
            case .mercredi: return "M"
            case .jeudi: return "J"
            case .vendredi: return "V"
            case .samedi: return "S"
            case .dimanche: return "D"
        }
    }

    var fullName: String {
        switch self {
            case .lundi: return "Lundi"
            case .mardi: return "Mardi"
            case .mercredi: return "Mercredi"
            case .jeudi: return "Jeudi"
            case .vendredi: return "Vendredi"
            case .samedi: return "Samedi"
            case .dimanche: return "Dimanche"
        }
    }

    var calendarWeekday: Int {
        return self.rawValue
    }
}
