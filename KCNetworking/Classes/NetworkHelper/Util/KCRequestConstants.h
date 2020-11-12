//
//  KCRequestConstants.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#ifdef LOG_LEVEL_DEF
//可选载入CocoaLumberjack
#import <CocoaLumberjack/CocoaLumberjack.h>
#endif

#import <Foundation/Foundation.h>

@class KCRequest;
@class KCResponse;
@class KCResponseError;
@protocol KCMultipartFormData;

typedef void (^KCEventHandler)(KCRequest *request);
typedef void (^KCSuccessHandler)(id result, KCRequest *request);
typedef void (^KCFailureHandler)(KCResponseError *error, KCRequest *request);
typedef void (^KCConstructingBlock)(id<KCMultipartFormData> formData);
typedef void (^KCDownloadProgressBlock)(NSProgress *downloadProgress);
typedef void (^KCUploadProgressBlock)(NSProgress *uploadProgress);

static int const ddLogLevel = 1111;

FOUNDATION_EXTERN void KCLog(NSString* format, ...) NS_FORMAT_FUNCTION(1, 2);


void blockCleanUp(__strong void(^*block)(void));
//attribute((cleanup(...)))，用于修饰一个变量，在它的作用域结束时可以自动执行一个指定的方法
//指定一个cleanup方法，注意入参是所修饰变量的地址，类型要一样,对于指向objc对象的指针(id *)，如果不强制声明__strong默认是__autoreleasing，造成类型不匹配
#ifndef onExit
#define onExit\
    __strong void(^block)(void) __attribute__((cleanup(blockCleanUp), unused)) = ^
#endif

#ifdef LOG_LEVEL_DEF

#define KCLogInfo    DDLogInfo
#define KCLogError   DDLogError
#define KCLogWarn    DDLogWarn
#define KCLogDebug   DDLogDebug
#define KCLogVerbose DDLogVerbose

#else

#define KCLogInfo    KCLog
#define KCLogError   KCLog
#define KCLogWarn    KCLog
#define KCLogDebug   KCLog
#define KCLogVerbose KCLog

#endif

#ifndef _S
#define _S(str,...) [NSString stringWithFormat:str,##__VA_ARGS__]
#endif

#define HandlerDeclare Success:(KCSuccessHandler)success failure:(KCFailureHandler)failure

#define kCCCacheName @"cn_com_cache_kcrequest"
