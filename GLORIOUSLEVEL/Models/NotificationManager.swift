//
//  ScheduleReminder.swift
//  TEST#4
//
//  Created by Mo on 26/11/2024.
//

import Foundation
import UserNotifications
import Observation

@MainActor
@Observable
class NotificationManager {
	var reminders: [ScheduledReminder] = []
	
	init() {
		Task {
			await loadScheduledNotifications()
		}
	}
	
	// Demande l'autorisation d'envoyer des notifications
	func requestAuthorization() {
		Task {
			do {
				let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
				if granted {
					print("Autorisation accordée.")
				} else {
					print("Autorisation refusée.")
				}
			} catch {
				print("Erreur lors de la demande d'autorisation : \(error.localizedDescription)")
			}
		}
	}
	
	// Planifie une notification pour une date donnée
	func scheduleNotification(at date: Date) {
		let content = UNMutableNotificationContent()
		content.title = "Exercice de respiration"
		content.body = "Il est temps de faire vos exercices de respiration !"
		content.sound = .default

		let triggerDate = Calendar.current.dateComponents([.weekday, .hour, .minute], from: date)
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true) // Répétitions activées

		let identifier = UUID().uuidString
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

		Task {
			do {
				try await UNUserNotificationCenter.current().add(request)
				self.reminders.append(ScheduledReminder(id: identifier, date: date))
				print("Notification planifiée pour \(date)")
			} catch {
				print("Erreur lors de la planification de la notification : \(error.localizedDescription)")
			}
		}
	}
	
	// Planification des rappels hebdomadaires
	@discardableResult
	func scheduleWeeklyReminders(for selectedDays: [WeekDay], at selectedTime: Date) -> Int {
		let calendar = Calendar.current
		let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
		var scheduledCount = 0

		for day in selectedDays {
			// Vérifier si un rappel existe déjà pour ce jour et cette heure
			let alreadyExists = reminders.contains { reminder in
				let reminderComponents = calendar.dateComponents([.weekday, .hour, .minute], from: reminder.date)
				return reminderComponents.weekday == day.calendarWeekday &&
					   reminderComponents.hour == timeComponents.hour &&
					   reminderComponents.minute == timeComponents.minute
			}

			if alreadyExists {
				print("Rappel déjà existant pour \(day.fullName) à \(selectedTime.formatted(date: .omitted, time: .shortened))")
				continue
			}

			var components = DateComponents()
			components.hour = timeComponents.hour
			components.minute = timeComponents.minute
			components.weekday = day.calendarWeekday

			if let reminderDate = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTimePreservingSmallerComponents) {
				scheduleNotification(at: reminderDate)
				scheduledCount += 1
			}
		}
		return scheduledCount
	}

	// Charge les notifications déjà planifiées
	private func loadScheduledNotifications() async {
		let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
		let reminders = requests.compactMap { request -> ScheduledReminder? in
			guard let trigger = request.trigger as? UNCalendarNotificationTrigger else { return nil }
			guard let date = Calendar.current.date(from: trigger.dateComponents) else { return nil }
			return ScheduledReminder(id: request.identifier, date: date)
		}
		self.reminders = reminders.sorted { $0.date < $1.date }
	}

	// Supprime toutes les notifications
	func removeAllNotifications() {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		self.reminders.removeAll()
	}

	// Supprime une notification spécifique
	func removeNotification(_ reminder: ScheduledReminder) {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id])
		self.reminders.removeAll { $0.id == reminder.id }
	}
}
