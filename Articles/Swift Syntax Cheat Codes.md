
# Swift: Syntax Cheat Codes

这篇文章主要介绍一些很常见的语法。


### 闭包

```swift
() -> Void
```

也叫做 `匿名函数`。闭包是自包含的函数代码块，可以在代码中被传递和使用。在 `C` 和 `OC` 中有 `block` 与之对应。

如果你之前就有 iOS 开发经验, 你肯定看到过 UIView 动画的 API

<!--more-->

```swift
class func animate(withDuration duration: NSTimeInterval,
 animations: @escaping() -> Void)
```

`animations`就是动画的参数。

```swift
UIView.animate(withDuration: 10.0, animations: {
    button.alpha = 0
})
```

`animationWithDuration` 方法就会使用这个闭包做一件事情:让button慢慢的消失。

### 尾随闭包

```swift
UIView.animate(withDuration: 10.0) { 
    button.alpha = 0
}
```

这是 Swift 的特性之一, 这样可以节省一些没什么必要存在的代码。看这段的代码, 跟上面的代码调用的是同一个 API, 只是这段代码使用了更简洁的语法。

因为 `animate` 这个方法的最后一个参数是一个闭包---**尾随闭包**。尾随闭包允许我们在编码的时候省略掉最后的参数名, 并让他从参数列表那个括号里面移出来。这样会让代码更优雅简洁。

```swift
func say(_ message: String, completion: @escaping () -> Void) {
    print(message)
    completion()
}
// 没有使用尾随闭包
say("Hello", completion: {
    // prints: "Hello" 
    // Do some other stuff
})
// 使用了尾随闭包
say("Hello") {
    // prints: "Hello"
    // Do some other stuff
}
```


### 类型别名

```swift
typealias
```

类型别名是一个很有用的小工具, 能尽可能少的减少重复代码。看下面的例子:

```swift
func dance(do:(Int, String, Double) -> (Int, String, Double)) {}
```

这段代码的功能其实很简单, 但是如果在其他方法中也需要传递这个闭包的话, 我们就应该记住这个闭包, 并且保证在任何我们使用它的地方都是一致的, 不然编译器可能就不高兴了。

```swift
func dance(do: (Int, String, Double) -> (Int, String, Double)) { }
func sing(do: (Int, String, Double) -> (Int, String, Double)) { }
func act(do: (Int, String, Double) -> (Int, String, Double)) { }
```

但是如果某个时刻我们需要修改一下这个闭包。这就尴尬了, 上面三个方法都需要去修改。 这就是使用**类型别名**的场景。

```swift
typealias TripleThreat = (Int, String, Double) -> (Int, String, Double)
func dance(dance: TripleThreat) { }
func act(act: TripleThreat) { }
func sing(sing: TripleThreat) { }
```

这样写的话, 只要我们需要修改这个闭包的时候, 就只需要修改一个地方了。

**喜闻乐见的类型别名**

```
typealias Void = ()
typealias NSTimeInterval = Double
```


### 参数名缩写

```swift
$0,$1,$2
```

一个闭包内有参数的情况下, 你可以在闭包定义中省略参数列表，并且对应参数名称缩写的类型会 通过函数类型进行推断。

```swift
func say(_ message: String, completion: (_ goodbye: String) -> Void) {
    print(message)
    completion("Goodbye")
}
...
say("Hi") { (goodbye: String) -> Void in
    print(goodbye)
}
// prints: "Hi"
// prints: "Goodbye"
```

这个例子中，这个尾随闭包有一个 `String` 类型的 `goodbye` 参数。Xcode 会自动把它放在一个元组里面。用 `in` 来表示参数、返回值的结束。并另起一行来实现我们想要的功能。当这个闭包很小的时候，这样写就显得代码非常的冗长了。我们来改造一下段代码。

```swift
(goodbye: String) -> Void in
```

这段代码完全没有必要写出来。使用参数名缩写就好了。

```swift
say("Hi") { print($0) }
// prints: "Hi"
// prints: "Goodbye"
```

你看, 这样写完全省略掉了闭包的参数还有返回值声明的代码。因为在这个场景中，我们完全没有必要使用参数名。每个参数都按照声明的顺序命名好了。这么简单, 直接放在一行代码里就可以了。

如果有不止一个参数的时候应该怎么弄呢？我也不想解释了, 直接看下面的代码: 

```swift
(goodbye: String, name: String, age: Int) -> Void in
// $0: goodbye
// $1: name
// $2: age
```


### 返回 Self

```swift
-> Self
```

Swift2.0 带来的一大堆操作符(map, flatmap), 这些操作符更给力的是让我们能够使用 `.` 语法链式的调用一系列方法。

```swift
[1 , 2, 3, nil, 5]
    .flatMap {$0}    // 移除空
    .filter {$0 < 3} // 过滤大于2的值
    .map {$0 * 100}  // 每个值放大100倍
// [100, 200]
```

这样太优雅了, 既可读又易于理解。

假设我们为`String`建一个扩展, 在字符串的本身上执行一些操作, 而不使函数返回 `Void` 而是他自己.

```swift
// extension UIView
func with(backgroundColor: UIColor) -> Self {
    backgroundColor = color
    return self
}

func with(cornerRadius: CGFloat) -> Self {
    layer.cornerRadius = 3
    return self
}

let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
          .with(backgroundColor: .black)
          .with(cornerRadius: 3)
```


### That's it!
[原文地址](https://medium.com/swift-programming/swift-syntax-cheat-codes-9ce4ab4bc82e)

### 最后

我是一名来自中国的 iOS 程序员, 对技术有着浓厚的兴趣, 在学习的过程中, 发现了很多来自国外的优秀博客。为了更好的学习这些文章, 产生了将这些文章翻译成中文的想法。


