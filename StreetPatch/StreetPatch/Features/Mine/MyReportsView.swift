import StreetPatchKit
import SwiftUI

// <mineview>
/// The resident's own reports: first those still on the device, then those the town
/// has, with their status. Signed out, the tab explains why an account is needed.
struct MyReportsView: View {
    @Environment(MyReportsModel.self) private var model
    @Environment(SessionModel.self) private var session
    @Environment(AppDependencies.self) private var dependencies
    @State private var isSigningIn = false

    var body: some View {
        NavigationStack {
            Group {
                if session.isSignedIn {
                    list
                } else {
                    ContentUnavailableView {
                        Label("Your reports", systemImage: "person.crop.circle")
                    } description: {
                        Text("Sign in to report problems, follow them and support others.")
                    } actions: {
                        Button("Sign in") { isSigningIn = true }
                            .buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("mine.signIn")
                    }
                }
            }
            .navigationTitle("Mine")
            .navigationDestination(for: Report.self) { report in
                ReportDetailView(model: dependencies.makeDetail(for: report))
            }
            .toolbar {
                if session.isSignedIn {
                    Button("Sign out") { Task { await session.signOut() } }
                }
            }
            .sheet(isPresented: $isSigningIn) { SignInView() }
            .task(id: session.email) {
                if session.isSignedIn { await model.refresh() }
            }
        }
    }

    private var list: some View {
        List {
            if !model.pending.isEmpty {
                Section("Waiting to be sent") {
                    ForEach(model.pending) { item in
                        PendingRow(item: item)
                            .swipeActions {
                                Button("Discard", systemImage: "trash", role: .destructive) {
                                    Task { await model.discard(item) }
                                }
                            }
                    }
                }
            }
            Section {
                ForEach(model.reports) { report in
                    NavigationLink(value: report) { ReportRow(report: report) }
                }
            } header: {
                Text("Sent")
            } footer: {
                if let message = model.errorMessage { Text(message) }
            }
        }
        .refreshable { await model.refresh() }
        .overlay {
            if model.pending.isEmpty && model.reports.isEmpty {
                ContentUnavailableView(
                    "No reports yet", systemImage: "road.lanes",
                    description: Text("Problems you report appear here."))
            }
        }
    }
}

private struct PendingRow: View {
    let item: PendingReport

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.draft.title).font(.headline)
            if let failure = item.failure {
                Label(failure, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            } else {
                Label("Will be sent when you are online", systemImage: "icloud.and.arrow.up")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }
}
// </mineview>
