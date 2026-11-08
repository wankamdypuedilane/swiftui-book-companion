import SwiftUI

// <async>
/// AsyncImage downloads an image from a URL and reports each phase of the download.
struct RemoteImageView: View {
    // This demonstration address does not exist, so the failure phase is shown.
    let url = URL(string: "https://images.verdant.example/species/monstera.jpg")

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                ContentUnavailableView(
                    "No photo",
                    systemImage: "photo.badge.exclamationmark",
                    description: Text("The image could not be loaded."))
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 280, height: 200)
        .background(.quaternary, in: .rect(cornerRadius: 16))
        .clipShape(.rect(cornerRadius: 16))
    }
}
// </async>

#Preview { RemoteImageView() }
