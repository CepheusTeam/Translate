# Handing non-optional optionals in Swift


**optional**, 可以说是 Swift 中最为重要的特性, 也是它跟 `Objective-C` 不同的关键特征。在编码的时候强制处理那些可能为空的值, 可以让程序更具有可预测性, 减少错误发生的机会。

然而在开发中我们经常会遇到一些变量, 明明是 `optional` 的, 但在逻辑又一定是非空的。比如说 `controller` 中的 `view`

```swift
struct ViewModel{}
class TableViewController: UIViewController {
    var tableView: UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView.init(frame: view.bounds)
        view.addSubview(tableView!)
    }
    func viewModelDidUpdate(_ viewModel: ViewModel) {
        tableView?.reloadData()
    }
}
```

如何处理这种情况在 `Swift` 程序员之间的争议, 就使用 `tab` 还是 `space `来缩进一样。

> 既然是可选类型, 我们就应该正确的使用它。 使用` if let` 或者 `guard`

也有人持有相反的态度: 

> 既然都知道这个变量非空, 那就强制解包。就算崩溃也不能让程序进入不可控的状态。

上面的讨论基本上都是围绕着**是否有必要进行防御性编程**展开的。应该让程序从未定义的状态中恢复, 还是应该让程序直接崩溃。

如果非要回答这个问题, 我可能会选择后者。未定义的状态会导致很难追踪的 bug, 可能会执行不必要的代码。而且防御性的代码往往也很难维护。

但是我觉得, 研究一些避免出现这种情况的技巧更实在一些。


### Is it really optional?

变量和属性是不是可选取决于你代码的逻辑。如果在设计程序的时候, 根本就没有想过这个变量会是 `nil`。或者说在设计之初, 这个变量就不会出现为空的情况。这个变量就不应该是 `optional` 

即使在和一些系统 API 交互的时候, 可选类型基本上都是无法避免的。但是也有一些办法让我们尽可能的避免使用 `optional` 类型。

### Being lazy is better than being non-optionally optional

对于一个对象来说, 如果它的属性会在这个对象初始化之后赋值。比如说 `UIController` 上面的 `View` 应该在 `viewDidLoad()` 中初始化。就可以使用 `lazy` 属性。一个懒加载属性是不可空的, 即使他在这个对象的初始化方法中没有被赋值。因为在第一次访问的时候, 它就会被初始化出来。

我们来更新一下刚才的代码。

```swift
struct ViewModel{}
class TableViewController: UIViewController {
    lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView.init(frame: view.bounds)
        view.addSubview(tableView)
    }
    func viewModelDidUpdate(_ viewModel: ViewModel) {
        tableView.reloadData()
    }
}
```

没有可空类型了。🎉

### Proper dependency management is better than non-optional optionals


为了打破循环依赖我们也经常会使用可选类型。比如：在A、B两个类互相依赖的时候: 

```swift
class Comment {
    init(text: String) {}
}

class UserManager {
    private weak var commentManager: CommentManager?
    
    func userDidpostComment(_ comment: Comment) {
        
    }
    
    func logOutCurrentUser() {
        commentManager?.clearCache()
    }
}


class CommentManager {
    private weak var userManager: UserManager?
    
    func composer(_ composer: Comment) {
        userManager?.userDidpostComment(composer)
    }
    
    func clearCache() {
        
    }
}

```

看上面的代码我们可以发现一个很明显的循环引用 `UserManager` - `CommentManager` 任何一个都没有持有另外一个, 但是它们也依赖另外一个来完成自己的业务逻辑。😅


解决这样的问题, 我们可以让 `CommentComposer` 来做为中间人。 他来通知 `UserManger` 还有 `CommentManager` 一条评论消息产生了。

```swift
class CommentComposer {
    private let commentManager: CommentManager
    private let userManager: UserManager
    private lazy var textView = UITextView()
    
    init(commentManager: CommentManager,
         userManager: UserManager) {
        self.commentManager = commentManager
        self.userManager = userManager
    }
    
    func postComment()  {
        let comment = Comment(text: textView.text)
        commentManager.composer(comment)
        userManager.userDidpostComment(comment)
    }
}
```

这样的话 `UserManager` 就可以强引用 `CommentManager` 了。

```swift
class UserManager {
    private let commentManager: CommentManager
    
    init(commentManager: CommentManager) {
        self.commentManager = commentManager
    }
    
    func userDidpostComment(_ comment: Comment) {
        
    }
    
    func logOutCurrentUser() {
        commentManager.clearCache()
    }
}
```

`optional` 也消失了🎉

### Crashing gracefully

上面的例子中，我们看到了两个通过调整我们的代码, 来控制代码中的不确定性。但是在有些情况下这么做是不可能的。我们来假设一下, 你正在加载一个包含了你程序的配置信息的 JSON 文件。这就天然的存在一些可能会出错的情况。此时需要做的就是尽可能的错误处理。

拿到了错误的配置文件, 如果继续往下执行的话, 程序进入我们没有定义的状态中。这种情况下, 最好的办法是让程序崩溃, 然后 QA 中, 通过日志, 将这个问题解决掉。

那么我们应该怎么来让程序崩溃呢。最简单的办法就是使用 `!` 操作符。当这个变量为空的时候强制解包, 就会导致程序崩溃。

```swift
let configuration = loadConfiguration()!
```

虽然这种方法很简单, 但是它也有很大的缺点。如果这个代码 crash。 我们得到的日志是这样的：

```
fatal error: unexpectedly found nil while unwrapping an Optional value
```

没有错误原因, 也没有错误发生的地点。这样的错误信息基本上没有什么能够让我们迅速的解决这个 bug 的信息。

更好的方法是在 `guard` 表达式中使用 `preconditionFailure()` 函数让程序发生崩溃, 抛出自定义的错误信息。

```swift
guard let configuration = loadConfiguration() else {
    preconditionFailure("Configuration couldn't be loaded + verifu that Config.JSON is valid")
}
```

这样的话, 在程序崩溃的时候我们就能得到有用的信息了。

```swift
fatal error: Configuration couldn’t be loaded. Verify that Config.JSON is valid.: file /Users/John/AmazingApp/Sources/AppDelegate.swift, line 17
```

### Summary

处理不可空的可选类型有一下几个方法:

1. 用懒加载属性, 替代不可空的可选类型。
2. 适当的依赖管理, 替代不可空的可选类型。
3. 在遇到这种情况的时候, 让程序崩溃, 并抛出异常。


