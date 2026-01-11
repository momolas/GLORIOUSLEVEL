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
	@State var showNotificationScheduler = false
	
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
					
                    Button(action: {
                        self.showNotificationScheduler.toggle()
                    }) {
                        Label("Gérer les rappels", systemImage: "clock")
                            .foregroundStyle(.white)
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
            .sheet(isPresented: $showNotificationScheduler) {
                NotificationSchedulerView(notificationManager: notificationManager)
            }
		}
	}
}

#Preview {
	SettingsView(modelData: BreathingViewModel(), notificationManager: NotificationManager(), healthkitManager: HealthKitManager(), showSettingsView: .constant(true))
		.environment(BreathingViewModel())
		.preferredColorScheme(.dark)
}

