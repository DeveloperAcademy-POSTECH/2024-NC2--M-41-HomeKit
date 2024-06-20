import SwiftData
import Foundation

@Model
final class BookmarkModel {
    @Attribute(.unique) var id = UUID()
    var title: String
//    var
    
    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}
