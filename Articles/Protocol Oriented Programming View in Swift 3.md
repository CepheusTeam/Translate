# Protocol Oriented Programming View in Swift 3

> 学习如何在不创建一大堆类的前提下做按钮、label、图片的动画。

掌握了足够的知识而不去使用它, 就像你长了满口的牙齿, 但是成天都喝牛奶一样。 掌握了足够的理论知识, 在项目中怎么使用 POP 呢？🤔

### What I think you will learn

使用协议让 UI 组件做动画。也会用传统的方法来更 POP 比较。😎

#### UI

这个 demo 叫 "Welcome to My House Party"。 我写这个app 来验证你是否被邀请。你得输入你的邀请码。**这个 app 没有逻辑相关的东西，按下这个按钮之后, 上面的控件都会动起来** 界面上有4个组件会动。 `passcodeTextField`、`loginButton`、`errorMessageLabel`、`profileImageView`.

一共有两种动画类型 

1. Buzzing 
2. Popping

<center>
![](https://cdn-images-1.medium.com/max/1600/1*uN6sB588ehZIivOmmAsLPg.gif)
</center>

不要担心跟不上，只需要跟着节奏往下走就行了。如果你没信心了，滑到最后面，把 Demo 下下来, 直接看代码就行了。


#### Things Back Then

要真正掌握在实际情况中 POP 的魔力，我们先比较一下传统的写法。你可能会创造两个子类然后给她添加一个方法。

```swift
class BuzzableButton: UIButton {
    func buzz() {// Animation Logic}
}
class BuzzableLabel: UILabel {
    func buzz() {// Animation Logic}
}
```

然后让他动起来，当你点击这个按钮

```swift
@IBOutlet weak var errorMessageLabel: BuzzableLabel!
@IBOutlet weak var loginButton: BuzzableButton!

@IBAction func didtapLoginButton(_ sender: UIButton) {
    errorMessageLabel.buzz()
    loginButton.buzz()
}
```

你看到我们重复了几次相同的事情了吗？ 动画的逻辑至少都需要5行代码。既然用 extension 是更好的办法。 UILabel 和 UIButton 都继承了 UIView。 我们可以这样。

```swift
extension UIView {
    func buzz() { // Animation Logic }
}
```
现在 `BuzzableButton` 还有 `BuzzableLabel` 都有 `buzz` 这个方法了。 现在我们就没有重复了。

```swift
class BuzzableButton: UIButton {}
class BuzzableLabel: UILabel {}

@IBOutlet weak var errorMessageLabel: BuzzableLabel!
@IBOutlet weak var loginButton: BuzzableButton!

@IBAction func didTapLoginButton(_ sender: UIButton) {
 errorMessageLabel.buzz()
 loginButton.buzz() 
}
```

#### Okay, then why POP? 🤔

你应该也看见了那个写着 "Please enter valid code 😂" 的`errorMessageLabel` 还有另外一个动画。她先是出现然后在消失。所以, 之前的方法是怎么样的呢？

有两个方法来做这件事情。首先你需要再给 `UIView` 添加一个方法。

```
// Extend UIView
extension UIView {
    func buzz() { // Animation Logic}
    func pop() { // UILable Animation Logic }
}
```

但是如果我们给 UIView 添加了这个方法。这个方法在其他的组件上也有了。包括他的子类 `UILabel`。 我们继承了没有必要的方法。这些组件也莫名其妙的变的很臃肿了。

还有一个方法是给 `UILabel` 添加一个子类，

```swift
// Subclass UILabel
class BuzzableLabel: UILabel {
    func pop() { // UILabel Animation Logic }
}
```

这也能实现。但是可能我们还需要把这个类的名字改一下，然它更直观一点.换成 `BuzzablePoppableLabel` 吧！

如果你想给这个 Label 添加更多的方法。为了让这个 Label 更直观的表达它的作用，可能名字又得改了 `BuzzablePoppableFlashableDopeFancyLovelyLabel` 这显然非常的不可持续。

### Protocol Oriented Programming

用子类来实现就是这样的。选择我们先写一个协议吧！ Buzzing

因为动画的代码都比较长，我没有在这里写出来。

```swift
protocol Buzzable {}
extension Buzzable where Self: UIview {
    func buzz() { // Animation Logic}
}
```

只要遵守了这个协议的 UI 组件就都有 Buzz 这个方法了。与 extension 不同的是，只有遵守的这个协议才会有这个方法。并且我是用了 `where Self: UIView` 来声明这个协议只能被 UIView 及其子类遵守。

既然这样，我们就先给 `loginButton`, `passcodeTextField`, `errorMessageLabel`、`profileImageView` 加上这个协议吧。
对了，还有 pop

```swift
protocol Poppable {}
extension Poppable where Self: UIView {
 func pop() { // Pop Animation Logic }
}
```

好了现在可以开始写了

```swift
class BuzzableTextField: UITextField, Buzzable {}
class BuzzableButton: UIButton, Buzzable {}
class BuzzableImageView: UIImageView, Buzzable {}
class BuzzablePoppableLabel: UILabel, Buzzable, Poppable {}

class LoginViewController: UIViewController {
  @IBOutlet weak var passcodTextField: BuzzableTextField!
  @IBOutlet weak var loginButton: BuzzableButton!
  @IBOutlet weak var errorMessageLabel: BuzzablePoppableLabel!
  @IBOutlet weak var profileImageView: BuzzableImageView!
  
  @IBAction func didTabLoginButton(_ sender: UIButton) {
    passcodTextField.buzz()
    loginButton.buzz()
    errorMessageLabel.buzz()
    errorMessageLabel.pop()
    profileImageView.buzz()
  }
}
```

最方便的事情是我们都不需要使用子类就可能给任何的 UI 组件添加 pop 这个方法了。

```
class MyImageView: UIImageVIew, Buzzable, Poppable 
```

现在，类的名称就可以变的更加的灵活了。因为你已经知道了这些协议的方法，并且这些协议也描述了这些类，所以也不用 `MyBuzzablePoppableProfileImage` 了。

* 没有子类
* 类名更灵活
* 更 Swifty


[SourceCode](https://github.com/bobthedev/Blog_Protocol_Oriented_View)


### That's it!
[原文地址](https://blog.bobthedeveloper.io/protocol-oriented-programming-view-in-swift-3-8bcb3305c427)

### 最后

我是一名来自中国的 iOS 程序员, 对技术有着浓厚的兴趣, 在学习的过程中, 发现了很多来自国外的优秀博客。为了更好的学习这些文章, 产生了将这些文章翻译成中文的想法。

