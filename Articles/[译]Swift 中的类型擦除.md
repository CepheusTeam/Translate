
# [译]Swift 中的类型擦除



你可能听过这个术语 :**类型擦除**。甚至你也用过标准库中的类型擦除(`AnySequence`)。但是具体什么是类型擦除, 我们怎么才能实现类型擦除呢？这篇文章就是介绍这件事情的。

在日常的开发中, 总有想要把某个类或者是某些实现细节对其他模块隐藏起来, 不然总会感觉这些类在项目里到处都是。或者想要实现两个不同类之间的互相转换。类型擦除就是一个移除某个类的类型标准， 将其变得更加通用的过程。

到这里很自然的就会想到协议或者是提取抽象的父类来做这件事情。**协议**或者**父类** 就可以看作是一种实现类型擦除的方式。举个例子:

**NSString** 在标准库中我们是没办法得到 `NSString` 的实例的，我们得到的所有的 `NSString` 对象其实都是标准库中 `NSString` 的私有子类。这些私有类型对外界可以说是完全隐藏起来了的, 同时可以是用 `NSString` 的 API 来使用这些实例。所有的子类我们在使用的时候都不需要知道他们具体是什么, 也就不需要考虑他们具体的类型信息了。

在处理 Swift 中的泛型和有关联类型的协议的时候, 就需要一些更高级的东西了。Swift 不允许把协议当作类来使用。如果你想要写一个**接受一个 Int 类型的序列的方法**。这么写是不对的:

```swift
func f(seq: Sequence<Int>) {...}

// Compile error： Cannot specialize non-generic type 'Sequence'
```

<!--more-->

这种情况下, 我们应该考虑使用的是泛型:

```swift
func f<S: Sequence>(seq: S) where S.Element == Int { ... }
```

这样写就可以了。**但是**, 还是有一些情况是比较麻烦的比如说: **我们无法使用这样的代码来表达返回值类型或者是属性**。

```swift
func g<S: Sequence>() -> S where S.Element == Int { ... }
```

这么写并不会是我们想要的那种结果。在这行代码中，我们想要的是返回一个满足条件的类的实例，但是这行代码会允许调用者去选择他想要的具体的类型, 然后 `g` 这个方法去提供合适的值。

```swift
protocol Fork {
    associatedtype E
    func call() -> E
}

struct Dog: Fork {
    typealias E = String
    func call() -> String {
        return "🐶"
    }
}

struct Cat: Fork {
    typealias E = Int
    
    func call() -> Int {
        return 1
    }
}

func g<S: Fork>() -> S where S.E == String {
    return Dog() as! S
}

// 在这里可以看出来。g 这个函数具体返回什么东西是在调用的时候决定的。就是说要想正确的使用 g 这个函数必须使用  `let dog: Dog = g()`  这样的代码
let dog: Dog = g()
dog.call()

// error
let dog = g()
let cat: Cat = g()
```

Swift 提供了 AnySequence 这个类来解决这个问题。AnySequence 包装了任意的 Sequence 并把他的类型信息给隐藏起来了。然后通过 AnySequence 来代替这个。有了 AnySequence 我们可以这样来写上面的 `f` 和 `g` 方法。

```swift
func f(seq: AnySequence<Int>) { ... }
func g() -> AnySequence<Int> { ... }
```

这么一来， 泛型没有了， 而且所有具体的类型信息都被隐藏起来了。使用 AnySequence 增加了一点点的复杂性和运行成本，但是代码却更干净了。

Swift 标准库中有很多这样的类型, 比如 `AnyCollection`, `AnyHashable`, `AnyIndex` 等。 在代码中你可以自己定义一些泛型或者协议,  或者直接使用这些特性来简化代码。



## 基于类的擦除

**我们需要在不公开类型信息的情况下从多个类型中包装出来一些公共的功能**。这很自然就能想到抽象父类。事实上我们确实可以通过**抽象父类**来实现**类型擦除**。父类暴露 API 出来，子类根据具体的类型信息来做具体的实现。我们来看看怎么自己实现一个类似 AnySequence 的东西。

```swift
class MAnySequence<Element>: Sequence {
```

这个类需要实现 `iterator` 类型作为 `makeIterator` 的返回类型。我们必须要做两次类型擦除来隐藏底层的序列类型以及迭代器的类型。这种内在的迭代器类型遵守了 `IteratorProtocol` 协议并且在 `next()` 方法中使用 `fatalError` 来抛出异常。Swift 本身是不支持抽象类的， 所以这就足够了:

```swift
    class Iterator: IteratorProtocol {
        func next() -> Element? {
            fatalError("Must override next()")
        }
    }
```

`ManySequence` 对 `makeIterator` 方法的实现也差不多， 使用 `fatalError` 来抛出异常。 这个错误用来提示子类来实现这个功能:

```swift
    func makeIterator() -> Iterator {
        fatalError("Must override makeIterator()")
    }
```

这就是**基于类的类型擦除**需要的公共 API。私有的实现需要去子类化这个类。这公共类被元素的类型参数化, 但是私有的实现却在这个类型当中:

```swift
private class MAnySequenceImpl<Seq: Sequence>: MAnySequence<Seq.Element> {
```

这个类需要内部的子类来实现上面提到的两个方法:

```swift
class IteratorImpl: Iterator {
```

这一步包装了这个序列的迭代器的类型

```swift
    class IteratorImpl: Iterator {
        var wrapped: Seq.Iterator
        
        init(_ wrapped: Seq.Iterator) {
            self.wrapped = wrapped
        }
    }
```

这一步实现了 `next` 方法。 实际上是调用它包装的序列的迭代器的 `next` 方法.

```swift
        override func next() -> Element? {
            return wrapped.next()
        }
```

