//
//  View+Ext.swift
//  
//
//  Created by Дмитрий Папков on 17.07.2021.
//

import SwiftUI
import FittedSheets

/// Алиас для настроек из пакета FittedSheets. Нужен лишь для  уменьшения числа импортов в файле конечного проекта
public typealias SheetOptions = FittedSheets.SheetOptions

/// OpenerHack - класс, необходимый для добавления возможности создания view с привязкой с логической переменной
class OpenerHack: Identifiable {}
extension View {
    public func particialSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        sizes: [SheetSize] = [.intrinsic],
        options: SheetOptions? = nil,
        modificate: @escaping (SheetViewController) -> Void = { _ in },
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        self.background(
            ParticialSheet(
                item: item,
                sizes: sizes,
                options: options,
                modificate: modificate,
                content: content))
    }
    
    public func particialSheet<Content: View>(
        isPresented: Binding<Bool>,
        sizes: [SheetSize] = [.intrinsic],
        options: SheetOptions? = nil,
        modificate: @escaping (SheetViewController) -> Void = { _ in },
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.background(
            ParticialSheet(
                isPresented: isPresented,
                sizes: sizes,
                options: options,
                modificate: modificate,
                content: content))
    }
}
