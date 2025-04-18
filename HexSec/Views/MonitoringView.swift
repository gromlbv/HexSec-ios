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
    @EnvironmentObject var store: DomainStore
    @StateObject private var monitoringManager = MonitoringManager()

    @State private var currentDomainIndex: Int = 0
    @State private var selectedRange: TimeRange = .day
    @State private var scrollPosition: Int?
    
    @State private var isDebugMode: Bool = false
    
    @State var scaleAnimation1 = 0.7
    @State var scaleAnimation2 = 0.0
    
    enum TimeRange: String, CaseIterable {
        case day = "День"
        case week = "Неделя"
        case month = "Месяц"
    }
    
    private var currentDomain: String {
        store.domainList.indices.contains(currentDomainIndex) ? store.domainList[currentDomainIndex] : ""
    }
    
    var body: some View {
        if store.domainList.isEmpty {
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
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            NavigationView {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(Array(store.domainList.enumerated()), id: \.offset) { index, domain in
                                WebsiteExtractedView(
                                    currentStatus: monitoringManager.responseCode.map { "\($0)" } ?? "none", myDomain: domain
                                )
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
                
                
                if monitoringManager.monitoringData.isEmpty {
                    ProgressView("Загрузка...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .padding()
                        .padding(.vertical, 128)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    
                    
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            if let processingTime = monitoringManager.processingTimeMillis {
                                Text("\(processingTime) ms")
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(.white.opacity(0.2))
                                    .cornerRadius(6)
                            }
                            if let responseCode = monitoringManager.responseCode {
                                HStack(spacing: 6){
                                    Text("Ответ домена:")
                                        .font(.footnote)
                                        .opacity(0.5)
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 4, height: 4)
                                        .scaleEffect(scaleAnimation1*1.2)
                                        .opacity(1/scaleAnimation1*2)

                                        .overlay(
                                            Circle()
                                                .fill(.green)
                                                .frame(width: 4, height: 4)
                                                .scaleEffect(scaleAnimation2 * 2)
                                                .opacity(1/scaleAnimation2*6)
                                        )
                                        .onAppear {
                                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                                scaleAnimation1 = 1
                                            }
                                            
                                            withAnimation(.easeIn(duration: 3).repeatForever(autoreverses: false)) {
                                                scaleAnimation2 = 1
                                            }
                                        }
                                    
                                    Text("\(responseCode)")
                                        .foregroundStyle(.green)
                                        .font(.footnote)
                                    Image(systemName: "questionmark.circle.fill")
                                        .imageScale(.small)
                                        .opacity(0.35)
                                }
                                
                            }
                        }
                        Spacer()
                        
                        if let latestRequestDate = monitoringManager.latestRequestDate {
                            Text("Обновлено: \(latestRequestDate)")
                                .font(.footnote)
                                .opacity(0.5)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.12))
                    
                    
                    
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
                    .padding()
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
        .listRowInsets(EdgeInsets())
#if os(iOS)
        .listSectionSpacing(0)
#endif
    }
    
    private var timeRangeSection: some View {
        Section(header: Text("За промежутки времени")) {
            VStack(alignment: .leading, spacing: 12) {
                Picker("", selection: $selectedRange) {
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
    
    let currentStatus: String
    let myDomain: String
    
    let statusCode: String = "Загрузка..."
    
    var body: some View {
        HStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .font(.title)
            VStack(alignment: .leading) {
                Text(myDomain)
                    .font(.headline)
                
                ZStack {
                    if statusDescription == "Загружаю" {
                        Text("Загружаю")
                            .opacity(0.0)
                            .font(.subheadline)
                            .background(
                                LoadingGradient()
                                    .cornerRadius(8)
                            )
                            .transition(.blurReplace)
                    } else {
                        Text(statusDescription)
                            .font(.subheadline)
                            .opacity(0.5)
                            .transition(.blurReplace)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: statusDescription)
                
            }
            Spacer()
            Button {
                appViewModel.selectedTab = 2
                appViewModel.flashSection(.settingsDomains)
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
    
    var statusDescription: String {
        guard let statusCode = Int(currentStatus) else { return "Загружаю" }
        return "\(getStatusDescription(statusCode))"
    }
    
    private func getStatusDescription(_ code: Int) -> String {
        switch code {
        case 200: return "Онлайн"
        case 301: return "Редирект"
        case 302: return "Временный редирект"
        case 400: return "Некорректный запрос"
        case 401: return "Не авторизован"
        case 403: return "Запрещено"
        case 404: return "Не найдено"
        case 405: return "Метод не разрешен"
        case 408: return "Тайм-аут запроса"
        case 500: return "Внутренняя ошибка сервера"
        case 502: return "Плохой шлюз"
        case 503: return "Сервис недоступен"
        case 504: return "Шлюз не ответил вовремя"
        default: return "Статус \(code)"
        }
    }
}

struct ChartData {
    var value: Double
    var label: String
    var type: String
}

#Preview {
    MonitoringView()
        .environmentObject(DomainStore())
    
}
