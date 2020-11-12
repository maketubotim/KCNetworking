//
//  KCRequest.m
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import "KCRequest.h"
#import "KCRequestDispatchCenter.h"
#import "KCResponseError.h"
#import "KCRequest+Private.h"

@interface KCRequest () {
    KCPromise *_promise;
}

@property (nonatomic, assign) KCRequestStatus status;

@property (nonatomic, strong) KCResponse *response;

@property (nonatomic, copy) NSHashTable *callbacks;

@property (nonatomic, strong) NSHashTable *accesoris;

@property (nonatomic, strong) KCResponseError *error;

@end

@implementation KCRequest

#pragma mark - Lifecycle

- (void)dealloc {
    [self.manager invalidateSessionCancelingTasks:YES];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.accesoris = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        self.callbacks = [NSHashTable hashTableWithOptions:NSHashTableCopyIn];
        self.timeout = 60.f;
        self.respSerializerType = KCResponseSerializerTypeJSON;
    }
    return self;
}

#pragma mark - Action

- (void)start {
    [[KCRequestDispatchCenter defaultCenter] dispatchRequest:self];
    self.status = KCRequestStatusRunning;
}

- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    [[KCRequestDispatchCenter defaultCenter] cancelRequest:self];
    self.status = KCRequestStatusStop;
    [self toggleAccessoriesDidStopCallBack];
}

- (void)cancel {
    [self.sessionTask cancel];
    self.successHandler = nil;
    self.failureHandler = nil;
    self.delegate = nil;
    self.status = KCRequestStatusCanceled;
    [self toggleAccessoriesCanceledCallBack];
}

- (KCRequest *)appendAccessory:(id<KCRequestAccessory>)accessory {
    [self.accesoris addObject:accessory];
    return self;
}
- (KCRequest *)removeAccessory:(id<KCRequestAccessory>)accessory {
    [self.accesoris removeObject:accessory];
    return self;
}

- (KCRequest *)requestWithSuccess:(KCSuccessHandler)success failure:(KCFailureHandler)failure {
    self.successHandler = success;
    self.failureHandler = failure;
    [self start];
    return self;
}

- (KCRequest *)appendCallback:(KCEventHandler)callback {
    [self.callbacks addObject:callback];
    return self;
}

#pragma mark - Overwrite Me

- (id)handleSuccessParam:(id)responseObject {
    return responseObject;
}

- (KCReachabilityLevel)getReachabilityLevel {
    return KCReachabilityLevelLocal;
}

//Validator
- (NSString *)responseStatusCode {
    return _S(@"%zd",self.response.statusCode);
}

- (NSString *)responseMessage {
    //该方法需要子类视具体接口业务而定
    return nil;
}

- (BOOL)statusCodeValidator {
    //[!] 当HTTP请求方法为HEAD时,最好不要重写此逻辑
    NSInteger statusCode = [[self responseStatusCode] integerValue];
    return statusCode >= 200 && statusCode <= 299;
}


- (NSArray*)requestAuthorizationHeaderFieldArray { return nil; }

- (NSDictionary*)requestHeaderFieldValueDictionary { return nil; }

- (KCConstructingBlock)constructingBodyBlock { return nil; }

- (KCUploadProgressBlock)resumableUploadProgressBlock { return nil; }

- (KCDownloadProgressBlock)resumableDownloadProgressBlock { return nil; }

@end


@implementation KCRequest (Promise)

+ (KCPromise *)promise {
    return [[self.class new] promise];
}

- (KCPromise *)promise {
    
    if (!_promise) {
        _promise = ({
            KCPromise *promise = [KCPromise promise];
            
            __weak __typeof(self) weakSelf = self;
            promise.run = ^(){
                __strong __typeof(weakSelf) self = weakSelf;
                [self requestWithSuccess:NULL failure:NULL];
            };
            
            promise.done = ^() {
                __strong __typeof(weakSelf) self = weakSelf;
                if (self.status == KCRequestStatusRunning) {
                    [self stop];
                }
            };
            
            //[!]若不持有一个Request的引用
            //[!]将产生空指针中断promise链
            
            [[KCRequestDispatchCenter defaultCenter] promiseRequest:self];
            
            promise;
        });
    }
    return _promise;
}

- (KCRequest *)bindRequestArgument:(id)argument {
    self.requestArgument = argument;
    return self;
}

@end


@implementation KCRequest(Private)

- (void)complete {
    if (_status != KCRequestStatusRunning) {
        return;
    }
    for (KCEventHandler handler in _callbacks) {
        handler(self);
    }
    [self toggleAccessoriesDidCompleteCallBack];
}

