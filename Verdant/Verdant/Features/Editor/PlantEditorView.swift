import SwiftUI
import VerdantKit

// <editor>
/// The form used to add and edit a plant. All the rules live in PlantEditorModel;
/// the view arranges fields, manages focus and shows the model's messages.
struct PlantEditorView: View {
    @State var model: PlantEditorModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var isConfirmingDiscard = false

    enum Field: Hashable { case nickname, species, notes }

    var body: some View {
        NavigationStack {
            Form {
                Section("Plant") {
                    TextField("Name, e.g. Monty", text: $model.draft.nickname)
                        .focused($focusedField, equals: .nickname)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .species }
                        .accessibilityIdentifier("editor.nickname")
                    TextField("Species, e.g. Monstera", text: $model.draft.speciesName)
                        .focused($focusedField, equals: .species)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                        .accessibilityIdentifier("editor.species")
                    Picker("Room", selection: $model.draft.room) {
                        ForEach(Room.allCases) { room in
                            Label(room.title, systemImage: room.symbolName).tag(room)
                        }
                    }
                }

                Section("Care") {
                    Picker("Light", selection: $model.draft.light) {
                        ForEach(LightLevel.allCases) { Text($0.title).tag($0) }
                    }
                    Stepper(
                        value: $model.draft.wateringIntervalDays, in: PlantDraft.intervalRange
                    ) {
                        LabeledContent(
                            "Water every", value: "\(model.draft.wateringIntervalDays) days")
                    }
                    DatePicker(
                        "At home since", selection: $model.draft.acquiredOn,
                        in: ...Date.now, displayedComponents: .date)
                }

                Section("Notes") {
                    TextField(
                        "Anything worth remembering", text: $model.draft.notes, axis: .vertical
                    )
                    .lineLimit(3...8)
                    .focused($focusedField, equals: .notes)
                }

                if !model.visibleIssues.isEmpty {
                    Section {
                        ForEach(model.visibleIssues, id: \.self) { issue in
                            Label(issue.message, systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .accessibilityIdentifier("editor.issues")
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(model.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
            .interactiveDismissDisabled(model.hasChanges)  // no accidental swipe-away
            .confirmationDialog("Discard your changes?", isPresented: $isConfirmingDiscard) {
                Button("Discard changes", role: .destructive) { dismiss() }
            }
            .onAppear { if model.isNew { focusedField = .nickname } }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                if model.hasChanges { isConfirmingDiscard = true } else { dismiss() }
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(model.isNew ? "Add" : "Save") {
                Task {
                    if await model.save() != nil { dismiss() } else { focusedField = nil }
                }
            }
            .accessibilityIdentifier("editor.save")
        }
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { focusedField = nil }
        }
    }
}
// </editor>

#Preview("New plant") {
    PlantEditorView(model: PlantEditorModel(garden: AppDependencies.preview.garden))
}
