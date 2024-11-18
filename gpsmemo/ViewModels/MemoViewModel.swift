import SwiftUI
import CoreLocation

class MemoViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var memos: [LocationMemo] = []
    @Published var categories: [Category] = []
    @Published var isEditingMemo = false
    @Published var selectedCategoryId: UUID?
    private var locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    private let geocoder = CLGeocoder()
    @Published var currentAddress: String?

    override init() {
        super.init()
        locationManager.delegate = self
        loadMemos()
        loadCategories()
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            reverseGeocode(location: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    func deleteMemo(at offsets: IndexSet) {
        memos.remove(atOffsets: offsets)
        saveMemos()
    }

    func getFirstLine(of text: String) -> String {
        return text.components(separatedBy: .newlines).first ?? text
    }

    func saveMemo(_ memo: LocationMemo) {
        let trimmedText = memo.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            if let index = memos.firstIndex(where: { $0.id == memo.id }) {
                memos[index] = memo
            } else {
                memos.append(memo)
            }
            saveMemos()
        }
    }

    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }

    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        memos.indices.forEach { index in
            if memos[index].categoryId == category.id {
                memos[index].categoryId = nil
            }
        }
        saveCategories()
        saveMemos()
    }

    func saveMemos() {
        if let encoded = try? JSONEncoder().encode(memos) {
            UserDefaults.standard.set(encoded, forKey: "savedMemos")
        }
    }
    
    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }

    private func loadMemos() {
        if let savedMemos = UserDefaults.standard.data(forKey: "savedMemos"),
           let decodedMemos = try? JSONDecoder().decode([LocationMemo].self, from: savedMemos) {
            memos = decodedMemos
        }
    }

    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "savedCategories")
        }
    }

    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.data(forKey: "savedCategories"),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: savedCategories) {
            categories = decodedCategories
        }
    }

    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Failed to reverse geocode location: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                self?.currentAddress = [placemark.administrativeArea, placemark.locality, placemark.subLocality]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }
        }
    }
}
