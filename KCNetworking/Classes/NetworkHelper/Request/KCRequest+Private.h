//
//  KCRequest+Private.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import "KCRequest.h"

@interface KCRequest(Private)

- (id)handleSuccessParam:(id)responseObject result:(BOOL *)result;

- (id)handleFailParam:(id)responseObject error:(NSError*)error;

- (void)successWithResult:(id)result;

- (void)failWithError:(id)error;

- (void)complete;

- (void)toggleAccessoriesWillStartCallBack;

- (void)toggleAccessoriesCanceledCallBack;

- (void)toggleAccessoriesWillStopCallBack;

- (void)toggleAccessoriesDidStopCallBack;

- (void)toggleAccessoriesDidCompleteCallBack;

- (void)toggleAccessoriesWillRetryCallBack;

@end
