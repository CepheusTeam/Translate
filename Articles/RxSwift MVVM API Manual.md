## RxSwift MVVM API Manual 📃

现在我们掌握了所有的工具, 也明确了他存在的风险以及规避的方法。现在是时候想想应该怎么样最大可能的运用它了。以 MVVM 为例。

又很多方法来写 RxSwift 的 API。 我怕的做法是: 利用 RxSwift 很酷的观察者模式和很方便的操作符, 管理异步的任务。可能不是 100% 纯正的 RxSwift。 在将我做过很多的尝试试图将两种编程思维统一起来,但是我都失败了。

下面是一些我使用 RxSwift 的方法。

### Be Consistent

这是在接口设计中最重要的事情, 如果你做出了选择。就坚持下去。

既然如此, 现在就开始吧！**input vs output**

```swift
class FilterViewModel {
    //Input
    let filterButtonEvents: BehaviorSubject<Int>
    let filterSelectionEvent: PublishSubject<Int>
    
    //OutPut
    let currentFilter: Observable<Int>
    let shouldShowFilter: Observable<Bool>
    
}
```

有好几个可以用来声明 inout 和 output 的组合。这是我最喜欢的一个。

#### Input

通过将 `input` 声明成 `subject` 类型。我可以很方便的使用 `RxSwift` 中的各种操作符。我用的最多的应该是 **throttle**。

```swift
        filterButtonEvents
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (counter) in
            self?.makeRequest()
        })
```

当然用 observable 做 input 也是可以的。

#### Output

记住 `output` 应该是 `Observable`, 甚至是 `Subject`。 如果不这样的话，一些外部的类可能会错误的把这他当做是 `output` 这样就打破了封装了。当我想要发出一个变量的时候, 就是强制的释放。

```swift
    (observable as! PublishSubject)
        .onNext("Ugly...")
```

如果你知道有更好的方法, 一定要告诉我。我感觉这么干是在是不优雅😱。

### Safety

如果在一个简单的 Demo 中, 你可能记得做所有的细节。但在一个复杂的 app 中, 你几乎不可能记得住所有的实现细节。这里面可能有好几百个订阅者。 `Observable` 又是一个非常广泛的类型。都还没有说这个信号是热信号还是冷信号, 他是在主线程还是在后台线程中运行。这也是 `Driver` 被设计出来的原因, 为了让 API 更加明确。我们鼓励自己去创建一些单元。

**Driver** 是一个热信号, 而且是运行在主线程当中的。好想忽略掉了冷信号？没关系, 创造一个就是了。我称他作 **Template** 因为冷信号就是是一个模版, 在这个模版中你可以用 `subscribe` 来运行他。

```swift
class Template<Element> {
    
    let observable: Observable<Element>
    
    init(_ subscribe: @escaping (AnyObserver<Element>) -> Disposable) {
        observable = Observable.create(subscribe)
            .subscribeOn(MainScheduler.instance)
    }
    
}
```

这样 `Template` 就能确保是一个在主线程中执行的冷信号。

```
class MyViewModel {
 //Cold ❄️
 let createRequest : Template<Int>
 //Hot 🌶
 let shouldShowelement : Driver<Bool>
}
```

这样看, 程序中暴露的接口就很明确了。


### MVVM State Machine

涉及到状态的管理的时候, `ViewController` 经常会变得很复杂。如果在 `viewModel` 中使用状态机, 来告诉 `ViewController` 在什么时候应该怎么做。[这里有一篇不错的文章](http://curtclifton.net/generic-state-machine-in-swift)

* 把这些状态放在一个枚举里面, 而不是分散在各个地方。这样做可以极大的减少你的 `Observable`。
* 这也会强迫你吧更多的逻辑移到 `ViewModel` 里面。
* 让你的代码更加的具有声明性。
👋

[原文地址](http://swiftpearls.com/mvvm-state-manage.html)

### 最后

我是一名来自中国的 iOS 程序员, 对技术有着浓厚的兴趣, 在学习的过程中, 发现了很多来自国外的优秀博客。为了更好的学习这些文章, 产生了将这些文章翻译成中文的想法。

