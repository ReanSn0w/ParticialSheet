//
//  ParticialSheetPreview.swift
//  
//
//  Created by Дмитрий Папков on 17.07.2021.
//

import SwiftUI

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
