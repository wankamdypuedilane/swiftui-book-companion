import MapKit
import StreetPatchKit
import SwiftUI

// <detailview>
/// A report: where it is, what the town did with it, and what the resident can do.
struct ReportDetailView: View {
    @State private var model: ReportDetailModel
    @Environment(ReportsModel.self) private var reports
    @Environment(MyReportsModel.self) private var mine
    @Environment(SessionModel.self) private var session
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmingWithdrawal = false

    init(model: ReportDetailModel) {
        _model = State(initialValue: model)
    }

    private var report: Report { model.report }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label(report.category.title, systemImage: report.category.symbolName)
                        .font(.subheadline)
                        .foregroundStyle(report.category.tint)
                    Text(report.title).font(.title2.bold())
                    if !report.details.isEmpty { Text(report.details) }
                    StatusPill(status: report.status)
                }
                .padding(.vertical, 4)
                if report.hasPhoto { photo }
                Map(
                    initialPosition: .camera(
                        .init(centerCoordinate: report.coordinate.clCoordinate, distance: 600))
                ) {
                    Marker(
                        report.title, systemImage: report.category.symbolName,
                        coordinate: report.coordinate.clCoordinate
                    )
                    .tint(report.category.tint)
                }
                .frame(height: 160)
                .listRowInsets(EdgeInsets())
                .disabled(true)
                .accessibilityHidden(true)  // the title and history say it all
            }
            Section("Progress") {
                StatusTimeline(history: report.history)
            }
            actions
        }
        .navigationTitle(report.id)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await model.refresh() }
        .onChange(of: model.report) { _, changed in reports.upsert(changed) }
        .confirmationDialog(
            "Withdraw this report?", isPresented: $isConfirmingWithdrawal,
            titleVisibility: .visible
        ) {
            Button("Withdraw", role: .destructive) {
                Task {
                    if await model.withdraw() {
                        reports.remove(id: report.id)
                        await mine.refresh()
                        dismiss()
                    }
                }
            }
        } message: {
            Text("The town has not looked at it yet. You can report it again later.")
        }
    }

    private var photo: some View {
        AsyncImage(url: dependencies.photoURL(report)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ProgressView().frame(maxWidth: .infinity)
        }
        .frame(height: 200)
        .clipped()
        .listRowInsets(EdgeInsets())
        .accessibilityLabel("Photo of the problem")
    }

    @ViewBuilder private var actions: some View {
        Section {
            if report.canBeSupported && session.isSignedIn {
                Button {
                    Task { await model.toggleSupport() }
                } label: {
                    Label(
                        report.supportedByMe ? "You support this report" : "Me too",
                        systemImage: report.supportedByMe
                            ? "hand.thumbsup.fill" : "hand.thumbsup")
                }
                .disabled(model.isWorking)
                .accessibilityIdentifier("detail.support")
            }
            LabeledContent("Residents affected", value: "\(report.supportCount + 1)")
            if report.canBeWithdrawn {
                Button("Withdraw report", role: .destructive) {
                    isConfirmingWithdrawal = true
                }
                .accessibilityIdentifier("detail.withdraw")
            }
        } footer: {
            if let message = model.errorMessage {
                Text(message).foregroundStyle(.red)
            }
        }
    }
}
// </detailview>

// <timeline>
/// The history of a report, oldest first: a vertical line of dated steps.
struct StatusTimeline: View {
    let history: [Report.Change]

    var body: some View {
        ForEach(Array(history.enumerated()), id: \.offset) { index, change in
            HStack(alignment: .top, spacing: 12) {
                Image(
                    systemName: index == history.count - 1
                        ? "circle.inset.filled" : "circle.fill"
                )
                .foregroundStyle(change.status.tint)
                .font(.caption)
                .padding(.top, 4)
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(change.status.title).font(.headline)
                    Text(change.at, format: .dateTime.day().month().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let note = change.note { Text(note).font(.callout) }
                }
            }
            .accessibilityElement(children: .combine)
        }
    }
}
// </timeline>
