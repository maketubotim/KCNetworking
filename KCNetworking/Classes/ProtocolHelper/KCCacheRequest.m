//
//  KCCacheRequest.m
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import "KCCacheRequest.h"
#import "KCResponseError.h"
#import "KCCacheCenter.h"
#import "KCRequestDispatchCenter.h"
#import "KCRequest+Private.h"

@interface KCCacheRequest ()

@end

@implementation KCCacheRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        self.service = [KCCacheCenter defultCenter];
    }
    return self;
}

- (void)start {
    
    do {
        //发起网络请求
        if (self.requestCachePolicy == KCRequestReloadRemoteDataIgnoringCacheData
            || self.requestCachePolicy == KCRequestReloadRemoteDataElseReturnCacheData) {
            break;
        }
        KCResponse *response = [self readCache];
        if (response) {
            //执行回调
            __weak __typeof(self) weakSelf = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf SuccessWithCacheResult:response];
            });
        
            if (self.requestCachePolicy == KCRequestReturnCacheDataElseReloadRemoteData) {
                //结束请求
                return;
            }
        }
        //KCRequestReturnCacheDataThenReloadRemoteData
        //KCRequestReturnCacheDataElseReloadRemoteData
        //发起网络请求
    } while (0);

    [super start];
}

/**
 *  重写网络请求的回调方法,写入缓存数据
 */
- (void)successWithResult:(id)result {
    if (self.dataCachePolicy == KCCachePolicyRawData) {
        [self.service cacheReponse:self.response ForRequest:self];
    } else if (self.dataCachePolicy == KCCachePolicyModel) {
        [self.service cacheReponse:result ForRequest:self];
    }
    [super successWithResult:result];
}

- (void)failWithError:(KCResponseError *)error {
    
    if (error.code == kCCResponseErrorCodeBusinessError) {
        //业务逻辑错误,清理缓存
        [self.service cleanCacheForRequrst:self];
    } else if (error.code == kCCResponseErrorCodeUserCancel) {
        //用户主动取消请求,不处理缓存
    } else {
        //其他错误(系统错误)
        if (self.requestCachePolicy == KCRequestReloadRemoteDataElseReturnCacheData) {
            KCResponse *response = [self readCache];
            if (response) {
                [self SuccessWithCacheResult:response];
                return;
            }
        }
    }

    [super failWithError:error];
}

#pragma mark - Tools

/**
 *  通过读取缓存数据回调
 */
- (void)SuccessWithCacheResult:(id)result {
    
    [[KCRequestDispatchCenter defaultCenter] resolveRequest:self];
    
    [super successWithResult:result];
}

/**
 *  读取缓存
 */
- (id)readCache {
    if (self.returnCachePolicy == KCReturnCacheDataByFireTime) {
        return [self.service getCacheForRequest:self];
    } else if (self.returnCachePolicy == KCReloadRevalidatingCacheData) {
        return [self.service getRevalidatingCacheForRequest:self];
    }
    return nil;
}

#pragma mark - Setter

- (void)setRequestCachePolicy:(KCRequestCachePolicy)requestCachePolicy {
    //请求发出后,不得再修改请求策略
    if (self.status == KCRequestStatusRunning) {
        KCLogError(@"[%@ >>]Can not set request cache policy while request is running.",NSStringFromClass(self.class));
        return;
    }
    if (requestCachePolicy != _requestCachePolicy) {
        _requestCachePolicy = requestCachePolicy;
    }
}

- (void)setDataCachePolicy:(KCDataCachePolicy)dataCachePolicy {
    //元数据发起的请求,缓存策略过滤为KCCachePolicyRawData
    if (self.respSerializerType == KCResponseSerializerTypeRawData) {
        dataCachePolicy = KCCachePolicyRawData;
    }
    if (_dataCachePolicy != dataCachePolicy) {
        _dataCachePolicy = dataCachePolicy;
    }
}

- (void)setRespSerializerType:(KCResponseSerializerType)respSerializerType {
    if (_respSerializerType != respSerializerType) {
        _respSerializerType = respSerializerType;
    }
    if (respSerializerType == KCResponseSerializerTypeRawData) {
        _dataCachePolicy = KCCachePolicyRawData;
    }
}


@end
