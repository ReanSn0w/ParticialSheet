//
//  ParticialSheet.swift
//  
//
//  Created by Дмитрий Папков on 17.07.2021.
//

import SwiftUI
import FittedSheets

// MARK: - Пример использования

struct ParticialSheetExample: View {
    @State var opened: Bool = false
    
    var body: some View {
        Button(action: { self.opened.toggle() }) {
            Text("Open")
        }
        .particialSheet(isPresented: $opened, sizes: [.fixed(100), .marginFromTop(150)]) {
            Text("Particial Sheet")
        }
    }
}

struct ParticialSheetExample_Previews: PreviewProvider {
    static var previews: some View {
        ParticialSheetExample()
    }
}

// MARK: - Базовая реализация

struct ParticialSheet<Item, Content>: UIViewControllerRepresentable where Item: Identifiable, Content: View {
    @Binding var item: Item?
    var sizes: [SheetSize]
    var options: SheetOptions?
    var modificate: (SheetViewController) -> Void
    var contentBuilder: (Item) -> Content
    
    init(
        item: Binding<Item?>,
        sizes: [SheetSize] = [.intrinsic],
        options: SheetOptions? = nil,
        modificate: @escaping (SheetViewController) -> Void = { _ in },
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._item = item
        self.sizes = sizes
        self.options = options
        self.modificate = modificate
        self.contentBuilder = content
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.sheet?.attemptDismiss(animated: true)
        context.coordinator.sheet = nil
        
        if let item = item {
            let hostingController = UIHostingController(rootView: contentBuilder(item))
            let sheetController = SheetViewController(
                controller: hostingController,
                sizes: sizes,
                options: options)
            
            modificate(sheetController)
            
            sheetController.didDismiss = { _ in
                DispatchQueue.main.async {
                    self.item = nil
                }
            }
            
            uiViewController.present(sheetController, animated: true, completion: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }
    
    class Coordinator: NSObject {
        var parent: ParticialSheet
        var sheet: SheetViewController?
        
        init(parent: ParticialSheet) {
            self.parent = parent
            self.sheet = nil
        }
    }
}

// MARK: - Расширение для привязки к логическим значениям

extension ParticialSheet where Item == OpenerHack {
    init(
        isPresented: Binding<Bool>,
        sizes: [SheetSize],
        options: SheetOptions?,
        modificate: @escaping (SheetViewController) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._item = .init(
            get: {
                if isPresented.wrappedValue {
                    return OpenerHack()
                } else {
                    return nil
                }
            }, set: { newValue in
                if newValue == nil { isPresented.wrappedValue = false }
            })
        
        self.sizes = sizes
        self.options = options
        self.modificate = modificate
        self.contentBuilder = { _ in return content() }
    }
}
