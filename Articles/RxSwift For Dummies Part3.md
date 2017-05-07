## RxSwift For Dummies 🐣 Part3


好了, 接下来是第三个部分。**Subjects**

学了之前内容. 我们可能已经发现了。之前学习的内容都是 `Observables` 输出事件的部分。我们可以订阅他, 就能知道他输出的事件了。但是我们还不能改变他。

**Subject** 也是一个 `Observable` 但是他是能够同时输入和输出的。也就是说, 我们可以动态(强制)的在一个序列中发出信号。

```swift
        let subject = PublishSubject<String>()
        // 可以直接转换，因为他也是一个 `Observable`
        let observable: Observable<String> = subject
        observable.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        // 只要你想发出一个新的事件, 就可以用 onNext 方法 
        subject.onNext("Hey!")
        subject.onNext("I'm back!")
```

**onNext** 是一个输出事件的方法。最后控制台会输出

>"Hey!"
>"I'm back!"

`Subject` 到底有什么用呢? 为了很轻松的将 Rxswift 中声明式的世界和我们平常的世界连接起来。让我们在需要写实现式的代码的时候更 Rx 

在一个纯正的 Rx 的世界里。当你需要有一个更完美的流的时候, 不用去管这个 `Observable` 是怎么实现的。这个东西我会另外的解释。反正, 如果你需要， 大胆的用吧。

上面式关于 Subject 最基本的内容。接下来我们学习一下怎么更好的使用 **Subject**

### Hot🔥 vs Cold❄️

在第一篇文章中就已经提到过了热信号🔥和冷信号❄️。今天我们在深入的了解一点吧，因为 **Subject** 实际上是我们第一次接触到真正的热信号。

我们一定确定了，当我们使用 **create** 创建一个 **Observable** 的时候, 由于没有人订阅他，所以她是不会发送消息的。只有被 **subscribe**(订阅)之后才会开始发送消息出来。这就是我们叫它为冷信号❄️的原因。如果很不幸你忘了这个知识点。你可以回到第一篇文章去看看。热信号🔥 就是那种即使没有被订阅也会发出消息的信号, 这也是 `subject` 做的事情。

```swift
        let subject = PublishSubject<String>()
        let observable: Observable<String> = subject
        // 这个信号还没有被订阅, 所以这个值不回被接受到
        subject.onNext("Am I too early for the party?")
        
        observable
            .subscribe(onNext: { (text) in
                print(text)
            }).addDisposableTo(disposeBag)
        // 这个值发出来的时候已经有一个订阅者了, 所以这个值会打印出来
        subject.onNext("🎉🎉🎉")
```

很简单直接吧。如果在第一篇中你理解了冷信号的话, 理解热信号也是很自然的事情。


### Subject Types

常用的 `Subject` 有三种。 他们其实都差不多, 唯一的区别就是: 在订阅之前, 它会干什么。

#### Publish Subject

在上面的例子中已经说到了。 **PublishSubject** 会忽略掉在订阅之前发出来的信号。

```swift
        let subject = PublishSubject<String>()
        let observable: Observable<String> = subject
        subject.onNext("Ignored...")
        observable.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        subject.onNext("Printed!")
```

当你只关注你订阅之后发生了什么的时候, 就可以使用 `PublishSubject`


#### Replay Subjects

**ReplaySubject** 会将最后 n 个值发出来, 即使是订阅发生之前的值。 这个 n 个值被被放在一个环从区里面。在这个例子中会缓有 3 个值被保留。

```swift
        let subject = ReplaySubject<String>.create(bufferSize: 3)
        let observable: Observable<String> = subject

        subject.onNext("Not printed!")
        subject.onNext("Printed")
        subject.onNext("Printed!")
        subject.onNext("Printed!")
        
        observable.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        subject .onNext("Printed!")
```
当我们需要知道订阅之前发生了什么的时候, 我们就需要使用 `ReplaySubject` 了。

#### Behavior Subject

**BehaviorSubject** 只会重复最后一个值。 更其他的 Subject 的同， 他在创建的时候就需要给定一个初始值。

