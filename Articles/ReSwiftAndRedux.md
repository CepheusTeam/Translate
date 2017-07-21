# 用 ReSwift 实现 Redux 架构

随着 app 的发展， MVC 渐渐的满足不了业务的需求。大家都在探索各种各样的架构模式来适应这种情况，像是MVVM、VIPER、[Riblets](https://eng.uber.com/new-rider-app/) 等等。 他们都有各自的特点，但是都有同一个核心: 通过多向数据流将代码按照单一职责原则来划分代码。在多向数据流中，数据在各个模块中传递。

多向数据流并不一定是你想要的，反而，单向数据流才是我们更喜欢的数据传递方式。在这个 ReSwift 的教程中，你会学到如何使用 ReSwift 来实现单向数据流，并完成一个状态驱动的游戏——**MemoryTunes**

## 什么是 ReSwift

[ReSwift](https://github.com/ReSwift/ReSwift) 是一个轻量级的框架，能够帮助你很轻松的去构建一个 Redux 架构的app。当然它是用Swift 实现的。

RxSwift 有以下四个模块

* **Views**： 响应 **Store** 的改变，并且把他们展示在页面上。views 发出 **Actions**。
* **Actions**:发起app 种状态的改变。Action 是有 **Reducer** 操作的。
* **Reducers**: 直接改变程序的状态，这些状态由 **Store** 来保存。
* **Store**:保存当前的程序的状态。其他模块，比如说 **Views** 可以订阅这个状态，并且响应状态的改变。

ReSwift 至少有以下这些优势:

* **很强的约束力**：把一些代码放在不合适的地方往往具有很强的诱惑性，虽然这样写很方便。ReSwift 通过很强的约束力来避免这种情况。
* **单向数据流**：多向数据流的代码在阅读和debug上都可能变成一场灾难。一个改变可能会带来一系列的连锁反应。而单向数据流就能让程序的运行更加具有可预测性，也能够减少阅读这些代码的痛苦。
* **容易测试**：大多数的业务逻辑都在Reducer 中，这些都是纯的功能。
* **复用性**：ReSwift 中的每个组件—Store、Reducer、Action ，都是能在各个平台独立运行的，可以很轻松的在iOS、macOS、或者tvOS 中复用这些模块。

### 多向数据流 vs. 单向数据流

通过以下的几个例子，我们来理解一下什么是数据流。一个基于 VIPER 架构实现的程序就允许数据在其组件中多向传递。

<center>

![VIPER 中的多向数据流](http://ocg4av0wv.bkt.clouddn.com/2017-07-20-033011.jpg)

VIPER 中的多向数据流</center>

跟 ReSwift 中的数据传递方向比较一下：

<center>

![](http://ocg4av0wv.bkt.clouddn.com/2017-07-20-033331.jpg)

ReSwift 中的单向数据流</center>

可以看出来，数据是单向传递的，这么做，可以让程序中的数据传递更加清晰，也能够很轻松的定位到问题的所在。

## 开始

这是一个已经把整个框架差不多搭建起来的模版项目，包含了一些骨架代码，和库。

首先需要做一些准备工作，首先就是要设置这个app最重要的部分:state

打开**AppState.swift** 文件，创建一个 AppState 的结构体:

```swift
import ReSwift

struct AppState : StateType{
  
}
```

这个结构体定义了整个app的状态。

在创建包含所有的 AppState 的 **Store** 之前，还要创建一个主 Reducer

<center>

![](http://ocg4av0wv.bkt.clouddn.com/2017-07-20-034323.jpg)

</center>

Reducer 是唯一可以直接改变 **Store** 中 **AppState** 的值的地方。只有 Action 可以驱动 Reducer 来改变当前程序的状态。而 Reducer 改变当前 AppState 的值，又取决于他接受到的 Action 类型。

> 注意，在程序中只有一个 Store， 他也只有一个主 Reducer

接下来在**AppReducer.swift** 中创建主 reducer：

```swift
import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
  return AppState()
}
```

**appReducer** 是一个接收 Action 并且返回改变之后的 AppState 的函数。参数 state 是程序当前的 state。 这个函数可以根据他接收的 Action 直接改变这个 状态。现在就可以很容易的创建一个 AppState 值了。

现在应该创建 Store 来保存 state 了。

<center>

![](http://ocg4av0wv.bkt.clouddn.com/2017-07-20-035231.jpg)

</center>

Store 包含了整个程序当前的状态：这是 AppState 的一个实例。打开**AppDelegate.swift** ,在 impore UIkit 下面添加如下代码:

```swift
import ReSwift

var store = Store<AppState>(reducer: appReducer, state: nil)
```

这段代码通过 appReducer 创建了一个全局的变量store，appReducer 是这个 Store 的主 Reducer，他包含了接收到action的时候，store 应该怎么改变的规则。因为这是一些准备工作，所以只是传递了一个 nil state 进去。

编译运行，当然，什么都看不见。因为还没写啊！

## App Routing

现在可以创建第一个实质的 state了，可是使用 IB 的导航，或者是 routing。

App 路由在所有的架构模式中都是一个挑战，在 ReSwift 中也是。在 MemoryTunes 中将使用很简单的方法来做这件事情，首先需要通过 enum 定义所有的终点，然后让 AppState 持有当前的终点。AppRouter 就会响应这个值的改变，达到路由的目的。

在 **AppRouter.swift** 中添加下面的代码：

```swift
import ReSwift

enum RoutingDestination: String {
  case menu = "MenuTableViewController"
  case categories = "CategoriesTableViewController"
  case game = "GameViewController"
}
```

这个枚举代表了app 中的所有 ViewController。

到现在，终于有能够放在你程序状态中的数据了。在这个例子里面，只有一个 state 结构体(AppState), 你也可以在这个 state 里面通过子状态的方法，将状态进行分类，这是一个很好的实践。

打开 **RoutingState.swift** 添加如下的子状态结构体：

```swift
import ReSwift

struct RoutingState: StateType {
  var navigationState: RoutingDestination
  
  init(navigationState: RoutingDestination = .menu) {
    self.navigationState = navigationState
  }
}
```

RoutingState 包含了 navigationState， 这个东西，就是当前屏幕展示的界面。

> menu 是 navigationState 的默认值。如果没有制定的话，将它设置成这个app的最初状态。

在 **AppState.swift** 中，添加如下代码:

```swift
let routingState: RoutingState
```

现在 AppState 就有了 RoutingState 这个子状态。编译一下，会发现一个错误。

<center>

![](http://ocg4av0wv.bkt.clouddn.com/2017-07-20-091710.jpg)

</center>

*appReducer* 编译不过了！因为我们给 *AppState* 添加了 *routingState*，但是在初始化的时候并没有把这个东西传进去。现在还需要一个 reducer 来创建 *routingState*

现在我们只有一个主 **Reducer**， 跟 state 类型，我们也可以通过 子Reducer 来将 Reducer 划分开来。

<center>

![](http://ocg4av0wv.bkt.clouddn.com/2017-07-21-014930.jpg)

</center>

在 **RoutingReducer.swift** 中添加下面的 **Reducer**：

```swift
import ReSwift

func routingReducer(action: Action, state: RoutingState?) -> RoutingState {
  let state = state ?? RoutingState()
  return state
}
```

跟 主 Reducer 差不多， *routionReducer* 根据接收到的 Action 改变状态，然后将这个状态返回。到现在，还没有创建 action 所以如果没有接收到 state 的话，就 new 一个 *RoutingState*，然后返回。

子 reducer 负责创造他们对应的 子状态。

现在回到 **AppReducer.swift** 去改变这个编译错误:

```swift
return AppState(routingState: routingReducer(action: action, 
										 state: state?.routingState))
```

给 AppState 的初始化方法中添加了对应的参数。其中的 action 和 state 都是由main reducer 传递进去的。

### 订阅  subscribing

还记得 RoutingState 里面那个默认的 state `.menu` 吗？他就是 app 默认的状态。只是你还没有订阅它。

任何的类都可以定于这个 store， 不仅仅是 **View**。当一个类订阅了这个 Store 之后，每次 state 的改变他都会得到通知。我们在 *AppRouter* 中订阅这个 Store， 然后收到通知之后，push 一个 Controller

打开 **AppRouter.swift** 然后重新写 *AppRouter*

```swift
final class AppRouter {
  
  let navigationController: UINavigationController
  
  init(window: UIWindow) {
    navigationController = UINavigationController()
    window.rootViewController = navigationController
    
    // 1
    store.subscribe(self) {
      $0.select {
        $0.routingState
      }
    }
  }
  
  // 2
  fileprivate func  pushViewController(identifier: String, animated: Bool) {
    let viewController = instantiateViewController(identifier: identifier)
    navigationController.pushViewController(viewController, animated: animated)
  }
  
  fileprivate func instantiateViewController(identifier: String) -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: identifier)
  }
  
}

// MARK: - StoreSubscriber
// 3
extension AppRouter :StoreSubscriber {
  func newState(state: RoutingState) {
    // 4
    let shouldsAnimate = navigationController.topViewController != nil
    pushViewController(identifier: state.navigationState.rawValue, animated: shouldsAnimate)
  }
}
```

在这段代码中，我们改了 AppRouter 这个类，然后添加了一个 extension。我们看看具体每一步都做了什么吧！

1. *AppState* 现在订阅了全局的 store， 在闭包里面， selct 表明正在订阅 routingState 的改变。
2. *pushViewController* 用来初始化，并且 push 这个控制器。通过 identifier 加载的 StoryBoard 中的控制器。
3. 让 *AppRouter* 响应 StoreSubscriber， 当 routingState 改变的时候，将新的值返回回来。
4. 根控制器是不需要动画的，所以在这个地方判断一下根控制器。
5. 当 state 发生改变，就可以去出 state.navigationState, push 出对应的 controller

AppRouter 现在就就初始化 *menu* 然后将 *MenuTableViewController* push 出来

编译运行：

<center>

<img src="http://ocg4av0wv.bkt.clouddn.com/2017-07-21-024808.jpg" width="200">

</center>

现在 app 中就是 *MenuTableViewController* 了, 现在当然还是空的。毕竟我们还没有开始学 view。

## View

<center>

![](http://ocg4av0wv.bkt.clouddn.com/2017-07-21-025205.jpg)

</center>

任何东西都可能是一个 *StoreSubscriber*， 但是大多数情况下都是 view 层在响应状态的变化。现在是让 *MenuTableViewController* 来展示两个不同的 menu 了。

去 **MenuState.swift**， 创建对应的 Reducer

```swift
import ReSwift

struct MenuState: StateType {
  var menuTitles: [String]
  
  init() {
    menuTitles = ["NewGame", "Choose Category"]
  }
}
```

**MenuState** 有一个 *menuTitles， 这个属性就是 tableView 的 title

在 **MenuReducer.swift** 中，创建这个 state 对应的 Reducer:

```swift
import ReSwift

func menuReducer(action: Action, state: MenuState?) -> MenuState {
  return MenuState()
}
```

因为 MenuState 是静态的，所以不需要去处理状态的变化。所以这里只需要简单的返回一个新的 MenuState

回到 **AppState.swift** 中, 添加

```swift
let meunState: MenuState
```

编译又失败了，然后需要到 **AppReducer.swift** 中去修改这个编译错误。

```swift
return AppState(routingState: routingReducer(action: action,
                                  state: state?.routingState),
      meunState: menuReducer(action: action, state: state?.meunState))
```

现在有了 MenuState, 接下来就是要订阅它了。

先在打开 **MenuTableViewController.swift**, 然后将代码改成这样:

```swift
import ReSwift

final class MenuTableViewController: UITableViewController {
  // 1
  var tableDataSource: TableDataSource<UITableViewCell, String>?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // 2
    store.subscribe(self) {
      $0.select {
        $0.menuState
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // 3
    store.unsubscribe(self)
  }
  
}

// MARK: - StoreSubscriber
extension MenuTableViewController: StoreSubscriber {
  func newState(state: MenuState) {
    // 4
    tableDataSource = TableDataSource(cellIdentifier: "TitleCell", models: state.menuTitles) {
      $0.textLabel?.text = $1
      $0.textLabel?.textAlignment = .center
      return $0
    }
    
    tableView.dataSource = tableDataSource
    tableView.reloadData()
  }
}
```

现在我们来看看这段代码做了什么？

1. TableDataSource 包含了UITableView data source 相关的东西。
2. 订阅了 menuState
3. 取消订阅
4. 这段代码就是实现 UITableView 的代码，在这儿可以很明确的看到 state 是怎么变成 view 的。

> 可能已经发现了，ReSwift 使用了很多值类型变量，而不是对象类型。并且推荐使用声明式的 UI 代码。为什么呢？
>
> StoreSubscriber 中定义的 newState 回调了状态的改变。你可能会通过这样的方法去接货这个值
>
> ```swift
> final class MenuTableViewController: UITableViewController {
>   var currentMenuTitlesState: [String]
>   ...
> ```
>
> 但是写声明式的 UI 代码，可以很明确的知道 state 是怎么转换成 View 的。在这个例子中的问题的 UITableView 并没有这样的API。这就是我写 TableDataSource 来桥接的原因。如果你感兴趣的话可以去看看这个 **TableDataSource.swift**

编译运行，就能够看到了:

<center>

<img src="http://ocg4av0wv.bkt.clouddn.com/2017-07-21-032618.jpg" width="200">

</center>

## Action

<center>

![](http://ocg4av0wv.bkt.clouddn.com/2017-07-21-032930.jpg)

</center>

做好了 View 接下来就来写 **Action** 了。

Action 是 Store 中数据改变的原因。一个 Action 就是一个有很多变量结构体，这写变量也是这个 Action 的参数。 Reducer 处理一系列的 action， 然后改变 app 的状态。

我们现在先创建一个 Action， 打开 **RoutingAction.swift**

```swift
import ReSwift

struct RoutingAction: Action {
  let destination: RoutingDestination
}
```

*RoutingAction* 改变当前的 routing 终点

现在，当 menu 的 cell 被点击的时候，派发一个 action。

在 **MenuTableViewController.swift** 中添加下面的代码:

```swift
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var routeDestination: RoutingDestination = .categories
    switch indexPath.row {
    case 0: routeDestination = .game
    case 1: routeDestination = .categories
    default:break
    }
    store.dispatch(RoutingAction(destination: routeDestination))
  }
```

这段代码，根据选择的 cell 设置不同的 routeDestination 然后用dispatch 方法派发出去。

这个 action 被派发出去了，但是，还没有被任何的 reducer 给支持。现在去 RoutingReducer.swift 然后做一下对应的修改。

```swift
  var state = state ?? RoutingState()
  
  switch action {
  case let routingAction as RoutingAction:
    state.navigationState = routingAction.destination
  default: break
  }
  return state
```

switch 语句用来判断是否传入的 action 是 RoutingAction。如果是，就修改 state 为这个 action 的 destination

编译运行，现在点击 item ， 就会对应的 push 出 controller。

## Updating the State

这样去实现导航可能是由瑕疵的。当你点击 "New Game" 的时候，`RoutingState` 的 `navigationState` 就会从`menu` 变成 `game`。 但是当你点击 controller 的返回按钮的时候，navigationState 却没有改变。

在 ReSwift 中，让状态跟 UI 同步是很重要的，但是这又是最容易搞忘的东西。特别是向上面那样，由 UIKit 自动控制的东西。

我们可以在 MenutableViewController 出现的时候更新一下这个状态。

在 **MenuTableViewController.swift** 的 `viewWillAppear`: 方法中，添加:

```swift
store.dispatch(RoutingAction(destination: .menu))
```

这样就能够在上面的问题出现的时候解决这个问题。

运行一下呢？呃... 完全乱了。也可能会看到一个崩溃。

<center>

![](http://ocg4av0wv.bkt.clouddn.com/2017-07-21-live.gif)

</center>

打开 **AppRouter.swift**， 你会看到每次接收到一个新的 navigationState 的时候，都会调用 `pushViewController` 方法。也就是说，每次响应就会 push 一个 menu 出来！

所以我们还必须在 push 之前确定这个 controller 是不是正在屏幕中。所以我们修改一下 `pushViewController`  这个方法:

```swift
fileprivate func  pushViewController(identifier: String, animated: Bool) {
	let viewController = instantiateViewController(identifier: identifier)
    let newViewControllerType = type(of: viewController)
    if let currentVc = navigationController.topViewController {
      let currentViewControllerType = type(of: currentVc)
      if currentViewControllerType == newViewControllerType {
        return
      }
    }
    navigationController.pushViewController(viewController, animated: animated)
}
```

上面的方法中，通过 `type(of:)` 方法来避免当前的 topViewController 跟 要推出来的 Controller 进行对比。如果相等，就直接 `return` 。

编译运行，这时候，又一切正常了。

当 UI 发生变化的时候更新当前的状态是比较复杂的事情。这是写 ReSwift 的时候必须要解决的一件事情。还好他不是那么常见。

## Category

现在，我们继续来实现  *CategoriesTableViewController* 这一部分跟之前的部分比起来更复杂一些。这个界面需要允许用户来选择音乐的类型，首先，我们在**CategoriesState.swift** 中添加响应的状态。

```swift
import ReSwift

enum Category: String {
  case pop = "Pop"
  case electrinic = "Electronic"
  case rock = "Rock"
  case metal = "Metal"
  case rap = "Rap"
}

struct CategoriesState: StateType {
  let categories: [Category]
  var currentCategorySelected: Category
  
  init(currentCategory: Category) {
    categories = [.pop, .electrinic, .rock, .metal, .rap]
    currentCategorySelected = currentCategory
  }
}
```

这个枚举定义了一些音乐的类型。CategoriesState 包含了一个数组的种类，以及当前选择的种类。

在 **ChangeCategoryAction.swift** 中添加这些代码:

```swift
import ReSwift

struct ChangeCategoryAction: Action {
  let categoryIndex: Int
}
```

这里定义了对应的 action， 使用 categoryIndex 来寻找对应的音乐类型。

现在来实现 Reducer了。 这个 reducer 需要接受 ChangeCategoryAction 然后将新的 state 保存起来。打开 **CategoryReducer.swift**：

```swift
import ReSwift

private struct CategoriesReducerConstants {
  static let userDefaultCategoryKey = "currentCategoryKey"
}

private typealias C = CategoriesReducerConstants

func categoriesReducer(action: Action, state: CategoriesState?) -> CategoriesState {
  var currentCategory: Category = .pop
  // 1
  if let loadedCategory = getCurrentCategoryStateFromUserDefaults() {
    currentCategory = loadedCategory
  }
  var state = state ?? CategoriesState(currentCategory: currentCategory)
  
  switch action {
  case let changeCategoryAction as ChangeCategoryAction:
    // 2
    let newCategory = state.categories[changeCategoryAction.categoryIndex]
    state.currentCategorySelected = newCategory
    saveCurrentCategoryStateToUserdefaults(category: newCategory)
  default: break
  }
  return state
}

// 3
private func getCurrentCategoryStateFromUserDefaults() -> Category?
{
  let userDefaults = UserDefaults.standard
  let rawValue = userDefaults.string(forKey: C.userDefaultCategoryKey)
  if let rawValue = rawValue {
    return Category(rawValue: rawValue)
  } else {
    return nil
  }
}

// 4
private func saveCurrentCategoryStateToUserdefaults(category: Category) {
  let userDefaults = UserDefaults.standard
  userDefaults.set(category.rawValue, forKey: C.userDefaultCategoryKey)
  userDefaults.synchronize()
}

```

跟其他的 Reducer 一样，这些方法实现了一下比较复杂的状态的改变，并且将选择之后的状态通过 Userdefault 持久化。

1. 从 UserDefault 中获取 category， 然后赋值给 CategoriesState
2. 在接收到 ChangeCategoryAction 的时候更新状态，然后保存下来
3. 从 Userdefault 中获取state
4. 将 state 保存在 UserDefault 中

3、4 中的两个方法都是功能很单一的方法，而且是全局的。你也可以把他们放在一个类或者结构体中。

接下来很自然的，就会需要在 AppState 中添加新的状态。打开 **AppState.swift** 然后添加对应的状态:

```swift
let categoriesState: CategoriesState
```

然后去 **AppReducer.swift** 中去修改对应的错误

```swift
  return AppState(routingState: routingReducer(action: action,
                                               state: state?.routingState),
                  meunState: menuReducer(action: action, state: state?.meunState),
        categoriesState: categoriesReducer(action: action, state: state?.categoriesState))
```

现在还需要 View 了。现在需要在 CategoriesViewController 中去写这部分的 View

```swift
import ReSwift

final class CategoriesTableViewController: UITableViewController {
  var tableDataSource: TableDataSource<UITableViewCell, Category>?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //1
    store.subscribe(self) {
      $0.select {
        $0.categoriesState
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    store.unsubscribe(self)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // 2
    store.dispatch(ChangeCategoryAction(categoryIndex: indexPath.row))
  }
}

extension CategoriesTableViewController: StoreSubscriber {
  func newState(state: CategoriesState) {
    tableDataSource = TableDataSource(cellIdentifier: "CategoryCell", models: state.categories) {
      $0.textLabel?.text = $1.rawValue
      // 3
      $0.accessoryType = (state.currentCategorySelected == $1) ? .checkmark : .none
      return $0
    }
    tableView.dataSource = tableDataSource
    tableView.reloadData()
  }
}

```

这部分的代码跟 MenuTableViewController 差不多。注释中标记的内容分别是：

1. 在 `viewWillAppear` 中订阅 categoriesState 的改变，然后在 `viewillDisappear` 中取消订阅。
2. 将事件派发出去
3. 标记选择的状态

所有的东西都写好了，现在试一下！

<center>

<img src="http://ocg4av0wv.bkt.clouddn.com/2017-07-21-065609.jpg" width="200">

</center>

## 异步任务

怎么都跑不了这个话题，这在 ReSwift 也很方便。

场景:从 iTunes的 [API](https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/?uo=8&at=11ld4k) 中去获取照片。首先需要创建对应的 state， reducer 以及相关的 action.

打开 **GameState.swift** 添加

```swift
import ReSwift

struct GameState: StateType {
  var memoryCards: [MemoryCard]
  // 1
  var showLoading: Bool
  // 2
  var gameFinishied: Bool
}
```

这段代码定义了 Game 的状态。

1. loading 的 菊花，是否存在
2. 游戏是否结束

接下来是Reducer **GameReducer.swift**:

```swift
import ReSwift

func gameReducer(action: Action, state: GameState?) -> GameState {
  let state = state ?? GameState(memoryCards: [],
                                 showLoading: false,
                                 gameFinishied: false)
  return state
}
```

这段代码就是简单的创建了一个 *GameState*, 稍后会再回到这个地方的。

在 **AppState.swift** 中，添加对应的状态

```swift
let gameState: GameState
```

修改 **AppReducer.swift** 中出现的编译错误

```swift
return AppState(routingState: routingReducer(action: action,
                                               state: state?.routingState),
                  meunState: menuReducer(action: action, state: state?.meunState),
                  categoriesState: categoriesReducer(action: action, state: state?.categoriesState),
                  gameState: gameReducer(action: action, state: state?.gameState))
```

> 发现了规律了吧，在每次写完 Action/Reducer/State之后应该做什么都是可见并且很简单的。这种情况，得益于ReSwift 的单向数据特效和严格的代码约束。只有 Reducer 能够改变 app 的 Store，只有 Action 能够触发这种响应。这样做能够让你知道在上面地方找代码，在什么地方做新功能。

现在开始定义 Action， 这个 action 用来更新卡片。在 **SetCardsAction.swift**：

```swift
import ReSwift

struct SetCardsAction: Action {
  let cardImageUrls: [String]
}
```

这个 action 用来设置 GameState 中图片的URL

现在开始准备程序中第一个异步行为吧！在 **FetchTumesAction.swift** 中，添加下面的代码:

```swift
import ReSwift

func fetchTunes(state: AppState, store: Store<AppState>) -> FetchTunesAction {
  iTunesAPI.searchFor(category: state.categoriesState.currentCategorySelected.rawValue) {
    store.dispatch(SetCardsAction(cardImageUrls: $0))
  }
  return FetchTunesAction()
}


struct FetchTunesAction: Action{}

```

`fetchTunes`  通过 `itunesAPI` 获取了图片。然后在闭包中将结果派发出来。 ReSwift 中的异步任务就是这么简单。

`fetchTunes` 返回一个 `FetchTunesAction`  这个 action 是用来验证请求的。

打开 **OpenReducer.swift** 然后添加对这两个 action 的支持。把 `gameReducer` 中的代码改成下面这样：

```swift
 var state = state ?? GameState(memoryCards: [],
                                 showLoading: false,
                                 gameFinishied: false)
  switch action {
  // 1
  case _ as FetchTunesAction:
    state = GameState(memoryCards: [],
                      showLoading: true,
                      gameFinishied: false)
  // 2
  case let setCardsAction as SetCardsAction:
    state.memoryCards = generateNewCards(with: setCardsAction.cardImageUrls)
    state.showLoading = false
  default:break
  }
  return state

```

这段代码，就是根据具体的 action 做不同的事情。

1. FetchTunesAction, 设置 showLoading 为 true
2. SetCardsAction, 打乱卡片，然后将 showLoading 设置为 false。 generateNewCards 方法可以在 **MemoryGameLogic.swift** 中找到

现在开始写 **View**

在 **CardCollectionViewCell.swift** 中添加下面的方法:

```swift
  func configCell(with cardState: MemoryCard) {
    let url = URL(string: cardState.imageUrl)
    // 1
    cardImageView.kf.setImage(with: url)
    // 2
    cardImageView.alpha = cardState.isAlreadyGuessed || cardState.isFlipped ? 1 : 0
  }
```

`configCell` 这个方法做了下面两件事情:

1. 使用 Kingfisher 来缓存图片
2. 判断是否展示图片

下一步，实现 CollectionView。在 gameViewCotroller.swift 倒入 `import ReSwift` 然后在 `showGameFinishedAlert` 上面添加下面的代码:

```swift
 var collectionDataSource: CollectionDataSource<CardCollectionViewCell, MemoryCard>?
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.subscribe(self) {
      $0.select {
        $0.gameState
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    store.unsubscribe(self)
  }
  
  override func viewDidLoad() {
    // 1
    store.dispatch(fetchTunes)
    collectionView.delegate = self
    loadingIndicator.hidesWhenStopped = true
    
    // 2
    collectionDataSource = CollectionDataSource.init(cellIdentifier: "CardCell", models: []) {
      $0.configCell(with: $1)
      return $0
    }
    collectionView.dataSource = collectionDataSource
  }

```

由于没有写 StoreSubscriber ，所以这里会有一点点的编译错误。我们先假设已经写了。这段代码，首先是订阅了取消订阅 gameState 然后:

1. 派发 fetchTunes 来获取图片
2. 使用 CollectiondataSource  来配置 cell 相关信息。

现在我们来添加 `StoreSubscriber` :

```swift
extension GameViewController: StoreSubscriber {

  func newState(state: GameState) {
    collectionDataSource?.models = state.memoryCards
    collectionView.reloadData()
    // 1
    state.showLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
       // 2
    if state.gameFinishied {
      showGameFinishedAlert()
      store.dispatch(fetchTunes)
    }
  }
}
```

这段代码实现了 state 改变的时候对应的变化。他会更新 dataSource

1. 更新 loading indicator 的状态。
2. 当游戏结束时，弹窗

现在，运行一下吧！

<center>

<img src="http://ocg4av0wv.bkt.clouddn.com/2017-07-21-085643.jpg" width="200">

</center>

## Play

游戏的逻辑是： 让用户翻转两张卡片的时候，如果它们是一眼的，就让他们保持，如果不一样就翻回去。用户的任务是在尽可能少的尝试之后翻转所有的卡片。

现在需要一个翻转的事件。在 **OpenCardAction.swift** 中添加代码:

```swift
import ReSwift

struct FlipCardAction: Action{
  let cardIndexToFlip: Int
}
```

当卡片翻转的时候: FlipCardAction 使用 cardIndexToFlip 来更新 gameState 中的状态。

下一步修改 `gamereducer `  来支持这个 action。打开 **GameReducer.swift** 添加下面对应的case

```swift
  case let flipCardAction as FlipCardAction:
    state.memoryCards = flipCard(index: flipCardAction.cardIndexToFlip,
                                 memoryCards: state.memoryCards)
	state.gameFinishied = hasFinishedGame(cards: state.memoryCards)
```

对 FlipCardAction 来说， flipCard 改变卡片的状态。hasFinishedGame 会在游戏结束的时候调用。两个方法都可以在 **MemoryGameLogic.swift** 中找到。

最后一个问题是在点击的时候，把翻转的 action 派发出去。

在 **GameViewController.swift** 中，找到 `UICollectionViewDelegate`  这个 extension。在 `collectionView(_:didSelectItemAt:)` 中添加:

```swift
store.dispatch(FlipCardAction(cardIndexToFlip: indexPath.row))
```

当卡片被选择的时候，关联的` indexPath.row` 就会跟着 `FlipcardAction` 被派发出去.

再运行一下，就会发现！

<center>

<img src="http://ocg4av0wv.bkt.clouddn.com/2017-07-21-091810.jpg" width="200">

</center>



## 结束语

模版项目已经完整项目都在 []() 

ReSwift 不仅仅是我们今天提到的内容。他还以很多:

* **Middleware**: 中间件。swift目前还没有很好的办法来做切面。但是 ReSwift 解决了这个问题。可以使用ReSwift 的 [Middleware] 特性来解决这个问题。他能够让你轻松的切面(logging, 统计， 缓存)。
* **Routing**： 在这个 app 中已经实现了自己的 Routing， 还有个更通用的解决方案[ReSwift-Routing](https://github.com/ReSwift/ReSwift-Router) 单这在社区还是一个还没有完全解决的问题。说不定解决它的人就是你！
* **Testing**: ReSwift 或许是最方便测试的框架了。 Reducer 包含了你需要测试的所有代码。他们都是纯的功能函数。这种函数在接受了同一个input 总是返回同一个值，他们不回依赖于程序当前的状态。
* **Debugging**： ReSwift 的所有状态都在一个结构体中定义，并且是单向数据流的，debug 会非常的简单，甚至你还可以用 [ReSwift-Recorder](https://github.com/ReSwift/ReSwift-Recorder) 来记录下导致 crash 的状态
* **Persistence**: 因为所有的状态都在一个地方，拓展和坚持都是很容易的事情。缓存离线的数据也是一个比较麻烦的架构问题，但是 ReSwift 解决了这个问题。
* **others**： Redux 架构并不是一个库，它是一种编程范式，你也可以自己实现一套，还有 [Katana](https://github.com/BendingSpoons/katana-swift) 或者 [ReduxKit](https://github.com/ReduxKit/ReduxKit) 也可以做这件事

如果你想学习更多关于 ReSwift 的东西，可以看 ReSwift 作者 [Benjamin Encz](https://news.realm.io/news/benji-encz-unidirectional-data-flow-swift/) 的演讲视频

[Christian Tietze’s blog](http://christiantietze.de/posts/2016/01/reswift-level-indirection/) 的博客上有很多有趣的例子。

**这篇文章翻译自Ray wenderlich [ReSwift Tutorial: Memory Game App](https://www.raywenderlich.com/155815/reswift-tutorial-memory-game-app)]**