import SwiftUI

struct ContentView: View {
    @State private var memos = [String]() // 保存されたメモのリスト
    @State private var showingAddMemoView = false // メモ追加ビューの表示状態
    @State private var isEditingMemo = false // メモ編集中かどうか

    var body: some View {
        VStack {
            NavigationView {
                List {
                    ForEach(memos.indices, id: \.self) { index in
                        NavigationLink(destination: AddMemoView(memos: $memos, memoIndex: .constant(index), isEditingMemo: $isEditingMemo)) {
                            Text(memos[index])
                                .lineLimit(1) // テキストを1行に制限
                                .truncationMode(.tail) // 長いテキストは末尾を切り詰める
                        }
                    }
                    .onDelete(perform: deleteMemo)
                }
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
}

// AddMemoViewの定義は同じ
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
                Spacer() // 左側のスペース
                Button("Save") {
                    if !memoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        if let index = memoIndex {
                            memos[index] = memoText // 既存のメモを更新
                        } else {
                            memos.append(memoText) // 新しいメモを追加
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                    isEditingMemo = false
                }
                Spacer() // 右側のスペース
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
