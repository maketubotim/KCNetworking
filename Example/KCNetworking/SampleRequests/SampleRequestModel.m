//
//  SampleRequestModel.m
//  KCNetworking
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import "SampleRequestModel.h"

@implementation SampleRequestModel

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
//    [params setObject:self.foo?:@"" forKey:@"foo"];
    [params setObject:self.pageNumber?:@(1) forKey:@"pageNumber"];
    [params setObject:self.pageSize?:@(10) forKey:@"pageSize"];
    return params;
}

@end
