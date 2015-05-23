# WAKeyValuePersistenceStore

`WAKeyValuePersistenceStore` is a simple, file based Key-Value persistence store. 

##Usage

__Create a `WAKeyValuePersistenceStore` is simple:__

    self.store = WAKeyValuePersistenceStore(
    directory: NSSearchPathDirectory.CachesDirectory,
    name: "Store",
    objectSerializer: WAPersistenceObjectSerializer.keyedArchiveSerializer())

`directory` is where you want to store the data files. (cache directory, document directory, application support directory... etc.)

`name` is the store's name. Stores with the same name share the same data storage.

`objectSerializer` controls how object will be serialized.

For instance, `WAPersistenceObjectSerializer.keyedArchiveSerializer()` uses `NSKeyedArchiver` and `NSKeyedUnarchiver` to serialize objects. 

`WAPersistenceObjectSerializer.passthroughSerializer()` is used to directly write the object to the disk. You may want to use this object serializer to store `NSData` objects.

You can also created custom object serializers by conform to the `WAPersistenceObjectSerialization` protocol.

__Use subscript to store or retrive objects:__

 	var testData = NSProcessInfo.processInfo().globallyUniqueString
    self.store["data"] = testData
    //.....
    var string = self.store["data"]
    
__Manage the store or get the store's information__
	
	//WAKeyValuePersistenceStore

	//Get the store's path on disk.
	var path: String { get }
    
    //Get the preferred file URL for a key.
    func fileURLForKey(key: String) -> NSURL
    
    //Remove objects
    func removeAllObjects()
    
    func removeObjectsByLastAccessDate(date: NSDate, progressChangedBlock: ((UInt, UInt, UnsafeMutablePointer<ObjCBool>) -> Void)?)
    
    //Store information
    var currentDiskUsage: UInt { get }
    
    var objectCount: UInt { get }
    
__Generics with Swift__

There's a swift extension for `WAKeyValuePersistenceStore`. You may specify the object type when retriving object from the store.

	extension WAKeyValuePersistenceStore {
	    public func objectForKey<ValueType>(aKey: String, valueType: ValueType.Type) -> ValueType? {
	        if let value = self.objectForKey(aKey) as? ValueType {
	            return value
	        } else {
	            return nil
	        }
	    }
	}

Also there's a `WAKeyValuePersistenceStoreTypedAccessor<ValueType>` class. You may use it to access a store using generics.

For example:

	self.typedStore = WAKeyValuePersistenceStoreTypedAccessor<[Int]>(store: self.store)
	var testData = [0,1,2,3,4,5,6]
    self.typedStore["data"] = testData
    //.....
    var array = self.typedStore["data"] //array is [Int]
    
##Install

Either clone the repo and manually add the files in `WAKeyValuePersistenceStore` directory

__Or If you use Cocoapods:__

Add the following to your Podfile

	pod 'WAKeyValuePersistenceStore'
	
If you use Swift, you can enable generics support by adding
	
	use_frameworks!
	
	pod 'WAKeyValuePersistenceStore/Generics'
	    
##Requirements

* Automatic Reference Counting (ARC)
* iOS 7.0+
* Xcode 6.3+

##Contributing

If you find a bug and know exactly how to fix it, please open a pull request. If you can't make the change yourself, please open an issue after making sure that one isn't already logged.