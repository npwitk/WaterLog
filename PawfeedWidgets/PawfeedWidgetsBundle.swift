import SwiftUI
import WidgetKit

@main
struct PawfeedWidgetsBundle: WidgetBundle {
    var body: some Widget {
        PetsWidget()
        FeedControl()
    }
}
