# WizardRegistrationSwiftUI
This repository is inspired by Apple WWDC "Combine in Practice" app.

## Purpose

This project demonstrates different approaches of using SwiftUI and Combine frameworks.
We can divide approaches into several groups.

1. Pure SwiftUI.
2. SwiftUI with Publishers.

### Pure SwiftUI.

In this approach we only use `didSet` hooks on our data to react on UI updates. It is fairly limited, but can provide basic building blocks to achieve simple apps with single source of truth.

#### Details

```swift 
//MARK: Model
class Model : BindableObject {
  var name: String {didSet {didChange.send()}}
  var password: String {didSet {didChange.send()}}
  var passwordAgain: String {didSet {didChange.send()}}
}

//MARK: View
struct SomeView : View {
  @Binding var model: Model.PureSwiftUI
  var body : some View {
    SomeView.Child(model: $model.childValue)
  }
}
```

### SwiftUI with Publishers.

On the other hand, we can combine `@State` property wrapper on view with `@Published` property wrapper on model. It is required to provide achieve exclusive access on propetries that view utilize.

#### Details

```swift
//MARK: Model
class Model : BindableObject {
  @Published var name: String = ""
  @Published var password: String = ""
  @Published var passwordAgain: String = ""
  
  // We must set publisher to any value, because we need to combine publishers in `init` 
  var didChange: AnyPublisher<Result<(String, String), Error>, Never> = Publishers.Empty().eraseToAnyPublisher()
  
  init() {
    self.name = ""
    self.password = ""
    self.passwordAgain = ""
    
    self.didChange = `...`
  }
}

//MARK: View
struct SomeView : View {
  @Binding var model: Model
  @State var name: String = ""
  @State var password: String = ""
  @State var passwordAgain: String = ""
  @State var error: Error?
  
  var body : some View {
    Form {
      SomeView.Child(model: Binding(
        getValue: { return self.name }
        setValue: { value in 
          self.name = value
          self.model.name = value
        }
      ))
    }.onReceive(self.model.didChange) { value in
      // process value
  }
}
```
