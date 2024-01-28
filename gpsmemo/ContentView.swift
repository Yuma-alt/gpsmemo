import SwiftUI

struct ContentView: View {
    @State private var memos = [String]() // 保存されたメモのリスト
    @State private var selectedMemoIndex: Int? = nil // 選択されたメモのインデックス

    var body: some View {
        NavigationView {
            List {
                ForEach(memos.indices, id: \.self) { index in
                    NavigationLink(destination: AddMemoView(memos: $memos, memoIndex: .constant(index))) {
                        Text(memos[index])
                    }
                }
                .onDelete(perform: deleteMemo)
            }
            .navigationTitle("")
            .navigationBarItems(trailing: NavigationLink(destination: AddMemoView(memos: $memos, memoIndex: .constant(nil))) {
                Image(systemName: "plus")
            })
        }
    }

    func deleteMemo(at offsets: IndexSet) {
        memos.remove(atOffsets: offsets)
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
                .border(Color.white, width: 1)

            HStack {
                Spacer() // 左側のスペース
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
                Spacer() // 右側のスペース
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
