//: Playground - noun: a place where people can play

import UIKit


class HumanClass {
    var name: String
    init(name: String) {
        self.name = name
    }
}

var classHuman = HumanClass(name: "Bob")
// "Bob"
classHuman.name
// Created a "copied" object
var newClassHuman = classHuman
newClassHuman.name = "Bobby"
classHuman.name


struct HumanStruct {
    var name: String
}
var humanStruct = HumanStruct(name: "Bob")
var newHumanStruct = humanStruct
newHumanStruct.name = "Bobby"
humanStruct.name


protocol Human {
    var name: String {get set}
    var race: String {get set}
    func sayHi()
}

struct Korean: Human {
    var name: String = "Bob Lee"
    var race: String = "Asian"
    func sayHi() {
        print("Hi, I'm \(name)")
    }
}


protocol SuperMan: Human {
    var canFly: Bool { get set }
    func punch()
}


struct SuperSaiyan: SuperMan {
    var name: String = "Goku"
    var race: String = "Asian"
    var canFly: Bool = true
    func sayHi() { print("Hi, I'm \(name)") }
    func punch() { print("Puuooookkk") }
}


// Super Animal speaks English
protocol SuperAnimal {
    func speakEnglish()
}

extension SuperAnimal {
    func speakEnglish() { print("I speak English, pretty cool, huh?")}
}

class Donkey: SuperAnimal {
    
}

var ramon = Donkey()
ramon.speakEnglish()





protocol Fightable {
    func legKick()
}

struct StructKangaroo: Fightable {
    func legKick() {
        print("Puuook")
    }
}
class ClassKangroo: Fightable {
    func legKick() {
        print("Pakkkk")
    }
}

let structKangroo = StructKangaroo()
let classKangroo = ClassKangroo()



var kangaroos: [Fightable] = [structKangroo, classKangroo]

for kang in kangaroos {
    kang.legKick()
}



