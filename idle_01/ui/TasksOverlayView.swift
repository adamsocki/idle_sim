////
////  TasksOverlayView.swift
////  idle_01
////
////  Created by Adam Socki on 10/8/25.
////
//
//import SwiftUI
//import SwiftData
//
//struct TasksOverlayView: View {
//    let city: City
//    @Binding var selectedItemID: PersistentIdentifier?
//    
//    @Environment(\.modelContext) private var modelContext
//    
//    private var items: [Item] {
//        city.items.sorted { $0.timestamp > $1.timestamp }
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            List(selection: $selectedItemID) {
//                ForEach(items) { item in
//                    ItemRow(item: item, onDelete: { delete(item) })
//                        .tag(item.persistentModelID)
//                }
//                .onDelete { offsets in
//                    offsets.map { items[$0] }.forEach(delete)
//                }
//            }
//            
//            // Add button at bottom
//            HStack {
//                Spacer()
//                Button(action: addItem) {
//                    Label("Add Task", systemImage: "plus.circle.fill")
//                        .font(.title3)
//                }
//                .padding()
//            }
//            .background(.ultraThinMaterial)
//        }
//    }
//    
//    private func addItem() {
//        let item = Item(name: "New Task", city: city)
//        modelContext.insert(item)
//        try? modelContext.save()
//    }
//    
//    private func delete(_ item: Item) {
//        modelContext.delete(item)
//        try? modelContext.save()
//    }
//}
