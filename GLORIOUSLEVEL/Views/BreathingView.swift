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
					SettingsView(modelData: breathingViewModel, notificationManager: notificationManager, healthkitManager: breathingViewModel.HKManager, showSettingsView: $showSettingsView)
				}
			}
			
			Text(breathingPlanSelection.description)
				.font(.largeTitle)
				.fontWeight(.light)
				.fontDesign(.rounded)
			
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
			
			Spacer()
				
			ZStack {
				Circle()
					.stroke(Color.blue, lineWidth: 3)
					.frame(width: 250, height: 250, alignment: .center)
					.scaleEffect(breathingViewModel.getScale(state: breathingViewModel.currentState))
					.opacity(breathingViewModel.getOpacity(state: breathingViewModel.currentState))
					.animation(.easeInOut(duration: Double(breathingViewModel.currentState == BreathingState.initial ? 3 : breathingViewModel.getDuration(state: breathingViewModel.currentState))), value: breathingViewModel.currentState)
				
				VStack {
					Text(breathingViewModel.breathingMessage)
						.font(.title2)
						.bold()
						.multilineTextAlignment(.center)

					Text(breathingViewModel.timeRemaining, format: .number)
						.font(.system(size: 48, weight: .semibold))
					Text("s")
						.font(.subheadline)
				}
			}
			.frame(width: 300, height: 300, alignment: .center)
			
			if breathingViewModel.currentState == .initial {
				Text("\(breathingViewModel.cycleNumber) \(breathingViewModel.cycleNumber == 1 ? "cycle" : "cycles")")
					.font(.system(size: 32, weight: .semibold))
			} else {
				Text("\(breathingViewModel.cycleRemaining) \(breathingViewModel.cycleRemaining == 1 ? "cycle restant" : "cycles restants")")
					.font(.system(size: 32, weight: .semibold))
			}
			
			HStack(spacing: 20) {
				if breathingViewModel.inhaleTime > 0 {
					TimeIndicator(label: "In", value: "\(breathingViewModel.inhaleTime)s")
				}
				if breathingViewModel.holdFullTime > 0 {
					TimeIndicator(label: "Hold", value: "\(breathingViewModel.holdFullTime)s")
				}
				if breathingViewModel.exhaleTime > 0 {
					TimeIndicator(label: "Out", value: "\(breathingViewModel.exhaleTime)s")
				}
				if breathingViewModel.holdEmptyTime > 0 {
					TimeIndicator(label: "Rest", value: "\(breathingViewModel.holdEmptyTime)s")
				}
			}
			.padding(.top, 20)

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

struct TimeIndicator: View {
	var label: String
	var value: String
	var body: some View {
		VStack {
			Text(label).font(.caption).foregroundColor(.gray)
			Text(value).font(.headline)
		}
	}
}

#Preview {
	BreathingView(breathingViewModel: BreathingViewModel(), breathingPlanSelection: BreathingPlan.m365, showSettingsView: false)
		.preferredColorScheme(.dark)
}
