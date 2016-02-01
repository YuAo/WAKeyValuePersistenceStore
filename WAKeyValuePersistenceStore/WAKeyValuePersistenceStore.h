//
//  WAKeyValuePersistenceStore.h
//  Pods
//
//  Created by YuAo on 4/11/15.
//
//

#import <Foundation/Foundation.h>
#import "WAPersistenceObjectSerialization.h"

NS_ASSUME_NONNULL_BEGIN

@interface WAKeyValuePersistenceStore : NSObject

@property (readonly,copy) NSString *name;

@property (readonly) NSSearchPathDirectory directory;

@property (readonly,strong) id<WAPersistenceObjectSerialization> objectSerializer;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDirectory:(NSSearchPathDirectory)directory
                             name:(NSString *)name
                 objectSerializer:(id<WAPersistenceObjectSerialization>)objectSerializer NS_DESIGNATED_INITIALIZER;

@property (readonly) NSString *path;

- (NSURL *)fileURLForKey:(NSString *)key;

- (void)setObject:(nullable id)object forKey:(NSString *)aKey;

- (nullable id)objectForKey:(NSString *)aKey;

- (void)removeObjectForKey:(NSString *)aKey;

- (void)removeAllObjects;

- (void)removeObjectsByLastAccessDate:(NSDate *)date
                 progressChangedBlock:(nullable void (^)(NSUInteger numberOfFilesProcessed, NSUInteger totalNumberOfFilesToProcess, BOOL *stop))progressChangedBlock;

@property (readonly) NSUInteger currentDiskUsage;

@property (readonly) NSUInteger objectCount;

@end

@interface WAKeyValuePersistenceStore (KeyedSubscript)

- (nullable id)objectForKeyedSubscript:(NSString *)key;

- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
