//
//  Observation.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017 Xander Deng - https://github.com/ddddxxx/LyricsX
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import AppKit
import GenericID

private class NotificationObservationToken {
    
    var center: NotificationCenter?
    var token: NSObjectProtocol?
    
    init(center: NotificationCenter, token: NSObjectProtocol) {
        self.center = center
        self.token = token
    }
    
    func invalidate() {
        if let center = center, let token = token {
            center.removeObserver(token)
        }
        center = nil
        token = nil
    }
    
    deinit {
        invalidate()
    }
}

extension NSObject {
    
    private static var autoDestructionTokens: Void?
    
    // using [Any] causes unexpected destruction, use NSMutableArray instead.
    private var autoDestruction: NSMutableArray {
        if let arr = objc_getAssociatedObject(self, &NSObject.autoDestructionTokens) as? NSMutableArray {
            return arr
        }
        let arr = NSMutableArray()
        objc_setAssociatedObject(self, &NSObject.autoDestructionTokens, arr, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return arr
    }
    
    func postNotification(center: NotificationCenter = .default,
                          name: NSNotification.Name,
                          userInfo: [String: Any] = [:]) {
        center.post(name: name, object: self, userInfo: userInfo)
    }
    
    func observeNotification(center: NotificationCenter = .default,
                             name: NSNotification.Name,
                             object: Any? = nil,
                             queue: OperationQueue? = nil,
                             using: @escaping (Notification) -> Void) {
        let token = center.addObserver(forName: name, object: object, queue: queue, using: using)
        autoDestruction.add(NotificationObservationToken(center: center, token: token))
    }
    
    func observeObject<Target: NSObject, Value>(_ object: Target,
                                                keyPath: KeyPath<Target, Value>,
                                                options: NSKeyValueObservingOptions,
                                                changeHandler: @escaping (NSObject, NSKeyValueObservedChange<Value>) -> Void) {
        let token = object.observe(keyPath, options: options, changeHandler: changeHandler)
        autoDestruction.add(token)
    }
    
    func observeDefaults<T>(_ defaults: UserDefaults = .standard,
                            key: UserDefaults.DefaultsKeys.Key<T>,
                            options: NSKeyValueObservingOptions = [],
                            changeHandler: @escaping (UserDefaults, UserDefaults.DefaultsObservedChange<T>) -> Void) {
        let token = defaults.observe(key, options: options, changeHandler: changeHandler)
        autoDestruction.add(token)
    }
    
    func observeDefaults<T: DefaultConstructible>(_ defaults: UserDefaults = .standard,
                                                    key: UserDefaults.DefaultsKeys.Key<T>,
                                                    options: NSKeyValueObservingOptions = [],
                                                    changeHandler: @escaping (UserDefaults, UserDefaults.ConstructedDefaultsObservedChange<T>) -> Void) {
        let token = defaults.observe(key, options: options, changeHandler: changeHandler)
        autoDestruction.add(token)
    }
    
    func observeDefaults(_ defaults: UserDefaults = .standard,
                         keys: [UserDefaults.DefaultsKeys],
                         options: NSKeyValueObservingOptions = [],
                         changeHandler: @escaping () -> Void) {
        let token = defaults.observe(keys: keys, options: options, changeHandler: changeHandler)
        autoDestruction.add(token)
    }
}

/// MARK: Binding

protocol KeyPathBinding {}

extension NSObject {
    
    func bind(_ binding: NSBindingName,
              to observable: UserDefaults = .standard,
              withDefaultName defaultName: UserDefaults.DefaultsKeys,
              options: [NSBindingOption: Any] = [:]) {
        var options = options
        if defaultName.valueTransformer != nil {
            options[.valueTransformerName] = NSValueTransformerName.keyedUnarchiveFromDataTransformerName
        }
        bind(binding, to: observable, withKeyPath: defaultName.key, options: options)
    }
}

extension KeyPathBinding where Self: NSObject {
    
    func bind<Target, Value>(_ binding: KeyPath<Self, Value>,
                             to observable: Target,
                             withKeyPath keyPath: KeyPath<Target, Value>,
                             options: [NSBindingOption: Any] = [:]) {
        self.bind(NSBindingName(binding._kvcKeyPathString!), to: observable, withKeyPath: keyPath._kvcKeyPathString!, options: options)
    }
    
    func bind<Target, Value>(_ binding: KeyPath<Self, Value?>,
                             to observable: Target,
                             withKeyPath keyPath: KeyPath<Target, Value>,
                             options: [NSBindingOption: Any] = [:]) {
        self.bind(NSBindingName(binding._kvcKeyPathString!), to: observable, withKeyPath: keyPath._kvcKeyPathString!, options: options)
    }
    
    func bind<Value>(_ binding: KeyPath<Self, Value>,
                     to defaults: UserDefaults = .standard,
                     withDefaultName defaultName: UserDefaults.DefaultsKey<Value>,
                     options: [NSBindingOption: Any] = [:]) {
        self.bind(NSBindingName(binding._kvcKeyPathString!), to: defaults, withDefaultName: defaultName, options: options)
    }
    
    func bind<Value>(_ binding: KeyPath<Self, Value>,
                     to defaults: UserDefaults = .standard,
                     withUnmatchedDefaultName defaultName: UserDefaults.DefaultsKeys,
                     options: [NSBindingOption: Any] = [:]) {
        self.bind(NSBindingName(binding._kvcKeyPathString!), to: defaults, withDefaultName: defaultName, options: options)
    }
}

extension NSObject: KeyPathBinding {}
