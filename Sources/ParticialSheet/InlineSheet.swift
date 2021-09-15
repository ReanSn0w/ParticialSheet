//
//  InlineSheet.swift
//
//  View для подключения FitterSheet к UIView внутри SwiftUI
//
//  Created by Дмитрий Папков on 15.09.2021.
//

import SwiftUI
import FittedSheets

// MARK: - Пример использования

struct InlineSheetExample: View {
    @State var opened: Bool = false
    
    var body: some View {
        Button(action: { self.opened.toggle() }) {
            Text("Open")
        }
        .inlineSheet(isPresented: $opened, sizes: [.fixed(100), .fullscreen]) {
            Text("Inline Sheet")
        }
    }
}

struct InlineSheetExample_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            InlineSheetExample()
                .tabItem {
                    Image(systemName: "person")
                    Text("Пример")
                }
        }
    }
}

// MARK: - базовая реализация

struct InlineSheet<Item, Content>: UIViewControllerRepresentable where Item: Identifiable, Content: View {
    @Binding var item: Item?
    var content: (Item) -> Content
    var sizes: [SheetSize]
    var options: SheetOptions?
    var modificate: (SheetViewController) -> Void
    
    init(
        item: Binding<Item?>,
        sizes: [SheetSize],
        options: SheetOptions?,
        modificate: @escaping (SheetViewController) -> Void = { _ in },
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._item = item
        self.sizes = sizes
        self.options = options
        self.modificate = modificate
        self.content = content
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.sheet?.attemptDismiss(animated: true)
        context.coordinator.sheet = nil
        
        if let root = uiViewController.parent, let item = item {
            let host = UIHostingController(rootView: content(item))
            let sheet = SheetViewController(
                controller: host,
                sizes: sizes,
                options: .init(
                    pullBarHeight: options?.pullBarHeight,
                    presentingViewCornerRadius: options?.presentingViewCornerRadius,
                    shouldExtendBackground: options?.shouldExtendBackground,
                    setIntrinsicHeightOnNavigationControllers: options?.setIntrinsicHeightOnNavigationControllers,
                    useFullScreenMode: options?.useFullScreenMode,
                    shrinkPresentingViewController: options?.shrinkPresentingViewController,
                    useInlineMode: true,
                    horizontalPadding: options?.horizontalPadding,
                    maxWidth: options?.maxWidth))
            
            modificate(sheet)
            
            sheet.didDismiss = { _ in
                DispatchQueue.main.async {
                    self.item = nil
                }
            }
            
            context.coordinator.sheet = sheet
            sheet.animateIn(to: root.view, in: root)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }
    
    class Coordinator: NSObject {
        var parent: InlineSheet
        var sheet: SheetViewController?
        
        init(parent: InlineSheet) {
            self.parent = parent
            self.sheet = nil
        }
    }
}

// MARK: - расширение для работы с логическими типами

extension InlineSheet where Item == OpenerHack {
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
        self.content = { _ in return content() }
    }
}
