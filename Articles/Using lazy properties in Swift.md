# Using lazy properties in Swift

懒加载属于让你可以在需要的时候才初始化, 而不是在初始化这个对象的时候就必须要。懒加载可以用来避免 optional 的使用, 当某个属性的初始化耗费很多资源的时候会提升性能。当然使用懒加载也能让对象的初始化方法看起来很清爽, 因为某些设置会在这个对象的生命周期中被推迟。

这周我们来学习一下 Swift 中懒加载的定义, 以及使用。

### 基本用法

定义一个懒加载属性最简单的办法就是在 `var` 前加一个 `lazy` 关键字, 并且还要给 出默认的值。这个默认值会在这个属性被第一次访问的时候被指定, 也就是说在这个对象的初始化方法中这个就不需要再去初始化这个属性了。

```swift
class FileLoader {
    private lazy var cahce = Cache<File>()
    
    func loadFile(name name: String) throws -> File {
        if let cachedFile = cahce[name] {
            return cachedFile
        }
        let file = try loadFileFromDisk(fileName: name)
        cahce[name] = file
        return file
    }
}
```

### 使用工厂方法

有些时候我们可能需要在这个属性在懒加载的时候设置一些东西, 只是简单的使用它的初始化方法可能就没有那么方便了。这种情况下, 更方便的方法是把这个属性的初始化代理给一个工厂方法。

```swift
class Scene {
    private lazy var eventManager: EventManager = self.makeEventManager()
    private func makeEventManager() -> EventManager{
        let manager = EventManager()
        return manager
    }
}
```


如果你不希望你的类里面全是各种 `make..()` 这类工厂方法, 你可以把这些方法放在一个专门的 `extension` 中

### 使用自执行闭包

除了使用工厂方法来返回这个属性值以外, 你也可以选择在这个属性声明的地方通过一个自执行的闭包来出初始化这个属性。我们看看上面这个情况, 我们应该怎么做吧！

```swift
    private lazy var eventManager: EventManager = {
       let manager = EventManager()
        return manager
    }()
```

这要做有一个好处: 让这个属性的在同一个地方声明和设置。当然阅读这些代码可能会比较不爽。特别是在这个属性的设置需要很长的代码的时候。我自己的规则是当这个属性的初始化方法只有两三行代码的时候。就是使用这样的方法来初始化懒加载属性。

### 使用静态工厂方法

对于那些设置起来更复杂属性, 把这些代码放到其他的类中, 会是更好的办法。这么做, 可以让这个类更加专注于它自己的职责, 让这个类不至于那么复杂。当然这也可以在不使用子类的条件下, 在多个类中共享代码。


```swift
private lazy var actionButton: UIButton = ViewFactory.makeActionButton()
```

在这个例子中, `ViewFactory` 这个类包含了这个 `controller` 中所有控件的初始化方法。不用引入更多的类, 也不用让继承树变复杂。如果我们希望在另外一个 `controller` 中使用这个按钮, 也只需要调用同一个 API 就好了 `ViewFactory.makeActionButton()`

### 总结

可能有人会问, 有没有什么大一统的方法来使用懒加载呢？ 个人认为没有. 写代码就是这样, 选择最合适的方法来处理不同的业务需求才是最正确的做法。而且我自己也在日常开发中使用上面所有的方法。

Twitter 又一个问题: 使用不同的方法, 对编译时间有什么影响呢？我做了一些基本的测试, 并没有发现这其中有什么差别。当然这也跟这个懒加载属性有关。

Thanks for reading! 🚀

