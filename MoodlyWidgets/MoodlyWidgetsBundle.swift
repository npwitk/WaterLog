import SwiftUI
import WidgetKit

@main
struct MoodlyWidgetsBundle: WidgetBundle {
    var body: some Widget {
        MoodWidget()
        GreatDayControl()
    }
}