- (id)handleSuccessParam:(id)responseObject result:(BOOL *)result {
    
    //刷新Response对象
    if (self.response) {
        self.response = nil;
    }
    self.response = [[KCResponse alloc] initWithRespType:self.respSerializerType
                                             sessionTask:self.sessionTask
                                          responseObject:responseObject];
    
    //状态码合法性验证
    *result = [self statusCodeValidator];
    
    return [self handleSuccessParam:responseObject];
}

- (id)handleFailParam:(id)responseObject error:(NSError*)error {
    
    KCResponseError *handleError = nil;
    
    if (responseObject) {
        
        /// 服务端业务/系统错误
        
        NSString *desp = [self responseMessage]?:NSLocalizedStringFromTable(@"business error", @"CCResponseError", nil);
        handleError = [[KCResponseError alloc] initWithDomain:kCCResponseErrorCodeDomain
                                                         code:kCCResponseErrorCodeBusinessError
                                                     userInfo:nil
                                                  description:desp];
    } else {
        
        /// NA端系统请求失败
        /// 默认未知错误
        
        NSInteger code = kCCResponseErrorUnkowenError;
        
        if (error) {
            
            code = error.code;
            
            if (code == NSURLErrorCancelled) {
                //用户主动cancel请求
                code = kCCResponseErrorCodeUserCancel;
            } else if (code == NSURLErrorNotConnectedToInternet){
                //网络连接失败
                code = kCCResponseErrorCodeNoConnection;
            } else if (code == NSURLErrorTimedOut) {
                //请求超时
                code = kCCResponseErrorCodeTimeOut;
            }
        }
        
        NSDictionary *userInfo = self.respSerializerType==KCResponseSerializerTypeJSON?responseObject:nil;
        handleError = [KCResponseError errorWithCode:code userInfo:userInfo];
    }
    
    return self.error = handleError;
}

- (void)successWithResult:(id)result{
    [self toggleAccessoriesWillStopCallBack];
    if (self.successHandler) {
        @autoreleasepool {
            self.successHandler(result, self);
        }
    }
    if ([self.delegate respondsToSelector:@selector(requestFinished:)]) {
        @autoreleasepool {
            [self.delegate requestFinished:self];
        }
    }
    
    //promise
    if (_promise) {
        [_promise fulfill:result];
    }
    
    [self complete];
    [self toggleAccessoriesDidStopCallBack];
}

- (void)failWithError:(id)error {
    [self toggleAccessoriesWillStopCallBack];
    if (self.failureHandler) {
        @autoreleasepool {
            self.failureHandler(error, self);
        }
    }
    if ([self.delegate respondsToSelector:@selector(requestFinished:)]) {
        @autoreleasepool {
            [self.delegate requestFinished:self];
        }
    }
    
    //promise
    if (_promise) {
        [_promise reject:error];
    }
    [self complete];
    [self toggleAccessoriesDidStopCallBack];
}

- (void)toggleAccessoriesWillStartCallBack {
    for (id<KCRequestAccessory> accessory in _accesoris) {
        if ([accessory respondsToSelector:@selector(requestWillStart:)]) {
            [accessory requestWillStart:self];
        }
    }
}
- (void)toggleAccessoriesCanceledCallBack {
    for (id<KCRequestAccessory> accesory in _accesoris) {
        if ([accesory respondsToSelector:@selector(requestCanceled:)]) {
            [accesory requestCanceled:self];
        }
    }
}
- (void)toggleAccessoriesWillStopCallBack {
    for (id<KCRequestAccessory> accesory in _accesoris) {
        if ([accesory respondsToSelector:@selector(requestWillStop:)]) {
            [accesory requestWillStop:self];
        }
    }
}
- (void)toggleAccessoriesDidStopCallBack {
    for (id<KCRequestAccessory> accessory in _accesoris) {
        if ([accessory respondsToSelector:@selector(requestDidStop:)]) {
            [accessory requestDidStop:self];
        }
    }
}
- (void)toggleAccessoriesDidCompleteCallBack {
    for (id<KCRequestAccessory> accessory in _accesoris) {
        if ([accessory respondsToSelector:@selector(requestDidComplete:)]) {
            [accessory requestDidComplete:self];
        }
    }
}
- (void)toggleAccessoriesWillRetryCallBack {
    for (id<KCRequestAccessory> accessory in _accesoris) {
        if ([accessory respondsToSelector:@selector(requestWillRetry:)]) {
            [accessory requestWillRetry:self];
        }
    }
}

@end


