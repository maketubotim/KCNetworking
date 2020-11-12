//
//  KCResponseError.m
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import "KCResponseError.h"



NSString * const kCCResponseErrorCodeDomain = @"cn.com.KCREQEST";

@interface KCResponseError ()

@property (nonatomic, strong) NSString *_localizedDescription;

@end

@implementation KCResponseError
@synthesize _localizedDescription;

- (id)initWithDomain:(NSString *)domain code:(KCResponseErrorCode)code userInfo:(NSDictionary *)dict description:(NSString *)description {
    self = [super initWithDomain:domain code:code userInfo:dict];
    if (self) {
        self._localizedDescription = description;
    }
    return self;
}

+ (id)errorWithCode:(KCResponseErrorCode)code userInfo:(NSDictionary *)userInfo {
    KCResponseError *error = [[KCResponseError alloc] initWithDomain:kCCResponseErrorCodeDomain code:code userInfo:userInfo description:[self descriptionForCode:code]];
    return error;
}

+ (NSString *)descriptionForCode:(KCResponseErrorCode)code {
    switch (code) {
        case kCCResponseErrorCodeEmptyResponse:
            return @"网络连接失败，请稍后重试";
        case kCCResponseErrorCodeResponseNotJsonString:
            return @"网络连接失败，请稍后重试";
        case kCCResponseErrorCodeNoConnection:
            return @"请检查网络连接是否正常";
        case kCCResponseErrorCodeUserCancel:
            return @"取消请求";
        case kCCResponseErrorCodeInternalError:
            return @"网络连接失败，请稍后重试";
        case kCCResponseErrorCodeBusinessError:
            return @"请求数据异常";
        case kCCResponseErrorCodeFailRequst:
            return @"错误的请求";
        case kCCResponseErrorCodeTimeOut:
            return @"请求超时";
        case kCCResponseErrorCodeInvalidResponseCode:
            return @"错误的网络状态码";
        case kCCResponseErrorUnkowenError:
        default:
            return @"服务器异常,请稍后再试";
    }
}

- (NSString *)localizedDescription {
    return self._localizedDescription;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\r\nDomain: %@\r\nCode: %zd\r\nLocalized: %@\r\nUserInfo: %@",self.domain,self.code,self.localizedDescription,self.userInfo];
}

@end

