//
//  Model.swift
//  WizardRegistrationSwiftUI
//
//  Created by Dmitry Lobanov on 05/07/2019.
//  Copyright © 2019 Dmitry Lobanov. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class Validation {
    enum TheError : LocalizedError, CustomStringConvertible {
        case passwordsDoNotMatch(String, String)
        case passwordInBlackList(String, [String])
        case passwordDoNotReachLength(String, Int)
        case nameDoNotReachLength(String, Int)
        var description: String {
            switch self {
            case let .passwordsDoNotMatch(password, passwordAgain): return "Password <\(password)> do not match password again <\(passwordAgain)>."
            case let .passwordInBlackList(password, list): return "Password <\(password)> is in blacklist <\(list)>."
            case let .passwordDoNotReachLength(password, length): return "Password <\(password)> do not reach length <\(length)>"
            case let .nameDoNotReachLength(name, length): return "Name <\(name)> do not reach length <\(length)>"
            }
        }
        var errorDescription: String? {
            return self.description
        }
    }
    
    static func passwordsMatched(_ password: String, passwordAgain: String) -> Result<String, Error> {
        return password == passwordAgain ? .success(password) : .failure(TheError.passwordsDoNotMatch(password, passwordAgain))
    }
    
    static func blacklist() -> [String] {
        return ["qwerty"]
    }
    
    static func whitelistedPassword(_ password: String, list: [String] = blacklist()) -> Result<String, Error> {
        return list.contains(password) ? .failure(TheError.passwordInBlackList(password, list)) : .success(password)
    }
    
    static func passwordLength() -> Int {
        return 8
    }
    
    static func passwordIsLong(_ password: String, length: Int = passwordLength()) -> Result<String, Error> {
        return password.count >= length ? .success(password) : .failure(TheError.passwordDoNotReachLength(password, length))
    }
    
    static func nameLength() -> Int {
        return 5
    }
    
    static func nameIsLong(_ name: String, length: Int = nameLength()) -> Result<String, Error> {
        return name.count >= length ? .success(name) : .failure(TheError.nameDoNotReachLength(name, length))
    }
}

class Model {}

extension Model {
    class PureSwiftUI : BindableObject {
        var name: String {didSet {didChange.send()}}
        var password: String {didSet {didChange.send()}}
        var passwordAgain: String {didSet {didChange.send()}}
        var didChange = PassthroughSubject<Void, Never>()

//        var publisher = PassthroughSubject<Result<PureSwiftUI, Error>, Never>()

        init() {
            self.name = ""
            self.password = ""
            self.passwordAgain = ""
        }
    }
}

extension Model.PureSwiftUI {
    func validatedData() -> Result<(String, String), Error> {
        let validPassword = Validation.passwordIsLong(password)
            .flatMap{Validation.whitelistedPassword($0)}
            .flatMap{Validation.passwordsMatched($0, passwordAgain: passwordAgain)}
        let validName = Validation.nameIsLong(name)
        return validName.flatMap { first in
            return validPassword.flatMap { second in
                .success((first, second))
            }
        }
    }
    var error: Error? {
        let validatedData = self.validatedData()
        switch validatedData {
        case let .failure(error):
            print("Form is invalid: \(error)")
            return error
        case let .success((name, password)):
            print("name <\(name)> and password <\(password)> are ok!")
            return nil
        }
    }
    var canAcceptData: Bool {
        return self.error == nil
    }
}

extension Model {
    class SwiftUIWithPublishers : BindableObject {
        
        @Published var name: String = ""
        @Published var password: String = ""
        @Published var passwordAgain: String = ""
        
        var didChange: AnyPublisher<Result<(String, String), Error>, Never> = Publishers.Empty().eraseToAnyPublisher()
        
        init() {
            self.name = ""
            self.password = ""
            self.passwordAgain = ""
            
            // we should provide values to all derived publishers BEFORE we can use self.publishers :3
            // for that we use .Empty publisher.
            // Yes, we can't use any other F[_] Optional type (! or ?)
            let publisher = Publishers.CombineLatest3($name, $password, $passwordAgain).map{ (name, password, passwordAgain) -> Result<(String, String), Error> in
                let validPassword = Validation.passwordIsLong(password)
                    .flatMap{Validation.whitelistedPassword($0)}
                    .flatMap{Validation.passwordsMatched($0, passwordAgain: passwordAgain)}
                let validName = Validation.nameIsLong(name)
                return validName.flatMap { name in
                    validPassword.flatMap { password in
                        return .success((name, password))
                    }
                }
            }.eraseToAnyPublisher()
            self.didChange = publisher
        }
    }
}