```swift
        let subject = BehaviorSubject<String>(value: "Initial value")
        let observable: Observable<String> = subject
        
        subject.onNext("Not printed!")
        subject.onNext("Not printed!")
        subject.onNext("Printed!")
        
        observable.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        subject.onNext("Printed!")
```

当你只需要知道最后一个值的时候。就需要使用 `BehaviorSubject`


### Binding

你可以把一个 `Observable` 和 `Subject` 绑定到一起。也就是说可以让这个 `Observable` 将它的序列里的所有值都发送给这个 `Subject`

```swift
        let subject = PublishSubject<String>()
        let observable = Observable<String>.just("I'm being passed around 😲")
        subject.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        
        observable.subscribe { (event) in
            subject.on(event)
        }.addDisposableTo(disposeBag)
```

有一个语法糖来简化这些代码。


```swift
        let subject = PublishSubject<String>()
        let observable = Observable<String>.just("I'm being passed around 😲")
        subject.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        
        observable.bind(to: subject).addDisposableTo(disposeBag)
```

输出

> I'm being passed around 😲


**Warning**

Binding 不仅仅会传递值, 他也会把完成和错误都传递过来。这种情况下这个 `Subject` 就会被释放。


### Quick Example

还是把第一篇文章中的 Demo 稍微修改一下吧。

```swift
import Foundation
import RxCocoa
import RxSwift

final class GoogleModel {
    let googleString = BehaviorSubject<String>(value: "")
    private let disposeBag = DisposeBag()
    
    
    func fetchNetString()  {
        let observable = Observable<String>.create { (observer) -> Disposable in
            let session = URLSession.shared
            let task = session.dataTask(with: URL(string: "https://www.google.com")!, completionHandler: { (data, response, error) in
                
                DispatchQueue.main.async {
                    if let err = error {
                        observer.onError(err)
                    } else {
                        let googleString = NSString(data: data!, encoding: 1) as String?
                        
                        observer.onNext(googleString!)
                        observer.onCompleted()
                    }
                }
            })
            task.resume()
            return Disposables.create{
                task.cancel()
            }
        }
        
        // Bind the observable to the subject
        observable.bind(to: googleString).addDisposableTo(disposeBag)
    }
}        
// Bind the observable to the subject
observable.bind(to: googleString).addDisposableTo(disposeBag)
```

可以看到，在这个例子中，我们有一个视图模型将 `googleString` 这个 `subject` 暴露出来。让 `ViewController` 能够订阅。我们将这个 `observable` 绑定到这个 `subject` 上, 这样我们就可以在网络请求有结果的时候, 立马将请求结果传递到这给 `subject`。

### Bonus: Variable

距离完完全全的 Rx 还差最后一点了。强行的获取之前发送出来的值。

这就是为什么会有 **Variable** 这个东西了。Variable 是对 BehaviorSubject 的简单包装。[可以看一下](https://github.com/ReactiveX/RxSwift/blob/master/RxSwift/Subjects/Variable.swift) 它的实现是非常简单的。但它却非常的方便。

还是用一个小例子来说明这个问题吧。在这个例子中, 我们需要在任何时间都可以得到 "googleString" "当前" 的值。

```swift
        let googleString = Variable("currentString")
        // get
        print(googleString.value)
        // set
        googleString.value = "newString"
        // 订阅
        googleString.asObservable().subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
```

你一定会爱上他的。这基本上就是 **RxSwift** 的简单模式了。

看起来很简单吧，但是别忘了，还是有很多的坑的。还是小心为上。下一篇文章我会讲讲: 怎么写 Rxswift 最保险。


### That's it!

你知道了太多了。剩下的就是 `Subjects` 了

[原文地址](http://swiftpearls.com/RxSwift-for-dummies-3-Subjects.html)

### 最后

我是一名来自中国的 iOS 程序员, 对技术有着浓厚的兴趣, 在学习的过程中, 发现了很多来自国外的优秀博客。为了更好的学习这些文章, 产生了将这些文章翻译成中文的想法。

