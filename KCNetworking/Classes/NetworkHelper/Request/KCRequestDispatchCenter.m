//
//  KCRequestDispatchCenter.m
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import "KCRequestDispatchCenter.h"
#import "KCRequest.h"
#import "KCRequestConstants.h"
#import "KCResponseError.h"
#import <AFNetworking/AFNetworking.h>
#import <pthread.h>
#import "KCRequest+Private.h"

@interface KCRequestDispatchCenter () {
    pthread_mutex_t _lock;//互斥锁
    NSMutableDictionary *_requestsHashTable;
}

@end

@implementation KCRequestDispatchCenter

+ (KCRequestDispatchCenter *)defaultCenter {
    static id defaultCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCenter = [[self alloc] init];
    });
    return defaultCenter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        _requestsHashTable = [NSMutableDictionary dictionary];
        //在程序退出到后台或者即将结束的时候取消请求
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAllRequests) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAllRequests) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}


#pragma mark - Dispatch

- (AFHTTPSessionManager *)configManager:(KCRequest *)request {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    request.manager = manager;

    switch (request.respSerializerType) {
        case KCResponseSerializerTypeRawData: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        case KCResponseSerializerTypeJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
    }
    
    NSMutableSet* acceptableContentTypeSet = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [acceptableContentTypeSet addObject:@"text/html"];
    [acceptableContentTypeSet addObject:@"text/plain"];
    [acceptableContentTypeSet addObject:@"image/*;q=0.8"];
    [manager.responseSerializer setAcceptableContentTypes:acceptableContentTypeSet];
    
    manager.operationQueue.maxConcurrentOperationCount = 3;
    manager.requestSerializer.timeoutInterval = request.timeout;
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    // if api need server username and password
    NSArray* authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString*)authorizationHeaderFieldArray.firstObject password:(NSString*)authorizationHeaderFieldArray.lastObject];
    }
    
    // if api need add custom value to HTTPHeaderField
    NSDictionary* headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [manager.requestSerializer setValue:(NSString*)value forHTTPHeaderField:(NSString*)httpHeaderField];
            }
            else {
                KCLogError(@"[%@ >>]Error, class of key/value in headerFieldValueDictionary should be NSString.", NSStringFromClass(self.class));
            }
        }
    }
    return manager;
}

- (void)dispatchRequest:(KCRequest *)request {
    
    NSMutableString *str = [NSMutableString stringWithFormat:@"\r\n%@ <%p>: request start-%@",[[request class] description],request,request.requestUrl];
    [str appendFormat:@"\r\n*********************************************\r\n"];
    [str appendFormat:@"params:%@",request.requestArgument];
    [str appendFormat:@"\r\n*********************************************\r\n"];
    KCLogInfo(@"%@",str);
    
    AFHTTPSessionManager *manager = [self configManager:request];
    
    [request toggleAccessoriesWillStartCallBack];

    __weak __typeof(self) weakSelf = self;
    
    switch (request.requestMethod) {
        case KCRequestMethodGet: {
            request.sessionTask = [manager GET:request.requestUrl parameters:request.requestArgument progress:request.resumableDownloadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:error];
            }];
            break;
        }
        case KCRequestMethodPost: {
            if (!request.resumableUploadProgressBlock) {
                request.sessionTask = [manager POST:request.requestUrl parameters:request.requestArgument progress:request.resumableUploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    __strong __typeof(weakSelf) self = weakSelf;
                    [self handleRequestResult:task responseObject:responseObject error:nil];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    __strong __typeof(weakSelf) self = weakSelf;
                    [self handleRequestResult:task responseObject:nil error:error];
                }];
            } else {
                request.sessionTask = [manager POST:request.requestUrl parameters:request.requestArgument constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

                } progress:request.resumableUploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    __strong __typeof(weakSelf) self = weakSelf;
                    [self handleRequestResult:task responseObject:responseObject error:nil];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    __strong __typeof(weakSelf) self = weakSelf;
                    [self handleRequestResult:task responseObject:nil error:error];
                }];
//                request.sessionTask = [manager POST:request.requestUrl parameters:request.requestArgument constructingBodyWithBlock:request.constructingBodyBlock progress:request.resumableUploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                    __strong __typeof(weakSelf) self = weakSelf;
//                    [self handleRequestResult:task responseObject:responseObject error:nil];
//                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                    __strong __typeof(weakSelf) self = weakSelf;
//                    [self handleRequestResult:task responseObject:nil error:error];
//                }];
            }
            break;
        }
        case KCRequestMethodHead: {
            request.sessionTask = [manager HEAD:request.requestUrl parameters:request.requestArgument success:^(NSURLSessionDataTask * _Nonnull task) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:error];
            }];
            break;
        }
        case KCRequestMethodPut: {
            request.sessionTask = [manager PUT:request.requestUrl parameters:request.requestArgument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:error];
            }];
            break;
        }
        case KCRequestMethodDelete: {
            request.sessionTask = [manager DELETE:request.requestUrl parameters:request.requestArgument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:error];
            }];
            break;
        }
        case KCRequestMethodPatch: {
            request.sessionTask = [manager PATCH:request.requestUrl parameters:request.requestArgument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:error];
            }];
            break;
        }
        default: {
            KCResponseError *error = [KCResponseError errorWithCode:kCCResponseErrorCodeFailRequst userInfo:nil];
            [self failWithParam:[request handleFailParam:nil error:error] RParam:request];
            [self resolveRequest:request];
            return;
        }
    }
    
    [self addRequest:request];
}

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    
    NSString *key = [self requestTaskHashKey:task];
    KCRequest *request = _requestsHashTable[key];
    
    if (!request) {
        KCLogError(@"[%@ >>]Can not get reqest in hash table", NSStringFromClass(self.class));
        return;
    }
    
    if (error) {
        //failed
        [self failWithParam:[request handleFailParam:nil error:error] RParam:request];
    } else {
        //succeed
        __weak __typeof(self) weakSelf = self;
        __block KCRequest *b_request = request;
        if ([(NSHTTPURLResponse *)task.response statusCode] > 0) {
            if (responseObject || request.requestMethod == KCRequestMethodHead) {
                //Response object is not null or HTTP method is HEAD
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
                    BOOL success = YES;
                    id result = [b_request handleSuccessParam:responseObject result:&success];
                    if (success) {
                        __strong __typeof(weakSelf) self = weakSelf;
                        [self SuccessWithlParam:result RParam:b_request];
                    } else {
                        __strong __typeof(weakSelf) self = weakSelf;
                        [self failWithParam:[b_request handleFailParam:result error:nil] RParam:b_request];
                    }
                });
            } else {
                //empty response object
                KCResponseError *error = [KCResponseError errorWithCode:kCCResponseErrorCodeEmptyResponse userInfo:nil];
                [self failWithParam:[request handleFailParam:nil error:error] RParam:request];
            }
        } else {
            //invalid status code
            //@see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
            KCResponseError *error = [KCResponseError errorWithCode:kCCResponseErrorCodeInvalidResponseCode userInfo:nil];
            [self failWithParam:[request handleFailParam:responseObject error:error] RParam:request];
        }
    }
}

