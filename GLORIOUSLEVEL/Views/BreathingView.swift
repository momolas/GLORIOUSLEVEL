//
//  ContentView.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 05/10/2022.
//

import SwiftUI

struct BreathingView: View {
	
	@State var breathingViewModel = BreathingViewModel()
    @State var notificationManager = NotificationManager()
	@State var breathingPlanSelection = BreathingPlan.m365
	@State var showSettingsView = false
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Button("Settings", systemImage: "slider.horizontal.3") {
					self.showSettingsView.toggle()
				}
                .labelStyle(.iconOnly)
                .font(.system(size: 20))
                .frame(width: 60, height: 20)
				.sheet(isPresented: $showSettingsView) {
					SettingsView(modelData: breathingViewModel, notificationManager: notificationManager, healthkitManager: HealthKitManager(), showSettingsView: $showSettingsView)
				}
			}
			
			Text(breathingPlanSelection.description)
				.font(.largeTitle)
			
			Picker(selection: $breathingPlanSelection, label: Text("Sélectionnez un plan")) {
				ForEach(BreathingPlan.allCases, id: \.self) { plan in
					Text(plan.rawValue)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			.onChange(of: breathingPlanSelection) { _, _ in
				breathingViewModel.toggleBreathingPlan(breathingPlanSelected: breathingPlanSelection)
			}
			
			Spacer()
			
			Text(breathingViewModel.breathingMessage)
				.font(.largeTitle)
			
			Spacer()
				
			ZStack {
				Circle()
					.frame(width: 300, height: 300, alignment: .center)
					.foregroundStyle(Color(white: 0.15))
				Circle()
					.frame(width: 100, height: 100, alignment: .center)
					.foregroundStyle(Color(white: 0.3))
					.scaleEffect(breathingViewModel.getScale(state: breathingViewModel.currentState))
					.animation(.easeInOut(duration: Double(breathingViewModel.currentState == BreathingState.initial ? 3 : breathingViewModel.getDuration(state: breathingViewModel.currentState))), value: breathingViewModel.getScale(state: breathingViewModel.currentState))
				
                Text(breathingViewModel.timeRemaining, format: .number)
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
					.bold()
					.padding(.horizontal, 24)
					.padding(.vertical, 10)
					.background(.thinMaterial)
					.clipShape(.rect(cornerRadius: 5))
			})
			
		}
		.navigationBarBackButtonHidden(true)
		.padding()
	}
}

#Preview {
	BreathingView(breathingViewModel: BreathingViewModel(), breathingPlanSelection: BreathingPlan.m365, showSettingsView: false)
		.preferredColorScheme(.dark)
}
