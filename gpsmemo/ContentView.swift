import SwiftUI

struct ContentView: View {
    @State private var memos = [String]() // 保存されたメモのリスト
    @State private var showingMemoEditor = false // メモ編集画面の表示状態
    @State private var selectedMemoIndex: Int? = nil // 選択されたメモのインデックス

    var body: some View {
        NavigationView {
            List(memos.indices, id: \.self) { index in
                Text(memos[index])
                    .onTapGesture {
                        selectedMemoIndex = index // 選択されたメモのインデックスをセット
                        showingMemoEditor = true
                    }
            }
            .navigationTitle("memo")
            .navigationBarItems(trailing: Button(action: {
                selectedMemoIndex = nil // 新しいメモを追加するためにnilをセット
                showingMemoEditor = true
            }) {
                Image(systemName: "plus")
            })
        }
        .sheet(isPresented: $showingMemoEditor) {
            AddMemoView(memos: $memos, memoIndex: $selectedMemoIndex)
        }
    }
}

struct AddMemoView: View {
    @Binding var memos: [String]
    @Binding var memoIndex: Int? // 編集するメモのインデックス
    @State private var memoText = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            TextEditor(text: $memoText)
                .onAppear {
                    if let index = memoIndex {
                        memoText = memos[index] // 編集するメモをロード
                    }
                }
                .padding()
                .border(Color.gray, width: 1)

            Button("保存") {
                if !memoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    if let index = memoIndex {
                        memos[index] = memoText // 既存のメモを更新
                    } else {
                        memos.append(memoText) // 新しいメモを追加
                    }
                }
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
