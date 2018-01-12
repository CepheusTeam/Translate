---
title: Swift4.Codable
date: 2017-8-29 00:15:23
tags: [iOS, Swift, 翻译]
categories: Swift
---

WWDC2017中发布的 Swift4.0 有一个有趣的新特性： Coadble. 今天我们就来聊聊这个 Swift4.0 带来的协议！

### Serialization

对现在需要随时联网的移动应用来说，把值序列化成能够在硬盘或者通过网络传送的数据是一个基本的需求。但是在苹果的生态中我们的选择很有限。

<!--more-->

1. `NSCoding` 协议提供了对复杂对象的序列化能力，它在自定义类型身上也是有效的。但是，不完善的系列化格式并不适合跨平台的需求, 并且他需要我们手写代码来做编解码的工作。
2. `NSPropertyListSerialization` 和 `NSJSONSerialization` 能够让数据能够在 Cocoa 类(NSDictionary/NSString)和属性列表以及 JSON 之间转换。JSON 几乎是所有网络传输的标准格式。由于这些API 只提供了基础类型的转换, 我们必须要编写很多代码从这些值中取出具体类型信息。这些代码通常都是很难复用的，而且这种方式对脏数据的处理能力也不行。
3. `NSXMLParser` and `NSXMLDocument` 这种方式是给那些受虐狂，或者是那些深陷 XML 泥潭的人使用的。基本数据和模型对象之间转换的工作还是需要程序员来做。

这些方法往往会带来大量的样板代码。声明一个叫做 foo 的 Stirng 属性，这个属性会通过将 String 存储在 foo 下进行编码，并通过检索 foo 这个 key ，找到这个值，然后把它转换成String。如果在其中的某个过程中失败的话，就抛出错误。然后在声明第二个属性.....

程序员当然不可能会喜欢这类重复性的工作。这种工作是计算机做的事情。我们只想要做这样的事情:

```swift
struct Whatevet {
  var foo: String
  var bar: String
}
```

然后他就可以序列化了。这其实是有可能的，毕竟所有必要的信息都有了。

映射是一个很常见的方法，很多 OC 的程序员都写过自动将 JSON 转换成 OC 类型的代码。OC 在运行时能够提供转换需要的所有信息。但是对 Swift 来说呢？ 我们当然也能够使用 OC 的 runtime 或者使用 Swift 的镜像, 然后用一些很奇怪的方法来弥补他在这方面的不足。

在苹果的生态系统之外，这已经是很多语言常见的解决方案了。但是这也可能带来奇怪的安全漏洞。

映射并不是一个很好的解决方案。让他出错并且导致安全问题是很容易的事情。它没有使用静态类型，导致了很多bug都只能在运行时才能暴露出来。并且它的效率也不高，因为它对元数据做了很多的字符串查找。

Swift 采用了编译器代码生成的方法，来做这件事情。这就是说有些内容是被嵌入到编译器种的。但是这样做效率却很高，具备静态类型所有优点的同时，在使用上也不会带来什么麻烦。

### 概述

Swift 新引入的 Codable 是建立在一些基础协议之上的。

`Encodable` 这个协议用在那些需要被编码的类型上。如果遵守了这个协议，并且这个类的所有属性都是 Encodable 的， 编译器就会自动的生成相关的实现。如果不是，或者说你需要自定义一些东西，就需要自己实现了。

`Decodable`这个协议跟 `Encodable` 相反，它表示那些能够被解档的类型。跟 `Encodable` 一样,编译器也会自动为你生成相关的实现，前提是所有属性都是 Decodable 的

由于这两个协议总是一起出现，所以就引入了第三个协议:`Codable` 。`Codable`只是把 `Decodable`  和 `Encodable` 连到了一起。

```swift
typealias Codable = Decodable & Encodable
```

这两个协议都很简单。每一个都只有一个实现:

```swift
protocol Encodable {
	func encode(to encoder: Encoder) throws
}

protocol Decodable {
	init(from decoder: Decoder) throws
}
```

这两个协议说明了对象能够自己编码和解码自己。你不需要去考虑他们的基础用法，因为 `Codable` 已经给你添加了默认实现的所有细节, 只有在你需要自己实现 Codable 的时候才需要用到他们。这是比较复杂的部分了，后面我们会再说这个问题。

