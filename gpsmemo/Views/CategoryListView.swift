import SwiftUI

enum EditingCategory: Identifiable {
    case new
    case edit(Category)

    var id: String {
        switch self {
        case .new:
            return "new"
        case .edit(let category):
            return category.id.uuidString
        }
    }
}

struct CategoryListView: View {
    @ObservedObject var viewModel: MemoViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var editingCategory: EditingCategory?

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.categories) { category in
                    HStack {
                        Text(category.name)
                        Spacer()
                        Button(action: {
                            editingCategory = .edit(category)
                        }) {
                            Image(systemName: "pencil")
                        }
                    }
                }
                .onDelete(perform: deleteCategory)
            }
            .navigationTitle("Edit Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        editingCategory = .new
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $editingCategory) { editingCategory in
                NavigationView {
                    switch editingCategory {
                    case .new:
                        AddCategoryView(viewModel: viewModel, category: nil)
                    case .edit(let category):
                        AddCategoryView(viewModel: viewModel, category: category)
                    }
                }
            }
        }
    }

    private func deleteCategory(at offsets: IndexSet) {
        offsets.forEach { index in
            let category = viewModel.categories[index]
            viewModel.deleteCategory(category)
        }
    }
}
