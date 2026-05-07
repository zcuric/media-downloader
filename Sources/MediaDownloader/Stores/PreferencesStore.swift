import Foundation

final class PreferencesStore {
    private let key = "downloadFolderPath"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var downloadFolder: URL {
        get {
            if let path = defaults.string(forKey: key), !path.isEmpty {
                return URL(fileURLWithPath: path, isDirectory: true)
            }

            let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            return downloads
                ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Downloads", isDirectory: true)
        }
        set {
            defaults.set(newValue.path, forKey: key)
        }
    }
}
