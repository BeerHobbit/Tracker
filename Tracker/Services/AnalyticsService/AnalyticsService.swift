import AppMetricaCore

struct AnalyticsService {
    
    // MARK: - Public Methods
    
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "2d295bfe-01e2-433e-b684-8f3a0c5ce826") else {
            print("❌[AnalyticsService.activate()] Failed to create AppMetrica Configuration")
            return
        }
        
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?) {
        var params: [AnyHashable: Any] = [
            AnalyticsParameter.screen.rawValue: screen.rawValue
        ]
        switch event {
        case .open, .close: break
        case .click:
            if let item {
                params[AnalyticsParameter.item.rawValue] = item.rawValue
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
    
    private func log(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?) {
        let itemString = item?.rawValue ?? "nil"
        print("""
            📊[AppMetrica]
            event: \(event.rawValue),
            screen: \(screen.rawValue),
            item: \(itemString)
            """)
    }
    
}

