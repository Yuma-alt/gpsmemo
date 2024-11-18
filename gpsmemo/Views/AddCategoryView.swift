import SwiftUI

struct AddCategoryView: View {
    @ObservedObject var viewModel: MemoViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var categoryName: String = ""
    var category: Category?

    var body: some View {
        Form {
            Section(header: Text(category != nil ? "Edit Category" : "New Category")) {
                TextField("Category Name", text: $categoryName)
            }
        }
        .navigationTitle(category != nil ? "Edit Category" : "Add Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveCategory()
                }
                .disabled(categoryName.isEmpty)
            }
        }
        .onAppear {
            if let category = category {
                categoryName = category.name
            } else {
                categoryName = ""
            }
        }
    }

    private func saveCategory() {
        if var category = category {
            // カテゴリの更新
            category.name = categoryName
            viewModel.updateCategory(category)
        } else {
            // 新規カテゴリの追加
            let newCategory = Category(name: categoryName)
            viewModel.addCategory(newCategory)
        }
        presentationMode.wrappedValue.dismiss()
    }
}
