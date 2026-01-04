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
            Form {
				Section {
					Stepper(value: $tenseTime, in: 1...30) {
                        Label {
                            Text("Contraction")
                            Spacer()
                            Text("\(tenseTime) sec")
                                .foregroundStyle(.secondary)
                        } icon: {
                            Image(systemName: "wave.3.left")
                                .foregroundStyle(.blue)
                        }
					}
					
					Stepper(value: $relaxTime, in: 1...30) {
                        Label {
                            Text("Relâchement")
                            Spacer()
                            Text("\(relaxTime) sec")
                                .foregroundStyle(.secondary)
                        } icon: {
                            Image(systemName: "wave.3.right")
                                .foregroundStyle(.blue)
                        }
					}
					
					Stepper(value: $totalReps, in: 1...50) {
                        Label {
                            Text("Répétitions")
                            Spacer()
                            Text("\(totalReps)")
                                .foregroundStyle(.secondary)
                        } icon: {
                            Image(systemName: "repeat")
                                .foregroundStyle(.green)
                        }
					}

                    Button(role: .destructive, action: {
                        tenseTime = TimeConstants.defaultTensionTime
                        relaxTime = TimeConstants.defaultRelaxTime
                        totalReps = TimeConstants.defaultTotalReps
                    }) {
                        Text("Réinitialiser les durées")
                    }
                } header: {
                    Text("Personnalisation")
                }
					
				Section {
                    if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
                        Toggle(isOn: $reduceHaptics) {
                            Label {
                                Text("Désactiver les vibrations")
                            } icon: {
                                Image(systemName: "iphone.radiowaves.left.and.right")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                } header: {
                    Text("Retour haptique")
                }
					
                Section {
                    Toggle(isOn: $notificationManager.isReminder) {
                        Label {
                            Text("Activer les rappels")
                        } icon: {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.red)
                        }
                    }
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
                            Label("Ajouter un rappel", systemImage: "plus")
                        })
                    }
                } header: {
                    Text("Notifications")
                }
				
				if healthkitManager.isHealthKitAvailable() {
					Section {
                        Toggle(isOn: $saveToAppleHealth) {
                            Label {
                                Text("Synchroniser avec Santé")
                            } icon: {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.pink)
                            }
                        }
                        .onChange(of: saveToAppleHealth) { _, newValue in
                            if newValue {
                                Task {
                                    await healthkitManager.getAuthorization()
                                }
                            }
                        }
					} header: {
                        Text("Apple Health")
                    } footer: {
                        Text("La durée de chaque session sera enregistrée comme 'Mindful Minutes' dans l'application Santé.")
                    }
				}
			}
			.navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Terminé") {
						self.showSettingsView = false
					}
                    .fontWeight(.bold)
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
