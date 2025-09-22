//
//  ContentView.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 05/10/2022.
//

import SwiftUI

struct BreathingView: View {
	
	var breathingViewModel = BreathingViewModel()
	@State var breathingPlanSelection = BreathingPlan.m365
	@State var showSettingsView = false
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Button(action: {
					self.showSettingsView.toggle()
				}) {
					Image(systemName: "slider.horizontal.3")
						.font(.system(size: 20))
						.frame(width: 60, height: 20)
				}
				.sheet(isPresented: $showSettingsView) {
					SettingsView(modelData: BreathingViewModel(), healthkitManager: HealthKitManager(), showSettingsView: self.showSettingsView)
				}
			}
			
			Text("\(breathingPlanSelection.description)" as String)
				.font(.largeTitle)
			
			Picker(selection: $breathingPlanSelection, label: Text("Sélectionnez un plan")) {
				ForEach(BreathingPlan.allCases, id: \.self) { plan in
					Text(plan.rawValue)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			.onChange(of: breathingPlanSelection) {
				breathingViewModel.toggleBreathingPlan(breathingPlanSelected: breathingPlanSelection)
			}
			
			Spacer()
			
			Text(breathingViewModel.breathingMessage)
				.font(.largeTitle)
			
			Spacer()
				
			ZStack {
				Circle()
					.frame(width: 300, height: 300, alignment: .center)
					.foregroundColor(Color(white: 0.15))
				Circle()
					.frame(width: 100, height: 100, alignment: .center)
					.foregroundColor(Color(white: 0.3))
					.scaleEffect(breathingViewModel.getScale(state: breathingViewModel.currentState))
					.animation(.easeInOut(duration: Double(breathingViewModel.currentState == BreathingState.initial ? 3 : breathingViewModel.getDuration(state: breathingViewModel.currentState))), value: breathingViewModel.getScale(state: breathingViewModel.currentState))
				
				Text("\(breathingViewModel.timeRemaining)")
					.font(.system(size: 48, weight: .semibold))
			}
			.frame(width: 300, height: 300, alignment: .center)
			
			if breathingViewModel.currentState == .initial {
				Text("\(breathingViewModel.cycleNumber) \(breathingViewModel.cycleNumber == 1 ? "cycle" : "cycles")")
					.font(.system(size: 32, weight: .semibold))
			} else {
				Text("\(breathingViewModel.cycleRemaining) \(breathingViewModel.cycleRemaining == 1 ? "cycle restant" : "cycles restants")")
					.font(.system(size: 32, weight: .semibold))
			}
			
			Spacer()
			
			Button(action: {
				breathingViewModel.startBreathing()
			}, label: {
				Text(breathingViewModel.currentState != .initial ? "Terminer" : "Démarrer")
					.font(.title3)
					.fontWeight(.semibold)
					.padding(.horizontal, 24)
					.padding(.vertical, 10)
					.background(.thinMaterial)
					.cornerRadius(5)
			})
			
		}
		.navigationBarBackButtonHidden(true)
		.padding()
		.onReceive(breathingViewModel.timer) { _ in
			breathingViewModel.trackBreathing()
		}
	}
}

#Preview {
	BreathingView(breathingViewModel: BreathingViewModel(), breathingPlanSelection: BreathingPlan.m365, showSettingsView: false)
		.preferredColorScheme(.dark)
}
