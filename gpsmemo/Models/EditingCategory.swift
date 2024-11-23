import Foundation

enum EditingCategory: Identifiable {
    case new
    case edit(Category)
    
    var id: String {
        switch self {
        case .new:
            return "new"
        case .edit(let category):
            return category.id.uuidString
        }
    }
}
