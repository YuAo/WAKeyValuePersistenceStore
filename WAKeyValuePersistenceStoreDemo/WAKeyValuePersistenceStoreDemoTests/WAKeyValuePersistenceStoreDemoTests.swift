//
//  WAKeyValuePersistenceStoreDemoTests.swift
//  WAKeyValuePersistenceStoreDemoTests
//
//  Created by YuAo on 5/22/15.
//  Copyright (c) 2015 YuAo. All rights reserved.
//

import UIKit
import XCTest
import WAKeyValuePersistenceStore

class WAKeyValuePersistenceStoreDemoTests: XCTestCase {
    
    var store: WAKeyValuePersistenceStore!
    
    var typedStore: WAKeyValuePersistenceStoreTypedAccessor<[Int]>!

    override func setUp() {
        super.setUp()
        self.store = WAKeyValuePersistenceStore(directory: NSSearchPathDirectory.CachesDirectory, name: "Store", objectSerializer: WAPersistenceObjectSerializer.keyedArchiveSerializer())
        self.typedStore = WAKeyValuePersistenceStoreTypedAccessor<[Int]>(store: self.store)
    }
    
    override func tearDown() {
        super.tearDown()
        self.store = nil
        self.typedStore = nil
    }
    
    func testStore() {
        let testData = NSProcessInfo.processInfo().globallyUniqueString
        self.store["data"] = testData
        XCTAssert(self.store["data"] as! String == testData)
    }
    
    func testStoreWithType() {
        let testData = [0,1,2,3,4,5,6]
        self.typedStore["data"] = testData
        XCTAssert((self.typedStore["data"]!) == testData)
    }
    
    func testRemove() {
        let testData = [0,1,2,3,4,5,6]
        self.typedStore["data"] = testData
        XCTAssert(self.typedStore["data"]! == testData)
        self.typedStore["data"] = nil
        XCTAssert(self.typedStore["data"] == nil)
    }
    
    func testRemoveAll() {
        let testData = NSProcessInfo.processInfo().globallyUniqueString
        self.store["data"] = testData
        XCTAssert(self.store["data"] as! String == testData)
        self.store.removeAllObjects()
        XCTAssert(self.store["data"] == nil)
    }
    
    func testPerformanceExample() {
        var testData = [Int]()
        for i in 0..<1024 {
            testData.append(i)
        }
        let store = WAKeyValuePersistenceStore(directory: NSSearchPathDirectory.CachesDirectory, name: "PerformanceTest", objectSerializer: WAPersistenceObjectSerializer.keyedArchiveSerializer())
        self.measureBlock() {
            store.setObject(testData, forKey: "data")
        }
    }
    
}
