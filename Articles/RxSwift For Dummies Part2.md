## RxSwift For Dummies 🐣 Part2

我们在上一篇文章中介绍了 RxSwift 基础的部分. 现在我们来学习一些操作符, 来学习一下 **FRP** 中的**F**(unctional) 部分

### Schedulers

我们先学习一下之前就已经提到过的, 但是没有详细介绍的 **Schedulers**

**Schedulers** 最常见的用法就是告诉 `Observables` 和订阅者 应该在哪个线程或者队列中发送事件,或者通知。

关于 `Schedulers` 最常见的操作符是`observerOn` 和 `subscribleOn`

通常情况下 `Observables` 会在它被订阅的那个线程发送事件或者通知。

#### ObserveOn

**ObserveOn** 指定 `Observables` 发送事件的线程或者队列。它不会改变它执行的线程。

举一个跟 part1 很相似的例子：

```swift
let observable = Observable<String>.create { (observer) -> Disposable in
    DispatchQueue.global(qos: .default).async {
        Thread.sleep(forTimeInterval: 10)
        DispatchQueue.main.async {
            observer.onNext("Hello dummy 🐥")
            observer.onCompleted()
        }
    }
    return Disposables.create()
}
```

假设订阅者是一个 UI 层的东西， 比如说是一个 `UIViewController` 或者 `UIView`

```swift
DispatchQueue.global(qos: .default).async
```

我们把这个任务放在子线程中去执行， 以免阻塞 UI 

```
DispatchQueue.main.async{ ...
```

我们需要在主线程中去更新 UI, 你应该知道 `UIKit` 要求对 `UI` 的操作都必须在主线程中进行。所以这些操作对你来说一定是很熟悉的了。

记下来使用 **ObserveOn** 来重构一下这段代码

```swift
let observable = Observable<String>.create({ (observer) -> Disposable in
    DispatchQueue.global(qos: .default).async {
        Thread.sleep(forTimeInterval: 10)
        observer.onNext("Hello dummy 🐥")
        observer.onCompleted()
    }
        return Disposables.create()
    }).observeOn(MainScheduler.instance)
```

我们删掉了 `DispatchQueue.main.async {}` 然后添加了 `.observeOn(MainScheduler.instance)`。 这个就可以让所有的事件都在主线程中被发送出去。就是这么简单。 `"Hello dummy 🐥"` 这个元素就能够很安全的被发送给 UI 的元素， 因为我们可以很确定他会在主线程中被发送出去。

```swift
observable.subscribe(onNext: { [weak self] (element) in
    self?.label.text = element
}).addDisposableTo(disposeBag)
```
**ObserveOn** 大概是最常见的线程调度操作符了。你希望 `Observables` 包含了所有的逻辑, 和线程操作, 让订阅者尽可能的简单。所以我们接下来再了解一下 `subscribeOn` 这个操作符。


#### SubscribeOn (Optional)

这是一个非常先进的操作符。你可以先跳过这部分, 以后再来研究🐤

`subscribeOn` 跟 `ObserveOn` 非常的相似。**但是他只能改变 `Observable` 将要执行的任务所在的线程。**

```swift
let observable = Observable<String>.create { (observer) -> Disposable in
    Thread.sleep(forTimeInterval: 10)
    observer.onNext("Hello dummy 🐥")
    observer.onCompleted()
    return Disposables.create()
} 
observable
    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    .subscribe(onNext: { [weak self] (element) in
        self?.label.text = element
    }).addDisposableTo(disposeBag)
```

上面的代码中, 我删掉了 `Observable` 中的 `DispatchQueue.global(qos: .default).async {}`  是这个订阅者告诉他应该在一个 `global queue` 中执行下面的操作, 以免阻塞 UI. 很明显这回导致一个异常的抛出, 之前提到过： 这回导致 `Observable` 在全局队列中执行, **也会在全局队列中发出事件**。只需要添加在 `Observable` 中添加 `.observeOn(MainScheduler.instance)`就能避免这个问题。

```swift
let observable = Observable<String>.create { (observer) -> Disposable in
    Thread.sleep(forTimeInterval: 10)
    observer.onNext("Hello dummy 🐥")
    observer.onCompleted()
        return Disposables.create()
}.observeOn(MainScheduler.instance)      
observable
    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    .subscribe(onNext: { [weak self] (element) in
        self?.label.text = element
    }).addDisposableTo(disposeBag)
```
添加之后，就能够发现刚刚说到的问题已经解决掉了。

