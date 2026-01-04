//
//  SettingsView.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 12/01/2023.
//

import SwiftUI
import HealthKit
import CoreHaptics

struct SettingsView: View {
	@Environment(\.dismiss) var dismiss
	
	@Bindable var modelData: BreathingViewModel
	@Bindable var notificationManager: NotificationManager
	var healthkitManager: HealthKitManager
	
	@Binding var showSettingsView: Bool
	@State var showTimePickerModal = false
	@State private var newReminderDate = Date()
	
	@AppStorage("reduce_haptics") var reduceHaptics = false
	@AppStorage("tense_time") var tenseTime = TimeConstants.defaultTensionTime
	@AppStorage("relax_time") var relaxTime = TimeConstants.defaultRelaxTime
	@AppStorage("reps_count") var totalReps = TimeConstants.defaultTotalReps
	@AppStorage("save_healthkit") var saveToAppleHealth = false
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					Stepper(value: $tenseTime, in: 1...30) {
						HStack {
							ZStack {
								Image(systemName: "wave.3.left")
									.foregroundStyle(.white)
									.font(.callout)
							}
							.frame(width: 28, height: 28)
							.background(Color.blue)
							.clipShape(.rect(cornerRadius: 6))
							Text("Contraction: \(tenseTime) \(tenseTime == 1 ? "seconde" : "secondes")")
						}
					}
					
					Stepper(value: $relaxTime, in: 1...30) {
						HStack {
							ZStack {
								Image(systemName: "wave.3.right")
									.foregroundStyle(.white)
									.font(.callout)
							}
							.frame(width: 28, height: 28)
							.background(Color.blue)
							.clipShape(.rect(cornerRadius: 6))
							Text("Relachement: \(relaxTime) \(relaxTime == 1 ? "seconde" : "secondes")")
						}
					}
					
					Stepper(value: $totalReps, in: 1...50) {
						HStack {
							ZStack {
								Image(systemName: "repeat")
									.foregroundStyle(.white)
									.font(.callout)
							}
							.frame(width: 28, height: 28)
							.background(Color.green)
							.clipShape(.rect(cornerRadius: 6))
							Text("\(totalReps) \(totalReps == 1 ? "répétition" : "répétitions")")
						}
					}
					
					if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
						Toggle(isOn: $reduceHaptics) {
							HStack {
								ZStack {
									Image(systemName: "iphone.radiowaves.left.and.right")
										.foregroundStyle(.white)
										.font(.callout)
								}
								.frame(width: 28, height: 28)
								.background(Color.orange)
								.clipShape(.rect(cornerRadius: 6))
								Text("Désactiver les vibration")
							}
							.frame(width: 28, height: 28)
							.background(Color.orange)
							.clipShape(.rect(cornerRadius: 6))
							Text("Désactiver les vibration")
						}
					}
					
					HStack {
						Toggle(
							isOn: $notificationManager.isReminder,
							label: {
								Label("Rappels", systemImage: "clock")
									.foregroundStyle(.white)
							}
						)
                        .onChange(of: notificationManager.isReminder) { _, newValue in
                            if newValue {
                                Task {
                                    await notificationManager.requestPermission()
                                    notificationManager.scheduleNotification()
                                }
                            } else {
                                notificationManager.cancelNotification()
                            }
                        }
					}
					
                    if notificationManager.isReminder {
                        ForEach(notificationManager.reminders, id: \.self) { reminder in
                            Text(reminder)
                        }
                        .onDelete { indexSet in
                            notificationManager.reminders.remove(atOffsets: indexSet)
                            notificationManager.scheduleNotification()
                        }

                        Button(action: {
                            self.showTimePickerModal.toggle()
                        }, label: {
                            Text("Ajouter un rappel")
                        })
                    }
					
					Button(action: {
						tenseTime = TimeConstants.defaultTensionTime
						relaxTime = TimeConstants.defaultRelaxTime
						totalReps = TimeConstants.defaultTotalReps
					}) {
						Text("Réinitialiser")
					}
				}
				
				if healthkitManager.isHealthKitAvailable() {
					Section(footer: Text("The duration of each session will be saved in Apple Health as Mindful Minutes. If access has been previously revoked, this toggle will have no effect. Access will need to be granted through Settings > Privacy > Inhale.")) {
                        Toggle("Save to Apple Health", isOn: $saveToAppleHealth)
                            .onChange(of: saveToAppleHealth) { _, newValue in
                                if newValue {
                                    Task {
                                        await healthkitManager.getAuthorization()
                                    }
                                }
                            }
					}
				}
			}
			.navigationTitle("Paramètres")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button(
						action: {
							self.showSettingsView = false
						}
					) {
						Text("Terminé")
							.bold()
					}
				}
			}
            .sheet(isPresented: $showTimePickerModal) {
                NavigationStack {
                    VStack {
                        DatePicker("Heure de rappel", selection: $newReminderDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .padding()

                        Button("Ajouter") {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "hh:mm a"
                            let timeString = formatter.string(from: newReminderDate)
                            notificationManager.reminders.append(timeString)
                            notificationManager.scheduleNotification()
                            showTimePickerModal = false
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                    .navigationTitle("Ajouter un rappel")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Annuler") {
                                showTimePickerModal = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
		}
	}
}

#Preview {
	SettingsView(modelData: BreathingViewModel(), notificationManager: NotificationManager(), healthkitManager: HealthKitManager(), showSettingsView: .constant(true))
		.environment(BreathingViewModel())
		.preferredColorScheme(.dark)
}

