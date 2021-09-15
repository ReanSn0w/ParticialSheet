//
//  Environment.swift
//  
//
//  Created by Дмитрий Папков on 15.09.2021.
//

import SwiftUI
import FittedSheets

public struct SheetViewControllerEnvironmentKey: EnvironmentKey {
    public static let defaultValue: SheetViewControllerEnvPass = .init()
}

extension EnvironmentValues {
    public var sheetViewController: SheetViewControllerEnvPass {
        get { self[SheetViewControllerEnvironmentKey.self] }
        set { self[SheetViewControllerEnvironmentKey.self] = newValue }
    }
}

public class SheetViewControllerEnvPass {
    private(set) public var viewController: SheetViewController? = nil
    
    func set(sheet viewController: SheetViewController) {
        self.viewController = viewController
    }
}
