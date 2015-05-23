//
//  WAKeyValuePersistenceStore.m
//  Pods
//
//  Created by YuAo on 4/11/15.
//
//

#import <WAKeyValuePersistenceStore/WAKeyValuePersistenceStore.h>
#import <CommonCrypto/CommonDigest.h>

static NSString * WAMD5HashForKey(NSString *key) {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    
    static const char HexEncodeChars[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
    char *resultData = malloc(CC_MD5_DIGEST_LENGTH * 2 + 1);
    
    for (uint index = 0; index < CC_MD5_DIGEST_LENGTH; index++) {
        resultData[index * 2] = HexEncodeChars[(r[index] >> 4)];
        resultData[index * 2 + 1] = HexEncodeChars[(r[index] % 0x10)];
    }
    resultData[CC_MD5_DIGEST_LENGTH * 2] = 0;
    
    NSString *hash = @(resultData);
    
    if (resultData) {
        free(resultData);
    }
    
    return hash;
}


@interface WAKeyValuePersistenceStore ()

@property (nonatomic,copy) NSString *name;

@property (nonatomic) NSSearchPathDirectory directory;

@property (nonatomic,copy) NSString *cacheDirectoryPath;

@property (nonatomic,strong) NSOperationQueue *cacheRemovingQueue;

@property (nonatomic,strong) id<WAPersistenceObjectSerialization> objectSerializer;

@end

@implementation WAKeyValuePersistenceStore

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ is not the designated initializer for instances of %@.", NSStringFromSelector(_cmd), NSStringFromClass([self class])] userInfo:nil];
    return nil;
}

#pragma clang diagnostic pop

- (instancetype)initWithDirectory:(NSSearchPathDirectory)directory name:(NSString *)name objectSerializer:(id<WAPersistenceObjectSerialization>)objectSerializer {
    NSParameterAssert(directory);
    NSParameterAssert(name);
    NSParameterAssert(objectSerializer);
    if (self = [super init]) {
        self.directory = directory;
        self.name = name;
        self.objectSerializer = objectSerializer;
        self.cacheRemovingQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (NSString *)path {
    return self.cacheDirectoryPath;
}

- (NSString *)cacheDirectoryPath {
    if (!_cacheDirectoryPath) {
        @synchronized(self){
            if (!_cacheDirectoryPath) {
                NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(self.directory, NSUserDomainMask, YES).firstObject;
                _cacheDirectoryPath = [cachesDirectory stringByAppendingPathComponent:[@"com.imyuao.WAKeyValuePersistenceStore-" stringByAppendingPathComponent:self.name]];
                
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                BOOL isDirectory = NO;
                if (![fileManager fileExistsAtPath:_cacheDirectoryPath isDirectory:&isDirectory] || !isDirectory) {
                    [fileManager removeItemAtPath:_cacheDirectoryPath error:nil];
                    [fileManager createDirectoryAtPath:_cacheDirectoryPath withIntermediateDirectories:YES attributes:@{NSFileProtectionKey: NSFileProtectionNone} error:nil];
                }
            }
        }
    }
    return _cacheDirectoryPath;
}

- (NSURL *)fileURLForKey:(NSString *)key {
    NSParameterAssert(key);
    NSString *fileName = WAMD5HashForKey(key);
    if (key.pathExtension.length) {
        fileName = [fileName stringByAppendingPathExtension:[key pathExtension]];
    }
    return [NSURL fileURLWithPath:[self.cacheDirectoryPath stringByAppendingPathComponent:fileName]];
}

- (void)writeObject:(id)object toFile:(NSString *)path {
    NSData *data = [self.objectSerializer dataForCachingObject:object];
    NSError *error;
    [data writeToFile:path options:NSDataWritingFileProtectionNone|NSDataWritingAtomic error:&error];
    if (error) { NSLog(@"%@ : ERROR writting object to file. \n [obj]:%@ \n [path]: %@ \n [Error]: %@",self,object,path,error); }
}

- (id)objectFromFile:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [self.objectSerializer objectWithCachedData:data];
}

- (void)setObject:(id)object forKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    if (!object) {
        [self removeObjectForKey:aKey];
    } else {
        [self writeObject:object toFile:[self fileURLForKey:aKey].path];
    }
}

- (id)objectForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    return [self objectFromFile:[self fileURLForKey:aKey].path];
}

- (void)removeObjectForKey:(NSString *)aKey {
    NSParameterAssert(aKey);
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtURL:[self fileURLForKey:aKey] error:nil];
}

- (void)removeAllObjects {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtPath:self.cacheDirectoryPath error:nil];
    self.cacheDirectoryPath = nil;
}

- (void)removeObjectsByLastAccessDate:(NSDate *)date progressChangedBlock:(void (^)(NSUInteger, NSUInteger, BOOL *))progressChangedBlock {
    NSString *cacheDirectory = self.cacheDirectoryPath;
    [self.cacheRemovingQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        BOOL hasFiles = NO;
        BOOL isDirectory = NO;
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSUInteger processedFilesCount = 0;
        if ([fileManager fileExistsAtPath:cacheDirectory isDirectory:&isDirectory]) {
            if (isDirectory) {
                NSArray *contents = [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:cacheDirectory] includingPropertiesForKeys:@[NSURLNameKey,NSURLContentAccessDateKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
                for(NSURL *URL in contents){
                    NSString *cacheFilePath = URL.path;
                    NSDate *itemAccessDate;
                    [URL getResourceValue:&itemAccessDate forKey:NSURLContentAccessDateKey error:nil];
                    if(itemAccessDate && ![itemAccessDate isKindOfClass:[NSNull class]]){
                        if([itemAccessDate earlierDate:date] == itemAccessDate){
                            [fileManager removeItemAtPath:cacheFilePath error:nil];
                        }
                    }
                    processedFilesCount++;
                    hasFiles = YES;
                    if (progressChangedBlock) {
                        __block BOOL stop = NO;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            progressChangedBlock(processedFilesCount,contents.count,&stop);
                        });
                        if (stop) break;
                    }
                }
            }
        }
        if (!hasFiles) {
            if (progressChangedBlock) {
                __block BOOL stop = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressChangedBlock(0,0,&stop);
                });
            }
        }
    }]];
}

- (NSUInteger)currentDiskUsage {
    NSUInteger size = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:self.cacheDirectoryPath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [self.cacheDirectoryPath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

- (NSUInteger)objectCount {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    return [fileManager contentsOfDirectoryAtPath:self.cacheDirectoryPath error:nil].count;
}

@end

@implementation WAKeyValuePersistenceStore (KeyedSubscript)

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    return [self setObject:obj forKey:key];
}

@end
