import SwiftUI
import SwiftData

struct ItemListView: View {
    let items: [Item]
    @Binding var selection: PersistentIdentifier?
    let onAdd: () -> Void
    let onDeleteOffsets: (IndexSet) -> Void
    let onDeleteItem: (Item) -> Void

    var body: some View {
        List(selection: $selection) {
            ForEach(items) { item in
                ItemRow(item: item, onDelete: { onDeleteItem(item) })
                    .tag(item.persistentModelID)
            }
            .onDelete(perform: onDeleteOffsets)
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        .toolbar {
            ToolbarItem {
                Button(action: onAdd) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }
}
