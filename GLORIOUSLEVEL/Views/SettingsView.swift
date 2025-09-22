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
	var healthkitManager: HealthKitManager
	
	@State var showSettingsView: Bool
	@State var showTimePickerModal = false
	
	@AppStorage("reduce_haptics") var reduceHaptics = false
	@AppStorage("tense_time") var tenseTime = TimeConstants.defaultTensionTime
	@AppStorage("relax_time") var relaxTime = TimeConstants.defaultRelaxTime
	@AppStorage("reps_count") var totalReps = TimeConstants.defaultTotalReps
//	@AppStorage("save_healthkit") var saveToAppleHealth = healthkitManager.isHealthKitAvailable()
	
	var body: some View {
		NavigationView {
			List {
				Section(header: Text("Paramètres")) {
					Stepper(value: $tenseTime, in: 1...30) {
						HStack {
							ZStack {
								Image(systemName: "wave.3.left")
									.foregroundColor(.white)
									.font(.callout)
							}
							.frame(width: 28, height: 28)
							.background(Color.blue)
							.cornerRadius(6)
							Text("Contraction: \(tenseTime) \(tenseTime == 1 ? "seconde" : "secondes")")
						}
					}
					
					Stepper(value: $relaxTime, in: 1...30) {
						HStack {
							ZStack {
								Image(systemName: "wave.3.right")
									.foregroundColor(.white)
									.font(.callout)
							}
							.frame(width: 28, height: 28)
							.background(Color.blue)
							.cornerRadius(6)
							Text("Relachement: \(relaxTime) \(relaxTime == 1 ? "seconde" : "secondes")")
						}
					}
					
					Stepper(value: $totalReps, in: 1...50) {
						HStack {
							ZStack {
								Image(systemName: "repeat")
									.foregroundColor(.white)
									.font(.callout)
							}
							.frame(width: 28, height: 28)
							.background(Color.green)
							.cornerRadius(6)
							Text("\(totalReps) \(totalReps == 1 ? "répétition" : "répétitions")")
						}
					}
					
					if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
						Toggle(isOn: $reduceHaptics) {
							HStack {
								ZStack {
									Image(systemName: "iphone.radiowaves.left.and.right")
										.foregroundColor(.white)
										.font(.callout)
								}
								.frame(width: 28, height: 28)
								.background(Color.orange)
								.cornerRadius(6)
								Text("Désactiver les vibration")
							}
						}
					}
					
					HStack {
						Toggle(
							isOn: $modelData.isReminder,
							label: {
								Label("Rappels", systemImage: "clock")
									.foregroundColor(.white)
							}
						)
					}
					
					Button(action: {
						self.showTimePickerModal.toggle()
					}, label: {
						Text("Ajouter un rappel")
					})
					.disabled(!modelData.isReminder)
					
					Button(action: {
						tenseTime = TimeConstants.defaultTensionTime
						relaxTime = TimeConstants.defaultRelaxTime
						totalReps = TimeConstants.defaultTotalReps
					}) {
						Text("Réinitialiser")
					}
				}
				
//				if healthkitManager.isHealthKitAvailable() {
//					Section(footer: Text("The duration of each session will be saved in Apple Health as Mindful Minutes. If access has been previously revoked, this toggle will have no effect. Access will need to be granted through Settings > Privacy > Inhale.")) {
//						Toggle(isOn: $saveToAppleHealth) {
//							HStack {
//								ZStack {
//									Image(systemName: "heart.fill")
//										.foregroundColor(.white)
//										.font(.callout)
//								}
//								.frame(width: 28, height: 28)
//								.background(Color.red)
//								.cornerRadius(6)
//								Text("Save to Apple Health")
//							}
//						}
//						.onTapGesture {
//							print("Tap \(saveToAppleHealth)")
//							
//							// if the bool is false, this means the person just tapped it to toggle it to true
//							if !saveToAppleHealth {
//								healthkitManager.getAuthorization()
//							}
//						}
//					}
//				}
			}
			.listStyle(GroupedListStyle())
			.navigationTitle("Paramètres")
			.navigationBarItems(
				trailing: Button(
					action: {
						self.showSettingsView = false
					}
				) {
					Text("Terminé")
						.bold()
				}
			)
		}
	}
}

#Preview {
	SettingsView(modelData: BreathingViewModel(), healthkitManager: HealthKitManager(), showSettingsView: true)
		.environment(BreathingViewModel())
		.preferredColorScheme(.dark)
}
