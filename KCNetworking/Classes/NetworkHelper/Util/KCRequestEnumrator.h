//
//  KCRequestEnumrator.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#ifndef KCRequestEnumrator_h
#define KCRequestEnumrator_h

typedef NS_ENUM(NSInteger, KCRequestMethod) {
    KCRequestMethodGet = 0,
    KCRequestMethodPost,
    KCRequestMethodHead,
    KCRequestMethodPut,
    KCRequestMethodDelete,
    KCRequestMethodPatch
};

typedef NS_ENUM(NSInteger, KCResponseSerializerType) {
    //适用与普通请求
    KCResponseSerializerTypeJSON = 0,
    //适用于文件传输
    KCResponseSerializerTypeRawData,
};

typedef NS_ENUM(NSInteger, KCReachabilityLevel) {
    KCReachabilityLevelLocal,
    //待实现
    KCReachabilityLevelReal
};

typedef NS_ENUM(NSInteger, KCRequestStatus) {
    //默认状态
    KCRequestStatusNone,
    //正在运行
    KCRequestStatusRunning,
    //手动结束
    KCRequestStatusStop,
    //手动取消
    KCRequestStatusCanceled,
    //正常结束
    KCRequestStatusComplete
};

// 网络请求策略:

typedef NS_ENUM(NSUInteger, KCRequestCachePolicy) {
    
    // 永远忽略缓存,仅读远程数据
    KCRequestReloadRemoteDataIgnoringCacheData,
    
    // 优先先读取缓存,若读取成功,不再发起请求,反之读远程数据
    KCRequestReturnCacheDataElseReloadRemoteData,
    
    // 优先先读取缓存,若读取成功,先执行回调逻辑,再读远程数据,反之读远程数据
    KCRequestReturnCacheDataThenReloadRemoteData,
    
    // 优先读取远程数据,若读取失败,读取缓存
    KCRequestReloadRemoteDataElseReturnCacheData,
};

// 缓存读取策略:

typedef NS_ENUM(NSUInteger, KCReturnCachePolicy) {
    
    // 按设置的缓存过期时间读取
    KCReturnCacheDataByFireTime,
    
    // 若有缓存,强制重新激活缓存后读取
    KCReloadRevalidatingCacheData
};

// 数据缓存策略:

typedef NS_ENUM(NSUInteger, KCDataCachePolicy) {
    
    // 缓存解析后的模型(如果使用默认的缓存服务,要求模型层实现NSCoding协议)
    KCCachePolicyModel,
    
    // 缓存JSON对象或者元数据,取决于KCResponseSerializerType
    KCCachePolicyRawData,
};

#endif /* KCRequestEnumrator_h */
