//
//  TrendView.swift
//  WeightTracker
//
//  Created by James Maguire on 22/09/2022.
//

import SwiftUI
import Charts

struct TrendView: View {
    var dataStore: DataStore
    
    func getStrideCount(entries: [WeightEntry]) -> Int {
        if dataStore.dateRange < 5 {
            return 1
        }
        return Int(ceil(Double(dataStore.dateRange) / 5))
    }
    
    var body: some View {
        VStack {
            Chart {
                ForEach(dataStore.lastDays(days: 30), id: \.date) {
                    LineMark(
                        x: .value("Date", $0.date, unit: .hour),
                        y: .value("Weight", dataStore.sevenDayWeight(date: $0.date) - 95)
                    )
                    .foregroundStyle(by: .value("Value", "Weight"))
                    
                    LineMark(
                        x: .value("Date", $0.date, unit: .hour),
                        y: .value("Fat %", dataStore.sevenDayFat(date: $0.date) - 25)
                    )
                    .foregroundStyle(by: .value("Value", "Body Fat"))
                }
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: getStrideCount(entries: dataStore.entries))) {
                    _ in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel(anchor: UnitPoint(x: 0.5, y: 0))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .stride(by: 2)) {
                    axis in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel(String(format: "\((axis.as(Double.self) ?? 0) + 95) kg"))
                }
                AxisMarks(position: .trailing, values: .stride(by: 2)){
                    axis in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel(String(format: "\((axis.as(Double.self) ?? 0) + 25) %%"))
                }
            }
        }
    }
}

struct TrendView_Previews: PreviewProvider {
    static var previews: some View {
        TrendView(dataStore: DataStore.sampleData)
            .frame(height: 100)
            .padding(20)
    }
}