我们什么时候应该用 `observeOn` 呢？最常见的场景是:如果在 `Observable` 不需要在后台执行耗时操作(读取数据, 大的计算任务)的话.我不认为这是非常频繁的事情。但是，come on!  多知道一个你能用的工具 🛠不是件很 cool 的事情吗？

#### Scheduler Types

做为 RxSwift 菜鸟, 好奇 `observeOn` 和 `MainScheduler.instance` 没什么关系。你可以自己创建一个线程或者直接使用已经创建好了的。如果你很好奇的话[这里有很多](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Schedulers.md)。 这也没什么好复杂的， 就是对 GCD 和 NSOperation 的封装而已。


### Transforming Operators

现在你已经知道两种操作符了: 创建操作符(`create`、`interval`、`just`)  和 功能操作符(`observeOn`, `subscribeOn`)。 现在再学一些转换操作符吧！

#### Map

这是非常简单，但非常有用的操作符。它也可能是你未来最常用的一个操作符号。

```swift
let observerable = Observable<Int>.create { (observer) -> Disposable in
    observer.onNext(1)
    return Disposables.create()
}        
let boolObservable: Observable<Bool> = observerable.map{(element) -> Bool in
    if element == 0 {
        return false
    }
    return true
}
boolObservable.subscribe(onNext: { (boolElement) in
    print(boolElement)
}).addDisposableTo(disposeBag)
```

**Map** 操作符号，改变了序列中值的类型。他映射了一个 `Observable` 所以他以你告诉他的新的方式发送事件。在这个例子中, 我们将一个 `Int` 类型的 `Observable` 映射成了一个 `Bool` 类型。 

所以这个例子的结果是
> true

#### Scan

**scan** 要复杂一些了。

```swift
let observable = Observable<String>.create { (observer) -> Disposable in
    observer.onNext("D")
    observer.onNext("U")
    observer.onNext("M")
    observer.onNext("M")
    observer.onNext("Y")
    return Disposables.create()
}
observable.scan("") { (lastValue, currentValue) -> String in
    return lastValue + currentValue
}.subscribe(onNext: { (element) in
    print(element)
}).addDisposableTo(disposeBag)
```
在这个例子中会输出

>D
>DU
>DUM
>DUMM
>DUMMY

**scan**操作符, 让你可以通过上一个值来改变这一个值。他也被称作元素堆积。上面代码中的 `“”`是扫描参数传递的起始值。还是想着能干什么呢？

```swift
let observable = Observable<Int>.create { (observer) -> Disposable in
    observer.onNext(1)
    observer.onNext(2)
    observer.onNext(3)
    observer.onNext(4)
    observer.onNext(5)
    return Disposables.create()
}
observable.scan(1) { (lastValue, currentValue) -> Int in
    return lastValue + currentValue
}.subscribe(onNext: { (element) in
    print(element)
}).addDisposableTo(disposeBag)
```

这是通过 **scan** 操作符计算 5 的阶层。 算出来的答案是: 120

