//
//  KCRequestProtocol.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#ifndef KCRequestProtocol_h
#define KCRequestProtocol_h

@class KCRequest;
@protocol AFMultipartFormData;

@protocol KCRequestDelegate <NSObject>

- (void)requestFinished:(KCRequest*)request;
- (void)requestFailed:(KCRequest*)request;

@end

@protocol KCRequestAccessory <NSObject>

@optional
- (void)requestWillStart:(KCRequest*)request;
- (void)requestCanceled:(KCRequest*)request;
- (void)requestWillRetry:(KCRequest*)request;
- (void)requestWillStop:(KCRequest*)request;
- (void)requestDidStop:(KCRequest*)request;
- (void)requestDidComplete:(KCRequest*)request;
@end

@protocol KCMultipartFormData <AFMultipartFormData>

@end

#endif /* KCRequestProtocol_h */
