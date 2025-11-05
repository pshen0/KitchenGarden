import SwiftUI

enum Images {
    
    enum SystemImages {
        static let hashtag: Image = Image(systemName: "number")
        static let calendar: Image = Image(systemName: "calendar")
        static let flag: Image = Image(systemName: "flag.fill")
        static let ellipsis: Image = Image(systemName: "ellipsis") // это многоточие
        static let plus: Image = Image(systemName: "plus")
        static let chevronDown: Image = Image(systemName: "chevron.down") // стрелочка вниз для кнопки сортировки
        static let stop: Image = Image(systemName: "stop")
        static let pause: Image = Image(systemName: "pause")
        static let forwardEnd: Image = Image(systemName: "forward.end")
        static let play: Image = Image(systemName: "play")
    }
    
    enum LocalImages {
        static let corn: Image = Image("corn")
        static let cucumber: Image = Image("cucumber")
        static let tomato: Image = Image("tomato")
        static let vegetables: Image = Image("vegetables")
        static let moonSymbol: Image = Image("moonSymbol")
        static let moonSymbolSlash: Image = Image("moonSymbolSlash")
        static let tomatoSymbol: Image = Image("tomatoSymbol")
        static let tomatoSymbolSlash: Image = Image("tomatoSymbolSlash")
        static let tomatoTimer: Image = Image("tomatoTimer")
        static let gearshape: Image = Image("gearshape")
    }
}
