## RxSwift and the awesome things you can do with Reactive Programming — Part I

本文翻译自国外的美女工程师 [Kenza Iraki](https://medium.com/@kenzai) 的文章 [RxSwift and the awesome things you can do with Reactive Programming — Part I](https://medium.com/@kenzai/rxswift-and-the-awesome-things-you-can-do-with-reactive-programming-part-i-3921137d251)

date: 2017-5-5

第一次听见响应式编程，我的表情是这样的

<center>
<img src="https://cdn-images-1.medium.com/max/1600/1*28RdzpfQBHklPcgLGsg0jw.png">
</center>

接下来的几次几次接触, 也并没有什么改变。整整两个星期之后,即使我在项目中写了一些响应式代码。我依然是这种感觉。

现在我才知道有很多的人在第一次遇见响应式编程的时候跟我有一样的感觉。我也知道很多人看过响应式的代码之后再也不想再见到它了，因为她的学习曲线太过陡峭了。但是我能告诉你一个事实, 我还没听说过一个人， 在最终理解了他是怎么回事之后,后悔学习响应式编程。

我知道网上有很多关于响应式编程理论和思想还有 RxSwift 的的资源, 也有很多教你用Rx来做各种事情的教程(文末我会给出一些链接)。这篇文章不是是一个教程, 也不会解释 `stream` 和 `observables` 是怎么回事。 我要做的是提供一个直接、明确并且尽量少的理论总结来告诉你 RxSwift 能做什么, 并且告诉你为什么你会喜欢上它。由于 Rx 的世界深似海, 所以我打算写三篇文章来讨论这件事情, 这是第一篇。

## Part1: Data Binding, control events and gesture recognizers

### Data Binding

数据绑定看起来像是一个高端的词语, 但是它却是一件非常简单的事情。假如你有一个 App 需要用户在 `UITextField` 中输入它们的名字。当他们在打字的时候, 用 “你好 + 用户输入的文字” 展示在界面上。这样一个很基本的场景。如果在不是响应式的程序中, 我们需要遵守 `UITextFieldDelegate` 这个协议, 然后在 `ViewController` 中实现 `textFieldDidEndEditing` 这个方法, 来监听用户用户的行为，然后给 `Label` 赋值。

虽然很简单，但是假如有很多的 `UITextField` 我们还要在代理方法中判断, 又或者, 我们需要用户在输入的过程中时时的刷新 `Label`。这种场景, 我们的代码，看起来就会很糟糕。至少不会很优雅吧。

在响应式中, 这种情况就可以用数据绑定来实现。说白了,就是将用户在 `UITextField` 中输入的文字绑定到 `UILabel` 上。在 `RxSwift` 的世界里,  没有什么比处理数据绑定更简单的了。刚才描述的需求, 我们只需要通过以下代码就可以实现了。

<!--more-->

```swift
var namefield = UITextField()
var helloLabel = UILabel()
override func viewDidLoad() {
    nameField.rx.text.map { "Hello \($0)" }
                     .bindTo(helloLabel.rx.text)
```

上面的代码， 我们首先是获取到了 `UITextField` 的文字。 然后我们将这段文字映射成想要的格式，然后赋值给 `UILabel`。 在这里，我们之间见到的在文字前面加了一个 `'hello'`， 因为 map 是一个闭包, 可以简单的被看作一个匿名函数, 它的参数:`$0`(第一个参数)、`$1`(第二个参数)以此类推。然后将映射后的文字绑定到 `UILabel` 的 `text` 属性上。就这么简单，这个需求就完成了。没有使用代理，也没有用各种 if 语句, 就简单明了的几行代码。

你先在肯定在想,"是，这是很神奇, 但是真的有很多 app 在这样做吗" 我可以告诉你，是的。不要仅仅是限制在这简单的几个例子中。能够将数据绑定到视图是非常强大的事情。你想想看，如果我们有一个视图的背景颜色需要根据天气用户的地理位置而改变。基于可能变化的数据和一些简单的逻辑, 不需要太过深入的研究它背后的东西。这就是数据绑定最主要的思想。


### Control Events and Gesture Recognizers

简单的说一下什么是事件吧！事件基本上是用户能在你的 app 上操作的所有行为，点击、滑动、拖拽等等。当用户按下一个按钮的时候，你的程序会监听到一个 `UIControlEvent` 的事件类型 `.touchUpInSide`。 如果你用的是 `StoryBoary` ，你可能在创建 `IBAction` 的时候，没有想过这个按钮的行为。我已经写了一篇[why I never use storyboards]() 。如果你跟我一样,这段代码你肯定会很熟悉了

```swift
var button = UIButton()
override func viewDidLoad() {
    button.addTarget(#selector(ViewController.loginUser), target: self, event: .touchUpInside
}
func loginUser() {
    // Implementation here
}
```

我真的很讨厌 Selector, 这些代码太不明确了，让代码看起来很乱，也让我们更容易犯错。但是用 Rx 这样就可以了：

```swift
var button = UIButton()
var disposeBag = DisposeBag()
override func viewDidLoad() {
    button.rx.tap.subscribe { onNext _ in
        // Implementation here
    }.addDisposableTo(disposeBag)
}
```

不要太过纠结 `disposeBag` 和 `subscribe` 这些东西。你只要知道这些是一些必须的动作就可以了。(下面会有介绍)

当你需要给不具有 control event 的控件添加一些逻辑事件, 比如给 `UILabel` 或者 `UIImageView` 添加点击事件的时候。我们只能给他添加手势。(这是我做讨厌的 UIKit 特点之一)。


```swift
let label = UILabel()
override func viewDidLoad() {
    // Show example of gesture recognizers
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: “handleTap:”)
    label.addGestureRecognizer(gestureRecognizer)
}
func handleTap() {
    // Your logic here
}
```

其他的手势，如果你需要响应的话。你就需要给这个控件添加多个 `gesture recognizer` ,你要创建多个手势，然后挨个添加到这个控件上。这不仅是很多样板代码这么简单，这也可能带来一些难以想象的混乱和潜在的错误。

你可以已经想到了。Rx 让这个东西变的异常的简单：

```swift
let label = UILabel()
let disposeBag = DisposeBag()
override func viewDidLoad() {
    label.rx.gesture(.tap).subscribe {onNext (gesture) in
        // Your logic here
    }.addDisposableTo(disposeBag)
}
```

假如你需要添加多个手势的话:

```swift
let label = UILabel()
let disposeBag = DisposeBag()
override func viewDidLoad() {
    label.rx.gesture(.tap, .pan, .swipeUp).subscribe { onNext (gesture) in
        switch gesture {
        case .tap: // Do something
        case .pan: // Do something
        case .swipeUp: // Do something 
        default: break       
        }        
    }.addDisposableTo(disposeBag)
}
```

这些都是一个叫 [RxGesture](https://github.com/RxSwiftCommunity/RxGesture) 的 RxSwift 库提供的。


**参考资料**

[ReactiveX/RxSwift](https://github.com/ReactiveX/RxSwift)

[Functional Reactive Awesomeness With Swift](https://realm.io/news/altconf-ash-furrow-functional-reactive-swift/)

[My journey with reactive programming in Swift — and the iOS app that came out of it.](https://medium.com/swift-programming/reactive-swift-3b6050375534)

[DTVD/The-introduction-to-RxSwift-you-have-been-missing](https://github.com/DTVD/The-introduction-to-RxSwift-you-have-been-missing)

[RxSwift by Examples #1 – The basics.](https://www.thedroidsonroids.com/blog/ios/rxswift-by-examples-1-the-basics/)

[I create iOS apps - is RxSwift for me?](https://news.realm.io/news/tryswift-Marin-Todorov-I-create-iOS-apps-is-RxSwift-for-me/)

