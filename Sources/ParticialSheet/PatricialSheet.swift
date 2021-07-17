//
//  ParticialSheet.swift
//  
//
//  Created by Дмитрий Папков on 17.07.2021.
//

import SwiftUI
import FittedSheets

public struct ParticialSheet<Item, Content>: UIViewControllerRepresentable where Item: Identifiable, Content: View {
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
    
    public func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
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
}

extension ParticialSheet where Item == OpenerHack {
    init(
        isPresented: Binding<Bool>,
        sizes: [SheetSize] = [.intrinsic],
        options: SheetOptions? = nil,
        modificate: @escaping (SheetViewController) -> Void = { _ in },
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

class OpenerHack: Identifiable {}
