//
//  NewSSE.swift
//  HexSec
//
//  Created by dmitry lbv on 07.04.2025.
//

import SwiftUI
import Charts

struct MonitoringView: View {
    @ObservedObject var appViewModel = AppViewModel.shared
    @StateObject private var monitoringManager = MonitoringManager()
    
    @State private var currentDomainIndex: Int = 0
    @State private var selectedRange: TimeRange = .day
    @State private var scrollPosition: Int?
    
    @State private var isDebugMode: Bool = false
    
    
    enum TimeRange: String, CaseIterable {
        case day = "День"
        case week = "Неделя"
        case month = "Месяц"
    }
    
    private var currentDomain: String {
        appViewModel.domains.indices.contains(currentDomainIndex) ? appViewModel.domains[currentDomainIndex] : ""
    }
    
    var body: some View {
        if appViewModel.domains.isEmpty {
            VStack(spacing: 24) {
                
                Text("Добавьте домен во вкладке Настройки и перезагрузите приложение")
                    .multilineTextAlignment(.center)
                    .opacity(0.6)
                
                Button {
                    appViewModel.selectedTab = 2
                    AppViewModel.shared.flashSection(.settingsDomains)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                        .background {
                            Circle()
                                .fill()
                                .foregroundColor(.white)
                                .frame(width: 47, height: 47)
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            NavigationView {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(Array(appViewModel.domains.enumerated()), id: \.offset) { index, domain in
                                WebsiteExtractedView(myDomain: domain)
                                    .id(index)
                                    .containerRelativeFrame(.horizontal, count: 1, spacing: 6)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0.5)
                                            .grayscale(phase.isIdentity ? 0 : 1)
                                        //.offset(x: phase.value * (phase.isIdentity ? 0 : -80))
                                    }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $scrollPosition)
                    .scrollTargetBehavior(.viewAligned)
                    .frame(height: 90)
                    
                    .contentMargins(.trailing, 42, for: .scrollContent)
                    .contentMargins(.leading, 18, for: .scrollContent)
                    
                    
                    Divider()
                    
                    Form {
                        realtimeSection
                        timeRangeSection
                    }
                }
                .refreshable {
                    monitoringManager.start(domain: currentDomain)
                }
                .onChange(of: scrollPosition) { _, newValue in
                    if let newValue {
                        currentDomainIndex = newValue
                        monitoringManager.start(domain: currentDomain)
                    }
                }
                .onAppear {
                    monitoringManager.start(domain: currentDomain)
                }
            }
        }
    }
    
    private var realtimeSection: some View {
        Section(header: Text("В реальном времени")) {
            VStack(spacing: 24) {
                HStack {
                    if let processingTime = monitoringManager.processingTimeMillis {
                        Text("\(processingTime) ms")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.accentColor)
                            .cornerRadius(.infinity)
                        Spacer()
                    }
                    Spacer()
                    
                    // Отображаем дату обновления
                    if let latestRequestDate = monitoringManager.latestRequestDate {
                        Text("Обновлено: \(latestRequestDate)")
                            .font(.footnote)
                            .opacity(0.5)
                    }
                }
                
                if monitoringManager.monitoringData.isEmpty {
                    ProgressView("Загрузка...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .padding()
                } else {
                    
                    Chart(monitoringManager.monitoringData) { data in
                        LineMark(
                            x: .value("Дата", data.label),
                            y: .value("Время обработки", data.value)
                        )
                        .foregroundStyle(Color.accentColor)
                        .interpolationMethod(.cardinal)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .butt))
                    }
                    .chartLegend(position: .top, alignment: .leading)
                    .tint(Color.accentColor)
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: 1))
                    }
                    .padding(.bottom)
                    
                }
                
                if isDebugMode {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Дебаг данные:")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        ForEach(monitoringManager.debug, id: \.self) { message in
                            Text(message)
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        
                        if let responseCode = monitoringManager.responseCode {
                            Text("Response Code: \(responseCode)")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        
                        if let processingTime = monitoringManager.processingTimeMillis {
                            Text("Processing Time: \(processingTime) ms")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.leading, 10)
                }
            }
        }
    }
    
    private var timeRangeSection: some View {
        Section(header: Text("За промежутки времени")) {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Выберите диапазон", selection: $selectedRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                
                switch selectedRange {
                case .day: DayView
                case .week: DayView
                case .month: DayView
                }
            }
        }
    }
    
    private var DayView: some View {
        VStack{
            Text("Позже здесь будут графики за дни и недели")
                .font(.footnote)
                .opacity(0.5)
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct WebsiteExtractedView: View {
    @ObservedObject var appViewModel = AppViewModel.shared
    let myDomain: String
    
    var body: some View {
        HStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .font(.title)
            VStack(alignment: .leading) {
                Text(myDomain)
                    .font(.headline)
                Text("Онлайн")
                    .font(.subheadline)
                    .opacity(0.5)
            }
            Spacer()
            Button {
                appViewModel.selectedTab = 2
                AppViewModel.shared.flashSection(.settingsDomains)
            } label: {
                Image(systemName: "gear")
                    .foregroundStyle(.white)
            }
            .padding(8)
            .background(.accent)
            .cornerRadius(10)
        }
        .padding()
        .frame(height: 81)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(.infinity)
    }
}

struct ChartData {
    var value: Double
    var label: String
    var type: String
}

#Preview {
    MonitoringView()
}
