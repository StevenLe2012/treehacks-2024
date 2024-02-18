//
//  CarouselView.swift
//  TreeHacks2024
//
//  Created by Jiahui Chen  on 2/17/24.
//

import RealityKit
import RealityKitContent
import Foundation
import SwiftUI

struct Item: Identifiable {
    var id: Int
    var title: String
    var color: Color
}

class Store: ObservableObject {
    @Published var items: [Item]
    
    let colors: [Color] = [.red, .orange, .blue, .teal, .mint, .green, .gray, .indigo, .black]

    // dummy data
    init() {
        items = []
        for i in 0...7 {
            let new = Item(id: i, title: "Item \(i)", color: colors[i])
            items.append(new)
        }
    }
}


struct SceneSelectionCarousel: View {
    @StateObject var store = Store()
    @State private var snappedItem = 0.0
    @State private var draggingItem = 0.0
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    
    var body: some View {
        
        ZStack {
            ForEach(store.items) { item in
                // article view
                ZStack {
                    
                    VideoViewController(videoURL: Bundle.main.url(forResource: "spatialVideo1", withExtension: "MOV"))
                    RoundedRectangle(cornerRadius: 18)
                        .fill(item.color)
//                        .glassBackgroundEffect()
                    Text(item.title)
                        .padding()
                        .font(.title2)
                }
//                .background(item.color)
                .frame(width: 200, height: 200)
                .scaleEffect(1.0 - abs(distance(item.id)) * 0.2 )
                .opacity(1.0 - abs(distance(item.id)) * 0.3 )
                .offset(x: myXOffset(item.id), y: 0)
                .zIndex(1.0 - abs(distance(item.id)) * 0.1)
                .onTapGesture(perform: {
                    Task {
                        let result = await openImmersiveSpace(id: "classroom")
                        if case .error = result {
                            print("An error occurred")
                        }
                    }
                })
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
    
    func myXOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(store.items.count) * distance(item)
        return sin(angle) * 200
    }
    
}



#Preview {
    SceneSelectionCarousel()
}