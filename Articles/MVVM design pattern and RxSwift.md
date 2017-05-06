
## MVVM design pattern and RxSwift

本文翻译自(http://lukagabric.com/mvvm-design-pattern-and-rxswift/)

date: 2017-5-6

### MVVM
MVVM 是一种设计模式。他是程序的代码分离成三个部分: `Model`、`View`、`ViewModel`。 `Model` 代表数据的表现, `View` 代表用户看到的界面，`ViewModel` 代表着模型层和视图层的主要关联关系。

#### Model

`Model` 就是数据层。他包括一定范围内的模型，和业务逻辑。 `Model` 并不只是你程序中的那些模型结构体或者数据库, 他也包含了一些 Service 或者组件, 比如说 `Alamofire`和一些 SDK 等等。

`Model` 层执行所有跟数据有关的操作。比如常见的增删改查等等。这些操作由 `ViewModel` 发起。当 `Model`操作完了数据之后它再告诉 `ViewModel` 结果。
 
`Model` 被 ViewModel 持有。他也并不知道视图层和 `ViewModel` 层的事情。因为他是和这两个东西完全隔离开的。

#### View

`View` 是程序中数据的可视化展示。它没有逻辑相关的东西。他主要有接受用户交互事件，和将数据展示在界面上两个人物。它将用户交互的事件转发到 `ViewModel` 中进行处理。`View` 观察 `ViewModel` 中数据的变化, 并且将这些变化展现出来。

`View` 和 `Model` 之间没有任何直接的关联。 他们通过 `View` 持有的 `ViewModel` 产生关联。

界面信息在 `xib` 或者 `StoryBoard` 中通过 `UIKit` 中的组件被定义。`ViewController` 是直接跟 `xib` 或者 `StoryBoard` 关联的。它包含了 `Xib` 或者 `StoryBoard` 中的 `outlets` 和一些定义 UI 的额外配置。他也负责管理 `View` 的生命周期。 在 MVVM 中他和 `View` 的关联是非常紧密的, 他其实就是 `View` 层的一部分。

#### ViewModel

`ViewModel` 是程序的逻辑层。他处理用户交互行为。然后更新数据。然后在通知 `View` 新的数据和显示的方式。举一个很平常的例子。一个 ViewModel 从Model层中请求到了一些包含 `Date` 的模型。 这个 Date 值并不会被告诉给 View, ViewModel 告诉 View 的应该是被格式化之后的字符串。视图不会操作数据本身，他只负责将 ViewModel 准备好的数据展示出来。

#### Similar to MVC

在 MVC 设计模式中, `ViewController` 是 `Model` 和 `View` 之间的桥梁。他只有视图, 管理视图的结构，管理用户的交互。他还负责管理视图的生命周期,加载、显示、消失等。他具有的另外一个指责是更新模型数据, 这就包括了显示数据的相关逻辑(也就是数据的处理,如上文提到的讲 `Date` 转化成 `String` 的逻辑)。因为他具有这么多的职责，所以很多情况下 `Viewcontroller` 就会变的非常大。所以也有人称MVC 为 Massive View Controller

出现复杂的 `viewController` 主要有两个原因。由于 `Controller` 有很多的职责。代码就会变的非常的复杂。这很明显就违背了单一职责这个原则。这也让测试 `Controller` 中的逻辑变成一件很麻烦的事情。`Controller` 和 `View` 的高度耦合。`view` 的生命周期使得逻辑的分离变的不那么容易。我们就需要花很大的精力来处理视图的生命周期。

MVVM 和 MVC 非常相似。 正如前文所说。 MVC 中的 `Controller` 同时包含了视图和程序的逻辑。将逻辑相关的代码从 `Controller` 中分离出来, 放到他自己抽象出来的类里面去。这时候的 `Controller `就只关注视图相关的事情。刚刚分离出来的这个类处理相关的逻辑。这个类就是 ViewModel。他和 `Controller` 具有一一对应关系。所以说 MVVM 就是将逻辑代码从 `controller`中分离到 `ViewModel` 中的 MVC

#### Binding data from ViewModel to View

有很多将数据绑定的机制, 比如 Swift 中的属性观察。视图可以对外提供一个 Closure 来进行视图的更新。这个 Closure 用来通知 View 他关联的属性的更新。除了熟悉观察。我们的程序还经常需要处理各种异步操作，比如网络请求，和通知或者事件的流信息。函数响应式编程(FRP)框架简直就是为了处理这类事件而生的。现在也有很多FRP 框架，对 iOS 开发来说，最出名的应该是 `RxSwift` 和 `ReactiveCocoa`了。之前在一篇对比文章中有提到过, 不管怎样，我更喜欢 `RxSwift` 

### RxSwift

指令式编程是基于一步一步明确的指令来执行的。他详细的描述了程序的运行过程。值做为状态而存在。由于程序是一步一步的执行的,所以如果其中一个值在之后发生了改变，这一改变也不会被传到下一步。

```swift
// 指令式编程
a = 1
b = 2
c = a + b  // c = 3
a = 5   // c = 3
```

响应式编程,跟指令式相反。他是基于变化的。他基于声明式编程，这就意味着他关注的是程序应该完成什么，而不是程序是怎么运行的。它是通过数学运算和其他像是 `filter` `map` `reduce` 之类的运算操作的运用来实现的。如何准确的运行被交给底层的程序语言或者框架来考虑了。

```swift
// 响应式编程
a = 1
b = 2
c = a + b // c = 3
a = 5     // c = 7
```

RxSwift 让你能用通过函数响应式编程来编写你的代码。使用 RxSwift 可以很轻松的创建事件或者数据流。这些事件或者数据流可以互相组合、转换。并且最终被观察到，基于值来进行一些操作。

正如前文所说，在 MVVM 中 View 观察 ViewModel 中模型的数据。RxSwift 提供了一个非常简单并且干净的方法来观察这些值，并绑定到对应的 View 上。

<!--more-->

#### Observable

Observable 是 RxSwift 的主要构成部分。他是一个可以异步的接受元素的序列。这个序列可以有0个或者很多个的元素。有三种事件能够基于它发生。下一步(Next)、完成(Completed)、错误(Error)

```swift
enum Event {
    case next(Element)   // 这个序列的下一个元素
    case error(Swift.Error)// 这个序列发生了错误
    case completed      // 这个序列成功的完成的所有人任务
}
```

可以使用 `Observable` 的 `subscribe` 方法来订阅这些事件。 用这种方法可以分别处理这个事件的各种情况。

* OnNext: 可以使用被订阅的元素值。
* OnCompleted: 当这个序列成功的发送完所有元素之后会被调用。
* OnError: 当这个序列不能完成的时候被调用。

只要 `Complete` 或者 `Error` 被观察到了, 这个序列就不能产生任何新的元素了。

```swift
observable.subscribe(
    onNext: { element in ... }, 
    onError: { error in ... },
    onCompleted: { ... }
)
```

#### Hot and cold observables

即使没有被观察也会发送消息的信号被称作热信号。想象一下 `NotificationCenter` 技术没有其他对象接受通知, 也也然会发送出来。如果你在某个时候订阅了这个信号, 之前发出来的消息你就会错过。

那些只有被订阅之后才开始发送消息的信号被称作冷信号。这些资源会被分配给每个订阅对象。(比如说，你每次订阅的网络请求就会被释放)但是这些资源可以被多个对象共享(只有一个网络请求被释放了,但可能这被很多个观察者订阅)

#### Driver

Driver 是 RxCocoa 框架中的一个值类型。它是对一个可订阅的序列的封装，如果要把一个简单的值绑定到View上, 它会是一个更简单的方法。如果 `Observables` 发生了错误, 你需要很方便的将一些东西展示出来。每个信号都可以很容易的被转换成 `Driver`。 当你提供了这个信号发生错误的返回什么的时候，只需要使用 `asDriver` 方法就可以了。

```swift
.asDriver(onErrorJustReturn: "No items to display.")
```

想象一下异步操作的场景。比如说网络请求。我们需要在界面上展示返回值的个数。在这个场景中，我们需要将返回值的个数映射成一个字符串。可能这个字符串的格式可能是 `"X item(s)"` `Driver` 还能够确保我们需要修改 UI 的这个订阅是发生在主线程当中的。

```swift
let results: Observable<[SomeItem]> = ...
let resultsCountDriver = results
    .map { "\($0.count) item(s)" }
    .asDriver(onErrorJustReturn: "No items to display.")
```

把这个数据绑定到 Label 中就很简单了

```swift
resultsCountDriver.drive(resultCountLabel.rx.text).disposed(by: disposeBag)
```

#### DisposeBag

如果一个序列停止了, 但是它并没有被释放掉。在他就会造成资源的浪费和内存的泄漏。知道他完成了或者处错了。如果一个序列没有停止，也没有出错，这个资源就会被永久的占用。这就是为什么我们要在需要订阅的对象中生命一个 `DisposeBag` 的成员变量的原因了。这样的话，只要这个对象呗释放掉了，所有相关的资源都会被释放并且被系统回收。

#### Variable

`Variable`表示可以被订阅的状态。它是信号和功能范式之间的桥梁。`Variable` 总是包含了提供给构造函数的初始值当你订阅当前的值的时候，这个初始值会立马被发送到过来。(只有最新和当前值会被发出，旧的值不会)。也可以直接获取或者设置 `Variable` 的值。他内部的信号可以通过 `asObservable` 方法获取到。另外, `Variable` 永远都不会出错。

```swift
let variable = Variable("My Variable")
variable.value = "Some value"
let variableObservable = variable.asObservable()
variableObservable.subscribe(onNext: { value in
    print(value) //prints "Some value"
})
```


最后， 我写了一个 Demo 来演示 MVVM + RxSwift. 这是一个简单的程序获取并且显示天气的数据。这个app有三种状态， 加载中，显示中，错误。有两种对错误的处理，一是，我们只显示错误。另一个是显示之前的数据。如果没有，就显示错误。这两种处理方式都是通过响应式编程和指令式编程实现的。

在这些例子中，只有 ViewMoel 会发生改变。你可以看到给功能增加复杂性(显示错误或者旧的数据)。如果使用指令式编程，可能会对代码带来很多的变动。而使用响应式编程，只需要增加额外的状态而已。







