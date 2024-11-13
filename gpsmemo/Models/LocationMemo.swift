
import Foundation
import CoreLocation

struct LocationMemo: Identifiable, Codable {
    let id: UUID
    var text: String
    var location: CLLocationCoordinate2D?
    var categoryId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case id, text, latitude, longitude, categoryId
    }
    
    init(id: UUID = UUID(), text: String, location: CLLocationCoordinate2D? = nil, categoryId: UUID? = nil) {
        self.id = id
        self.text = text
        self.location = location
        self.categoryId = categoryId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        if let latitude = latitude, let longitude = longitude {
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        categoryId = try container.decodeIfPresent(UUID.self, forKey: .categoryId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(location?.latitude, forKey: .latitude)
        try container.encodeIfPresent(location?.longitude, forKey: .longitude)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
    }
}