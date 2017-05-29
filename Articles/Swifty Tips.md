# Swifty Tips ⚡️

Swift 开发中的一些小的技巧

刚开始的时候, 特别好奇大厂是怎么搞的, 他们的项目长什么样子, 他们用哪些库...想在巨人的肩膀上开发, 免得浪费时间在那些已经有很好解决方案的事情上。

四年前，我和团队中很多很厉害的人讨论过一些编程实践。今天就分享一些东西吧。

欢迎指正！🚀


## 滥用引用类型

只有“动态”对象才使用引用类型。这里的“动态”对象是什么呢？看下面的代码:

```swift
struct Car {
    let model: String
}
class CarManager {
    private(set) var cars: [Car]
    func fetchCars() {}
    func registerCar(_ car: Car) {}
}
```

🚗 在这里只是一个值。他代表的就是一些数据。就像 `1`、`2`、`3`。 这种数据是“静态”的数据(死的)。 它不会处理任何东西, 所以它也没有必要是“动态”的, 也就是说, 没必要把它定义成引用类型。

**另一方面:**

`CarManager` 就需要是一个“动态”的对象。因为这个对象会发起网络请求, 然后将请求结果保存起来。在值类型对象中是不能执行异步任务的, 因为他们是“静态”的数据。我们需要的 `CarManager` 对象在一定的范围内是应该是动态的, 他会请求数据, 也会注册新的 `Car`。

