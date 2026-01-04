//
//  ProgressView.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 05/10/2022.
//

import SwiftUI

struct ProgressView: View {
	
	var breathingViewModel: BreathingViewModel
	
	var body: some View {
		
		ZStack {
			Circle()
				.stroke(Color.blue.opacity(0.5), lineWidth: 30)
			
			Circle()
				.trim(from: 0, to: CGFloat(breathingViewModel.timeRemaining))
				.stroke(Color.blue, style: StrokeStyle(lineWidth: 30, lineCap: .round))
				.rotationEffect(.degrees(-90))
				.animation(.easeOut, value: breathingViewModel.timeRemaining/100)
			
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
		.frame(width: 300, height: 300)
	}
}

#Preview {
	ProgressView(breathingViewModel: BreathingViewModel())
		.preferredColorScheme(.dark)
		.environment(BreathingViewModel())
}
