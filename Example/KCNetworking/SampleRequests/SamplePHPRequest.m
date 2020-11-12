//
//  SamplePHPRequest.m
//  KCNetworking
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//


#import "SamplePHPRequest.h"
#import "SampleRequestModel.h"

@implementation SamplePHPRequest

- (KCRequest *)requestWithSuccess:(KCSuccessHandler)success failure:(KCFailureHandler)failure {
    
    if (self.requestArgument) {
        
        SampleRequestModel *model = self.requestArgument;
        if (![model isKindOfClass:SampleRequestModel.class]) {
            //若参数拼接发生错误,可在此抛出异常,并阻止发起请求.
            KCResponseError *error = [KCResponseError errorWithCode:kCCResponseErrorCodeBusinessError
                                                           userInfo:nil];
            if (failure) {
                failure(error, self);
            }
            return self;
        }
        
        //将self.requestArgument 转成字典格式
        self.requestArgument = model.dictionaryValue;
    }
    
    //这个url用于测试失败的情况
//    self.requestUrl = @"http://nj03-vip-sandbox.nj03.xincc.com:8008/common-api/data/Superproductrecommendlist";
    //这个url用于测试成功的请求
//    self.requestUrl = @"http://www.chojer.com/sys.php/api/hot_search";
    self.requestUrl = @"http://api.xlxili.com/xili/api/mat/getMainMatList";
    self.requestMethod = KCRequestMethodPost;
    self.requestCachePolicy = KCRequestReloadRemoteDataIgnoringCacheData;
    self.dataCachePolicy = KCCachePolicyRawData;
    self.retryTimes = 3;
    self.timeout = 3;
    return [super requestWithSuccess:success failure:failure];
}

- (KCConstructingBlock)constructingBodyBlock {
    
    return ^(id<KCMultipartFormData> formData) {
        
        NSMutableDictionary *reqData = [NSMutableDictionary dictionaryWithCapacity:0];
        [reqData setObject:@(1) forKey:@"pageNum"];
        [reqData setObject:@(20) forKey:@"pageSize"];
        [reqData setObject:@(1) forKey:@"type"];
        [reqData setObject:@(1) forKey:@"sort"];
        [reqData setObject:@(1) forKey:@"productType"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:@{@"clientTerminal":@"ios"} forKey:@"clientInfo"];
        [params setObject:reqData forKey:@"reqData"];
        
        NSError *err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&err];
        if (!data || err) {return;}
        
        
        /**
         *  某些场景要求在参数POST前面加上一个key
         */
        [formData appendPartWithFormData:data name:@"request"];
        
    };
}

- (id)handleSuccessParam:(id)responseObject
{
    id response = [super handleSuccessParam:responseObject];
    //model解析, 该方法将在后台线程运行, 无需额外的线程操作
    //...
    return response;
}


@end
