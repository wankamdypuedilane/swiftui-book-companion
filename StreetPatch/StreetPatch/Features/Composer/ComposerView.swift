import MapKit
import PhotosUI
import StreetPatchKit
import SwiftUI

// <composerview>
/// New Report: a photo, a category, a title and a place. The place starts where the
/// resident stands (or at the town centre) and moves with a tap on the map.
struct ComposerView: View {
    @Bindable var model: ComposerModel
    @Environment(ReportsModel.self) private var reports
    @Environment(MyReportsModel.self) private var mine
    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem?
    @State private var isPreparingPhoto = false
    @State private var queuedAlert = false
    @State private var refusal: String?
    @FocusState private var focusedField: Field?

    enum Field { case title, details }

    var body: some View {
        NavigationStack {
            Form {
                photoSection
                Section("What") {
                    Picker("Category", selection: $model.draft.category) {
                        ForEach(ReportCategory.allCases) { category in
                            Label(category.title, systemImage: category.symbolName)
                                .tag(category)
                        }
                    }
                    TextField(
                        "Title", text: $model.draft.title, prompt: Text("Short description")
                    )
                    .focused($focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .details }
                    .accessibilityIdentifier("composer.title")
                    TextField("Details (optional)", text: $model.draft.details, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .details)
                }
                Section {
                    LocationPicker(location: $model.draft.location)
                        .frame(height: 220)
                        .listRowInsets(EdgeInsets())
                } header: {
                    Text("Where")
                } footer: {
                    Text("Tap the map to move the pin to the problem.")
                }
                if !model.problems.isEmpty {
                    Section {
                        ForEach(model.problems, id: \.self) { problem in
                            Label(problem.message, systemImage: "exclamationmark.circle")
                                .foregroundStyle(.red)
                        }
                    }
                    .accessibilityIdentifier("composer.problems")
                }
                if let refusal {
                    Section { Text(refusal).foregroundStyle(.red) }
                }
            }
            .navigationTitle("New report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") { Task { await send() } }
                        .disabled(model.isSubmitting || isPreparingPhoto)
                        .accessibilityIdentifier("composer.send")
                }
            }
            .interactiveDismissDisabled(!model.draft.title.isEmpty)  // do not lose a draft
            .alert("Saved on your iPhone", isPresented: $queuedAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("You are offline. The report will be sent as soon as you are back online.")
            }
            .onChange(of: photoItem) { _, item in Task { await loadPhoto(item) } }
        }
    }

    private var photoSection: some View {
        Section {
            if let data = model.photo, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("Selected photo")
            }
            PhotosPicker(selection: $photoItem, matching: .images) {
                Label(
                    model.photo == nil ? "Add a photo" : "Choose another photo",
                    systemImage: "photo")
            }
            if isPreparingPhoto { ProgressView("Preparing the photo…") }
        } footer: {
            Text("A photo helps the town's crews find and judge the problem.")
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        isPreparingPhoto = true
        defer { isPreparingPhoto = false }
        if let data = try? await item.loadTransferable(type: Data.self) {
            model.photo = await PhotoEncoder.jpeg(from: data)
        }
    }

    private func send() async {
        refusal = nil
        switch await model.submit() {
        case .sent(let report):
            reports.upsert(report)
            await mine.refresh()
            dismiss()
        case .queued:
            await mine.refresh()
            queuedAlert = true
        case .refused(let message):
            refusal = message
        case nil:
            break  // problems are shown in the form
        }
    }
}
// </composerview>

// <locationpicker>
/// A map with a pin. MapReader converts the tapped point to a coordinate.
struct LocationPicker: View {
    @Binding var location: Coordinate?
    @State private var position = MapCameraPosition.automatic

    var body: some View {
        MapReader { proxy in
            Map(position: $position) {
                if let location {
                    Marker("Problem", systemImage: "mappin", coordinate: location.clCoordinate)
                }
                UserAnnotation()
            }
            .onTapGesture { point in
                if let coordinate = proxy.convert(point, from: .local) {
                    location = Coordinate(
                        latitude: coordinate.latitude, longitude: coordinate.longitude)
                }
            }
            .onAppear {
                let centre = (location ?? ServiceArea.kerbrume.centre).clCoordinate
                position = .camera(MapCamera(centerCoordinate: centre, distance: 800))
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Place of the problem")
        .accessibilityValue(location == nil ? "Not chosen" : "Pin placed")
    }
}
// </locationpicker>
