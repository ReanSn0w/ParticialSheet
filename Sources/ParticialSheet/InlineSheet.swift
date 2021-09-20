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
    private var pass: SheetViewControllerEnvPass = .init()
    
    @Binding var item: Item?
    var content: (Item) -> Content
    var sizes: [SheetSize]
    var options: SheetOptions?
    var modificate: (SheetViewController) -> Void
    var onValue: ((Item?) -> Void)?
    
    init(
        item: Binding<Item?>,
        sizes: [SheetSize],
        options: SheetOptions?,
        modificate: @escaping (SheetViewController) -> Void = { _ in },
        onValue: ((Item?) -> Void)?,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._item = item
        self.sizes = sizes
        self.options = options
        self.modificate = modificate
        self.onValue = onValue
        self.content = content
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        self.onValue?(self.item)
        
        guard let item = self.item, context.coordinator.checkItem(new: item) else { return }
        
        context.coordinator.sheet?.attemptDismiss(animated: true)
        context.coordinator.sheet = nil
        
        DispatchQueue.main.async {
            if let root = uiViewController.parent {
                let host = UIHostingController(rootView: content(item).environment(\.sheetViewController, pass))
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
                
                pass.set(sheet: sheet)
                modificate(sheet)
                
                let dismissAction = sheet.didDismiss
                
                sheet.didDismiss = { svc in
                    DispatchQueue.main.async {
                        self.item = nil
                    }
                    
                    dismissAction?(svc)
                }
                
                context.coordinator.sheet = sheet
                sheet.animateIn(to: root.view, in: root)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }
    
    class Coordinator: NSObject {
        var parent: InlineSheet
        var sheet: SheetViewController?
        var item: Item?
        
        init(parent: InlineSheet) {
            self.parent = parent
            self.sheet = nil
            self.item = nil
        }
        
        func checkItem(new item: Item?) -> Bool {
            guard self.item?.id != item?.id else { return false }
            
            self.item = item
            
            return true
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
        onValue: (() -> Void)?,
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
        self.onValue = { _ in onValue?() }
        self.content = { _ in return content() }
    }
}
