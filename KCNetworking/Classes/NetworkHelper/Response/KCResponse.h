//
//  KCResponse.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCRequestEnumrator.h"

@interface KCResponse : NSObject <NSCoding>

- (instancetype)initWithRespType:(KCResponseSerializerType)type
                     sessionTask:(NSURLSessionTask *)task
                  responseObject:(id)responseObject;

@property (nonatomic, strong, readonly) NSString *responseString;

@property (nonatomic, strong, readonly) NSObject<NSCoding> *responseJSONObject;

@property (nonatomic, strong, readonly) NSData *responseData;

@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;

@property (nonatomic, strong, readonly) NSString *suggestedFilename;

@property (nonatomic, assign, readonly) NSInteger statusCode;

@end
