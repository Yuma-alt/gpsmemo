import SwiftUI

struct AddCategoryView: View {
    @ObservedObject var viewModel: MemoViewModel
    @State private var categoryName = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Category")) {
                    TextField("Category Name", text: $categoryName)
                }
            }
            .navigationBarTitle("Add Category", displayMode: .inline)
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
        let newCategory = Category(name: categoryName)
        viewModel.addCategory(newCategory)
        presentationMode.wrappedValue.dismiss()
    }
}
