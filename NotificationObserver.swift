//
//  NotificationObserver.swift
//  HiveOnline
//
//  Created by Andrey Bogushev on 8/31/17.
//  Copyright © 2017 Seductive. All rights reserved.
//

import Foundation

fileprivate var observersCache: [String: NSObjectProtocol] = [:]

extension NotificationCenter {
    static let defaultValueKey = "NotificationObserverValueKey"
    
    static func postNotification<T>(name: String, notification: T) {
        let name = Notification.Name(name)
        let userInfo = [NotificationCenter.defaultValueKey: notification]
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
}

protocol NotificationObserver {}

extension NotificationObserver {
    
    func register<T>(for name: String, object: AnyObject? = nil, handler: @escaping (T) -> Void) -> NSObjectProtocol {
        let observer = NotificationCenter.default.addObserver(forName: Notification.Name(name), object: object, queue: nil) { note in
            if let obj = note.userInfo?[NotificationCenter.defaultValueKey] as? T {
                handler(obj)
            }
        }
        
        registerObserver(observer, forName: name, object: object)
        return observer
    }
    
    func unregister(from name: String, object: AnyObject? = nil) {
        let key = keyFor(name: name, object: object)
        print("Unregister from notifications - \(key)")
        
        if object != nil, let observer = observersCache.removeValue(forKey: key) {
            NotificationCenter.default.removeObserver(observer)
        } else {
            unregisterFromName(withKey: key)
        }
    }
    
    private func unregisterFromName(withKey key: String) {
        let nc = NotificationCenter.default
        
        observersCache.keys
            .filter { $0.hasPrefix(key) }
            .forEach {
                if let observer = observersCache.removeValue(forKey: $0) {
                    nc.removeObserver(observer)
                }
        }
    }
    
    private func registerObserver(_ observer: NSObjectProtocol, forName name: String, object: AnyObject? = nil) {
        let key = keyFor(name: name, object: object)
        print("Register for notifications - \(key)")
        
        if let oldObserver = observersCache[key] {
            NotificationCenter.default.removeObserver(oldObserver)
        }
        observersCache[key] = observer
    }
    
    private func keyFor(name: String, object: AnyObject? = nil) -> String {
        let myPointer = unsafeBitCast(self, to: Int.self)
        
        if let obj = object {
            let objectPointer = unsafeBitCast(obj, to: Int.self)
            return name + String(myPointer) + String(objectPointer)
        }
        return name + String(myPointer)
    }
}


//MARK: - NameableNotification

protocol NameableNotification {
    static var name: String { get }
}

extension NotificationCenter {
    static func postNotification<T: NameableNotification>(_ notification: T) {
        NotificationCenter.postNotification(name: T.name, notification: notification)
    }
}
