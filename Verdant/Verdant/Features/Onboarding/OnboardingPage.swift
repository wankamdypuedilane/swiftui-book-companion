import SwiftUI

// <page>
/// The content of one onboarding page. Pages are data, so adding or reordering
/// a page never requires touching the views.
struct OnboardingPage: Identifiable, Hashable {
    let id: Int
    let symbolName: String
    let title: String
    let message: String
    let tint: Color

    static let all: [OnboardingPage] = [
        OnboardingPage(id: 0, symbolName: "leaf.circle.fill",
                       title: "Welcome to Verdant",
                       message: "Keep every plant in your home happy, from the hardy snake plant "
                           + "to the most dramatic fern.",
                       tint: .green),
        OnboardingPage(id: 1, symbolName: "drop.circle.fill",
                       title: "Never forget to water",
                       message: "Verdant learns each plant's rhythm and reminds you on the right day, "
                           + "not every day.",
                       tint: .blue),
        OnboardingPage(id: 2, symbolName: "books.vertical.circle.fill",
                       title: "Discover species",
                       message: "Browse a catalogue of house plants with their light and watering "
                           + "needs, and add them to your garden in one tap.",
                       tint: .orange),
        OnboardingPage(id: 3, symbolName: "map.circle.fill",
                       title: "Meet plant lovers",
                       message: "Find nurseries, plant swaps and community gardens near you.",
                       tint: .teal),
    ]
}
// </page>
