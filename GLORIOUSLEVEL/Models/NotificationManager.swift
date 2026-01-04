//
//  NotificationManager.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 14/11/2023.
//

import Foundation
import UserNotifications
import Observation

@Observable
@MainActor
class NotificationManager {
	
	var isReminder: Bool {
		didSet {
			UserDefaults.standard.set(isReminder, forKey: "isReminder")
		}
	}
	
	var reminders: [String] {
		didSet {
			UserDefaults.standard.set(reminders, forKey: "reminders")
		}
	}
	
	init() {
		self.isReminder = UserDefaults.standard.object(forKey: "isReminder") as? Bool ?? false
		self.reminders = UserDefaults.standard.object(forKey: "reminders") as? [String] ?? []
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
	
	func cancelNotification() {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		UNUserNotificationCenter.current().removeAllDeliveredNotifications()
	}
	
	func scheduleNotification() {
		cancelNotification()
		for reminder in reminders {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "hh:mm a"
			if let date = dateFormatter.date(from: reminder) {
				let dateComponents = DateComponents(hour: Calendar.current.component(.hour, from: date), minute: Calendar.current.component(.minute, from: date))
				Task {
					await sendNotification(date: dateComponents, title: "Kegel", subtitle: "Exercise", body: "Il est temps de faire de l'exercice")
				}
			}
		}
	}
	
	func sendNotification(date: DateComponents, title: String, subtitle: String, body: String, repeat: Bool = true) async {
		
		let center = UNUserNotificationCenter.current()
		
		func addRequest() async {
			let content = UNMutableNotificationContent()
			content.title = title
			content.subtitle = subtitle
			content.body = body
			content.sound = .default
			
			let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
			let request = UNNotificationRequest(identifier: UUID().uuidString + title, content: content, trigger: trigger)
			
			do {
				try await center.add(request)
			} catch {
				print("Error adding notification: \(error.localizedDescription)")
			}
		}
		
		let settings = await center.notificationSettings()
		if settings.authorizationStatus == .authorized {
			await addRequest()
		} else {
			do {
				let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound, .provisional])
				if granted {
					await addRequest()
				}
			} catch {
				print(error.localizedDescription)
			}
		}
	}
}