相似的， `MAnySequenceImpl` 是 sequence 的包装。

```swift
    var seq: Seq
    
    init(_ seq: Seq) {
        self.seq = seq
    }
```

这一步实现了 `makeIterator` 方法。从包装的序列中去获取迭代去对象, 然后把这个迭代器对象包装给 `IteratorImpl`。

```swift
    override func makeIterator() -> IteratorImpl {
        return IteratorImpl(seq.makeIterator())
    }
```

还需要一点: 使用 `MAnySequence` 来初始化一个 `MAnySequenceImpl`，但是返回值还是标记成 `MAnySequence` 类型。

```swift
extension MAnySequence {
    static func make<Seq: Sequence>(_ seq: Seq) -> MAnySequence<Element> where Seq.Element == Element {
        return MAnySequenceImpl<Seq>(seq)
    }
}
```

我们来用一下这个 `MAnySequence`:

```swift
func printInts(_ seq: MAnySequence<Int>) {
    for elt in seq {
        print(elt)
    }
}

let array = [1, 2, 3, 4, 5]
printInts(MAnySequence.make(array))
printInts(MAnySequence.make(array[1 ..< 4]))
```



## 基于函数的擦除

**我们希望公开多个类型的功能而不公开这些类型。**很自然的方法是储存那些签名只涉及到我们想要公开的类型的函数。函数的主体可以在底层信息已知的上下文中创建。

我们来看看 MAnySequence 要怎么来实现呢？更上面的内容差不多。只是这次因为我们不需要继承而且他只是一个容器，所以我们用 Struct 来实现。

还是声明一个 Struct

```swift
struct MAnySequence<Element>: Sequence {
```

跟上面一样, 实现 Sequence 协议需要有一个迭代器(Iterator)来作为返回值。这个东西也是一个 `struct` 它有一个储存属性, 这个储存属性是一个不接受参数， 返回一个` Element?`  的函数。 他是 `IteratorProtocol` 这个协议要求的

```swift
    struct Iterator: IteratorProtocol {
        let _next: () -> Element?
        
        func next() -> Element? {
            return _next()
        }
    }
```

`MAnySequence` 跟这个也相似。他包含了一个返回 `Iterator`  的函数的储存属性。 Sequence 通过调用这个函数来实现。

```swift
    let _makeIterator: () -> Iterator
    
    func makeIterator() -> Iterator {
        return _makeIterator()
    }
```

`MAnySequence`  的 `init` 方法是最重要的地方。他接受任意的 `Sequence` 作为参数(`Sequence<Int>`、` Sequence<String>`):

```swift
init<Seq: Sequence>(_ seq: Seq) where Seq.Element == Element {
```

然后需要把这个 Sequence 需要的功能包装在这个函数中:

```swift
        _makeIterator = {
```

再然后我们需要在这里做一个迭代器 `Sequence` 正好有这个东西：

```swift
var iterator = seq.makeIterator()
```

最后我们把这个迭代器包装给 `MAnySequence`。 他的 `_next` 函数就能调用到 `iterator` 的 `next` 函数了：

```swift
            return Iterator(_next: { iterator.next() })
        }
    }
}
```

下面看这个 MAnySequence 是怎么用的:

```swift
func printInts(_ seq: MAnySequence<Int>) {
    for elt in seq {
        print(elt)
    }
}

let array = [1, 2, 3, 4, 5]
printInts(MAnySequence(array))
printInts(MAnySequence(array[1 ..< 4]))
```

搞定！

这种基于函数的擦除方法在处理需要把一小部分功能作为更大类型的一部分来包装的时候非常有效, 这样做就不需要有单独的类来擦除其他类的类型信息。

比如说，我们需要写一些能在特定几个集合类型上面使用的代码：

```swift
class GenericDataSource<Element> {
    let count: () -> Int
    
    let getElement: (Int) -> Element
    
    init<C: Collection>(_ c: C) where C.Element == Element, C.Index == Int {
        count = { Int(c.count) }
        getElement = { c[$0 - c.startIndex]}
    }
}
```

这样， `GenericDataSource` 中的其他代码就能够直接使用 `count()`、 ` getElement()` 两个方法来操作传入的collection 了。并且这个集合类型不会污染 `GenericDataSource` 的泛型参数。



## 总结

类型擦除是个非常有用的技术。他被用来阻止泛型对代码的侵入,  也能够让接口更加的简单。通过将底层的类型信息包装起来, 将 API 和具体的功能分开。使用静态的公有类型或者将 API 包装进函数都能够做到类型擦除。基于函数做类型擦除对那种只需要几个功能的简单情况尤其有用。

Swift 标准库提供了一些可以直接使用的类型擦除。`AnySequence` 是 `Sequence` 的包装,  从名字可以看出来, 他允许你在不知道具体类型的情况下迭代遍历某个序列。`AnyIterator` 是他的好朋友, 它提供了一个类型已经被擦除掉的迭代器。`AnyHashable` 包装了类型擦除掉了的 `Hashable` 类型。Swift 中还有一些基于集合类型的协议。在文档中搜索 “Any” 就可以看到。标准库中的 `Codable` 也有用到了类型擦除： `KeyedEncodingContainer` 和 `KeyedDecodingContainer` 都是对应协议类型擦除的包装。他们用来在不知道具体类型信息的情况下实现 encode 还有 decode。

 

## 最后

前几天看到 MikeAsh 最新的 *Friday Q&A* [Type Erasure in Swift](https://www.mikeash.com/pyblog/friday-qa-2017-12-08-type-erasure-in-swift.html)。想趁着最近没什么事情翻译一下的。结果最近一直沉迷吃鸡， 没有时间去做这件事情。所以...



