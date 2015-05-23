//
//  ViewController.swift
//  WAKeyValuePersistenceStoreDemo
//
//  Created by YuAo on 5/22/15.
//  Copyright (c) 2015 YuAo. All rights reserved.
//

import UIKit
import WAKeyValuePersistenceStore

private let ViewControllerTextCacheKey = "ViewControllerTextCacheKey"

class ViewController: UIViewController {
    
    private let cacheStore = WAKeyValuePersistenceStore(directory: NSSearchPathDirectory.CachesDirectory, name: "CacheStore", objectSerializer: WAPersistenceObjectSerializer.keyedArchiveSerializer())
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.text = self.cacheStore[ViewControllerTextCacheKey] as? String
    }

    @IBAction private func textFieldChanged(sender: UITextField) {
        self.cacheStore[ViewControllerTextCacheKey] = sender.text
        self.label.text = "Saved! See WAKeyValuePersistenceStoreDemoTests for more usage."
    }
    
}

