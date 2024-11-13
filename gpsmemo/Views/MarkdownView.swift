import SwiftUI

struct MarkdownView: View {
    var markdownText: String

    var body: some View {
        if let attributedString = try? AttributedString(markdown: markdownText) {
            Text(attributedString)
                .padding()
        } else {
            Text("Failed to render Markdown")
                .foregroundColor(.red)
        }
    }
}
