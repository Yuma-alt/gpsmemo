import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MemoViewModel()
    @State private var showingAddMemoView = false
    @State private var showingAddCategoryView = false
    @State private var activeMemoIndex: Int?
    @State private var showingCategoryListView = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    categoryPicker
                    
                    List {
                        ForEach(filteredMemos) { memo in
                            NavigationLink(
                                destination: AddMemoView(
                                    viewModel: viewModel,
                                    memo: memo
                                )
                            ) {
                                MarkdownView(markdownText: viewModel.getFirstLine(of: memo.text))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                        .onDelete(perform: viewModel.deleteMemo)
                        .onMove(perform: moveMemo)
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddCategoryView = true
                        }) {
                            Image(systemName: "folder.badge.plus")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
                
                VStack {
                    Spacer()
                    Button(action: {
                        showingAddMemoView = true
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .sheet(isPresented: $showingAddMemoView) {
            AddMemoView(viewModel: viewModel, memo: nil)
        }
        .sheet(isPresented: $showingAddCategoryView) {
            AddCategoryView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.requestLocation()
        }
    }

    private var categoryPicker: some View {
        HStack {
            Picker("Category", selection: $viewModel.selectedCategoryId) {
                Text("All").tag(UUID?.none)
                ForEach(viewModel.categories) { category in
                    Text(category.name).tag(category.id as UUID?)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Button(action: {
                showingCategoryListView = true
            }) {
                Image(systemName: "pencil")
            }
            .sheet(isPresented: $showingCategoryListView) {
                CategoryListView(viewModel: viewModel)
            }
        }
        .padding()
    }
    
    private var filteredMemos: [LocationMemo] {
        if let selectedCategoryId = viewModel.selectedCategoryId {
            return viewModel.memos.filter { $0.categoryId == selectedCategoryId }
        } else {
            return viewModel.memos
        }
    }
    
    private func moveMemo(from source: IndexSet, to destination: Int) {
        if viewModel.selectedCategoryId == nil {
            // カテゴリが未選択の場合、viewModel.memos を直接操作
            viewModel.memos.move(fromOffsets: source, toOffset: destination)
        } else {
            // フィルタリングされたメモを操作
            var filtered = filteredMemos
            filtered.move(fromOffsets: source, toOffset: destination)
            
            // viewModel.memos を更新
            var newMemos: [LocationMemo] = []
            var filteredIndex = 0
            for memo in viewModel.memos {
                if memo.categoryId == viewModel.selectedCategoryId {
                    // 選択されたカテゴリのメモは、並べ替え後の順序で追加
                    newMemos.append(filtered[filteredIndex])
                    filteredIndex += 1
                } else {
                    // その他のメモはそのまま追加
                    newMemos.append(memo)
                }
            }
            viewModel.memos = newMemos
            // メモの保存
            viewModel.saveMemos()
        }
    }
}

// add to show preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
