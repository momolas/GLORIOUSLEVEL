//
//  NotificationSchedulerView.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 26/11/2024.
//

import SwiftUI

enum WeekDay: Int, CaseIterable {
	case lundi = 1, mardi, mercredi, jeudi, vendredi, samedi, dimanche

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
		switch self {
			case .lundi: return 1
			case .mardi: return 2
			case .mercredi: return 3
			case .jeudi: return 4
			case .vendredi: return 5
			case .samedi: return 6
			case .dimanche: return 7
		}
	}
}

struct NotificationSchedulerView: View {
	@Environment(\.dismiss) var dismiss
	var notificationManager: NotificationManager

	@State private var selectedDays: [WeekDay] = [] // Liste des jours sélectionnés
	@State private var selectedTime: Date = {
		var components = DateComponents()
		components.hour = 9
		components.minute = 0
		return Calendar.current.date(from: components) ?? Date()
	}()
	@State private var showAlert = false

	var body: some View {
		NavigationStack {
			VStack {
				// Ajouter un nouveau rappel
				VStack {
					Text("Ajouter un rappel")
						.font(.headline)

					// Sélecteur de jour avec des cercles interactifs
					HStack {
						Spacer()
						ForEach(WeekDay.allCases, id: \.self) { day in
							Button {
								if selectedDays.contains(day) {
									selectedDays.removeAll(where: { $0 == day })
								} else {
									selectedDays.append(day)
								}
							} label: {
								Text(day.abbreviation)
									.bold()
									.foregroundStyle(.white)
									.frame(width: 30, height: 30)
									.background(selectedDays.contains(day) ? .blue : .gray, in: .circle)
							}
							.buttonStyle(.plain)
							.accessibilityLabel("\(selectedDays.contains(day) ? "Désélectionner" : "Sélectionner") \(day.fullName)")
						}
						Spacer()
					}
					.padding(.vertical)

					// Sélecteur d'heure
					DatePicker("Heure", selection: $selectedTime, displayedComponents: .hourAndMinute)
						.datePickerStyle(.wheel)
						.labelsHidden()

					Button(action: {
						let count = notificationManager.scheduleWeeklyReminders(for: selectedDays, at: selectedTime)
						if count == 0 {
							showAlert = true
						}
					}, label: {
						Text("Ajouter")
							.font(.title3)
							.bold()
							.padding(.horizontal, 24)
							.padding(.vertical, 10)
							.frame(maxWidth: .infinity)
							.background(.thinMaterial)
							.clipShape(.rect(cornerRadius: 5))
					})
					.disabled(selectedDays.isEmpty) // Désactivé si aucun jour n'est sélectionné
					.alert("Aucun rappel ajouté", isPresented: $showAlert) {
						Button("OK", role: .cancel) { }
					} message: {
						Text("Les rappels sélectionnés existent déjà.")
					}
				}
				.padding()
				.background(.thinMaterial)
				.clipShape(.rect(cornerRadius: 12))
				.padding()

				Divider()

				// Liste des rappels existants
				if notificationManager.reminders.isEmpty {
					Text("Aucun rappel pour l'instant.")
						.foregroundStyle(.secondary)
						.padding()
				} else {
					List {
						ForEach(notificationManager.reminders) { reminder in
							HStack {
								Text("\(WeekDay(rawValue: Calendar.current.component(.weekday, from: reminder.date))?.fullName ?? ""), \(reminder.date, format: .dateTime.hour().minute())")
								Spacer()
								Button("Supprimer", systemImage: "trash") {
									notificationManager.removeNotification(reminder)
								}
								.labelStyle(.iconOnly)
								.foregroundStyle(.red)
								.bold()
							}
						}
					}
				}
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button(action: {
						notificationManager.removeAllNotifications()
					}) {
						Text("Tout effacer")
							.foregroundStyle(.red)
							.bold()
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					Button("Annuler") {
						dismiss()
					}
				}
			}
            .navigationTitle("Rappels")
            .navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	NotificationSchedulerView(notificationManager: NotificationManager())
		.preferredColorScheme(.dark)
}
