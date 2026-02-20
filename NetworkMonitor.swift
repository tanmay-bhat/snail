import Foundation
import Network

class NetworkMonitor: ObservableObject {
    @Published var currentUploadSpeed: Double = 0
    @Published var currentDownloadSpeed: Double = 0
    @Published var todayUploadTotal: UInt64 = 0
    @Published var todayDownloadTotal: UInt64 = 0
    
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitorQueue")
    
    // Store previous bytes to calculate delta (speed)
    private var lastUploadBytes: UInt64 = 0
    private var lastDownloadBytes: UInt64 = 0
    private var lastUpdateDate: Date = Date()
    
    private var activeInterfaceName: String?
    
    // Daily tracking keys
    private let dailyUploadKey = "dailyUploadTotal"
    private let dailyDownloadKey = "dailyDownloadTotal"
    private let lastRecordedDayKey = "lastRecordedDay"
    
    init() {
        loadDailyTotals()
        
        pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.updateActiveInterface(from: path)
        }
    }
    
    func startMonitoring() {
        pathMonitor.start(queue: monitorQueue)
        fetchNetworkStats()
    }
    
    private func updateActiveInterface(from path: NWPath) {
        // Find primary interface
        let interfaces = path.availableInterfaces
        if let primary = interfaces.first(where: { $0.type == .wifi || $0.type == .wiredEthernet }) {
            DispatchQueue.main.async {
                self.activeInterfaceName = primary.name
            }
        } else if let fallback = interfaces.first {
            DispatchQueue.main.async {
                self.activeInterfaceName = fallback.name
            }
        }
    }
    
    func fetchNetworkStats() {
        guard let activeName = activeInterfaceName else { return }
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return }
        
        var uploadBytes: UInt64 = 0
        var downloadBytes: UInt64 = 0
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            let interface = ptr?.pointee
            guard let namePtr = interface?.ifa_name else { continue }
            let name = String(cString: namePtr)
            
            // Only count if it's the active interface
            guard name == activeName else { continue }
            
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            // AF_LINK gives us the data link layer stats
            if addrFamily == UInt8(AF_LINK) {
                let data = unsafeBitCast(interface?.ifa_data, to: UnsafeMutablePointer<if_data>.self)
                uploadBytes += UInt64(data.pointee.ifi_obytes)
                downloadBytes += UInt64(data.pointee.ifi_ibytes)
            }
        }
        
        freeifaddrs(ifaddr)
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastUpdateDate)
        
        if lastUploadBytes > 0 && lastDownloadBytes > 0 && timeInterval > 0 {
            // Check for wrap-around or network drop/reconnect
            if uploadBytes >= lastUploadBytes && downloadBytes >= lastDownloadBytes {
                let uploadDelta = uploadBytes - lastUploadBytes
                let downloadDelta = downloadBytes - lastDownloadBytes
                
                let upSpeed = Double(uploadDelta) / timeInterval
                let downSpeed = Double(downloadDelta) / timeInterval
                
                DispatchQueue.main.async {
                    self.currentUploadSpeed = upSpeed
                    self.currentDownloadSpeed = downSpeed
                    self.incrementDailyTotals(uploadDelta: uploadDelta, downloadDelta: downloadDelta)
                }
            } else {
                DispatchQueue.main.async {
                    self.currentUploadSpeed = 0
                    self.currentDownloadSpeed = 0
                }
            }
        }
        
        lastUploadBytes = uploadBytes
        lastDownloadBytes = downloadBytes
        lastUpdateDate = now
    }
    
    func formattedSpeed(bytesPerSecond: Double) -> String {
        return SettingsManager.shared.preferredUnit.format(bytesPerSecond: bytesPerSecond)
    }
    
    func formattedTotal(bytes: UInt64) -> String {
        return SettingsManager.shared.preferredUnit.formatTotal(bytes: bytes)
    }
    
    // MARK: - Daily Tracking
    private func loadDailyTotals() {
        let defaults = UserDefaults.standard
        let lastDay = defaults.string(forKey: lastRecordedDayKey)
        let currentDay = currentDayString()
        
        if lastDay == currentDay {
            todayUploadTotal = UInt64(defaults.double(forKey: dailyUploadKey))
            todayDownloadTotal = UInt64(defaults.double(forKey: dailyDownloadKey))
        } else {
            todayUploadTotal = 0
            todayDownloadTotal = 0
            defaults.set(currentDay, forKey: lastRecordedDayKey)
            saveDailyTotals()
        }
    }
    
    private func incrementDailyTotals(uploadDelta: UInt64, downloadDelta: UInt64) {
        let defaults = UserDefaults.standard
        let lastDay = defaults.string(forKey: lastRecordedDayKey)
        let currentDay = currentDayString()
        
        if lastDay != currentDay {
            todayUploadTotal = 0
            todayDownloadTotal = 0
            defaults.set(currentDay, forKey: lastRecordedDayKey)
        }
        
        todayUploadTotal += uploadDelta
        todayDownloadTotal += downloadDelta
        saveDailyTotals()
    }
    
    private func saveDailyTotals() {
        let defaults = UserDefaults.standard
        defaults.set(Double(todayUploadTotal), forKey: dailyUploadKey)
        defaults.set(Double(todayDownloadTotal), forKey: dailyDownloadKey)
    }
    
    private func currentDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