最后，还有一个叫 `CodingKey` 的协议，用来表示编码和解码的 key。与使用普通的字符串相比，他为程序添加了一个额外的静态类型检查层。他提供了 String 和一个可选的 Int 作为位置键。

```swift
protocol CodingKey {
	var stringValue: String { get }
	init?(stringValue: String)
	var intValue: Int? { get }
	public init?(intValue: Int)
}
```

### 编码器和解码器

Encoder 和 Decoder 的基本概念跟 NSCoder 类似。对象接受一个编码器然后调用自己的方法来编码或者解码。

`NSCoder` 的API 是很直接的。NSCoder 有一系列像是 `encodeObject:forKey` 还有`encodeInteger:forKey`的方法。对象调用他们来完成他们的编码。当然还有一些不需要 key 的方法比如说`encodeObject:` 和`encodeInteger` 。他们不需要通过键来定位。

Swift 的 API 就没那么直接了。 Encoder 不提供编码方法而是提供容器，由容器来做编码的工作。一个用于键控编码，一个用于无键编码，一个用来编码单个的值。

这样设计能够让事情更清晰， 也更适合那些便于携带的序列化格式。NSCoder 指需要使用苹果的编码格式，所以放在一起是没有问题的。但是 Encoder 必须使用JSON这一类东西:如果一个对象使用了键编码，就会产生一个 JSON 字典，如果使用的无键编码，产生的就是一个 JSON 数组。但是如果对象是为空，并且没有编码值呢？使用 NSCoder， 是无法知道到底输出什么的。要是使用 `Encoder` 的话, 对象会请求一个有键容器或者是无键容器这时候编码器就能够从中的值到底需要返回什么了。

`Decoder` 也差不多，我们不直接从中获取解码值，而是通过请求一个容器，从这个容器中获取。跟 `Encoder` 一样, `Decoder` 也提供了有键容器、无键容器，还有用来解码单个值的容器。

因为容器这个设计， `Encoder` 和`Decoder` 这两个协议就非常的小的。他们只需要少量的信息(路径 info 之类的), 加上一些获取容器的方法。

```swift
protocol Encoder {
  var codingPath: [CodingKey?] { get }
  public var userInfo: [CodingUserInfoKey : Any] { get }

  func container<Key>(keyedBy type: Key.Type)
          -> KeyedEncodingContainer<Key> where Key : CodingKey
  func unkeyedContainer() -> UnkeyedEncodingContainer
  func singleValueContainer() -> SingleValueEncodingContainer
}

protocol Decoder {
  var codingPath: [CodingKey?] { get }
  var userInfo: [CodingUserInfoKey : Any] { get }

  func container<Key>(keyedBy type: Key.Type) throws
          -> KeyedDecodingContainer<Key> where Key : CodingKey
  func unkeyedContainer() throws -> UnkeyedDecodingContainer
  func singleValueContainer() throws -> SingleValueDecodingContainer
}
```

复杂的部分是在这些容器里面的。你可以通过递归在 Codable 的属性中走到很深的节点。不过，某些时候，我们需要获取可以被编解码的元数据类型。 在 Codable 中这种类型可能是各种 `Int`、 `Float` 、`Double`、 `Bool` 、`String`….。这就形成了一整套相似的编解码方法。无键容器也直接支持编码这些类型的序列。

除了这些基本的方法之外，还有一些方法来支持各种不同的使用场景。

* KeyedDecodingContainer 有个叫做 `decodeIfPresent` 的方法，这个方法会返回一个 可选类型， 当找不到某个 key 的时候，返回 nil 而不是抛出异常。
* 编码容器也支持软编码, 只有在其他对象也在编码的时候才会编码。这个可以用来处理一些复杂的父引用。
* 还有一写方法用来获取嵌套容器，这种容器能够编码不同的层次结构。
* 最后还有获取 super 编解码器的方法, 这种方法能够让子类和父类在编解码的过程中共存,子类能够直接编码自己, 也能够通过调用父类编码器来编码自己, 唯一的要求是 key 不冲突。

### 实现 Codable

实现 Codable 是很简单：遵守协议，然后编译器就会自动帮你做剩下的事情了。

要知道它到底干了什么，我们先看看它的最终效果是什么样的，然后再看看如果要自己搞，应该做些什么。我们先看看这个 Codable 的类型:

```swift
struct Person: Codable {
  var name: String
  var age: Int
  var quest: String
}
```

编译器会自动生成对应的 key 嵌套在 Person 类中。如果我们自己来做这件事情，这个嵌套类型会是这样的。

