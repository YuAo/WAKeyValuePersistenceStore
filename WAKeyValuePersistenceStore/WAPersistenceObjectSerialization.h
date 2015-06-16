//
//  WAPersistenceObjectSerialization.h
//  Pods
//
//  Created by YuAo on 4/11/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WAPersistenceObjectSerialization <NSObject>

- (nullable NSData *)dataForCachingObject:(id)object;

- (nullable id)objectWithCachedData:(NSData *)data;

@end

@interface WAPersistenceObjectSerializer : NSObject <WAPersistenceObjectSerialization>

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)passthroughSerializer;

+ (instancetype)keyedArchiveSerializer;

@end

NS_ASSUME_NONNULL_END
