//
//  KCRequestDispatchCenter.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KCRequest;

@interface KCRequestDispatchCenter : NSObject

+ (KCRequestDispatchCenter *)defaultCenter;

- (void)dispatchRequest:(KCRequest *)request;

- (void)cancelRequest:(KCRequest *)request;

- (void)cancelAllRequests;

- (void)promiseRequest:(KCRequest *)request;

- (void)resolveRequest:(KCRequest *)request;

@end