```swift
private enum CodingKeys: CodingKey {
  case name
  case age
  case quest
}
```

这些枚举对应 Person 类中的各种属性名称。编译器很智能的给每个CodingKey 的值匹配了对应的属性名，这就是说属性名就是归档这个对象所要用的 key 值。

如果我们需要用不同的名称, 只需要提供我们自己的 CodingKey 。像这样:

```swift
private enum CodingKeys:String, CodingKey {
  case name = "person_name"
  case age
  case quest
}
```

这样写就会让 Person 的 name 属性通过 “person_name”来实现编码和解码。这就是我们需要做的所有事情了。编译器能够很轻松的接受我们自定义的 CodingKey 类型，然后帮你实现 Codable 剩下的部分，并且这些默认的实现支持我们的自定义类型。

编译器同时也生成了 `encode(to:)` 、`init(from:)` 相关的实现。 `encode(to:)` 的实现, 首先获取到有键容器然后挨个去 encode 所有的属性。

```swift
func encode(to encoder: Encoder) throws {
  var container = encoder.container(keyedBy: CodingKeys.self)
  
  try container.encode(name, forKey: .name)
  try container.encode(age, forKey: .age)
  try container.encode(quest, forKey: .quest)
}
```

编译器也会实现 `inin(from:)` 像是这样：

```swift
init(from decoder: Decoder) throws {
  let container = try decoder.container(keyedBy:CodingKeys.self)
  
  name = try container.decode(String.self, forKey: .name)
  age = try container.decode(String.self, forKey: .age)
  quest = try container.decode(String.self, forKey: .quest)
}
```

这就是全部的东西了。就像 CodingKeys 一样, 如果你需要自定义一些具体的行为。你可以自己实现你需要的部分，然后让编译器为你补全剩下的部分。然而，还是没有办法去指定某一个属性的行为，所以，还是需要把所有的属性都实现一边，即使你希望其余的部分都是默认的。不过这应该还好吧！😂

如果你准备自定义所有的过错。Person 类完整的Codable 实现大概是这样的:

```swift
extension Person {
  private enum CodingKeys: CodingKey {
    case name
    case age
    case quest
  }
  
  func encode(to encoder:Encoder) throws {
	var container = encoder.container(keyedBy: CodingKeys.self)

	try container.encode(name, forKey: .name)
	try container.encode(age, forKey: .age)
	try container.encode(quest, forKey: .quest)
  }
  
  init(from decoder: Decoder) throws {
	let container = try decoder.container(keyedBy: CodingKeys.self)

	name = try container.decode(String.self, forKey: .name)
	age = try container.decode(Int.self, forKey: .age)
	quest = try container.decode(String.self, forKey: .quest)
        }
}
```

### 实现 Encoder、 Decoder

你可能永远都不需要自己实现 `Endocer` 或者是 `Decoder`. Swift 已经很好的支持了 JSON、PropertyList。而这两个基本上包含了所有的可能遇见的数据格式。

当然你也可以自己去实现一套来支持你的自定义格式。container  协议的大小说明这需要花点精力，但是这只是大小的问题，而不是增加了什么复杂度。

要实现自定义的 `Encoder`,  你需要一个实现了 Encoder 协议 同时也要实现容器协议的东西。实现三个容器协议需要大量的模版代码，来实现编解码。

他们具体要怎么做完全是看你了， 编码器可能需要保存正在被编码的的数据，容器需要给编码器提供正在被编码数据的各种信息。

实现自定义的 `Decoder` 也差不多。你需要在实现这个协议的同时实现容器协议。解码器保存序列化数据，容器跟他通信提供具体的类型信息。

### 结论

Swift 4 的 Codable 看起来是很强大，他们简化很多代码。对 JSON 来说， 声明对应的模型来遵守 Codable 协议，让后让编译器做剩下的事情，就完全够了。如果需要，你还可以实现这个协议的某一个部分来满足你自己的需求，甚至你还可以完全自己实现。

Encoder 和 Decoder 都很复杂，但是没办法。通过自己实现 Encoder 和 Decoder 来支持一个自定义数据格式需要做一些工作，但这基本上也都是做一些填空题。



[原文地址:Friday Q&A 2017-07-14: Swift.Codable](https://www.mikeash.com/pyblog/friday-qa-2017-07-14-swiftcodable.html)





