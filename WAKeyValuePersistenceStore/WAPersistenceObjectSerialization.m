//
//  WAPersistenceObjectSerialization.m
//  Pods
//
//  Created by YuAo on 4/11/15.
//
//

#import <WAKeyValuePersistenceStore/WAPersistenceObjectSerialization.h>

@interface WAPersistenceObjectSerializer ()

@property (nonatomic,copy) id (^deserializationBlock)(NSData *data);

@property (nonatomic,copy) NSData * (^serizalizationBlock)(id object);

@end

@implementation WAPersistenceObjectSerializer

- (instancetype)initWithSerizalizationBlock:(NSData * (^)(id object))serizalizationBlock deserializationBlock:(id (^)(NSData *data))deserializationBlock {
    if (self = [super init]) {
        self.serizalizationBlock = serizalizationBlock;
        self.deserializationBlock = deserializationBlock;
    }
    return self;
}

- (NSData *)dataForCachingObject:(id)object {
    if (self.serizalizationBlock) {
        return self.serizalizationBlock(object);
    }
    return object;
}

- (id)objectWithCachedData:(NSData *)data {
    if (self.deserializationBlock) {
        return self.deserializationBlock(data);
    }
    return data;
}

+ (instancetype)passthroughSerializer {
    WAPersistenceObjectSerializer *serializer = [[WAPersistenceObjectSerializer alloc] initWithSerizalizationBlock:nil deserializationBlock:nil];
    return serializer;
}

+ (instancetype)keyedArchiveSerializer {
    WAPersistenceObjectSerializer *serializer = [[WAPersistenceObjectSerializer alloc] initWithSerizalizationBlock:^NSData *(id object) {
        return [NSKeyedArchiver archivedDataWithRootObject:object];
    } deserializationBlock:^id(NSData *data) {
        if (data.length) {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        } else {
            return nil;
        }
    }];
    return serializer;
}

@end
