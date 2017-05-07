## RxSwift Safety Manual 📚


RxSwift 提供了大量非常好用的工具, 让写代码更爽, 但是他也可能给你带来一些头疼的地方, 也可能是bug😱。 用了三个月之后我觉得我应该也可以给出一些建议来避免一些问题。

### Side Effects

在计算机科学中副作用这个词可能没那么容易理解, 因为这是一个非常宽泛的内容。在 [Stackoverflow](http://softwareengineering.stackexchange.com/questions/40297/what-is-a-side-effect) 有一些比较好的讨论。

简单点说, 一个函数/闭包/...如果他们改变了 app 的状态, 都有可能带来一些副作用。在下面的例子中：

```swift
        let observable = Observable<Int>.create { (observer) -> Disposable in
            // 这样写没有副作用
            observer.onNext(1)
            return Disposables.create()
        }
        
        let observableWithSideEffect = Observable<Int>.create { (observer) -> Disposable in
            // 这里就会有副作用: 这个 closure 改变了 counter 的值
            counter = counter + 1
            observer.onNext(counter)
            return Disposables.create()
        }
```

为什么在 RxSwift 中这个很重要呢? 因为对于冷信号❄️来说。**每次被订阅他都会执行一下里面的任务**

我们两次订阅这个 `observableWithSideEffect`: 

```swift
        observableWithSideEffect
            .subscribe(onNext: { (counter) in
                print(counter)
            }).addDisposableTo(disposeBag)
        
        observableWithSideEffect
            .subscribe(onNext: { (counter) in
                print(counter)
            }).addDisposableTo(disposeBag)
```

我们可能希望他输出的是两个2.但是事实上它会输出2，3. 因为每次订阅都会分别执行, 所以在闭包里面的代码会被执行两次。**所以 counter + 1 会执行两次**

也就是说, 如果你在这里面房里两个网络请求。**它会发出两次请求**

我们怎么来解决这个问题呢？ 把这个冷信号转换成热信号💡。 使用 **publish** connect 还有 refCount 就可以了,这是[完整细节](http://www.tailec.com/blog/understanding-publish-connect-refcount-share)。

```swift
        var counter = 1
        let observableWithSideEffect = Observable<Int>.create { (observer) -> Disposable in
            counter = counter + 1
            observer.onNext(counter)
            return Disposables.create()
        }.publish()
        // publish returns an observable with a shared subscription(hot).
        // It's not active yet
        
        observableWithSideEffect
            .subscribe(onNext: { (counter) in
                print(counter)
            }).addDisposableTo(disposeBag)
        
        observableWithSideEffect
            .connect()
            .addDisposableTo(disposeBag)
```

这会输出 2，2


大多数情况下这就够了。但是还有一个更高级的 *shareReplay* 操作符。他使用了 `refCont` 操作符合 `replay`. `refCount` 也是一种 `connect` 但是它是自动管理的。他会在第一次订阅开始的时候开始。 replay 会把一些元素发送给那些 "迟到了" 的订阅者/

```swift
        var counter = 1
        let observableWithSideEffect = Observable<Int>.create { (observer) -> Disposable in
            counter = counter + 1
            observer.onNext(counter)
            return Disposables.create()
            }.shareReplay(1)
        
        observableWithSideEffect
            .subscribe(onNext: { (counter) in
                print(counter)
            }).addDisposableTo(disposeBag)

        observableWithSideEffect
            .subscribe(onNext: { (counter) in
                print(counter)
            }).addDisposableTo(disposeBag)
```

### Main Queue

当订阅行为是发生在 viewcontroller 上, 然后你不知道订阅行为是在那个线程中进行的。在刷新 UI 的时候确定这是在主线程中进行的。

```swift
        observableWithSideEffect
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (counter) in
                // update UI
            }).addDisposableTo(disposeBag)
```

### Error Events

如果你把好几个 `Observerable` 合并在了一起。如果其中有一个发生了错误。所有的 `Observerable` 都会结束。如果最开始是UI的话, 他就会停止响应。你应该好好的设计你的代码, 考虑好如果发生了 `complete` 或者 `error` 会发生什么。

```
viewModel.importantText
    .bindTo(myImportantLabel.rx.text)
    .addDisposableTo(disposeBag)
```

如果 viewModel.importantText 因为什么原因发送出来一个error事件。这个 `bingding` 订阅也会结束。

如果你想避免这种情况的发生你可以使用 **catchErrorJustReturn**

```swift
        viewModel.importantText
            .catchErrorJustReturn("default text")
            .bind(to: lable.rx.text)
            .addDisposableTo(disposeBag)
```



### Driver

**Driver** 是一个能够 `observeOn`、`catchErrorJustReturn`、`shareReplay` **Observable**.如果你想在viewModel中暴露一个安全的API。使用 **Driver** 是更好的做法。

```swift
        viewModel.importantText
            .asDriver(onErrorJustReturn: "default text")
            .drive(lable.rx.text)
            .addDisposableTo(disposeBag)
```

### Reference Cycles

防止内存泄漏需要在话很多心思在避免引用循环上，当我们使用在订阅闭包中使用外部变量的时候。这个变量会被捕获为一个强引用。

```swift
        viewModel.priceString
            .subscribe(onNext: {(text) in
                self.priceLabel.text = text
            }).addDisposableTo(disposeBag)
```

这个 vc 强引用了 viewModel。现在这个 viewmodel 又因为在这个闭包中强引用了这个 vc。这就带来了循环引用。 ["WEAK, STRONG, UNOWNED, OH MY!" - A GUIDE TO REFERENCES IN SWIFT](https://krakendev.io/blog/weak-and-unowned-references-in-swift)

下面是解决办法

```swift
        viewModel.priceString
            .subscribe(onNext: {[unowned self] (text) in
                self.priceLabel.text = text
            }).addDisposableTo(disposeBag)
```

使用 **[unowned self]** 语句之后就不用去考虑这个问题了🤗。

self 并不是唯一一个你需要担心的东西。你可能需要考虑所有你在在闭包中捕获的变量。

```swift
// out side the view controller
        viewModel.priceString
            .subscribe(onNext: {[weak viewController] (text) in
                viewController?.priceLabel.text = text
            }).addDisposableTo(disposeBag)
```

这可能会比较复杂。这也是我**强烈建议你尽量让你的闭包很短**的原因。如果一个闭包超过了3、4行代码的话。可以考虑把这部分逻辑放在一个新的方法里面去。这样的话，这些依赖关系就会变的很明确了。你才能够很好的去考虑强弱应用的问题。


### Managing your subscriptions

记住要把你不需要订阅的订阅清楚掉。我曾经遇到过一次, 由于我没有及时的清除掉我的订阅, 当 `cell` 被重用的时候, 就会创建一个新的订阅, 导致了非常壮观的 **bug**。

```swift
    var reuseBag = DisposeBag()
    // Called each time a cell is reused
    func configCell() {
        viewModel
            .subscribe(onNext: { [unowned self] (element) in
                self.sendOpenNewDetailsScreen()
            })
    }
    // Creating a new bag for each cell
    override func prepareForReuse() {
        reuseBag = DisposeBag()
    }

```

RxSwift 是非常复杂的东西。但是如果你设定好了自己的一套规则, 然后在编码的时候坚持这个规则。这也没什么好难受的😇。 在使用 RxSwift 做的时候在每一层中考虑清楚你需要把哪些 API 暴露出来。这也能帮助你很快的发现 bug。

[原文地址](http://swiftpearls.com/RxSwift-Safety-Manual.html)

### 最后

我是一名来自中国的 iOS 程序员, 对技术有着浓厚的兴趣, 在学习的过程中, 发现了很多来自国外的优秀博客。为了更好的学习这些文章, 产生了将这些文章翻译成中文的想法。

