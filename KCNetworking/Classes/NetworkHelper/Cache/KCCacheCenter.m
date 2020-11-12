//
//  KCCacheCenter.m
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import "KCCacheCenter.h"
#import "KCRequest.h"
#import "YYCache.h"
#import <CommonCrypto/CommonCrypto.h>
#import "KCRequestConstants.h"

@interface KCCacheCenter()

@property (nonatomic, strong) YYCache *cache;

@end

@implementation KCCacheCenter

/// String's md5 hash.
static NSString *_CCNSStringMD5(NSString *string) {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = [[YYCache alloc] initWithName:@"KCCacheCenter"];
        //默认一周过期时间
        self.cache.diskCache.ageLimit = 1*7*24*60*60;
        
    }
    return self;
}

+ (id)defultCenter {
    static KCCacheCenter *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[KCCacheCenter alloc] init];
    });
    return service;
}

- (void)cacheReponse:(id)response ForRequest:(KCRequest *)request {
    NSString *key = _CCNSStringMD5(_S(@"%@%@",request.requestUrl,[request.requestArgument description]));
    [self.cache setObject:response forKey:key];
}

- (void)cleanCacheForRequrst:(KCRequest *)request {
    NSString *key = _CCNSStringMD5(_S(@"%@%@",request.requestUrl,[request.requestArgument description]));
    [self.cache removeObjectForKey:key];
}

- (id)getCacheForRequest:(KCRequest *)request{
    NSString *key = _CCNSStringMD5(_S(@"%@%@",request.requestUrl,[request.requestArgument description]));
    return (KCResponse *)[self.cache objectForKey:key];
}

- (id)getRevalidatingCacheForRequest:(KCRequest *)request {
    /**
     *  YYCache中实现了LRU淘汰算法,理论上不会取到过期数据
     *  若自己实现缓存服务,请自行设计此处逻辑
     *  读取缓存逻辑参考 KCReturnCachePolicy
     */
    return [self getCacheForRequest:request];
}

- (void)cleanAllCaches {
    [self.cache removeAllObjects];
}

- (void)cleanAllCachesWithBlock:(void(^)(void))block {
    [self.cache removeAllObjectsWithBlock:block];
}

- (void)cleanAllCachesWithProgressBlock:(void(^)(int removedCount, int totalCount))progress
                                 endBlock:(void(^)(BOOL error))end {
    [self.cache removeAllObjectsWithProgressBlock:progress endBlock:end];
}

@end
