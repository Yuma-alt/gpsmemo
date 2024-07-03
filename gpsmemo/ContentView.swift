import SwiftUI
import CoreLocation

struct Category: Identifiable, Codable {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

struct LocationMemo: Identifiable, Codable {
    let id: UUID
    var text: String
    var location: CLLocationCoordinate2D?
    var categoryId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case id, text, latitude, longitude, categoryId
    }
    
    init(id: UUID = UUID(), text: String, location: CLLocationCoordinate2D? = nil, categoryId: UUID? = nil) {
        self.id = id
        self.text = text
        self.location = location
        self.categoryId = categoryId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        if let latitude = latitude, let longitude = longitude {
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        categoryId = try container.decodeIfPresent(UUID.self, forKey: .categoryId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(location?.latitude, forKey: .latitude)
        try container.encodeIfPresent(location?.longitude, forKey: .longitude)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
    }
}

class MemoViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var memos: [LocationMemo] = []
    @Published var categories: [Category] = []
    @Published var isEditingMemo = false
    @Published var selectedCategoryId: UUID?
    private var locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        loadMemos()
        loadCategories()
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    func deleteMemo(at offsets: IndexSet) {
        memos.remove(atOffsets: offsets)
        saveMemos()
    }

    func getFirstLine(of text: String) -> String {
        return text.components(separatedBy: .newlines).first ?? text
    }

    func saveMemo(_ memo: LocationMemo) {
        let trimmedText = memo.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            if let index = memos.firstIndex(where: { $0.id == memo.id }) {
                memos[index] = memo
            } else {
                memos.append(memo)
            }
            saveMemos()
        }
    }

    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }

    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        memos.indices.forEach { index in
            if memos[index].categoryId == category.id {
                memos[index].categoryId = nil
            }
        }
        saveCategories()
        saveMemos()
    }

    private func saveMemos() {
        if let encoded = try? JSONEncoder().encode(memos) {
            UserDefaults.standard.set(encoded, forKey: "savedMemos")
        }
    }

    private func loadMemos() {
        if let savedMemos = UserDefaults.standard.data(forKey: "savedMemos"),
           let decodedMemos = try? JSONDecoder().decode([LocationMemo].self, from: savedMemos) {
            memos = decodedMemos
        }
    }

    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "savedCategories")
        }
    }

    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.data(forKey: "savedCategories"),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: savedCategories) {
            categories = decodedCategories
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = MemoViewModel()
    @State private var showingAddMemoView = false
    @State private var showingAddCategoryView = false
    @State private var activeMemoIndex: Int?

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

    var categoryPicker: some View {
        Picker("Category", selection: $viewModel.selectedCategoryId) {
            Text("All").tag(UUID?.none)
            ForEach(viewModel.categories) { category in
                Text(category.name).tag(category.id as UUID?)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
    }

    var filteredMemos: [LocationMemo] {
        if let selectedCategoryId = viewModel.selectedCategoryId {
            return viewModel.memos.filter { $0.categoryId == selectedCategoryId }
        } else {
            return viewModel.memos
        }
    }
}

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

// 他のコードは変更なし
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

struct MarkdownView: View {
    var markdownText: String

    var body: some View {
        if let attributedString = try? AttributedString(markdown: markdownText) {
            Text(attributedString)
                .padding()
        } else {
            Text("Failed to render Markdown")
                .foregroundColor(.red)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