[Marin 给了一个更有用的例子](http://rx-marin.com/post/rxswift-state-with-scan/) 关于按钮的 selected 状态

```swift
let button = UIButton()
button.rx.tap.scan(false) { last, new in
    return !last
}.subscribe(onNext: { (element) in
    print("tap: \(element)")
}).addDisposableTo(disposeBag)
```

现在你知道他能干什么了吧？ 当然还有很多其他的转换操作符。

### Filtering Operators

发出事件是很重要的事情, 但是很多情况下我们还需要过滤掉一些没用的事件。这就是 filter 操作符所做的事什么。

#### Filter

决定那些事件是要响应的那些是要过滤掉的。

```swift
let observerable = Observable<String>.create { (observer) -> Disposable in
    observer.onNext("🎁")
    observer.onNext("💩")
    observer.onNext("💩")
    observer.onNext("💩")
    observer.onNext("🎁")
    return Disposables.create()
}
observerable.filter { (element) -> Bool in
    return element == "🎁"
}.subscribe(onNext: { (element) in
    print(element)
}).addDisposableTo(disposeBag)
```

输出

>🎁
>🎁

#### Debounce

简单且有用

```swift
observerable
    .debounce(2, scheduler: MainScheduler.instance)
    .subscribe(onNext: { (element) in
        print(element)
    }).addDisposableTo(disposeBag)
```

**debounce** 会过滤掉2秒以内的所有事件, 如果事件a在上一次事件之后的0.5秒被发送出来。那么他就会被过滤掉。如果他在上次事件的2.5秒被发送出来。那么他就会被接受到。需要注意的是, 如果就算当前时间之后没有其他的事件，他也要在2秒之后被发送出来。

> 译者: 需要注意的 `debounce` 和 `throttle` 的区别。还有 Obj-C 中的 `ReactiveCocoa` 中的 throttle 的区别。
    
    
### Combining Operator
    
联合操作符让你可以把多个 `Observable` 转换成一个。

#### Merge

合并只是将多个 `Observable` 发送的事件合并到一个 `Observable` 中。

```swift
let observable = Observable<String>.create { (observer) -> Disposable in
    observer.onNext("🎁")
    observer.onNext("🎁")
    return Disposables.create()
}
let observable2 = Observable<String>.create { (observer) -> Disposable in
    observer.onNext("💩")
    observer.onNext("💩")
    return Disposables.create()
}
Observable.of(observable, observable2).merge().subscribe(onNext: { (element) in
    print(element)
}).addDisposableTo(disposeBag)     
```

>🎁
>🎁
>💩
>💩

#### Zip

**Zip** 将每个 `Observable` 发出来的值合并成一个值。

```swift
let observable = Observable<String>.create { (observer) -> Disposable in
    observer.onNext("🎁")
    observer.onNext("🎁")
    return Disposables.create()
}
let observable2 = Observable<String>.create { (observer) -> Disposable in
    observer.onNext("💩")
    observer.onNext("💩")
    return Disposables.create()
}
Observable.zip(observable ,observable2).subscribe(onNext: { (element) in
    print(element)
}).addDisposableTo(disposeBag)
```
>🎁💩
>🎁💩

这是一个很有用的操作符。还是举一个例子吧！ 假如你有两个网络请求, 你需要等到他们都结束之后再进行下一步操作。

```swift
let observable = Observable<String>.create { (observer) -> Disposable in
    DispatchQueue.main.async {
        Thread.sleep(forTimeInterval: 3)
        observer.onNext("fetched from sever 1")
    }
    return Disposables.create()
}
let observable2 = Observable<String>.create { (observer) -> Disposable in
    DispatchQueue.main.async {
        Thread.sleep(forTimeInterval: 2)
        observer.onNext("fetched from sever 2")
    }
    return Disposables.create()
}
Observable.zip(observable, observable2)
    .subscribe(onNext: { (element) in
        print(element)
    }).addDisposableTo(disposeBag)
```

**Zip** 会等到两个 `Observable` 都结束之后将两个请求的结果合并成一个值发送出来。

### Other Operators

还有很多有趣的操作符, 比如 `reduce`、 `takeUntil` 等等。我认为如果你什么时候有了一些想法, 你也会很容易的找到他们。他们非常的强大, 能让你快速简单的操作事件序列。

### Mixing Operators

这个教程不需要具体的实例项目, 但是能快的将各种操作符搭配使用。我们来做一个实验吧：工具根据事件改变视图的颜色。

```swift
Observable<NSDate>.create { (observer) -> Disposable in
    DispatchQueue.global(qos: .default).async {
        while true {
            Thread.sleep(forTimeInterval: 0.01)
            observer.onNext(NSDate())
        }
    }
    return Disposables.create()
    }// 需要在主线程中刷新 UI
    .observeOn(MainScheduler.instance)
    // 我们只需要能够被2整除的事件
    .filter { (date) -> Bool in
        return Int(date.timeIntervalSince1970) % 2 == 0
    }
    // 将数据转换成颜色
    .map { (date) -> UIColor in
        let interval: Int = Int(date.timeIntervalSince1970)
        let color1 = CGFloat( Double(((interval * 1) % 255)) / 255.0)
        let color2 = CGFloat( Double(((interval * 2) % 255)) / 255.0)
        let color3 = CGFloat( Double(((interval * 3) % 255)) / 255.0)
        return UIColor(red: color1, green: color2, blue: color3, alpha: 1)
    }
    .subscribe(onNext: {[weak self] (color) in
        self?.demoView.backgroundColor = color
    }).addDisposableTo(disposeBag)
```
You can find more examples in the [RxSwfit playgrounds](https://github.com/ReactiveX/RxSwift/blob/master/Rx.playground/Pages/Combining_Operators.xcplaygroundpage/Contents.swift)

### That's it!

你知道了太多了。剩下的就是 `Subjects` 了

[原文地址](http://swiftpearls.com/RxSwift-for-dummies-2-Operators.html)

### 最后

我是一名来自中国的 iOS 程序员, 对技术有着浓厚的兴趣, 在学习的过程中, 发现了很多来自国外的优秀博客。为了更好的学习这些文章, 产生了将这些文章翻译成中文的想法。

