import SwiftUI

struct ContentView: View {
    @State private var memos = [String]() // 保存されたメモのリスト
    @State private var showingAddMemo = false // メモ追加画面の表示状態

    var body: some View {
        NavigationView {
            List(memos, id: \.self) { memo in
                Text(memo)
            }
            .navigationTitle("memo")
            .navigationBarItems(trailing: Button(action: {
                showingAddMemo = true // メモ追加画面を表示
            }) {
                Image(systemName: "plus")
            })
        }
        .sheet(isPresented: $showingAddMemo) {
            AddMemoView(memos: $memos)
        }
    }
}

struct AddMemoView: View {
    @Binding var memos: [String]
    @State private var memoText = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            // TextEditorを使用してメモを入力
            TextEditor(text: $memoText)
                .padding()
                .border(Color.gray, width: 1) // 枠線を追加

            Button("save") {
                if !memoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    memos.append(memoText)
                }
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .navigationBarTitle("new memo", displayMode: .inline) // ナビゲーションバータイトルを追加
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
