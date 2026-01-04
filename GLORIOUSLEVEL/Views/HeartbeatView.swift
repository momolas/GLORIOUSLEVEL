//
//  HeartbeatView.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 11/10/2022.
//

import SwiftUI
import HealthKit

struct HeartbeatView: View {
	@State var labelText = "Get Data"
	@State var flag = false
	
	let healthStore = HKHealthStore()
	let allTypes = Set([
		HKSeriesType.heartbeat(),
		HKObjectType.quantityType(forIdentifier: .heartRate)!,
		HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
	])
	
	var body: some View {
		
		VStack {
			Text(labelText)
				.font(.largeTitle)
				.padding(.bottom)
			
			Button(action: {
				if flag {
					labelText = "Données récupérées"
					flag = false
				} else {
					if HKHealthStore.isHealthDataAvailable() {
						labelText = "Succès !"
						healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
							let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
							let query = HKSampleQuery(sampleType: HKSeriesType.heartbeat(), predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (_, samples, _) in
								if let sample = samples?.first as? HKHeartbeatSeriesSample {
									print("series start:\(sample.startDate)\tend:\(sample.endDate)")
									let seriesQuery = HKHeartbeatSeriesQuery(heartbeatSeries: sample) {
										query, timeSinceSeriesStart, precededByGap, done, error in
										let formatted = String(format: "%.2f", timeSinceSeriesStart)
										print("timeSinceSeriesStart:\(formatted)\tprecededByGap:\(precededByGap)\t done:\(done)")
									}
									healthStore.execute(seriesQuery)
								}
							}
							healthStore.execute(query)
						}
					} else {
						labelText = "Indisponible"
					}
					flag = true
				}
			}) {
				Text("Charger les données")
					.font(.title3)
					.bold()
					.padding(.horizontal, 24)
					.padding(.vertical, 10)
					.background(.thinMaterial)
					.clipShape(.rect(cornerRadius: 5))
			}
		}
	}
}

#Preview {
	HeartbeatView(labelText: "Get Data", flag: false)
}
