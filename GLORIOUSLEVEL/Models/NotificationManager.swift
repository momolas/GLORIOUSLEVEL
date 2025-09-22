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
	
	func requestPermission() {
		let options: UNAuthorizationOptions = [.alert, .badge, .sound, .provisional]
		UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
			if success {
				print("authorization granted")
			} else if let error {
				print(error.localizedDescription)
			}
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
			let date = dateFormatter.date(from: reminder)
			
			let dateComponents = DateComponents(hour: Calendar.current.component(.hour, from: date!), minute: Calendar.current.component(.minute, from: date!))
			sendNotification(date: dateComponents, title: "Kegel", subtitle: "Exercise", body: "Il est temps de faire de l'exercice")
		}
	}
	
	func sendNotification(date: DateComponents, title: String, subtitle: String, body: String, repeat: Bool = true) {
		
		let center = UNUserNotificationCenter.current()
		
		let addRequest = {
			let content = UNMutableNotificationContent()
			content.title = title
			content.subtitle = subtitle
			content.body = body
			content.sound = .default
			
			let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
			let request = UNNotificationRequest(identifier: UUID().uuidString + title, content: content, trigger: trigger)
			
			center.add(request)
		}
		
		center.getNotificationSettings { settings in
			if settings.authorizationStatus == .authorized {
				addRequest()
			} else {
				center.requestAuthorization(options: [.alert, .badge, .sound, .provisional]) { success, error in
					if success {
						addRequest()
					} else if let error {
						print(error.localizedDescription)
					}
				}
			}
		}
	}
}
