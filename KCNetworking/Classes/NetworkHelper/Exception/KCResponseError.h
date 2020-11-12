//
//  KCResponseError.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KCResponseErrorCode) {
    /**
     配置Post请求体(读取文件)失败
     */
    kCCResponseErrorCodeConstructingBody = 10000,
    /**
     空的返回值
     */
    kCCResponseErrorCodeEmptyResponse,
    /**
     返回结果不为JSON字符串
     */
    kCCResponseErrorCodeResponseNotJsonString,
    /**
     没有网络连接
     */
    kCCResponseErrorCodeNoConnection,
    /**
     错误的网络状态码
     */
    kCCResponseErrorCodeInvalidResponseCode,
    /**
     取消了此次网络请求
     */
    kCCResponseErrorCodeUserCancel,
    
    /**
     内部程序处理逻辑错误
     */
    kCCResponseErrorCodeInternalError,
    /**
     业务逻辑错误
     */
    kCCResponseErrorCodeBusinessError,
    
    /**
     错误的请求
     */
    kCCResponseErrorCodeFailRequst,
    /**
     请求超时
     */
    kCCResponseErrorCodeTimeOut,
    /**
     未知错误
     */
    kCCResponseErrorUnkowenError,
};


@interface KCResponseError : NSError

+ (id)errorWithCode:(KCResponseErrorCode)code
           userInfo:(NSDictionary *)userInfo;


- (id)initWithDomain:(NSString *)domain
                code:(KCResponseErrorCode)code
            userInfo:(NSDictionary *)dict
         description:(NSString *)description;

@end


FOUNDATION_EXTERN NSString * const kCCResponseErrorCodeDomain;

