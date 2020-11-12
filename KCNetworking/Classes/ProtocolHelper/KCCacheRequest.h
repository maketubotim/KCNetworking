//
//  KCCacheRequest.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import "KCRequest.h"
@protocol KCCacheProtocol;

/**
 *  缓存相关需求的网络请求可继承此类
 */
@interface KCCacheRequest : KCRequest

/**
 *  网络请求策略
 */
@property (nonatomic, assign) KCRequestCachePolicy requestCachePolicy;

/**
 *  缓存读取策略
 */
@property (nonatomic, assign) KCReturnCachePolicy returnCachePolicy;

/**
 *  缓存数据策略
 */
@property (nonatomic, assign) KCDataCachePolicy dataCachePolicy;

/**
 *  缓存处理服务
 *  用于缓存数据的读写操作
 *  Default @see KCCacheCenter
 */
@property (nonatomic, strong) id<KCCacheProtocol> service;



@end
