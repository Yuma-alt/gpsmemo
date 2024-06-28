import SwiftUI
import CoreLocation

struct LocationMemo: Identifiable, Codable {
    let id: UUID
    var text: String
    var location: CLLocationCoordinate2D?
    
    enum CodingKeys: String, CodingKey {
        case id, text, latitude, longitude
    }
    
    init(id: UUID = UUID(), text: String, location: CLLocationCoordinate2D? = nil) {
        self.id = id
        self.text = text
        self.location = location
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
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(location?.latitude, forKey: .latitude)
        try container.encodeIfPresent(location?.longitude, forKey: .longitude)
    }
}

class MemoViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var memos: [LocationMemo] = []
    @Published var isEditingMemo = false
    private var locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        loadMemos()
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
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            memos[index] = memo
        } else {
            memos.append(memo)
        }
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
}

struct ContentView: View {
    @StateObject private var viewModel = MemoViewModel()
    @State private var showingAddMemoView = false
    @State private var activeMemoIndex: Int?

    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(viewModel.memos) { memo in
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
                if !viewModel.isEditingMemo {
                    addButton
                }
            }
        }
        .sheet(isPresented: $showingAddMemoView) {
            AddMemoView(viewModel: viewModel, memo: nil)
        }
        .onAppear {
            viewModel.requestLocation()
        }
    }

    var addButton: some View {
        Button(action: {
            showingAddMemoView = true
            viewModel.isEditingMemo = false
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

struct AddMemoView: View {
    @ObservedObject var viewModel: MemoViewModel
    @State private var memoText: String
    @State private var memo: LocationMemo
    @Environment(\.presentationMode) var presentationMode

    init(viewModel: MemoViewModel, memo: LocationMemo?) {
        self.viewModel = viewModel
        _memo = State(initialValue: memo ?? LocationMemo(text: ""))
        _memoText = State(initialValue: memo?.text ?? "")
    }

    var body: some View {
        NavigationView {
            VStack {
                if let location = memo.location {
                    Text("Latitude: \(location.latitude), Longitude: \(location.longitude)")
                        .font(.caption)
                        .padding()
                }
                
                TextEditor(text: $memoText)
                    .padding()
                    .border(Color.white, width: 1)
                
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
                        saveMemo()
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
        }
        .onAppear {
            viewModel.isEditingMemo = true
        }
        .onDisappear {
            viewModel.isEditingMemo = false
        }
    }

    private func saveMemo() {
        memo.text = memoText
        if memo.location == nil {
            memo.location = viewModel.currentLocation?.coordinate
        }
        viewModel.saveMemo(memo)
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
