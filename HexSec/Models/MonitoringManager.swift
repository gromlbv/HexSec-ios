import Foundation
import EventSource

@MainActor
class MonitoringManager: ObservableObject {
    @Published var rawMessages: [String] = []
    @Published var debug: [String] = []
    @Published var isRunning: Bool = false
    @Published var latestRequestDate: String?
    @Published var responseCode: Int?
    @Published var processingTimeMillis: String?

    @Published var monitoringData: [MonitoringData] = []
    
    private var task: Task<Void, Never>? = nil
    private var currentDomain: String? = nil
    
    func start(domain: String) {
        clear()
        stop()
        isRunning = true
        currentDomain = domain
        
        var userId = 0
        userId = .random(in: 1...5)
        task = Task {
            guard let url = URL(string: "https://just-wholly-osprey.ngrok-free.app/load/monitoring/start?domain=\(domain)&userId=\(userId)") else {
                rawMessages.append("Невалидный URL")
                isRunning = false
                return
            }

            let eventSource = EventSource()
            let request = URLRequest(url: url)
            let dataTask = await eventSource.dataTask(for: request)

            for await event in await dataTask.events() {
                switch event {
                case .open:
                    debug.append("started for \(domain)")
                case .event(let event):
                    let name = event.event ?? "unnamed"
                    if name == "load monitoring" {
                        if let data = event.data?.data(using: .utf8) {
                            let decoder = JSONDecoder()
                            do {
                                let response = try decoder.decode(MonitoringResponse.self, from: data)
                                DispatchQueue.main.async {
                                    let formattedTime = self.formatLastUpdateTime(response.requestDate)
                                    let newData = MonitoringData(
                                        label: formattedTime,
                                        value: Double(response.processingTimeMillis)
                                    )
                                    self.monitoringData.append(newData)
                                    
                                    if self.monitoringData.count > 20 {
                                        self.monitoringData.removeFirst(self.monitoringData.count - 20)
                                    }

                                    self.latestRequestDate = formattedTime
                                    self.responseCode = response.responseCode
                                    self.processingTimeMillis = self.formatTime(milliseconds: response.processingTimeMillis)
                                }
                            } catch {
                                debug.append("Ошибка при декодировании JSON: \(error)")
                            }
                        }
                        rawMessages.append(event.data ?? "")
                    }
                    debug.append("new event: \(name)")

                case .error(let error):
                    debug.append("error: \(error.localizedDescription)")
                case .closed:
                    debug.append("closed by server")
                    isRunning = false
                }
            }

            isRunning = false
        }
    }
    
    struct MonitoringData: Identifiable, Equatable {
        var id = UUID()
        var label: String
        var value: Double
    }

    struct MonitoringResponse: Codable {
        var responseCode: Int
        var requestDate: String
        var processingTimeMillis: Int
    }
    
    func stop() {
        task?.cancel()
        task = nil
        isRunning = false
    }

    func clear() {
        rawMessages.removeAll()
        debug.removeAll()
        monitoringData.removeAll()
        latestRequestDate = nil
        responseCode = nil
        processingTimeMillis = nil
    }

    func updateDomain(domain: String) {
        stop()
        clear()
        start(domain: domain)
    }

    func getCurrentDomain() -> String {
        return currentDomain ?? "task inactive"
    }
    
    func formatLastUpdateTime(_ requestDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        if let date = formatter.date(from: requestDate) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            return timeFormatter.string(from: date)
        } else {
            return "Invalid Date"
        }
    }

    func formatTime(milliseconds: Int) -> String {
        return "\(milliseconds)"
    }
}
