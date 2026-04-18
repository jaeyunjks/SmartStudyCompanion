import SwiftUI
import QuickLook
import UIKit

struct WorkspaceMaterialPreviewView: View {
    let material: StudyMaterial
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if material.type == .image, let image = UIImage(contentsOfFile: material.storedPath) {
                    Color.black.ignoresSafeArea()
                        .overlay {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                        }
                } else if material.type == .text, let preview = material.previewText {
                    ScrollView {
                        Text(preview)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                } else {
                    QuickLookPreview(url: material.localURL)
                }
            }
            .navigationTitle(material.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        context.coordinator.url = url
        uiViewController.reloadData()
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        var url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}

#Preview {
    WorkspaceMaterialPreviewView(
        material: StudyMaterial(
            workspaceID: UUID(),
            title: "Sample",
            type: .text,
            storedPath: "/tmp/sample.txt",
            createdAt: Date(),
            previewText: "This is a sample text preview."
        )
    )
}
