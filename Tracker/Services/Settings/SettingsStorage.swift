import Foundation

final class SettingsStorage: SettingsStorageProtocol {
    
    var didFinishOnboarding: Bool {
        get { storage.bool(forKey: Keys.didFinishOnboarding) }
        set { storage.set(newValue, forKey: Keys.didFinishOnboarding) }
    }
    
    private let storage = UserDefaults.standard
    
    private enum Keys {
        static let didFinishOnboarding = "didFinishOnboarding"
    }
    
}
