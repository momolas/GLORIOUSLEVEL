//
//  HeartbeatView.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 11/10/2022.
//

import SwiftUI
import HealthKit

struct HeartbeatView: View {
	@State var labelText = "Données Cardiaques"
	@State var flag = false

	let healthStore = HKHealthStore()
	let allTypes = Set([
		HKSeriesType.heartbeat(),
		HKObjectType.quantityType(forIdentifier: .heartRate)!,
		HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
	])

	var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.red.gradient)
                    .symbolEffect(.pulse)

                Text(labelText)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()

                Button(action: {
                    if flag {
                        labelText = "Prêt"
                        flag = false
                    } else {
                        if HKHealthStore.isHealthDataAvailable() {
                            labelText = "Chargement..."
                            healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
                                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
                                let query = HKSampleQuery(sampleType: HKSeriesType.heartbeat(), predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (_, samples, _) in
                                    DispatchQueue.main.async {
                                        if let sample = samples?.first as? HKHeartbeatSeriesSample {
                                            print("series start:\(sample.startDate)\tend:\(sample.endDate)")
                                            let seriesQuery = HKHeartbeatSeriesQuery(heartbeatSeries: sample) {
                                                query, timeSinceSeriesStart, precededByGap, done, error in
                                                let formatted = String(format: "%.2f", timeSinceSeriesStart)
                                                print("timeSinceSeriesStart:\(formatted)\tprecededByGap:\(precededByGap)\t done:\(done)")
                                            }
                                            healthStore.execute(seriesQuery)
                                            labelText = "Données récupérées (Console)"
                                        } else {
                                            labelText = "Aucune donnée récente"
                                        }
                                    }
                                }
                                healthStore.execute(query)
                            }
                        } else {
                            labelText = "HealthKit Indisponible"
                        }
                        flag = true
                    }
                }) {
                    Text("Charger les données")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(Capsule())
                        .shadow(radius: 10)
                }
                .padding(.bottom, 40)
            }
        }
	}
}

#Preview {
	HeartbeatView(labelText: "Prêt", flag: false)
}
