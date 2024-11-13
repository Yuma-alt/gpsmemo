import SwiftUI

struct AddMemoView: View {
    @ObservedObject var viewModel: MemoViewModel
    @State private var memoText: String
    @State private var memo: LocationMemo
    @State private var selectedCategoryId: UUID?
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false

    init(viewModel: MemoViewModel, memo: LocationMemo?) {
        self.viewModel = viewModel
        _memo = State(initialValue: memo ?? LocationMemo(text: ""))
        _memoText = State(initialValue: memo?.text ?? "")
        _selectedCategoryId = State(initialValue: memo?.categoryId)
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Memo")) {
                        TextEditor(text: $memoText)
                            .frame(height: 200)
                    }
                    
                    Section(header: Text("Category")) {
                        Picker("Category", selection: $selectedCategoryId) {
                            Text("None").tag(UUID?.none)
                            ForEach(viewModel.categories) { category in
                                Text(category.name).tag(category.id as UUID?)
                            }
                        }
                    }
                    
                    if let location = memo.location {
                        Section(header: Text("Location")) {
                            Text("Latitude: \(location.latitude), Longitude: \(location.longitude)")
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        if !memoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            saveMemo()
                        } else {
                            showAlert = true
                        }
                    }) {
                        Text("Save")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationBarTitle(memo.id == UUID() ? "Add Memo" : "Edit Memo", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Empty Memo"), message: Text("Please enter some text before saving."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveMemo() {
        memo.text = memoText
        memo.categoryId = selectedCategoryId
        if memo.location == nil {
            memo.location = viewModel.currentLocation?.coordinate
        }
        viewModel.saveMemo(memo)
        presentationMode.wrappedValue.dismiss()
    }
}
