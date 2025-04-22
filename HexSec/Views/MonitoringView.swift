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
                    
                    VStack {
                        if let processingTime = monitoringManager.processingTimeMillis {
                            VStack{
                                Text("Среднее время отклика")
                                    .font(.callout)
                                    .opacity(0.5)
                                HStack(alignment: .bottom){
                                    Text("\(processingTime)")
                                        .font(.system(size: 100, weight: .bold, design: .default))
                                        .foregroundStyle(Color.accentColor)
                                    Text("ms")
                                        .font(.headline)
                                }
                            }
                            
                            
                            .transition(.opacity)
                            
                            //if let latestRequestDate = monitoringManager.latestRequestDate {
                            //    Text("Обновлено: \(latestRequestDate)")
                            //        .font(.footnote)
                            //        .opacity(0.5)
                            //}
                        }
                        
                        VStack{
                            realtimeSection
                            
                            VStack{
                                tableSection
                                
                                Button {
                                    
                                } label: {
                                    Text("Статистика за месяц")
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.accentColor)
                                }
                                .frame(width: 238, alignment: .top)
                                .background(Color(red: 0.49, green: 0, blue: 0.1).opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                    .inset(by: 0.5)
                                    .stroke(.white.opacity(0.08), lineWidth: 1)
                                )
                            }
                            
                            
                        }

                        Spacer()
                    }
                    .padding(.top, 46)
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
        let curGradient = LinearGradient(
            gradient: Gradient (
                colors: [
                    Color(Color.accentColor).opacity(0.1),
                    Color(Color.accentColor).opacity(0.0)
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
        
        
        return Chart(monitoringManager.monitoringData) { data in
            LineMark(
                x: .value("Дата", data.label),
                y: .value("Время обработки", data.value)
            )
            
            //.annotation(position: .top) {
            //    Text("\(data.label)")
            //        .font(.system(size: 18, weight: .semibold, design: .rounded))
            //        .foregroundStyle(.accentColor)
            //}
            .foregroundStyle(Color.accentColor)
            //.interpolationMethod(.cardinal)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .butt))
            
            AreaMark(
                x: .value("Дата", data.label),
                y: .value("Время обработки", data.value)
            )
            .foregroundStyle(curGradient)

        }
        .chartLegend(position: .top, alignment: .leading)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        
        .tint(Color.accentColor)
        
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    private var tableSection: some View {
        HStack {
            VStack(alignment: .leading, spacing:16) {
                Text("200")
                    .font(.headline)
                Text("Код ответа сайта")
                    .opacity(0.5)
            }
            .padding(.leading, 12)
            .padding(.trailing, 9)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(.white.opacity(0.03))

            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.5)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing:16) {
                Text("Только что")
                    .font(.headline)
                Text("Обновлено")
                    .opacity(0.5)
            }
            .padding(.leading, 12)
            .padding(.trailing, 9)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(.white.opacity(0.03))
            //.background(.ultraThinMaterial)

            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.5)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
                    .fill(.clear)
                
            )
        }
        .padding()
        .padding(.top, 200)

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
            .background(.red) //accentColor
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
