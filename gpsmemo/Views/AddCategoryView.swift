import SwiftUI

struct AddCategoryView: View {
    @ObservedObject var viewModel: MemoViewModel
    @State private var categoryName: String
    @Environment(\.presentationMode) var presentationMode
    var category: Category?

    init(viewModel: MemoViewModel, category: Category? = nil) {
        self.viewModel = viewModel
        self.category = category
        _categoryName = State(initialValue: category?.name ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(category != nil ? "Edit Category" : "New Category")) {
                    TextField("Category Name", text: $categoryName)
                }
            }
            .navigationBarTitle(category != nil ? "Edit Category" : "Add Category", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveCategory()
                }
                .disabled(categoryName.isEmpty)
            )
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
