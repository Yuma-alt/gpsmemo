import SwiftUI

struct CategoryListView: View {
    @ObservedObject var viewModel: MemoViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddCategoryView = false
    @State private var editingCategory: Category?

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.categories) { category in
                    HStack {
                        Text(category.name)
                        Spacer()
                        Button(action: {
                            editingCategory = category
                            showingAddCategoryView = true
                        }) {
                            Image(systemName: "pencil")
                        }
                    }
                }
                .onDelete(perform: deleteCategory)
            }
            .navigationBarTitle("Edit Categories", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    showingAddCategoryView = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddCategoryView) {
                AddCategoryView(viewModel: viewModel, category: editingCategory)
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