这个主题完全可以写一篇文章来深入。推荐看看 [Andy Matuschak 的文章](https://news.realm.io/news/andy-matuschak-controlling-complexity/), 和 [WWDC](https://developer.apple.com/videos/play/wwdc2015/414/)


## 隐式解包可选类型(`!`)

默认不要隐式解包可选类型。 在大多数场景中你都可能会忘掉这件事情。但是在一些特殊情况下应该这样做来减少编译器的压力。而且我们也需要去理解这件事情背后的逻辑。

基本上, 如果这个属性在初始化的过程中必须为 `nil` 但是之后就会被赋值,  就可以定义这个属性为 optional。因为你肯定不会在赋值之前访问这个属性, 如果编译器一直警告这个值可能为 `nil` 真的挺讨厌的。

看看xib中拖出来的属性:

```swift
class SomeView: UIView {
    @IBOutlet let nameLabel: UILabel
}
```

如果这样定义的话, 编译器就会让你在初始化方法中给`nameLabel`赋值。因为这行代码告诉编译器这个 `View` 无论什么时候都有 `nameLabel`。 但是, 有病啊！肯定不能这么干啊。因为其实在 `initWithCoder` 中已经帮我们实现了 `xib` 中的 `label` 和这个属性之间的关联。明白了吗？ 这个值永远都不可能为空, 就没有必要判断这个东西是不是存在了。所以也不需要去赋值了啊。


> 你:这玩意儿肯定不可能是空, 别瞎几把报错了
> 编译器: 好的!

```swift
class SomeView: UIView {
    @IBOutlet var nameLabel: UILabel!
}
```

**Q:** 在dequeue一个tableviewCell 的时候能不能(`!`)?
**A:** 还是不要吧！至少给一个 Crash 啊

```swift
guard let cell = tableView.dequeueCell(...) else {
    fatalError("Cannot dequeue cell with identifier \(cellID)")
}
```

## 滥用 AppDelegate

`AppDelegate` 不是拿来给你做保存全局变量的容器的(全局属性、工具方法、管理类等等。)他只是一个用来实现一些协议的类而已。放过它吧！

在 `applicationDidFinishLaunching` 方法里肯定都会做一些很重要的事情, 但是当项目不断变大的时候这种情况很容易变的很恐怖。创建新的类(文件)来做这些事情吧！

**👎 Don’t:**

```swift
let persistentStoreCoordinator: NSPersistentStoreCoordinator
func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor { ... }
func appDidFinishLaunching... {
    Firebase.setup("3KDSF-234JDF-234D")
    Firebase.logLevel = .verbose
    AnotherSDK.start()
    AnotherSDK.enableSomething()
    AnotherSDK.disableSomething()
    AnotherSDK.anotherConfiguration()
    persistentStoreCoordinator = ...
    return true
}
```

**👍 Do:**

```swift
func appDidFinishLaunching... {
    DependencyManager.configure()
    CoreDataStack.setup()
    return true
}
```

## 默认参数

给一个方法的某些参数设置默认值是非常方便的事情。如果没有这个特性的话, 可能就需要给同一个功能写好几个方法了。像下面一样:

```swift
func print(_ string: String, options: String?) { ... }
func print(_ string: String) {
  print(string, options: nil)
}
```

如果有默认参数值, 就可以是这样的:

```swift
func print(_ string: String, options: String? = nil) {...}
```

很简单对吧！ 给自定义 UI 组件设置默认颜色、提供默认的参数、给网络请求添加默认的超时时间等等。但是, 使用这个语法糖在遇到依赖注入的时候就要小心了。

看下面的例子:

```swift
class TicketsViewModel {
    let service: TicketService
    let database: TicketDatabase
    init(service: TicketService,
       database: TicketDatabase) { ... }
}
```

在 App target:

```swift
let model = TicketsViewModel(
  service: LiveTicketService()
  database: LiveTicketDatabase()
)
```

在 Test target:

```swift
let model = TicketsViewModel(
    service: MockTicketService()
    database: MockTicketDatabase()
)
```

在这里使用协议的原因就是把这些功能从具体的类中抽象出来。这就使得你可以向这个 `viewModel` 中注入任何你想要的具体实现。 如果这里你把 `LiveTicketService` 作为默认的参数, 这就使得`TicketsViewModel` 依赖了 `LiveTicketService`这么一个具体的类型。这跟最初想要达到的目的有了一些冲突。

**现在没那么方便了吧？**

想象一下在你 App 还有 Test 两个 target 中。 `TicketsViewModel` 会被同时添加到两个 target 中, 然后把 `LiveTicketService` 和 `MockTicketService` 分别添加。如果 `TicketsViewModel `添加了对 `LiveTicketService` 的依赖。 Test target 肯定就编译不过了。


## 可变参数函数

这... 就是很爽啊！

```swift
func sum(_ numbers: Int...) -> Int {
    return numbers.reduce(0, +)
}
sum(1,2)      // 3
sum(1,2,3)    // 6
sum(1,2,3,4)  // 10
```


## 使用类型嵌套

Swift 支持内部类。所以有用就可以这么做：

**👎 Don’t:**

```swift
enum PhotoCollectionViewCellStyle {
    case default
    case photoOnly
    case photoAndDescription
}
```

这个枚举可能在 `PhotoCollectionViewCell` 之外就不会再使用到了。没理由把这个枚举声明成全局的。

**👍 Do:**

```swift
class PhotoCollectionViewCell {
    enum Style {
        case default
        case photoOnly
        case photoAndDescription
    }
    let style: Style = .default
}
```

这很容易理解, 毕竟 `Style` 本来就是用来标记 `PhotoCollectionViewCell` 的。而且还少了23个字符呢。


## 使用 final 关键字 🏁

如果你不需要拓展某些类, 也不希望这些类被拓展, 使用 `final` 修饰它。不用担心犯错, 比如 `PhotoCollectionViewCell` 这个类, 你还有可能继承它吗？

而且:**这么做可以节约编译时间。**

## 给常量命名空间

在 OC 中是通过在全局的常量前面加 `PFX` 或者 `k` 来给这些常量命名空间的。但是 Swift 可不这样。

**👎 Don’t:**

```swift
static ket kAnimationDuration: TimeInterval = 0.3
static let kLowAlpha = 0.2
static let kAPIKey = "13511-5234-5234-59234"
```

**👍 Do:**

```swift
enum Constant {
    enum UI {
        static let animationDuration: TimeInterval = 0.3
        static let lowAlpha: CGFloat = 0.2  
    }
    enum Analytics {
        static let apiKey = "13511-5234-5234-59234"
    }
}
```

我个人的偏好是使用 `C` 来代替 `Constant`, 他已经够清晰了。这个可以看你自己喜欢了。

**Before:** `kAnimationDuration` 或者 `kAnalyticsAPIKey`
**After:** `C.UI.animationDuration` 或者 `C.Analytics.apiKey`


## `_` 的使用

`_` 是对没有使用到的变量的占位符。他就是告诉编译器"这个值是什么不重要"。 不然编译器会有警告⚠️。

**👎 Don't**

```swift
if let _ = name {
    print("Name is not nil.")
}
```

`optional`就像一个盒子。可以直接看他是不是空的, 没必要每次都把里面的东西拿出来。

**👍 Do:**

* 判空

```swift
if name != nil {
    print("Name is not nil.")
}
```

* 返回值没用

```swift
_ = manager.removeCar(car) // 成功返回true
```

* ConpletionHandler

```swift
service.fetchItems {data, error , _ in
    // 第三个参数我不在乎他是什么
}
```

## 方法命名

这点适用于所有需要人类去阅读的语言。代码总是不那么容易理解的, 不要浪费别人的精力。

```swift
driver.driving()
```

这是在干什么？

* 是把 `driver` 标记成 `driving` 状态？
* 还是检查 `driver` 是不是 `driving` 状态, 并且返回一个 `bool` 值？

**如果要点进去看才知道这方法是干什么的, 这个命名就是失败了。**多人协同开发或者处理遗留项目的时候, 你读别人代码的时间比你写代码的时间都要长。所以在命名的时候想着别让看你代码的人痛苦。


## 关于 print

很严肃的说, 不要得到一个 `error` 或者 `response` 就在控制台打印出来。你这么做还不如不打印呢！搞得控制台一堆乱七八糟的东西看起来真的很爽吗？

**Do:**

* 在 `framework` 中使用 `error` 级的 `log level`。
* 使用一些能够让你有不同输出级别的 log 库。*XGGLogger*、*SwiftyBeaver*
* 不要用 log 来 debug 了。Xcode 有很多有用的工具[Debugging: A Case Study](https://www.objc.io/issues/19-debugging/debugging-case-study/)

## 没用的代码

经常在一些老项目里面见到被注释掉的代码, 但是出来没有通过把这些代码打开来解决过问题。所以, 既然这些代码都没有什么用了, 就删了它! 还能增加代码的可读性, 看起来整洁的代码总要让人舒服一些。



**最后推荐一个好文[Using SwiftLint and Danger for Swift Best Practices](https://medium.com/@gokselkoksal/swifty-tips-%EF%B8%8F-8564553ba3ec)**


**[原文地址](https://medium.com/@gokselkoksal/swifty-tips-%EF%B8%8F-8564553ba3ec)**

