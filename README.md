# ParticialSheet

Пакет для отображения модальных окон в окружении SwiftUI.

**Пример использования**  

```swift
import SwiftUI
import ParticialSheet

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
```

Данный пакет основан на библиотеке ![FittedSheet](https://github.com/gordontucker/FittedSheets)

Лицензия MIT
