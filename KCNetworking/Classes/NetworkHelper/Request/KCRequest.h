//
//  KCRequest.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "KCRequestConstants.h"
#import "KCRequestEnumrator.h"
#import "KCResponse.h"
#import "KCRequestProtocol.h"
#import "KCResponseError.h"
#import "KCPromise.h"

@interface KCRequest : NSObject {
    
    @protected
    KCResponseSerializerType _respSerializerType;
}

// URL
@property (nonatomic, copy) NSString *requestUrl;

// Request arguments
@property (nonatomic, strong) id requestArgument;

// Request method
@property (nonatomic, assign) KCRequestMethod requestMethod;

// Request session manager
@property (nonatomic, strong) AFHTTPSessionManager *manager;

// Request session task
@property (nonatomic, strong) NSURLSessionTask *sessionTask;

// Request delegate
@property (nonatomic, weak) id<KCRequestDelegate> delegate;

// Request timeout stamp
@property (nonatomic, assign) NSTimeInterval timeout;

// Retry times
@property (nonatomic, assign) NSInteger retryTimes;

// status
@property (nonatomic, assign, readonly) KCRequestStatus status;

/**
 *  Request serializer type.
 *  You should better use KCResponseSerializerTypeRawData
 *  for files download task such as image
 */
@property (nonatomic, assign) KCResponseSerializerType respSerializerType;

/**
 *  Response object
 *  This object is nil until get data from server succeed
 */
@property (nonatomic, strong, readonly) KCResponse *response;

/**
 *  Response error
 *  There are some default error types catched by KCRequest.
 *  You can get the object no matter what bad things happend.
 *  And you can get error info in this object.
 */
@property (nonatomic, strong, readonly) KCResponseError *error;

/**
 *  @param result the final result for this request (serialized if you
 *  implamented - (id)handleSuccessParam:(id)responseObject )
 *
 *  @param request  the request instance
 */
@property (nonatomic, copy) KCSuccessHandler successHandler;
/**
 *  @param error    the request's error
 *  @param request  the request instance
 */
@property (nonatomic, copy) KCFailureHandler failureHandler;



#pragma mark - Operate

/**
 *  Add into dispatch center and start request.
 */
- (void)start;

/**
 *  Remove the request from dispatch center and cancel it,
 *  so the request may be dealloced.
 */
- (void)stop;

/**
 *  Clear delegets, callbacks and cancel session task,
 *  but accessories still exist.
 */
- (void)cancel;

/**
 *  Request Action
 *  You can overwrite this method but call super 
 *  in every subclasses to get a better Programming Experience
 *
 *  @see samples
 *
 *  @return the request instance
 */
- (KCRequest *)requestWithSuccess:(KCSuccessHandler)success failure:(KCFailureHandler)failure;

/**
 *  Append more callback
 *  These callbacks's only have one param: the request instance
 *
 *  @return the request instance
 */
- (KCRequest *)appendCallback:(KCEventHandler)callback;


/**
 *  Append/Remove one accessory to hook the request action.
 *  Inclueding will start, will stop, did stop and complete
 *
 *  @return the request instance
 */
- (KCRequest *)appendAccessory:(id<KCRequestAccessory>)accessory;
- (KCRequest *)removeAccessory:(id<KCRequestAccessory>)accessory;



#pragma mark - Overwrite Me

/**
 *  Model serialize operate, overwrite this method if needed
 *  Success with cache data will not call this mothod.
 *  The Mothod is called in background thread.
 *
 *  @param responseObject Networking response object
 *
 *  @return Serialized model
 */
- (id)handleSuccessParam:(id)responseObject;

/**
 *  Validate current response
 *  Defaut condition is `statusCode >= 200 && statusCode <= 299`
 *
 *  Overwrite it to implement your custom validator
 *
 *  @return validate or not
 */
- (BOOL)statusCodeValidator;

/**
 *  Default is self.sessionTask.response.statusCode
 *
 *  Overwrite it in the way of an agreement knocked by you and yor server
 *
 *  @return statusCode
 */
- (NSString *)responseStatusCode;

/**
 *  Default is nil, and the final massage will be 
 *  `business error` in ../Exception/KCRequest.strings.
 *  You can also change default massages in this file.
 *
 *  Overwrite it to show a suitable message for the 
 *  request when your server is not that friendly
 *
 *  @return the massage
 */
- (NSString *)responseMessage;

/**
 *  Overwrite it if your server api need server username and password
 *  Inser username at first index and password in the last
 *  Default is nil
 *
 *  @return Authorization fields
 */
- (NSArray*)requestAuthorizationHeaderFieldArray;

/**
 *  Overwrite it if api need add custom value to HTTPHeaderField
 *
 *  @return HTTP Header fields
 */
- (NSDictionary*)requestHeaderFieldValueDictionary;

/**
 *  Overwrite it to construct your HTTP Body by your self
 *
 *  @return KCConstructingBlock
 */
- (KCConstructingBlock)constructingBodyBlock;

/**
 *  Overwrite it to catch progress of upload request
 *
 *  @return KCUploadProgressBlock
 */
- (KCUploadProgressBlock)resumableUploadProgressBlock;

/**
 *  Overwrite it to catch progress of download request
 *
 *  @return KCDownloadProgressBlock
 */
- (KCDownloadProgressBlock)resumableDownloadProgressBlock;


/**
 *  Overwrite it to generate the reachability level
 *  @default KCReachabilityLevelLocal
 *  @see KCReachabilityLevel
 *
 *  @return KCReachabilityLevel
 */
- (KCReachabilityLevel)getReachabilityLevel;

@end


@interface KCRequest (Promise)

/**
 *  Generate the request to act as Promise
 *  @see API in KCPromise
 *
 *  @return the promise object
 */
- (KCPromise *)promise;
+ (KCPromise *)promise;

/**
 *  Set request argument, use this mthod replace setRequestArgument: 
 *  and you can get a better Programming Experience
 *
 *  @param argument argument
 *
 *  @return the request instance
 */
- (KCRequest *)bindRequestArgument:(id)argument;

@end
