//
//  NotificationManager.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 14/11/2023.
//

import Foundation
import UserNotifications
import Observation

struct Reminder: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var days: [Int] // 1 = Sunday, 2 = Monday, etc.
}

@Observable
@MainActor
class NotificationManager {
	
	var reminders: [Reminder] {
		didSet {
            if let encoded = try? JSONEncoder().encode(reminders) {
                UserDefaults.standard.set(encoded, forKey: "reminders_v2")
            }
		}
	}
	
	init() {
        if let data = UserDefaults.standard.data(forKey: "reminders_v2"),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            self.reminders = decoded
        } else {
            self.reminders = []
        }
	}
	
	func requestPermission() async {
		let options: UNAuthorizationOptions = [.alert, .badge, .sound, .provisional]
		do {
			let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
			if granted {
				print("authorization granted")
			}
		} catch {
			print(error.localizedDescription)
		}
	}

    func scheduleWeeklyReminders(for days: [WeekDay], at time: Date) -> Int {
        var count = 0
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        // Convert Day enum (1=Mon) to Calendar weekday (2=Mon) logic if needed,
        // but Day enum says 1=Monday. Calendar 1=Sunday usually.
        // Let's rely on the Day struct provided later.
        // Assuming the Day enum is passed in, we extract raw values.

        let dayInts = days.map { $0.calendarWeekday }

        // Check if a similar reminder already exists
        let exists = reminders.contains { reminder in
            let rHour = calendar.component(.hour, from: reminder.date)
            let rMinute = calendar.component(.minute, from: reminder.date)
            // Check if sets of days overlap significantly or are identical?
            // User requirement: "Les rappels sélectionnés existent déjà" logic suggests checking exact duplicates or overlap.
            // Let's assume we just add new ones for now, but the View logic "count == 0" implies we return 0 if nothing added.
            // Simplified check: exact match of time and days.
            return rHour == hour && rMinute == minute && Set(reminder.days) == Set(dayInts)
        }

        if exists { return 0 }

        let newReminder = Reminder(date: time, days: dayInts)
        reminders.append(newReminder)

        Task {
            await scheduleNotification(for: newReminder)
        }

        return 1
    }

    func removeNotification(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders.remove(at: index)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
            // Also need to remove individual weekday scheduled items if we used separate requests?
            // If we schedule one request per weekday, we need to track IDs better.
            // Strategy: use UUID + weekday as ID.
            let identifiers = reminder.days.map { "\(reminder.id.uuidString)-\($0)" }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    func removeAllNotifications() {
        reminders.removeAll()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
	
	private func scheduleNotification(for reminder: Reminder) async {
        await requestPermission()

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminder.date)
        let minute = calendar.component(.minute, from: reminder.date)

        for weekday in reminder.days {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = weekday // 1=Sunday, 2=Monday...

            let content = UNMutableNotificationContent()
            content.title = "Respirez"
            content.body = "C'est l'heure de votre session de respiration."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            // Unique ID per weekday for this reminder
            let id = "\(reminder.id.uuidString)-\(weekday)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Error scheduling: \(error)")
            }
        }
	}
}
