//
//  WAKeyValuePersistenceStore+Generics.swift
//  Pods
//
//  Created by YuAo on 5/22/15.
//
//

import Foundation

extension WAKeyValuePersistenceStore {
    public func objectForKey<ValueType>(aKey: String, valueType: ValueType.Type) -> ValueType? {
        if let value = self.objectForKey(aKey) as? ValueType {
            return value
        } else {
            return nil
        }
    }
}

public class WAKeyValuePersistenceStoreTypedAccessor<ValueType> {
    public let store: WAKeyValuePersistenceStore
    
    public func setObject(object: ValueType?, forKey aKey: String) {
        self.store.setObject(object as? AnyObject, forKey: aKey)
    }
    
    public func objectForKey(aKey: String) -> ValueType? {
        return self.store.objectForKey(aKey, valueType: ValueType.self)
    }
    
    public init(store: WAKeyValuePersistenceStore) {
        self.store = store;
    }
    
    public subscript(key: String) -> ValueType? {
        get {
            return self.objectForKey(key)
        }
        set {
            self.setObject(newValue, forKey: key)
        }
    }
}