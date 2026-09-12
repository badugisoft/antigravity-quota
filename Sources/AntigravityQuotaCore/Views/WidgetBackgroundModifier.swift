import SwiftUI
import WidgetKit

extension View {
    @ViewBuilder
    public func applyWidgetBackground() -> some View {
        if #available(macOS 14.0, iOS 17.0, *) {
            self.containerBackground(.regularMaterial, for: .widget)
        } else {
            self.background(.regularMaterial)
        }
    }
}
