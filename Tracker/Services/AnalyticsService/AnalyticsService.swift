import AppMetricaCore

struct AnalyticsService {
    
    // MARK: - Types
    
    enum Event: String {
        case open
        case close
        case click
    }
    
    enum Parameter: String {
        case screen
        case item
    }
    
    enum Screen: String {
        case trackerList = "TrackerListViewController"
    }
    
    enum Item: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete
    }
    
    // MARK: - Public Methods
    
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "2d295bfe-01e2-433e-b684-8f3a0c5ce826") else {
            print("❌[AnalyticsService.activate()] Failed to create AppMetrica Configuration")
            return
        }
        
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: Event, screen: Screen, item: Item?) {
        var params: [AnyHashable: Any] = [
            Parameter.screen.rawValue: screen.rawValue
        ]
        switch event {
        case .open, .close: break
        case .click:
            if let item {
                params[Parameter.item.rawValue] = item.rawValue
            }
        }
        
        AppMetrica.reportEvent(
            name: event.rawValue,
            parameters: params,
            onFailure: { error in
                print("❌[AppMetrica.reportEvent()] Failed to report event: \(event), error: \(error)")
            }
        )
        
        log(event: event, screen: screen, item: item)
    }
    
    // MARK: - Private Methods
    
    private func log(event: Event, screen: Screen, item: Item?) {
        let itemString = item?.rawValue ?? "nil"
        print("""
            📊[AppMetrica]
            event: \(event.rawValue),
            screen: \(screen.rawValue),
            item: \(itemString)
            """)
    }
    
}

