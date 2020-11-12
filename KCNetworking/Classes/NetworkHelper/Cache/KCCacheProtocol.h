//
//  KCCacheProtocol.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//


/**
 *  给出缓存读写策略的接口,和一个默认实现(KCCacheCenter)
 *  可视业务需求选择自己的缓存读写方案,设计一个实现本接口的类即可
 */

@class KCRequest;

@protocol KCCacheProtocol <NSObject>

@required

- (id)getCacheForRequest:(KCRequest *)request;

- (id)getRevalidatingCacheForRequest:(KCRequest *)request;

- (void)cacheReponse:(id)response ForRequest:(KCRequest *)request;

- (void)cleanCacheForRequrst:(KCRequest *)request;

@optional

- (void)cleanAllCaches;

- (void)cleanAllCachesWithBlock:(void(^)(void))block;

- (void)cleanAllCachesWithProgressBlock:(void(^)(int removedCount, int totalCount))progress
                                 endBlock:(void(^)(BOOL error))end;

@end
