# Picking the right way of failing in Swift


Swift 的一大特色就是编译安全。这使得我们开发者能够更容易的编写出可预测性的代码, 并且能勾减少运行时错误的发生。但是, 在实际的情况中, 错误发生的原因是千奇百怪的。

我们今天来看一下如果正确的去处理各类错误, 以及我们有什么工具来做这件事情。上一篇文章研究了如何处理 `non-optional`。 在那篇文章中我使用 `guard` + `preconditionFailure()` 代替了强制解包。

之后很多人都在问 `preconditionFailure()` 和 `assert()` 有什么区别。 在这篇文章中。我们再仔细的看看这些语言特性。最重要的是在什么情况下使用哪一种？

### Let's start with a list

我先把我知道的所有异常处理方法列举出来。

* **返回 `nil` 或者是一个 error 枚举值**, 最简单的异常处理机制就是直接在发生错误的方法中返回 `nil` 或者是 `.error`(使用了一个枚举来做为返回值类型的时候)。这中做法在很多的场景中都是有效的, 但是如果任何情况下都这么干的话。可能会导致你代码中的 API 编的非常繁琐。也会带来一些逻辑的错误。
* **抛出错误信息**, 这要求在处理潜在的错误是使用`do`、`try`、`catch` 语句。另外如果使用 `try？`错误会被忽略掉。
* **使用断言 `assert()` 和 `assertionFailure()`**, 来确定这个表达式是不是成立。默认情况下, 在 Debug 环境下会导致异常的抛出。在 release 下一场会被忽略。所以无法保证这个断言在出发的时候, 程序会立马停止。所以这种模式也可以被理解运行时警告。
* **使用 `precondition()` 和 `preconditionFailure()`**来代替断言。跟断义最大的区别就是它们在任何情况下都会发生, 可以确保在发生异常的时候程序会立马停止。
* **调用 `fataError()`**, 这个函数在 Xcode 自动生成的 `init(coder:)` 中大概都看到过。只要这个方法被调用就会立马杀掉当前进程。
* **调用 `exit()`**, 使用这个代码直接结束进程。这在命令行还有脚本中是非常有效的方法。

### 是否可恢复

这个异常发生之后程序还能否从异常中恢复是选择异常处理方式的重要因素。

比如说。我们向服务器发强请求, 然后得到了错误的请求结果。这种情况无论我们是多么牛逼的程序员, 我们使用了多么强大的服务器基本上肯定都会发生。把这种异常看作是致命异常或者是不可恢复的异常可能就不对了。这种场景中, 我们希望的可能就是给用户展示一些错误信息就可以了。

既然这样, 在这种场景中, 选择什么样的方法来处理异常呢？如果你仔细看了上面的列表, 我们其实可以把这些按照是否可恢复归位两类:


**可恢复的**

* 返回 `nil` 或者一个 `error` 枚举值。
* 抛出错误信息。

**不可恢复的**

* assert()
* precondition()
* fatalError()
* exit()

既然我们处理的是一个异步的任务, 返回 `nil` 或者 `error` 枚举值就是最好的选择了。


```swift
class DataLoader {
    enum Result {
        case success(Data)
        case failure(Error?)
    }
    
    func loadData(from url: URL, completionHandler: @escaping (Result) -> Void) {
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard let data = data else {
                completionHandler(.failure(error))
                return
            }
            completionHandler(.success(data))
        }
        task.resume()
    }   
}
```

如果任务是同步的, 抛出错误应该是最好的方法了。毕竟 API 也是这样设计的。

```swift
class StringFormatter {
    enum Error: Swift.Error {
        case emptyString
    }
    func format(_ string:String) throws -> String {
        guard !string.isEmpty else {
            throw Error.emptyString
        }
        return string.replacingOccurrences(of: "\n", with: " ")
    }
}
```

在有些情况下, 错误是不可恢复的。比如说, 我们需要在程序启动的时候加载配置文件。如果这个配置文件丢失了, 这会把程序带入未定义的状态中。所以这种情况下 crash 可能就要比让程序就运行好得多了。这种情况下, 使用更强的并且不可恢复的方法来让程序崩溃会是更合适的。

在这个例子中, 使用 `preconditionFailure()` 来停止运行。

```swift
guard let config = FileLoader().loadFile(name: "Config.json") else {
    preconditionFailure("Failed to load config file")
}
```

### 程序错误和运行错误

另外一个重要的标准是:异常的发生原因是逻辑还是配置, 或者说这个错误是不是程序流程中合法的部分。基本上判断的标准就是这个错误的原因是因为程序员还是外部因素。

为了减少麻烦, 可能你更愿意使用不可恢复的方法来处理各类错误。这样你就不用写各种代码来处理各种特殊情况了, 并且如果测试做得好的话, 这些错误就能够早的被捕获到了。

比如。 我们在做一个界面, 需要一个 `viewModel` 在使用之前跟他做好绑定。这个 `viewModel` 在我们的代码中是一个 `optional` 类型, 但是我们又不希望每次使用的时候都要强制解包。我们也不希望在这个 `viewmodel` 莫名其妙消失的时候程序在生产环境中崩溃。使用断言在 `debug` 下获得错误信息就足够了。

```swift
class DetailView: UIView {
    struct ViewModel {
        var title: String
        var subtitle: String
        var action: String
    }
    var viewModel: ViewModel?
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let actionButton = UIButton()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let viewModel = viewModel else {
            assertionFailure("No view model assigned to DetailView.")
            return
        }
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        actionButton.setTitle(viewModel.action, for: .normal)
    }
}
```

需要注意的是: 我们必须在上面的 `guard` 表达式中 `return`, 不然在 `release` 条件下 `assertFailure()` 也没什么作用。


### 总结

我希望这篇文章有助于让你理解到各种异常处理方法的区别。我的建议是不要只是专注于技术, 而是要在不同的场景中尝试使用不同的方法。一般情况下, 我更建议大家尽量在程序出错的时候恢复过来, 除非异常是致命的, 都不要影响用户体验。

另外 `print(error)` 并不是一个异常处理机制。

Thanks for reading! 🚀


### That's it!
[原文地址](https://medium.com/@johnsundell/picking-the-right-way-of-failing-in-swift-e89125a6b5b5)

### 最后

我是一名来自中国的 iOS 程序员, 对技术有着浓厚的兴趣, 在学习的过程中, 发现了很多来自国外的优秀博客。为了更好的学习这些文章, 产生了将这些文章翻译成中文的想法。



