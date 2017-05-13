# Introduction to Protocol Oriented Programming in Swift

> OOP is okay, but could've been better


### Introduction

即使你还不知道 Class 和 Struct 基本的区别, 你也可以看这个文章。都知道 Struct 不能继承, 但是, 为什么呢？

如果你还不知道上面这个问题的答案, 花两分钟时间读一下下面这段代码。这些代码是写在 playground 上的

```swift
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
classHuman.name //"Bobby"
```

等我们改变 `newClassHuman` 的 `name` 属性为 `“Bobby”` 之后, `classHuman` 的 `name` 属性也变成 `“Bobby”` 了。

我们再看看 Struct 

```swift
struct HumanStruct {
    var name: String
}
var humanStruct = HumanStruct(name: "Bob")
var newHumanStruct = humanStruct
newHumanStruct.name = "Bobby"
humanStruct.name  // "Bobby"
```

看出来区别了吗？ 改变复制出来的 `newHumanStruct` 的 `name` 属性比呢没有改变原始的 `humanStruct` 的 `name` 属性。

对于 Class 来说, 这样的复制出来的对象, 和原来的对象都指向的是内存中的同一个对象。对任何一个对象的改变, 都会改变其他的对象(引用类型)。 对于 Struct 来说, 在传递和赋值的时候会创造一个新的对象(值类型)

[这里有一个介绍这个概念的视频](https://www.youtube.com/watch?v=MNnfUwzJ4ig)


### Bye OOP

你可能会比较好奇为什么我讲了半天跟面向协议编程没关系的东西。在我开始将 POP 对比 OOP 的优势之前， 你得理解引用类型和值类型的区别。

这里有一些毋庸置疑的 OOP 的优势, 也是劣势。

1. 创建一个子类, 这个子类会继承一些并不需要的属性和方法。这会让这个子类变的臃肿。
2. 当你有很多的继承关系的时候, 找到各个类之间的关系, 就变的比较困难了。
3. 当对象指向的内存中的同一块地址的时候, 如果对其中一个进行了修改, 所有的都会变。

顺便看一下 UIKit 中的 OOP 吧

<center>
![](https://cdn-images-1.medium.com/max/1600/1*hjEXB3PGUOSbxet0qUJRNA.png)
2015 WWDC_Hideous Structure
</center>

如果你是刚进苹果的工程师, 你能够搞定这些东西吗？我们在使用它的时候总觉的会比较混乱。

有人说 OOP 是一个让你的代码变的想意大利面那样乱的模块化方案。如果你想要更多吐槽 OOP 的内容. [这儿](https://content.pivotal.io/blog/all-evidence-points-to-oop-being-bullshit)[这儿](https://krakendev.io/blog/subclassing-can-suck-and-heres-why)[这儿](http://www.smashcompany.com/technology/object-oriented-programming-is-an-expensive-disaster-which-must-end)[还有这儿](https://www.leaseweb.com/labs/2015/08/object-oriented-programming-is-exceptionally-bad/)


### Welcome POP

你可能已经猜到了, POP 的基础不是类, 而是值类型变量。没有引用，不像刚刚看到的金字塔结构。 POP 喜欢扁平的, 没那么多嵌套关系的代码。

只是吓你一下啦, 下面我们看看苹果爸爸的官方定义。

> “A protocol defines a blueprint of methods, properties… The protocol can then be adopted by a class, structure, or enumeration” — Apple

> 协议定义了方法属性的蓝图, 协议可以被类、结构体、还有枚举实现。
> 

### Getting Real with POP

首先我们设计一下 human 这个东西。

```swift
protocol Human {
    var name: String {get set}
    var race: String {get set}
    func sayHi()
}
```

在这个协议中, 我没有申明 `drinking`. 它只是声明一些一定存在的东西。现在先不要纠结 `{get set}`. 它只是表明你可以给这个属性赋值也可以取值。先不要担心, 除非你要使用计算属性。

我们在定义一个韩国人 🇰🇷 结构体, 来实现这个协议。

```swift
struct Korean: Human {
    var name: String = "Bob Lee"
    var race: String = "Asian"
    func sayHi() {
        print("Hi, I'm \(name)")
    }
}
```

只要这个结构体遵守了这个协议，它就必须要实现这个协议中的多有方法和属性。如果没有的话 Xcode 就会报错😡

只要是遵守了这个蓝图。你就可以做其他任何事情了, 盖一座长城也没关系。

我们在来实现一个美国人 🇺🇸

```swift
struct Korean: Human {
    var name: String = "Joe Smith"
    var race: String = "White"
    func sayHi() {
        print("Hi, I'm \(name)")
    }
}
```

很酷吧！ 不需要用那些 `init` `override` 关键字。 开始感兴趣了吗？

[Intro to Protocol Lesson](https://www.youtube.com/watch?v=lyzcERHGH_8&t=2s&list=PL8btZwalbjYm5xDXDURW9u86vCtRKaHML&index=1)

### Protocol Inheritance

如果你想要一个 `superman` 的协议。这个协议也需要遵守 `Human` 这个协议呢？

```swift
protocol SuperHuman: Human {
 var canFly: Bool { get set } 
 func punch()
}
```

现在如果你有一个遵守了 `SuperMan` 这个协议的类或者结构体的话，这个类也必须实现 `Human` 这个协议中的方法。

```swift
struct SuperSaiyan: SuperMan {
    var name: String = "Goku"
    var race: String = "Asian"
    var canFly: Bool = true
    func sayHi() { print("Hi, I'm \(name)") }
    func punch() { print("Puuooookkk") }
}
```

当然你也可以遵守多个协议。就可以实现多继承了。

```swift
//Example
struct Example: ProtocolOne, ProtocolTwo {}
```

### Protocol Extension

下面才是协议最强大的特性了。

```swift
// Super Animal speaks English
protocol SuperAnimal {
 func speakEnglish() 
}
```

给这个协议加一个 `Extension`

```swift
extension SuperAnimal {
    func speakEnglish() { print("I speak English, pretty cool, huh?")}
}
```

现在再创建一个遵守这个协议的类

```swift
class Donkey: SuperAnimal {
    
}
var ramon = Donkey()
ramon.speakEnglish()
//  "I speak English, pretty cool, huh?"
```

如果你使用了 `Extension` 就可以给这个协议添加默认的实现和属性值了。这样不爽吗？

### Protocol as Type(Last)

如果我跟你说我能在一个数组中同时放一个对象和一个结构体呢？😮

我要用袋鼠打架求偶来写一个 demo 了。

```swift
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
```

然后初始化俩袋鼠出来

```swift
let structKangroo = StructKangaroo()
let classKangroo = ClassKangroo()
```

现在就可以把他们放在一个数组中了。

```swift
var kangaroos: [Fightable] = [structKang, classKang]
```

难以置信吧！ 再看看

```swift
for kang in kangaroos { 
 kang.legKick() 
}
// "Puuook"
// "Pakkkk"
```

这很爽吧！ 想象在 OOP 中我们怎么实现这个东西呢？


### That's it!
[原文地址](https://blog.bobthedeveloper.io/protocol-oriented-programming-view-in-swift-3-8bcb3305c427)

### 最后

我是一名来自中国的 iOS 程序员, 对技术有着浓厚的兴趣, 在学习的过程中, 发现了很多来自国外的优秀博客。为了更好的学习这些文章, 产生了将这些文章翻译成中文的想法。



