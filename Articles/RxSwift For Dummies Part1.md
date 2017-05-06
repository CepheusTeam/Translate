## RxSwift For Dummies 🐣 Part1

**RxSwift** 真的是一个非常值得学习的东西。非常遗憾的是我没有研究所有的架构模式MVVM VIPER Routing。

要非常好的讲出来RxSwift到底是个什么东西，我也说不好。毕竟他能做太多的事情了。普遍认为，他是函数响应式编程中非常重要的观察者模式。在最初的定义中,他并不就是函数响应式编程。他最初的设计灵感就是来自于函数响应式(**FRP**), 所以也可以说它包含了函数响应式的特性。

如果你不知道什么是 **FRP** 的话, 不用担心, 在这个教程中你会自然而然的理解什么是 **FRP**。

通过对 RXSwift 的深入研究, 我得到了很多的启发, 同时也被很多的问题困扰。相信你也会这样。

需要花很多个小时的时间来适应新的思维模式，唯一能确定的是，一旦你适应了，你就再也不想回到从前了。

在这个教程中，我会尽可能的节约你的时间，并且解释的尽可能的详细。想教幼儿园的小朋友一样。

开始学习之前, 请确定你已经掌握了 Swift 和 UIkit 的基础知识. 


### The Why?

写 UI 的时候经常会处理一些异步的操作。我们很早就知道要使用观察者模式来实现这个东西。我相信你现在已经非常熟悉代理模式了。代理模式是一种很酷的设计模式。但是写起来真的很烦😡。

