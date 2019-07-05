//
//  ContentView.swift
//  WizardRegistrationSwiftUI
//
//  Created by Dmitry Lobanov on 05/07/2019.
//  Copyright © 2019 Dmitry Lobanov. All rights reserved.
//

import SwiftUI

extension RegistrationView {
    struct NameView : View {
        @Binding var model: String
        var body: some View {
            TextField($model, placeholder: Text("Wizard name"), onEditingChanged: { (changed) in
                
            }) {
                
            }
        }
    }
}

extension RegistrationView {
    struct PasswordView : View {
        @Binding var model: String
        var body: some View {
            TextField($model, placeholder: Text("Password"), onEditingChanged: { (changed) in
                
            }) {
                
            }
        }
    }
}

extension RegistrationView {
    struct PasswordAgainView : View {
        @Binding var model: String
        var body: some View {
            TextField($model, placeholder: Text("Password again"), onEditingChanged: { (changed) in
                
            }) {
                
            }
        }
    }
}

extension RegistrationView {
    struct AcceptButtonView : View {
        var model: Bool
        var body: some View {
            Button(action: {
                
            }) {
                return Text("Create account")
            }.disabled(!model)
        }
    }
}

extension RegistrationView {
    struct ErrorView : View {
        var model: Error?
        func exists() -> Bool {
            return self.model != nil
        }
        func errorDescription() -> String {
            return self.model?.localizedDescription ?? "No error"
        }
        var body: some View {        Text(self.errorDescription()).multilineTextAlignment(.center).lineLimit(nil).foregroundColor(self.exists() ? .red : .green)
        }
    }
}

struct RegistrationView {}

struct PureSwiftUIView : View {
    @Binding var model: Model.PureSwiftUI
    var body: some View {
        Form {
            
            Section {
                RegistrationView.NameView(model: $model.name)
                RegistrationView.PasswordView(model: $model.password)
                RegistrationView.PasswordAgainView(model: $model.passwordAgain)
            }
            
            // we don't need "binding" here, cause it is "readonly" data and all redrawing will happen only by affecting model "readwrite" fields.
            
            RegistrationView.AcceptButtonView(model: model.canAcceptData)
            
            Section {
                RegistrationView.ErrorView(model: model.error)
            }
        }.colorInvert()
    }
}

struct SwiftUIWithPublishers : View {
    @Binding var model: Model.SwiftUIWithPublishers
    @State var name: String = ""
    @State var password: String = ""
    @State var passwordAgain: String = ""
    @State var error: Error?
    var canAcceptData: Bool {
        return self.error == nil
    }
    var body : some View {
        Form {
            
            Section {
                RegistrationView.NameView(model: Binding(getValue: {
                    return self.name
                }, setValue: { (newValue) in
                    self.name = newValue
                    self.model.name = newValue
                }))
                RegistrationView.PasswordView(model: Binding(getValue: {
                    return self.password
                }, setValue: { (newValue) in
                    self.password = newValue
                    self.model.password = newValue
                }))
                RegistrationView.PasswordAgainView(model: Binding(getValue: {
                    return self.passwordAgain
                }, setValue: { (newValue) in
                    self.passwordAgain = newValue
                    self.model.passwordAgain = newValue
                }))
            }
            
            RegistrationView.AcceptButtonView(model: self.canAcceptData)

            Section {
                RegistrationView.ErrorView(model: self.error)
            }
        }.colorInvert().onReceive(self.model.didChange) { value in
            switch value {
            case let .failure(error): self.error = error
            case let .success((name, password)): // do other stuff
                self.error = nil                
            }
        }
    }
}

struct ContentView : View {
    enum ContentViewType {
        case pureSwiftUI
        case swiftUIWithPublishers
    }
    @State var model: Model.PureSwiftUI
    @State var model2: Model.SwiftUIWithPublishers
    var state : ContentViewType = .pureSwiftUI
    var body: some View {
//        PureSwiftUIView(model: $model).hidden()
        SwiftUIWithPublishers(model: $model2)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
//        ContentView()
        Text("Abc")
    }
}
#endif
