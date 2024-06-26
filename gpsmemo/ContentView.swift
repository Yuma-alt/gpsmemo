import SwiftUI

struct ContentView: View {
    @State private var memos = [
        "This is a **bold** memo",
        "This is *italic* memo"
    ]

    @State private var showingAddMemoView = false
    @State private var isEditingMemo = false

    var body: some View {
        VStack {
            NavigationView {
                List {
                    ForEach(memos.indices, id: \.self) { index in
                        NavigationLink(destination: AddMemoView(memos: $memos, memoIndex: .constant(index), isEditingMemo: $isEditingMemo)) {
                            MarkdownView(markdownText: getFirstLine(of: memos[index]))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .onDelete(perform: deleteMemo)
                }
                .navigationTitle("Memos")
            }

            if !isEditingMemo {
                addButton
            }
        }
        .sheet(isPresented: $showingAddMemoView) {
            AddMemoView(memos: $memos, memoIndex: .constant(nil), isEditingMemo: $isEditingMemo)
        }
    }

    var addButton: some View {
        Button(action: {
            showingAddMemoView = true
            isEditingMemo = false
        }) {
            Image(systemName: "plus")
                .resizable()
                .frame(width: 24, height: 24)
                .padding()
                .background(Color.blue)
                .foregroundColor(Color.white)
                .clipShape(Circle())
        }
        .padding(.bottom, 20)
    }

    func deleteMemo(at offsets: IndexSet) {
        memos.remove(atOffsets: offsets)
    }

    func getFirstLine(of text: String) -> String {
        return text.components(separatedBy: .newlines).first ?? text
    }
}

struct AddMemoView: View {
    @Binding var memos: [String]
    @Binding var memoIndex: Int?
    @Binding var isEditingMemo: Bool
    @State private var memoText = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            TextEditor(text: $memoText)
                .padding()
                .border(Color.white, width: 1)

            HStack {
                Spacer()
                Button("Save") {
                    if !memoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        if let index = memoIndex {
                            memos[index] = memoText
                        } else {
                            memos.append(memoText)
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                    isEditingMemo = false
                }
                Spacer()
            }
            .padding()
        }
        .onAppear {
            isEditingMemo = true
            if let index = memoIndex {
                memoText = memos[index]
            }
        }
        .onDisappear {
            isEditingMemo = false
        }
    }
}

struct MarkdownView: View {
    var markdownText: String

    var body: some View {
        if let attributedString = try? AttributedString(markdown: markdownText) {
            Text(attributedString)
                .padding()
        } else {
            Text("Failed to render Markdown") // レンダリングに失敗した場合のエラー表示
                .foregroundColor(.red)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
