import Foundation
import CoreLocation

struct Memo {
    var text: String
    var location: CLLocation?
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
}

// ContentViewやAddMemoViewでLocationManagerを使用して、
// 現在の位置情報を取得し、メモと一緒に保存する。