//dispatch

- (void)failWithParam:(id)lParam RParam:(KCRequest *)rParam {
    
    KCLogInfo(@"\r\n%@ failure-%@<%p> \r\nparam:\r\n*********************************************\r\nresponse:%@\r\nerror:%@\r\n*********************************************\r\n",
              [[rParam class] description],
              rParam.requestUrl,
              rParam,rParam.
              sessionTask.response,
              lParam);

    __weak __typeof(self) weakSelf = self;
    __block KCRequest *b_request = rParam;
    if (rParam.retryTimes > 0 && rParam.status != KCRequestStatusCanceled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelf) self = weakSelf;
            [self removeRequest:b_request];
            [b_request toggleAccessoriesWillRetryCallBack];
            [self dispatchRequest:b_request];
            b_request.retryTimes --;
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(){
            __strong __typeof(weakSelf) self = weakSelf;
            [b_request failWithError:lParam];
            [self removeRequest:b_request];
        });
    }
}

- (void)SuccessWithlParam:(id)lParam RParam:(KCRequest *)rParam {
    
    NSMutableString *str_response = [NSMutableString stringWithFormat:@"\r\n"];
    [str_response appendFormat:@"%@ sucess-<%p> resposnse %zd -%@",[[rParam class] description],rParam,[(NSHTTPURLResponse*)rParam.sessionTask.response statusCode],rParam.sessionTask.currentRequest.URL.absoluteString];
    
    [str_response appendString:@"\r\n*********************************************\r\n"];
    [str_response appendFormat:@"response:\r\n%@\r\n",lParam];
    [str_response appendString:@"\r\n*********************************************\r\n"];
    
    KCLogInfo(@"%@",str_response);
    
    __block KCRequest *b_request = rParam;
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^(){
        __strong __typeof(weakSelf) self = weakSelf;
        [b_request successWithResult:lParam];
        [self removeRequest:b_request];
    });
}

#pragma mark - Hash

- (void)addRequest:(KCRequest *)request {
    
    [self resolveRequest:request];

    if (request.sessionTask != nil) {
        NSString *key = [self requestTaskHashKey:request.sessionTask];
        if (key.length) {
            pthread_mutex_lock(&_lock);
            _requestsHashTable[key] = request;
            pthread_mutex_unlock(&_lock);
        }
    }
}

- (void)removeRequest:(KCRequest *)request {
    [self removeRequest:request hash:nil];
}

- (void)removeRequest:(KCRequest *)request hash:(NSString *)hash {
    //Remove
    NSString *key = [self requestTaskHashKey:request.sessionTask];
    if (hash) {
        key = hash;
    }
    if (key.length) {
        pthread_mutex_lock(&_lock);
        [_requestsHashTable removeObjectForKey:key];
        pthread_mutex_unlock(&_lock);
    }
    
    if (!hash) {
        KCLogInfo(@"[%@ >>]Request queue size = %lu", NSStringFromClass(self.class), (unsigned long)[_requestsHashTable count]);
    }
}

- (void)promiseRequest:(KCRequest *)request {
    
    NSString *key = [self requestHashKey:request];
    if (key.length) {
        pthread_mutex_lock(&_lock);
        _requestsHashTable[key] = request;
        pthread_mutex_unlock(&_lock);
    }
}

- (void)resolveRequest:(KCRequest *)request {
    NSString *hash = [self requestHashKey:request];
    [self removeRequest:request hash:hash];
}
//哈希值比对，确认唯一性
- (NSString*)requestTaskHashKey:(NSURLSessionTask*)task {
    return _S(@"%lu", (unsigned long)[task hash]);
}

- (NSString*)requestHashKey:(KCRequest *)request {
    return _S(@"%lu", (unsigned long)[request hash]);
}


#pragma mark - Cancel

- (void)cancelRequest:(KCRequest *)request {
    [request cancel];
    [self removeRequest:request];
}

- (void)cancelAllRequests {
    NSDictionary *copyHash = [_requestsHashTable copy];
    for (NSString *key in copyHash.allKeys) {
        KCRequest *reqest = copyHash[key];
        [reqest stop];
    }
}


@end
