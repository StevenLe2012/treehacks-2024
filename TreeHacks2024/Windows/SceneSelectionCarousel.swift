//
//  CarouselView.swift
//  TreeHacks2024
//
//  Created by Jiahui Chen  on 2/17/24.
//

import Foundation
import RealityKit
import RealityKitContent
import SwiftUI

// Define the structure of each carousel item
struct Item: Identifiable {
    var id: Int
    var title: String
    var subtitle: String
    var imageName: String
    var videoName: String
    var entityName: String
}

// Observable object to hold and manage the items
class Store: ObservableObject {
    @Published var items: [Item]

    init() {
        items = []
        let imageNames = ["Tibet", "Apple", "Hiking", "Paris"] // Placeholder image names
        let titles = ["Tibet Backpacking", "Summer Memories", "Yosemite", "Paris"]
        let subtitles = ["Feb 2024", "July 2023", "June 2021", "Aug 2023"] // Placeholder subtitles
        let videoNames = ["TibetWindow", "AppleParkWindow", "YosemiteWindow", "ParisWindow"]
        let entityIds = ["TibetSpace", "AppleParkSpace", "ElCapitanSpace", "ParisSpace"]
        for i in 0 ..< imageNames.count {
            let new = Item(id: i, title: "\(titles[i])", subtitle: "\(subtitles[i])", imageName: imageNames[i], videoName: videoNames[i], entityName: entityIds[i])
            items.append(new)
        }
    }
}

// The main view for the carousel
struct SceneSelectionCarousel: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismiss) private var dismiss

    @StateObject var store = Store()
    @State private var snappedItem = 0.0
    @State private var draggingItem = 0.0

    @State var currentWindow: String = ""
    @State var currentSpace: String = ""

    var body: some View {
        ZStack {
            ForEach(store.items) { item in
                VStack {
                    Image(item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .frame(width: 200, height: 200)
                        .cornerRadius(20)
                    VStack {
                        Text(item.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(item.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .onTapGesture {
                    // Open new window
                    openWindow(id: item.videoName)
                    currentWindow = item.videoName
                    Task {
                        // Dismiss the current space if present
                        if currentSpace != "" {
                            await dismissImmersiveSpace()
                        }
                        // Open new immersive space
                        await openImmersiveSpace(id: item.entityName)
                        currentSpace = item.entityName
                    }
                }
                .frame(width: 200, height: 200)
                .scaleEffect(1.0 - abs(distance(item.id)) * 0.2)
                .opacity(1.0 - abs(distance(item.id)) * 0.5)
                .offset(x: myXOffset(item.id), y: 0)
                .zIndex(1.0 - abs(distance(item.id)) * 0.1)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    draggingItem = snappedItem + value.translation.width / 100
                }
                .onEnded { value in
                    withAnimation {
                        draggingItem = snappedItem + value.predictedEndTranslation.width / 100
                        draggingItem = round(draggingItem).remainder(dividingBy: Double(store.items.count))
                        snappedItem = draggingItem
                    }
                }
        )
    }

    func distance(_ item: Int) -> Double {
        return (draggingItem - Double(item)).remainder(dividingBy: Double(store.items.count))
    }

    func myXOffset(_ item: Int) -> CGFloat {
        let angle = Double.pi * 2 / Double(store.items.count) * distance(item)
        return CGFloat(sin(angle) * 200)
    }
}

// Preview provider to visualize the carousel in Xcode's canvas
struct SceneSelectionCarousel_Previews: PreviewProvider {
    static var previews: some View {
        SceneSelectionCarousel()
    }
}
