import SwiftUI

enum Images {
    
    enum SystemImages {
        static let hashtag: Image = Image(systemName: "number")
        static let calendar: Image = Image(systemName: "calendar")
        static let flag: Image = Image(systemName: "flag.fill")
        static let ellipsis: Image = Image(systemName: "ellipsis") // это многоточие
        static let plus: Image = Image(systemName: "plus")
        static let chevronDown: Image = Image(systemName: "chevron.down") // стрелочка вниз для кнопки сортировки
        static let moon: Image = Image(systemName: "moon")
        static let stop: Image = Image(systemName: "stop")
        static let pause: Image = Image(systemName: "pause")
        static let forwardEnd: Image = Image(systemName: "forward.end")
    }
    
    enum LocalImages {
        static let corn: Image = Image("corn")
        static let cucumber: Image = Image("cucumber")
        static let tomato: Image = Image("tomato")
        static let vegetables: Image = Image("vegetables")
        static let moonSlash: Image = Image("moonSlash")
        static let tomatoSlash: Image = Image("tomatoSlash")
        static let tomatoTimer: Image = Image("tomatoTimer")
    }
}