<center>
![](http://swiftpearls.com/images/cry.jpg)
</center>

* 代理模式需要些很多的模版代码: 创建一个协议, 声明一个 `delegate` 变量, 遵守协议, 设置代理...
* 写完这么多模版代码,可能你不小心就忘了其中的某个步骤。 比如说 `object.delegete = self`
* 管理起来非常麻烦。他需要在好几个文件中跳跃。

RxSwift 解决了这个问题。他能够让你通过声明的方式使用观察者模式。减少了管理的负担, 当然，也不用写那么多模版代码。

我刚刚开始了一个项目，在这个项目中，至今还没有写一个 `delegate`

### Basic Example

talk is cheap, show you the code.

```swift
class ExampleClass {
    let disposeBag = DisposeBag()
    
    func runExample() {
        // OBSERVABLE //
        let observable = Observable<String>.create { (observer) -> Disposable
            DispatchQueue.global(qos: .default).async {
                Thread.sleep(forTimeInterval: 10)
                observer.onNext("Hello dummy 🐣")
                observer.onCompleted()
            }
            return Disposables.create()
        }
        // OBSERVER //
        
        observable.subscribe(onNext:{ (element) in
            print(element)
        }).addDisposableTo(disposeBag)
    }
}
```

这就是最基本的例子, 在这个示例中, 我们声明了一个 runExample 方法。在这个方法中执行的是一些 RxSwift 中的事情。想一下在这个例子中发生了什么吧。


### Observable 📡

我们还是从 RxSwift 中最基本的构建单元开始吧。 `Observable`。 它其实非常的简单。 `Observable` 执行某些动作, 然后观察者能够对此作出一些反应。

```swift
 let observable = Observable<String>.create { (observer) -> Disposable
    DispatchQueue.global(qos: .default).async {
        // Simulate some work
        Thread.sleep(forTimeInterval: 10)
        observer.onNext("Hello dummy 🐣")
        observer.onCompleted()
    }
    return Disposables.create()
}
                
observable.subscribe(onNext:{ (element) in
    print(element)
}).addDisposableTo(disposeBag)
```

现在我们有了一个 `Observable` 信号了。这种信号只有在被订阅之后才会执行它也被叫做:冷信号❄️。相反热信号🔥是那种既是没有被订阅也会执行的信号。

在下一步们我们会具体的讲解二者的区别。现在你只需要理解的是: 因为你初始化出来的是一个冷❄️信号`Hello dummy 🐣`这个值是不会被发送出来的。冷信号❄️只有在有东西订阅之后才会发送消息。

我们一步一步的来分析一下这究竟是什么意思。

```swift
DispatchQueue.global(qos: .default).async {...}
```

这行代码保证这个 `Observable` 信号在主线程中发送消息。其实 RxSwift 是有一个调度机制, 但是我现在还不想那么早告诉你, 不然你该记不值了。

```swift
observer.onNext("Hello dummy 🐣")
```

一个 `Observable` 信号发出的消息从时间上来看, 可以被看作是一个 **序列**。在这个序列中可能有无限多的值。我们可以通过 `onNext` 方法类将这些值发送出来。

```swift
observer.onCompleted()
```

当这个序列已经发送完了所有的值之后，它可以发送一个 `Completed` 或者 `Error`出来。之后这个信号就不能在产生更多的值了, 然后就会随着一个闭包被释放掉。

```swift
return Disposables.create()
```
每一个  `Observable` 信号都要返回一个 `Disposable`.

使用 `Disposables.create()` 如果你不想在信号被释放的时候处理其他事情。你可以看看[NopDisposable](https://github.com/ReactiveX/RxSwift/blob/master/RxSwift/Disposables/NopDisposable.swift)的实现，你会发现，他什么事情都没有做，只是一些空方法。

### Disposable

`Disposable` 对象必须要在 `Observable` 中返回, 它是用来在`Observable`不能再正常的完成的时候清除掉这些信号的。比如说你可以使用 **AnonymousDisposable**:

```swift
return Disposables.create(with: {
    connection.close()
    database.closeImportantSomething()
    cache.clear()
})
```

只有当信号被提前释放或者程序手动调用了 `dispose()` 方法, `Disposable` 才会被调用。但是在多数情况下, `dispose()` 方法都是通过 **Dispose Bags** 自动调用的。别着急，你可以在一些更具体的例子中自己实现这个东西。

### Observer 🕵

我们创建的 `Observable` 是冷信号❄️。 除非我们订阅了它，不然它是不会发送信号的。

```swift
let disposeBag = DisposeBag()

...

observable.subscribe(onNext: {(element) in
  print(element)
}).addDisposableTo(disposeBag)
```

这就是订阅信号的方法。在 `subscribeNext` 方法中一个订阅就发生了。这个方法也会返回一个 `Disposable`.这个 `Disposable` 就是对这个订阅的记录

这个 `Observable` 就开始工作了, 10秒之后, 你就会在控制台看见

> Hello dummy 🐣

`subscribe(onNext:)` 只会在Next事件发送出来的时候响应。也可以使用 `subscribe(onCompleted:)` 和 `subscribe(onError:)` 响应对应的事件。

### Dispose Bag 🗑

唯一一个还有点神秘的东西就是 `addDisposableTo` 这个方法了。

> Dispose bags are used to return ARC like behavior to RX. When a DisposeBag is deallocated, it will call dispose on each of the added disposables.
>
> Dispose bags 就像是一个垃圾筐。就像是 AutoreleasePool 一样，当这个垃圾筐被释放的时候, 里面的所有东西都会被释放掉。

当你订阅一个信号的时候, 你就需要把你创建出来的 `Disposable` 添加到这个框里面。当这的框被释放的时候(ExampleClass 对象 dealloc 的时候)。这些没有执行完的`Disposable`就会被释放掉。

它被用作释放在闭包中引用的值, 以及没用的资源, 比如说, 一个 HTTP 网络连接, 数据库连接, 或者是缓存的对象。

如果你还是不懂, 一会儿再举一个例子。

### Observable operators

`create` 只是信号诸多操作方法中的一个而已，它被用来创建一个新的信号。可以看一下 ReactiveX
的[官方文档](http://reactivex.io/documentation/operators.html)。哪里有所有的操作方法。我只是举一些常见的例子。

#### Just

```swift
let observable = Observable<String>.just("Hello again dummy 🐥");
observable.subscribe(onNext: { (element) in
    print(element)
}).addDisposableTo(disposeBag)
        
observable.subscribe(onCompleted: { 
    print("I'm done")
}).addDisposableTo(disposeBag)
```
> Hello again dummy 🐥
> I'm done

**Just** just 创建了一个智能释放一个值的信号。所以在这个信号序列中的事件，是这样的:

```
.Next("Hello") ->  .Completed
```

#### Interval

```swift
let observable = Observable<Int>.interval(0.3, scheduler: MainScheduler.instance)
observable.subscribe(onNext: { (element) in
   print(element)
}).addDisposableTo(disposeBag)
```

>0
>1
>2
>3
>...

**Interval** 是一个非常具体的操作符号。在这个例子中, 它从 0 每0.3秒递增, `scheduler` 是用来定义异步行为的。

#### Repeat

```swift
let observable = Observable<String>.repeatElement("This is fun 🙄")
observable.subscribe(onNext: { (element) in
   print(element)
}).addDisposableTo(disposeBag)
```
> This is fun 🙄
> This is fun 🙄
> This is fun 🙄
> This is fun 🙄
> ...

**repeat** 会无限的重复我们给定的值。你可以通过定义 `scheduler` 类型的方法来控制线程的行为。

目前为止, 可能都不是非常的给力。但是知道其他的操作是必要的。另外一件很重要的事情涘，这是 RxSwift 最有用的一部分。

### Real life example

现在我们开始快速的通过一个例子巩固一下这些知识。我们对 RxSwift 的了解目前为止是非常有限的。所有我们先使用一个简单的 MVC 的例子。我们先创建一个模型， 它可以从 google 上获取数据。

```swift
import Foundation
import RxCocoa
import RxSwift

final class GoogleModel {
    
    func createGoogleDataObservable() -> Observable<String> {
        return Observable<String>.create({ (observer) -> Disposable in
            
            let session = URLSession.shared
            let task = session.dataTask(with: URL(string: "https://www.google.com")!) { (data, response, error) in
                
                // 我们需要在主线程中更新
                DispatchQueue.main.async {
                    if let err = error {
                        // 如果请求失败, 直接发处失败的事件
                        observer.onError(err)
                    } else {
                        // 解析数据
                        if let googleString = String(data: data!, encoding: .ascii) {
                            // 将数据发送出去
                            observer.onNext(googleString)
                        } else {
                            // 如果解析失败发送失败的事件
                            observer.onNext("Error! Unable to parse the response data from google!")
                        }
                        // 结束这个序列
                        observer.onCompleted()
                    }
                }
            }
            task.resume()
            
            // 返回一个 AnonymousDisposable
            return Disposables.create(with: {
                // 取消请求
                task.cancel()
            })
        })
    }
}
```

这是非常简单的。 `createGoogleDataObservable `中我们创建了一个可以被订阅的信号。这个信号创建了一个从 google 获取数据的任务。

```swift
DispatchQueue.main.async {...}
```

URLSession 的任务是在后台线程中进行的, 所以我们需要在 UI 线程中更新。记住还有一个 `schedulers` 这会在更高级的阶段介绍出来。

```swift
return Disposables.create(with: {
 task.cancel()
})
```

`Disposable` 是一个给长给力的机制： 如果订阅者停止订阅这个信号了。这个任务就会被取消。

接下来是订阅者这部分的内容了。

```swift
import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {


    // 通常就是这样创建 DisposeBag 的
    // 当这个 controller 被释放掉的时候，disposebag
    // 也会释放掉, 并且所有 bag 中的元素都会调用 dispose() 方法
    let disposeBag = DisposeBag()
    let model = GoogleModel()
    
    @IBOutlet weak var googleText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 记住使用 [weak self] 或者 [unowned self] 来避免循环引用
        model.createGoogleDataObservable()
            .subscribe(onNext: { [weak self] (element) in
                self?.googleText.text = element
            }).addDisposableTo(disposeBag)
    }
}
```

神奇吗？没有协议, 没有代理。只是声明了一下在一个事情发生的时候应该做什么。

在闭包中记得使用 `[weak self]` 或者 `[unowned self]` 来避免循环引用

还有一种更响应式的方法来为 `UITextView` 绑定文本, 绑定。但那是更高级的内容。

### Dispose Bag Example

你可能已经发现了 `disposeBag` 是 `ViewController` 的一个成员变量。

```swift
class ViewController: UIViewController {

let disposeBag = DisposeBag()
```

当这个控制器被释放的时候，它也会释放掉这个 `disposeBag` .

如果这个 `disposeBag` 被释放掉之后, 它我们添加到这个 bag 里面所有的信号都会被释放掉。而这个网络请求任务如果还没有结束的话也会被取消。
希望我讲清楚了 `DisposeBag` 的机制。


### That‘s it！

Demo 我已经放在 GitHub 上了。

到现在, 我们已经学到了如何创建一个 Observable 和 订阅者。以及 disposing 机制是怎么回事。希望你能够理解到这样做比平常的观察者模式有什么优势。

下一篇是关于 RxSwift 操作符的。

[原文地址](http://swiftpearls.com/RxSwift-for-dummies-1-Observables.html#basic-example)

### 最后

我是一名来自中国的 iOS 程序员, 对技术有着浓厚的兴趣, 在学习的过程中, 发现了很多来自国外的优秀博客。为了更好的学习这些文章, 产生了将这些文章翻译成中文的想法。



